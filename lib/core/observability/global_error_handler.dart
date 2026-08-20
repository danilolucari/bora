import 'package:flutter/foundation.dart';

import 'app_logger.dart';

/// Arma os handlers globais de erro: nenhuma exceção fora de BLoC some em
/// silêncio (FUND-14).
///
/// Roda **depois** do binding do Flutter e **antes** da inicialização do
/// Firebase — é o que dá a FUND-17 onde registrar a queda do emulador.
///
// SPEC_DEVIATION: o design pede
// `WidgetsBinding.instance.platformDispatcher.onError`; aqui o alvo é
// `PlatformDispatcher.instance`.
// Reason: em produção são o mesmo objeto (`BindingBase.platformDispatcher`
// devolve `PlatformDispatcher.instance`), mas sob `flutter_test` o binding
// entrega um `TestPlatformDispatcher` cujo setter de `onError` é no-op
// (flutter_test/lib/src/window.dart:915) — pela via do binding, a metade de
// plataforma de FUND-14 seria inverificável.
void installGlobalErrorHandlers(AppLogger logger) {
  FlutterError.onError = (details) {
    logger.logError(details.exception, details.stack, name: 'flutter');
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.logError(error, stackTrace, name: 'platform');
    return true;
  };
}
