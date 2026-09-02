import 'dart:io';

// A porta de entrada da camada é o barrel — este import é, ele mesmo, a
// asserção de que `festas.dart` exporta `NivelDoLink`.
import 'package:bora/core/festas/festas.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../architecture/calculo_isolation_test.dart'
    show importsProibidosEm;

const String _arquivo = 'lib/core/festas/dominio/nivel_do_link.dart';

void main() {
  group('GAL-21 — os três níveis de link de RN-23', () {
    test('são exatamente três, na ordem de RN-23', () {
      expect(
        NivelDoLink.values,
        [
          NivelDoLink.soVer,
          NivelDoLink.editarLista,
          NivelDoLink.coAnfitriao,
        ],
      );
    });

    test('a chave de serialização é literal, e nenhuma é derivada de name', () {
      expect(NivelDoLink.soVer.chave, 'sover');
      expect(NivelDoLink.editarLista.chave, 'editarlista');
      expect(NivelDoLink.coAnfitriao.chave, 'coanfitriao');

      for (final nivel in NivelDoLink.values) {
        expect(
          nivel.chave,
          isNot(nivel.name),
          reason: 'chave é contrato de dado e name é detalhe de linguagem: '
              'derivar uma da outra faria renomear o enum reescrever o que já '
              'está gravado',
        );
      }
    });
  });

  group('GAL-21 — porChave devolve o nível, ou null para o desconhecido', () {
    test('cada uma das três chaves devolve o nível correspondente', () {
      expect(NivelDoLink.porChave('sover'), NivelDoLink.soVer);
      expect(NivelDoLink.porChave('editarlista'), NivelDoLink.editarLista);
      expect(NivelDoLink.porChave('coanfitriao'), NivelDoLink.coAnfitriao);
    });

    test('chave desconhecida devolve null — quem converte decide', () {
      expect(NivelDoLink.porChave('qualquer-coisa'), isNull);
      expect(
        NivelDoLink.porChave('soVer'),
        isNull,
        reason: 'o nome do valor do enum não é chave de serialização',
      );
      expect(NivelDoLink.porChave(''), isNull);
    });
  });

  group('GAL-21 AC6 — dado ausente ou desconhecido resolve por menor '
      'privilégio', () {
    test('resolver(null) devolve SÓ VER', () {
      expect(
        NivelDoLink.resolver(null),
        NivelDoLink.soVer,
        reason: 'A-12: nunca conceder edição por falta de informação',
      );
    });

    test('resolver de chave desconhecida devolve SÓ VER', () {
      expect(NivelDoLink.resolver('qualquer-coisa'), NivelDoLink.soVer);
      expect(
        NivelDoLink.resolver('coAnfitriao'),
        NivelDoLink.soVer,
        reason: 'dado de versão futura ou corrompido não promove ninguém',
      );
    });

    test('resolver das três chaves válidas devolve o nível de cada uma', () {
      expect(NivelDoLink.resolver('sover'), NivelDoLink.soVer);
      expect(NivelDoLink.resolver('editarlista'), NivelDoLink.editarLista);
      expect(NivelDoLink.resolver('coanfitriao'), NivelDoLink.coAnfitriao);
    });
  });

  group('GAL-21 AC6 — festa nova nasce em EDITAR LISTA', () {
    test('padraoDeFestaNova é EDITAR LISTA', () {
      expect(NivelDoLink.padraoDeFestaNova, NivelDoLink.editarLista);
    });

    test('e difere do que resolver devolve para dado ausente', () {
      expect(
        NivelDoLink.padraoDeFestaNova,
        isNot(NivelDoLink.resolver(null)),
        reason: 'default de produto e menor privilégio são situações '
            'diferentes: colapsá-las num default só apagaria a distinção que a '
            'A-12 separou de propósito',
      );
    });
  });

  group('AD-029 — o dado do nível é Dart puro', () {
    test('o arquivo não importa Flutter nem Firebase', () {
      final conteudo = File(_arquivo).readAsStringSync();

      expect(conteudo, isNotEmpty);
      expect(importsProibidosEm(conteudo), isEmpty);
    });
  });
}
