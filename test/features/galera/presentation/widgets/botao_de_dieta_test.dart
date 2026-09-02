import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/galera/presentation/galera_textos.dart';
import 'package:bora/features/galera/presentation/widgets/botao_de_dieta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const String _arquivoDoBotao =
    'lib/features/galera/presentation/widgets/botao_de_dieta.dart';

/// As duas viewports do produto: o frame do celular e a janela do web.
const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

Future<List<Dieta>> _montar(
  WidgetTester tester, {
  Dieta dieta = Dieta.veggie,
  bool ativo = false,
  Size viewport = _frameCompacto,
}) async {
  final escolhas = <Dieta>[];

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: Center(
          child: BotaoDeDieta(
            dieta: dieta,
            ativo: ativo,
            onEscolher: escolhas.add,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return escolhas;
}

/// Os três botões numa linha, como T-05 desenha a seção.
Future<void> _montarOsTres(WidgetTester tester, Dieta ativa) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(_frameCompacto);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: Row(
          children: [
            for (final dieta in Dieta.values)
              Expanded(
                child: BotaoDeDieta(
                  dieta: dieta,
                  ativo: dieta == ativa,
                  onEscolher: (_) {},
                ),
              ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// A decoração que o botão está de fato desenhando.
BoxDecoration _decoracao(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find.descendant(
      of: find.byType(BotaoDeDieta),
      matching: find.byType(DecoratedBox),
    ),
  );
  return caixa.decoration as BoxDecoration;
}

Offset _sombra(WidgetTester tester) =>
    _decoracao(tester).boxShadow!.single.offset;

Matrix4 _translacao(WidgetTester tester) => tester
    .widget<Transform>(
      find.descendant(
        of: find.byType(BotaoDeDieta),
        matching: find.byType(Transform),
      ),
    )
    .transform;

Text _rotulo(WidgetTester tester) =>
    tester.widget<Text>(find.byType(Text).first);

/// O arquivo do botão **sem os comentários** — é o código que as guardas de
/// §5.3 e de §8 olham, no molde de `design.md` §13.
String _codigoDoBotao() => File(_arquivoDoBotao)
    .readAsLinesSync()
    .where((linha) => !linha.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  group('GAL-11, A-13 — o rótulo literal de RN-21', () {
    for (final viewport in _viewports.entries) {
      testWidgets('em ${viewport.key}, o botão traz emoji e rótulo',
          (tester) async {
        await _montar(tester, viewport: viewport.value);

        expect(find.text('🥗 Veggie'), findsOneWidget);
      });
    }

    testWidgets('as três dietas trazem os três rótulos de RN-21',
        (tester) async {
      await _montarOsTres(tester, Dieta.tudo);

      expect(find.text('🍖 Come de tudo'), findsOneWidget);
      expect(find.text('🥗 Veggie'), findsOneWidget);
      expect(find.text('🚫 Sem porco'), findsOneWidget);
    });

    testWidgets('o rótulo é o que GaleraTextos devolve, não um literal novo',
        (tester) async {
      await _montar(tester, dieta: Dieta.semPorco);

      expect(
        find.text(GaleraTextos.rotuloDaDieta(Dieta.semPorco)),
        findsOneWidget,
      );
    });
  });

  group('T-05 — o ativo é vermelho, contra o token', () {
    testWidgets('ativo pinta o fundo de primary e o texto de ink',
        (tester) async {
      await _montar(tester, ativo: true);

      expect(_decoracao(tester).color, BoraColors.primary);
      expect(_rotulo(tester).style?.color, BoraColors.ink);
    });

    testWidgets('o par do ativo é o que §5 fixou em BoraStatus.paga',
        (tester) async {
      await _montar(tester, ativo: true);

      expect(_decoracao(tester).color, BoraStatus.paga.fundo);
      expect(_rotulo(tester).style?.color, BoraStatus.paga.texto);
    });

    testWidgets('inativo usa o par neutro, e não o vermelho', (tester) async {
      await _montar(tester);

      expect(_decoracao(tester).color, BotaoDeDieta.fundoInativo);
      expect(_decoracao(tester).color, isNot(BoraColors.primary));
      expect(_rotulo(tester).style?.color, BoraColors.text2);
    });

    testWidgets('o fundo é opaco nos dois estados — a sombra dura não vaza',
        (tester) async {
      await _montar(tester);
      expect(_decoracao(tester).color?.a, 1.0);

      await _montar(tester, ativo: true);
      expect(_decoracao(tester).color?.a, 1.0);
    });
  });

  group('Arquivo 02 §4 — o botão afunda no press', () {
    testWidgets('pointer down desloca (2,2) e encolhe a sombra de 4 para 2',
        (tester) async {
      await _montar(tester);

      expect(_translacao(tester), Matrix4.translationValues(0, 0, 0));
      expect(_sombra(tester), const Offset(4, 4));

      final gesto = await tester.startGesture(
        tester.getCenter(find.byType(BotaoDeDieta)),
      );
      await tester.pumpAndSettle();

      expect(_translacao(tester), Matrix4.translationValues(2, 2, 0));
      expect(_sombra(tester), const Offset(2, 2));

      await gesto.up();
      await tester.pumpAndSettle();

      expect(_sombra(tester), const Offset(4, 4));
    });
  });

  group('GAL-11, GAL-28 — o gesto', () {
    testWidgets('tocar um inativo emite aquela dieta', (tester) async {
      final escolhas = await _montar(tester, dieta: Dieta.semPorco);

      await tester.tap(find.byType(BotaoDeDieta));
      await tester.pumpAndSettle();

      expect(escolhas, [Dieta.semPorco]);
    });

    testWidgets('tocar o já ativo não emite nada (GAL-28)', (tester) async {
      final escolhas = await _montar(
        tester,
        dieta: Dieta.semPorco,
        ativo: true,
      );

      await tester.tap(find.byType(BotaoDeDieta));
      await tester.pumpAndSettle();

      expect(escolhas, isEmpty);
    });
  });

  group('design.md §5.3 — não é um segmented', () {
    testWidgets('os três botões numa linha não montam BoraSegmentedControl',
        (tester) async {
      await _montarOsTres(tester, Dieta.tudo);

      expect(find.byType(BotaoDeDieta), findsNWidgets(3));
      expect(find.byType(BoraSegmentedControl), findsNothing);
    });

    test('o arquivo não replica a geometria do segmented', () {
      // Sem os comentários: o doc **cita** o componente de propósito, para
      // registrar a variante adiada. É o código que não pode montá-lo.
      expect(_codigoDoBotao(), isNot(contains('BoraSegmentedControl(')));
      expect(_codigoDoBotao(), isNot(contains('IntrinsicHeight')));
    });

    test('o arquivo registra a variante de DS adiada', () {
      final fonte = File(_arquivoDoBotao).readAsStringSync();

      expect(fonte, contains('acentoAtivo:'));
      expect(fonte, contains('SPEC_DEVIATION'));
    });
  });

  group('Arquivo 02 §8 — nenhum literal no arquivo', () {
    test('sem literal de cor, de fonte ou de sombra', () {
      final fonte = File(_arquivoDoBotao).readAsStringSync();

      expect(fonte, isNot(contains('Color(0x')));
      expect(fonte, isNot(contains('fontFamily:')));
      expect(fonte, isNot(contains('BoxShadow(')));
    });
  });
}
