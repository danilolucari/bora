import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:flutter_test/flutter_test.dart';

import 'rn30_estado_inicial.dart';
import 'rn30_estado_inicial_tipado.dart';

const String _arquivoTipado = 'test/fixtures/rn30_estado_inicial_tipado.dart';

final RegExp _comentarios = RegExp(r'^\s*//.*$', multiLine: true);

Pessoa _pessoa(String nome) =>
    pessoasRn30Tipadas.firstWhere((pessoa) => pessoa.nome == nome);

Map<String, Object?> _bruta(String nome) =>
    pessoasRn30.firstWhere((pessoa) => pessoa['nome'] == nome);

void main() {
  group('CALC-06 — a festa tipada bate com RN-30 campo a campo', () {
    test('nome, data, hora, local e duração saem do bruto', () {
      expect(festaRn30Tipada.nome, 'CHURRAS DO RAFA 🔥');
      expect(festaRn30Tipada.data, 'SÁB · 18 JUL');
      expect(festaRn30Tipada.hora, '14H');
      expect(festaRn30Tipada.local, 'Laje do Rafa — Vila Madalena');
      expect(festaRn30Tipada.duracaoHoras, 4);

      expect(festaRn30Tipada.nome, festaRn30['nome']);
      expect(festaRn30Tipada.data, festaRn30['data']);
      expect(festaRn30Tipada.hora, festaRn30['hora']);
      expect(festaRn30Tipada.local, festaRn30['local']);
      expect(festaRn30Tipada.duracaoHoras, festaRn30['duracaoHoras']);
    });

    test('a festa do exemplo ainda vai acontecer', () {
      expect(
        festaRn30Tipada.status,
        StatusDaFesta.chegando,
        reason: 'RN-30 não declara status; o default da entidade vale',
      );
    });
  });

  group('CALC-06 — as cinco pessoas nomeadas', () {
    test('são cinco, na ordem do bruto', () {
      expect(
        pessoasRn30Tipadas.map((pessoa) => pessoa.nome).toList(),
        ['Rafa', 'Ana', 'Léo', 'Bia', 'Duda'],
      );
      expect(
        pessoasRn30Tipadas.map((pessoa) => pessoa.nome).toList(),
        pessoasRn30.map((pessoa) => pessoa['nome']).toList(),
      );
    });

    test('os papéis do arquivo 01 §7 viram PapelNaFesta', () {
      expect(
        pessoasRn30Tipadas.map((pessoa) => pessoa.papel).toList(),
        [
          PapelNaFesta.anfitriao,
          PapelNaFesta.coAnfitriao,
          PapelNaFesta.convidado,
          PapelNaFesta.convidado,
          PapelNaFesta.soVe,
        ],
      );
    });

    test('quatro confirmadas e a Duda pendente', () {
      expect(
        pessoasRn30Tipadas.map((pessoa) => pessoa.status).toList(),
        [
          StatusDePresenca.confirmado,
          StatusDePresenca.confirmado,
          StatusDePresenca.confirmado,
          StatusDePresenca.confirmado,
          StatusDePresenca.pendente,
        ],
      );
    });

    test('as dietas declaradas viram Dieta', () {
      expect(_pessoa('Rafa').dieta, Dieta.tudo);
      expect(_pessoa('Ana').dieta, Dieta.tudo);
      expect(_pessoa('Léo').dieta, Dieta.veggie);
      expect(_pessoa('Bia').dieta, Dieta.semPorco);
    });

    test('quem bebe vem do bruto: só a Bia declarou que não bebe', () {
      expect(
        pessoasRn30Tipadas.map((pessoa) => pessoa.bebe).toList(),
        [true, true, true, false, null],
      );
    });

    test('Rafa é o "você", e é o único', () {
      expect(
        pessoasRn30Tipadas
            .where((pessoa) => pessoa.voce)
            .map((pessoa) => pessoa.nome)
            .toList(),
        ['Rafa'],
      );
    });
  });

  group('CALC-06 — a Duda continua sem dieta e sem bebida (A-08)', () {
    test('dieta e bebe chegam null, não um default fabricado', () {
      final duda = _pessoa('Duda');

      expect(duda.dieta, isNull);
      expect(duda.bebe, isNull);
      expect(
        duda.dieta,
        isNot(Dieta.tudo),
        reason: 'o arquivo 01 §7 não diz o que a Duda come; "come de tudo" '
            'seria invenção',
      );
      expect(
        duda.bebe,
        isNot(false),
        reason: 'null não é "não bebe": um false fabricado tiraria a Duda da '
            'conta da cerveja em RN-21',
      );
    });

    test('tipar não fez as chaves aparecerem no dado bruto', () {
      final duda = _bruta('Duda');

      expect(
        duda.containsKey('dieta'),
        isFalse,
        reason: 'a fixture bruta é intocada: a chave continua ausente, não '
            'presente com valor null (R-9)',
      );
      expect(duda.containsKey('bebe'), isFalse);
    });

    test('ausente e desconhecida não se confundem', () {
      expect(
        dietaTipada(null),
        isNull,
        reason: 'ausente ⇒ null: a spec não define',
      );
      expect(
        () => dietaTipada('carnivora'),
        throwsArgumentError,
        reason: 'dieta declarada e não reconhecida vira erro, nunca null — '
            'senão "não declarado" e "não reconhecido" viram a mesma coisa',
      );
    });
  });

  group('CALC-06 — os sete itens padrão', () {
    test('as chaves brutas viram ChaveItem, na ordem de RN-30', () {
      expect(itensPadraoRn30Tipados, [
        ChaveItem.bovina,
        ChaveItem.frango,
        ChaveItem.paoDeAlho,
        ChaveItem.refrigerante,
        ChaveItem.agua,
        ChaveItem.cerveja,
        ChaveItem.cachaca,
      ]);
      expect(itensPadraoRn30Tipados, hasLength(itensPadraoRn30.length));
    });

    test('chave desconhecida quebra em vez de virar item inventado', () {
      expect(
        ChaveItem.porChave('linguica'),
        isNull,
        reason: 'o catálogo não conhece a chave — quem converte decide',
      );
      expect(
        () => itemTipado('linguica'),
        throwsArgumentError,
        reason: 'e a decisão da fixture é falhar alto: um item fabricado '
            'entraria no cálculo com preço-base fabricado',
      );
    });
  });

  group('CALC-06 — derivação, não cópia', () {
    test('o arquivo tipado não repete nenhum literal de RN-30', () {
      final codigo =
          File(_arquivoTipado).readAsStringSync().replaceAll(_comentarios, '');

      final literaisDoBruto = <String>{
        ...festaRn30.values.whereType<String>(),
        ...pessoasRn30.expand((pessoa) => pessoa.values).whereType<String>(),
        ...itensPadraoRn30,
      };

      expect(codigo, isNotEmpty);
      expect(literaisDoBruto, hasLength(greaterThan(10)));
      for (final literal in literaisDoBruto) {
        expect(
          codigo,
          isNot(contains("'$literal'")),
          reason: '"$literal" está escrito no arquivo tipado — seria uma '
              'segunda fonte da verdade, e as duas divergiriam no primeiro '
              'ajuste',
        );
      }
    });

    test('cada pessoa tipada segue a bruta campo a campo', () {
      for (final bruta in pessoasRn30) {
        final tipada = _pessoa(bruta['nome']! as String);

        expect(tipada.papel.chave, bruta['papel']);
        expect(tipada.status.chave, bruta['status']);
        expect(tipada.dieta?.chave, bruta['dieta']);
        expect(tipada.bebe, bruta['bebe']);
        expect(tipada.voce, bruta['voce']);
      }
    });
  });

  group('GAL-01 — o convite tipado deriva do bruto', () {
    test('o código é o do bruto, e é o literal de bora.app/c/rafa18', () {
      expect(conviteRn30Tipado.codigo, 'rafa18');
      expect(conviteRn30Tipado.codigo, festaRn30['codigo']);
    });

    test('o nível é o padrão de festa nova', () {
      expect(
        conviteRn30Tipado.nivel,
        NivelDoLink.padraoDeFestaNova,
        reason: 'contra a constante, não contra a chave: se o padrão de '
            'produto mudar, este teste discorda',
      );
    });

    test('o nível volta a ser exatamente a chave que estava no bruto', () {
      expect(
        conviteRn30Tipado.nivel.chave,
        festaRn30['nivelDoLink'],
        reason: 'derivação, não cópia: tipar não pode reinterpretar o dado',
      );
    });

    test('o convite inteiro é o par que o bruto declara', () {
      expect(
        conviteRn30Tipado,
        ConviteDaFesta(
          codigo: festaRn30['codigo']! as String,
          nivel: NivelDoLink.padraoDeFestaNova,
        ),
      );
    });
  });
}
