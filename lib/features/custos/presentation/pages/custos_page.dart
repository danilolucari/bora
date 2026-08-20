import 'package:flutter/material.dart';

import '../../../../core/routing/placeholder_page.dart';

/// T-09 custos — placeholder da fundação, quarta aba permanente da festa.
class CustosPage extends StatelessWidget {
  const CustosPage({super.key});

  /// Identificador desta tela na chave do placeholder.
  static const String id = 'custos';

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(id: id, titulo: 'CUSTOS');
  }
}
