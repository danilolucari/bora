import 'package:bora/core/design_system/tokens/bora_accent.dart';
import 'package:bora/core/design_system/tokens/bora_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DS-08 — o acento é conjunto fechado com significado fixo', () {
    test('cada acento aponta para o token de §1 do seu significado', () {
      expect(BoraAccent.primary.cor, BoraColors.primary,
          reason: 'vermelho = dinheiro/CTA');
      expect(BoraAccent.purple.cor, BoraColors.purple,
          reason: 'roxo = galera/link');
      expect(BoraAccent.waGreen.cor, BoraColors.waGreen,
          reason: '#25D366 = WhatsApp');
      expect(BoraAccent.green.cor, BoraColors.green,
          reason: 'verde = pago/comprado');
      expect(BoraAccent.yellow.cor, BoraColors.yellow,
          reason: 'amarelo = destaque');
      expect(BoraAccent.ink.cor, BoraColors.ink, reason: 'ink = neutro');
    });

    test('o conjunto tem exatamente os seis acentos de §1', () {
      expect(
        BoraAccent.values,
        <BoraAccent>[
          BoraAccent.primary,
          BoraAccent.purple,
          BoraAccent.waGreen,
          BoraAccent.green,
          BoraAccent.yellow,
          BoraAccent.ink,
        ],
        reason: 'acento novo aqui é significado novo no sistema — §8 limita a '
            'paleta e as telas limitam o uso a 2 por tela',
      );
    });
  });
}
