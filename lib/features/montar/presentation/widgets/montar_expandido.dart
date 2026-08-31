import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../bloc/montar_event.dart';
import '../bloc/montar_state.dart';
import '../montar_textos.dart';
import 'formulario_de_montagem.dart';
import 'rail_do_custo.dart';

/// W-03 inteiro — Montar e Lista na **mesma** tela (MONT-09, MONT-10,
/// MONT-12, MONT-13).
///
/// "A fusão é a diferença estrutural do web: **não existe passo 'Fechar
/// lista'**". Por isso não há [BoraFooterBar] aqui: o CTA mora no rail (W-R2),
/// e a lista que no celular é a tela seguinte já está à direita.
///
/// **As seções não são reescritas.** A coluna da esquerda monta o **mesmo**
/// [FormularioDeMontagem] de T-03, trocando só os quatro rótulos que divergem
/// (A-09) e passando o teto de 360px que W-03 dá ao segmented. É isso que faz
/// W-R1 ser estrutural: um estado, dois arranjos.
///
/// **O rail não rola.** O formulário rola dentro da própria coluna e o
/// [RailDoCusto] é coluna irmã, fora da rolagem — sticky por construção, sem
/// `Sliver` e sem plugin. A única rolagem do rail é a da lista viva, nos 330px
/// de W-03 (W-R4).
///
/// *SPEC_PRECISION_GAP*: W-03 não desenha botão de voltar ("voltar quando
/// aplicável", sem dizer quando) e não desenha a edição de nome e data. A
/// linha de título **reflete** os dois, que é o que P1-5 AC3 pede do web
/// ("no header mobile e na linha de título do web"); editar continua sendo
/// afordância do header de T-03. Nenhum controle é inventado aqui.
class MontarExpandido extends StatelessWidget {
  const MontarExpandido({
    required this.estado,
    required this.aoAlterarContagem,
    required this.aoAlternarItem,
    required this.aoSelecionarDuracao,
    required this.aoMandarNoGrupo,
    required this.aoSalvar,
    super.key,
  });

  /// W-03: "Container 1060px".
  static const double larguraDoContainer = 1060;

  /// W-03: "padding 30px 36px 48px".
  static const EdgeInsets paddingDoContainer =
      EdgeInsets.fromLTRB(36, 30, 36, 48);

  /// W-03: "'A CONTA DO ROLÊ' 34px" — o degrau web do mesmo papel que T-03
  /// usa em 22px (§"Tipografia sobe um degrau" do arquivo 06). O design
  /// system é dono do papel; a spec de tela é dona do degrau.
  static const double tamanhoDoTitulo = 34;

  /// W-03: "gap 30px" — entre a linha de título e o grid, e entre as duas
  /// colunas.
  static const double vaoDoGrid = 30;

  /// W-03: "segmented 2h/4h/6h/Dia (máx 360px)".
  ///
  /// Mora aqui, e não na [SecaoDeDuracao]: é número **de W-03**, e T-03 não
  /// declara teto nenhum.
  static const double larguraMaximaDaDuracao = 360;

  /// O estado da tela. Formulário, card-herói e lista viva leem o **mesmo**
  /// objeto — é o que faz MONT-12 ("recalculam juntos") ser estrutura e não
  /// disciplina.
  final MontarState estado;

  final void Function(TipoDeCabeca tipo, int delta) aoAlterarContagem;
  final void Function(ChaveItem chave) aoAlternarItem;
  final void Function(int horas) aoSelecionarDuracao;
  final VoidCallback aoMandarNoGrupo;
  final VoidCallback aoSalvar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: larguraDoContainer),
        child: Padding(
          padding: paddingDoContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LinhaDeTitulo(festa: estado.festa),
              const SizedBox(height: vaoDoGrid),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // "Grid `1fr / 370px`": a esquerda é o que sobra, e é ela
                    // quem rola.
                    Expanded(
                      child: SingleChildScrollView(
                        child: FormularioDeMontagem(
                          composicao: estado.composicao,
                          rotuloDePessoas:
                              MontarTextos.secaoDePessoasExpandido,
                          rotuloDaDuracao: MontarTextos.duracaoExpandido,
                          larguraMaximaDaDuracao: larguraMaximaDaDuracao,
                          aoAlterarContagem: aoAlterarContagem,
                          aoAlternarItem: aoAlternarItem,
                          aoSelecionarDuracao: aoSelecionarDuracao,
                        ),
                      ),
                    ),
                    const SizedBox(width: vaoDoGrid),
                    RailDoCusto(
                      resultado: estado.resultado,
                      duracaoHoras: estado.composicao.duracaoHoras,
                      aoMandarNoGrupo: aoMandarNoGrupo,
                      aoSalvar: aoSalvar,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// W-03: "'A CONTA DO ROLÊ' 34px + 'CHURRAS DO RAFA · SÁB 18 JUL' 800 12px
/// ls 1px `text-2` à direita".
class _LinhaDeTitulo extends StatelessWidget {
  const _LinhaDeTitulo({required this.festa});

  final Festa festa;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          MontarTextos.titulo,
          style: BoraTextStyles.tituloTela.copyWith(
            fontSize: MontarExpandido.tamanhoDoTitulo,
          ),
        ),
        const Spacer(),
        // §2 não tem um papel de 800 12px ls 1px em `text-2`, e inventar um
        // `TextStyle` seria medida fora dos tokens: fica o papel de label do
        // sistema, que é o mesmo peso e a mesma cor.
        Text(
          MontarTextos.identidadeExpandida(
            nome: festa.nome,
            data: festa.data,
          ),
          style: BoraTextStyles.labelSecao,
        ),
      ],
    );
  }
}
