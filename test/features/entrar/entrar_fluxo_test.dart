import 'package:bora/core/autenticacao/autenticacao.dart';
import 'package:bora/core/routing/placeholder_page.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:bora/features/entrar/presentation/pages/entrar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/design_system/support/font_loading.dart';
import '../../support/app_de_teste.dart';

/// O fluxo de UC-01 ponta a ponta, dentro do roteador real.
///
/// Existe porque os testes de tela e os de rota provavam metades diferentes e
/// **nunca se encontravam**: o teste de tela afirma que a página não navega
/// sozinha (AD-020), e o de rota provocava a sessão por `mudarSessao`, pulando
/// o formulário. Nenhum dos dois provava o Independent Test que a spec
/// descreve — "preencher, tocar, e cair na Home". Era o gap nº 3 do Verifier.
void main() {
  setUpAll(carregarFontesArchivo);

  Future<void> preencher(
    WidgetTester tester, {
    String email = 'rafa@bora.app',
    String senha = 'segredo',
  }) async {
    await tester.enterText(find.byType(TextField).first, email);
    await tester.enterText(find.byType(TextField).last, senha);
  }

  group('ENT-06 — e-mail e senha levam à Home', () {
    testWidgets('preencher e tocar COMEÇAR → cai em /roles', (tester) async {
      tester.view.physicalSize = const Size(390, 820);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await abrirApp(tester, Routes.entrar);
      expect(find.byKey(EntrarPage.pageKey), findsOneWidget);

      await preencher(tester);
      await tester.tap(find.text('COMEÇAR →'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(PlaceholderPage.keyFor('home')),
        findsOneWidget,
        reason: 'UC-01: pós-login sempre cai na Home. E ninguém chamou '
            'context.go — a sessão mudou, o refreshListenable acordou e a '
            'guarda decidiu (AD-020)',
      );
      expect(find.byKey(EntrarPage.pageKey), findsNothing);
    });

    testWidgets('credencial recusada NÃO leva à Home', (tester) async {
      tester.view.physicalSize = const Size(390, 820);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final autenticacao = await abrirApp(tester, Routes.entrar);
      autenticacao.falha = FalhaDeAutenticacao.credencialInvalida;

      await preencher(tester, senha: 'errada');
      await tester.tap(find.text('COMEÇAR →'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(EntrarPage.pageKey),
        findsOneWidget,
        reason: 'par discriminante do teste acima: sem ele, uma guarda que '
            'levasse sempre para a Home passaria',
      );
      expect(find.text('E-MAIL OU SENHA INCORRETOS'), findsOneWidget);
    });
  });

  group('ENT-14 AC2 — o Google leva ao mesmo destino', () {
    testWidgets('tocar o botão do Google cai em /roles', (tester) async {
      tester.view.physicalSize = const Size(390, 820);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await abrirApp(tester, Routes.entrar);

      await tester.tap(find.text('CONTINUAR COM GOOGLE'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(PlaceholderPage.keyFor('home')),
        findsOneWidget,
        reason: 'ENT-14 AC2: o mesmo destino do e-mail/senha, porque é o mesmo '
            'mecanismo — não uma segunda linha de navegação',
      );
    });
  });

  group('ENT-20 AC3 — o cadastro leva ao mesmo destino', () {
    testWidgets('criar conta cai em /roles', (tester) async {
      tester.view.physicalSize = const Size(390, 820);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await abrirApp(tester, Routes.entrar);

      await tester.tap(find.text('CRIAR CONTA'));
      await tester.pumpAndSettle();
      await preencher(tester, email: 'novo@bora.app');
      await tester.tap(find.text('CRIAR CONTA →'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(PlaceholderPage.keyFor('home')),
        findsOneWidget,
        reason: 'os três caminhos terminam no mesmo lugar porque terminam no '
            'mesmo mecanismo',
      );
    });
  });
}
