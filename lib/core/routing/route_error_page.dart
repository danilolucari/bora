import 'package:flutter/material.dart';

/// Destino de toda rota que não leva a lugar nenhum (FUND-09).
///
/// Rota inexistente, `/c/` sem código e `/c/<código malformado>` caem aqui —
/// nunca em tela em branco. Sem token da spec 01, que reveste depois.
class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({required this.location, super.key});

  /// A URL que o usuário tentou abrir.
  final String location;

  /// Chave do destino de erro.
  static const Key pageKey = Key('route-error');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('PÁGINA NÃO ENCONTRADA'),
            const Text('Esse endereço não leva a nenhuma tela do bora.'),
            Text(location),
          ],
        ),
      ),
    );
  }
}
