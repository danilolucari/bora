import 'package:bora/app.dart';
import 'package:bora/core/design_system/tokens/bora_colors.dart';
import 'package:bora/core/design_system/tokens/bora_text_styles.dart';
import 'package:bora/core/routing/app_router.dart';
import 'package:bora/core/routing/placeholder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta o app inteiro e devolve o tema **como uma tela montada o enxerga**.
///
/// A diferença para o teste de `boraTheme()` da spec 01 é o alvo: lá se prova
/// que a função devolve os tokens, aqui que eles chegam à árvore. Um `theme:`
/// esquecido passaria naquele teste e falha neste.
Future<ThemeData> _temaDaTelaMontada(WidgetTester tester) async {
  await tester.pumpWidget(BoraApp(router: buildAppRouter()));
  await tester.pumpAndSettle();

  return Theme.of(tester.element(find.byKey(PlaceholderPage.keyFor('home'))));
}

void main() {
  testWidgets('BoraApp monta com o roteador real e cai em /roles',
      (tester) async {
    await tester.pumpWidget(BoraApp(router: buildAppRouter()));
    await tester.pumpAndSettle();

    expect(find.byType(BoraApp), findsOneWidget);
    expect(find.byKey(PlaceholderPage.keyFor('home')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('ENT-01 — o app veste os tokens do design system', () {
    testWidgets('a tela montada recebe o fundo paper do tema', (tester) async {
      final tema = await _temaDaTelaMontada(tester);

      expect(tema.scaffoldBackgroundColor, BoraColors.paper);
    });

    testWidgets('a tela montada recebe Archivo, e não a Roboto do Material',
        (tester) async {
      final tema = await _temaDaTelaMontada(tester);

      expect(tema.textTheme.bodyLarge?.fontFamily, BoraTextStyles.familiaUi);
      expect(tema.textTheme.titleLarge?.fontFamily,
          BoraTextStyles.familiaDisplay);
    });

    testWidgets('a tela montada recebe o colorScheme dos tokens',
        (tester) async {
      final tema = await _temaDaTelaMontada(tester);

      expect(tema.colorScheme.primary, BoraColors.primary);
      expect(tema.colorScheme.onPrimary, BoraColors.cream);
      expect(tema.colorScheme.surface, BoraColors.white);
      expect(tema.colorScheme.onSurface, BoraColors.ink);
    });
  });

  group('ENT-02 — o tema não custa a regressão do título', () {
    testWidgets('o MaterialApp recebe o título literal de W-R5',
        (tester) async {
      await tester.pumpWidget(BoraApp(router: buildAppRouter()));
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(app.title, 'bora — a conta do rolê');
    });
  });
}
