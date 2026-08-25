import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A tabela de §5, relida da spec e não do código: significado, rótulo,
/// fundo e texto.
///
/// "Cores por significado: RECEBE=fundo `ink`, PAGA=fundo `primary`, NO
/// ZERO=branco, ANFITRIÃO=`yellow`, CO-ANFITRIÃO=`purple`/texto branco,
/// CONVIDADO=branco, SÓ VÊ=`wa-bubble`/texto `text-2`."
const Map<BoraStatus, (String, Color, Color)> _tabelaDeStatus = {
  BoraStatus.recebe: ('RECEBE', BoraColors.ink, BoraColors.cream),
  BoraStatus.paga: ('PAGA', BoraColors.primary, BoraColors.ink),
  BoraStatus.noZero: ('NO ZERO', BoraColors.white, BoraColors.ink),
  BoraStatus.anfitriao: ('ANFITRIÃO', BoraColors.yellow, BoraColors.ink),
  BoraStatus.coAnfitriao: (
    'CO-ANFITRIÃO',
    BoraColors.purple,
    BoraColors.white,
  ),
  BoraStatus.convidado: ('CONVIDADO', BoraColors.white, BoraColors.ink),
  BoraStatus.soVe: ('SÓ VÊ', BoraColors.waBubble, BoraColors.text2),
};

BoxDecoration _pill(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(BoraStatusTag),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return caixa.decoration as BoxDecoration;
}

Future<void> _montar(WidgetTester tester, BoraStatus status) =>
    pumpComponent(tester, BoraStatusTag(status: status));

void main() {
  group('DS-22 — os sete significados de §5', () {
    test('o enum tem exatamente os sete de §5, e nenhum a mais', () {
      expect(
        BoraStatus.values.toSet(),
        _tabelaDeStatus.keys.toSet(),
        reason: 'um status novo sem cor declarada quebra aqui',
      );
      expect(BoraStatus.values, hasLength(7));
    });

    for (final entrada in _tabelaDeStatus.entries) {
      final (rotulo, fundo, texto) = entrada.value;

      testWidgets('$rotulo tem o par de cores de §5', (tester) async {
        await _montar(tester, entrada.key);

        expect(find.text(rotulo), findsOneWidget);
        expect(
          _pill(tester).color,
          fundo,
          reason: '§5 fixa o fundo de $rotulo',
        );
        expect(
          tester.widget<Text>(find.text(rotulo)).style!.color,
          texto,
          reason: '§5 fixa o texto de $rotulo',
        );
      });
    }
  });

  group('DS-22 — a pill é quadrada', () {
    testWidgets('borda 2px ink, canto reto e sem sombra', (tester) async {
      await _montar(tester, BoraStatus.anfitriao);

      final decoracao = _pill(tester);

      expect(decoracao.border!.top.width, 2.0, reason: '§5: "Borda 2px ink"');
      expect(decoracao.border!.top.color, BoraColors.ink);
      expect(
        decoracao.borderRadius,
        BorderRadius.zero,
        reason: '§3: "pill quadrada" — o nome é de pastilha, a forma é reta',
      );
      expect(decoracao.boxShadow, isNull);
    });

    testWidgets('padding 4×7 e texto 800 9px com ls .5', (tester) async {
      await _montar(tester, BoraStatus.anfitriao);

      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(BoraStatusTag),
              matching: find.byType(Padding),
            )
            .first,
      );

      expect(
        padding.padding,
        BoraSpacing.tag,
        reason: '§5: "padding 4–6px 7–9px"',
      );
      expect(BoraSpacing.tag.vertical / 2, 4.0);
      expect(BoraSpacing.tag.horizontal / 2, 7.0);

      final estilo = tester.widget<Text>(find.text('ANFITRIÃO')).style!;

      expect(
        estilo.fontSize,
        9.0,
        reason: '§5 pede 9–10.5px e A-02 fixa o piso de 9',
      );
      expect(estilo.fontWeight, FontWeight.w800);
      expect(estilo.letterSpacing, 0.5, reason: '§5: "ls .5px"');
    });
  });

  group('DS-32 — o rótulo sai em CAIXA ALTA', () {
    test('os sete rótulos de §5 já são a copy em caixa alta', () {
      for (final status in BoraStatus.values) {
        expect(
          status.rotulo,
          status.rotulo.toUpperCase(),
          reason: '§7: label em CAIXA ALTA',
        );
      }
    });

    testWidgets('a tag desenha o rótulo em caixa alta', (tester) async {
      await _montar(tester, BoraStatus.soVe);

      expect(find.text('SÓ VÊ'), findsOneWidget);
      expect(find.text('só vê'), findsNothing);
    });
  });
}
