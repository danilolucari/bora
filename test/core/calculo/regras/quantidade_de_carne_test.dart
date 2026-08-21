import 'package:bora/core/calculo/dominio/contagem_de_pessoas.dart';
import 'package:bora/core/calculo/regras/quantidade_de_carne.dart';
import 'package:flutter_test/flutter_test.dart';

ContagemDePessoas get _estadoPadrao =>
    ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1);

void main() {
  group('CALC-07 — gramas de carne da festa (RN-03)', () {
    test('o estado padrão 3H+3M+1C com f=1 dá 2300 g', () {
      expect(
        gramasDeCarne(contagem: _estadoPadrao, fator: 1),
        closeTo(2300, 0.001),
        reason: '3×400 + 3×300 + 1×200',
      );
    });

    test('cada sexo e a criança pesam diferente na conta', () {
      expect(
        gramasDeCarne(contagem: ContagemDePessoas(homens: 1), fator: 1),
        closeTo(400, 0.001),
      );
      expect(
        gramasDeCarne(contagem: ContagemDePessoas(mulheres: 1), fator: 1),
        closeTo(300, 0.001),
      );
      expect(
        gramasDeCarne(contagem: ContagemDePessoas(criancas: 1), fator: 1),
        closeTo(200, 0.001),
      );
    });

    test('a festa de 2 h (f=0,5) come metade: 1150 g', () {
      expect(
        gramasDeCarne(contagem: _estadoPadrao, fator: 0.5),
        closeTo(1150, 0.001),
      );
    });

    test('a festa de dia todo (f=2,5) come 5750 g', () {
      expect(
        gramasDeCarne(contagem: _estadoPadrao, fator: 2.5),
        closeTo(5750, 0.001),
      );
    });

    test('sem ninguém, não há grama nenhuma', () {
      expect(
        gramasDeCarne(contagem: ContagemDePessoas(), fator: 1),
        closeTo(0, 0.001),
      );
    });
  });

  group('CALC-07 — quilos por carne selecionada (RN-03)', () {
    test('2300 g entre bovina e frango dão 1,2 kg de cada', () {
      expect(
        kgPorCarne(gramasTotais: 2300, carnesSelecionadas: 2),
        1.2,
        reason: 'o caso literal do arquivo 03: 1150 g arredondam para cima',
      );
    });

    test('1150 g por carne dão 1,2 kg — arredondar em kg daria 1,1 e '
        'quebraria o R\$ 211', () {
      expect(kgPorCarne(gramasTotais: 1150, carnesSelecionadas: 1), 1.2);
    });

    test('2300 g numa carne só dão 2,3 kg', () {
      expect(kgPorCarne(gramasTotais: 2300, carnesSelecionadas: 1), 2.3);
    });

    test('2300 g entre três carnes dão 0,8 kg de cada', () {
      expect(kgPorCarne(gramasTotais: 2300, carnesSelecionadas: 3), 0.8);
    });

    test('menos de 500 g por carne travam no piso de 0,5 kg', () {
      expect(kgPorCarne(gramasTotais: 400, carnesSelecionadas: 1), 0.5);
    });

    test('nenhuma carne selecionada dá 0,0 kg, sem dividir por zero', () {
      expect(kgPorCarne(gramasTotais: 2300, carnesSelecionadas: 0), 0.0);
    });
  });
}
