import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

const double _larguraDoPalco = 320;

/// Três linhas com painéis distinguíveis pelo texto — é assim que o teste
/// afirma **qual** painel está aberto, e não só que existe um.
final List<BoraExpandableItem> _tresLinhas = [
  (titulo: 'rafa', painel: const Text('painel do rafa')),
  (titulo: 'ana', painel: const Text('painel da ana')),
  (titulo: 'léo', painel: const Text('painel do léo')),
];

/// A decoração do painel que mostra [texto].
BoxDecoration _painel(WidgetTester tester, String texto) {
  final caixa = tester.widget<DecoratedBox>(
    find.ancestor(of: find.text(texto), matching: find.byType(DecoratedBox)).first,
  );
  return caixa.decoration as BoxDecoration;
}

Future<void> _montarGrupo(WidgetTester tester) {
  return pumpComponent(
    tester,
    SizedBox(
      width: _larguraDoPalco,
      child: BoraExpandableGroup(linhas: _tresLinhas),
    ),
  );
}

Future<void> _tocar(WidgetTester tester, String titulo) async {
  await tester.tap(find.text(titulo));
  await tester.pumpAndSettle();
}

void main() {
  group('DS-20 — o caret e o painel da linha', () {
    testWidgets('fechada mostra ▾ e não monta o painel', (tester) async {
      await pumpComponent(
        tester,
        SizedBox(
          width: _larguraDoPalco,
          child: BoraExpandableRow(
            titulo: 'rafa',
            aberta: false,
            onAlternar: () {},
            painel: const Text('painel do rafa'),
          ),
        ),
      );

      expect(find.text('▾'), findsOneWidget, reason: '§5: caret ▾ fechado');
      expect(find.text('▴'), findsNothing);
      expect(find.text('painel do rafa'), findsNothing);
    });

    testWidgets('aberta mostra ▴ e o painel em paper com border-top 2px',
        (tester) async {
      await pumpComponent(
        tester,
        SizedBox(
          width: _larguraDoPalco,
          child: BoraExpandableRow(
            titulo: 'rafa',
            aberta: true,
            onAlternar: () {},
            painel: const Text('painel do rafa'),
          ),
        ),
      );

      expect(find.text('▴'), findsOneWidget, reason: '§5: caret ▴ aberto');
      expect(find.text('▾'), findsNothing);
      expect(find.text('painel do rafa'), findsOneWidget);

      final decoracao = _painel(tester, 'painel do rafa');

      expect(
        decoracao.color,
        BoraColors.paper,
        reason: '§5: "painel aberto com fundo paper"',
      );
      expect(
        decoracao.border!.top.width,
        2.0,
        reason: '§5: "border-top 2px"',
      );
      expect(decoracao.border!.top.color, BoraColors.ink, reason: '§3');
      expect(
        decoracao.border!.bottom,
        BorderSide.none,
        reason: '§5 dá ao painel só a borda de cima',
      );
      expect(decoracao.borderRadius, isNull, reason: '§3: canto reto');
    });

    testWidgets('tocar a cabeça da linha emite onAlternar', (tester) async {
      var alternadas = 0;
      await pumpComponent(
        tester,
        SizedBox(
          width: _larguraDoPalco,
          child: BoraExpandableRow(
            titulo: 'rafa',
            aberta: false,
            onAlternar: () => alternadas++,
            painel: const Text('painel do rafa'),
          ),
        ),
      );

      await _tocar(tester, 'rafa');

      expect(alternadas, 1);
      expect(
        find.text('painel do rafa'),
        findsNothing,
        reason: 'a linha é controlada: ela não abre sozinha',
      );
    });
  });

  group('DS-20 — no máximo uma aberta por vez', () {
    testWidgets('o grupo começa com nenhuma aberta', (tester) async {
      await _montarGrupo(tester);

      expect(find.text('painel do rafa'), findsNothing);
      expect(find.text('painel da ana'), findsNothing);
      expect(find.text('painel do léo'), findsNothing);
      expect(
        find.text('▾'),
        findsNWidgets(3),
        reason: 'as três nascem fechadas',
      );
      expect(find.text('▴'), findsNothing);
    });

    testWidgets('abrir a segunda fecha a primeira', (tester) async {
      await _montarGrupo(tester);

      await _tocar(tester, 'rafa');
      expect(find.text('painel do rafa'), findsOneWidget);

      await _tocar(tester, 'ana');

      expect(
        find.text('painel do rafa'),
        findsNothing,
        reason: '§5: "Só 1 aberta por vez (abrir fecha a anterior)"',
      );
      expect(find.text('painel da ana'), findsOneWidget);
      expect(
        find.text('▴'),
        findsNWidgets(1),
        reason: 'um caret aberto na tela inteira',
      );
      expect(find.text('▾'), findsNWidgets(2));
    });

    testWidgets('tocar a que já está aberta fecha e deixa o grupo sem nenhuma',
        (tester) async {
      await _montarGrupo(tester);

      await _tocar(tester, 'ana');
      expect(find.text('painel da ana'), findsOneWidget);

      await _tocar(tester, 'ana');

      expect(find.text('painel da ana'), findsNothing);
      expect(find.text('▴'), findsNothing, reason: 'nenhuma aberta sobrou');
      expect(find.text('▾'), findsNWidgets(3));
    });

    testWidgets('a terceira abre depois de a primeira ter aberto e fechado',
        (tester) async {
      await _montarGrupo(tester);

      await _tocar(tester, 'rafa');
      await _tocar(tester, 'rafa');
      await _tocar(tester, 'léo');

      expect(find.text('painel do léo'), findsOneWidget);
      expect(find.text('painel do rafa'), findsNothing);
      expect(find.text('painel da ana'), findsNothing);
    });
  });

  group('DS-20 — a linha reusa o desenho da linha de lista', () {
    testWidgets('título em 800 14px com o padding de §5', (tester) async {
      await _montarGrupo(tester);

      final estilo = tester.widget<Text>(find.text('rafa')).style!;

      expect(estilo.fontSize, 14.0);
      expect(estilo.fontWeight, FontWeight.w800);
      expect(
        tester.getRect(find.text('rafa')).left,
        tester.getRect(find.byType(BoraExpandableGroup)).left +
            BoraSpacing.linhaLista.left,
        reason: '§5: a linha do accordion tem o padding da linha de lista',
      );
    });
  });
}
