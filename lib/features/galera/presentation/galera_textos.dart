/// A copy da tela A GALERA — T-05, W-04, RN-21, RN-23 e RN-29.
///
/// Fica junta e nomeada pelo mesmo motivo de `home_textos.dart`: literal de
/// copy espalhado por dois layouts diverge no primeiro ajuste, e a spec pede a
/// **mesma** frase nas duas plataformas.
abstract final class GaleraTextos {
  /// A URL do convite — RN-23.
  ///
  /// **Um lugar só**, e é o que faz a string exibida no card e a string
  /// escrita na área de transferência serem a mesma — inclusive quando o
  /// código tiver caractere que exigiria escape (Edge Case da `spec.md`).
  /// Montá-la em dois lugares seria montá-la de dois jeitos no primeiro
  /// ajuste.
  ///
  /// Não mora em `ConviteDaFesta`: o convite é dado, e o domínio da URL é
  /// apresentação.
  static String urlDoConvite(String codigo) => 'bora.app/c/$codigo';
}
