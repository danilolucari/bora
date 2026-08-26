import 'package:bora/core/routing/placeholder_page.dart';
import 'package:bora/core/routing/route_error_page.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_de_teste.dart';

/// Monta o app **sem sessão** — o estado em que estas rotas públicas vivem.
Future<void> _abrir(WidgetTester tester, String location) =>
    abrirApp(tester, location);

void main() {
  group('FUND-07 — cada rota pública tem destino identificável', () {
    testWidgets('/entrar renderiza o placeholder de entrar', (tester) async {
      await _abrir(tester, Routes.entrar);

      expect(find.byKey(PlaceholderPage.keyFor('entrar')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('FUND-08 — o convidado entra sem conta e sem o shell do app', () {
    testWidgets('/c/rafa18 renderiza o placeholder do convidado com o código',
        (tester) async {
      await _abrir(tester, Routes.convidado('rafa18'));

      expect(find.byKey(PlaceholderPage.keyFor('convidado')), findsOneWidget);
      expect(find.text('CONVIDADO · rafa18'), findsOneWidget);
    });

    testWidgets('/c/rafa18 não desvia para a tela de entrar', (tester) async {
      await _abrir(tester, Routes.convidado('rafa18'));

      expect(find.byKey(PlaceholderPage.keyFor('entrar')), findsNothing);
      expect(find.byKey(RouteErrorPage.pageKey), findsNothing);
    });
  });

  group('FUND-09 — nada cai em tela em branco', () {
    testWidgets('rota inexistente cai no erro mostrando a url tentada',
        (tester) async {
      await _abrir(tester, '/rota-que-nao-existe');

      expect(find.byKey(RouteErrorPage.pageKey), findsOneWidget);
      expect(find.text('/rota-que-nao-existe'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('/c/ sem código cai no erro', (tester) async {
      await _abrir(tester, '/c/');

      expect(find.byKey(RouteErrorPage.pageKey), findsOneWidget);
      expect(find.byKey(PlaceholderPage.keyFor('convidado')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('/c/@@@ com código malformado cai no erro', (tester) async {
      await _abrir(tester, '/c/@@@');

      expect(find.byKey(RouteErrorPage.pageKey), findsOneWidget);
      expect(find.byKey(PlaceholderPage.keyFor('convidado')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('FUND-10 — título da aba no navegador', () {
    testWidgets('o MaterialApp usa o título literal de W-R5', (tester) async {
      await _abrir(tester, Routes.entrar);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

      expect(app.title, 'bora — a conta do rolê');
    });
  });
}
