import '../../../../core/autenticacao/autenticacao.dart';
import '../../domain/validacao_de_credenciais.dart';

/// Entrar ou criar conta — a mesma tela, dois modos (ENT-20, A-04).
enum ModoDeEntrada { entrar, cadastro }

/// Em que ponto do envio a tela está — ENT-07, ENT-10.
enum SituacaoDeEnvio { ocioso, enviando, falhou }

/// O estado da tela de entrar.
///
/// **Não existe estado de sucesso**, e a ausência é de propósito: autenticar
/// não produz tela nova, produz emissão no stream de sessão. Quem reage é a
/// guarda de rota (AD-020). Um `EntrarState.autenticado` seria uma segunda
/// fonte de verdade para "estou logado", competindo com o stream.
class EntrarState {
  const EntrarState({
    this.modo = ModoDeEntrada.entrar,
    this.situacao = SituacaoDeEnvio.ocioso,
    this.falha,
    this.erroDeEmail,
    this.erroDeSenha,
  });

  final ModoDeEntrada modo;
  final SituacaoDeEnvio situacao;

  /// A falha vinda do repositório. `null` quando não houve.
  final FalhaDeAutenticacao? falha;

  final ErroDeEmail? erroDeEmail;
  final ErroDeSenha? erroDeSenha;

  /// `true` enquanto uma autenticação está em curso — é o que desabilita o CTA
  /// e impede o duplo toque de disparar dois logins (ENT-07, ENT-10).
  bool get enviando => situacao == SituacaoDeEnvio.enviando;

  /// `true` quando a falha corrente merece mensagem na tela.
  ///
  /// [FalhaDeAutenticacao.cancelada] fica de fora: quem fechou o popup do
  /// Google sabe que fechou, e acusar erro faria a tela reclamar de algo que
  /// não aconteceu (ENT-14 AC3).
  bool get mostraFalha =>
      falha != null && falha != FalhaDeAutenticacao.cancelada;

  EntrarState copyWith({
    ModoDeEntrada? modo,
    SituacaoDeEnvio? situacao,
    FalhaDeAutenticacao? falha,
    ErroDeEmail? erroDeEmail,
    ErroDeSenha? erroDeSenha,
    bool limparFalha = false,
    bool limparValidacao = false,
  }) =>
      EntrarState(
        modo: modo ?? this.modo,
        situacao: situacao ?? this.situacao,
        falha: limparFalha ? null : (falha ?? this.falha),
        erroDeEmail: limparValidacao ? null : (erroDeEmail ?? this.erroDeEmail),
        erroDeSenha: limparValidacao ? null : (erroDeSenha ?? this.erroDeSenha),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntrarState &&
          other.modo == modo &&
          other.situacao == situacao &&
          other.falha == falha &&
          other.erroDeEmail == erroDeEmail &&
          other.erroDeSenha == erroDeSenha;

  @override
  int get hashCode =>
      Object.hash(modo, situacao, falha, erroDeEmail, erroDeSenha);
}
