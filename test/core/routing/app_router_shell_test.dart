import 'package:bora/app.dart';
import 'package:bora/core/routing/app_router.dart';
import 'package:bora/core/routing/app_shell.dart';
import 'package:bora/core/routing/festa_tabs_shell.dart';
import 'package:bora/core/routing/placeholder_page.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:flutter_test/flutter_test.dart';

const String _festaId = 'rafa18';

/// Monta o app inteiro já posicionado em [location].
Future<void> _abrir(WidgetTester tester, String location) async {
  await tester.pumpWidget(
    BoraApp(router: buildAppRouter(initialLocation: location)),
  );
  await tester.pumpAndSettle();
}

/// Afirma que a tela [id] está montada e que nenhuma das [outras] está.
void _apenas(String id, {required List<String> outras}) {
  expect(
    find.byKey(PlaceholderPage.keyFor(id)),
    findsOneWidget,
    reason: 'a rota deveria renderizar o placeholder de $id',
  );
  for (final outra in outras) {
    expect(
      find.byKey(PlaceholderPage.keyFor(outra)),
      findsNothing,
      reason: '$outra não deveria estar na tela junto de $id',
    );
  }
}

void main() {
  group('FUND-07 — as sete rotas do shell respondem', () {
    testWidgets('/roles renderiza a home', (tester) async {
      await _abrir(tester, Routes.roles);

      _apenas('home', outras: ['montar', 'lista']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('/roles/novo renderiza montar', (tester) async {
      await _abrir(tester, Routes.novoRole);

      _apenas('montar', outras: ['home', 'lista']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('/roles/:festaId/montar renderiza montar', (tester) async {
      await _abrir(tester, Routes.montar(_festaId));

      _apenas('montar', outras: ['home', 'lista']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('/roles/:festaId/lista renderiza a aba lista', (tester) async {
      await _abrir(tester, Routes.lista(_festaId));

      _apenas('lista', outras: ['galera', 'convite', 'custos', 'home']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('/roles/:festaId/galera renderiza a aba galera',
        (tester) async {
      await _abrir(tester, Routes.galera(_festaId));

      _apenas('galera', outras: ['lista', 'convite', 'custos', 'home']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('/roles/:festaId/whatsapp renderiza a aba convite',
        (tester) async {
      await _abrir(tester, Routes.whatsapp(_festaId));

      _apenas('convite', outras: ['lista', 'galera', 'custos', 'home']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('/roles/:festaId/custos renderiza a aba custos',
        (tester) async {
      await _abrir(tester, Routes.custos(_festaId));

      _apenas('custos', outras: ['lista', 'galera', 'convite', 'home']);
      expect(tester.takeException(), isNull);
    });
  });

  group('AD-003 — as quatro abas vivem sob o sub-shell da festa', () {
    testWidgets('rota de aba monta o FestaTabsShell', (tester) async {
      await _abrir(tester, Routes.lista(_festaId));

      expect(find.byType(FestaTabsShell), findsOneWidget);
    });

    testWidgets('rota fora das abas não monta o FestaTabsShell',
        (tester) async {
      await _abrir(tester, Routes.roles);

      expect(find.byType(FestaTabsShell), findsNothing);
    });
  });

  group('FUND-08 — o chrome do app envolve /roles e não envolve /c/:codigo',
      () {
    for (final location in [
      Routes.roles,
      Routes.novoRole,
      Routes.montar(_festaId),
      Routes.lista(_festaId),
      Routes.galera(_festaId),
      Routes.whatsapp(_festaId),
      Routes.custos(_festaId),
    ]) {
      testWidgets('o chrome está presente em $location', (tester) async {
        await _abrir(tester, location);

        expect(find.byKey(AppShell.chromeKey), findsOneWidget);
      });
    }

    testWidgets('o chrome está ausente em /c/rafa18', (tester) async {
      await _abrir(tester, Routes.convidado('rafa18'));

      expect(find.byKey(PlaceholderPage.keyFor('convidado')), findsOneWidget);
      expect(find.byKey(AppShell.chromeKey), findsNothing);
    });
  });
}
