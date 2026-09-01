import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/lista/data/pedido_falso.dart';
import 'package:bora/features/lista/domain/parceiro_de_entrega.dart';
import 'package:bora/features/lista/domain/pedido.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pedido_falso_de_teste.dart';

const String _arquivoDoAdaptador = 'lib/features/lista/data/pedido_falso.dart';
const String _arquivoDaPorta =
    'lib/features/lista/domain/pedido_repository.dart';

/// Um import de rede ou de plataforma no código do adaptador.
///
/// Testada contra um trecho sintético infrator logo abaixo: varredura verde
/// contra código limpo não prova que morde.
final RegExp _importDeRede = RegExp(
  r'''import\s+'(package:http|package:firebase|package:cloud_firestore|dart:io)''',
);

/// Uma declaração de método dentro da porta abstrata.
final RegExp _metodoDaPorta = RegExp(r'^  [\w<>,?\s]+ (\w+)\(', multiLine: true);

/// A fonte de [caminho] sem comentários — o que a varredura de fato inspeciona.
String _fonteSemComentarios(String caminho) =>
    File(caminho).readAsStringSync().replaceAll(RegExp('//.*'), '');

ItemDeLista _item(ChaveItem chave) => ItemDeLista(
      chave: chave,
      nome: chave.name,
      emoji: '🧪',
      unidade: UnidadeDeItem.unidade,
      quantidadeAutomatica: 1,
      precoBase: 10,
    );

Pedido _pedido() => Pedido(
      parceiro: ParceiroDeEntrega.ifood,
      endereco: 'Laje do Rafa — Vila Madalena',
      itens: [_item(ChaveItem.bovina)],
      subtotal: 271,
      frete: 12,
      total: 283,
    );

void main() {
  group('LIST-28 — a porta de pedido da AD-024', () {
    test('a porta declara `enviar` como único método', () {
      final nomes = _metodoDaPorta
          .allMatches(_fonteSemComentarios(_arquivoDaPorta))
          .map((achado) => achado.group(1))
          .toList();

      expect(nomes, ['enviar']);
    });
  });

  group('LIST-28 — o adaptador falso do MVP', () {
    test('devolve o pedido confirmado — é ele que alimenta o overlay', () async {
      final confirmado = await const PedidoFalso().enviar(_pedido());

      expect(confirmado, _pedido());
      expect(confirmado.parceiro, ParceiroDeEntrega.ifood);
      expect(confirmado.endereco, 'Laje do Rafa — Vila Madalena');
      expect(confirmado.total, 283);
    });

    test('não faz rede: sem import de http, Firebase ou dart:io', () {
      expect(
        _importDeRede.allMatches(_fonteSemComentarios(_arquivoDoAdaptador)),
        isEmpty,
      );
    });

    test('a varredura morde um trecho sintético infrator', () {
      expect(_importDeRede.hasMatch("import 'package:http/http.dart';"), isTrue);
      expect(_importDeRede.hasMatch("import 'dart:io';"), isTrue);
      expect(
        _importDeRede.hasMatch("import 'package:firebase_core/firebase_core.dart';"),
        isTrue,
      );
      expect(_importDeRede.hasMatch("import '../domain/pedido.dart';"), isFalse);
    });
  });

  group('LIST-32 — o duplo escrito à mão da porta', () {
    test('registra o que foi enviado, na ordem, e devolve o pedido', () async {
      final porta = PedidoFalsoDeTeste();

      final confirmado = await porta.enviar(_pedido());

      expect(porta.enviados, [_pedido()]);
      expect(confirmado, _pedido());
    });

    test('em modo de falha, propaga a exceção em vez de confirmar', () async {
      final porta = PedidoFalsoDeTeste(erroAoEnviar: StateError('sem parceiro'));

      await expectLater(
        porta.enviar(_pedido()),
        throwsA(isA<StateError>()),
      );
    });
  });
}
