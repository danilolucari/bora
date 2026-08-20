import 'package:bora/core/observability/global_error_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/recording_app_logger.dart';

void main() {
  late RecordingAppLogger logger;
  late FlutterExceptionHandler? handlerDeFrameworkAnterior;
  late bool Function(Object, StackTrace)? handlerDePlataformaAnterior;

  final erro = Exception('erro fora de bloc');
  final stack = StackTrace.current;

  setUp(() {
    logger = RecordingAppLogger();
    handlerDeFrameworkAnterior = FlutterError.onError;
    handlerDePlataformaAnterior = PlatformDispatcher.instance.onError;
    installGlobalErrorHandlers(logger);
  });

  tearDown(() {
    FlutterError.onError = handlerDeFrameworkAnterior;
    PlatformDispatcher.instance.onError = handlerDePlataformaAnterior;
  });

  group('FUND-14 — exceção fora de BLoC é registrada, não descartada', () {
    test('erro do framework chega ao logger com exceção e stack trace', () {
      FlutterError.onError!(FlutterErrorDetails(exception: erro, stack: stack));

      expect(logger.erros.single.error, same(erro));
      expect(logger.erros.single.stackTrace, same(stack));
    });

    test('erro assíncrono da plataforma chega ao logger com exceção e stack',
        () {
      PlatformDispatcher.instance.onError!(erro, stack);

      expect(logger.erros.single.error, same(erro));
      expect(logger.erros.single.stackTrace, same(stack));
    });

    test('o handler da plataforma devolve true — erro tratado, não repassado',
        () {
      expect(PlatformDispatcher.instance.onError!(erro, stack), isTrue);
    });
  });
}
