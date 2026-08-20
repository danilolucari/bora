import 'package:flutter/widgets.dart';

import 'layout_mode.dart';

/// Expõe o [LayoutMode] da largura disponível à árvore de widgets.
///
/// Nenhum token, nenhuma cor, nenhuma fonte: quem decide a aparência de cada
/// modo é a spec 01 `design-system`.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, LayoutMode mode) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          builder(context, layoutModeForWidth(constraints.maxWidth)),
    );
  }
}
