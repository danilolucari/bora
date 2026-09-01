import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/festas/festas.dart';
import '../../../../core/observability/app_logger.dart';
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

  /// A porta entregou a festa observada — LIST-31.
  void _aoReceberFesta(FestaRecebida evento, Emitter<ListaState> emit) {
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

  /// Uma gravação do estado corrente — LIST-15, LIST-32.
  Future<void> _gravar(FestaEmEdicao festa) async {
    try {
      await _festas.salvarFesta(_festaId, festa);
    } catch (erro, stack) {
      add(GravacaoFalhou(erro, stack));
    }
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
