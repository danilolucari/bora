import 'package:bora/core/calculo/dominio/linha_de_acerto.dart';
import 'package:bora/core/calculo/regras/quitacao.dart';
import 'package:flutter_test/flutter_test.dart';

/// As três linhas do Teste A de RN-16, todas pendentes.
List<LinhaDeAcerto> _linhasDoTesteA() => const [
      LinhaDeAcerto(de: 'LÉO', para: 'VOCÊ', valor: 80),
      LinhaDeAcerto(de: 'BIA', para: 'VOCÊ', valor: 40),
      LinhaDeAcerto(de: 'BIA', para: 'ANA', valor: 40),
    ];

void main() {
  group('CALC-23 — o progresso da quitação (RN-18)', () {
    test('nenhuma linha paga deixa a barra em zero', () {
      final progresso = progressoDeQuitacao(_linhasDoTesteA());

      expect(progresso.fracao, closeTo(0, 0.001));
      expect(progresso.pagas, 0);
      expect(progresso.valorPago, closeTo(0, 0.001));
    });

    test('todas pagas enchem a barra', () {
      final linhas = [
        for (final linha in _linhasDoTesteA()) linha.copyWith(paga: true),
      ];

      final progresso = progressoDeQuitacao(linhas);

      expect(progresso.fracao, closeTo(1, 0.001));
      expect(progresso.pagas, 3);
      expect(progresso.valorPago, closeTo(160, 0.001));
    });

    test('o progresso é de dinheiro, não de contagem: 1 linha de 3 pode ser '
        'metade da barra', () {
      final linhas = _linhasDoTesteA();
      final progresso = progressoDeQuitacao([
        linhas[0].copyWith(paga: true),
        linhas[1],
        linhas[2],
      ]);

      expect(
        progresso.fracao,
        closeTo(0.5, 0.001),
        reason: 'a linha de R\$ 80 é metade dos R\$ 160 devidos',
      );
      expect(
        progresso.fracao,
        isNot(closeTo(1 / 3, 0.001)),
        reason: 'contar linhas em vez de somar valores daria 33%',
      );
      expect(progresso.pagas, 1);
      expect(progresso.total, 3);
    });

    test('N de M: as pagas e o total saem certos', () {
      final linhas = _linhasDoTesteA();
      final progresso = progressoDeQuitacao([
        linhas[0].copyWith(paga: true),
        linhas[1].copyWith(paga: true),
        linhas[2],
      ]);

      expect(progresso.pagas, 2);
      expect(progresso.total, 3);
    });

    test('o valor devido soma todas as linhas, pagas e pendentes', () {
      final linhas = _linhasDoTesteA();
      final progresso = progressoDeQuitacao([
        linhas[0].copyWith(paga: true),
        linhas[1],
        linhas[2],
      ]);

      expect(
        progresso.valorDevido,
        closeTo(160, 0.001),
        reason: '80 + 40 + 40 — quitar não tira a linha do denominador',
      );
      expect(progresso.valorPago, closeTo(80, 0.001));
    });
  });

  group('CALC-23 — a alternância PENDENTE ⇄ PAGO é reversível (RN-18)', () {
    test('desmarcar uma linha devolve o progresso de antes', () {
      final linhas = _linhasDoTesteA();

      final antes = progressoDeQuitacao(linhas);
      final depoisDeMarcar = progressoDeQuitacao([
        linhas[0].copyWith(paga: true),
        linhas[1],
        linhas[2],
      ]);
      final depoisDeDesmarcar = progressoDeQuitacao([
        linhas[0].copyWith(paga: true).copyWith(paga: false),
        linhas[1],
        linhas[2],
      ]);

      expect(depoisDeMarcar.fracao, closeTo(0.5, 0.001));
      expect(depoisDeDesmarcar.fracao, closeTo(antes.fracao, 0.001));
      expect(depoisDeDesmarcar.pagas, 0);
      expect(depoisDeDesmarcar.valorPago, closeTo(0, 0.001));
    });
  });

  group('CALC-23 — sem nenhuma linha, o acerto está vazio (A-16)', () {
    test('a barra fica cheia, com 0 de 0', () {
      final progresso = progressoDeQuitacao(const []);

      expect(
        progresso.fracao,
        1.0,
        reason: 'zero linhas é zero pendências; 0.0 é a alternativa '
            'defensável, e trocar é uma linha em quitacao.dart',
      );
      expect(progresso.pagas, 0);
      expect(progresso.total, 0);
      expect(progresso.valorDevido, closeTo(0, 0.001));
      expect(progresso.fracao.isNaN, isFalse);
    });
  });
}
