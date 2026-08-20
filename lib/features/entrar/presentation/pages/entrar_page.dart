import 'package:flutter/material.dart';

import '../../../../core/routing/placeholder_page.dart';

/// T-01 entrar — placeholder da fundação.
///
/// A spec 03 `entrar` troca o corpo deste arquivo sem tocar na tabela de rotas.
class EntrarPage extends StatelessWidget {
  const EntrarPage({super.key});

  /// Identificador desta tela na chave do placeholder.
  static const String id = 'entrar';

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(id: id, titulo: 'ENTRAR');
  }
}
