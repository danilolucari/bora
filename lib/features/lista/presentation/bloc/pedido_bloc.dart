import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/observability/app_logger.dart';
import '../../domain/parceiro_de_entrega.dart';
import '../../domain/pedido.dart';
import '../../domain/pedido_repository.dart';
import 'pedido_event.dart';
import 'pedido_state.dart';

export 'pedido_event.dart';
export 'pedido_state.dart';

/// O estado da sheet "FAZER PEDIDO" — LIST-21..LIST-25, LIST-28, LIST-32,
/// LIST-33.
///
/// **Nasce com a sheet e morre com ela** (`design.md` §2.3). Não é um segundo
/// dono do estado da tela: os itens e o endereço chegam prontos na construção,
/// e nada do que acontece aqui alcança a `FestaEmEdicao` — é o que faz "o
/// endereço trocado vale só para este pedido" (A-08) ser verdade por
/// construção, e não por código de limpeza.
///
/// **Não soma nada.** O subtotal vem de `subtotalDeItens` /
/// `subtotalDoQueFalta` e o total de `totalDoPedido`, os três de
/// `core/calculo` (LIST-07). O frete é dado do [ParceiroDeEntrega].
class PedidoBloc extends Bloc<PedidoEvent, PedidoState> {
  PedidoBloc(
    this._pedidos,
    this._logger, {
    required List<ItemDeLista> itens,
    required String enderecoDaFesta,
    bool apenasOQueFalta = false,
  })  : _enderecoDaFesta = enderecoDaFesta,
        _itens = itensDoPedido(itens, apenasOQueFalta: apenasOQueFalta),
        super(
          _estadoInicial(
            itens: itens,
            endereco: enderecoDaFesta,
            apenasOQueFalta: apenasOQueFalta,
          ),
        ) {
    on<ParceiroSelecionado>(_aoSelecionarParceiro);
    on<EnderecoTrocado>(_aoTrocarEndereco);
    on<PedidoEnviado>(_aoEnviar);
  }

  final PedidoRepository _pedidos;
  final AppLogger _logger;

  /// O endereço para onde o pedido volta quando o campo fica vazio (A-08).
  final String _enderecoDaFesta;

  /// O que vai no pedido — a lista inteira em PLANEJAR, só os não marcados em
  /// COMPRAR (UC-16 A2). Fixo pela vida da sheet.
  final List<ItemDeLista> _itens;

  /// Os itens que de fato vão no pedido — LIST-23 (A-19), UC-16 A2.
  ///
  /// Passa por `itensCobraveis`, o **único** predicado de "entra em dinheiro"
  /// do projeto: 🍽️ Copos & pratos aparece na lista e não entra no pedido nem
  /// no subtotal. Com [apenasOQueFalta], sobram só os que ainda não estão no
  /// carrinho — é o "PEDIR O QUE FALTA 🛵" do modo COMPRAR.
  ///
  /// A **ordem** da lista é preservada: o pedido chega ao parceiro na mesma
  /// ordem que a tela mostrou.
  static List<ItemDeLista> itensDoPedido(
    List<ItemDeLista> itens, {
    required bool apenasOQueFalta,
  }) =>
      [
        for (final item in itensCobraveis(itens))
          if (!apenasOQueFalta || !item.noCarrinho) item,
      ];

  /// Um parceiro foi escolhido — LIST-22, LIST-23, LIST-24.
  ///
  /// Trocar de parceiro troca o **frete**, e o total é resomado por
  /// `totalDoPedido`: os três números do resumo andam juntos ou não andam.
  ///
  /// Parceiro inerte é **ignorado aqui**, e não só apagado na tela: a guarda
  /// de RN-27 é regra, e uma tela futura que esqueça o `onPressed: null` não
  /// pode conseguir mandar cerveja e picanha pelo Zé.
  void _aoSelecionarParceiro(
    ParceiroSelecionado evento,
    Emitter<PedidoState> emit,
  ) {
    if (!state.podeEscolher(evento.parceiro)) return;

    emit(
      state.copyWith(
        parceiro: evento.parceiro,
        frete: evento.parceiro.frete,
        total: totalDoPedido(
          subtotal: state.subtotal,
          frete: evento.parceiro.frete,
        ).total,
      ),
    );
  }

  /// "TROCAR" trouxe um endereço novo — LIST-21.
  ///
  /// **Vazio volta ao endereço da festa** (A-08): o pedido não sai sem para
  /// onde ir, e o overlay não escreve "Chega em 40–60 min na ." Espaço em
  /// branco conta como vazio — do contrário a defesa cairia no primeiro campo
  /// deixado com um espaço.
  void _aoTrocarEndereco(EnderecoTrocado evento, Emitter<PedidoState> emit) {
    final endereco = evento.endereco.trim();

    emit(
      state.copyWith(
        endereco: endereco.isEmpty ? _enderecoDaFesta : endereco,
      ),
    );
  }

  /// "CONFIRMAR PEDIDO →" — LIST-28, LIST-32, LIST-33.
  ///
  /// **Idempotente por guarda, não por sorte**: com um envio em voo ou um
  /// pedido já confirmado, o evento é descartado. Dois toques rápidos produzem
  /// **um** `enviar` na porta e **um** `Pedido` confirmado — e, portanto, uma
  /// `Despesa` só quando o `ListaBloc` o receber (LIST-27).
  ///
  /// O que vai para [PedidoState.confirmado] é o pedido que a **porta
  /// devolveu** (LIST-28 AC2), nunca o que foi enviado: é o adaptador que tem
  /// a palavra final sobre parceiro, ETA, endereço e total, e é isso que faz a
  /// troca por um adaptador real ser troca de uma linha (AD-024).
  ///
  /// Na falha: **sem** `confirmado`, `falhou: true` e `logError` (AD-005). Sem
  /// overlay e sem despesa, porque o `ListaBloc` nunca fica sabendo do pedido.
  Future<void> _aoEnviar(PedidoEnviado evento, Emitter<PedidoState> emit) async {
    if (state.enviando || state.confirmado != null) return;

    emit(state.copyWith(enviando: true, falhou: false));

    try {
      final confirmado = await _pedidos.enviar(_pedidoDoEstado());

      emit(state.copyWith(enviando: false, confirmado: confirmado));
    } catch (erro, stack) {
      _logger.logError(erro, stack, name: 'lista');

      emit(state.copyWith(enviando: false, falhou: true));
    }
  }

  /// O [Pedido] que a porta recebe, montado do estado corrente.
  Pedido _pedidoDoEstado() => Pedido(
        parceiro: state.parceiro,
        endereco: state.endereco,
        itens: _itens,
        subtotal: state.subtotal,
        frete: state.frete,
        total: state.total,
      );
}

/// O estado com que a sheet abre — LIST-22 (A-14), LIST-23.
///
/// [ParceiroDeEntrega.ifood] pré-selecionado, o frete dele já no resumo e o
/// total já somado: a sheet não abre com um resumo em branco esperando um
/// toque.
PedidoState _estadoInicial({
  required List<ItemDeLista> itens,
  required String endereco,
  required bool apenasOQueFalta,
}) {
  const parceiro = ParceiroDeEntrega.ifood;

  final cobraveis = itensCobraveis(itens);
  final subtotal = apenasOQueFalta
      ? subtotalDoQueFalta(cobraveis)
      : subtotalDeItens(cobraveis);

  return PedidoState(
    parceiro: parceiro,
    endereco: endereco,
    subtotal: subtotal,
    frete: parceiro.frete,
    total: totalDoPedido(subtotal: subtotal, frete: parceiro.frete).total,
    soBebidas: _soBebidas(
      PedidoBloc.itensDoPedido(itens, apenasOQueFalta: apenasOQueFalta),
    ),
  );
}

/// `true` quando **todo** item de [itens] é do corredor BEBIDAS — RN-27.
///
/// O corredor sai do catálogo (`DefinicaoDeItem.corredor`), o mesmo dado que
/// agrupa o modo COMPRAR: o Zé aceitar ou não o pedido e o item aparecer em
/// BEBIDAS no checklist são a **mesma** decisão, lida do mesmo lugar.
bool _soBebidas(List<ItemDeLista> itens) => itens.every(
      (item) => catalogoDeItens[item.chave]!.corredor == Corredor.bebidas,
    );
