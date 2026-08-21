import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// As cinco personas de RN-30 com o par de cores que §1 fixa para cada uma,
/// e a inicial que A-13 manda desenhar.
const List<(String, String, Color, Color)> _personas = [
  ('Rafa', 'R', BoraColors.primary, BoraColors.white),
  ('Ana', 'A', BoraColors.yellow, BoraColors.ink),
  ('Léo', 'L', BoraColors.purple, BoraColors.white),
  ('Bia', 'B', BoraColors.green, BoraColors.white),
  ('Duda', 'D', BoraColors.ink, BoraColors.cream),
];

/// A decoração do círculo que mostra [inicial].
BoxDecoration _circulo(WidgetTester tester, String inicial) {
  final caixa = tester.widget<DecoratedBox>(
    find.ancestor(of: find.text(inicial), matching: find.byType(DecoratedBox)).first,
  );
  return caixa.decoration as BoxDecoration;
}

TextStyle _estilo(WidgetTester tester, String texto) =>
    tester.widget<Text>(find.text(texto)).style!;

void main() {
  group('DS-21 — o avatar é círculo, exceção de forma de §3', () {
    testWidgets('34px, borda 2px ink e a inicial em 800', (tester) async {
      await pumpComponent(tester, const BoraAvatar(nome: 'Rafa'));

      final decoracao = _circulo(tester, 'R');

      expect(
        decoracao.shape,
        BoxShape.circle,
        reason: '§3: "Exceções: avatares e dots (círculo, 50%)"',
      );
      expect(decoracao.border!.top.width, 2.0, reason: '§5: "borda 2px ink"');
      expect(decoracao.border!.top.color, BoraColors.ink);
      expect(
        tester.getSize(find.byType(BoraAvatar)),
        const Size(34, 34),
        reason: '§5: "34–40px"',
      );
      expect(
        _estilo(tester, 'R').fontWeight,
        FontWeight.w800,
        reason: '§5: "iniciais 800"',
      );
    });

    testWidgets('a inicial é a primeira letra, em CAIXA ALTA', (tester) async {
      await pumpComponent(tester, const BoraAvatar(nome: 'rafa'));

      expect(
        find.text('R'),
        findsOneWidget,
        reason: 'A-13: a primeira letra do nome, em CAIXA ALTA',
      );
      expect(find.text('r'), findsNothing);
      expect(find.text('RAFA'), findsNothing);
      expect(BoraAvatar.inicialDe('ana clara'), 'A');
    });
  });

  group('DS-21 — as cores de §1', () {
    testWidgets('cada uma das cinco personas usa o par fixo de §1',
        (tester) async {
      await pumpComponent(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final persona in _personas) BoraAvatar(nome: persona.$1),
          ],
        ),
      );

      for (final persona in _personas) {
        expect(
          _circulo(tester, persona.$2).color,
          persona.$3,
          reason: '§1 fixa o fundo de ${persona.$1}',
        );
        expect(
          _estilo(tester, persona.$2).color,
          persona.$4,
          reason: '§1 fixa o texto de ${persona.$1}',
        );
      }
    });

    testWidgets('nome de fora da tabela cai num dos mesmos cinco pares',
        (tester) async {
      await pumpComponent(tester, const BoraAvatar(nome: 'Marina'));

      final fundo = _circulo(tester, 'M').color;
      final texto = _estilo(tester, 'M').color;

      expect(
        _personas.map((persona) => persona.$3),
        contains(fundo),
        reason: 'A-05: paleta nova violaria "nenhuma cor fora dos tokens"',
      );
      expect(
        _personas.singleWhere((persona) => persona.$3 == fundo).$4,
        texto,
        reason: 'o par de §1 vem inteiro: fundo e texto do mesmo dono',
      );
    });

    testWidgets('o mesmo nome recebe sempre a mesma cor', (tester) async {
      await pumpComponent(tester, const BoraAvatar(nome: 'Marina'));
      final primeira = _circulo(tester, 'M').color;

      await pumpComponent(tester, const BoraAvatar(nome: 'Marina'));

      expect(
        _circulo(tester, 'M').color,
        primeira,
        reason: 'A-05: checksum determinístico — a pilha não pisca de cor',
      );
    });
  });

  group('DS-21 — a pilha e o slot "+N"', () {
    testWidgets('os avatares se sobrepõem em -8px', (tester) async {
      await pumpComponent(
        tester,
        const BoraStackedAvatars(nomes: ['Rafa', 'Ana', 'Léo']),
      );

      final avatares = find.byType(BoraAvatar);
      final primeiro = tester.getRect(avatares.at(0));
      final segundo = tester.getRect(avatares.at(1));

      expect(avatares, findsNWidgets(3));
      expect(
        segundo.left - primeiro.right,
        BoraStackedAvatars.sobreposicaoPadrao,
        reason: '§5: "sobreposição margin-left: -8 a -10px"',
      );
      expect(BoraStackedAvatars.sobreposicaoPadrao, -8.0);
      expect(
        BoraStackedAvatars.sobreposicaoPadrao,
        inInclusiveRange(-10, -8),
        reason: 'a faixa que §5 declara',
      );
    });

    testWidgets('o último slot é "+N" branco com borda tracejada',
        (tester) async {
      await pumpComponent(
        tester,
        const BoraStackedAvatars(nomes: ['Rafa', 'Ana'], extras: 3),
      );

      expect(find.text('+3'), findsOneWidget);

      final decoracao = _circulo(tester, '+3');

      expect(
        decoracao.color,
        BoraColors.white,
        reason: '§1: "slot +N branco com borda tracejada"',
      );
      expect(decoracao.shape, BoxShape.circle);
      expect(
        decoracao.border,
        isNull,
        reason: 'a borda do slot é tracejada — não é a borda sólida de §3',
      );

      final pintura = tester.widget<CustomPaint>(
        find.ancestor(of: find.text('+3'), matching: find.byType(CustomPaint)).first,
      );
      final tracejado = pintura.foregroundPainter! as BoraDashedCirclePainter;

      expect(
        tracejado.cor,
        BoraBorders.slotTracejado.cor,
        reason: '§3: o tracejado de slot é 2px #9b9b9b',
      );
      expect(tracejado.largura, 2.0);
      expect(
        BoraDashedCirclePainter.vao,
        greaterThan(0),
        reason: 'sem vão não há tracejado, só um traço contínuo',
      );
    });

    testWidgets('o slot fica à direita do último avatar', (tester) async {
      await pumpComponent(
        tester,
        const BoraStackedAvatars(nomes: ['Rafa', 'Ana'], extras: 3),
      );

      expect(
        tester.getRect(find.text('+3')).left,
        greaterThan(tester.getRect(find.text('A')).left),
        reason: '§5: "último slot +N"',
      );
    });

    testWidgets('com +0 o slot não é renderizado', (tester) async {
      await pumpComponent(
        tester,
        const BoraStackedAvatars(nomes: ['Rafa', 'Ana']),
      );

      expect(
        find.text('+0'),
        findsNothing,
        reason: 'edge case da spec: "+0" não é informação',
      );
      expect(find.byType(CustomPaint).evaluate().where((elemento) {
        final widget = elemento.widget as CustomPaint;
        return widget.foregroundPainter is BoraDashedCirclePainter;
      }), isEmpty);
      expect(find.byType(BoraAvatar), findsNWidgets(2));
    });

    testWidgets('pilha sem ninguém e sem extras não desenha círculo nenhum',
        (tester) async {
      await pumpComponent(tester, const BoraStackedAvatars(nomes: []));

      expect(find.byType(BoraAvatar), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
