import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/despesa.dart';
import 'package:bora/core/calculo/dominio/item_de_lista.dart';
import 'package:bora/core/calculo/regras/contribuicoes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Um item já calculado, com dono opcional.
ItemDeLista _item({
  required ChaveItem chave,
  required double quantidade,
  required double preco,
  String? quemLeva,
}) =>
    ItemDeLista(
      chave: chave,
      nome: chave.chave,
      emoji: '🍖',
      unidade: UnidadeDeItem.unidade,
      quantidadeAutomatica: quantidade,
      precoBase: preco,
      quemLeva: quemLeva,
    );

void main() {
  group('CALC-18 — o que a pessoa levou entra como contribuição (RN-20)', () {
    test('só itens: o valor dos itens assumidos vai para quem os leva', () {
      final contribuicoes = contribuicoesPorPessoa(
        participantes: const ['VOCÊ', 'ANA'],
        itens: [
          _item(
            chave: ChaveItem.bovina,
            quantidade: 4,
            preco: 45,
            quemLeva: 'VOCÊ',
          ),
          _item(
            chave: ChaveItem.carvao,
            quantidade: 1,
            preco: 20,
            quemLeva: 'VOCÊ',
          ),
        ],
      );

      expect(contribuicoes['VOCÊ'], closeTo(200, 0.001));
      expect(contribuicoes['ANA'], closeTo(0, 0.001));
    });

    test('só despesas: o valor adiantado vai para quem pagou', () {
      final contribuicoes = contribuicoesPorPessoa(
        participantes: const ['VOCÊ', 'ANA'],
        despesas: const [
          Despesa(quemPagou: 'ANA', descricao: 'Cerveja', valor: 90),
          Despesa(quemPagou: 'ANA', descricao: 'Gelo', valor: 30),
        ],
      );

      expect(contribuicoes['ANA'], closeTo(120, 0.001));
      expect(contribuicoes['VOCÊ'], closeTo(0, 0.001));
    });

    test('itens e despesas da mesma pessoa somam na mesma contribuição', () {
      final contribuicoes = contribuicoesPorPessoa(
        participantes: const ['LÉO'],
        itens: [
          _item(
            chave: ChaveItem.paoDeAlho,
            quantidade: 4,
            preco: 6,
            quemLeva: 'LÉO',
          ),
        ],
        despesas: const [
          Despesa(quemPagou: 'LÉO', descricao: 'Descartáveis', valor: 36),
        ],
      );

      expect(
        contribuicoes['LÉO'],
        closeTo(60, 0.001),
        reason: '24 de pão de alho + 36 de descartáveis',
      );
    });

    test('participante que não levou nada fica no mapa com 0,0', () {
      final contribuicoes = contribuicoesPorPessoa(
        participantes: const ['VOCÊ', 'ANA', 'LÉO', 'BIA'],
        despesas: const [
          Despesa(quemPagou: 'VOCÊ', descricao: 'Carnes', valor: 200),
        ],
      );

      expect(contribuicoes.containsKey('BIA'), isTrue);
      expect(contribuicoes['BIA'], 0.0);
      expect(contribuicoes['LÉO'], 0.0);
    });

    test('item sem dono não entra na contribuição de ninguém', () {
      final contribuicoes = contribuicoesPorPessoa(
        participantes: const ['VOCÊ', 'ANA'],
        itens: [
          _item(chave: ChaveItem.cerveja, quantidade: 18, preco: 4),
        ],
      );

      expect(contribuicoes['VOCÊ'], closeTo(0, 0.001));
      expect(contribuicoes['ANA'], closeTo(0, 0.001));
      expect(totalDasContribuicoes(contribuicoes), closeTo(0, 0.001));
    });

    test('nome que não está entre os participantes é ignorado', () {
      final contribuicoes = contribuicoesPorPessoa(
        participantes: const ['VOCÊ', 'ANA'],
        itens: [
          _item(
            chave: ChaveItem.gelo,
            quantidade: 3,
            preco: 10,
            quemLeva: 'DUDA',
          ),
        ],
        despesas: const [
          Despesa(quemPagou: 'DUDA', descricao: 'Sal grosso', valor: 8),
        ],
      );

      expect(contribuicoes.containsKey('DUDA'), isFalse);
      expect(contribuicoes.keys, ['VOCÊ', 'ANA']);
      expect(totalDasContribuicoes(contribuicoes), closeTo(0, 0.001));
    });

    test('a ordem do mapa é a ordem dos participantes — é a ordem que RN-16 '
        'percorre (A-14)', () {
      final contribuicoes = contribuicoesPorPessoa(
        participantes: const ['RAFA', 'ANA', 'LÉO', 'BIA'],
        despesas: const [
          Despesa(quemPagou: 'BIA', descricao: 'Nada', valor: 0),
          Despesa(quemPagou: 'LÉO', descricao: 'Pão', valor: 60),
          Despesa(quemPagou: 'RAFA', descricao: 'Carnes', valor: 200),
        ],
      );

      expect(
        contribuicoes.keys.toList(),
        ['RAFA', 'ANA', 'LÉO', 'BIA'],
        reason: 'a ordem de chegada das despesas não pode reordenar o mapa',
      );
    });
  });

  group('CALC-18 — o total das contribuições (RN-20)', () {
    test('soma tudo que a galera colocou: o Teste A dá 320', () {
      final contribuicoes = contribuicoesPorPessoa(
        participantes: const ['VOCÊ', 'ANA', 'LÉO', 'BIA'],
        despesas: const [
          Despesa(quemPagou: 'VOCÊ', descricao: 'Carnes + carvão', valor: 200),
          Despesa(quemPagou: 'ANA', descricao: 'Cerveja + gelo', valor: 120),
        ],
      );

      expect(totalDasContribuicoes(contribuicoes), closeTo(320, 0.001));
    });

    test('mapa vazio soma 0, sem lançar', () {
      expect(totalDasContribuicoes(const {}), closeTo(0, 0.001));
    });
  });
}
