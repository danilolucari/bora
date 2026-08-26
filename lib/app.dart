import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/design_system/tokens/bora_theme.dart';

/// Raiz do app BORA.
///
/// Recebe o roteador por parâmetro — não o resolve do container — para que a
/// suíte monte o app inteiro sem DI.
///
/// É aqui que o tema do arquivo 02 entra no app (AD-013, ENT-01): o `ThemeData`
/// chega pronto de `core/design_system/`, e nenhum valor nasce neste arquivo.
/// Sem isto, toda tela cairia no default do Material — azul, Roboto e canto
/// arredondado.
class BoraApp extends StatelessWidget {
  const BoraApp({required this.router, super.key});

  /// Título da aba no navegador (FUND-10). Literal de W-R5.
  static const String titulo = 'bora — a conta do rolê';

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: titulo,
      theme: boraTheme(),
      routerConfig: router,
    );
  }
}
