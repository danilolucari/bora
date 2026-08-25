import '../dominio/item_de_lista.dart';
import 'totais.dart';

/// O subtotal da sheet de pedido: a soma **exata** do valor de [itens] —
/// RN-27 · CALC-26.
///
/// É o mesmo somatório de `totalExato`, e delega a ele de propósito: duas
/// somas iguais em arquivos diferentes divergiriam no primeiro ajuste. O nome
/// existe porque a sheet fala em "subtotal", não em "total da festa".
///
/// Soma o [ItemDeLista.valor], que já é o ajuste manual quando existe (RN-12).
double subtotalDeItens(Iterable<ItemDeLista> itens) => totalExato(itens);

/// O subtotal de "PEDIR O QUE FALTA 🛵" — só os itens que **não** estão no
/// carrinho — RN-27 · CALC-26.
///
/// No modo COMPRAR o CTA troca de sentido: em vez de pedir a lista inteira,
/// pede só o que ainda não foi marcado. Com tudo marcado, o subtotal é 0.
double subtotalDoQueFalta(Iterable<ItemDeLista> itens) =>
    totalExato(itens.where((item) => !item.noCarrinho));

/// O rodapé da sheet de pedido: `subtotal + frete = total` — RN-27 · CALC-26.
///
/// **A aritmética para aqui.** A ordem dos corredores do modo COMPRAR, os
/// parceiros de delivery (iFood Mercado, Rappi Turbo, Zé Delivery), os ETAs e
/// **os valores de frete** são da spec `lista`, dona de RN-27. Esta camada só
/// soma — porque o `CLAUDE.md` proíbe aritmética dentro de widget, e um
/// `subtotal + frete` feito na sheet seria exatamente isso.
class TotalDoPedido {
  const TotalDoPedido({required this.subtotal, required this.frete});

  /// A soma dos itens pedidos.
  final double subtotal;

  /// O frete do parceiro escolhido — **um dado de entrada**, que quem monta a
  /// sheet informa. O Zé Delivery entra com 0.
  final double frete;

  /// `subtotal + frete`, sem arredondar: dinheiro arredonda uma única vez, na
  /// formatação (RN-13).
  ///
  /// É derivado, não armazenado, para que não exista `TotalDoPedido` com um
  /// total que não bate com as parcelas.
  double get total => subtotal + frete;
}

/// Monta o total do pedido a partir do subtotal e do frete — RN-27 · CALC-26.
TotalDoPedido totalDoPedido({
  required double subtotal,
  required double frete,
}) =>
    TotalDoPedido(subtotal: subtotal, frete: frete);
