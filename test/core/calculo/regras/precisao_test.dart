import 'package:bora/core/calculo/regras/precisao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CALC-07 — o quilo arredonda em décimos, contando gramas', () {
    test('1149 g dão 1,1 kg', () {
      expect(kgArredondadoEmDecimos(1149), 1.1);
    });

    test('1150 g dão 1,2 kg — meio para cima, sem erro de ponto flutuante',
        () {
      expect(
        kgArredondadoEmDecimos(1150),
        1.2,
        reason: 'arredondar em kg daria 1,1 e quebraria o caso literal de '
            'R\$ 211',
      );
    });

    test('1151 g dão 1,2 kg', () {
      expect(kgArredondadoEmDecimos(1151), 1.2);
    });

    test('0 g dão 0,0 kg', () {
      expect(kgArredondadoEmDecimos(0), 0.0);
    });
  });

  group('CALC-07 — unidades inteiras com piso de 1', () {
    test('0,1 unidade vira 1', () {
      expect(unidadesComPisoDeUm(0.1), 1);
    });

    test('1,0 unidade continua 1', () {
      expect(unidadesComPisoDeUm(1.0), 1);
    });

    test('1,45 unidade vira 2 — arredonda para cima, não para o mais próximo',
        () {
      expect(unidadesComPisoDeUm(1.45), 2);
    });

    test('17,14 unidades viram 18', () {
      expect(unidadesComPisoDeUm(17.14), 18);
    });
  });

  group('CALC-21 — tolerância de 1 centavo', () {
    test('a tolerância é de um centavo', () {
      expect(toleranciaDeCentavo, 0.01);
    });

    test('um centavo conta como zero', () {
      expect(ehZeroNaTolerancia(0.01), isTrue);
    });

    test('um centavo e um décimo já não é zero', () {
      expect(ehZeroNaTolerancia(0.011), isFalse);
    });

    test('a tolerância vale nos dois sentidos: dívida também zera', () {
      expect(ehZeroNaTolerancia(-0.01), isTrue);
      expect(ehZeroNaTolerancia(-0.011), isFalse);
    });
  });
}
