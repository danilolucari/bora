import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Sub-shell das quatro abas permanentes da festa — Lista · Galera · WhatsApp ·
/// Custos (arquivo 01 §5).
///
/// Vive sobre `StatefulShellRoute.indexedStack` (AD-003): cada aba tem o seu
/// próprio navigator, então trocar de aba **não remonta** a tela nem perde o
/// estado. A barra de abas em si é da spec 01.
class FestaTabsShell extends StatelessWidget {
  const FestaTabsShell({required this.navigationShell, super.key});

  /// O container das abas, entregue pelo `go_router`.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return navigationShell;
  }
}
