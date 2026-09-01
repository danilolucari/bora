import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/lista/presentation/widgets/checkbox_da_lista.dart';
import 'package:bora/features/lista/presentation/widgets/linha_de_compra.dart';
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

Future<List<void>> _montar(
  WidgetTester tester, {
  required ItemDeLista item,
  required bool marcado,
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
        body: LinhaDeCompra(
          item: item,
          marcado: marcado,
          onAlternar: () => toques.add(null),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return toques;
}

/// A opacidade que a linha inteira está usando.
double _opacidadeDaLinha(WidgetTester tester) => tester
    .widget<Opacity>(
      find
          .descendant(
            of: find.byType(LinhaDeCompra),
            matching: find.byType(Opacity),
          )
          .first,
    )
    .opacity;

bool _checkboxMarcado(WidgetTester tester) =>
    tester.widget<CheckboxDaLista>(find.byType(CheckboxDaLista)).marcado;

void main() {
  final resultado = resultadoRn30();
  final cerveja = itemDe(resultado, ChaveItem.cerveja);

  _viewports.forEach((nome, viewport) {
    group('LIST-18 — a linha do checklist ($nome)', () {
      testWidgets('traz checkbox, emoji, nome, quantidade e valor',
          (tester) async {
        await _montar(
          tester,
          item: cerveja,
          marcado: false,
          viewport: viewport,
        );

        expect(find.byType(CheckboxDaLista), findsOneWidget);
        expect(find.text(cerveja.emoji), findsOneWidget);
        expect(find.text(cerveja.nome), findsOneWidget);
        expect(
          find.text(rotuloDeQuantidade(cerveja.quantidade, cerveja.unidade)),
          findsOneWidget,
        );
        expect(
          find.text(MoneyFormatter.reais(cerveja.valor)),
          findsOneWidget,
        );
      });

      testWidgets('tocar o nome — fora do quadradinho — alterna o check',
          (tester) async {
        final toques = await _montar(
          tester,
          item: cerveja,
          marcado: false,
          viewport: viewport,
        );

        await tester.tap(find.text(cerveja.nome));
        await tester.pump();

        expect(toques, hasLength(1));
      });
    });
  });

  group('LIST-18 — o alvo é a linha inteira', () {
    testWidgets('tocar o próprio quadradinho também alterna', (tester) async {
      final toques = await _montar(tester, item: cerveja, marcado: false);

      await tester.tap(find.byType(CheckboxDaLista));
      await tester.pump();

      expect(toques, hasLength(1));
    });

    testWidgets('tocar o valor, na outra ponta da linha, também alterna',
        (tester) async {
      final toques = await _montar(tester, item: cerveja, marcado: false);

      await tester.tap(find.text(MoneyFormatter.reais(cerveja.valor)));
      await tester.pump();

      expect(toques, hasLength(1));
    });
  });

  group('LIST-18 — os dois estados da linha', () {
    testWidgets('marcada: ✓ no checkbox e a linha na opacidade de T-04',
        (tester) async {
      await _montar(tester, item: cerveja, marcado: true);

      expect(_checkboxMarcado(tester), isTrue);
      expect(find.text(CheckboxDaLista.simboloDoCheck), findsOneWidget);
      expect(_opacidadeDaLinha(tester), LinhaDeCompra.opacidadeMarcada);
    });

    testWidgets('desmarcada: sem ✓ e na opacidade cheia', (tester) async {
      await _montar(tester, item: cerveja, marcado: false);

      expect(_checkboxMarcado(tester), isFalse);
      expect(find.text(CheckboxDaLista.simboloDoCheck), findsNothing);
      expect(_opacidadeDaLinha(tester), LinhaDeCompra.opacidadeNormal);
    });

    testWidgets('as duas opacidades são diferentes — marcar apaga a linha',
        (tester) async {
      expect(
        LinhaDeCompra.opacidadeMarcada,
        lessThan(LinhaDeCompra.opacidadeNormal),
      );
    });

    testWidgets('o valor exibido não muda ao marcar — marcar não é preço',
        (tester) async {
      await _montar(tester, item: cerveja, marcado: false);
      expect(find.text(MoneyFormatter.reais(cerveja.valor)), findsOneWidget);

      await _montar(tester, item: cerveja, marcado: true);
      expect(find.text(MoneyFormatter.reais(cerveja.valor)), findsOneWidget);
    });
  });

  group('LIST-18 — o que o modo COMPRAR não tem', () {
    testWidgets('nenhuma barra de faixa e nenhuma régua de override',
        (tester) async {
      await _montar(tester, item: cerveja, marcado: false);

      expect(find.byType(BoraPriceRangeBar), findsNothing);
      expect(find.byType(PainelDeOverride), findsNothing);
    });
  });
}
