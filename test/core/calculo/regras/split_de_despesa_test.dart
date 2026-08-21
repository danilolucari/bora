import 'package:bora/core/calculo/dominio/despesa.dart';
import 'package:bora/core/calculo/regras/split_de_despesa.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CALC-22 — o split igualitário da despesa (RN-17)', () {
    test('R\$ 80 entre 4 adultos dão R\$ 20 para cada um', () {
      final split = splitIgualitario(
        despesa: const Despesa(
          quemPagou: 'ANA',
          descricao: 'Gelo + carvão',
          valor: 80,
        ),
        adultos: 4,
      );

      expect(split.valorPorAdulto, closeTo(20, 0.001));
    });

    test('o valor fracionário fica exato — o arredondamento é da exibição', () {
      final split = splitIgualitario(
        despesa: const Despesa(
          quemPagou: 'LÉO',
          descricao: 'Descartáveis',
          valor: 100,
        ),
        adultos: 3,
      );

      expect(
        split.valorPorAdulto,
        closeTo(33.3333, 0.001),
        reason: 'arredondar aqui daria 33 e o rateio deixaria de fechar',
      );
      expect(split.valorPorAdulto, isNot(closeTo(33, 0.001)));
    });

    test('sem adulto nenhum o valor por adulto é 0 — nunca NaN nem Infinity',
        () {
      final split = splitIgualitario(
        despesa: const Despesa(quemPagou: 'BIA', descricao: 'Gelo', valor: 80),
        adultos: 0,
      );

      expect(split.valorPorAdulto, 0.0);
      expect(split.valorPorAdulto.isNaN, isFalse);
      expect(split.valorPorAdulto.isInfinite, isFalse);
    });

    test('o número de adultos volta junto, para a copy "split R\$ X × N"', () {
      final split = splitIgualitario(
        despesa: const Despesa(
          quemPagou: 'RAFA',
          descricao: 'Carnes',
          valor: 200,
        ),
        adultos: 4,
      );

      expect(split.adultos, 4);
      expect(split.valorPorAdulto, closeTo(50, 0.001));
    });

    test('a despesa rateada volta inteira, com quem adiantou', () {
      const despesa = Despesa(
        quemPagou: 'RAFA',
        descricao: 'Carnes + carvão',
        valor: 200,
      );

      final split = splitIgualitario(despesa: despesa, adultos: 4);

      expect(split.despesa, despesa);
      expect(split.despesa.quemPagou, 'RAFA');
    });

    test('o divisor são os adultos, não as pessoas — criança de fora (RN-14)',
        () {
      const despesa = Despesa(quemPagou: 'ANA', descricao: 'Gelo', valor: 80);

      final entreQuatroAdultos = splitIgualitario(
        despesa: despesa,
        adultos: 4,
      );

      expect(
        entreQuatroAdultos.valorPorAdulto,
        closeTo(20, 0.001),
        reason: 'numa festa de 4 adultos + 2 crianças, dividir pelas 6 pessoas '
            'daria 13,33 e quebraria RN-14',
      );
      expect(entreQuatroAdultos.valorPorAdulto, isNot(closeTo(80 / 6, 0.001)));
    });
  });
}
