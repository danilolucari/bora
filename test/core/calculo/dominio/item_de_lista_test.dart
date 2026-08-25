import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/item_de_lista.dart';
import 'package:flutter_test/flutter_test.dart';

ItemDeLista _bovina({double? quantidadeOverride, double? precoOverride}) =>
    ItemDeLista(
      chave: ChaveItem.bovina,
      nome: 'BOVINA',
      emoji: '🥩',
      unidade: UnidadeDeItem.kg,
      quantidadeAutomatica: 1.2,
      precoBase: 45,
      quantidadeOverride: quantidadeOverride,
      precoOverride: precoOverride,
    );

void main() {
  group('CALC-05 — o valor do item sai de quantidade × preço', () {
    test('sem ajuste, a bovina de 1,2 kg a R\$ 45/kg vale 54', () {
      expect(_bovina().quantidade, 1.2);
      expect(_bovina().preco, 45);
      expect(_bovina().valor, closeTo(54, 0.001));
    });

    test('sem ajuste, o frango de 1,2 kg a R\$ 18/kg vale 21,60 — sem '
        'arredondar no item', () {
      final frango = ItemDeLista(
        chave: ChaveItem.frango,
        nome: 'FRANGO',
        emoji: '🍗',
        unidade: UnidadeDeItem.kg,
        quantidadeAutomatica: 1.2,
        precoBase: 18,
      );

      expect(
        frango.valor,
        closeTo(21.6, 0.001),
        reason: 'dinheiro arredonda uma única vez, na formatação (RN-13)',
      );
    });

    test('o ajuste de quantidade substitui a automática', () {
      final item = _bovina(quantidadeOverride: 2);

      expect(item.quantidade, 2);
      expect(item.quantidadeAutomatica, 1.2);
      expect(item.valor, closeTo(90, 0.001));
    });

    test('o ajuste de preço substitui o preço-base', () {
      final item = _bovina(precoOverride: 50);

      expect(item.preco, 50);
      expect(item.precoBase, 45);
      expect(item.valor, closeTo(60, 0.001));
    });

    test('os dois ajustes juntos valem ao mesmo tempo', () {
      final item = _bovina(quantidadeOverride: 2, precoOverride: 50);

      expect(item.valor, closeTo(100, 0.001));
    });
  });

  group('CALC-17 — o item se declara editado (RN-12)', () {
    test('sem nenhum ajuste, não está editado', () {
      expect(_bovina().editado, isFalse);
    });

    test('com ajuste só de quantidade, está editado', () {
      expect(_bovina(quantidadeOverride: 2).editado, isTrue);
    });

    test('com ajuste só de preço, está editado', () {
      expect(_bovina(precoOverride: 50).editado, isTrue);
    });
  });

  group('CALC-05 — o item é valor, não identidade', () {
    test('dois itens com os mesmos campos são iguais e têm o mesmo hashCode',
        () {
      expect(_bovina(), _bovina());
      expect(_bovina().hashCode, _bovina().hashCode);
    });

    test('um ajuste de quantidade torna o item diferente', () {
      expect(_bovina(quantidadeOverride: 2), isNot(_bovina()));
    });

    test('um ajuste de preço torna o item diferente', () {
      expect(_bovina(precoOverride: 50), isNot(_bovina()));
    });

    test('copyWith troca só o campo pedido e não muta o original', () {
      final original = _bovina();
      final copia = original.copyWith(quemLeva: 'Ana', noCarrinho: true);

      expect(copia.quemLeva, 'Ana');
      expect(copia.noCarrinho, isTrue);
      expect(copia.quantidadeAutomatica, 1.2);
      expect(original.quemLeva, isNull);
      expect(original.noCarrinho, isFalse);
    });
  });

  group('CALC-17 — OverrideDeItem', () {
    test('nasce sem ajuste nenhum', () {
      const override = OverrideDeItem();

      expect(override.quantidade, isNull);
      expect(override.preco, isNull);
    });

    test('dois overrides com os mesmos campos são iguais', () {
      expect(
        const OverrideDeItem(quantidade: 2, preco: 50),
        const OverrideDeItem(quantidade: 2, preco: 50),
      );
      expect(
        const OverrideDeItem(quantidade: 2).hashCode,
        const OverrideDeItem(quantidade: 2).hashCode,
      );
      expect(
        const OverrideDeItem(quantidade: 2),
        isNot(const OverrideDeItem(preco: 2)),
      );
    });
  });
}
