import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
import 'package:bora/features/lista/presentation/widgets/card_de_comprar.dart';
import 'package:bora/features/lista/presentation/widgets/linha_de_compra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/festa_rn30.dart';

const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

const String _arquivoDoCard =
    'lib/features/lista/presentation/widgets/card_de_comprar.dart';

/// A ordem literal de RN-27, em rótulo.
const List<String> _rotulosDeRn27 = [
  'AÇOUGUE',
  'HORTIFRÚTI',
  'PADARIA',
  'BEBIDAS',
  'MERCEARIA',
];

Future<List<ChaveItem>> _montar(
  WidgetTester tester, {
  required ResultadoDoCalculo resultado,
  Size viewport = _frameCompacto,
}) async {
  final alternados = <ChaveItem>[];

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: SingleChildScrollView(
          child: CardDeComprar(
            resultado: resultado,
            aoAlternar: alternados.add,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return alternados;
}

/// Os corredores renderizados, na ordem da árvore.
List<Corredor> _corredoresNaArvore(WidgetTester tester) => tester
    .widgetList<GrupoDoCorredor>(find.byType(GrupoDoCorredor))
    .map((grupo) => grupo.corredor)
    .toList();

/// As chaves renderizadas, na ordem da árvore.
List<ChaveItem> _chavesNaArvore(WidgetTester tester) => tester
    .widgetList<LinhaDeCompra>(find.byType(LinhaDeCompra))
    .map((linha) => linha.item.chave)
    .toList();

Finder _grupo(Corredor corredor) => find.byWidgetPredicate(
      (widget) => widget is GrupoDoCorredor && widget.corredor == corredor,
    );

/// Uma lista só de bebidas, montada à mão: a calculadora sempre acrescenta os
/// quatro essenciais de RN-10, e o caso "corredor sem item" precisa de uma
/// lista que não os tenha.
ResultadoDoCalculo _soDeBebidas() {
  final padrao = resultadoRn30();

  return ResultadoDoCalculo(
    itens: [
      itemDe(padrao, ChaveItem.refrigerante),
      itemDe(padrao, ChaveItem.agua),
      itemDe(padrao, ChaveItem.cerveja),
    ],
    essenciais: const [],
    contagem: padrao.contagem,
    fator: padrao.fator,
    totalDosItens: padrao.totalDosItens,
    totalDosEssenciais: 0,
    porCabeca: padrao.porCabeca,
    porAdulto: padrao.porAdulto,
  );
}

void main() {
  final padrao = resultadoRn30();
  final vazio = resultadoRn30(contagem: ContagemDePessoas());
  final comCarrinho = resultadoRn30(
    noCarrinho: const {ChaveItem.cerveja, ChaveItem.carvao},
  );

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
    group('LIST-16 — a ordem dos corredores ($nome)', () {
      testWidgets('os grupos saem na ordem de RN-27', (tester) async {
        await _montar(tester, resultado: padrao, viewport: viewport);

        expect(
          _corredoresNaArvore(tester),
          [
            Corredor.acougue,
            Corredor.padaria,
            Corredor.bebidas,
            Corredor.mercearia,
          ],
        );
      });

      testWidgets('cada grupo traz o rótulo em caixa alta e "{N} itens"',
          (tester) async {
        await _montar(tester, resultado: padrao, viewport: viewport);

        for (final corredor in _corredoresNaArvore(tester)) {
          final grupo = tester.widget<GrupoDoCorredor>(_grupo(corredor));

          expect(
            find.descendant(
              of: _grupo(corredor),
              matching: find.text(ListaTextos.rotuloDoCorredor(corredor)),
            ),
            findsOneWidget,
          );
          expect(
            find.descendant(
              of: _grupo(corredor),
              matching:
                  find.text(ListaTextos.itensNoCorredor(grupo.itens.length)),
            ),
            findsOneWidget,
          );
        }
      });
    });
  });

  group('LIST-16 — a ordem é da feature, não do enum', () {
    test('a lista literal é a de RN-27', () {
      expect(
        CardDeComprar.ordemDosCorredores.map(ListaTextos.rotuloDoCorredor),
        _rotulosDeRn27,
      );
    });

    test('o card não lê `Corredor.values` nem o `index` do enum', () {
      // Sem os comentários: o arquivo **documenta** que não usa nenhum dos
      // dois, e a prosa que explica a decisão não pode acusá-lo.
      final codigo = File(_arquivoDoCard)
          .readAsStringSync()
          .replaceAll(RegExp('//.*'), '');

      expect(codigo, isNot(contains('Corredor.values')));
      expect(codigo, isNot(contains('.index')));
    });

    testWidgets('marcar itens não reordena corredor nem linha', (tester) async {
      await _montar(tester, resultado: padrao);
      final corredoresAntes = _corredoresNaArvore(tester);
      final chavesAntes = _chavesNaArvore(tester);

      await _montar(tester, resultado: comCarrinho);

      expect(_corredoresNaArvore(tester), corredoresAntes);
      expect(_chavesNaArvore(tester), chavesAntes);
    });
  });

  group('LIST-16 — corredor sem item não renderiza', () {
    testWidgets('uma lista só de bebidas deixa os outros quatro fora da árvore',
        (tester) async {
      await _montar(tester, resultado: _soDeBebidas());

      expect(_corredoresNaArvore(tester), [Corredor.bebidas]);
      for (final rotulo in _rotulosDeRn27) {
        expect(
          find.text(rotulo),
          rotulo == 'BEBIDAS' ? findsOneWidget : findsNothing,
        );
      }
    });

    testWidgets('sem legumes, HORTIFRÚTI não aparece no estado padrão',
        (tester) async {
      await _montar(tester, resultado: padrao);

      expect(_grupo(Corredor.hortifruti), findsNothing);
    });
  });

  group('LIST-17 — o corredor sai do catálogo, não da tabela de RN-11', () {
    testWidgets('frango cai em AÇOUGUE', (tester) async {
      await _montar(tester, resultado: padrao);

      expect(
        find.descendant(
          of: _grupo(Corredor.acougue),
          matching: find.text(itemDe(padrao, ChaveItem.frango).nome),
        ),
        findsOneWidget,
      );
    });

    testWidgets('água e cachaça caem em BEBIDAS', (tester) async {
      await _montar(tester, resultado: padrao);

      for (final chave in [ChaveItem.agua, ChaveItem.cachaca]) {
        expect(
          find.descendant(
            of: _grupo(Corredor.bebidas),
            matching: find.text(itemDe(padrao, chave).nome),
          ),
          findsOneWidget,
          reason: '${chave.chave} é bebida no catálogo',
        );
      }
    });

    testWidgets('sal grosso e copos & pratos caem em MERCEARIA',
        (tester) async {
      await _montar(tester, resultado: padrao);

      for (final chave in [ChaveItem.salGrosso, ChaveItem.coposEPratos]) {
        expect(
          find.descendant(
            of: _grupo(Corredor.mercearia),
            matching: find.text(itemDe(padrao, chave).nome),
          ),
          findsOneWidget,
          reason: '${chave.chave} é mercearia no catálogo',
        );
      }
    });

    testWidgets('o kit veggie de RN-21 cai em HORTIFRÚTI', (tester) async {
      await _montar(tester, resultado: comVeggie);

      expect(
        find.descendant(
          of: _grupo(Corredor.hortifruti),
          matching:
              find.text(itemDe(comVeggie, ChaveItem.legumesParaGrelha).nome),
        ),
        findsOneWidget,
      );
    });
  });

  group('LIST-20 — o carrinho e o toque', () {
    testWidgets('a linha reflete o carrinho que a composição carrega',
        (tester) async {
      await _montar(tester, resultado: comCarrinho);

      final marcadas = tester
          .widgetList<LinhaDeCompra>(find.byType(LinhaDeCompra))
          .where((linha) => linha.marcado)
          .map((linha) => linha.item.chave)
          .toSet();

      expect(marcadas, {ChaveItem.cerveja, ChaveItem.carvao});
    });

    testWidgets('tocar uma linha pede para alternar a chave dela',
        (tester) async {
      final alternados = await _montar(tester, resultado: padrao);

      await tester.tap(find.text(itemDe(padrao, ChaveItem.gelo).nome));
      await tester.pump();

      expect(alternados, [ChaveItem.gelo]);
    });
  });

  group('LIST-31 — a lista vazia', () {
    testWidgets('festa sem ninguém não renderiza grupo nenhum', (tester) async {
      await _montar(tester, resultado: vazio);

      expect(find.byType(GrupoDoCorredor), findsNothing);
      expect(find.byType(LinhaDeCompra), findsNothing);
      for (final rotulo in _rotulosDeRn27) {
        expect(find.text(rotulo), findsNothing);
      }
    });
  });
}
