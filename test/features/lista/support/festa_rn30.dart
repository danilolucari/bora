import 'package:bora/core/calculo/calculo.dart';

/// Os sete chips do estado padrão de RN-30.
const Set<ChaveItem> chipsPadraoRn30 = {
  ChaveItem.bovina,
  ChaveItem.frango,
  ChaveItem.paoDeAlho,
  ChaveItem.refrigerante,
  ChaveItem.agua,
  ChaveItem.cerveja,
  ChaveItem.cachaca,
};

/// A composição do estado padrão de RN-30: 3H + 3M + 1C, 4h e os sete chips.
///
/// É o caso literal do arquivo 03 — R\$ 211 sem essenciais, R\$ 271 com eles e
/// ≈ R\$ 45 por adulto —, e por isso é a fixture de toda tela desta feature.
ComposicaoDaFesta composicaoRn30({
  ContagemDePessoas? contagem,
  Set<ChaveItem> itens = chipsPadraoRn30,
  Map<ChaveItem, OverrideDeItem> overrides = const {},
  Set<ChaveItem> noCarrinho = const {},
  List<Pessoa> pessoas = const [],
}) =>
    ComposicaoDaFesta(
      contagem:
          contagem ?? ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: 4,
      itensSelecionados: itens,
      overrides: overrides,
      noCarrinho: noCarrinho,
      pessoas: pessoas,
    );

/// O resultado da calculadora para [composicaoRn30] — a **única** fonte de
/// itens, totais e essenciais dos testes de tela.
ResultadoDoCalculo resultadoRn30({
  ContagemDePessoas? contagem,
  Set<ChaveItem> itens = chipsPadraoRn30,
  Map<ChaveItem, OverrideDeItem> overrides = const {},
  Set<ChaveItem> noCarrinho = const {},
}) =>
    CalculadoraDaFesta.calcular(
      composicaoRn30(
        contagem: contagem,
        itens: itens,
        overrides: overrides,
        noCarrinho: noCarrinho,
      ),
    );

/// O item de [chave] na lista calculada — escolhidos **e** essenciais.
ItemDeLista itemDe(ResultadoDoCalculo resultado, ChaveItem chave) =>
    resultado.todosOsItens.firstWhere((item) => item.chave == chave);
