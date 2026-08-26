import '../../../core/autenticacao/autenticacao.dart';
import '../domain/validacao_de_credenciais.dart';
import 'bloc/entrar_state.dart';

/// A copy literal de T-01 e W-01, num lugar só.
///
/// Existe para a **produção** não espalhar string por três widgets — não para
/// o teste comparar contra ela. Os testes afirmam o literal escrito neles,
/// porque a fonte da verdade da copy é a spec: comparar com estas constantes
/// faria o teste concordar com qualquer copy, inclusive a errada.
abstract final class EntrarTextos {
  /// Tag rotacionada −2° (T-01, W-01).
  static const String tagline = 'A CONTA DO ROLÊ, RESOLVIDA';

  /// Parágrafo de apresentação (T-01, W-01).
  static const String apresentacao =
      'Monta o churras, chama a galera e racha a conta. '
      'Sem planilha, sem treta.';

  static const String placeholderEmail = 'seu e-mail';
  static const String placeholderSenha = 'senha';

  /// Rótulo do card no web (W-01), por modo.
  static String label(ModoDeEntrada modo) =>
      modo == ModoDeEntrada.cadastro ? 'CRIAR CONTA' : 'ENTRAR';

  /// CTA principal, por modo (T-01/W-01 e A-07).
  static String cta(ModoDeEntrada modo) =>
      modo == ModoDeEntrada.cadastro ? 'CRIAR CONTA →' : 'COMEÇAR →';

  static const String divisor = 'OU';

  /// A copy do botão do Google **difere entre plataformas** (A-05): T-01 diz
  /// "CONTINUAR COM GOOGLE" e W-01 diz "🌐 ENTRAR COM GOOGLE". As duas ficam
  /// literais — unificar seria escolher qual das duas specs desobedecer.
  static const String googleCompacto = 'CONTINUAR COM GOOGLE';
  static const String googleExpandido = '🌐 ENTRAR COM GOOGLE';

  /// Rodapé, por modo. O prefixo é sentence case e a ação é caixa alta.
  static String rodapePergunta(ModoDeEntrada modo) =>
      modo == ModoDeEntrada.cadastro ? 'Já tem conta? ' : 'Novo por aqui? ';

  static String rodapeAcao(ModoDeEntrada modo) =>
      modo == ModoDeEntrada.cadastro ? 'ENTRAR' : 'CRIAR CONTA';

  /// A mensagem de erro de credencial (A-06).
  ///
  /// Inline, e **não** toast: RN-29 fecha a lista de toasts canônicos e nenhum
  /// deles é de erro. Erro de formulário é do formulário.
  static const String credencialInvalida = 'E-MAIL OU SENHA INCORRETOS';
  static const String emailEmUso = 'JÁ EXISTE CONTA COM ESSE E-MAIL';
  static const String senhaFraca = 'ESCOLHA UMA SENHA MAIS FORTE';
  static const String semRede = 'SEM CONEXÃO — TENTE DE NOVO';
  static const String indisponivel = 'NÃO DEU PRA ENTRAR AGORA';

  /// A mensagem de [falha], ou `null` quando ela não merece mensagem.
  static String? mensagemDe(FalhaDeAutenticacao? falha) => switch (falha) {
        FalhaDeAutenticacao.credencialInvalida => credencialInvalida,
        FalhaDeAutenticacao.emailEmUso => emailEmUso,
        FalhaDeAutenticacao.senhaFraca => senhaFraca,
        FalhaDeAutenticacao.semRede => semRede,
        FalhaDeAutenticacao.indisponivel => indisponivel,
        // Quem fechou o popup do Google sabe que fechou (ENT-14 AC3).
        FalhaDeAutenticacao.cancelada => null,
        null => null,
      };

  static const String emailVazio = 'INFORME SEU E-MAIL';
  static const String emailInvalido = 'E-MAIL INVÁLIDO';
  static const String senhaVazia = 'INFORME SUA SENHA';
  static const String senhaCurta = 'MÍNIMO DE $minimoDeSenha CARACTERES';

  static String? mensagemDeEmail(ErroDeEmail? erro) => switch (erro) {
        ErroDeEmail.vazio => emailVazio,
        ErroDeEmail.formato => emailInvalido,
        null => null,
      };

  static String? mensagemDeSenha(ErroDeSenha? erro) => switch (erro) {
        ErroDeSenha.vazia => senhaVazia,
        ErroDeSenha.curta => senhaCurta,
        null => null,
      };
}
