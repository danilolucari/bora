import '../../../core/calculo/calculo.dart';
import '../../../core/design_system/design_system.dart';
import '../domain/secao_da_montagem.dart';

/// A copy literal de T-03 e W-03, num arquivo só.
///
/// Existe pela mesma razão de `home_textos.dart` e `entrar_textos.dart`: os
/// dois layouts desenham a **mesma** tela, e literal espalhado por widget
/// diverge no primeiro ajuste. Os testes afirmam o literal escrito neles,
/// porque a fonte da verdade da copy é a spec — comparar com estas constantes
/// faria o teste concordar com qualquer copy, inclusive a errada. A **única**
/// exceção é o toast: ele é token de RN-29 no design system, e ali o teste
/// compara com o token justamente para provar que ninguém o redigitou
/// *(L-008)*.
///
/// **Nenhum valor de dinheiro nasce aqui.** As duas frases do "por cabeça"
/// recebem a string já formatada por `MoneyFormatter` — RN-13 é da camada de
/// cálculo, e escrever o cifrão neste arquivo seria a primeira fórmula
/// vazando para a apresentação (MONT-08).
abstract final class MontarTextos {
  /// T-03 e W-03: o título da tela, o mesmo nas duas plataformas.
  static const String titulo = 'A CONTA DO ROLÊ';

  // --- Os quatro rótulos que divergem por plataforma (A-09) ---------------
  //
  // Declarados **em par**, e não resolvidos por um `if` espalhado pelos
  // widgets: T-03 e W-03 escrevem frases diferentes para o mesmo controle, e
  // unificá-las seria escolher qual das duas specs desobedecer.

  /// T-03: o rótulo da seção de steppers no compacto.
  static const String secaoDePessoasCompacto = 'CONFIRMADOS + EXTRAS SEM APP';

  /// W-03: o mesmo bloco, com a copy do web.
  static const String secaoDePessoasExpandido = 'QUEM CONFIRMOU';

  /// T-03: o rótulo do segmented de duração no compacto.
  static const String duracaoCompacto = 'QUANTO TEMPO DE FESTA?';

  /// W-03: o mesmo segmented, com a copy do web.
  static const String duracaoExpandido = 'ATÉ QUE HORAS?';

  // --- As três linhas do card de contagem (T-03, iguais em W-03) ----------

  /// T-03: "👨 Homens" — corpo em sentence case (§7), emoji à esquerda.
  static const String homens = '👨 Homens';
  static const String mulheres = '👩 Mulheres';
  static const String criancas = '🧒 Crianças';

  // --- As três seções de chips, iguais nas duas plataformas (AD-018) ------

  static const String naGrelha = 'NA GRELHA';
  static const String naGeladeira = 'NA GELADEIRA';
  static const String prosFortes = 'PROS FORTES';

  /// O rótulo de [secao].
  ///
  /// A copy mora aqui e não em `SecaoDaMontagem`: o domínio é Dart puro e
  /// declara explicitamente que rótulo é da camada de apresentação. `switch`
  /// exaustivo — uma seção nova quebra a compilação em vez de aparecer sem
  /// nome na tela.
  static String rotuloDaSecao(SecaoDaMontagem secao) => switch (secao) {
        SecaoDaMontagem.naGrelha => naGrelha,
        SecaoDaMontagem.naGeladeira => naGeladeira,
        SecaoDaMontagem.prosFortes => prosFortes,
      };

  /// T-03 e W-03: as quatro opções do segmented, **na ordem literal**.
  static const List<String> opcoesDeDuracao = ['2h', '4h', '6h', 'Dia'];

  // --- O bloco do dinheiro ------------------------------------------------

  /// T-03: o rótulo do rodapé fixo. Também abre o rótulo do card-herói de
  /// W-03, e por isso é uma constante só.
  static const String saiPor = 'SAI POR';

  /// T-03: a sublinha do rodapé fixo.
  ///
  /// [valorFormatado] chega pronto de `MoneyFormatter.reais` — este arquivo
  /// não formata, não arredonda e não divide (RN-13, MONT-08).
  static String porCabecaCompacto(String valorFormatado) =>
      '≈ $valorFormatado / cabeça';

  /// W-03: a mesma informação, com a frase do web. Mostra **o mesmo número**
  /// que [porCabecaCompacto] — só a frase muda (A-09).
  static String porCabecaExpandido(String valorFormatado) =>
      'dividido dá $valorFormatado por cabeça';

  /// W-03: a label amarela do card-herói — "SAI POR · {N} PESSOAS ·
  /// {duração}".
  ///
  /// A duração vem de `rotuloDeDuracao` (`4 horas`, `Dia todo`), da camada de
  /// cálculo: RN-13 fixa os dois rótulos e A-15 manda "Dia" virar "Dia todo".
  ///
  /// *SPEC_PRECISION_GAP*: W-03 escreve "{N} PESSOAS" e não dá a forma
  /// singular. O literal fica como a spec o escreve — flexionar aqui seria
  /// inventar copy que nenhuma spec declara.
  static String labelDoHeroi({
    required int pessoas,
    required int duracaoHoras,
  }) =>
      '$saiPor · $pessoas PESSOAS · ${rotuloDeDuracao(duracaoHoras)}';

  // --- Saídas da tela -----------------------------------------------------

  /// T-03: o CTA do rodapé fixo.
  static const String fecharLista = 'FECHAR LISTA →';

  /// W-03: o CTA do rail. Não existe "FECHAR LISTA" no web — lá o formulário
  /// e a lista coexistem.
  static const String mandarNoGrupo = 'MANDAR NO GRUPO 📲';

  /// A ação secundária do rail (A-14). W-03 pede "salvar sem mandar no grupo"
  /// sem dar a copy; este rótulo é **default declarado**, não literal de spec.
  static const String salvarRole = 'SALVAR ROLÊ';

  /// O toast que "SALVAR ROLÊ" dispara — MONT-23.
  ///
  /// **Referência**, nunca cópia: o literal de RN-29 mora em
  /// [BoraToastTexts.roleSalvo], e redigitá-lo aqui criaria uma segunda fonte
  /// da verdade que divergiria no primeiro ajuste *(L-008)*.
  static const String toastRoleSalvo = BoraToastTexts.roleSalvo;

  /// W-03: a linha final de cada categoria da lista viva.
  static const String subtotal = 'SUBTOTAL';

  /// W-03: a identidade do rolê à direita da linha de título —
  /// "{NOME DA FESTA} · {DATA}".
  static String identidadeExpandida({
    required String nome,
    required String data,
  }) =>
      '$nome · $data';
}
