import 'package:bora/app.dart';
import 'package:bora/core/design_system/tokens/bora_colors.dart';
import 'package:bora/core/design_system/tokens/bora_text_styles.dart';
import 'package:bora/core/routing/placeholder_page.dart';
import 'package:bora/features/entrar/presentation/pages/entrar_page.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/app_de_teste.dart';

/// Monta o app inteiro **com sessão** e devolve o tema como uma tela o enxerga.
///
/// A diferença para o teste de `boraTheme()` da spec 01 é o alvo: lá se prova
/// que a função devolve os tokens, aqui que eles chegam à árvore. Um `theme:`
/// esquecido passaria naquele teste e falha neste.
Future<ThemeData> _temaDaTelaMontada(WidgetTester tester) async {
  await abrirApp(tester, Routes.roles, sessao: sessaoDeTeste);

  return Theme.of(tester.element(find.byKey(PlaceholderPage.keyFor('home'))));
}

void main() {
  group('ENT-15/ENT-16 — a sessão decide onde o app abre (E-4)', () {
    testWidgets('com sessão, o app cai na Home', (tester) async {
      await abrirApp(tester, Routes.roles, sessao: sessaoDeTeste);

      expect(find.byType(BoraApp), findsOneWidget);
      expect(find.byKey(PlaceholderPage.keyFor('home')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sem sessão, a mesma rota cai em /entrar', (tester) async {
      await abrirApp(tester, Routes.roles);

      expect(
        find.byKey(EntrarPage.pageKey),
        findsOneWidget,
        reason: 'o par com/sem sessão é o que discrimina a guarda: um teste '
            'que só afirmasse a Home passaria com a guarda desligada',
      );
      expect(find.byKey(PlaceholderPage.keyFor('home')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a sessão terminando leva de volta a /entrar (ENT-18)',
        (tester) async {
      final autenticacao =
          await abrirApp(tester, Routes.roles, sessao: sessaoDeTeste);
      expect(find.byKey(PlaceholderPage.keyFor('home')), findsOneWidget);

      autenticacao.mudarSessao(null);
      await tester.pumpAndSettle();

      expect(
        find.byKey(EntrarPage.pageKey),
        findsOneWidget,
        reason: 'o refreshListenable reavalia a guarda sem ninguém chamar '
            'context.go — é a AD-020 funcionando',
      );
    });

    testWidgets('a sessão começando leva de /entrar para a Home (ENT-16)',
        (tester) async {
      final autenticacao = await abrirApp(tester, Routes.entrar);
      expect(find.byKey(EntrarPage.pageKey), findsOneWidget);

      autenticacao.mudarSessao(sessaoDeTeste);
      await tester.pumpAndSettle();

      expect(
        find.byKey(PlaceholderPage.keyFor('home')),
        findsOneWidget,
        reason: 'UC-01: pós-login sempre cai na Home — sem nenhuma feature '
            'navegar (AD-020)',
      );
    });
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
      expect(
        tema.textTheme.titleLarge?.fontFamily,
        BoraTextStyles.familiaDisplay,
      );
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
      await abrirApp(tester, Routes.entrar);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(app.title, 'bora — a conta do rolê');
    });
  });
}
