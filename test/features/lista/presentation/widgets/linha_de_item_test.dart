import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
import 'package:bora/features/lista/presentation/widgets/linha_de_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/festa_rn30.dart';

/// As duas viewports do produto: o frame do celular e a janela do web.
const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

/// Monta a linha isolada e devolve quantas vezes ela pediu para expandir.
Future<List<void>> _montar(
  WidgetTester tester, {
  required ItemDeLista item,
  PrecoDeMercado? leitura,
  bool aberta = false,
  bool expansivel = true,
  Size viewport = _frameCompacto,
}) async {
  final toques = <void>[];

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: LinhaDeItem(
          item: item,
          leitura: leitura,
          aberta: aberta,
          onAlternar: expansivel ? () => toques.add(null) : null,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return toques;
}

Finder _barra() => find.byType(BoraPriceRangeBar);

/// Um texto no papel "nome/valor de linha de lista" de §2.
///
/// A distinção importa: o valor da Picanha é `R\$ 54` e o **mínimo** da faixa
/// também — 54 = 45 × 1,2 kg é a coincidência que `tabela_de_precos_de_
/// mercado.dart` registra. Os dois textos moram em papéis tipográficos
/// diferentes, e é por eles que o teste os separa.
Finder _textoDeLinha(String texto) => find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data == texto &&
          widget.style == BoraTextStyles.linhaLista,
    );

BoraPriceRangeBar _barraDe(WidgetTester tester) =>
    tester.widget<BoraPriceRangeBar>(_barra());

/// O ponto vermelho de 8px de RN-12, achado pela decoração que o define.
Finder _pontoDeEditado() => find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration ==
              const BoxDecoration(
                color: BoraColors.primary,
                shape: BoxShape.circle,
              ),
    );

void main() {
  final resultado = resultadoRn30();
  final bovina = itemDe(resultado, ChaveItem.bovina);
  final frango = itemDe(resultado, ChaveItem.frango);
  final paoDeAlho = itemDe(resultado, ChaveItem.paoDeAlho);
  final gelo = itemDe(resultado, ChaveItem.gelo);

  final leituraDaBovina = LinhaDeItem.leituraDeMercadoDe(ChaveItem.bovina)!;
  final leituraDoPao = LinhaDeItem.leituraDeMercadoDe(ChaveItem.paoDeAlho)!;
  final leituraDoGelo = LinhaDeItem.leituraDeMercadoDe(ChaveItem.gelo)!;

  _viewports.forEach((nome, viewport) {
    group('LIST-03 — emoji, nome, quantidade e valor ($nome)', () {
      testWidgets('a linha renderiza os quatro dados do item', (tester) async {
        await _montar(
          tester,
          item: bovina,
          leitura: leituraDaBovina,
          viewport: viewport,
        );

        expect(find.text(bovina.emoji), findsOneWidget);
        expect(_textoDeLinha(bovina.nome), findsOneWidget);
        expect(
          _textoDeLinha(MoneyFormatter.reais(bovina.valor)),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            rotuloDeQuantidade(bovina.quantidade, bovina.unidade),
          ),
          findsOneWidget,
        );
      });
    });

    group('LIST-08 — a leitura de mercado ($nome)', () {
      testWidgets('item coberto traz "{quantidade} · média de N mercados"',
          (tester) async {
        await _montar(
          tester,
          item: bovina,
          leitura: leituraDaBovina,
          viewport: viewport,
        );

        expect(
          find.text(
            ListaTextos.mediaDeMercados(
              rotuloDeQuantidade(bovina.quantidade, bovina.unidade),
              4,
            ),
          ),
          findsOneWidget,
        );
      });

      testWidgets('item não coberto mostra a quantidade sem média e sem barra',
          (tester) async {
        await _montar(tester, item: frango, viewport: viewport);

        expect(
          find.text(rotuloDeQuantidade(frango.quantidade, frango.unidade)),
          findsOneWidget,
        );
        expect(find.textContaining('média de'), findsNothing);
        expect(_barra(), findsNothing);
      });
    });
  });

  group('LIST-08 — o N de cada linha vem da coluna Fontes de RN-11', () {
    testWidgets('4 na Picanha bovina, 3 no Pão de alho, 2 no Gelo',
        (tester) async {
      for (final caso in [
        (bovina, leituraDaBovina, 4),
        (paoDeAlho, leituraDoPao, 3),
        (gelo, leituraDoGelo, 2),
      ]) {
        final (item, leitura, fontes) = caso;

        await _montar(tester, item: item, leitura: leitura);

        expect(
          find.text(
            ListaTextos.mediaDeMercados(
              rotuloDeQuantidade(item.quantidade, item.unidade),
              fontes,
            ),
          ),
          findsOneWidget,
          reason: '${item.nome} tem média de $fontes mercados em RN-11',
        );
      }
    });
  });

  group('LIST-08 — a barra de faixa', () {
    testWidgets('a Picanha exibe os extremos R\$ 54 e R\$ 83', (tester) async {
      await _montar(tester, item: bovina, leitura: leituraDaBovina);

      expect(_barra(), findsOneWidget);
      expect(_barraDe(tester).rotuloMin, 'R\$ 54');
      expect(_barraDe(tester).rotuloMax, 'R\$ 83');
      expect(
        find.descendant(of: _barra(), matching: find.text('R\$ 54')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _barra(), matching: find.text('R\$ 83')),
        findsOneWidget,
      );
    });

    testWidgets('a fração é a de posicaoDoMarcador, não uma conta do widget',
        (tester) async {
      await _montar(tester, item: bovina, leitura: leituraDaBovina);

      expect(_barraDe(tester).fracao, posicaoDoMarcador(leituraDaBovina));
    });

    testWidgets('faixa degenerada (máximo == mínimo) põe o marcador em 0',
        (tester) async {
      const degenerada = PrecoDeMercado(
        nome: 'Picanha bovina',
        emoji: '🥩',
        corredor: Corredor.acougue,
        rotuloDeQuantidade: '1,2 kg',
        media: 65,
        minimo: 65,
        maximo: 65,
        fontes: 4,
        chave: ChaveItem.bovina,
      );

      await _montar(tester, item: bovina, leitura: degenerada);

      expect(_barra(), findsOneWidget);
      expect(_barraDe(tester).fracao, 0);
      expect(_barraDe(tester).fracaoNoTrilho, 0);
    });

    testWidgets('override acima do máximo não move a faixa nem tira o '
        'marcador do trilho', (tester) async {
      final caro = bovina.copyWith(precoOverride: 900);

      await _montar(tester, item: caro, leitura: leituraDaBovina);

      expect(_barraDe(tester).rotuloMin, MoneyFormatter.reais(54));
      expect(_barraDe(tester).rotuloMax, MoneyFormatter.reais(83));
      expect(_barraDe(tester).fracao, posicaoDoMarcador(leituraDaBovina));
      expect(_barraDe(tester).fracaoNoTrilho, inInclusiveRange(0, 1));
    });
  });

  group('D-2 — a micro-label MÉDIA', () {
    testWidgets('renderiza na linha com leitura de mercado', (tester) async {
      await _montar(tester, item: bovina, leitura: leituraDaBovina);

      expect(find.text(ListaTextos.media), findsOneWidget);
    });

    testWidgets('não renderiza na linha sem leitura de mercado',
        (tester) async {
      await _montar(tester, item: frango);

      expect(find.text(ListaTextos.media), findsNothing);
    });
  });

  group('LIST-12 — o ponto vermelho de 8px', () {
    testWidgets('item editado o exibe, com o lado de RN-12', (tester) async {
      final editado = bovina.copyWith(quantidadeOverride: 2);

      await _montar(tester, item: editado);

      expect(_pontoDeEditado(), findsOneWidget);
      expect(
        tester.getSize(_pontoDeEditado()),
        const Size(
          LinhaDeItem.ladoDoPontoDeEditado,
          LinhaDeItem.ladoDoPontoDeEditado,
        ),
      );
    });

    testWidgets('item sem ajuste não o exibe', (tester) async {
      await _montar(tester, item: bovina);

      expect(_pontoDeEditado(), findsNothing);
    });
  });

  group('LIST-10 — o toque e o caret', () {
    testWidgets('tocar a linha dispara o callback de expansão', (tester) async {
      final toques = await _montar(tester, item: bovina);

      await tester.tap(find.text(bovina.nome));
      await tester.pump();

      expect(toques, hasLength(1));
    });

    testWidgets('a linha aberta mostra ▴ e a fechada, ▾', (tester) async {
      await _montar(tester, item: bovina, aberta: true);
      expect(find.text(BoraExpandableRow.caretAberto), findsOneWidget);
      expect(find.text(BoraExpandableRow.caretFechado), findsNothing);

      await _montar(tester, item: bovina);
      expect(find.text(BoraExpandableRow.caretFechado), findsOneWidget);
      expect(find.text(BoraExpandableRow.caretAberto), findsNothing);
    });

    testWidgets('linha sem expansão não tem caret e não emite no toque',
        (tester) async {
      final toques = await _montar(tester, item: gelo, expansivel: false);

      await tester.tap(find.text(gelo.nome));
      await tester.pump();

      expect(toques, isEmpty);
      expect(find.text(BoraExpandableRow.caretFechado), findsNothing);
      expect(find.text(BoraExpandableRow.caretAberto), findsNothing);
    });
  });
}
