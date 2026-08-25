import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DS-35 — o barrel entrega os tokens da fase', () {
    test('cor, tipo, forma, sombra, espaço, acento, motion e tema saem daqui',
        () {
      // Só o barrel foi importado: se um export sumir, este arquivo nem
      // compila — é assim que a tela consegue importar um arquivo só.
      expect(BoraColors.ink.toARGB32(), 0xFF141414);
      expect(BoraTextStyles.todos, isNotEmpty);
      expect(BoraBorders.raio, BorderRadius.zero);
      expect(BoraShadows.cardBranco.blurRadius, 0.0);
      expect(BoraSpacing.toast.horizontal, greaterThan(0));
      expect(BoraAccent.values, hasLength(6));
      expect(BoraMotion.estado.inMilliseconds, 150);
      expect(boraTheme().scaffoldBackgroundColor, BoraColors.paper);
    });
  });
}
