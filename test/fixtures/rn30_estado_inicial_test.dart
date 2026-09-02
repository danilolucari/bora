import 'dart:io';

import 'package:bora/core/festas/festas.dart';
import 'package:flutter_test/flutter_test.dart';

import '../architecture/calculo_isolation_test.dart' show importsProibidosEm;
import 'rn30_estado_inicial.dart';

const String _arquivoDaFixture = 'test/fixtures/rn30_estado_inicial.dart';

void main() {
  group('FUND-18 — a fixture reproduz RN-30 literalmente', () {
    test('os campos da festa são o texto literal de RN-30', () {
      expect(festaRn30['nome'], 'CHURRAS DO RAFA 🔥');
      expect(festaRn30['data'], 'SÁB · 18 JUL');
      expect(festaRn30['hora'], '14H');
      expect(festaRn30['local'], 'Laje do Rafa — Vila Madalena');
      expect(festaRn30['duracaoHoras'], 4);
    });

    test('a Home mostra 4 confirmados e 2 pendentes', () {
      expect(festaRn30['confirmadosNaHome'], 4);
      expect(festaRn30['pendentesNaHome'], 2);
    });

    test('são 5 pessoas nomeadas, as personas do arquivo 01 §7', () {
      expect(
        pessoasRn30.map((pessoa) => pessoa['nome']).toList(),
        ['Rafa', 'Ana', 'Léo', 'Bia', 'Duda'],
      );
    });

    test('4 das 5 estão confirmadas', () {
      expect(
        pessoasRn30
            .where((pessoa) => pessoa['status'] == 'confirmado')
            .map((pessoa) => pessoa['nome'])
            .toList(),
        ['Rafa', 'Ana', 'Léo', 'Bia'],
      );
    });

    test('Duda é a quinta: viewer e não confirmada', () {
      final duda = pessoasRn30.firstWhere((pessoa) => pessoa['nome'] == 'Duda');

      expect(duda['papel'], 'viewer');
      expect(duda['status'], 'pendente');
    });

    test('papel, dieta e bebida vêm das personas do arquivo 01 §7', () {
      expect(
        pessoasRn30
            .map((pessoa) => [pessoa['papel'], pessoa['dieta'], pessoa['bebe']])
            .toList(),
        [
          ['host', 'tudo', true],
          ['cohost', 'tudo', true],
          ['guest', 'veggie', true],
          ['guest', 'semporco', false],
          // O arquivo 01 §7 só diz "Duda — só-vê (viewer)": dieta e bebida
          // dela não estão especificadas, então a fixture não as inventa.
          ['viewer', null, null],
        ],
      );
    });

    test('Rafa é o "você" padrão', () {
      expect(
        pessoasRn30
            .where((pessoa) => pessoa['voce'] == true)
            .map((pessoa) => pessoa['nome'])
            .toList(),
        ['Rafa'],
      );
    });

    test('os itens padrão são os sete de RN-30', () {
      expect(itensPadraoRn30, [
        'bovina',
        'frango',
        'pao_de_alho',
        'refrigerante',
        'agua',
        'cerveja',
        'cachaca',
      ]);
    });

    test('os contadores da Home convivem com as 5 pessoas sem reconciliação',
        () {
      final somaDosContadores = (festaRn30['confirmadosNaHome']! as int) +
          (festaRn30['pendentesNaHome']! as int);

      expect(pessoasRn30, hasLength(5));
      expect(
        somaDosContadores,
        isNot(pessoasRn30.length),
        reason: '4 confirmados + 2 pendentes é o texto literal de RN-30 e não '
            'fecha com as 5 pessoas nomeadas — a fixture não reconcilia',
      );
    });
  });

  group('FUND-19 — a fixture é Dart puro e dado bruto', () {
    test('não importa Flutter nem Firebase', () {
      final conteudo = File(_arquivoDaFixture).readAsStringSync();

      expect(conteudo, isNotEmpty);
      expect(
        importsProibidosEm(conteudo),
        isEmpty,
        reason: 'a fixture RN-30 é Dart puro: sem Flutter e sem Firebase',
      );
    });

    test('só contém primitivos — nenhuma entidade de domínio', () {
      final valores = [
        ...festaRn30.values,
        ...pessoasRn30.expand((pessoa) => pessoa.values),
        ...itensPadraoRn30,
      ];

      for (final valor in valores) {
        expect(
          valor,
          anyOf(isA<String>(), isA<int>(), isA<bool>()),
          reason: 'Festa/Pessoa/ItemDeLista são da spec 02 — aqui só '
              'primitivos',
        );
      }
    });
  });

  group('GAL-01 — a festa de RN-30 tem o link do convite', () {
    test('o código é o rafa18 literal de RN-23 e RN-26b', () {
      expect(festaRn30['codigo'], 'rafa18');
    });

    test('a festa está no nível com que toda festa nova nasce', () {
      expect(
        festaRn30['nivelDoLink'],
        NivelDoLink.padraoDeFestaNova.chave,
        reason: 'afirmar contra a constante, e não contra o literal, é o que '
            'faz o teste discordar se o padrão de produto mudar (L-008)',
      );
    });
  });
}
