import 'package:bora/core/calculo/regras/fator_duracao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CALC-02 — RN-02 dá o fator de duração', () {
    test('2 horas dão fator 0.5', () {
      expect(fatorDuracao(2), 0.5);
    });

    test('4 horas — o baseline — dão fator 1.0', () {
      expect(fatorDuracao(4), 1.0);
    });

    test('6 horas dão fator 1.5', () {
      expect(fatorDuracao(6), 1.5);
    });

    test('dia todo — 10 horas — dá fator 2.5', () {
      expect(fatorDuracao(10), 2.5);
    });
  });

  group('CALC-02 — o piso de 0.5 segura as durações curtas', () {
    test('1 hora não desce de 0.5', () {
      expect(fatorDuracao(1), 0.5);
    });

    test('0 hora não desce de 0.5', () {
      expect(fatorDuracao(0), 0.5);
    });
  });
}
