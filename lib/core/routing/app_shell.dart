import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../autenticacao/dominio/usuario_logado.dart';
import '../design_system/design_system.dart';
import '../responsive/layout_mode.dart';
import '../responsive/responsive_builder.dart';
import 'routes.dart';

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
  const AppShell({
    required this.child,
    this.usuario,
    this.rotaAtual,
    super.key,
  });

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

  /// `06` §Header de app: "na Home a ação é o botão + NOVO ROLÊ".
  static const String rotuloDeNovoRole = '+ NOVO ROLÊ';

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

  /// A rota que está montada, para o header saber qual ação é a dele.
  ///
  /// Chega pelo roteador — que é quem sabe —, e não de `GoRouterState.of`, para
  /// que o header continue montável num teste sem rota. Qual ação pertence a
  /// qual rota é decisão do header, e mora num lugar só.
  final String? rotaAtual;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: chromeKey,
      child: Column(
        children: [
          _HeaderDeApp(usuario: usuario, rotaAtual: rotaAtual),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _HeaderDeApp extends StatelessWidget {
  const _HeaderDeApp({required this.usuario, required this.rotaAtual});

  final UsuarioLogado? usuario;
  final String? rotaAtual;

  /// A ação contextual desta rota, se houver.
  ///
  /// `06` dá a ação do header **só no web** e T-02 não desenha barra de app
  /// nenhuma no mobile (A-07), então em compacto o header não tem ação — a
  /// entrada para criar rolê ali é o card "🔥 CHURRASCO" da própria Home.
  ///
  /// SPEC_PRECISION_GAP: `06` desenha o botão como "primário compacto"
  /// (padding 9x14, sombra 3px). O padding e a sombra de §4 são 15 e 4px, e o
  /// `CLAUDE.md` manda a sombra vir do token — um 3px aqui seria sombra fora
  /// do sistema. Fica o primário do design system; se o compacto for mesmo
  /// necessário, é variante do componente, não decisão de um arquivo de rota.
  bool _temAcao(LayoutMode modo) =>
      modo == LayoutMode.expanded && rotaAtual == Routes.roles;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, modo) => _barra(context, modo));
  }

  Widget _barra(BuildContext context, LayoutMode modo) {
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
          // Sem botão voltar na Home: ela é a raiz do app logado.
          //
          // SPEC_PRECISION_GAP: `06` põe o voltar "quando aplicável" e nenhuma
          // tela do M1 define quando isso é. Enquanto nenhuma spec disser, o
          // header não desenha voltar em rota alguma — inventar o critério
          // aqui furaria o mapa de navegação de AD-003.
          const BoraMarca.header(),
          const Spacer(),
          if (_temAcao(modo)) ...[
            BoraPrimaryButton(
              rotulo: AppShell.rotuloDeNovoRole,
              onPressed: () => context.go(Routes.novoRole),
            ),
            const SizedBox(width: 16),
          ],
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
