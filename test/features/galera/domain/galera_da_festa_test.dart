import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/domain/galera_da_festa.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../architecture/calculo_isolation_test.dart'
    show importsProibidosEm;
import '../../../fixtures/rn30_estado_inicial_tipado.dart';

const String _arquivo = 'lib/features/galera/domain/galera_da_festa.dart';

Pessoa _pessoa(String nome, StatusDePresenca status) => Pessoa(
      nome: nome,
      papel: PapelNaFesta.convidado,
      status: status,
    );

ComposicaoDaFesta _composicao(List<Pessoa> pessoas) => ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: 4,
      pessoas: pessoas,
    );

GaleraDaFesta _galera({
  String festaId = 'festa-1',
  ConviteDaFesta? convite,
  List<Pessoa>? pessoas,
}) =>
    GaleraDaFesta(
      festaId: festaId,
      convite: convite ?? conviteRn30Tipado,
      composicao: _composicao(pessoas ?? pessoasRn30Tipadas),
    );

void main() {
  group('GAL-09 AC8 — confirmados conta as pessoas nomeadas confirmadas', () {
    test('a festa de RN-30 tem 4 confirmadas — o literal de T-05', () {
      expect(_galera().confirmados, 4);
    });

    test('festa sem pessoa nomeada nenhuma tem 0 confirmadas', () {
      expect(_galera(pessoas: const []).confirmados, 0);
    });

    test(
        'com uma confirmada, uma que recusou e uma pendente, conta só a '
        'confirmada', () {
      final galera = _galera(pessoas: [
        _pessoa('Ana', StatusDePresenca.confirmado),
        _pessoa('Léo', StatusDePresenca.recusou),
        _pessoa('Duda', StatusDePresenca.pendente),
      ]);

      expect(galera.confirmados, 1);
    });

    test(
        'quem recusou aparece em pessoas e não entra em confirmados — o par '
        'que discrimina', () {
      final galera = _galera(pessoas: [
        _pessoa('Ana', StatusDePresenca.confirmado),
        _pessoa('Léo', StatusDePresenca.recusou),
      ]);

      expect(galera.pessoas.map((p) => p.nome), ['Ana', 'Léo']);
      expect(galera.confirmados, 1);
    });
  });

  group('GAL-09 — pessoas sai na ordem do repositório, sem reordenar', () {
    test('a fixture de RN-30 sai como Rafa, Ana, Léo, Bia, Duda', () {
      expect(
        _galera().pessoas.map((p) => p.nome).toList(),
        ['Rafa', 'Ana', 'Léo', 'Bia', 'Duda'],
      );
    });

    test('a ordem invertida da composição sai invertida, não normalizada', () {
      final invertida = pessoasRn30Tipadas.reversed.toList();

      expect(
        _galera(pessoas: invertida).pessoas.map((p) => p.nome).toList(),
        ['Duda', 'Bia', 'Léo', 'Ana', 'Rafa'],
      );
    });
  });

  group('A leitura é valor: igualdade profunda nos dois sentidos', () {
    test('duas leituras de mesmo id, convite e composição são iguais', () {
      expect(_galera(), _galera());
      expect(_galera().hashCode, _galera().hashCode);
    });

    test('trocar só o festaId separa', () {
      expect(_galera(festaId: 'festa-2'), isNot(_galera()));
    });

    test('trocar só o nível do convite separa', () {
      final outro = ConviteDaFesta(
        codigo: conviteRn30Tipado.codigo,
        nivel: NivelDoLink.coAnfitriao,
      );

      expect(_galera(convite: outro), isNot(_galera()));
    });

    test('trocar só a composição separa', () {
      expect(
        _galera(pessoas: [_pessoa('Ana', StatusDePresenca.confirmado)]),
        isNot(_galera()),
      );
    });
  });

  group('GAL-19 AC7 — o modelo de leitura é Dart puro', () {
    test('galera_da_festa.dart não importa Flutter nem Firebase', () {
      expect(
        importsProibidosEm(File(_arquivo).readAsStringSync()),
        isEmpty,
        reason: 'a spec 09 traduz este domínio em security rules — arrastar '
            'UI junto inviabiliza',
      );
    });
  });
}
