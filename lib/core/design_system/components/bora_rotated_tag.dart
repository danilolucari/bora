import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/bora_accent.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';
import 'bora_surface.dart';

/// A tag rotacionada de §3: "`transform: rotate(-2deg)` (esq.) ou
/// `rotate(3deg)` (dir.), fundo `primary` ou `yellow`, posicionadas vazando o
/// card (`top:-13px`)".
///
/// O vazamento é do componente, não de quem o usa: a tag sobe os 13px sozinha
/// e é desenhada **fora** dos limites do pai. Quem a coloca só precisa não
/// recortar (`Clip.none` num `Stack`).
///
/// §3 dá o ângulo em **graus** e o Flutter gira em **radianos** — o grau cru
/// em `Transform.rotate` seria um erro silencioso (2 rad ≈ 115°), então a
/// conversão mora aqui, uma vez.
class BoraRotatedTag extends StatelessWidget {
  const BoraRotatedTag({
    required this.texto,
    this.acento = BoraAccent.primary,
    this.aEsquerda = true,
    super.key,
  });

  /// §3: "`rotate(-2deg)` (esq.)".
  static const double grausAEsquerda = -2;

  /// §3: "`rotate(3deg)` (dir.)".
  static const double grausADireita = 3;

  /// §3: "posicionadas vazando o card (`top:-13px`)".
  static const double vazamentoDoTopo = -13;

  /// Os graus de §3 em radianos.
  static double radianosDe(double graus) => graus * math.pi / 180;

  /// A copy da tag, renderizada em CAIXA ALTA (§7, DS-32).
  final String texto;

  /// §3: "fundo `primary` ou `yellow`". O componente recebe o acento, nunca
  /// uma `Color` solta (DS-08).
  final BoraAccent acento;

  /// Qual das duas inclinações de §3: `true` ⇒ −2°, `false` ⇒ +3°.
  final bool aEsquerda;

  /// O ângulo desta tag, em radianos.
  double get anguloEmRadianos =>
      radianosDe(aEsquerda ? grausAEsquerda : grausADireita);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, vazamentoDoTopo),
      child: Transform.rotate(
        angle: anguloEmRadianos,
        child: BoraSurface(
          fundo: acento.cor,
          padding: BoraSpacing.tag,
          child: Text(
            texto.toUpperCase(),
            // §3 não dá cor ao texto da tag: fica o texto principal de §1.
            style: BoraTextStyles.microTag.copyWith(color: BoraColors.ink),
          ),
        ),
      ),
    );
  }
}
