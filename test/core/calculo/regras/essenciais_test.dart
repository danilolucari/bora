import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/item_de_lista.dart';
import 'package:bora/core/calculo/regras/essenciais.dart';
import 'package:flutter_test/flutter_test.dart';

ItemDeLista _essencial(ChaveItem chave) =>
    essenciaisAutomaticos().firstWhere((item) => item.chave == chave);

void main() {
  group('CALC-14 — os quatro essenciais de RN-10 entram sozinhos', () {
    test('são quatro, na ordem do bloco "ESSENCIAIS · ENTRAM SOZINHOS"', () {
      expect(
        essenciaisAutomaticos().map((item) => item.chave).toList(),
        [
          ChaveItem.carvao,
          ChaveItem.gelo,
          ChaveItem.salGrosso,
          ChaveItem.coposEPratos,
        ],
      );
    });

    test('as quantidades são os defaults de RN-10: 1 saco, 3 sacos, 1 kg, '
        '1 kit', () {
      expect(_essencial(ChaveItem.carvao).quantidade, 1);
      expect(
        _essencial(ChaveItem.gelo).quantidade,
        3,
        reason: 'RN-10 default: 3 sacos de gelo — fixo, sem fórmula (A-09)',
      );
      expect(_essencial(ChaveItem.salGrosso).quantidade, 1);
      expect(_essencial(ChaveItem.coposEPratos).quantidade, 1);
    });

    test('os valores são 22 · 30 · 8 · 15', () {
      expect(_essencial(ChaveItem.carvao).valor, closeTo(22, 0.001));
      expect(
        _essencial(ChaveItem.gelo).valor,
        closeTo(30, 0.001),
        reason: '3 sacos × R\$ 10/saco',
      );
      expect(_essencial(ChaveItem.salGrosso).valor, closeTo(8, 0.001));
      expect(_essencial(ChaveItem.coposEPratos).valor, closeTo(15, 0.001));
    });

    test('todos se declaram essenciais', () {
      for (final item in essenciaisAutomaticos()) {
        expect(item.essencial, isTrue, reason: '${item.nome} é de RN-10');
      }
    });

    test('cada um carrega a fonte da proporção literal de RN-10', () {
      expect(_essencial(ChaveItem.carvao).fonteDaProporcao, 'kg de carne');
      expect(
        _essencial(ChaveItem.gelo).fonteDaProporcao,
        'volume de bebida gelada',
      );
      expect(_essencial(ChaveItem.salGrosso).fonteDaProporcao, 'kg de carne');
      expect(
        _essencial(ChaveItem.coposEPratos).fonteDaProporcao,
        'nº de pessoas',
      );
    });
  });

  group('CALC-14 — total dos essenciais: 60, não 75 (A-01/A-02)', () {
    test('soma Carvão + Gelo + Sal e dá exatamente 60', () {
      expect(
        totalDosEssenciais(essenciaisAutomaticos()),
        closeTo(60, 0.001),
        reason: 'leitura (a) de RN-10: 210,60 + 60 = 270,60 → R\$ 271',
      );
    });

    test('Copos & pratos está na lista e fica fora do total', () {
      final essenciais = essenciaisAutomaticos();
      final soma = essenciais.fold<double>(0, (a, item) => a + item.valor);

      expect(
        essenciais.map((item) => item.chave),
        contains(ChaveItem.coposEPratos),
        reason: 'RN-10 manda os quatro aparecerem na lista',
      );
      expect(
        soma,
        closeTo(75, 0.001),
        reason: 'os quatro valem 75 juntos',
      );
      expect(
        totalDosEssenciais(essenciais),
        closeTo(soma - 15, 0.001),
        reason: 'o total é 15 menor que a lista — os copos não somam',
      );
    });

    test('sozinho, Copos & pratos não soma nada', () {
      expect(
        totalDosEssenciais([_essencial(ChaveItem.coposEPratos)]),
        closeTo(0, 0.001),
      );
    });
  });
}
