import 'package:bora/core/autenticacao/autenticacao.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_autenticacao_repository.dart';

void main() {
  late FakeAutenticacaoRepository repositorio;

  setUp(() => repositorio = FakeAutenticacaoRepository());
  tearDown(() => repositorio.dispose());

  group('o duplo sustenta a suíte, então ele próprio precisa estar certo', () {
    test('nasce sem sessão, ou com a que recebeu', () {
      expect(repositorio.sessaoAtual, isNull);

      final logado = FakeAutenticacaoRepository(
        sessaoInicial: FakeAutenticacaoRepository.usuarioPadrao,
      );
      expect(logado.sessaoAtual, FakeAutenticacaoRepository.usuarioPadrao);
      logado.dispose();
    });

    test('autenticar emite no stream e atualiza o snapshot na mesma transição',
        () async {
      final emitidos = <UsuarioLogado?>[];
      repositorio.mudancasDeSessao.listen(emitidos.add);

      await repositorio.entrarComEmailESenha(
        email: 'rafa@bora.app',
        senha: 'segredo',
      );
      await Future<void>.delayed(Duration.zero);

      expect(emitidos, [FakeAutenticacaoRepository.usuarioPadrao]);
      expect(
        repositorio.sessaoAtual,
        FakeAutenticacaoRepository.usuarioPadrao,
        reason: 'o roteador acorda pelo stream e lê sessaoAtual: ler o valor '
            'anterior faria a guarda decidir com dado velho',
      );
    });

    test('os três caminhos de autenticação produzem a mesma sessão', () async {
      final google = FakeAutenticacaoRepository();
      final cadastro = FakeAutenticacaoRepository();

      await google.entrarComGoogle();
      await cadastro.criarConta(email: 'novo@bora.app', senha: 'segredo');

      expect(google.sessaoAtual, FakeAutenticacaoRepository.usuarioPadrao);
      expect(cadastro.sessaoAtual, FakeAutenticacaoRepository.usuarioPadrao);

      google.dispose();
      cadastro.dispose();
    });

    test('a falha programada é lançada e a sessão não muda', () async {
      repositorio.falha = FalhaDeAutenticacao.credencialInvalida;

      await expectLater(
        repositorio.entrarComEmailESenha(
          email: 'rafa@bora.app',
          senha: 'errada',
        ),
        throwsA(FalhaDeAutenticacao.credencialInvalida),
      );
      expect(repositorio.sessaoAtual, isNull);
    });

    test('registra cada chamada, em ordem', () async {
      await repositorio.entrarComGoogle();
      await repositorio.sair();

      expect(repositorio.chamadas, ['entrarComGoogle', 'sair']);
    });

    test('sair derruba a sessão e emite null', () async {
      final emitidos = <UsuarioLogado?>[];
      await repositorio.entrarComGoogle();
      repositorio.mudancasDeSessao.listen(emitidos.add);

      await repositorio.sair();
      await Future<void>.delayed(Duration.zero);

      expect(emitidos, [null]);
      expect(repositorio.sessaoAtual, isNull);
    });

    test('mudarSessao simula a sessão expirando por fora do app', () async {
      await repositorio.entrarComGoogle();

      repositorio.mudarSessao(null);

      expect(repositorio.sessaoAtual, isNull);
      expect(
        repositorio.chamadas,
        ['entrarComGoogle'],
        reason: 'expirar não é o app chamando sair()',
      );
    });
  });
}
