import 'package:flutter/painting.dart';

import 'bora_colors.dart';

/// O descritor de uma borda tracejada de §3.
///
/// O Flutter não desenha borda tracejada: quem pinta é o componente, e é este
/// descritor que diz com que cor e com que espessura.
typedef BoraDashedBorder = ({Color cor, double largura});

/// As formas e bordas do arquivo 02 §3.
///
/// A lei é `border-radius: 0` em **tudo**. As duas únicas exceções — avatares
/// e dots (círculo) e o frame do celular (38px) — moram no próprio componente,
/// declaradas na allowlist da guarda de forma.
abstract final class BoraBorders {
  /// §3: "`border-radius: 0` em **tudo** (botões, cards, inputs, chips)".
  static const BorderRadius raio = BorderRadius.zero;

  /// §3: borda padrão `2px solid`, na cor pedida.
  static Border solida(Color cor) => Border.all(color: cor, width: 2);

  /// §3: a borda padrão de cards, botões, inputs, chips e checkboxes —
  /// `2px solid #141414`.
  static final Border padraoInk = solida(BoraColors.ink);

  /// §5, frame do celular: `border 1px rgba(0,0,0,.25)`.
  static final Border frame = Border.all(
    color: BoraColors.frameBorder,
    width: 1,
  );

  /// §3, dica/nota: `2px dashed #141414`.
  static const BoraDashedBorder dicaTracejada = (
    cor: BoraColors.ink,
    largura: 2,
  );

  /// §3, slot vazio/desabilitado: `2px dashed #9b9b9b`.
  static const BoraDashedBorder slotTracejado = (
    cor: BoraColors.text3,
    largura: 2,
  );

  /// §3: a opacidade do slot vazio/desabilitado — `opacity .7`.
  ///
  /// É a única opacidade do arquivo 02, e por isso também é a do estado
  /// desabilitado de botão e de stepper (A-07). O desabilitado mantém a borda
  /// **sólida**: o tracejado é do slot vazio, não do desabilitado.
  static const double opacidadeDesabilitado = 0.7;
}
