import 'package:go_router/go_router.dart';

import '../../features/convidado/presentation/pages/convidado_page.dart';
import '../../features/entrar/presentation/pages/entrar_page.dart';
import 'invite_code_format.dart';
import 'route_error_page.dart';
import 'routes.dart';

/// Monta a tabela de rotas do app.
///
/// Três zonas: a pública (sem shell e sem autenticação), o destino de erro, e o
/// shell do app com as abas da festa. `/c/:codigo` fica deliberadamente fora de
/// qualquer shell — o convidado não tem conta (FUND-08).
GoRouter buildAppRouter({String initialLocation = Routes.roles}) {
  return GoRouter(
    initialLocation: initialLocation,
    errorBuilder: (context, state) =>
        RouteErrorPage(location: state.uri.toString()),
    routes: [
      GoRoute(
        path: Routes.entrar,
        builder: (context, state) => const EntrarPage(),
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
    ],
  );
}
