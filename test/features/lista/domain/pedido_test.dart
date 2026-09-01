import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/lista/domain/parceiro_de_entrega.dart';
import 'package:bora/features/lista/domain/pedido.dart';
import 'package:flutter_test/flutter_test.dart';

ItemDeLista _item(ChaveItem chave, {double preco = 10}) => ItemDeLista(
      chave: chave,
      nome: chave.name,
      emoji: '🧪',
      unidade: UnidadeDeItem.unidade,
      quantidadeAutomatica: 1,
      precoBase: preco,
    );

Pedido _pedido({
  ParceiroDeEntrega parceiro = ParceiroDeEntrega.ifood,
  String endereco = 'Laje do Rafa — Vila Madalena',
  List<ItemDeLista>? itens,
  double subtotal = 271,
  double frete = 12,
  double total = 283,
}) =>
    Pedido(
      parceiro: parceiro,
      endereco: endereco,
      itens: itens ?? [_item(ChaveItem.bovina)],
      subtotal: subtotal,
      frete: frete,
      total: total,
    );

void main() {
  group('LIST-22 — o pedido que a porta transporta', () {
    test('guarda parceiro, endereço, itens, subtotal, frete e total', () {
      final pedido = _pedido();

      expect(pedido.parceiro, ParceiroDeEntrega.ifood);
      expect(pedido.endereco, 'Laje do Rafa — Vila Madalena');
      expect(pedido.itens, [_item(ChaveItem.bovina)]);
      expect(pedido.subtotal, 271);
      expect(pedido.frete, 12);
      expect(pedido.total, 283);
    });

    test('não calcula: o total é campo, e não subtotal + frete', () {
      expect(_pedido(subtotal: 271, frete: 12, total: 999).total, 999);
    });

    test('dois pedidos com os mesmos campos são iguais, itens inclusive', () {
      expect(_pedido(), _pedido());
      expect(_pedido().hashCode, _pedido().hashCode);
    });

    test('listas de itens diferentes tornam os pedidos diferentes', () {
      expect(
        _pedido(itens: [_item(ChaveItem.bovina)]),
        isNot(_pedido(itens: [_item(ChaveItem.frango)])),
      );
    });

    test('um total diferente torna os pedidos diferentes', () {
      expect(_pedido(total: 283), isNot(_pedido(total: 280)));
    });

    test('parceiro, endereço, subtotal e frete entram na igualdade', () {
      expect(_pedido(), isNot(_pedido(parceiro: ParceiroDeEntrega.rappi)));
      expect(_pedido(), isNot(_pedido(endereco: 'Outro lugar')));
      expect(_pedido(), isNot(_pedido(subtotal: 270)));
      expect(_pedido(), isNot(_pedido(frete: 9)));
    });
  });
}
