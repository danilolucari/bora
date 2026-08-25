import 'package:bora/core/design_system/tokens/bora_borders.dart';
import 'package:bora/core/design_system/tokens/bora_colors.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DS-05 — a forma padrão é o canto reto', () {
    test('o raio do sistema é zero', () {
      expect(
        BoraBorders.raio,
        BorderRadius.zero,
        reason: '§3: "border-radius: 0 em tudo (botões, cards, inputs, chips)"',
      );
    });
  });

  group('DS-06 — as bordas de §3', () {
    test('a borda sólida tem 2px na cor pedida', () {
      final borda = BoraBorders.solida(BoraColors.primary);

      expect(borda.top.width, 2.0, reason: '§3: borda padrão 2px solid');
      expect(borda.top.color, BoraColors.primary);
      expect(borda.isUniform, isTrue, reason: 'os quatro lados são iguais');
    });

    test('a borda padrão é 2px ink', () {
      expect(BoraBorders.padraoInk.top.width, 2.0);
      expect(
        BoraBorders.padraoInk.top.color,
        BoraColors.ink,
        reason: '§3: "2px solid #141414 em cards, botões, inputs, chips"',
      );
    });

    test('a borda do frame é 1px, a única fina do sistema', () {
      expect(
        BoraBorders.frame.top.width,
        1.0,
        reason: '§5, frame do celular: border 1px rgba(0,0,0,.25)',
      );
      expect(BoraBorders.frame.top.color, BoraColors.frameBorder);
    });

    test('a dica tracejada é 2px ink', () {
      expect(BoraBorders.dicaTracejada.largura, 2.0);
      expect(
        BoraBorders.dicaTracejada.cor,
        BoraColors.ink,
        reason: '§3, dica/nota: 2px dashed #141414',
      );
    });

    test('o slot vazio tracejado é 2px text-3', () {
      expect(BoraBorders.slotTracejado.largura, 2.0);
      expect(
        BoraBorders.slotTracejado.cor,
        BoraColors.text3,
        reason: '§3, slot vazio/desabilitado: 2px dashed #9b9b9b',
      );
    });

    test('a opacidade de desabilitado é 0.7', () {
      expect(
        BoraBorders.opacidadeDesabilitado,
        0.7,
        reason: '§3: "Slot vazio/desabilitado: … opacity .7" — a única '
            'opacidade do arquivo 02 (A-07)',
      );
    });
  });
}
