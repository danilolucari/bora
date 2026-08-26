import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

/// O divisor "OU" entre o CTA e o botão do Google — T-01 e W-01.
///
/// Composição de tela, não componente do design system: o arquivo 02 não o
/// descreve em §5. O que ele empresta são os tokens — a linha usa o
/// `divider2`, que é o `#141414` a 13% que T-01 pede, e o rótulo usa o papel
/// de label de seção.
class DivisorOu extends StatelessWidget {
  const DivisorOu({super.key});

  /// A copy literal de T-01.
  static const String rotulo = 'OU';

  /// Espessura da linha, em px (T-01: "linhas 2px 13%").
  static const double espessura = 2;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _Linha()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(rotulo, style: BoraTextStyles.labelSecao),
        ),
        const Expanded(child: _Linha()),
      ],
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: DivisorOu.espessura,
        child: ColoredBox(color: BoraColors.divider2),
      );
}
