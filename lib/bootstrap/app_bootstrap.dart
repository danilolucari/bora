import '../core/observability/app_logger.dart';

/// Ordem determinística de inicialização do app (FUND-15).
///
/// Todos os passos entram como closure — por isso não há import de Firebase
/// aqui. É essa costura que torna ordem e degradação afirmáveis sem SDK real,
/// sem rede e sem emulador ligado.
///
/// A spec fixa `binding → Firebase → emulador → DI → runApp`. A observabilidade
/// entra **entre** binding e Firebase porque FUND-17 exige que a queda do
/// Firebase seja registrada, e o handler precisa estar armado antes de haver o
/// que registrar. A ordem dos cinco passos da spec fica preservada.
class AppBootstrap {
  const AppBootstrap({
    required this.logger,
    required this.ensureBinding,
    required this.installObservability,
    required this.initializeFirebase,
    required this.connectEmulators,
    required this.configureDependencies,
  });

  final AppLogger logger;
  final void Function() ensureBinding;
  final void Function() installObservability;
  final Future<void> Function() initializeFirebase;
  final Future<void> Function() connectEmulators;
  final Future<void> Function() configureDependencies;

  /// Nome com que a falha de inicialização externa é registrada.
  static const String nomeDoRegistro = 'bootstrap';

  /// Executa a inicialização e só então entrega o app a [startApp].
  Future<void> run(void Function() startApp) async {
    ensureBinding();
    installObservability();

    // Só o par Firebase/emulador é protegido: a indisponibilidade deles é
    // degradação, não crash (FUND-17). Se a inicialização falhou, apontar para
    // o emulador não faria sentido — por isso os dois passos dividem o mesmo
    // try.
    try {
      await initializeFirebase();
      await connectEmulators();
    } catch (error, stackTrace) {
      logger.logError(error, stackTrace, name: nomeDoRegistro);
    }

    await configureDependencies();

    // Sempre por último: nenhum widget monta antes de as dependências
    // existirem (FUND-15).
    startApp();
  }
}
