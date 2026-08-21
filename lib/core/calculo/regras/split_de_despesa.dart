import '../dominio/despesa.dart';

/// Uma despesa com o seu rateio pronto para a copy "split R$ X × N" (RN-17).
class SplitDeDespesa {
  const SplitDeDespesa({
    required this.despesa,
    required this.valorPorAdulto,
    required this.adultos,
  });

  /// A despesa rateada — quem adiantou, o quê e quanto.
  final Despesa despesa;

  /// Quanto cabe a cada adulto, **sem arredondar**: R$ 100 entre 3 dá 33,33…
  /// aqui, e só vira R$ 33 na exibição (RN-13).
  final double valorPorAdulto;

  /// O `N` da copy "split R$ X × N" — quantos adultos dividem a conta.
  final int adultos;
}

/// O split igualitário de uma despesa — RN-17 · CALC-22.
///
/// `valorPorAdulto = valor ÷ adultos`. O divisor são **os adultos**, nunca as
/// pessoas: criança não entra no racha (RN-14), e uma despesa é racha como
/// qualquer outro custo da festa. [adultos] volta junto porque a tela imprime
/// os dois números — "R$ 20 × 4".
///
/// Sem adulto nenhum o valor por adulto é **0,0** — nunca `NaN` nem `Infinity`.
SplitDeDespesa splitIgualitario({
  required Despesa despesa,
  required int adultos,
}) =>
    SplitDeDespesa(
      despesa: despesa,
      valorPorAdulto: adultos == 0 ? 0 : despesa.valor / adultos,
      adultos: adultos,
    );
