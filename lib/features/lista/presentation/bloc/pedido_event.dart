import '../../domain/parceiro_de_entrega.dart';

/// Os eventos da sheet de pedido — LIST-21, LIST-22, LIST-25.
///
/// **O bloc não navega** (AD-020, como em `ListaBloc`): quem fecha a sheet e
/// quem mostra o overlay é quem a abriu.
sealed class PedidoEvent {
  const PedidoEvent();
}

/// Um cartão-radio de "ENTREGA POR" foi tocado — LIST-22, LIST-24.
///
/// Selecionar um parceiro **só-bebidas** com item fora do corredor BEBIDAS é
/// ignorado: o cartão está inerte na tela (A-09), e a guarda mora aqui para
/// que a regra não dependa de quem desenha.
class ParceiroSelecionado extends PedidoEvent {
  const ParceiroSelecionado(this.parceiro);

  final ParceiroDeEntrega parceiro;
}

/// O "TROCAR" ao lado do endereço — LIST-21.
///
/// Vale **só para este pedido**: o bloc nasce com a sheet e morre com ela, e
/// nada daqui chega à `FestaEmEdicao` (A-08).
///
/// [endereco] vazio volta ao endereço da festa — o pedido nunca sai sem para
/// onde ir.
class EnderecoTrocado extends PedidoEvent {
  const EnderecoTrocado(this.endereco);

  final String endereco;
}

/// "CONFIRMAR PEDIDO →" — LIST-28, LIST-32, LIST-33.
///
/// **Idempotente**: um envio em voo ou um pedido já confirmado descartam o
/// evento, e por isso dois toques rápidos produzem **um** pedido e **uma**
/// despesa.
class PedidoEnviado extends PedidoEvent {
  const PedidoEnviado();
}
