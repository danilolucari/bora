import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/montar/domain/rascunho_inicial.dart';
import 'package:bora/features/montar/domain/secao_da_montagem.dart';
import 'package:bora/features/montar/presentation/widgets/lista_viva.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';
import '../../../../support/cifrao_na_fonte.dart';

/// O rail de W-03 tem 370px; a lista viva vive nessa largura.
const double _larguraDoRail = 370;

/// O estado padrão de RN-30, o do aceite de UC-03.
ComposicaoDaFesta get _composicaoRn30 => ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: duracaoDefaultDoRole,
      itensSelecionados: itensPadraoDoRole,
    );

ResultadoDoCalculo get _resultadoRn30 =>
    CalculadoraDaFesta.calcular(_composicaoRn30);

/// Chave de teste do marcador que fica **fora** da lista viva — é por ela que
/// se prova que rolar a lista não rolou a página.
const Key _marcadorDaPagina = Key('marcador-da-pagina');

Future<void> _montar(
  WidgetTester tester,
  ResultadoDoCalculo resultado,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: SingleChildScrollView(
          child: SizedBox(
            width: _larguraDoRail,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  key: _marcadorDaPagina,
                  height: 20,
                  width: _larguraDoRail,
                ),
                ListaViva(resultado: resultado),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Os textos renderizados, na ordem em que aparecem na árvore.
List<String> _textosNaOrdem(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((t) => t.data ?? '')
    .toList();

double _topoDe(WidgetTester tester, Finder alvo) => tester.getTopLeft(alvo).dy;

void main() {
  setUpAll(carregarFontesArchivo);

  group('MONT-11 — agrupa nas três categorias, na ordem do formulário (A-07)',
      () {
    testWidgets('NA GRELHA vem antes de NA GELADEIRA, que vem antes de '
        'PROS FORTES', (tester) async {
      await _montar(tester, _resultadoRn30);

      final ordem = [
        _topoDe(tester, find.text('NA GRELHA')),
        _topoDe(tester, find.text('NA GELADEIRA')),
        _topoDe(tester, find.text('PROS FORTES')),
      ];

      expect(ordem, orderedEquals(List<double>.from(ordem)..sort()));
    });

    testWidgets('dentro da categoria, a ordem é a de ordemCanonicaDaLista',
        (tester) async {
      final resultado = _resultadoRn30;
      await _montar(tester, resultado);

      final naGeladeira = [
        for (final chave in ordemCanonicaDaLista)
          if (secaoDe(chave) == SecaoDaMontagem.naGeladeira &&
              resultado.itens.any((item) => item.chave == chave))
            catalogoDeItens[chave]!.nome,
      ];

      // PÃO DE ALHO → REFRIGERANTE → ÁGUA → CERVEJA, com o estado de RN-30.
      expect(naGeladeira, ['PÃO DE ALHO', 'REFRIGERANTE', 'ÁGUA', 'CERVEJA']);
      expect(
        naGeladeira.map((nome) => _topoDe(tester, find.text(nome))).toList(),
        orderedEquals(
          naGeladeira.map((nome) => _topoDe(tester, find.text(nome))).toList()
            ..sort(),
        ),
      );
    });

    testWidgets('a linha do item traz emoji, nome, quantidade e valor',
        (tester) async {
      final resultado = _resultadoRn30;
      await _montar(tester, resultado);

      final frango = resultado.itens
          .firstWhere((item) => item.chave == ChaveItem.frango);
      final linha = tester.widgetList<BoraListCard>(find.byType(BoraListCard))
          .expand((card) => card.linhas)
          .firstWhere((linha) => linha.titulo == 'FRANGO');

      expect(linha.emoji, '🍗');
      expect(linha.sublinha,
          rotuloDeQuantidade(frango.quantidade, frango.unidade));
      expect(linha.valor, MoneyFormatter.reais(frango.valor));
    });
  });

  group('MONT-11 — o subtotal por categoria vem de totalExato', () {
    testWidgets('cada categoria fecha com uma linha SUBTOTAL', (tester) async {
      await _montar(tester, _resultadoRn30);

      expect(find.text('SUBTOTAL'), findsNWidgets(3));
    });

    testWidgets('o subtotal de cada categoria é totalExato dos itens dela',
        (tester) async {
      final resultado = _resultadoRn30;
      await _montar(tester, resultado);

      for (final secao in SecaoDaMontagem.values) {
        final itens = resultado.itens
            .where((item) => secaoDe(item.chave) == secao)
            .toList();
        final card = tester
            .widgetList<BoraListCard>(find.byType(BoraListCard))
            .firstWhere(
              (card) => card.linhas.any(
                (linha) => linha.titulo == catalogoDeItens[itens.first.chave]!.nome,
              ),
            );

        expect(
          card.linhas.last.valor,
          MoneyFormatter.reais(totalExato(itens)),
          reason: 'o SUBTOTAL de $secao tem de ser totalExato, não uma soma '
              'escrita no widget',
        );
      }
    });

    testWidgets('o subtotal arredonda a soma exata, não a soma dos '
        'arredondados (AD-009)', (tester) async {
      // Dois itens de 10,40: somados dá 20,80 → R$ 21. Um widget que somasse
      // os valores já arredondados (10 + 10) mostraria R$ 20 e morre aqui.
      const um = ItemDeLista(
        chave: ChaveItem.bovina,
        nome: 'BOVINA',
        emoji: '🥩',
        unidade: UnidadeDeItem.kg,
        quantidadeAutomatica: 1,
        precoBase: 10.4,
      );
      const outro = ItemDeLista(
        chave: ChaveItem.frango,
        nome: 'FRANGO',
        emoji: '🍗',
        unidade: UnidadeDeItem.kg,
        quantidadeAutomatica: 1,
        precoBase: 10.4,
      );
      final resultado = ResultadoDoCalculo(
        itens: const [um, outro],
        essenciais: const [],
        contagem: ContagemDePessoas(homens: 1),
        fator: 1,
        totalDosItens: 20.8,
        totalDosEssenciais: 0,
        porCabeca: 20.8,
        porAdulto: 20.8,
      );

      await _montar(tester, resultado);

      final card = tester.widget<BoraListCard>(find.byType(BoraListCard));

      expect(card.linhas.last.titulo, 'SUBTOTAL');
      expect(card.linhas.last.valor, MoneyFormatter.reais(20.8));
      expect(MoneyFormatter.reais(20.8), isNot(MoneyFormatter.reais(20)));
    });

    testWidgets('a soma dos subtotais fecha com o total do card-herói',
        (tester) async {
      final resultado = _resultadoRn30;
      await _montar(tester, resultado);

      final subtotais = <double>[
        for (final secao in SecaoDaMontagem.values)
          totalExato(
            resultado.itens.where((item) => secaoDe(item.chave) == secao),
          ),
      ];

      expect(
        MoneyFormatter.reais(subtotais.reduce((a, b) => a + b)),
        MoneyFormatter.reais(resultado.totalDosItens),
      );
      expect(MoneyFormatter.reais(resultado.totalDosItens), r'R$ 211');
    });
  });

  group('MONT-11 — o que a lista viva NÃO mostra (A-02, A-06, AD-018)', () {
    testWidgets('sem botão QUEM LEVA? e sem a dica 💡', (tester) async {
      await _montar(tester, _resultadoRn30);

      expect(find.textContaining('QUEM LEVA'), findsNothing);
      expect(find.textContaining('💡'), findsNothing);
      expect(find.byType(BoraDashedNote), findsNothing);
    });

    testWidgets('os quatro essenciais de RN-10 não aparecem', (tester) async {
      final resultado = _resultadoRn30;
      await _montar(tester, resultado);

      expect(resultado.essenciais, isNotEmpty);
      for (final chave in [
        ChaveItem.carvao,
        ChaveItem.gelo,
        ChaveItem.salGrosso,
        ChaveItem.coposEPratos,
      ]) {
        expect(
          find.text(catalogoDeItens[chave]!.nome),
          findsNothing,
          reason: '${catalogoDeItens[chave]!.nome} é essencial (RN-10) e é da '
              'tela Lista — aqui ele faria a soma divergir do card-herói',
        );
      }
    });

    testWidgets('categoria sem item selecionado não renderiza seção vazia',
        (tester) async {
      final resultado = CalculadoraDaFesta.calcular(
        ComposicaoDaFesta(
          contagem: ContagemDePessoas(homens: 2),
          duracaoHoras: duracaoDefaultDoRole,
          itensSelecionados: const {ChaveItem.bovina},
        ),
      );

      await _montar(tester, resultado);

      expect(find.text('NA GRELHA'), findsOneWidget);
      expect(find.text('NA GELADEIRA'), findsNothing);
      expect(find.text('PROS FORTES'), findsNothing);
      expect(find.text('SUBTOTAL'), findsOneWidget);
    });

    testWidgets('festa sem ninguém não renderiza card nenhum e não quebra',
        (tester) async {
      final resultado = CalculadoraDaFesta.calcular(
        ComposicaoDaFesta(
          contagem: ContagemDePessoas(),
          duracaoHoras: duracaoDefaultDoRole,
          itensSelecionados: itensPadraoDoRole,
        ),
      );

      await _montar(tester, resultado);

      expect(find.byType(BoraListCard), findsNothing);
      expect(find.text('SUBTOTAL'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('MONT-24 — o kit veggie de RN-21 entra em NA GRELHA sem ter chip',
      () {
    testWidgets('Legumes p/ grelha aparece na primeira categoria',
        (tester) async {
      final resultado = CalculadoraDaFesta.calcular(
        ComposicaoDaFesta(
          contagem: ContagemDePessoas(homens: 2, mulheres: 1),
          duracaoHoras: duracaoDefaultDoRole,
          pessoas: const [
            Pessoa(
              nome: 'ANA',
              papel: PapelNaFesta.convidado,
              status: StatusDePresenca.confirmado,
              dieta: Dieta.veggie,
            ),
          ],
          itensSelecionados: const {ChaveItem.bovina},
        ),
      );

      await _montar(tester, resultado);

      final legumes = catalogoDeItens[ChaveItem.legumesParaGrelha]!.nome;

      expect(find.text(legumes), findsOneWidget);
      expect(
        chipsPorSecao[SecaoDaMontagem.naGrelha],
        isNot(contains(ChaveItem.legumesParaGrelha)),
        reason: 'o kit entra sozinho por RN-21 — dar-lhe chip seria criar '
            'controle que a spec não desenha (A-08)',
      );
      expect(
        _topoDe(tester, find.text(legumes)),
        greaterThan(_topoDe(tester, find.text('NA GRELHA'))),
      );
      expect(find.text('NA GELADEIRA'), findsNothing);
    });
  });

  group('MONT-13 — a lista rola dentro do próprio contêiner (W-03, W-R4)', () {
    testWidgets('excedendo 330px, a altura para em 330', (tester) async {
      await _montar(tester, _resultadoRn30);

      expect(
        tester.getSize(find.byType(ListaViva)).height,
        ListaViva.alturaMaxima,
      );
    });

    testWidgets('rolar a lista move as linhas e não move a página',
        (tester) async {
      await _montar(tester, _resultadoRn30);

      final marcadorAntes = _topoDe(tester, find.byKey(_marcadorDaPagina));
      final grelhaAntes = _topoDe(tester, find.text('NA GRELHA'));

      await tester.drag(find.text('NA GRELHA'), const Offset(0, -120));
      await tester.pumpAndSettle();

      expect(_topoDe(tester, find.text('NA GRELHA')), lessThan(grelhaAntes));
      expect(_topoDe(tester, find.byKey(_marcadorDaPagina)), marcadorAntes);
    });

    testWidgets('a lista curta não estica até 330px', (tester) async {
      final resultado = CalculadoraDaFesta.calcular(
        ComposicaoDaFesta(
          contagem: ContagemDePessoas(homens: 2),
          duracaoHoras: duracaoDefaultDoRole,
          itensSelecionados: const {ChaveItem.bovina},
        ),
      );

      await _montar(tester, resultado);

      expect(
        tester.getSize(find.byType(ListaViva)).height,
        lessThan(ListaViva.alturaMaxima),
      );
    });
  });

  group('MONT-08 — a lista viva não formata dinheiro nem soma', () {
    test('o arquivo não escreve R\$, .fold(, .reduce( nem .sum', () {
      final fonte = File(
        'lib/features/montar/presentation/widgets/lista_viva.dart',
      ).readAsStringSync();

      expect(cifraoEm(fonte), isEmpty);
      expect(fonte, isNot(contains('.fold(')));
      expect(fonte, isNot(contains('.reduce(')));
      expect(fonte, isNot(contains('.sum')));
    });

    testWidgets('todo valor exibido é o de MoneyFormatter, e nenhum outro',
        (tester) async {
      final resultado = _resultadoRn30;
      await _montar(tester, resultado);

      final esperados = <String>{
        for (final item in resultado.itens) MoneyFormatter.reais(item.valor),
        for (final secao in SecaoDaMontagem.values)
          MoneyFormatter.reais(
            totalExato(
              resultado.itens.where((item) => secaoDe(item.chave) == secao),
            ),
          ),
      };
      final exibidos = _textosNaOrdem(tester)
          .where((texto) => texto.startsWith(r'R$'))
          .toSet();

      expect(exibidos, esperados);
    });
  });
}
