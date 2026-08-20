import 'package:flutter/material.dart';

import '../../../../core/routing/placeholder_page.dart';

/// T-05 galera — placeholder da fundação, segunda aba permanente da festa.
class GaleraPage extends StatelessWidget {
  const GaleraPage({super.key});

  /// Identificador desta tela na chave do placeholder.
  static const String id = 'galera';

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(id: id, titulo: 'GALERA');
  }
}
