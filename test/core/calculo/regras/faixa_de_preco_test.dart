import 'package:bora/core/calculo/dominio/corredor.dart';
import 'package:bora/core/calculo/dominio/preco_de_mercado.dart';
import 'package:bora/core/calculo/dominio/tabela_de_precos_de_mercado.dart';
import 'package:bora/core/calculo/regras/faixa_de_preco.dart';
import 'package:flutter_test/flutter_test.dart';

/// Uma linha qualquer da tabela, com a faixa que o teste precisa.
PrecoDeMercado _faixa({
  required double media,
  required double minimo,
  required double maximo,
}) =>
    PrecoDeMercado(
      nome: 'Item de teste',
      emoji: '🧪',
      corredor: Corredor.mercearia,
      rotuloDeQuantidade: '1 un',
      media: media,
      minimo: minimo,
      maximo: maximo,
      fontes: 2,
    );

PrecoDeMercado _linha(String nome) =>
    tabelaDePrecosDeMercado.firstWhere((preco) => preco.nome == nome);

void main() {
  group('CALC-25 — a posição do marcador (RN-11)', () {
    test('a picanha (65, 54, 83) fica em 11/29 ≈ 0,379', () {
      expect(posicaoDoMarcador(_linha('Picanha bovina')), closeTo(11 / 29, 1e-9));
      expect(posicaoDoMarcador(_linha('Picanha bovina')), closeTo(0.379, 0.001));
    });

    test('média igual ao mín põe o marcador na origem', () {
      expect(posicaoDoMarcador(_faixa(media: 54, minimo: 54, maximo: 83)), 0.0);
    });

    test('média igual ao máx põe o marcador no fim', () {
      expect(posicaoDoMarcador(_faixa(media: 83, minimo: 54, maximo: 83)), 1.0);
    });

    test('máx igual ao mín devolve 0.0 em vez de dividir por zero (A-15)', () {
      final posicao =
          posicaoDoMarcador(_faixa(media: 40, minimo: 40, maximo: 40));

      expect(posicao, 0.0);
      expect(posicao.isNaN, isFalse, reason: '0/0 daria NaN na barra');
      expect(posicao.isFinite, isTrue);
    });

    test('média acima do máx trava em 1.0', () {
      expect(posicaoDoMarcador(_faixa(media: 120, minimo: 54, maximo: 83)), 1.0);
    });

    test('média abaixo do mín trava em 0.0', () {
      expect(posicaoDoMarcador(_faixa(media: 10, minimo: 54, maximo: 83)), 0.0);
    });

    test('toda linha de RN-11 cai dentro de [0,1]', () {
      for (final preco in tabelaDePrecosDeMercado) {
        final posicao = posicaoDoMarcador(preco);

        expect(posicao, inInclusiveRange(0, 1), reason: preco.nome);
      }
    });
  });

  group('CALC-25 — o total e a faixa do rodapé (RN-11)', () {
    test('a tabela inteira soma média 286', () {
      expect(totalDeMercado(tabelaDePrecosDeMercado).media, closeTo(286, 1e-9));
    });

    test('a faixa real vai de 234 a 356', () {
      final total = totalDeMercado(tabelaDePrecosDeMercado);

      expect(total.minimo, closeTo(234, 1e-9));
      expect(total.maximo, closeTo(356, 1e-9));
    });

    test('cada total soma a própria coluna, sem trocar uma pela outra', () {
      final total = totalDeMercado([
        _faixa(media: 10, minimo: 6, maximo: 15),
        _faixa(media: 20, minimo: 12, maximo: 25),
      ]);

      expect(total.media, closeTo(30, 1e-9));
      expect(total.minimo, closeTo(18, 1e-9));
      expect(total.maximo, closeTo(40, 1e-9));
    });
  });
}
