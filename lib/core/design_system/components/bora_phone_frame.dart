import 'package:flutter/widgets.dart';

import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_shadows.dart';

/// O frame do celular de §5: `390×820`, `radius 38px`, borda
/// `1px rgba(0,0,0,.25)`, `overflow hidden`, header e rodapé fixos e o
/// conteúdo rolando na área central.
///
/// Este arquivo carrega as **duas** exceções do design system, e as duas pelo
/// mesmo motivo: o frame não é UI, é o **palco** onde a UI aparece (§4).
///
/// 1. **Radius 38.** §3 manda `border-radius: 0` em tudo; as exceções são
///    avatares/dots e este frame. Por isso `bora_phone_frame.dart` está na
///    allowlist de forma da guarda de §3.
/// 2. **A única sombra com blur.** §4 manda sombra dura, sem blur, em toda a
///    UI. [BoraShadows.frame] é a única suave do sistema — e ela desenha o
///    celular pousado sobre a página, não um componente. Qualquer outro blur
///    sob `lib/` é violação, e a guarda de §4 acusa.
///
/// A sombra fica **fora** do recorte: quem corta é o [ClipRRect] interno, que
/// segura o conteúdo dentro dos cantos. Cortar por cima da sombra apagaria o
/// pouso do palco na página.
class BoraPhoneFrame extends StatelessWidget {
  const BoraPhoneFrame({
    required this.conteudo,
    this.header,
    this.rodape,
    super.key,
  });

  /// A chave do frame na árvore.
  static const Key frameKey = Key('bora-phone-frame');

  /// A chave da área que rola.
  static const Key conteudoKey = Key('bora-phone-frame-conteudo');

  /// §5: "390×820".
  static const double largura = 390;
  static const double altura = 820;

  /// §5: `radius 38px` — a exceção de §3, e o único raio não-zero de um
  /// componente que não é círculo.
  static const BorderRadius raio = BorderRadius.all(Radius.circular(38));

  /// O header fixo, no topo. Não rola.
  final Widget? header;

  /// O corpo, na área central. É o único que rola.
  final Widget conteudo;

  /// O rodapé fixo, embaixo. Não rola.
  final Widget? rodape;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: frameKey,
      width: largura,
      height: altura,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: BoraColors.paper,
          border: BoraBorders.frame,
          borderRadius: raio,
          boxShadow: const [BoraShadows.frame],
        ),
        child: ClipRRect(
          borderRadius: raio,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (header case final Widget header) header,
              Expanded(
                child: SingleChildScrollView(
                  key: conteudoKey,
                  child: conteudo,
                ),
              ),
              if (rodape case final Widget rodape) rodape,
            ],
          ),
        ),
      ),
    );
  }
}
