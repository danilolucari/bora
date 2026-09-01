import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/parceiro_de_entrega.dart';
import '../lista_textos.dart';

/// Um cartão-radio de "ENTREGA POR" — T-04 · RN-27 · LIST-22, LIST-24.
///
/// "3 cartões-radio (parceiro, 'chega em ETA', frete à direita; selecionado =
/// fundo `paper`, borda vermelha, dot vermelho)". As três coisas que mudam com
/// a seleção são exatamente essas — nada de tamanho, peso ou cor de texto
/// mudando junto.
///
/// **Não decide nada.** Quem sabe qual parceiro está escolhido e qual pode ser
/// escolhido é o `PedidoBloc`: [selecionado] e [onSelecionar] chegam prontos, e
/// `onSelecionar: null` é o cartão inerte de A-09.
///
/// O frete sai de [ParceiroDeEntrega.frete] pela mão do `MoneyFormatter`
/// (RN-13); zero vira a palavra [ListaTextos.freteGratis], que é como RN-27 o
/// escreve.
///
// SPEC_DEVIATION: `tasks.md` T20 sugere reusar `BoraSecondaryButton`, e o
// cartão é composto direto sobre `BoraPressSink`.
// Reason: `BoraSecondaryButton` é um botão de **um rótulo**, e ele aplica
// `toUpperCase()` nele (§7, DS-32). "iFood Mercado" e "Zé Delivery" são nome
// próprio de parceiro, dado de RN-27 — em caixa alta virariam outra coisa —, e
// o cartão tem quatro blocos de texto, não um. O afundamento obrigatório de §4
// continua vindo inteiro do `BoraPressSink`, que é o que o botão secundário
// também usa; nenhum número novo nasce aqui.
class CartaoDeParceiro extends StatelessWidget {
  const CartaoDeParceiro({
    required this.parceiro,
    required this.selecionado,
    this.onSelecionar,
    super.key,
  });

  /// O vão horizontal entre os blocos do cartão — o mesmo ritmo de §5.
  static double get vao => BoraListCard.vaoDoEmoji;

  /// O parceiro que este cartão oferece.
  final ParceiroDeEntrega parceiro;

  /// Se é ele que está escolhido agora.
  final bool selecionado;

  /// Emitido no toque. `null` ⇒ **cartão inerte** (A-09): o `BoraPressSink`
  /// apaga a 70%, não afunda e não emite.
  final VoidCallback? onSelecionar;

  /// T-04: o frete "à direita" — o valor de RN-27, ou "grátis" quando é zero.
  String get freteEscrito => parceiro.frete == 0
      ? ListaTextos.freteGratis
      : MoneyFormatter.reais(parceiro.frete);

  @override
  Widget build(BuildContext context) {
    return BoraPressSink(
      acento: BoraAccent.primary,
      onPressed: onSelecionar,
      // T-04: "selecionado = fundo `paper`, borda vermelha".
      fundo: selecionado ? BoraColors.paper : BoraColors.white,
      corDaBorda: selecionado ? BoraColors.primary : BoraColors.ink,
      padding: BoraSpacing.linhaLista,
      child: Row(
        children: [
          DotDeSelecao(selecionado: selecionado),
          SizedBox(width: vao),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        parceiro.nome,
                        style: BoraTextStyles.linhaLista,
                      ),
                    ),
                    if (parceiro.soBebidas) ...[
                      SizedBox(width: vao),
                      Text(
                        ListaTextos.soBebidas,
                        style: BoraTextStyles.sublinhaLista,
                      ),
                    ],
                  ],
                ),
                Text(
                  ListaTextos.chegaEmEta(parceiro.eta),
                  style: BoraTextStyles.sublinhaLista,
                ),
              ],
            ),
          ),
          SizedBox(width: vao),
          Text(freteEscrito, style: BoraTextStyles.linhaLista),
        ],
      ),
    );
  }
}

/// O dot do cartão-radio — T-04: "dot vermelho" quando selecionado.
///
/// **Círculo de propósito**: o arquivo 02 §3 zera o raio de tudo, e abre
/// exceção para "avatares/dots". É a mesma exceção que o ponto de item editado
/// usa, e a única forma do sistema que não é reta.
///
/// Composto de tokens, como o `CheckboxDaLista` (A-13): borda padrão de §3 e o
/// vermelho de §1 — nenhum literal de cor mora aqui.
class DotDeSelecao extends StatelessWidget {
  const DotDeSelecao({required this.selecionado, super.key});

  /// O diâmetro do dot — o mesmo do ponto de "item editado" de T-04.
  static const double diametro = 8;

  /// O lado da moldura do dot, no ritmo do checkbox 26×26 de T-04.
  static const double lado = 18;

  final bool selecionado;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: lado,
      height: lado,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: BoraColors.white,
        border: BoraBorders.solida(
          selecionado ? BoraColors.primary : BoraColors.ink,
        ),
      ),
      child: selecionado
          ? Center(
              child: Container(
                width: diametro,
                height: diametro,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: BoraColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}
