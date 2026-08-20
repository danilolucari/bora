import 'dart:developer' as developer;

/// Sink único de observabilidade do app.
///
/// É interface, e não classe concreta, porque é a costura que torna
/// "o observador registrou" afirmável em teste: a suíte injeta um duplo e lê o
/// que foi registrado.
abstract interface class AppLogger {
  /// Registra um acontecimento — transição de bloc, passo de boot, etc.
  void logEvent(String message, {String? name, Object? data});

  /// Registra uma falha com a exceção e, quando houver, o stack trace.
  void logError(Object error, StackTrace? stackTrace, {String? name});
}

/// Implementação de desenvolvimento: escreve em `dart:developer`, que só tem
/// efeito com o VM service conectado — em release é inerte.
class DebugAppLogger implements AppLogger {
  const DebugAppLogger();

  @override
  void logEvent(String message, {String? name, Object? data}) {
    developer.log(
      data == null ? message : '$message · $data',
      name: name ?? 'bora',
    );
  }

  @override
  void logError(Object error, StackTrace? stackTrace, {String? name}) {
    developer.log(
      '$error',
      name: name ?? 'bora',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
