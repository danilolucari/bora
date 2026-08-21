import 'package:bora/core/calculo/dominio/catalogo_de_itens.dart';
import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/composicao_da_festa.dart';
import 'package:bora/core/calculo/dominio/contagem_de_pessoas.dart';
import 'package:bora/core/calculo/dominio/despesa.dart';
import 'package:bora/core/calculo/dominio/item_de_lista.dart';
import 'package:bora/core/calculo/dominio/linha_de_acerto.dart';
import 'package:bora/core/calculo/dominio/saldo_de_pessoa.dart';
import 'package:bora/core/calculo/formatacao/money_formatter.dart';
import 'package:bora/core/calculo/regras/calculadora_da_festa.dart';
import 'package:bora/core/calculo/regras/contribuicoes.dart';
import 'package:bora/core/calculo/regras/quem_paga_quem.dart';
import 'package:bora/core/calculo/regras/saldos.dart';
import 'package:flutter_test/flutter_test.dart';

/// Os casos numéricos que o `CLAUDE.md` eleva a lei: *"os exemplos numéricos
/// de `03` são casos de teste literais, não ilustrações — se um desses falhar,
/// o errado é o código"*.
///
/// O estado padrão de RN-10: 3 homens + 3 mulheres + 1 criança (6 adultos,
/// 7 pessoas), 4 horas (f = 1), **sem pessoas nomeadas**, com bovina + frango
/// + pão de alho + refrigerante + água + cerveja + cachaça.
ComposicaoDaFesta _estadoPadrao() => ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: 4,
      itensSelecionados: const {
        ChaveItem.bovina,
        ChaveItem.frango,
        ChaveItem.paoDeAlho,
        ChaveItem.refrigerante,
        ChaveItem.agua,
        ChaveItem.cerveja,
        ChaveItem.cachaca,
      },
    );

ItemDeLista _item(ResultadoDoCalculo resultado, ChaveItem chave) =>
    resultado.itens.firstWhere((item) => item.chave == chave);

/// Um item da lista que alguém assumiu — a contribuição "eu levo" de RN-20.
ItemDeLista _levadoPor(
  String pessoa, {
  required ChaveItem chave,
  required double quantidade,
}) {
  final definicao = catalogoDeItens[chave]!;

  return ItemDeLista(
    chave: chave,
    nome: definicao.nome,
    emoji: definicao.emoji,
    unidade: definicao.unidade,
    quantidadeAutomatica: quantidade,
    precoBase: definicao.precoBase,
    quemLeva: pessoa,
  );
}

/// Cada linha de acerto na copy da tela: `LÉO → VOCÊ · R$ 80`.
List<String> _acerto(List<LinhaDeAcerto> linhas) => [
      for (final linha in linhas)
        '${linha.de} → ${linha.para} · ${MoneyFormatter.reais(linha.valor)}',
    ];

/// As contribuições do **Teste A** de RN-16: VOCÊ leva as carnes e o carvão
/// (R$ 200), ANA leva a cerveja e o gelo (R$ 120), LÉO e BIA não levam nada.
///
/// A composição dos itens é livre — o que o arquivo 03 fixa são as
/// contribuições e o total de R$ 320. Os preços são os do catálogo da
/// calculadora (RN-03..RN-10).
Map<String, double> _contribuicoesDoTesteA() => contribuicoesPorPessoa(
      participantes: const ['VOCÊ', 'ANA', 'LÉO', 'BIA'],
      itens: [
        _levadoPor('VOCÊ', chave: ChaveItem.bovina, quantidade: 2),
        _levadoPor('VOCÊ', chave: ChaveItem.suina, quantidade: 2.5),
        _levadoPor('VOCÊ', chave: ChaveItem.frango, quantidade: 1),
        _levadoPor('VOCÊ', chave: ChaveItem.carvao, quantidade: 1),
        _levadoPor('ANA', chave: ChaveItem.cerveja, quantidade: 20),
        _levadoPor('ANA', chave: ChaveItem.gelo, quantidade: 4),
      ],
    );

/// Os saldos do Teste A: total 320, entre **4 adultos** — criança de fora.
List<SaldoDePessoa> _saldosDoTesteA() {
  final contribuicoes = _contribuicoesDoTesteA();

  return calcularSaldos(
    contribuicoes: contribuicoes,
    total: totalDasContribuicoes(contribuicoes),
    adultos: 4,
  );
}

/// As despesas do **Teste B** de RN-16: Rafa adiantou R$ 200, Ana R$ 120,
/// Léo R$ 60 (pão + descartáveis) e Bia nada.
const _despesasDoTesteB = [
  Despesa(quemPagou: 'RAFA', descricao: 'Carnes + carvão', valor: 200),
  Despesa(quemPagou: 'ANA', descricao: 'Cerveja + gelo', valor: 120),
  Despesa(
    quemPagou: 'LÉO',
    descricao: 'Pão de alho + descartáveis',
    valor: 60,
  ),
];

/// Os saldos do Teste B: total 380, entre **4 adultos** — cota 95.
List<SaldoDePessoa> _saldosDoTesteB() {
  final contribuicoes = contribuicoesPorPessoa(
    participantes: const ['RAFA', 'ANA', 'LÉO', 'BIA'],
    despesas: _despesasDoTesteB,
  );

  return calcularSaldos(
    contribuicoes: contribuicoes,
    total: totalDasContribuicoes(contribuicoes),
    adultos: 4,
  );
}


void main() {
  group('Arquivo 03, RN-10 — o estado padrão, item a item', () {
    test('as quantidades são as do exemplo do arquivo 03', () {
      final resultado = CalculadoraDaFesta.calcular(_estadoPadrao());

      expect(
        _item(resultado, ChaveItem.bovina).quantidade,
        closeTo(1.2, 0.001),
        reason: 'carne 2.300 g ÷ 2 = 1,2 kg cada',
      );
      expect(_item(resultado, ChaveItem.frango).quantidade, closeTo(1.2, 0.001));
      expect(_item(resultado, ChaveItem.paoDeAlho).quantidade, 4);
      expect(_item(resultado, ChaveItem.refrigerante).quantidade, 2);
      expect(_item(resultado, ChaveItem.agua).quantidade, 2);
      expect(_item(resultado, ChaveItem.cerveja).quantidade, 18);
      expect(_item(resultado, ChaveItem.cachaca).quantidade, 1);
    });

    test('cada item vale exatamente o que o arquivo 03 afirma', () {
      final resultado = CalculadoraDaFesta.calcular(_estadoPadrao());

      String dinheiro(ChaveItem chave) =>
          MoneyFormatter.reais(_item(resultado, chave).valor);

      expect(dinheiro(ChaveItem.bovina), 'R\$ 54', reason: '1,2 kg × 45');
      expect(dinheiro(ChaveItem.frango), 'R\$ 22', reason: '1,2 kg × 18');
      expect(dinheiro(ChaveItem.paoDeAlho), 'R\$ 24', reason: '4 un × 6');
      expect(dinheiro(ChaveItem.refrigerante), 'R\$ 18', reason: '2 gf × 9');
      expect(dinheiro(ChaveItem.agua), 'R\$ 6', reason: '2 gf × 3');
      expect(dinheiro(ChaveItem.cerveja), 'R\$ 72', reason: '18 latas × 4');
      expect(dinheiro(ChaveItem.cachaca), 'R\$ 15', reason: '1 gf × 15');
    });

    test('o Frango vale 21,60 na aritmética e só vira 22 na exibição', () {
      final resultado = CalculadoraDaFesta.calcular(_estadoPadrao());

      expect(
        _item(resultado, ChaveItem.frango).valor,
        closeTo(21.6, 0.001),
        reason: 'arredondar o item aqui somaria 211,00 por acaso e esconderia '
            'o erro em listas maiores',
      );
    });
  });

  group('Arquivo 03, RN-10 — R\$ 211 e ≈ R\$ 30 por cabeça', () {
    test('o total dos itens é R\$ 211', () {
      final resultado = CalculadoraDaFesta.calcular(_estadoPadrao());

      expect(
        resultado.totalDosItens,
        closeTo(210.6, 0.001),
        reason: '54 + 21,60 + 24 + 18 + 6 + 72 + 15',
      );
      expect(MoneyFormatter.reais(resultado.totalDosItens), 'R\$ 211');
    });

    test('a estimativa é ≈ R\$ 30 por cabeça, dividindo pelas 7 pessoas', () {
      final resultado = CalculadoraDaFesta.calcular(_estadoPadrao());

      expect(resultado.contagem.pessoas, 7);
      expect(resultado.porCabeca, closeTo(30.0857, 0.001));
      expect(MoneyFormatter.reais(resultado.porCabeca), 'R\$ 30');
    });
  });

  group('Arquivo 03, RN-10 — R\$ 271 e ≈ R\$ 45 por adulto', () {
    test('os essenciais que somam valem 60', () {
      final resultado = CalculadoraDaFesta.calcular(_estadoPadrao());

      expect(
        resultado.totalDosEssenciais,
        closeTo(60, 0.001),
        reason: 'Carvão 22 + Gelo 30 + Sal 8; Copos & pratos (15) está na '
            'lista e fora do total — leitura (a) de RN-10 (A-01)',
      );
      expect(
        resultado.essenciais.map((item) => item.chave),
        contains(ChaveItem.coposEPratos),
      );
    });

    test('o total com os essenciais é R\$ 271', () {
      final resultado = CalculadoraDaFesta.calcular(_estadoPadrao());

      expect(
        resultado.totalComEssenciais,
        closeTo(270.6, 0.001),
        reason: '210,60 + 60',
      );
      expect(MoneyFormatter.reais(resultado.totalComEssenciais), 'R\$ 271');
    });

    test('o por adulto é ≈ R\$ 45, dividindo pelos 6 adultos', () {
      final resultado = CalculadoraDaFesta.calcular(_estadoPadrao());

      expect(resultado.contagem.adultos, 6);
      expect(resultado.porAdulto, closeTo(45.1, 0.001));
      expect(MoneyFormatter.reais(resultado.porAdulto), 'R\$ 45');
    });
  });

  group('Arquivo 03, RN-14 — os dois números coexistem, e não se unificam',
      () {
    test('o por cabeça sai do total sem essenciais, dividido por 7; o por '
        'adulto sai do total com essenciais, dividido por 6', () {
      final resultado = CalculadoraDaFesta.calcular(_estadoPadrao());

      expect(
        resultado.porCabeca * resultado.contagem.pessoas,
        closeTo(resultado.totalDosItens, 0.001),
        reason: 'a estimativa da tela Montar não conhece os essenciais',
      );
      expect(
        resultado.porAdulto * resultado.contagem.adultos,
        closeTo(resultado.totalComEssenciais, 0.001),
        reason: 'a divisão financeira de RN-14 é por adulto e já conta os '
            'essenciais — criança nunca entra no racha',
      );
      expect(
        resultado.contagem.pessoas,
        isNot(resultado.contagem.adultos),
        reason: 'é a criança que separa os dois divisores',
      );
    });
  });

  group('Arquivo 03, RN-16 — Teste A: o acerto de "quem levou"', () {
    test('as contribuições são 200, 120, 0 e 0, e a festa sai por 320', () {
      final contribuicoes = _contribuicoesDoTesteA();

      expect(
        contribuicoes['VOCÊ'],
        closeTo(200, 0.001),
        reason: '2 kg de bovina 90 + 2,5 kg de suína 70 + 1 kg de frango 18 '
            '+ 1 saco de carvão 22',
      );
      expect(
        contribuicoes['ANA'],
        closeTo(120, 0.001),
        reason: '20 latas de cerveja 80 + 4 sacos de gelo 40',
      );
      expect(contribuicoes['LÉO'], closeTo(0, 0.001));
      expect(contribuicoes['BIA'], closeTo(0, 0.001));
      expect(totalDasContribuicoes(contribuicoes), closeTo(320, 0.001));
    });

    test('a cota é R\$ 80 e os saldos são +120, +40, −80, −80', () {
      final saldos = _saldosDoTesteA();

      expect(MoneyFormatter.reais(saldos.first.cota), 'R\$ 80');
      expect(saldos[0].saldo, closeTo(120, 0.001));
      expect(saldos[1].saldo, closeTo(40, 0.001));
      expect(saldos[2].saldo, closeTo(-80, 0.001));
      expect(saldos[3].saldo, closeTo(-80, 0.001));
      expect(saldos[0].situacao, SituacaoDeSaldo.recebe);
      expect(saldos[2].situacao, SituacaoDeSaldo.paga);
    });

    test('as linhas são LÉO→VOCÊ 80 · BIA→VOCÊ 40 · BIA→ANA 40, nesta ordem',
        () {
      final linhas = calcularRacha(_saldosDoTesteA());

      expect(_acerto(linhas), [
        'LÉO → VOCÊ · R\$ 80',
        'BIA → VOCÊ · R\$ 40',
        'BIA → ANA · R\$ 40',
      ]);
    });
  });

  group('Arquivo 03, RN-16 — Teste B: o acerto de custos e despesas', () {
    test('as despesas somam 380 e a cota é R\$ 95', () {
      final saldos = _saldosDoTesteB();

      expect(
        saldos.fold<double>(0, (soma, saldo) => soma + saldo.contribuicao),
        closeTo(380, 0.001),
      );
      expect(MoneyFormatter.reais(saldos.first.cota), 'R\$ 95');
    });

    test('os saldos são +105, +25, −35, −95', () {
      final saldos = _saldosDoTesteB();

      expect(saldos.map((saldo) => saldo.pessoa).toList(),
          ['RAFA', 'ANA', 'LÉO', 'BIA']);
      expect(saldos[0].saldo, closeTo(105, 0.001));
      expect(saldos[1].saldo, closeTo(25, 0.001));
      expect(saldos[2].saldo, closeTo(-35, 0.001));
      expect(saldos[3].saldo, closeTo(-95, 0.001));
    });

    test('as linhas são LÉO→RAFA 35 · BIA→RAFA 70 · BIA→ANA 25, nesta ordem',
        () {
      final linhas = calcularRacha(_saldosDoTesteB());

      expect(_acerto(linhas), [
        'LÉO → RAFA · R\$ 35',
        'BIA → RAFA · R\$ 70',
        'BIA → ANA · R\$ 25',
      ]);
    });

    test('a ordem não é por valor: ordenar credores e devedores por valor '
        'decrescente daria outra saída (A-14)', () {
      final linhas = calcularRacha(_saldosDoTesteB());

      expect(
        _acerto(linhas),
        isNot([
          'BIA → RAFA · R\$ 95',
          'LÉO → RAFA · R\$ 10',
          'LÉO → ANA · R\$ 25',
        ]),
        reason: 'as três linhas somariam os mesmos R\$ 130 e ainda assim '
            'violariam RN-16 — a ordem é comportamento observável',
      );
    });
  });

  group('Arquivo 03, RN-16 — o balanço dos dois testes (UC-20)', () {
    test('a soma paga iguala a soma recebida, nos dois', () {
      for (final saldos in [_saldosDoTesteA(), _saldosDoTesteB()]) {
        final linhas = calcularRacha(saldos);
        final pago = linhas.fold<double>(0, (soma, l) => soma + l.valor);
        final devido = saldos
            .where((saldo) => saldo.situacao == SituacaoDeSaldo.paga)
            .fold<double>(0, (soma, saldo) => soma - saldo.saldo);
        final aReceber = saldos
            .where((saldo) => saldo.situacao == SituacaoDeSaldo.recebe)
            .fold<double>(0, (soma, saldo) => soma + saldo.saldo);

        expect(pago, closeTo(devido, 0.001));
        expect(pago, closeTo(aReceber, 0.001));
      }
    });
  });
}
