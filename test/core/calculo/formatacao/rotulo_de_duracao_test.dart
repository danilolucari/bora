import 'package:bora/core/calculo/formatacao/rotulo_de_duracao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CALC-04 — RN-13 rotula a duração da festa', () {
    test('2 horas', () {
      expect(rotuloDeDuracao(2), '2 horas');
    });

    test('4 horas', () {
      expect(rotuloDeDuracao(4), '4 horas');
    });

    test('6 horas', () {
      expect(rotuloDeDuracao(6), '6 horas');
    });

    test('10 horas é o dia todo', () {
      expect(rotuloDeDuracao(10), 'Dia todo');
    });
  });
}
