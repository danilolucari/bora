import 'package:flutter/widgets.dart';

import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_motion.dart';

/// A barra de progresso da quitação, de §5: "Altura 12px, borda 2px `cream`
/// (sobre card escuro), preenchimento `#25D366`, `transition: width .3s`".
///
/// **A fração chega pronta** (DS-34): quanto da conta já foi quitado é RN-18 e
/// mora em `core/calculo`. Fora de `[0,1]` clampa; `NaN` e infinito viram `0`
/// — a mesma regra de DS-27, e nenhum caminho lança.
///
/// §5 descreve a barra **sobre card escuro**, e é esse o padrão. Fora dele a
/// borda volta a ser a de §3 (2px `ink`): `cream` sobre `paper` seria uma
/// borda invisível, não uma variante.
class BoraProgressBar extends StatelessWidget {
  const BoraProgressBar({
    required this.fracao,
    this.sobreCardEscuro = true,
    super.key,
  });

  /// §5: "Altura 12px" — a borda de 2px é desenhada por dentro, então este é
  /// o tamanho da barra inteira.
  static const double altura = 12;

  /// Quanto da conta já foi quitado, **já calculado** (RN-18).
  final double fracao;

  /// §5: a variante que a spec descreve é a de cima do card escuro.
  final bool sobreCardEscuro;

  /// A fração efetivamente pintada: clampada, e `0` quando não é finita.
  double get fracaoPintada => fracao.isFinite ? fracao.clamp(0, 1) : 0;

  Color get _corDaBorda =>
      sobreCardEscuro ? BoraColors.cream : BoraColors.ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: altura,
      decoration: BoxDecoration(
        border: BoraBorders.solida(_corDaBorda),
        borderRadius: BoraBorders.raio,
      ),
      // §6: "Progresso: `width .3s`". A largura anima do valor anterior para
      // o novo sempre que a fração muda — é a única coisa que se move aqui.
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: fracaoPintada),
        duration: BoraMotion.progresso,
        curve: BoraMotion.curva,
        builder: (context, avanco, child) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: avanco,
          child: child,
        ),
        child: const ColoredBox(color: BoraColors.waGreen),
      ),
    );
  }
}
