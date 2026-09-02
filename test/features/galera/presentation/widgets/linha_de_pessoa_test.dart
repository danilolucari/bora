import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/galera/presentation/galera_textos.dart';
import 'package:bora/features/galera/presentation/widgets/linha_de_pessoa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/rn30_estado_inicial_tipado.dart';
import '../../../../support/galera_de_teste.dart';

const String _arquivoDaLinha =
    'lib/features/galera/presentation/widgets/linha_de_pessoa.dart';

/// As duas viewports do produto: o frame do celular e a janela do web.
const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

Pessoa _daFixture(String nome) =>
    pessoasRn30Tipadas.firstWhere((pessoa) => pessoa.nome == nome);

/// Monta uma linha isolada e devolve quantas vezes ela pediu para alternar.
Future<List<void>> _montar(
  WidgetTester tester, {
  required Pessoa pessoa,
  bool aberta = false,
  Size viewport = _frameCompacto,
}) async {
  final toques = <void>[];

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: LinhaDePessoa(
          pessoa: pessoa,
          aberta: aberta,
          onAlternar: () => toques.add(null),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return toques;
}

/// Monta várias linhas empilhadas — o caso das homônimas.
Future<void> _montarVarias(
  WidgetTester tester,
  List<Pessoa> pessoas,
) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(_frameCompacto);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: Column(
          children: [
            for (final pessoa in pessoas)
              LinhaDePessoa(
                pessoa: pessoa,
                aberta: false,
                onAlternar: () {},
              ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

BoraStatusTag _tag(WidgetTester tester) =>
    tester.widget<BoraStatusTag>(find.byType(BoraStatusTag));

void main() {
  final rafa = _daFixture('Rafa');
  final ana = _daFixture('Ana');
  final leo = _daFixture('Léo');
  final bia = _daFixture('Bia');
  final duda = _daFixture('Duda');

  group('GAL-07 — o que a linha mostra de cada pessoa', () {
    for (final viewport in _viewports.entries) {
      testWidgets('em ${viewport.key}, avatar, nome, tag e caret',
          (tester) async {
        await _montar(tester, pessoa: leo, viewport: viewport.value);

        expect(find.byType(BoraAvatar), findsOneWidget);
        expect(find.text('Léo'), findsOneWidget);
        expect(find.byType(BoraStatusTag), findsOneWidget);
        expect(find.text(BoraExpandableRow.caretFechado), findsOneWidget);
      });
    }

    testWidgets('o avatar leva a inicial do nome', (tester) async {
      await _montar(tester, pessoa: leo);

      expect(tester.widget<BoraAvatar>(find.byType(BoraAvatar)).nome, 'Léo');
    });
  });

  group('GAL-07 AC4 — o badge "VOCÊ" e o par que discrimina', () {
    testWidgets('o Rafa, que é o usuário do app, tem o badge', (tester) async {
      await _montar(tester, pessoa: rafa);

      expect(find.text(GaleraTextos.badgeVoce), findsOneWidget);
    });

    testWidgets('a Ana, que não é, não tem badge algum', (tester) async {
      await _montar(tester, pessoa: ana);

      expect(find.text(GaleraTextos.badgeVoce), findsNothing);
    });

    testWidgets('o badge é claro sobre escuro — não some no fundo',
        (tester) async {
      await _montar(tester, pessoa: rafa);

      final texto = tester.widget<Text>(find.text(GaleraTextos.badgeVoce));

      expect(texto.style?.color, BoraColors.cream);
    });
  });

  group('GAL-07 AC5, AC6 — a sublinha (A-14)', () {
    testWidgets('a do Rafa é a que GaleraTextos.sublinhaDe devolve',
        (tester) async {
      await _montar(tester, pessoa: rafa);

      expect(find.text(GaleraTextos.sublinhaDe(rafa)!), findsOneWidget);
    });

    testWidgets('a da Bia traz a dieta e a abstinência', (tester) async {
      await _montar(tester, pessoa: bia);

      expect(find.text(GaleraTextos.sublinhaDe(bia)!), findsOneWidget);
      expect(find.text(GaleraTextos.sublinhaDe(rafa)!), findsNothing);
    });

    testWidgets('a Duda, sem dieta e sem bebida, renderiza sem sublinha',
        (tester) async {
      await _montar(tester, pessoa: duda);

      expect(GaleraTextos.sublinhaDe(duda), isNull);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text && widget.style == BoraTextStyles.sublinhaLista,
        ),
        findsNothing,
      );
      expect(find.text('Duda'), findsOneWidget);
    });

    testWidgets('só a dieta declarada rende uma sublinha de um termo só',
        (tester) async {
      final nina = pessoaDeTeste('Nina', dieta: Dieta.veggie);

      await _montar(tester, pessoa: nina);

      expect(find.text('🥗 Veggie'), findsOneWidget);
    });
  });

  group('GAL-08 — o papel vira tag, e a cor vem do enum', () {
    testWidgets('ANFITRIÃO usa o status amarelo de §5', (tester) async {
      await _montar(tester, pessoa: rafa);

      expect(_tag(tester).status, BoraStatus.anfitriao);
      expect(_tag(tester).status.fundo, BoraColors.yellow);
    });

    testWidgets('CO-ANFITRIÃO usa o roxo com texto branco', (tester) async {
      await _montar(tester, pessoa: ana);

      expect(_tag(tester).status, BoraStatus.coAnfitriao);
      expect(_tag(tester).status.fundo, BoraColors.purple);
      expect(_tag(tester).status.texto, BoraColors.white);
    });

    testWidgets('CONVIDADO usa o branco', (tester) async {
      await _montar(tester, pessoa: leo);

      expect(_tag(tester).status, BoraStatus.convidado);
      expect(_tag(tester).status.fundo, BoraColors.white);
    });

    testWidgets('SÓ VÊ usa wa-bubble com texto text-2', (tester) async {
      await _montar(tester, pessoa: duda);

      expect(_tag(tester).status, BoraStatus.soVe);
      expect(_tag(tester).status.fundo, BoraColors.waBubble);
      expect(_tag(tester).status.texto, BoraColors.text2);
    });

    testWidgets('o rótulo da tag é o do papel, não o nome da pessoa',
        (tester) async {
      await _montar(tester, pessoa: ana);

      expect(find.text(GaleraTextos.rotuloDoPapel(PapelNaFesta.coAnfitriao)),
          findsOneWidget);
      expect(find.text(GaleraTextos.rotuloDoPapel(PapelNaFesta.anfitriao)),
          findsNothing);
    });
  });

  group('GAL-10 — o caret e o toque', () {
    testWidgets('fechada, o caret é o de BoraExpandableRow', (tester) async {
      await _montar(tester, pessoa: leo);

      expect(find.text(BoraExpandableRow.caretFechado), findsOneWidget);
      expect(find.text(BoraExpandableRow.caretAberto), findsNothing);
    });

    testWidgets('aberta, o caret vira o outro', (tester) async {
      await _montar(tester, pessoa: leo, aberta: true);

      expect(find.text(BoraExpandableRow.caretAberto), findsOneWidget);
      expect(find.text(BoraExpandableRow.caretFechado), findsNothing);
    });

    testWidgets('tocar a linha emite a alternância uma vez', (tester) async {
      final toques = await _montar(tester, pessoa: leo);

      await tester.tap(find.byType(LinhaDePessoa));
      await tester.pumpAndSettle();

      expect(toques, hasLength(1));
    });

    testWidgets('a linha não decide: tocá-la duas vezes emite duas vezes',
        (tester) async {
      final toques = await _montar(tester, pessoa: leo);

      await tester.tap(find.byType(LinhaDePessoa));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(LinhaDePessoa));
      await tester.pumpAndSettle();

      expect(toques, hasLength(2));
    });
  });

  group('Edge Cases — nome longo e homônimas', () {
    testWidgets('nome longo não estoura o layout', (tester) async {
      await _montar(
        tester,
        pessoa: pessoaDeTeste(
          'Maria Aparecida do Nascimento Albuquerque Cavalcanti',
          dieta: Dieta.tudo,
          bebe: true,
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('duas homônimas renderizam como duas linhas distintas',
        (tester) async {
      await _montarVarias(tester, [
        pessoaDeTeste('Ana', dieta: Dieta.veggie),
        pessoaDeTeste('Ana', dieta: Dieta.semPorco),
      ]);

      expect(find.byType(LinhaDePessoa), findsNWidgets(2));
      expect(find.text('Ana'), findsNWidgets(2));
      expect(find.text('🥗 Veggie'), findsOneWidget);
      expect(find.text('🚫 Sem porco'), findsOneWidget);
    });
  });

  group('Arquivo 02 §8 — nenhum literal no arquivo', () {
    test('sem literal de cor, de fonte ou de sombra', () {
      final fonte = File(_arquivoDaLinha).readAsStringSync();

      expect(fonte, isNot(contains('Color(0x')));
      expect(fonte, isNot(contains('fontFamily:')));
      expect(fonte, isNot(contains('BoxShadow(')));
    });
  });
}
