import 'dart:async';

import 'package:flutter/widgets.dart';

import '../tokens/bora_accent.dart';
import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_motion.dart';
import '../tokens/bora_shadows.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';

/// §5, toast: "posição central, `bottom: 112px`".
const double _distanciaDoRodape = 112;

/// O **visual** do toast de §5, sem o controlador de `Overlay`.
///
/// Fundo `ink`, texto `cream` 800 13px ls .5px, padding 12px 20px e sombra
/// dura `4px 4px 0` no acento do contexto. Separado do controlador para que o
/// catálogo possa mostrar o toast parado, sem botão e sem overlay.
///
/// A copy chega em CAIXA ALTA (§7 e DS-32) venha como vier.
class BoraToastContent extends StatelessWidget {
  const BoraToastContent({
    required this.texto,
    this.acento = BoraAccent.primary,
    super.key,
  });

  /// A chave do toast na árvore — é por ela que "1 por vez" é contável.
  static const Key toastKey = Key('bora-toast');

  final String texto;
  final BoraAccent acento;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BoraColors.ink,
        borderRadius: BoraBorders.raio,
        boxShadow: [BoraShadows.hard(acento.cor, BoraShadows.distanciaCta)],
      ),
      child: Padding(
        padding: BoraSpacing.toast,
        child: Text(texto.toUpperCase(), style: BoraTextStyles.toast),
      ),
    );
  }
}

/// O toast do sistema: **1 por vez**, 2200 ms, some sozinho (RN-29 e §8).
///
/// §8: "toast persistente ou empilhado" não existe — o novo **substitui** o
/// anterior. O par entry/timer é estático porque "1 por vez" é propriedade do
/// app inteiro, não de uma subárvore.
abstract final class BoraToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  /// A chave do toast visível.
  static const Key toastKey = BoraToastContent.toastKey;

  /// Mostra [texto] por [BoraMotion.toastVida] e some sozinho.
  ///
  /// Um segundo `mostrar` com o primeiro ainda visível remove o anterior **e
  /// cancela o timer dele** — senão o timer velho derrubaria o toast novo
  /// antes da hora. Sem `Overlay` no contexto (ou com ele já desmontado) a
  /// chamada retorna em silêncio: toast é feedback, não conteúdo.
  static void mostrar(
    BuildContext context, {
    required String texto,
    BoraAccent acento = BoraAccent.primary,
  }) {
    _cancelar();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (context) => _ToastEntrando(texto: texto, acento: acento),
    );
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(BoraMotion.toastVida, _cancelar);
  }

  /// Tira o toast da tela agora, se houver algum.
  static void esconder() => _cancelar();

  static void _cancelar() {
    _timer?.cancel();
    _timer = null;

    final entry = _entry;
    _entry = null;
    if (entry != null && entry.mounted) {
      entry.remove();
    }
  }
}

/// A entrada de §6 (`toastIn`): fade + sobe 14px em 300 ms `ease`.
///
/// A saída é remoção seca: §6 não descreve animação de saída, e §8 proíbe
/// inventar motion.
class _ToastEntrando extends StatelessWidget {
  const _ToastEntrando({required this.texto, required this.acento});

  final String texto;
  final BoraAccent acento;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: _distanciaDoRodape,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: BoraMotion.toastIn,
        curve: BoraMotion.curva,
        builder: (context, avanco, child) => Opacity(
          opacity: avanco,
          child: Transform.translate(
            offset: Offset(0, BoraMotion.toastSubida * (1 - avanco)),
            child: child,
          ),
        ),
        // `heightFactor: 1` encolhe a caixa até a altura do toast: sem isso a
        // `Positioned` esticaria e o `bottom: 112` deixaria de ancorar.
        child: Center(
          heightFactor: 1,
          child: BoraToastContent(
            key: BoraToastContent.toastKey,
            texto: texto,
            acento: acento,
          ),
        ),
      ),
    );
  }
}
