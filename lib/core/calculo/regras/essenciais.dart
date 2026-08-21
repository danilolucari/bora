import '../dominio/catalogo_de_itens.dart';
import '../dominio/item_de_lista.dart';

/// Os quatro itens que entram na lista **sozinhos** — RN-10 · CALC-14.
///
/// Saem na ordem canônica do catálogo, que termina exatamente no bloco
/// "ESSENCIAIS · ENTRAM SOZINHOS" de RN-10: 🔥 Carvão · 🧊 Gelo · 🧂 Sal
/// grosso · 🍽️ Copos & pratos.
///
/// **As quantidades são os defaults de RN-10, fixas** (1 saco de carvão,
/// 3 sacos de gelo, 1 kg de sal, 1 kit). RN-10 dá a cada essencial um badge
/// `AUTO ∝ <fonte>`, mas **nenhuma fórmula** de proporcionalidade — a fonte é
/// metadado do item, para o badge, e nada mais (A-09). Inventar uma escala
/// aqui mudaria o caso literal de R$ 271 do arquivo 03.
List<ItemDeLista> essenciaisAutomaticos() => ordemCanonicaDaLista
    .map((chave) => catalogoDeItens[chave]!)
    .where((definicao) => definicao.essencial)
    .map(_essencialDe)
    .toList();

/// Soma o valor **apenas** dos essenciais que entram no total — RN-10 ·
/// CALC-14.
///
/// Aparecer na lista e somar no total são duas coisas diferentes, e quem
/// separa as duas é o `entraNoTotal` do catálogo (A-01/A-02): os quatro
/// aparecem, três somam. Carvão 22 + Gelo 30 + Sal 8 = 60, com 🍽️ Copos &
/// pratos (15) visível na lista e fora desta conta — é o que faz
/// 210,60 + 60 = 270,60 fechar em **R$ 271** e ≈**R$ 45**/adulto.
///
/// A soma é exata, sem arredondar: dinheiro só arredonda na formatação
/// (RN-13).
double totalDosEssenciais(Iterable<ItemDeLista> essenciais) => essenciais
    .where((item) => catalogoDeItens[item.chave]!.entraNoTotal)
    .fold<double>(0, (soma, item) => soma + item.valor);

/// Transforma a definição de catálogo de um essencial no item calculado, com a
/// quantidade default de RN-10 e a fonte da proporção preservada para o badge.
ItemDeLista _essencialDe(DefinicaoDeItem definicao) => ItemDeLista(
      chave: definicao.chave,
      nome: definicao.nome,
      emoji: definicao.emoji,
      unidade: definicao.unidade,
      quantidadeAutomatica: definicao.quantidadeDefault!,
      precoBase: definicao.precoBase,
      essencial: definicao.essencial,
      fonteDaProporcao: definicao.fonteDaProporcao,
    );
