import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A largura do palco. O marcador percorre `largura − 8` (a própria
/// espessura), então em 200px o passo é 192px.
const double _larguraDoPalco = 200;
const double _percursoDoMarcador =
    _larguraDoPalco - BoraPriceRangeBar.larguraDoMarcador;

/// A caixa pintada em [cor] dentro da barra.
Finder _caixa(Color cor) => find.descendant(
      of: find.byType(BoraPriceRangeBar),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            (widget.decoration as BoxDecoration).color == cor,
      ),
    );

Finder _trilho() => _caixa(BoraColors.paper2);
Finder _marcador() => _caixa(BoraColors.primary);

BoxDecoration _decoracao(WidgetTester tester, Finder finder) =>
    tester.widget<DecoratedBox>(finder).decoration as BoxDecoration;

Future<void> _montar(
  WidgetTester tester, {
  required double fracao,
  String rotuloMin = r'R$ 180',
  String rotuloMax = r'R$ 260',
}) {
  return pumpComponent(
    tester,
    SizedBox(
      width: _larguraDoPalco,
      child: BoraPriceRangeBar(
        fracao: fracao,
        rotuloMin: rotuloMin,
        rotuloMax: rotuloMax,
      ),
    ),
  );
}

/// A distância entre a ponta esquerda do trilho e a do marcador.
double _deslocamento(WidgetTester tester) =>
    tester.getRect(_marcador()).left - tester.getRect(_trilho()).left;

void main() {
  group('DS-27 — o trilho', () {
    testWidgets('8px de altura, fundo paper-2, borda 2px ink e canto reto',
        (tester) async {
      await _montar(tester, fracao: 0.5);

      final decoracao = _decoracao(tester, _trilho());

      expect(
        tester.getSize(_trilho()).height,
        8.0,
        reason: '§5: "Trilho 8px"',
      );
      expect(tester.getSize(_trilho()).width, _larguraDoPalco);
      expect(decoracao.color, BoraColors.paper2, reason: '§5: "fundo paper-2"');
      expect(decoracao.border!.top.width, 2.0, reason: '§5: "borda 2px ink"');
      expect(decoracao.border!.top.color, BoraColors.ink);
      expect(decoracao.borderRadius, BorderRadius.zero, reason: '§3');
    });
  });

  group('DS-27 — o marcador', () {
    testWidgets('8×12px, fundo primary, borda 2px ink e canto reto',
        (tester) async {
      await _montar(tester, fracao: 0.5);

      final decoracao = _decoracao(tester, _marcador());

      expect(
        tester.getSize(_marcador()),
        const Size(8, 12),
        reason: '§5: "marcador 8×12px"',
      );
      expect(decoracao.color, BoraColors.primary, reason: '§5: "fundo primary"');
      expect(decoracao.border!.top.width, 2.0);
      expect(decoracao.border!.top.color, BoraColors.ink);
      expect(decoracao.borderRadius, BorderRadius.zero, reason: '§3');
    });

    testWidgets('mais alto que o trilho, vazando igual dos dois lados',
        (tester) async {
      await _montar(tester, fracao: 0.5);

      final trilho = tester.getRect(_trilho());
      final marcador = tester.getRect(_marcador());

      expect(trilho.top - marcador.top, 2.0);
      expect(marcador.bottom - trilho.bottom, 2.0);
    });
  });

  group('DS-27 — a fração recebida vira posição', () {
    testWidgets('0.0 encosta na ponta esquerda do trilho', (tester) async {
      await _montar(tester, fracao: 0);

      expect(_deslocamento(tester), 0.0);
    });

    testWidgets('0.5 põe o marcador no meio do trilho', (tester) async {
      await _montar(tester, fracao: 0.5);

      expect(_deslocamento(tester), _percursoDoMarcador / 2);
      expect(
        tester.getRect(_marcador()).center.dx,
        tester.getRect(_trilho()).center.dx,
        reason: 'meia faixa ⇒ meio do trilho',
      );
    });

    testWidgets('1.0 encosta na ponta direita do trilho', (tester) async {
      await _montar(tester, fracao: 1);

      expect(_deslocamento(tester), _percursoDoMarcador);
      expect(
        tester.getRect(_marcador()).right,
        tester.getRect(_trilho()).right,
      );
    });

    testWidgets('uma fração intermediária pousa exatamente na proporção dela',
        (tester) async {
      await _montar(tester, fracao: 0.25);

      expect(
        _deslocamento(tester),
        _percursoDoMarcador * 0.25,
        reason: '§5: o marcador fica em (média−mín)/(máx−mín) da largura',
      );
    });
  });

  group('DS-27 — fração fora da faixa e não finita', () {
    testWidgets('menor que 0 clampa para 0, sem lançar', (tester) async {
      await _montar(tester, fracao: -0.3);

      expect(_deslocamento(tester), 0.0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('maior que 1 clampa para 1, sem lançar', (tester) async {
      await _montar(tester, fracao: 1.7);

      expect(_deslocamento(tester), _percursoDoMarcador);
      expect(tester.takeException(), isNull);
    });

    testWidgets('NaN vai para o extremo esquerdo, sem lançar', (tester) async {
      await _montar(tester, fracao: double.nan);

      expect(
        _deslocamento(tester),
        0.0,
        reason: 'edge case da spec: min == max produz NaN lá na origem',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('infinito e −infinito vão para o extremo esquerdo',
        (tester) async {
      await _montar(tester, fracao: double.infinity);
      expect(_deslocamento(tester), 0.0);
      expect(tester.takeException(), isNull);

      await _montar(tester, fracao: double.negativeInfinity);
      expect(_deslocamento(tester), 0.0);
      expect(tester.takeException(), isNull);
    });
  });

  group('DS-27 e DS-34 — os extremos rotulados', () {
    testWidgets('700 10px text-3, abaixo do trilho, mín à esquerda',
        (tester) async {
      await _montar(tester, fracao: 0.5);

      final estilo = tester.widget<Text>(find.text(r'R$ 180')).style!;
      final minimo = tester.getRect(find.text(r'R$ 180'));
      final maximo = tester.getRect(find.text(r'R$ 260'));
      final trilho = tester.getRect(_trilho());

      expect(estilo.fontSize, 10.0, reason: '§5: "700 10px text-3"');
      expect(estilo.fontWeight, FontWeight.w700);
      expect(estilo.color, BoraColors.text3);
      expect(
        minimo.top,
        greaterThanOrEqualTo(trilho.bottom),
        reason: '§5: "extremos rotulados abaixo"',
      );
      expect(minimo.left, lessThan(maximo.left));
      expect(minimo.left, trilho.left);
      expect(maximo.right, trilho.right);
    });

    testWidgets('os rótulos saem exatamente como chegaram', (tester) async {
      await _montar(tester, fracao: 0.5, rotuloMin: '180', rotuloMax: '260');

      expect(
        find.text('180'),
        findsOneWidget,
        reason: 'RN-13 é da spec calculo: a barra desenha a String recebida',
      );
      expect(find.text('260'), findsOneWidget);
      expect(find.text(r'R$ 180'), findsNothing);
    });
  });
}
