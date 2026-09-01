import '../domain/pedido.dart';
import '../domain/pedido_repository.dart';

/// O único adaptador de pedido do MVP — **e ele é falso** (AD-024) · LIST-28.
///
/// Devolve o pedido recebido, confirmado, **sem chamada de rede**: nenhum
/// import de `http`, de Firebase ou de `dart:io` mora neste arquivo, e um
/// teste de varredura o afirma.
///
/// ⚠️ **Ressalva de exposição pública, repetida aqui de propósito** (AD-024 ·
/// `design.md` §11): com este adaptador no lugar, a tela afirma "PEDIDO A
/// CAMINHO! 🛵" sem pedido a caminho, e lança no acerto da festa uma
/// `Despesa` de uma compra que não houve. A copy de T-04 fica literal, sem
/// selo de "simulado" — foi decisão consciente do usuário em 2026-08-27.
/// **Enquanto o adaptador for falso, o produto não vai a público com esta
/// tela ativa sem revisão da AD-024.** Quem trocar isto por um adaptador real
/// deve apagar esta ressalva junto.
///
/// O pedido devolvido é o que **alimenta o overlay** (LIST-28 AC2) — parceiro,
/// ETA, endereço, subtotal, frete e total saem daqui, não do widget.
class PedidoFalso implements PedidoRepository {
  const PedidoFalso();

  @override
  Future<Pedido> enviar(Pedido pedido) async => pedido;
}
