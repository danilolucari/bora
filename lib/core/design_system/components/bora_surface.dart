import 'package:flutter/widgets.dart';

import '../tokens/bora_accent.dart';
import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_shadows.dart';

/// A superfície comum do sistema: canto reto (§3), borda sólida de 2px (§3) e
/// sombra dura no acento (§4).
///
/// Existe **uma vez** para que os componentes de §5 não reimplementem — e não
/// errem — a mesma mecânica dezoito vezes. Quem precisa de card, botão, chip,
/// input ou tag monta a partir daqui.
class BoraSurface extends StatelessWidget {
  const BoraSurface({
    required this.child,
    this.fundo = BoraColors.white,
    this.corDaBorda = BoraColors.ink,
    this.larguraDaBorda = 2,
    this.acento,
    this.deslocamentoDaSombra = BoraShadows.distanciaCta,
    this.padding,
    super.key,
  });

  /// O preenchimento da superfície.
  final Color fundo;

  /// A cor da borda — §3 declara `2px solid #141414` como a padrão.
  final Color corDaBorda;

  /// A espessura da borda. O padrão é o "2px solid" de §3; o frame do celular
  /// é o único lugar do arquivo 02 que pede outra (1px).
  final double larguraDaBorda;

  /// O acento da sombra dura.
  ///
  /// `null` ⇒ **sem sombra alguma**. §4 não tem sombra transparente: ou a
  /// superfície projeta, ou não projeta.
  final BoraAccent? acento;

  /// A distância da sombra dura, nos dois eixos. O padrão é o `4px 4px 0` que
  /// §4 declara para o CTA.
  final double deslocamentoDaSombra;

  /// Preenchimento interno, quando o componente tem um padding de §5.
  final EdgeInsets? padding;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final acento = this.acento;
    final padding = this.padding;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fundo,
        border: Border.all(color: corDaBorda, width: larguraDaBorda),
        borderRadius: BoraBorders.raio,
        boxShadow: acento == null
            ? null
            : [BoraShadows.hard(acento.cor, deslocamentoDaSombra)],
      ),
      child: padding == null ? child : Padding(padding: padding, child: child),
    );
  }
}
