import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/festas/festas.dart';
import '../../../../core/observability/app_logger.dart';
import '../../../../core/responsive/layout_mode.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../domain/pedido.dart';
import '../../domain/pedido_repository.dart';
import '../bloc/lista_bloc.dart';
import '../bloc/pedido_bloc.dart';
import '../widgets/lista_compacta.dart';
import '../widgets/lista_expandida.dart';
import '../widgets/overlay_de_pedido.dart';
import '../widgets/sheet_de_pedido.dart';

/// T-04 e W-04 — a lista turbinada da festa (LIST-15, LIST-20, LIST-30,
/// LIST-31).
///
/// As duas portas e o logger chegam **pelo roteador**, como em [MontarPage] e
/// [HomePage]: a página não resolve `getIt`, porque isso faria todo teste de
/// rota configurar DI só para montar uma tela (precedente E-4 de `montar`).
///
/// **Um `BlocProvider` só, acima da escolha de layout.** É o que faz LIST-30
/// ser verdade **por construção**: cruzar os 900px de AD-007 com a tela
/// montada reorganiza a árvore sem destruir o bloc, então modo ativo, checks,
/// overrides e item expandido atravessam a fronteira inteiros. Se o bloc
/// descesse para dentro de cada layout, redimensionar a janela zeraria a tela
/// e reassinaria a porta do zero.
///
/// **O estado que sobrevive à navegação não é deste bloc** (AD-030): checks e
/// overrides moram na `ComposicaoDaFesta`, atrás da porta. Trocar de aba
/// destrói o bloc; a festa continua lá, e é por isso que o aceite de UC-06 e
/// de UC-15 fecha.
class ListaPage extends StatelessWidget {
  const ListaPage({
    required this.festaId,
    required this.festas,
    required this.pedidos,
    required this.logger,
    super.key,
  });

  /// Identificador desta tela.
  static const String id = 'lista';

  /// Chave do destino — é por ela que o teste sabe que a tela está montada.
  ///
  /// **Não** é por ela que o teste de rota afirma o destino: quem diz para
  /// onde se foi é `rotaAtual()` (AD-014).
  static const Key pageKey = Key('lista');

  /// A festa que a rota carrega.
  final String festaId;

  /// A porta de leitura e escrita da festa (AD-029).
  final FestaEmEdicaoRepository festas;

  /// A porta de pedido da AD-024 — no M1, o `PedidoFalso`.
  final PedidoRepository pedidos;

  final AppLogger logger;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ListaBloc(festas, logger, festaId: festaId),
      child: Scaffold(
        key: pageKey,
        backgroundColor: BoraColors.paper,
        body: SafeArea(
          child: BlocBuilder<ListaBloc, ListaState>(
            builder: (context, estado) => ResponsiveBuilder(
              builder: (context, modo) => modo == LayoutMode.compact
                  ? ListaCompacta(
                      estado: estado,
                      aoAlternarModo: (modo) =>
                          _emitir(context, ModoAlternado(modo)),
                      aoAlternarItem: (chave) =>
                          _emitir(context, ItemExpandido(chave)),
                      aoAjustarQuantidade: (chave, passos) =>
                          _emitir(context, QuantidadeAjustada(chave, passos)),
                      aoAjustarPreco: (chave, passos) =>
                          _emitir(context, PrecoAjustado(chave, passos)),
                      aoAlternarNoCarrinho: (chave) =>
                          _emitir(context, ItemAlternadoNoCarrinho(chave)),
                      aoRestaurar: () =>
                          _emitir(context, const OverridesRestaurados()),
                      aoPedir: () => _pedir(context, estado),
                    )
                  : ListaExpandida(
                      estado: estado,
                      aoAlternarModo: (modo) =>
                          _emitir(context, ModoAlternado(modo)),
                      aoAlternarItem: (chave) =>
                          _emitir(context, ItemExpandido(chave)),
                      aoAjustarQuantidade: (chave, passos) =>
                          _emitir(context, QuantidadeAjustada(chave, passos)),
                      aoAjustarPreco: (chave, passos) =>
                          _emitir(context, PrecoAjustado(chave, passos)),
                      aoAlternarNoCarrinho: (chave) =>
                          _emitir(context, ItemAlternadoNoCarrinho(chave)),
                      aoRestaurar: () =>
                          _emitir(context, const OverridesRestaurados()),
                      aoPedir: () => _pedir(context, estado),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  void _emitir(BuildContext context, ListaEvent evento) =>
      context.read<ListaBloc>().add(evento);

  /// Abre a sheet de pedido e, quando ela confirma, o overlay — LIST-26,
  /// LIST-27.
  ///
  /// O `PedidoBloc` nasce aqui e **morre com a sheet** (`design.md` §2.3): é o
  /// que faz "o endereço trocado vale só para este pedido" (A-08) ser verdade
  /// por construção.
  ///
  /// A ordem importa: a `Despesa` de RN-20 é lançada com o pedido que a
  /// **porta** devolveu, e o overlay mostra esse mesmo pedido (LIST-28 AC2).
  /// Na falha da porta nada disto acontece — a sheet nem chega a confirmar,
  /// então não há overlay nem despesa órfã (LIST-32).
  Future<void> _pedir(BuildContext context, ListaState estado) async {
    final resultado = estado.resultado;
    final festa = estado.festa;
    if (resultado == null || festa == null) return;

    final lista = context.read<ListaBloc>();
    // `rootNavigator: true` porque é lá que `showGeneralDialog` empilha a
    // sheet. Sem isto, o `pop` sairia no navigator da aba e derrubaria a
    // **própria tela** em vez do painel.
    final navegador = Navigator.of(context, rootNavigator: true);
    Pedido? confirmado;

    await SheetDePedido.mostrar(
      context,
      criarBloc: (_) => PedidoBloc(
        pedidos,
        logger,
        itens: resultado.todosOsItens,
        enderecoDaFesta: festa.festa.local,
        apenasOQueFalta: estado.modo == ModoDaLista.comprar,
      ),
      aoConfirmar: (pedido) {
        confirmado = pedido;
        navegador.pop();
      },
    );

    final pedido = confirmado;
    if (pedido == null) return;

    lista.add(PedidoConfirmado(pedido));

    if (!context.mounted) return;
    await OverlayDePedido.mostrar(context, pedido: pedido);
  }
}
