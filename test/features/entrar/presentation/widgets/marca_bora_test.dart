import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/entrar/presentation/widgets/divisor_ou.dart';
import 'package:bora/features/entrar/presentation/widgets/marca_bora.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/pump_component.dart';

/// O `Text` do logo montado.
///
/// A asserção mira o widget, e não o `RichText` que ele constrói: `Text.rich`
/// embrulha o span recebido num span externo, e ler a árvore interna faria o
/// teste afirmar um nível que não é o contrato do widget.
Text _logo(WidgetTester tester) =>
    tester.widget<Text>(find.byType(Text));

/// O span do ponto final.
TextSpan _ponto(WidgetTester tester) =>
    (_logo(tester).textSpan! as TextSpan).children!.single as TextSpan;

void main() {
  group('ENT-03/ENT-04 — o logo "BORA." com o ponto vermelho', () {
    testWidgets('renderiza BORA e o ponto', (tester) async {
      await pumpComponent(tester, const MarcaBora.compacta());

      expect(_logo(tester).textSpan!.toPlainText(), 'BORA.');
    });

    testWidgets('o ponto é o acento vermelho e o nome fica em ink',
        (tester) async {
      await pumpComponent(tester, const MarcaBora.compacta());

      expect(
        _logo(tester).style?.color,
        BoraColors.ink,
        reason: 'comparado com o token, não com o literal: literal no teste '
            'concorda com literal no widget',
      );
      expect(
        _ponto(tester).style?.color,
        BoraColors.primary,
        reason: 'T-01: o ponto é o único acento do logo',
      );
    });

    testWidgets('a compacta usa o papel tipográfico de 64px do arquivo 02',
        (tester) async {
      await pumpComponent(tester, const MarcaBora.compacta());
      final estilo = _logo(tester).style!;

      expect(estilo.fontSize, MarcaBora.tamanhoCompacto);
      expect(estilo.fontSize, BoraTextStyles.logoHero.fontSize);
      expect(estilo.fontFamily, BoraTextStyles.familiaDisplay);
      expect(estilo.letterSpacing, -2);
    });

    testWidgets('a expandida sobe o degrau de W-01: 92px e ls −3',
        (tester) async {
      await pumpComponent(tester, const MarcaBora.expandida());
      final estilo = _logo(tester).style!;

      expect(estilo.fontSize, MarcaBora.tamanhoExpandido);
      expect(estilo.letterSpacing, -3);
      expect(
        estilo.fontFamily,
        BoraTextStyles.familiaDisplay,
        reason: 'o degrau muda o tamanho, não a família — quem manda na '
            'família continua sendo o token',
      );
    });

    testWidgets('os dois tamanhos são de fato diferentes', (tester) async {
      await pumpComponent(tester, const MarcaBora.compacta());
      final compacto = _logo(tester).style!.fontSize;

      await pumpComponent(tester, const MarcaBora.expandida());
      final expandido = _logo(tester).style!.fontSize;

      expect(
        compacto,
        isNot(expandido),
        reason: 'anti-vácuo: um construtor que ignorasse o tamanho passaria '
            'em metade dos testes acima por acidente',
      );
    });
  });

  group('ENT-03 — o divisor "OU"', () {
    testWidgets('renderiza o rótulo literal de T-01', (tester) async {
      await pumpComponent(tester, const DivisorOu());

      expect(find.text('OU'), findsOneWidget);
    });

    testWidgets('duas linhas de 2px na cor de divisor de 13%', (tester) async {
      await pumpComponent(tester, const DivisorOu());

      final linhas = find.descendant(
        of: find.byType(DivisorOu),
        matching: find.byType(ColoredBox),
      );

      expect(linhas, findsNWidgets(2), reason: 'T-01: uma linha de cada lado');

      for (var i = 0; i < 2; i++) {
        expect(
          tester.widget<ColoredBox>(linhas.at(i)).color,
          BoraColors.divider2,
          reason: 'T-01 pede 13%, que é o token divider2',
        );
        expect(tester.getSize(linhas.at(i)).height, DivisorOu.espessura);
      }
    });
  });
}
