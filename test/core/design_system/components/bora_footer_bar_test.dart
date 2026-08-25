import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A largura do palco: o rodapé é fixo e atravessa a tela do celular.
const double _larguraDoPalco = 390;

/// A decoração do rodapé: a superfície mais externa da subárvore.
BoxDecoration _barra(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(BoraFooterBar),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return caixa.decoration as BoxDecoration;
}

TextStyle _estilo(WidgetTester tester, String texto) =>
    tester.widget<Text>(find.text(texto)).style!;

Future<void> _montar(
  WidgetTester tester, {
  String label = 'sai por',
  String valorFormatado = r'R$ 211',
  String sublinha = r'≈ R$ 30 por cabeça',
  Widget? cta,
}) {
  return pumpComponent(
    tester,
    SizedBox(
      width: _larguraDoPalco,
      child: BoraFooterBar(
        label: label,
        valorFormatado: valorFormatado,
        sublinha: sublinha,
        cta: cta ?? BoraPrimaryButton(rotulo: 'bora', onPressed: () {}),
      ),
    ),
  );
}

void main() {
  group('DS-26 — a borda fica só no topo', () {
    testWidgets('topo com 2px ink e os outros três lados sem borda',
        (tester) async {
      await _montar(tester);

      final borda = _barra(tester).border! as Border;

      expect(
        borda.top.width,
        2.0,
        reason: '§5: "`border-top 2px ink`"',
      );
      expect(borda.top.color, BoraColors.ink);
      expect(
        borda.left,
        BorderSide.none,
        reason: '§5 dá ao rodapé uma linha de separação, não uma caixa',
      );
      expect(borda.right, BorderSide.none);
      expect(borda.bottom, BorderSide.none);
    });

    testWidgets('fundo paper e canto reto', (tester) async {
      await _montar(tester);

      final decoracao = _barra(tester);

      expect(decoracao.color, BoraColors.paper, reason: '§5: "Fundo `paper`"');
      expect(decoracao.borderRadius, BorderRadius.zero, reason: '§3');
      expect(
        decoracao.boxShadow,
        isNull,
        reason: '§5 não dá sombra ao rodapé fixo',
      );
    });

    testWidgets('o padding é o 14/24/30 de §5', (tester) async {
      await _montar(tester);

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(BoraFooterBar),
              matching: find.byType(Padding),
            )
            .first,
      );

      expect(padding.padding, BoraSpacing.rodape);
      expect(
        BoraSpacing.rodape,
        const EdgeInsets.fromLTRB(24, 14, 24, 30),
        reason: '§5: "padding 14–16px 24px 30px"',
      );
    });
  });

  group('DS-26 — o bloco da esquerda', () {
    testWidgets('label 800 11px ls 1px text-2', (tester) async {
      await _montar(tester);

      final estilo = _estilo(tester, 'SAI POR');

      expect(estilo.fontSize, 11.0, reason: '§5: "label 800 11px ls 1px"');
      expect(estilo.fontWeight, FontWeight.w800);
      expect(estilo.letterSpacing, 1.0);
      expect(estilo.color, BoraColors.text2);
      expect(estilo.fontFamily, BoraTextStyles.familiaUi);
    });

    testWidgets('valor em Archivo Black e sublinha vermelha 700 12.5px',
        (tester) async {
      await _montar(tester);

      final valor = _estilo(tester, r'R$ 211');
      final sublinha = _estilo(tester, r'≈ R$ 30 por cabeça');

      expect(
        valor.fontFamily,
        BoraTextStyles.familiaDisplay,
        reason: '§5: "valor Archivo Black"',
      );
      expect(valor.fontSize, 24.0);
      expect(valor.color, BoraColors.ink);
      expect(
        sublinha.color,
        BoraColors.primary,
        reason: '§5: "sublinha vermelha 700 12.5px"',
      );
      expect(sublinha.fontSize, 12.5);
      expect(sublinha.fontWeight, FontWeight.w700);
    });

    testWidgets('as três linhas empilham à esquerda, o CTA fica à direita',
        (tester) async {
      await _montar(tester);

      final label = tester.getRect(find.text('SAI POR'));
      final valor = tester.getRect(find.text(r'R$ 211'));
      final sublinha = tester.getRect(find.text(r'≈ R$ 30 por cabeça'));
      final botao = tester.getRect(find.byType(BoraPrimaryButton));
      final barra = tester.getRect(find.byType(BoraFooterBar));

      expect(valor.top, greaterThanOrEqualTo(label.bottom));
      expect(sublinha.top, greaterThanOrEqualTo(valor.bottom));
      expect(valor.left, label.left);
      expect(
        label.left,
        barra.left + BoraSpacing.rodape.left,
        reason: '§5: o bloco começa na margem esquerda do padding',
      );
      expect(
        botao.left,
        greaterThanOrEqualTo(sublinha.right),
        reason: '§5: "e CTA à direita"',
      );
      expect(botao.right, barra.right - BoraSpacing.rodape.right);
    });

    testWidgets('o CTA recebido é o que aparece à direita', (tester) async {
      await _montar(
        tester,
        cta: BoraSecondaryButton(rotulo: 'agora não', onPressed: () {}),
      );

      expect(
        find.text('AGORA NÃO'),
        findsOneWidget,
        reason: '§5: o rodapé dá o lugar; o botão é de quem monta a tela',
      );
      expect(find.byType(BoraPrimaryButton), findsNothing);
    });
  });

  group('DS-32 e DS-34 — copy e dinheiro', () {
    testWidgets('label minúsculo entra e CAIXA ALTA sai', (tester) async {
      await _montar(tester, label: 'sai por');

      expect(find.text('SAI POR'), findsOneWidget, reason: '§7');
      expect(find.text('sai por'), findsNothing);
    });

    testWidgets('o valor sai exatamente como chegou', (tester) async {
      await _montar(
        tester,
        valorFormatado: '271',
        sublinha: 'com os essenciais',
      );

      expect(
        find.text('271'),
        findsOneWidget,
        reason: 'RN-13 é da spec calculo: o rodapé desenha a String recebida',
      );
      expect(find.text(r'R$ 271'), findsNothing);
      expect(
        find.text('com os essenciais'),
        findsOneWidget,
        reason: '§7: a sublinha é corpo, em sentence case',
      );
    });
  });
}
