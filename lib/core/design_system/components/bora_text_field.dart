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
    this.obscureText = false,
    super.key,
  });

  final TextEditingController controller;

  /// O texto de dica, exibido como veio (A-06).
  final String placeholder;

  /// O nó de foco, quando a tela precisa comandá-lo. Sem ele o campo cria o
  /// seu.
  final FocusNode? focusNode;

  /// Esconde o que foi digitado — o campo "senha" de T-01 e W-01 (ENT-21).
  ///
  /// SPEC_DEVIATION: acrescentado pela spec 03 `entrar` a um componente da
  /// spec 01, que está fechada (emenda E-2). Reason: o arquivo 02 desenha o
  /// input "senha" e não diz que ele esconde o texto — nem havia AC exigindo
  /// isso, o que virou ENT-21 —, mas uma senha legível na tela é defeito, não
  /// escolha de estilo. A mudança é **aditiva**: o default `false` mantém o
  /// comportamento de todos os usos existentes.
  final bool obscureText;

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
        obscureText: widget.obscureText,
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
