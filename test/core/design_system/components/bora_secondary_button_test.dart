import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A `BoxDecoration` que o botão colocou **na árvore renderizada**.
BoxDecoration _decoracao(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(BoraSecondaryButton),
      matching: find.byType(DecoratedBox),
    ),
  );
  return caixa.decoration as BoxDecoration;
}

/// Um ponteiro de mouse pousado sobre o botão.
Future<TestGesture> _mouseSobreOBotao(WidgetTester tester) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(find.byType(BoraSecondaryButton)));
  await tester.pumpAndSettle();
  return mouse;
}

void main() {
  group('DS-14 — o botão secundário de §5', () {
    testWidgets('fundo transparente, borda 2px ink e texto ink',
        (tester) async {
      await pumpComponent(
        tester,
        BoraSecondaryButton(rotulo: 'agora não', onPressed: () {}),
      );

      final decoracao = _decoracao(tester);

      expect(
        decoracao.color,
        Colors.transparent,
        reason: '§5, botão secundário: "Fundo transparente ou branco"',
      );
      expect(decoracao.border!.top.width, 2.0, reason: '§5: "borda 2px ink"');
      expect(decoracao.border!.top.color, BoraColors.ink);
      expect(
        decoracao.borderRadius,
        BorderRadius.zero,
        reason: '§3: "border-radius: 0 em tudo"',
      );
      expect(
        tester.widget<Text>(find.text('AGORA NÃO')).style!.color,
        BoraColors.ink,
        reason: '§5: "texto ink"',
      );
    });

    testWidgets('fundoBranco pinta o fundo de branco', (tester) async {
      await pumpComponent(
        tester,
        BoraSecondaryButton(
          rotulo: 'agora não',
          fundoBranco: true,
          onPressed: () {},
        ),
      );

      expect(
        _decoracao(tester).color,
        BoraColors.white,
        reason: '§5 dá as duas opções: "transparente ou branco"',
      );
    });

    testWidgets('no hover o fundo vira paper e o exit devolve o de repouso',
        (tester) async {
      await pumpComponent(
        tester,
        BoraSecondaryButton(rotulo: 'agora não', onPressed: () {}),
      );
      expect(_decoracao(tester).color, Colors.transparent);

      final mouse = await _mouseSobreOBotao(tester);

      expect(
        _decoracao(tester).color,
        BoraColors.paper,
        reason: '§5: "Hover: fundo paper ou sombra dura"',
      );

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();

      expect(_decoracao(tester).color, Colors.transparent);
    });

    testWidgets('a sombra continua dura, sem blur e sem radius',
        (tester) async {
      await pumpComponent(
        tester,
        BoraSecondaryButton(rotulo: 'agora não', onPressed: () {}),
      );

      final sombra = _decoracao(tester).boxShadow!.single;

      expect(
        sombra.blurRadius,
        0.0,
        reason: '§5 admite "sombra dura" no secundário — nunca radius (§8)',
      );
      expect(sombra.offset, const Offset(4, 4));
      expect(sombra.color, BoraColors.ink);
    });
  });

  group('DS-32 — a copy do botão secundário sai em CAIXA ALTA', () {
    testWidgets('entra "agora não", sai "AGORA NÃO"', (tester) async {
      await pumpComponent(
        tester,
        BoraSecondaryButton(rotulo: 'agora não', onPressed: () {}),
      );

      expect(find.text('AGORA NÃO'), findsOneWidget);
      expect(find.text('agora não'), findsNothing);
    });

    testWidgets('rótulo vazio renderiza sem exceção', (tester) async {
      await pumpComponent(
        tester,
        BoraSecondaryButton(rotulo: '', onPressed: () {}),
      );

      expect(find.byType(BoraSecondaryButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('DS-14 — o secundário desabilitado (A-07)', () {
    testWidgets('onPressed nulo rende opacidade .7 e não reage ao hover',
        (tester) async {
      await pumpComponent(
        tester,
        const BoraSecondaryButton(rotulo: 'agora não'),
      );

      expect(
        tester
            .widget<Opacity>(
              find.descendant(
                of: find.byType(BoraSecondaryButton),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        BoraBorders.opacidadeDesabilitado,
      );

      await _mouseSobreOBotao(tester);

      expect(
        _decoracao(tester).color,
        Colors.transparent,
        reason: 'desabilitado não ganha o fundo de hover',
      );
    });
  });
}
