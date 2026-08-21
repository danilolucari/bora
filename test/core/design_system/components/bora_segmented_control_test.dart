import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

const List<String> _opcoes = ['todos', 'quem paga', 'quem recebe'];

/// A largura do palco onde o segmented divide o espaço.
const double _larguraDoPalco = 300;

/// A decoração do **container** do segmented: a mais externa da subárvore.
/// As de dentro são as dos botões.
BoxDecoration _container(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(BoraSegmentedControl),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return caixa.decoration as BoxDecoration;
}

/// A decoração do botão que mostra [rotulo]: o `DecoratedBox` mais próximo
/// acima do texto.
BoxDecoration _botao(WidgetTester tester, String rotulo) {
  final caixa = tester.widget<DecoratedBox>(
    find.ancestor(of: find.text(rotulo), matching: find.byType(DecoratedBox)).first,
  );
  return caixa.decoration as BoxDecoration;
}

Color _corDoTexto(WidgetTester tester, String rotulo) =>
    tester.widget<Text>(find.text(rotulo)).style!.color!;

/// Os divisores da árvore: caixas de 2px na cor pedida por §5.
Finder _divisores(Color cor) => find.descendant(
      of: find.byType(BoraSegmentedControl),
      matching: find.byWidgetPredicate(
        (widget) => widget is ColoredBox && widget.color == cor,
      ),
    );

Future<void> _montar(
  WidgetTester tester, {
  List<String> opcoes = _opcoes,
  int indiceAtivo = 0,
  bool sobreCardEscuro = false,
  ValueChanged<int>? onSelecionar,
}) {
  return pumpComponent(
    tester,
    SizedBox(
      width: _larguraDoPalco,
      child: BoraSegmentedControl(
        opcoes: opcoes,
        indiceAtivo: indiceAtivo,
        sobreCardEscuro: sobreCardEscuro,
        onSelecionar: onSelecionar ?? (_) {},
      ),
    ),
  );
}

void main() {
  group('DS-16 — o container e a divisão da largura', () {
    testWidgets('borda 2px ink sobre branco, canto reto', (tester) async {
      await _montar(tester);

      final decoracao = _container(tester);

      expect(
        decoracao.color,
        BoraColors.white,
        reason: '§5: "Container com borda 2px ink sobre branco"',
      );
      expect(decoracao.border!.top.width, 2.0);
      expect(decoracao.border!.top.color, BoraColors.ink);
      expect(decoracao.borderRadius, BorderRadius.zero, reason: '§3');
    });

    testWidgets('os botões dividem a largura igualmente', (tester) async {
      await _montar(tester);

      final botoes = find.descendant(
        of: find.byType(BoraSegmentedControl),
        matching: find.byType(AnimatedContainer),
      );
      // O que sobra do palco depois dos dois divisores de 2px. A borda da
      // superfície não entra na conta: `DecoratedBox` pinta a borda **sobre**
      // o conteúdo em vez de reservar espaço para ela.
      const esperada = (_larguraDoPalco - 2 * 2) / 3;

      for (var indice = 0; indice < _opcoes.length; indice++) {
        expect(
          tester.getSize(botoes.at(indice)).width,
          closeTo(esperada, 0.01),
          reason: '§5: os botões são "flex:1"',
        );
      }
    });
  });

  group('DS-16 — exatamente um ativo', () {
    testWidgets('o ativo é ink + cream e os inativos transparentes + text-2',
        (tester) async {
      await _montar(tester, indiceAtivo: 1);

      expect(
        _botao(tester, 'QUEM PAGA').color,
        BoraColors.ink,
        reason: '§5: "ativo = fundo ink + texto cream"',
      );
      expect(_corDoTexto(tester, 'QUEM PAGA'), BoraColors.cream);

      for (final inativo in ['TODOS', 'QUEM RECEBE']) {
        expect(
          _botao(tester, inativo).color,
          Colors.transparent,
          reason: '§5: "inativo = transparente + text-2"',
        );
        expect(_corDoTexto(tester, inativo), BoraColors.text2);
      }
    });

    testWidgets('a troca de ativo anda na transição .15s de §6',
        (tester) async {
      await _montar(tester);

      final animado = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.byType(BoraSegmentedControl),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );

      expect(animado.duration, BoraMotion.estado);
      expect(
        animado.duration,
        const Duration(milliseconds: 150),
        reason: '§6: "transition: all .15s em chips, segmented, botões"',
      );
    });
  });

  group('DS-16 — os divisores', () {
    testWidgets('com 3 opções há 2 divisores de 2px em divider-2',
        (tester) async {
      await _montar(tester);

      final divisores = _divisores(BoraColors.divider2);

      expect(
        divisores,
        findsNWidgets(2),
        reason: '§5: com n opções há n-1 divisores',
      );
      expect(
        tester.getSize(divisores.first).width,
        2.0,
        reason: '§5: "divisor 2px divider-2"',
      );
    });

    testWidgets('com 1 opção não há divisor nenhum', (tester) async {
      await _montar(tester, opcoes: const ['todos']);

      expect(
        _divisores(BoraColors.divider2),
        findsNothing,
        reason: 'edge case da spec: uma opção só renderiza sem divisor',
      );
      expect(find.text('TODOS'), findsOneWidget);
    });
  });

  group('DS-16 — a variante sobre card escuro', () {
    testWidgets('borda e divisores em cream/25%', (tester) async {
      await _montar(tester, sobreCardEscuro: true);

      expect(
        _container(tester).border!.top.color,
        BoraColors.creamQuarter,
        reason: '§5: "borda e divisores em cream/25%"',
      );
      expect(_container(tester).border!.top.width, 2.0);
      expect(_divisores(BoraColors.creamQuarter), findsNWidgets(2));
      expect(
        _divisores(BoraColors.divider2),
        findsNothing,
        reason: 'o divisor claro não sobrevive à variante escura',
      );
    });

    testWidgets('o ativo muda só o texto para cream', (tester) async {
      await _montar(tester, sobreCardEscuro: true, indiceAtivo: 1);

      expect(
        _botao(tester, 'QUEM PAGA').color,
        Colors.transparent,
        reason: '§5: sobre card escuro o ativo NÃO ganha fundo ink',
      );
      expect(_corDoTexto(tester, 'QUEM PAGA'), BoraColors.cream);
      expect(_corDoTexto(tester, 'TODOS'), BoraColors.text2);
    });
  });

  group('DS-16 — o índice é prop, não estado', () {
    testWidgets('tocar emite o índice e não muda o ativo sozinho',
        (tester) async {
      final emitidos = <int>[];
      await _montar(tester, onSelecionar: emitidos.add);

      await tester.tap(find.text('QUEM RECEBE'));
      await tester.pumpAndSettle();

      expect(emitidos, [2], reason: 'o índice tocado, sem payload extra');
      expect(
        _botao(tester, 'TODOS').color,
        BoraColors.ink,
        reason: 'o ativo continua o da prop: o componente não guarda seleção',
      );
      expect(_botao(tester, 'QUEM RECEBE').color, Colors.transparent);
    });
  });

  group('DS-32 — os rótulos saem em CAIXA ALTA', () {
    testWidgets('entra "quem paga", sai "QUEM PAGA"', (tester) async {
      await _montar(tester);

      expect(find.text('QUEM PAGA'), findsOneWidget);
      expect(find.text('quem paga'), findsNothing);
    });
  });
}
