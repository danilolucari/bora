import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta um app com `Overlay` e devolve um contexto de dentro dele.
Future<BuildContext> _montarApp(WidgetTester tester) async {
  late BuildContext contexto;
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Builder(
        builder: (context) {
          contexto = context;
          return const Scaffold(body: SizedBox.expand());
        },
      ),
    ),
  );
  return contexto;
}

/// A `BoxDecoration` do toast que está na árvore renderizada.
BoxDecoration _decoracao(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byKey(BoraToast.toastKey),
      matching: find.byType(DecoratedBox),
    ),
  );
  return caixa.decoration as BoxDecoration;
}

TextStyle _estilo(WidgetTester tester) => tester
    .widget<Text>(
      find.descendant(
        of: find.byKey(BoraToast.toastKey),
        matching: find.byType(Text),
      ),
    )
    .style!;

double _opacidade(WidgetTester tester) => tester
    .widgetList<Opacity>(
      find.ancestor(
        of: find.byKey(BoraToast.toastKey),
        matching: find.byType(Opacity),
      ),
    )
    .first
    .opacity;

Matrix4 _translacao(WidgetTester tester) => tester
    .widgetList<Transform>(
      find.ancestor(
        of: find.byKey(BoraToast.toastKey),
        matching: find.byType(Transform),
      ),
    )
    .first
    .transform;

void main() {
  group('DS-12 — o toast de §5', () {
    testWidgets('fundo ink, texto cream 800/13 ls .5 e sombra dura no acento',
        (tester) async {
      final contexto = await _montarApp(tester);

      BoraToast.mostrar(
        contexto,
        texto: BoraToastTexts.linkCopiado,
        acento: BoraAccent.purple,
      );
      await tester.pump();
      await tester.pump(BoraMotion.toastIn);

      final decoracao = _decoracao(tester);
      expect(decoracao.color, BoraColors.ink, reason: '§5: "Fundo ink"');
      expect(decoracao.borderRadius, BorderRadius.zero);
      expect(decoracao.boxShadow, hasLength(1));
      expect(decoracao.boxShadow!.single.blurRadius, 0.0);
      expect(
        decoracao.boxShadow!.single.offset,
        const Offset(4, 4),
        reason: '§5: "sombra 4px 4px 0 no acento do contexto"',
      );
      expect(decoracao.boxShadow!.single.color, BoraColors.purple);

      final estilo = _estilo(tester);
      expect(estilo.color, BoraColors.cream);
      expect(estilo.fontSize, 13.0);
      expect(estilo.fontWeight, FontWeight.w800);
      expect(estilo.letterSpacing, 0.5);

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byKey(BoraToast.toastKey),
          matching: find.byType(Padding),
        ),
      );
      expect(
        padding.padding,
        BoraSpacing.toast,
        reason: '§5: "padding 12px 20px"',
      );

      BoraToast.esconder();
      await tester.pump();
    });

    testWidgets('fica centralizado a 112px do rodapé', (tester) async {
      final contexto = await _montarApp(tester);

      BoraToast.mostrar(contexto, texto: BoraToastTexts.roleSalvo);
      await tester.pump();
      await tester.pump(BoraMotion.toastIn);

      final tela = tester.getSize(find.byType(MaterialApp));
      final toast = tester.getRect(find.byKey(BoraToast.toastKey));

      expect(
        tela.height - toast.bottom,
        112.0,
        reason: '§5: "posição central, bottom: 112px"',
      );
      expect(toast.center.dx, tela.width / 2);

      BoraToast.esconder();
      await tester.pump();
    });

    testWidgets('entra com fade e subida de 14px em 300ms', (tester) async {
      final contexto = await _montarApp(tester);

      BoraToast.mostrar(contexto, texto: BoraToastTexts.listaNoGrupo);
      await tester.pump();

      expect(_opacidade(tester), 0.0);
      expect(
        _translacao(tester),
        Matrix4.translationValues(0, BoraMotion.toastSubida, 0),
        reason: '§6, toastIn: "from {opacity:0; translateY(14px)}"',
      );

      await tester.pump(BoraMotion.toastIn);

      expect(_opacidade(tester), 1.0);
      expect(_translacao(tester), Matrix4.translationValues(0, 0, 0));
      expect(BoraMotion.toastIn, const Duration(milliseconds: 300));

      final animacao = tester.widget<TweenAnimationBuilder<double>>(
        find.ancestor(
          of: find.byKey(BoraToast.toastKey),
          matching: find.byType(TweenAnimationBuilder<double>),
        ),
      );
      expect(animacao.duration, BoraMotion.toastIn);
      expect(
        animacao.curve,
        BoraMotion.curva,
        reason: '§6, toastIn: ".3s ease"',
      );

      BoraToast.esconder();
      await tester.pump();
    });

    testWidgets('a copy sai em CAIXA ALTA mesmo chegando em minúsculas',
        (tester) async {
      final contexto = await _montarApp(tester);

      BoraToast.mostrar(contexto, texto: 'link copiado 🔗');
      await tester.pump();

      expect(find.text(BoraToastTexts.linkCopiado), findsOneWidget);
      expect(find.text('link copiado 🔗'), findsNothing);

      BoraToast.esconder();
      await tester.pump();
    });
  });

  group('DS-12 — 2200ms e some sozinho', () {
    testWidgets('presente em 2199ms, ausente logo depois de 2200ms',
        (tester) async {
      final contexto = await _montarApp(tester);

      BoraToast.mostrar(contexto, texto: BoraToastTexts.salvoNaAgenda);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2199));

      expect(
        find.byKey(BoraToast.toastKey),
        findsOneWidget,
        reason: 'RN-29: a vida do toast é 2200ms',
      );

      await tester.pump(const Duration(milliseconds: 2));

      expect(
        find.byKey(BoraToast.toastKey),
        findsNothing,
        reason: '§5: "some sozinho após 2200ms", sem interação',
      );
      expect(BoraMotion.toastVida, const Duration(milliseconds: 2200));
    });
  });

  group('DS-12 — 1 por vez: o novo substitui o anterior', () {
    testWidgets('dois seguidos deixam um só toast, com o texto do segundo',
        (tester) async {
      final contexto = await _montarApp(tester);

      BoraToast.mostrar(contexto, texto: BoraToastTexts.linkCopiado);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      BoraToast.mostrar(contexto, texto: BoraToastTexts.roleSalvo);
      await tester.pump();

      expect(
        find.byKey(BoraToast.toastKey),
        findsOneWidget,
        reason: '§8: "toast persistente ou empilhado" não existe',
      );
      expect(find.text(BoraToastTexts.roleSalvo), findsOneWidget);
      expect(find.text(BoraToastTexts.linkCopiado), findsNothing);

      BoraToast.esconder();
      await tester.pump();
    });

    testWidgets('o timer do primeiro é cancelado e não derruba o segundo',
        (tester) async {
      final contexto = await _montarApp(tester);

      BoraToast.mostrar(contexto, texto: BoraToastTexts.linkCopiado);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      BoraToast.mostrar(contexto, texto: BoraToastTexts.roleSalvo);
      await tester.pump();

      // O timer do primeiro venceria aqui (2200ms depois de ele aparecer).
      await tester.pump(const Duration(milliseconds: 2150));

      expect(
        find.text(BoraToastTexts.roleSalvo),
        findsOneWidget,
        reason: 'timer órfão derrubaria o toast novo antes da hora dele',
      );

      // E o timer do segundo vence na hora dele, contada do próprio começo.
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(BoraToast.toastKey), findsNothing);
    });
  });

  group('DS-12 — sem Overlay o toast é ignorado, não lança', () {
    testWidgets('mostrar sem Overlay no contexto retorna em silêncio',
        (tester) async {
      late BuildContext contexto;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              contexto = context;
              return const SizedBox.expand();
            },
          ),
        ),
      );

      expect(
        () => BoraToast.mostrar(
          contexto,
          texto: BoraToastTexts.crieOGrupoPrimeiro,
        ),
        returnsNormally,
      );
      expect(find.byKey(BoraToast.toastKey), findsNothing);
    });

    testWidgets('o timer que vence depois do Overlay desmontado não lança',
        (tester) async {
      final contexto = await _montarApp(tester);

      BoraToast.mostrar(contexto, texto: BoraToastTexts.enquetePostada);
      await tester.pump();
      expect(find.byKey(BoraToast.toastKey), findsOneWidget);

      await tester.pumpWidget(const SizedBox.expand());
      await tester.pump(const Duration(milliseconds: 2200));

      expect(tester.takeException(), isNull);
      expect(find.byKey(BoraToast.toastKey), findsNothing);
    });
  });
}
