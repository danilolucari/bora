/// Dieta declarada por uma pessoa nomeada (arquivo 01 §6 · CALC-05).
///
/// A [chave] é o rótulo literal da spec — o mesmo que aparece no dado bruto de
/// RN-30 (`test/fixtures/rn30_estado_inicial.dart`).
///
/// Alimenta RN-21: `veggie` acrescenta o kit de legumes e `semPorco` remove a
/// carne suína. Ausência de dieta é `null` em `Pessoa.dieta`, **não**
/// [Dieta.tudo] (A-08).
enum Dieta {
  tudo('tudo'),
  veggie('veggie'),
  semPorco('semporco');

  const Dieta(this.chave);

  /// Rótulo literal do arquivo 01 §6.
  final String chave;

  /// A dieta de [chave], ou `null` se a chave não existir — quem converte dado
  /// bruto decide o que fazer com o desconhecido, em vez de receber um default
  /// inventado.
  static Dieta? porChave(String chave) {
    for (final dieta in values) {
      if (dieta.chave == chave) return dieta;
    }
    return null;
  }
}
