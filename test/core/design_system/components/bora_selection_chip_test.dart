import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A `BoxDecoration` que o chip colocou **na árvore renderizada**.
BoxDecoration _decoracao(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(BoraSelectionChip),
      matching: find.byType(DecoratedBox),
    ),
  );
  return caixa.decoration as BoxDecoration;
}

/// O `Text` do chip, com o estilo que a árvore recebeu.
Text _texto(WidgetTester tester) {
  return tester.widget<Text>(
    find.descendant(
      of: find.byType(BoraSelectionChip),
      matching: find.byType(Text),
    ),
  );
}

BoraSelectionChip _chip({required bool selecionado, VoidCallback? onTap}) {
  return BoraSelectionChip(
    rotulo: 'carne bovina',
    emoji: '🥩',
    selecionado: selecionado,
    onTap: onTap,
  );
}

Future<void> _montar(
  WidgetTester tester, {
  required bool selecionado,
  VoidCallback? onTap,
}) {
  return pumpComponent(tester, _chip(selecionado: selecionado, onTap: onTap));
}

void main() {
  group('DS-15 — os dois estados do chip de §5', () {
    testWidgets('não selecionado: fundo branco, texto ink, borda 2px ink',
        (tester) async {
      await _montar(tester, selecionado: false);

      final decoracao = _decoracao(tester);

      expect(
        decoracao.color,
        BoraColors.white,
        reason: '§5: "Não selecionado: fundo branco"',
      );
      expect(
        _texto(tester).style!.color,
        BoraColors.ink,
        reason: '§5: "Não selecionado: … texto ink"',
      );
      expect(decoracao.border!.top.width, 2.0, reason: '§5: "borda 2px ink"');
      expect(decoracao.border!.top.color, BoraColors.ink);
      expect(
        decoracao.borderRadius,
        BorderRadius.zero,
        reason: '§3: "border-radius: 0 em tudo (… chips)"',
      );
      expect(
        decoracao.boxShadow,
        isNull,
        reason: '§5 não dá sombra ao chip — e §4 não tem sombra invisível',
      );
    });

    testWidgets('selecionado: fundo ink, texto cream', (tester) async {
      await _montar(tester, selecionado: true);

      expect(
        _decoracao(tester).color,
        BoraColors.ink,
        reason: '§5: "Selecionado: fundo ink"',
      );
      expect(
        _texto(tester).style!.color,
        BoraColors.cream,
        reason: '§5: "Selecionado: … texto cream"',
      );
    });
  });

  group('DS-15, DS-32 — a copy do chip', () {
    testWidgets('o rótulo sai em CAIXA ALTA, com o emoji à esquerda',
        (tester) async {
      await _montar(tester, selecionado: false);

      expect(
        _texto(tester).data,
        '🥩 CARNE BOVINA',
        reason: '§5: "800 13px CAIXA ALTA, emoji à esquerda"',
      );
      expect(find.text('carne bovina'), findsNothing);
    });

    testWidgets('o texto é 800 13px e o padding é o 10×14 de §5',
        (tester) async {
      await _montar(tester, selecionado: false);

      final estilo = _texto(tester).style!;

      expect(estilo.fontSize, 13.0, reason: '§5: "800 13px"');
      expect(estilo.fontWeight, FontWeight.w800);
      expect(
        tester
            .widget<Padding>(
              find.descendant(
                of: find.byType(BoraSelectionChip),
                matching: find.byType(Padding),
              ),
            )
            .padding,
        BoraSpacing.chip + const EdgeInsets.all(2),
        reason: '§5: "Padding 10px 14px" mais a borda de 2px de §3, que o box '
            'model do CSS põe por fora do padding',
      );
      expect(
        BoraSpacing.chip,
        const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      );
    });
  });

  group('DS-15 — a troca de estado é a transição .15s de §6', () {
    testWidgets('a animação usa BoraMotion.estado', (tester) async {
      await _montar(tester, selecionado: false);

      final animado = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(BoraSelectionChip),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect(animado.duration, BoraMotion.estado);
      expect(
        animado.duration,
        const Duration(milliseconds: 150),
        reason: '§6: "transition: all .15s em chips, segmented, botões"',
      );
      expect(animado.curve, BoraMotion.curva);
    });

    testWidgets('no meio dos 150ms o fundo não é nem branco nem ink',
        (tester) async {
      await _montar(tester, selecionado: false);
      // Trocar de estado sem `pumpAndSettle`: é no meio da transição que
      // salto e transição se distinguem.
      await tester.pumpWidget(
        MaterialApp(
          theme: boraTheme(),
          home: Scaffold(body: Center(child: _chip(selecionado: true))),
        ),
      );
      await tester.pump(const Duration(milliseconds: 75));

      final meio = _decoracao(tester).color;

      expect(meio, isNot(BoraColors.white));
      expect(
        meio,
        isNot(BoraColors.ink),
        reason: 'a troca de §6 é transição, não salto',
      );

      await tester.pumpAndSettle();
      expect(_decoracao(tester).color, BoraColors.ink);
    });
  });

  group('DS-15 — o toque do chip', () {
    testWidgets('tocar chama onTap exatamente uma vez', (tester) async {
      var toques = 0;
      await _montar(tester, selecionado: false, onTap: () => toques++);

      await tester.tap(find.byType(BoraSelectionChip));
      await tester.pumpAndSettle();

      expect(toques, 1);
    });
  });
}
