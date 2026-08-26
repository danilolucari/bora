import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/entrar/presentation/widgets/divisor_ou.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/pump_component.dart';

void main() {
  group('ENT-03 — o divisor "OU"', () {
    testWidgets('renderiza o rótulo literal de T-01', (tester) async {
      await pumpComponent(tester, const DivisorOu());

      expect(find.text('OU'), findsOneWidget);
    });

    testWidgets('duas linhas de 2px na cor de divisor de 13%', (tester) async {
      await pumpComponent(tester, const DivisorOu());

      final linhas = find.descendant(
        of: find.byType(DivisorOu),
        matching: find.byType(ColoredBox),
      );

      expect(linhas, findsNWidgets(2), reason: 'T-01: uma linha de cada lado');

      for (var i = 0; i < 2; i++) {
        expect(
          tester.widget<ColoredBox>(linhas.at(i)).color,
          BoraColors.divider2,
          reason: 'T-01 pede 13%, que é o token divider2',
        );
        expect(tester.getSize(linhas.at(i)).height, DivisorOu.espessura);
      }
    });
  });
}
