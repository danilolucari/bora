import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

import '../tokens/bora_colors.dart';
import '../tokens/bora_motion.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';
import 'bora_surface.dart';

/// O segmented control de §5: "Container com borda 2px `ink` sobre branco;
/// botões `flex:1` separados por divisor 2px `divider-2`; ativo = fundo `ink`
/// + texto `cream`, inativo = transparente + `text-2`. Variante sobre card
/// escuro: borda e divisores em `cream`/25%; ativo só muda o texto para
/// `cream`".
///
/// O índice ativo é **propriedade**, não estado: quem seleciona é quem sabe o
/// que a seleção significa. O componente só emite [onSelecionar] com o índice
/// tocado — tocar não muda nada sozinho.
class BoraSegmentedControl extends StatelessWidget {
  const BoraSegmentedControl({
    required this.opcoes,
    required this.indiceAtivo,
    required this.onSelecionar,
    this.sobreCardEscuro = false,
    super.key,
  });

  /// Os rótulos, renderizados em CAIXA ALTA (§7, DS-32). Com `n` opções há
  /// `n - 1` divisores; com uma só, nenhum.
  final List<String> opcoes;

  /// O índice ativo — **exatamente um** (§5).
  final int indiceAtivo;

  /// Emitido com o índice tocado.
  final ValueChanged<int> onSelecionar;

  /// §5: sobre card escuro, borda e divisores viram `cream`/25% e o ativo
  /// muda **só o texto**.
  final bool sobreCardEscuro;

  Color get _corDaBorda =>
      sobreCardEscuro ? BoraColors.creamQuarter : BoraColors.ink;

  Color get _corDoDivisor =>
      sobreCardEscuro ? BoraColors.creamQuarter : BoraColors.divider2;

  @override
  Widget build(BuildContext context) {
    return BoraSurface(
      // Sobre card escuro o container não pinta fundo: §5 troca só borda e
      // divisores, e um branco aqui apagaria o card.
      fundo: sobreCardEscuro ? Colors.transparent : BoraColors.white,
      corDaBorda: _corDaBorda,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var indice = 0; indice < opcoes.length; indice++) ...[
              if (indice > 0)
                SizedBox(width: 2, child: ColoredBox(color: _corDoDivisor)),
              Expanded(child: _botao(indice)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _botao(int indice) {
    final ativo = indice == indiceAtivo;
    return GestureDetector(
      // Sem isto o toque no vão transparente do botão inativo se perderia.
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelecionar(indice),
      child: AnimatedContainer(
        duration: BoraMotion.estado,
        curve: BoraMotion.curva,
        // §5: sobre card escuro "o ativo só muda o texto" — nada de fundo.
        color: ativo && !sobreCardEscuro ? BoraColors.ink : Colors.transparent,
        // §5 não dá padding ao segmented: fica o do chip, o vizinho mais
        // próximo da mesma seção, para nenhum número novo entrar no sistema.
        padding: BoraSpacing.chip,
        alignment: Alignment.center,
        child: Text(
          opcoes[indice].toUpperCase(),
          textAlign: TextAlign.center,
          style: BoraTextStyles.botao.copyWith(
            color: ativo ? BoraColors.cream : BoraColors.text2,
          ),
        ),
      ),
    );
  }
}
