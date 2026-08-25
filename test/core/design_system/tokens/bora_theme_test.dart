import 'dart:io';

import 'package:bora/core/design_system/tokens/bora_colors.dart';
import 'package:bora/core/design_system/tokens/bora_text_styles.dart';
import 'package:bora/core/design_system/tokens/bora_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _arquivo = 'lib/core/design_system/tokens/bora_theme.dart';

void main() {
  group('DS-35 — o tema é derivado dos tokens', () {
    test('o fundo do tema é paper', () {
      final tema = boraTheme();

      expect(tema.scaffoldBackgroundColor, BoraColors.paper,
          reason: '§1: paper é "fundo de todas as telas e barras fixas"');
      expect(tema.canvasColor, BoraColors.paper);
    });

    test('a família de texto do tema é Archivo', () {
      final texto = boraTheme().textTheme;

      expect(texto.bodyLarge?.fontFamily, BoraTextStyles.familiaUi);
      expect(
        texto.displayMedium?.fontFamily,
        BoraTextStyles.familiaUi,
        reason: 'até o papel que o tema não declara herda Archivo — nenhum '
            'texto pode cair na Roboto do Material',
      );
    });

    test('o textTheme mapeia os tokens de §2, inclusive os de display', () {
      final texto = boraTheme().textTheme;

      expect(texto.titleLarge?.fontFamily, BoraTextStyles.familiaDisplay,
          reason: 'título de tela é Archivo Black e não pode ser sobrescrito '
              'pela família de UI do tema');
      expect(texto.titleLarge?.fontSize, 22.0);
      expect(texto.titleLarge?.fontWeight, FontWeight.w400);
      expect(texto.bodyLarge?.fontSize, BoraTextStyles.corpo.fontSize);
      expect(texto.labelMedium?.fontWeight, BoraTextStyles.botao.fontWeight);
    });

    test('o colorScheme sai dos tokens de §1', () {
      final cores = boraTheme().colorScheme;

      expect(cores.primary, BoraColors.primary);
      expect(cores.onPrimary, BoraColors.cream);
      expect(cores.secondary, BoraColors.purple);
      expect(cores.surface, BoraColors.white);
      expect(cores.onSurface, BoraColors.ink);
    });

    test('o tema não tem ripple', () {
      expect(
        boraTheme().splashFactory,
        NoSplash.splashFactory,
        reason: '§8 não tem ripple: o feedback de toque do sistema é o '
            'afundamento do CTA de §4',
      );
    });

    test('o arquivo do tema não tem literal de cor nem de fontFamily', () {
      final fonte = File(_arquivo).readAsStringSync();

      expect(fonte, isNot(contains('Color(0x')),
          reason: 'cor só existe em bora_colors.dart');
      expect(fonte, isNot(matches(RegExp(r'(?<!Bora)Colors\.(?!transparent)'))),
          reason: 'nem os atalhos do Material entram: são cor fora do token');
      expect(
        fonte,
        isNot(matches(RegExp('''fontFamily:\\s*['"]'''))),
        reason: 'família só existe em bora_text_styles.dart — o tema lê o '
            'token, não digita o nome',
      );
    });
  });
}
