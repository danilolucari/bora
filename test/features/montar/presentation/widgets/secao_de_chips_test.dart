import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/montar/domain/secao_da_montagem.dart';
import 'package:bora/features/montar/presentation/widgets/secao_de_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';

const String _arquivoDaSecao =
    'lib/features/montar/presentation/widgets/secao_de_chips.dart';

const Size _janelaCompacta = Size(390, 820);

Future<List<ChaveItem>> _montar(
  WidgetTester tester,
  SecaoDaMontagem secao, {
  Set<ChaveItem> selecionados = const {},
  Size janela = _janelaCompacta,
}) async {
  final tocados = <ChaveItem>[];

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: SecaoDeChips(
            secao: secao,
            selecionados: selecionados,
            aoAlternar: tocados.add,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return tocados;
}

Finder _chipDe(ChaveItem chave) => find.byWidgetPredicate(
      (w) => w is BoraSelectionChip && w.rotulo == catalogoDeItens[chave]!.nome,
    );

/// A cor de fundo que o chip de [chave] está pintando agora.
Color? _fundoDo(WidgetTester tester, ChaveItem chave) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(of: _chipDe(chave), matching: find.byType(AnimatedContainer)),
  );

  return (container.decoration! as BoxDecoration).color;
}

/// A cor do texto do chip de [chave].
Color? _corDoTextoDo(WidgetTester tester, ChaveItem chave) => tester
    .widget<Text>(find.descendant(of: _chipDe(chave), matching: find.byType(Text)))
    .style
    ?.color;

void main() {
  setUpAll(carregarFontesArchivo);

  group('MONT-01 — as seções de chips de T-03/W-03', () {
    testWidgets('cada seção mostra o seu rótulo literal', (tester) async {
      await _montar(tester, SecaoDaMontagem.naGrelha);
      expect(find.text('NA GRELHA'), findsOneWidget);

      await _montar(tester, SecaoDaMontagem.naGeladeira);
      expect(find.text('NA GELADEIRA'), findsOneWidget);

      await _montar(tester, SecaoDaMontagem.prosFortes);
      expect(find.text('PROS FORTES'), findsOneWidget);
    });

    testWidgets('NA GRELHA tem os três chips de T-03, com emoji',
        (tester) async {
      await _montar(tester, SecaoDaMontagem.naGrelha);

      expect(find.text('🥩 BOVINA'), findsOneWidget);
      expect(find.text('🐷 SUÍNA'), findsOneWidget);
      expect(find.text('🍗 FRANGO'), findsOneWidget);
      expect(find.byType(BoraSelectionChip), findsNWidgets(3));
    });

    testWidgets('NA GELADEIRA tem os cinco chips de T-03, com emoji',
        (tester) async {
      await _montar(tester, SecaoDaMontagem.naGeladeira);

      expect(find.text('🧄 PÃO DE ALHO'), findsOneWidget);
      expect(find.text('🥤 REFRIGERANTE'), findsOneWidget);
      expect(find.text('🧃 SUCO'), findsOneWidget);
      expect(find.text('💧 ÁGUA'), findsOneWidget);
      expect(find.text('🍺 CERVEJA'), findsOneWidget);
      expect(find.byType(BoraSelectionChip), findsNWidgets(5));
    });

    testWidgets('PROS FORTES tem os três destilados — AD-018, também no '
        'compacto', (tester) async {
      await _montar(tester, SecaoDaMontagem.prosFortes);

      expect(find.text('🍸 VODKA'), findsOneWidget);
      expect(find.text('🍹 CACHAÇA'), findsOneWidget);
      expect(find.text('🥃 WHISKY'), findsOneWidget);
      expect(find.byType(BoraSelectionChip), findsNWidgets(3));
    });

    testWidgets('nome e emoji de todo chip vêm do catálogo, nenhum '
        'redigitado', (tester) async {
      for (final secao in SecaoDaMontagem.values) {
        await _montar(tester, secao);

        for (final chave in chipsPorSecao[secao]!) {
          final item = catalogoDeItens[chave]!;
          expect(find.text('${item.emoji} ${item.nome}'), findsOneWidget);
        }
      }

      expect(File(_arquivoDaSecao).readAsStringSync(), isNot(contains('BOVINA')));
    });

    testWidgets('a seção de chips não escreve dinheiro — RN-13 é da camada',
        (tester) async {
      expect(File(_arquivoDaSecao).readAsStringSync(), isNot(contains(r'R$')));
    });
  });

  group('MONT-02 — tocar um chip emite a chave dele', () {
    testWidgets('cada chip emite a sua própria ChaveItem', (tester) async {
      final tocados = await _montar(tester, SecaoDaMontagem.naGrelha);

      await tester.tap(_chipDe(ChaveItem.suina));
      await tester.tap(_chipDe(ChaveItem.frango));

      expect(tocados, [ChaveItem.suina, ChaveItem.frango]);
    });

    testWidgets('tocar não muda a seleção sozinho — quem alterna é o bloc',
        (tester) async {
      await _montar(tester, SecaoDaMontagem.naGrelha);

      await tester.tap(_chipDe(ChaveItem.bovina));
      await tester.pumpAndSettle();

      expect(_fundoDo(tester, ChaveItem.bovina), BoraColors.white);
    });
  });

  group('MONT-02 — o estado de seleção é o par ink/cream de §5', () {
    testWidgets('o chip selecionado pinta fundo ink e texto cream',
        (tester) async {
      await _montar(
        tester,
        SecaoDaMontagem.naGrelha,
        selecionados: const {ChaveItem.bovina},
      );

      expect(_fundoDo(tester, ChaveItem.bovina), BoraColors.ink);
      expect(_corDoTextoDo(tester, ChaveItem.bovina), BoraColors.cream);
    });

    testWidgets('o não selecionado pinta fundo branco e texto ink',
        (tester) async {
      await _montar(
        tester,
        SecaoDaMontagem.naGrelha,
        selecionados: const {ChaveItem.bovina},
      );

      expect(_fundoDo(tester, ChaveItem.suina), BoraColors.white);
      expect(_corDoTextoDo(tester, ChaveItem.suina), BoraColors.ink);
    });

    testWidgets('os dois estados são distintos — a seleção é visível',
        (tester) async {
      await _montar(
        tester,
        SecaoDaMontagem.naGrelha,
        selecionados: const {ChaveItem.bovina},
      );

      expect(
        _fundoDo(tester, ChaveItem.bovina),
        isNot(_fundoDo(tester, ChaveItem.suina)),
      );
      expect(
        tester.widget<BoraSelectionChip>(_chipDe(ChaveItem.bovina)).selecionado,
        isTrue,
      );
      expect(
        tester.widget<BoraSelectionChip>(_chipDe(ChaveItem.suina)).selecionado,
        isFalse,
      );
    });
  });

  group('W-R4 — os chips quebram linha em 390px', () {
    testWidgets('a seção mais larga não estoura a viewport compacta',
        (tester) async {
      await _montar(tester, SecaoDaMontagem.naGeladeira);

      expect(tester.takeException(), isNull);
      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('os cinco chips ocupam mais de uma linha, sem sair da tela',
        (tester) async {
      await _montar(tester, SecaoDaMontagem.naGeladeira);

      final primeiro = tester.getTopLeft(_chipDe(ChaveItem.paoDeAlho)).dy;
      final ultimo = tester.getTopLeft(_chipDe(ChaveItem.cerveja)).dy;

      expect(ultimo, greaterThan(primeiro));
      for (final chave in chipsPorSecao[SecaoDaMontagem.naGeladeira]!) {
        expect(
          tester.getBottomRight(_chipDe(chave)).dx,
          lessThanOrEqualTo(_janelaCompacta.width),
        );
      }
    });
  });
}
