import 'package:bora/app.dart';
import 'package:bora/core/design_system/catalog/catalog_page.dart';
import 'package:bora/core/routing/app_router.dart';
import 'package:bora/core/routing/app_shell.dart';
import 'package:bora/core/routing/route_error_page.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta o app inteiro já posicionado em [location].
Future<void> _abrir(WidgetTester tester, String location) async {
  await tester.pumpWidget(
    BoraApp(router: buildAppRouter(initialLocation: location)),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('DS-33 — /catalogo é rota alcançável com destino afirmado', () {
    testWidgets('/catalogo renderiza a página do catálogo', (tester) async {
      await _abrir(tester, Routes.catalogo);

      expect(find.byKey(CatalogPage.pageKey), findsOneWidget);
      expect(find.byType(CatalogPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('/catalogo fica fora de qualquer shell e não cai no erro',
        (tester) async {
      await _abrir(tester, Routes.catalogo);

      expect(
        find.byKey(AppShell.chromeKey),
        findsNothing,
        reason: 'o catálogo não é tela de produto: fica fora do chrome do app',
      );
      expect(find.byKey(RouteErrorPage.pageKey), findsNothing);
    });

    testWidgets('a url do catálogo é a que a rota registra', (tester) async {
      expect(Routes.catalogo, '/catalogo');

      await _abrir(tester, '/catalogo');

      expect(find.byKey(CatalogPage.pageKey), findsOneWidget);
    });

    testWidgets('a rota nova não muda as existentes: /roles segue no shell',
        (tester) async {
      await _abrir(tester, Routes.roles);

      expect(find.byKey(AppShell.chromeKey), findsOneWidget);
      expect(find.byKey(CatalogPage.pageKey), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
