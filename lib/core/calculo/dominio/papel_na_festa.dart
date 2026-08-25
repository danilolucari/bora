/// Papel de uma pessoa na festa (arquivo 01 §6 · CALC-05).
///
/// Só o enum: a **tabela de permissões** de RN-22/RN-23 é domínio de `galera`
/// e não mora nesta camada.
enum PapelNaFesta {
  anfitriao('host'),
  coAnfitriao('cohost'),
  convidado('guest'),
  soVe('viewer');

  const PapelNaFesta(this.chave);

  /// Rótulo literal do arquivo 01 §6.
  final String chave;

  /// O papel de [chave], ou `null` se a chave não existir.
  static PapelNaFesta? porChave(String chave) {
    for (final papel in values) {
      if (papel.chave == chave) return papel;
    }
    return null;
  }
}
