import 'package:flutter/material.dart';

import '../../../../core/routing/placeholder_page.dart';

/// T-02 home — placeholder da fundação.
///
/// A spec 04 `home` troca o corpo deste arquivo sem tocar na tabela de rotas.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  /// Identificador desta tela na chave do placeholder.
  static const String id = 'home';

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(id: id, titulo: 'HOME');
  }
}
