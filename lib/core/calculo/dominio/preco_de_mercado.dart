import 'chave_item.dart';
import 'corredor.dart';

/// Uma linha da tabela de preço médio real de RN-11 — CALC-24.
///
/// É a **segunda** fonte de preço do projeto, e ela nunca se mistura com a
/// primeira: `catalogoDeItens` governa a **calculadora** (o "SAI POR" da tela
/// Montar, que produz o R$ 211), enquanto esta governa a **tela Lista no modo
/// PLANEJAR** — a média real de N mercados próximos, com a faixa mín–máx.
/// As duas coexistem de propósito e unificar quebraria um dos dois casos
/// literais (A-03): a Picanha bovina vale R$ 45/kg lá e média R$ 65 aqui.
///
/// Valor imutável e `const`, no mesmo formato de `DefinicaoDeItem`: linha de
/// catálogo, lida por chave, nunca comparada por valor.
class PrecoDeMercado {
  const PrecoDeMercado({
    required this.nome,
    required this.emoji,
    required this.corredor,
    required this.rotuloDeQuantidade,
    required this.media,
    required this.minimo,
    required this.maximo,
    required this.fontes,
    this.chave,
  });

  /// Copy literal de RN-11: `Picanha bovina`, `Linguiça toscana`, …
  final String nome;

  final String emoji;
  final Corredor corredor;

  /// A quantidade **como rótulo**, literal de RN-11: `1,2 kg`, `18 latas`,
  /// `kit veggie`. Não é número: `kit veggie` não tem unidade que a
  /// calculadora conheça, e converter exigiria inventar uma.
  final String rotuloDeQuantidade;

  /// A média dos [fontes] mercados — o número que a tela mostra.
  final double media;

  /// A ponta barata da faixa.
  final double minimo;

  /// A ponta cara da faixa.
  final double maximo;

  /// Quantos mercados entraram na média — o rótulo "média de N mercados".
  final int fontes;

  /// O item correspondente no catálogo da calculadora, **quando existe**.
  ///
  /// É `ChaveItem?` de propósito (risco R-6): a 🌭 Linguiça toscana de RN-11
  /// **não tem chip em T-03** nem preço-base em RN-03..RN-10. `null` é a única
  /// resposta honesta — criar `ChaveItem.linguica` obrigaria a inventar um
  /// preço-base que a spec não dá, e esse número fabricado entraria no R$ 211.
  ///
  /// O contrário também vale: RN-11 não cobre água, suco, sal, copos nem
  /// destilados. As duas tabelas não cobrem o mesmo conjunto (A-03).
  final ChaveItem? chave;
}
