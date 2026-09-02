import 'package:flutter/widgets.dart';

import '../tokens/bora_accent.dart';
import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_motion.dart';
import '../tokens/bora_shadows.dart';
import 'bora_surface.dart';

/// O afundamento obrigatório de §4, compartilhado por todo CTA.
///
/// §4: "Hover/press de CTA (**obrigatório**): `transform: translate(2px,2px)`
/// + sombra encolhe de `4px 4px` para `2px 2px` (efeito 'afundar')". As duas
/// coisas acontecem juntas, no press **e** no hover, em `BoraMotion.estado`
/// (A-03: o CTA é botão de estado, e uma segunda velocidade criaria um
/// segundo sistema).
///
/// É um widget, e não um mixin, para que o afundamento seja a **mesma**
/// implementação em todo botão — e o teste de DS-11 valha para todos por
/// construção.
class BoraPressSink extends StatefulWidget {
  const BoraPressSink({
    required this.acento,
    required this.child,
    this.fundo = BoraColors.white,
    this.corDaBorda = BoraColors.ink,
    this.deslocamento = BoraShadows.distanciaCta,
    this.onPressed,
    this.padding,
    super.key,
  });

  /// O acento da sombra dura — §4: "4px 4px 0 `<acento>`".
  ///
  /// `null` **desliga** a sombra. Serve a quem afunda sobre fundo
  /// transparente: `BoxShadow` não é recortado para fora da borda como o
  /// `box-shadow` do CSS, então uma sombra sem blur atrás de um fundo
  /// transparente aparece através dele e tapa o conteúdo.
  final BoraAccent? acento;

  /// A distância da sombra em repouso.
  final double deslocamento;

  /// `null` ⇒ desabilitado: `opacity .7` (A-07) e **nenhum** afundamento.
  final VoidCallback? onPressed;

  final Color fundo;
  final Color corDaBorda;
  final EdgeInsets? padding;
  final Widget child;

  @override
  State<BoraPressSink> createState() => _BoraPressSinkState();
}

class _BoraPressSinkState extends State<BoraPressSink> {
  bool _pressionado = false;
  bool _sobHover = false;

  bool get _habilitado => widget.onPressed != null;

  bool get _afundado => _habilitado && (_pressionado || _sobHover);

  void _pressionar(bool valor) {
    if (!_habilitado || _pressionado == valor) return;
    setState(() => _pressionado = valor);
  }

  void _pairar(bool valor) {
    if (!_habilitado || _sobHover == valor) return;
    setState(() => _sobHover = valor);
  }

  @override
  Widget build(BuildContext context) {
    final afundamento = _afundado ? BoraShadows.distanciaCtaAfundado : 0.0;
    final sombra =
        _afundado ? BoraShadows.distanciaCtaAfundado : widget.deslocamento;

    final Widget conteudo = MouseRegion(
      onEnter: (_) => _pairar(true),
      onExit: (_) => _pairar(false),
      child: GestureDetector(
        onTapDown: (_) => _pressionar(true),
        onTapUp: (_) => _pressionar(false),
        onTapCancel: () => _pressionar(false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: BoraMotion.estado,
          curve: BoraMotion.curva,
          transform: Matrix4.translationValues(afundamento, afundamento, 0),
          decoration: BoraSurface.decoracaoDe(
            fundo: widget.fundo,
            corDaBorda: widget.corDaBorda,
            acento: widget.acento,
            deslocamentoDaSombra: sombra,
          ),
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );

    if (_habilitado) {
      return conteudo;
    }
    return Opacity(
      opacity: BoraBorders.opacidadeDesabilitado,
      child: conteudo,
    );
  }
}
