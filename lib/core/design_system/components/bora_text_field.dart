import 'package:flutter/material.dart';

import '../tokens/bora_colors.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';
import 'bora_surface.dart';

/// O input de §5: "Fundo branco, borda 2px `ink`, radius 0, padding 15px
/// 16px, texto 600 15px; focus: `border-color: #FF4D2E`. Placeholder em
/// minúsculas ('seu e-mail', 'senha')".
///
/// A borda é do design system, não do Material: o `TextField` entra sem
/// decoração nenhuma para que a caixa de §3 seja a mesma superfície de todo o
/// resto do sistema — e para que a troca de cor no foco seja legível como
/// `BoxDecoration`, e não como pintura interna do `InputDecorator`.
///
/// O [placeholder] **não** é transformado: §7 manda CAIXA ALTA em título,
/// label, botão e toast — o placeholder de §5 aparece em minúsculas, e
/// forçar caixa aqui estragaria nome próprio (A-06).
class BoraTextField extends StatefulWidget {
  const BoraTextField({
    required this.controller,
    required this.placeholder,
    this.focusNode,
    super.key,
  });

  final TextEditingController controller;

  /// O texto de dica, exibido como veio (A-06).
  final String placeholder;

  /// O nó de foco, quando a tela precisa comandá-lo. Sem ele o campo cria o
  /// seu.
  final FocusNode? focusNode;

  @override
  State<BoraTextField> createState() => _BoraTextFieldState();
}

class _BoraTextFieldState extends State<BoraTextField> {
  FocusNode? _interno;

  FocusNode get _foco => widget.focusNode ?? (_interno ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _foco.addListener(_repintar);
  }

  @override
  void didUpdateWidget(BoraTextField anterior) {
    super.didUpdateWidget(anterior);
    if (widget.focusNode != anterior.focusNode) {
      anterior.focusNode?.removeListener(_repintar);
      _foco.addListener(_repintar);
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_repintar);
    _interno?.dispose();
    super.dispose();
  }

  void _repintar() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return BoraSurface(
      // §5: "focus: border-color: #FF4D2E" — muda a cor, não a espessura nem
      // a forma.
      corDaBorda: _foco.hasFocus ? BoraColors.primary : BoraColors.ink,
      padding: BoraSpacing.input,
      child: TextField(
        controller: widget.controller,
        focusNode: _foco,
        style: BoraTextStyles.input,
        cursorColor: BoraColors.primary,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: widget.placeholder,
          // §5 não dá cor ao placeholder: fica o texto terciário de §1.
          hintStyle: BoraTextStyles.input.copyWith(color: BoraColors.text3),
        ),
      ),
    );
  }
}
