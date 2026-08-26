import 'package:go_router/go_router.dart';

import '../../features/home/domain/festa_repository.dart';
import '../autenticacao/autenticacao.dart';
import '../observability/app_logger.dart';

import '../../features/convidado/presentation/pages/convidado_page.dart';
import '../../features/convite/presentation/pages/convite_page.dart';
import '../../features/custos/presentation/pages/custos_page.dart';
import '../../features/entrar/presentation/pages/entrar_page.dart';
import '../../features/galera/presentation/pages/galera_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/lista/presentation/pages/lista_page.dart';
import '../../features/montar/presentation/pages/montar_page.dart';
import '../design_system/catalog/catalog_page.dart';
import 'app_shell.dart';
import 'festa_tabs_shell.dart';
import 'go_router_refresh_stream.dart';
import 'guarda_de_sessao.dart';
import 'invite_code_format.dart';
import 'route_error_page.dart';
import 'routes.dart';

// SPEC_DEVIATION: o `design.md` desenha `/roles/:festaId/montar` e as quatro
// abas como rotas irmãs e planas dentro do `ShellRoute`. Aqui elas são
// sub-rotas de um nó `/roles/:festaId` que não é tela — só carrega o parâmetro.
// Reason: `go_router` proíbe que a rota padrão de um `StatefulShellBranch`
// tenha parâmetro de caminho (`configuration.dart:149`,
// 'The default location of a StatefulShellBranch cannot be a parameterized
// route'), então o `:festaId` precisa morar num ancestral do shell de abas.
// Nenhuma URL do mapa canônico muda: `/roles/:festaId/lista` continua sendo
// `/roles/:festaId/lista`.
const String _festaPattern = '/roles/:${Routes.paramFestaId}';

/// Monta a tabela de rotas do app.
///
/// Três zonas: a pública (sem shell e sem autenticação), o destino de erro, e o
/// shell do app com as abas da festa. `/c/:codigo` fica deliberadamente fora de
/// qualquer shell — o convidado não tem conta (FUND-08).
///
/// [autenticacao] é **obrigatório** (AD-017): com um parâmetro opcional, a
/// produção poderia esquecer a guarda e nada acusaria — o app subiria com
/// `/roles` aberto a quem digitasse a URL. A regra em si vive em
/// [guardaDeSessao], que é pura; aqui é só fiação.
GoRouter buildAppRouter({
  required AutenticacaoRepository autenticacao,
  required FestaRepository festas,
  required AppLogger logger,
  String initialLocation = Routes.roles,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    // Reavalia os redirects a cada mudança de sessão — é o que faz o login
    // levar à Home sem nenhuma feature chamar `context.go` (AD-020).
    refreshListenable:
        GoRouterRefreshStream(autenticacao.mudancasDeSessao),
    redirect: (context, state) => guardaDeSessao(
      rota: state.uri.path,
      temSessao: autenticacao.sessaoAtual != null,
    ),
    errorBuilder: (context, state) =>
        RouteErrorPage(location: state.uri.toString()),
    routes: [
      GoRoute(
        path: Routes.entrar,
        builder: (context, state) => EntrarPage(autenticacao: autenticacao),
      ),
      GoRoute(
        path: Routes.erro,
        builder: (context, state) =>
            RouteErrorPage(location: state.uri.toString()),
      ),
      GoRoute(
        path: Routes.convidadoPattern,
        // Código malformado nunca chega à tela do convidado. `/c/` sem código
        // sequer casa com `:codigo` e cai no `errorBuilder` acima.
        redirect: (context, state) =>
            isWellFormedInviteCode(state.pathParameters[Routes.paramCodigo])
                ? null
                : Routes.erro,
        builder: (context, state) => ConvidadoPage(
          codigo: state.pathParameters[Routes.paramCodigo]!,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          usuario: autenticacao.sessaoAtual,
          rotaAtual: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: Routes.roles,
            builder: (context, state) =>
            HomePage(festas: festas, logger: logger),
          ),
          // Declarada antes de `/roles/:festaId` de propósito: `novo` é uma
          // palavra reservada da rota, não um id de festa.
          GoRoute(
            path: Routes.novoRole,
            builder: (context, state) => const MontarPage(),
          ),
          GoRoute(
            path: _festaPattern,
            // Sem `builder`: este nó não é tela. Só quando ele **é** o destino
            // final é que vale abrir a festa na primeira aba.
            redirect: (context, state) => state.fullPath == _festaPattern
                ? Routes.lista(state.pathParameters[Routes.paramFestaId]!)
                : null,
            routes: [
              GoRoute(
                path: 'montar',
                builder: (context, state) => const MontarPage(),
              ),
              StatefulShellRoute.indexedStack(
                builder: (context, state, navigationShell) =>
                    FestaTabsShell(navigationShell: navigationShell),
                branches: [
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'lista',
                        builder: (context, state) => const ListaPage(),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'galera',
                        builder: (context, state) => const GaleraPage(),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'whatsapp',
                        builder: (context, state) => const ConvitePage(),
                      ),
                    ],
                  ),
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: 'custos',
                        builder: (context, state) => const CustosPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Acrescentada ao fim: o catálogo do design system (DS-33) é irmão de
      // `/entrar` e `/erro` — fica **fora de qualquer shell**, porque não é
      // tela de produto e o chrome do app ainda é placeholder da fundação.
      GoRoute(
        path: Routes.catalogo,
        builder: (context, state) => const CatalogPage(),
      ),
    ],
  );
}
