import 'dart:io';

import 'package:bora/core/design_system/catalog/catalog_page.dart';
import 'package:bora/core/design_system/catalog/catalog_sections.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A prova de completude de DS-33.
///
/// O catálogo só cumpre o papel dele — ser onde o design system é conferido a
/// olho contra o arquivo 02 — se **todo** componente tiver lugar lá dentro. Um
/// componente que existe mas não aparece no catálogo é um componente que
/// ninguém confere.
///
/// Por isso as duas listas deste arquivo são de naturezas diferentes, de
/// propósito:
///
/// - a de **tipos** é escrita à mão: tirar um componente do catálogo tem de
///   quebrar aqui, e uma lista derivada da árvore renderizada concordaria com
///   qualquer catálogo, inclusive um vazio;
/// - a de **arquivos** é varrida do disco: componente novo entra sozinho na
///   cobrança do barrel, sem depender de alguém lembrar de vir aqui.
const String _diretorioDoDesignSystem = 'lib/core/design_system';
const String _barrel = '$_diretorioDoDesignSystem/design_system.dart';

/// Frame do celular e janela do web do `CLAUDE.md` — um de cada lado do
/// breakpoint de 900 de AD-007.
const Size _janelaCompacta = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

/// Todo componente público do sistema, com o arquivo onde mora — o arquivo
/// entra na mensagem de falha para que o que faltou seja localizável sem
/// caçar.
const List<(Type, String)> _componentes = <(Type, String)>[
  (BoraSurface, 'bora_surface.dart'),
  (BoraPressSink, 'bora_press_sink.dart'),
  (BoraPrimaryButton, 'bora_primary_button.dart'),
  (BoraSecondaryButton, 'bora_secondary_button.dart'),
  (BoraSelectionChip, 'bora_selection_chip.dart'),
  (BoraSegmentedControl, 'bora_segmented_control.dart'),
  (BoraStepper, 'bora_stepper.dart'),
  (BoraTextField, 'bora_text_field.dart'),
  (BoraListCard, 'bora_list_card.dart'),
  (BoraExpandableRow, 'bora_expandable_row.dart'),
  (BoraExpandableGroup, 'bora_expandable_row.dart'),
  (BoraAvatar, 'bora_avatar.dart'),
  (BoraStackedAvatars, 'bora_avatar.dart'),
  (BoraStatusTag, 'bora_status_tag.dart'),
  (BoraDashedNote, 'bora_dashed_note.dart'),
  (BoraEmptySlot, 'bora_dashed_note.dart'),
  (BoraRotatedTag, 'bora_rotated_tag.dart'),
  (BoraHeroCard, 'bora_hero_card.dart'),
  (BoraFooterBar, 'bora_footer_bar.dart'),
  (BoraPriceRangeBar, 'bora_price_range_bar.dart'),
  (BoraProgressBar, 'bora_progress_bar.dart'),
  (BoraPollOption, 'bora_poll_option.dart'),
  (BoraBottomSheet, 'bora_bottom_sheet.dart'),
  (BoraPhoneFrame, 'bora_phone_frame.dart'),
];

Future<void> _montarCatalogo(WidgetTester tester, Size janela) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);
  await tester.pumpWidget(const MaterialApp(home: CatalogPage()));
  await tester.pumpAndSettle();
}

/// Os `.dart` de [subdiretorio], no formato em que o barrel os exporta.
List<String> arquivosExportaveisDe(String subdiretorio) =>
    Directory('$_diretorioDoDesignSystem/$subdiretorio')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((nome) => nome.endsWith('.dart'))
        .map((nome) => '$subdiretorio/$nome')
        .toList()
      ..sort();

/// Os caminhos de [arquivos] que [barrel] não exporta.
List<String> naoExportadosEm(String barrel, List<String> arquivos) => [
      for (final arquivo in arquivos)
        if (!barrel.contains("export '$arquivo';")) arquivo,
    ];

void main() {
  group('DS-33 — todo componente tem lugar de conferência no catálogo', () {
    testWidgets('cada componente do sistema aparece no catálogo compacto',
        (tester) async {
      await _montarCatalogo(tester, _janelaCompacta);

      final ausentes = <String>[
        for (final (tipo, arquivo) in _componentes)
          if (find.byType(tipo).evaluate().isEmpty) '$tipo ($arquivo)',
      ];

      expect(
        ausentes,
        isEmpty,
        reason: 'DS-33: componente sem seção no catálogo é componente que '
            'ninguém confere contra o arquivo 02',
      );
    });

    testWidgets('cada componente do sistema aparece no catálogo expandido',
        (tester) async {
      await _montarCatalogo(tester, _janelaExpandida);

      final ausentes = <String>[
        for (final (tipo, arquivo) in _componentes)
          if (find.byType(tipo).evaluate().isEmpty) '$tipo ($arquivo)',
      ];

      expect(ausentes, isEmpty);
      expect(tester.takeException(), isNull);
    });

    test('a lista canônica não roda vazia e não tem tipo repetido', () {
      expect(_componentes, isNotEmpty);
      expect(
        _componentes.map((c) => c.$1).toSet(),
        hasLength(_componentes.length),
        reason: 'tipo repetido esconderia um componente sem cobrir outro',
      );
    });

    testWidgets('um tipo que o catálogo não mostra é acusado pelo nome',
        (tester) async {
      await _montarCatalogo(tester, _janelaCompacta);

      // O sensor: um widget que o catálogo comprovadamente não usa. Se a
      // varredura não acusar **este**, ela não acusaria nenhum.
      const ausenteDeProposito = (Placeholder, 'nao_existe.dart');
      final ausentes = <String>[
        for (final (tipo, arquivo) in [..._componentes, ausenteDeProposito])
          if (find.byType(tipo).evaluate().isEmpty) '$tipo ($arquivo)',
      ];

      expect(ausentes, ['Placeholder (nao_existe.dart)']);
    });
  });

  group('DS-33 — o barrel é a porta única do design system', () {
    test('exporta todo componente e todo token', () {
      final barrel = File(_barrel).readAsStringSync();
      final arquivos = [
        ...arquivosExportaveisDe('components'),
        ...arquivosExportaveisDe('tokens'),
      ];

      expect(
        naoExportadosEm(barrel, arquivos),
        isEmpty,
        reason: 'quem não está no barrel não entra pela porta única — a tela '
            'teria de importar o arquivo interno',
      );
    });

    test('a varredura de arquivos não roda vazia nos dois diretórios', () {
      expect(arquivosExportaveisDe('components'), isNotEmpty);
      expect(arquivosExportaveisDe('tokens'), isNotEmpty);
    });

    test('um arquivo fora do barrel é acusado pelo caminho', () {
      final barrel = File(_barrel).readAsStringSync();

      expect(
        naoExportadosEm(barrel, ['components/bora_inexistente.dart']),
        ['components/bora_inexistente.dart'],
        reason: 'sem isto a cobrança passaria vacuamente',
      );
      expect(
        naoExportadosEm(barrel, ['components/bora_surface.dart']),
        isEmpty,
      );
    });

    test('todo export do barrel aponta para um arquivo que existe', () {
      final exports = RegExp("export '([^']+)';")
          .allMatches(File(_barrel).readAsStringSync())
          .map((m) => m.group(1)!);

      final quebrados = [
        for (final alvo in exports)
          if (!File('$_diretorioDoDesignSystem/$alvo').existsSync()) alvo,
      ];

      expect(
        quebrados,
        isEmpty,
        reason: 'export apontando para arquivo removido deixa o barrel '
            'mentindo sobre o que o sistema oferece',
      );
    });
  });

  group('DS-33 — cada seção declara o trecho do arquivo 02 que prova', () {
    test('toda seção tem título e referência não vazios', () {
      final semReferencia = [
        for (final secao in secoes)
          if (secao.titulo.trim().isEmpty || secao.referencia.trim().isEmpty)
            secao.titulo,
      ];

      expect(
        semReferencia,
        isEmpty,
        reason: 'DS-33: a conferência é seção-a-seção contra o arquivo 02, e '
            'sem a referência não se sabe contra o quê conferir',
      );
      expect(
        secoes.map((s) => s.titulo).toSet(),
        hasLength(secoes.length),
        reason: 'título repetido quebraria o findsOneWidget da conferência',
      );
    });
  });
}
