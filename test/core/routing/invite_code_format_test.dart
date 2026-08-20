import 'package:bora/core/routing/invite_code_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FUND-09 — forma do código de convite', () {
    test('o código do link de RN-24 é bem formado', () {
      expect(isWellFormedInviteCode('rafa18'), isTrue);
    });

    test('letra, dígito, sublinhado e hífen são aceitos', () {
      expect(isWellFormedInviteCode('Rafa_18-B'), isTrue);
    });

    test('código ausente não é bem formado', () {
      expect(isWellFormedInviteCode(null), isFalse);
    });

    test('código vazio não é bem formado', () {
      expect(isWellFormedInviteCode(''), isFalse);
    });

    test('caractere inesperado não é bem formado', () {
      expect(isWellFormedInviteCode('@@@'), isFalse);
      expect(isWellFormedInviteCode('rafa 18'), isFalse);
      expect(isWellFormedInviteCode('rafa/18'), isFalse);
    });

    test('64 caracteres ainda é bem formado', () {
      expect(isWellFormedInviteCode('a' * 64), isTrue);
    });

    test('65 caracteres já é tamanho absurdo', () {
      expect(isWellFormedInviteCode('a' * 65), isFalse);
    });
  });
}
