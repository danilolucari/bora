/// Resposta de uma pessoa ao convite (arquivo 01 §6 · CALC-05).
enum StatusDePresenca {
  confirmado('confirmado'),
  pendente('pendente'),
  recusou('recusou');

  const StatusDePresenca(this.chave);

  /// Rótulo literal do arquivo 01 §6.
  final String chave;

  /// O status de [chave], ou `null` se a chave não existir.
  static StatusDePresenca? porChave(String chave) {
    for (final status in values) {
      if (status.chave == chave) return status;
    }
    return null;
  }
}
