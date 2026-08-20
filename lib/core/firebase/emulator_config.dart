/// Endereço do Emulator Suite visto pelo app.
///
/// As portas espelham `firebase.json`, que é a fonte declarada pela spec — o
/// teste cruza os dois arquivos para que não divirjam em silêncio (risco R-6).
abstract final class EmulatorConfig {
  static const int authPort = 9099;
  static const int firestorePort = 8080;

  static const String localhostHost = 'localhost';

  /// O emulador de Android enxerga a máquina hospedeira neste endereço —
  /// `localhost` ali apontaria para o próprio aparelho virtual (risco R-8).
  static const String androidEmulatorHost = '10.0.2.2';

  /// Host dos emuladores para a plataforma em que o app está rodando.
  ///
  /// No web o código roda no navegador, então `localhost` vale mesmo quando o
  /// sistema por baixo é Android.
  static String host({required bool isAndroid, required bool isWeb}) =>
      isAndroid && !isWeb ? androidEmulatorHost : localhostHost;
}
