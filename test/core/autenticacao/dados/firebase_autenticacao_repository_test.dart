import 'dart:async';

import 'package:bora/core/autenticacao/autenticacao.dart';
import 'package:bora/core/autenticacao/dados/firebase_autenticacao_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/recording_app_logger.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockUserCredential extends Mock implements UserCredential {}

void main() {
  late _MockFirebaseAuth auth;
  late RecordingAppLogger logger;
  late StreamController<User?> mudancas;

  /// Constrói o repositório já com o stream do SDK sob controle do teste.
  FirebaseAutenticacaoRepository criar({User? inicial}) {
    when(() => auth.currentUser).thenReturn(inicial);
    when(auth.authStateChanges).thenAnswer((_) => mudancas.stream);

    return FirebaseAutenticacaoRepository(auth, logger);
  }

  _MockUser usuarioFirebase({
    String uid = 'u1',
    String? email = 'rafa@bora.app',
    String? nome = 'Rafa',
  }) {
    final usuario = _MockUser();
    when(() => usuario.uid).thenReturn(uid);
    when(() => usuario.email).thenReturn(email);
    when(() => usuario.displayName).thenReturn(nome);
    return usuario;
  }

  /// Programa o login por e-mail/senha para [resposta].
  void quandoEntrar({Object? lanca, bool sucesso = false}) {
    final chamada = when(
      () => auth.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );

    if (sucesso) {
      chamada.thenAnswer((_) async => _MockUserCredential());
    } else {
      chamada.thenThrow(lanca!);
    }
  }

  setUp(() {
    auth = _MockFirebaseAuth();
    logger = RecordingAppLogger();
    mudancas = StreamController<User?>.broadcast();
  });

  tearDown(() => mudancas.close());

  group('ENT-06 — a sessão sai do SDK e vira domínio', () {
    test('sem usuário no SDK, não há sessão', () {
      final repositorio = criar();

      expect(repositorio.sessaoAtual, isNull);
      repositorio.dispose();
    });

    test('o usuário do SDK vira UsuarioLogado no snapshot inicial', () {
      final repositorio = criar(inicial: usuarioFirebase());

      expect(
        repositorio.sessaoAtual,
        const UsuarioLogado(id: 'u1', email: 'rafa@bora.app', nome: 'Rafa'),
      );
      repositorio.dispose();
    });

    test('mudança no SDK emite no stream e atualiza o snapshot', () async {
      final repositorio = criar();
      final emitidos = <UsuarioLogado?>[];
      repositorio.mudancasDeSessao.listen(emitidos.add);

      mudancas.add(usuarioFirebase());
      await Future<void>.delayed(Duration.zero);

      expect(emitidos, [
        const UsuarioLogado(id: 'u1', email: 'rafa@bora.app', nome: 'Rafa'),
      ]);
      expect(
        repositorio.sessaoAtual,
        isNotNull,
        reason: 'o roteador acorda pelo stream e lê sessaoAtual: ler o valor '
            'anterior faria a guarda decidir com dado velho',
      );
      repositorio.dispose();
    });

    test('e-mail nulo no SDK não derruba a sessão', () {
      final repositorio = criar(inicial: usuarioFirebase(email: null));

      expect(repositorio.sessaoAtual?.email, '');
      expect(
        repositorio.sessaoAtual?.inicial,
        'R',
        reason: 'cai no displayName — a rede de segurança que T2 deixou',
      );
      repositorio.dispose();
    });

    test('entrar com credencial boa não lança e chama o SDK uma vez', () async {
      final repositorio = criar();
      quandoEntrar(sucesso: true);

      await repositorio.entrarComEmailESenha(
        email: 'rafa@bora.app',
        senha: 'segredo',
      );

      verify(
        () => auth.signInWithEmailAndPassword(
          email: 'rafa@bora.app',
          password: 'segredo',
        ),
      ).called(1);
      expect(logger.erros, isEmpty);
      repositorio.dispose();
    });

    test('criar conta chama o método de cadastro, não o de login', () async {
      final repositorio = criar();
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _MockUserCredential());

      await repositorio.criarConta(email: 'novo@bora.app', senha: 'segredo');

      verify(
        () => auth.createUserWithEmailAndPassword(
          email: 'novo@bora.app',
          password: 'segredo',
        ),
      ).called(1);
      verifyNever(
        () => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
      repositorio.dispose();
    });
  });

  group('ENT-09/ENT-11 — a exceção do SDK não vaza para a tela', () {
    const codigos = {
      'invalid-credential': FalhaDeAutenticacao.credencialInvalida,
      'INVALID_LOGIN_CREDENTIALS': FalhaDeAutenticacao.credencialInvalida,
      'email-already-in-use': FalhaDeAutenticacao.emailEmUso,
      'weak-password': FalhaDeAutenticacao.senhaFraca,
      'network-request-failed': FalhaDeAutenticacao.semRede,
      'coisa-que-ninguem-mapeou': FalhaDeAutenticacao.indisponivel,
    };

    codigos.forEach((codigo, esperada) {
      test('$codigo chega como ${esperada.name}, e não como exceção do SDK',
          () async {
        final repositorio = criar();
        quandoEntrar(lanca: FirebaseAuthException(code: codigo));

        await expectLater(
          repositorio.entrarComEmailESenha(email: 'a@b.c', senha: 'segredo'),
          throwsA(esperada),
        );
        repositorio.dispose();
      });
    });

    test('erro que não é do Firebase também vira falha de domínio', () async {
      final repositorio = criar();
      quandoEntrar(lanca: StateError('Firebase não inicializado'));

      await expectLater(
        repositorio.entrarComEmailESenha(email: 'a@b.c', senha: 'segredo'),
        throwsA(FalhaDeAutenticacao.indisponivel),
      );
      repositorio.dispose();
    });
  });

  group('ENT-12 — nenhuma falha de autenticação é silenciosa', () {
    test('a falha do SDK vai para o AppLogger, com nome próprio', () async {
      final repositorio = criar();
      quandoEntrar(lanca: FirebaseAuthException(code: 'invalid-credential'));

      await expectLater(
        repositorio.entrarComEmailESenha(email: 'a@b.c', senha: 'errada'),
        throwsA(FalhaDeAutenticacao.credencialInvalida),
      );

      expect(logger.erros, hasLength(1));
      expect(
        logger.erros.single.name,
        FirebaseAutenticacaoRepository.nomeDoRegistro,
      );
      repositorio.dispose();
    });

    test('sucesso não registra erro nenhum', () async {
      final repositorio = criar();
      when(auth.signOut).thenAnswer((_) async {});

      await repositorio.sair();

      expect(logger.erros, isEmpty);
      repositorio.dispose();
    });
  });

  group('AD-019 — dispose solta a inscrição no SDK', () {
    test('depois de dispose, mudança no SDK não emite mais', () async {
      final repositorio = criar();
      final emitidos = <UsuarioLogado?>[];
      repositorio.mudancasDeSessao.listen(emitidos.add);

      await repositorio.dispose();
      mudancas.add(usuarioFirebase());
      await Future<void>.delayed(Duration.zero);

      expect(
        emitidos,
        isEmpty,
        reason: 'inscrição vazada contamina o teste seguinte',
      );
    });
  });
}
