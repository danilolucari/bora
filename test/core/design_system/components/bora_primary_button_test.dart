import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A `BoxDecoration` que o botão colocou **na árvore renderizada**.
BoxDecoration _decoracao(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(BoraPrimaryButton),
      matching: find.byType(DecoratedBox),
    ),
  );
  return caixa.decoration as BoxDecoration;
}

/// O padding que envolve o rótulo na árvore renderizada.
EdgeInsetsGeometry _padding(WidgetTester tester) {
  return tester
      .widget<Padding>(
        find.descendant(
          of: find.byType(BoraPrimaryButton),
          matching: find.byType(Padding),
        ),
      )
      .padding;
}

/// O botão dentro de um pai que oferece **no máximo** [largura] — folga que o
/// `larguraTotal` pode ou não ocupar.
Future<void> _montarEm(
  WidgetTester tester, {
  required double largura,
  required bool larguraTotal,
}) {
  return pumpComponent(
    tester,
    ConstrainedBox(
      constraints: BoxConstraints(maxWidth: largura),
      child: BoraPrimaryButton(
        rotulo: 'salvar rolê',
        larguraTotal: larguraTotal,
        onPressed: () {},
      ),
    ),
  );
}

void main() {
  group('DS-14 — o botão primário de §5', () {
    testWidgets('fundo ink, texto cream, borda 2px ink e padding de §5',
        (tester) async {
      await pumpComponent(
        tester,
        BoraPrimaryButton(rotulo: 'salvar', onPressed: () {}),
      );

      final decoracao = _decoracao(tester);

      expect(
        decoracao.color,
        BoraColors.ink,
        reason: '§5, botão primário: "Fundo ink"',
      );
      expect(decoracao.border!.top.width, 2.0, reason: '§5: "borda 2px ink"');
      expect(decoracao.border!.top.color, BoraColors.ink);
      expect(
        decoracao.borderRadius,
        BorderRadius.zero,
        reason: '§3: "border-radius: 0 em tudo (botões, …)"',
      );
      expect(
        tester.widget<Text>(find.text('SALVAR')).style!.color,
        BoraColors.cream,
        reason: '§5: "texto cream"',
      );
      expect(
        _padding(tester),
        BoraSpacing.botao + const EdgeInsets.all(2),
        reason: '§5: "padding 15–16px" mais a borda de 2px de §3 — o box '
            'model do CSS põe a borda por fora do padding, e o Container faz '
            'o mesmo somando a borda ao padding pedido',
      );
      expect(BoraSpacing.botao, const EdgeInsets.all(15));
    });

    testWidgets('a sombra é dura, 4px 4px, no acento do contexto',
        (tester) async {
      await pumpComponent(
        tester,
        BoraPrimaryButton(rotulo: 'salvar', onPressed: () {}),
      );

      final sombra = _decoracao(tester).boxShadow!.single;

      expect(sombra.offset, const Offset(4, 4), reason: '§5: "4px 4px 0"');
      expect(
        sombra.blurRadius,
        0.0,
        reason: '§4: as sombras são "sempre duras, sem blur"',
      );
      expect(
        sombra.color,
        BoraColors.primary,
        reason: 'o acento padrão do CTA é o vermelho de §1',
      );
    });

    testWidgets('trocar o acento troca a cor da sombra', (tester) async {
      await pumpComponent(
        tester,
        BoraPrimaryButton(
          rotulo: 'chamar a galera',
          acento: BoraAccent.purple,
          onPressed: () {},
        ),
      );

      expect(
        _decoracao(tester).boxShadow!.single.color,
        BoraColors.purple,
        reason: '§5: a sombra é "no acento do contexto" — galera/link é roxo',
      );
    });

    testWidgets('larguraTotal ocupa a largura do pai', (tester) async {
      await _montarEm(tester, largura: 300, larguraTotal: true);

      expect(
        tester.getSize(find.byType(BoraPrimaryButton)).width,
        300.0,
        reason: '§5: "Largura total quando é o CTA do rodapé"',
      );
    });

    testWidgets('sem larguraTotal o botão só ocupa o próprio conteúdo',
        (tester) async {
      await _montarEm(tester, largura: 300, larguraTotal: false);

      expect(
        tester.getSize(find.byType(BoraPrimaryButton)).width,
        lessThan(300.0),
        reason: 'a largura total é da variante de rodapé, não do padrão',
      );
    });
  });

  group('DS-32 — a copy do botão sai em CAIXA ALTA', () {
    testWidgets('entra "bora", sai "BORA"', (tester) async {
      await pumpComponent(
        tester,
        BoraPrimaryButton(rotulo: 'bora', onPressed: () {}),
      );

      expect(find.text('BORA'), findsOneWidget);
      expect(
        find.text('bora'),
        findsNothing,
        reason: '§7: "botões em CAIXA ALTA", venha a copy como vier',
      );
    });

    testWidgets('rótulo vazio renderiza sem exceção', (tester) async {
      await pumpComponent(
        tester,
        BoraPrimaryButton(rotulo: '', onPressed: () {}),
      );

      expect(find.byType(BoraPrimaryButton), findsOneWidget);
      expect(find.text(''), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('DS-14 — o toque e o desabilitado (A-07)', () {
    testWidgets('o toque chama onPressed exatamente uma vez', (tester) async {
      var toques = 0;
      await pumpComponent(
        tester,
        BoraPrimaryButton(rotulo: 'salvar', onPressed: () => toques++),
      );

      await tester.tap(find.byType(BoraPrimaryButton));
      await tester.pumpAndSettle();

      expect(toques, 1);
    });

    testWidgets('onPressed nulo rende opacidade .7 e não dispara nada',
        (tester) async {
      var toques = 0;
      await pumpComponent(
        tester,
        BoraPrimaryButton(rotulo: 'salvar', onPressed: () => toques++),
      );
      await tester.tap(find.byType(BoraPrimaryButton));
      await tester.pumpAndSettle();
      expect(toques, 1);

      await pumpComponent(tester, const BoraPrimaryButton(rotulo: 'salvar'));
      await tester.tap(find.byType(BoraPrimaryButton));
      await tester.pumpAndSettle();

      expect(
        toques,
        1,
        reason: 'desabilitado não emite — nem o callback que ele tinha antes',
      );
      expect(
        tester
            .widget<Opacity>(
              find.descendant(
                of: find.byType(BoraPrimaryButton),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        BoraBorders.opacidadeDesabilitado,
        reason: 'A-07: desabilitado é opacity .7',
      );
    });
  });
}
