import 'package:bora/features/lista/domain/pedido.dart';
import 'package:bora/features/lista/domain/pedido_repository.dart';

/// Duplo **escrito à mão** da porta de pedido (**AD-021**: `mocktail` só para
/// SDK concreto de terceiro; porta de domínio tem fake próprio).
///
/// Guarda o que foi enviado e em que ordem — é o que torna afirmável que dois
/// toques em "CONFIRMAR PEDIDO →" produzem **um** envio (LIST-33).
///
/// [erroAoEnviar] é o caminho de falha de LIST-32: com ele, [enviar] lança em
/// vez de confirmar, e quem chama tem de não mostrar overlay e não criar
/// despesa.
class PedidoFalsoDeTeste implements PedidoRepository {
  PedidoFalsoDeTeste({this.erroAoEnviar});

  /// Os pedidos passados a [enviar], na ordem.
  final List<Pedido> enviados = [];

  /// Quando não-nulo, é lançado por [enviar] — a porta que falha.
  Object? erroAoEnviar;

  @override
  Future<Pedido> enviar(Pedido pedido) async {
    enviados.add(pedido);

    final erro = erroAoEnviar;
    if (erro != null) throw erro;

    return pedido;
  }
}
