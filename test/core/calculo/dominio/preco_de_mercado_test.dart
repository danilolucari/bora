import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/corredor.dart';
import 'package:bora/core/calculo/dominio/preco_de_mercado.dart';
import 'package:flutter_test/flutter_test.dart';

/// `const` no teste é a prova de que o construtor é `const`.
const PrecoDeMercado _picanha = PrecoDeMercado(
  nome: 'Picanha bovina',
  emoji: '🥩',
  corredor: Corredor.acougue,
  rotuloDeQuantidade: '1,2 kg',
  media: 65,
  minimo: 55,
  maximo: 78,
  fontes: 4,
  chave: ChaveItem.bovina,
);

void main() {
  group('CALC-05 — PrecoDeMercado é um valor, não uma identidade', () {
    test('duas linhas com os mesmos campos são iguais', () {
      const outra = PrecoDeMercado(
        nome: 'Picanha bovina',
        emoji: '🥩',
        corredor: Corredor.acougue,
        rotuloDeQuantidade: '1,2 kg',
        media: 65,
        minimo: 55,
        maximo: 78,
        fontes: 4,
        chave: ChaveItem.bovina,
      );

      expect(outra, _picanha);
      expect(outra.hashCode, _picanha.hashCode);
    });

    test('mudar a média torna as linhas diferentes', () {
      const maisCara = PrecoDeMercado(
        nome: 'Picanha bovina',
        emoji: '🥩',
        corredor: Corredor.acougue,
        rotuloDeQuantidade: '1,2 kg',
        media: 70,
        minimo: 55,
        maximo: 78,
        fontes: 4,
        chave: ChaveItem.bovina,
      );

      expect(maisCara, isNot(_picanha));
    });

    test('a linha sem chave não é igual à que tem chave', () {
      const semChave = PrecoDeMercado(
        nome: 'Picanha bovina',
        emoji: '🥩',
        corredor: Corredor.acougue,
        rotuloDeQuantidade: '1,2 kg',
        media: 65,
        minimo: 55,
        maximo: 78,
        fontes: 4,
      );

      expect(semChave.chave, isNull);
      expect(
        semChave,
        isNot(_picanha),
        reason: 'a 🌭 Linguiça toscana de RN-11 não tem chip em T-03, e essa '
            'ausência é dado, não detalhe (R-6)',
      );
    });
  });
}
