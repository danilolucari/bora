import 'bloc/home_state.dart';

/// A copy da Home — T-02 e W-02.
///
/// Fica junta e nomeada pelo mesmo motivo de `entrar_textos.dart`: literal de
/// copy espalhado por dois layouts diverge no primeiro ajuste, e a spec pede a
/// **mesma** frase nas duas plataformas.
abstract final class HomeTextos {
  /// T-02 e W-02: o título da tela.
  static const String titulo = 'SEUS ROLÊS';

  /// A mensagem do estado `falhou` (HOME-16).
  ///
  /// SPEC_PRECISION_GAP: nenhuma tela de `04` ou `06` desenha a Home falhando,
  /// e nenhuma spec dá esta copy. O `design.md` só diz "mensagem de falha, e
  /// COMEÇAR OUTRA permanece acessível". A frase copia a **voz** que a spec 03
  /// já fixou para falha de carregamento (`EntrarTextos.indisponivel`, "NÃO
  /// DEU PRA ENTRAR AGORA"), em caixa alta como §7 manda para label. Fica
  /// declarada como premissa, não como literal de spec.
  static const String falha = 'NÃO DEU PRA CARREGAR SEUS ROLÊS';

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
        : '$chegando ${plural(chegando, 'festa')} chegando';

    if (passadas == 0) return esquerda;

    return '$esquerda · $passadas ${plural(passadas, 'passada')}';
  }

  /// O subtítulo **desta situação**, ou `null` quando a Home não tem o que
  /// dizer sobre contagem.
  ///
  /// Carregando e falhando não são "nenhuma festa chegando": a tela afirmaria
  /// que o usuário não tem rolê nenhum no mesmo instante em que diz que não
  /// conseguiu carregá-los. Sem contagem verdadeira, a Home cala.
  static String? subtituloDe(
    SituacaoDaHome situacao, {
    required int chegando,
    required int passadas,
  }) =>
      situacao == SituacaoDaHome.comFestas || situacao == SituacaoDaHome.vazia
          ? subtitulo(chegando: chegando, passadas: passadas)
          : null;

  /// "{n} {palavra}" com o plural em PT-BR — a regra mora num lugar só.
  static String contagem(int quantos, String palavra) =>
      '$quantos ${plural(quantos, palavra)}';

  /// [palavra] no plural quando [quantos] não é 1.
  static String plural(int quantos, String palavra) =>
      quantos == 1 ? palavra : '${palavra}s';
}
