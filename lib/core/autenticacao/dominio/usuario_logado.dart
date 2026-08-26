/// Quem está logado no app — a identidade da conta, não a da festa.
///
/// É deliberadamente **distinta de `Pessoa`** (`core/calculo/dominio/`):
/// `Pessoa` é convidado de churrasco, com papel, dieta e presença;
/// `UsuarioLogado` é conta. Uni-las acoplaria a sessão ao domínio de cálculo
/// sem que nenhuma spec peça.
///
/// Valor imutável: dois usuários com os mesmos campos são iguais, porque o
/// `Stream` de sessão compara emissões para decidir se houve mudança.
///
/// `==`/`hashCode` são escritos à mão porque `package:meta` é dependência
/// transitiva e importá-la derrubaria `flutter analyze` — a mesma restrição
/// que `core/calculo/dominio/pessoa.dart` já enfrenta.
class UsuarioLogado {
  const UsuarioLogado({
    required this.id,
    required this.email,
    this.nome,
  });

  /// O `uid` da conta — estável entre sessões e dispositivos.
  final String id;

  /// O e-mail da conta.
  final String email;

  /// O nome de exibição. `null` em conta de e-mail/senha, que não tem um.
  final String? nome;

  /// A letra que o avatar do header mostra (spec 04, HOME-01 AC2).
  ///
  /// Cai no e-mail quando não há nome, porque conta de e-mail/senha nunca tem
  /// `displayName` e um avatar vazio seria pior que a inicial do e-mail.
  ///
  /// SPEC_PRECISION_GAP: nenhuma spec define a inicial de um usuário **sem**
  /// nome e **sem** e-mail. O caso só existiria se o adaptador construísse um
  /// `UsuarioLogado` com e-mail vazio — `User.email` é anulável no Firebase.
  /// A resposta certa é o adaptador nunca produzir isso (T5); aqui a função é
  /// total para que a UI não estoure em `email[0]` se ele produzir.
  String get inicial {
    final fonte = (nome != null && nome!.isNotEmpty) ? nome! : email;

    return fonte.isEmpty ? '?' : fonte[0].toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioLogado &&
          other.id == id &&
          other.email == email &&
          other.nome == nome;

  @override
  int get hashCode => Object.hash(id, email, nome);

  @override
  String toString() => 'UsuarioLogado($id, $email, $nome)';
}
