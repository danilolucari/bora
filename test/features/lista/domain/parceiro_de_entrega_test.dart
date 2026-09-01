import 'package:bora/features/lista/domain/parceiro_de_entrega.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LIST-22 — os três parceiros de RN-27', () {
    test('vêm na ordem literal de RN-27: iFood, Rappi, Zé', () {
      expect(
        ParceiroDeEntrega.values.map((parceiro) => parceiro.nome).toList(),
        ['iFood Mercado', 'Rappi Turbo', 'Zé Delivery'],
      );
    });

    test('o primeiro declarado é o iFood — o pré-selecionado da A-14', () {
      expect(ParceiroDeEntrega.values.first, ParceiroDeEntrega.ifood);
    });

    test('iFood Mercado chega em 40–60 min com frete 12', () {
      expect(ParceiroDeEntrega.ifood.nome, 'iFood Mercado');
      expect(ParceiroDeEntrega.ifood.eta, '40–60 min');
      expect(ParceiroDeEntrega.ifood.frete, 12);
      expect(ParceiroDeEntrega.ifood.soBebidas, isFalse);
    });

    test('Rappi Turbo chega em 15–30 min com frete 9', () {
      expect(ParceiroDeEntrega.rappi.nome, 'Rappi Turbo');
      expect(ParceiroDeEntrega.rappi.eta, '15–30 min');
      expect(ParceiroDeEntrega.rappi.frete, 9);
      expect(ParceiroDeEntrega.rappi.soBebidas, isFalse);
    });

    test('Zé Delivery chega em 30–45 min, frete 0, e é só bebidas', () {
      expect(ParceiroDeEntrega.ze.nome, 'Zé Delivery');
      expect(ParceiroDeEntrega.ze.eta, '30–45 min');
      expect(ParceiroDeEntrega.ze.frete, 0);
      expect(ParceiroDeEntrega.ze.soBebidas, isTrue);
    });

    test('só o Zé é só-bebidas — a guarda da A-09 não pega os outros dois', () {
      expect(
        ParceiroDeEntrega.values.where((parceiro) => parceiro.soBebidas),
        [ParceiroDeEntrega.ze],
      );
    });

    test('os fretes são números, nunca strings com R\$', () {
      expect(
        ParceiroDeEntrega.values.map((parceiro) => parceiro.frete).toList(),
        [12.0, 9.0, 0.0],
      );
      for (final parceiro in ParceiroDeEntrega.values) {
        expect(parceiro.frete, isA<double>());
      }
    });
  });
}
