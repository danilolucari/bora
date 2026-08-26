import 'routes.dart';

/// As rotas que abrem **com ou sem sessão** — ENT-17 AC3.
///
/// Não é conveniência: `/c/:codigo` é o link do convidado, que por RN-24
/// responde **sem baixar nada e sem conta**. Barrá-lo mataria o diferencial do
/// produto. `/erro` precisa ser alcançável de qualquer lugar, inclusive antes
/// do login, e `/catalogo` é ferramenta interna (AD-014).
const Set<String> rotasLivres = {
  Routes.erro,
  Routes.catalogo,
};

/// Prefixo da rota pública do convidado, que carrega parâmetro.
const String _prefixoDoConvidado = '/c/';

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
String? guardaDeSessao({required String rota, required bool temSessao}) {
  if (_ehLivre(rota)) return null;

  if (!temSessao) {
    // Sem sessão, o único destino possível é a porta de entrada. Devolver
    // `null` aqui deixaria `/roles` acessível por URL digitada no web.
    return rota == Routes.entrar ? null : Routes.entrar;
  }

  // Com sessão, ficar em `/entrar` não faz sentido — e é literalmente o
  // aceite de UC-01, "pós-login sempre cai na Home".
  return rota == Routes.entrar ? Routes.roles : null;
}

bool _ehLivre(String rota) =>
    rotasLivres.contains(rota) || rota.startsWith(_prefixoDoConvidado);
