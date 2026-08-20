import 'package:flutter/material.dart';

/// Chrome do app logado — envolve tudo que vive sob `/roles`.
///
/// Aqui é só a costura estrutural: quem desenha header, navegação e tokens é a
/// spec 01 `design-system`. O que importa nesta spec é que a rota pública do
/// convidado fique **fora** deste envelope (FUND-08).
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  /// Chave do chrome. É por ela que o teste afirma o par discriminante de
  /// FUND-08: presente em `/roles`, ausente em `/c/:codigo`.
  static const Key chromeKey = Key('app-shell-chrome');

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: chromeKey, child: child);
  }
}
