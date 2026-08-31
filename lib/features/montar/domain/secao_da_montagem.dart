import '../../../core/calculo/calculo.dart';

/// As três seções em que T-03 e W-03 agrupam o que vai ter no rolê —
/// MONT-01, e o agrupamento da lista viva (A-07).
///
/// Dart puro: este arquivo fala só em tipos de `core/calculo`, pelo barrel.
/// Os **rótulos** ("NA GRELHA", "NA GELADEIRA", "PROS FORTES") não moram aqui
/// — copy é da camada de apresentação.
enum SecaoDaMontagem { naGrelha, naGeladeira, prosFortes }

/// Os 11 chips do formulário, por seção, **na ordem literal** de T-03/W-03.
///
/// "PROS FORTES" existe nas **duas** plataformas (**AD-018**): sem ela o
/// mobile fecharia R$ 196 em vez dos R$ 211 que o aceite de UC-03 exige, e o
/// aceite ficaria impossível na própria tela que o descreve.
///
/// Os quatro essenciais de RN-10 e o kit veggie de RN-21 **não** têm chip: os
/// primeiros entram sozinhos (A-06) e o segundo entra por preferência (A-08).
const Map<SecaoDaMontagem, List<ChaveItem>> chipsPorSecao = {
  SecaoDaMontagem.naGrelha: [
    ChaveItem.bovina,
    ChaveItem.suina,
    ChaveItem.frango,
  ],
  SecaoDaMontagem.naGeladeira: [
    ChaveItem.paoDeAlho,
    ChaveItem.refrigerante,
    ChaveItem.suco,
    ChaveItem.agua,
    ChaveItem.cerveja,
  ],
  SecaoDaMontagem.prosFortes: [
    ChaveItem.vodka,
    ChaveItem.cachaca,
    ChaveItem.whisky,
  ],
};

/// A seção de um item **calculado** — inclusive o que não tem chip.
///
/// É a **mesma** declaração que governa o formulário: duas listas separadas
/// divergiriam no primeiro ajuste, e a lista viva mostraria um item numa
/// categoria em que o chip não está (A-07).
///
/// - `legumesParaGrelha` → [SecaoDaMontagem.naGrelha]: entra sozinho por
///   RN-21, é item de grelha, e não tem chip (A-08).
/// - os quatro essenciais de RN-10 → `null`: **não** aparecem na lista viva
///   desta tela (A-06), senão a soma da lista divergiria do card-herói.
///
/// `switch` exaustivo de propósito: um item novo em `ChaveItem` **quebra a
/// compilação** em vez de sumir da tela sem ninguém notar.
SecaoDaMontagem? secaoDe(ChaveItem chave) => switch (chave) {
      ChaveItem.bovina ||
      ChaveItem.suina ||
      ChaveItem.frango ||
      ChaveItem.legumesParaGrelha =>
        SecaoDaMontagem.naGrelha,
      ChaveItem.paoDeAlho ||
      ChaveItem.refrigerante ||
      ChaveItem.suco ||
      ChaveItem.agua ||
      ChaveItem.cerveja =>
        SecaoDaMontagem.naGeladeira,
      ChaveItem.vodka ||
      ChaveItem.cachaca ||
      ChaveItem.whisky =>
        SecaoDaMontagem.prosFortes,
      ChaveItem.carvao ||
      ChaveItem.gelo ||
      ChaveItem.salGrosso ||
      ChaveItem.coposEPratos =>
        null,
    };
