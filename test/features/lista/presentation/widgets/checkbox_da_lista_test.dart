import 'dart:io';

import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/lista/presentation/widgets/checkbox_da_lista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

const String _arquivoDoCheckbox =
    'lib/features/lista/presentation/widgets/checkbox_da_lista.dart';

const String _diretorioDoDesignSystem = 'lib/core/design_system';

Future<void> _montar(
  WidgetTester tester, {
  required bool marcado,
  Size viewport = _frameCompacto,
}) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: Center(child: CheckboxDaLista(marcado: marcado)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

BoraSurface _superficie(WidgetTester tester) => tester.widget<BoraSurface>(
      find.descendant(
        of: find.byType(CheckboxDaLista),
        matching: find.byType(BoraSurface),
      ),
    );

void main() {
  _viewports.forEach((nome, viewport) {
    group('LIST-18 — a forma do checkbox ($nome)', () {
      testWidgets('o quadrado tem 26×26', (tester) async {
        await _montar(tester, marcado: false, viewport: viewport);

        expect(
          tester.getSize(find.byType(CheckboxDaLista)),
          const Size(CheckboxDaLista.lado, CheckboxDaLista.lado),
        );
      });

      testWidgets('a borda é a de 2px `ink` de §3, com canto reto',
          (tester) async {
        await _montar(tester, marcado: false, viewport: viewport);

        final superficie = _superficie(tester);

        expect(superficie.corDaBorda, BoraColors.ink);
        expect(superficie.larguraDaBorda, 2);
        expect(superficie.acento, isNull);

        final decoracao = BoraSurface.decoracaoDe(
          fundo: superficie.fundo,
          corDaBorda: superficie.corDaBorda,
          larguraDaBorda: superficie.larguraDaBorda,
        );

        expect(decoracao.borderRadius, BoraBorders.raio);
      });
    });
  });

  group('LIST-18 — os dois estados', () {
    testWidgets('desmarcado: fundo branco e nenhum ✓', (tester) async {
      await _montar(tester, marcado: false);

      expect(_superficie(tester).fundo, BoraColors.white);
      expect(find.text(CheckboxDaLista.simboloDoCheck), findsNothing);
    });

    testWidgets('marcado: fundo verde de §1 e o ✓ branco', (tester) async {
      await _montar(tester, marcado: true);

      expect(_superficie(tester).fundo, BoraColors.green);
      expect(find.text(CheckboxDaLista.simboloDoCheck), findsOneWidget);

      final check = tester.widget<Text>(
        find.text(CheckboxDaLista.simboloDoCheck),
      );

      expect(check.style?.color, BoraColors.white);
    });

    testWidgets('os dois fundos são cores diferentes — marcar muda o estado',
        (tester) async {
      await _montar(tester, marcado: false);
      final desmarcado = _superficie(tester).fundo;

      await _montar(tester, marcado: true);

      expect(_superficie(tester).fundo, isNot(desmarcado));
    });
  });

  group('A-13 — a fronteira do componente', () {
    test('nenhum literal de cor mora no arquivo — tudo vem dos tokens', () {
      final fonte = File(_arquivoDoCheckbox).readAsStringSync();

      expect(fonte, isNot(contains('Color(0x')));
      expect(fonte, isNot(contains('0B6B3A')));
    });

    test('o checkbox mora na feature, e não em core/design_system', () {
      expect(File(_arquivoDoCheckbox).existsSync(), isTrue);

      final noDesignSystem = Directory(_diretorioDoDesignSystem)
          .listSync(recursive: true)
          .whereType<File>()
          .where((arquivo) => arquivo.path.endsWith('.dart'))
          .where(
            (arquivo) =>
                arquivo.readAsStringSync().contains('CheckboxDaLista'),
          )
          .map((arquivo) => arquivo.path)
          .toList();

      expect(noDesignSystem, isEmpty);
    });
  });
}
