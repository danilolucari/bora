import 'package:bora/core/calculo/regras/quantidade_de_destilado.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CALC-13 — garrafas por destilado (RN-09)', () {
    test('os 6 adultos do estado padrão só na cachaça pedem 1 garrafa', () {
      expect(
        garrafasPorDestilado(
          adultos: 6,
          fator: 1,
          destiladosSelecionados: 1,
        ),
        1,
        reason: '6 × 120 = 720 ml → 1 garrafa de 1 L, R\$ 15',
      );
    });

    test('dois destilados dividem os mesmos 720 ml — 1 garrafa de cada', () {
      expect(
        garrafasPorDestilado(
          adultos: 6,
          fator: 1,
          destiladosSelecionados: 2,
        ),
        1,
        reason: '360 ml de cada; os 120 ml por adulto se dividem, não dobram',
      );
    });

    test('10 adultos passam do litro e pedem 2 garrafas', () {
      expect(
        garrafasPorDestilado(
          adultos: 10,
          fator: 1,
          destiladosSelecionados: 1,
        ),
        2,
        reason: '10 × 120 = 1200 ml',
      );
    });

    test('o dia todo (f=2,5) leva os 6 adultos a 2 garrafas', () {
      expect(
        garrafasPorDestilado(
          adultos: 6,
          fator: 2.5,
          destiladosSelecionados: 1,
        ),
        2,
        reason: '720 × 2,5 = 1800 ml',
      );
    });

    test('um litro exato não vira duas garrafas', () {
      expect(
        garrafasPorDestilado(
          adultos: 25,
          fator: 1,
          destiladosSelecionados: 3,
        ),
        1,
        reason: '25 × 120 ÷ 3 = 1000 ml exatos',
      );
    });
  });

  group('CALC-13 — sem adulto ou sem seleção, não há destilado (A-12)', () {
    test('festa só de crianças não compra destilado', () {
      expect(
        garrafasPorDestilado(
          adultos: 0,
          fator: 1,
          destiladosSelecionados: 1,
        ),
        0,
        reason: 'RN-09 é só para adultos; o piso não compra para plateia '
            'nenhuma',
      );
    });

    test('nenhum destilado selecionado dá 0, sem dividir por zero', () {
      expect(
        garrafasPorDestilado(
          adultos: 6,
          fator: 1,
          destiladosSelecionados: 0,
        ),
        0,
      );
    });
  });
}
