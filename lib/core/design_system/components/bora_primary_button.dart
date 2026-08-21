import 'package:flutter/widgets.dart';

import '../tokens/bora_accent.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';
import 'bora_press_sink.dart';

/// O botão primário de §5: "Fundo `ink`, texto `cream`, borda 2px `ink`,
/// padding 15–16px, sombra `4px 4px 0` no acento do contexto. Largura total
/// quando é o CTA do rodapé".
///
/// A borda, a sombra e o afundamento obrigatório de §4 vêm inteiros do
/// [BoraPressSink] — este botão só decide **as cores do papel primário**, o
/// rótulo e a largura. O `toUpperCase()` do rótulo é a lei de §7 (DS-32), e é
/// aqui que ela mora: o mecanismo de press não conhece copy.
class BoraPrimaryButton extends StatelessWidget {
  const BoraPrimaryButton({
    required this.rotulo,
    this.onPressed,
    this.acento = BoraAccent.primary,
    this.larguraTotal = false,
    super.key,
  });

  /// A copy do botão. Chega como o produto a escreve e **sai em CAIXA ALTA**
  /// (§7: "botões em CAIXA ALTA").
  final String rotulo;

  /// `null` ⇒ desabilitado: `opacity .7` (A-07) e nenhum toque emitido.
  final VoidCallback? onPressed;

  /// O acento da sombra dura — §4: "4px 4px 0 `<acento>`". O padrão é o
  /// vermelho de CTA/dinheiro.
  final BoraAccent acento;

  /// §5: "Largura total quando é o CTA do rodapé".
  final bool larguraTotal;

  @override
  Widget build(BuildContext context) {
    final botao = BoraPressSink(
      acento: acento,
      onPressed: onPressed,
      fundo: BoraColors.ink,
      padding: BoraSpacing.botao,
      child: Text(
        rotulo.toUpperCase(),
        textAlign: TextAlign.center,
        style: BoraTextStyles.botao.copyWith(color: BoraColors.cream),
      ),
    );

    if (!larguraTotal) {
      return botao;
    }
    return SizedBox(width: double.infinity, child: botao);
  }
}
