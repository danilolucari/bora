import 'package:bora/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BoraApp monta sem exceção', (tester) async {
    await tester.pumpWidget(const BoraApp());

    expect(find.byType(BoraApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
