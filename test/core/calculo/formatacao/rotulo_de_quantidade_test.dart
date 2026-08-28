import 'package:bora/core/calculo/calculo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MONT-11 — os quatro rótulos que o design §7.2 declara', () {
    test('carne fracionária: 1,2 kg', () {
      expect(rotuloDeQuantidade(1.2, UnidadeDeItem.kg), '1,2 kg');
    });

    test('cerveja do estado padrão de RN-30: 8 latas', () {
      expect(rotuloDeQuantidade(8, UnidadeDeItem.lata), '8 latas');
    });

    test('refrigerante: 2 garrafas', () {
      expect(rotuloDeQuantidade(2, UnidadeDeItem.garrafa), '2 garrafas');
    });

    test('kit veggie de RN-21: 1 kit', () {
      expect(rotuloDeQuantidade(1, UnidadeDeItem.kit), '1 kit');
    });
  });

  group('MONT-11 — quantidade inteira sai sem casa decimal', () {
    test('2 garrafas, nunca "2,0 garrafas"', () {
      expect(rotuloDeQuantidade(2, UnidadeDeItem.garrafa), '2 garrafas');
      expect(rotuloDeQuantidade(2, UnidadeDeItem.garrafa), isNot(contains(',')));
    });

    test('inteiro grande não ganha decimal', () {
      expect(rotuloDeQuantidade(18, UnidadeDeItem.lata), '18 latas');
    });

    test('o que arredonda para inteiro também sai sem casa', () {
      expect(
        rotuloDeQuantidade(1.98, UnidadeDeItem.kg),
        '2 kg',
        reason: 'a decisão "é inteiro?" vale sobre o número exibido, não '
            'sobre o que veio da calculadora',
      );
    });
  });

  group('MONT-11 — quantidade fracionária sai com uma casa e vírgula pt-BR',
      () {
    test('uma casa decimal, com vírgula e nunca ponto', () {
      expect(rotuloDeQuantidade(1.2, UnidadeDeItem.kg), '1,2 kg');
      expect(rotuloDeQuantidade(1.2, UnidadeDeItem.kg), isNot(contains('.')));
    });

    test('arredonda para uma casa — a precisão de 0,1 kg da AD-009', () {
      expect(rotuloDeQuantidade(1.25, UnidadeDeItem.kg), '1,3 kg');
      expect(rotuloDeQuantidade(1.24, UnidadeDeItem.kg), '1,2 kg');
    });

    test('meio quilo é 0,5 kg, não 0.5 kg', () {
      expect(rotuloDeQuantidade(0.5, UnidadeDeItem.kg), '0,5 kg');
    });

    test('fracionário maior que 1 fica no plural', () {
      expect(rotuloDeQuantidade(1.5, UnidadeDeItem.lata), '1,5 latas');
    });
  });

  group('MONT-11 — plural por unidade, com o singular em 1', () {
    test('kg não pluraliza — é símbolo de medida, não substantivo', () {
      expect(rotuloDeQuantidade(1, UnidadeDeItem.kg), '1 kg');
      expect(rotuloDeQuantidade(3, UnidadeDeItem.kg), '3 kg');
    });

    test('unidade / unidades', () {
      expect(rotuloDeQuantidade(1, UnidadeDeItem.unidade), '1 unidade');
      expect(rotuloDeQuantidade(4, UnidadeDeItem.unidade), '4 unidades');
    });

    test('garrafa / garrafas', () {
      expect(rotuloDeQuantidade(1, UnidadeDeItem.garrafa), '1 garrafa');
      expect(rotuloDeQuantidade(2, UnidadeDeItem.garrafa), '2 garrafas');
    });

    test('lata / latas', () {
      expect(rotuloDeQuantidade(1, UnidadeDeItem.lata), '1 lata');
      expect(rotuloDeQuantidade(18, UnidadeDeItem.lata), '18 latas');
    });

    test('litro / litros', () {
      expect(rotuloDeQuantidade(1, UnidadeDeItem.litro), '1 litro');
      expect(rotuloDeQuantidade(3, UnidadeDeItem.litro), '3 litros');
    });

    test('saco / sacos', () {
      expect(rotuloDeQuantidade(1, UnidadeDeItem.saco), '1 saco');
      expect(rotuloDeQuantidade(2, UnidadeDeItem.saco), '2 sacos');
    });

    test('kit / kits', () {
      expect(rotuloDeQuantidade(1, UnidadeDeItem.kit), '1 kit');
      expect(rotuloDeQuantidade(2, UnidadeDeItem.kit), '2 kits');
    });

    test('só o 1 exato é singular — 1,2 já é plural', () {
      expect(rotuloDeQuantidade(1.2, UnidadeDeItem.lata), '1,2 latas');
    });
  });

  group('MONT-11 — zero tem rótulo definido e não quebra', () {
    test('zero é plural, como em pt-BR', () {
      expect(rotuloDeQuantidade(0, UnidadeDeItem.lata), '0 latas');
      expect(rotuloDeQuantidade(0, UnidadeDeItem.kg), '0 kg');
    });

    test('nenhuma das sete unidades quebra em zero', () {
      for (final unidade in UnidadeDeItem.values) {
        final rotulo = rotuloDeQuantidade(0, unidade);

        expect(rotulo, startsWith('0 '), reason: 'unidade $unidade');
        expect(rotulo.split(' ').last, isNotEmpty, reason: 'unidade $unidade');
      }
    });
  });

  group('MONT-11 — toda unidade de UnidadeDeItem tem rótulo', () {
    test('as sete unidades têm singular e plural, sem ponto decimal', () {
      expect(UnidadeDeItem.values, hasLength(7));

      for (final unidade in UnidadeDeItem.values) {
        final singular = rotuloDeQuantidade(1, unidade);
        final plural = rotuloDeQuantidade(2, unidade);

        expect(singular, startsWith('1 '), reason: 'unidade $unidade');
        expect(plural, startsWith('2 '), reason: 'unidade $unidade');
        expect(singular, isNot(contains('.')), reason: 'unidade $unidade');
        expect(plural, isNot(contains('.')), reason: 'unidade $unidade');
      }
    });

    test('só kg repete a mesma palavra no singular e no plural', () {
      final invariantes = UnidadeDeItem.values.where(
        (unidade) =>
            rotuloDeQuantidade(1, unidade).split(' ').last ==
            rotuloDeQuantidade(2, unidade).split(' ').last,
      );

      expect(
        invariantes,
        [UnidadeDeItem.kg],
        reason: 'plural esquecido numa unidade nova morre aqui',
      );
    });
  });
}
