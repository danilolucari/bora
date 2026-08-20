import 'package:bora/core/observability/app_logger.dart';

/// O que um `logEvent` registrou.
class RegistroDeEvento {
  const RegistroDeEvento(this.message, {this.name, this.data});

  final String message;
  final String? name;
  final Object? data;

  /// `data` lido como mapa — é a forma que `AppBlocObserver` usa.
  Map<String, Object?> get dados => data! as Map<String, Object?>;
}

/// O que um `logError` registrou.
class RegistroDeErro {
  const RegistroDeErro(this.error, this.stackTrace, {this.name});

  final Object error;
  final StackTrace? stackTrace;
  final String? name;
}

/// Duplo de teste do [AppLogger]: guarda o que foi registrado, em ordem.
///
/// É a costura que torna "o observador registrou" afirmável.
class RecordingAppLogger implements AppLogger {
  final List<RegistroDeEvento> eventos = [];
  final List<RegistroDeErro> erros = [];

  @override
  void logEvent(String message, {String? name, Object? data}) {
    eventos.add(RegistroDeEvento(message, name: name, data: data));
  }

  @override
  void logError(Object error, StackTrace? stackTrace, {String? name}) {
    erros.add(RegistroDeErro(error, stackTrace, name: name));
  }
}
