import 'package:bora/core/autenticacao/autenticacao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AD-019 — a inicial que o avatar do header mostra', () {
    test('usa a primeira letra do nome, em caixa alta', () {
      const usuario = UsuarioLogado(
        id: 'u1',
        email: 'rafa@bora.app',
        nome: 'rafa',
      );

      expect(usuario.inicial, 'R');
    });

    test('cai no e-mail quando a conta não tem nome', () {
      const usuario = UsuarioLogado(id: 'u1', email: 'ana@bora.app');

      expect(
        usuario.inicial,
        'A',
        reason: 'conta de e-mail/senha nunca tem displayName, e avatar vazio '
            'seria pior que a inicial do e-mail',
      );
    });

    test('cai no e-mail quando o nome vem vazio', () {
      const usuario = UsuarioLogado(
        id: 'u1',
        email: 'leo@bora.app',
        nome: '',
      );

      expect(usuario.inicial, 'L');
    });

    test('não estoura quando nome e e-mail estão vazios', () {
      const usuario = UsuarioLogado(id: 'u1', email: '', nome: '');

      expect(
        usuario.inicial,
        '?',
        reason: 'SPEC_PRECISION_GAP: nenhuma spec define este caso. A função é '
            'total para que a UI não estoure em email[0] — a correção de '
            'verdade é o adaptador nunca produzir e-mail vazio (T5)',
      );
    });
  });

  group('AD-019 — o usuário é valor, porque o stream compara emissões', () {
    test('dois usuários com os mesmos campos são iguais', () {
      const a = UsuarioLogado(id: 'u1', email: 'rafa@bora.app', nome: 'Rafa');
      const b = UsuarioLogado(id: 'u1', email: 'rafa@bora.app', nome: 'Rafa');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('mudar qualquer campo torna os dois diferentes', () {
      const base = UsuarioLogado(id: 'u1', email: 'rafa@bora.app', nome: 'Rafa');

      expect(base == const UsuarioLogado(id: 'u2', email: 'rafa@bora.app', nome: 'Rafa'), isFalse);
      expect(base == const UsuarioLogado(id: 'u1', email: 'outro@bora.app', nome: 'Rafa'), isFalse);
      expect(base == const UsuarioLogado(id: 'u1', email: 'rafa@bora.app', nome: 'Léo'), isFalse);
    });
  });

  group('AD-019 — o vocabulário de falha é fechado', () {
    test('as seis falhas do design existem', () {
      expect(FalhaDeAutenticacao.values, [
        FalhaDeAutenticacao.credencialInvalida,
        FalhaDeAutenticacao.emailEmUso,
        FalhaDeAutenticacao.senhaFraca,
        FalhaDeAutenticacao.semRede,
        FalhaDeAutenticacao.cancelada,
        FalhaDeAutenticacao.indisponivel,
      ]);
    });
  });
}
