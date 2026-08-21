import 'package:bora/core/calculo/formatacao/money_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CALC-03 — RN-13 escreve dinheiro em pt-BR, sempre inteiro', () {
    test('zero vira R\$ 0', () {
      expect(MoneyFormatter.reais(0), r'R$ 0');
    });

    test('30,14 vira R\$ 30 — arredonda para baixo', () {
      expect(MoneyFormatter.reais(30.14), r'R$ 30');
    });

    test('210,60 — o total do caso literal — vira R\$ 211', () {
      expect(MoneyFormatter.reais(210.6), r'R$ 211');
    });

    test('270,60 — o total com essenciais — vira R\$ 271', () {
      expect(MoneyFormatter.reais(270.6), r'R$ 271');
    });

    test('30,5 vira R\$ 31 — meio afastado do zero', () {
      expect(MoneyFormatter.reais(30.5), r'R$ 31');
    });
  });

  group('CALC-03 — o milhar é agrupado com ponto', () {
    test('1234 vira R\$ 1.234', () {
      expect(MoneyFormatter.reais(1234), r'R$ 1.234');
    });

    test('1000000 vira R\$ 1.000.000', () {
      expect(MoneyFormatter.reais(1000000), r'R$ 1.000.000');
    });

    test('999 fica sem separador', () {
      expect(MoneyFormatter.reais(999), r'R$ 999');
    });
  });

  group('CALC-03 — sinal e ausência de centavos', () {
    test('valor negativo leva o sinal antes do R\$', () {
      expect(MoneyFormatter.reais(-5), r'-R$ 5');
      expect(MoneyFormatter.reais(-1234.6), r'-R$ 1.235');
    });

    test('nenhuma saída tem vírgula nem centavo', () {
      const valores = [0, 30.14, 210.6, 270.6, 30.5, 1234, 1000000, -5];

      for (final valor in valores) {
        expect(
          MoneyFormatter.reais(valor),
          isNot(contains(',')),
          reason: 'RN-13 proíbe centavos e separador decimal',
        );
      }
    });
  });
}
