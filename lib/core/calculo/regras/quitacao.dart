import '../dominio/linha_de_acerto.dart';

/// Quanto do acerto já foi quitado — RN-18 · CALC-23.
///
/// Alimenta a label "N de M quitados · R$ pago de R$ devido" e a barra verde.
class ProgressoDeQuitacao {
  const ProgressoDeQuitacao({
    required this.pagas,
    required this.total,
    required this.valorPago,
    required this.valorDevido,
  });

  /// Quantas linhas já estão marcadas como pagas.
  final int pagas;

  /// Quantas linhas o acerto tem, pagas e pendentes.
  final int total;

  /// A soma das linhas pagas, **sem arredondar** (RN-13 arredonda na exibição).
  final double valorPago;

  /// A soma de **todas** as linhas — é o denominador do progresso.
  final double valorDevido;

  /// A fração da barra verde: `valorPago ÷ valorDevido`.
  ///
  /// O progresso é de **dinheiro**, não de contagem: com as linhas do Teste A
  /// (80, 40, 40), quitar só a de R$ 80 é 1 linha de 3 e metade do valor — a
  /// barra anda 50%, não 33%.
  ///
  /// **Sem nenhuma linha a fração é 1.0** (A-16): UC-22 define 100% como
  /// "todas as linhas pagas", e com zero linhas isso é vacuamente verdade —
  /// não há nada pendente. `0.0` ("nada foi pago ainda") é a alternativa
  /// defensável; se a spec `custos` decidir por ela, a troca é **esta linha**,
  /// do `1` para o `0`.
  double get fracao => valorDevido == 0 ? 1 : valorPago / valorDevido;
}

/// Resume as linhas de acerto em progresso de quitação — RN-18 · CALC-23.
///
/// Conta as linhas e soma os valores numa passada só. A alternância
/// PENDENTE ⇄ PAGO ✓ é reversível: como [LinhaDeAcerto] é imutável, quem marca
/// e desmarca é o `copyWith`, e recalcular a lista devolve o progresso anterior.
ProgressoDeQuitacao progressoDeQuitacao(Iterable<LinhaDeAcerto> linhas) {
  var pagas = 0;
  var total = 0;
  var valorPago = 0.0;
  var valorDevido = 0.0;

  for (final linha in linhas) {
    total++;
    valorDevido += linha.valor;
    if (linha.paga) {
      pagas++;
      valorPago += linha.valor;
    }
  }

  return ProgressoDeQuitacao(
    pagas: pagas,
    total: total,
    valorPago: valorPago,
    valorDevido: valorDevido,
  );
}
