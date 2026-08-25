import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A decoração da **caixa** do input: a mais externa da subárvore.
BoxDecoration _decoracao(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(BoraTextField),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return caixa.decoration as BoxDecoration;
}

Future<FocusNode> _montar(
  WidgetTester tester, {
  String placeholder = 'seu e-mail',
}) async {
  final controller = TextEditingController();
  final foco = FocusNode();
  addTearDown(controller.dispose);
  addTearDown(foco.dispose);

  await pumpComponent(
    tester,
    SizedBox(
      width: 300,
      child: BoraTextField(
        controller: controller,
        placeholder: placeholder,
        focusNode: foco,
      ),
    ),
  );
  return foco;
}

void main() {
  group('DS-18 — o input sem foco', () {
    testWidgets('fundo branco, borda 2px ink, canto reto e padding 15×16',
        (tester) async {
      await _montar(tester);

      final decoracao = _decoracao(tester);

      expect(
        decoracao.color,
        BoraColors.white,
        reason: '§5, inputs: "Fundo branco"',
      );
      expect(
        decoracao.border!.top.color,
        BoraColors.ink,
        reason: '§5: "borda 2px ink"',
      );
      expect(decoracao.border!.top.width, 2.0);
      expect(
        decoracao.borderRadius,
        BorderRadius.zero,
        reason: '§5: "radius 0" — e §3 já mandava',
      );
      expect(
        tester
            .widget<Padding>(
              find.descendant(
                of: find.byType(BoraTextField),
                matching: find.byType(Padding),
              ),
            )
            .padding,
        BoraSpacing.input,
        reason: '§5: "padding 15px 16px"',
      );
      expect(
        BoraSpacing.input,
        const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
      );
    });

    testWidgets('o texto do campo é 600 15px', (tester) async {
      await _montar(tester);

      final estilo = tester.widget<TextField>(find.byType(TextField)).style!;

      expect(estilo.fontSize, 15.0, reason: '§5: "texto 600 15px"');
      expect(estilo.fontWeight, FontWeight.w600);
      expect(estilo, BoraTextStyles.input);
    });
  });

  group('DS-18 — o foco pinta a borda de primary', () {
    testWidgets('requestFocus troca a borda de ink para primary',
        (tester) async {
      final foco = await _montar(tester);
      expect(_decoracao(tester).border!.top.color, BoraColors.ink);

      foco.requestFocus();
      await tester.pumpAndSettle();

      final decoracao = _decoracao(tester);

      expect(
        decoracao.border!.top.color,
        BoraColors.primary,
        reason: '§5: "focus: border-color: #FF4D2E"',
      );
      expect(
        decoracao.border!.top.width,
        2.0,
        reason: 'o foco muda a cor, não a espessura',
      );
      expect(
        decoracao.borderRadius,
        BorderRadius.zero,
        reason: 'nem no foco o canto arredonda (§3)',
      );
    });

    testWidgets('perder o foco devolve a borda ink', (tester) async {
      final foco = await _montar(tester);
      foco.requestFocus();
      await tester.pumpAndSettle();
      expect(_decoracao(tester).border!.top.color, BoraColors.primary);

      foco.unfocus();
      await tester.pumpAndSettle();

      expect(_decoracao(tester).border!.top.color, BoraColors.ink);
    });

    testWidgets('sem focusNode de fora o campo cria o seu e reage ao toque',
        (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpComponent(
        tester,
        SizedBox(
          width: 300,
          child: BoraTextField(controller: controller, placeholder: 'senha'),
        ),
      );
      expect(_decoracao(tester).border!.top.color, BoraColors.ink);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      expect(_decoracao(tester).border!.top.color, BoraColors.primary);
    });
  });

  group('DS-18, A-06 — o placeholder não é transformado', () {
    testWidgets('"seu e-mail" aparece em minúsculas', (tester) async {
      await _montar(tester);

      expect(
        find.text('seu e-mail'),
        findsOneWidget,
        reason: '§5: "Placeholder em minúsculas (seu e-mail, senha)"',
      );
      expect(
        find.text('SEU E-MAIL'),
        findsNothing,
        reason: 'A-06: CAIXA ALTA é de título, label, botão e toast — o '
            'toUpperCase aqui estragaria nome próprio',
      );
    });
  });
}
