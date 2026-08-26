import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/routing/route_error_page.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:bora/features/home/presentation/pages/home_page.dart';
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

      final titulo = tester.widget<Text>(find.text('PÁGINA NÃO ENCONTRADA'));

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

      // Literal, e não `RouteErrorPage.voltar`: a regra do tasks.md diz que
      // copy da spec se afirma contra o literal escrito no teste — comparar
      // com a constante faria o teste concordar com qualquer copy.
      await tester.tap(find.text('VOLTAR PRO INÍCIO'));
      await tester.pumpAndSettle();

      // O DESTINO, não só "saiu daqui": trocar /roles por /catalogo sobrevivia
      // à asserção anterior (gap nº 4 do Verifier).
      expect(
        find.byKey(HomePage.pageKey),
        findsOneWidget,
        reason: 'ENT-19 AC2: o CTA leva à raiz do app logado, ${Routes.roles}',
      );
      expect(find.byKey(RouteErrorPage.pageKey), findsNothing);
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
