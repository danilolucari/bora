import 'package:flutter/material.dart';

import '../../../../core/routing/placeholder_page.dart';

/// T-03 montar — placeholder da fundação.
///
/// Atende as duas rotas do mapa canônico: `/roles/novo` (rolê que ainda não
/// existe) e `/roles/:festaId/montar` (rolê existente).
class MontarPage extends StatelessWidget {
  const MontarPage({super.key});

  /// Identificador desta tela na chave do placeholder.
  static const String id = 'montar';

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(id: id, titulo: 'MONTAR');
  }
}
