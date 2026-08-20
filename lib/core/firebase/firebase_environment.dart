import 'package:firebase_core/firebase_core.dart';

import 'demo_firebase_options.dart';

/// Decide com quais [FirebaseOptions] o app sobe.
///
/// Fora de release vale sempre o projeto de emulador. Em release sem projeto
/// real a resolução **falha cedo e ruidosa**, em vez de deixar o app tentar em
/// silêncio alcançar um projeto que não existe (FUND-16).
abstract final class FirebaseEnvironment {
  /// Nome do `--dart-define` que carrega o projeto real.
  static const String projectIdDefine = 'BORA_FIREBASE_PROJECT_ID';

  /// Prefixo reservado pelo Firebase a projetos que só existem no emulador.
  static const String demoPrefix = 'demo-';

  /// [isRelease] entra como parâmetro, e nunca como `kReleaseMode` lido aqui
  /// dentro — é o que torna os dois ramos testáveis.
  static FirebaseOptions resolve({
    required bool isRelease,
    String? projectIdFromEnv,
  }) {
    if (!isRelease) return demoFirebaseOptions;

    final projectId = projectIdFromEnv;
    if (projectId == null ||
        projectId.isEmpty ||
        projectId.startsWith(demoPrefix)) {
      throw StateError(
        'Build de release sem projeto Firebase real: '
        '$projectIdDefine=${projectId ?? '<ausente>'}. '
        'Passe --dart-define=$projectIdDefine=<id do projeto> com um id que '
        'não comece com "$demoPrefix". O README explica: a fundação é '
        'emulator-first e não versiona projeto na nuvem.',
      );
    }

    return demoFirebaseOptions.copyWith(projectId: projectId);
  }
}
