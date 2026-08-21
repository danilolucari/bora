import 'package:flutter/painting.dart';

import 'bora_colors.dart';

/// A escala tipográfica do arquivo 02 §2, um `TextStyle` por papel.
///
/// Este é o **único** arquivo do projeto autorizado a conter um literal de
/// `fontFamily` (DS-09). O peso é sempre declarado por `fontWeight`: desde o
/// Flutter 3.41 é ele que move o eixo `wght` da fonte variável, e a doc oficial
/// recomenda **evitar** declarar o eixo à mão — por isso nenhum arquivo de
/// `lib/` declara variação de eixo tipográfico (DS-03).
abstract final class BoraTextStyles {
  /// A família de UI, variável, pesos 400–800 (§2).
  static const String familiaUi = 'Archivo';

  /// A família de display, estática (§2). Sempre `w400` (A-11): pedir outro
  /// peso numa família de um arquivo só arriscaria negrito sintético.
  static const String familiaDisplay = 'Archivo Black';

  // --- Archivo Black (display) -------------------------------------------

  /// Logo/hero do login: Archivo Black 64px, ls −2px, line-height .92 (§2).
  static const TextStyle logoHero = TextStyle(
    fontFamily: familiaDisplay,
    fontSize: 64,
    fontWeight: FontWeight.w400,
    letterSpacing: -2,
    height: 0.92,
  );

  /// Título de tela: Archivo Black 22–24px, ls −0.5px, CAIXA ALTA (§2).
  static const TextStyle tituloTela = TextStyle(
    fontFamily: familiaDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
    color: BoraColors.ink,
  );

  /// Título de card, extremo pequeno da faixa 26–40px (§2).
  static const TextStyle tituloCard = TextStyle(
    fontFamily: familiaDisplay,
    fontSize: 26,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
    color: BoraColors.ink,
  );

  /// Título de card, extremo grande da faixa 26–40px, ls −1.5px (§2).
  static const TextStyle tituloCardGrande = TextStyle(
    fontFamily: familiaDisplay,
    fontSize: 40,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.5,
    color: BoraColors.ink,
  );

  /// Valor-herói (R$): Archivo Black 40–42px, ls −1.5px, sobre card escuro
  /// (§2, §5 card-herói).
  static const TextStyle valorHeroi = TextStyle(
    fontFamily: familiaDisplay,
    fontSize: 40,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.5,
    color: BoraColors.cream,
  );

  /// Valor de rodapé (SAI POR): Archivo Black 24–26px, ls −1px (§2).
  static const TextStyle valorRodape = TextStyle(
    fontFamily: familiaDisplay,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: -1,
    color: BoraColors.ink,
  );

  /// Título do bottom sheet: Archivo Black 22px (§5).
  static const TextStyle tituloSheet = TextStyle(
    fontFamily: familiaDisplay,
    fontSize: 22,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.5,
    color: BoraColors.ink,
  );

  // --- Archivo (UI) -------------------------------------------------------

  /// Label de seção: Archivo 800 11.5px, ls 1.2px, `text-2`, CAIXA ALTA (§2).
  static const TextStyle labelSecao = TextStyle(
    fontFamily: familiaUi,
    fontSize: 11.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
    color: BoraColors.text2,
  );

  /// Botão, extremo pequeno da faixa 12–16px, ls 0.5px (§2). A cor vem do
  /// contexto do botão.
  static const TextStyle botao = TextStyle(
    fontFamily: familiaUi,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );

  /// Botão, extremo grande da faixa 12–16px, ls 1px (§2).
  static const TextStyle botaoGrande = TextStyle(
    fontFamily: familiaUi,
    fontSize: 16,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
  );

  /// Nome/linha de lista: Archivo 800 14px `ink`; serve também ao valor à
  /// direita da linha (§2, §5 card de lista).
  static const TextStyle linhaLista = TextStyle(
    fontFamily: familiaUi,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: BoraColors.ink,
  );

  /// Sublinha de lista: Archivo 600 11.5–12px `text-2` (§2).
  static const TextStyle sublinhaLista = TextStyle(
    fontFamily: familiaUi,
    fontSize: 11.5,
    fontWeight: FontWeight.w600,
    color: BoraColors.text2,
  );

  /// Corpo: Archivo 500–600 12–15px, line-height 1.4–1.5 (§2).
  static const TextStyle corpo = TextStyle(
    fontFamily: familiaUi,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: BoraColors.textBody,
  );

  /// Dica/nota: Archivo 600 12px, line-height 1.4, `text-2` (§2, §3).
  static const TextStyle dica = TextStyle(
    fontFamily: familiaUi,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: BoraColors.text2,
  );

  /// Micro-tag: Archivo 800, ls 0.5px (§2, §5 tag de status).
  ///
  /// §2 permite 8.5px, mas §8 e o `CLAUDE.md` proíbem texto de UI **abaixo de
  /// 9px**. O conflito é real dentro da spec-fonte e o piso vence (A-02):
  /// este token usa **9.0**, o menor tamanho legal do sistema.
  static const TextStyle microTag = TextStyle(
    fontFamily: familiaUi,
    fontSize: 9,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );

  /// Chip de seleção: Archivo 800 13px, CAIXA ALTA (§5).
  static const TextStyle chip = TextStyle(
    fontFamily: familiaUi,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  /// Input: Archivo 600 15px (§5).
  static const TextStyle input = TextStyle(
    fontFamily: familiaUi,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: BoraColors.ink,
  );

  /// Valor central do stepper: Archivo 800 17px (§5).
  static const TextStyle stepperValor = TextStyle(
    fontFamily: familiaUi,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: BoraColors.ink,
  );

  /// Toast: Archivo 800 13px, ls .5px, `cream` sobre `ink` (§5).
  static const TextStyle toast = TextStyle(
    fontFamily: familiaUi,
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    color: BoraColors.cream,
  );

  /// Label do rodapé fixo: Archivo 800 11px, ls 1px, `text-2` (§5).
  static const TextStyle rodapeLabel = TextStyle(
    fontFamily: familiaUi,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
    color: BoraColors.text2,
  );

  /// Sublinha vermelha do rodapé fixo: Archivo 700 12.5px (§5).
  static const TextStyle rodapeSublinha = TextStyle(
    fontFamily: familiaUi,
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: BoraColors.primary,
  );

  /// Label do card-herói escuro: Archivo 800 12px, ls 1px, `yellow` (§5).
  static const TextStyle heroiLabel = TextStyle(
    fontFamily: familiaUi,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 1,
    color: BoraColors.yellow,
  );

  /// Sublinha do card-herói escuro: Archivo 700 13px, `primary` (§5).
  static const TextStyle heroiSublinha = TextStyle(
    fontFamily: familiaUi,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: BoraColors.primary,
  );

  /// Extremos da barra de faixa de preço: Archivo 700 10px, `text-3` (§5).
  static const TextStyle extremosFaixa = TextStyle(
    fontFamily: familiaUi,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: BoraColors.text3,
  );

  /// Todos os estilos declarados acima.
  ///
  /// A lista é **contrato**, não conveniência: é por ela que os testes de
  /// DS-04 varrem o sistema inteiro (piso de 9px, família válida, peso não
  /// nulo). Um estilo que não entre aqui escapa da verificação — e há teste
  /// que compara esta lista com as declarações do arquivo.
  static const List<TextStyle> todos = <TextStyle>[
    logoHero,
    tituloTela,
    tituloCard,
    tituloCardGrande,
    valorHeroi,
    valorRodape,
    tituloSheet,
    labelSecao,
    botao,
    botaoGrande,
    linhaLista,
    sublinhaLista,
    corpo,
    dica,
    microTag,
    chip,
    input,
    stepperValor,
    toast,
    rodapeLabel,
    rodapeSublinha,
    heroiLabel,
    heroiSublinha,
    extremosFaixa,
  ];
}
