import 'package:flutter/animation.dart';

/// O motion do arquivo 02 §6 — seco e imediato.
///
/// "Sem parallax, sem spring, sem skeleton animado": nenhuma curva de mola ou
/// bounce entra no sistema.
abstract final class BoraMotion {
  /// §6: "`transition: all .15s` em chips, segmented, botões de estado".
  ///
  /// É também a duração do afundamento do CTA (A-03): o CTA é botão de estado,
  /// e inventar outro número criaria uma segunda velocidade no sistema.
  static const Duration estado = Duration(milliseconds: 150);

  /// §6, `toastIn`: a entrada do toast, `.3s ease`.
  static const Duration toastIn = Duration(milliseconds: 300);

  /// §6: "Progresso: `width .3s`".
  static const Duration progresso = Duration(milliseconds: 300);

  /// §5, toast: "some sozinho após 2200ms".
  static const Duration toastVida = Duration(milliseconds: 2200);

  /// §6, `toastIn`: o toast entra subindo 14px (`translateY(14px)` → `0`).
  static const double toastSubida = 14;

  /// A curva de todo o sistema.
  ///
  /// O CSS de §6 não declara timing-function em `transition: all .15s`, e o
  /// default do CSS é `ease` (A-04). `toastIn` já diz `.3s ease`.
  static const Curve curva = Curves.ease;
}
