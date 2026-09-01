import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/montar/domain/secao_da_montagem.dart';
import 'package:bora/features/montar/presentation/bloc/montar_event.dart';
import 'package:bora/features/montar/presentation/montar_textos.dart';
import 'package:bora/features/montar/presentation/widgets/card_de_contagem.dart';
import 'package:bora/features/montar/presentation/widgets/formulario_de_montagem.dart';
import 'package:bora/features/montar/presentation/widgets/secao_de_chips.dart';
import 'package:bora/features/montar/presentation/widgets/secao_de_duracao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';

const Size _janelaCompacta = Size(390, 820);

/// Tudo o que o formulário devolveu, na ordem — o teste afirma que cada
/// callback chega a quem montou **sem transformação**.
class _Emitidos {
  final List<(TipoDeCabeca, int)> contagem = [];
  final List<ChaveItem> itens = [];
  final List<int> duracoes = [];
}

Future<_Emitidos> _montar(
  WidgetTester tester, {
  ComposicaoDaFesta? composicao,
  String rotuloDePessoas = MontarTextos.secaoDePessoasCompacto,
  String rotuloDaDuracao = MontarTextos.duracaoCompacto,
  Size janela = _janelaCompacta,
}) async {
  final emitidos = _Emitidos();

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        // O formulário não rola por conta própria: quem dá a rolagem é a tela
        // que o monta (T-03 rola o corpo; W-03 rola a coluna esquerda).
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: FormularioDeMontagem(
            composicao: composicao ??
                ComposicaoDaFesta(
                  contagem: ContagemDePessoas(),
                  duracaoHoras: 4,
                ),
            rotuloDePessoas: rotuloDePessoas,
            rotuloDaDuracao: rotuloDaDuracao,
            aoAlterarContagem: (tipo, delta) =>
                emitidos.contagem.add((tipo, delta)),
            aoAlternarItem: emitidos.itens.add,
            aoSelecionarDuracao: emitidos.duracoes.add,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return emitidos;
}

/// Todo texto renderizado agora, na ordem da árvore.
List<String?> _textosDaArvore(WidgetTester tester) =>
    tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList();

double _topoDe(WidgetTester tester, String texto) =>
    tester.getTopLeft(find.text(texto)).dy;

void main() {
  setUpAll(carregarFontesArchivo);

  group('MONT-01 — as cinco seções na ordem de T-03', () {
    testWidgets('contagem, NA GRELHA, NA GELADEIRA, PROS FORTES e duração, '
        'nessa ordem', (tester) async {
      await _montar(tester);

      final ordem = [
        _topoDe(tester, MontarTextos.secaoDePessoasCompacto),
        _topoDe(tester, 'NA GRELHA'),
        _topoDe(tester, 'NA GELADEIRA'),
        _topoDe(tester, 'PROS FORTES'),
        _topoDe(tester, MontarTextos.duracaoCompacto),
      ];

      expect(ordem, orderedEquals(List<double>.from(ordem)..sort()));
      expect(ordem.toSet(), hasLength(5));
    });

    testWidgets('monta um card de contagem, três seções de chips e uma de '
        'duração', (tester) async {
      await _montar(tester);

      expect(find.byType(CardDeContagem), findsOneWidget);
      expect(find.byType(SecaoDeChips), findsNWidgets(3));
      expect(find.byType(SecaoDeDuracao), findsOneWidget);
    });

    testWidgets('os 11 chips de T-03/W-03 estão presentes', (tester) async {
      await _montar(tester);

      expect(find.byType(BoraSelectionChip), findsNWidgets(11));
      for (final secao in SecaoDaMontagem.values) {
        for (final chave in chipsPorSecao[secao]!) {
          final item = catalogoDeItens[chave]!;
          expect(find.text('${item.emoji} ${item.nome}'), findsOneWidget);
        }
      }
    });
  });

  group('MONT-09 / W-R1 — o mesmo formulário, dois conjuntos de rótulos', () {
    testWidgets('com os rótulos de T-03 mostra os literais do mobile',
        (tester) async {
      await _montar(tester);

      expect(find.text('CONFIRMADOS + EXTRAS SEM APP'), findsOneWidget);
      expect(find.text('QUANTO TEMPO DE FESTA?'), findsOneWidget);
      expect(find.text('QUEM CONFIRMOU'), findsNothing);
      expect(find.text('ATÉ QUE HORAS?'), findsNothing);
    });

    testWidgets('com os rótulos de W-03 mostra os literais do web',
        (tester) async {
      await _montar(
        tester,
        rotuloDePessoas: MontarTextos.secaoDePessoasExpandido,
        rotuloDaDuracao: MontarTextos.duracaoExpandido,
      );

      expect(find.text('QUEM CONFIRMOU'), findsOneWidget);
      expect(find.text('ATÉ QUE HORAS?'), findsOneWidget);
      expect(find.text('CONFIRMADOS + EXTRAS SEM APP'), findsNothing);
      expect(find.text('QUANTO TEMPO DE FESTA?'), findsNothing);
    });

    testWidgets('fora os dois rótulos, a árvore é a mesma — a prova de W-R1',
        (tester) async {
      await _montar(tester);
      final noMobile = _textosDaArvore(tester);

      await _montar(
        tester,
        rotuloDePessoas: MontarTextos.secaoDePessoasExpandido,
        rotuloDaDuracao: MontarTextos.duracaoExpandido,
      );
      final noWeb = _textosDaArvore(tester);

      expect(noWeb, hasLength(noMobile.length));

      final divergentes = <int>[
        for (var i = 0; i < noMobile.length; i++)
          if (noMobile[i] != noWeb[i]) i,
      ];

      expect(divergentes, hasLength(2));
      expect(
        [for (final i in divergentes) noMobile[i]],
        [
          MontarTextos.secaoDePessoasCompacto,
          MontarTextos.duracaoCompacto,
        ],
      );
      expect(
        [for (final i in divergentes) noWeb[i]],
        [
          MontarTextos.secaoDePessoasExpandido,
          MontarTextos.duracaoExpandido,
        ],
      );
    });

    testWidgets('AD-018: PROS FORTES aparece também com os rótulos do mobile',
        (tester) async {
      await _montar(tester);

      expect(find.text('PROS FORTES'), findsOneWidget);
      expect(find.text('🍹 CACHAÇA'), findsOneWidget);
    });
  });

  group('MONT-01 — o formulário reflete a composição que recebe', () {
    testWidgets('contagem, chips marcados e duração vêm do estado',
        (tester) async {
      await _montar(
        tester,
        composicao: ComposicaoDaFesta(
          contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
          duracaoHoras: 6,
          itensSelecionados: const {ChaveItem.bovina, ChaveItem.cerveja},
        ),
      );

      expect(
        tester.widget<CardDeContagem>(find.byType(CardDeContagem)).contagem,
        ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      );
      expect(
        tester.widget<SecaoDeDuracao>(find.byType(SecaoDeDuracao)).indiceAtivo,
        2,
      );
      expect(
        tester
            .widgetList<BoraSelectionChip>(find.byType(BoraSelectionChip))
            .where((c) => c.selecionado)
            .map((c) => c.rotulo),
        unorderedEquals([
          catalogoDeItens[ChaveItem.bovina]!.nome,
          catalogoDeItens[ChaveItem.cerveja]!.nome,
        ]),
      );
    });
  });

  group('MONT-01 — todo callback chega a quem montou, sem transformação', () {
    testWidgets('o stepper devolve o tipo e o passo', (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(
        find.descendant(
          of: find.byType(BoraStepper).at(1),
          matching: find.text(BoraStepper.simboloMais),
        ),
      );

      expect(emitidos.contagem, [(TipoDeCabeca.mulheres, 1)]);
    });

    testWidgets('o chip devolve a própria ChaveItem', (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(find.text('🍹 CACHAÇA'));
      await tester.tap(find.text('💧 ÁGUA'));

      expect(emitidos.itens, [ChaveItem.cachaca, ChaveItem.agua]);
    });

    testWidgets('a duração devolve as horas da opção tocada', (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(find.text('DIA'));

      expect(emitidos.duracoes, [10]);
    });

    testWidgets('nenhum toque muda o formulário sozinho — o estado é de fora',
        (tester) async {
      await _montar(tester);

      await tester.tap(find.text('🍹 CACHAÇA'));
      await tester.tap(find.text('DIA'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widgetList<BoraSelectionChip>(find.byType(BoraSelectionChip))
            .where((c) => c.selecionado),
        isEmpty,
      );
      expect(
        tester.widget<SecaoDeDuracao>(find.byType(SecaoDeDuracao)).indiceAtivo,
        1,
      );
    });
  });
}
