import 'package:bora/core/calculo/regras/quantidade_de_cerveja.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CALC-09 — latas de cerveja (RN-05)', () {
    test('os 6 adultos do estado padrão com f=1 pedem 18 latas', () {
      expect(
        latasDeCerveja(adultosQueBebem: 6, fator: 1),
        18,
        reason: '6000 ml ÷ 350 = 17,14 → 18 latas, R\$ 72',
      );
    });

    test('1 adulto pede 3 latas', () {
      expect(
        latasDeCerveja(adultosQueBebem: 1, fator: 1),
        3,
        reason: '1000 ml ÷ 350 = 2,86',
      );
    });

    test('a festa de 2 h (f=0,5) reduz os 6 adultos a 9 latas', () {
      expect(latasDeCerveja(adultosQueBebem: 6, fator: 0.5), 9);
    });

    test('o dia todo (f=2,5) leva os 6 adultos a 43 latas', () {
      expect(
        latasDeCerveja(adultosQueBebem: 6, fator: 2.5),
        43,
        reason: '15000 ml ÷ 350 = 42,86',
      );
    });

    test('volume exato de uma lata não vira duas', () {
      expect(
        latasDeCerveja(adultosQueBebem: 1, fator: 0.35),
        1,
        reason: '350 ml é exatamente uma lata — o ceil não arredonda o exato',
      );
    });

    test('volume exato de dez latas não vira onze', () {
      expect(
        latasDeCerveja(adultosQueBebem: 7, fator: 0.5),
        10,
        reason: '7 × 1000 × 0,5 = 3500 ml ÷ 350 = 10 exatos',
      );
    });
  });

  group('CALC-09 — sem quem beba, não há cerveja (A-12)', () {
    test('ninguém que bebe dá 0 latas, não 1', () {
      expect(
        latasDeCerveja(adultosQueBebem: 0, fator: 1),
        0,
        reason: 'o piso de RN-05 vale quando há plateia; festa só de crianças '
            'não compra cerveja',
      );
    });

    test('nem o dia todo faz aparecer lata sem quem beba', () {
      expect(latasDeCerveja(adultosQueBebem: 0, fator: 2.5), 0);
    });
  });
}
