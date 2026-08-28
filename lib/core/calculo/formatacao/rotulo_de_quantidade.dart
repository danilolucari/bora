import '../dominio/chave_item.dart';

/// Rótulo da quantidade de um item da lista: `1,2 kg` · `8 latas` ·
/// `2 garrafas` · `1 kit`.
///
/// SPEC_DEVIATION: **nenhuma RN define este rótulo.** Ele nasce aqui, e não em
/// `lib/features/montar/**`, porque a `spec.md` de `montar` proíbe formatação
/// de número na feature — decidir casas decimais, vírgula do pt-BR e plural é
/// formatação, irmã de [MoneyFormatter] e de `rotuloDeDuracao`. Escrevê-lo no
/// widget seria a primeira fórmula vazando, que é o risco nº 1 declarado na
/// spec. A camada estava fechada; a própria `spec.md` previu este caminho:
/// *"conta que faltar **nasce lá**, como desvio registrado, nunca aqui"*.
///
/// **Nenhum número novo entra no sistema**: a regra de arredondamento é
/// herdada, não inventada — inteiro quando a quantidade é inteira, **uma** casa
/// decimal quando não é, que é o mesmo 0,1 kg que a AD-009 já fixa para a
/// carne.
///
/// SPEC_PRECISION_GAP: a spec-fonte só escreve quantidade por extenso em
/// abreviação (`Pão 4 un`, `Refri 2 gf`, em RN-30) e o `design.md` §7.2 dá
/// quatro exemplos — `kg`, `latas`, `garrafas`, `kit`. Os nomes das outras
/// três unidades (`unidade`, `litro`, `saco`) seguem o mesmo padrão: o
/// substantivo da unidade, pluralizado. Nenhuma tela do M1 os exibe abreviados.
///
/// Mesmo contrato de [MoneyFormatter]: **a UI recebe o rótulo pronto.**
String rotuloDeQuantidade(double quantidade, UnidadeDeItem unidade) {
  final arredondada = _emUmaCasa(quantidade);

  return '${_numero(arredondada)} '
      '${_nomeDa(unidade, singular: arredondada == 1)}';
}

/// A quantidade com **uma** casa decimal — a precisão de AD-009.
///
/// Arredondar antes de escrever é o que faz `1,98 kg` virar `2 kg`, e não
/// `2,0 kg`: a decisão "é inteiro?" tem de valer sobre o número que vai ser
/// exibido, nunca sobre o que veio da calculadora.
double _emUmaCasa(double quantidade) => (quantidade * 10).round() / 10;

/// O número em pt-BR: sem casa decimal quando é inteiro, com **uma** e
/// vírgula quando não é.
String _numero(double quantidade) => quantidade == quantidade.roundToDouble()
    ? quantidade.toStringAsFixed(0)
    : quantidade.toStringAsFixed(1).replaceAll('.', ',');

/// O nome da unidade, no singular só quando a quantidade é exatamente 1.
///
/// `switch` exaustivo de propósito: uma unidade nova em [UnidadeDeItem]
/// **quebra a compilação** aqui, em vez de sair da tela com o plural errado.
///
/// `kg` não pluraliza — é símbolo de unidade de medida, não substantivo.
String _nomeDa(UnidadeDeItem unidade, {required bool singular}) =>
    switch (unidade) {
      UnidadeDeItem.kg => 'kg',
      UnidadeDeItem.unidade => singular ? 'unidade' : 'unidades',
      UnidadeDeItem.garrafa => singular ? 'garrafa' : 'garrafas',
      UnidadeDeItem.lata => singular ? 'lata' : 'latas',
      UnidadeDeItem.litro => singular ? 'litro' : 'litros',
      UnidadeDeItem.saco => singular ? 'saco' : 'sacos',
      UnidadeDeItem.kit => singular ? 'kit' : 'kits',
    };
