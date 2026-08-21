import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/font_loading.dart';

/// Uma frase longa o bastante para a diferença de peso se acumular em pixels.
const _frase = 'BORA GALERA DO ROLE';
const _tamanho = 40.0;

double _larguraDe(TextStyle estilo) {
  final medidor = TextPainter(
    text: TextSpan(text: _frase, style: estilo),
    textDirection: TextDirection.ltr,
  )..layout();
  return medidor.width;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(carregarFontesArchivo);

  group('DS-03 — o peso declarado chega ao texto rasterizado', () {
    test('w400 e w800 medem diferente na Archivo', () {
      final leve = _larguraDe(const TextStyle(
        fontFamily: 'Archivo',
        fontSize: _tamanho,
        fontWeight: FontWeight.w400,
      ));
      final pesada = _larguraDe(const TextStyle(
        fontFamily: 'Archivo',
        fontSize: _tamanho,
        fontWeight: FontWeight.w800,
      ));

      expect(
        (pesada - leve).abs(),
        greaterThan(1.0),
        reason: 'se o eixo wght não respondesse ao fontWeight, as duas medidas '
            'seriam idênticas — e §2 (Archivo 400–800) seria decorativa. '
            'Medido: w400 $leve px, w800 $pesada px',
      );
    });

    test('w900 também abre folga sobre w400', () {
      final leve = _larguraDe(const TextStyle(
        fontFamily: 'Archivo',
        fontSize: _tamanho,
        fontWeight: FontWeight.w400,
      ));
      final maisPesada = _larguraDe(const TextStyle(
        fontFamily: 'Archivo',
        fontSize: _tamanho,
        fontWeight: FontWeight.w900,
      ));

      expect(
        (maisPesada - leve).abs(),
        greaterThan(1.0),
        reason: 'a folga é medida entre extremos (w400 × w900), nunca entre '
            'vizinhos, cuja diferença é de fração de pixel. '
            'Medido: w400 $leve px, w900 $maisPesada px',
      );
    });

    test('w800 mede exatamente o mesmo que o eixo wght em 800', () {
      final porPeso = _larguraDe(const TextStyle(
        fontFamily: 'Archivo',
        fontSize: _tamanho,
        fontWeight: FontWeight.w800,
      ));
      final porEixo = _larguraDe(const TextStyle(
        fontFamily: 'Archivo',
        fontSize: _tamanho,
        fontVariations: [FontVariation('wght', 800)],
      ));

      expect(
        porPeso,
        porEixo,
        reason: 'neste SDK os dois caminhos são o mesmo mecanismo (Flutter '
            '3.41+), e é por isso que o código de produto declara só '
            'fontWeight. Se um dia esta asserção falhar, o SDK recuou e a '
            'decisão precisa ser revista',
      );
    });

    test('Archivo Black mede diferente de Archivo w400', () {
      final archivo = _larguraDe(const TextStyle(
        fontFamily: 'Archivo',
        fontSize: _tamanho,
        fontWeight: FontWeight.w400,
      ));
      final archivoBlack = _larguraDe(const TextStyle(
        fontFamily: 'Archivo Black',
        fontSize: _tamanho,
        fontWeight: FontWeight.w400,
      ));

      expect(
        (archivoBlack - archivo).abs(),
        greaterThan(1.0),
        reason: 'medida igual significaria que a segunda família não carregou '
            'e caiu em fallback silencioso. Medido: Archivo $archivo px, '
            'Archivo Black $archivoBlack px',
      );
    });
  });
}
