import 'package:flutter/material.dart';

import '../../../../core/routing/placeholder_page.dart';

/// T-04 lista — placeholder da fundação, primeira aba permanente da festa.
class ListaPage extends StatelessWidget {
  const ListaPage({super.key});

  /// Identificador desta tela na chave do placeholder.
  static const String id = 'lista';

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(id: id, titulo: 'LISTA');
  }
}
