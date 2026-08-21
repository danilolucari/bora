import 'package:flutter/painting.dart';

import 'bora_colors.dart';

/// As sombras do arquivo 02 §4 — **sempre duras, sem blur**.
///
/// Toda sombra da UI nasce de [hard], que fixa `blurRadius: 0` e
/// `spreadRadius: 0`. A única exceção do sistema é [frame], a sombra do palco.
abstract final class BoraShadows {
  /// Uma sombra dura: deslocada em [distancia] nos dois eixos, sem blur e sem
  /// spread.
  static BoxShadow hard(Color acento, double distancia) => BoxShadow(
        color: acento,
        offset: Offset(distancia, distancia),
        blurRadius: 0,
        spreadRadius: 0,
      );

  /// §4, botão CTA: `4px 4px 0 <acento>`.
  ///
  /// A cor é a do acento do contexto, então o que fica fixo é a distância —
  /// quem monta o CTA chama `hard(acento.cor, distanciaCta)`.
  //
  // SPEC_DEVIATION: o design.md lista este uso como a constante `ctaCurta`,
  // junto com as outras sombras nomeadas de §4.
  // Motivo: §4 declara a sombra do CTA como `4px 4px 0 <acento>` — a cor é a
  // do contexto. Uma constante `BoxShadow` teria de congelar uma cor que a
  // spec deixa em aberto; o que §4 fixa aqui é a distância.
  static const double distanciaCta = 4;

  /// §4, "Hover/press de CTA (**obrigatório**)": no afundamento a sombra
  /// encolhe de `4px 4px` para `2px 2px`.
  ///
  /// É o mesmo 2px do `transform: translate(2px,2px)` da mesma frase de §4 —
  /// o CTA desce exatamente o quanto a sombra encolhe, que é o que produz o
  /// efeito de afundar.
  static const double distanciaCtaAfundado = 2;

  /// §4, CTA grande do login: `5px 5px 0 #FF4D2E`.
  static final BoxShadow loginGrande = hard(BoraColors.primary, 5);

  /// §4, card do link (galera): `5px 5px 0 #6C4BF5`.
  static final BoxShadow cardLink = hard(BoraColors.purple, 5);

  /// §4, card criar grupo: `5px 5px 0 #25D366`.
  static final BoxShadow cardGrupo = hard(BoraColors.waGreen, 5);

  /// §4, card branco destacado: `6px 6px 0 #141414`.
  static final BoxShadow cardBranco = hard(BoraColors.ink, 6);

  /// §4, card branco destacado, variante forte: `8px 8px 0 #141414`.
  static final BoxShadow cardBrancoGrande = hard(BoraColors.ink, 8);

  /// §4, card-herói escuro: `6px 6px 0 #FF4D2E`.
  static final BoxShadow cardHeroi = hard(BoraColors.primary, 6);

  /// §4, flyer do convite: `8px 8px 0 #FF4D2E`.
  static final BoxShadow flyer = hard(BoraColors.primary, 8);

  /// §4, bolha do WhatsApp: `4px 4px 0 #141414`.
  static final BoxShadow bolhaWa = hard(BoraColors.ink, 4);

  /// §4, frame do celular: `0 20px 50px -20px rgba(20,10,50,.35)`.
  ///
  /// A **única** sombra suave permitida no sistema — e ela não é UI: o frame é
  /// o palco onde a UI aparece (§4). Qualquer outro blur em `lib/` é violação.
  static const BoxShadow frame = BoxShadow(
    color: BoraColors.frameShadow,
    offset: Offset(0, 20),
    blurRadius: 50,
    spreadRadius: -20,
  );
}
