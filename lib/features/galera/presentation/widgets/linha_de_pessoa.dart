import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../galera_textos.dart';

/// O card-linha de uma pessoa na seção "PESSOAS" de T-05: "avatar colorido,
/// nome + badge 'VOCÊ' (quando for o usuário), sublinha 'dieta · bebe 🍺/não
/// bebe 🚫', tag de papel (cores RN-22/DS §5) e caret".
///
/// **A linha é controlada**: ela não guarda se está aberta e não decide nada.
/// Toca-se nela, ela emite [onAlternar]; quem sabe o que a alternância
/// significa é o bloc, porque "1 aberta por vez" é regra entre irmãs
/// (GAL-10 AC1).
///
/// **Por que não `BoraExpandableRow`**: aquela linha desenha os slots fixos de
/// §5 — título e caret — e não tem onde receber avatar, badge, sublinha e tag.
/// A linha é composta aqui a partir dos **mesmos tokens**, e reusa os glifos
/// de caret de [BoraExpandableRow] para os dois acordeões não divergirem no
/// primeiro ajuste (SPEC_DEVIATION declarada em `design.md` §2.3).
///
/// **Nenhuma cor é escolhida aqui.** A tag vem de
/// [GaleraTextos.statusDoPapel], e é o enum do design system que fixa o par de
/// cores de cada papel (GAL-08).
class LinhaDePessoa extends StatefulWidget {
  const LinhaDePessoa({
    required this.pessoa,
    required this.aberta,
    required this.onAlternar,
    super.key,
  });

  /// O vão horizontal entre os blocos da linha — o ritmo de §5.
  static double get vao => BoraListCard.vaoDoEmoji;

  /// O vão curto entre o nome e o badge, e entre a tag e o caret.
  static double get vaoCurto => BoraSpacing.tag.left;

  /// O fundo em repouso: a superfície branca do card de §5.
  ///
  /// Opaco de propósito: a sombra dura do sistema não é recortada como a do
  /// CSS, e sobre fundo transparente ela apareceria por cima do conteúdo.
  static const Color fundoEmRepouso = BoraColors.white;

  /// O fundo sob o ponteiro — **GAL-22 AC6**, o hover que W-04 exige de todo
  /// elemento clicável.
  ///
  /// `paper`, e não uma cor nova: é o mesmo par que §5 já fixa para o hover do
  /// botão secundário sobre branco. A linha ganha estado de hover reusando o
  /// token, sem acrescentar regra visual que o arquivo 02 não escreve.
  static const Color fundoNoHover = BoraColors.paper;

  final Pessoa pessoa;

  /// Se o painel desta pessoa está à mostra — muda só o caret. É propriedade,
  /// não estado.
  final bool aberta;

  /// Emitido quando a linha inteira é tocada.
  final VoidCallback onAlternar;

  @override
  State<LinhaDePessoa> createState() => _LinhaDePessoaState();
}

/// O estado é **só o hover** (GAL-22 AC6): se a linha está aberta continua
/// sendo propriedade, porque "1 aberta por vez" é regra entre irmãs e mora no
/// bloc.
class _LinhaDePessoaState extends State<LinhaDePessoa> {
  bool _sobHover = false;

  void _pairar(bool valor) {
    if (_sobHover == valor) return;
    setState(() => _sobHover = valor);
  }

  @override
  Widget build(BuildContext context) {
    final pessoa = widget.pessoa;
    final sublinha = GaleraTextos.sublinhaDe(pessoa);

    return MouseRegion(
      // W-04 e §4: o ponteiro diz que a linha é clicável antes do toque.
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _pairar(true),
      onExit: (_) => _pairar(false),
      child: GestureDetector(
        // O alvo é a linha inteira, não só o texto (§5).
        behavior: HitTestBehavior.opaque,
        onTap: widget.onAlternar,
        child: ColoredBox(
          color: _sobHover
              ? LinhaDePessoa.fundoNoHover
              : LinhaDePessoa.fundoEmRepouso,
          child: Padding(
            padding: BoraSpacing.linhaLista,
            child: Row(
              children: [
                BoraAvatar(nome: pessoa.nome),
                SizedBox(width: LinhaDePessoa.vao),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              pessoa.nome,
                              style: BoraTextStyles.linhaLista,
                              // Nome longo trunca; estourar o card seria pior
                              // que não caber (Edge Case da `spec.md`).
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (pessoa.voce) ...[
                            SizedBox(width: LinhaDePessoa.vaoCurto),
                            const _BadgeVoce(),
                          ],
                        ],
                      ),
                      if (sublinha != null)
                        Text(sublinha, style: BoraTextStyles.sublinhaLista),
                    ],
                  ),
                ),
                SizedBox(width: LinhaDePessoa.vao),
                BoraStatusTag(status: GaleraTextos.statusDoPapel(pessoa.papel)),
                SizedBox(width: LinhaDePessoa.vaoCurto),
                Text(
                  widget.aberta
                      ? BoraExpandableRow.caretAberto
                      : BoraExpandableRow.caretFechado,
                  style: BoraTextStyles.linhaLista,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// O badge "VOCÊ" de T-05 — quem está usando o app (GAL-07 AC4).
///
/// T-05 nomeia o badge e não lhe dá cor. Ele nasce com a forma da tag de §5 e
/// o par que §1 fixa para texto sobre escuro (`ink`/`cream`): nenhuma cor nova
/// entra, e ele fica distinto dos quatro fundos de papel — que são `yellow`,
/// `purple`, branco e `wa-bubble`. Premissa declarada, não literal de spec.
class _BadgeVoce extends StatelessWidget {
  const _BadgeVoce();

  @override
  Widget build(BuildContext context) {
    return BoraSurface(
      fundo: BoraColors.ink,
      padding: BoraSpacing.tag,
      child: Text(
        GaleraTextos.badgeVoce,
        style: BoraTextStyles.microTag.copyWith(color: BoraColors.cream),
      ),
    );
  }
}
