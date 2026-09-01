import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/lista/presentation/bloc/lista_bloc.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
import 'package:bora/features/lista/presentation/widgets/card_de_comprar.dart';
import 'package:bora/features/lista/presentation/widgets/card_de_planejar.dart';
import 'package:bora/features/lista/presentation/widgets/checkbox_da_lista.dart';
import 'package:bora/features/lista/presentation/widgets/linha_de_compra.dart';
import 'package:bora/features/lista/presentation/widgets/linha_de_item.dart';
import 'package:bora/features/lista/presentation/widgets/lista_compacta.dart';
import 'package:bora/features/lista/presentation/widgets/painel_de_override.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/festa_em_edicao_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';
import '../../support/festa_rn30.dart';

const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

const String _festaId = 'rafa18';

/// O endereço da fixture de RN-30 — o mesmo string que a sheet mostra.
const String _endereco = 'Laje do Rafa — Vila Madalena';

/// O palco: o bloc real por trás da tela e o que o CTA de pedido pediu.
class _Palco {
  _Palco(this.bloc, this.pedidos);

  final ListaBloc bloc;

  /// Um item por acionamento efetivo do CTA — vazio quando ele está inerte.
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

/// Monta a tela com o **bloc real** por trás.
///
/// É o `ListaBloc` que transforma cada toque, como na tela de verdade: sem
/// ele, "marcar atualiza o contador imediatamente" e "alternar de modo
/// preserva os checks" seriam afirmados contra um estado montado à mão pelo
/// próprio teste.
Future<_Palco> _montar(
  WidgetTester tester, {
  ComposicaoDaFesta? composicao,
  Size viewport = _frameCompacto,
}) async {
  final porta = FestaEmEdicaoRepositoryFake(
    festas: {_festaId: _festaCom(composicao ?? composicaoRn30())},
  );
  addTearDown(porta.dispose);

  final bloc = ListaBloc(porta, RecordingAppLogger(), festaId: _festaId);
  addTearDown(bloc.close);

  final pedidos = <ModoDaLista>[];

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: BlocBuilder<ListaBloc, ListaState>(
          bloc: bloc,
          builder: (context, estado) => ListaCompacta(
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
            aoPedir: () => pedidos.add(bloc.state.modo),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return _Palco(bloc, pedidos);
}

/// Vai para o modo COMPRAR pelo próprio segmented da tela.
Future<void> _irParaComprar(WidgetTester tester) async {
  await tester.tap(find.text(ListaTextos.modoComprar.toUpperCase()));
  await tester.pumpAndSettle();
}

Future<void> _irParaPlanejar(WidgetTester tester) async {
  await tester.tap(find.text(ListaTextos.modoPlanejar.toUpperCase()));
  await tester.pumpAndSettle();
}

/// O texto de uma linha do rodapé, achado **dentro do bloco de total** — o
/// desambiguador de literal colidente (`R$ 54` é preço da Picanha e mínimo da
/// faixa dela).
Finder _noRodape(String texto) => find.descendant(
      of: find.byType(BlocoDeTotal),
      matching: find.text(texto),
    );

/// Os botões "+" da régua de override — o "−" pode estar no piso e inerte.
final Finder _maisDoStepper = find.byWidgetPredicate(
  (widget) =>
      widget is BotaoDePasso && widget.simbolo == BoraStepper.simboloMais,
);

/// O CTA do rodapé, para perguntar se ele está inerte.
BoraPrimaryButton _cta(WidgetTester tester) =>
    tester.widget<BoraPrimaryButton>(find.byKey(RodapeDaLista.ctaKey));

void main() {
  group('LIST-01 — o header e o segmented de T-04', () {
    for (final MapEntry(key: nome, value: viewport) in _viewports.entries) {
      testWidgets('em $nome: "SUA LISTA" e as duas opções literais, com '
          'PLANEJAR ativo por default', (tester) async {
        await _montar(tester, viewport: viewport);

        expect(find.text(ListaTextos.titulo), findsOneWidget);
        expect(
          find.text(ListaTextos.modoPlanejar.toUpperCase()),
          findsOneWidget,
        );
        expect(
          find.text(ListaTextos.modoComprar.toUpperCase()),
          findsOneWidget,
        );
        expect(
          tester
              .widget<BoraSegmentedControl>(find.byType(BoraSegmentedControl))
              .indiceAtivo,
          ModoDaLista.planejar.index,
          reason: 'T-04: PLANEJAR é o modo default da tela',
        );
        expect(find.byType(CardDePlanejar), findsOneWidget);
      });
    }

    testWidgets('tocar 🛒 COMPRAR troca o corpo e o ativo do segmented',
        (tester) async {
      final palco = await _montar(tester);

      await _irParaComprar(tester);

      expect(palco.estado.modo, ModoDaLista.comprar);
      expect(
        tester
            .widget<BoraSegmentedControl>(find.byType(BoraSegmentedControl))
            .indiceAtivo,
        ModoDaLista.comprar.index,
      );
      expect(find.byType(CardDeComprar), findsOneWidget);
      expect(find.byType(CardDePlanejar), findsNothing);
    });
  });

  group('LIST-02 — a dica tracejada de cada modo, literal', () {
    testWidgets('PLANEJAR mostra a dica de T-04, com a âncora 📊',
        (tester) async {
      await _montar(tester);

      final nota = tester.widget<BoraDashedNote>(find.byType(BoraDashedNote));

      expect('${nota.emoji} ${nota.texto}', ListaTextos.dicaPlanejar);
      expect(nota.emoji, '📊');
      expect(find.text(ListaTextos.dicaComprar), findsNothing);
    });

    testWidgets('COMPRAR mostra a dica de T-04, com a âncora ✅',
        (tester) async {
      await _montar(tester);
      await _irParaComprar(tester);

      final nota = tester.widget<BoraDashedNote>(find.byType(BoraDashedNote));

      expect('${nota.emoji} ${nota.texto}', ListaTextos.dicaComprar);
      expect(nota.emoji, '✅');
    });
  });

  group('LIST-05, LIST-06 — o aceite de UC-05 no rodapé', () {
    for (final MapEntry(key: nome, value: viewport) in _viewports.entries) {
      testWidgets('em $nome: MÉDIA TOTAL, R\$ 271, ≈ R\$ 45 por adulto e o '
          'CTA "FAZER PEDIDO 🛒"', (tester) async {
        final palco = await _montar(tester, viewport: viewport);
        final resultado = palco.estado.resultado!;

        expect(_noRodape(ListaTextos.mediaTotal), findsOneWidget);
        expect(
          _noRodape(MoneyFormatter.reais(resultado.totalComEssenciais)),
          findsOneWidget,
          reason: 'um formatador escrito à mão mostraria outro número aqui',
        );
        expect(MoneyFormatter.reais(resultado.totalComEssenciais), r'R$ 271');
        expect(
          _noRodape(
            ListaTextos.porAdulto(MoneyFormatter.reais(resultado.porAdulto)),
          ),
          findsOneWidget,
        );
        expect(MoneyFormatter.reais(resultado.porAdulto), r'R$ 45');
        expect(_cta(tester).rotulo, ListaTextos.fazerPedidoComCarrinho);
        expect(_cta(tester).onPressed, isNotNull);
      });
    }
  });

  group('LIST-09 — a faixa real no rodapé de PLANEJAR', () {
    testWidgets('a linha soma a faixa da lista e lê de R\$ 245 a R\$ 343',
        (tester) async {
      final palco = await _montar(tester);
      final faixa = faixaRealDaLista(
        palco.estado.resultado!.todosOsItens,
        tabelaDePrecosDeMercado,
      );

      expect(
        _noRodape(
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

    testWidgets('em COMPRAR a faixa real dá lugar ao contador do carrinho',
        (tester) async {
      final palco = await _montar(tester);
      await _irParaComprar(tester);

      final total = palco.estado.resultado!.todosOsItens.length;

      expect(_noRodape(ListaTextos.noCarrinho(0, total)), findsOneWidget);
      expect(find.textContaining('faixa real:'), findsNothing);
    });
  });

  group('LIST-19 — o rodapé de COMPRAR', () {
    testWidgets('contador, total e o CTA "PEDIR O QUE FALTA 🛵"',
        (tester) async {
      final palco = await _montar(tester);
      await _irParaComprar(tester);

      final resultado = palco.estado.resultado!;

      expect(
        _noRodape(
          ListaTextos.noCarrinho(0, resultado.todosOsItens.length),
        ),
        findsOneWidget,
      );
      expect(
        _noRodape(MoneyFormatter.reais(resultado.totalComEssenciais)),
        findsOneWidget,
      );
      expect(_cta(tester).rotulo, ListaTextos.pedirOQueFalta);
    });

    testWidgets('marcar um item atualiza o contador na hora e o total não '
        'muda', (tester) async {
      final palco = await _montar(tester);
      await _irParaComprar(tester);

      final antes = palco.estado.resultado!;
      final totalAntes = MoneyFormatter.reais(antes.totalComEssenciais);
      final quantos = antes.todosOsItens.length;

      await tester.tap(find.byType(CheckboxDaLista).first);
      await tester.pumpAndSettle();

      expect(_noRodape(ListaTextos.noCarrinho(1, quantos)), findsOneWidget);
      expect(_noRodape(ListaTextos.noCarrinho(0, quantos)), findsNothing);
      expect(
        _noRodape(totalAntes),
        findsOneWidget,
        reason: 'marcar é estado de compra, não de preço (LIST-19 AC6)',
      );
      expect(
        MoneyFormatter.reais(palco.estado.resultado!.totalComEssenciais),
        totalAntes,
      );
    });
  });

  group('LIST-14 — o RESTAURAR só existe quando há override', () {
    testWidgets('sem override, o botão não está na árvore', (tester) async {
      await _montar(tester);

      expect(find.byKey(RodapeDaLista.restaurarKey), findsNothing);
      expect(find.text(ListaTextos.restaurar), findsNothing);
    });

    testWidgets('um ajuste faz o botão aparecer; RESTAURAR o faz sumir no '
        'mesmo frame, sem diálogo e sem toast', (tester) async {
      final palco = await _montar(
        tester,
        composicao: composicaoRn30(
          overrides: const {ChaveItem.bovina: OverrideDeItem(quantidade: 3)},
        ),
      );

      expect(find.byKey(RodapeDaLista.restaurarKey), findsOneWidget);
      expect(palco.estado.resultado!.temOverrides, isTrue);

      await tester.tap(find.byKey(RodapeDaLista.restaurarKey));
      await tester.pump();

      expect(find.byKey(RodapeDaLista.restaurarKey), findsNothing);
      expect(palco.estado.resultado!.temOverrides, isFalse);
      expect(
        find.byType(Dialog),
        findsNothing,
        reason: 'UC-06 A1: um toque zera tudo, sem confirmação',
      );
      expect(find.byKey(BoraToastContent.toastKey), findsNothing);
    });
  });

  group('LIST-15, LIST-20 — alternar de modo preserva o que a festa guarda',
      () {
    testWidgets('checks, overrides e item expandido sobrevivem ao ida e volta',
        (tester) async {
      final palco = await _montar(tester);

      await tester.tap(find.byType(LinhaDeItem).first);
      await tester.pumpAndSettle();
      final expandida = palco.estado.chaveExpandida;
      expect(expandida, isNotNull);
      expect(find.byType(PainelDeOverride), findsOneWidget);

      await tester.tap(_maisDoStepper.first);
      await tester.pumpAndSettle();
      expect(palco.estado.resultado!.temOverrides, isTrue);

      await _irParaComprar(tester);
      await tester.tap(find.byType(CheckboxDaLista).first);
      await tester.pumpAndSettle();
      final marcada = palco.estado.festa!.composicao.noCarrinho;
      expect(marcada, hasLength(1));

      await _irParaPlanejar(tester);

      expect(palco.estado.chaveExpandida, expandida);
      expect(find.byType(PainelDeOverride), findsOneWidget);
      expect(palco.estado.resultado!.temOverrides, isTrue);
      expect(find.byKey(RodapeDaLista.restaurarKey), findsOneWidget);

      await _irParaComprar(tester);

      expect(palco.estado.festa!.composicao.noCarrinho, marcada);
      expect(
        tester
            .widgetList<LinhaDeCompra>(find.byType(LinhaDeCompra))
            .where((linha) => linha.marcado),
        hasLength(1),
      );
    });
  });

  group('LIST-31 — festa sem ninguém', () {
    for (final MapEntry(key: nome, value: viewport) in _viewports.entries) {
      testWidgets('em $nome: card vazio, R\$ 0, ≈ R\$ 0 por adulto, sem faixa '
          'e com o CTA inerte', (tester) async {
        final palco = await _montar(
          tester,
          composicao: composicaoRn30(contagem: ContagemDePessoas()),
          viewport: viewport,
        );

        expect(find.byType(LinhaDeItem), findsNothing);
        expect(_noRodape(r'R$ 0'), findsOneWidget);
        expect(_noRodape(ListaTextos.porAdulto(r'R$ 0')), findsOneWidget);
        expect(find.textContaining('faixa real:'), findsNothing);
        expect(
          _cta(tester).onPressed,
          isNull,
          reason: 'LIST-31 AC3: sem lista, a sheet não abre',
        );

        await tester.tap(find.byKey(RodapeDaLista.ctaKey));
        await tester.pumpAndSettle();

        expect(palco.pedidos, isEmpty);
      });
    }

    testWidgets('em COMPRAR a lista vazia lê "0 de 0 no carrinho" e não tem '
        'grupo de corredor', (tester) async {
      await _montar(tester, composicao: composicaoRn30(
        contagem: ContagemDePessoas(),
      ));
      await _irParaComprar(tester);

      expect(_noRodape(ListaTextos.noCarrinho(0, 0)), findsOneWidget);
      expect(find.byType(GrupoDoCorredor), findsNothing);
      expect(find.byType(LinhaDeCompra), findsNothing);
    });
  });

  group('LIST-25 — "PEDIR O QUE FALTA 🛵" quando não falta nada', () {
    testWidgets('com tudo marcado o CTA fica inerte, a sheet não abre e '
        'nenhum toast aparece', (tester) async {
      final palco = await _montar(
        tester,
        composicao: composicaoRn30(
          noCarrinho: ChaveItem.values.toSet(),
        ),
      );
      await _irParaComprar(tester);

      final quantos = palco.estado.resultado!.todosOsItens.length;

      expect(_noRodape(ListaTextos.noCarrinho(quantos, quantos)),
          findsOneWidget);
      expect(_cta(tester).onPressed, isNull);

      await tester.tap(find.byKey(RodapeDaLista.ctaKey));
      await tester.pumpAndSettle();

      expect(palco.pedidos, isEmpty);
      expect(find.byKey(BoraToastContent.toastKey), findsNothing);
    });

    testWidgets('faltando um item, o CTA volta a acionar o pedido do modo',
        (tester) async {
      final palco = await _montar(
        tester,
        composicao: composicaoRn30(
          noCarrinho: ChaveItem.values.toSet()..remove(ChaveItem.bovina),
        ),
      );
      await _irParaComprar(tester);

      expect(_cta(tester).onPressed, isNotNull);

      await tester.tap(find.byKey(RodapeDaLista.ctaKey));
      await tester.pumpAndSettle();

      expect(palco.pedidos, [ModoDaLista.comprar]);
    });
  });

  group('A-23 — a tela não tem toast nenhum', () {
    testWidgets('nenhuma ação da tela põe um BoraToast na árvore',
        (tester) async {
      await _montar(
        tester,
        composicao: composicaoRn30(
          overrides: const {ChaveItem.bovina: OverrideDeItem(quantidade: 3)},
        ),
      );

      await tester.tap(find.byType(LinhaDeItem).first);
      await tester.pumpAndSettle();
      await tester.tap(_maisDoStepper.first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(RodapeDaLista.restaurarKey));
      await tester.pumpAndSettle();
      await _irParaComprar(tester);
      await tester.tap(find.byType(CheckboxDaLista).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(RodapeDaLista.ctaKey));
      await tester.pumpAndSettle();

      expect(find.byKey(BoraToastContent.toastKey), findsNothing);
      expect(find.byType(BoraToastContent), findsNothing);
    });
  });
}
