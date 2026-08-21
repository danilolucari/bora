import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A `BoxDecoration` que a superfície colocou **na árvore renderizada** — não
/// a que o construtor recebeu.
BoxDecoration _decoracao(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(BoraSurface),
      matching: find.byType(DecoratedBox),
    ),
  );
  return caixa.decoration as BoxDecoration;
}

void main() {
  group('DS-13 — a superfície comum de §3 e §4', () {
    testWidgets('canto reto, borda de 2px ink e uma única sombra dura',
        (tester) async {
      await pumpComponent(
        tester,
        const BoraSurface(acento: BoraAccent.primary, child: Text('BORA')),
      );

      final decoracao = _decoracao(tester);

      expect(
        decoracao.borderRadius,
        BorderRadius.zero,
        reason: '§3: "border-radius: 0 em tudo"',
      );
      expect(decoracao.border!.top.width, 2.0, reason: '§3: "2px solid"');
      expect(decoracao.border!.top.color, BoraColors.ink);
      expect(
        decoracao.boxShadow,
        hasLength(1),
        reason: '§4: uma sombra, não uma pilha',
      );
      expect(
        decoracao.boxShadow!.single.blurRadius,
        0.0,
        reason: '§4: "sempre duras, sem blur"',
      );
      expect(
        decoracao.boxShadow!.single.offset,
        const Offset(4, 4),
        reason: '§4, botão CTA: "4px 4px 0 <acento>"',
      );
    });

    testWidgets('sem acento não há sombra alguma, e não uma transparente',
        (tester) async {
      await pumpComponent(
        tester,
        const BoraSurface(child: Text('BORA')),
      );

      expect(
        _decoracao(tester).boxShadow,
        isNull,
        reason: 'sombra transparente ainda é sombra: §4 quer a ausência dela',
      );
    });

    testWidgets('a sombra sai na cor do acento pedido', (tester) async {
      await pumpComponent(
        tester,
        const BoraSurface(acento: BoraAccent.purple, child: Text('BORA')),
      );

      expect(
        _decoracao(tester).boxShadow!.single.color,
        BoraColors.purple,
        reason: '§4: a sombra do CTA é "0 <acento>" — a cor é a do contexto',
      );
    });

    testWidgets('o fundo, a cor e a espessura da borda pedidos chegam à árvore',
        (tester) async {
      await pumpComponent(
        tester,
        const BoraSurface(
          fundo: BoraColors.paper,
          corDaBorda: BoraColors.frameBorder,
          larguraDaBorda: 1,
          child: Text('BORA'),
        ),
      );

      final decoracao = _decoracao(tester);

      expect(decoracao.color, BoraColors.paper);
      expect(decoracao.border!.top.color, BoraColors.frameBorder);
      expect(decoracao.border!.top.width, 1.0);
      expect(
        decoracao.borderRadius,
        BorderRadius.zero,
        reason: 'nem a borda de 1px do frame ganha canto arredondado',
      );
    });

    testWidgets('a distância da sombra pedida chega à árvore', (tester) async {
      await pumpComponent(
        tester,
        const BoraSurface(
          acento: BoraAccent.ink,
          deslocamentoDaSombra: 6,
          child: Text('BORA'),
        ),
      );

      expect(
        _decoracao(tester).boxShadow!.single.offset,
        const Offset(6, 6),
        reason: '§4 tabela: "6px 6px 0 #141414" no card branco destacado',
      );
    });

    testWidgets('o padding pedido envolve o filho', (tester) async {
      await pumpComponent(
        tester,
        const BoraSurface(
          padding: BoraSpacing.chip,
          child: SizedBox(width: 10, height: 10),
        ),
      );

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(BoraSurface),
          matching: find.byType(Padding),
        ),
      );

      expect(padding.padding, BoraSpacing.chip);
    });
  });

  group('DS-13 — o palco mínimo dos testes de componente', () {
    testWidgets('pumpComponent monta o componente sob boraTheme()',
        (tester) async {
      await pumpComponent(tester, const BoraSurface(child: Text('BORA')));

      final tema = Theme.of(tester.element(find.byType(BoraSurface)));

      expect(tema.scaffoldBackgroundColor, BoraColors.paper);
      expect(tema.splashFactory, NoSplash.splashFactory);
      expect(find.text('BORA'), findsOneWidget);
    });
  });
}
