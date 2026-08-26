import 'routes.dart';

/// Decide o destino de [rota] dado o estado da sessão — ENT-15..ENT-18.
///
/// Devolve `null` quando a rota pedida vale, ou o caminho para onde desviar.
///
/// É função pura, em arquivo próprio, e não um `redirect` inline no
/// `app_router.dart`, por dois motivos: concentra a regra inteira da AD-017
/// num lugar só, e fica afirmável por **tabela** — sem montar widget, sem
/// `GoRouter` e sem duplo.
///
/// A guarda também é o que torna a navegação pós-login **consequência**, e não
/// chamada imperativa (AD-020): os três caminhos de entrar — e-mail/senha,
/// Google e cadastro — não navegam; eles mudam a sessão, e quem decide o
/// destino é esta função.
///
/// ## Protege por prefixo, não por lista de exceções
///
/// Só `/roles` e o que vive sob ele são protegidos. Tudo o mais passa: o link
/// do convidado (`/c/:codigo`, que por RN-24 responde **sem conta** — barrá-lo
/// mataria o diferencial do produto), `/erro`, `/catalogo` e **as rotas que
/// não existem**.
///
/// A última é a que obriga o desenho a ser este. O `redirect` do `go_router`
/// roda antes de a rota ser casada, então uma guarda de "default fechado"
/// engoliria `/rota-que-nao-existe` e mandaria para `/entrar` — apagando a
/// página de erro que FUND-09 construiu para que nada caia em tela em branco.
/// Rota desconhecida não expõe conteúdo do app: ela cai no `errorBuilder`,
/// que é exatamente onde deve cair.
String? guardaDeSessao({required String rota, required bool temSessao}) {
  if (!temSessao) return _ehProtegida(rota) ? Routes.entrar : null;

  // Com sessão, ficar em `/entrar` não faz sentido — e é literalmente o
  // aceite de UC-01, "pós-login sempre cai na Home".
  return rota == Routes.entrar ? Routes.roles : null;
}

bool _ehProtegida(String rota) =>
    rota == Routes.roles || rota.startsWith('${Routes.roles}/');
