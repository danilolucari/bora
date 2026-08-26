/// O que há de errado com o e-mail digitado — ENT-08.
enum ErroDeEmail {
  /// Campo em branco.
  vazio,

  /// Não parece e-mail: falta `@`, falta domínio, ou tem espaço no meio.
  formato,
}

/// O que há de errado com a senha digitada — ENT-08.
enum ErroDeSenha {
  /// Campo em branco.
  vazia,

  /// Menos que o mínimo aceito pelo backend.
  curta,
}

/// O mínimo de caracteres da senha (A-08).
///
/// Seis não é escolha de gosto: é o mínimo que o **próprio Firebase Auth**
/// impõe. Um número menor faria a tela aceitar o que o backend recusa; um
/// maior faria a tela recusar conta que o backend criaria.
const int minimoDeSenha = 6;

/// Valida o e-mail. Devolve `null` quando está bom — ENT-08.
///
/// O `trim` acontece aqui, e não na tela: espaço nas pontas é acidente de
/// digitação (e de colar), e quem decide o que é um e-mail válido é esta
/// função. Deixar o corte para o widget espalharia a regra.
ErroDeEmail? validarEmail(String email) {
  final limpo = email.trim();

  if (limpo.isEmpty) return ErroDeEmail.vazio;

  return _pareceEmail(limpo) ? null : ErroDeEmail.formato;
}

/// Valida a senha. Devolve `null` quando está boa — ENT-08.
///
/// Sem `trim`: espaço pode ser parte legítima de uma senha, e apará-lo
/// impediria o usuário de entrar com a senha que ele realmente cadastrou.
ErroDeSenha? validarSenha(String senha) {
  if (senha.isEmpty) return ErroDeSenha.vazia;

  return senha.length < minimoDeSenha ? ErroDeSenha.curta : null;
}

/// O e-mail normalizado que vai para o repositório.
String emailNormalizado(String email) => email.trim();

/// Um `algo@algo.algo` sem espaços.
///
/// Deliberadamente frouxo: validar e-mail por regex a sério é folclore, e o
/// juiz final é o backend, que devolve `invalid-email`. O que esta checagem
/// evita é a viagem de rede óbvia — não é autoridade sobre o que existe.
bool _pareceEmail(String email) {
  if (email.contains(RegExp(r'\s'))) return false;

  final partes = email.split('@');
  if (partes.length != 2) return false;

  final [usuario, dominio] = partes;

  return usuario.isNotEmpty && dominio.contains('.') && !dominio.startsWith('.') && !dominio.endsWith('.');
}
