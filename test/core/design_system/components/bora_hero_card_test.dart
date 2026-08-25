import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A decoração do card: a superfície mais externa da subárvore.
BoxDecoration _cartao(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(BoraHeroCard),
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
  String label = 'total do rolê',
  String valorFormatado = r'R$ 211',
  String sublinha = r'≈ R$ 30 por cabeça',
}) {
  return pumpComponent(
    tester,
    BoraHeroCard(
      label: label,
      valorFormatado: valorFormatado,
      sublinha: sublinha,
    ),
  );
}

void main() {
  group('DS-25 — a caixa do card-herói', () {
    testWidgets('fundo ink, canto reto e sombra dura 6px no primary',
        (tester) async {
      await _montar(tester);

      final decoracao = _cartao(tester);

      expect(
        decoracao.color,
        BoraColors.ink,
        reason: '§5: "Fundo `ink`" — o card do dinheiro é o escuro',
      );
      expect(decoracao.borderRadius, BorderRadius.zero, reason: '§3');
      expect(
        decoracao.boxShadow!.single.color,
        BoraColors.primary,
        reason: '§4: "Card-herói escuro: 6px 6px 0 #FF4D2E"',
      );
      expect(decoracao.boxShadow!.single.offset, const Offset(6, 6));
      expect(
        decoracao.boxShadow!.single.blurRadius,
        0.0,
        reason: '§4: sombras "sempre duras, sem blur"',
      );
    });

    testWidgets('a sombra desenhada é o token, não uma cópia dele',
        (tester) async {
      await _montar(tester);

      // As três asserções acima batem em literais, e literal no teste concorda
      // com literal no componente: as duas cópias do 6 podiam divergir do token
      // sem nada ficar vermelho. Esta amarra o que o card desenha ao que
      // `BoraShadows` declara.
      expect(_cartao(tester).boxShadow!.single, BoraShadows.cardHeroi);
      expect(
        BoraHeroCard.deslocamentoDaSombra,
        BoraShadows.distanciaCardHeroi,
        reason: 'a distância do card é a do token, não um segundo 6',
      );
    });

    testWidgets('o padding é o 20px de §5', (tester) async {
      await _montar(tester);

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(BoraHeroCard),
              matching: find.byType(Padding),
            )
            .first,
      );

      expect(
        padding.padding,
        BoraSpacing.cardHeroi,
        reason: '§5: "padding 20–22px" — a superfície não soma a borda ao '
            'padding, então o valor chega inteiro',
      );
      expect(BoraSpacing.cardHeroi, const EdgeInsets.all(20));
    });
  });

  group('DS-25 — os três papéis de texto', () {
    testWidgets('label yellow 800 12px ls 1px', (tester) async {
      await _montar(tester);

      final estilo = _estilo(tester, 'TOTAL DO ROLÊ');

      expect(estilo.color, BoraColors.yellow, reason: '§5: "Label `yellow`"');
      expect(estilo.fontSize, 12.0);
      expect(estilo.fontWeight, FontWeight.w800);
      expect(estilo.letterSpacing, 1.0, reason: '§5: "800 12px ls 1px"');
      expect(estilo.fontFamily, BoraTextStyles.familiaUi);
    });

    testWidgets('valor cream em Archivo Black 40px', (tester) async {
      await _montar(tester);

      final estilo = _estilo(tester, r'R$ 211');

      expect(
        estilo.color,
        BoraColors.cream,
        reason: '§5: "valor `cream` Archivo Black 40–42px"',
      );
      expect(estilo.fontSize, 40.0);
      expect(
        estilo.fontFamily,
        BoraTextStyles.familiaDisplay,
        reason: '§2: o valor-herói é da família de display',
      );
      expect(estilo.fontWeight, FontWeight.w400, reason: 'A-11');
    });

    testWidgets('sublinha primary 700 13px', (tester) async {
      await _montar(tester);

      final estilo = _estilo(tester, r'≈ R$ 30 por cabeça');

      expect(
        estilo.color,
        BoraColors.primary,
        reason: '§5: "sublinha `primary` 700 13px"',
      );
      expect(estilo.fontSize, 13.0);
      expect(estilo.fontWeight, FontWeight.w700);
      expect(estilo.fontFamily, BoraTextStyles.familiaUi);
    });

    testWidgets('label em cima, valor no meio, sublinha embaixo, à esquerda',
        (tester) async {
      await _montar(tester);

      final label = tester.getRect(find.text('TOTAL DO ROLÊ'));
      final valor = tester.getRect(find.text(r'R$ 211'));
      final sublinha = tester.getRect(find.text(r'≈ R$ 30 por cabeça'));

      expect(valor.top, greaterThanOrEqualTo(label.bottom));
      expect(sublinha.top, greaterThanOrEqualTo(valor.bottom));
      expect(valor.left, label.left);
      expect(sublinha.left, label.left);
      expect(
        label.left,
        tester.getRect(find.byType(BoraHeroCard)).left +
            BoraSpacing.cardHeroi.left,
        reason: '§5: as três linhas começam na margem do padding',
      );
    });
  });

  group('DS-32 — a copy de label sai em CAIXA ALTA', () {
    testWidgets('label minúscula entra, CAIXA ALTA sai', (tester) async {
      await _montar(tester, label: 'sai por');

      expect(find.text('SAI POR'), findsOneWidget, reason: '§7');
      expect(find.text('sai por'), findsNothing);
    });

    testWidgets('label vazio renderiza sem exceção', (tester) async {
      await _montar(tester, label: '');

      expect(find.text(''), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('DS-34 — o card não formata dinheiro', () {
    testWidgets('o valor sai exatamente como chegou', (tester) async {
      await _montar(tester, valorFormatado: r'R$ 211');

      expect(
        find.text(r'R$ 211'),
        findsOneWidget,
        reason: 'RN-13 é da spec calculo: o card desenha a String recebida',
      );
    });

    testWidgets('valor sem R\$ não ganha R\$, e não é arredondado nem '
        'transformado', (tester) async {
      await _montar(
        tester,
        valorFormatado: '211,49',
        sublinha: 'por cabeça, sem taxa',
      );

      expect(find.text('211,49'), findsOneWidget);
      expect(find.text(r'R$ 211'), findsNothing);
      expect(find.text(r'R$ 211,49'), findsNothing);
      expect(
        find.text('por cabeça, sem taxa'),
        findsOneWidget,
        reason: '§7: a sublinha é corpo, em sentence case — não vai a CAIXA '
            'ALTA',
      );
    });
  });
}
