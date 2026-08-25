import 'package:bora/core/calculo/dominio/catalogo_de_itens.dart';
import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:flutter_test/flutter_test.dart';

DefinicaoDeItem _def(ChaveItem chave) => catalogoDeItens[chave]!;

void main() {
  group('CALC-07..CALC-14 — o catálogo cobre os 16 itens', () {
    test('todo item do enum tem definição no catálogo', () {
      expect(catalogoDeItens.keys.toSet(), ChaveItem.values.toSet());
    });

    test('cada definição declara a própria chave', () {
      for (final entrada in catalogoDeItens.entries) {
        expect(entrada.value.chave, entrada.key);
      }
    });
  });

  group('CALC-07..CALC-14 — preços-base literais do arquivo 03', () {
    test('as três carnes de RN-03: 45, 28 e 18 por kg', () {
      expect(_def(ChaveItem.bovina).precoBase, 45);
      expect(_def(ChaveItem.suina).precoBase, 28);
      expect(_def(ChaveItem.frango).precoBase, 18);
    });

    test('os consumíveis de RN-04..RN-08: pão 6, refri 9, suco 8, água 3, '
        'cerveja 4', () {
      expect(_def(ChaveItem.paoDeAlho).precoBase, 6);
      expect(_def(ChaveItem.refrigerante).precoBase, 9);
      expect(_def(ChaveItem.suco).precoBase, 8);
      expect(_def(ChaveItem.agua).precoBase, 3);
      expect(_def(ChaveItem.cerveja).precoBase, 4);
    });

    test('os destilados de RN-09: vodka 40, cachaça 15, whisky 90', () {
      expect(_def(ChaveItem.vodka).precoBase, 40);
      expect(_def(ChaveItem.cachaca).precoBase, 15);
      expect(_def(ChaveItem.whisky).precoBase, 90);
    });

    test('o kit veggie de RN-21 custa 28 — o único número que a spec dá', () {
      expect(
        _def(ChaveItem.legumesParaGrelha).precoBase,
        28,
        reason: 'RN-03..RN-09 não dão preço ao kit; 28 vem da tabela de RN-11 '
            '(A-10)',
      );
    });

    test('os essenciais de RN-10: carvão 22, gelo 10/saco, sal 8, copos 15',
        () {
      expect(_def(ChaveItem.carvao).precoBase, 22);
      expect(_def(ChaveItem.gelo).precoBase, 10);
      expect(_def(ChaveItem.salGrosso).precoBase, 8);
      expect(_def(ChaveItem.coposEPratos).precoBase, 15);
    });
  });

  group('CALC-07..CALC-14 — unidade de cada item', () {
    test('carne e sal em kg, pão em unidade, suco em litro', () {
      expect(_def(ChaveItem.bovina).unidade, UnidadeDeItem.kg);
      expect(_def(ChaveItem.suina).unidade, UnidadeDeItem.kg);
      expect(_def(ChaveItem.frango).unidade, UnidadeDeItem.kg);
      expect(_def(ChaveItem.salGrosso).unidade, UnidadeDeItem.kg);
      expect(_def(ChaveItem.paoDeAlho).unidade, UnidadeDeItem.unidade);
      expect(_def(ChaveItem.suco).unidade, UnidadeDeItem.litro);
    });

    test('refri, água e destilados em garrafa; cerveja em lata', () {
      expect(_def(ChaveItem.refrigerante).unidade, UnidadeDeItem.garrafa);
      expect(_def(ChaveItem.agua).unidade, UnidadeDeItem.garrafa);
      expect(_def(ChaveItem.vodka).unidade, UnidadeDeItem.garrafa);
      expect(_def(ChaveItem.cachaca).unidade, UnidadeDeItem.garrafa);
      expect(_def(ChaveItem.whisky).unidade, UnidadeDeItem.garrafa);
      expect(_def(ChaveItem.cerveja).unidade, UnidadeDeItem.lata);
    });

    test('carvão e gelo em saco; legumes e copos em kit', () {
      expect(_def(ChaveItem.carvao).unidade, UnidadeDeItem.saco);
      expect(_def(ChaveItem.gelo).unidade, UnidadeDeItem.saco);
      expect(_def(ChaveItem.legumesParaGrelha).unidade, UnidadeDeItem.kit);
      expect(_def(ChaveItem.coposEPratos).unidade, UnidadeDeItem.kit);
    });
  });

  group('CALC-17 — passos de quantidade de RN-12', () {
    test('as três carnes andam de 0,5 kg', () {
      expect(_def(ChaveItem.bovina).passoDeQuantidade, 0.5);
      expect(_def(ChaveItem.suina).passoDeQuantidade, 0.5);
      expect(_def(ChaveItem.frango).passoDeQuantidade, 0.5);
    });

    test('a cerveja anda de 2 latas', () {
      expect(_def(ChaveItem.cerveja).passoDeQuantidade, 2);
    });

    test('todos os demais andam de 1', () {
      final passoDiferenteDeUm = catalogoDeItens.values
          .where((item) => item.passoDeQuantidade != 1)
          .map((item) => item.chave)
          .toSet();

      expect(
        passoDiferenteDeUm,
        {
          ChaveItem.bovina,
          ChaveItem.suina,
          ChaveItem.frango,
          ChaveItem.cerveja,
        },
      );
    });
  });

  group('CALC-14 — os quatro essenciais de RN-10', () {
    test('só carvão, gelo, sal grosso e copos & pratos são essenciais', () {
      final essenciais = catalogoDeItens.values
          .where((item) => item.essencial)
          .map((item) => item.chave)
          .toSet();

      expect(
        essenciais,
        {
          ChaveItem.carvao,
          ChaveItem.gelo,
          ChaveItem.salGrosso,
          ChaveItem.coposEPratos,
        },
      );
    });

    test('cada essencial traz a quantidade default de RN-10', () {
      expect(_def(ChaveItem.carvao).quantidadeDefault, 1);
      expect(_def(ChaveItem.gelo).quantidadeDefault, 3);
      expect(_def(ChaveItem.salGrosso).quantidadeDefault, 1);
      expect(_def(ChaveItem.coposEPratos).quantidadeDefault, 1);
    });

    test('cada essencial declara a fonte da proporção do badge de RN-10', () {
      expect(_def(ChaveItem.carvao).fonteDaProporcao, 'kg de carne');
      expect(
        _def(ChaveItem.gelo).fonteDaProporcao,
        'volume de bebida gelada',
      );
      expect(_def(ChaveItem.salGrosso).fonteDaProporcao, 'kg de carne');
      expect(_def(ChaveItem.coposEPratos).fonteDaProporcao, 'nº de pessoas');
    });

    test('item que não é essencial não tem fonte de proporção', () {
      expect(_def(ChaveItem.bovina).fonteDaProporcao, isNull);
      expect(_def(ChaveItem.cerveja).fonteDaProporcao, isNull);
    });
  });

  group('CALC-14 — aparecer na lista não é somar no total (A-01/A-02)', () {
    test('copos & pratos é o único item fora do total', () {
      final foraDoTotal = catalogoDeItens.values
          .where((item) => !item.entraNoTotal)
          .map((item) => item.chave)
          .toSet();

      expect(
        foraDoTotal,
        {ChaveItem.coposEPratos},
        reason: 'leitura (a) de RN-10, decidida pelo usuário em 2026-08-20: '
            'carvão 22 + gelo 30 + sal 8 = 60, e 210,60 + 60 fecha em R\$ 271 '
            'com ≈R\$ 45/adulto',
      );
    });
  });

  group('CALC-15 — a ordem canônica da lista', () {
    test('cobre o catálogo inteiro, sem repetir nenhum item', () {
      expect(ordemCanonicaDaLista.length, 16);
      expect(ordemCanonicaDaLista.toSet(), catalogoDeItens.keys.toSet());
    });

    test('os quatro essenciais fecham a ordem — é o bloco final de RN-10', () {
      expect(
        ordemCanonicaDaLista.sublist(12),
        [
          ChaveItem.carvao,
          ChaveItem.gelo,
          ChaveItem.salGrosso,
          ChaveItem.coposEPratos,
        ],
      );
    });
  });

  group('CALC-07..CALC-14 — nome e emoji literais da fonte', () {
    test('os chips de T-03 vêm em caixa alta', () {
      expect(_def(ChaveItem.bovina).nome, 'BOVINA');
      expect(_def(ChaveItem.bovina).emoji, '🥩');
      expect(_def(ChaveItem.paoDeAlho).nome, 'PÃO DE ALHO');
      expect(_def(ChaveItem.paoDeAlho).emoji, '🧄');
      expect(_def(ChaveItem.cerveja).nome, 'CERVEJA');
      expect(_def(ChaveItem.cerveja).emoji, '🍺');
    });

    test('os itens de RN-10 e RN-21 vêm em sentence case', () {
      expect(_def(ChaveItem.carvao).nome, 'Carvão');
      expect(_def(ChaveItem.carvao).emoji, '🔥');
      expect(_def(ChaveItem.coposEPratos).nome, 'Copos & pratos');
      expect(
        _def(ChaveItem.legumesParaGrelha).nome,
        'Legumes p/ grelha (kit veggie)',
      );
    });
  });
}
