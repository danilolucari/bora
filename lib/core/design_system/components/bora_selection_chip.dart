import 'package:flutter/widgets.dart';

import '../tokens/bora_colors.dart';
import '../tokens/bora_motion.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';
import 'bora_surface.dart';

/// O chip de seleção dos itens da festa (§5): "Padding 10px 14px, 800 13px
/// CAIXA ALTA, emoji à esquerda, borda 2px `ink`. Não selecionado: fundo
/// branco, texto `ink`. Selecionado: fundo `ink`, texto `cream`. Transição
/// `.15s`".
///
/// A decoração vem de [BoraSurface.decoracaoDe] em vez do widget porque §6
/// pede **transição**: o chip é um dos três casos nomeados do `.15s` de §6, e
/// só uma decoração em forma de valor pode ser animada.
///
/// O chip não afunda: §4 manda o afundamento para o CTA, que é o que tem
/// sombra para encolher — o chip de §5 não tem sombra alguma.
class BoraSelectionChip extends StatelessWidget {
  const BoraSelectionChip({
    required this.rotulo,
    required this.emoji,
    required this.selecionado,
    this.onTap,
    super.key,
  });

  /// O nome do item, renderizado em CAIXA ALTA (§5, §7, DS-32).
  final String rotulo;

  /// O emoji do item, **à esquerda** do rótulo (§5).
  final String emoji;

  /// Qual dos dois estados de §5 o chip mostra.
  final bool selecionado;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BoraMotion.estado,
        curve: BoraMotion.curva,
        padding: BoraSpacing.chip,
        decoration: BoraSurface.decoracaoDe(
          fundo: selecionado ? BoraColors.ink : BoraColors.white,
        ),
        child: Text(
          '$emoji ${rotulo.toUpperCase()}',
          style: BoraTextStyles.chip.copyWith(
            color: selecionado ? BoraColors.cream : BoraColors.ink,
          ),
        ),
      ),
    );
  }
}
