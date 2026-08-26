/// A copy da Home — T-02 e W-02.
///
/// Fica junta e nomeada pelo mesmo motivo de `entrar_textos.dart`: literal de
/// copy espalhado por dois layouts diverge no primeiro ajuste, e a spec pede a
/// **mesma** frase nas duas plataformas.
abstract final class HomeTextos {
  /// T-02 e W-02: o título da tela.
  static const String titulo = 'SEUS ROLÊS';

  /// O subtítulo, **derivado** da contagem real (A-05).
  ///
  /// T-02 escreve "1 festa chegando · 2 passadas", que é o que sai da fixture
  /// de RN-30 — mas como consequência do dado, não como literal fixo: um
  /// literal mentiria em qualquer outro estado da Home.
  ///
  /// Sem festa chegando, a metade da esquerda vira "nenhuma festa chegando"
  /// (HOME-15 AC1); sem passada nenhuma, a metade da direita simplesmente não
  /// aparece — "· 0 passadas" seria ruído.
  static String subtitulo({required int chegando, required int passadas}) {
    final esquerda = chegando == 0
        ? 'nenhuma festa chegando'
        : '$chegando ${_plural(chegando, 'festa')} chegando';

    if (passadas == 0) return esquerda;

    return '$esquerda · $passadas ${_plural(passadas, 'passada')}';
  }

  static String _plural(int quantos, String palavra) =>
      quantos == 1 ? palavra : '${palavra}s';
}
