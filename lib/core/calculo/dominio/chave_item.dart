/// Identidade de cada item que a calculadora conhece (CALC-05).
///
/// A [chave] é o rótulo snake_case do dado bruto — o mesmo vocabulário de
/// `itensPadraoRn30` em `test/fixtures/rn30_estado_inicial.dart`. É por ela
/// que o dado serializado (RN-30 hoje, Firestore depois) volta a ser tipo.
///
/// São **16**: as três carnes e os oito consumíveis dos chips de T-03, o kit
/// veggie que RN-21 acrescenta e os quatro essenciais de RN-10.
enum ChaveItem {
  bovina('bovina'),
  suina('suina'),
  frango('frango'),
  paoDeAlho('pao_de_alho'),
  refrigerante('refrigerante'),
  suco('suco'),
  agua('agua'),
  cerveja('cerveja'),
  vodka('vodka'),
  cachaca('cachaca'),
  whisky('whisky'),
  legumesParaGrelha('legumes_para_grelha'),
  carvao('carvao'),
  gelo('gelo'),
  salGrosso('sal_grosso'),
  coposEPratos('copos_e_pratos');

  const ChaveItem(this.chave);

  /// Rótulo snake_case do item no dado bruto.
  final String chave;

  /// O item de [chave], ou `null` se a chave não existir — quem converte dado
  /// bruto decide o que fazer com o desconhecido, em vez de receber um default
  /// inventado.
  static ChaveItem? porChave(String chave) {
    for (final item in values) {
      if (item.chave == chave) return item;
    }
    return null;
  }
}

/// Unidade em que a quantidade de um item é contada e comprada.
///
/// Sai literal de RN-03..RN-10: carne em `kg`, pão de alho em `unidade`,
/// refrigerante e água em `garrafa`, suco em `litro`, cerveja em `lata`,
/// destilado em `garrafa` de 1 L, carvão e gelo em `saco`, sal grosso em `kg`,
/// copos & pratos e legumes em `kit`.
enum UnidadeDeItem {
  kg,
  unidade,
  garrafa,
  lata,
  litro,
  saco,
  kit,
}
