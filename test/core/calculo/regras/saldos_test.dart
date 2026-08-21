import 'package:bora/core/calculo/dominio/saldo_de_pessoa.dart';
import 'package:bora/core/calculo/regras/saldos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CALC-20 — saldo é contribuição menos cota (RN-15)', () {
    test('os saldos do Teste A: +120, +40, −80, −80', () {
      final saldos = calcularSaldos(
        contribuicoes: const {'VOCÊ': 200, 'ANA': 120, 'LÉO': 0, 'BIA': 0},
        total: 320,
        adultos: 4,
      );

      expect(saldos.map((s) => s.pessoa).toList(),
          ['VOCÊ', 'ANA', 'LÉO', 'BIA']);
      expect(saldos[0].saldo, closeTo(120, 0.001));
      expect(saldos[1].saldo, closeTo(40, 0.001));
      expect(saldos[2].saldo, closeTo(-80, 0.001));
      expect(saldos[3].saldo, closeTo(-80, 0.001));
      expect(
        saldos.every((s) => (s.cota - 80).abs() < 0.001),
        isTrue,
        reason: 'a cota é a mesma para todo mundo: 320 ÷ 4 adultos',
      );
    });

    test('os saldos do Teste B: +105, +25, −35, −95', () {
      final saldos = calcularSaldos(
        contribuicoes: const {'RAFA': 200, 'ANA': 120, 'LÉO': 60, 'BIA': 0},
        total: 380,
        adultos: 4,
      );

      expect(saldos.map((s) => s.pessoa).toList(),
          ['RAFA', 'ANA', 'LÉO', 'BIA']);
      expect(saldos[0].saldo, closeTo(105, 0.001));
      expect(saldos[1].saldo, closeTo(25, 0.001));
      expect(saldos[2].saldo, closeTo(-35, 0.001));
      expect(saldos[3].saldo, closeTo(-95, 0.001));
    });

    test('a contribuição de cada um é preservada ao lado do saldo', () {
      final saldos = calcularSaldos(
        contribuicoes: const {'RAFA': 200, 'BIA': 0},
        total: 380,
        adultos: 4,
      );

      expect(saldos[0].contribuicao, closeTo(200, 0.001));
      expect(saldos[1].contribuicao, closeTo(0, 0.001));
    });

    test('a cota vem dos adultos da festa, não do tamanho do mapa (RN-14)',
        () {
      final saldos = calcularSaldos(
        contribuicoes: const {'VOCÊ': 200, 'ANA': 120},
        total: 320,
        adultos: 4,
      );

      expect(
        saldos[0].cota,
        closeTo(80, 0.001),
        reason: 'dividir pelos 2 nomes do mapa daria 160 e quebraria RN-14 — '
            'os outros adultos e as crianças não somem da conta',
      );
      expect(saldos[0].saldo, closeTo(120, 0.001));
    });

    test('sem adulto nenhum o saldo é a própria contribuição, sem NaN', () {
      final saldos = calcularSaldos(
        contribuicoes: const {'VOCÊ': 200},
        total: 320,
        adultos: 0,
      );

      expect(saldos[0].cota, 0.0);
      expect(saldos[0].saldo, closeTo(200, 0.001));
    });

    test('a ordem da lista é a ordem de entrada das contribuições (A-14)', () {
      final saldos = calcularSaldos(
        contribuicoes: const {'BIA': 0, 'LÉO': 60, 'ANA': 120, 'RAFA': 200},
        total: 380,
        adultos: 4,
      );

      expect(
        saldos.map((s) => s.pessoa).toList(),
        ['BIA', 'LÉO', 'ANA', 'RAFA'],
        reason: 'ordenar por saldo aqui mudaria as linhas de RN-16',
      );
    });
  });

  group('CALC-20 — a tag RECEBE / PAGA / NO ZERO (RN-15)', () {
    test('saldo positivo recebe', () {
      const saldo = SaldoDePessoa(
        pessoa: 'VOCÊ',
        contribuicao: 200,
        cota: 80,
        saldo: 120,
      );

      expect(saldo.situacao, SituacaoDeSaldo.recebe);
    });

    test('saldo negativo paga', () {
      const saldo = SaldoDePessoa(
        pessoa: 'LÉO',
        contribuicao: 0,
        cota: 80,
        saldo: -80,
      );

      expect(saldo.situacao, SituacaoDeSaldo.paga);
    });

    test('saldo zero está no zero', () {
      const saldo = SaldoDePessoa(
        pessoa: 'ANA',
        contribuicao: 80,
        cota: 80,
        saldo: 0,
      );

      expect(saldo.situacao, SituacaoDeSaldo.noZero);
    });

    test('resíduo de meio centavo conta como no zero, dos dois lados', () {
      const sobrando = SaldoDePessoa(
        pessoa: 'ANA',
        contribuicao: 80.005,
        cota: 80,
        saldo: 0.005,
      );
      const faltando = SaldoDePessoa(
        pessoa: 'BIA',
        contribuicao: 79.995,
        cota: 80,
        saldo: -0.005,
      );

      expect(sobrando.situacao, SituacaoDeSaldo.noZero);
      expect(faltando.situacao, SituacaoDeSaldo.noZero);
    });

    test('meio real já é saldo de verdade — a tolerância é de um centavo', () {
      const saldo = SaldoDePessoa(
        pessoa: 'ANA',
        contribuicao: 80.5,
        cota: 80,
        saldo: 0.5,
      );

      expect(saldo.situacao, SituacaoDeSaldo.recebe);
    });
  });

  group('CALC-20 — o saldo é um valor imutável comparável', () {
    test('dois saldos iguais campo a campo são iguais e compartilham o '
        'hashCode', () {
      const um = SaldoDePessoa(
        pessoa: 'ANA',
        contribuicao: 120,
        cota: 80,
        saldo: 40,
      );
      const outro = SaldoDePessoa(
        pessoa: 'ANA',
        contribuicao: 120,
        cota: 80,
        saldo: 40,
      );
      const outraPessoa = SaldoDePessoa(
        pessoa: 'BIA',
        contribuicao: 120,
        cota: 80,
        saldo: 40,
      );

      expect(um, outro);
      expect(um.hashCode, outro.hashCode);
      expect(um, isNot(outraPessoa));
    });
  });
}
