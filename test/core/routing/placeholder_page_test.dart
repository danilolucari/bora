import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/routing/placeholder_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _montar(WidgetTester tester, {String titulo = 'HOME'}) =>
    tester.pumpWidget(
      MaterialApp(
        theme: boraTheme(),
        home: PlaceholderPage(id: 'home', titulo: titulo),
      ),
    );

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

  group('HOME-18 — o placeholder veste os tokens do arquivo 02', () {
    testWidgets('o fundo é o paper do token', (tester) async {
      await _montar(tester);

      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        BoraColors.paper,
        reason: 'afirmado pelo token, não pelo hex: comparar com o literal '
            'faria o teste concordar com qualquer cor',
      );
    });

    testWidgets('o título usa o papel de título de tela, Archivo Black',
        (tester) async {
      await _montar(tester);
      final estilo = tester.widget<Text>(find.text('HOME')).style!;

      expect(estilo, BoraTextStyles.tituloTela);
      expect(estilo.fontFamily, BoraTextStyles.familiaDisplay);
    });

    testWidgets('o título sai como veio, sem mexer na caixa', (tester) async {
      await _montar(tester, titulo: 'CONVIDADO · rafa18');

      expect(
        find.text('CONVIDADO · rafa18'),
        findsOneWidget,
        reason: 'a caixa alta de §7 é da copy, e a tabela de rotas já a passa '
            'assim; o título do convidado interpola o código do convite, que '
            'é dado de URL (RN-24) — maiusculizar aqui viraria RAFA18',
      );
      expect(find.text('CONVIDADO · RAFA18'), findsNothing);
    });

    testWidgets('o id fica no papel de dica, abaixo do título',
        (tester) async {
      await _montar(tester);

      expect(tester.widget<Text>(find.text('home')).style, BoraTextStyles.dica);
      expect(
        tester.getTopLeft(find.text('home')).dy,
        greaterThan(tester.getTopLeft(find.text('HOME')).dy),
      );
    });

    testWidgets('a chave continua sendo a que as rotas afirmam',
        (tester) async {
      await _montar(tester);

      expect(
        find.byKey(PlaceholderPage.keyFor('home')),
        findsOneWidget,
        reason: 'os testes de FUND-07 identificam a tela por ela; revestir '
            'não pode trocar a chave',
      );
    });
  });
}
