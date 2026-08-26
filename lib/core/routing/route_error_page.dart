import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design_system/design_system.dart';
import 'routes.dart';

/// Destino de toda rota que não leva a lugar nenhum (FUND-09, ENT-19).
///
/// Rota inexistente, `/c/` sem código e `/c/<código malformado>` caem aqui —
/// nunca em tela em branco. É alcançável **sem sessão** de propósito: a guarda
/// de AD-017 só protege `/roles`, porque interceptar o desconhecido apagaria
/// justamente esta página.
///
/// O arquivo 02 não desenha uma tela de erro, então nada aqui é inventado além
/// do arranjo: fundo `paper`, título no papel de título de tela, corpo no papel
/// de corpo, e o secundário do design system. Sem ilustração, sem cor nova.
class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({required this.location, super.key});

  /// A URL que o usuário tentou abrir.
  final String location;

  /// Chave do destino de erro.
  static const Key pageKey = Key('route-error');

  /// A copy, em caixa alta como §7 manda para título.
  static const String titulo = 'PÁGINA NÃO ENCONTRADA';
  static const String corpo =
      'Esse endereço não leva a nenhuma tela do bora.';
  static const String voltar = 'VOLTAR PRO INÍCIO';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      backgroundColor: BoraColors.paper,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: BoraTextStyles.tituloTela,
                ),
                const SizedBox(height: 12),
                Text(
                  corpo,
                  textAlign: TextAlign.center,
                  style: BoraTextStyles.corpo,
                ),
                const SizedBox(height: 8),
                Text(
                  location,
                  textAlign: TextAlign.center,
                  style: BoraTextStyles.dica,
                ),
                const SizedBox(height: 24),
                BoraSecondaryButton(
                  rotulo: voltar,
                  onPressed: () => context.go(Routes.roles),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
