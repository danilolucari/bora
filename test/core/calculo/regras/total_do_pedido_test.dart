import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/item_de_lista.dart';
import 'package:bora/core/calculo/regras/total_do_pedido.dart';
import 'package:flutter_test/flutter_test.dart';

ItemDeLista _item(
  ChaveItem chave, {
  required double quantidade,
  required double preco,
  bool noCarrinho = false,
  double? quantidadeOverride,
  double? precoOverride,
}) =>
    ItemDeLista(
      chave: chave,
      nome: chave.chave,
      emoji: '🛒',
      unidade: UnidadeDeItem.unidade,
      quantidadeAutomatica: quantidade,
      precoBase: preco,
      quantidadeOverride: quantidadeOverride,
      precoOverride: precoOverride,
      noCarrinho: noCarrinho,
    );

/// Três itens do pedido: R$ 54,00 + R$ 21,60 + R$ 24,00 = R$ 99,60.
List<ItemDeLista> _pedido() => [
      _item(ChaveItem.bovina, quantidade: 1.2, preco: 45),
      _item(ChaveItem.frango, quantidade: 1.2, preco: 18, noCarrinho: true),
      _item(ChaveItem.paoDeAlho, quantidade: 4, preco: 6),
    ];

void main() {
  group('CALC-26 — o subtotal da sheet de pedido (RN-27)', () {
    test('soma o valor de todos os itens, sem arredondar as parcelas', () {
      expect(subtotalDeItens(_pedido()), closeTo(99.6, 0.001));
    });

    test('lista vazia dá subtotal 0', () {
      expect(subtotalDeItens(const []), 0);
      expect(subtotalDoQueFalta(const []), 0);
    });

    test('o subtotal usa o valor ajustado à mão, não o automático (RN-12)', () {
      final ajustado = [
        _item(
          ChaveItem.bovina,
          quantidade: 1.2,
          preco: 45,
          quantidadeOverride: 2,
          precoOverride: 50,
        ),
      ];

      expect(
        subtotalDeItens(ajustado),
        closeTo(100, 0.001),
        reason: 'o item vale 2 × 50; somar o automático daria 54',
      );
    });
  });

  group('CALC-26 — "PEDIR O QUE FALTA" só pede o que não foi marcado', () {
    test('o que já está no carrinho fica de fora do subtotal', () {
      expect(
        subtotalDoQueFalta(_pedido()),
        closeTo(78, 0.001),
        reason: 'o frango de R\$ 21,60 já está no carrinho',
      );
    });

    test('com tudo no carrinho, não falta nada a pedir', () {
      final tudoMarcado = [
        for (final item in _pedido()) item.copyWith(noCarrinho: true),
      ];

      expect(subtotalDoQueFalta(tudoMarcado), 0);
    });
  });

  group('CALC-26 — subtotal + frete = total (RN-27)', () {
    test('o total soma o frete ao subtotal', () {
      final pedido = totalDoPedido(subtotal: 99.6, frete: 12);

      expect(pedido.subtotal, closeTo(99.6, 0.001));
      expect(pedido.frete, closeTo(12, 0.001));
      expect(pedido.total, closeTo(111.6, 0.001));
    });

    test('frete grátis deixa o total igual ao subtotal (Zé Delivery)', () {
      final pedido = totalDoPedido(subtotal: 99.6, frete: 0);

      expect(pedido.total, closeTo(99.6, 0.001));
      expect(pedido.total, pedido.subtotal);
    });
  });
}
