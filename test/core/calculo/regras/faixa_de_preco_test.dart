import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/composicao_da_festa.dart';
import 'package:bora/core/calculo/dominio/contagem_de_pessoas.dart';
import 'package:bora/core/calculo/dominio/corredor.dart';
import 'package:bora/core/calculo/dominio/item_de_lista.dart';
import 'package:bora/core/calculo/dominio/preco_de_mercado.dart';
import 'package:bora/core/calculo/dominio/tabela_de_precos_de_mercado.dart';
import 'package:bora/core/calculo/formatacao/money_formatter.dart';
import 'package:bora/core/calculo/regras/calculadora_da_festa.dart';
import 'package:bora/core/calculo/regras/faixa_de_preco.dart';
import 'package:flutter_test/flutter_test.dart';

/// Uma linha qualquer da tabela, com a faixa que o teste precisa.
PrecoDeMercado _faixa({
  required double media,
  required double minimo,
  required double maximo,
}) =>
    PrecoDeMercado(
      nome: 'Item de teste',
      emoji: '🧪',
      corredor: Corredor.mercearia,
      rotuloDeQuantidade: '1 un',
      media: media,
      minimo: minimo,
      maximo: maximo,
      fontes: 2,
    );

PrecoDeMercado _linha(String nome) =>
    tabelaDePrecosDeMercado.firstWhere((preco) => preco.nome == nome);

/// Um item de lista com a chave e o valor pedidos.
ItemDeLista _item(ChaveItem chave, {double valor = 10, double? precoOverride}) =>
    ItemDeLista(
      chave: chave,
      nome: chave.name,
      emoji: '🧪',
      unidade: UnidadeDeItem.unidade,
      quantidadeAutomatica: 1,
      precoBase: valor,
      precoOverride: precoOverride,
    );

/// Os sete chips do estado padrão do arquivo 03 (RN-30).
const Set<ChaveItem> _chipsPadrao = {
  ChaveItem.bovina,
  ChaveItem.frango,
  ChaveItem.paoDeAlho,
  ChaveItem.refrigerante,
  ChaveItem.agua,
  ChaveItem.cerveja,
  ChaveItem.cachaca,
};

ResultadoDoCalculo _estadoPadrao({
  Map<ChaveItem, OverrideDeItem> overrides = const {},
}) =>
    CalculadoraDaFesta.calcular(
      ComposicaoDaFesta(
        contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
        duracaoHoras: 4,
        itensSelecionados: _chipsPadrao,
        overrides: overrides,
      ),
    );

void main() {
  group('CALC-25 — a posição do marcador (RN-11)', () {
    test('a picanha (65, 54, 83) fica em 11/29 ≈ 0,379', () {
      expect(posicaoDoMarcador(_linha('Picanha bovina')), closeTo(11 / 29, 1e-9));
      expect(posicaoDoMarcador(_linha('Picanha bovina')), closeTo(0.379, 0.001));
    });

    test('média igual ao mín põe o marcador na origem', () {
      expect(posicaoDoMarcador(_faixa(media: 54, minimo: 54, maximo: 83)), 0.0);
    });

    test('média igual ao máx põe o marcador no fim', () {
      expect(posicaoDoMarcador(_faixa(media: 83, minimo: 54, maximo: 83)), 1.0);
    });

    test('máx igual ao mín devolve 0.0 em vez de dividir por zero (A-15)', () {
      final posicao =
          posicaoDoMarcador(_faixa(media: 40, minimo: 40, maximo: 40));

      expect(posicao, 0.0);
      expect(posicao.isNaN, isFalse, reason: '0/0 daria NaN na barra');
      expect(posicao.isFinite, isTrue);
    });

    test('média acima do máx trava em 1.0', () {
      expect(posicaoDoMarcador(_faixa(media: 120, minimo: 54, maximo: 83)), 1.0);
    });

    test('média abaixo do mín trava em 0.0', () {
      expect(posicaoDoMarcador(_faixa(media: 10, minimo: 54, maximo: 83)), 0.0);
    });

    test('toda linha de RN-11 cai dentro de [0,1]', () {
      for (final preco in tabelaDePrecosDeMercado) {
        final posicao = posicaoDoMarcador(preco);

        expect(posicao, inInclusiveRange(0, 1), reason: preco.nome);
      }
    });
  });

  group('CALC-25 — o total e a faixa do rodapé (RN-11)', () {
    test('a tabela inteira soma média 286', () {
      expect(totalDeMercado(tabelaDePrecosDeMercado).media, closeTo(286, 1e-9));
    });

    test('a faixa real vai de 234 a 356', () {
      final total = totalDeMercado(tabelaDePrecosDeMercado);

      expect(total.minimo, closeTo(234, 1e-9));
      expect(total.maximo, closeTo(356, 1e-9));
    });

    test('cada total soma a própria coluna, sem trocar uma pela outra', () {
      final total = totalDeMercado([
        _faixa(media: 10, minimo: 6, maximo: 15),
        _faixa(media: 20, minimo: 12, maximo: 25),
      ]);

      expect(total.media, closeTo(30, 1e-9));
      expect(total.minimo, closeTo(18, 1e-9));
      expect(total.maximo, closeTo(40, 1e-9));
    });
  });

  group('LIST-09 — a faixa real sobre a lista da festa (RN-11 · A-03)', () {
    test('lista vazia devolve (0, 0)', () {
      final faixa = faixaRealDaLista(const [], tabelaDePrecosDeMercado);

      expect(faixa.minimo, 0);
      expect(faixa.maximo, 0);
    });

    test('item coberto por RN-11 contribui com o mín e o máx da tabela, não '
        'com o próprio valor', () {
      final faixa = faixaRealDaLista(
        [_item(ChaveItem.bovina, valor: 54)],
        tabelaDePrecosDeMercado,
      );

      expect(faixa.minimo, closeTo(_linha('Picanha bovina').minimo, 1e-9));
      expect(faixa.maximo, closeTo(_linha('Picanha bovina').maximo, 1e-9));
      expect(faixa.minimo, closeTo(54, 1e-9));
      expect(faixa.maximo, closeTo(83, 1e-9));
    });

    test('item que a tabela não cobre contribui com o próprio valor nas duas '
        'pontas — nenhuma faixa é fabricada', () {
      final faixa = faixaRealDaLista(
        [_item(ChaveItem.salGrosso, valor: 8)],
        tabelaDePrecosDeMercado,
      );

      expect(faixa.minimo, closeTo(8, 1e-9));
      expect(faixa.maximo, closeTo(8, 1e-9));
      expect(
        faixa.minimo,
        faixa.maximo,
        reason: 'sem linha em RN-11, as duas pontas são o mesmo número',
      );
    });

    test('coberto e não coberto somam juntos, cada um pela sua regra', () {
      final faixa = faixaRealDaLista(
        [
          _item(ChaveItem.bovina, valor: 54),
          _item(ChaveItem.salGrosso, valor: 8),
        ],
        tabelaDePrecosDeMercado,
      );

      expect(faixa.minimo, closeTo(54 + 8, 1e-9));
      expect(faixa.maximo, closeTo(83 + 8, 1e-9));
    });

    test('Copos & pratos fica fora das duas pontas (AD-010)', () {
      final semKit = faixaRealDaLista(
        [_item(ChaveItem.carvao, valor: 22)],
        tabelaDePrecosDeMercado,
      );
      final comKit = faixaRealDaLista(
        [
          _item(ChaveItem.carvao, valor: 22),
          _item(ChaveItem.coposEPratos, valor: 15),
        ],
        tabelaDePrecosDeMercado,
      );

      expect(comKit.minimo, closeTo(semKit.minimo, 1e-9));
      expect(comKit.maximo, closeTo(semKit.maximo, 1e-9));
      expect(comKit.minimo, closeTo(18, 1e-9));
      expect(comKit.maximo, closeTo(28, 1e-9));
    });

    test('com toda a lista coberta a função degenera em totalDeMercado — '
        'R\$ 234 a R\$ 356', () {
      // A 8ª linha de RN-11 é a 🌭 Linguiça toscana, que não tem `ChaveItem`
      // (R-6) e por isso não pode virar `ItemDeLista`. Dar a ela uma chave
      // livre deixa as **oito** linhas cobertas sem mover um só número da
      // tabela — as somas continuam sendo as de `tabelaDePrecosDeMercado`.
      final tabela = [
        for (final preco in tabelaDePrecosDeMercado)
          if (preco.chave != null)
            preco
          else
            PrecoDeMercado(
              nome: preco.nome,
              emoji: preco.emoji,
              corredor: preco.corredor,
              rotuloDeQuantidade: preco.rotuloDeQuantidade,
              media: preco.media,
              minimo: preco.minimo,
              maximo: preco.maximo,
              fontes: preco.fontes,
              chave: ChaveItem.suina,
            ),
      ];
      final itens = [
        for (final preco in tabela) _item(preco.chave!, valor: preco.media),
      ];

      final faixa = faixaRealDaLista(itens, tabela);
      final total = totalDeMercado(tabelaDePrecosDeMercado);

      expect(itens, hasLength(8));
      expect(faixa.minimo, closeTo(total.minimo, 1e-9));
      expect(faixa.maximo, closeTo(total.maximo, 1e-9));
      expect(MoneyFormatter.reais(faixa.minimo), 'R\$ 234');
      expect(MoneyFormatter.reais(faixa.maximo), 'R\$ 356');
    });

    test('no estado padrão de RN-30 devolve 244,60 e 342,60 — exibidos como '
        'R\$ 245 e R\$ 343', () {
      final faixa = faixaRealDaLista(
        _estadoPadrao().todosOsItens,
        tabelaDePrecosDeMercado,
      );

      expect(faixa.minimo, closeTo(244.6, 1e-9));
      expect(faixa.maximo, closeTo(342.6, 1e-9));
      expect(MoneyFormatter.reais(faixa.minimo), 'R\$ 245');
      expect(MoneyFormatter.reais(faixa.maximo), 'R\$ 343');
    });

    test('override de preço em item coberto não move a faixa (A-04)', () {
      final semOverride = faixaRealDaLista(
        _estadoPadrao().todosOsItens,
        tabelaDePrecosDeMercado,
      );
      final comOverride = faixaRealDaLista(
        _estadoPadrao(
          overrides: const {ChaveItem.bovina: OverrideDeItem(preco: 200)},
        ).todosOsItens,
        tabelaDePrecosDeMercado,
      );

      expect(comOverride.minimo, closeTo(semOverride.minimo, 1e-9));
      expect(comOverride.maximo, closeTo(semOverride.maximo, 1e-9));
      expect(
        comOverride.maximo,
        closeTo(342.6, 1e-9),
        reason: 'a faixa da tabela não persegue o override',
      );
    });

    test('item não coberto entra com o valor já ajustado — é o próprio valor '
        'dele que contribui', () {
      final faixa = faixaRealDaLista(
        [_item(ChaveItem.salGrosso, valor: 8, precoOverride: 20)],
        tabelaDePrecosDeMercado,
      );

      expect(faixa.minimo, closeTo(20, 1e-9));
      expect(faixa.maximo, closeTo(20, 1e-9));
    });
  });
}
