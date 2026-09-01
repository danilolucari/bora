import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/montar/presentation/bloc/montar_event.dart';
import 'package:bora/features/montar/presentation/widgets/card_de_contagem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';
import '../../../../support/cifrao_na_fonte.dart';

const String _arquivoDoCard =
    'lib/features/montar/presentation/widgets/card_de_contagem.dart';

/// O que o card emitiu, na ordem — o par (tipo, delta) de `ContagemAlterada`.
typedef Intencao = (TipoDeCabeca, int);

Future<List<Intencao>> _montar(
  WidgetTester tester, {
  int homens = 0,
  int mulheres = 0,
  int criancas = 0,
}) async {
  final emitidas = <Intencao>[];

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(const Size(390, 820));
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: CardDeContagem(
            contagem: ContagemDePessoas(
              homens: homens,
              mulheres: mulheres,
              criancas: criancas,
            ),
            aoAlterar: (tipo, delta) => emitidas.add((tipo, delta)),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return emitidas;
}

/// O stepper da linha [indice] — 0 homens, 1 mulheres, 2 crianças.
Finder _stepper(int indice) => find.byType(BoraStepper).at(indice);

Finder _mais(int indice) => find.descendant(
      of: _stepper(indice),
      matching: find.text(BoraStepper.simboloMais),
    );

Finder _menos(int indice) => find.descendant(
      of: _stepper(indice),
      matching: find.text(BoraStepper.simboloMenos),
    );

/// O valor que a linha [indice] está exibindo.
String _valorExibido(WidgetTester tester, int indice) =>
    tester.widget<BoraStepper>(_stepper(indice)).valor.toString();

void main() {
  setUpAll(carregarFontesArchivo);

  group('MONT-01 — as três linhas de T-03', () {
    testWidgets('mostra os rótulos literais com emoji, na ordem da spec',
        (tester) async {
      await _montar(tester);

      expect(find.text('👨 Homens'), findsOneWidget);
      expect(find.text('👩 Mulheres'), findsOneWidget);
      expect(find.text('🧒 Crianças'), findsOneWidget);

      final homens = tester.getTopLeft(find.text('👨 Homens')).dy;
      final mulheres = tester.getTopLeft(find.text('👩 Mulheres')).dy;
      final criancas = tester.getTopLeft(find.text('🧒 Crianças')).dy;

      expect(homens, lessThan(mulheres));
      expect(mulheres, lessThan(criancas));
    });

    testWidgets('desenha exatamente três steppers', (tester) async {
      await _montar(tester);

      expect(find.byType(BoraStepper), findsNWidgets(3));
    });
  });

  group('MONT-02 — cada stepper emite a intenção da sua própria linha', () {
    testWidgets('o + de cada linha emite +1 com o tipo daquela cabeça',
        (tester) async {
      final emitidas = await _montar(tester, homens: 1, mulheres: 1);

      await tester.tap(_mais(0));
      await tester.tap(_mais(1));
      await tester.tap(_mais(2));

      expect(emitidas, [
        (TipoDeCabeca.homens, 1),
        (TipoDeCabeca.mulheres, 1),
        (TipoDeCabeca.criancas, 1),
      ]);
    });

    testWidgets('mexer em dois steppers não cruza os tipos', (tester) async {
      final emitidas = await _montar(tester, mulheres: 2, criancas: 2);

      await tester.tap(_mais(1));
      await tester.tap(_menos(2));

      expect(emitidas, [
        (TipoDeCabeca.mulheres, 1),
        (TipoDeCabeca.criancas, -1),
      ]);
    });

    testWidgets('o − emite −1, e nunca outro passo', (tester) async {
      final emitidas = await _montar(tester, homens: 3);

      await tester.tap(_menos(0));

      expect(emitidas, [(TipoDeCabeca.homens, -1)]);
    });
  });

  group('MONT-14 — o piso de 0 de UC-03 E1', () {
    testWidgets('em 0 a linha vem sem decremento — a guarda é o null do '
        'componente', (tester) async {
      await _montar(tester, mulheres: 2);

      expect(tester.widget<BoraStepper>(_stepper(0)).onDecrementar, isNull);
      expect(tester.widget<BoraStepper>(_stepper(2)).onDecrementar, isNull);
      expect(
        tester.widget<BoraStepper>(_stepper(1)).onDecrementar,
        isNotNull,
      );
    });

    testWidgets('tocar o − no piso não emite nada', (tester) async {
      final emitidas = await _montar(tester, mulheres: 2);

      await tester.tap(_menos(0));
      await tester.tap(_menos(2));

      expect(emitidas, isEmpty);
    });

    testWidgets('com uma linha no piso as outras seguem ativas',
        (tester) async {
      final emitidas = await _montar(tester, mulheres: 2);

      await tester.tap(_menos(0));
      await tester.tap(_menos(1));

      expect(emitidas, [(TipoDeCabeca.mulheres, -1)]);
    });

    testWidgets('acima do piso o + segue emitindo em todas as linhas',
        (tester) async {
      final emitidas = await _montar(tester);

      await tester.tap(_mais(0));

      expect(emitidas, [(TipoDeCabeca.homens, 1)]);
    });
  });

  group('MONT-02 — o valor exibido é o recebido', () {
    testWidgets('cada linha mostra a sua própria contagem', (tester) async {
      await _montar(tester, homens: 3, mulheres: 2, criancas: 1);

      expect(_valorExibido(tester, 0), '3');
      expect(_valorExibido(tester, 1), '2');
      expect(_valorExibido(tester, 2), '1');
    });

    testWidgets('tocar o + não muda o número sozinho — o card não guarda '
        'contagem própria', (tester) async {
      await _montar(tester, homens: 3);

      await tester.tap(_mais(0));
      await tester.pumpAndSettle();

      expect(_valorExibido(tester, 0), '3');
    });

    testWidgets('o card não escreve dinheiro — RN-13 é da camada',
        (tester) async {
      expect(cifraoEm(File(_arquivoDoCard).readAsStringSync()), isEmpty);
    });
  });
}
