import 'package:bora/core/calculo/dominio/catalogo_de_itens.dart';
import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/corredor.dart';
import 'package:bora/core/calculo/dominio/preco_de_mercado.dart';
import 'package:bora/core/calculo/dominio/tabela_de_precos_de_mercado.dart';
import 'package:flutter_test/flutter_test.dart';

PrecoDeMercado _linha(String nome) =>
    tabelaDePrecosDeMercado.firstWhere((preco) => preco.nome == nome);

void main() {
  group('CALC-24 — a tabela reproduz as oito linhas de RN-11', () {
    test('são oito itens, na ordem do arquivo 03, com emoji e nome literais',
        () {
      expect(
        tabelaDePrecosDeMercado
            .map((preco) => '${preco.emoji} ${preco.nome}')
            .toList(),
        [
          '🥩 Picanha bovina',
          '🌭 Linguiça toscana',
          '🥗 Legumes p/ grelha',
          '🧄 Pão de alho',
          '🍺 Cerveja',
          '🥤 Refrigerante',
          '🔥 Carvão 5 kg',
          '🧊 Gelo',
        ],
      );
    });

    test('média, mín, máx e fontes são os números literais de RN-11', () {
      expect(
        tabelaDePrecosDeMercado
            .map((preco) => [preco.media, preco.minimo, preco.maximo, preco.fontes])
            .toList(),
        [
          [65.0, 54.0, 83.0, 4],
          [23.0, 18.0, 29.0, 3],
          [28.0, 22.0, 35.0, 2],
          [24.0, 20.0, 30.0, 3],
          [76.0, 64.0, 92.0, 4],
          [18.0, 14.0, 23.0, 3],
          [22.0, 18.0, 28.0, 3],
          [30.0, 24.0, 36.0, 2],
        ],
      );
    });

    test('cada item está no corredor que RN-11 declara', () {
      expect(
        tabelaDePrecosDeMercado.map((preco) => preco.corredor).toList(),
        [
          Corredor.acougue,
          Corredor.acougue,
          Corredor.hortifruti,
          Corredor.padaria,
          Corredor.bebidas,
          Corredor.bebidas,
          Corredor.mercearia,
          Corredor.mercearia,
        ],
      );
    });

    test('o rótulo de quantidade é o texto literal de RN-11', () {
      expect(
        tabelaDePrecosDeMercado
            .map((preco) => preco.rotuloDeQuantidade)
            .toList(),
        [
          '1,2 kg',
          '1 kg',
          'kit veggie',
          '4 un',
          '18 latas',
          '2 gf 2 L',
          '1 saco',
          '3 sacos',
        ],
      );
    });
  });

  group('CALC-24 — as duas fontes de preço coexistem sem se unificar (A-03)',
      () {
    test('a linguiça toscana entra sem chave: não há chip para ela em T-03',
        () {
      expect(
        _linha('Linguiça toscana').chave,
        isNull,
        reason: 'RN-11 lista a linguiça, mas RN-03..RN-10 não dão preço-base a '
            'ela — inventar ChaveItem.linguica fabricaria um número (R-6)',
      );
      expect(
        ChaveItem.porChave('linguica'),
        isNull,
        reason: 'o catálogo da calculadora não conhece linguiça',
      );
    });

    test('as outras sete linhas apontam para o item do catálogo', () {
      expect(
        tabelaDePrecosDeMercado.map((preco) => preco.chave).toList(),
        [
          ChaveItem.bovina,
          null,
          ChaveItem.legumesParaGrelha,
          ChaveItem.paoDeAlho,
          ChaveItem.cerveja,
          ChaveItem.refrigerante,
          ChaveItem.carvao,
          ChaveItem.gelo,
        ],
      );
    });

    test('a picanha aponta para a bovina mas não herda o preço da calculadora',
        () {
      final picanha = _linha('Picanha bovina');
      final bovina = catalogoDeItens[ChaveItem.bovina]!;

      expect(picanha.chave, ChaveItem.bovina);
      expect(bovina.precoBase, 45);
      expect(
        picanha.media,
        isNot(bovina.precoBase),
        reason: 'a média real de mercados (65) e o preço-base da calculadora '
            '(45/kg) são fontes diferentes e nunca se unificam (A-03)',
      );
      expect(
        picanha.minimo,
        closeTo(bovina.precoBase * 1.2, 0.001),
        reason: 'o preço-base de 1,2 kg dá R\$ 54, que é o **mín** de RN-11, '
            'não a média — coincidência esperada, não bug',
      );
    });

    test('RN-11 não cobre tudo o que a calculadora cobre', () {
      final cobertas =
          tabelaDePrecosDeMercado.map((preco) => preco.chave).toSet();

      expect(
        cobertas,
        isNot(contains(ChaveItem.agua)),
        reason: 'água, suco, sal, copos e destilados não estão em RN-11 (A-03)',
      );
      expect(cobertas, isNot(contains(ChaveItem.suco)));
      expect(cobertas, isNot(contains(ChaveItem.salGrosso)));
      expect(cobertas, isNot(contains(ChaveItem.coposEPratos)));
      expect(cobertas, isNot(contains(ChaveItem.cachaca)));
    });
  });
}
