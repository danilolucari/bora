import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/composicao_da_festa.dart';
import 'package:bora/core/calculo/dominio/contagem_de_pessoas.dart';
import 'package:bora/core/calculo/dominio/dieta.dart';
import 'package:bora/core/calculo/dominio/item_de_lista.dart';
import 'package:bora/core/calculo/dominio/papel_na_festa.dart';
import 'package:bora/core/calculo/dominio/pessoa.dart';
import 'package:bora/core/calculo/dominio/status_de_presenca.dart';
import 'package:bora/core/calculo/regras/calculadora_da_festa.dart';
import 'package:flutter_test/flutter_test.dart';

/// Os chips do estado padrão do arquivo 03: bovina + frango + pão de alho +
/// refrigerante + água + cerveja + cachaça.
const Set<ChaveItem> _chipsPadrao = {
  ChaveItem.bovina,
  ChaveItem.frango,
  ChaveItem.paoDeAlho,
  ChaveItem.refrigerante,
  ChaveItem.agua,
  ChaveItem.cerveja,
  ChaveItem.cachaca,
};

ComposicaoDaFesta _composicao({
  ContagemDePessoas? contagem,
  int duracaoHoras = 4,
  List<Pessoa> pessoas = const [],
  Set<ChaveItem> itens = _chipsPadrao,
  Map<ChaveItem, OverrideDeItem> overrides = const {},
}) =>
    ComposicaoDaFesta(
      contagem:
          contagem ?? ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: duracaoHoras,
      pessoas: pessoas,
      itensSelecionados: itens,
      overrides: overrides,
    );

Pessoa _pessoa(String nome, {Dieta? dieta, bool? bebe}) => Pessoa(
      nome: nome,
      papel: PapelNaFesta.convidado,
      status: StatusDePresenca.confirmado,
      dieta: dieta,
      bebe: bebe,
    );

List<ChaveItem> _chaves(List<ItemDeLista> itens) =>
    itens.map((item) => item.chave).toList();

double _quantidade(List<ItemDeLista> itens, ChaveItem chave) =>
    itens.firstWhere((item) => item.chave == chave).quantidade;

void main() {
  group('CALC-15 — o estado padrão vira lista', () {
    test('os sete chips saem na ordem canônica do catálogo', () {
      final resultado = CalculadoraDaFesta.calcular(_composicao());

      expect(_chaves(resultado.itens), [
        ChaveItem.bovina,
        ChaveItem.frango,
        ChaveItem.paoDeAlho,
        ChaveItem.refrigerante,
        ChaveItem.agua,
        ChaveItem.cerveja,
        ChaveItem.cachaca,
      ]);
      expect(resultado.contagem.pessoas, 7);
    });

    test('cada item sai com a quantidade da sua regra', () {
      final itens = CalculadoraDaFesta.calcular(_composicao()).itens;

      expect(
        _quantidade(itens, ChaveItem.bovina),
        closeTo(1.2, 0.001),
        reason: '2300 g ÷ 2 carnes = 1150 g → 1,2 kg (RN-03)',
      );
      expect(_quantidade(itens, ChaveItem.frango), closeTo(1.2, 0.001));
      expect(_quantidade(itens, ChaveItem.paoDeAlho), 4);
      expect(_quantidade(itens, ChaveItem.refrigerante), 2);
      expect(_quantidade(itens, ChaveItem.agua), 2);
      expect(_quantidade(itens, ChaveItem.cerveja), 18);
      expect(_quantidade(itens, ChaveItem.cachaca), 1);
    });

    test('a lista inteira é a escolhida mais os quatro essenciais de RN-10',
        () {
      final resultado = CalculadoraDaFesta.calcular(_composicao());

      expect(_chaves(resultado.essenciais), [
        ChaveItem.carvao,
        ChaveItem.gelo,
        ChaveItem.salGrosso,
        ChaveItem.coposEPratos,
      ]);
      expect(
        _chaves(resultado.todosOsItens),
        _chaves(resultado.itens) + _chaves(resultado.essenciais),
      );
    });

    test('duas chamadas devolvem a mesma lista, na mesma ordem', () {
      final primeira = CalculadoraDaFesta.calcular(_composicao());
      final segunda = CalculadoraDaFesta.calcular(_composicao());

      expect(_chaves(segunda.itens), _chaves(primeira.itens));
      expect(
        segunda.itens.map((item) => item.quantidade),
        primeira.itens.map((item) => item.quantidade),
      );
    });

    test('a duração entra pelo fator de RN-02 e encolhe as quantidades', () {
      final resultado =
          CalculadoraDaFesta.calcular(_composicao(duracaoHoras: 2));

      expect(resultado.fator, closeTo(0.5, 0.001));
      expect(
        _quantidade(resultado.itens, ChaveItem.cerveja),
        9,
        reason: '6 × 1000 × 0,5 ÷ 350 = 8,57 → 9 latas',
      );
    });
  });

  group('CALC-15 — as preferências mudam a lista (RN-21)', () {
    test('uma pessoa veggie acrescenta o kit de legumes', () {
      final resultado = CalculadoraDaFesta.calcular(
        _composicao(pessoas: [_pessoa('ANA', dieta: Dieta.veggie)]),
      );

      expect(_chaves(resultado.itens), contains(ChaveItem.legumesParaGrelha));
      expect(_quantidade(resultado.itens, ChaveItem.legumesParaGrelha), 1);
    });

    test('sem pessoa veggie o kit não aparece', () {
      final resultado = CalculadoraDaFesta.calcular(_composicao());

      expect(
        _chaves(resultado.itens),
        isNot(contains(ChaveItem.legumesParaGrelha)),
      );
    });

    test('uma pessoa sem porco tira a suína e redivide as gramas entre as '
        'carnes restantes', () {
      const tresCarnes = {
        ChaveItem.bovina,
        ChaveItem.suina,
        ChaveItem.frango,
      };

      final semPreferencia =
          CalculadoraDaFesta.calcular(_composicao(itens: tresCarnes));
      final comSemPorco = CalculadoraDaFesta.calcular(
        _composicao(
          itens: tresCarnes,
          pessoas: [_pessoa('LÉO', dieta: Dieta.semPorco)],
        ),
      );

      expect(
        _quantidade(semPreferencia.itens, ChaveItem.bovina),
        closeTo(0.8, 0.001),
        reason: '2300 g ÷ 3 carnes = 766,7 g → 0,8 kg',
      );
      expect(
        _chaves(comSemPorco.itens),
        [ChaveItem.bovina, ChaveItem.frango],
        reason: 'a suína sai mesmo estando selecionada',
      );
      expect(
        _quantidade(comSemPorco.itens, ChaveItem.bovina),
        closeTo(1.2, 0.001),
        reason: 'as gramas se redividem entre as duas que sobraram',
      );
    });

    test('sem porco na única carne selecionada equivale a nenhuma carne', () {
      final soSuina = CalculadoraDaFesta.calcular(
        _composicao(
          itens: const {ChaveItem.suina, ChaveItem.paoDeAlho},
          pessoas: [_pessoa('LÉO', dieta: Dieta.semPorco)],
        ),
      );
      final nenhumaCarne = CalculadoraDaFesta.calcular(
        _composicao(itens: const {ChaveItem.paoDeAlho}),
      );

      expect(_chaves(soSuina.itens), [ChaveItem.paoDeAlho]);
      expect(_chaves(soSuina.itens), _chaves(nenhumaCarne.itens));
      expect(
        _quantidade(soSuina.itens, ChaveItem.paoDeAlho),
        _quantidade(nenhumaCarne.itens, ChaveItem.paoDeAlho),
      );
    });

    test('a cerveja dimensiona por quem bebe, não pelos adultos', () {
      final resultado = CalculadoraDaFesta.calcular(
        _composicao(pessoas: [_pessoa('RAFA', bebe: false)]),
      );

      expect(
        _quantidade(resultado.itens, ChaveItem.cerveja),
        15,
        reason: '6 adultos − 1 abstêmio = 5 → 5000 ml ÷ 350 = 14,3 → 15 latas',
      );
    });
  });

  group('CALC-16 — festa sem ninguém não compra nada (A-11, UC-03 E1)', () {
    test('0 pessoas devolve lista vazia, sem nenhum piso max(1, …)', () {
      final resultado = CalculadoraDaFesta.calcular(
        _composicao(contagem: ContagemDePessoas()),
      );

      expect(resultado.itens, isEmpty);
      expect(
        resultado.essenciais,
        isEmpty,
        reason: 'nem os essenciais de RN-10 entram numa festa sem plateia',
      );
      expect(resultado.todosOsItens, isEmpty);
    });
  });

  group('CALC-15 — item de quantidade 0 não entra na lista', () {
    test('festa só de crianças fica sem cerveja e sem destilado, mas com '
        'refrigerante e água', () {
      final resultado = CalculadoraDaFesta.calcular(
        _composicao(contagem: ContagemDePessoas(criancas: 3)),
      );

      expect(_chaves(resultado.itens), [
        ChaveItem.bovina,
        ChaveItem.frango,
        ChaveItem.paoDeAlho,
        ChaveItem.refrigerante,
        ChaveItem.agua,
      ]);
      expect(
        _chaves(resultado.itens),
        isNot(contains(ChaveItem.cerveja)),
        reason: 'RN-05 é só de adulto: 0 latas, não 1 (A-12)',
      );
      expect(
        _chaves(resultado.itens),
        isNot(contains(ChaveItem.cachaca)),
        reason: 'RN-09 é só de adulto: 0 garrafas, não 1 (A-12)',
      );
      expect(
        _quantidade(resultado.itens, ChaveItem.refrigerante),
        1,
        reason: '3 crianças × 500 ml = 1500 ml → 1 garrafa (o piso vale, há '
            'plateia)',
      );
      expect(_quantidade(resultado.itens, ChaveItem.agua), 1);
      expect(
        _quantidade(resultado.itens, ChaveItem.bovina),
        closeTo(0.5, 0.001),
        reason: '600 g ÷ 2 carnes = 300 g, abaixo do piso de 0,5 kg de RN-03 '
            '— criança come carne, só não entra no racha',
      );
    });

    test('nenhum item da lista sai com quantidade zero', () {
      final resultado = CalculadoraDaFesta.calcular(
        _composicao(contagem: ContagemDePessoas(criancas: 3)),
      );

      for (final item in resultado.todosOsItens) {
        expect(item.quantidade, greaterThan(0), reason: item.nome);
      }
    });
  });

  group('CALC-17 — os ajustes manuais chegam ao item (RN-12)', () {
    test('override de quantidade e de preço cobrem o automático sem apagá-lo',
        () {
      final resultado = CalculadoraDaFesta.calcular(
        _composicao(
          overrides: const {
            ChaveItem.bovina: OverrideDeItem(quantidade: 3),
            ChaveItem.cerveja: OverrideDeItem(preco: 5),
          },
        ),
      );

      final bovina =
          resultado.itens.firstWhere((item) => item.chave == ChaveItem.bovina);
      final cerveja =
          resultado.itens.firstWhere((item) => item.chave == ChaveItem.cerveja);

      expect(bovina.quantidade, closeTo(3, 0.001));
      expect(
        bovina.quantidadeAutomatica,
        closeTo(1.2, 0.001),
        reason: 'o automático continua guardado, para o RESTAURAR de RN-12',
      );
      expect(bovina.editado, isTrue);
      expect(cerveja.preco, closeTo(5, 0.001));
      expect(cerveja.precoBase, closeTo(4, 0.001));
      expect(cerveja.quantidade, 18, reason: 'só o preço foi ajustado');
    });

    test('a lista informa que há overrides a restaurar', () {
      final resultado = CalculadoraDaFesta.calcular(
        _composicao(
          overrides: const {ChaveItem.bovina: OverrideDeItem(quantidade: 3)},
        ),
      );

      expect(resultado.temOverrides, isTrue);
    });

    test('sem nenhum ajuste, não há o que restaurar', () {
      expect(CalculadoraDaFesta.calcular(_composicao()).temOverrides, isFalse);
    });
  });
}
