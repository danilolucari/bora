import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import 'checkbox_da_lista.dart';

/// A linha marcável do modo COMPRAR — T-04 · LIST-18.
///
/// "linha = checkbox 26×26 + emoji + nome/qtd + preço; marcada fica a 45%
/// opacidade". O alvo do toque é a **linha inteira**, não o quadradinho: é o
/// requisito literal, e um alvo menor obrigaria a mira no mercado, de mão
/// cheia.
///
/// **Marcar é estado de compra, não de preço**: o valor exibido é o mesmo nos
/// dois estados, e o total da tela não muda (LIST-19 AC6). O conjunto "no
/// carrinho" mora na composição da festa (AD-030); esta linha só o reflete.
///
/// **Nem barra de faixa nem régua de override aqui.** A leitura de mercado e
/// os steppers são do modo PLANEJAR; repetir qualquer um deles no checklist
/// faria a mesma informação viver em dois lugares.
///
// SPEC_DEVIATION: `tasks.md` T17 sugere reusar `BoraPressSink`, e a linha usa
// um `GestureDetector` simples.
// Reason: `BoraPressSink` é o afundamento **obrigatório de CTA** de §4 — ele
// veste a linha com borda e sombra dura no acento. T-04 desenha a linha do
// checklist sem borda e sem sombra, dentro do card; usá-lo daria a cada item
// da lista a moldura de um botão.
class LinhaDeCompra extends StatelessWidget {
  const LinhaDeCompra({
    required this.item,
    required this.marcado,
    required this.onAlternar,
    super.key,
  });

  /// T-04: "marcada fica a 45% opacidade".
  static const double opacidadeMarcada = 0.45;

  /// A opacidade da linha ainda por comprar — cheia.
  static const double opacidadeNormal = 1;

  /// O item **já calculado**, com override aplicado quando existe.
  final ItemDeLista item;

  /// Se o item já está no carrinho.
  final bool marcado;

  /// Emitido no toque da linha inteira — **alterna**, não liga (LIST-33).
  final VoidCallback onAlternar;

  /// O vão horizontal entre os blocos da linha — o mesmo ritmo de §5.
  static double get _vao => BoraListCard.vaoDoEmoji;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: marcado ? opacidadeMarcada : opacidadeNormal,
      child: GestureDetector(
        // O alvo é a linha inteira, não só o quadradinho (LIST-18).
        behavior: HitTestBehavior.opaque,
        onTap: onAlternar,
        child: Padding(
          padding: BoraSpacing.linhaLista,
          child: Row(
            children: [
              CheckboxDaLista(marcado: marcado),
              SizedBox(width: _vao),
              Text(
                item.emoji,
                style: BoraTextStyles.linhaLista.copyWith(
                  fontSize: BoraListCard.tamanhoDoEmoji,
                ),
              ),
              SizedBox(width: _vao),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.nome, style: BoraTextStyles.linhaLista),
                    Text(
                      rotuloDeQuantidade(item.quantidade, item.unidade),
                      style: BoraTextStyles.sublinhaLista,
                    ),
                  ],
                ),
              ),
              SizedBox(width: _vao),
              Text(
                MoneyFormatter.reais(item.valor),
                style: BoraTextStyles.linhaLista,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
