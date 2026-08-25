import 'dart:ui';

import 'package:bora/core/design_system/tokens/bora_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DS-01 — os 17 tokens de cor de §1', () {
    test('cada token tem o hex literal da tabela', () {
      expect(BoraColors.paper.toARGB32(), 0xFFF4EFE3, reason: 'paper #F4EFE3');
      expect(BoraColors.paper2.toARGB32(), 0xFFEFECE5,
          reason: 'paper-2 #EFECE5');
      expect(BoraColors.ink.toARGB32(), 0xFF141414, reason: 'ink #141414');
      expect(BoraColors.cream.toARGB32(), 0xFFF4EFE3, reason: 'cream #F4EFE3');
      expect(BoraColors.primary.toARGB32(), 0xFFFF4D2E,
          reason: 'primary #FF4D2E');
      expect(BoraColors.yellow.toARGB32(), 0xFFFFD23F,
          reason: 'yellow #FFD23F');
      expect(BoraColors.purple.toARGB32(), 0xFF6C4BF5,
          reason: 'purple #6C4BF5');
      expect(BoraColors.green.toARGB32(), 0xFF0B6B3A, reason: 'green #0B6B3A');
      expect(BoraColors.waGreen.toARGB32(), 0xFF25D366,
          reason: 'wa-green #25D366');
      expect(BoraColors.waBubble.toARGB32(), 0xFFE7DFCB,
          reason: 'wa-bubble #E7DFCB');
      expect(BoraColors.waConfirm.toARGB32(), 0xFFDCF8C6,
          reason: 'wa-confirm #DCF8C6');
      expect(BoraColors.white.toARGB32(), 0xFFFFFFFF, reason: 'white #FFFFFF');
      expect(BoraColors.text2.toARGB32(), 0xFF6B6B6B,
          reason: 'text-2 #6b6b6b');
      expect(BoraColors.text3.toARGB32(), 0xFF9B9B9B,
          reason: 'text-3 #9b9b9b');
      expect(BoraColors.textBody.toARGB32(), 0xFF3A3A3A,
          reason: 'text-body #3a3a3a');
      expect(BoraColors.divider.toARGB32(), 0x18141414,
          reason: 'divider #141414 @ 9%');
      expect(BoraColors.divider2.toARGB32(), 0x22141414,
          reason: 'divider-2 #141414 @ 13%');
    });

    test('paper e cream existem os dois, com o mesmo valor', () {
      expect(
        BoraColors.cream,
        BoraColors.paper,
        reason: '§1: cream é "texto sobre ink (mesmo valor de paper)" — são '
            'dois tokens porque são dois papéis, não duas cores',
      );
    });

    test('o alfa dos divisores é o primeiro byte, não o último', () {
      expect(
        BoraColors.divider.toARGB32(),
        isNot(0x14141418),
        reason: 'o #14141418 de §1 é RGBA: lido como ARGB daria um azul opaco',
      );
      expect(
        BoraColors.divider.toARGB32() >> 24,
        0x18,
        reason: 'divider é ink a 9% de opacidade',
      );
      expect(
        BoraColors.divider2.toARGB32() >> 24,
        0x22,
        reason: 'divider-2 é ink a 13% de opacidade',
      );
    });
  });

  group('DS-01 — as cores derivadas de A-15 são token nomeado', () {
    test('o scrim do bottom sheet é o preto-arroxeado de §5, não ink', () {
      expect(
        BoraColors.sheetScrim.toARGB32(),
        0x73140A32,
        reason: '§5 bottom sheet: overlay rgba(20,10,50,.45)',
      );
      expect(
        BoraColors.sheetScrim.toARGB32() & 0x00FFFFFF,
        isNot(BoraColors.ink.toARGB32() & 0x00FFFFFF),
        reason: 'o RGB do scrim (20,10,50) não é o de ink (20,20,20)',
      );
    });

    test('o preenchimento da enquete é wa-green a 18%', () {
      expect(
        BoraColors.pollFill.toARGB32(),
        0x2E25D366,
        reason: '§5 opção de enquete: rgba(37,211,102,.18)',
      );
    });

    test('o cream a 25% do segmented escuro é token', () {
      expect(
        BoraColors.creamQuarter.toARGB32(),
        0x40F4EFE3,
        reason: '§5 segmented control sobre card escuro: cream/25%',
      );
    });

    test('a borda e a sombra do frame são token', () {
      expect(
        BoraColors.frameBorder.toARGB32(),
        0x40000000,
        reason: '§5 frame do celular: border 1px rgba(0,0,0,.25)',
      );
      expect(
        BoraColors.frameShadow.toARGB32(),
        0x59140A32,
        reason: '§4 frame do celular: 0 20px 50px -20px rgba(20,10,50,.35)',
      );
    });
  });

  group('DS-21 — as cores de avatar de §1', () {
    test('os cinco pares fixos por pessoa estão na tabela', () {
      expect(BoraColors.avatarPairs['Rafa'],
          (fundo: const Color(0xFFFF4D2E), texto: const Color(0xFFFFFFFF)),
          reason: 'Rafa #FF4D2E / texto #fff');
      expect(BoraColors.avatarPairs['Ana'],
          (fundo: const Color(0xFFFFD23F), texto: const Color(0xFF141414)),
          reason: 'Ana #FFD23F / #141414');
      expect(BoraColors.avatarPairs['Léo'],
          (fundo: const Color(0xFF6C4BF5), texto: const Color(0xFFFFFFFF)),
          reason: 'Léo #6C4BF5 / #fff');
      expect(BoraColors.avatarPairs['Bia'],
          (fundo: const Color(0xFF0B6B3A), texto: const Color(0xFFFFFFFF)),
          reason: 'Bia #0B6B3A / #fff');
      expect(BoraColors.avatarPairs['Duda'],
          (fundo: const Color(0xFF141414), texto: const Color(0xFFF4EFE3)),
          reason: 'Duda #141414 / #F4EFE3');
      expect(BoraColors.avatarPairs, hasLength(5),
          reason: '§1 fixa cinco pessoas — nenhum par a mais');
    });

    test('avatarPairFor devolve o par de §1 para as personas de RN-30', () {
      for (final persona in BoraColors.avatarPairs.keys) {
        expect(
          BoraColors.avatarPairFor(persona),
          BoraColors.avatarPairs[persona],
          reason: '$persona tem cor fixa em §1',
        );
      }
    });

    test('nome fora da tabela cai no par do checksum de A-05', () {
      expect(
        BoraColors.avatarPairFor('Zeca'),
        BoraColors.avatarPairs['Léo'],
        reason: 'soma dos code units de "Zeca" = 387; 387 % 5 = 2, o terceiro '
            'par de §1',
      );
      expect(
        BoraColors.avatarPairFor('Marcinha'),
        BoraColors.avatarPairs['Bia'],
        reason: 'soma dos code units de "Marcinha" = 803; 803 % 5 = 3',
      );
    });

    test('o mesmo nome desconhecido devolve sempre o mesmo par', () {
      expect(
        BoraColors.avatarPairFor('Marcinha'),
        BoraColors.avatarPairFor('Marcinha'),
        reason: 'A-05: mesmo nome ⇒ sempre o mesmo par, senão a pilha de '
            'avatares muda de cor a cada rebuild',
      );
    });

    test('nenhum nome recebe cor fora dos cinco pares de §1', () {
      const nomes = ['Zeca', 'Marcinha', 'Bruno', 'Xu', '', 'a', 'Rafael'];

      for (final nome in nomes) {
        expect(
          BoraColors.avatarPairs.values,
          contains(BoraColors.avatarPairFor(nome)),
          reason: '"$nome" não pode inventar cor: §8 proíbe cor fora dos '
              'tokens',
        );
      }
    });
  });
}
