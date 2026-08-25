/// Uma despesa que alguém adiantou pela festa (RN-20 · CALC-05, CALC-18).
///
/// É o "eu paguei o gelo" da tela Custos: [quemPagou] é o **nome** da pessoa,
/// porque `Pessoa` não tem identificador nesta camada (A-24), e [valor] é o
/// que ela tirou do bolso — entra na contribuição dela no acerto, exatamente
/// como o valor dos itens que ela levou.
///
/// Valor imutável, com `==`/`hashCode` escritos à mão (A-19).
class Despesa {
  const Despesa({
    required this.quemPagou,
    required this.descricao,
    required this.valor,
  });

  /// O nome de quem adiantou o dinheiro (A-24).
  final String quemPagou;

  /// A descrição livre da despesa ("Carvão + gelo", "Pedido no Zé").
  final String descricao;

  /// Quanto foi pago, em reais e **sem arredondar** — dinheiro só arredonda na
  /// formatação (RN-13).
  final double valor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Despesa &&
          other.quemPagou == quemPagou &&
          other.descricao == descricao &&
          other.valor == valor;

  @override
  int get hashCode => Object.hash(quemPagou, descricao, valor);
}
