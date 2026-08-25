import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Os três arquivos que o arquivo 02 §2 exige que viajem com o app.
const _archivoVariavel = 'assets/fonts/Archivo[wdth,wght].ttf';
const _archivoBlack = 'assets/fonts/ArchivoBlack-Regular.ttf';
const _licenca = 'assets/fonts/OFL.txt';

/// Lê o `pubspec.yaml` ignorando linha de comentário — o bloco de exemplo
/// gerado pelo `flutter create` também fala em `family:` e `asset:`.
List<String> _linhasDeConfiguracao() => File('pubspec.yaml')
    .readAsLinesSync()
    .where((linha) => !linha.trimLeft().startsWith('#'))
    .toList();

List<String> _valoresDe(String chave) {
  final marcador = '- $chave:';
  return _linhasDeConfiguracao()
      .map((linha) => linha.trim())
      .where((linha) => linha.startsWith(marcador))
      .map((linha) => linha.substring(marcador.length).trim())
      .toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DS-02 — as duas fontes viajam no repositório', () {
    test('a Archivo variável está no bundle, com colchete e vírgula no nome',
        () async {
      final fonte = await rootBundle.load(_archivoVariavel);

      expect(
        fonte.lengthInBytes,
        658596,
        reason: '$_archivoVariavel precisa chegar inteira pelo rootBundle: sem '
            'ela o app cai na fonte do sistema em silêncio',
      );
    });

    test('a Archivo Black está no bundle', () async {
      final fonte = await rootBundle.load(_archivoBlack);

      expect(
        fonte.lengthInBytes,
        90988,
        reason: '$_archivoBlack precisa chegar inteira pelo rootBundle',
      );
    });

    test('a licença OFL viaja ao lado dos .ttf', () async {
      final licenca = await rootBundle.loadString(_licenca);

      expect(
        licenca,
        contains('SIL Open Font License'),
        reason: 'a OFL exige que a licença seja redistribuída junto com a '
            'fonte — $_licenca fica ao lado dos .ttf',
      );
    });

    test('o pubspec declara exatamente as famílias Archivo e Archivo Black',
        () {
      expect(
        _valoresDe('family'),
        <String>['Archivo', 'Archivo Black'],
        reason: '§2 do arquivo 02: "Archivo Black (display) e Archivo 400–800 '
            '(UI). Nenhuma outra."',
      );
      expect(
        _valoresDe('asset'),
        <String>[_archivoVariavel, _archivoBlack],
        reason: 'cada família aponta para o seu arquivo em assets/fonts/',
      );
    });

    test('nenhuma família declara descritor de peso', () {
      final descritoresDePeso = _linhasDeConfiguracao()
          .map((linha) => linha.trim())
          .where((linha) => linha.startsWith('weight:'))
          .toList();

      expect(
        descritoresDePeso,
        isEmpty,
        reason: 'cada família tem um arquivo só: é o FontWeight que move o '
            'eixo wght (DS-03), não um descritor weight: no pubspec',
      );
    });
  });
}
