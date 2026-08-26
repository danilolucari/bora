import 'falha_de_autenticacao.dart';
import 'usuario_logado.dart';

/// O contrato de sessão e autenticação — sem Firebase, sem Flutter.
///
/// É a porta que o roteador consulta para a guarda de AD-017 e que a tela de
/// entrar aciona. A implementação Firebase vive em `dados/`, e é injetada; a
/// suíte inteira roda contra um duplo, sem emulador ligado (AD-016).
///
/// **Os métodos de ação devolvem `Future<void>`, não o usuário.** Quem anuncia
/// o sucesso é [mudancasDeSessao]: se o método também devolvesse o usuário,
/// existiriam duas fontes de verdade para "estou logado", e a mais rápida
/// venceria de forma não determinística. Falha vira `throw
/// FalhaDeAutenticacao`.
abstract class AutenticacaoRepository {
  /// A sessão de agora, **síncrona**.
  ///
  /// Síncrona porque o `redirect` do `go_router` decide o destino sem esperar:
  /// um `Future` aqui obrigaria a rota a passar por um estado de carregando
  /// que nenhuma tela da spec desenha.
  UsuarioLogado? get sessaoAtual;

  /// Emite a cada mudança de sessão. Alimenta o `refreshListenable` do
  /// roteador — é o que faz a navegação pós-login ser consequência da guarda,
  /// e não uma chamada imperativa (AD-020).
  Stream<UsuarioLogado?> get mudancasDeSessao;

  /// Entra com e-mail e senha. Lança [FalhaDeAutenticacao] se não der.
  Future<void> entrarComEmailESenha({
    required String email,
    required String senha,
  });

  /// Entra pelo provedor Google. Cancelar o fluxo lança
  /// [FalhaDeAutenticacao.cancelada], que **não** é erro para a tela.
  Future<void> entrarComGoogle();

  /// Cria a conta e já autentica. Lança [FalhaDeAutenticacao] se não der.
  Future<void> criarConta({required String email, required String senha});

  /// Encerra a sessão.
  Future<void> sair();

  /// Libera a inscrição interna que alimenta [mudancasDeSessao].
  ///
  /// Não estava na lista do `design.md`: apareceu na implementação, porque uma
  /// implementação que observa o SDK **é** dona de uma inscrição, e inscrição
  /// vazada contamina o teste seguinte.
  Future<void> dispose();
}
