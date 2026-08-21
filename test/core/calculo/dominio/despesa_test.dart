import 'package:bora/core/calculo/dominio/despesa.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CALC-18 — a despesa guarda quem adiantou, o quê e quanto (RN-20)',
      () {
    test('os três campos ficam como foram declarados', () {
      const despesa = Despesa(
        quemPagou: 'ANA',
        descricao: 'Cerveja + gelo',
        valor: 120,
      );

      expect(despesa.quemPagou, 'ANA');
      expect(despesa.descricao, 'Cerveja + gelo');
      expect(despesa.valor, closeTo(120, 0.001));
    });

    test('duas despesas iguais campo a campo são iguais e compartilham o '
        'hashCode', () {
      const uma = Despesa(quemPagou: 'ANA', descricao: 'Gelo', valor: 30);
      const outra = Despesa(quemPagou: 'ANA', descricao: 'Gelo', valor: 30);

      expect(uma, outra);
      expect(uma.hashCode, outra.hashCode);
    });

    test('trocar quem pagou quebra a igualdade', () {
      const ana = Despesa(quemPagou: 'ANA', descricao: 'Gelo', valor: 30);
      const leo = Despesa(quemPagou: 'LÉO', descricao: 'Gelo', valor: 30);

      expect(ana, isNot(leo));
    });

    test('trocar a descrição quebra a igualdade', () {
      const gelo = Despesa(quemPagou: 'ANA', descricao: 'Gelo', valor: 30);
      const carvao = Despesa(quemPagou: 'ANA', descricao: 'Carvão', valor: 30);

      expect(gelo, isNot(carvao));
    });

    test('trocar o valor quebra a igualdade', () {
      const trinta = Despesa(quemPagou: 'ANA', descricao: 'Gelo', valor: 30);
      const trintaEUm = Despesa(quemPagou: 'ANA', descricao: 'Gelo', valor: 31);

      expect(trinta, isNot(trintaEUm));
    });
  });
}
