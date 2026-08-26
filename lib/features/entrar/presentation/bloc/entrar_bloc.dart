import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/autenticacao/autenticacao.dart';
import '../../domain/validacao_de_credenciais.dart';
import 'entrar_event.dart';
import 'entrar_state.dart';

export 'entrar_event.dart';
export 'entrar_state.dart';

/// O estado da tela de entrar — ENT-06, ENT-07, ENT-08, ENT-10, ENT-13,
/// ENT-14, ENT-20.
///
/// **Este bloc não navega e não conhece `BuildContext`** (AD-020). Autenticar
/// com sucesso não emite estado nenhum: emite no stream de sessão do
/// repositório, o `refreshListenable` acorda, e a guarda de rota leva para a
/// Home. Os três caminhos — e-mail/senha, Google e cadastro — terminam no
/// mesmo lugar porque terminam no mesmo mecanismo, não porque três linhas
/// iguais foram escritas em três lugares.
class EntrarBloc extends Bloc<EntrarEvent, EntrarState> {
  EntrarBloc(this._autenticacao) : super(const EntrarState()) {
    on<ModoAlternado>(_aoAlternarModo);
    on<SubmetidoComCredenciais>(_aoSubmeterCredenciais);
    on<SubmetidoComGoogle>(_aoSubmeterGoogle);
  }

  final AutenticacaoRepository _autenticacao;

  /// ENT-13: alternar preserva o e-mail (que vive no controlador da tela) e
  /// **limpa a falha anterior** — carregar para o modo cadastro um erro que
  /// aconteceu no modo entrar acusaria o usuário de algo que ele não fez ali.
  void _aoAlternarModo(ModoAlternado evento, Emitter<EntrarState> emit) {
    emit(
      state.copyWith(
        modo: state.modo == ModoDeEntrada.entrar
            ? ModoDeEntrada.cadastro
            : ModoDeEntrada.entrar,
        situacao: SituacaoDeEnvio.ocioso,
        limparFalha: true,
        limparValidacao: true,
      ),
    );
  }

  Future<void> _aoSubmeterCredenciais(
    SubmetidoComCredenciais evento,
    Emitter<EntrarState> emit,
  ) async {
    // ENT-07/ENT-10: já há uma autenticação em curso. Sair aqui é o que faz o
    // duplo toque disparar um login, e não dois.
    if (state.enviando) return;

    final erroDeEmail = validarEmail(evento.email);
    final erroDeSenha = validarSenha(evento.senha);

    // ENT-08: validação barra **antes** do repositório — sem viagem de rede
    // para o que a tela já sabe que está errado.
    if (erroDeEmail != null || erroDeSenha != null) {
      // Estado montado do zero em vez de `copyWith`: aqui a falha anterior e
      // os erros anteriores **devem** sumir, e só estes dois valem. Um
      // `copyWith` com limpeza e atribuição ao mesmo tempo se contradiz.
      emit(
        EntrarState(
          modo: state.modo,
          erroDeEmail: erroDeEmail,
          erroDeSenha: erroDeSenha,
        ),
      );
      return;
    }

    await _autenticando(
      emit,
      () => state.modo == ModoDeEntrada.cadastro
          ? _autenticacao.criarConta(
              email: emailNormalizado(evento.email),
              senha: evento.senha,
            )
          : _autenticacao.entrarComEmailESenha(
              email: emailNormalizado(evento.email),
              senha: evento.senha,
            ),
    );
  }

  Future<void> _aoSubmeterGoogle(
    SubmetidoComGoogle evento,
    Emitter<EntrarState> emit,
  ) async {
    if (state.enviando) return;

    await _autenticando(emit, _autenticacao.entrarComGoogle);
  }

  /// O ciclo comum aos três caminhos: marcar envio, tentar, e voltar ao
  /// ocioso — com a falha quando houver.
  ///
  /// Note que o sucesso **não emite estado novo além de sair do envio**: quem
  /// anuncia que entrou é o stream de sessão.
  Future<void> _autenticando(
    Emitter<EntrarState> emit,
    Future<void> Function() tentativa,
  ) async {
    emit(
      state.copyWith(
        situacao: SituacaoDeEnvio.enviando,
        limparFalha: true,
        limparValidacao: true,
      ),
    );

    try {
      await tentativa();
      emit(state.copyWith(situacao: SituacaoDeEnvio.ocioso));
    } on FalhaDeAutenticacao catch (falha) {
      emit(
        state.copyWith(situacao: SituacaoDeEnvio.falhou, falha: falha),
      );
    }
  }
}
