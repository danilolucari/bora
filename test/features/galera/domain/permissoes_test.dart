import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/domain/permissoes.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../architecture/calculo_isolation_test.dart'
    show importsProibidosEm;

const String _arquivo = 'lib/features/galera/domain/permissoes.dart';

const Pessoa _rafa = Pessoa(
  nome: 'Rafa',
  papel: PapelNaFesta.anfitriao,
  status: StatusDePresenca.confirmado,
  voce: true,
);
const Pessoa _ana = Pessoa(
  nome: 'Ana',
  papel: PapelNaFesta.coAnfitriao,
  status: StatusDePresenca.confirmado,
);
const Pessoa _duda = Pessoa(
  nome: 'Duda',
  papel: PapelNaFesta.soVe,
  status: StatusDePresenca.pendente,
);

void main() {
  // As 32 células de RN-22, uma por teste, com o valor escrito à mão. Um laço
  // sobre a tabela compararia o domínio consigo mesmo e passaria com ela
  // inteira errada.
  group('GAL-19 AC1 — a linha de RN-22 do ANFITRIÃO, célula a célula', () {
    test('ANFITRIÃO pode ver a festa', () {
      expect(
        pode(PapelNaFesta.anfitriao, Capacidade.verAFesta),
        isTrue,
      );
    });
    test('ANFITRIÃO pode confirmar presença', () {
      expect(
        pode(PapelNaFesta.anfitriao, Capacidade.confirmarPresenca),
        isTrue,
      );
    });
    test('ANFITRIÃO pode marcar o que leva', () {
      expect(
        pode(PapelNaFesta.anfitriao, Capacidade.marcarOQueLeva),
        isTrue,
      );
    });
    test('ANFITRIÃO pode ajustar a lista', () {
      expect(
        pode(PapelNaFesta.anfitriao, Capacidade.ajustarALista),
        isTrue,
      );
    });
    test('ANFITRIÃO pode editar tudo', () {
      expect(
        pode(PapelNaFesta.anfitriao, Capacidade.editarTudo),
        isTrue,
      );
    });
    test('ANFITRIÃO pode cobrar a galera', () {
      expect(
        pode(PapelNaFesta.anfitriao, Capacidade.cobrarAGalera),
        isTrue,
      );
    });
    test('ANFITRIÃO pode gerenciar papéis', () {
      expect(
        pode(PapelNaFesta.anfitriao, Capacidade.gerenciarPapeis),
        isTrue,
      );
    });
    test('ANFITRIÃO pode configurar o nível do link', () {
      expect(
        pode(PapelNaFesta.anfitriao, Capacidade.configurarNivelDoLink),
        isTrue,
      );
    });
  });

  group('GAL-19 AC2 — a linha de RN-22 do CO-ANFITRIÃO, célula a célula', () {
    test('CO-ANFITRIÃO pode ver a festa', () {
      expect(
        pode(PapelNaFesta.coAnfitriao, Capacidade.verAFesta),
        isTrue,
      );
    });
    test('CO-ANFITRIÃO pode confirmar presença', () {
      expect(
        pode(PapelNaFesta.coAnfitriao, Capacidade.confirmarPresenca),
        isTrue,
      );
    });
    test('CO-ANFITRIÃO pode marcar o que leva', () {
      expect(
        pode(PapelNaFesta.coAnfitriao, Capacidade.marcarOQueLeva),
        isTrue,
      );
    });
    test('CO-ANFITRIÃO pode ajustar a lista', () {
      expect(
        pode(PapelNaFesta.coAnfitriao, Capacidade.ajustarALista),
        isTrue,
      );
    });
    test('CO-ANFITRIÃO pode editar tudo', () {
      expect(
        pode(PapelNaFesta.coAnfitriao, Capacidade.editarTudo),
        isTrue,
      );
    });
    test('CO-ANFITRIÃO pode cobrar a galera', () {
      expect(
        pode(PapelNaFesta.coAnfitriao, Capacidade.cobrarAGalera),
        isTrue,
      );
    });
    test('CO-ANFITRIÃO não pode gerenciar papéis', () {
      expect(
        pode(PapelNaFesta.coAnfitriao, Capacidade.gerenciarPapeis),
        isFalse,
      );
    });
    test('CO-ANFITRIÃO não pode configurar o nível do link', () {
      expect(
        pode(PapelNaFesta.coAnfitriao, Capacidade.configurarNivelDoLink),
        isFalse,
      );
    });
  });

  group('GAL-19 AC3 — a linha de RN-22 do CONVIDADO, célula a célula', () {
    test('CONVIDADO pode ver a festa', () {
      expect(
        pode(PapelNaFesta.convidado, Capacidade.verAFesta),
        isTrue,
      );
    });
    test('CONVIDADO pode confirmar presença', () {
      expect(
        pode(PapelNaFesta.convidado, Capacidade.confirmarPresenca),
        isTrue,
      );
    });
    test('CONVIDADO pode marcar o que leva', () {
      expect(
        pode(PapelNaFesta.convidado, Capacidade.marcarOQueLeva),
        isTrue,
      );
    });
    test('CONVIDADO pode ajustar a lista', () {
      expect(
        pode(PapelNaFesta.convidado, Capacidade.ajustarALista),
        isTrue,
      );
    });
    test('CONVIDADO não pode editar tudo', () {
      expect(
        pode(PapelNaFesta.convidado, Capacidade.editarTudo),
        isFalse,
      );
    });
    test('CONVIDADO não pode cobrar a galera', () {
      expect(
        pode(PapelNaFesta.convidado, Capacidade.cobrarAGalera),
        isFalse,
      );
    });
    test('CONVIDADO não pode gerenciar papéis', () {
      expect(
        pode(PapelNaFesta.convidado, Capacidade.gerenciarPapeis),
        isFalse,
      );
    });
    test('CONVIDADO não pode configurar o nível do link', () {
      expect(
        pode(PapelNaFesta.convidado, Capacidade.configurarNivelDoLink),
        isFalse,
      );
    });
  });

  group('GAL-19 AC4 — a linha de RN-22 do SÓ VÊ, célula a célula', () {
    test('SÓ VÊ pode ver a festa', () {
      expect(
        pode(PapelNaFesta.soVe, Capacidade.verAFesta),
        isTrue,
      );
    });
    test('SÓ VÊ pode confirmar presença', () {
      expect(
        pode(PapelNaFesta.soVe, Capacidade.confirmarPresenca),
        isTrue,
      );
    });
    test('SÓ VÊ não pode marcar o que leva', () {
      expect(
        pode(PapelNaFesta.soVe, Capacidade.marcarOQueLeva),
        isFalse,
      );
    });
    test('SÓ VÊ não pode ajustar a lista', () {
      expect(
        pode(PapelNaFesta.soVe, Capacidade.ajustarALista),
        isFalse,
      );
    });
    test('SÓ VÊ não pode editar tudo', () {
      expect(
        pode(PapelNaFesta.soVe, Capacidade.editarTudo),
        isFalse,
      );
    });
    test('SÓ VÊ não pode cobrar a galera', () {
      expect(
        pode(PapelNaFesta.soVe, Capacidade.cobrarAGalera),
        isFalse,
      );
    });
    test('SÓ VÊ não pode gerenciar papéis', () {
      expect(
        pode(PapelNaFesta.soVe, Capacidade.gerenciarPapeis),
        isFalse,
      );
    });
    test('SÓ VÊ não pode configurar o nível do link', () {
      expect(
        pode(PapelNaFesta.soVe, Capacidade.configurarNivelDoLink),
        isFalse,
      );
    });
  });

  group('GAL-19 — o tamanho de cada linha, e o que separa o dono do '
      'co-anfitrião', () {
    test('ANFITRIÃO tem as oito capacidades', () {
      expect(capacidadesDe(PapelNaFesta.anfitriao), hasLength(8));
      expect(
        capacidadesDe(PapelNaFesta.anfitriao),
        Capacidade.values.toSet(),
      );
    });

    test('CO-ANFITRIÃO tem seis', () {
      expect(capacidadesDe(PapelNaFesta.coAnfitriao), hasLength(6));
    });

    test('CONVIDADO tem quatro', () {
      expect(capacidadesDe(PapelNaFesta.convidado), hasLength(4));
    });

    test('SÓ VÊ tem duas', () {
      expect(capacidadesDe(PapelNaFesta.soVe), hasLength(2));
    });

    test('as duas exclusivas do anfitrião são gerenciar papéis e configurar o '
        'nível do link', () {
      expect(
        capacidadesDe(PapelNaFesta.anfitriao)
            .difference(capacidadesDe(PapelNaFesta.coAnfitriao)),
        {Capacidade.gerenciarPapeis, Capacidade.configurarNivelDoLink},
        reason: 'A-19: é a diferença que RN-22 deixou implícita e que os '
            'atores de UC-12 e UC-13 fixam',
      );
    });

    test('o conjunto devolvido é imutável — quem consulta não reescreve '
        'RN-22', () {
      final capacidades = capacidadesDe(PapelNaFesta.soVe);

      expect(
        () => capacidades.add(Capacidade.cobrarAGalera),
        throwsUnsupportedError,
      );
      expect(capacidadesDe(PapelNaFesta.soVe), hasLength(2));
    });
  });

  group('GAL-20 AC5 — o nível do link traduzido em papel', () {
    test('SÓ VER entra como SÓ VÊ', () {
      expect(papelDoNivel(NivelDoLink.soVer), PapelNaFesta.soVe);
    });

    test('EDITAR LISTA entra como CONVIDADO', () {
      expect(papelDoNivel(NivelDoLink.editarLista), PapelNaFesta.convidado);
    });

    test('CO-ANFITRIÃO entra como CO-ANFITRIÃO', () {
      expect(papelDoNivel(NivelDoLink.coAnfitriao), PapelNaFesta.coAnfitriao);
    });

    test('nenhum nível entrega o papel de anfitrião', () {
      for (final nivel in NivelDoLink.values) {
        expect(
          papelDoNivel(nivel),
          isNot(PapelNaFesta.anfitriao),
          reason: 'RN-22: ANFITRIÃO é fixo, 1 — nenhum link promove a dono',
        );
      }
    });
  });

  group('papelDoUsuario — quem está usando o app', () {
    test('devolve o papel de quem está marcado "você"', () {
      expect(papelDoUsuario(const [_rafa, _ana, _duda]),
          PapelNaFesta.anfitriao);
      expect(
        papelDoUsuario([
          _rafa.copyWith(voce: false),
          _ana.copyWith(voce: true),
          _duda,
        ]),
        PapelNaFesta.coAnfitriao,
      );
    });

    test('sem ninguém marcado devolve anfitrião — premissa P-1', () {
      expect(
        papelDoUsuario(const [_ana, _duda]),
        PapelNaFesta.anfitriao,
        reason: 'a rota está atrás da guarda de sessão e é a área do dono do '
            'rolê; GAL-24 AC2 exige o card do link funcional numa festa nova',
      );
    });

    test('lista vazia devolve anfitrião — a festa recém-criada', () {
      expect(papelDoUsuario(const []), PapelNaFesta.anfitriao);
    });
  });

  group('GAL-19 AC7 — a tabela é Dart puro', () {
    test('o arquivo não importa Flutter nem Firebase', () {
      final conteudo = File(_arquivo).readAsStringSync();

      expect(conteudo, isNotEmpty);
      expect(
        importsProibidosEm(conteudo),
        isEmpty,
        reason: 'a spec 09 traduz esta tabela em security rules: arrastar UI '
            'junto tornaria isso impossível',
      );
    });
  });
}
