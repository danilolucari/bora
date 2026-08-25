import 'package:bora/core/calculo/regras/cota.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CALC-19 — a cota justa é o total dividido pelos adultos (RN-14)', () {
    test('total 320 entre 4 adultos dá cota 80 — o Teste A de RN-16', () {
      expect(cotaPorAdulto(total: 320, adultos: 4), closeTo(80, 0.001));
    });

    test('total 380 entre 4 adultos dá cota 95 — o Teste B de RN-16', () {
      expect(cotaPorAdulto(total: 380, adultos: 4), closeTo(95, 0.001));
    });

    test('criança fica de fora: o divisor são os adultos, nunca as pessoas',
        () {
      const total = 270.6;

      expect(
        cotaPorAdulto(total: total, adultos: 6),
        closeTo(45.1, 0.001),
        reason: 'a festa padrão tem 7 pessoas e 6 adultos; dividir por 7 daria '
            '38,66 e quebraria RN-14',
      );
      expect(
        cotaPorAdulto(total: total, adultos: 6),
        isNot(closeTo(total / 7, 0.001)),
      );
    });

    test('sem adulto nenhum a cota é 0 — nunca NaN nem Infinity', () {
      final cota = cotaPorAdulto(total: 320, adultos: 0);

      expect(cota, 0.0);
      expect(cota.isNaN, isFalse);
      expect(cota.isInfinite, isFalse);
    });

    test('total zero dá cota zero', () {
      expect(cotaPorAdulto(total: 0, adultos: 4), closeTo(0, 0.001));
    });
  });
}
