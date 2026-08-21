import 'package:bora/core/calculo/regras/quantidades_de_bebida.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CALC-10 — refrigerante (RN-06)', () {
    test('o estado padrão 6 adultos + 1 criança com f=1 pede 2 garrafas', () {
      expect(
        garrafasDeRefrigerante(adultos: 6, criancas: 1, fator: 1),
        2,
        reason: '(6×400 + 1×500) = 2900 ml ÷ 2000 = 1,45 → 2 garrafas de 2 L',
      );
    });

    test('exatamente 2000 ml cabem numa garrafa só', () {
      expect(
        garrafasDeRefrigerante(adultos: 5, criancas: 0, fator: 1),
        1,
        reason: '5 × 400 = 2000 ml — a fronteira exata não vira 2',
      );
    });

    test('criança bebe 500 ml, não 400: 5 crianças passam de uma garrafa', () {
      expect(
        garrafasDeRefrigerante(adultos: 0, criancas: 5, fator: 1),
        2,
        reason: '5 × 500 = 2500 ml; a 400 ml daria 2000 e caberia em 1',
      );
    });

    test('sem ninguém, o piso de RN-06 devolve 1 garrafa', () {
      expect(garrafasDeRefrigerante(adultos: 0, criancas: 0, fator: 1), 1);
    });

    test('o dia todo (f=2,5) leva o estado padrão a 4 garrafas', () {
      expect(
        garrafasDeRefrigerante(adultos: 6, criancas: 1, fator: 2.5),
        4,
        reason: '2900 × 2,5 = 7250 ml ÷ 2000 = 3,625 → 4',
      );
    });
  });

  group('CALC-11 — suco (RN-07)', () {
    test('o estado padrão 6 adultos + 1 criança com f=1 pede 2 litros', () {
      expect(
        litrosDeSuco(adultos: 6, criancas: 1, fator: 1),
        2,
        reason: '(6×250 + 1×400) = 1900 ml ÷ 1000 = 1,9 → 2 L',
      );
    });

    test('adulto bebe 250 ml: 5 adultos passam de um litro', () {
      expect(
        litrosDeSuco(adultos: 5, criancas: 0, fator: 1),
        2,
        reason: '5 × 250 = 1250 ml',
      );
    });

    test('exatamente 1000 ml cabem num litro só', () {
      expect(litrosDeSuco(adultos: 4, criancas: 0, fator: 1), 1);
    });

    test('criança bebe 400 ml: 3 crianças passam de um litro', () {
      expect(
        litrosDeSuco(adultos: 0, criancas: 3, fator: 1),
        2,
        reason: '3 × 400 = 1200 ml; a 250 ml daria 750 e caberia em 1',
      );
    });

    test('sem ninguém, o piso de RN-07 devolve 1 litro', () {
      expect(litrosDeSuco(adultos: 0, criancas: 0, fator: 1), 1);
    });

    test('a festa de 2 h (f=0,5) reduz o estado padrão a 1 litro', () {
      expect(
        litrosDeSuco(adultos: 6, criancas: 1, fator: 0.5),
        1,
        reason: '1900 × 0,5 = 950 ml → 1 L',
      );
    });
  });
}
