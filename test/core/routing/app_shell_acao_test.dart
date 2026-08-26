import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/responsive/layout_mode.dart';
import 'package:bora/core/routing/app_shell.dart';
import 'package:bora/core/routing/placeholder_page.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_de_teste.dart';
import '../design_system/support/font_loading.dart';

/// Um pouco acima e um pouco abaixo da fronteira de AD-007.
const Size _janelaExpandida = Size(1180, 800);
const Size _janelaCompacta = Size(390, 820);

const String _festaId = 'rafa18';

Future<void> _abrir(
  WidgetTester tester,
  String location, {
  required Size janela,
}) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);
  await abrirApp(tester, location, sessao: sessaoDeTeste);
}

Finder get _acao => find.text(AppShell.rotuloDeNovoRole);

void main() {
  setUpAll(carregarFontesArchivo);

  group('HOME-02 — "+ NOVO ROLÊ" é a ação da Home no web', () {
    testWidgets('na Home em expandido, o header mostra a ação',
        (tester) async {
      await _abrir(tester, Routes.roles, janela: _janelaExpandida);

      expect(_acao, findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(AppShell.headerKey),
          matching: _acao,
        ),
        findsOneWidget,
        reason: '`06`: a ação é do header, não do corpo da tela',
      );
    });

    testWidgets('o toque leva a /roles/novo', (tester) async {
      await _abrir(tester, Routes.roles, janela: _janelaExpandida);

      await tester.tap(_acao);
      await tester.pumpAndSettle();

      expect(
        rotaAtual(),
        Routes.novoRole,
        reason: 'A-06: "+ NOVO ROLÊ" e o card CHURRASCO têm o mesmo destino. '
            'A URL é o que discrimina — `/roles/novo` e '
            '`/roles/:festaId/montar` renderizam a mesma MontarPage, então a '
            'chave da tela deixaria passar o destino errado',
      );
      expect(find.byKey(PlaceholderPage.keyFor('montar')), findsOneWidget);
    });

    testWidgets('em compacto não há ação nem barra (A-07)', (tester) async {
      await _abrir(tester, Routes.roles, janela: _janelaCompacta);

      expect(
        _acao,
        findsNothing,
        reason: 'T-02 não desenha barra de app nenhuma; a entrada para criar '
            'rolê no mobile é o card "🔥 CHURRASCO"',
      );
      expect(
        find.byKey(AppShell.headerKey),
        findsNothing,
        reason: 'P1-1 AC1 escopa a barra em viewport expandida',
      );
    });

    testWidgets('em rota logada que não é a Home, a ação não existe',
        (tester) async {
      await _abrir(tester, Routes.lista(_festaId), janela: _janelaExpandida);

      expect(
        _acao,
        findsNothing,
        reason: 'é o par que discrimina "contextual": uma ação fixa passaria '
            'no teste da Home',
      );
      expect(find.byKey(AppShell.headerKey), findsOneWidget);
    });
  });

  group('HOME-01 AC4 — a Home é a raiz: nenhum voltar no header', () {
    testWidgets('sem botão voltar na barra da Home', (tester) async {
      await _abrir(tester, Routes.roles, janela: _janelaExpandida);

      expect(
        find.descendant(
          of: find.byKey(AppShell.headerKey),
          matching: find.byType(BackButton),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byKey(AppShell.headerKey),
          matching: find.byIcon(Icons.arrow_back),
        ),
        findsNothing,
      );
    });
  });

  group('HOME-01 — a sessão do roteador chega ao avatar', () {
    testWidgets('a inicial do avatar é a do usuário logado', (tester) async {
      await _abrir(tester, Routes.roles, janela: _janelaExpandida);

      expect(
        find.descendant(
          of: find.byKey(AppShell.headerKey),
          matching: find.text(sessaoDeTeste.inicial),
        ),
        findsOneWidget,
        reason: 'E-3: sem o roteador passar a sessão, o header montaria sem '
            'avatar e ninguém notaria',
      );
      expect(find.byType(BoraAvatar), findsOneWidget);
    });
  });

  group('a fronteira de AD-007 decide, e é a mesma do resto do app', () {
    testWidgets('em 900px a ação já aparece', (tester) async {
      await _abrir(
        tester,
        Routes.roles,
        janela: const Size(kCompactBreakpoint, 800),
      );

      expect(
        _acao,
        findsOneWidget,
        reason: 'W-R3 é inclusivo à direita: 900.0 já é expandido',
      );
    });

    testWidgets('um pixel abaixo de 900px ela some', (tester) async {
      await _abrir(
        tester,
        Routes.roles,
        janela: const Size(kCompactBreakpoint - 1, 800),
      );

      expect(_acao, findsNothing);
    });
  });
}
