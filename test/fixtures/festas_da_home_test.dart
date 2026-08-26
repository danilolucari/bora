import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'festas_da_home.dart';
import 'rn30_estado_inicial.dart';

const String _arquivoDaFixture = 'test/fixtures/festas_da_home.dart';

void main() {
  group('A-04 — a festa que chega é RN-30 lida, nunca redigitada', () {
    test('os contadores da Home vêm do bruto de RN-30', () {
      expect(rn30NaHome.confirmados, festaRn30['confirmadosNaHome']);
      expect(rn30NaHome.pendentes, festaRn30['pendentesNaHome']);
    });

    test('e valem 4 e 2, os números literais de RN-30', () {
      expect(rn30NaHome.confirmados, 4);
      expect(rn30NaHome.pendentes, 2);
    });

    test('a festa é a de RN-30, com o nome literal', () {
      expect(rn30NaHome.festa.nome, 'CHURRAS DO RAFA 🔥');
      expect(rn30NaHome.festa.data, 'SÁB · 18 JUL');
    });

    test('está chegando, não é passada', () {
      expect(rn30NaHome.ehPassada, isFalse);
      expect(rn30NaHome.pessoas, isNull);
      expect(rn30NaHome.total, isNull);
    });

    test('as iniciais são R/A/L, derivadas dos confirmados de RN-30', () {
      expect(rn30NaHome.iniciais, ['R', 'A', 'L']);
    });

    test('a Duda não entra nos avatares — ela é a pendente de RN-30', () {
      expect(
        rn30NaHome.iniciais,
        isNot(contains('D')),
        reason: 'avatar empilhado é de quem confirmou (T-02)',
      );
    });

    test('com 4 confirmados e 3 avatares, sobra "+1"', () {
      expect(rn30NaHome.excedenteDeAvatares(3), 1);
    });
  });

  group('HOME-14 — o ARQUIVO tem as duas festas passadas de UC-24', () {
    test('"Churras da laje · 14 pessoas · R\$ 612" é o literal de UC-24', () {
      final laje = festasPassadas.first;

      expect(laje.festa.nome, 'Churras da laje');
      expect(laje.pessoas, 14);
      expect(laje.total, 612);
    });

    test('as duas festas do arquivo estão concluídas', () {
      expect(festasPassadas, hasLength(2));
      for (final passada in festasPassadas) {
        expect(passada.ehPassada, isTrue);
        expect(passada.festa.status, StatusDaFesta.passada);
      }
    });

    test('festa passada tem pessoas e total; festa que chega, não', () {
      for (final passada in festasPassadas) {
        expect(passada.pessoas, isNotNull);
        expect(passada.total, isNotNull);
      }
    });

    test('festa passada não tem contador de convite', () {
      for (final passada in festasPassadas) {
        expect(passada.confirmados, 0);
        expect(passada.pendentes, 0);
      }
    });
  });

  group('A-05 — o estado inteiro produz "1 festa chegando · 2 passadas"', () {
    test('uma chegando e duas passadas', () {
      expect(festasDaHome.where((f) => !f.ehPassada), hasLength(1));
      expect(festasDaHome.where((f) => f.ehPassada), hasLength(2));
    });

    test('a que está chegando vem primeiro, como T-02 desenha', () {
      expect(festasDaHome.first, rn30NaHome);
    });
  });

  group('L-002 — o que é premissa está declarado como premissa', () {
    test('a segunda festa é marcada como não-literal no próprio arquivo', () {
      final conteudo = File(_arquivoDaFixture).readAsStringSync();

      expect(conteudo, isNotEmpty);
      expect(
        conteudo,
        contains('não é literal de spec'),
        reason: 'sem a marca, a segunda festa vira "literal de UC-24" por '
            'descuido na próxima leitura — foi o L-002 da fundação',
      );
    });

    test('a fixture bruta de RN-30 não ganhou festa passada', () {
      final bruto =
          File('test/fixtures/rn30_estado_inicial.dart').readAsStringSync();

      expect(
        bruto,
        isNot(contains('Churras da laje')),
        reason: 'E-1: o bruto declara "fonte literal: RN-30" e festa passada '
            'não está em RN-30 — o arquivo fica intocado',
      );
    });
  });
}
