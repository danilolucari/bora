import '../dominio/item_de_lista.dart';

/// A soma **exata** dos valores de [itens] — CALC-16.
///
/// Sem arredondar em passo nenhum: o Frango de 1,2 kg vale 21,60 aqui, não 22.
/// Total é o arredondamento da soma exata, nunca a soma de parcelas já
/// arredondadas, e quem arredonda é a formatação de RN-13, uma única vez.
///
/// No caso literal do arquivo 03 as duas contas coincidem em R$ 211 — por isso
/// o caso literal **não discrimina** esta regra, e ela tem teste próprio, com
/// um item de valor fracionário.
double totalExato(Iterable<ItemDeLista> itens) =>
    itens.fold<double>(0, (soma, item) => soma + item.valor);

/// A estimativa rápida "≈ R$ X / cabeça" da tela Montar — RN-10 · CALC-16.
///
/// Divide o total **sem os essenciais** pelo total de **pessoas**, crianças
/// inclusive: no estado padrão, 210,60 ÷ 7 = 30,1 → ≈ R$ 30.
///
/// Este número e o de [estimativaPorAdulto] coexistem de propósito e **nunca**
/// se unificam (RN-14): aqui a criança conta, porque a pergunta é "quanto sai
/// a festa por cabeça"; no racha ela nunca entra, porque a pergunta é "quem
/// paga quanto". São duas telas e duas perguntas diferentes.
///
/// Sem ninguém, a estimativa é **0,0** — nunca `NaN` nem `Infinity`.
double estimativaPorCabeca({
  required double totalDosItens,
  required int pessoas,
}) =>
    pessoas == 0 ? 0 : totalDosItens / pessoas;

/// O "por adulto" da tela Lista — RN-14 · CALC-16.
///
/// Divide o total **com os essenciais** pelo número de **adultos**: no estado
/// padrão, 270,60 ÷ 6 = 45,1 → ≈ R$ 45. Criança fica de fora, sempre (RN-14).
///
/// A assimetria em relação a [estimativaPorCabeca] — outro numerador e outro
/// divisor — é deliberada e é o que faz os dois pares de números do arquivo 03
/// fecharem ao mesmo tempo (A-04).
///
/// Sem adulto, a estimativa é **0,0** — nunca `NaN` nem `Infinity`.
double estimativaPorAdulto({
  required double totalComEssenciais,
  required int adultos,
}) =>
    adultos == 0 ? 0 : totalComEssenciais / adultos;
