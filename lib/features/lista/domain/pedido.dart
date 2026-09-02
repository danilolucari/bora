// SPEC_DEVIATION: `Pedido` e `ParceiroDeEntrega` moram em
// `lib/features/lista/domain/`, e não em `core/calculo/dominio/`, apesar de a
// AD-008 mandar as entidades do arquivo 01 §6 para a camada de cálculo.
// Reason: o critério da AD-008 é **entidade compartilhada**, e esta tem um
// consumidor só — o que atravessa a fronteira para `custos` é a `Despesa`,
// que já está em `core`. E `core/calculo/regras/total_do_pedido.dart` já
// decidiu o assunto por escrito: "os parceiros de delivery, os ETAs e os
// valores de frete são da spec `lista`, dona de RN-27. Esta camada só soma."
// Pôr `Pedido` em `core/calculo` acrescentaria à camada uma entidade que
// nenhuma RN calcula (`lista/design.md` §6.6).

import '../../../core/calculo/calculo.dart';
import 'parceiro_de_entrega.dart';

/// O pedido de delivery que a porta de **AD-024** transporta — LIST-22,
/// LIST-28.
///
/// Valor imutável, com `==`/`hashCode` por valor e igualdade **profunda** em
/// [itens] — dois pedidos com os mesmos itens são o mesmo pedido, que é o que
/// torna afirmável "confirmar duas vezes cria uma despesa só" (LIST-33).
///
/// **Não calcula nada.** [total] é campo, e quem o alimenta é
/// `totalDoPedido(subtotal:, frete:)` de `core/calculo`, fora daqui: um
/// `double get total => subtotal + frete` seria aritmética de dinheiro dentro
/// da feature, exatamente o que o `CLAUDE.md` proíbe e o guard de LIST-07
/// procura.
class Pedido {
  const Pedido({
    required this.parceiro,
    required this.endereco,
    required this.itens,
    required this.subtotal,
    required this.frete,
    required this.total,
  });

  /// O parceiro escolhido na sheet — dele saem o ETA e o frete do overlay.
  final ParceiroDeEntrega parceiro;

  /// O endereço da entrega, **inteiro** e como a sheet o mostrou (D-6):
  /// "Laje do Rafa — Vila Madalena", não "Laje do Rafa".
  final String endereco;

  /// O que vai no pedido: a lista inteira em PLANEJAR, só os não marcados em
  /// COMPRAR (UC-16 A2).
  final List<ItemDeLista> itens;

  /// A soma exata dos [itens], vinda de `subtotalDeItens` /
  /// `subtotalDoQueFalta`.
  final double subtotal;

  /// O frete do [parceiro], repetido aqui porque o pedido confirmado tem de
  /// se bastar: é ele que a spec 10 `custos` lê depois.
  final double frete;

  /// `subtotal + frete`, já somado por `totalDoPedido` — sem arredondar, que
  /// arredondar é da formatação (RN-13 · AD-009).
  final double total;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pedido &&
          other.parceiro == parceiro &&
          other.endereco == endereco &&
          listaIgual(other.itens, itens) &&
          other.subtotal == subtotal &&
          other.frete == frete &&
          other.total == total;

  @override
  int get hashCode => Object.hash(
        parceiro,
        endereco,
        Object.hashAll(itens),
        subtotal,
        frete,
        total,
      );
}
