import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';

import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';
import 'bora_surface.dart';

/// A opção de enquete (estilo WhatsApp) de §5: "Borda 2px (`ink`; `#25D366`
/// quando é seu voto); barra de % preenchendo o fundo com
/// `rgba(37,211,102,.18)`; radio circular 15px (verde quando votado); % à
/// direita; contagem 'n votos' abaixo".
///
/// O radio é **redondo**: é a exceção de forma que §3 autoriza ("avatares e
/// dots"), e este arquivo está por isso na allowlist da guarda de forma.
///
/// **Nada é calculado aqui** (DS-34): a fração da barra, o percentual e a
/// contagem chegam prontos de quem conta os votos. A fração fora de `[0,1]`
/// clampa e a não finita vira `0` — a mesma regra de DS-27 e DS-28.
class BoraPollOption extends StatelessWidget {
  const BoraPollOption({
    required this.texto,
    required this.fracao,
    required this.percentualFormatado,
    required this.contagemFormatada,
    required this.meuVoto,
    this.onVotar,
    super.key,
  });

  /// §5: "radio circular 15px".
  static const double tamanhoDoRadio = 15;

  /// A espessura da borda de §3, que a barra de % não pode cobrir: a borda é
  /// pintada por trás do conteúdo, então o preenchimento se recolhe dela.
  static double get espessuraDaBorda => BoraBorders.padraoInk.top.width;

  /// O vão entre o radio e o texto — o mesmo vão horizontal da linha de
  /// lista, para que nenhum número novo entre no sistema.
  static double get vaoDoRadio => BoraSpacing.linhaLista.left;

  /// A opção votada, em sentence case (§7).
  final String texto;

  /// Quanto dos votos esta opção levou, **já calculado** (DS-34).
  final double fracao;

  /// O percentual à direita, **já formatado** (DS-34).
  final String percentualFormatado;

  /// A contagem de baixo ("12 votos"), **já formatada** (DS-34).
  final String contagemFormatada;

  /// §5: "`#25D366` quando é seu voto" — muda a borda e pinta o radio.
  final bool meuVoto;

  /// Emitido ao tocar a opção. `null` ⇒ a enquete só é exibida.
  final VoidCallback? onVotar;

  /// A fração efetivamente pintada: clampada, e `0` quando não é finita.
  double get fracaoPintada => fracao.isFinite ? fracao.clamp(0, 1) : 0;

  Color get _corDaBorda => meuVoto ? BoraColors.waGreen : BoraColors.ink;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onVotar,
      child: BoraSurface(
        // §5 não dá fundo à opção: o que preenche é a barra de %, e pintar
        // por baixo apagaria a conversa que aparece atrás dela.
        fundo: Colors.transparent,
        corDaBorda: _corDaBorda,
        child: Stack(
          children: [
            Positioned.fill(
              left: espessuraDaBorda,
              top: espessuraDaBorda,
              right: espessuraDaBorda,
              bottom: espessuraDaBorda,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: fracaoPintada,
                  child: const ColoredBox(color: BoraColors.pollFill),
                ),
              ),
            ),
            Padding(
              // §5 não dá padding à opção: fica o da linha de lista, o
              // vizinho mais próximo.
              padding: BoraSpacing.linhaLista,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Radio(votado: meuVoto),
                      SizedBox(width: vaoDoRadio),
                      Expanded(
                        child: Text(texto, style: BoraTextStyles.corpo),
                      ),
                      Text(
                        percentualFormatado,
                        style: BoraTextStyles.linhaLista,
                      ),
                    ],
                  ),
                  Text(
                    contagemFormatada,
                    style: BoraTextStyles.sublinhaLista,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// O radio circular de §5 — 15px, verde quando votado.
///
/// Vazio ele é só o contorno de 2px de §3; votado, fica cheio de `waGreen`.
class _Radio extends StatelessWidget {
  const _Radio({required this.votado});

  final bool votado;

  @override
  Widget build(BuildContext context) {
    final cor = votado ? BoraColors.waGreen : BoraColors.ink;
    return SizedBox(
      width: BoraPollOption.tamanhoDoRadio,
      height: BoraPollOption.tamanhoDoRadio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // §3: a exceção de forma dos "dots". Círculo e raio não coexistem
          // numa `BoxDecoration`, então não há `borderRadius` junto.
          shape: BoxShape.circle,
          color: votado ? BoraColors.waGreen : Colors.transparent,
          border: BoraBorders.solida(cor),
        ),
      ),
    );
  }
}
