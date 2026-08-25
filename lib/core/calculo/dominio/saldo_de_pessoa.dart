import '../regras/precisao.dart';

/// A tag que a tela mostra ao lado do nome — RN-15.
enum SituacaoDeSaldo {
  /// Saldo positivo: colocou mais que a cota. Copy: "RECEBE R$ X".
  recebe,

  /// Saldo negativo: colocou menos que a cota. Copy: "PAGA R$ X".
  paga,

  /// Saldo zero, dentro da tolerância de 1 centavo. Copy: "NO ZERO".
  noZero,
}

/// Como uma pessoa está em relação à cota justa — RN-15 · CALC-20.
///
/// `saldo = contribuição − cota`: o que ela colocou menos o que caberia a ela.
/// Positivo, recebe; negativo, paga; zero, está no zero.
///
/// Valor imutável, com `==`/`hashCode` escritos à mão (A-19).
class SaldoDePessoa {
  const SaldoDePessoa({
    required this.pessoa,
    required this.contribuicao,
    required this.cota,
    required this.saldo,
  });

  /// O nome da pessoa — a identidade nesta camada (A-24).
  final String pessoa;

  /// O que ela já colocou: itens que levou + despesas que adiantou (RN-20).
  final double contribuicao;

  /// A cota justa por adulto da festa (RN-14).
  final double cota;

  /// `contribuicao − cota`, sem arredondar (RN-13 arredonda só na exibição).
  final double saldo;

  /// A tag de RN-15.
  ///
  /// O zero é decidido pela [toleranciaDeCentavo], não por `== 0`: resíduo de
  /// `double` abaixo de um centavo é zero para o produto (A-13). Sem isso,
  /// alguém com saldo de R$ 0,004 apareceria como devedor.
  SituacaoDeSaldo get situacao {
    if (ehZeroNaTolerancia(saldo)) return SituacaoDeSaldo.noZero;
    return saldo > 0 ? SituacaoDeSaldo.recebe : SituacaoDeSaldo.paga;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaldoDePessoa &&
          other.pessoa == pessoa &&
          other.contribuicao == contribuicao &&
          other.cota == cota &&
          other.saldo == saldo;

  @override
  int get hashCode => Object.hash(pessoa, contribuicao, cota, saldo);
}
