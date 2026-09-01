import 'pedido.dart';

/// A porta de pedido da **AD-024** — LIST-28.
///
/// **A única implementação do MVP é falsa**: `PedidoFalso` não faz rede,
/// porque nenhum dos três parceiros de RN-27 expõe API pública de pedido.
/// Quando houver contrato, troca-se o adaptador — **nem a tela nem os testes
/// de aceite mudam**. É essa troca de uma linha que a porta existe para
/// garantir.
///
/// Dart puro: sem Flutter, sem Firebase, sem `http`. Quem constrói o
/// [Pedido] é o `PedidoBloc`, com o subtotal e o total já somados por
/// `core/calculo`.
abstract class PedidoRepository {
  /// Envia [pedido] ao parceiro e devolve o **pedido confirmado**.
  ///
  /// O que volta daqui é o que alimenta o overlay "PEDIDO A CAMINHO!"
  /// (LIST-28 AC2): o widget nunca monta o pedido de exibição por conta
  /// própria, e é isso que o teste de aceite afirma.
  ///
  /// **Falha lança.** Sem overlay, sem `Despesa`, sem pedido pela metade
  /// (LIST-32): quem chama trata a exceção, registra no `AppLogger` (AD-005)
  /// e deixa a sheet aberta com o CTA de volta ao ativo.
  Future<Pedido> enviar(Pedido pedido);
}
