import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A caixa **visual** do botão de [simbolo] — o quadrado pintado de §5.
Finder _caixaVisual(String simbolo) => find
    .ancestor(of: find.text(simbolo), matching: find.byType(AnimatedContainer))
    .first;

/// O **alvo de toque** do botão de [simbolo]: o detector de gesto, que é
/// maior que a caixa pintada.
Finder _alvoDeToque(String simbolo) => find
    .ancestor(of: find.text(simbolo), matching: find.byType(GestureDetector))
    .first;

BoxDecoration _decoracao(WidgetTester tester, String simbolo) {
  final caixa = tester.widget<DecoratedBox>(
    find.ancestor(of: find.text(simbolo), matching: find.byType(DecoratedBox)).first,
  );
  return caixa.decoration as BoxDecoration;
}

Color _corDoSimbolo(WidgetTester tester, String simbolo) =>
    tester.widget<Text>(find.text(simbolo)).style!.color!;

Future<void> _montar(
  WidgetTester tester, {
  int valor = 3,
  VoidCallback? onIncrementar = _nada,
  VoidCallback? onDecrementar = _nada,
}) {
  return pumpComponent(
    tester,
    BoraStepper(
      valor: valor,
      onIncrementar: onIncrementar,
      onDecrementar: onDecrementar,
    ),
  );
}

void _nada() {}

/// Um ponteiro de mouse pousado sobre o botão de [simbolo].
Future<TestGesture> _mouseSobre(WidgetTester tester, String simbolo) async {
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  addTearDown(mouse.removePointer);
  await mouse.moveTo(tester.getCenter(_caixaVisual(simbolo)));
  await tester.pumpAndSettle();
  return mouse;
}

void main() {
  group('DS-17 — o desenho do stepper de §5', () {
    testWidgets('os dois botões medem 34×34', (tester) async {
      await _montar(tester);

      for (final simbolo in [BoraStepper.simboloMenos, BoraStepper.simboloMais]) {
        expect(
          tester.getSize(_caixaVisual(simbolo)),
          const Size(34, 34),
          reason: '§5: "Botões 34×34"',
        );
      }
    });

    testWidgets('o "−" é branco com borda 2px ink e o "+" é ink com cream',
        (tester) async {
      await _montar(tester);

      final menos = _decoracao(tester, BoraStepper.simboloMenos);
      expect(
        menos.color,
        BoraColors.white,
        reason: '§5: "− branco borda ink"',
      );
      expect(menos.border!.top.color, BoraColors.ink);
      expect(menos.border!.top.width, 2.0);
      expect(menos.borderRadius, BorderRadius.zero, reason: '§3');
      expect(
        _corDoSimbolo(tester, BoraStepper.simboloMenos),
        BoraColors.ink,
      );

      expect(
        _decoracao(tester, BoraStepper.simboloMais).color,
        BoraColors.ink,
        reason: '§5: "+ fundo ink texto cream"',
      );
      expect(
        _corDoSimbolo(tester, BoraStepper.simboloMais),
        BoraColors.cream,
      );
    });

    testWidgets('o valor central é 800 17px', (tester) async {
      await _montar(tester, valor: 7);

      final estilo = tester.widget<Text>(find.text('7')).style!;

      expect(estilo.fontSize, 17.0, reason: '§5: "Valor central 800 17px"');
      expect(estilo.fontWeight, FontWeight.w800);
    });

    testWidgets('o hover pinta o "+" de primary', (tester) async {
      await _montar(tester);
      expect(_decoracao(tester, BoraStepper.simboloMais).color, BoraColors.ink);

      final mouse = await _mouseSobre(tester, BoraStepper.simboloMais);

      expect(
        _decoracao(tester, BoraStepper.simboloMais).color,
        BoraColors.primary,
        reason: '§5: "+ fundo ink texto cream (hover #FF4D2E)"',
      );

      await mouse.moveTo(Offset.zero);
      await tester.pumpAndSettle();
      expect(_decoracao(tester, BoraStepper.simboloMais).color, BoraColors.ink);
    });
  });

  group('DS-17 — o alvo de toque acessível', () {
    testWidgets('cada botão é tocável em 44px nos dois eixos', (tester) async {
      await _montar(tester);

      for (final simbolo in [BoraStepper.simboloMenos, BoraStepper.simboloMais]) {
        final alvo = tester.getSize(_alvoDeToque(simbolo));

        expect(
          alvo.width,
          greaterThanOrEqualTo(44.0),
          reason: '§5: "garantir alvo de toque ≥44px via padding"',
        );
        expect(alvo.height, greaterThanOrEqualTo(44.0));
        expect(
          alvo.width,
          greaterThan(tester.getSize(_caixaVisual(simbolo)).width),
          reason: 'o alvo é maior que a caixa pintada — é a folga que o cria',
        );
      }
    });
  });

  group('DS-17, DS-34 — o stepper não faz conta', () {
    testWidgets('tocar "+" chama onIncrementar uma vez e o valor não muda',
        (tester) async {
      var incrementos = 0;
      await _montar(tester, valor: 3, onIncrementar: () => incrementos++);

      await tester.tap(_alvoDeToque(BoraStepper.simboloMais));
      await tester.pumpAndSettle();

      expect(incrementos, 1);
      expect(
        find.text('3'),
        findsOneWidget,
        reason: 'o valor exibido é a prop: sem estado interno, sem valor + 1',
      );
      expect(
        find.text('4'),
        findsNothing,
        reason: 'RN-12 é da spec calculo — o componente não a duplica',
      );
    });

    testWidgets('três toques em "+" continuam sem mexer no valor',
        (tester) async {
      var incrementos = 0;
      await _montar(tester, valor: 3, onIncrementar: () => incrementos++);

      for (var toque = 0; toque < 3; toque++) {
        await tester.tap(_alvoDeToque(BoraStepper.simboloMais));
        await tester.pumpAndSettle();
      }

      expect(incrementos, 3);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('tocar "−" chama onDecrementar uma vez', (tester) async {
      var decrementos = 0;
      await _montar(tester, valor: 3, onDecrementar: () => decrementos++);

      await tester.tap(_alvoDeToque(BoraStepper.simboloMenos));
      await tester.pumpAndSettle();

      expect(decrementos, 1);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsNothing);
    });
  });

  group('DS-17 — o limite vem de fora (A-07)', () {
    testWidgets('onDecrementar nulo rende o "−" em .7 e não emite nada',
        (tester) async {
      var decrementos = 0;
      await _montar(tester, onDecrementar: () => decrementos++);
      await tester.tap(_alvoDeToque(BoraStepper.simboloMenos));
      await tester.pumpAndSettle();
      expect(decrementos, 1);

      await _montar(tester, onDecrementar: null);
      await tester.tap(_alvoDeToque(BoraStepper.simboloMenos));
      await tester.pumpAndSettle();

      expect(
        decrementos,
        1,
        reason: 'no limite o stepper não emite — sem calcular limite algum',
      );
      expect(
        tester
            .widget<Opacity>(
              find
                  .ancestor(
                    of: find.text(BoraStepper.simboloMenos),
                    matching: find.byType(Opacity),
                  )
                  .first,
            )
            .opacity,
        BoraBorders.opacidadeDesabilitado,
        reason: 'A-07: desabilitado é opacity .7',
      );
      expect(
        find.ancestor(
          of: find.text(BoraStepper.simboloMais),
          matching: find.byType(Opacity),
        ),
        findsNothing,
        reason: 'só o botão sem callback esmaece',
      );
    });
  });
}
