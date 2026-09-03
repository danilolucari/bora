import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/festas/festas.dart';
import '../../domain/chave_de_pessoa.dart';
import '../bloc/galera_state.dart';
import '../galera_textos.dart';
import 'card_do_link.dart';
import 'faixa_de_preferencias.dart';
import 'galera_compacta.dart';

/// W-04 — a galera no expandido (GAL-22, GAL-23).
///
/// "Duas colunas: card do link (escuro, sombra roxa) fixo à esquerda (370px);
/// lista de pessoas com accordions à direita".
///
/// **Sem rodapé fixo** (W-R2): o CTA "+ CONVIDAR MAIS GENTE 🔗" mora na coluna
/// esquerda, logo abaixo do card do link (A-17).
///
/// **As duas telas montam os mesmos widgets.** [CardDoLink],
/// [FaixaDePreferencias], [SecaoDePessoas] e [CabecalhoDaGalera] vêm de
/// `galera_compacta.dart` — um estado, dois arranjos, que é o que torna W-R1
/// estrutural em vez de disciplina. Se o expandido montasse widgets próprios,
/// a copy dos dois divergiria no primeiro ajuste (`design.md` §7.5).
///
/// **A coluna esquerda é sticky por construção**, e não por plugin: ela é uma
/// coluna de largura fixa montada **fora** da área rolável, como o rail de
/// W-04 na Lista. Quem rola é a coluna da direita — rolagem só no documento,
/// nunca de lado (W-R4).
///
// SPEC_PRECISION_GAP: W-04 dá as duas colunas e o que vai em cada uma, mas
// não diz onde fica a faixa amarela de RN-21. Ela renderiza no topo da coluna
// **direita**, imediatamente acima de "PESSOAS": a faixa fala do efeito das
// preferências sobre a lista, e as preferências são o que se edita ali. A
// ordem relativa de T-05 (faixa antes das pessoas) é preservada.
class GaleraExpandida extends StatelessWidget {
  const GaleraExpandida({
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

  /// W-04: "card do link … fixo à esquerda (370px)".
  static const double larguraDaColuna = 370;

  /// A chave da coluna esquerda — é por ela que a largura é **medida**.
  static const Key colunaKey = Key('galera-coluna-do-link');

  /// A chave do CTA do expandido.
  ///
  /// Distinta da do rodapé compacto de propósito: é o que permite afirmar que
  /// o rodapé fixo **não existe** aqui (W-R2) sem que uma chave compartilhada
  /// esconda a diferença.
  static const Key ctaKey = Key('galera-expandida-cta-convidar');

  /// O padding do container e o vão entre as duas colunas.
  ///
  /// W-04 não dá medida a esta tela: fica o ritmo de §5
  /// (`BoraSpacing.sheet`), para nenhum número novo entrar no sistema — o
  /// mesmo critério do expandido da Lista.
  static const EdgeInsets paddingDoContainer = BoraSpacing.sheet;

  /// O vão entre a linha de título e o grid, e entre as duas colunas.
  static double get vaoDoGrid => BoraSpacing.sheet.left;

  final GaleraState estado;
  final CapacidadesDaGalera capacidades;
  final VoidCallback aoCopiar;
  final ValueChanged<NivelDoLink> aoEscolherNivel;
  final ValueChanged<ChaveDePessoa> aoAlternarLinha;
  final void Function(ChaveDePessoa chave, PapelNaFesta papel) aoEscolherPapel;
  final void Function(ChaveDePessoa chave, Dieta dieta) aoEscolherDieta;
  final void Function(ChaveDePessoa chave, bool bebe) aoAlternarBebida;

  /// Sem link, os dois botões ficam inertes — a mesma regra do compacto.
  bool get temLink => estado.galera?.convite.codigo.isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    final galera = estado.galera;

    return Padding(
      padding: paddingDoContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CabecalhoDaGalera(estado: estado),
          if (estado.situacao == SituacaoDaGalera.falhou) ...[
            SizedBox(height: vaoDoGrid),
            const FaixaDeFalhaDaGalera(),
          ],
          SizedBox(height: vaoDoGrid),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  key: colunaKey,
                  width: larguraDaColuna,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (galera != null) ...[
                        CardDoLink(
                          convite: galera.convite,
                          onCopiar: aoCopiar,
                          onEscolherNivel: aoEscolherNivel,
                          podeConfigurarNivel:
                              capacidades.podeConfigurarNivel,
                        ),
                        SizedBox(height: vaoDoGrid),
                      ],
                      // W-R2 e A-17: o CTA mora aqui, e não num rodapé fixo
                      // que o web não tem.
                      BoraPrimaryButton(
                        key: ctaKey,
                        rotulo: GaleraTextos.convidarMaisGente,
                        acento: BoraAccent.purple,
                        larguraTotal: true,
                        onPressed: temLink ? aoCopiar : null,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: vaoDoGrid),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (galera != null)
                          ...corpoDaDireita(galera.composicao, galera.pessoas),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A faixa amarela e a seção PESSOAS — os mesmos widgets do compacto.
  List<Widget> corpoDaDireita(
    ComposicaoDaFesta composicao,
    List<Pessoa> pessoas,
  ) {
    final faixa = FaixaDePreferencias(composicao: composicao);

    return [
      if (faixa.texto.isNotEmpty) ...[
        faixa,
        SizedBox(height: vaoDoGrid),
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
}
