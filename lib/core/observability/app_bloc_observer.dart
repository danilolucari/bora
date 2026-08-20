import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_logger.dart';

/// Observador global de BLoC: nenhuma transição e nenhum erro de bloc some em
/// silêncio (FUND-13).
///
/// Instalado uma vez, em `installObservability`, com `Bloc.observer = …`.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(this._logger);

  final AppLogger _logger;

  /// Chave da mensagem de transição — `Bloc` emite evento e estado.
  static const String mensagemDeTransicao = 'transição';

  /// Chave da mensagem de mudança — `Cubit` emite só estado.
  static const String mensagemDeMudanca = 'mudança';

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _logger.logEvent(
      mensagemDeTransicao,
      name: 'bloc',
      data: <String, Object?>{
        'bloc': bloc.runtimeType.toString(),
        'evento': transition.event,
        'estado': transition.nextState,
      },
    );
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _logger.logEvent(
      mensagemDeMudanca,
      name: 'bloc',
      data: <String, Object?>{
        'bloc': bloc.runtimeType.toString(),
        'estado': change.nextState,
      },
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.logError(error, stackTrace, name: bloc.runtimeType.toString());
  }
}
