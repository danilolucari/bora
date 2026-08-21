import 'package:flutter/material.dart';

import 'bora_colors.dart';
import 'bora_text_styles.dart';

/// O `ThemeData` do BORA — **derivado** dos tokens, nunca fonte deles.
///
/// Existe para impedir que o default do Material (azul, Roboto, canto de 4px,
/// ripple) apareça por dentro de qualquer widget Material que um componente
/// use. Nenhum valor nasce aqui: cada campo lê de [BoraColors] ou de
/// [BoraTextStyles], e é isso que a guarda de pureza de token policia.
///
/// **Escopo:** o tema não é aplicado ao app nesta spec — `lib/app.dart` não
/// pertence a ela (A-16). O catálogo aplica o tema em si mesmo, e quem o pluga
/// no `BoraApp` é a spec 03.
ThemeData boraTheme() {
  return ThemeData(
    scaffoldBackgroundColor: BoraColors.paper,
    canvasColor: BoraColors.paper,
    fontFamily: BoraTextStyles.familiaUi,
    // §8 não tem ripple: o estilo é seco, e o feedback de toque do sistema é o
    // afundamento do CTA de §4.
    splashFactory: NoSplash.splashFactory,
    colorScheme: const ColorScheme.light(
      primary: BoraColors.primary,
      onPrimary: BoraColors.cream,
      secondary: BoraColors.purple,
      onSecondary: BoraColors.white,
      tertiary: BoraColors.waGreen,
      onTertiary: BoraColors.ink,
      error: BoraColors.primary,
      onError: BoraColors.cream,
      surface: BoraColors.white,
      onSurface: BoraColors.ink,
      outline: BoraColors.ink,
    ),
    textTheme: const TextTheme(
      displayLarge: BoraTextStyles.logoHero,
      headlineLarge: BoraTextStyles.tituloCardGrande,
      headlineMedium: BoraTextStyles.tituloCard,
      headlineSmall: BoraTextStyles.valorRodape,
      titleLarge: BoraTextStyles.tituloTela,
      titleMedium: BoraTextStyles.linhaLista,
      titleSmall: BoraTextStyles.labelSecao,
      bodyLarge: BoraTextStyles.corpo,
      bodyMedium: BoraTextStyles.dica,
      bodySmall: BoraTextStyles.sublinhaLista,
      labelLarge: BoraTextStyles.botaoGrande,
      labelMedium: BoraTextStyles.botao,
      labelSmall: BoraTextStyles.microTag,
    ),
  );
}
