import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

const Key _headerKey = Key('header-de-teste');
const Key _rodapeKey = Key('rodape-de-teste');
const Key _alvoKey = Key('alvo-la-embaixo');

/// O frame mede 390×820: a janela padrão do teste (800×600) não o comporta e
/// o overflow mascararia toda medida. Aqui a janela é maior que o palco.
void _janelaQueComportaOFrame(WidgetTester tester) {
  tester.view.physicalSize = const Size(600, 1100);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Widget _frame({bool comHeaderERodape = true}) => BoraPhoneFrame(
      header: comHeaderERodape
          ? const SizedBox(key: _headerKey, height: 60)
          : null,
      rodape: comHeaderERodape
          ? const SizedBox(key: _rodapeKey, height: 80)
          : null,
      conteudo: const SizedBox(
        height: 2000,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(key: _alvoKey, height: 10),
        ),
      ),
    );

BoxDecoration _decoracaoDoFrame(WidgetTester tester) => tester
    .widget<DecoratedBox>(
      find
          .descendant(
            of: find.byKey(BoraPhoneFrame.frameKey),
            matching: find.byType(DecoratedBox),
          )
          .first,
    )
    .decoration as BoxDecoration;

Finder _rolagemDoFrame() => find.descendant(
      of: find.byKey(BoraPhoneFrame.frameKey),
      matching: find.byType(Scrollable),
    );

void main() {
  group('DS-31 — o frame do celular é o palco', () {
    testWidgets('mede 390×820', (tester) async {
      _janelaQueComportaOFrame(tester);
      await pumpComponent(tester, _frame());

      expect(
        tester.getSize(find.byKey(BoraPhoneFrame.frameKey)),
        const Size(390, 820),
        reason: '§5: "390×820"',
      );
    });

    testWidgets('tem radius 38 e borda de 1px na cor do frame', (tester) async {
      _janelaQueComportaOFrame(tester);
      await pumpComponent(tester, _frame());

      final decoracao = _decoracaoDoFrame(tester);

      expect(
        decoracao.borderRadius,
        const BorderRadius.all(Radius.circular(38)),
        reason: '§5: "radius 38px" — a exceção de §3, que manda radius 0',
      );
      final borda = decoracao.border! as Border;
      expect(borda.top.width, 1.0, reason: '§5: borda de 1px');
      expect(
        borda.top.color,
        BoraColors.frameBorder,
        reason: '§5: `rgba(0,0,0,.25)`',
      );
    });

    testWidgets('a sombra é a do frame, a única do sistema com blur',
        (tester) async {
      _janelaQueComportaOFrame(tester);
      await pumpComponent(tester, _frame());

      final sombras = _decoracaoDoFrame(tester).boxShadow!;

      expect(sombras, [BoraShadows.frame]);
      expect(
        sombras.single.blurRadius,
        greaterThan(0),
        reason: '§4: a do frame é a única sombra suave — é o palco, não a UI',
      );
    });

    testWidgets('corta o conteúdo nos cantos arredondados', (tester) async {
      _janelaQueComportaOFrame(tester);
      await pumpComponent(tester, _frame());

      final recorte = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byKey(BoraPhoneFrame.frameKey),
          matching: find.byType(ClipRRect),
        ),
      );

      expect(recorte.clipBehavior, isNot(Clip.none), reason: '§5: overflow hidden');
      expect(recorte.borderRadius, BoraPhoneFrame.raio);
    });
  });

  group('DS-31 — header e rodapé ficam parados, o meio rola', () {
    testWidgets('só o conteúdo central está dentro da área que rola',
        (tester) async {
      _janelaQueComportaOFrame(tester);
      await pumpComponent(tester, _frame());

      final rolagem = _rolagemDoFrame();
      expect(rolagem, findsOneWidget, reason: 'há uma única área que rola');

      expect(
        find.descendant(of: rolagem, matching: find.byKey(_headerKey)),
        findsNothing,
        reason: '§5: o header é fixo',
      );
      expect(
        find.descendant(of: rolagem, matching: find.byKey(_rodapeKey)),
        findsNothing,
        reason: '§5: o rodapé é fixo',
      );
      expect(
        find.descendant(of: rolagem, matching: find.byKey(_alvoKey)),
        findsOneWidget,
        reason: '§5: o conteúdo é o que rola',
      );
    });

    testWidgets('rolar move o conteúdo e deixa header e rodapé no lugar',
        (tester) async {
      _janelaQueComportaOFrame(tester);
      await pumpComponent(tester, _frame());

      final headerAntes = tester.getTopLeft(find.byKey(_headerKey));
      final rodapeAntes = tester.getTopLeft(find.byKey(_rodapeKey));
      final conteudoAntes = tester.getTopLeft(find.byKey(_alvoKey));

      await tester.drag(_rolagemDoFrame(), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.byKey(_alvoKey)).dy,
        lessThan(conteudoAntes.dy),
        reason: 'o conteúdo subiu: a área central rolou de verdade',
      );
      expect(tester.getTopLeft(find.byKey(_headerKey)), headerAntes);
      expect(tester.getTopLeft(find.byKey(_rodapeKey)), rodapeAntes);
    });

    testWidgets('sem header e sem rodapé o conteúdo continua rolando',
        (tester) async {
      _janelaQueComportaOFrame(tester);
      await pumpComponent(tester, _frame(comHeaderERodape: false));

      expect(find.byKey(_headerKey), findsNothing);
      expect(find.byKey(_rodapeKey), findsNothing);
      expect(_rolagemDoFrame(), findsOneWidget);
      expect(
        tester.getSize(find.byKey(BoraPhoneFrame.frameKey)),
        const Size(390, 820),
        reason: 'o palco não muda de tamanho por não ter header',
      );
    });
  });
}
