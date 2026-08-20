import 'package:bora/app.dart';
import 'package:bora/core/routing/app_router.dart';
import 'package:bora/core/routing/placeholder_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BoraApp monta com o roteador real e cai em /roles',
      (tester) async {
    await tester.pumpWidget(BoraApp(router: buildAppRouter()));
    await tester.pumpAndSettle();

    expect(find.byType(BoraApp), findsOneWidget);
    expect(find.byKey(PlaceholderPage.keyFor('home')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
