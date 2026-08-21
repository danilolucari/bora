import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta [componente] sozinho, sob `boraTheme()`, e nada mais.
///
/// É o palco mínimo dos testes de componente: sem rota, sem shell e sem tela
/// de produto, para que o que a árvore mostrar seja do componente e do tema —
/// não de um envelope acidental. As fases 4–7 reusam este helper.
Future<void> pumpComponent(WidgetTester tester, Widget componente) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(body: Center(child: componente)),
    ),
  );
  await tester.pumpAndSettle();
}
