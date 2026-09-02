import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/composicao_da_festa.dart';
import 'package:bora/core/calculo/dominio/contagem_de_pessoas.dart';
import 'package:bora/core/calculo/dominio/item_de_lista.dart';
import 'package:bora/core/calculo/formatacao/money_formatter.dart';
import 'package:bora/core/calculo/regras/calculadora_da_festa.dart';
import 'package:bora/core/calculo/regras/total_do_pedido.dart';
import 'package:bora/core/calculo/regras/totais.dart';
import 'package:flutter_test/flutter_test.dart';

/// Um frango de 1,2 kg a R$ 18/kg: **21,60**, o valor fracionário que separa
/// "arredondar o total" de "somar arredondados".
ItemDeLista _frango() => const ItemDeLista(
      chave: ChaveItem.frango,
      nome: 'FRANGO',
      emoji: '🍗',
      unidade: UnidadeDeItem.kg,
      quantidadeAutomatica: 1.2,
      precoBase: 18,
    );

/// Um item qualquer com a chave pedida, valendo `valor` reais.
ItemDeLista _item(ChaveItem chave, {double valor = 10}) => ItemDeLista(
      chave: chave,
      nome: chave.name,
      emoji: '🧪',
      unidade: UnidadeDeItem.unidade,
      quantidadeAutomatica: 1,
      precoBase: valor,
    );

void main() {
  group('LIST-04 — itensCobraveis, o predicado da AD-010', () {
    test('remove exatamente os itens com entraNoTotal false', () {
      final itens = [
        _item(ChaveItem.carvao),
        _item(ChaveItem.coposEPratos),
        _item(ChaveItem.gelo),
      ];

      expect(
        itensCobraveis(itens).map((item) => item.chave),
        [ChaveItem.carvao, ChaveItem.gelo],
        reason: '🍽️ Copos & pratos aparece na lista e não soma (AD-010)',
      );
    });

    test('preserva a ordem dos itens que sobram', () {
      final itens = [
        _item(ChaveItem.gelo),
        _item(ChaveItem.coposEPratos),
        _item(ChaveItem.bovina),
        _item(ChaveItem.carvao),
      ];

      expect(
        itensCobraveis(itens).map((item) => item.chave).toList(),
        [ChaveItem.gelo, ChaveItem.bovina, ChaveItem.carvao],
      );
    });

    test('lista vazia devolve vazio', () {
      expect(itensCobraveis(const []), isEmpty);
    });

    test('lista sem nenhum item excluído devolve todos, na mesma ordem', () {
      final itens = [
        _item(ChaveItem.bovina),
        _item(ChaveItem.cerveja),
        _item(ChaveItem.salGrosso),
      ];

      expect(itensCobraveis(itens).toList(), itens);
    });

    test('Copos & pratos fica fora do total e do subtotal do pedido — as duas '
        'superfícies passam pelo mesmo predicado', () {
      final itens = [
        _item(ChaveItem.carvao, valor: 22),
        _item(ChaveItem.coposEPratos, valor: 15),
      ];
      final cobraveis = itensCobraveis(itens).toList();

      expect(totalExato(cobraveis), 22);
      expect(subtotalDeItens(cobraveis), 22);
      expect(
        totalExato(itens),
        37,
        reason: 'sem o predicado os 15 do kit entrariam nas duas superfícies',
      );
      expect(
        totalDoPedido(subtotal: subtotalDeItens(cobraveis), frete: 0).total,
        22,
      );
    });

    test('o total do estado padrão não se move ao passar pelo predicado — '
        'R\$ 271 de RN-10 (A-01/A-02)', () {
      final resultado = CalculadoraDaFesta.calcular(
        ComposicaoDaFesta(
          contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
          duracaoHoras: 4,
          itensSelecionados: const {
            ChaveItem.bovina,
            ChaveItem.frango,
            ChaveItem.paoDeAlho,
            ChaveItem.refrigerante,
            ChaveItem.agua,
            ChaveItem.cerveja,
            ChaveItem.cachaca,
          },
        ),
      );

      expect(
        totalExato(itensCobraveis(resultado.todosOsItens)),
        closeTo(resultado.totalComEssenciais, 1e-9),
      );
      expect(
        totalExato(itensCobraveis(resultado.todosOsItens)),
        closeTo(270.6, 0.001),
      );
      expect(
        MoneyFormatter.reais(totalExato(itensCobraveis(resultado.todosOsItens))),
        'R\$ 271',
      );
    });
  });

  group('CALC-16 — soma exata, sem arredondar parcela', () {
    test('lista vazia soma 0', () {
      expect(totalExato(const []), closeTo(0, 0.001));
    });

    test('a soma preserva os centavos das parcelas', () {
      expect(
        totalExato([_frango(), _frango()]),
        closeTo(43.2, 0.001),
        reason: '21,60 + 21,60 — nenhuma parcela vira 22 no caminho',
      );
    });

    test('o total é o arredondamento da soma exata, não a soma dos '
        'arredondados', () {
      final itens = [_frango(), _frango()];
      final somaDeArredondados = itens
          .map((item) => item.valor.round())
          .fold<int>(0, (soma, valor) => soma + valor);

      expect(
        MoneyFormatter.reais(totalExato(itens)),
        'R\$ 43',
        reason: '43,20 arredondado uma única vez, na exibição (RN-13)',
      );
      expect(
        somaDeArredondados,
        44,
        reason: 'somar 22 + 22 daria R\$ 44 — um real a mais, do nada',
      );
    });
  });

  group('CALC-16 — as duas estimativas de RN-14 (A-04)', () {
    test('o por cabeça divide o total dos itens pelas pessoas', () {
      expect(
        estimativaPorCabeca(totalDosItens: 210.6, pessoas: 7),
        closeTo(30.0857, 0.001),
      );
    });

    test('o por adulto divide o total com essenciais pelos adultos', () {
      expect(
        estimativaPorAdulto(totalComEssenciais: 270.6, adultos: 6),
        closeTo(45.1, 0.001),
      );
    });

    test('sem pessoas, o por cabeça é 0 — nunca NaN nem infinito', () {
      final estimativa = estimativaPorCabeca(totalDosItens: 210.6, pessoas: 0);

      expect(estimativa, 0);
      expect(estimativa.isFinite, isTrue);
    });

    test('sem adultos, o por adulto é 0 — nunca NaN nem infinito', () {
      final estimativa =
          estimativaPorAdulto(totalComEssenciais: 270.6, adultos: 0);

      expect(estimativa, 0);
      expect(estimativa.isFinite, isTrue);
    });
  });

  group('CALC-16 — festa sem ninguém zera todos os totais', () {
    test('0 pessoas devolve total, estimativas e essenciais em 0', () {
      final resultado = CalculadoraDaFesta.calcular(
        ComposicaoDaFesta(
          contagem: ContagemDePessoas(),
          duracaoHoras: 4,
          itensSelecionados: const {ChaveItem.bovina, ChaveItem.cerveja},
        ),
      );

      expect(resultado.totalDosItens, closeTo(0, 0.001));
      expect(
        resultado.totalDosEssenciais,
        closeTo(0, 0.001),
        reason: 'os 60 dos essenciais não entram numa festa sem plateia',
      );
      expect(resultado.totalComEssenciais, closeTo(0, 0.001));
      expect(resultado.porCabeca, 0);
      expect(resultado.porAdulto, 0);
      expect(MoneyFormatter.reais(resultado.totalComEssenciais), 'R\$ 0');
    });

    test('festa só de crianças zera o por adulto e mantém o por cabeça', () {
      final resultado = CalculadoraDaFesta.calcular(
        ComposicaoDaFesta(
          contagem: ContagemDePessoas(criancas: 2),
          duracaoHoras: 4,
          itensSelecionados: const {ChaveItem.agua},
        ),
      );

      expect(
        resultado.porAdulto,
        0,
        reason: 'nenhum adulto para dividir — RN-14 não divide por criança',
      );
      expect(
        resultado.porCabeca,
        closeTo(1.5, 0.001),
        reason: '1 garrafa de água a R\$ 3 ÷ 2 pessoas = 1,50 — a criança '
            'conta por cabeça, só não conta no racha',
      );
    });
  });
}
