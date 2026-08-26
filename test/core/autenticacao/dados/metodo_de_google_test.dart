import 'package:bora/core/autenticacao/dados/metodo_de_google.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ENT-14 — a escolha do método por plataforma', () {
    test('no web é signInWithPopup', () {
      expect(
        metodoDeGooglePara(isWeb: true),
        MetodoDeGoogle.popup,
        reason: 'firebase_auth_web 6.2.6 não sobrescreve signInWithProvider: '
            'a chamada cairia no throw UnimplementedError do platform '
            'interface e o login com Google quebraria só no navegador',
      );
    });

    test('fora do web é signInWithProvider', () {
      expect(
        metodoDeGooglePara(isWeb: false),
        MetodoDeGoogle.provider,
        reason: 'implementado no method channel — é o que dispensa o pacote '
            'google_sign_in e mantém zero dependência nova (AD-002)',
      );
    });

    test('os dois ramos são distintos', () {
      expect(
        metodoDeGooglePara(isWeb: true),
        isNot(metodoDeGooglePara(isWeb: false)),
        reason: 'anti-vácuo: um método só para as duas plataformas seria '
            'exatamente o bug que esta função existe para impedir',
      );
    });
  });
}
