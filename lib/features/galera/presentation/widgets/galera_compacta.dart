import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/festas/festas.dart';
import '../../domain/chave_de_pessoa.dart';
import '../../domain/permissoes.dart';
import '../bloc/galera_state.dart';
import '../galera_textos.dart';
import 'card_do_link.dart';
import 'faixa_de_preferencias.dart';
import 'linha_de_pessoa.dart';
import 'painel_da_pessoa.dart';

/// T-05 inteira no compacto — GAL-01, GAL-03, GAL-06, GAL-09, GAL-10, GAL-13,
/// GAL-24, GAL-25.
///
/// A ordem é a da spec-fonte, de cima para baixo: header "A GALERA" + sub,
/// card do link, faixa amarela de RN-21, seção "PESSOAS" com as linhas e o
/// painel aberto, e o rodapé fixo com "+ CONVIDAR MAIS GENTE 🔗".
///
/// **O rodapé não rola.** Ele é irmão da área rolável, não filho dela — o CTA
/// que chama a galera fica à vista enquanto o anfitrião mexe nas preferências
/// lá embaixo (a mesma estrutura de T-03 e T-04).
///
/// **Só desenha.** O estado chega pronto do `GaleraBloc` e os toques saem por
/// callback; quem escreve na porta é o bloc (AD-020). Nenhuma conta nasce aqui
/// (GAL-15): a faixa amarela recebe o registro e a frase inteira vem de
/// `resumoDasPreferencias`, em `core/calculo`.
///
// SPEC_DEVIATION: o arquivo 02 §8 limita a **2 acentos por tela** e esta usa
// três — roxo (sombra do card do link e do CTA), amarelo (label do link e
// faixa de RN-21) e vermelho (o ativo de "RESTRIÇÃO ALIMENTAR").
// Reason: T-05 é literal nos três usos. Roxo e amarelo são estruturais —
// "galera/link" e a faixa de dica —, e o vermelho entra como **estado ativo**
// de um controle, não como cor de superfície. A leitura estrita de §8 continua
// violada — declarada, não silenciada (D-2 / A-16 da `spec.md`).
class GaleraCompacta extends StatelessWidget {
  const GaleraCompacta({
    required this.estado,
    required this.capacidades,
    required this.aoCopiar,
    required this.aoEscolherNivel,
    required this.aoAlternarLinha,
    required this.aoEscolherPapel,
    required this.aoEscolherDieta,
    required this.aoAlternarBebida,
    super.key,
  });

  /// O padding do header.
  ///
  /// T-05 não dá medida de margem à tela: fica o ritmo horizontal que o rodapé
  /// fixo de §5 já tem (`BoraSpacing.rodape`), para nenhum número novo entrar
  /// no sistema — o mesmo critério de T-04.
  static final EdgeInsets paddingDoHeader = EdgeInsets.fromLTRB(
    BoraSpacing.rodape.left,
    BoraSpacing.rodape.top,
    BoraSpacing.rodape.right,
    0,
  );

  /// O padding do corpo rolável — o mesmo ritmo, com a folga de baixo de §5.
  static const EdgeInsets paddingDoCorpo = BoraSpacing.sheet;

  /// O vão entre um bloco e o seguinte — o ritmo vertical de §5.
  static double get vaoEntreBlocos => BoraSpacing.linhaLista.top;

  /// O estado da tela. Header, card, faixa e linhas leem o **mesmo** objeto:
  /// não há como um deles ficar para trás (W-R1).
  final GaleraState estado;

  /// O que o usuário do app pode nesta festa — GAL-27.
  final CapacidadesDaGalera capacidades;

  /// "COPIAR 🔗" e "+ CONVIDAR MAIS GENTE 🔗" chamam **este mesmo** callback:
  /// é o que impede GAL-03 AC6 e AC7 de divergirem.
  final VoidCallback aoCopiar;

  final ValueChanged<NivelDoLink> aoEscolherNivel;
  final ValueChanged<ChaveDePessoa> aoAlternarLinha;
  final void Function(ChaveDePessoa chave, PapelNaFesta papel) aoEscolherPapel;
  final void Function(ChaveDePessoa chave, Dieta dieta) aoEscolherDieta;
  final void Function(ChaveDePessoa chave, bool bebe) aoAlternarBebida;

  @override
  Widget build(BuildContext context) {
    final galera = estado.galera;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: paddingDoHeader,
          child: CabecalhoDaGalera(estado: estado),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: paddingDoCorpo,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // GAL-25: a falha é mensagem na tela, nunca tela branca — e o
                // card do link continua abaixo, funcionando.
                if (estado.situacao == SituacaoDaGalera.falhou) ...[
                  const FaixaDeFalhaDaGalera(),
                  SizedBox(height: vaoEntreBlocos),
                ],
                if (galera != null)
                  ...corpoDaGalera(
                    galera.convite,
                    galera.composicao,
                    galera.pessoas,
                  ),
              ],
            ),
          ),
        ),
        RodapeDaGalera(aoConvidar: temLink ? aoCopiar : null),
      ],
    );
  }

  /// O card do link, a faixa amarela e a seção PESSOAS — **os mesmos três**
  /// que W-04 rearranja em duas colunas (`design.md` §7.5).
  List<Widget> corpoDaGalera(
    ConviteDaFesta convite,
    ComposicaoDaFesta composicao,
    List<Pessoa> pessoas,
  ) {
    final faixa = FaixaDePreferencias(composicao: composicao);

    return [
      CardDoLink(
        convite: convite,
        onCopiar: aoCopiar,
        onEscolherNivel: aoEscolherNivel,
        podeConfigurarNivel: capacidades.podeConfigurarNivel,
      ),
      SizedBox(height: vaoEntreBlocos),
      // GAL-13 AC7: sem termo algum a dizer, a faixa não renderiza — e o vão
      // dela não fica para trás.
      if (faixa.texto.isNotEmpty) ...[
        faixa,
        SizedBox(height: vaoEntreBlocos),
      ],
      SecaoDePessoas(
        pessoas: pessoas,
        aberta: estado.aberta,
        podeGerenciarPapeis: capacidades.podeGerenciarPapeis,
        aoAlternarLinha: aoAlternarLinha,
        aoEscolherPapel: aoEscolherPapel,
        aoEscolherDieta: aoEscolherDieta,
        aoAlternarBebida: aoAlternarBebida,
      ),
    ];
  }

  /// Se há link a copiar — `design.md` §14: festa criada antes de a spec 09
  /// gerar códigos não tem URL, e os dois botões ficam inertes em vez de
  /// entregarem `bora.app/c/` seco.
  bool get temLink => estado.galera?.convite.codigo.isNotEmpty ?? false;
}

/// As duas capacidades que a tela consulta — GAL-27, RN-22.
///
/// Derivadas num lugar só, e **sempre** por `papelDoUsuario` + `pode(...)` de
/// `permissoes.dart`: nem a página nem os dois layouts decidem permissão por
/// conta própria, que é como a tabela de RN-22 acabaria copiada (AD-031).
class CapacidadesDaGalera {
  const CapacidadesDaGalera({
    required this.podeConfigurarNivel,
    required this.podeGerenciarPapeis,
  });

  /// As capacidades de quem está usando o app, pela marca `voce` de [Pessoa].
  ///
  /// Lista sem ninguém marcado ⇒ anfitrião, pela premissa **P-1** declarada em
  /// `permissoes.dart` — e é o que faz a festa recém-criada de GAL-24 AC2
  /// continuar com o card do link funcional.
  factory CapacidadesDaGalera.de(List<Pessoa> pessoas) {
    final papel = papelDoUsuario(pessoas);

    return CapacidadesDaGalera(
      podeConfigurarNivel: pode(papel, Capacidade.configurarNivelDoLink),
      podeGerenciarPapeis: pode(papel, Capacidade.gerenciarPapeis),
    );
  }

  /// GAL-27 AC1: `false` ⇒ o segmented "QUEM ABRIR O LINK PODE…" some da
  /// árvore; a URL e o "COPIAR 🔗" ficam.
  final bool podeConfigurarNivel;

  /// GAL-27 AC2: `false` ⇒ "NÍVEL DE ACESSO" some de **todos** os painéis;
  /// dieta e bebida ficam.
  final bool podeGerenciarPapeis;
}

/// O header de T-05: "A GALERA" e o sub "{n} pessoas · {n} confirmadas".
///
/// O sub é **derivado** da leitura (A-10), e não renderiza enquanto nada
/// chegou do repositório: T-05 não desenha estado de carregamento e RN-29 não
/// dá copy para ele — inventar uma seria copy nossa num produto de copy
/// literal.
class CabecalhoDaGalera extends StatelessWidget {
  const CabecalhoDaGalera({required this.estado, super.key});

  final GaleraState estado;

  /// `null` enquanto a Galera não tem contagem verdadeira a dizer.
  String? get subtitulo {
    final galera = estado.galera;
    if (galera == null) return null;

    return GaleraTextos.subtitulo(
      pessoas: galera.pessoas.length,
      confirmadas: galera.confirmados,
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitulo = this.subtitulo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(GaleraTextos.titulo, style: BoraTextStyles.tituloTela),
        if (subtitulo != null) ...[
          SizedBox(height: BoraSpacing.tag.top),
          Text(subtitulo, style: BoraTextStyles.corpo),
        ],
      ],
    );
  }
}

/// A mensagem do estado `falhou`, igual nos dois layouts (GAL-25).
///
/// Existe como widget próprio pelo mesmo motivo de `FaixaDeFalha` na Home: o
/// mobile e o web não podem discordar sobre como o produto avisa que não
/// conseguiu carregar.
class FaixaDeFalhaDaGalera extends StatelessWidget {
  const FaixaDeFalhaDaGalera({super.key});

  @override
  Widget build(BuildContext context) =>
      Text(GaleraTextos.falha, style: BoraTextStyles.labelSecao);
}

/// A seção "PESSOAS" de T-05 — GAL-06, GAL-09, GAL-10.
///
/// Uma linha por pessoa nomeada, **na ordem do repositório** (A-15), e o
/// painel logo abaixo da linha aberta. **Um aberto por vez** não é decidido
/// aqui: quem guarda a chave aberta é o `GaleraBloc`, e é o que faz o painel
/// sobreviver à emissão do stream (GAL-26) e à travessia dos 900px (GAL-23).
///
/// **Sem contagem de pendentes e sem linha para quem não tem nome**
/// (GAL-09 AC9): as linhas saem de [pessoas], que são as pessoas nomeadas da
/// festa, e nada mais é desenhado.
///
/// Sem pessoa nenhuma, sobra o rótulo da seção — e **nenhuma copy inventada**
/// (GAL-24 AC2): a frase que o produto diz nesse estado é o sub do header.
class SecaoDePessoas extends StatelessWidget {
  const SecaoDePessoas({
    required this.pessoas,
    required this.aberta,
    required this.podeGerenciarPapeis,
    required this.aoAlternarLinha,
    required this.aoEscolherPapel,
    required this.aoEscolherDieta,
    required this.aoAlternarBebida,
    super.key,
  });

  /// §5: as linhas do card de lista são "separadas por `2px solid divider`" —
  /// do token, para o card desta seção e o de §5 não divergirem.
  static const double espessuraDoDivisor = BoraListCard.espessuraDoDivisor;

  final List<Pessoa> pessoas;
  final ChaveDePessoa? aberta;
  final bool podeGerenciarPapeis;
  final ValueChanged<ChaveDePessoa> aoAlternarLinha;
  final void Function(ChaveDePessoa chave, PapelNaFesta papel) aoEscolherPapel;
  final void Function(ChaveDePessoa chave, Dieta dieta) aoEscolherDieta;
  final void Function(ChaveDePessoa chave, bool bebe) aoAlternarBebida;

  @override
  Widget build(BuildContext context) {
    final chaves = ChaveDePessoa.de(pessoas);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(GaleraTextos.secaoPessoas, style: BoraTextStyles.labelSecao),
        SizedBox(height: BoraSpacing.tag.top),
        if (pessoas.isNotEmpty)
          // Fundo branco e opaco: a sombra dura do sistema não é recortada
          // como a do CSS, e sobre fundo transparente ela apareceria por cima
          // do conteúdo das linhas.
          BoraSurface(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var indice = 0; indice < pessoas.length; indice++) ...[
                  if (indice > 0)
                    const SizedBox(
                      height: espessuraDoDivisor,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: BoraColors.divider),
                      ),
                    ),
                  LinhaDePessoa(
                    pessoa: pessoas[indice],
                    aberta: chaves[indice] == aberta,
                    onAlternar: () => aoAlternarLinha(chaves[indice]),
                  ),
                  if (chaves[indice] == aberta)
                    PainelDaPessoa(
                      chave: chaves[indice],
                      pessoa: pessoas[indice],
                      podeGerenciarPapeis: podeGerenciarPapeis,
                      onEscolherPapel: aoEscolherPapel,
                      onEscolherDieta: aoEscolherDieta,
                      onAlternarBebida: aoAlternarBebida,
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// O rodapé fixo de T-05: "CTA '+ CONVIDAR MAIS GENTE 🔗' (sombra roxa) →
/// copia o link (toast)".
///
// SPEC_DEVIATION: `design.md` §7.5 monta este rodapé com [BoraFooterBar], e
// ele não serve inteiro — o rodapé de §5 tem o bloco "SAI POR"/valor/sublinha
// à esquerda, e T-05 não dá **nenhum** número a esta tela: a Galera não fala
// de dinheiro.
// Reason: composto aqui a partir dos tokens do próprio [BoraFooterBar] —
// `bordaSuperior` e `BoraSpacing.rodape` —, com o CTA ocupando a largura
// inteira. Nenhum número novo entra no sistema e `core/design_system/` não é
// tocado. Mesmo caminho que o rodapé de T-04 já tomou.
class RodapeDaGalera extends StatelessWidget {
  const RodapeDaGalera({required this.aoConvidar, super.key});

  /// A chave do CTA — é por ela que o teste distingue o botão do rodapé do
  /// "COPIAR 🔗" que mora dentro do card.
  static const Key ctaKey = Key('galera-cta-convidar');

  /// `null` ⇒ o CTA fica **inerte**: festa sem código de link não tem o que
  /// copiar (`design.md` §14).
  final VoidCallback? aoConvidar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BoraColors.paper,
        border: BoraFooterBar.bordaSuperior,
        borderRadius: BoraBorders.raio,
      ),
      child: Padding(
        padding: BoraSpacing.rodape,
        child: BoraPrimaryButton(
          key: ctaKey,
          rotulo: GaleraTextos.convidarMaisGente,
          // §1: o roxo é a cor de "galera/link", e T-05 pede a sombra roxa
          // neste CTA — é o mesmo significado do card do link.
          acento: BoraAccent.purple,
          larguraTotal: true,
          onPressed: aoConvidar,
        ),
      ),
    );
  }
}
