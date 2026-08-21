import 'package:flutter/painting.dart';

/// Os paddings literais dos componentes do arquivo 02 §5.
///
/// Onde §5 dá faixa ("padding 12–13px 14–16px"), o token fica no **extremo
/// inferior** declarado — o mesmo critério que A-01 fixou para a tipografia:
/// extremo é literal da spec, valor no meio seria invenção.
abstract final class BoraSpacing {
  /// §5, botão primário e secundário: "padding 15–16px".
  static const EdgeInsets botao = EdgeInsets.all(15);

  /// §5, chip de seleção: "Padding 10px 14px".
  static const EdgeInsets chip = EdgeInsets.symmetric(
    vertical: 10,
    horizontal: 14,
  );

  /// §5, card de lista: "linhas com padding 12–13px 14–16px".
  static const EdgeInsets linhaLista = EdgeInsets.symmetric(
    vertical: 12,
    horizontal: 14,
  );

  /// §5, card-herói escuro: "padding 20–22px".
  static const EdgeInsets cardHeroi = EdgeInsets.all(20);

  /// §5, rodapé fixo: "padding 14–16px 24px 30px".
  static const EdgeInsets rodape = EdgeInsets.fromLTRB(24, 14, 24, 30);

  /// §5, bottom sheet: "padding 22px 24px 30px".
  static const EdgeInsets sheet = EdgeInsets.fromLTRB(24, 22, 24, 30);

  /// §5, tag de status: "padding 4–6px 7–9px".
  static const EdgeInsets tag = EdgeInsets.symmetric(
    vertical: 4,
    horizontal: 7,
  );

  /// §5, toast: "padding 12px 20px".
  static const EdgeInsets toast = EdgeInsets.symmetric(
    vertical: 12,
    horizontal: 20,
  );

  /// §5, inputs: "padding 15px 16px".
  static const EdgeInsets input = EdgeInsets.symmetric(
    vertical: 15,
    horizontal: 16,
  );
}
