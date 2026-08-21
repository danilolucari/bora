import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';

/// A dica/nota de §3: "`2px dashed #141414`, fundo branco, texto 600 12px
/// `text-2`, sempre com emoji-âncora (💡 📊 ✅)".
///
/// O emoji é obrigatório porque §3 diz "sempre": uma dica sem âncora não é a
/// dica do arquivo 02.
class BoraDashedNote extends StatelessWidget {
  const BoraDashedNote({
    required this.emoji,
    required this.texto,
    super.key,
  });

  /// Os três emojis-âncora que §3 nomeia.
  static const List<String> emojisAncora = ['💡', '📊', '✅'];

  /// O vão entre o emoji e o texto — o mesmo critério da linha de lista: em
  /// vez de um número novo, o ritmo horizontal que a caixa já tem.
  static double get vaoDoEmoji => BoraSpacing.linhaLista.left;

  /// A âncora à esquerda (§3).
  final String emoji;

  /// O corpo da dica, em sentence case (§7).
  final String texto;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      // O tracejado é pintado **sobre** o fundo: metade do traço cai dentro
      // da caixa, e o branco desenhado depois o comeria.
      foregroundPainter: BoraDashedBorderPainter(
        cor: BoraBorders.dicaTracejada.cor,
        largura: BoraBorders.dicaTracejada.largura,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: BoraColors.white,
          borderRadius: BoraBorders.raio,
        ),
        child: Padding(
          // §3 não dá padding à dica: fica o da linha de lista, o vizinho
          // mais próximo — nenhum número novo entra no sistema.
          padding: BoraSpacing.linhaLista,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: BoraTextStyles.dica),
              SizedBox(width: vaoDoEmoji),
              Flexible(child: Text(texto, style: BoraTextStyles.dica)),
            ],
          ),
        ),
      ),
    );
  }
}

/// O slot vazio/desabilitado de §3: "borda `2px dashed` `#9b9b9b`,
/// opacity .7".
///
/// §3 não lhe dá fundo: o slot é a moldura de um lugar ainda sem conteúdo, e
/// pintar por baixo o tornaria um card.
class BoraEmptySlot extends StatelessWidget {
  const BoraEmptySlot({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: BoraBorders.opacidadeDesabilitado,
      child: CustomPaint(
        foregroundPainter: BoraDashedBorderPainter(
          cor: BoraBorders.slotTracejado.cor,
          largura: BoraBorders.slotTracejado.largura,
        ),
        child: Padding(padding: BoraSpacing.linhaLista, child: child),
      ),
    );
  }
}

/// O tracejado retangular de §3, desenhado à mão.
///
/// O Flutter não tem `BorderStyle.dashed`: a borda é um retângulo percorrido
/// em pedaços, e o vão é o pedaço que não se desenha. Trazer um pacote novo
/// ou uma imagem para isto violaria AD-002.
class BoraDashedBorderPainter extends CustomPainter {
  const BoraDashedBorderPainter({required this.cor, required this.largura});

  /// O comprimento do traço.
  ///
  /// **Assumption:** §3 diz "2px dashed" sem dar traço nem vão. O valor
  /// escolhido é o dobro da espessura de 2px — nenhum número novo entra no
  /// sistema, e a proporção fica 1:1 entre traço e vão. É o mesmo par que o
  /// tracejado circular do slot "+N" usa.
  static const double traco = 4;

  /// O comprimento do vão, igual ao [traco] pelo mesmo motivo.
  static const double vao = 4;

  final Color cor;
  final double largura;

  @override
  void paint(Canvas canvas, Size size) {
    // A borda é desenhada por dentro: o traço fica centrado na linha, e sem
    // o recuo metade dele cairia fora da caixa.
    final recuo = largura / 2;
    if (size.width <= largura || size.height <= largura) return;

    final pincel = Paint()
      ..color = cor
      ..strokeWidth = largura
      ..style = PaintingStyle.stroke;
    final contorno = Path()
      ..addRect(
        Rect.fromLTWH(
          recuo,
          recuo,
          size.width - largura,
          size.height - largura,
        ),
      );

    for (final metrica in contorno.computeMetrics()) {
      var percorrido = 0.0;
      while (percorrido < metrica.length) {
        final fimDoTraco = math.min(percorrido + traco, metrica.length);
        canvas.drawPath(
          metrica.extractPath(percorrido, fimDoTraco),
          pincel,
        );
        percorrido = fimDoTraco + vao;
      }
    }
  }

  @override
  bool shouldRepaint(BoraDashedBorderPainter anterior) =>
      anterior.cor != cor || anterior.largura != largura;
}
