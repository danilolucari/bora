import 'dart:io';

import 'package:bora/core/design_system/tokens/bora_colors.dart';
import 'package:bora/core/design_system/tokens/bora_shadows.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _arquivo = 'lib/core/design_system/tokens/bora_shadows.dart';

/// Cada uso da tabela de §4 com o par de offset e a cor que a tabela declara.
typedef _Uso = ({BoxShadow sombra, Offset deslocamento, Color cor});

final Map<String, _Uso> _duras = <String, _Uso>{
  'loginGrande': (
    sombra: BoraShadows.loginGrande,
    deslocamento: const Offset(5, 5),
    cor: BoraColors.primary,
  ),
  'cardLink': (
    sombra: BoraShadows.cardLink,
    deslocamento: const Offset(5, 5),
    cor: BoraColors.purple,
  ),
  'cardGrupo': (
    sombra: BoraShadows.cardGrupo,
    deslocamento: const Offset(5, 5),
    cor: BoraColors.waGreen,
  ),
  'cardBranco': (
    sombra: BoraShadows.cardBranco,
    deslocamento: const Offset(6, 6),
    cor: BoraColors.ink,
  ),
  'cardBrancoGrande': (
    sombra: BoraShadows.cardBrancoGrande,
    deslocamento: const Offset(8, 8),
    cor: BoraColors.ink,
  ),
  'cardHeroi': (
    sombra: BoraShadows.cardHeroi,
    deslocamento: const Offset(6, 6),
    cor: BoraColors.primary,
  ),
  'flyer': (
    sombra: BoraShadows.flyer,
    deslocamento: const Offset(8, 8),
    cor: BoraColors.primary,
  ),
  'bolhaWa': (
    sombra: BoraShadows.bolhaWa,
    deslocamento: const Offset(4, 4),
    cor: BoraColors.ink,
  ),
};

void main() {
  group('DS-07 — as sombras de §4 são sempre duras', () {
    test('nenhuma sombra da UI tem blur ou spread', () {
      _duras.forEach((uso, contrato) {
        expect(contrato.sombra.blurRadius, 0.0,
            reason: '$uso: §4 é "sempre duras, sem blur"');
        expect(contrato.sombra.spreadRadius, 0.0, reason: '$uso: sem spread');
      });
    });

    test('cada uso tem o offset e a cor da tabela de §4', () {
      _duras.forEach((uso, contrato) {
        expect(contrato.sombra.offset, contrato.deslocamento,
            reason: '$uso: offset da tabela de §4');
        expect(contrato.sombra.color, contrato.cor, reason: '$uso: cor de §4');
      });
    });

    test('hard() devolve sombra dura na distância pedida', () {
      final sombra = BoraShadows.hard(BoraColors.waGreen, 4);

      expect(sombra.offset, const Offset(4, 4));
      expect(sombra.color, BoraColors.waGreen);
      expect(sombra.blurRadius, 0.0);
      expect(sombra.spreadRadius, 0.0);
    });

    test('o CTA de §4 desloca 4px', () {
      expect(
        BoraShadows.distanciaCta,
        4.0,
        reason: '§4, botão CTA: "4px 4px 0 <acento>" — a cor é a do contexto, '
            'a distância é fixa',
      );
    });
  });

  group('DS-07 — a sombra do frame é a única suave', () {
    test('o frame tem o blur, o spread e a cor de §4', () {
      expect(BoraShadows.frame.offset, const Offset(0, 20));
      expect(BoraShadows.frame.blurRadius, 50.0);
      expect(BoraShadows.frame.spreadRadius, -20.0);
      expect(BoraShadows.frame.color, BoraColors.frameShadow);
    });

    test('nenhuma outra sombra declarada tem blur', () {
      final comBlur = _duras.entries
          .where((uso) => uso.value.sombra.blurRadius != 0)
          .map((uso) => uso.key)
          .toList();

      expect(
        comBlur,
        isEmpty,
        reason: '§4: a do frame é a única sombra suave permitida — é o palco, '
            'não a UI',
      );
    });
  });

  group('DS-07 — o contrato do arquivo de sombras', () {
    test('este teste cobre toda sombra declarada no arquivo', () {
      final fonte = File(_arquivo).readAsStringSync();
      final declaradas = RegExp(r'static (?:final|const) BoxShadow (\w+) =')
          .allMatches(fonte)
          .map((achado) => achado.group(1)!)
          .toSet();

      expect(declaradas, isNotEmpty,
          reason: 'a varredura precisa achar as declarações em $_arquivo');
      expect(
        declaradas,
        {..._duras.keys, 'frame'},
        reason: 'sombra declarada fora da tabela deste teste entra no sistema '
            'sem offset nem blur afirmados',
      );
    });
  });
}
