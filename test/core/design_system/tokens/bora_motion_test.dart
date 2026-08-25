import 'package:bora/core/design_system/tokens/bora_motion.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DS-10 — as durações de §6', () {
    test('chips, segmented e botões de estado mudam em 150ms', () {
      expect(
        BoraMotion.estado,
        const Duration(milliseconds: 150),
        reason: '§6: "transition: all .15s em chips, segmented, botões de '
            'estado" — e é a mesma duração do afundamento do CTA (A-03)',
      );
    });

    test('o toast entra em 300ms e vive 2200ms', () {
      expect(BoraMotion.toastIn, const Duration(milliseconds: 300),
          reason: '§6, toastIn: .3s ease');
      expect(
        BoraMotion.toastVida,
        const Duration(milliseconds: 2200),
        reason: '§5, toast: "some sozinho após 2200ms"',
      );
    });

    test('a barra de progresso anima a largura em 300ms', () {
      expect(
        BoraMotion.progresso,
        const Duration(milliseconds: 300),
        reason: '§6: "Progresso: width .3s"',
      );
    });

    test('o toast entra subindo 14px', () {
      expect(
        BoraMotion.toastSubida,
        14.0,
        reason: '§6, toastIn: from translateY(14px) to translateY(0)',
      );
    });

    test('a curva do sistema é ease, sem mola nem bounce', () {
      expect(
        BoraMotion.curva,
        Curves.ease,
        reason: '§6 não declara timing-function em "transition: all .15s", e o '
            'default do CSS é ease (A-04); §6 proíbe spring e parallax',
      );
    });
  });
}
