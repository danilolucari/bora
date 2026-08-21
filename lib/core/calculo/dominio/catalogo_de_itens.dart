import 'chave_item.dart';

/// Os dados-base de um item **para a calculadora** (CALC-07..CALC-14, CALC-17).
///
/// Esta é a fonte de preço de RN-03..RN-10 — a que produz o R$ 211 do arquivo
/// 03 — e ela **nunca** se mistura com a de RN-11, que é a média real de
/// mercados da tela Lista. As duas coexistem de propósito (A-03): a Bovina vale
/// R$ 45/kg aqui e R$ 65 na faixa de mercado, e unificar quebraria um dos dois
/// casos literais.
class DefinicaoDeItem {
  const DefinicaoDeItem({
    required this.chave,
    required this.nome,
    required this.emoji,
    required this.unidade,
    required this.precoBase,
    required this.passoDeQuantidade,
    this.essencial = false,
    this.fonteDaProporcao,
    this.quantidadeDefault,
    this.entraNoTotal = true,
  });

  final ChaveItem chave;

  /// Copy literal da fonte: chips de T-03 em caixa alta, itens de RN-10 e
  /// RN-21 em sentence case. Transformar caixa é trabalho da UI.
  final String nome;

  final String emoji;
  final UnidadeDeItem unidade;

  /// Preço-base de RN-03..RN-10, por [unidade].
  final double precoBase;

  /// Passo do stepper de quantidade (RN-12): carnes 0,5 · cerveja 2 · demais 1.
  /// O mínimo de quantidade é **um passo**.
  final double passoDeQuantidade;

  /// `true` nos quatro itens de RN-10, que entram na lista sozinhos.
  final bool essencial;

  /// A fonte do badge `AUTO ∝ <fonte>` de RN-10.
  ///
  /// É **metadado**, não fórmula: RN-10 nomeia a proporção mas não dá conta
  /// nenhuma, então a quantidade vem de [quantidadeDefault] (A-09). Inventar
  /// uma fórmula aqui mudaria o caso literal de R$ 271.
  final String? fonteDaProporcao;

  /// Quantidade fixa do item, quando a spec dá uma em vez de uma fórmula.
  ///
  /// `null` nos itens cuja quantidade sai de RN-03..RN-09.
  final double? quantidadeDefault;

  /// Se o valor do item soma no **total** da festa.
  ///
  /// Aparecer na lista e somar no total são duas coisas diferentes, e o único
  /// item em que elas divergem é 🍽️ Copos & pratos — consequência da decisão
  /// do usuário de 2026-08-20 (A-01/A-02) pela **leitura (a) de RN-10**: o
  /// parêntese "(22+30+8+15)" soma 75, mas o total afirmado na mesma frase é
  /// R$ 271 e o por adulto é ≈R$ 45, e só 22+30+8 = 60 fecha os dois
  /// (210,60 + 60 = 270,60 → R$ 271; ÷ 6 adultos = 45,10 → ≈R$ 45).
  ///
  /// Trocar para a leitura (b) é virar este booleano em `coposEPratos`: o
  /// efeito esperado seria **R$ 286** e **≈R$ 48/adulto**.
  final bool entraNoTotal;
}

/// Preço-base, unidade, passo e metadado dos 16 itens da calculadora.
///
/// Os preços são literais de RN-03..RN-10, com uma única exceção declarada: o
/// kit veggie de RN-21 não tem preço em RN-03..RN-09 — **R$ 28 é o único
/// número que a spec associa ao item**, via a tabela de RN-11 ("🥗 Legumes p/
/// grelha · kit veggie · média 28"), e é o valor adotado aqui (A-10).
const Map<ChaveItem, DefinicaoDeItem> catalogoDeItens = {
  ChaveItem.bovina: DefinicaoDeItem(
    chave: ChaveItem.bovina,
    nome: 'BOVINA',
    emoji: '🥩',
    unidade: UnidadeDeItem.kg,
    precoBase: 45,
    passoDeQuantidade: 0.5,
  ),
  ChaveItem.suina: DefinicaoDeItem(
    chave: ChaveItem.suina,
    nome: 'SUÍNA',
    emoji: '🐷',
    unidade: UnidadeDeItem.kg,
    precoBase: 28,
    passoDeQuantidade: 0.5,
  ),
  ChaveItem.frango: DefinicaoDeItem(
    chave: ChaveItem.frango,
    nome: 'FRANGO',
    emoji: '🍗',
    unidade: UnidadeDeItem.kg,
    precoBase: 18,
    passoDeQuantidade: 0.5,
  ),
  ChaveItem.paoDeAlho: DefinicaoDeItem(
    chave: ChaveItem.paoDeAlho,
    nome: 'PÃO DE ALHO',
    emoji: '🧄',
    unidade: UnidadeDeItem.unidade,
    precoBase: 6,
    passoDeQuantidade: 1,
  ),
  ChaveItem.refrigerante: DefinicaoDeItem(
    chave: ChaveItem.refrigerante,
    nome: 'REFRIGERANTE',
    emoji: '🥤',
    unidade: UnidadeDeItem.garrafa,
    precoBase: 9,
    passoDeQuantidade: 1,
  ),
  ChaveItem.suco: DefinicaoDeItem(
    chave: ChaveItem.suco,
    nome: 'SUCO',
    emoji: '🧃',
    unidade: UnidadeDeItem.litro,
    precoBase: 8,
    passoDeQuantidade: 1,
  ),
  ChaveItem.agua: DefinicaoDeItem(
    chave: ChaveItem.agua,
    nome: 'ÁGUA',
    emoji: '💧',
    unidade: UnidadeDeItem.garrafa,
    precoBase: 3,
    passoDeQuantidade: 1,
  ),
  ChaveItem.cerveja: DefinicaoDeItem(
    chave: ChaveItem.cerveja,
    nome: 'CERVEJA',
    emoji: '🍺',
    unidade: UnidadeDeItem.lata,
    precoBase: 4,
    passoDeQuantidade: 2,
  ),
  ChaveItem.vodka: DefinicaoDeItem(
    chave: ChaveItem.vodka,
    nome: 'VODKA',
    emoji: '🍸',
    unidade: UnidadeDeItem.garrafa,
    precoBase: 40,
    passoDeQuantidade: 1,
  ),
  ChaveItem.cachaca: DefinicaoDeItem(
    chave: ChaveItem.cachaca,
    nome: 'CACHAÇA',
    emoji: '🍹',
    unidade: UnidadeDeItem.garrafa,
    precoBase: 15,
    passoDeQuantidade: 1,
  ),
  ChaveItem.whisky: DefinicaoDeItem(
    chave: ChaveItem.whisky,
    nome: 'WHISKY',
    emoji: '🥃',
    unidade: UnidadeDeItem.garrafa,
    precoBase: 90,
    passoDeQuantidade: 1,
  ),
  ChaveItem.legumesParaGrelha: DefinicaoDeItem(
    chave: ChaveItem.legumesParaGrelha,
    nome: 'Legumes p/ grelha (kit veggie)',
    emoji: '🥗',
    unidade: UnidadeDeItem.kit,
    precoBase: 28,
    passoDeQuantidade: 1,
    quantidadeDefault: 1,
  ),
  ChaveItem.carvao: DefinicaoDeItem(
    chave: ChaveItem.carvao,
    nome: 'Carvão',
    emoji: '🔥',
    unidade: UnidadeDeItem.saco,
    precoBase: 22,
    passoDeQuantidade: 1,
    essencial: true,
    fonteDaProporcao: 'kg de carne',
    quantidadeDefault: 1,
  ),
  ChaveItem.gelo: DefinicaoDeItem(
    chave: ChaveItem.gelo,
    nome: 'Gelo',
    emoji: '🧊',
    unidade: UnidadeDeItem.saco,
    precoBase: 10,
    passoDeQuantidade: 1,
    essencial: true,
    fonteDaProporcao: 'volume de bebida gelada',
    quantidadeDefault: 3,
  ),
  ChaveItem.salGrosso: DefinicaoDeItem(
    chave: ChaveItem.salGrosso,
    nome: 'Sal grosso',
    emoji: '🧂',
    unidade: UnidadeDeItem.kg,
    precoBase: 8,
    passoDeQuantidade: 1,
    essencial: true,
    fonteDaProporcao: 'kg de carne',
    quantidadeDefault: 1,
  ),
  ChaveItem.coposEPratos: DefinicaoDeItem(
    chave: ChaveItem.coposEPratos,
    nome: 'Copos & pratos',
    emoji: '🍽️',
    unidade: UnidadeDeItem.kit,
    precoBase: 15,
    passoDeQuantidade: 1,
    essencial: true,
    fonteDaProporcao: 'nº de pessoas',
    quantidadeDefault: 1,
    entraNoTotal: false,
  ),
};

/// A ordem estável em que os itens saem na lista (CALC-15).
///
/// Segue a leitura do arquivo 03: primeiro a grelha, depois a geladeira, os
/// fortes, o kit que RN-21 acrescenta e, por último, o bloco "ESSENCIAIS ·
/// ENTRAM SOZINHOS" de RN-10. É declarada aqui — e não derivada de
/// `ChaveItem.values` — porque a ordem da lista é comportamento observável,
/// não consequência acidental da ordem de declaração do enum.
const List<ChaveItem> ordemCanonicaDaLista = [
  ChaveItem.bovina,
  ChaveItem.suina,
  ChaveItem.frango,
  ChaveItem.paoDeAlho,
  ChaveItem.refrigerante,
  ChaveItem.suco,
  ChaveItem.agua,
  ChaveItem.cerveja,
  ChaveItem.vodka,
  ChaveItem.cachaca,
  ChaveItem.whisky,
  ChaveItem.legumesParaGrelha,
  ChaveItem.carvao,
  ChaveItem.gelo,
  ChaveItem.salGrosso,
  ChaveItem.coposEPratos,
];
