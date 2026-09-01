import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/montar/domain/secao_da_montagem.dart';
import 'package:flutter_test/flutter_test.dart';

const String _diretorioDoDominio = 'lib/features/montar/domain';

/// O que `montar/domain` **não** pode conhecer: é Dart puro, como
/// `core/calculo` (CLAUDE.md §Arquitetura). Widget e bloc vêm depois, em
/// `presentation/`.
const List<String> _prefixosProibidos = [
  'package:flutter/',
  'package:flutter_bloc/',
  'package:firebase',
  'dart:ui',
];

final RegExp _diretivaDeImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

List<File> _arquivosDartEm(String caminho) => Directory(caminho)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

/// Uma linha por violação, no formato `<arquivo>: <import>` — é o que nomeia
/// o arquivo infrator quando a suíte quebra.
List<String> _importsDeFlutter(String diretorio) => [
      for (final arquivo in _arquivosDartEm(diretorio))
        for (final alvo in _diretivaDeImport
            .allMatches(arquivo.readAsStringSync())
            .map((m) => m.group(1)!))
          if (_prefixosProibidos.any(alvo.startsWith)) '${arquivo.path}: $alvo',
    ];

/// A seção literal de **cada um** dos 16 itens da calculadora, escrita à mão a
/// partir de T-03/W-03, A-06 e A-08 — nunca derivada de `secaoDe`.
///
/// É o que faz um item novo em `ChaveItem` quebrar a suíte: sem entrada aqui,
/// o item some da tela em silêncio.
const Map<ChaveItem, SecaoDaMontagem?> _secaoEsperada = {
  ChaveItem.bovina: SecaoDaMontagem.naGrelha,
  ChaveItem.suina: SecaoDaMontagem.naGrelha,
  ChaveItem.frango: SecaoDaMontagem.naGrelha,
  ChaveItem.legumesParaGrelha: SecaoDaMontagem.naGrelha,
  ChaveItem.paoDeAlho: SecaoDaMontagem.naGeladeira,
  ChaveItem.refrigerante: SecaoDaMontagem.naGeladeira,
  ChaveItem.suco: SecaoDaMontagem.naGeladeira,
  ChaveItem.agua: SecaoDaMontagem.naGeladeira,
  ChaveItem.cerveja: SecaoDaMontagem.naGeladeira,
  ChaveItem.vodka: SecaoDaMontagem.prosFortes,
  ChaveItem.cachaca: SecaoDaMontagem.prosFortes,
  ChaveItem.whisky: SecaoDaMontagem.prosFortes,
  ChaveItem.carvao: null,
  ChaveItem.gelo: null,
  ChaveItem.salGrosso: null,
  ChaveItem.coposEPratos: null,
};

void main() {
  group('MONT-01 — os 11 chips do formulário, na ordem de T-03/W-03', () {
    test('são exatamente 3 + 5 + 3 = 11 chips', () {
      final todos = [
        for (final chips in chipsPorSecao.values) ...chips,
      ];

      expect(todos, hasLength(11));
    });

    test('NA GRELHA tem BOVINA, SUÍNA, FRANGO nessa ordem', () {
      expect(chipsPorSecao[SecaoDaMontagem.naGrelha], [
        ChaveItem.bovina,
        ChaveItem.suina,
        ChaveItem.frango,
      ]);
    });

    test('NA GELADEIRA tem os cinco de T-03 nessa ordem', () {
      expect(chipsPorSecao[SecaoDaMontagem.naGeladeira], [
        ChaveItem.paoDeAlho,
        ChaveItem.refrigerante,
        ChaveItem.suco,
        ChaveItem.agua,
        ChaveItem.cerveja,
      ]);
    });

    test('AD-018: PROS FORTES existe com vodka, cachaça e whisky', () {
      expect(chipsPorSecao[SecaoDaMontagem.prosFortes], [
        ChaveItem.vodka,
        ChaveItem.cachaca,
        ChaveItem.whisky,
      ]);
    });

    test('as três seções são declaradas, e só elas', () {
      expect(chipsPorSecao.keys, SecaoDaMontagem.values);
    });

    test('nenhum chip aparece em duas seções', () {
      final todos = [
        for (final chips in chipsPorSecao.values) ...chips,
      ];

      expect(todos.toSet(), hasLength(todos.length));
    });

    test('A-07: os chips seguem a ordem de ordemCanonicaDaLista', () {
      final todos = [
        for (final chips in chipsPorSecao.values) ...chips,
      ];
      final posicoes = [
        for (final chave in todos) ordemCanonicaDaLista.indexOf(chave),
      ];

      expect(posicoes, isNot(contains(-1)));
      expect(posicoes, orderedEquals(List.of(posicoes)..sort()));
    });

    test('nenhum essencial de RN-10 e nenhum kit veggie vira chip', () {
      final todos = [
        for (final chips in chipsPorSecao.values) ...chips,
      ];

      expect(todos, isNot(contains(ChaveItem.carvao)));
      expect(todos, isNot(contains(ChaveItem.gelo)));
      expect(todos, isNot(contains(ChaveItem.salGrosso)));
      expect(todos, isNot(contains(ChaveItem.coposEPratos)));
      expect(todos, isNot(contains(ChaveItem.legumesParaGrelha)));
    });
  });

  group('secaoDe — a mesma declaração serve formulário e lista viva', () {
    test('A-08: o kit veggie cai em NA GRELHA sem ter chip', () {
      expect(secaoDe(ChaveItem.legumesParaGrelha), SecaoDaMontagem.naGrelha);
      expect(
        chipsPorSecao[SecaoDaMontagem.naGrelha],
        isNot(contains(ChaveItem.legumesParaGrelha)),
        reason: 'A-08: entra sozinho por RN-21, sem controle no formulário',
      );
    });

    test('A-06: os quatro essenciais de RN-10 não têm seção', () {
      expect(secaoDe(ChaveItem.carvao), isNull);
      expect(secaoDe(ChaveItem.gelo), isNull);
      expect(secaoDe(ChaveItem.salGrosso), isNull);
      expect(secaoDe(ChaveItem.coposEPratos), isNull);
    });

    test('todo chip resolve para a seção em que ele está declarado', () {
      for (final entrada in chipsPorSecao.entries) {
        for (final chave in entrada.value) {
          expect(
            secaoDe(chave),
            entrada.key,
            reason: '$chave está em ${entrada.key} no formulário e teria de '
                'cair na mesma categoria da lista viva (A-07)',
          );
        }
      }
    });

    test('todo valor de ChaveItem tem resultado declarado', () {
      expect(
        _secaoEsperada.keys.toSet(),
        ChaveItem.values.toSet(),
        reason: 'item novo no enum quebra a suíte em vez de sumir da tela',
      );

      for (final chave in ChaveItem.values) {
        expect(secaoDe(chave), _secaoEsperada[chave], reason: '$chave');
      }
    });
  });

  group('montar/domain é Dart puro', () {
    test('a varredura não roda vazia: o diretório existe e tem arquivo .dart',
        () {
      expect(_arquivosDartEm(_diretorioDoDominio), isNotEmpty);
    });

    test('nenhum arquivo de montar/domain importa Flutter, bloc ou Firebase',
        () {
      expect(_importsDeFlutter(_diretorioDoDominio), isEmpty);
    });

    test('a varredura acusa o import proibido nomeando o arquivo infrator', () {
      final infrator = File('$_diretorioDoDominio/infrator_de_teste.dart');
      addTearDown(() {
        if (infrator.existsSync()) infrator.deleteSync();
      });
      infrator.writeAsStringSync(
        "import 'package:flutter/material.dart';\n"
        "import 'dart:ui';\n"
        "import 'package:firebase_core/firebase_core.dart';\n"
        // O barrel de `core/calculo` é o import legítimo da camada — se fosse
        // acusado, o domínio não poderia falar em `ChaveItem`.
        "import '../../../core/calculo/calculo.dart';\n",
      );

      final violacoes = _importsDeFlutter(_diretorioDoDominio);

      expect(violacoes, hasLength(3));
      expect(
        violacoes.every((v) => v.contains('infrator_de_teste.dart')),
        isTrue,
      );
      expect(violacoes[0], contains('package:flutter/material.dart'));
      expect(violacoes[1], contains('dart:ui'));
      expect(
        violacoes[2],
        contains('package:firebase_core/firebase_core.dart'),
      );
    });
  });
}
