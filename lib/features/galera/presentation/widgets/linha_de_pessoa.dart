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
class LinhaDePessoa extends StatelessWidget {
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

  final Pessoa pessoa;

  /// Se o painel desta pessoa está à mostra — muda só o caret. É propriedade,
  /// não estado.
  final bool aberta;

  /// Emitido quando a linha inteira é tocada.
  final VoidCallback onAlternar;

  @override
  Widget build(BuildContext context) {
    final sublinha = GaleraTextos.sublinhaDe(pessoa);

    return GestureDetector(
      // O alvo é a linha inteira, não só o texto (§5).
      behavior: HitTestBehavior.opaque,
      onTap: onAlternar,
      child: Padding(
        padding: BoraSpacing.linhaLista,
        child: Row(
          children: [
            BoraAvatar(nome: pessoa.nome),
            SizedBox(width: vao),
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
                          // Nome longo trunca; estourar o card seria pior que
                          // não caber (Edge Case da `spec.md`).
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (pessoa.voce) ...[
                        SizedBox(width: vaoCurto),
                        const _BadgeVoce(),
                      ],
                    ],
                  ),
                  if (sublinha != null)
                    Text(sublinha, style: BoraTextStyles.sublinhaLista),
                ],
              ),
            ),
            SizedBox(width: vao),
            BoraStatusTag(status: GaleraTextos.statusDoPapel(pessoa.papel)),
            SizedBox(width: vaoCurto),
            Text(
              aberta
                  ? BoraExpandableRow.caretAberto
                  : BoraExpandableRow.caretFechado,
              style: BoraTextStyles.linhaLista,
            ),
          ],
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
