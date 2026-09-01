import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/montar/presentation/montar_textos.dart';
import 'package:bora/features/montar/presentation/widgets/secao_de_duracao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';
import '../../../../support/cifrao_na_fonte.dart';

Future<List<int>> _montar(
  WidgetTester tester, {
  String rotulo = MontarTextos.duracaoCompacto,
  int duracaoHoras = 4,
  double? larguraMaxima,
  Size janela = const Size(390, 820),
}) async {
  final emitidas = <int>[];

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SecaoDeDuracao(
            rotulo: rotulo,
            duracaoHoras: duracaoHoras,
            aoSelecionar: emitidas.add,
            larguraMaxima: larguraMaxima,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return emitidas;
}

/// Quantos botões do segmented estão pintados como ativo (fundo `ink`, §5).
int _ativosPintados(WidgetTester tester) => tester
    .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
    .where((c) => (c.decoration as BoxDecoration?)?.color == BoraColors.ink)
    .length;

const String _arquivoDaSecao =
    'lib/features/montar/presentation/widgets/secao_de_duracao.dart';

void main() {
  setUpAll(carregarFontesArchivo);

  group('MONT-08 — o bloco de duração não faz conta', () {
    testWidgets('não escreve dinheiro: RN-13 é da camada de cálculo',
        (tester) async {
      expect(cifraoEm(File(_arquivoDaSecao).readAsStringSync()), isEmpty);
    });
  });

  group('MONT-01 — o segmented de duração', () {
    testWidgets('mostra as quatro opções de T-03, na ordem literal',
        (tester) async {
      await _montar(tester);

      expect(find.text('2H'), findsOneWidget);
      expect(find.text('4H'), findsOneWidget);
      expect(find.text('6H'), findsOneWidget);
      expect(find.text('DIA'), findsOneWidget);

      final segmented =
          tester.widget<BoraSegmentedControl>(find.byType(BoraSegmentedControl));
      expect(segmented.opcoes, ['2h', '4h', '6h', 'Dia']);
    });
  });

  group('MONT-09 — o rótulo diverge por plataforma (A-09)', () {
    testWidgets('com o rótulo de T-03 mostra "QUANTO TEMPO DE FESTA?"',
        (tester) async {
      await _montar(tester);

      expect(find.text('QUANTO TEMPO DE FESTA?'), findsOneWidget);
      expect(find.text('ATÉ QUE HORAS?'), findsNothing);
    });

    testWidgets('com o rótulo de W-03 mostra "ATÉ QUE HORAS?"', (tester) async {
      await _montar(tester, rotulo: MontarTextos.duracaoExpandido);

      expect(find.text('ATÉ QUE HORAS?'), findsOneWidget);
      expect(find.text('QUANTO TEMPO DE FESTA?'), findsNothing);
    });
  });

  group('MONT-02 — exatamente uma ativa, e ela é a duração recebida', () {
    testWidgets('4h ativa acende a segunda opção, e só ela', (tester) async {
      await _montar(tester);

      expect(
        tester
            .widget<BoraSegmentedControl>(find.byType(BoraSegmentedControl))
            .indiceAtivo,
        1,
      );
      expect(_ativosPintados(tester), 1);
    });

    testWidgets('cada uma das quatro durações acende a sua própria opção',
        (tester) async {
      for (final (indice, horas)
          in SecaoDeDuracao.horasPorOpcao.indexed) {
        await _montar(tester, duracaoHoras: horas);

        expect(
          tester
              .widget<BoraSegmentedControl>(find.byType(BoraSegmentedControl))
              .indiceAtivo,
          indice,
        );
        expect(_ativosPintados(tester), 1);
      }
    });

    testWidgets('duração fora das quatro não acende opção nenhuma — mentir '
        'sobre a ativa seria pior', (tester) async {
      await _montar(tester, duracaoHoras: 3);

      expect(_ativosPintados(tester), 0);
    });
  });

  group('MONT-02 / RN-02 — tocar emite as horas da opção tocada', () {
    testWidgets('2h emite 2 e 6h emite 6', (tester) async {
      final emitidas = await _montar(tester);

      await tester.tap(find.text('2H'));
      await tester.tap(find.text('6H'));

      expect(emitidas, [2, 6]);
    });

    testWidgets('"Dia" emite 10 horas — o dia todo de RN-02 (A-15)',
        (tester) async {
      final emitidas = await _montar(tester);

      await tester.tap(find.text('DIA'));

      expect(emitidas, [10]);
      expect(rotuloDeDuracao(emitidas.single), 'Dia todo');
    });

    testWidgets('tocar a já ativa emite a mesma duração, sem exceção',
        (tester) async {
      final emitidas = await _montar(tester);

      await tester.tap(find.text('4H'));

      expect(emitidas, [4]);
    });

    testWidgets('tocar não move o ativo sozinho — quem decide é o bloc',
        (tester) async {
      await _montar(tester);

      await tester.tap(find.text('DIA'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<BoraSegmentedControl>(find.byType(BoraSegmentedControl))
            .indiceAtivo,
        1,
      );
    });
  });

  group('W-03 — o teto de largura do segmented é da plataforma', () {
    /// Larga o bastante para o segmented esticar muito além de 360px se
    /// ninguém o segurasse.
    const Size janelaLarga = Size(900, 800);

    testWidgets('sem teto, o segmented ocupa a coluna inteira — o default de '
        'T-03', (tester) async {
      await _montar(tester, janela: janelaLarga);

      expect(
        tester.getSize(find.byType(BoraSegmentedControl)).width,
        greaterThan(360),
      );
    });

    testWidgets('com o teto de W-03, o segmented para em 360px',
        (tester) async {
      await _montar(tester, janela: janelaLarga, larguraMaxima: 360);

      expect(tester.getSize(find.byType(BoraSegmentedControl)).width, 360);
    });

    testWidgets('o teto não muda o que o segmented emite', (tester) async {
      final emitidas =
          await _montar(tester, janela: janelaLarga, larguraMaxima: 360);

      await tester.tap(find.text('6H'));

      expect(emitidas, [6]);
    });
  });
}
