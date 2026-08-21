import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

const String _textoDaDica = 'a cerveja some rápido: conte 3 latas por adulto';

/// O tracejado desenhado sobre [pai].
BoraDashedBorderPainter _tracejado(WidgetTester tester, Type pai) {
  final pintura = tester.widget<CustomPaint>(
    find.descendant(of: find.byType(pai), matching: find.byType(CustomPaint)).first,
  );
  return pintura.foregroundPainter! as BoraDashedBorderPainter;
}

Future<void> _montarDica(WidgetTester tester, {String emoji = '💡'}) {
  return pumpComponent(
    tester,
    SizedBox(
      width: 320,
      child: BoraDashedNote(emoji: emoji, texto: _textoDaDica),
    ),
  );
}

void main() {
  group('DS-23 — a dica tracejada de §3', () {
    testWidgets('fundo branco, canto reto e borda 2px tracejada ink',
        (tester) async {
      await _montarDica(tester);

      final caixa = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(BoraDashedNote),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoracao = caixa.decoration as BoxDecoration;

      expect(decoracao.color, BoraColors.white, reason: '§3: "fundo branco"');
      expect(decoracao.borderRadius, BorderRadius.zero, reason: '§3');
      expect(
        decoracao.border,
        isNull,
        reason: 'a borda da dica é tracejada — não é a sólida de §3',
      );

      final tracejado = _tracejado(tester, BoraDashedNote);

      expect(
        tracejado.cor,
        BoraColors.ink,
        reason: '§3: "Dica/nota: 2px dashed #141414"',
      );
      expect(tracejado.largura, 2.0);
      expect(tracejado.cor, BoraBorders.dicaTracejada.cor);
      expect(tracejado.largura, BoraBorders.dicaTracejada.largura);
    });

    testWidgets('texto 600 12px text-2', (tester) async {
      await _montarDica(tester);

      final estilo = tester.widget<Text>(find.text(_textoDaDica)).style!;

      expect(
        estilo.fontSize,
        12.0,
        reason: '§3: "texto 600 12px text-2"',
      );
      expect(estilo.fontWeight, FontWeight.w600);
      expect(estilo.color, BoraColors.text2);
    });

    testWidgets('cada emoji-âncora de §3 aparece à esquerda do texto',
        (tester) async {
      for (final emoji in BoraDashedNote.emojisAncora) {
        await _montarDica(tester, emoji: emoji);

        expect(
          find.text(emoji),
          findsOneWidget,
          reason: '§3: "sempre com emoji-âncora (💡 📊 ✅)"',
        );
        expect(
          tester.getRect(find.text(emoji)).right,
          lessThanOrEqualTo(tester.getRect(find.text(_textoDaDica)).left),
          reason: 'a âncora fica à esquerda',
        );
      }

      expect(BoraDashedNote.emojisAncora, ['💡', '📊', '✅']);
    });
  });

  group('DS-23 — o slot vazio de §3', () {
    testWidgets('borda 2px tracejada text-3 e opacity .7', (tester) async {
      await pumpComponent(
        tester,
        const BoraEmptySlot(child: Text('ninguém trouxe ainda')),
      );

      final tracejado = _tracejado(tester, BoraEmptySlot);

      expect(
        tracejado.cor,
        BoraColors.text3,
        reason: '§3: "Slot vazio/desabilitado: borda 2px dashed #9b9b9b"',
      );
      expect(tracejado.largura, 2.0);
      expect(tracejado.cor, BoraBorders.slotTracejado.cor);

      final opacidade = tester.widget<Opacity>(
        find
            .descendant(
              of: find.byType(BoraEmptySlot),
              matching: find.byType(Opacity),
            )
            .first,
      );

      expect(opacidade.opacity, 0.7, reason: '§3: "opacity .7"');
      expect(opacidade.opacity, BoraBorders.opacidadeDesabilitado);
    });

    testWidgets('mostra o filho e não pinta fundo nenhum', (tester) async {
      await pumpComponent(
        tester,
        const BoraEmptySlot(child: Text('ninguém trouxe ainda')),
      );

      expect(find.text('ninguém trouxe ainda'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BoraEmptySlot),
          matching: find.byType(DecoratedBox),
        ),
        findsNothing,
        reason: '§3 dá ao slot só borda tracejada e opacidade — não um fundo',
      );
    });
  });

  group('DS-23 — o tracejado é desenhado à mão', () {
    test('traço e vão são positivos: sem vão não há tracejado', () {
      expect(BoraDashedBorderPainter.traco, greaterThan(0));
      expect(BoraDashedBorderPainter.vao, greaterThan(0));
    });
  });
}
