import 'package:bora/bootstrap/app_bootstrap.dart';
import 'package:bora/core/observability/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/recording_app_logger.dart';

/// Passo que o boot anota ao executar.
const String _binding = 'ensureBinding';
const String _observabilidade = 'installObservability';
const String _firebase = 'initializeFirebase';
const String _emuladores = 'connectEmulators';
const String _di = 'configureDependencies';
const String _app = 'startApp';

/// Monta um boot cujos passos só registram o próprio nome em [passos].
///
/// [falhaNoFirebase] e [falhaNoEmulador] fazem o passo correspondente lançar,
/// depois de anotado — é assim que a suíte derruba a dependência externa sem
/// precisar de SDK nem de emulador.
AppBootstrap _bootDeMentira(
  List<String> passos, {
  required AppLogger logger,
  Object? falhaNoFirebase,
  Object? falhaNoEmulador,
}) {
  return AppBootstrap(
    logger: logger,
    ensureBinding: () => passos.add(_binding),
    installObservability: () => passos.add(_observabilidade),
    initializeFirebase: () async {
      passos.add(_firebase);
      if (falhaNoFirebase != null) throw falhaNoFirebase;
    },
    connectEmulators: () async {
      passos.add(_emuladores);
      if (falhaNoEmulador != null) throw falhaNoEmulador;
    },
    configureDependencies: () async => passos.add(_di),
  );
}

void main() {
  group('FUND-15 — a ordem de inicialização é determinística', () {
    test('binding, observabilidade, firebase, emuladores, DI e só então o app',
        () async {
      final passos = <String>[];
      final logger = RecordingAppLogger();

      await _bootDeMentira(passos, logger: logger).run(() => passos.add(_app));

      expect(passos, [
        _binding,
        _observabilidade,
        _firebase,
        _emuladores,
        _di,
        _app,
      ]);
    });

    test('o boot feliz não registra erro nenhum', () async {
      final passos = <String>[];
      final logger = RecordingAppLogger();

      await _bootDeMentira(passos, logger: logger).run(() => passos.add(_app));

      expect(logger.erros, isEmpty);
    });
  });

  group('FUND-17 — o Firebase fora do ar é degradação, não crash', () {
    test('a inicialização do Firebase falha e o app abre mesmo assim',
        () async {
      final passos = <String>[];
      final logger = RecordingAppLogger();

      await _bootDeMentira(
        passos,
        logger: logger,
        falhaNoFirebase: StateError('firebase fora do ar'),
      ).run(() => passos.add(_app));

      expect(passos, [_binding, _observabilidade, _firebase, _di, _app]);
      expect(passos.last, _app);
    });

    test('a falha do Firebase é registrada com exceção e stack trace',
        () async {
      final passos = <String>[];
      final logger = RecordingAppLogger();
      final falha = StateError('firebase fora do ar');

      await _bootDeMentira(passos, logger: logger, falhaNoFirebase: falha)
          .run(() => passos.add(_app));

      expect(logger.erros, hasLength(1));
      expect(logger.erros.single.error, same(falha));
      expect(logger.erros.single.stackTrace, isNotNull);
    });

    test('o emulador fora do ar não impede o app de abrir', () async {
      final passos = <String>[];
      final logger = RecordingAppLogger();
      final falha = StateError('emulador fora do ar');

      await _bootDeMentira(passos, logger: logger, falhaNoEmulador: falha)
          .run(() => passos.add(_app));

      expect(
        passos,
        [_binding, _observabilidade, _firebase, _emuladores, _di, _app],
      );
      expect(logger.erros.single.error, same(falha));
    });
  });
}
