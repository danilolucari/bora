/// Qual chamada do SDK atende o Google em cada plataforma.
enum MetodoDeGoogle {
  /// `signInWithPopup` — o caminho do **web**.
  popup,

  /// `signInWithProvider` — o caminho de Android e iOS.
  provider,
}

/// Escolhe o método pelo destino da build — ENT-14.
///
/// Existe como função pura, e não como um `if (kIsWeb)` enterrado dentro do
/// repositório, porque **o ramo errado só falha em runtime, no navegador**:
/// nem o compilador nem `flutter test` pegam. Isolada, a escolha vira tabela
/// de teste.
///
/// ## Por que o web não pode usar `signInWithProvider`
///
/// `firebase_auth_web-6.2.6` **não sobrescreve** `signInWithProvider`. A
/// chamada cai no default do platform interface, que faz
/// `throw UnimplementedError('signInWithProvider() is not implemented')`
/// (`firebase_auth_platform_interface-9.0.6/lib/src/platform_interface/platform_interface_firebase_auth.dart:595`).
/// Ou seja: usar o método "universal" quebraria o login com Google no web, em
/// silêncio, só em produção.
///
/// No mobile o caminho inverso vale: `signInWithProvider` **é** implementado
/// no method channel
/// (`.../method_channel/method_channel_firebase_auth.dart:444`), e é o que
/// dispensa o pacote `google_sign_in` — nenhuma dependência nova (AD-002).
MetodoDeGoogle metodoDeGooglePara({required bool isWeb}) =>
    isWeb ? MetodoDeGoogle.popup : MetodoDeGoogle.provider;
