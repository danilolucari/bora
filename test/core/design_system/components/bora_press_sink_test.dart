import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A translação que o `Transform` da árvore renderizada aplica.
Matrix4 _translacao(WidgetTester tester) {
  final transform = tester.widget<Transform>(
    find.descendant(
      of: find.byType(BoraPressSink),
      matching: find.byType(Transform),
    ),
  );
  return transform.transform;
}

/// O deslocamento da sombra que está na árvore renderizada.
Offset _sombra(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(BoraPressSink),
      matching: find.byType(DecoratedBox),
    ),
  );
  return (caixa.decoration as BoxDecoration).boxShadow!.single.offset;
}

Future<void> _montar(
  WidgetTester tester, {
  VoidCallback? onPressed = _nada,
}) async {
  await pumpComponent(
    tester,
    BoraPressSink(
      acento: BoraAccent.primary,
      onPressed: onPressed,
      child: const SizedBox(width: 120, height: 48),
    ),
  );
}

void _nada() {}

/// Um ponteiro de mouse pousado sobre o CTA.
Future<TestGesture> _mouseSobreOCta(WidgetTester tester) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(find.byType(BoraPressSink)));
  await tester.pumpAndSettle();
  return mouse;
}

void main() {
  group('DS-11 — o CTA afunda no press', () {
    testWidgets('pointer down desloca (2,2) e encolhe a sombra de 4 para 2',
        (tester) async {
      await _montar(tester);
      expect(_translacao(tester), Matrix4.translationValues(0, 0, 0));
      expect(_sombra(tester), const Offset(4, 4));

      final gesto = await tester.startGesture(
        tester.getCenter(find.byType(BoraPressSink)),
      );
      await tester.pumpAndSettle();

      expect(
        _translacao(tester),
        Matrix4.translationValues(2, 2, 0),
        reason: '§4: "transform: translate(2px,2px)"',
      );
      expect(
        _sombra(tester),
        const Offset(2, 2),
        reason: '§4: "sombra encolhe de 4px 4px para 2px 2px"',
      );

      await gesto.up();
      await tester.pumpAndSettle();
    });

    testWidgets('pointer up volta a (0,0) e à sombra de 4px', (tester) async {
      await _montar(tester);
      final gesto = await tester.startGesture(
        tester.getCenter(find.byType(BoraPressSink)),
      );
      await tester.pumpAndSettle();

      await gesto.up();
      await tester.pumpAndSettle();

      expect(_translacao(tester), Matrix4.translationValues(0, 0, 0));
      expect(_sombra(tester), const Offset(4, 4));
    });

    testWidgets('pointer cancel também volta ao repouso', (tester) async {
      await _montar(tester);
      final gesto = await tester.startGesture(
        tester.getCenter(find.byType(BoraPressSink)),
      );
      await tester.pumpAndSettle();
      expect(_sombra(tester), const Offset(2, 2));

      await gesto.cancel();
      await tester.pumpAndSettle();

      expect(_translacao(tester), Matrix4.translationValues(0, 0, 0));
      expect(_sombra(tester), const Offset(4, 4));
    });

    testWidgets('o toque chama onPressed', (tester) async {
      var toques = 0;
      await pumpComponent(
        tester,
        BoraPressSink(
          acento: BoraAccent.primary,
          onPressed: () => toques++,
          child: const SizedBox(width: 120, height: 48),
        ),
      );

      await tester.tap(find.byType(BoraPressSink));
      await tester.pumpAndSettle();

      expect(toques, 1);
    });
  });

  group('DS-11 — o hover afunda igual (§4 diz "hover/press")', () {
    testWidgets('onEnter afunda e onExit volta', (tester) async {
      await _montar(tester);

      final mouse = await _mouseSobreOCta(tester);

      expect(_translacao(tester), Matrix4.translationValues(2, 2, 0));
      expect(_sombra(tester), const Offset(2, 2));

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();

      expect(_translacao(tester), Matrix4.translationValues(0, 0, 0));
      expect(_sombra(tester), const Offset(4, 4));
    });
  });

  group('DS-11 — o afundamento é uma transição, não um salto', () {
    testWidgets('a animação usa BoraMotion.estado e BoraMotion.curva',
        (tester) async {
      await _montar(tester);

      final animado = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(BoraPressSink),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(animado.duration, BoraMotion.estado);
      expect(animado.duration, const Duration(milliseconds: 150));
      expect(animado.curve, BoraMotion.curva);
    });

    testWidgets('no meio dos 150ms a sombra está entre 4px e 2px',
        (tester) async {
      await _montar(tester);

      final gesto = await tester.startGesture(
        tester.getCenter(find.byType(BoraPressSink)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));

      final meio = _sombra(tester).dx;
      expect(meio, greaterThan(2.0));
      expect(meio, lessThan(4.0));

      await gesto.up();
      await tester.pumpAndSettle();
    });
  });

  group('DS-11 — desabilitado não afunda', () {
    testWidgets('onPressed nulo rende opacidade .7', (tester) async {
      await _montar(tester, onPressed: null);

      final opacidade = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(BoraPressSink),
          matching: find.byType(Opacity),
        ),
      );

      expect(
        opacidade.opacity,
        BoraBorders.opacidadeDesabilitado,
        reason: 'A-07: a única opacidade do arquivo 02 é .7',
      );
      expect(opacidade.opacity, 0.7);
    });

    testWidgets('desabilitado não afunda no press nem no hover',
        (tester) async {
      await _montar(tester, onPressed: null);

      final gesto = await tester.startGesture(
        tester.getCenter(find.byType(BoraPressSink)),
      );
      await tester.pumpAndSettle();

      expect(_translacao(tester), Matrix4.translationValues(0, 0, 0));
      expect(_sombra(tester), const Offset(4, 4));

      await gesto.up();
      await _mouseSobreOCta(tester);

      expect(_translacao(tester), Matrix4.translationValues(0, 0, 0));
      expect(_sombra(tester), const Offset(4, 4));
    });
  });
}
