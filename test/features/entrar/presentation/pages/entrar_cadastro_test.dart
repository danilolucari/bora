import 'package:bora/core/autenticacao/autenticacao.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/entrar/presentation/pages/entrar_page.dart';
import 'package:bora/features/entrar/presentation/widgets/formulario_de_entrada.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';
import '../../../../support/fake_autenticacao_repository.dart';

const Size _compacto = Size(390, 820);
const Size _expandido = Size(1180, 800);

void main() {
  late FakeAutenticacaoRepository autenticacao;

  setUpAll(carregarFontesArchivo);
  setUp(() => autenticacao = FakeAutenticacaoRepository());
  tearDown(() => autenticacao.dispose());

  Future<void> abrir(WidgetTester tester, {Size tamanho = _compacto}) async {
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: boraTheme(),
        home: EntrarPage(autenticacao: autenticacao),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> alternarParaCadastro(WidgetTester tester) async {
    await tester.tap(find.text('CRIAR CONTA'));
    await tester.pumpAndSettle();
  }

  group('ENT-20 — CRIAR CONTA alterna a própria tela', () {
    testWidgets('o modo cadastro troca CTA e rodapé', (tester) async {
      await abrir(tester);
      expect(find.text('COMEÇAR →'), findsOneWidget);

      await alternarParaCadastro(tester);

      expect(find.text('CRIAR CONTA →'), findsOneWidget);
      expect(find.text('Já tem conta? '), findsOneWidget);
      expect(find.text('ENTRAR'), findsOneWidget);
      expect(
        find.text('COMEÇAR →'),
        findsNothing,
        reason: 'o par presente/ausente é o que discrimina a alternância',
      );
    });

    testWidgets('a tela continua sendo a mesma — não houve rota nova',
        (tester) async {
      await abrir(tester);

      await alternarParaCadastro(tester);

      expect(
        find.byKey(EntrarPage.pageKey),
        findsOneWidget,
        reason: 'A-04: modo alternado na mesma tela, sem acrescentar nó ao '
            'mapa canônico da AD-003',
      );
    });

    testWidgets('no web o label do card também vira CRIAR CONTA',
        (tester) async {
      await abrir(tester, tamanho: _expandido);
      expect(find.text('ENTRAR'), findsOneWidget);

      await tester.tap(find.text('CRIAR CONTA'));
      await tester.pumpAndSettle();

      // No modo cadastro, "CRIAR CONTA" aparece no label do card e no CTA;
      // "ENTRAR" migra para o rodapé.
      expect(find.text('CRIAR CONTA'), findsOneWidget);
      expect(find.text('CRIAR CONTA →'), findsOneWidget);
      expect(find.text('Já tem conta? '), findsOneWidget);
    });

    testWidgets('voltar para entrar restaura a copy original', (tester) async {
      await abrir(tester);
      await alternarParaCadastro(tester);

      await tester.tap(find.text('ENTRAR'));
      await tester.pumpAndSettle();

      expect(find.text('COMEÇAR →'), findsOneWidget);
      expect(find.text('Novo por aqui? '), findsOneWidget);
    });
  });

  group('ENT-13 — a alternância preserva o e-mail e limpa o erro', () {
    testWidgets('o e-mail digitado sobrevive à troca de modo', (tester) async {
      await abrir(tester);
      await tester.enterText(find.byType(TextField).first, 'rafa@bora.app');

      await alternarParaCadastro(tester);

      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller?.text,
        'rafa@bora.app',
        reason: 'os controladores vivem na página, acima do modo — trocar de '
            'modo não recria os campos',
      );
    });

    testWidgets('a falha do modo anterior some ao alternar', (tester) async {
      autenticacao.falha = FalhaDeAutenticacao.credencialInvalida;
      await abrir(tester);

      await tester.enterText(find.byType(TextField).first, 'rafa@bora.app');
      await tester.enterText(find.byType(TextField).last, 'segredo');
      await tester.tap(find.text('COMEÇAR →'));
      await tester.pumpAndSettle();
      expect(find.byKey(FormularioDeEntrada.mensagemDeFalhaKey), findsOneWidget);

      await alternarParaCadastro(tester);

      expect(
        find.byKey(FormularioDeEntrada.mensagemDeFalhaKey),
        findsNothing,
        reason: 'carregar para o cadastro um erro que aconteceu no modo entrar '
            'acusaria o usuário de algo que ele não fez ali',
      );
    });

    testWidgets('os erros de validação também somem', (tester) async {
      await abrir(tester);

      await tester.tap(find.text('COMEÇAR →'));
      await tester.pumpAndSettle();
      expect(find.text('INFORME SEU E-MAIL'), findsOneWidget);

      await alternarParaCadastro(tester);

      expect(find.text('INFORME SEU E-MAIL'), findsNothing);
    });
  });

  group('ENT-20 — o cadastro chama o método certo', () {
    testWidgets('submeter no modo cadastro chama criarConta', (tester) async {
      await abrir(tester);
      await alternarParaCadastro(tester);

      await tester.enterText(find.byType(TextField).first, 'novo@bora.app');
      await tester.enterText(find.byType(TextField).last, 'segredo');
      await tester.tap(find.text('CRIAR CONTA →'));
      await tester.pumpAndSettle();

      expect(
        autenticacao.chamadas,
        ['criarConta'],
        reason: 'e não entrarComEmailESenha — o modo decide o método',
      );
      expect(autenticacao.sessaoAtual, isNotNull);
    });

    testWidgets('e-mail em uso mostra mensagem e mantém o modo cadastro',
        (tester) async {
      autenticacao.falha = FalhaDeAutenticacao.emailEmUso;
      await abrir(tester);
      await alternarParaCadastro(tester);

      await tester.enterText(find.byType(TextField).first, 'rafa@bora.app');
      await tester.enterText(find.byType(TextField).last, 'segredo');
      await tester.tap(find.text('CRIAR CONTA →'));
      await tester.pumpAndSettle();

      expect(find.text('JÁ EXISTE CONTA COM ESSE E-MAIL'), findsOneWidget);
      expect(
        find.text('CRIAR CONTA →'),
        findsOneWidget,
        reason: 'ENT-20 AC4: jogar o usuário de volta para o modo entrar '
            'esconderia o que ele estava tentando fazer',
      );
    });
  });
}
