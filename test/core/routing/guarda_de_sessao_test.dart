import 'package:bora/core/routing/guarda_de_sessao.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Toda rota do mapa canônico (AD-003) que a guarda precisa classificar.
const _rotasProtegidas = [
  Routes.roles,
  Routes.novoRole,
  '/roles/rafa18/montar',
  '/roles/rafa18/lista',
  '/roles/rafa18/galera',
  '/roles/rafa18/whatsapp',
  '/roles/rafa18/custos',
];

const _rotasLivres = [
  Routes.erro,
  Routes.catalogo,
  '/c/rafa18',
];

void main() {
  group('ENT-15 — sem sessão, rota de festa desvia para entrar', () {
    for (final rota in _rotasProtegidas) {
      test('$rota sem sessão vai para /entrar', () {
        expect(
          guardaDeSessao(rota: rota, temSessao: false),
          Routes.entrar,
          reason: 'sem guarda, no web basta digitar a rota na barra',
        );
      });
    }

    test('/entrar sem sessão fica onde está', () {
      expect(guardaDeSessao(rota: Routes.entrar, temSessao: false), isNull);
    });
  });

  group('ENT-16 — com sessão, /entrar cai na Home', () {
    test('/entrar com sessão vai para /roles', () {
      expect(
        guardaDeSessao(rota: Routes.entrar, temSessao: true),
        Routes.roles,
        reason: 'é o aceite literal de UC-01: pós-login sempre cai na Home',
      );
    });

    for (final rota in _rotasProtegidas) {
      test('$rota com sessão passa direto', () {
        expect(guardaDeSessao(rota: rota, temSessao: true), isNull);
      });
    }
  });

  group('ENT-17 — as rotas livres passam nos dois estados de sessão', () {
    for (final rota in _rotasLivres) {
      test('$rota passa com sessão', () {
        expect(guardaDeSessao(rota: rota, temSessao: true), isNull);
      });

      test('$rota passa sem sessão', () {
        expect(
          guardaDeSessao(rota: rota, temSessao: false),
          isNull,
          reason: 'RN-24: o convidado responde sem baixar nada e sem conta — '
              'barrá-lo mataria o diferencial do produto',
        );
      });
    }

    test('qualquer código de convite passa, não só o da fixture', () {
      expect(guardaDeSessao(rota: '/c/outro-codigo', temSessao: false), isNull);
    });
  });

  group('a guarda discrimina — não devolve sempre a mesma coisa', () {
    test('a mesma rota decide diferente conforme a sessão', () {
      expect(
        guardaDeSessao(rota: Routes.roles, temSessao: false),
        isNot(guardaDeSessao(rota: Routes.roles, temSessao: true)),
        reason: 'anti-vácuo: guarda que ignora a sessão passaria em metade '
            'dos testes acima por acidente',
      );
      expect(
        guardaDeSessao(rota: Routes.entrar, temSessao: false),
        isNot(guardaDeSessao(rota: Routes.entrar, temSessao: true)),
      );
    });

    test('rota desconhecida sem sessão também é barrada', () {
      expect(
        guardaDeSessao(rota: '/rota-que-nao-existe', temSessao: false),
        Routes.entrar,
        reason: 'o default é fechado: rota nova nasce protegida, e quem quiser '
            'abri-la precisa dizer isso em rotasLivres',
      );
    });
  });
}
