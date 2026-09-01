import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/festas/festas.dart';
import '../../../../core/observability/app_logger.dart';
import '../../domain/pedido.dart';
import 'lista_event.dart';
import 'lista_state.dart';

export 'lista_event.dart';
export 'lista_state.dart';

/// A composição de uma festa que não existe — LIST-31.
///
/// Zero cabeças, e por isso a guarda de `CalculadoraDaFesta.calcular` devolve
/// lista vazia, total 0 e nenhum essencial. É o **mesmo caminho** de "festa
/// sem ninguém": um segundo caminho para o estado vazio poderia divergir dele.
///
/// A duração é a default do produto e não influencia nada: sem pessoas, o
/// fator de RN-02 não chega a multiplicar item nenhum.
final ComposicaoDaFesta _semNinguem = ComposicaoDaFesta(
  contagem: ContagemDePessoas(),
  duracaoHoras: 4,
);

/// O estado da tela Lista — LIST-10, LIST-31, LIST-32.
///
/// É o **único** lugar desta feature que chama `CalculadoraDaFesta.calcular` e
/// `faixaRealDaLista`. Nenhum widget faz conta: eles leem `state.resultado` e
/// `state.faixaReal` (LIST-07).
///
/// **Este bloc não navega** (AD-020): quem chama `context.go` é a página.
///
/// Assina `observarFesta` na construção, e continua assinado enquanto a tela
/// vive: outra aba da festa (`galera`, RN-21) pode mudar a composição com a
/// Lista viva no `indexedStack`.
class ListaBloc extends Bloc<ListaEvent, ListaState> {
  ListaBloc(
    this._festas,
    this._logger, {
    required String festaId,
  })  : _festaId = festaId,
        super(const ListaState()) {
    on<FestaRecebida>(_aoReceberFesta);
    on<ObservacaoFalhou>(_aoFalharObservacao);
    on<GravacaoFalhou>(_aoFalharGravacao);
    on<ModoAlternado>(_aoAlternarModo);
    on<ItemExpandido>(_aoExpandirItem);
    on<QuantidadeAjustada>(_aoAjustarQuantidade);
    on<PrecoAjustado>(_aoAjustarPreco);
    on<OverridesRestaurados>(_aoRestaurarOverrides);
    on<ItemAlternadoNoCarrinho>(_aoAlternarNoCarrinho);
    on<PedidoConfirmado>(_aoConfirmarPedido);

    _inscricao = _festas.observarFesta(festaId).listen(
          (festa) => add(FestaRecebida(festa)),
          onError: (Object erro, StackTrace stack) =>
              add(ObservacaoFalhou(erro, stack)),
        );
  }

  final FestaEmEdicaoRepository _festas;
  final AppLogger _logger;
  final String _festaId;

  late final StreamSubscription<FestaEmEdicao?> _inscricao;

  /// A última `FestaEmEdicao` que este bloc mandou gravar — §8.2.
  FestaEmEdicao? _ultimaGravada;

  /// Quantas gravações estão em voo agora.
  int _gravacoesEmVoo = 0;

  /// A porta entregou a festa observada — LIST-31, LIST-34.
  ///
  /// **Supressão de eco** (§8.2). O bloc é a autoridade sobre o estado da
  /// lista: cada evento transforma a festa, emite síncrono e só então grava.
  /// Duas emissões são descartadas:
  ///
  /// - a que **é igual à última gravada** — o próprio eco da nossa escrita,
  ///   que só custaria um recálculo idêntico;
  /// - **qualquer uma que chegue com gravação em voo** — a porta ainda não
  ///   viu o que acabamos de escrever, então o que ela emite é mais velho que
  ///   o que está na tela. Sem esta guarda, um eco atrasado sobrescreveria um
  ///   toque de stepper mais novo, que é exatamente o defeito que LIST-34
  ///   proíbe.
  ///
  /// A consequência declarada: uma mudança **externa** (outra aba mexendo na
  /// composição) que chegue no meio de uma gravação é perdida, porque a
  /// gravação seguinte a sobrescreve. É o preço de "o bloc é a autoridade",
  /// e no M1 a impl é em memória e local (AD-016).
  void _aoReceberFesta(FestaRecebida evento, Emitter<ListaState> emit) {
    if (_gravacoesEmVoo > 0) return;
    if (evento.festa != null && evento.festa == _ultimaGravada) return;

    emit(_estadoCom(evento.festa));
  }

  /// O stream falhou — LIST-32.
  ///
  /// Loga (AD-005) e **não emite**: o último estado bom fica de pé. O stream
  /// da porta é broadcast e o erro não cancela a inscrição, então zerar aqui
  /// apagaria uma lista que continua válida — e a emissão seguinte, com o
  /// mesmo conteúdo, seria descartada pela igualdade e não a traria de volta.
  void _aoFalharObservacao(ObservacaoFalhou evento, Emitter<ListaState> emit) {
    _logger.logError(evento.erro, evento.stackTrace, name: 'lista');
  }

  /// O segmented mudou — LIST-01. **Não grava**: modo não é dado da festa.
  void _aoAlternarModo(ModoAlternado evento, Emitter<ListaState> emit) {
    emit(state.copyWith(modo: evento.modo));
  }

  /// Uma linha foi aberta ou fechada — LIST-10.
  ///
  /// `copyWith` não serve: ele resolve cada campo com `?? this.x`, então
  /// `ItemExpandido(null)` manteria o item aberto em vez de fechá-lo.
  void _aoExpandirItem(ItemExpandido evento, Emitter<ListaState> emit) {
    emit(
      ListaState(
        carregando: state.carregando,
        festa: state.festa,
        resultado: state.resultado,
        modo: state.modo,
        chaveExpandida: evento.chave,
        faixaReal: state.faixaReal,
        falhouAoSalvar: state.falhouAoSalvar,
      ),
    );
  }

  /// Uma gravação falhou — LIST-32.
  ///
  /// Loga (AD-005) e acende o aviso **sem reverter nada**: reverter perderia o
  /// toque que o anfitrião acabou de dar, e ele não teria como saber. O
  /// requisito literal é "não perde o estado da tela nem trava a interação".
  ///
  /// *SPEC_PRECISION_GAP* (`design.md` §10): nenhuma spec desenha a Lista
  /// falhando ao gravar nem dá copy para isso. [ListaState.falhouAoSalvar]
  /// existe para a tela poder decidir, e no M1 nada é desenhado com ele — a
  /// evidência do requisito é a preservação do estado mais o registro no log.
  void _aoFalharGravacao(GravacaoFalhou evento, Emitter<ListaState> emit) {
    _logger.logError(evento.erro, evento.stackTrace, name: 'lista');

    emit(state.copyWith(falhouAoSalvar: true));
  }

  /// O stepper de quantidade — LIST-11, RN-12.
  void _aoAjustarQuantidade(
    QuantidadeAjustada evento,
    Emitter<ListaState> emit,
  ) {
    _ajustar(
      emit,
      evento.chave,
      (item) => comPassoDeQuantidade(item, evento.passos),
    );
  }

  /// O stepper de preço — LIST-11, RN-12.
  void _aoAjustarPreco(PrecoAjustado evento, Emitter<ListaState> emit) {
    _ajustar(
      emit,
      evento.chave,
      (item) => comPassoDePreco(item, evento.passos),
    );
  }

  /// "RESTAURAR" — LIST-14, RN-12.
  ///
  /// `semOverrides()` zera o mapa inteiro de uma vez: não há laço item a item
  /// que possa deixar um para trás.
  void _aoRestaurarOverrides(
    OverridesRestaurados evento,
    Emitter<ListaState> emit,
  ) {
    final festa = state.festa;
    if (festa == null || festa.composicao.overrides.isEmpty) return;

    _aplicarMudanca(
      emit,
      festa.copyWith(
        composicao: festa.composicao.copyWith(overrides: semOverrides()),
      ),
    );
  }

  /// O caminho **único** dos dois steppers — LIST-11, LIST-13.
  ///
  /// O passo sai de `core/calculo` ([comPassoDeQuantidade] /
  /// [comPassoDePreco]), aplicado sobre o item **já calculado**: é assim que
  /// o piso de RN-12 chega aqui sem ser reescrito. O resultado vira uma
  /// entrada nova no mapa de `overrides`, e a composição nova é que recalcula
  /// tudo — valor da linha, subtotais, total, por adulto e faixa real na
  /// **mesma** emissão (UC-04).
  ///
  /// Só itens de [ResultadoDoCalculo.itens] são ajustáveis: os quatro
  /// essenciais de RN-10 são reconstruídos por `essenciaisAutomaticos()` a
  /// cada cálculo e a calculadora não lhes aplica override — guardar um seria
  /// gravar um ajuste que nunca aparece.
  ///
  /// **No piso, nada acontece.** Quando o passo devolve o mesmo ajuste que já
  /// está guardado, não há emissão nem gravação: o decremento fica inerte, em
  /// vez de gravar N vezes o mesmo valor.
  void _ajustar(
    Emitter<ListaState> emit,
    ChaveItem chave,
    ItemDeLista Function(ItemDeLista) passo,
  ) {
    final festa = state.festa;
    final resultado = state.resultado;
    if (festa == null || resultado == null) return;

    final item = _itemAjustavel(resultado, chave);
    if (item == null) return;

    final ajustado = passo(item);
    final override = OverrideDeItem(
      quantidade: ajustado.quantidadeOverride,
      preco: ajustado.precoOverride,
    );

    if (override == festa.composicao.overrides[chave]) return;

    _aplicarMudanca(
      emit,
      festa.copyWith(
        composicao: festa.composicao.copyWith(
          overrides: {...festa.composicao.overrides, chave: override},
        ),
      ),
    );
  }

  /// Emite o recálculo e grava — o caminho de **toda** mudança da tela.
  ///
  /// Emite **antes** de gravar, síncrono: o bloc é a autoridade sobre o estado
  /// da lista, e a porta é o destino, não a fonte (§8.2).
  void _aplicarMudanca(Emitter<ListaState> emit, FestaEmEdicao festa) {
    emit(_estadoCom(festa));
    unawaited(_gravar(festa));
  }

  /// Uma gravação do estado corrente — LIST-15, LIST-20, LIST-32, LIST-34.
  ///
  /// O contador e a última gravada são atualizados **antes** do `await`, e por
  /// isso já valem para o eco que chegar em seguida.
  Future<void> _gravar(FestaEmEdicao festa) async {
    _ultimaGravada = festa;
    _gravacoesEmVoo++;

    try {
      await _festas.salvarFesta(_festaId, festa);
    } catch (erro, stack) {
      add(GravacaoFalhou(erro, stack));
    } finally {
      _gravacoesEmVoo--;
    }
  }

  /// Uma linha do modo COMPRAR foi marcada ou desmarcada — LIST-20, LIST-33.
  ///
  /// `remove` devolve `false` quando não havia o que tirar: alternar fica
  /// determinístico sem consultar o estado antes de decidir. O conjunto mora
  /// na composição (AD-030), então **marcar não muda o total** — a
  /// calculadora só o reaplica em `ItemDeLista.noCarrinho`.
  void _aoAlternarNoCarrinho(
    ItemAlternadoNoCarrinho evento,
    Emitter<ListaState> emit,
  ) {
    final festa = state.festa;
    if (festa == null) return;

    final noCarrinho = {...festa.composicao.noCarrinho};
    if (!noCarrinho.remove(evento.chave)) noCarrinho.add(evento.chave);

    _aplicarMudanca(
      emit,
      festa.copyWith(
        composicao: festa.composicao.copyWith(noCarrinho: noCarrinho),
      ),
    );
  }

  /// O pedido confirmado vira a `Despesa` de RN-20 — LIST-27.
  ///
  /// Acrescenta **uma** despesa e grava. Checks e overrides ficam intactos
  /// (A-21): eles moram na composição, e aqui só a lista de despesas muda.
  ///
  /// **Idempotente** (LIST-33): confirmar o mesmo pedido duas vezes produz a
  /// mesma `Despesa`, e a segunda é descartada por já estar lançada. A
  /// consequência declarada é que dois pedidos **idênticos** de propósito
  /// viram um só — nenhuma spec desenha esse caso, e perder um lançamento
  /// duplicado é menos grave que cobrar a galera duas vezes pelo mesmo
  /// delivery.
  void _aoConfirmarPedido(PedidoConfirmado evento, Emitter<ListaState> emit) {
    final festa = state.festa;
    if (festa == null) return;

    final despesa = _despesaDoPedido(evento.pedido, festa);
    if (festa.despesas.contains(despesa)) return;

    _aplicarMudanca(
      emit,
      festa.copyWith(despesas: [...festa.despesas, despesa]),
    );
  }

  @override
  Future<void> close() async {
    await _inscricao.cancel();
    return super.close();
  }

  /// O **único** ponto de cálculo da tela — LIST-07.
  ///
  /// Todo caminho que troca a festa termina aqui, e por isso não existe
  /// emissão que deixe `resultado` ou `faixaReal` para trás: é invariante do
  /// bloc, não disciplina de quem escrever o handler seguinte.
  ///
  /// Modo, item expandido e o aviso de falha **sobrevivem** ao recálculo: um
  /// item aberto continua aberto quando a lista recalcula (edge case da
  /// `spec.md`).
  ListaState _estadoCom(FestaEmEdicao? festa) {
    final resultado = CalculadoraDaFesta.calcular(
      festa?.composicao ?? _semNinguem,
    );

    return ListaState(
      carregando: false,
      festa: festa,
      resultado: resultado,
      modo: state.modo,
      chaveExpandida: state.chaveExpandida,
      faixaReal: _faixaDe(resultado),
      falhouAoSalvar: state.falhouAoSalvar,
    );
  }
}

/// O nome de quem paga quando ninguém está nomeado na festa — RN-16, RN-30.
///
/// É o rótulo que o arquivo 03 usa para o dono do app em toda linha de acerto
/// ("LÉO → VOCÊ · R$ 80"), e é o que sobra quando a festa ainda não tem
/// pessoas nomeadas — o caso do M1, em que `galera` ainda não escreve.
const String _usuarioSemNome = 'VOCÊ';

/// A `Despesa` que um pedido confirmado lança na festa — RN-20 · LIST-27.
///
/// [Despesa.quemPagou] é o **nome** da pessoa (A-24): quem estiver marcado
/// como `voce` na composição, ou [_usuarioSemNome] enquanto não houver pessoa
/// nomeada. O valor é o **total** do pedido — subtotal + frete, já somado por
/// `totalDoPedido` fora daqui —, porque é o total que "racha no acerto da
/// festa".
Despesa _despesaDoPedido(Pedido pedido, FestaEmEdicao festa) => Despesa(
      quemPagou: _nomeDoUsuario(festa.composicao.pessoas),
      descricao: 'Pedido no ${pedido.parceiro.nome}',
      valor: pedido.total,
    );

/// O nome da pessoa marcada como `voce`, ou [_usuarioSemNome].
String _nomeDoUsuario(List<Pessoa> pessoas) {
  for (final pessoa in pessoas) {
    if (pessoa.voce) return pessoa.nome;
  }
  return _usuarioSemNome;
}

/// O item de [chave] entre os ajustáveis, ou `null` se ele não está na lista.
///
/// Percorre só [ResultadoDoCalculo.itens] — os essenciais de RN-10 não
/// recebem override (ver [ListaBloc._ajustar]).
ItemDeLista? _itemAjustavel(ResultadoDoCalculo resultado, ChaveItem chave) {
  for (final item in resultado.itens) {
    if (item.chave == chave) return item;
  }
  return null;
}

/// A faixa real do rodapé, ou `null` com a lista vazia — LIST-09, LIST-31.
FaixaReal? _faixaDe(ResultadoDoCalculo resultado) =>
    resultado.todosOsItens.isEmpty
        ? null
        : faixaRealDaLista(resultado.todosOsItens, tabelaDePrecosDeMercado);
