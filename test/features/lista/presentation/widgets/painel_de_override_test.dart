import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
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

/// Os passos que o painel emitiu, na ordem: `('quantidade' | 'preco', passos)`.
typedef Intencao = (String, int);

Future<List<Intencao>> _montar(
  WidgetTester tester, {
  required ItemDeLista item,
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
        body: PainelDeOverride(
          item: item,
          aoAjustarQuantidade: (passos) => emitidas.add(('quantidade', passos)),
          aoAjustarPreco: (passos) => emitidas.add(('preco', passos)),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return emitidas;
}

/// Os quatro botões, na ordem em que o painel os desenha.
Finder _menosDaQuantidade() => find.byType(BotaoDePasso).at(0);
Finder _maisDaQuantidade() => find.byType(BotaoDePasso).at(1);
Finder _menosDoPreco() => find.byType(BotaoDePasso).at(2);
Finder _maisDoPreco() => find.byType(BotaoDePasso).at(3);

VoidCallback? _acaoDe(WidgetTester tester, Finder botao) =>
    tester.widget<BotaoDePasso>(botao).onPressed;

void main() {
  final resultado = resultadoRn30();
  final bovina = itemDe(resultado, ChaveItem.bovina);

  /// A Picanha no piso de quantidade: um passo de catálogo (0,5 kg).
  final noPisoDeQuantidade = bovina.copyWith(
    quantidadeOverride: catalogoDeItens[ChaveItem.bovina]!.passoDeQuantidade,
  );

  /// A Picanha no piso de preço de RN-12.
  final noPisoDePreco = bovina.copyWith(precoOverride: 1);

  _viewports.forEach((nome, viewport) {
    group('LIST-11 — os dois steppers ($nome)', () {
      testWidgets('renderizam com os rótulos literais de RN-12',
          (tester) async {
        await _montar(tester, item: bovina, viewport: viewport);

        expect(find.text(ListaTextos.quantidade), findsOneWidget);
        expect(find.text(ListaTextos.preco), findsOneWidget);
        expect(find.byType(BotaoDePasso), findsNWidgets(4));
      });

      testWidgets('exibem os valores formatados pela camada de cálculo',
          (tester) async {
        await _montar(tester, item: bovina, viewport: viewport);

        expect(
          find.text(rotuloDeQuantidade(bovina.quantidade, bovina.unidade)),
          findsOneWidget,
        );
        expect(find.text(MoneyFormatter.reais(bovina.preco)), findsOneWidget);
      });
    });
  });

  group('LIST-11 — o painel emite passos, não valores', () {
    testWidgets('o + e o − de quantidade emitem +1 e -1 passo', (tester) async {
      final emitidas = await _montar(tester, item: bovina);

      await tester.tap(_maisDaQuantidade());
      await tester.tap(_menosDaQuantidade());
      await tester.pump();

      expect(emitidas, [('quantidade', 1), ('quantidade', -1)]);
    });

    testWidgets('o + e o − de preço emitem +1 e -1 passo', (tester) async {
      final emitidas = await _montar(tester, item: bovina);

      await tester.tap(_maisDoPreco());
      await tester.tap(_menosDoPreco());
      await tester.pump();

      expect(emitidas, [('preco', 1), ('preco', -1)]);
    });

    testWidgets('o valor exibido não muda ao tocar — quem calcula é a camada',
        (tester) async {
      await _montar(tester, item: bovina);

      await tester.tap(_maisDaQuantidade());
      await tester.tap(_maisDoPreco());
      await tester.pump();

      expect(
        find.text(rotuloDeQuantidade(bovina.quantidade, bovina.unidade)),
        findsOneWidget,
      );
      expect(find.text(MoneyFormatter.reais(bovina.preco)), findsOneWidget);
    });
  });

  group('RN-12 — o piso, que é do catálogo e não do widget', () {
    testWidgets('fora do piso, os dois decrementos estão ativos',
        (tester) async {
      await _montar(tester, item: bovina);

      expect(_acaoDe(tester, _menosDaQuantidade()), isNotNull);
      expect(_acaoDe(tester, _menosDoPreco()), isNotNull);
    });

    testWidgets('no piso de quantidade o decremento é null e o toque é inerte',
        (tester) async {
      final emitidas = await _montar(tester, item: noPisoDeQuantidade);

      expect(_acaoDe(tester, _menosDaQuantidade()), isNull);

      await tester.tap(_menosDaQuantidade());
      await tester.pump();

      expect(emitidas, isEmpty);
    });

    testWidgets('no piso de quantidade o incremento continua ativo',
        (tester) async {
      final emitidas = await _montar(tester, item: noPisoDeQuantidade);

      await tester.tap(_maisDaQuantidade());
      await tester.pump();

      expect(emitidas, [('quantidade', 1)]);
    });

    testWidgets('no piso de preço o decremento é null e o toque é inerte',
        (tester) async {
      final emitidas = await _montar(tester, item: noPisoDePreco);

      expect(_acaoDe(tester, _menosDoPreco()), isNull);

      await tester.tap(_menosDoPreco());
      await tester.pump();

      expect(emitidas, isEmpty);
    });

    testWidgets('no piso de preço o incremento continua ativo', (tester) async {
      final emitidas = await _montar(tester, item: noPisoDePreco);

      await tester.tap(_maisDoPreco());
      await tester.pump();

      expect(emitidas, [('preco', 1)]);
    });

    testWidgets('o botão inerte fica na opacidade de desabilitado de §3',
        (tester) async {
      await _montar(tester, item: noPisoDePreco);

      final opacidade = tester.widget<Opacity>(
        find.descendant(
          of: _menosDoPreco(),
          matching: find.byType(Opacity),
        ),
      );

      expect(opacidade.opacity, BoraBorders.opacidadeDesabilitado);
    });
  });
}
