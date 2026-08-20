import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _diretorioDoCalculo = 'lib/core/calculo';

/// Prefixos de import que quebram o contrato "Dart puro" de `core/calculo/`.
const List<String> _prefixosProibidos = [
  'package:flutter/',
  'dart:ui',
  'package:firebase',
  'package:cloud_firestore',
  'package:flutter_bloc',
];

final RegExp _diretivaDeImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

/// Alvos de import proibidos encontrados em [conteudoDart].
List<String> importsProibidosEm(String conteudoDart) => _diretivaDeImport
    .allMatches(conteudoDart)
    .map((m) => m.group(1)!)
    .where((alvo) => _prefixosProibidos.any(alvo.startsWith))
    .toList();

List<File> arquivosDartEm(Directory diretorio) => diretorio
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

/// Uma linha por violação, no formato `<caminho do arquivo>: <import>` — é o
/// que nomeia o arquivo infrator quando a suíte quebra.
List<String> violacoesEm(Directory diretorio) => [
      for (final arquivo in arquivosDartEm(diretorio))
        for (final alvo in importsProibidosEm(arquivo.readAsStringSync()))
          '${arquivo.path}: $alvo',
    ];

void main() {
  group('FUND-06 — core/calculo é Dart puro', () {
    test('nenhum arquivo sob lib/core/calculo tem import proibido', () {
      expect(
        violacoesEm(Directory(_diretorioDoCalculo)),
        isEmpty,
        reason: 'import proibido em core/calculo — a fórmula não pode '
            'depender de Flutter nem de Firebase',
      );
    });

    test('a varredura não roda vazia: o diretório existe e tem arquivo .dart',
        () {
      final diretorio = Directory(_diretorioDoCalculo);

      expect(diretorio.existsSync(), isTrue);
      expect(arquivosDartEm(diretorio), isNotEmpty);
    });

    test('import proibido sob lib/core/calculo é reportado nomeando o arquivo',
        () {
      final infrator = File('$_diretorioDoCalculo/infrator_de_teste.dart');
      addTearDown(() {
        if (infrator.existsSync()) infrator.deleteSync();
      });
      infrator.writeAsStringSync("import 'package:flutter/material.dart';\n");

      final violacoes = violacoesEm(Directory(_diretorioDoCalculo));

      expect(violacoes, hasLength(1));
      expect(violacoes.single, contains('infrator_de_teste.dart'));
      expect(violacoes.single, contains('package:flutter/material.dart'));
    });

    test('cada import da lista proibida é detectado', () {
      const alvos = [
        'package:flutter/material.dart',
        'dart:ui',
        'package:firebase_core/firebase_core.dart',
        'package:cloud_firestore/cloud_firestore.dart',
        'package:flutter_bloc/flutter_bloc.dart',
      ];

      for (final alvo in alvos) {
        expect(
          importsProibidosEm("import '$alvo';"),
          [alvo],
          reason: '$alvo deveria ser proibido em core/calculo',
        );
      }
    });

    test('import permitido de Dart puro não é acusado', () {
      expect(importsProibidosEm("import 'dart:math';"), isEmpty);
      expect(importsProibidosEm("import 'package:meta/meta.dart';"), isEmpty);
    });
  });
}
