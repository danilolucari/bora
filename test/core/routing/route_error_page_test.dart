import 'package:bora/core/routing/route_error_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FUND-09 — destino de erro legível', () {
    testWidgets('mostra a url que foi tentada', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RouteErrorPage(location: '/rota-que-nao-existe'),
        ),
      );

      expect(find.text('/rota-que-nao-existe'), findsOneWidget);
    });

    testWidgets('não fica em branco: tem chave e mensagem legível',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RouteErrorPage(location: '/c/')),
      );

      expect(find.byKey(RouteErrorPage.pageKey), findsOneWidget);
      expect(find.text('PÁGINA NÃO ENCONTRADA'), findsOneWidget);
      expect(
        find.text('Esse endereço não leva a nenhuma tela do bora.'),
        findsOneWidget,
      );
    });
  });
}
