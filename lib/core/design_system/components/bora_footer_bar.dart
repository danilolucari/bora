import 'package:flutter/widgets.dart';

import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';

/// O rodapé fixo (CTA bar) de §5: "Fundo `paper`, `border-top 2px ink`,
/// padding 14–16px 24px 30px. Padrão: bloco 'SAI POR'/label à esquerda (label
/// 800 11px ls 1px `text-2` + valor Archivo Black + sublinha vermelha 700
/// 12.5px) e CTA à direita".
///
/// A borda é **só no topo** — não é a borda inteira de §3. O rodapé encosta
/// nas três outras margens da tela: fechá-lo por completo desenharia uma
/// caixa onde a spec-fonte pede uma linha de separação.
///
/// O [cta] chega pronto, como `Widget`: quem monta a tela decide qual botão
/// vai ali (e com que acento), e o rodapé só lhe dá o lugar à direita.
///
/// **O valor chega formatado** (DS-34): RN-13 é da spec `calculo`, e este
/// componente não põe `R$`, não arredonda e não divide.
class BoraFooterBar extends StatelessWidget {
  const BoraFooterBar({
    required this.label,
    required this.valorFormatado,
    required this.sublinha,
    required this.cta,
    super.key,
  });

  /// §5: `border-top 2px ink` — o mesmo `BorderSide` da borda padrão de §3,
  /// aplicado a um lado só. Nenhum número novo entra no sistema.
  static final Border bordaSuperior = Border(top: BoraBorders.padraoInk.top);

  /// O rótulo do bloco da esquerda ("SAI POR"). Sai em CAIXA ALTA (§7).
  final String label;

  /// O valor, **já formatado** pela camada de cálculo (DS-34).
  final String valorFormatado;

  /// A linha vermelha de baixo, em sentence case (§7).
  final String sublinha;

  /// O CTA da direita, montado por quem usa o rodapé.
  final Widget cta;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BoraColors.paper,
        border: bordaSuperior,
        borderRadius: BoraBorders.raio,
      ),
      child: Padding(
        padding: BoraSpacing.rodape,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: BoraTextStyles.rodapeLabel),
                  Text(valorFormatado, style: BoraTextStyles.valorRodape),
                  Text(sublinha, style: BoraTextStyles.rodapeSublinha),
                ],
              ),
            ),
            cta,
          ],
        ),
      ),
    );
  }
}
