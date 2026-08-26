import 'package:bora/features/entrar/domain/validacao_de_credenciais.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ENT-08 — validação de e-mail', () {
    test('e-mail bom passa', () {
      expect(validarEmail('rafa@bora.app'), isNull);
    });

    test('campo em branco é vazio, não formato', () {
      expect(validarEmail(''), ErroDeEmail.vazio);
      expect(
        validarEmail('   '),
        ErroDeEmail.vazio,
        reason: 'só espaço é campo em branco, não e-mail malformado — a '
            'mensagem que o usuário merece é outra',
      );
    });

    for (final ruim in ['rafa', 'rafa@', '@bora.app', 'rafa@bora', 'a@b@c.d']) {
      test('"$ruim" é erro de formato', () {
        expect(validarEmail(ruim), ErroDeEmail.formato);
      });
    }

    test('espaço no meio não passa', () {
      expect(validarEmail('ra fa@bora.app'), ErroDeEmail.formato);
    });

    test('domínio começando ou terminando em ponto não passa', () {
      expect(validarEmail('rafa@.app'), ErroDeEmail.formato);
      expect(validarEmail('rafa@bora.'), ErroDeEmail.formato);
    });
  });

  group('ENT-08 — espaço nas pontas é acidente, não erro', () {
    test('e-mail com espaço nas pontas é aceito', () {
      expect(
        validarEmail('  rafa@bora.app  '),
        isNull,
        reason: 'edge case da spec: aparar antes de validar e de enviar',
      );
    });

    test('emailNormalizado devolve o e-mail sem as pontas', () {
      expect(emailNormalizado('  rafa@bora.app  '), 'rafa@bora.app');
    });
  });

  group('ENT-08 — validação de senha, com a fronteira dos dois lados', () {
    test('senha em branco é vazia, não curta', () {
      expect(validarSenha(''), ErroDeSenha.vazia);
    });

    test('cinco caracteres é curta', () {
      expect(validarSenha('12345'), ErroDeSenha.curta);
    });

    test('seis caracteres passa — a fronteira é inclusiva', () {
      expect(
        validarSenha('123456'),
        isNull,
        reason: 'A-08: seis é o mínimo que o próprio Firebase Auth impõe; '
            'recusar aqui negaria conta que o backend criaria',
      );
      expect(minimoDeSenha, 6);
    });

    test('senha longa passa', () {
      expect(validarSenha('uma senha bem comprida'), isNull);
    });

    test('espaço não é aparado da senha', () {
      expect(
        validarSenha('  a  '),
        ErroDeSenha.curta,
        reason: 'espaço pode ser parte legítima da senha; apará-lo impediria '
            'o usuário de entrar com a senha que ele cadastrou',
      );
    });
  });
}
