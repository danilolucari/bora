import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/entrar/presentation/pages/entrar_page.dart';
import 'package:bora/features/entrar/presentation/widgets/entrar_compacto.dart';
import 'package:bora/features/entrar/presentation/widgets/entrar_expandido.dart';
import 'package:bora/features/entrar/presentation/widgets/marca_bora.dart';
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

  Future<void> abrir(WidgetTester tester, {Size tamanho = _expandido}) async {
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

  /// A superfície do card de W-01, por chave.
  ///
  /// Por chave, e não por tipo: o input também é uma `BoraSurface`, e um
  /// finder por tipo pegaria o primeiro da árvore — que é o da coluna
  /// esquerda, não o card.
  BoraSurface cardDoFormulario(WidgetTester tester) =>
      tester.widget<BoraSurface>(find.byKey(EntrarExpandido.cardKey));

  group('ENT-04 — W-01 monta as duas colunas', () {
    testWidgets('o layout expandido substitui o compacto', (tester) async {
      await abrir(tester);

      expect(find.byType(EntrarExpandido), findsOneWidget);
      expect(
        find.byType(EntrarCompacto),
        findsNothing,
        reason: 'AD-007: acima de 900 é o layout do arquivo 06, e só ele',
      );
    });

    testWidgets('abaixo do breakpoint volta o compacto', (tester) async {
      await abrir(tester, tamanho: _compacto);

      expect(find.byType(EntrarCompacto), findsOneWidget);
      expect(
        find.byType(EntrarExpandido),
        findsNothing,
        reason: 'par discriminante do breakpoint',
      );
    });

    testWidgets('a marca fica à esquerda e o card à direita', (tester) async {
      // R-2 do Verifier: tudo do card estava afirmado contra token, mas os
      // LADOS não — inverter a ordem das colunas (M24) sobrevivia aos 945.
      // W-01 é explícito: "coluna esquerda (marca)" e "coluna direita (form)".
      await abrir(tester);

      final marca = tester.getTopLeft(find.byType(MarcaBora)).dx;
      final card = tester.getTopLeft(find.byKey(EntrarExpandido.cardKey)).dx;

      expect(marca, lessThan(card));
    });

    testWidgets('o espaço entre as colunas é o gap de W-01', (tester) async {
      await abrir(tester);

      final fimDaMarca = tester.getRect(find.byType(MarcaBora)).right;
      final inicioDoCard =
          tester.getTopLeft(find.byKey(EntrarExpandido.cardKey)).dx;

      expect(inicioDoCard, greaterThan(fimDaMarca));
      expect(EntrarExpandido.espacoEntreColunas, 74);
    });

    testWidgets('a marca usa o degrau de 92px do arquivo 06', (tester) async {
      await abrir(tester);

      final logo = tester.widget<Text>(
        find.descendant(
          of: find.byType(MarcaBora),
          matching: find.byType(Text),
        ),
      );

      expect(logo.style?.fontSize, MarcaBora.tamanhoExpandido);
      expect(logo.style?.letterSpacing, -3);
    });
  });

  group('ENT-04 — o card branco de W-01', () {
    testWidgets('sombra de 10px, e não a do CTA', (tester) async {
      await abrir(tester);

      expect(
        cardDoFormulario(tester).deslocamentoDaSombra,
        EntrarExpandido.sombraDoCard,
        reason: 'W-01 pede "sombra 10px 10px 0 ink" — mais funda que o 4px do '
            'CTA. Uma mutação para 4 sobreviveu à suíte inteira antes deste '
            'teste existir (gap nº 2 do Verifier)',
      );
      expect(EntrarExpandido.sombraDoCard, 10);
    });

    testWidgets('a sombra é ink, e a borda também', (tester) async {
      await abrir(tester);
      final card = cardDoFormulario(tester);

      expect(card.acento, BoraAccent.ink);
      expect(card.corDaBorda, BoraColors.ink);
      expect(card.larguraDaBorda, 2);
      expect(card.fundo, BoraColors.white);
    });

    testWidgets('o padding interno é o de W-01', (tester) async {
      await abrir(tester);

      expect(cardDoFormulario(tester).padding, EntrarExpandido.paddingDoCard);
      expect(EntrarExpandido.paddingDoCard, const EdgeInsets.all(30));
    });

    testWidgets('a coluna do formulário tem a largura de W-01',
        (tester) async {
      await abrir(tester);

      expect(
        tester.getSize(find.byKey(EntrarExpandido.cardKey)).width,
        EntrarExpandido.larguraDoCard,
      );
      expect(EntrarExpandido.larguraDoCard, 340);
    });
  });

  group('ENT-04 — a copy de W-01, literal', () {
    testWidgets('label, CTA, Google e rodapé', (tester) async {
      await abrir(tester);

      expect(find.text('ENTRAR'), findsOneWidget);
      expect(find.text('COMEÇAR →'), findsOneWidget);
      expect(find.text('🌐 ENTRAR COM GOOGLE'), findsOneWidget);
      expect(find.text('Novo por aqui? '), findsOneWidget);
      expect(find.text('CRIAR CONTA'), findsOneWidget);
    });

    testWidgets('a tag e a apresentação continuam presentes', (tester) async {
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
  });

  group('ENT-04 — o formulário funciona igual no web', () {
    testWidgets('submeter chama o repositório com o e-mail digitado',
        (tester) async {
      await abrir(tester);

      await tester.enterText(find.byType(TextField).first, 'rafa@bora.app');
      await tester.enterText(find.byType(TextField).last, 'segredo');
      await tester.tap(find.text('COMEÇAR →'));
      await tester.pumpAndSettle();

      expect(autenticacao.registros.single.metodo, 'entrarComEmailESenha');
      expect(autenticacao.registros.single.email, 'rafa@bora.app');
    });

    testWidgets('o botão do Google do web chama entrarComGoogle',
        (tester) async {
      await abrir(tester);

      await tester.tap(find.text('🌐 ENTRAR COM GOOGLE'));
      await tester.pumpAndSettle();

      expect(autenticacao.chamadas, ['entrarComGoogle']);
    });
  });
}
