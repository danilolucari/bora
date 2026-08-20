import 'dart:convert';
import 'dart:io';

import 'package:bora/core/firebase/emulator_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// Porta declarada para [emulador] em `firebase.json` — a fonte da verdade
/// segundo a spec.
int _portaDeclaradaEm(String emulador) {
  final arquivo =
      jsonDecode(File('firebase.json').readAsStringSync()) as Map<String, Object?>;
  final emuladores = arquivo['emulators']! as Map<String, Object?>;
  final config = emuladores[emulador]! as Map<String, Object?>;
  return config['port']! as int;
}

void main() {
  group('FUND-16 — as portas do Dart batem com firebase.json', () {
    test('auth', () {
      expect(_portaDeclaradaEm('auth'), EmulatorConfig.authPort);
    });

    test('firestore', () {
      expect(_portaDeclaradaEm('firestore'), EmulatorConfig.firestorePort);
    });
  });

  group('FUND-16 — o host depende da plataforma', () {
    test('no emulador Android o host é 10.0.2.2', () {
      expect(
        EmulatorConfig.host(isAndroid: true, isWeb: false),
        '10.0.2.2',
      );
    });

    test('no web o host é localhost mesmo em Android', () {
      expect(
        EmulatorConfig.host(isAndroid: true, isWeb: true),
        'localhost',
      );
    });

    test('nas demais plataformas nativas o host é localhost', () {
      expect(
        EmulatorConfig.host(isAndroid: false, isWeb: false),
        'localhost',
      );
    });
  });
}
