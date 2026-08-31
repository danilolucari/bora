import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/festas/festas.dart';
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
  MontarBloc({required FestaEmEdicao inicial}) : super(_estadoDe(inicial)) {
    on<ContagemAlterada>(_aoMudarContagem);
    on<ItemAlternado>(_aoAlternarItem);
    on<DuracaoAlterada>(_aoMudarDuracao);
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

    _emitirComCalculo(emit, composicao: _composicaoCom(contagem: contagem));
  }

  void _aoAlternarItem(ItemAlternado evento, Emitter<MontarState> emit) {
    // `remove` devolve `false` quando não havia o que tirar — é o que torna
    // alternar determinístico sem consultar o estado antes de decidir.
    final itens = {...state.composicao.itensSelecionados};
    if (!itens.remove(evento.chave)) itens.add(evento.chave);

    _emitirComCalculo(emit, composicao: _composicaoCom(itensSelecionados: itens));
  }

  void _aoMudarDuracao(DuracaoAlterada evento, Emitter<MontarState> emit) {
    // A duração é espelhada nos dois lados **num lugar só**: a composição é
    // quem entra na calculadora, e `Festa.duracaoHoras` é o que a tela grava.
    // Divergirem em silêncio faria o card-herói mostrar uma duração enquanto
    // a conta usa outra.
    _emitirComCalculo(
      emit,
      festa: state.festa.copyWith(duracaoHoras: evento.horas),
      composicao: _composicaoCom(duracaoHoras: evento.horas),
    );
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
  }) =>
      MontarState(
        festaId: festaId,
        festa: festa.festa,
        composicao: festa.composicao,
        resultado: CalculadoraDaFesta.calcular(festa.composicao),
        falhouAoSalvar: falhouAoSalvar,
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
