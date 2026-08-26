import 'package:flutter/material.dart';

import '../autenticacao/dominio/usuario_logado.dart';
import '../design_system/design_system.dart';

/// Chrome do app logado — envolve tudo que vive sob `/roles`.
///
/// Duas responsabilidades, e só duas: manter a rota pública do convidado
/// **fora** deste envelope (FUND-08) e desenhar o header de app do arquivo
/// `06` — "barra sticky: fundo `paper`, `border-bottom 2px ink`, padding 13px
/// 36px; logo BORA. 20px · spacer · avatar do usuário 36px".
///
/// A barra é sticky por construção: ela vive **fora** do que rola, numa
/// `Column` acima do conteúdo, então não há o que grudar.
class AppShell extends StatelessWidget {
  const AppShell({required this.child, this.usuario, super.key});

  /// Chave do chrome. É por ela que o teste afirma o par discriminante de
  /// FUND-08: presente em `/roles`, ausente em `/c/:codigo`.
  static const Key chromeKey = Key('app-shell-chrome');

  /// Chave da barra do header — o que distingue "o envelope existe" de "o
  /// header está desenhado".
  static const Key headerKey = Key('app-shell-header');

  /// `06` §Header de app: "padding 13px 36px".
  static const EdgeInsets paddingDoHeader = EdgeInsets.symmetric(
    horizontal: 36,
    vertical: 13,
  );

  /// `06` §Header de app: "avatar do usuário 36px".
  static const double tamanhoDoAvatar = 36;

  /// `06` §Header de app: o avatar de conta é sempre `#FFD23F`, com a inicial
  /// em `ink` (A-08). Não é persona de festa, então não deriva do nome.
  static const BoraAvatarPair parDoAvatar = (
    fundo: BoraColors.yellow,
    texto: BoraColors.ink,
  );

  final Widget child;

  /// Quem está logado, para o avatar do header.
  ///
  /// Chega **pelo roteador**, que já tem a porta de sessão para a guarda de
  /// AD-017. O shell não resolve `getIt` nem observa a porta: resolver o
  /// container aqui faria todo teste de rota configurar DI para montar uma
  /// tela — o motivo que a spec 03 documentou em `entrar_page.dart`.
  ///
  /// `null` só acontece fora de `/roles`, onde a guarda não deixa chegar sem
  /// sessão. Nesse caso o avatar não é desenhado, em vez de mostrar uma
  /// inicial inventada.
  final UsuarioLogado? usuario;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: chromeKey,
      child: Column(
        children: [
          _HeaderDeApp(usuario: usuario),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _HeaderDeApp extends StatelessWidget {
  const _HeaderDeApp({required this.usuario});

  final UsuarioLogado? usuario;

  @override
  Widget build(BuildContext context) {
    // `Container`, e não `DecoratedBox`: ele soma a espessura da borda ao
    // padding, que é a semântica de `06` — lá o `border-bottom` fica **fora**
    // do padding. Com `DecoratedBox` a borda é pintada por dentro e come 2px
    // dos 13, deixando o header com menos respiro do que a spec pede.
    return Container(
      key: AppShell.headerKey,
      decoration: const BoxDecoration(
        color: BoraColors.paper,
        // `06`: "border-bottom 2px ink" — só a de baixo.
        border: Border(bottom: BorderSide(color: BoraColors.ink, width: 2)),
      ),
      padding: AppShell.paddingDoHeader,
      child: Row(
        children: [
          const BoraMarca.header(),
          const Spacer(),
          if (usuario != null)
            BoraAvatar(
              // A inicial vem de `UsuarioLogado.inicial`, que já resolve o
              // nome ausente caindo no e-mail (AD-019). Passá-la como nome
              // mantém uma fonte só para a letra do avatar.
              nome: usuario!.inicial,
              tamanho: AppShell.tamanhoDoAvatar,
              par: AppShell.parDoAvatar,
            ),
        ],
      ),
    );
  }
}
