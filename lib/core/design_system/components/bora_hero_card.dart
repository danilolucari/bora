import 'package:flutter/widgets.dart';

import '../tokens/bora_accent.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';
import 'bora_surface.dart';

/// O card-herói escuro do dinheiro, de §5: "Fundo `ink`, padding 20–22px,
/// sombra `6px 6px 0 #FF4D2E`. Label `yellow` 800 12px ls 1px; valor `cream`
/// Archivo Black 40–42px; sublinha `primary` 700 13px".
///
/// **O valor chega pronto** (DS-34): [valorFormatado] é `String`, e este
/// componente não põe `R$`, não arredonda e não divide. RN-13 ("dinheiro é
/// sempre `R$ + round(valor)`") é da spec `calculo`, e duplicar a fórmula aqui
/// é exatamente o que o `CLAUDE.md` chama de quebra de produto.
///
/// §5 não dá vão entre as três linhas, e nenhum é inventado: o que as separa é
/// a altura de linha de cada papel de §2.
class BoraHeroCard extends StatelessWidget {
  const BoraHeroCard({
    required this.label,
    required this.valorFormatado,
    required this.sublinha,
    super.key,
  });

  /// §4, card-herói escuro: `6px 6px 0 #FF4D2E`.
  static const double deslocamentoDaSombra = 6;

  /// O rótulo do topo. Sai em CAIXA ALTA (§7, DS-32) venha como vier.
  final String label;

  /// O valor, **já formatado** pela camada de cálculo (DS-34). Desenhado
  /// caractere a caractere como chegou.
  final String valorFormatado;

  /// A linha de baixo, em sentence case (§7): não é título, label, botão nem
  /// toast, então não é transformada.
  final String sublinha;

  @override
  Widget build(BuildContext context) {
    return BoraSurface(
      fundo: BoraColors.ink,
      acento: BoraAccent.primary,
      deslocamentoDaSombra: deslocamentoDaSombra,
      padding: BoraSpacing.cardHeroi,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: BoraTextStyles.heroiLabel),
          Text(valorFormatado, style: BoraTextStyles.valorHeroi),
          Text(sublinha, style: BoraTextStyles.heroiSublinha),
        ],
      ),
    );
  }
}
