import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'emulator_config.dart';
import 'firebase_environment.dart';

/// Adaptador fino sobre os singletons do Firebase.
///
/// **Nenhuma decisão mora aqui.** Quais opções (`FirebaseEnvironment.resolve`),
/// qual host e quais portas (`EmulatorConfig`) já foram decididos e testados
/// unitariamente; este arquivo só chama o SDK. É por isso que ele não tem
/// teste unitário próprio — a matriz de cobertura o declara como camada sem
/// teste, e a verificação é o gate de build mais a checagem manual do README.
abstract final class FirebaseBootstrap {
  /// Projeto real passado por `--dart-define` numa build de release.
  ///
  /// Vazio quando ausente — e é assim que `resolve` sabe falhar cedo.
  static const String _projectIdFromEnv =
      String.fromEnvironment(FirebaseEnvironment.projectIdDefine);

  /// Sobe o app Firebase com as opções que valem para este ambiente.
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: FirebaseEnvironment.resolve(
        isRelease: kReleaseMode,
        projectIdFromEnv: _projectIdFromEnv,
      ),
    );
  }

  /// Aponta Auth e Firestore para o Emulator Suite local (FUND-16).
  ///
  /// Em release não faz nada: o app nunca deve conversar com emulador contra
  /// infraestrutura real.
  static Future<void> connectEmulators() async {
    if (kReleaseMode) return;

    final host = EmulatorConfig.host(
      isAndroid: defaultTargetPlatform == TargetPlatform.android,
      isWeb: kIsWeb,
    );

    await FirebaseAuth.instance.useAuthEmulator(host, EmulatorConfig.authPort);
    FirebaseFirestore.instance.useFirestoreEmulator(
      host,
      EmulatorConfig.firestorePort,
    );
  }
}
