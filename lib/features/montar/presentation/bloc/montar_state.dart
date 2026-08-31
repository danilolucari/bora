import '../../../../core/calculo/calculo.dart';

/// O estado da tela Montar — MONT-04, MONT-12.
///
/// [resultado] **mora no estado**, e é o que faz MONT-12 ("card-herói, lista
/// viva e rodapé recalculam juntos") deixar de ser disciplina e virar
/// estrutura: os três leem o **mesmo** objeto, então não há como um deles
/// ficar para trás.
///
/// Igualdade por valor, escrita à mão como em `HomeState` e `EntrarState`:
/// sem ela o `emit` do bloc não descarta emissão repetida, e toda emissão do
/// repositório reconstruiria o formulário inteiro.
///
/// [resultado] fica **fora** de `==` de propósito: ele é função pura de
/// [composicao] — duas composições iguais produzem o mesmo resultado, e
/// `ResultadoDoCalculo` não tem igualdade por valor, então incluí-lo tornaria
/// dois estados idênticos permanentemente diferentes.
class MontarState {
  const MontarState({
    required this.festa,
    required this.composicao,
    required this.resultado,
    this.festaId,
    this.falhouAoSalvar = false,
  });

  /// `null` enquanto o rolê é rascunho não persistido (MONT-17).
  final String? festaId;

  /// Nome e data que o header mostra e edita.
  final Festa festa;

  /// A entrada da calculadora.
  final ComposicaoDaFesta composicao;

  /// A saída, recalculada a cada transição — nunca por quem desenha.
  final ResultadoDoCalculo resultado;

  /// A última gravação falhou (MONT-19). Não reverte nada do que está na tela.
  final bool falhouAoSalvar;

  /// Copia trocando campos. **Trocar [composicao] sem trocar [resultado]
  /// deixaria os dois em desacordo** — só `_emitirComCalculo` faz isso, e ele
  /// passa os dois juntos.
  MontarState copyWith({
    String? festaId,
    Festa? festa,
    ComposicaoDaFesta? composicao,
    ResultadoDoCalculo? resultado,
    bool? falhouAoSalvar,
  }) =>
      MontarState(
        festaId: festaId ?? this.festaId,
        festa: festa ?? this.festa,
        composicao: composicao ?? this.composicao,
        resultado: resultado ?? this.resultado,
        falhouAoSalvar: falhouAoSalvar ?? this.falhouAoSalvar,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MontarState &&
          other.festaId == festaId &&
          other.festa == festa &&
          other.composicao == composicao &&
          other.falhouAoSalvar == falhouAoSalvar;

  @override
  int get hashCode => Object.hash(festaId, festa, composicao, falhouAoSalvar);
}
