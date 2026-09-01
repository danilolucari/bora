import '../../../../core/calculo/calculo.dart';
import '../../../../core/festas/festas.dart';

/// Os dois modos do segmented de T-04 — RN-27 · LIST-01.
///
/// PLANEJAR é o default: é ele que a tela abre ativo.
enum ModoDaLista { planejar, comprar }

/// O estado da tela Lista — LIST-10, LIST-31, LIST-32.
///
/// [resultado] e [faixaReal] **moram no estado**, prontos: card, rodapé e
/// rail leem o mesmo objeto, então não há como um deles ficar para trás e
/// nenhum widget precisa somar nada (LIST-07).
///
/// Igualdade por valor, escrita à mão como em `MontarState` e `HomeState`.
/// [resultado] e [faixaReal] ficam **fora** do `==` de propósito: são funções
/// puras de `festa.composicao` — duas festas iguais produzem os mesmos dois —
/// e nenhum dos dois tipos tem igualdade por valor, então incluí-los tornaria
/// dois estados idênticos permanentemente diferentes.
class ListaState {
  const ListaState({
    this.carregando = true,
    this.festa,
    this.resultado,
    this.modo = ModoDaLista.planejar,
    this.chaveExpandida,
    this.faixaReal,
    this.falhouAoSalvar = false,
  });

  /// `true` até a primeira emissão de `observarFesta`. Enquanto ele for
  /// `true`, [resultado] é `null`; depois, **nunca** mais (LIST-31).
  final bool carregando;

  /// A festa observada. `null` = a festa não existe: a rota é válida, o dado
  /// é que não está lá (LIST-31), e a lista sai vazia pelo mesmo caminho de
  /// 0 pessoas.
  final FestaEmEdicao? festa;

  /// A saída da calculadora, recalculada a cada transição — nunca por quem
  /// desenha.
  final ResultadoDoCalculo? resultado;

  /// O modo ativo do segmented. Estado de UI: **não** é gravado na porta.
  final ModoDaLista modo;

  /// O item aberto no modo PLANEJAR, ou `null` com todos fechados.
  ///
  /// **Um campo, não um `Set`**: abrir um item fecha o anterior por
  /// construção, que é o aceite de UC-06 (LIST-10).
  final ChaveItem? chaveExpandida;

  /// A "faixa real: de R$ X a R$ Y" do rodapé de PLANEJAR — LIST-09.
  ///
  /// `null` quando a lista está vazia: a linha **não renderiza** em vez de
  /// mostrar uma faixa de R$ 0 a R$ 0 (LIST-31 AC2).
  final FaixaReal? faixaReal;

  /// A última gravação na porta falhou (LIST-32). **Não reverte nada** do que
  /// está na tela: o anfitrião continua editando.
  final bool falhouAoSalvar;

  ListaState copyWith({
    bool? carregando,
    FestaEmEdicao? festa,
    ResultadoDoCalculo? resultado,
    ModoDaLista? modo,
    ChaveItem? chaveExpandida,
    FaixaReal? faixaReal,
    bool? falhouAoSalvar,
  }) =>
      ListaState(
        carregando: carregando ?? this.carregando,
        festa: festa ?? this.festa,
        resultado: resultado ?? this.resultado,
        modo: modo ?? this.modo,
        chaveExpandida: chaveExpandida ?? this.chaveExpandida,
        faixaReal: faixaReal ?? this.faixaReal,
        falhouAoSalvar: falhouAoSalvar ?? this.falhouAoSalvar,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListaState &&
          other.carregando == carregando &&
          other.festa == festa &&
          other.modo == modo &&
          other.chaveExpandida == chaveExpandida &&
          other.falhouAoSalvar == falhouAoSalvar;

  @override
  int get hashCode =>
      Object.hash(carregando, festa, modo, chaveExpandida, falhouAoSalvar);
}
