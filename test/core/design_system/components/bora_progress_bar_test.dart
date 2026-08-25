import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A largura do palco. A borda de 2px de cada lado é desenhada por dentro,
/// então o preenchimento percorre `200 − 4`.
const double _larguraDoPalco = 200;
const double _larguraInterna = _larguraDoPalco - 4;

Finder _barra() => find.byType(BoraProgressBar);

/// O preenchimento verde da barra.
Finder _preenchimento() => find.descendant(
      of: _barra(),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == BoraColors.waGreen,
      ),
    );

BoxDecoration _decoracao(WidgetTester tester) {
  final caixa = tester.widget<Container>(
    find.descendant(of: _barra(), matching: find.byType(Container)).first,
  );
  return caixa.decoration! as BoxDecoration;
}

Widget _comLargura(Widget componente) =>
    SizedBox(width: _larguraDoPalco, child: componente);

Future<void> _montar(
  WidgetTester tester, {
  required double fracao,
  bool sobreCardEscuro = true,
}) {
  return pumpComponent(
    tester,
    _comLargura(
      BoraProgressBar(fracao: fracao, sobreCardEscuro: sobreCardEscuro),
    ),
  );
}

void main() {
  group('DS-28 — a caixa da barra', () {
    testWidgets('12px de altura, borda 2px cream e canto reto', (tester) async {
      await _montar(tester, fracao: 0.5);

      final decoracao = _decoracao(tester);

      expect(
        tester.getSize(_barra()).height,
        12.0,
        reason: '§5: "Altura 12px"',
      );
      expect(
        decoracao.border!.top.color,
        BoraColors.cream,
        reason: '§5: "borda 2px cream (sobre card escuro)"',
      );
      expect(decoracao.border!.top.width, 2.0);
      expect(decoracao.borderRadius, BorderRadius.zero, reason: '§3');
      expect(
        decoracao.color,
        isNull,
        reason: '§5 não dá fundo ao trilho: o que se vê é o preenchimento',
      );
    });

    testWidgets('fora do card escuro a borda volta a ser a 2px ink de §3',
        (tester) async {
      await _montar(tester, fracao: 0.5, sobreCardEscuro: false);

      expect(_decoracao(tester).border!.top.color, BoraColors.ink);
      expect(_decoracao(tester).border!.top.width, 2.0);
    });
  });

  group('DS-28 — a fração recebida vira largura', () {
    testWidgets('0.0 não pinta nada', (tester) async {
      await _montar(tester, fracao: 0);

      expect(tester.getSize(_preenchimento()).width, 0.0);
    });

    testWidgets('0.5 pinta metade da largura interna, em waGreen',
        (tester) async {
      await _montar(tester, fracao: 0.5);

      expect(tester.getSize(_preenchimento()).width, _larguraInterna / 2);
      expect(
        tester.getSize(_preenchimento()).height,
        8.0,
        reason: 'a borda de 2px de §3 é desenhada por dentro dos 12px',
      );
      expect(
        tester.widget<ColoredBox>(_preenchimento()).color,
        BoraColors.waGreen,
        reason: '§5: "preenchimento #25D366"',
      );
    });

    testWidgets('1.0 pinta a largura interna inteira', (tester) async {
      await _montar(tester, fracao: 1);

      expect(tester.getSize(_preenchimento()).width, _larguraInterna);
      expect(
        tester.getRect(_preenchimento()).left,
        tester.getRect(_barra()).left + 2,
        reason: 'o preenchimento cresce da esquerda para a direita',
      );
    });
  });

  group('DS-28 — fração fora da faixa e não finita', () {
    testWidgets('menor que 0 clampa para 0, sem lançar', (tester) async {
      await _montar(tester, fracao: -0.3);

      expect(tester.getSize(_preenchimento()).width, 0.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('maior que 1 clampa para 1, sem lançar', (tester) async {
      await _montar(tester, fracao: 1.7);

      expect(tester.getSize(_preenchimento()).width, _larguraInterna);
      expect(tester.takeException(), isNull);
    });

    testWidgets('NaN e infinito não pintam nada, sem lançar', (tester) async {
      await _montar(tester, fracao: double.nan);
      expect(tester.getSize(_preenchimento()).width, 0.0);
      expect(tester.takeException(), isNull);

      await _montar(tester, fracao: double.infinity);
      expect(tester.getSize(_preenchimento()).width, 0.0);
      expect(tester.takeException(), isNull);
    });
  });

  group('DS-28 — a largura anima em 300ms', () {
    testWidgets('a barra sai de vazia e chega cheia em 300ms', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: boraTheme(),
          home: Scaffold(
            body: Center(child: _comLargura(const BoraProgressBar(fracao: 0))),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          theme: boraTheme(),
          home: Scaffold(
            body: Center(child: _comLargura(const BoraProgressBar(fracao: 1))),
          ),
        ),
      );

      expect(
        tester.getSize(_preenchimento()).width,
        0.0,
        reason: 'no primeiro frame a largura ainda é a antiga',
      );

      await tester.pump(const Duration(milliseconds: 150));
      final meio = tester.getSize(_preenchimento()).width;
      expect(meio, greaterThan(0.0));
      expect(
        meio,
        lessThan(_larguraInterna),
        reason: '§6: "Progresso: width .3s" — no meio do caminho a barra está '
            'no meio, não no fim',
      );

      await tester.pump(const Duration(milliseconds: 150));
      expect(
        tester.getSize(_preenchimento()).width,
        _larguraInterna,
        reason: 'passados os 300ms de BoraMotion.progresso, a barra chegou',
      );
      expect(BoraMotion.progresso.inMilliseconds, 300);
    });
  });
}
