import 'dart:async';

import 'package:bora/core/observability/app_bloc_observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/recording_app_logger.dart';

sealed class _ContadorEvento {
  const _ContadorEvento();
}

final class _Incrementar extends _ContadorEvento {
  const _Incrementar();
}

final class _Explodir extends _ContadorEvento {
  const _Explodir();
}

class _FalhaDeProposito implements Exception {
  const _FalhaDeProposito();

  @override
  String toString() => 'falha de propósito';
}

/// Bloc de mentira do Independent Test de FUND-13: emite estado e depois lança.
class _ContadorBloc extends Bloc<_ContadorEvento, int> {
  _ContadorBloc() : super(0) {
    on<_Incrementar>((evento, emit) => emit(state + 1));
    on<_Explodir>((evento, emit) => throw const _FalhaDeProposito());
  }
}

class _ContadorCubit extends Cubit<int> {
  _ContadorCubit() : super(0);

  void incrementar() => emit(state + 1);
}

void main() {
  late RecordingAppLogger logger;
  late BlocObserver observadorAnterior;

  setUp(() {
    logger = RecordingAppLogger();
    observadorAnterior = Bloc.observer;
    Bloc.observer = AppBlocObserver(logger);
  });

  tearDown(() => Bloc.observer = observadorAnterior);

  group('FUND-13 — o observador global registra o que os blocs fazem', () {
    test('transição identifica o bloc, o evento e o estado resultante',
        () async {
      final bloc = _ContadorBloc();
      addTearDown(bloc.close);

      bloc.add(const _Incrementar());
      await bloc.stream.first;

      final transicao = logger.eventos.singleWhere(
        (e) => e.message == AppBlocObserver.mensagemDeTransicao,
      );
      expect(transicao.dados['bloc'], '_ContadorBloc');
      expect(transicao.dados['evento'], isA<_Incrementar>());
      expect(transicao.dados['estado'], 1);
    });

    test('mudança de cubit é registrada — Cubit não emite transição', () async {
      final cubit = _ContadorCubit();
      addTearDown(cubit.close);

      cubit.incrementar();

      final mudanca = logger.eventos.singleWhere(
        (e) => e.message == AppBlocObserver.mensagemDeMudanca,
      );
      expect(mudanca.dados['bloc'], '_ContadorCubit');
      expect(mudanca.dados['estado'], 1);
      expect(
        logger.eventos.where(
          (e) => e.message == AppBlocObserver.mensagemDeTransicao,
        ),
        isEmpty,
      );
    });

    test('bloc que lança tem a exceção registrada', () async {
      await _rodaBlocQueLanca();

      expect(logger.erros.single.error, isA<_FalhaDeProposito>());
      expect(logger.erros.single.name, '_ContadorBloc');
    });

    test('bloc que lança tem o stack trace registrado', () async {
      await _rodaBlocQueLanca();

      expect(logger.erros.single.stackTrace, isNotNull);
      expect(
        logger.erros.single.stackTrace.toString(),
        contains('_ContadorBloc'),
      );
    });
  });
}

/// Roda o bloc de mentira até ele lançar.
///
/// O `bloc` relança o erro do handler depois de avisar o observador, e esse
/// relançamento vira erro assíncrono não tratado — a zona guardada o contém
/// para que o teste possa afirmar sobre o que o observador registrou.
Future<void> _rodaBlocQueLanca() async {
  final concluido = Completer<void>();

  runZonedGuarded(
    () async {
      final bloc = _ContadorBloc();
      bloc.add(const _Explodir());
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
      if (!concluido.isCompleted) concluido.complete();
    },
    (_, _) {},
  );

  await concluido.future;
}
