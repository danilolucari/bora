import 'package:bora/core/design_system/catalog/catalog_page.dart';
import 'package:bora/core/design_system/catalog/catalog_sections.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/responsive/responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Frame do celular e janela do web do `CLAUDE.md` — um de cada lado do
/// breakpoint de 900 de AD-007.
const Size _janelaCompacta = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

Future<void> _montar(WidgetTester tester, Size janela) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);
  await tester.pumpWidget(const MaterialApp(home: CatalogPage()));
  await tester.pumpAndSettle();
}

void main() {
  group('DS-33 — o catálogo aplica o tema em si mesmo', () {
    testWidgets('o conteúdo é envolvido por boraTheme()', (tester) async {
      await _montar(tester, _janelaCompacta);

      final tema = Theme.of(tester.element(find.byKey(CatalogPage.pageKey)));

      expect(
        tema.scaffoldBackgroundColor,
        BoraColors.paper,
        reason: 'A-16: o tema não é plugado no BoraApp nesta spec — a página '
            'o aplica em si mesma',
      );
      expect(tema.splashFactory, NoSplash.splashFactory);
      // O `ThemeData` normaliza o `textTheme` com a tipografia do
      // Material, então a comparação é campo a campo, não por igualdade
      // do `TextStyle` inteiro.
      expect(tema.textTheme.bodyLarge?.fontFamily, BoraTextStyles.familiaUi);
      expect(
        tema.textTheme.bodyLarge?.fontSize,
        BoraTextStyles.corpo.fontSize,
      );
    });
  });

  group('DS-33 — o registro de seções é a casa de cada componente', () {
    test('a lista começa pela seção de tokens, com título e referência', () {
      expect(secoes, isNotEmpty);
      expect(secoes.first.titulo, 'TOKENS');
      expect(secoes.first.referencia, '§1 · §2 · §4');
    });

    testWidgets('cada seção registrada aparece com título e referência',
        (tester) async {
      await _montar(tester, _janelaCompacta);

      for (final secao in secoes) {
        expect(find.text(secao.titulo), findsOneWidget);
        expect(find.text(secao.referencia), findsOneWidget);
      }
    });

    testWidgets('a seção de tokens mostra cor, tipografia e sombra',
        (tester) async {
      await _montar(tester, _janelaCompacta);

      expect(find.text('CORES · §1'), findsOneWidget);
      expect(find.text('TIPOGRAFIA · §2'), findsOneWidget);
      expect(find.text('SOMBRAS · §4'), findsOneWidget);
    });
  });

  group('DS-33 — o catálogo abre nos dois modos de AD-007', () {
    testWidgets('largura compacta (390) renderiza sem overflow',
        (tester) async {
      await _montar(tester, _janelaCompacta);

      expect(find.byType(ResponsiveBuilder), findsOneWidget);
      expect(find.text('TOKENS'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('TOKENS')).dx,
        BoraSpacing.linhaLista.left,
        reason: 'no compacto a coluna ocupa a largura toda, com a margem do '
            'próprio conteúdo',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('largura expandida (1180) renderiza centrada e sem overflow',
        (tester) async {
      await _montar(tester, _janelaExpandida);

      expect(find.text('TOKENS'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('TOKENS')).dx,
        greaterThan(BoraSpacing.linhaLista.left),
        reason: 'arquivo 06: no web o conteúdo é um container central com '
            'largura máxima — não cola na margem do compacto',
      );
      expect(tester.takeException(), isNull);
    });
  });
}
