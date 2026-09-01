import '../../domain/parceiro_de_entrega.dart';
import '../../domain/pedido.dart';

/// O estado da sheet de pedido — LIST-22, LIST-23, LIST-24, LIST-32, LIST-33.
///
/// [subtotal], [frete] e [total] **moram no estado, prontos**: o resumo da
/// sheet lê os três do mesmo objeto e não soma nada (LIST-07). Quem soma é
/// `totalDoPedido` de `core/calculo`.
///
/// Igualdade por valor, escrita à mão como em `ListaState` e `MontarState`.
class PedidoState {
  const PedidoState({
    required this.parceiro,
    required this.endereco,
    required this.subtotal,
    required this.frete,
    required this.total,
    required this.soBebidas,
    this.enviando = false,
    this.confirmado,
    this.falhou = false,
  });

  /// O parceiro escolhido. Abre em [ParceiroDeEntrega.ifood] (A-14).
  final ParceiroDeEntrega parceiro;

  /// Para onde o pedido vai — o endereço da festa até que "TROCAR" o mude, e
  /// **nunca** vazio (A-08).
  final String endereco;

  /// A soma dos itens que vão neste pedido, sem frete.
  final double subtotal;

  /// O frete do [parceiro] escolhido.
  final double frete;

  /// `subtotal + frete`, já somado por `totalDoPedido`.
  final double total;

  /// `true` quando **todo** item do pedido é do corredor BEBIDAS.
  ///
  /// É o que decide se o Zé Delivery pode ser escolhido (RN-27, A-09). Não
  /// muda durante a vida da sheet: os itens são fixados na construção.
  final bool soBebidas;

  /// Um envio está em voo. O CTA fica inerte enquanto for `true` (LIST-33).
  final bool enviando;

  /// O pedido que a **porta devolveu** (LIST-28 AC2), ou `null` enquanto não
  /// houve confirmação. É ele — e não um pedido montado pelo widget — que
  /// alimenta o overlay "PEDIDO A CAMINHO!".
  final Pedido? confirmado;

  /// A porta falhou no último envio — LIST-32.
  ///
  /// Sem overlay e sem despesa: [confirmado] continua `null`, e o CTA volta a
  /// ativo para que o anfitrião possa tentar de novo.
  ///
  /// *SPEC_PRECISION_GAP* (`design.md` §10): T-04 não desenha erro de pedido e
  /// RN-29 não dá toast para ele. Este campo existe para a tela poder decidir;
  /// a evidência do requisito é a **ausência** de overlay e de despesa, mais o
  /// registro no `AppLogger`.
  final bool falhou;

  /// Se [parceiro] pode ser escolhido para este pedido — RN-27 · LIST-24.
  ///
  /// Só o Zé Delivery restringe, e só quando o pedido tem item fora de
  /// BEBIDAS. O cartão continua **visível**: a explicação é o qualificador
  /// "(só bebidas)" do próprio cartão, não uma copy de erro nova (A-09).
  bool podeEscolher(ParceiroDeEntrega parceiro) =>
      !parceiro.soBebidas || soBebidas;

  PedidoState copyWith({
    ParceiroDeEntrega? parceiro,
    String? endereco,
    double? subtotal,
    double? frete,
    double? total,
    bool? soBebidas,
    bool? enviando,
    Pedido? confirmado,
    bool? falhou,
  }) =>
      PedidoState(
        parceiro: parceiro ?? this.parceiro,
        endereco: endereco ?? this.endereco,
        subtotal: subtotal ?? this.subtotal,
        frete: frete ?? this.frete,
        total: total ?? this.total,
        soBebidas: soBebidas ?? this.soBebidas,
        enviando: enviando ?? this.enviando,
        confirmado: confirmado ?? this.confirmado,
        falhou: falhou ?? this.falhou,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PedidoState &&
          other.parceiro == parceiro &&
          other.endereco == endereco &&
          other.subtotal == subtotal &&
          other.frete == frete &&
          other.total == total &&
          other.soBebidas == soBebidas &&
          other.enviando == enviando &&
          other.confirmado == confirmado &&
          other.falhou == falhou;

  @override
  int get hashCode => Object.hash(
        parceiro,
        endereco,
        subtotal,
        frete,
        total,
        soBebidas,
        enviando,
        confirmado,
        falhou,
      );
}
