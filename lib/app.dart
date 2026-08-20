import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Raiz do app BORA.
///
/// Recebe o roteador por parâmetro — não o resolve do container — para que a
/// suíte monte o app inteiro sem DI. Nenhum token da spec 01 aqui.
class BoraApp extends StatelessWidget {
  const BoraApp({required this.router, super.key});

  /// Título da aba no navegador (FUND-10). Literal de W-R5.
  static const String titulo = 'bora — a conta do rolê';

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: titulo,
      routerConfig: router,
    );
  }
}
