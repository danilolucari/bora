import 'package:flutter/material.dart';

import '../../../../core/routing/placeholder_page.dart';

/// T-06/T-07 convite — placeholder da fundação, terceira aba permanente da
/// festa (a que a URL chama de `whatsapp`).
class ConvitePage extends StatelessWidget {
  const ConvitePage({super.key});

  /// Identificador desta tela na chave do placeholder.
  static const String id = 'convite';

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(id: id, titulo: 'CONVITE');
  }
}
