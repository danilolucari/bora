import 'dart:io';

import 'package:bora/core/autenticacao/autenticacao.dart';
import 'package:bora/core/autenticacao/dados/falha_de_codigo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ENT-09 — credencial errada, nas quatro formas que o backend usa', () {
    const formas = {
      'invalid-credential': 'a forma canônica desde a proteção contra '
          'enumeração de e-mail (default desde set/2023)',
      'INVALID_LOGIN_CREDENTIALS': 'a forma que o EMULADOR devolve — é contra '
          'ele que a AD-016 manda desenvolver',
      'wrong-password': 'projeto com a proteção desligada ainda devolve',
      'user-not-found': 'idem',
    };

    formas.forEach((codigo, porque) {
      test('$codigo vira credencialInvalida', () {
        expect(
          falhaDeCodigo(codigo),
          FalhaDeAutenticacao.credencialInvalida,
          reason: porque,
        );
      });
    });
  });

  group('ENT-09/ENT-11 — cada código documentado tem o seu destino', () {
    const tabela = {
      'email-already-in-use': FalhaDeAutenticacao.emailEmUso,
      'weak-password': FalhaDeAutenticacao.senhaFraca,
      'network-request-failed': FalhaDeAutenticacao.semRede,
    };

    tabela.forEach((codigo, esperada) {
      test('$codigo vira ${esperada.name}', () {
        expect(falhaDeCodigo(codigo), esperada);
      });
    });
  });

  group('ENT-11 — o ramo default é a degradação de AD-004', () {
    for (final codigo in ['too-many-requests', 'invalid-email', 'coisa-nova', '']) {
      test('${codigo.isEmpty ? '(string vazia)' : codigo} vira indisponivel',
          () {
        expect(
          falhaDeCodigo(codigo),
          FalhaDeAutenticacao.indisponivel,
          reason: 'código desconhecido não pode virar credencialInvalida: '
              'diria ao usuário que a senha está errada quando o problema é '
              'outro',
        );
      });
    }
  });

  test('o mapeamento é Dart puro — não importa o SDK', () {
    final fonte = File('lib/core/autenticacao/dados/falha_de_codigo.dart')
        .readAsLinesSync();
    final imports =
        fonte.where((linha) => linha.trimLeft().startsWith('import ')).toList();

    expect(
      imports.where((linha) => linha.contains('firebase')),
      isEmpty,
      reason: 'a tabela é a única parte ramificada do adaptador; mantê-la sem '
          'SDK é o que a torna afirmável sem emulador. O doc CITA o SDK de '
          'propósito, para registrar de onde os códigos saíram — por isso a '
          'asserção olha os imports, e não o texto do arquivo',
    );
    expect(
      imports,
      isNotEmpty,
      reason: 'anti-vácuo: varredura que não acha import nenhum passaria à toa',
    );
  });
}
