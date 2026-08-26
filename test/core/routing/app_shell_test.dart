import 'package:bora/core/autenticacao/autenticacao.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/routing/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../design_system/support/font_loading.dart';

const UsuarioLogado _rafa = UsuarioLogado(
  id: 'uid-rafa',
  email: 'rafa@bora.app',
  nome: 'Rafa',
);

const UsuarioLogado _ana = UsuarioLogado(
  id: 'uid-ana',
  email: 'ana@bora.app',
  nome: 'Ana',
);

/// Conta de e-mail/senha: o Firebase não dá `displayName`, e a inicial cai no
/// e-mail (AD-019).
const UsuarioLogado _semNome = UsuarioLogado(
  id: 'uid-bia',
  email: 'bia@bora.app',
);

Future<void> _montar(WidgetTester tester, {UsuarioLogado? usuario}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        body: AppShell(
          usuario: usuario,
          child: const Text('conteúdo da rota'),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

BoxDecoration _decoracaoDoHeader(WidgetTester tester) =>
    tester.widget<Container>(find.byKey(AppShell.headerKey)).decoration!
        as BoxDecoration;

/// A decoração do círculo do avatar de conta.
BoxDecoration _circuloDoAvatar(WidgetTester tester, String inicial) =>
    tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.text(inicial),
            matching: find.byType(DecoratedBox),
          )
          .first,
    ).decoration as BoxDecoration;

void main() {
  setUpAll(carregarFontesArchivo);

  group('FUND-08 — o envelope continua sendo o que marca a rota logada', () {
    testWidgets('o chrome está presente e envolve o conteúdo da rota',
        (tester) async {
      await _montar(tester, usuario: _rafa);

      expect(find.byKey(AppShell.chromeKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(AppShell.chromeKey),
          matching: find.text('conteúdo da rota'),
        ),
        findsOneWidget,
        reason: 'revestir o shell não pode tirar a rota de dentro dele — os '
            'testes de FUND-07/08 dependem disso',
      );
    });
  });

  group('HOME-01 — a barra do header de `06`', () {
    testWidgets('fundo paper e borda inferior de 2px ink', (tester) async {
      await _montar(tester, usuario: _rafa);
      final decoracao = _decoracaoDoHeader(tester);

      expect(
        decoracao.color,
        BoraColors.paper,
        reason: '`06`: "fundo paper" — afirmado pelo token, não pelo hex',
      );

      final borda = decoracao.border! as Border;
      expect(borda.bottom.width, 2, reason: '`06`: "border-bottom 2px ink"');
      expect(borda.bottom.color, BoraColors.ink);
      expect(
        borda.top,
        BorderSide.none,
        reason: '`06` põe borda só embaixo — uma borda em volta seria outra '
            'coisa',
      );
    });

    testWidgets('o padding de 13x36 chega à árvore, não só à constante',
        (tester) async {
      await _montar(tester, usuario: _rafa);

      final barra = tester.getRect(find.byKey(AppShell.headerKey));
      final logo = tester.getRect(find.byType(BoraMarca));
      final avatar = tester.getRect(find.byType(BoraAvatar));

      expect(logo.left - barra.left, 36, reason: '`06`: padding lateral 36px');
      expect(barra.right - avatar.right, 36);
      expect(
        avatar.top - barra.top,
        13,
        reason: '`06`: padding vertical 13px — medido no avatar, que é o '
            'elemento de altura fixa da barra',
      );
      expect(barra.bottom - avatar.bottom, 13 + 2, reason: 'mais a borda');
    });

    testWidgets('a barra fica no topo, acima do conteúdo da rota',
        (tester) async {
      await _montar(tester, usuario: _rafa);

      expect(
        tester.getBottomLeft(find.byKey(AppShell.headerKey)).dy,
        lessThanOrEqualTo(tester.getTopLeft(find.text('conteúdo da rota')).dy),
        reason: 'a barra é sticky por viver fora do que rola: se estivesse '
            'dentro do conteúdo, sairia da tela ao rolar',
      );
    });

    testWidgets('o logo BORA. de 20px abre a barra', (tester) async {
      await _montar(tester, usuario: _rafa);

      final logo = find.descendant(
        of: find.byKey(AppShell.headerKey),
        matching: find.byType(BoraMarca),
      );

      expect(logo, findsOneWidget);
      expect(
        tester.widget<Text>(
          find.descendant(of: logo, matching: find.byType(Text)),
        ).style!.fontSize,
        BoraMarca.tamanhoHeader,
      );
    });

    testWidgets('o logo vem antes do avatar, com o spacer entre os dois',
        (tester) async {
      await _montar(tester, usuario: _rafa);

      expect(
        tester.getTopRight(find.byType(BoraMarca)).dx,
        lessThan(tester.getTopLeft(find.byType(BoraAvatar)).dx),
        reason: '`06`: "logo BORA. · spacer · … · avatar do usuário"',
      );
    });
  });

  group('HOME-01 AC2 — o avatar é o do usuário logado', () {
    testWidgets('36px, amarelo, borda 2px e a inicial em ink', (tester) async {
      await _montar(tester, usuario: _rafa);

      expect(find.text('R'), findsOneWidget);
      expect(
        tester.getSize(find.byType(BoraAvatar)),
        const Size(AppShell.tamanhoDoAvatar, AppShell.tamanhoDoAvatar),
        reason: '`06`: "avatar do usuário 36px"',
      );

      final circulo = _circuloDoAvatar(tester, 'R');
      expect(
        circulo.color,
        BoraColors.yellow,
        reason: 'A-08: o avatar de conta é sempre o amarelo do token',
      );
      expect(circulo.border!.top.width, 2, reason: '`06`: "borda 2px"');
    });

    testWidgets('a inicial vem do usuário, não de uma letra fixa',
        (tester) async {
      await _montar(tester, usuario: _ana);

      expect(
        find.text('A'),
        findsOneWidget,
        reason: 'é o par que discrimina: um avatar com a letra escrita à mão '
            'passaria no teste do Rafa',
      );
      expect(find.text('R'), findsNothing);
    });

    testWidgets('sem nome, a inicial cai no e-mail (AD-019)', (tester) async {
      await _montar(tester, usuario: _semNome);

      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('o avatar não fica amarelo por acaso do nome', (tester) async {
      await _montar(tester, usuario: _rafa);

      expect(
        BoraColors.avatarPairFor('R').fundo,
        isNot(BoraColors.yellow),
        reason: 'se o par de §1 para esta inicial já fosse amarelo, o teste de '
            'cima passaria com o override ignorado',
      );
    });

    testWidgets('sem sessão, o avatar não é desenhado', (tester) async {
      await _montar(tester);

      expect(
        find.byType(BoraAvatar),
        findsNothing,
        reason: 'inicial inventada é pior que avatar nenhum — e fora de '
            '/roles a guarda de AD-017 não deixa chegar sem sessão',
      );
      expect(find.byType(BoraMarca), findsOneWidget);
    });
  });
}
