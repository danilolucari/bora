import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/routing/route_error_page.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_de_teste.dart';

void main() {
  group('ENT-19 — a tela de erro veste os tokens do arquivo 02', () {
    testWidgets('fundo paper', (tester) async {
      await abrirApp(tester, '/rota-que-nao-existe');

      final scaffold = tester.widget<Scaffold>(
        find.descendant(
          of: find.byType(RouteErrorPage),
          matching: find.byType(Scaffold),
        ),
      );

      expect(scaffold.backgroundColor, BoraColors.paper);
    });

    testWidgets('o título usa o papel de título de tela, em Archivo Black',
        (tester) async {
      await abrirApp(tester, '/rota-que-nao-existe');

      final titulo = tester.widget<Text>(find.text(RouteErrorPage.titulo));

      expect(titulo.style?.fontFamily, BoraTextStyles.familiaDisplay);
      expect(titulo.style?.fontSize, BoraTextStyles.tituloTela.fontSize);
    });

    testWidgets('a URL tentada continua visível (FUND-09)', (tester) async {
      await abrirApp(tester, '/rota-que-nao-existe');

      expect(
        find.text('/rota-que-nao-existe'),
        findsOneWidget,
        reason: 'revestir não pode custar a informação que a fundação pôs aqui',
      );
    });
  });

  group('ENT-19 — o CTA de volta', () {
    testWidgets('leva para a raiz do app', (tester) async {
      final autenticacao = await abrirApp(
        tester,
        '/rota-que-nao-existe',
        sessao: sessaoDeTeste,
      );
      expect(autenticacao.sessaoAtual, isNotNull);

      await tester.tap(find.text(RouteErrorPage.voltar));
      await tester.pumpAndSettle();

      expect(
        find.byKey(RouteErrorPage.pageKey),
        findsNothing,
        reason: 'saiu da tela de erro — o destino final é ${Routes.roles}',
      );
    });
  });

  group('ENT-19/ENT-17 — a tela de erro abre sem sessão', () {
    testWidgets('sem sessão, a rota inexistente ainda mostra o erro',
        (tester) async {
      await abrirApp(tester, '/rota-que-nao-existe');

      expect(
        find.byKey(RouteErrorPage.pageKey),
        findsOneWidget,
        reason: 'a guarda protege por prefixo /roles: interceptar o '
            'desconhecido apagaria esta página, que é a garantia de FUND-09 '
            'de que nada cai em tela em branco',
      );
    });
  });
}
