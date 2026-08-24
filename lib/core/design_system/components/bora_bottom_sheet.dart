import 'package:flutter/material.dart'
    show MaterialLocalizations, MaterialType, Material, showGeneralDialog;
import 'package:flutter/widgets.dart';

import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';
import 'bora_surface.dart';

/// O bottom sheet de §5: "Overlay `rgba(20,10,50,.45)`; painel ancorado
/// embaixo, fundo `paper`, `border-top 2px ink`, padding 22px 24px 30px;
/// título Archivo Black 22px + botão ✕ 32×32 borda 2px".
///
/// O scrim **não é `ink` com opacidade**: `rgba(20,10,50,.45)` é um
/// preto-arroxeado próprio, e por isso mora em [BoraColors.sheetScrim]. Trocar
/// um pelo outro deixaria a tela por baixo cinza em vez de roxa.
///
/// A borda é só no topo — o painel encosta nas outras três margens da tela.
class BoraBottomSheet extends StatelessWidget {
  const BoraBottomSheet({
    required this.titulo,
    required this.conteudo,
    this.onFechar,
    super.key,
  });

  /// A chave do painel na árvore.
  static const Key panelKey = Key('bora-bottom-sheet');

  /// A chave do botão ✕.
  static const Key fecharKey = Key('bora-bottom-sheet-fechar');

  /// §5: "botão ✕ 32×32".
  static const double tamanhoDoFechar = 32;

  /// §5: `border-top 2px ink`, o mesmo `BorderSide` da borda padrão de §3.
  static final Border bordaSuperior = Border(top: BoraBorders.padraoInk.top);

  /// O título, em CAIXA ALTA (§7, DS-32).
  final String titulo;

  /// O corpo do sheet, montado por quem o abre.
  final WidgetBuilder conteudo;

  /// O que fazer no ✕. Quando o sheet é aberto por [mostrar], é fechar a
  /// rota; no catálogo, onde o painel aparece parado, é `null`.
  final VoidCallback? onFechar;

  /// Abre o sheet sobre a tela atual e devolve o que ele fechar com.
  ///
  /// O scrim é [BoraColors.sheetScrim] e fecha ao ser tocado. A transição é
  /// **instantânea** de propósito: §6 não descreve motion de sheet, e §8
  /// proíbe inventar um.
  static Future<T?> mostrar<T>(
    BuildContext context, {
    required String titulo,
    required WidgetBuilder conteudo,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierColor: BoraColors.sheetScrim,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: Duration.zero,
      pageBuilder: (contextoDaRota, _, _) => Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          // Transparente: quem pinta o painel é o próprio sheet. O `Material`
          // existe para dar à rota o estilo de texto padrão — sem ripple,
          // que §8 não tem.
          type: MaterialType.transparency,
          child: SizedBox(
            width: double.infinity,
            child: BoraBottomSheet(
              titulo: titulo,
              conteudo: conteudo,
              onFechar: () => Navigator.of(contextoDaRota).pop(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: panelKey,
      decoration: BoxDecoration(
        color: BoraColors.paper,
        border: bordaSuperior,
        borderRadius: BoraBorders.raio,
      ),
      child: Padding(
        padding: BoraSpacing.sheet,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    titulo.toUpperCase(),
                    style: BoraTextStyles.tituloSheet,
                  ),
                ),
                GestureDetector(
                  key: fecharKey,
                  onTap: onFechar,
                  child: SizedBox(
                    width: tamanhoDoFechar,
                    height: tamanhoDoFechar,
                    child: BoraSurface(
                      // §5 não dá fundo ao ✕: o que o define é a borda de 2px.
                      fundo: BoraColors.paper,
                      child: Center(
                        child: Text(
                          '✕',
                          style: BoraTextStyles.botao
                              .copyWith(color: BoraColors.ink),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            conteudo(context),
          ],
        ),
      ),
    );
  }
}
