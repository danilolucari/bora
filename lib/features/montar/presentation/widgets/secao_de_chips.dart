import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/secao_da_montagem.dart';
import '../montar_textos.dart';

/// Uma seção de chips do formulário — "NA GRELHA", "NA GELADEIRA" ou
/// "PROS FORTES" (MONT-01, MONT-02).
///
/// Os chips saem de `chipsPorSecao`, e nome e emoji de cada um saem de
/// `catalogoDeItens`: **nada é redigitado aqui**. Um nome copiado neste
/// arquivo divergiria do catálogo no primeiro ajuste, e a tela mostraria um
/// item com nome diferente do que a conta usa.
///
/// **SPEC_DEVIATION** (`design.md` §11): a `spec.md` (P1-1 AC2, A-16) diz que
/// o chip selecionado é "vermelho". §5 do arquivo 02 desenha o chip
/// selecionado com fundo `ink` e texto `cream`, e o [BoraSelectionChip] é um
/// componente fechado do design system. Prevalece §5 — pintar o componente
/// fora do token dele violaria o `CLAUDE.md`. O vermelho de T-03 é o do
/// segmented ativo, o do CTA e o da sombra do card-herói.
class SecaoDeChips extends StatelessWidget {
  const SecaoDeChips({
    required this.secao,
    required this.selecionados,
    required this.aoAlternar,
    super.key,
  });

  /// O vão entre chips, na horizontal e entre linhas do [Wrap].
  ///
  /// §5 não declara o gap da grade de chips; fica o mesmo ritmo vertical que
  /// §5 dá ao padding do próprio chip, para nenhum número novo entrar.
  static double get vao => BoraSpacing.chip.top;

  /// Qual das três seções esta é. Os chips vêm dela.
  final SecaoDaMontagem secao;

  /// Os itens marcados agora. O widget **não** guarda seleção própria.
  final Set<ChaveItem> selecionados;

  /// Emitido com a chave do chip tocado. Quem alterna é o bloc — aqui só sai
  /// a intenção, e por isso tocar duas vezes é determinístico (MONT-20).
  final void Function(ChaveItem chave) aoAlternar;

  /// Os chips desta seção, na ordem literal de T-03/W-03.
  List<ChaveItem> get chips => chipsPorSecao[secao]!;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MontarTextos.rotuloDaSecao(secao),
          style: BoraTextStyles.labelSecao,
        ),
        SizedBox(height: vao),
        Wrap(
          spacing: vao,
          runSpacing: vao,
          children: [
            for (final chave in chips)
              BoraSelectionChip(
                rotulo: catalogoDeItens[chave]!.nome,
                emoji: catalogoDeItens[chave]!.emoji,
                selecionado: selecionados.contains(chave),
                onTap: () => aoAlternar(chave),
              ),
          ],
        ),
      ],
    );
  }
}
