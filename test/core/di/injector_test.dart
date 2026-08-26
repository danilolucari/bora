import 'package:bora/core/di/injector.dart';
import 'package:bora/core/observability/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../support/fake_autenticacao_repository.dart';
import '../../support/recording_app_logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetDependencies);
  tearDown(resetDependencies);

  group('FUND-12 — o container registra o que a fundação precisa', () {
    test('registra logger, roteador e os serviços do Firebase', () async {
      await configureDependencies(logger: RecordingAppLogger());

      expect(getIt.isRegistered<AppLogger>(), isTrue);
      expect(getIt.isRegistered<GoRouter>(), isTrue);
      expect(getIt.isRegistered<FirebaseAuth>(), isTrue);
      expect(getIt.isRegistered<FirebaseFirestore>(), isTrue);
    });

    test('registrar não toca no SDK do Firebase', () async {
      // Se Auth ou Firestore fossem registrados com resolução adiantada, esta
      // chamada lançaria: nenhum app Firebase foi inicializado nesta suíte.
      await expectLater(
        configureDependencies(logger: RecordingAppLogger()),
        completes,
      );
    });

    test('o roteador é singleton preguiçoso: sempre a mesma instância',
        () async {
      // Desde a AD-017 o roteador exige a porta de sessão, e resolvê-lo
      // construiria o adaptador Firebase de verdade — que toca o SDK. O duplo
      // entra pela costura que `configureDependencies` já expõe.
      await configureDependencies(
        logger: RecordingAppLogger(),
        autenticacaoFactory: FakeAutenticacaoRepository.new,
      );

      expect(getIt<GoRouter>(), same(getIt<GoRouter>()));
    });
  });

  group('FUND-12 — configurar duas vezes é inofensivo', () {
    test('a segunda chamada não lança', () async {
      await configureDependencies(logger: RecordingAppLogger());

      await expectLater(
        configureDependencies(logger: RecordingAppLogger()),
        completes,
      );
    });

    test('a segunda chamada não duplica nem troca o que já estava registrado',
        () async {
      final primeiro = RecordingAppLogger();
      await configureDependencies(logger: primeiro);

      await configureDependencies(logger: RecordingAppLogger());

      expect(getIt<AppLogger>(), same(primeiro));
    });
  });

  group('FUND-12 — o reset devolve o container ao estado vazio', () {
    test('depois do reset nada está registrado', () async {
      await configureDependencies(logger: RecordingAppLogger());

      await resetDependencies();

      expect(getIt.isRegistered<AppLogger>(), isFalse);
      expect(getIt.isRegistered<GoRouter>(), isFalse);
      expect(getIt.isRegistered<FirebaseAuth>(), isFalse);
      expect(getIt.isRegistered<FirebaseFirestore>(), isFalse);
    });

    test('depois do reset dá para configurar de novo, com outro duplo',
        () async {
      await configureDependencies(logger: RecordingAppLogger());
      await resetDependencies();

      final novo = RecordingAppLogger();
      await configureDependencies(logger: novo);

      expect(getIt<AppLogger>(), same(novo));
    });
  });
}
