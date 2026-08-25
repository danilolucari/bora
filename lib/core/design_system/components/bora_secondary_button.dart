import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

import '../tokens/bora_accent.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';
import 'bora_press_sink.dart';

/// O botão secundário de §5: "Fundo transparente ou branco, borda 2px `ink`,
/// texto `ink`. Hover: fundo `paper` ou sombra dura".
///
/// As duas metades do hover valem aqui: a sombra dura vem do [BoraPressSink]
/// (que a encolhe no afundamento de §4) e o fundo `paper` é o que **muda** ao
/// ponteiro entrar — sem ele o hover não ganharia nada que já não estivesse na
/// tela. A troca anda na duração de estado de §6, porque é a decoração do
/// próprio press que anima.
class BoraSecondaryButton extends StatefulWidget {
  const BoraSecondaryButton({
    required this.rotulo,
    this.onPressed,
    this.fundoBranco = false,
    super.key,
  });

  /// A copy do botão, renderizada em CAIXA ALTA (§7, DS-32).
  final String rotulo;

  /// `null` ⇒ desabilitado: `opacity .7` (A-07), sem hover e sem toque.
  final VoidCallback? onPressed;

  /// §5 dá as duas: "fundo transparente **ou** branco". O padrão é
  /// transparente — o botão secundário some no papel da tela.
  final bool fundoBranco;

  @override
  State<BoraSecondaryButton> createState() => _BoraSecondaryButtonState();
}

class _BoraSecondaryButtonState extends State<BoraSecondaryButton> {
  bool _sobHover = false;

  bool get _habilitado => widget.onPressed != null;

  void _pairar(bool valor) {
    if (!_habilitado || _sobHover == valor) return;
    setState(() => _sobHover = valor);
  }

  /// §5: em repouso, transparente ou branco; no hover, `paper`.
  Color get _fundo {
    if (_sobHover) return BoraColors.paper;
    return widget.fundoBranco ? BoraColors.white : Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _pairar(true),
      onExit: (_) => _pairar(false),
      child: BoraPressSink(
        acento: BoraAccent.ink,
        onPressed: widget.onPressed,
        fundo: _fundo,
        padding: BoraSpacing.botao,
        child: Text(
          widget.rotulo.toUpperCase(),
          textAlign: TextAlign.center,
          style: BoraTextStyles.botao.copyWith(color: BoraColors.ink),
        ),
      ),
    );
  }
}
