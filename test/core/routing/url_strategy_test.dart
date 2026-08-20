import 'package:bora/core/routing/url_strategy/url_strategy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FUND-01/FUND-10 — a estratégia de URL não amarra o app ao navegador',
      () {
    // Este teste guarda o import condicional: se o barrel passasse a apontar
    // direto para `flutter_web_plugins`, o alvo não-web deixaria de resolver e
    // o mesmo `main.dart` não serviria as duas plataformas. Fora do navegador,
    // não fazer nada **é** o comportamento especificado.
    test('na VM configurar a estratégia é inerte e não lança', () {
      expect(configureUrlStrategy, returnsNormally);
    });
  });
}
