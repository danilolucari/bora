import 'package:bora/core/calculo/dominio/linha_de_acerto.dart';
import 'package:bora/core/calculo/dominio/saldo_de_pessoa.dart';
import 'package:bora/core/calculo/regras/quem_paga_quem.dart';
import 'package:flutter_test/flutter_test.dart';

/// Saldos na ordem em que o mapa foi escrito — a ordem é o que RN-16 percorre.
List<SaldoDePessoa> _saldos(Map<String, double> porPessoa, {double cota = 80}) =>
    [
      for (final entrada in porPessoa.entries)
        SaldoDePessoa(
          pessoa: entrada.key,
          contribuicao: cota + entrada.value,
          cota: cota,
          saldo: entrada.value,
        ),
    ];

/// `de → para` de cada linha, na ordem em que saíram.
List<String> _rotas(List<LinhaDeAcerto> linhas) =>
    [for (final linha in linhas) '${linha.de}→${linha.para}'];

void main() {
  group('CALC-21 — o Teste A de RN-16, linha a linha e na ordem', () {
    test('LÉO→VOCÊ 80 · BIA→VOCÊ 40 · BIA→ANA 40', () {
      final linhas = calcularRacha(
        _saldos(const {'VOCÊ': 120, 'ANA': 40, 'LÉO': -80, 'BIA': -80}),
      );

      expect(_rotas(linhas), ['LÉO→VOCÊ', 'BIA→VOCÊ', 'BIA→ANA']);
      expect(linhas[0].valor, closeTo(80, 0.001));
      expect(linhas[1].valor, closeTo(40, 0.001));
      expect(linhas[2].valor, closeTo(40, 0.001));
    });

    test('a soma paga iguala a soma recebida', () {
      final linhas = calcularRacha(
        _saldos(const {'VOCÊ': 120, 'ANA': 40, 'LÉO': -80, 'BIA': -80}),
      );

      double pagoPor(String pessoa) => linhas
          .where((linha) => linha.de == pessoa)
          .fold<double>(0, (soma, linha) => soma + linha.valor);
      double recebidoPor(String pessoa) => linhas
          .where((linha) => linha.para == pessoa)
          .fold<double>(0, (soma, linha) => soma + linha.valor);

      expect(pagoPor('LÉO'), closeTo(80, 0.001));
      expect(pagoPor('BIA'), closeTo(80, 0.001));
      expect(recebidoPor('VOCÊ'), closeTo(120, 0.001));
      expect(recebidoPor('ANA'), closeTo(40, 0.001));
      expect(
        pagoPor('LÉO') + pagoPor('BIA'),
        closeTo(recebidoPor('VOCÊ') + recebidoPor('ANA'), 0.001),
      );
    });
  });

  group('CALC-21 — o Teste B de RN-16, linha a linha e na ordem', () {
    test('LÉO→RAFA 35 · BIA→RAFA 70 · BIA→ANA 25', () {
      final linhas = calcularRacha(
        _saldos(
          const {'RAFA': 105, 'ANA': 25, 'LÉO': -35, 'BIA': -95},
          cota: 95,
        ),
      );

      expect(_rotas(linhas), ['LÉO→RAFA', 'BIA→RAFA', 'BIA→ANA']);
      expect(linhas[0].valor, closeTo(35, 0.001));
      expect(linhas[1].valor, closeTo(70, 0.001));
      expect(linhas[2].valor, closeTo(25, 0.001));
    });

    test('a soma paga iguala a soma recebida', () {
      final linhas = calcularRacha(
        _saldos(
          const {'RAFA': 105, 'ANA': 25, 'LÉO': -35, 'BIA': -95},
          cota: 95,
        ),
      );

      final pago = linhas.fold<double>(0, (soma, l) => soma + l.valor);

      expect(pago, closeTo(130, 0.001), reason: '35 de LÉO + 95 de BIA');
      expect(
        linhas
            .where((l) => l.para == 'RAFA')
            .fold<double>(0, (soma, l) => soma + l.valor),
        closeTo(105, 0.001),
      );
      expect(
        linhas
            .where((l) => l.para == 'ANA')
            .fold<double>(0, (soma, l) => soma + l.valor),
        closeTo(25, 0.001),
      );
    });
  });

  group('CALC-21 — a ordem de entrada é comportamento observável (A-14)', () {
    test('trocar a ordem dos credores muda as linhas, e a saída é a daquela '
        'ordem', () {
      final linhas = calcularRacha(
        _saldos(
          const {'ANA': 25, 'RAFA': 105, 'LÉO': -35, 'BIA': -95},
          cota: 95,
        ),
      );

      expect(
        _rotas(linhas),
        ['LÉO→ANA', 'LÉO→RAFA', 'BIA→RAFA'],
        reason: 'com ANA na frente, LÉO esgota o crédito dela antes de chegar '
            'em RAFA — outra entrada, outra saída legítima',
      );
      expect(linhas[0].valor, closeTo(25, 0.001));
      expect(linhas[1].valor, closeTo(10, 0.001));
      expect(linhas[2].valor, closeTo(95, 0.001));
    });

    test('os credores não são ordenados por valor: o Teste B começa por LÉO, '
        'o menor devedor', () {
      final linhas = calcularRacha(
        _saldos(
          const {'RAFA': 105, 'ANA': 25, 'LÉO': -35, 'BIA': -95},
          cota: 95,
        ),
      );

      expect(
        _rotas(linhas),
        isNot(['BIA→RAFA', 'LÉO→RAFA', 'LÉO→ANA']),
        reason: 'ordenar por valor decrescente daria BIA→RAFA 95 · '
            'LÉO→RAFA 10 · LÉO→ANA 25 — soma certa, conteúdo errado',
      );
      expect(linhas.first.de, 'LÉO');
    });
  });

  group('CALC-21 — quando não há o que acertar', () {
    test('lista de saldos vazia devolve lista vazia', () {
      expect(calcularRacha(const []), isEmpty);
    });

    test('só credores devolve lista vazia', () {
      expect(calcularRacha(_saldos(const {'VOCÊ': 120, 'ANA': 40})), isEmpty);
    });

    test('só devedores devolve lista vazia', () {
      expect(calcularRacha(_saldos(const {'LÉO': -80, 'BIA': -80})), isEmpty);
    });

    test('todo mundo no zero devolve lista vazia', () {
      expect(
        calcularRacha(_saldos(const {'VOCÊ': 0, 'ANA': 0, 'LÉO': 0})),
        isEmpty,
      );
    });
  });

  group('CALC-21 — resíduo de centavo não vira cobrança (A-13)', () {
    test('saldos de meio centavo não geram linha nenhuma', () {
      expect(
        calcularRacha(_saldos(const {'VOCÊ': 0.005, 'LÉO': -0.005})),
        isEmpty,
      );
    });

    test('o crédito que sobra abaixo de um centavo não vira uma linha extra',
        () {
      final linhas = calcularRacha(
        _saldos(const {'VOCÊ': 80.005, 'LÉO': -80, 'BIA': -0.005}),
      );

      expect(_rotas(linhas), ['LÉO→VOCÊ']);
      expect(linhas.single.valor, closeTo(80, 0.001));
    });

    test('o credor de meio centavo na frente da fila não vira linha fantasma',
        () {
      // A tolerância na **entrada** é o que protege daqui: sem ela, ANA entra
      // na fila de credores e, por ser a primeira, recebe uma linha de
      // R$ 0,005 antes de RAFA. Classificar por `> 0` deixa os outros testes
      // deste grupo verdes — eles exercitam o resíduo do lado devedor e o que
      // sobra no fim, não um credor sub-centavo no início da ordem.
      final linhas = calcularRacha(
        _saldos(const {'ANA': 0.005, 'RAFA': 50, 'BIA': -50.005}),
      );

      expect(_rotas(linhas), ['BIA→RAFA']);
      expect(linhas.single.valor, closeTo(50, 0.001));
    });

    test('nenhuma linha emitida vale um centavo ou menos', () {
      final linhas = calcularRacha(
        _saldos(const {'VOCÊ': 80.005, 'ANA': 40, 'LÉO': -80, 'BIA': -40.005}),
      );

      expect(linhas, isNotEmpty);
      expect(linhas.every((linha) => linha.valor > 0.01), isTrue);
    });
  });

  group('CALC-21 — a linha de acerto (RN-16, RN-18)', () {
    test('nasce pendente', () {
      const linha = LinhaDeAcerto(de: 'LÉO', para: 'VOCÊ', valor: 80);

      expect(linha.paga, isFalse);
    });

    test('as linhas do racha nascem pendentes', () {
      final linhas = calcularRacha(
        _saldos(const {'VOCÊ': 120, 'ANA': 40, 'LÉO': -80, 'BIA': -80}),
      );

      expect(linhas, isNotEmpty);
      expect(linhas.any((linha) => linha.paga), isFalse);
    });

    test('copyWith marca como paga sem mexer em quem paga quem, nem quanto',
        () {
      const linha = LinhaDeAcerto(de: 'LÉO', para: 'VOCÊ', valor: 80);

      final quitada = linha.copyWith(paga: true);

      expect(quitada.paga, isTrue);
      expect(quitada.de, 'LÉO');
      expect(quitada.para, 'VOCÊ');
      expect(quitada.valor, closeTo(80, 0.001));
    });

    test('duas linhas iguais campo a campo são iguais; a marca de paga '
        'diferencia', () {
      const uma = LinhaDeAcerto(de: 'LÉO', para: 'VOCÊ', valor: 80);
      const outra = LinhaDeAcerto(de: 'LÉO', para: 'VOCÊ', valor: 80);

      expect(uma, outra);
      expect(uma.hashCode, outra.hashCode);
      expect(uma, isNot(uma.copyWith(paga: true)));
    });
  });
}
