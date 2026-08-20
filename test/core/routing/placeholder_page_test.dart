import 'package:bora/core/routing/placeholder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FUND-07 — destino identificável de cada rota', () {
    testWidgets('mostra o título e o id da tela', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PlaceholderPage(id: 'home', titulo: 'HOME')),
      );

      expect(find.text('HOME'), findsOneWidget);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('a chave diz qual placeholder está na tela', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PlaceholderPage(id: 'home', titulo: 'HOME')),
      );

      expect(find.byKey(PlaceholderPage.keyFor('home')), findsOneWidget);
      expect(find.byKey(PlaceholderPage.keyFor('galera')), findsNothing);
    });
  });
}
