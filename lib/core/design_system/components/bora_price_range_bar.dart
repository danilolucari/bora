import 'package:flutter/widgets.dart';

import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_text_styles.dart';

/// A barra de faixa de preço (mín/máx) de §5: "Trilho 8px, fundo `paper-2`,
/// borda 2px `ink`; marcador 8×12px fundo `primary` borda 2px `ink`,
/// posicionado em `(média−mín)/(máx−mín)` da largura; extremos rotulados
/// abaixo em 700 10px `text-3`".
///
/// **Este componente não calcula nada.** A conta `(média−mín)/(máx−mín)` é
/// RN-11 e pertence à camada `core/calculo` (DS-34): a barra recebe a fração
/// pronta e os dois rótulos já formatados, e só pinta. É por isso que a
/// assinatura não aceita `media`, `min` nem `max` — API que aceitasse número
/// convidaria a fórmula a ser reescrita aqui.
///
/// **Assumption:** §5 diz "posicionado em `(média−mín)/(máx−mín)` da largura"
/// sem dizer o que acontece nos extremos. O marcador percorre a largura
/// **disponível a ele** (o trilho menos a própria espessura): em `0` ele
/// encosta na ponta esquerda e em `1` na direita, sempre dentro do trilho.
/// A alternativa — centrar o marcador na fração — o deixaria metade fora da
/// barra nos dois extremos, que são justamente os valores que a faixa existe
/// para mostrar.
class BoraPriceRangeBar extends StatelessWidget {
  const BoraPriceRangeBar({
    required this.fracao,
    required this.rotuloMin,
    required this.rotuloMax,
    super.key,
  });

  /// §5: "Trilho 8px".
  static const double alturaDoTrilho = 8;

  /// §5: "marcador 8×12px".
  static const double larguraDoMarcador = 8;
  static const double alturaDoMarcador = 12;

  /// A posição do marcador, **já calculada** (RN-11, spec `calculo`).
  ///
  /// Fora de `[0,1]` é clampada; `NaN` e infinito viram `0` (é o que
  /// `min == max` produz lá na origem). Nada disso lança: a barra é
  /// informação, não validação.
  final double fracao;

  /// O extremo esquerdo, **já formatado** (DS-34).
  final String rotuloMin;

  /// O extremo direito, **já formatado** (DS-34).
  final String rotuloMax;

  /// A fração efetivamente usada para posicionar o marcador.
  ///
  /// Mesma regra em DS-27, DS-28 e DS-29: fora da faixa clampa, não finito
  /// vira `0`.
  double get fracaoNoTrilho => fracao.isFinite ? fracao.clamp(0, 1) : 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: alturaDoMarcador,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                // O trilho é mais baixo que o marcador: centrá-lo é o que
                // faz o marcador vazar igual para cima e para baixo.
                top: (alturaDoMarcador - alturaDoTrilho) / 2,
                height: alturaDoTrilho,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: BoraColors.paper2,
                    border: BoraBorders.padraoInk,
                    borderRadius: BoraBorders.raio,
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  // −1 encosta à esquerda, +1 à direita: a fração vira a
                  // posição do marcador ao longo do trilho.
                  alignment: Alignment(2 * fracaoNoTrilho - 1, 0),
                  child: SizedBox(
                    width: larguraDoMarcador,
                    height: alturaDoMarcador,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: BoraColors.primary,
                        border: BoraBorders.padraoInk,
                        borderRadius: BoraBorders.raio,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(rotuloMin, style: BoraTextStyles.extremosFaixa),
            Text(rotuloMax, style: BoraTextStyles.extremosFaixa),
          ],
        ),
      ],
    );
  }
}
