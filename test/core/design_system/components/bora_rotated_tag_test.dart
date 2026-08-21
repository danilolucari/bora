import 'dart:math' as math;

import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// O card sob a tag, para provar o vazamento do topo.
const Key _cartao = Key('cartao');
const Size _tamanhoDoCartao = Size(240, 72);

/// Os `Transform` que a tag monta: o de fora translada, o de dentro gira.
Matrix4 _matriz(WidgetTester tester, int indice) => tester
    .widget<Transform>(
      find
          .descendant(
            of: find.byType(BoraRotatedTag),
            matching: find.byType(Transform),
          )
          .at(indice),
    )
    .transform;

/// O ângulo que a matriz de rotação carrega, em radianos.
double _anguloDe(Matrix4 matriz) =>
    math.atan2(matriz.storage[1], matriz.storage[0]);

BoxDecoration _pill(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(BoraRotatedTag),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return caixa.decoration as BoxDecoration;
}

/// Monta a tag sobre um card, sem recorte — é assim que §3 a desenha.
Future<void> _montarSobreCartao(
  WidgetTester tester, {
  required bool aEsquerda,
  BoraAccent acento = BoraAccent.primary,
  String texto = 'auto',
}) {
  return pumpComponent(
    tester,
    Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox.fromSize(
          size: _tamanhoDoCartao,
          child: const ColoredBox(key: _cartao, color: BoraColors.white),
        ),
        Positioned(
          left: 12,
          top: 0,
          child: BoraRotatedTag(
            texto: texto,
            acento: acento,
            aEsquerda: aEsquerda,
          ),
        ),
      ],
    ),
  );
}

void main() {
  group('DS-24 — as duas inclinações de §3, em radianos', () {
    testWidgets('a variante da esquerda gira -2°', (tester) async {
      await _montarSobreCartao(tester, aEsquerda: true);

      expect(
        _anguloDe(_matriz(tester, 1)),
        closeTo(-2 * math.pi / 180, 1e-12),
        reason: '§3: "rotate(-2deg) (esq.)" — grau cru seria erro silencioso',
      );
      expect(BoraRotatedTag.grausAEsquerda, -2.0);
      expect(
        BoraRotatedTag.radianosDe(BoraRotatedTag.grausAEsquerda),
        -2 * math.pi / 180,
      );
    });

    testWidgets('a variante da direita gira +3°', (tester) async {
      await _montarSobreCartao(tester, aEsquerda: false);

      expect(
        _anguloDe(_matriz(tester, 1)),
        closeTo(3 * math.pi / 180, 1e-12),
        reason: '§3: "rotate(3deg) (dir.)"',
      );
      expect(BoraRotatedTag.grausADireita, 3.0);
    });
  });

  group('DS-24 — a tag vaza o topo do card em -13px', () {
    testWidgets('o deslocamento vertical é -13', (tester) async {
      await _montarSobreCartao(tester, aEsquerda: true);

      expect(
        _matriz(tester, 0).storage[13],
        -13.0,
        reason: '§3: "posicionadas vazando o card (top:-13px)"',
      );
      expect(BoraRotatedTag.vazamentoDoTopo, -13.0);
    });

    testWidgets('a tag continua visível acima da borda do card',
        (tester) async {
      await _montarSobreCartao(tester, aEsquerda: true);

      final topoDoCartao = tester.getRect(find.byKey(_cartao)).top;

      expect(
        tester.getRect(find.text('AUTO')).top,
        lessThan(topoDoCartao),
        reason: 'o vazamento é o ponto: a tag sai dos limites do pai',
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('DS-24 — o fundo, a borda e a forma', () {
    testWidgets('fundo primary, borda 2px ink e canto reto', (tester) async {
      await _montarSobreCartao(tester, aEsquerda: true);

      final decoracao = _pill(tester);

      expect(
        decoracao.color,
        BoraColors.primary,
        reason: '§3: "fundo primary ou yellow"',
      );
      expect(decoracao.border!.top.width, 2.0);
      expect(decoracao.border!.top.color, BoraColors.ink);
      expect(decoracao.borderRadius, BorderRadius.zero, reason: '§3');
    });

    testWidgets('fundo yellow na outra variante de acento', (tester) async {
      await _montarSobreCartao(
        tester,
        aEsquerda: false,
        acento: BoraAccent.yellow,
      );

      expect(_pill(tester).color, BoraColors.yellow);
    });
  });

  group('DS-32 — a copy da tag sai em CAIXA ALTA', () {
    testWidgets('entra "auto", sai "AUTO", no token microTag', (tester) async {
      await _montarSobreCartao(tester, aEsquerda: true);

      expect(find.text('AUTO'), findsOneWidget);
      expect(find.text('auto'), findsNothing);

      final estilo = tester.widget<Text>(find.text('AUTO')).style!;

      expect(estilo.fontSize, 9.0);
      expect(estilo.fontWeight, FontWeight.w800);
      expect(estilo.letterSpacing, 0.5);
      expect(estilo.color, BoraColors.ink);
    });
  });
}
