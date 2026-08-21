import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// O espelho de `test/architecture/calculo_isolation_test.dart`, olhando do
/// outro lado da fronteira.
///
/// Aquele teste impede a fórmula de depender do Flutter; este impede a UI de
/// depender da fórmula. A regra do `CLAUDE.md` é "nunca duplique uma fórmula em
/// componente de UI": RN-11 (a posição do marcador na faixa de preço) e RN-13
/// (a formatação `R$ N` inteira) são da spec 02 `calculo`, e os componentes
/// desta spec recebem `double` **já calculado** e `String` **já formatada**.
///
/// Pelo mesmo motivo o design system não conhece Firebase nem BLoC: componente
/// não busca dado e não guarda estado de negócio — quem faz isso é a camada de
/// apresentação de cada feature.
const String _diretorioDoDesignSystem = 'lib/core/design_system';

/// Prefixos de import que quebram a fronteira do design system.
const List<String> _prefixosProibidos = [
  'package:firebase',
  'package:cloud_firestore',
  'package:flutter_bloc',
];

/// Qualquer alvo que mencione a camada de cálculo, relativo
/// (`../../calculo/calculo.dart`) ou por pacote
/// (`package:bora/core/calculo/calculo.dart`). Nenhum arquivo do design system
/// tem motivo legítimo para citá-la.
const String _alvoDeCalculo = 'calculo';

final RegExp _diretivaDeImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

/// Alvos de import proibidos em [conteudoDart].
List<String> importsProibidosEm(String conteudoDart) => _diretivaDeImport
    .allMatches(conteudoDart)
    .map((m) => m.group(1)!)
    .where((alvo) =>
        alvo.contains(_alvoDeCalculo) || _prefixosProibidos.any(alvo.startsWith))
    .toList();

List<File> arquivosDartEm(Directory diretorio) => diretorio
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

/// Uma linha por violação, no formato `<caminho do arquivo>: <import>`.
List<String> violacoesEm(Directory diretorio) => [
      for (final arquivo in arquivosDartEm(diretorio))
        for (final alvo in importsProibidosEm(arquivo.readAsStringSync()))
          '${arquivo.path}: $alvo',
    ];

void main() {
  final designSystem = Directory(_diretorioDoDesignSystem);

  group('DS-34 — o design system não atravessa a fronteira', () {
    test('nenhum arquivo sob lib/core/design_system tem import proibido', () {
      expect(
        violacoesEm(designSystem),
        isEmpty,
        reason: 'componente não calcula nem formata: recebe double pronto e '
            'String pronta, e não conhece Firebase nem BLoC',
      );
    });

    test('a varredura não roda vazia: o diretório existe e tem arquivo .dart',
        () {
      expect(designSystem.existsSync(), isTrue);
      expect(
        arquivosDartEm(designSystem),
        isNotEmpty,
        reason: 'guarda sem alvo passa vacuamente — o falso-verde do risco R-4',
      );
    });

    test('import da camada de cálculo é acusado nomeando o arquivo, e removê-lo '
        'faz passar', () {
      final infrator = File('$_diretorioDoDesignSystem/fronteira_de_teste.dart');
      addTearDown(() {
        if (infrator.existsSync()) infrator.deleteSync();
      });
      infrator.writeAsStringSync("import '../../calculo/calculo.dart';\n");

      final violacoes = violacoesEm(designSystem);
      expect(violacoes, hasLength(1));
      expect(violacoes.single, contains('fronteira_de_teste.dart'));
      expect(violacoes.single, contains('calculo/calculo.dart'));

      infrator.deleteSync();

      expect(violacoesEm(designSystem), isEmpty);
    });

    test('cada alvo da lista proibida é detectado, relativo ou por pacote', () {
      const alvos = [
        '../../calculo/calculo.dart',
        'package:bora/core/calculo/calculo.dart',
        'package:firebase_core/firebase_core.dart',
        'package:cloud_firestore/cloud_firestore.dart',
        'package:flutter_bloc/flutter_bloc.dart',
      ];

      for (final alvo in alvos) {
        expect(
          importsProibidosEm("import '$alvo';"),
          [alvo],
          reason: '$alvo deveria ser proibido no design system',
        );
      }
    });

    test('export proibido também é acusado — o barrel não é rota de fuga', () {
      expect(
        importsProibidosEm("export 'package:bora/core/calculo/calculo.dart';"),
        ['package:bora/core/calculo/calculo.dart'],
        reason: 'reexportar a fórmula pelo barrel a colocaria na UI do mesmo '
            'jeito',
      );
    });

    test('o que o design system pode importar não é acusado', () {
      expect(importsProibidosEm("import 'package:flutter/material.dart';"),
          isEmpty);
      expect(importsProibidosEm("import 'bora_colors.dart';"), isEmpty);
      expect(
        importsProibidosEm("import 'package:go_router/go_router.dart';"),
        isEmpty,
        reason: 'a rota do catálogo é interna ao design system',
      );
    });
  });
}
