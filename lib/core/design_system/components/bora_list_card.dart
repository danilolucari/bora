import 'package:flutter/widgets.dart';

import '../tokens/bora_colors.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';
import 'bora_surface.dart';

/// Uma linha do [BoraListCard], de §5: "emoji 19–20px à esquerda; valor 800
/// 14px à direita".
///
/// O [valor] chega **pronto**. `R$ N` inteiro é RN-13, e a regra mora em
/// `core/calculo` — o card só desenha a `String` que recebeu (DS-34).
class BoraListRow {
  const BoraListRow({
    required this.emoji,
    required this.titulo,
    this.sublinha,
    this.valor,
    this.onTap,
  });

  /// O emoji-âncora da linha, à esquerda (§5).
  final String emoji;

  /// O nome da linha, no papel "Nome/linha de lista" de §2.
  final String titulo;

  /// A sublinha 600 `text-2` de §2. `null` ⇒ a linha tem só o título.
  final String? sublinha;

  /// O valor já formatado, à direita. `null` ⇒ a linha não mostra valor.
  final String? valor;

  final VoidCallback? onTap;
}

/// O card de lista de §5: "Fundo branco, borda 2px `ink`; linhas com padding
/// 12–13px 14–16px separadas por `2px solid divider`; emoji 19–20px à
/// esquerda; valor 800 14px à direita".
///
/// Com `n` linhas há `n - 1` divisores: o separador vive **entre** linhas, e
/// com uma linha só não há nada para separar.
class BoraListCard extends StatelessWidget {
  const BoraListCard({required this.linhas, super.key});

  /// §5: "emoji 19–20px à esquerda" — o extremo inferior da faixa, pelo mesmo
  /// critério de A-01.
  static const double tamanhoDoEmoji = 19;

  /// §5: "separadas por `2px solid divider`".
  static const double espessuraDoDivisor = 2;

  /// O vão entre o emoji e o texto.
  ///
  /// §5 não o declara. Em vez de inventar um número novo, a linha reusa o
  /// próprio ritmo horizontal — o padding que §5 dá a ela.
  static double get vaoDoEmoji => BoraSpacing.linhaLista.left;

  final List<BoraListRow> linhas;

  @override
  Widget build(BuildContext context) {
    return BoraSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var indice = 0; indice < linhas.length; indice++) ...[
            if (indice > 0)
              const SizedBox(
                height: espessuraDoDivisor,
                child: ColoredBox(color: BoraColors.divider),
              ),
            _Linha(linha: linhas[indice]),
          ],
        ],
      ),
    );
  }
}

/// Uma linha desenhada: emoji, o bloco título/sublinha e o valor.
class _Linha extends StatelessWidget {
  const _Linha({required this.linha});

  final BoraListRow linha;

  @override
  Widget build(BuildContext context) {
    final sublinha = linha.sublinha;
    final valor = linha.valor;

    return GestureDetector(
      // Sem isto o toque no vão entre o texto e o valor se perderia.
      behavior: HitTestBehavior.opaque,
      onTap: linha.onTap,
      child: Padding(
        padding: BoraSpacing.linhaLista,
        child: Row(
          children: [
            Text(
              linha.emoji,
              style: BoraTextStyles.linhaLista.copyWith(
                fontSize: BoraListCard.tamanhoDoEmoji,
              ),
            ),
            SizedBox(width: BoraListCard.vaoDoEmoji),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(linha.titulo, style: BoraTextStyles.linhaLista),
                  if (sublinha != null)
                    Text(sublinha, style: BoraTextStyles.sublinhaLista),
                ],
              ),
            ),
            if (valor != null)
              Text(valor, style: BoraTextStyles.linhaLista),
          ],
        ),
      ),
    );
  }
}
