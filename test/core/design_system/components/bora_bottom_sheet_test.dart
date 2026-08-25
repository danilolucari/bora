import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

const double _larguraDoPalco = 390;

/// A decoração do painel.
BoxDecoration _painel(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find.byKey(BoraBottomSheet.panelKey),
  );
  return caixa.decoration as BoxDecoration;
}

/// A decoração do botão ✕.
BoxDecoration _fechar(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byKey(BoraBottomSheet.fecharKey),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return caixa.decoration as BoxDecoration;
}

/// As cores dos scrims presentes na árvore.
Iterable<Color?> _scrims(WidgetTester tester) => tester
    .widgetList<ModalBarrier>(find.byType(ModalBarrier))
    .map((barreira) => barreira.color);

Future<void> _montarPainel(WidgetTester tester, {String titulo = 'o que rola'}) {
  return pumpComponent(
    tester,
    SizedBox(
      width: _larguraDoPalco,
      child: BoraBottomSheet(
        titulo: titulo,
        conteudo: (context) => const Text('quem leva o quê'),
      ),
    ),
  );
}

/// Uma tela com um botão que abre o sheet de verdade.
Future<void> _abrirPelaRota(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        body: Builder(
          builder: (context) => BoraPrimaryButton(
            rotulo: 'abrir',
            onPressed: () => BoraBottomSheet.mostrar<void>(
              context,
              titulo: 'o que rola',
              conteudo: (context) => const Text('quem leva o quê'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('ABRIR'));
  await tester.pumpAndSettle();
}

void main() {
  group('DS-30 — o painel', () {
    testWidgets('fundo paper, borda só no topo com 2px ink, canto reto',
        (tester) async {
      await _montarPainel(tester);

      final decoracao = _painel(tester);
      final borda = decoracao.border! as Border;

      expect(decoracao.color, BoraColors.paper, reason: '§5: "fundo paper"');
      expect(borda.top.width, 2.0, reason: '§5: "border-top 2px ink"');
      expect(borda.top.color, BoraColors.ink);
      expect(
        borda.bottom,
        BorderSide.none,
        reason: 'o painel encosta nas outras três margens da tela',
      );
      expect(borda.left, BorderSide.none);
      expect(borda.right, BorderSide.none);
      expect(decoracao.borderRadius, BorderRadius.zero, reason: '§3');
    });

    testWidgets('o padding é o 22/24/30 de §5', (tester) async {
      await _montarPainel(tester);

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byKey(BoraBottomSheet.panelKey),
              matching: find.byType(Padding),
            )
            .first,
      );

      expect(padding.padding, BoraSpacing.sheet);
      expect(
        BoraSpacing.sheet,
        const EdgeInsets.fromLTRB(24, 22, 24, 30),
        reason: '§5: "padding 22px 24px 30px"',
      );
    });

    testWidgets('título em Archivo Black 22px e CAIXA ALTA', (tester) async {
      await _montarPainel(tester, titulo: 'o que rola');

      final estilo = tester.widget<Text>(find.text('O QUE ROLA')).style!;

      expect(
        estilo.fontFamily,
        BoraTextStyles.familiaDisplay,
        reason: '§5: "título Archivo Black 22px"',
      );
      expect(estilo.fontSize, 22.0);
      expect(find.text('o que rola'), findsNothing, reason: '§7');
    });

    testWidgets('o ✕ é 32×32 com borda 2px, e o conteúdo recebido aparece',
        (tester) async {
      await _montarPainel(tester);

      expect(
        tester.getSize(find.byKey(BoraBottomSheet.fecharKey)),
        const Size(32, 32),
        reason: '§5: "botão ✕ 32×32 borda 2px"',
      );
      expect(_fechar(tester).border!.top.width, 2.0);
      expect(_fechar(tester).border!.top.color, BoraColors.ink);
      expect(_fechar(tester).borderRadius, BorderRadius.zero, reason: '§3');
      expect(find.text('✕'), findsOneWidget);
      expect(find.text('quem leva o quê'), findsOneWidget);
    });
  });

  group('DS-30 — o sheet aberto sobre a tela', () {
    testWidgets('o scrim é rgba(20,10,50,.45), e não ink', (tester) async {
      await _abrirPelaRota(tester);

      expect(
        _scrims(tester),
        contains(BoraColors.sheetScrim),
        reason: '§5: "Overlay rgba(20,10,50,.45)"',
      );
      expect(BoraColors.sheetScrim.toARGB32(), 0x73140A32);
      expect(
        _scrims(tester),
        isNot(contains(BoraColors.ink)),
        reason: 'o scrim é um preto-arroxeado próprio, não o ink da tabela',
      );
    });

    testWidgets('o painel fica ancorado embaixo, na largura da tela',
        (tester) async {
      await _abrirPelaRota(tester);

      final painel = tester.getRect(find.byKey(BoraBottomSheet.panelKey));
      final tela = tester.getRect(find.byType(MaterialApp));

      expect(painel.bottom, tela.bottom, reason: '§5: "ancorado embaixo"');
      expect(painel.left, tela.left);
      expect(painel.right, tela.right);
      expect(painel.top, greaterThan(tela.top));
    });

    testWidgets('tocar o ✕ fecha o sheet', (tester) async {
      await _abrirPelaRota(tester);
      expect(find.byKey(BoraBottomSheet.panelKey), findsOneWidget);

      await tester.tap(find.byKey(BoraBottomSheet.fecharKey));
      await tester.pumpAndSettle();

      expect(find.byKey(BoraBottomSheet.panelKey), findsNothing);
      expect(find.text('ABRIR'), findsOneWidget);
    });

    testWidgets('tocar o scrim fecha o sheet', (tester) async {
      await _abrirPelaRota(tester);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(
        find.byKey(BoraBottomSheet.panelKey),
        findsNothing,
        reason: 'tocar fora do painel fecha, como manda o comportamento de '
            'sheet modal',
      );
    });
  });
}
