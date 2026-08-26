import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/home/presentation/widgets/comecar_outra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';

Future<void> _montar(WidgetTester tester, {VoidCallback? aoComecar}) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(const Size(390, 820));
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: ComecarOutra(aoComecarChurrasco: aoComecar ?? () {}),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontesArchivo);

  group('HOME-12 — a seção de T-02', () {
    testWidgets('tem o título e os dois cards do grid', (tester) async {
      await _montar(tester);

      expect(find.text('COMEÇAR OUTRA'), findsOneWidget);
      expect(find.text('🔥 CHURRASCO'), findsOneWidget);
      expect(find.text('🎈 NIVER · EM BREVE'), findsOneWidget);
    });

    testWidgets('os dois ficam lado a lado, em duas colunas', (tester) async {
      await _montar(tester);

      final esquerda = tester.getRect(find.text('🔥 CHURRASCO'));
      final direita = tester.getRect(find.text('🎈 NIVER · EM BREVE'));

      expect(esquerda.right, lessThan(direita.left));
      expect(
        esquerda.center.dy,
        closeTo(direita.center.dy, 1),
        reason: 'T-02: grid de 2 colunas, não uma coluna empilhada',
      );
    });

    testWidgets('as duas colunas têm a mesma largura', (tester) async {
      await _montar(tester);

      expect(
        tester.getSize(find.byType(BoraPressSink)).width,
        closeTo(tester.getSize(find.byType(BoraEmptySlot)).width, 0.5),
      );
    });
  });

  group('HOME-12 — o churrasco é a entrada para Montar', () {
    testWidgets('o toque volta por callback', (tester) async {
      var comecou = 0;
      await _montar(tester, aoComecar: () => comecou++);

      await tester.tap(find.text('🔥 CHURRASCO'));
      await tester.pumpAndSettle();

      expect(comecou, 1);
    });
  });

  group('HOME-13 — "NIVER · EM BREVE" não é clicável (aceite de UC-02)', () {
    testWidgets('tocar nele não dispara nada', (tester) async {
      var comecou = 0;
      await _montar(tester, aoComecar: () => comecou++);

      await tester.tap(find.text('🎈 NIVER · EM BREVE'));
      await tester.pumpAndSettle();

      expect(
        comecou,
        0,
        reason: 'é o par que discrimina: um teste que só afirmasse o toque do '
            'churrasco passaria com o níver clicável',
      );
      expect(
        tester.takeException(),
        isNull,
        reason: 'tocar não pode nem estourar nem navegar — nada acontece',
      );
    });

    testWidgets('o níver é slot vazio: tracejado e esmaecido', (tester) async {
      await _montar(tester);

      final slot = find.byType(BoraEmptySlot);
      expect(slot, findsOneWidget);
      expect(
        find.descendant(of: slot, matching: find.text('🎈 NIVER · EM BREVE')),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Opacity>(
              find.descendant(of: slot, matching: find.byType(Opacity)).first,
            )
            .opacity,
        BoraBorders.opacidadeDesabilitado,
        reason: 'T-02: "tracejado, opacity .7"',
      );
    });

    testWidgets('o níver não tem afundamento de CTA nenhum', (tester) async {
      await _montar(tester);

      expect(
        find.descendant(
          of: find.byType(BoraEmptySlot),
          matching: find.byType(BoraPressSink),
        ),
        findsNothing,
        reason: '"EM BREVE" não é ação bloqueada: é ação que ainda não existe',
      );
      expect(
        find.byType(BoraPressSink),
        findsOneWidget,
        reason: 'só o churrasco é ação',
      );
    });
  });
}
