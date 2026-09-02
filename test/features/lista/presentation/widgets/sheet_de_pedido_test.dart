import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/core/responsive/layout_mode.dart';
import 'package:bora/features/lista/domain/parceiro_de_entrega.dart';
import 'package:bora/features/lista/domain/pedido.dart';
import 'package:bora/features/lista/presentation/bloc/lista_bloc.dart';
import 'package:bora/features/lista/presentation/bloc/pedido_bloc.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
import 'package:bora/features/lista/presentation/widgets/cartao_de_parceiro.dart';
import 'package:bora/features/lista/presentation/widgets/sheet_de_pedido.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/festa_em_edicao_repository_fake.dart';
import '../../../../support/pedido_falso_de_teste.dart';
import '../../../../support/recording_app_logger.dart';
import '../../support/festa_rn30.dart';

const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

/// O local da festa de RN-30 — o endereço com que a sheet abre.
const String _enderecoDaFesta = 'Laje do Rafa — Vila Madalena';

const String _festaId = 'festa-1';

const Festa _festaRn30 = Festa(
  nome: 'CHURRAS DO RAFA 🔥',
  data: 'SÁB 18 JUL',
  hora: '14H',
  local: _enderecoDaFesta,
  duracaoHoras: 4,
);

/// O que a sheet devolveu para quem a abriu.
class _Sonda {
  final List<Pedido> confirmados = [];
}

void main() {
  late PedidoFalsoDeTeste porta;
  late RecordingAppLogger logger;

  setUp(() {
    porta = PedidoFalsoDeTeste();
    logger = RecordingAppLogger();
  });

  PedidoBloc criar({
    List<ItemDeLista>? itens,
    bool apenasOQueFalta = false,
  }) =>
      PedidoBloc(
        porta,
        logger,
        itens: itens ?? resultadoRn30().todosOsItens,
        enderecoDaFesta: _enderecoDaFesta,
        apenasOQueFalta: apenasOQueFalta,
      );

  /// Monta a sheet parada, no invólucro que a largura pede.
  Future<_Sonda> montar(
    WidgetTester tester, {
    Size viewport = _frameCompacto,
    List<ItemDeLista>? itens,
    bool apenasOQueFalta = false,
  }) async {
    final sonda = _Sonda();

    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(viewport);
    await tester.pumpWidget(
      MaterialApp(
        theme: boraTheme(),
        home: Scaffold(
          backgroundColor: BoraColors.paper,
          body: BlocProvider<PedidoBloc>(
            create: (_) => criar(itens: itens, apenasOQueFalta: apenasOQueFalta),
            child: SingleChildScrollView(
              child: SheetDePedido(
                expandido: viewport.width >= kCompactBreakpoint,
                aoConfirmar: sonda.confirmados.add,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return sonda;
  }

  /// Abre a sheet **pela rota**, como a tela a abre — é o caminho que tem ✕ e
  /// barreira.
  Future<_Sonda> abrirPelaRota(
    WidgetTester tester, {
    Size viewport = _frameCompacto,
  }) async {
    final sonda = _Sonda();

    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(viewport);
    await tester.pumpWidget(
      MaterialApp(
        theme: boraTheme(),
        home: Scaffold(
          backgroundColor: BoraColors.paper,
          body: Builder(
            builder: (context) => Center(
              child: GestureDetector(
                onTap: () => SheetDePedido.mostrar(
                  context,
                  criarBloc: (_) => criar(),
                  aoConfirmar: sonda.confirmados.add,
                ),
                child: const Text('ABRIR'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ABRIR'));
    await tester.pumpAndSettle();

    return sonda;
  }

  /// O valor de uma linha do resumo — o bloco é nomeado porque o frete do
  /// iFood aparece também no cartão dele.
  Finder valorDoResumo(String rotulo) => find.descendant(
        of: find.ancestor(
          of: find.text(rotulo),
          matching: find.byType(Row),
        ),
        matching: find.byType(Text),
      );

  String valorNoResumo(WidgetTester tester, String rotulo) => tester
      .widgetList<Text>(
        find.descendant(
          of: find.byKey(ConteudoDoPedido.resumoKey),
          matching: valorDoResumo(rotulo),
        ),
      )
      .last
      .data!;

  /// Toda a copy que a sheet põe na tela.
  List<String> copyNaArvore(WidgetTester tester) => tester
      .widgetList<Text>(
        find.descendant(
          of: find.byType(SheetDePedido),
          matching: find.byType(Text),
        ),
      )
      .map((texto) => texto.data!)
      .toList();

  _viewports.forEach((nome, viewport) {
    group('LIST-21 — a cabeça e o endereço ($nome)', () {
      testWidgets('o título é "FAZER PEDIDO", com o ✕ ao lado (A-18)',
          (tester) async {
        await montar(tester, viewport: viewport);

        expect(find.text(ListaTextos.tituloDoPedido), findsOneWidget);
        expect(find.text('✕'), findsOneWidget);
      });

      testWidgets('a linha 📍 traz o endereço da festa e o TROCAR ao lado',
          (tester) async {
        await montar(tester, viewport: viewport);

        expect(find.text(ConteudoDoPedido.pino), findsOneWidget);
        expect(find.text(_enderecoDaFesta), findsOneWidget);
        expect(find.text(ListaTextos.trocar), findsOneWidget);
      });
    });

    group('LIST-22 — os três cartões ($nome)', () {
      testWidgets('saem na ordem de RN-27, com o iFood pré-selecionado',
          (tester) async {
        await montar(tester, viewport: viewport);

        final cartoes = tester
            .widgetList<CartaoDeParceiro>(find.byType(CartaoDeParceiro))
            .toList();

        expect(
          cartoes.map((cartao) => cartao.parceiro),
          ParceiroDeEntrega.values,
        );
        expect(
          cartoes.where((cartao) => cartao.selecionado).map((c) => c.parceiro),
          [ParceiroDeEntrega.ifood],
        );
      });

      testWidgets('o Zé fica inerte com item fora de BEBIDAS (A-09)',
          (tester) async {
        await montar(tester, viewport: viewport);

        final ze = tester.widget<CartaoDeParceiro>(
          find.byWidgetPredicate(
            (widget) =>
                widget is CartaoDeParceiro &&
                widget.parceiro == ParceiroDeEntrega.ze,
          ),
        );

        expect(ze.onSelecionar, isNull);
      });
    });

    group('LIST-23 — o resumo ($nome)', () {
      testWidgets('abre com Subtotal 271, Frete 12 e Total 283',
          (tester) async {
        await montar(tester, viewport: viewport);

        expect(valorNoResumo(tester, ListaTextos.subtotal), r'R$ 271');
        expect(valorNoResumo(tester, ListaTextos.frete), r'R$ 12');
        expect(valorNoResumo(tester, ListaTextos.total), r'R$ 283');
      });

      testWidgets('trocar para o Rappi atualiza os três', (tester) async {
        await montar(tester, viewport: viewport);

        await tester.tap(
          find.byWidgetPredicate(
            (widget) =>
                widget is CartaoDeParceiro &&
                widget.parceiro == ParceiroDeEntrega.rappi,
          ),
        );
        await tester.pumpAndSettle();

        expect(valorNoResumo(tester, ListaTextos.subtotal), r'R$ 271');
        expect(valorNoResumo(tester, ListaTextos.frete), r'R$ 9');
        expect(valorNoResumo(tester, ListaTextos.total), r'R$ 280');
      });
    });
  });

  group('LIST-21 — o TROCAR', () {
    testWidgets('é vermelho e sublinhado', (tester) async {
      await montar(tester);

      final estilo = tester.widget<Text>(find.text(ListaTextos.trocar)).style!;

      expect(estilo.color, BoraColors.primary);
      expect(estilo.decoration, TextDecoration.underline);
    });

    testWidgets('abre a edição do endereço', (tester) async {
      await montar(tester);
      expect(find.byKey(ConteudoDoPedido.campoDoEnderecoKey), findsNothing);

      await tester.tap(find.byKey(ConteudoDoPedido.trocarKey));
      await tester.pumpAndSettle();

      expect(find.byKey(ConteudoDoPedido.campoDoEnderecoKey), findsOneWidget);
    });

    testWidgets('o endereço novo aparece na linha e vai no pedido',
        (tester) async {
      await montar(tester);

      await tester.tap(find.byKey(ConteudoDoPedido.trocarKey));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(ConteudoDoPedido.campoDoEnderecoKey),
        'Rua da Mooca, 300',
      );
      await tester.tap(find.byKey(ConteudoDoPedido.trocarKey));
      await tester.pumpAndSettle();

      expect(find.text('Rua da Mooca, 300'), findsOneWidget);
      expect(find.text(_enderecoDaFesta), findsNothing);

      await tester.tap(find.byKey(ConteudoDoPedido.confirmarKey));
      await tester.pumpAndSettle();

      expect(porta.enviados.single.endereco, 'Rua da Mooca, 300');
    });

    testWidgets('trocar o endereço não escreve nada na porta de festa (A-08)',
        (tester) async {
      final festas = FestaEmEdicaoRepositoryFake(
        festas: {
          _festaId: FestaEmEdicao(
            festa: _festaRn30,
            composicao: composicaoRn30(),
          ),
        },
      );
      addTearDown(festas.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: boraTheme(),
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<ListaBloc>(
                  create: (_) =>
                      ListaBloc(festas, logger, festaId: _festaId),
                ),
                BlocProvider<PedidoBloc>(create: (_) => criar()),
              ],
              child: const SingleChildScrollView(
                child: SheetDePedido(expandido: false),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(ConteudoDoPedido.trocarKey));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(ConteudoDoPedido.campoDoEnderecoKey),
        'Rua da Mooca, 300',
      );
      await tester.tap(find.byKey(ConteudoDoPedido.trocarKey));
      await tester.pumpAndSettle();

      expect(festas.salvas, isEmpty);
    });
  });

  group('LIST-25 — aberta pelo COMPRAR (UC-16 A2)', () {
    testWidgets('o subtotal reflete só os itens que faltam', (tester) async {
      final comCarrinho = resultadoRn30(
        noCarrinho: const {ChaveItem.cerveja, ChaveItem.carvao},
      ).todosOsItens;

      await montar(tester, itens: comCarrinho, apenasOQueFalta: true);

      final inteiro = MoneyFormatter.reais(
        subtotalDeItens(itensCobraveis(comCarrinho)),
      );
      final oQueFalta = MoneyFormatter.reais(
        subtotalDoQueFalta(itensCobraveis(comCarrinho)),
      );

      expect(valorNoResumo(tester, ListaTextos.subtotal), oQueFalta);
      expect(valorNoResumo(tester, ListaTextos.subtotal), isNot(inteiro));
    });

    testWidgets('o título continua "FAZER PEDIDO" (A-18)', (tester) async {
      await montar(tester, apenasOQueFalta: true);

      expect(find.text(ListaTextos.tituloDoPedido), findsOneWidget);
    });
  });

  group('UC-16 A1 — fechar não pede nada', () {
    testWidgets('o ✕ fecha sem criar pedido', (tester) async {
      final sonda = await abrirPelaRota(tester);

      await tester.tap(find.byKey(BoraBottomSheet.fecharKey));
      await tester.pumpAndSettle();

      expect(find.byType(SheetDePedido), findsNothing);
      expect(porta.enviados, isEmpty);
      expect(sonda.confirmados, isEmpty);
    });

    testWidgets('o toque fora fecha sem criar pedido', (tester) async {
      final sonda = await abrirPelaRota(tester);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byType(SheetDePedido), findsNothing);
      expect(porta.enviados, isEmpty);
      expect(sonda.confirmados, isEmpty);
    });
  });

  group('LIST-28 — confirmar devolve o pedido da porta', () {
    testWidgets('"CONFIRMAR PEDIDO →" envia e entrega o pedido confirmado',
        (tester) async {
      final sonda = await montar(tester);

      await tester.tap(find.byKey(ConteudoDoPedido.confirmarKey));
      await tester.pumpAndSettle();

      expect(porta.enviados.length, 1);
      expect(sonda.confirmados.single, porta.enviados.single);
    });
  });

  group('W-04 — um conteúdo, dois invólucros', () {
    testWidgets('compacto e expandido renderizam a mesma copy e os mesmos '
        'números', (tester) async {
      await montar(tester);
      final compacto = copyNaArvore(tester);

      await montar(tester, viewport: _janelaExpandida);
      final expandido = copyNaArvore(tester);

      expect(expandido, compacto);
    });

    testWidgets('cada largura monta o seu invólucro', (tester) async {
      await montar(tester);
      expect(find.byKey(BoraBottomSheet.panelKey), findsOneWidget);
      expect(find.byKey(SheetDePedido.painelExpandidoKey), findsNothing);

      await montar(tester, viewport: _janelaExpandida);
      expect(find.byKey(SheetDePedido.painelExpandidoKey), findsOneWidget);
      expect(find.byKey(BoraBottomSheet.panelKey), findsNothing);
    });

    testWidgets('mostrar escolhe o invólucro pela largura (AD-007)',
        (tester) async {
      await abrirPelaRota(tester, viewport: _janelaExpandida);

      expect(find.byKey(SheetDePedido.painelExpandidoKey), findsOneWidget);
      expect(find.byKey(BoraBottomSheet.panelKey), findsNothing);
    });
  });
}
