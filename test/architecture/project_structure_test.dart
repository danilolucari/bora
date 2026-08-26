import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Pastas de `lib/core/` exigidas pela árvore do CLAUDE.md e do `design.md`.
const List<String> _pastasDeCore = [
  'design_system',
  'calculo',
  // AD-019: a sessão mora em core/, não dentro de features/entrar/ — o
  // roteador a consome para a guarda de AD-017, e a spec 04 consome a
  // entidade para o avatar do header.
  'autenticacao',
  'di',
  'routing',
  'observability',
  'firebase',
  'responsive',
];

/// As seis features do CLAUDE.md mais `entrar` e `home` (AD-006).
const List<String> _features = [
  'montar',
  'galera',
  'lista',
  'convite',
  'custos',
  'convidado',
  'entrar',
  'home',
];

/// As três camadas da Clean Architecture dentro de cada feature.
const List<String> _camadas = ['domain', 'data', 'presentation'];

List<String> _ausentes(Iterable<String> caminhos) =>
    caminhos.where((c) => !Directory(c).existsSync()).toList();

void main() {
  group('FUND-04 — a árvore de lib/ existe', () {
    test('lib/core tem design_system, calculo e as pastas de infraestrutura',
        () {
      final esperadas = _pastasDeCore.map((p) => 'lib/core/$p');

      expect(
        _ausentes(esperadas),
        isEmpty,
        reason: 'pasta exigida ausente em lib/core/',
      );
    });

    test('as oito features existem, cada uma com domain, data e presentation',
        () {
      final esperadas = [
        for (final feature in _features)
          for (final camada in _camadas) 'lib/features/$feature/$camada',
      ];

      expect(
        _ausentes(esperadas),
        isEmpty,
        reason: 'camada de feature ausente em lib/features/',
      );
    });
  });

  group('FUND-05 — test/ espelha a estrutura de lib/', () {
    test('cada pasta de lib/core tem espelho em test/core', () {
      final esperadas = _pastasDeCore.map((p) => 'test/core/$p');

      expect(
        _ausentes(esperadas),
        isEmpty,
        reason: 'espelho ausente em test/core/',
      );
    });

    test('cada camada de feature tem espelho em test/features', () {
      final esperadas = [
        for (final feature in _features)
          for (final camada in _camadas) 'test/features/$feature/$camada',
      ];

      expect(
        _ausentes(esperadas),
        isEmpty,
        reason: 'espelho ausente em test/features/',
      );
    });
  });
}
