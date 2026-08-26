/// O vocabulário fechado de falhas que a tela sabe tratar.
///
/// É enum, e não `String`, para que a UI nunca compare `e.code` com literal do
/// SDK: o mapeamento de código para falha acontece **uma vez**, em
/// `dados/falha_de_codigo.dart`, e o resto do app fala só esta linguagem.
///
/// Sem `chave` de serialização — ao contrário de `PapelNaFesta`, uma falha
/// nunca é persistida nem trafega; ela vive o tempo de uma interação.
enum FalhaDeAutenticacao {
  /// E-mail ou senha incorretos. A tela mostra "E-MAIL OU SENHA INCORRETOS".
  credencialInvalida,

  /// Já existe conta com este e-mail — só acontece no modo cadastro.
  emailEmUso,

  /// O backend recusou a senha por ser fraca demais.
  senhaFraca,

  /// Sem rede, ou o Firebase inalcançável.
  semRede,

  /// O usuário abortou o fluxo do provedor. **Não é erro**: a tela volta ao
  /// estado ocioso, sem mensagem — quem fechou o popup sabe que fechou.
  cancelada,

  /// Qualquer outra, inclusive Firebase não inicializado. É o ramo que mantém
  /// a degradação de AD-004: o app abre, o CTA falha com mensagem, nada trava.
  indisponivel,
}
