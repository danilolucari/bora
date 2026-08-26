import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// O `Text` do logo montado.
///
/// A asserção mira o widget, e não o `RichText` que ele constrói: `Text.rich`
/// embrulha o span recebido num span externo, e ler a árvore interna faria o
/// teste afirmar um nível que não é o contrato do widget.
Text _logo(WidgetTester tester) => tester.widget<Text>(find.byType(Text));

/// O span do ponto final.
TextSpan _ponto(WidgetTester tester) =>
    (_logo(tester).textSpan! as TextSpan).children!.single as TextSpan;

void main() {
  group('ENT-03/ENT-04 — o logo "BORA." com o ponto vermelho', () {
    testWidgets('renderiza BORA e o ponto', (tester) async {
      await pumpComponent(tester, const BoraMarca.compacta());

      expect(_logo(tester).textSpan!.toPlainText(), 'BORA.');
    });

    testWidgets('o ponto é o acento vermelho e o nome fica em ink',
        (tester) async {
      await pumpComponent(tester, const BoraMarca.compacta());

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
      await pumpComponent(tester, const BoraMarca.compacta());
      final estilo = _logo(tester).style!;

      expect(estilo.fontSize, BoraMarca.tamanhoCompacto);
      expect(estilo.fontSize, BoraTextStyles.logoHero.fontSize);
      expect(estilo.fontFamily, BoraTextStyles.familiaDisplay);
      expect(estilo.letterSpacing, -2);
    });

    testWidgets('a expandida sobe o degrau de W-01: 92px e ls −3',
        (tester) async {
      await pumpComponent(tester, const BoraMarca.expandida());
      final estilo = _logo(tester).style!;

      expect(estilo.fontSize, BoraMarca.tamanhoExpandido);
      expect(estilo.letterSpacing, -3);
      expect(
        estilo.fontFamily,
        BoraTextStyles.familiaDisplay,
        reason: 'o degrau muda o tamanho, não a família — quem manda na '
            'família continua sendo o token',
      );
    });

    testWidgets('os dois tamanhos são de fato diferentes', (tester) async {
      await pumpComponent(tester, const BoraMarca.compacta());
      final compacto = _logo(tester).style!.fontSize;

      await pumpComponent(tester, const BoraMarca.expandida());
      final expandido = _logo(tester).style!.fontSize;

      expect(
        compacto,
        isNot(expandido),
        reason: 'anti-vácuo: um construtor que ignorasse o tamanho passaria '
            'em metade dos testes acima por acidente',
      );
    });
  });

  group('HOME-01 — a marca de 20px do header de app', () {
    testWidgets('o header usa 20px, o tamanho do arquivo 06', (tester) async {
      await pumpComponent(tester, const BoraMarca.header());
      final estilo = _logo(tester).style!;

      expect(estilo.fontSize, BoraMarca.tamanhoHeader);
      expect(estilo.fontSize, 20);
    });

    testWidgets('é a mesma marca: BORA em ink e o ponto vermelho',
        (tester) async {
      await pumpComponent(tester, const BoraMarca.header());

      expect(_logo(tester).textSpan!.toPlainText(), 'BORA.');
      expect(_logo(tester).style?.color, BoraColors.ink);
      expect(_ponto(tester).style?.color, BoraColors.primary);
    });

    testWidgets('e a mesma família de display de §2', (tester) async {
      await pumpComponent(tester, const BoraMarca.header());

      expect(
        _logo(tester).style!.fontFamily,
        BoraTextStyles.familiaDisplay,
      );
    });

    testWidgets('o header é menor que os outros dois tamanhos',
        (tester) async {
      await pumpComponent(tester, const BoraMarca.header());

      expect(
        _logo(tester).style!.fontSize,
        lessThan(BoraMarca.tamanhoCompacto),
        reason: 'anti-vácuo: um construtor que ignorasse o tamanho cairia no '
            'papel de 64px de §2 e passaria despercebido',
      );
    });

    test('a ls do header é a do papel de §2 mais próximo, não um número '
        'inventado', () {
      expect(
        BoraMarca.espacamentoHeader,
        BoraTextStyles.tituloTela.letterSpacing,
        reason: 'SPEC_PRECISION_GAP: `06` dá o tamanho do logo do header e '
            'não dá a letter-spacing. Se §2 mudar o papel, isto quebra em vez '
            'de o header ficar com um número órfão',
      );
    });
  });
}
