import 'package:bora/core/calculo/dominio/contagem_de_pessoas.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher _recusaCampo(String campo) => throwsA(
      isA<ArgumentError>().having((erro) => erro.name, 'campo', campo),
    );

void main() {
  group('CALC-01 — RN-01 conta adultos e pessoas', () {
    test('o estado padrão 3H+3M+1C dá 6 adultos e 7 pessoas', () {
      final contagem =
          ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1);

      expect(contagem.adultos, 6);
      expect(contagem.pessoas, 7);
    });

    test('contagem zerada dá 0 adultos e 0 pessoas', () {
      final contagem = ContagemDePessoas();

      expect(contagem.adultos, 0);
      expect(contagem.pessoas, 0);
    });

    test('só crianças dá 0 adultos, e as crianças contam como pessoas', () {
      final contagem = ContagemDePessoas(criancas: 2);

      expect(contagem.adultos, 0);
      expect(contagem.pessoas, 2);
    });
  });

  group('CALC-01 — contagem negativa é recusada na construção', () {
    test('homens negativo lança ArgumentError nomeando o campo', () {
      expect(() => ContagemDePessoas(homens: -1), _recusaCampo('homens'));
    });

    test('mulheres negativo lança ArgumentError nomeando o campo', () {
      expect(() => ContagemDePessoas(mulheres: -1), _recusaCampo('mulheres'));
    });

    test('criancas negativo lança ArgumentError nomeando o campo', () {
      expect(() => ContagemDePessoas(criancas: -1), _recusaCampo('criancas'));
    });

    test('copyWith com valor negativo também é recusado', () {
      final contagem = ContagemDePessoas(homens: 3);

      expect(() => contagem.copyWith(homens: -1), _recusaCampo('homens'));
    });
  });

  group('CALC-01 — a contagem é um valor', () {
    test('duas contagens com os mesmos campos são iguais', () {
      final uma = ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1);
      final outra = ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1);

      expect(outra, uma);
      expect(outra.hashCode, uma.hashCode);
    });

    test('copyWith devolve uma cópia alterada e não muta a original', () {
      final contagem = ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1);

      final comMaisUmaCrianca = contagem.copyWith(criancas: 2);

      expect(comMaisUmaCrianca.pessoas, 8);
      expect(comMaisUmaCrianca.homens, 3);
      expect(contagem.criancas, 1);
      expect(contagem.pessoas, 7);
    });
  });
}
