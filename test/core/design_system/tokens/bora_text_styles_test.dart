import 'dart:io';

import 'package:bora/core/design_system/tokens/bora_colors.dart';
import 'package:bora/core/design_system/tokens/bora_text_styles.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _arquivo = 'lib/core/design_system/tokens/bora_text_styles.dart';

/// O contrato de um papel de §2: o valor exato do token e a faixa que o
/// arquivo 02 declara para aquele papel.
typedef _Papel = ({
  TextStyle estilo,
  String familia,
  double tamanho,
  FontWeight peso,
  double? espacamento,
  double? altura,
  Color? cor,
  double faixaMin,
  double faixaMax,
});

const Map<String, _Papel> _papeis = <String, _Papel>{
  'logoHero': (
    estilo: BoraTextStyles.logoHero,
    familia: 'Archivo Black',
    tamanho: 64,
    peso: FontWeight.w400,
    espacamento: -2,
    altura: 0.92,
    cor: null,
    faixaMin: 64,
    faixaMax: 64,
  ),
  'tituloTela': (
    estilo: BoraTextStyles.tituloTela,
    familia: 'Archivo Black',
    tamanho: 22,
    peso: FontWeight.w400,
    espacamento: -0.5,
    altura: null,
    cor: BoraColors.ink,
    faixaMin: 22,
    faixaMax: 24,
  ),
  'tituloCard': (
    estilo: BoraTextStyles.tituloCard,
    familia: 'Archivo Black',
    tamanho: 26,
    peso: FontWeight.w400,
    espacamento: -0.5,
    altura: null,
    cor: BoraColors.ink,
    faixaMin: 26,
    faixaMax: 40,
  ),
  'tituloCardGrande': (
    estilo: BoraTextStyles.tituloCardGrande,
    familia: 'Archivo Black',
    tamanho: 40,
    peso: FontWeight.w400,
    espacamento: -1.5,
    altura: null,
    cor: BoraColors.ink,
    faixaMin: 26,
    faixaMax: 40,
  ),
  'valorHeroi': (
    estilo: BoraTextStyles.valorHeroi,
    familia: 'Archivo Black',
    tamanho: 40,
    peso: FontWeight.w400,
    espacamento: -1.5,
    altura: null,
    cor: BoraColors.cream,
    faixaMin: 40,
    faixaMax: 42,
  ),
  'valorRodape': (
    estilo: BoraTextStyles.valorRodape,
    familia: 'Archivo Black',
    tamanho: 24,
    peso: FontWeight.w400,
    espacamento: -1,
    altura: null,
    cor: BoraColors.ink,
    faixaMin: 24,
    faixaMax: 26,
  ),
  'tituloSheet': (
    estilo: BoraTextStyles.tituloSheet,
    familia: 'Archivo Black',
    tamanho: 22,
    peso: FontWeight.w400,
    espacamento: -0.5,
    altura: null,
    cor: BoraColors.ink,
    faixaMin: 22,
    faixaMax: 22,
  ),
  'labelSecao': (
    estilo: BoraTextStyles.labelSecao,
    familia: 'Archivo',
    tamanho: 11.5,
    peso: FontWeight.w800,
    espacamento: 1.2,
    altura: null,
    cor: BoraColors.text2,
    faixaMin: 11.5,
    faixaMax: 11.5,
  ),
  'botao': (
    estilo: BoraTextStyles.botao,
    familia: 'Archivo',
    tamanho: 12,
    peso: FontWeight.w800,
    espacamento: 0.5,
    altura: null,
    cor: null,
    faixaMin: 12,
    faixaMax: 16,
  ),
  'botaoGrande': (
    estilo: BoraTextStyles.botaoGrande,
    familia: 'Archivo',
    tamanho: 16,
    peso: FontWeight.w800,
    espacamento: 1,
    altura: null,
    cor: null,
    faixaMin: 12,
    faixaMax: 16,
  ),
  'linhaLista': (
    estilo: BoraTextStyles.linhaLista,
    familia: 'Archivo',
    tamanho: 14,
    peso: FontWeight.w800,
    espacamento: null,
    altura: null,
    cor: BoraColors.ink,
    faixaMin: 14,
    faixaMax: 14,
  ),
  'sublinhaLista': (
    estilo: BoraTextStyles.sublinhaLista,
    familia: 'Archivo',
    tamanho: 11.5,
    peso: FontWeight.w600,
    espacamento: null,
    altura: null,
    cor: BoraColors.text2,
    faixaMin: 11.5,
    faixaMax: 12,
  ),
  'corpo': (
    estilo: BoraTextStyles.corpo,
    familia: 'Archivo',
    tamanho: 15,
    peso: FontWeight.w500,
    espacamento: null,
    altura: 1.5,
    cor: BoraColors.textBody,
    faixaMin: 12,
    faixaMax: 15,
  ),
  'dica': (
    estilo: BoraTextStyles.dica,
    familia: 'Archivo',
    tamanho: 12,
    peso: FontWeight.w600,
    espacamento: null,
    altura: 1.4,
    cor: BoraColors.text2,
    faixaMin: 12,
    faixaMax: 15,
  ),
  'microTag': (
    estilo: BoraTextStyles.microTag,
    familia: 'Archivo',
    tamanho: 9,
    peso: FontWeight.w800,
    espacamento: 0.5,
    altura: null,
    cor: null,
    faixaMin: 9,
    faixaMax: 10.5,
  ),
  'chip': (
    estilo: BoraTextStyles.chip,
    familia: 'Archivo',
    tamanho: 13,
    peso: FontWeight.w800,
    espacamento: null,
    altura: null,
    cor: null,
    faixaMin: 13,
    faixaMax: 13,
  ),
  'input': (
    estilo: BoraTextStyles.input,
    familia: 'Archivo',
    tamanho: 15,
    peso: FontWeight.w600,
    espacamento: null,
    altura: null,
    cor: BoraColors.ink,
    faixaMin: 15,
    faixaMax: 15,
  ),
  'stepperValor': (
    estilo: BoraTextStyles.stepperValor,
    familia: 'Archivo',
    tamanho: 17,
    peso: FontWeight.w800,
    espacamento: null,
    altura: null,
    cor: BoraColors.ink,
    faixaMin: 17,
    faixaMax: 17,
  ),
  'toast': (
    estilo: BoraTextStyles.toast,
    familia: 'Archivo',
    tamanho: 13,
    peso: FontWeight.w800,
    espacamento: 0.5,
    altura: null,
    cor: BoraColors.cream,
    faixaMin: 13,
    faixaMax: 13,
  ),
  'rodapeLabel': (
    estilo: BoraTextStyles.rodapeLabel,
    familia: 'Archivo',
    tamanho: 11,
    peso: FontWeight.w800,
    espacamento: 1,
    altura: null,
    cor: BoraColors.text2,
    faixaMin: 11,
    faixaMax: 11,
  ),
  'rodapeSublinha': (
    estilo: BoraTextStyles.rodapeSublinha,
    familia: 'Archivo',
    tamanho: 12.5,
    peso: FontWeight.w700,
    espacamento: null,
    altura: null,
    cor: BoraColors.primary,
    faixaMin: 12.5,
    faixaMax: 12.5,
  ),
  'heroiLabel': (
    estilo: BoraTextStyles.heroiLabel,
    familia: 'Archivo',
    tamanho: 12,
    peso: FontWeight.w800,
    espacamento: 1,
    altura: null,
    cor: BoraColors.yellow,
    faixaMin: 12,
    faixaMax: 12,
  ),
  'heroiSublinha': (
    estilo: BoraTextStyles.heroiSublinha,
    familia: 'Archivo',
    tamanho: 13,
    peso: FontWeight.w700,
    espacamento: null,
    altura: null,
    cor: BoraColors.primary,
    faixaMin: 13,
    faixaMax: 13,
  ),
  'extremosFaixa': (
    estilo: BoraTextStyles.extremosFaixa,
    familia: 'Archivo',
    tamanho: 10,
    peso: FontWeight.w700,
    espacamento: null,
    altura: null,
    cor: BoraColors.text3,
    faixaMin: 10,
    faixaMax: 10,
  ),
};

void main() {
  group('DS-04 — cada papel de §2 tem o valor da tabela', () {
    test('família, tamanho, peso, espaçamento, altura e cor', () {
      _papeis.forEach((papel, contrato) {
        final estilo = contrato.estilo;

        expect(estilo.fontFamily, contrato.familia, reason: '$papel: família');
        expect(estilo.fontSize, contrato.tamanho, reason: '$papel: tamanho');
        expect(estilo.fontWeight, contrato.peso, reason: '$papel: peso');
        expect(estilo.letterSpacing, contrato.espacamento,
            reason: '$papel: letter-spacing');
        expect(estilo.height, contrato.altura, reason: '$papel: line-height');
        expect(estilo.color, contrato.cor, reason: '$papel: cor');
      });
    });

    test('o tamanho de cada papel fica dentro da faixa de §2', () {
      _papeis.forEach((papel, contrato) {
        expect(
          contrato.estilo.fontSize,
          inInclusiveRange(contrato.faixaMin, contrato.faixaMax),
          reason: '$papel: §2 declara a faixa '
              '${contrato.faixaMin}–${contrato.faixaMax}px',
        );
      });
    });

    test('o espaçamento e a altura ficam dentro das faixas de §2', () {
      expect(BoraTextStyles.tituloCard.letterSpacing,
          inInclusiveRange(-1.5, -0.5),
          reason: 'título de card: ls −0.5 a −1.5px');
      expect(BoraTextStyles.tituloCardGrande.letterSpacing,
          inInclusiveRange(-1.5, -0.5),
          reason: 'título de card: ls −0.5 a −1.5px');
      expect(BoraTextStyles.botao.letterSpacing, inInclusiveRange(0.5, 1),
          reason: 'botão: ls 0.5–1px');
      expect(BoraTextStyles.botaoGrande.letterSpacing, inInclusiveRange(0.5, 1),
          reason: 'botão: ls 0.5–1px');
      expect(BoraTextStyles.microTag.letterSpacing, inInclusiveRange(0.5, 1),
          reason: 'micro-tag: ls 0.5–1px');
      expect(BoraTextStyles.corpo.height, inInclusiveRange(1.4, 1.5),
          reason: 'corpo/dica: line-height 1.4–1.5');
      expect(BoraTextStyles.dica.height, inInclusiveRange(1.4, 1.5),
          reason: 'corpo/dica: line-height 1.4–1.5');
    });
  });

  group('DS-04 — as leis de §8 valem para a lista inteira', () {
    test('nenhum texto de UI fica abaixo de 9px', () {
      for (final estilo in BoraTextStyles.todos) {
        expect(
          estilo.fontSize,
          greaterThanOrEqualTo(9.0),
          reason: '§8 proíbe texto de UI abaixo de 9px — ${estilo.fontFamily} '
              '${estilo.fontSize}px',
        );
      }
    });

    test('a micro-tag usa o piso de 9px, não os 8.5px de §2', () {
      expect(
        BoraTextStyles.microTag.fontSize,
        9.0,
        reason: 'A-02: o piso de §8 vence o extremo inferior da faixa de §2',
      );
    });

    test('toda família é Archivo ou Archivo Black', () {
      for (final estilo in BoraTextStyles.todos) {
        expect(
          estilo.fontFamily,
          anyOf('Archivo', 'Archivo Black'),
          reason: '§2: "Archivo Black (display) e Archivo 400–800 (UI). '
              'Nenhuma outra."',
        );
      }
    });

    test('nenhum estilo tem peso nulo', () {
      for (final estilo in BoraTextStyles.todos) {
        expect(
          estilo.fontWeight,
          isNotNull,
          reason: 'peso nulo cairia no default do Material — '
              '${estilo.fontFamily} ${estilo.fontSize}px',
        );
      }
    });

    test('todo estilo de Archivo Black usa w400', () {
      final display = BoraTextStyles.todos
          .where((estilo) => estilo.fontFamily == BoraTextStyles.familiaDisplay)
          .toList();

      expect(display, isNotEmpty,
          reason: 'sem nenhum estilo de display a asserção passaria vazia');
      for (final estilo in display) {
        expect(
          estilo.fontWeight,
          FontWeight.w400,
          reason: 'A-11: a família é estática, de um arquivo só — pedir outro '
              'peso arriscaria negrito sintético (${estilo.fontSize}px)',
        );
      }
    });
  });

  group('DS-04, DS-03 — o contrato do arquivo de estilos', () {
    test('a lista todos traz exatamente os estilos declarados no arquivo', () {
      final fonte = File(_arquivo).readAsStringSync();
      final declarados = RegExp(r'static const TextStyle (\w+) =')
          .allMatches(fonte)
          .map((achado) => achado.group(1)!)
          .toSet();
      final blocoDaLista = RegExp(
        r'static const List<TextStyle> todos = <TextStyle>\[(.*?)\];',
        dotAll: true,
      ).firstMatch(fonte);

      expect(declarados, isNotEmpty,
          reason: 'a varredura precisa achar as declarações em $_arquivo');
      expect(blocoDaLista, isNotNull,
          reason: 'BoraTextStyles.todos precisa existir como lista literal');

      final listados = RegExp(r'\w+')
          .allMatches(blocoDaLista!.group(1)!)
          .map((achado) => achado.group(0)!)
          .toSet();

      expect(
        listados,
        declarados,
        reason: 'estilo declarado fora de `todos` escapa da varredura de '
            'DS-04: a lista é contrato',
      );
      expect(BoraTextStyles.todos, hasLength(declarados.length),
          reason: 'a lista não pode repetir nem omitir estilo');
      expect(_papeis.keys.toSet(), declarados,
          reason: 'a tabela de papéis deste teste precisa cobrir cada estilo '
              'declarado, senão um token novo entra sem valor afirmado');
    });

    test('nenhum FontVariation no arquivo de estilos', () {
      final fonte = File(_arquivo).readAsStringSync();

      expect(
        fonte,
        isNot(contains('FontVariation')),
        reason: 'DS-03: o peso é declarado por fontWeight; desde o Flutter '
            '3.41 é ele que move o eixo wght, e a doc oficial recomenda '
            'evitar FontVariation',
      );
    });
  });
}
