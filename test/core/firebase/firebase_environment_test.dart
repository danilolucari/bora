import 'package:bora/core/firebase/demo_firebase_options.dart';
import 'package:bora/core/firebase/firebase_environment.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher _falhaExplicitaDeRelease() => throwsA(
      isA<StateError>().having(
        (e) => e.message,
        'message',
        allOf(
          contains(FirebaseEnvironment.projectIdDefine),
          contains('README'),
        ),
      ),
    );

void main() {
  group('FUND-16 — fora de release vale o projeto de emulador', () {
    test('resolve devolve as opções demo', () {
      final options = FirebaseEnvironment.resolve(isRelease: false);

      expect(options, same(demoFirebaseOptions));
      expect(options.projectId, 'demo-bora');
    });

    test('em debug o projeto real informado não desvia do emulador', () {
      final options = FirebaseEnvironment.resolve(
        isRelease: false,
        projectIdFromEnv: 'bora-producao',
      );

      expect(options.projectId, 'demo-bora');
    });
  });

  group('FUND-16 — release sem projeto real falha cedo', () {
    test('sem o dart-define lança StateError explícito', () {
      expect(
        () => FirebaseEnvironment.resolve(isRelease: true),
        _falhaExplicitaDeRelease(),
      );
      expect(
        () => FirebaseEnvironment.resolve(
          isRelease: true,
          projectIdFromEnv: '',
        ),
        _falhaExplicitaDeRelease(),
      );
    });

    test('com projeto demo- lança StateError explícito', () {
      expect(
        () => FirebaseEnvironment.resolve(
          isRelease: true,
          projectIdFromEnv: 'demo-bora',
        ),
        _falhaExplicitaDeRelease(),
      );
    });
  });

  group('FUND-16 — release com projeto real sobe', () {
    test('resolve devolve as opções com o projeto informado', () {
      final options = FirebaseEnvironment.resolve(
        isRelease: true,
        projectIdFromEnv: 'bora-producao',
      );

      expect(options.projectId, 'bora-producao');
    });
  });
}
