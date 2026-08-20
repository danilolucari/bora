import 'package:bora/app.dart';
import 'package:bora/core/routing/app_router.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BoraApp monta sem exceção', (tester) async {
    await tester
        .pumpWidget(BoraApp(router: buildAppRouter(initialLocation: Routes.entrar)));

    expect(find.byType(BoraApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
