import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:bora/features/lista/presentation/bloc/lista_bloc.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
import 'package:bora/features/lista/presentation/pages/lista_page.dart';
import 'package:bora/features/lista/presentation/widgets/card_de_comprar.dart';
import 'package:bora/features/lista/presentation/widgets/checkbox_da_lista.dart';
import 'package:bora/features/lista/presentation/widgets/linha_de_item.dart';
import 'package:bora/features/lista/presentation/widgets/lista_compacta.dart';
import 'package:bora/features/lista/presentation/widgets/lista_expandida.dart';
import 'package:bora/features/lista/presentation/widgets/overlay_de_pedido.dart';
import 'package:bora/features/lista/presentation/widgets/painel_de_override.dart';
import 'package:bora/features/lista/presentation/widgets/sheet_de_pedido.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/app_de_teste.dart';
import '../../../../support/festa_em_edicao_repository_fake.dart';
import '../../../../support/pedido_falso_de_teste.dart';
import '../../support/festa_rn30.dart';

const Size _janelaCompacta = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const String _festaId = 'rafa18';
const String _endereco = 'Laje do Rafa — Vila Madalena';

FestaEmEdicao _festaRn30({String local = _endereco}) => FestaEmEdicao(
      festa: Festa(
        nome: 'CHURRAS DO RAFA',
        data: 'SÁB · 18 JUL',
        hora: '14H',
        local: local,
        duracaoHoras: 4,
      ),
      composicao: composicaoRn30(),
    );

/// Abre o app de verdade em [location], com sessão e a festa de RN-30.
Future<FestaEmEdicaoRepositoryFake> _abrir(
  WidgetTester tester, {
  String? location,
  Size janela = _janelaCompacta,
  bool comSessao = true,
  PedidoFalsoDeTeste? pedidos,
  String local = _endereco,
}) async {
  final porta =
      FestaEmEdicaoRepositoryFake(festas: {_festaId: _festaRn30(local: local)});
  addTearDown(porta.dispose);

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);

  await abrirApp(
    tester,
    location ?? Routes.lista(_festaId),
    sessao: comSessao ? sessaoDeTeste : null,
    festasEmEdicao: porta,
    pedidos: pedidos,
  );

  return porta;
}

/// O estado que a tela está desenhando agora, venha ela do compacto ou do
/// expandido.
ListaState _estado(WidgetTester tester) {
  final compacta = find.byType(ListaCompacta);
  if (compacta.evaluate().isNotEmpty) {
    return tester.widget<ListaCompacta>(compacta).estado;
  }

  return tester.widget<ListaExpandida>(find.byType(ListaExpandida)).estado;
}

final Finder _maisDoStepper = find.byWidgetPredicate(
  (widget) =>
      widget is BotaoDePasso && widget.simbolo == BoraStepper.simboloMais,
);

Future<void> _irParaComprar(WidgetTester tester) async {
  await tester.tap(find.text(ListaTextos.modoComprar.toUpperCase()));
  await tester.pumpAndSettle();
}

Future<void> _irParaPlanejar(WidgetTester tester) async {
  await tester.tap(find.text(ListaTextos.modoPlanejar.toUpperCase()));
  await tester.pumpAndSettle();
}

/// Abre um item e dá um passo de quantidade — o override de RN-12.
Future<void> _ajustarPrimeiroItem(WidgetTester tester) async {
  await tester.tap(find.byType(LinhaDeItem).first);
  await tester.pumpAndSettle();
  await tester.tap(_maisDoStepper.first);
  await tester.pumpAndSettle();
}

void main() {
  group('LIST-31 — a rota da lista monta a tela por inteiro', () {
    testWidgets('/roles/{festaId}/lista renderiza a Lista e a URL é a dela',
        (tester) async {
      await _abrir(tester);

      expect(find.byKey(ListaPage.pageKey), findsOneWidget);
      expect(find.text(ListaTextos.titulo), findsOneWidget);
      expect(
        rotaAtual(),
        Routes.lista(_festaId),
        reason: 'AD-014: o destino é afirmado pela URL, não pelo widget',
      );
    });

    testWidgets('/roles/{festaId} sem sufixo continua caindo na Lista',
        (tester) async {
      await _abrir(tester, location: '/roles/$_festaId');

      expect(rotaAtual(), Routes.lista(_festaId));
      expect(find.byKey(ListaPage.pageKey), findsOneWidget);
    });

    testWidgets('AD-017: sem sessão, a rota da Lista continua desviando para '
        '/entrar', (tester) async {
      await _abrir(tester, comSessao: false);

      expect(rotaAtual(), Routes.entrar);
      expect(find.byKey(ListaPage.pageKey), findsNothing);
    });
  });

  group('LIST-30 — um BlocProvider só, acima da escolha de layout', () {
    testWidgets('a compacta monta em 390×820 e a expandida em 1180×800',
        (tester) async {
      await _abrir(tester);

      expect(find.byType(ListaCompacta), findsOneWidget);
      expect(find.byType(ListaExpandida), findsNothing);

      await tester.binding.setSurfaceSize(_janelaExpandida);
      await tester.pumpAndSettle();

      expect(find.byType(ListaExpandida), findsOneWidget);
      expect(find.byType(ListaCompacta), findsNothing);
    });

    testWidgets('há exatamente um BlocProvider de ListaBloc na árvore',
        (tester) async {
      await _abrir(tester);

      expect(find.byType(BlocProvider<ListaBloc>), findsOneWidget);
    });

    testWidgets('cruzar 900px preserva modo, checks, overrides e o item '
        'expandido', (tester) async {
      await _abrir(tester);

      await _ajustarPrimeiroItem(tester);
      final expandida = _estado(tester).chaveExpandida;
      expect(expandida, isNotNull);
      expect(_estado(tester).resultado!.temOverrides, isTrue);

      await _irParaComprar(tester);
      await tester.tap(find.byType(CheckboxDaLista).first);
      await tester.pumpAndSettle();
      final marcados = _estado(tester).festa!.composicao.noCarrinho;
      expect(marcados, hasLength(1));

      await tester.binding.setSurfaceSize(_janelaExpandida);
      await tester.pumpAndSettle();

      expect(find.byType(ListaExpandida), findsOneWidget);
      expect(
        _estado(tester).modo,
        ModoDaLista.comprar,
        reason: 'W-R3: o modo ativo atravessa a fronteira de AD-007',
      );
      expect(find.byType(CardDeComprar), findsOneWidget);
      expect(_estado(tester).festa!.composicao.noCarrinho, marcados);
      expect(_estado(tester).resultado!.temOverrides, isTrue);
      expect(find.byKey(RailDaLista.restaurarKey), findsOneWidget);
      expect(_estado(tester).chaveExpandida, expandida);

      await _irParaPlanejar(tester);

      expect(find.byType(PainelDeOverride), findsOneWidget);
      expect(_estado(tester).chaveExpandida, expandida);
    });
  });

  group('LIST-15, LIST-20 — o estado sobrevive à navegação dentro da festa',
      () {
    testWidgets('override e check continuam aplicados depois de sair da tela '
        'e voltar', (tester) async {
      await _abrir(tester);

      await _ajustarPrimeiroItem(tester);
      await _irParaComprar(tester);
      await tester.tap(find.byType(CheckboxDaLista).first);
      await tester.pumpAndSettle();

      final quantos = _estado(tester).resultado!.todosOsItens.length;
      final marcados = _estado(tester).festa!.composicao.noCarrinho;
      final overrides = _estado(tester).festa!.composicao.overrides;
      expect(overrides, isNotEmpty);

      await irPara(tester, Routes.galera(_festaId));
      expect(rotaAtual(), Routes.galera(_festaId));

      await irPara(tester, Routes.roles);
      expect(rotaAtual(), Routes.roles);
      expect(find.byKey(ListaPage.pageKey), findsNothing);

      await irPara(tester, Routes.lista(_festaId));

      expect(rotaAtual(), Routes.lista(_festaId));
      expect(_estado(tester).festa!.composicao.overrides, overrides);
      expect(find.byKey(RodapeDaLista.restaurarKey), findsOneWidget);

      await _irParaComprar(tester);

      expect(_estado(tester).festa!.composicao.noCarrinho, marcados);
      expect(
        find.descendant(
          of: find.byType(BlocoDeTotal),
          matching: find.text(ListaTextos.noCarrinho(1, quantos)),
        ),
        findsOneWidget,
      );
    });
  });

  group('LIST-27, LIST-28 — a porta de pedido chega pelo roteador', () {
    testWidgets('confirmar o pedido usa o duplo injetado e mostra o overlay '
        'com o que ele devolveu', (tester) async {
      final duplo = PedidoFalsoDeTeste();
      final porta = await _abrir(tester, pedidos: duplo);

      await tester.tap(find.byKey(RodapeDaLista.ctaKey));
      await tester.pumpAndSettle();

      expect(find.text(ListaTextos.tituloDoPedido), findsOneWidget);

      await tester.tap(find.byKey(ConteudoDoPedido.confirmarKey));
      await tester.pumpAndSettle();

      expect(
        duplo.enviados,
        hasLength(1),
        reason: 'a substituição da porta não exigiu tocar a página',
      );

      final enviado = duplo.enviados.single;

      expect(find.text(ListaTextos.pedidoACaminho), findsOneWidget);
      expect(
        find.text(ListaTextos.chegaEm(enviado.parceiro.eta, enviado.endereco)),
        findsOneWidget,
      );
      expect(
        find.text(
          ListaTextos.rachadoNoAcerto(MoneyFormatter.reais(enviado.total)),
        ),
        findsOneWidget,
      );
      expect(
        porta.salvas.last.$2.despesas.single.valor,
        enviado.total,
        reason: 'RN-20: a despesa nasce com o total do pedido confirmado',
      );

      await tester.tap(find.byKey(OverlayDePedido.voltarKey));
      await tester.pumpAndSettle();

      expect(find.text(ListaTextos.pedidoACaminho), findsNothing);
      expect(rotaAtual(), Routes.lista(_festaId));
    });

    testWidgets('a porta que falha não abre overlay e não lança despesa',
        (tester) async {
      final duplo = PedidoFalsoDeTeste(erroAoEnviar: StateError('sem rede'));
      final porta = await _abrir(tester, pedidos: duplo);

      await tester.tap(find.byKey(RodapeDaLista.ctaKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ConteudoDoPedido.confirmarKey));
      await tester.pumpAndSettle();

      expect(duplo.enviados, hasLength(1));
      expect(find.text(ListaTextos.pedidoACaminho), findsNothing);
      expect(
        porta.salvas.where((salva) => salva.$2.despesas.isNotEmpty),
        isEmpty,
      );
    });
  });

  group('LIST-25 — o modo COMPRAR chega ao pedido', () {
    testWidgets('a sheet aberta em COMPRAR pede só o que falta, e o subtotal '
        'reflete só ele', (tester) async {
      final duplo = PedidoFalsoDeTeste();
      await _abrir(tester, pedidos: duplo);

      await _irParaComprar(tester);
      await tester.tap(find.byType(CheckboxDaLista).first);
      await tester.pumpAndSettle();

      final estado = _estado(tester);
      final marcada = estado.festa!.composicao.noCarrinho.single;
      final cobraveis = itensCobraveis(estado.resultado!.todosOsItens);
      final soOQueFalta = subtotalDoQueFalta(cobraveis);

      // Sem esta desigualdade o resto do teste não discriminaria nada: se o
      // item marcado valesse 0, "só o que falta" e "a lista inteira" dariam o
      // mesmo número e a sheet passaria nos dois modos.
      expect(soOQueFalta, lessThan(subtotalDeItens(cobraveis)));

      await tester.tap(find.byKey(RodapeDaLista.ctaKey));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(ConteudoDoPedido.resumoKey),
          matching: find.text(MoneyFormatter.reais(soOQueFalta)),
        ),
        findsOneWidget,
        reason: 'UC-16 A2: o Subtotal do resumo é o do que falta, e quem diz '
            'que é o modo COMPRAR é a página',
      );

      await tester.tap(find.byKey(ConteudoDoPedido.confirmarKey));
      await tester.pumpAndSettle();

      final enviado = duplo.enviados.single;
      expect(enviado.subtotal, closeTo(soOQueFalta, 1e-9));
      expect(
        enviado.itens.map((item) => item.chave),
        isNot(contains(marcada)),
        reason: 'o item já no carrinho não vai no pedido',
      );
    });
  });

  group('LIST-21 — o endereço do pedido vem desta festa', () {
    testWidgets('a linha 📍 e o pedido carregam o local da festa aberta',
        (tester) async {
      // Um local que **não** é o literal de RN-30 nem o default de nenhuma
      // fixture: é o que separa "veio da festa" de "está escrito na página".
      // Com o endereço da fixture, uma constante plantada em `lista_page.dart`
      // passaria despercebida.
      const local = 'Quintal do Tonho — Freguesia do Ó';
      final duplo = PedidoFalsoDeTeste();
      await _abrir(tester, pedidos: duplo, local: local);

      await tester.tap(find.byKey(RodapeDaLista.ctaKey));
      await tester.pumpAndSettle();

      expect(
        find.text(local),
        findsOneWidget,
        reason: 'P1-5 AC2: a sheet mostra o endereço da festa',
      );

      await tester.tap(find.byKey(ConteudoDoPedido.confirmarKey));
      await tester.pumpAndSettle();

      expect(duplo.enviados.single.endereco, local);
    });
  });
}
