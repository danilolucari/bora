import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../home_textos.dart';

/// A mensagem do estado `falhou`, igual nos dois layouts (HOME-16).
///
/// Existe como widget próprio para que a Home do mobile e a do web não possam
/// discordar sobre como o produto avisa que não conseguiu carregar — foi o
/// mesmo motivo de `HomeTextos`.
class FaixaDeFalha extends StatelessWidget {
  const FaixaDeFalha({super.key});

  @override
  Widget build(BuildContext context) =>
      Text(HomeTextos.falha, style: BoraTextStyles.labelSecao);
}
