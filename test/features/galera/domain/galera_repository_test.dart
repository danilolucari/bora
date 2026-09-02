import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/domain/chave_de_pessoa.dart';
import 'package:bora/features/galera/domain/galera_da_festa.dart';
import 'package:bora/features/galera/domain/galera_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../architecture/calculo_isolation_test.dart'
    show importsProibidosEm;

const String _arquivo = 'lib/features/galera/domain/galera_repository.dart';

/// As oito capacidades de escrita que a Galera **não** tem: mexer em resposta
/// de presença e em contador de festa (GAL-09 AC9 · AD-022).
const List<String> _identificadoresProibidos = [
  'StatusDePresenca',
  'status',
  'confirmados',
  'pendentes',
];

/// A fonte sem os comentários de doc — é o **código** que se afirma aqui, não
/// a prosa que o descreve. Sem esta poda, o próprio doc que promete "não toca
/// status" faria a varredura acusar o arquivo que ela protege.
String semDocumentacao(String fonte) => fonte
    .split('\n')
    .where((linha) => !linha.trimLeft().startsWith('///'))
    .join('\n');

final RegExp _assinatura = RegExp(
  r'^\s+\w+(?:<[^>]*>)?\s+(\w+)\(',
  multiLine: true,
);

/// Os nomes dos métodos declarados na fonte, na ordem em que aparecem.
List<String> metodosDeclaradosEm(String fonte) => _assinatura
    .allMatches(semDocumentacao(fonte))
    .map((m) => m.group(1)!)
    .toList();

/// Os identificadores proibidos que aparecem no **código** da fonte.
List<String> proibidosEm(String fonte) {
  final codigo = semDocumentacao(fonte);
  return [
    for (final proibido in _identificadoresProibidos)
      if (codigo.contains(proibido)) proibido,
  ];
}

/// Duplo escrito à mão da porta (**AD-021**). A ausência de qualquer outro
/// método aqui é parte da asserção: a porta é satisfeita com estes cinco.
class _GaleraFake implements GaleraRepository {
  @override
  Stream<GaleraDaFesta?> observarGalera(String festaId) =>
      Stream<GaleraDaFesta?>.value(null);

  @override
  Future<void> alterarDieta(
    String festaId,
    ChaveDePessoa quem,
    Dieta dieta,
  ) async {}

  @override
  Future<void> alterarBebida(
    String festaId,
    ChaveDePessoa quem,
    bool bebe,
  ) async {}

  @override
  Future<void> alterarPapel(
    String festaId,
    ChaveDePessoa quem,
    PapelNaFesta papel,
  ) async {}

  @override
  Future<void> definirNivelDoLink(String festaId, NivelDoLink nivel) async {}
}

void main() {
  group('GAL-09 — a porta declara a leitura e as quatro escritas', () {
    test('uma implementação com os cinco métodos satisfaz a porta', () {
      expect(_GaleraFake(), isA<GaleraRepository>());
    });

    test('observarGalera devolve Stream<GaleraDaFesta?> — null quando não há',
        () async {
      final GaleraRepository porta = _GaleraFake();

      expect(porta.observarGalera('festa-1'), isA<Stream<GaleraDaFesta?>>());
      await expectLater(porta.observarGalera('festa-1'), emits(isNull));
    });

    test('a porta declara exatamente cinco métodos, e são estes', () {
      expect(
        metodosDeclaradosEm(File(_arquivo).readAsStringSync()),
        [
          'observarGalera',
          'alterarDieta',
          'alterarBebida',
          'alterarPapel',
          'definirNivelDoLink',
        ],
      );
    });
  });

  group('GAL-09 AC9 — nenhuma escrita da porta toca status ou contador', () {
    test('o código da porta não menciona status, confirmados nem pendentes',
        () {
      expect(
        proibidosEm(File(_arquivo).readAsStringSync()),
        isEmpty,
        reason: 'contador é dado da festa (AD-022) — a Galera não tem como '
            'escrever um se a porta não oferece o método',
      );
    });

    test('a varredura morde: um sexto método é reportado', () {
      const infrator = '''
abstract class GaleraRepository {
  Stream<GaleraDaFesta?> observarGalera(String festaId);
  Future<void> alterarDieta(String festaId, ChaveDePessoa quem, Dieta dieta);
  Future<void> alterarBebida(String festaId, ChaveDePessoa quem, bool bebe);
  Future<void> alterarPapel(String f, ChaveDePessoa q, PapelNaFesta p);
  Future<void> definirNivelDoLink(String festaId, NivelDoLink nivel);
  Future<void> salvarTudo(String festaId, GaleraDaFesta galera);
}
''';

      expect(metodosDeclaradosEm(infrator), hasLength(6));
      expect(metodosDeclaradosEm(infrator).last, 'salvarTudo');
    });

    test('a varredura morde: uma escrita de status é reportada', () {
      const infrator = '''
abstract class GaleraRepository {
  Future<void> confirmarPresenca(String f, ChaveDePessoa q, StatusDePresenca status);
}
''';

      expect(proibidosEm(infrator), contains('StatusDePresenca'));
      expect(proibidosEm(infrator), contains('status'));
    });

    test('a varredura não confunde prosa com código: o doc não acusa', () {
      const documentado = '''
/// Nunca toca status, confirmados nem pendentes.
abstract class GaleraRepository {
  Future<void> definirNivelDoLink(String festaId, NivelDoLink nivel);
}
''';

      expect(proibidosEm(documentado), isEmpty);
    });
  });

  group('GAL-19 AC7 — a porta é Dart puro', () {
    test('galera_repository.dart não importa Flutter nem Firebase', () {
      expect(
        importsProibidosEm(File(_arquivo).readAsStringSync()),
        isEmpty,
      );
    });
  });
}
