import 'chave_item.dart';
import 'corredor.dart';
import 'preco_de_mercado.dart';

/// As **oito linhas literais** da tabela de referência de RN-11 — CALC-24.
///
/// Item, corredor, quantidade, média, mín, máx e fontes saem palavra por
/// palavra do arquivo 03. O total declarado na mesma seção — média **R$ 286**,
/// faixa **R$ 234–356** — é a soma destas linhas, e é caso de teste.
///
/// **Esta tabela nunca alimenta a calculadora, e a calculadora nunca alimenta
/// esta tabela** (A-03). Ela é a média real de mercados da tela Lista no modo
/// PLANEJAR; `catalogoDeItens` é o preço-base de RN-03..RN-10, que produz o
/// R$ 211. Que a Picanha bovina apareça aqui com média 65 e lá com R$ 45/kg
/// **não é bug**: o preço-base coincide com o **mín** desta faixa (54 = 45 ×
/// 1,2 kg), não com a média. Unificar as duas quebraria um dos casos literais.
///
/// As duas tabelas também não cobrem o mesmo conjunto: aqui há 🌭 Linguiça
/// toscana, que não tem chip em T-03 e por isso entra com [PrecoDeMercado
/// .chave] `null`; e faltam água, suco, sal grosso, copos e destilados, que a
/// calculadora tem.
const List<PrecoDeMercado> tabelaDePrecosDeMercado = [
  PrecoDeMercado(
    nome: 'Picanha bovina',
    emoji: '🥩',
    corredor: Corredor.acougue,
    rotuloDeQuantidade: '1,2 kg',
    media: 65,
    minimo: 54,
    maximo: 83,
    fontes: 4,
    chave: ChaveItem.bovina,
  ),
  PrecoDeMercado(
    nome: 'Linguiça toscana',
    emoji: '🌭',
    corredor: Corredor.acougue,
    rotuloDeQuantidade: '1 kg',
    media: 23,
    minimo: 18,
    maximo: 29,
    fontes: 3,
    // Sem `chave`: RN-11 lista a linguiça, os chips de T-03 não. Ver R-6.
  ),
  PrecoDeMercado(
    nome: 'Legumes p/ grelha',
    emoji: '🥗',
    corredor: Corredor.hortifruti,
    rotuloDeQuantidade: 'kit veggie',
    media: 28,
    minimo: 22,
    maximo: 35,
    fontes: 2,
    chave: ChaveItem.legumesParaGrelha,
  ),
  PrecoDeMercado(
    nome: 'Pão de alho',
    emoji: '🧄',
    corredor: Corredor.padaria,
    rotuloDeQuantidade: '4 un',
    media: 24,
    minimo: 20,
    maximo: 30,
    fontes: 3,
    chave: ChaveItem.paoDeAlho,
  ),
  PrecoDeMercado(
    nome: 'Cerveja',
    emoji: '🍺',
    corredor: Corredor.bebidas,
    rotuloDeQuantidade: '18 latas',
    media: 76,
    minimo: 64,
    maximo: 92,
    fontes: 4,
    chave: ChaveItem.cerveja,
  ),
  PrecoDeMercado(
    nome: 'Refrigerante',
    emoji: '🥤',
    corredor: Corredor.bebidas,
    rotuloDeQuantidade: '2 gf 2 L',
    media: 18,
    minimo: 14,
    maximo: 23,
    fontes: 3,
    chave: ChaveItem.refrigerante,
  ),
  PrecoDeMercado(
    nome: 'Carvão 5 kg',
    emoji: '🔥',
    corredor: Corredor.mercearia,
    rotuloDeQuantidade: '1 saco',
    media: 22,
    minimo: 18,
    maximo: 28,
    fontes: 3,
    chave: ChaveItem.carvao,
  ),
  PrecoDeMercado(
    nome: 'Gelo',
    emoji: '🧊',
    corredor: Corredor.mercearia,
    rotuloDeQuantidade: '3 sacos',
    media: 30,
    minimo: 24,
    maximo: 36,
    fontes: 2,
    chave: ChaveItem.gelo,
  ),
];
