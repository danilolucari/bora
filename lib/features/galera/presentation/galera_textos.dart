import '../../../core/calculo/calculo.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/festas/festas.dart';

/// A copy da tela A GALERA — T-05, W-04, RN-21, RN-23 e RN-29.
///
/// Fica junta e nomeada pelo mesmo motivo de `home_textos.dart`: literal de
/// copy espalhado por dois layouts diverge no primeiro ajuste, e a spec pede a
/// **mesma** frase nas duas plataformas.
///
/// Tudo aqui é literal de T-05, RN-21, RN-23 ou RN-29 — exceto três premissas
/// declaradas: [semPessoas] (A-08), o plural de [subtitulo] (A-10) e [falha]
/// (SPEC_PRECISION_GAP, `design.md` §14).
abstract final class GaleraTextos {
  /// T-05 e W-04: o título da tela.
  static const String titulo = 'A GALERA';

  /// T-05: o sub quando a festa ainda não tem pessoa nomeada nenhuma.
  ///
  /// **Premissa A-08, declarada.** T-05 só desenha o sub cheio ("5 pessoas ·
  /// 4 confirmadas"); a festa recém-criada de GAL-24 AC2 não tem o que contar,
  /// e "0 pessoas · 0 confirmadas" seria ruído com cara de erro.
  static const String semPessoas = 'nenhuma pessoa ainda';

  /// A mensagem do estado `falhou` (GAL-25).
  ///
  /// SPEC_PRECISION_GAP: nenhuma tela de `04` ou `06` desenha a Galera
  /// falhando, e nenhuma spec dá esta copy. A frase copia a **voz** que
  /// `HomeTextos.falha` ("NÃO DEU PRA CARREGAR SEUS ROLÊS") e
  /// `EntrarTextos.indisponivel` já fixaram, em caixa alta como §7 manda para
  /// label. Fica declarada como premissa, não como literal de spec.
  static const String falha = 'NÃO DEU PRA CARREGAR A GALERA';

  /// T-05: a label amarela do card do link.
  static const String labelDoLink = 'LINK PRA CONVIDAR';

  /// T-05: o botão claro do card escuro.
  static const String copiar = 'COPIAR 🔗';

  /// T-05: a label acima do segmented dos três níveis.
  ///
  /// O tempo verbal é do futuro de propósito (A-09): ela fala de quem **vai**
  /// abrir o link, e é o que faz GAL-04 (o nível não retroage) não precisar de
  /// copy de aviso.
  static const String quemAbrirPode = 'QUEM ABRIR O LINK PODE…';

  /// T-05: o cabeçalho da seção das pessoas.
  static const String secaoPessoas = 'PESSOAS';

  /// T-05: o badge de quem está usando o app.
  static const String badgeVoce = 'VOCÊ';

  /// T-05: a primeira seção do painel expandido (GAL-10 AC2).
  static const String secaoNivelDeAcesso = 'NÍVEL DE ACESSO';

  /// T-05: a segunda seção do painel expandido.
  static const String secaoRestricao = 'RESTRIÇÃO ALIMENTAR';

  /// T-05: a terceira seção do painel expandido.
  static const String secaoBebida = 'BEBIDA';

  /// T-05 e RN-21: a metade "bebe" do toggle, em CAIXA ALTA porque é botão
  /// (§7). Não confundir com o termo da sublinha, que é corpo de texto.
  static const String bebe = 'BEBE 🍺';

  /// T-05 e RN-21: a metade "não bebe" do toggle.
  static const String naoBebe = 'NÃO BEBE 🚫';

  /// T-05: a nota do painel do anfitrião — a **única** coisa que ele exibe
  /// (GAL-16).
  static const String notaDoAnfitriao =
      '👑 Anfitrião manda em tudo — acesso fixo.';

  /// T-05: o CTA do rodapé.
  static const String convidarMaisGente = '+ CONVIDAR MAIS GENTE 🔗';

  /// RN-29: o toast da cópia do link.
  ///
  /// Vem do token, **não** redigitado: RN-29 é contrato de copy do sistema
  /// inteiro, e uma segunda cópia da frase divergiria no primeiro ajuste.
  static const String linkCopiado = BoraToastTexts.linkCopiado;

  /// A URL do convite — RN-23.
  ///
  /// **Um lugar só**, e é o que faz a string exibida no card e a string
  /// escrita na área de transferência serem a mesma — inclusive quando o
  /// código tiver caractere que exigiria escape (Edge Case da `spec.md`).
  /// Montá-la em dois lugares seria montá-la de dois jeitos no primeiro
  /// ajuste.
  ///
  /// Não mora em `ConviteDaFesta`: o convite é dado, e o domínio da URL é
  /// apresentação.
  static String urlDoConvite(String codigo) => 'bora.app/c/$codigo';

  /// T-05: o sub do header, **derivado** da contagem real (A-10).
  ///
  /// T-05 escreve "5 pessoas · 4 confirmadas", que é o que sai da fixture de
  /// RN-30 — mas como consequência do dado, não como literal fixo: um literal
  /// mentiria em qualquer outro estado da tela.
  ///
  /// Sem pessoa nomeada nenhuma, vira [semPessoas] (GAL-24 AC2).
  static String subtitulo({required int pessoas, required int confirmadas}) {
    if (pessoas == 0) return semPessoas;

    return '$pessoas ${_plural(pessoas, 'pessoa')} · '
        '$confirmadas ${_plural(confirmadas, 'confirmada')}';
  }

  /// T-05: a faixa amarela — `'💡 '` e o [resumo] que RN-21 devolve.
  ///
  /// A feature concatena o emoji-âncora e **nada mais** (GAL-13 AC5): a frase
  /// inteira é de `resumoDasPreferencias`, em `core/calculo`. Resumo vazio ⇒
  /// string vazia, e quem desenha não renderiza faixa alguma (GAL-13 AC7).
  static String faixa(String resumo) => resumo.isEmpty ? '' : '💡 $resumo';

  /// RN-23: o rótulo do nível no segmented "QUEM ABRIR O LINK PODE…".
  static String rotuloDoNivel(NivelDoLink nivel) => switch (nivel) {
        NivelDoLink.soVer => 'SÓ VER',
        NivelDoLink.editarLista => 'EDITAR LISTA',
        NivelDoLink.coAnfitriao => 'CO-ANFITRIÃO',
      };

  /// Os três rótulos, **na ordem de `NivelDoLink.values`**.
  ///
  /// A ordem é contrato: é por ela que o índice do segmented vira nível, e uma
  /// lista escrita à mão poderia discordar do enum sem que nada avisasse.
  static List<String> get niveis =>
      NivelDoLink.values.map(rotuloDoNivel).toList(growable: false);

  /// RN-23: a nota dinâmica sob o segmented, literal da regra.
  static String notaDoNivel(NivelDoLink nivel) => switch (nivel) {
        NivelDoLink.soVer => 'convidados só veem a festa e confirmam presença',
        NivelDoLink.editarLista =>
          'convidados marcam o que levam e ajustam a lista',
        NivelDoLink.coAnfitriao =>
          'acesso total: editam tudo e cobram a galera',
      };

  /// RN-21: o rótulo da dieta, com o emoji que a regra escreve (A-13).
  static String rotuloDaDieta(Dieta dieta) => switch (dieta) {
        Dieta.tudo => '🍖 Come de tudo',
        Dieta.veggie => '🥗 Veggie',
        Dieta.semPorco => '🚫 Sem porco',
      };

  /// Os três rótulos de dieta, **na ordem de `Dieta.values`** — o mesmo motivo
  /// de [niveis].
  static List<String> get dietas =>
      Dieta.values.map(rotuloDaDieta).toList(growable: false);

  /// O status de §5 que corresponde a [papel] — GAL-08.
  ///
  /// Mora aqui, e num lugar só, porque é dele que saem **as duas** coisas que
  /// a tela mostra do papel: o rótulo ([rotuloDoPapel]) e o par de cores da
  /// tag. Duas tabelas — uma para a copy, outra para a cor — divergiriam sem
  /// que nenhum teste percebesse. A feature **mapeia**; quem escolhe a cor é o
  /// enum do design system.
  static BoraStatus statusDoPapel(PapelNaFesta papel) => switch (papel) {
        PapelNaFesta.anfitriao => BoraStatus.anfitriao,
        PapelNaFesta.coAnfitriao => BoraStatus.coAnfitriao,
        PapelNaFesta.convidado => BoraStatus.convidado,
        PapelNaFesta.soVe => BoraStatus.soVe,
      };

  /// O rótulo de [papel] — **do token**, nunca redigitado.
  static String rotuloDoPapel(PapelNaFesta papel) =>
      statusDoPapel(papel).rotulo;

  /// Os papéis que "NÍVEL DE ACESSO" oferece, na ordem de T-05.
  ///
  /// **`anfitriao` não está aqui, e é o ponto** (GAL-18): o painel do
  /// anfitrião não tem o controle, e o controle não tem a opção. Quem quiser
  /// atribuir o papel do dono não acha por onde.
  static const List<PapelNaFesta> papeisAtribuiveis = [
    PapelNaFesta.convidado,
    PapelNaFesta.coAnfitriao,
    PapelNaFesta.soVe,
  ];

  /// Os três rótulos de [papeisAtribuiveis], na mesma ordem.
  static List<String> get papeis =>
      papeisAtribuiveis.map(rotuloDoPapel).toList(growable: false);

  /// T-05: a sublinha do card-linha — `{dieta} · bebe 🍺` / `… · não bebe 🚫`.
  ///
  /// Omite o termo **não declarado** (A-14): `null` em `dieta` ou em `bebe` é
  /// "ninguém sabe", e escrever "come de tudo" ou "não bebe" no lugar seria
  /// inventar declaração que a pessoa não fez.
  ///
  /// Os dois ausentes ⇒ `null`, e a sublinha não renderiza. É o caso da Duda
  /// de RN-30: um `' · '` solto seria pior que linha nenhuma.
  static String? sublinhaDe(Pessoa pessoa) {
    final dieta = pessoa.dieta;
    final bebe = pessoa.bebe;

    final termos = <String>[
      if (dieta != null) rotuloDaDieta(dieta),
      if (bebe != null) (bebe ? 'bebe 🍺' : 'não bebe 🚫'),
    ];

    return termos.isEmpty ? null : termos.join(' · ');
  }

  /// [palavra] no plural quando [quantos] não é 1.
  ///
  /// Escrito aqui, e não importado de `home_textos.dart`: copy de uma feature
  /// não atravessa a fronteira de outra, e a regra é uma linha.
  static String _plural(int quantos, String palavra) =>
      quantos == 1 ? palavra : '${palavra}s';
}
