import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
import 'package:bora/features/lista/presentation/widgets/card_de_planejar.dart';
import 'package:bora/features/lista/presentation/widgets/linha_de_item.dart';
import 'package:bora/features/lista/presentation/widgets/painel_de_override.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/festa_rn30.dart';

const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

/// Os quatro essenciais de RN-10, na ordem canônica.
const List<ChaveItem> _essenciaisDeRn10 = [
  ChaveItem.carvao,
  ChaveItem.gelo,
  ChaveItem.salGrosso,
  ChaveItem.coposEPratos,
];

/// O que o card pediu: `('expandir' | 'quantidade' | 'preco', chave, passos)`.
typedef Intencao = (String, ChaveItem?, int);

Future<List<Intencao>> _montar(
  WidgetTester tester, {
  required ResultadoDoCalculo resultado,
  ChaveItem? chaveExpandida,
  Size viewport = _frameCompacto,
}) async {
  final emitidas = <Intencao>[];

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: SingleChildScrollView(
          child: CardDePlanejar(
            resultado: resultado,
            chaveExpandida: chaveExpandida,
            aoAlternar: (chave) => emitidas.add(('expandir', chave, 0)),
            aoAjustarQuantidade: (chave, passos) =>
                emitidas.add(('quantidade', chave, passos)),
            aoAjustarPreco: (chave, passos) =>
                emitidas.add(('preco', chave, passos)),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return emitidas;
}

/// As chaves das linhas renderizadas, **na ordem em que a árvore as tem**.
List<ChaveItem> _chavesNaArvore(WidgetTester tester) => tester
    .widgetList<LinhaDeItem>(find.byType(LinhaDeItem))
    .map((linha) => linha.item.chave)
    .toList();

void main() {
  final padrao = resultadoRn30();
  final vazio = resultadoRn30(contagem: ContagemDePessoas());

  /// O estado padrão com uma pessoa veggie: RN-21 acrescenta o kit de legumes.
  final comVeggie = CalculadoraDaFesta.calcular(
    composicaoRn30(
      pessoas: const [
        Pessoa(
          nome: 'Duda',
          papel: PapelNaFesta.convidado,
          status: StatusDePresenca.confirmado,
          dieta: Dieta.veggie,
        ),
      ],
    ),
  );

  _viewports.forEach((nome, viewport) {
    group('LIST-03 — a lista na ordem canônica ($nome)', () {
      testWidgets('os itens saem na ordem de ordemCanonicaDaLista',
          (tester) async {
        await _montar(tester, resultado: padrao, viewport: viewport);

        final esperada = [
          for (final chave in ordemCanonicaDaLista)
            if (padrao.todosOsItens.any((item) => item.chave == chave)) chave,
        ];

        expect(_chavesNaArvore(tester), esperada);
      });

      testWidgets('nenhum item que a composição não produza aparece',
          (tester) async {
        await _montar(tester, resultado: padrao, viewport: viewport);

        expect(_chavesNaArvore(tester), isNot(contains(ChaveItem.suina)));
        expect(_chavesNaArvore(tester), isNot(contains(ChaveItem.vodka)));
        expect(
          _chavesNaArvore(tester),
          isNot(contains(ChaveItem.legumesParaGrelha)),
        );
      });
    });

    group('LIST-04 — os essenciais entram sozinhos ($nome)', () {
      testWidgets('a categoria literal traz os quatro de RN-10 sem interação',
          (tester) async {
        await _montar(tester, resultado: padrao, viewport: viewport);

        expect(
          find.text(ListaTextos.categoriaDosEssenciais),
          findsOneWidget,
        );
        for (final chave in _essenciaisDeRn10) {
          expect(
            _chavesNaArvore(tester),
            contains(chave),
            reason: '${chave.chave} é essencial de RN-10',
          );
        }
      });
    });
  });

  group('LIST-04 — a badge amarela AUTO ∝', () {
    testWidgets('cada essencial traz a badge com a fonte literal de RN-10',
        (tester) async {
      await _montar(tester, resultado: padrao);

      final fontes = tester
          .widgetList<BadgeAuto>(find.byType(BadgeAuto))
          .map((badge) => badge.fonte)
          .toList();

      expect(fontes, [
        'kg de carne',
        'volume de bebida gelada',
        'kg de carne',
        'nº de pessoas',
      ]);
      expect(
        find.text(ListaTextos.autoProporcional('volume de bebida gelada')),
        findsOneWidget,
      );
    });

    testWidgets('a badge é amarela, na forma de §5', (tester) async {
      await _montar(tester, resultado: padrao);

      final superficie = tester.widget<BoraSurface>(
        find.descendant(
          of: find.byType(BadgeAuto).first,
          matching: find.byType(BoraSurface),
        ),
      );

      expect(superficie.fundo, BoraColors.yellow);
    });

    testWidgets('item escolhido não recebe badge — ela é dos essenciais',
        (tester) async {
      await _montar(tester, resultado: padrao);

      expect(find.byType(BadgeAuto), findsNWidgets(4));
    });
  });

  group('LIST-05, AD-010 — os subtotais vêm da camada', () {
    testWidgets('o subtotal dos essenciais lê R\$ 60 no estado padrão',
        (tester) async {
      await _montar(tester, resultado: padrao);

      expect(
        find.text(MoneyFormatter.reais(totalDosEssenciais(padrao.essenciais))),
        findsOneWidget,
      );
      expect(find.text('R\$ 60'), findsOneWidget);
    });

    testWidgets('🍽️ Copos & pratos aparece na lista e não soma', (tester) async {
      await _montar(tester, resultado: padrao);

      final copos = itemDe(padrao, ChaveItem.coposEPratos);

      expect(_chavesNaArvore(tester), contains(ChaveItem.coposEPratos));
      expect(copos.valor, greaterThan(0));
      expect(
        totalDosEssenciais(padrao.essenciais),
        lessThan(totalExato(padrao.essenciais)),
      );
    });

    testWidgets('o subtotal dos escolhidos vem de totalExato', (tester) async {
      await _montar(tester, resultado: padrao);

      expect(
        find.text(MoneyFormatter.reais(totalExato(padrao.itens))),
        findsOneWidget,
      );
      expect(
        find.text(ListaTextos.subtotalDaCategoria),
        findsNWidgets(2),
      );
    });
  });

  group('LIST-31, A-11 — a lista vazia', () {
    testWidgets('festa sem ninguém não renderiza item, essencial nem rótulo',
        (tester) async {
      await _montar(tester, resultado: vazio);

      expect(find.byType(LinhaDeItem), findsNothing);
      expect(find.byType(BadgeAuto), findsNothing);
      expect(find.text(ListaTextos.categoriaDosEssenciais), findsNothing);
      expect(find.text(ListaTextos.subtotalDaCategoria), findsNothing);
    });
  });

  group('LIST-10 — abrir um item fecha o anterior', () {
    testWidgets('só o item expandido abre a régua', (tester) async {
      await _montar(
        tester,
        resultado: padrao,
        chaveExpandida: ChaveItem.bovina,
      );

      expect(find.byType(PainelDeOverride), findsOneWidget);
      expect(
        tester.widget<PainelDeOverride>(find.byType(PainelDeOverride)).item
            .chave,
        ChaveItem.bovina,
      );

      final abertas = tester
          .widgetList<LinhaDeItem>(find.byType(LinhaDeItem))
          .where((linha) => linha.aberta)
          .map((linha) => linha.item.chave)
          .toList();

      expect(abertas, [ChaveItem.bovina]);
    });

    testWidgets('tocar outra linha pede a chave dela, não um conjunto',
        (tester) async {
      final emitidas = await _montar(
        tester,
        resultado: padrao,
        chaveExpandida: ChaveItem.bovina,
      );

      await tester.tap(find.text(itemDe(padrao, ChaveItem.cerveja).nome));
      await tester.pump();

      expect(emitidas, [('expandir', ChaveItem.cerveja, 0)]);
    });

    testWidgets('tocar a linha aberta pede fechar', (tester) async {
      final emitidas = await _montar(
        tester,
        resultado: padrao,
        chaveExpandida: ChaveItem.bovina,
      );

      await tester.tap(find.text(itemDe(padrao, ChaveItem.bovina).nome));
      await tester.pump();

      expect(emitidas, [('expandir', null, 0)]);
    });

    testWidgets('a régua aberta encaminha os passos com a chave do item',
        (tester) async {
      final emitidas = await _montar(
        tester,
        resultado: padrao,
        chaveExpandida: ChaveItem.bovina,
      );

      await tester.tap(find.byType(BotaoDePasso).at(1));
      await tester.pump();

      expect(emitidas, [('quantidade', ChaveItem.bovina, 1)]);
    });

    testWidgets('essencial não expande — a calculadora o reconstrói sozinho',
        (tester) async {
      final emitidas = await _montar(tester, resultado: padrao);

      final carvao = tester
          .widgetList<LinhaDeItem>(find.byType(LinhaDeItem))
          .firstWhere((linha) => linha.item.chave == ChaveItem.carvao);

      expect(carvao.onAlternar, isNull);

      await tester.tap(find.text(carvao.item.nome));
      await tester.pump();

      expect(emitidas, isEmpty);
    });
  });

  group('RN-21 — o kit veggie entra pela preferência', () {
    testWidgets('cai na posição canônica e traz a leitura de mercado',
        (tester) async {
      await _montar(tester, resultado: comVeggie);

      final chaves = _chavesNaArvore(tester);

      expect(chaves, contains(ChaveItem.legumesParaGrelha));
      expect(
        chaves.indexOf(ChaveItem.legumesParaGrelha),
        greaterThan(chaves.indexOf(ChaveItem.cerveja)),
      );
      expect(
        chaves.indexOf(ChaveItem.legumesParaGrelha),
        lessThan(chaves.indexOf(ChaveItem.carvao)),
      );

      final kit = itemDe(comVeggie, ChaveItem.legumesParaGrelha);

      expect(
        find.text(
          ListaTextos.mediaDeMercados(
            rotuloDeQuantidade(kit.quantidade, kit.unidade),
            2,
          ),
        ),
        findsOneWidget,
      );
    });
  });
}
