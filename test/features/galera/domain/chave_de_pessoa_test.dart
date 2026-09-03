import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/galera/domain/chave_de_pessoa.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../architecture/calculo_isolation_test.dart'
    show importsProibidosEm;

const String _arquivo = 'lib/features/galera/domain/chave_de_pessoa.dart';

Pessoa _pessoa(String nome) => Pessoa(
      nome: nome,
      papel: PapelNaFesta.convidado,
      status: StatusDePresenca.confirmado,
    );

/// Duas homônimas na lista — o caso que força a chave a ter ocorrência.
final List<Pessoa> _comDuasAnas = [
  _pessoa('Ana'),
  _pessoa('Léo'),
  _pessoa('Ana'),
];

void main() {
  group('GAL-10 — as chaves saem na ordem do repositório', () {
    test('duas Anas com um Léo no meio viram Ana#0, Léo#0, Ana#1', () {
      expect(ChaveDePessoa.de(_comDuasAnas), const [
        ChaveDePessoa('Ana', 0),
        ChaveDePessoa('Léo', 0),
        ChaveDePessoa('Ana', 1),
      ]);
    });

    test('lista vazia não produz chave nenhuma', () {
      expect(ChaveDePessoa.de(const []), isEmpty);
    });
  });

  group('GAL-10 — a chave é um valor: nome mais ocorrência', () {
    test('mesmo nome e mesma ocorrência são a mesma chave', () {
      expect(const ChaveDePessoa('Ana', 1), const ChaveDePessoa('Ana', 1));
      expect(
        const ChaveDePessoa('Ana', 1).hashCode,
        const ChaveDePessoa('Ana', 1).hashCode,
      );
    });

    test('mesmo nome com ocorrência diferente são chaves diferentes', () {
      expect(
        const ChaveDePessoa('Ana', 0),
        isNot(const ChaveDePessoa('Ana', 1)),
        reason: 'se o nome bastasse, escrever numa Ana escreveria nas duas',
      );
      expect(
        const ChaveDePessoa('Ana', 0).hashCode,
        isNot(const ChaveDePessoa('Ana', 1).hashCode),
      );
    });

    test('nomes diferentes na mesma ocorrência são chaves diferentes', () {
      expect(
        const ChaveDePessoa('Ana', 0),
        isNot(const ChaveDePessoa('Léo', 0)),
      );
    });
  });

  group('GAL-10 — indiceEm endereça a linha certa', () {
    test('cada uma das duas Anas resolve para o seu próprio índice', () {
      expect(
        ChaveDePessoa.indiceEm(_comDuasAnas, const ChaveDePessoa('Ana', 0)),
        0,
      );
      expect(
        ChaveDePessoa.indiceEm(_comDuasAnas, const ChaveDePessoa('Ana', 1)),
        2,
      );
      expect(
        ChaveDePessoa.indiceEm(_comDuasAnas, const ChaveDePessoa('Léo', 0)),
        1,
      );
    });

    test('nome que não está na lista devolve null', () {
      expect(
        ChaveDePessoa.indiceEm(_comDuasAnas, const ChaveDePessoa('Duda', 0)),
        isNull,
      );
    });

    test('ocorrência que não existe mais devolve null', () {
      expect(
        ChaveDePessoa.indiceEm(
          [_pessoa('Ana'), _pessoa('Léo')],
          const ChaveDePessoa('Ana', 1),
        ),
        isNull,
        reason: 'a segunda Ana sumiu entre abrir o painel e escrever: quem '
            'escreve não grava nada em vez de acertar a linha errada',
      );
    });
  });

  group('GAL-26 — o RSVP acrescenta ao fim e não reendereça ninguém', () {
    test('a chave de cada pessoa anterior continua a mesma', () {
      final antes = ChaveDePessoa.de(_comDuasAnas);
      final depois = ChaveDePessoa.de([..._comDuasAnas, _pessoa('Duda')]);

      expect(depois.take(antes.length), antes);
      expect(depois.last, const ChaveDePessoa('Duda', 0));
    });

    test('e o índice de cada uma continua o mesmo', () {
      final comDuda = [..._comDuasAnas, _pessoa('Duda')];

      for (final chave in ChaveDePessoa.de(_comDuasAnas)) {
        expect(
          ChaveDePessoa.indiceEm(comDuda, chave),
          ChaveDePessoa.indiceEm(_comDuasAnas, chave),
        );
      }
    });
  });

  group('GAL-19 AC7 — a chave é Dart puro', () {
    test('o arquivo não importa Flutter nem Firebase', () {
      final conteudo = File(_arquivo).readAsStringSync();

      expect(conteudo, isNotEmpty);
      expect(importsProibidosEm(conteudo), isEmpty);
    });
  });
}
