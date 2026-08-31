import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/festas/festas.dart';
import '../../../../core/observability/app_logger.dart';
import '../../domain/rascunho_inicial.dart';
import 'montar_event.dart';
import 'montar_state.dart';

export 'montar_event.dart';
export 'montar_state.dart';

/// O estado da tela Montar — MONT-04, MONT-05, MONT-07, MONT-14, MONT-20.
///
/// É o **único** lugar do app que chama `CalculadoraDaFesta.calcular`. Nenhum
/// widget desta feature faz conta: eles leem `state.resultado`.
///
/// **Este bloc não navega** (AD-020, como em `HomeBloc`): quem chama
/// `context.go` é a página.
class MontarBloc extends Bloc<MontarEvent, MontarState> {
  /// Com [festaId], assina `observarFesta(id)` e carrega o que está salvo
  /// (MONT-16). Sem ele, o rolê é o rascunho [inicial] e **nada é gravado** —
  /// abrir `/roles/novo` para olhar não pode criar rolê na Home (MONT-17).
  ///
  /// [inicial] chega pronto, e não de um `rascunhoInicial(hoje: DateTime.now())`
  /// interno: o relógio é da borda, pelo mesmo motivo de `data_do_role.dart` —
  /// com ele aqui dentro, a data default só seria afirmável no sábado.
  MontarBloc(
    this._festas,
    this._logger, {
    required FestaEmEdicao inicial,
    String? festaId,
  })  : _rascunho = inicial,
        _festaId = festaId,
        super(_estadoDe(inicial, festaId: festaId)) {
    on<ContagemAlterada>(_aoMudarContagem);
    on<ItemAlternado>(_aoAlternarItem);
    on<DuracaoAlterada>(_aoMudarDuracao);
    on<NomeAlterado>(_aoMudarNome);
    on<DataAlterada>(_aoMudarData);
    on<FestaRecebida>(_aoReceberFesta);
    on<FestaCriada>(_aoCriarFesta);
    on<SalvarPedido>(_aoPedirSalvar);
    on<PersistenciaConcluida>(_aoConcluirPersistencia);
    on<PersistenciaFalhou>(_aoFalharPersistencia);

    if (festaId != null) {
      _inscricao = _festas.observarFesta(festaId).listen(
            (festa) => add(FestaRecebida(festa)),
            onError: (Object erro, StackTrace stack) =>
                add(PersistenciaFalhou(erro, stack)),
          );
    }
  }

  final FestaEmEdicaoRepository _festas;
  final AppLogger _logger;

  /// O rascunho de abertura, guardado para o caso de a festa observada não
  /// existir: a tela abre montável em vez de quebrar (MONT-16).
  final FestaEmEdicao _rascunho;

  StreamSubscription<FestaEmEdicao?>? _inscricao;

  /// O id da festa **para efeito de gravação**.
  ///
  /// Existe além de `state.festaId` porque `criarFesta` responde antes de o
  /// `FestaCriada` chegar ao estado: uma segunda gravação nessa janela leria
  /// `festaId == null` e criaria a festa **de novo**.
  String? _festaId;

  /// Já existe uma gravação em voo.
  bool _gravando = false;

  /// Chegou mudança enquanto a gravação corrente estava em voo.
  bool _pendente = false;

  /// A mudança pendente inclui um "SALVAR ROLÊ".
  bool _pendentePorPedido = false;

  /// P1-5 AC6: nome apagado por completo **volta ao default** em vez de ficar
  /// vazio — um rolê sem nome nenhum é o que a Home teria de desenhar depois.
  void _aoMudarNome(NomeAlterado evento, Emitter<MontarState> emit) {
    final nome = evento.nome.trim();

    _aplicarMudanca(
      emit,
      festa: state.festa.copyWith(
        nome: nome.isEmpty ? nomeDefaultDoRole : nome,
      ),
    );
  }

  /// A data é normalizada para CAIXA ALTA (§7 do arquivo 02).
  ///
  /// Nada valida o formato: `Festa.data` é rótulo (A-23) e nenhuma tela de
  /// `04`/`06` desenha date picker — inventar validação aqui seria inventar
  /// produto.
  void _aoMudarData(DataAlterada evento, Emitter<MontarState> emit) {
    _aplicarMudanca(
      emit,
      festa: state.festa.copyWith(data: evento.data.toUpperCase()),
    );
  }

  /// O repositório entregou a festa observada — MONT-16, MONT-18.
  ///
  /// **Não grava de volta**: é a emissão que vem do store, e regravá-la
  /// fecharia um laço. É por aqui que a mudança feita de fora (outro
  /// dispositivo, um convidado confirmando no M2) chega à tela aberta.
  void _aoReceberFesta(FestaRecebida evento, Emitter<MontarState> emit) {
    final festa = evento.festa;

    // Festa inexistente: a rota é válida, o dado é que não está lá. Abre
    // montável, como rascunho, em vez de quebrar ou redirecionar para /erro.
    if (festa == null) {
      // Sem festa por trás, a próxima mudança tem de criar uma: o id de
      // gravação some junto com o do estado.
      _festaId = null;
      emit(
        _estadoDe(
          _rascunho,
          falhouAoSalvar: state.falhouAoSalvar,
          salvamentos: state.salvamentos,
        ),
      );
      return;
    }

    emit(
      _estadoDe(
        festa,
        festaId: state.festaId,
        falhouAoSalvar: state.falhouAoSalvar,
        salvamentos: state.salvamentos,
      ),
    );
  }

  /// `criarFesta` respondeu: o rascunho virou festa e o estado ganha o id.
  void _aoCriarFesta(FestaCriada evento, Emitter<MontarState> emit) {
    emit(
      _estadoDe(
        FestaEmEdicao(festa: state.festa, composicao: state.composicao),
        festaId: evento.festaId,
        falhouAoSalvar: state.falhouAoSalvar,
        salvamentos: state.salvamentos,
      ),
    );
  }

  /// "SALVAR ROLÊ" — MONT-23. Grava e **não navega**.
  void _aoPedirSalvar(SalvarPedido evento, Emitter<MontarState> emit) {
    unawaited(_persistir(porPedido: true));
  }

  /// A gravação terminou bem: o aviso de falha sai, e o "SALVAR ROLÊ" conta.
  void _aoConcluirPersistencia(
    PersistenciaConcluida evento,
    Emitter<MontarState> emit,
  ) {
    emit(
      state.copyWith(
        falhouAoSalvar: false,
        salvamentos:
            evento.porPedido ? state.salvamentos + 1 : state.salvamentos,
      ),
    );
  }

  /// MONT-19 — a falha vai para o log e **o estado da tela fica como está**.
  ///
  /// `copyWith`, e não estado reconstruído: reverter a composição perderia o
  /// toque que o anfitrião acabou de dar, e ele não teria como saber. O
  /// requisito literal é "não perde o estado da tela nem trava a interação".
  ///
  /// *SPEC_PRECISION_GAP*: nenhuma spec desenha montar falhando nem dá copy
  /// para isso; [MontarState.falhouAoSalvar] existe para a tela poder decidir,
  /// e no M1 nada é desenhado com ele.
  void _aoFalharPersistencia(
    PersistenciaFalhou evento,
    Emitter<MontarState> emit,
  ) {
    _logger.logError(evento.erro, evento.stackTrace, name: 'montar');

    emit(state.copyWith(falhouAoSalvar: true));
  }

  void _aoMudarContagem(ContagemAlterada evento, Emitter<MontarState> emit) {
    final atual = state.composicao.contagem;

    final contagem = switch (evento.tipo) {
      TipoDeCabeca.homens =>
        atual.copyWith(homens: _noPiso(atual.homens + evento.delta)),
      TipoDeCabeca.mulheres =>
        atual.copyWith(mulheres: _noPiso(atual.mulheres + evento.delta)),
      TipoDeCabeca.criancas =>
        atual.copyWith(criancas: _noPiso(atual.criancas + evento.delta)),
    };

    _aplicarMudanca(emit, composicao: _composicaoCom(contagem: contagem));
  }

  void _aoAlternarItem(ItemAlternado evento, Emitter<MontarState> emit) {
    // `remove` devolve `false` quando não havia o que tirar — é o que torna
    // alternar determinístico sem consultar o estado antes de decidir.
    final itens = {...state.composicao.itensSelecionados};
    if (!itens.remove(evento.chave)) itens.add(evento.chave);

    _aplicarMudanca(
      emit,
      composicao: _composicaoCom(itensSelecionados: itens),
    );
  }

  void _aoMudarDuracao(DuracaoAlterada evento, Emitter<MontarState> emit) {
    // A duração é espelhada nos dois lados **num lugar só**: a composição é
    // quem entra na calculadora, e `Festa.duracaoHoras` é o que a tela grava.
    // Divergirem em silêncio faria o card-herói mostrar uma duração enquanto
    // a conta usa outra.
    _aplicarMudanca(
      emit,
      festa: state.festa.copyWith(duracaoHoras: evento.horas),
      composicao: _composicaoCom(duracaoHoras: evento.horas),
    );
  }

  /// O caminho de **toda mudança feita na tela**: emite e grava.
  ///
  /// Separado de [_emitirComCalculo] porque a emissão que **vem** do
  /// repositório não pode ser regravada — seria um laço de escrita.
  void _aplicarMudanca(
    Emitter<MontarState> emit, {
    Festa? festa,
    ComposicaoDaFesta? composicao,
  }) {
    _emitirComCalculo(emit, festa: festa, composicao: composicao);
    unawaited(_persistir());
  }

  /// Single-flight com coalescência — MONT-21.
  ///
  /// Com uma gravação em voo, a mudança nova não abre outra: ela marca
  /// pendente, e ao fim da corrente grava-se **o estado de então**, que é o
  /// mais novo. Assim uma rajada de N toques produz no máximo duas gravações,
  /// e nenhuma escrita com valor antigo chega depois de uma com valor novo —
  /// que é o jeito de a lista voltar ao que era enquanto o dedo ainda está na
  /// tela.
  Future<void> _persistir({bool porPedido = false}) async {
    if (_gravando) {
      _pendente = true;
      _pendentePorPedido = _pendentePorPedido || porPedido;
      return;
    }

    _gravando = true;
    var pedido = porPedido;

    try {
      while (true) {
        _pendente = false;
        await _gravar(porPedido: pedido);

        if (!_pendente) break;

        pedido = _pendentePorPedido;
        _pendentePorPedido = false;
      }
    } finally {
      _gravando = false;
      _pendente = false;
      _pendentePorPedido = false;
    }
  }

  /// Uma gravação do estado corrente — MONT-17, MONT-18, MONT-19.
  ///
  /// Sem id, é a **primeira mudança** num rascunho: cria a festa já **com a
  /// mudança dentro**, e o id devolvido é o que a página observa para trocar a
  /// URL. Com id, grava por cima.
  Future<void> _gravar({required bool porPedido}) async {
    final festa = FestaEmEdicao(
      festa: state.festa,
      composicao: state.composicao,
    );
    final id = _festaId;

    try {
      if (id == null) {
        final novo = await _festas.criarFesta(festa);
        _festaId = novo;
        add(FestaCriada(novo));
      } else {
        await _festas.salvarFesta(id, festa);
      }

      add(PersistenciaConcluida(porPedido: porPedido));
    } catch (erro, stack) {
      add(PersistenciaFalhou(erro, stack));
    }
  }

  @override
  Future<void> close() async {
    await _inscricao?.cancel();
    return super.close();
  }

  /// O **único** ponto de emissão da tela — MONT-04.
  ///
  /// Todo handler termina aqui, e por isso não existe caminho que emita sem
  /// recalcular: MONT-04 é invariante do bloc, não disciplina de quem escreve
  /// o handler seguinte.
  void _emitirComCalculo(
    Emitter<MontarState> emit, {
    Festa? festa,
    ComposicaoDaFesta? composicao,
  }) {
    emit(
      _estadoDe(
        FestaEmEdicao(
          festa: festa ?? state.festa,
          composicao: composicao ?? state.composicao,
        ),
        festaId: state.festaId,
        // A falha só sai quando uma gravação **conclui** — recalcular não é
        // ter gravado, e apagar o aviso aqui esconderia o erro sem resolvê-lo.
        falhouAoSalvar: state.falhouAoSalvar,
        salvamentos: state.salvamentos,
      ),
    );
  }

  /// O **único** ponto de cálculo do app — MONT-04, MONT-08.
  ///
  /// Estado inicial e emissão passam pelos dois pelo mesmo lugar: um segundo
  /// ponto de cálculo seria, por construção, um caminho que pode ficar para
  /// trás.
  static MontarState _estadoDe(
    FestaEmEdicao festa, {
    String? festaId,
    bool falhouAoSalvar = false,
    int salvamentos = 0,
  }) =>
      MontarState(
        festaId: festaId,
        festa: festa.festa,
        composicao: festa.composicao,
        resultado: CalculadoraDaFesta.calcular(festa.composicao),
        falhouAoSalvar: falhouAoSalvar,
        salvamentos: salvamentos,
      );

  /// A composição corrente com um campo trocado.
  ///
  /// Existe porque `ComposicaoDaFesta` não tem `copyWith` e `core/calculo` é
  /// camada fechada — dar-lhe um seria mexer na camada que esta spec consome.
  /// **Preserva `pessoas` e `overrides`**: são os que carregam RN-21 e RN-12,
  /// e reconstruí-los vazios apagaria o efeito das preferências da galera.
  ComposicaoDaFesta _composicaoCom({
    ContagemDePessoas? contagem,
    int? duracaoHoras,
    Set<ChaveItem>? itensSelecionados,
  }) =>
      ComposicaoDaFesta(
        contagem: contagem ?? state.composicao.contagem,
        duracaoHoras: duracaoHoras ?? state.composicao.duracaoHoras,
        pessoas: state.composicao.pessoas,
        itensSelecionados:
            itensSelecionados ?? state.composicao.itensSelecionados,
        overrides: state.composicao.overrides,
      );
}

/// O piso de 0 de UC-03 E1 — o `−` fica inerte em vez de gerar contagem
/// negativa, que `ContagemDePessoas` recusaria lançando.
int _noPiso(int valor) => valor < 0 ? 0 : valor;
