/// Estratégia de URL do navegador, resolvida em tempo de compilação.
///
/// O ramo web usa `usePathUrlStrategy()`; o ramo mobile não faz nada. É o que
/// permite que o **mesmo** `main.dart` compile nas duas plataformas (FUND-01)
/// enquanto a URL no navegador continua sem `#` (FUND-10).
library;

export 'url_strategy_stub.dart'
    if (dart.library.js_interop) 'url_strategy_web.dart';
