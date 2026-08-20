import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'bootstrap/app_bootstrap.dart';
import 'core/di/injector.dart';
import 'core/firebase/firebase_bootstrap.dart';
import 'core/observability/app_bloc_observer.dart';
import 'core/observability/app_logger.dart';
import 'core/observability/global_error_handler.dart';
import 'core/routing/url_strategy/url_strategy.dart';

Future<void> main() async {
  // Antes de tudo: no navegador a rota precisa virar caminho já na primeira
  // leitura da URL. Fora do web esta chamada é inerte.
  configureUrlStrategy();

  const logger = DebugAppLogger();

  await AppBootstrap(
    logger: logger,
    ensureBinding: WidgetsFlutterBinding.ensureInitialized,
    installObservability: () {
      installGlobalErrorHandlers(logger);
      Bloc.observer = const AppBlocObserver(logger);
    },
    initializeFirebase: FirebaseBootstrap.initialize,
    connectEmulators: FirebaseBootstrap.connectEmulators,
    configureDependencies: () => configureDependencies(logger: logger),
  ).run(() => runApp(BoraApp(router: getIt<GoRouter>())));
}
