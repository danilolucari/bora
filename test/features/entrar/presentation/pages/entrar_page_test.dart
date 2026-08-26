import 'dart:async';

import 'package:bora/core/autenticacao/autenticacao.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/entrar/presentation/pages/entrar_page.dart';
import 'package:bora/features/entrar/presentation/widgets/formulario_de_entrada.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';
import '../../../../support/fake_autenticacao_repository.dart';

/// Viewport compacto (T-01) — o frame de 390×820 do arquivo 02.
const Size _compacto = Size(390, 820);

/// Viewport expandido (W-01) — a janela de referência do arquivo 06.
const Size _expandido = Size(1180, 800);

void main() {
  late FakeAutenticacaoRepository autenticacao;

  // A tela inteira mede texto: sem Archivo carregada, `flutter test` usa uma
  // fonte de fallback com glifo de largura fixa, muito mais larga, e o layout
  // estoura por artefato de ambiente — não por defeito.
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

  group('ENT-03 — T-01 renderiza a copy literal da spec', () {
    testWidgets('a marca, a tag e a apresentação', (tester) async {
      await abrir(tester);

      expect(find.text('A CONTA DO ROLÊ, RESOLVIDA'), findsOneWidget);
      expect(
        find.text(
          'Monta o churras, chama a galera e racha a conta. '
          'Sem planilha, sem treta.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('os dois campos, o CTA, o divisor e o Google', (tester) async {
      await abrir(tester);

      expect(find.text('seu e-mail'), findsOneWidget);
      expect(find.text('senha'), findsOneWidget);
      expect(find.text('COMEÇAR →'), findsOneWidget);
      expect(find.text('OU'), findsOneWidget);
      expect(
        find.text('CONTINUAR COM GOOGLE'),
        findsOneWidget,
        reason: 'A-05: no mobile a copy é esta; no web é outra, e as duas são '
            'literais da spec',
      );
    });

    testWidgets('o rodapé de criar conta', (tester) async {
      await abrir(tester);

      expect(find.text('Novo por aqui? '), findsOneWidget);
      expect(find.text('CRIAR CONTA'), findsOneWidget);
    });

    testWidgets('a tag usa a inclinação de −2° do token', (tester) async {
      await abrir(tester);

      final tag = tester.widget<BoraRotatedTag>(find.byType(BoraRotatedTag));

      expect(tag.aEsquerda, isTrue);
      expect(tag.anguloEmRadianos, BoraRotatedTag.radianosDe(-2));
    });
  });

  group('ENT-21 — o campo de senha esconde o que foi digitado', () {
    testWidgets('senha obscurecida, e-mail não', (tester) async {
      await abrir(tester);

      final campos =
          tester.widgetList<BoraTextField>(find.byType(BoraTextField)).toList();

      expect(campos, hasLength(2));
      expect(campos[0].obscureText, isFalse, reason: 'o e-mail é legível');
      expect(campos[1].obscureText, isTrue);
    });
  });

  group('ENT-06 — submeter aciona o repositório', () {
    testWidgets('credenciais válidas chamam entrarComEmailESenha',
        (tester) async {
      await abrir(tester);

      await tester.enterText(find.byType(TextField).first, 'rafa@bora.app');
      await tester.enterText(find.byType(TextField).last, 'segredo');
      await tester.tap(find.text('COMEÇAR →'));
      await tester.pumpAndSettle();

      expect(autenticacao.chamadas, ['entrarComEmailESenha']);
    });

    testWidgets('o botão do Google chama entrarComGoogle', (tester) async {
      await abrir(tester);

      await tester.tap(find.text('CONTINUAR COM GOOGLE'));
      await tester.pumpAndSettle();

      expect(autenticacao.chamadas, ['entrarComGoogle']);
    });

    testWidgets('a tela não navega — quem leva é a guarda', (tester) async {
      await abrir(tester);

      await tester.enterText(find.byType(TextField).first, 'rafa@bora.app');
      await tester.enterText(find.byType(TextField).last, 'segredo');
      await tester.tap(find.text('COMEÇAR →'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(EntrarPage.pageKey),
        findsOneWidget,
        reason: 'AD-020: montada sozinha, sem roteador, a tela permanece — o '
            'sucesso vive no stream de sessão. Se ela navegasse, este teste '
            'estouraria por falta de rota',
      );
      expect(autenticacao.sessaoAtual, isNotNull);
    });
  });

  group('ENT-08 — validação inline barra antes do repositório', () {
    testWidgets('e-mail inválido mostra mensagem e não chama o repositório',
        (tester) async {
      await abrir(tester);

      await tester.enterText(find.byType(TextField).first, 'rafa');
      await tester.enterText(find.byType(TextField).last, 'segredo');
      await tester.tap(find.text('COMEÇAR →'));
      await tester.pumpAndSettle();

      expect(find.text('E-MAIL INVÁLIDO'), findsOneWidget);
      expect(autenticacao.chamadas, isEmpty);
    });

    testWidgets('senha curta mostra o mínimo', (tester) async {
      await abrir(tester);

      await tester.enterText(find.byType(TextField).first, 'rafa@bora.app');
      await tester.enterText(find.byType(TextField).last, '12345');
      await tester.tap(find.text('COMEÇAR →'));
      await tester.pumpAndSettle();

      expect(find.text('MÍNIMO DE 6 CARACTERES'), findsOneWidget);
      expect(autenticacao.chamadas, isEmpty);
    });
  });

  group('ENT-09/ENT-11 — a falha aparece e a tela continua utilizável', () {
    Future<void> tentarComFalha(
      WidgetTester tester,
      FalhaDeAutenticacao falha,
    ) async {
      autenticacao.falha = falha;
      await abrir(tester);

      await tester.enterText(find.byType(TextField).first, 'rafa@bora.app');
      await tester.enterText(find.byType(TextField).last, 'segredo');
      await tester.tap(find.text('COMEÇAR →'));
      await tester.pumpAndSettle();
    }

    testWidgets('credencial recusada mostra a mensagem de A-06 e preserva o '
        'e-mail', (tester) async {
      await tentarComFalha(tester, FalhaDeAutenticacao.credencialInvalida);

      expect(find.text('E-MAIL OU SENHA INCORRETOS'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller?.text,
        'rafa@bora.app',
        reason: 'ENT-09: perder o e-mail digitado obrigaria a redigitar tudo',
      );
    });

    testWidgets('o CTA volta a funcionar depois da falha', (tester) async {
      await tentarComFalha(tester, FalhaDeAutenticacao.credencialInvalida);

      expect(
        tester
            .widget<BoraPrimaryButton>(find.byType(BoraPrimaryButton))
            .onPressed,
        isNotNull,
        reason: 'ENT-09: o CTA volta ao ocioso para o usuário tentar de novo',
      );
    });

    testWidgets('sem rede mostra falha e a tela não estoura', (tester) async {
      await tentarComFalha(tester, FalhaDeAutenticacao.semRede);

      expect(find.byKey(FormularioDeEntrada.mensagemDeFalhaKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Firebase indisponível degrada, não trava (AD-004)',
        (tester) async {
      await tentarComFalha(tester, FalhaDeAutenticacao.indisponivel);

      expect(find.text('NÃO DEU PRA ENTRAR AGORA'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('cancelar o Google não mostra erro nenhum', (tester) async {
      autenticacao.falha = FalhaDeAutenticacao.cancelada;
      await abrir(tester);

      await tester.tap(find.text('CONTINUAR COM GOOGLE'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(FormularioDeEntrada.mensagemDeFalhaKey),
        findsNothing,
        reason: 'ENT-14 AC3: quem fechou o popup sabe que fechou — o par com '
            'os testes acima é o que discrimina',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('sem falha, nenhuma mensagem aparece', (tester) async {
      await abrir(tester);

      expect(
        find.byKey(FormularioDeEntrada.mensagemDeFalhaKey),
        findsNothing,
        reason: 'par discriminante: uma mensagem sempre presente faria os '
            'testes de falha acima passarem à toa',
      );
    });
  });

  group('ENT-07/ENT-10 — o CTA fica inerte enquanto envia', () {
    Future<void> preencher(WidgetTester tester) async {
      await tester.enterText(find.byType(TextField).first, 'rafa@bora.app');
      await tester.enterText(find.byType(TextField).last, 'segredo');
    }

    testWidgets('duplo toque no CTA dispara UMA autenticação', (tester) async {
      // O edge case literal da spec. Sem pendurar o envio, o primeiro toque
      // termina no mesmo frame e o segundo encontra o botão já reabilitado —
      // foi por isso que a versão anterior deste requisito ficou sem prova.
      autenticacao.travaDeEnvio = Completer<void>();
      await abrir(tester);
      await preencher(tester);

      await tester.tap(find.text('COMEÇAR →'));
      await tester.pump();
      await tester.tap(find.text('COMEÇAR →'), warnIfMissed: false);
      await tester.pump();

      expect(
        autenticacao.chamadas,
        hasLength(1),
        reason: 'ENT-10: o segundo toque não pode virar um segundo login',
      );

      autenticacao.travaDeEnvio!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('durante o envio o CTA fica desabilitado e esmaecido',
        (tester) async {
      autenticacao.travaDeEnvio = Completer<void>();
      await abrir(tester);
      await preencher(tester);

      await tester.tap(find.text('COMEÇAR →'));
      await tester.pump();

      expect(
        tester
            .widget<BoraPrimaryButton>(find.byType(BoraPrimaryButton))
            .onPressed,
        isNull,
        reason: 'ENT-07: não aceitar novo acionamento',
      );
      expect(
        tester
            .widgetList<Opacity>(
              find.descendant(
                of: find.byType(BoraPrimaryButton),
                matching: find.byType(Opacity),
              ),
            )
            .single
            .opacity,
        BoraBorders.opacidadeDesabilitado,
        reason: 'SPEC-PRECISION GAP declarado: ENT-07 pede "exibir estado de '
            'carregando", mas o arquivo 02 não tem spinner e §8 proíbe '
            'inventar motion. O esmaecido do design system é a única '
            'afirmação de estado disponível dentro do sistema — e é o que '
            'está implementado. Registrado no validation.md.',
      );

      autenticacao.travaDeEnvio!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('o botão do Google também fica inerte durante o envio',
        (tester) async {
      autenticacao.travaDeEnvio = Completer<void>();
      await abrir(tester);

      await tester.tap(find.text('CONTINUAR COM GOOGLE'));
      await tester.pump();
      await tester.tap(find.text('CONTINUAR COM GOOGLE'), warnIfMissed: false);
      await tester.pump();

      expect(autenticacao.chamadas, hasLength(1));

      autenticacao.travaDeEnvio!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('terminado o envio, o CTA volta a aceitar toque',
        (tester) async {
      await abrir(tester);
      await preencher(tester);

      await tester.tap(find.text('COMEÇAR →'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<BoraPrimaryButton>(find.byType(BoraPrimaryButton))
            .onPressed,
        isNotNull,
        reason: 'par discriminante: um botão sempre inerte passaria nos '
            'testes acima por acidente',
      );
    });
  });

  group('edge cases da spec', () {
    testWidgets('cruzar 900px preserva o texto digitado e o modo',
        (tester) async {
      await abrir(tester);
      await tester.enterText(find.byType(TextField).first, 'rafa@bora.app');
      await tester.tap(find.text('CRIAR CONTA'));
      await tester.pumpAndSettle();

      tester.view.physicalSize = _expandido;
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller?.text,
        'rafa@bora.app',
        reason: 'os controladores vivem acima do ResponsiveBuilder — trocar de '
            'layout não pode recriar os campos',
      );
      expect(
        find.text('CRIAR CONTA →'),
        findsOneWidget,
        reason: 'o modo também sobrevive: o bloc está acima do split',
      );
    });

    testWidgets('o conteúdo rola, para o teclado não estourar o layout',
        (tester) async {
      await abrir(tester);

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('nenhum layout produz scroll horizontal (W-R4)',
        (tester) async {
      await abrir(tester, tamanho: _expandido);

      final scroll = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );

      expect(scroll.scrollDirection, Axis.vertical);
      expect(tester.takeException(), isNull);
    });
  });

  group('ENT-05 — o foco pinta a borda de vermelho', () {
    testWidgets('o campo sem foco usa ink; com foco, o acento', (tester) async {
      await abrir(tester);

      // `BoraSurface` desenha com `DecoratedBox` — a borda do input é a
      // decoração dela, não a de um `Container`.
      BoxDecoration decoracaoDoPrimeiroCampo() => tester
          .widget<DecoratedBox>(
            find
                .descendant(
                  of: find.byType(BoraTextField).first,
                  matching: find.byType(DecoratedBox),
                )
                .first,
          )
          .decoration as BoxDecoration;

      expect(
        (decoracaoDoPrimeiroCampo().border! as Border).top.color,
        BoraColors.ink,
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();

      expect(
        (decoracaoDoPrimeiroCampo().border! as Border).top.color,
        BoraColors.primary,
        reason: 'aceite literal de UC-01, afirmado contra o token',
      );
    });
  });

  group('ENT-04 — o layout muda de lado no breakpoint de AD-007', () {
    testWidgets('em viewport expandida, a copy do Google é a de W-01',
        (tester) async {
      await abrir(tester, tamanho: _expandido);

      expect(find.text('🌐 ENTRAR COM GOOGLE'), findsOneWidget);
      expect(
        find.text('CONTINUAR COM GOOGLE'),
        findsNothing,
        reason: 'A-05: o par de plataforma é o que prova que a copy não é a '
            'mesma nos dois lados',
      );
    });

    testWidgets('em viewport expandida, o card ganha o label ENTRAR',
        (tester) async {
      await abrir(tester, tamanho: _expandido);

      expect(find.text('ENTRAR'), findsOneWidget);
    });
  });
}
