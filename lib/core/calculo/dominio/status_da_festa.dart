/// Momento da festa na linha do tempo (arquivo 01 §6 · CALC-05).
enum StatusDaFesta {
  chegando('chegando'),
  passada('passada');

  const StatusDaFesta(this.chave);

  /// Rótulo literal do arquivo 01 §6.
  final String chave;

  /// O status de [chave], ou `null` se a chave não existir.
  static StatusDaFesta? porChave(String chave) {
    for (final status in values) {
      if (status.chave == chave) return status;
    }
    return null;
  }
}
