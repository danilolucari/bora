import '../dominio/preco_de_mercado.dart';

/// Onde o marcador da barra de faixa fica, já resolvido em `[0,1]` — RN-11 ·
/// CALC-25.
///
/// `(média − mín) ÷ (máx − mín)`. Para a Picanha bovina (65, 54, 83):
/// `11 / 29 ≈ 0,379` — o marcador fica a 37,9% do trilho.
///
/// **Contrato de fronteira nº 1 com a spec 01 `design-system`**: o componente
/// recebe este `double` pronto e **só pinta** o marcador na largura do trilho.
/// Ele não conhece [PrecoDeMercado.media], [PrecoDeMercado.minimo] nem
/// [PrecoDeMercado.maximo] para dividir coisa alguma — se conhecer, a fórmula
/// vazou para a UI e o `CLAUDE.md` foi violado. Toda aritmética vive nesta
/// camada; a tela consome o resultado.
///
/// Duas saídas declaradas, porque a barra não pode quebrar:
/// - `máx == mín` devolve **0.0**, sem dividir por zero (A-15): a barra tem
///   comprimento zero, e nela qualquer ponto é o mesmo ponto;
/// - média fora da faixa é **limitada** a `[0,1]`, para o marcador nunca sair
///   do trilho.
double posicaoDoMarcador(PrecoDeMercado preco) {
  final amplitude = preco.maximo - preco.minimo;
  if (amplitude == 0) return 0;

  return ((preco.media - preco.minimo) / amplitude).clamp(0.0, 1.0);
}

/// O rodapé da tela Lista no modo PLANEJAR — RN-11 · CALC-25.
///
/// "Total R$ [media] · faixa real: de R$ [minimo] a R$ [maximo]". Com as oito
/// linhas de RN-11: **286**, de **234** a **356**.
class TotalDeMercado {
  const TotalDeMercado({
    required this.media,
    required this.minimo,
    required this.maximo,
  });

  /// A soma das médias — o total que a tela mostra.
  final double media;

  /// A soma dos mínimos: o cenário mais barato.
  final double minimo;

  /// A soma dos máximos: o cenário mais caro.
  final double maximo;
}

/// Soma a média, o mín e o máx de [precos] numa passada só — RN-11 · CALC-25.
///
/// Soma **exata**, sem arredondar: quem arredonda é a formatação de RN-13, uma
/// única vez.
TotalDeMercado totalDeMercado(Iterable<PrecoDeMercado> precos) {
  var media = 0.0;
  var minimo = 0.0;
  var maximo = 0.0;

  for (final preco in precos) {
    media += preco.media;
    minimo += preco.minimo;
    maximo += preco.maximo;
  }

  return TotalDeMercado(media: media, minimo: minimo, maximo: maximo);
}
