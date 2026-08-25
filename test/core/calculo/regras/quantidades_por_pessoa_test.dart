import 'package:bora/core/calculo/regras/quantidades_por_pessoa.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CALC-08 — pão de alho por pessoa (RN-04)', () {
    test('as 7 pessoas do estado padrão com f=1 pedem 4 unidades', () {
      expect(
        unidadesDePaoDeAlho(pessoas: 7, fator: 1),
        4,
        reason: '7 × 0,5 = 3,5 → arredonda para cima',
      );
    });

    test('8 pessoas pedem exatamente 4 unidades — o ceil não inventa a 5ª',
        () {
      expect(unidadesDePaoDeAlho(pessoas: 8, fator: 1), 4);
    });

    test('1 pessoa pede 1 unidade — meio pão não se compra', () {
      expect(unidadesDePaoDeAlho(pessoas: 1, fator: 1), 1);
    });

    test('2 pessoas numa festa de 2 h (f=0,5) pedem 1 unidade', () {
      expect(unidadesDePaoDeAlho(pessoas: 2, fator: 0.5), 1);
    });

    test('o dia todo (f=2,5) leva as 7 pessoas a 9 unidades', () {
      expect(
        unidadesDePaoDeAlho(pessoas: 7, fator: 2.5),
        9,
        reason: '7 × 0,5 × 2,5 = 8,75 → 9',
      );
    });
  });

  group('CALC-12 — água por pessoa (RN-08)', () {
    test('as 7 pessoas do estado padrão com f=1 pedem 2 garrafas', () {
      expect(
        garrafasDeAgua(pessoas: 7, fator: 1),
        2,
        reason: '2800 ml ÷ 1500 = 1,867 → 2 garrafas de 1,5 L',
      );
    });

    test('3 pessoas pedem 1 garrafa', () {
      expect(garrafasDeAgua(pessoas: 3, fator: 1), 1);
    });

    test('1 pessoa pede 1 garrafa — o piso de RN-08', () {
      expect(garrafasDeAgua(pessoas: 1, fator: 1), 1);
    });

    test('exatamente 1500 ml cabem numa garrafa só', () {
      expect(
        garrafasDeAgua(pessoas: 5, fator: 0.75),
        1,
        reason: '5 × 400 × 0,75 = 1500 ml — a fronteira exata não vira 2',
      );
    });

    test('o dia todo (f=2,5) leva as 7 pessoas a 5 garrafas', () {
      expect(garrafasDeAgua(pessoas: 7, fator: 2.5), 5);
    });
  });
}
