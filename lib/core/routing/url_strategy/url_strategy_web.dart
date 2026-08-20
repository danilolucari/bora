import 'package:flutter_web_plugins/url_strategy.dart';

/// No navegador, a rota vira caminho de verdade: `bora.app/roles`, e não
/// `bora.app/#/roles` (FUND-10).
void configureUrlStrategy() => usePathUrlStrategy();
