/// O que o usuário faz na tela de entrar — ENT-06, ENT-13, ENT-14, ENT-20.
sealed class EntrarEvent {
  const EntrarEvent();
}

/// Tocou "CRIAR CONTA" (ou "ENTRAR", no modo cadastro) — ENT-20 AC1.
///
/// Um evento só para os dois sentidos: é a mesma alternância, e dois eventos
/// abririam caminho para os sentidos divergirem.
class ModoAlternado extends EntrarEvent {
  const ModoAlternado();
}

/// Tocou o CTA com e-mail e senha preenchidos.
///
/// **O mesmo evento serve entrar e criar conta** (ENT-06 e ENT-20 AC3): é o
/// mesmo gesto do usuário sobre o mesmo formulário, e quem decide o método é
/// o modo corrente no estado. Duplicar o evento duplicaria a validação, o
/// controle de envio e o tratamento de falha — três lugares para divergir.
class SubmetidoComCredenciais extends EntrarEvent {
  const SubmetidoComCredenciais({required this.email, required this.senha});

  final String email;
  final String senha;
}

/// Tocou o botão do Google — ENT-14.
class SubmetidoComGoogle extends EntrarEvent {
  const SubmetidoComGoogle();
}
