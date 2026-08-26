import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/data/festa_repository_em_memoria.dart';
import '../../features/home/domain/festa_repository.dart';
import '../autenticacao/autenticacao.dart';
import '../autenticacao/dados/firebase_autenticacao_repository.dart';
import '../observability/app_logger.dart';
import '../routing/app_router.dart';

/// Container de dependências do projeto — **o único**.
///
/// Nenhuma feature cria o seu: cada spec seguinte registra os próprios blocs
/// dentro de [configureDependencies].
final GetIt getIt = GetIt.instance;

/// Guarda de idempotência (FUND-12).
///
/// É uma flag, e não `getIt.isRegistered<T>()`, de propósito: um teste pode
/// pré-registrar um duplo antes de configurar, e a guarda por tipo registrado
/// abortaria o resto da configuração em silêncio.
bool _configured = false;

/// Registra as dependências da fundação. Chamar de novo é inofensivo.
///
/// [logger] e [routerFactory] entram como parâmetro para que a suíte configure
/// o container com duplos, sem depender do que a produção usa.
Future<void> configureDependencies({
  AppLogger? logger,
  GoRouter Function()? routerFactory,
  AutenticacaoRepository Function()? autenticacaoFactory,
  FestaRepository Function()? festasFactory,
}) async {
  if (_configured) return;
  _configured = true;

  getIt.registerSingleton<AppLogger>(logger ?? const DebugAppLogger());

  // Preguiçoso como os demais serviços do Firebase: registrar não pode tocar
  // no SDK (FUND-17). Quem constrói o repositório é quem primeiro o pede.
  getIt.registerLazySingleton<AutenticacaoRepository>(
    () => autenticacaoFactory != null
        ? autenticacaoFactory()
        : FirebaseAutenticacaoRepository(
            getIt<FirebaseAuth>(),
            getIt<AppLogger>(),
          ),
    dispose: (repositorio) => repositorio.dispose(),
  );

  // A semente de produção é **vazia**: a fixture de RN-30 é dado de teste
  // (G7), e `lib/` não a importa. O app abre no estado vazio de HOME-15 até a
  // spec 05 criar festa — que é a verdade do M1, não um buraco.
  getIt.registerLazySingleton<FestaRepository>(
    () => festasFactory != null ? festasFactory() : FestaRepositoryEmMemoria(),
    dispose: (repositorio) => repositorio.dispose(),
  );

  // Deixou de ser tear-off: o roteador agora exige a porta de sessão (AD-017),
  // e resolvê-la aqui dentro mantém a construção preguiçosa.
  getIt.registerLazySingleton<GoRouter>(
    routerFactory ??
        () => buildAppRouter(
              autenticacao: getIt<AutenticacaoRepository>(),
              festas: getIt<FestaRepository>(),
              logger: getIt<AppLogger>(),
            ),
  );

  // Lazy de propósito: registrar não pode tocar no SDK. Com o Firebase caído,
  // o erro aparece em quem usa o serviço, e não no boot (FUND-17).
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
}

/// Devolve o container ao estado vazio e rearma a guarda.
///
/// É o que permite que os testes rodem isolados e em qualquer ordem.
Future<void> resetDependencies() async {
  await getIt.reset();
  _configured = false;
}
