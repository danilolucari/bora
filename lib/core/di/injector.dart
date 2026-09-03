import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/galera/data/galera_repositorio_sobre_festas.dart';
import '../../features/galera/domain/galera_repository.dart';
import '../../features/home/data/festa_repository_em_memoria.dart';
import '../../features/home/domain/festa_repository.dart';
import '../../features/lista/data/pedido_falso.dart';
import '../../features/lista/domain/pedido_repository.dart';
import '../autenticacao/autenticacao.dart';
import '../autenticacao/dados/firebase_autenticacao_repository.dart';
import '../festas/festas.dart';
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
  PedidoRepository Function()? pedidosFactory,
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

  // A **segunda porta sobre a mesma instância** (AD-029): a Home lê a lista,
  // `montar` cria e grava. Sem `dispose`: quem detém o ciclo de vida do store
  // é a porta de leitura, que já o registra com `dispose` — fechar o mesmo
  // controller duas vezes lançaria.
  //
  // O `as` é a expressão honesta de "é o mesmo objeto": `FestaRepositoryEmMemoria`
  // implementa as duas portas, e resolver por aqui é o que garante que criar
  // um rolê em montar aparece na Home. Um duplo **só de leitura** injetado por
  // [festasFactory] continua servindo a Home; quem o injetar e depois abrir
  // `/roles/novo` é que descobre, alto, que faltou a metade de escrita.
  getIt.registerLazySingleton<FestaEmEdicaoRepository>(
    () => getIt<FestaRepository>() as FestaEmEdicaoRepository,
  );

  // A **terceira porta sobre a mesma instância**: a Galera é uma vista sobre o
  // registro da festa, e não um store paralelo (`galera/design.md` §2.1). É o
  // que faz a preferência mudada em T-05 mudar a lista da festa sem sincronia
  // nenhuma — dois stores divergiriam sem que nada avisasse.
  //
  // Sem `dispose` próprio, pela mesma razão da porta de edição: quem detém o
  // ciclo de vida do store é a porta de leitura da Home.
  getIt.registerLazySingleton<GaleraRepository>(
    () => GaleraRepositorioSobreFestas(
      getIt<FestaEmEdicaoRepository>(),
      getIt<AppLogger>(),
    ),
  );

  // A porta de pedido da AD-024. A **única** implementação do M1 é falsa, e a
  // ressalva de exposição pública mora no doc de `PedidoFalso`: com ela no
  // lugar, a tela Lista afirma "PEDIDO A CAMINHO!" sem pedido a caminho.
  // Trocar por um adaptador real é trocar esta linha.
  getIt.registerLazySingleton<PedidoRepository>(
    () => pedidosFactory != null ? pedidosFactory() : const PedidoFalso(),
  );

  // Deixou de ser tear-off: o roteador agora exige a porta de sessão (AD-017),
  // e resolvê-la aqui dentro mantém a construção preguiçosa.
  getIt.registerLazySingleton<GoRouter>(
    routerFactory ??
        () => buildAppRouter(
              autenticacao: getIt<AutenticacaoRepository>(),
              festas: getIt<FestaRepository>(),
              festasEmEdicao: getIt<FestaEmEdicaoRepository>(),
              galera: getIt<GaleraRepository>(),
              pedidos: getIt<PedidoRepository>(),
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
