import 'package:bora/core/calculo/dominio/catalogo_de_itens.dart';
import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/item_de_lista.dart';
import 'package:bora/core/calculo/regras/overrides.dart';
import 'package:flutter_test/flutter_test.dart';

/// Um item recém-calculado, sem nenhum ajuste manual.
ItemDeLista _automatico(ChaveItem chave, double quantidade) {
  final definicao = catalogoDeItens[chave]!;

  return ItemDeLista(
    chave: chave,
    nome: definicao.nome,
    emoji: definicao.emoji,
    unidade: definicao.unidade,
    quantidadeAutomatica: quantidade,
    precoBase: definicao.precoBase,
  );
}

void main() {
  group('CALC-17 — o passo de quantidade é o do item (RN-12)', () {
    test('a carne sobe de meio quilo em meio quilo', () {
      final ajustado =
          comPassoDeQuantidade(_automatico(ChaveItem.bovina, 1.2), 1);

      expect(ajustado.quantidade, closeTo(1.7, 0.001));
    });

    test('a cerveja sobe de duas latas em duas latas', () {
      final ajustado =
          comPassoDeQuantidade(_automatico(ChaveItem.cerveja, 18), 1);

      expect(ajustado.quantidade, closeTo(20, 0.001));
    });

    test('os demais sobem de um em um', () {
      final ajustado =
          comPassoDeQuantidade(_automatico(ChaveItem.paoDeAlho, 4), 1);

      expect(ajustado.quantidade, closeTo(5, 0.001));
    });

    test('vários passos de uma vez somam vários passos', () {
      final ajustado =
          comPassoDeQuantidade(_automatico(ChaveItem.bovina, 1.2), 3);

      expect(ajustado.quantidade, closeTo(2.7, 0.001));
    });
  });

  group('CALC-17 — descendo, o mínimo é um passo (RN-12)', () {
    test('a carne trava em 0,5 kg', () {
      final ajustado =
          comPassoDeQuantidade(_automatico(ChaveItem.bovina, 1.2), -5);

      expect(ajustado.quantidade, closeTo(0.5, 0.001));
    });

    test('a cerveja trava em 2 latas', () {
      final ajustado =
          comPassoDeQuantidade(_automatico(ChaveItem.cerveja, 18), -20);

      expect(ajustado.quantidade, closeTo(2, 0.001));
    });

    test('os demais travam em 1', () {
      final ajustado =
          comPassoDeQuantidade(_automatico(ChaveItem.paoDeAlho, 4), -10);

      expect(ajustado.quantidade, closeTo(1, 0.001));
    });
  });

  group('CALC-17 — o preço anda de R\$ 1 e para em R\$ 1 (RN-12)', () {
    test('sobe um real por passo', () {
      final ajustado = comPassoDePreco(_automatico(ChaveItem.bovina, 1.2), 3);

      expect(ajustado.preco, closeTo(48, 0.001), reason: '45 + 3');
    });

    test('trava em R\$ 1, nunca zera nem fica negativo', () {
      final ajustado =
          comPassoDePreco(_automatico(ChaveItem.bovina, 1.2), -100);

      expect(ajustado.preco, closeTo(1, 0.001));
    });
  });

  group('CALC-17 — os dois eixos são independentes', () {
    test('ajustar a quantidade preserva o preço ajustado, e vice-versa', () {
      final item = _automatico(ChaveItem.bovina, 1.2);
      final comPreco = comPassoDePreco(item, 5);
      final comOsDois = comPassoDeQuantidade(comPreco, 1);

      expect(comOsDois.preco, closeTo(50, 0.001));
      expect(comOsDois.quantidade, closeTo(1.7, 0.001));
      expect(comOsDois.valor, closeTo(85, 0.001), reason: '1,7 × 50');
    });
  });

  group('CALC-17 — automático → editado → restaurado (RN-12)', () {
    test('o item nasce não editado e se declara editado ao ser ajustado', () {
      final item = _automatico(ChaveItem.bovina, 1.2);

      expect(item.editado, isFalse);
      expect(comPassoDeQuantidade(item, 1).editado, isTrue);
      expect(comPassoDePreco(item, 1).editado, isTrue);
    });

    test('restaurar devolve exatamente o valor automático e apaga os dois '
        'ajustes', () {
      final item = _automatico(ChaveItem.bovina, 1.2);
      final editado = comPassoDePreco(comPassoDeQuantidade(item, 4), 10);

      expect(editado.quantidade, closeTo(3.2, 0.001));
      expect(editado.preco, closeTo(55, 0.001));

      final voltou = restaurado(editado);

      expect(voltou.editado, isFalse);
      expect(voltou.quantidadeOverride, isNull);
      expect(voltou.precoOverride, isNull);
      expect(voltou.quantidade, closeTo(1.2, 0.001));
      expect(voltou.preco, closeTo(45, 0.001));
      expect(
        voltou,
        item,
        reason: 'restaurado é o item automático de volta, campo a campo',
      );
    });

    test('restaurar zera os overrides, não o resto do item', () {
      final item = _automatico(ChaveItem.bovina, 1.2)
          .copyWith(quemLeva: 'LÉO', noCarrinho: true);

      final voltou = restaurado(comPassoDeQuantidade(item, 2));

      expect(voltou.quemLeva, 'LÉO');
      expect(voltou.noCarrinho, isTrue);
      expect(voltou.editado, isFalse);
    });
  });

  group('CALC-17 — o RESTAURAR global (RN-12)', () {
    test('semOverrides não guarda ajuste nenhum', () {
      expect(semOverrides(), isEmpty);
    });
  });
}
