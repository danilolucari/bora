import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../observability/app_logger.dart';
import '../dominio/autenticacao_repository.dart';
import '../dominio/falha_de_autenticacao.dart';
import '../dominio/usuario_logado.dart';
import 'falha_de_codigo.dart';
import 'metodo_de_google.dart';

/// A [AutenticacaoRepository] sobre o `firebase_auth` — **o único arquivo do
/// projeto que importa o SDK** fora do bootstrap e do injector (AD-019).
///
/// A ramificação de verdade não mora aqui: ela está em [falhaDeCodigo], que é
/// Dart puro. O que este arquivo faz é plumbing — chamar o SDK, capturar a
/// exceção, traduzir, registrar. Por isso o teste dele mira o **catch**: uma
/// `FirebaseAuthException` vazando para a UI seria o defeito, não um código
/// mal mapeado.
class FirebaseAutenticacaoRepository implements AutenticacaoRepository {
  /// Posicional, e não nomeado, porque `prefer_initializing_formals` pede
  /// `this._campo` e Dart proíbe parâmetro nomeado começando com underscore.
  /// Dois argumentos de tipos distintos não ficam ambíguos.
  FirebaseAutenticacaoRepository(this._auth, this._logger, {bool? isWeb})
      : _isWeb = isWeb ?? kIsWeb {
    _sessao = _usuarioDe(_auth.currentUser);
    _inscricao = _auth.authStateChanges().listen((usuario) {
      _sessao = _usuarioDe(usuario);
      _controlador.add(_sessao);
    });
  }

  /// Nome com que a falha de autenticação é registrada (AD-005).
  static const String nomeDoRegistro = 'autenticacao';

  final FirebaseAuth _auth;
  final AppLogger _logger;

  /// Injetável só para o teste alcançar os dois ramos de [metodoDeGooglePara];
  /// em produção é sempre `kIsWeb`.
  final bool _isWeb;
  final _controlador = StreamController<UsuarioLogado?>.broadcast();

  StreamSubscription<User?>? _inscricao;
  UsuarioLogado? _sessao;

  @override
  UsuarioLogado? get sessaoAtual => _sessao;

  @override
  Stream<UsuarioLogado?> get mudancasDeSessao => _controlador.stream;

  @override
  Future<void> entrarComEmailESenha({
    required String email,
    required String senha,
  }) =>
      _traduzindoFalha(
        () => _auth.signInWithEmailAndPassword(email: email, password: senha),
      );

  @override
  Future<void> criarConta({required String email, required String senha}) =>
      _traduzindoFalha(
        () => _auth.createUserWithEmailAndPassword(
          email: email,
          password: senha,
        ),
      );

  @override
  Future<void> entrarComGoogle() => _traduzindoFalha(() async {
        final provedor = GoogleAuthProvider();

        switch (metodoDeGooglePara(isWeb: _isWeb)) {
          case MetodoDeGoogle.popup:
            await _auth.signInWithPopup(provedor);
          case MetodoDeGoogle.provider:
            await _auth.signInWithProvider(provedor);
        }
      });

  @override
  Future<void> sair() => _traduzindoFalha(_auth.signOut);

  @override
  Future<void> dispose() async {
    await _inscricao?.cancel();
    _inscricao = null;
    await _controlador.close();
  }

  /// Executa [acao] e devolve toda falha no vocabulário de domínio.
  ///
  /// O `catch` é largo de propósito: qualquer coisa que o SDK lance — inclusive
  /// o `StateError` de Firebase não inicializado, que a AD-004 trata como
  /// degradação — vira [FalhaDeAutenticacao], nunca sobe crua para a tela.
  Future<void> _traduzindoFalha(Future<void> Function() acao) async {
    try {
      await acao();
    } on FirebaseAuthException catch (erro, pilha) {
      _logger.logError(erro, pilha, name: nomeDoRegistro);
      throw falhaDeCodigo(erro.code);
    } catch (erro, pilha) {
      _logger.logError(erro, pilha, name: nomeDoRegistro);
      throw FalhaDeAutenticacao.indisponivel;
    }
  }
}

/// Traduz o `User` do SDK para a entidade de domínio.
///
/// `User.email` é **anulável** no Firebase, e [UsuarioLogado.email] não é —
/// o gap que T2 registrou. Nossos dois provedores (e-mail/senha e Google)
/// sempre entregam e-mail, então o `?? ''` é caminho morto na prática; ele
/// existe para que um provedor futuro sem e-mail não derrube a sessão. A rede
/// de segurança é [UsuarioLogado.inicial], que é total.
UsuarioLogado? _usuarioDe(User? usuario) => usuario == null
    ? null
    : UsuarioLogado(
        id: usuario.uid,
        email: usuario.email ?? '',
        nome: usuario.displayName,
      );
