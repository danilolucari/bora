/// Uma linha do acerto: quem paga quem, e quanto — RN-16, RN-18 · CALC-21.
///
/// É a linha literal da tela: `LÉO → VOCÊ · R$ 80`. [paga] é o toggle
/// PENDENTE ⇄ PAGO ✓ de RN-18, e a transição é reversível pelo [copyWith].
///
/// **Sem campo de meio de pagamento, de propósito.** RN-19 (PIX / CARTÃO /
/// DINHEIRO, e a etiqueta que o selecionado imprime na linha) é da spec
/// `custos`, não desta camada: aqui não há escolha de meio, só aritmética. Quem
/// precisar da etiqueta estende a linha na sua feature, sem recalcular nada.
///
/// Valor imutável, com `==`/`hashCode` escritos à mão (A-19).
class LinhaDeAcerto {
  const LinhaDeAcerto({
    required this.de,
    required this.para,
    required this.valor,
    this.paga = false,
  });

  /// O nome de quem deve (A-24).
  final String de;

  /// O nome de quem recebe (A-24).
  final String para;

  /// Quanto desta linha, em reais e **sem arredondar** — dinheiro só arredonda
  /// na exibição (RN-13).
  final double valor;

  /// `true` quando a linha já foi quitada (RN-18). Nasce pendente.
  final bool paga;

  /// Copia trocando campos — é como a linha alterna PENDENTE ⇄ PAGO ✓ (RN-18).
  LinhaDeAcerto copyWith({
    String? de,
    String? para,
    double? valor,
    bool? paga,
  }) =>
      LinhaDeAcerto(
        de: de ?? this.de,
        para: para ?? this.para,
        valor: valor ?? this.valor,
        paga: paga ?? this.paga,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinhaDeAcerto &&
          other.de == de &&
          other.para == para &&
          other.valor == valor &&
          other.paga == paga;

  @override
  int get hashCode => Object.hash(de, para, valor, paga);
}
