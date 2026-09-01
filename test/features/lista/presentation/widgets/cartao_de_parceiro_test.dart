import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/lista/domain/parceiro_de_entrega.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
import 'package:bora/features/lista/presentation/widgets/cartao_de_parceiro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

const String _arquivoDoCartao =
    'lib/features/lista/presentation/widgets/cartao_de_parceiro.dart';

/// Os literais de RN-27, escritos como a spec-fonte os escreve — e não lidos
/// do enum, que é justamente o que estes testes precisam checar.
const Map<ParceiroDeEntrega, ({String nome, String eta})> _rn27 = {
  ParceiroDeEntrega.ifood: (nome: 'iFood Mercado', eta: '40–60 min'),
  ParceiroDeEntrega.rappi: (nome: 'Rappi Turbo', eta: '15–30 min'),
  ParceiroDeEntrega.ze: (nome: 'Zé Delivery', eta: '30–45 min'),
};

Future<List<int>> _montar(
  WidgetTester tester, {
  required ParceiroDeEntrega parceiro,
  bool selecionado = false,
  bool inerte = false,
  Size viewport = _frameCompacto,
}) async {
  final toques = <int>[];

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: CartaoDeParceiro(
          parceiro: parceiro,
          selecionado: selecionado,
          onSelecionar: inerte ? null : () => toques.add(1),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return toques;
}

/// A decoração que o cartão de fato pinta — a do `BoraPressSink`, que é a
/// primeira da árvore.
BoxDecoration _decoracaoDoCartao(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(BoraPressSink),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );

  return caixa.decoration as BoxDecoration;
}

/// As decorações do dot, de fora para dentro — uma quando vazio, duas quando
/// preenchido.
List<BoxDecoration> _decoracoesDoDot(WidgetTester tester) => tester
    .widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(DotDeSelecao),
        matching: find.byType(DecoratedBox),
      ),
    )
    .map((caixa) => caixa.decoration as BoxDecoration)
    .toList();

/// A translação que o cartão aplica agora.
Matrix4 _translacao(WidgetTester tester) => tester
    .widget<Transform>(
      find
          .descendant(
            of: find.byType(BoraPressSink),
            matching: find.byType(Transform),
          )
          .first,
    )
    .transform;

/// Toda a copy que o cartão põe na tela.
Set<String> _copyNaArvore(WidgetTester tester) => tester
    .widgetList<Text>(find.descendant(
      of: find.byType(CartaoDeParceiro),
      matching: find.byType(Text),
    ))
    .map((texto) => texto.data!)
    .toSet();

void main() {
  _viewports.forEach((nome, viewport) {
    group('LIST-22 — os literais de RN-27 ($nome)', () {
      for (final parceiro in ParceiroDeEntrega.values) {
        testWidgets('${_rn27[parceiro]!.nome} traz nome e "chega em {eta}"',
            (tester) async {
          await _montar(tester, parceiro: parceiro, viewport: viewport);

          expect(find.text(_rn27[parceiro]!.nome), findsOneWidget);
          expect(
            find.text(ListaTextos.chegaEmEta(_rn27[parceiro]!.eta)),
            findsOneWidget,
          );
        });
      }

      testWidgets('o frete do iFood e do Rappi sai por MoneyFormatter',
          (tester) async {
        await _montar(
          tester,
          parceiro: ParceiroDeEntrega.ifood,
          viewport: viewport,
        );
        expect(find.text(MoneyFormatter.reais(12)), findsOneWidget);

        await _montar(
          tester,
          parceiro: ParceiroDeEntrega.rappi,
          viewport: viewport,
        );
        expect(find.text(MoneyFormatter.reais(9)), findsOneWidget);
      });

      testWidgets('o frete do Zé é lido como "grátis", e não como zero',
          (tester) async {
        await _montar(
          tester,
          parceiro: ParceiroDeEntrega.ze,
          viewport: viewport,
        );

        expect(find.text(ListaTextos.freteGratis), findsOneWidget);
        expect(find.text(MoneyFormatter.reais(0)), findsNothing);
      });
    });

    group('LIST-24 — o qualificador do Zé ($nome)', () {
      testWidgets('"(só bebidas)" aparece no cartão do Zé', (tester) async {
        await _montar(
          tester,
          parceiro: ParceiroDeEntrega.ze,
          viewport: viewport,
        );

        expect(find.text(ListaTextos.soBebidas), findsOneWidget);
      });

      testWidgets('os outros dois cartões não trazem o qualificador',
          (tester) async {
        for (final parceiro in [
          ParceiroDeEntrega.ifood,
          ParceiroDeEntrega.rappi,
        ]) {
          await _montar(tester, parceiro: parceiro, viewport: viewport);

          expect(find.text(ListaTextos.soBebidas), findsNothing);
        }
      });
    });
  });

  group('LIST-24 — o cartão inerte (A-09)', () {
    testWidgets('o qualificador continua lá quando o cartão está inerte',
        (tester) async {
      await _montar(tester, parceiro: ParceiroDeEntrega.ze, inerte: true);

      expect(find.text(ListaTextos.soBebidas), findsOneWidget);
    });

    testWidgets('o toque não emite nada', (tester) async {
      final toques = await _montar(
        tester,
        parceiro: ParceiroDeEntrega.ze,
        inerte: true,
      );

      await tester.tap(find.byType(CartaoDeParceiro));
      await tester.pumpAndSettle();

      expect(toques, isEmpty);
    });

    testWidgets('inerte não acrescenta copy nenhuma — a explicação é o '
        'qualificador', (tester) async {
      await _montar(tester, parceiro: ParceiroDeEntrega.ze, inerte: true);

      expect(_copyNaArvore(tester), {
        'Zé Delivery',
        ListaTextos.soBebidas,
        ListaTextos.chegaEmEta('30–45 min'),
        ListaTextos.freteGratis,
      });
    });

    testWidgets('inerte não afunda no press', (tester) async {
      await _montar(tester, parceiro: ParceiroDeEntrega.ze, inerte: true);

      final gesto = await tester.startGesture(
        tester.getCenter(find.byType(CartaoDeParceiro)),
      );
      await tester.pumpAndSettle();

      expect(_translacao(tester), Matrix4.translationValues(0, 0, 0));

      await gesto.up();
      await tester.pumpAndSettle();
    });
  });

  group('LIST-22 — selecionado × não selecionado', () {
    testWidgets('selecionado: fundo paper, borda vermelha e dot preenchido',
        (tester) async {
      await _montar(
        tester,
        parceiro: ParceiroDeEntrega.ifood,
        selecionado: true,
      );

      final decoracao = _decoracaoDoCartao(tester);
      expect(decoracao.color, BoraColors.paper);
      expect((decoracao.border! as Border).top.color, BoraColors.primary);

      final dot = _decoracoesDoDot(tester);
      expect(dot.length, 2);
      expect((dot.first.border! as Border).top.color, BoraColors.primary);
      expect(dot.last.color, BoraColors.primary);
    });

    testWidgets('não selecionado: fundo branco, borda ink e dot vazio',
        (tester) async {
      await _montar(tester, parceiro: ParceiroDeEntrega.ifood);

      final decoracao = _decoracaoDoCartao(tester);
      expect(decoracao.color, BoraColors.white);
      expect((decoracao.border! as Border).top.color, BoraColors.ink);

      final dot = _decoracoesDoDot(tester);
      expect(dot.length, 1);
      expect((dot.single.border! as Border).top.color, BoraColors.ink);
    });

    testWidgets('o toque emite a seleção', (tester) async {
      final toques = await _montar(tester, parceiro: ParceiroDeEntrega.rappi);

      await tester.tap(find.byType(CartaoDeParceiro));
      await tester.pumpAndSettle();

      expect(toques.length, 1);
    });
  });

  group('DS-11 — o cartão afunda no press (§4)', () {
    testWidgets('pointer down desloca (2,2) e encolhe a sombra de 4 para 2',
        (tester) async {
      await _montar(tester, parceiro: ParceiroDeEntrega.ifood);

      expect(_translacao(tester), Matrix4.translationValues(0, 0, 0));
      expect(
        _decoracaoDoCartao(tester).boxShadow!.single.offset,
        const Offset(4, 4),
      );

      final gesto = await tester.startGesture(
        tester.getCenter(find.byType(CartaoDeParceiro)),
      );
      await tester.pumpAndSettle();

      expect(_translacao(tester), Matrix4.translationValues(2, 2, 0));
      expect(
        _decoracaoDoCartao(tester).boxShadow!.single.offset,
        const Offset(2, 2),
      );

      await gesto.up();
      await tester.pumpAndSettle();
    });
  });

  group('AD-011 — nenhuma cor fora dos tokens', () {
    test('o arquivo do cartão não tem literal de cor', () {
      final codigo = File(_arquivoDoCartao).readAsStringSync();

      expect(codigo, isNot(matches(RegExp(r'Color\(0x'))));
      expect(codigo, isNot(matches(RegExp(r'Colors\.'))));
    });
  });
}
