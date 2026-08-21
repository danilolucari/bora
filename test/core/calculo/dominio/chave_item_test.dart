import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/rn30_estado_inicial.dart';

void main() {
  group('CALC-05 — as 16 chaves de item', () {
    test('o enum tem exatamente os 16 itens da calculadora', () {
      expect(ChaveItem.values.length, 16);
    });

    test('cada item tem a chave snake_case da spec', () {
      expect(
        ChaveItem.values.map((item) => item.chave).toList(),
        [
          'bovina',
          'suina',
          'frango',
          'pao_de_alho',
          'refrigerante',
          'suco',
          'agua',
          'cerveja',
          'vodka',
          'cachaca',
          'whisky',
          'legumes_para_grelha',
          'carvao',
          'gelo',
          'sal_grosso',
          'copos_e_pratos',
        ],
      );
    });

    test('nenhuma chave se repete', () {
      expect(ChaveItem.values.map((item) => item.chave).toSet().length, 16);
    });
  });

  group('CALC-05 — porChave', () {
    test('toda chave volta a ser o próprio item', () {
      for (final item in ChaveItem.values) {
        expect(ChaveItem.porChave(item.chave), item);
      }
    });

    test('chave desconhecida devolve null, sem inventar default', () {
      expect(ChaveItem.porChave('picanha'), isNull);
      expect(ChaveItem.porChave(''), isNull);
      expect(ChaveItem.porChave('paoDeAlho'), isNull);
    });
  });

  group('CALC-05 — as chaves do dado bruto de RN-30 resolvem', () {
    test('os sete itens padrão de RN-30 viram ChaveItem', () {
      expect(
        itensPadraoRn30.map(ChaveItem.porChave).toList(),
        [
          ChaveItem.bovina,
          ChaveItem.frango,
          ChaveItem.paoDeAlho,
          ChaveItem.refrigerante,
          ChaveItem.agua,
          ChaveItem.cerveja,
          ChaveItem.cachaca,
        ],
        reason: 'o vocabulário do catálogo é o mesmo do dado bruto de RN-30 — '
            'se divergir, a fixture não tipa',
      );
    });
  });

  group('CALC-05 — as unidades de RN-03..RN-10', () {
    test('o enum tem as sete unidades em que os itens são comprados', () {
      expect(
        UnidadeDeItem.values,
        [
          UnidadeDeItem.kg,
          UnidadeDeItem.unidade,
          UnidadeDeItem.garrafa,
          UnidadeDeItem.lata,
          UnidadeDeItem.litro,
          UnidadeDeItem.saco,
          UnidadeDeItem.kit,
        ],
      );
    });
  });
}
