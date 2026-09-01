import '../dominio/chave_item.dart';
import '../dominio/item_de_lista.dart';
import '../dominio/preco_de_mercado.dart';
import 'totais.dart';

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

/// A "faixa real: de R$ X a R$ Y" do rodapé do modo PLANEJAR — RN-11 · A-03 ·
/// LIST-09.
///
/// **Sem campo `media`, de propósito.** O "MÉDIA TOTAL" do rodapé é
/// `ResultadoDoCalculo.totalComEssenciais` (R$ 271, A-01), não uma média desta
/// função — devolver um terceiro número aqui convidaria alguém a pintá-lo no
/// rodapé e reabriria a divergência D-1.
class FaixaReal {
  const FaixaReal({required this.minimo, required this.maximo});

  /// A ponta barata: o cenário mais em conta da lista inteira.
  final double minimo;

  /// A ponta cara.
  final double maximo;
}

/// Soma a faixa de preço sobre os itens de **uma lista** — que não é a tabela
/// de RN-11 — RN-11 · A-03 · LIST-09.
///
/// Duas contribuições, e só duas:
///
/// - item **coberto** por [tabela] (mesma [ItemDeLista.chave]) entra com o
///   `mínimo` e o `máximo` da linha de RN-11;
/// - item que a tabela **não** cobre entra com o próprio [ItemDeLista.valor]
///   nas duas pontas — não se fabrica faixa para item sem linha.
///
/// 🍽️ Copos & pratos fica fora das duas pontas, pelo mesmo `itensCobraveis`
/// que o tira do total e do pedido (AD-010).
///
/// Soma **exata**, sem arredondar em passo nenhum: quem arredonda é RN-13, uma
/// única vez, na formatação (AD-009). No estado padrão de RN-30 devolve
/// 244,60 e 342,60, que `MoneyFormatter` exibe como **R$ 245** e **R$ 343**.
///
/// Aplicada a uma lista em que **todo** item é coberto, degenera em
/// [totalDeMercado] — é a mesma soma, por outra porta.
FaixaReal faixaRealDaLista(
  Iterable<ItemDeLista> itens,
  Iterable<PrecoDeMercado> tabela,
) {
  final porChave = <ChaveItem, PrecoDeMercado>{
    for (final preco in tabela)
      if (preco.chave != null) preco.chave as ChaveItem: preco,
  };

  var minimo = 0.0;
  var maximo = 0.0;

  for (final item in itensCobraveis(itens)) {
    final preco = porChave[item.chave];

    minimo += preco?.minimo ?? item.valor;
    maximo += preco?.maximo ?? item.valor;
  }

  return FaixaReal(minimo: minimo, maximo: maximo);
}
