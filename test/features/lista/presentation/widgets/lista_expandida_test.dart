import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/lista/presentation/bloc/lista_bloc.dart';
import 'package:bora/features/lista/presentation/bloc/pedido_bloc.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
import 'package:bora/features/lista/presentation/widgets/card_de_planejar.dart';
import 'package:bora/features/lista/presentation/widgets/linha_de_item.dart';
import 'package:bora/features/lista/presentation/widgets/lista_compacta.dart';
import 'package:bora/features/lista/presentation/widgets/lista_expandida.dart';
import 'package:bora/features/lista/presentation/widgets/sheet_de_pedido.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/festa_em_edicao_repository_fake.dart';
import '../../../../support/pedido_falso_de_teste.dart';
import '../../../../support/recording_app_logger.dart';
import '../../support/festa_rn30.dart';

const Size _janelaExpandida = Size(1180, 800);
const String _festaId = 'rafa18';
const String _endereco = 'Laje do Rafa — Vila Madalena';

class _Palco {
  _Palco(this.bloc, this.pedidos);

  final ListaBloc bloc;
  final List<ModoDaLista> pedidos;

  ListaState get estado => bloc.state;
}

FestaEmEdicao _festaCom(ComposicaoDaFesta composicao) => FestaEmEdicao(
      festa: Festa(
        nome: 'CHURRAS DO RAFA',
        data: 'SÁB · 18 JUL',
        hora: '14H',
        local: _endereco,
        duracaoHoras: composicao.duracaoHoras,
      ),
      composicao: composicao,
    );

/// Monta W-04 com o **bloc real** por trás, na janela de 1180×800.
///
/// [abrirPedido] liga o CTA à sheet — é como a página o liga — para que o
/// invólucro do pedido em expandido seja observável a partir desta tela.
Future<_Palco> _montar(
  WidgetTester tester, {
  ComposicaoDaFesta? composicao,
  Size janela = _janelaExpandida,
  bool abrirPedido = false,
}) async {
  final porta = FestaEmEdicaoRepositoryFake(
    festas: {_festaId: _festaCom(composicao ?? composicaoRn30())},
  );
  addTearDown(porta.dispose);

  final bloc = ListaBloc(porta, RecordingAppLogger(), festaId: _festaId);
  addTearDown(bloc.close);

  final pedidos = <ModoDaLista>[];

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: BlocBuilder<ListaBloc, ListaState>(
          bloc: bloc,
          builder: (context, estado) => ListaExpandida(
            estado: estado,
            aoAlternarModo: (modo) => bloc.add(ModoAlternado(modo)),
            aoAlternarItem: (chave) => bloc.add(ItemExpandido(chave)),
            aoAjustarQuantidade: (chave, passos) =>
                bloc.add(QuantidadeAjustada(chave, passos)),
            aoAjustarPreco: (chave, passos) =>
                bloc.add(PrecoAjustado(chave, passos)),
            aoAlternarNoCarrinho: (chave) =>
                bloc.add(ItemAlternadoNoCarrinho(chave)),
            aoRestaurar: () => bloc.add(const OverridesRestaurados()),
            aoPedir: () {
              pedidos.add(estado.modo);
              if (!abrirPedido) return;

              SheetDePedido.mostrar(
                context,
                criarBloc: (_) => PedidoBloc(
                  PedidoFalsoDeTeste(),
                  RecordingAppLogger(),
                  itens: estado.resultado!.todosOsItens,
                  enderecoDaFesta: _endereco,
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return _Palco(bloc, pedidos);
}

Finder _noRail(String texto) => find.descendant(
      of: find.byType(BlocoDeTotal),
      matching: find.text(texto),
    );

double _topo(WidgetTester tester, Finder alvo) =>
    tester.getTopLeft(alvo).dy;

BoraPrimaryButton _cta(WidgetTester tester) =>
    tester.widget<BoraPrimaryButton>(find.byKey(RailDaLista.ctaKey));

Future<void> _irParaComprar(WidgetTester tester) async {
  await tester.tap(find.text(ListaTextos.modoComprar.toUpperCase()));
  await tester.pumpAndSettle();
}

void main() {
  group('LIST-29 — o grid 1fr / 370px de W-04', () {
    testWidgets('o card de itens fica à esquerda e o rail de 370px à direita',
        (tester) async {
      await _montar(tester);

      final card = tester.getRect(find.byType(CardDePlanejar));
      final rail = tester.getRect(find.byType(RailDaLista));

      expect(rail.width, ListaExpandida.larguraDoRail);
      expect(
        card.right,
        lessThanOrEqualTo(rail.left),
        reason: 'W-04: a coluna principal vem antes do rail',
      );
      expect(
        card.width,
        greaterThan(rail.width),
        reason: '"1fr" é o que sobra da janela, e sobra mais que 370px',
      );
    });

    testWidgets('o rail tem os cinco blocos de W-04 nesta ordem: segmented, '
        'total, faixa real, por adulto e CTA', (tester) async {
      final palco = await _montar(tester);
      final resultado = palco.estado.resultado!;
      final faixa = faixaRealDaLista(
        resultado.todosOsItens,
        tabelaDePrecosDeMercado,
      );

      final ordem = [
        _topo(tester, find.byType(BoraSegmentedControl)),
        _topo(
          tester,
          _noRail(MoneyFormatter.reais(resultado.totalComEssenciais)),
        ),
        _topo(
          tester,
          _noRail(
            ListaTextos.faixaReal(
              MoneyFormatter.reais(faixa.minimo),
              MoneyFormatter.reais(faixa.maximo),
            ),
          ),
        ),
        _topo(
          tester,
          _noRail(
            ListaTextos.porAdulto(MoneyFormatter.reais(resultado.porAdulto)),
          ),
        ),
        _topo(tester, find.byKey(RailDaLista.ctaKey)),
      ];

      expect(
        ordem,
        orderedEquals(<double>[...ordem]..sort()),
        reason: 'a ordem de W-04 é literal, não presumida',
      );
      expect(ordem.toSet(), hasLength(ordem.length));
    });

    testWidgets('em COMPRAR o contador do carrinho ocupa o lugar da faixa, '
        'entre o total e o "por adulto"', (tester) async {
      final palco = await _montar(tester);
      await _irParaComprar(tester);

      final resultado = palco.estado.resultado!;
      final contador = ListaTextos.noCarrinho(
        0,
        resultado.todosOsItens.length,
      );

      expect(_noRail(contador), findsOneWidget);
      expect(find.textContaining('faixa real:'), findsNothing);
      expect(
        _topo(tester, _noRail(contador)),
        greaterThan(
          _topo(
            tester,
            _noRail(MoneyFormatter.reais(resultado.totalComEssenciais)),
          ),
        ),
      );
      expect(
        _topo(tester, _noRail(contador)),
        lessThan(
          _topo(
            tester,
            _noRail(
              ListaTextos.porAdulto(MoneyFormatter.reais(resultado.porAdulto)),
            ),
          ),
        ),
      );
      expect(_cta(tester).rotulo, ListaTextos.pedirOQueFalta);
    });

    testWidgets('W-R2: o rodapé fixo mobile não existe em expandido',
        (tester) async {
      await _montar(tester);

      expect(find.byType(RodapeDaLista), findsNothing);
      expect(find.byType(BoraFooterBar), findsNothing);
      expect(find.byKey(RodapeDaLista.ctaKey), findsNothing);
      expect(find.byKey(RailDaLista.ctaKey), findsOneWidget);
    });

    testWidgets('W-R4: a coluna principal rola no documento e a página nunca '
        'rola de lado', (tester) async {
      await _montar(tester);

      final rolaveis = tester.widgetList<SingleChildScrollView>(
        find.descendant(
          of: find.byType(ListaExpandida),
          matching: find.byType(SingleChildScrollView),
        ),
      );

      expect(rolaveis, isNotEmpty);
      for (final rolavel in rolaveis) {
        expect(rolavel.scrollDirection, Axis.vertical);
      }
      expect(
        find.descendant(
          of: find.byType(ListaExpandida),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
        reason: 'W-R4: rolagem só no documento — o rail não rola',
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('o pedido abre como modal central, não como bottom sheet',
        (tester) async {
      await _montar(tester, abrirPedido: true);

      await tester.tap(find.byKey(RailDaLista.ctaKey));
      await tester.pumpAndSettle();

      expect(find.byKey(SheetDePedido.painelExpandidoKey), findsOneWidget);
      expect(find.byType(BoraBottomSheet), findsNothing);
      expect(find.text(ListaTextos.tituloDoPedido), findsOneWidget);
    });
  });

  group('W-R1 — os mesmos números do compacto renderizam aqui', () {
    testWidgets('R\$ 271, ≈ R\$ 45 por adulto e a faixa de R\$ 245 a R\$ 343',
        (tester) async {
      final palco = await _montar(tester);
      final resultado = palco.estado.resultado!;
      final faixa = faixaRealDaLista(
        resultado.todosOsItens,
        tabelaDePrecosDeMercado,
      );

      expect(_noRail(ListaTextos.mediaTotal), findsOneWidget);
      expect(
        _noRail(MoneyFormatter.reais(resultado.totalComEssenciais)),
        findsOneWidget,
      );
      expect(MoneyFormatter.reais(resultado.totalComEssenciais), r'R$ 271');
      expect(
        _noRail(
          ListaTextos.porAdulto(MoneyFormatter.reais(resultado.porAdulto)),
        ),
        findsOneWidget,
      );
      expect(MoneyFormatter.reais(resultado.porAdulto), r'R$ 45');
      expect(
        _noRail(
          ListaTextos.faixaReal(
            MoneyFormatter.reais(faixa.minimo),
            MoneyFormatter.reais(faixa.maximo),
          ),
        ),
        findsOneWidget,
      );
      expect(
        ListaTextos.faixaReal(
          MoneyFormatter.reais(faixa.minimo),
          MoneyFormatter.reais(faixa.maximo),
        ),
        r'faixa real: de R$ 245 a R$ 343',
      );
    });

    testWidgets('o CTA de PLANEJAR é o literal de T-04 e está ativo',
        (tester) async {
      await _montar(tester);

      expect(_cta(tester).rotulo, ListaTextos.fazerPedidoComCarrinho);
      expect(_cta(tester).onPressed, isNotNull);
    });
  });

  group('LIST-31 — festa sem ninguém em expandido', () {
    testWidgets('card vazio, R\$ 0, faixa ausente e CTA inerte',
        (tester) async {
      final palco = await _montar(
        tester,
        composicao: composicaoRn30(contagem: ContagemDePessoas()),
      );

      expect(find.byType(LinhaDeItem), findsNothing);
      expect(_noRail(r'R$ 0'), findsOneWidget);
      expect(_noRail(ListaTextos.porAdulto(r'R$ 0')), findsOneWidget);
      expect(find.textContaining('faixa real:'), findsNothing);
      expect(_cta(tester).onPressed, isNull);

      await tester.tap(find.byKey(RailDaLista.ctaKey));
      await tester.pumpAndSettle();

      expect(palco.pedidos, isEmpty);
      expect(find.byKey(SheetDePedido.painelExpandidoKey), findsNothing);
    });
  });

  group('LIST-14 — o RESTAURAR do rail segue a regra do rodapé', () {
    testWidgets('sem override o botão não existe na árvore', (tester) async {
      await _montar(tester);

      expect(find.byKey(RailDaLista.restaurarKey), findsNothing);
      expect(find.text(ListaTextos.restaurar), findsNothing);
    });

    testWidgets('com override ele aparece e some no mesmo frame em que o '
        'último é desfeito', (tester) async {
      final palco = await _montar(
        tester,
        composicao: composicaoRn30(
          overrides: const {ChaveItem.bovina: OverrideDeItem(quantidade: 3)},
        ),
      );

      expect(find.byKey(RailDaLista.restaurarKey), findsOneWidget);

      await tester.tap(find.byKey(RailDaLista.restaurarKey));
      await tester.pump();

      expect(find.byKey(RailDaLista.restaurarKey), findsNothing);
      expect(palco.estado.resultado!.temOverrides, isFalse);
      expect(find.byKey(BoraToastContent.toastKey), findsNothing);
    });
  });

  group('LIST-01 — o segmented do rail alterna o corpo', () {
    testWidgets('tocar COMPRAR troca o corpo sem sair de W-04',
        (tester) async {
      final palco = await _montar(tester);

      await _irParaComprar(tester);

      expect(palco.estado.modo, ModoDaLista.comprar);
      expect(find.byType(CardDePlanejar), findsNothing);
      expect(find.byType(RailDaLista), findsOneWidget);
      expect(find.byType(RodapeDaLista), findsNothing);
    });
  });
}
