import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/composicao_da_festa.dart';
import 'package:bora/core/calculo/dominio/contagem_de_pessoas.dart';
import 'package:bora/core/calculo/dominio/item_de_lista.dart';
import 'package:bora/core/calculo/formatacao/money_formatter.dart';
import 'package:bora/core/calculo/regras/calculadora_da_festa.dart';
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
}
