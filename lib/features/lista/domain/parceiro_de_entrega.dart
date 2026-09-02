/// Os três parceiros de entrega de **RN-27** — LIST-22.
///
/// Os literais são da spec-fonte, não paráfrase: nome, ETA e frete saem da
/// frase de RN-27 ("iFood Mercado (40–60 min, frete R$ 12) / Rappi Turbo
/// (15–30 min, R$ 9) / Zé Delivery só-bebidas (30–45 min, grátis)").
///
/// **A ordem de declaração é a de RN-27** e é comportamento, não arrumação:
/// é ela que dá a ordem dos cartões-radio da sheet e é o primeiro valor que a
/// A-14 pré-seleciona. Reordenar aqui muda a tela.
///
/// [frete] é **número**, nunca string com `R$`: a soma é de `totalDoPedido`
/// (`core/calculo`) e a formatação é de `MoneyFormatter` (RN-13). Um `'R$ 12'`
/// aqui seria dinheiro formatado à mão dentro da feature.
enum ParceiroDeEntrega {
  ifood(nome: 'iFood Mercado', eta: '40–60 min', frete: 12, soBebidas: false),
  rappi(nome: 'Rappi Turbo', eta: '15–30 min', frete: 9, soBebidas: false),
  ze(nome: 'Zé Delivery', eta: '30–45 min', frete: 0, soBebidas: true);

  const ParceiroDeEntrega({
    required this.nome,
    required this.eta,
    required this.frete,
    required this.soBebidas,
  });

  /// O nome literal do parceiro, como a sheet e o overlay o exibem.
  final String nome;

  /// O prazo literal de RN-27 — "chega em {eta}" na sheet, "Chega em {eta}"
  /// no overlay.
  final String eta;

  /// O frete em reais, **sem formatar**. O Zé entra com 0 — o "grátis" da
  /// copy é decisão de quem pinta, não outro número.
  final double frete;

  /// `true` só no Zé Delivery: pedido com item fora do corredor BEBIDAS não
  /// pode sair por ele (A-09). O cartão continua visível e fica inerte.
  final bool soBebidas;
}
