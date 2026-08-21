import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carrega Archivo e Archivo Black no teste que precisa **medir** texto.
///
/// `flutter test` não carrega as fontes declaradas no `pubspec.yaml`: sem isto
/// toda medida cairia na fonte de teste padrão, e a prova de DS-03 mediria o
/// nada. O carregamento é **local** de propósito — um `flutter_test_config.dart`
/// global mudaria o comportamento da suíte inteira, inclusive dos testes que
/// não devem depender de fonte alguma.
Future<void> carregarFontesArchivo() async {
  await _carregarFamilia(
    'Archivo',
    'assets/fonts/Archivo[wdth,wght].ttf',
  );
  await _carregarFamilia(
    'Archivo Black',
    'assets/fonts/ArchivoBlack-Regular.ttf',
  );
}

Future<void> _carregarFamilia(String familia, String caminho) {
  return (FontLoader(familia)..addFont(rootBundle.load(caminho))).load();
}
