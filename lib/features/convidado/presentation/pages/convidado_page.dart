import 'package:flutter/material.dart';

import '../../../../core/routing/placeholder_page.dart';

/// T-08 convidado — placeholder da fundação.
///
/// Vive fora do shell do app e sem autenticação: quem abre o link não tem
/// conta (RN-23/RN-24). A spec 09 `convidado` troca o corpo deste arquivo.
class ConvidadoPage extends StatelessWidget {
  const ConvidadoPage({required this.codigo, super.key});

  /// Identificador desta tela na chave do placeholder.
  static const String id = 'convidado';

  /// Código do convite que veio na URL — já validado na forma pela rota.
  final String codigo;

  @override
  Widget build(BuildContext context) {
    return PlaceholderPage(id: id, titulo: 'CONVIDADO · $codigo');
  }
}
