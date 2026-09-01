import 'package:flutter/material.dart'
    show MaterialType, Material, showGeneralDialog;
import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/pedido.dart';
import '../lista_textos.dart';

/// O overlay "PEDIDO A CAMINHO! 🛵" — T-04 · LIST-26, LIST-28.
///
/// "tela cheia `paper`, 🛵 56px, 'PEDIDO A CAMINHO!' 30px, 'Chega em **ETA**
/// na …', linha vermelha com o total e '· rachado no acerto da festa', CTA
/// 'VOLTAR À LISTA'". São cinco elementos, e são **só** esses.
///
/// **Tudo o que ele mostra vem do [pedido] que a porta devolveu** (LIST-28
/// AC2): ETA, endereço e total. Nenhum número e nenhum prazo é constante deste
/// arquivo — trocar o adaptador falso por um real muda o que a tela diz sem
/// tocar num widget, que é a promessa da AD-024.
///
/// ⚠️ **Sem selo de "simulado"**, e é decisão declarada (AD-024 · LIST-28 AC4):
/// enquanto o adaptador for o `PedidoFalso`, esta tela afirma "PEDIDO A
/// CAMINHO!" sem pedido a caminho. A copy de T-04 é literal, o selo foi
/// oferecido ao usuário em 2026-08-27 e recusado, e a ressalva de exposição
/// pública mora na AD-024 e no doc do `PedidoFalso`.
///
// SPEC_DEVIATION: `tasks.md` T22 sugere reusar `BoraSurface` como a superfície
// do overlay, e o fundo é um `ColoredBox` de `BoraColors.paper`.
// Reason: `BoraSurface` **sempre** desenha a borda sólida de 2px de §3 — é o
// que ela é. T-04 escreve "tela cheia `paper`", sem moldura: uma borda no
// contorno da janela seria decoração que a spec-fonte não pede. O CTA continua
// vindo inteiro de `BoraPrimaryButton`, com o afundamento de §4.
class OverlayDePedido extends StatelessWidget {
  const OverlayDePedido({
    required this.pedido,
    required this.onVoltar,
    super.key,
  });

  /// T-04: "🛵 56px".
  static const String moto = '🛵';
  static const double tamanhoDoMoto = 56;

  /// T-04: "'PEDIDO A CAMINHO!' 30px" — dentro da faixa 26–40px de §2, e por
  /// isso derivado de [BoraTextStyles.tituloCard], não de um estilo novo.
  static const double tamanhoDoTitulo = 30;

  /// A chave do CTA "VOLTAR À LISTA".
  static const Key voltarKey = Key('overlay-voltar');

  /// O vão vertical entre as linhas — o mesmo ritmo de §5.
  static double get vao => BoraSpacing.linhaLista.top;

  /// O pedido **confirmado pela porta**. Obrigatório e não-nulo: não existe
  /// caminho que monte este overlay sem um pedido (LIST-26).
  final Pedido pedido;

  /// "VOLTAR À LISTA" — encerra o overlay. Quem volta para a lista é quem o
  /// abriu; este widget não navega (AD-020).
  final VoidCallback onVoltar;

  /// Abre o overlay em tela cheia, sobre a lista.
  ///
  /// **Não fecha por toque fora**: a única saída é o CTA, e é ele que garante
  /// que o overlay encerre uma vez só (LIST-26).
  static Future<void> mostrar(
    BuildContext context, {
    required Pedido pedido,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: BoraColors.paper,
      // §6 não descreve motion de overlay e §8 proíbe inventar um.
      transitionDuration: Duration.zero,
      pageBuilder: (contextoDaRota, _, _) => Material(
        type: MaterialType.transparency,
        child: OverlayDePedido(
          pedido: pedido,
          onVoltar: () => Navigator.of(contextoDaRota).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BoraColors.paper,
      child: SizedBox.expand(
        child: Padding(
          padding: BoraSpacing.sheet,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                moto,
                textAlign: TextAlign.center,
                style: BoraTextStyles.tituloCard.copyWith(
                  fontSize: tamanhoDoMoto,
                ),
              ),
              SizedBox(height: vao),
              Text(
                ListaTextos.pedidoACaminho,
                textAlign: TextAlign.center,
                style: BoraTextStyles.tituloCard.copyWith(
                  fontSize: tamanhoDoTitulo,
                ),
              ),
              SizedBox(height: vao),
              Text(
                // O endereço sai **inteiro**, o mesmo string que a sheet
                // mostrou (D-6): não existe regra de encurtamento na
                // spec-fonte, e inventar uma faria a tela dizer um endereço
                // que o usuário não confirmou.
                ListaTextos.chegaEm(pedido.parceiro.eta, pedido.endereco),
                textAlign: TextAlign.center,
                style: BoraTextStyles.corpo,
              ),
              SizedBox(height: vao),
              Text(
                ListaTextos.rachadoNoAcerto(
                  MoneyFormatter.reais(pedido.total),
                ),
                textAlign: TextAlign.center,
                style: BoraTextStyles.linhaLista.copyWith(
                  color: BoraColors.primary,
                ),
              ),
              SizedBox(height: vao),
              BoraPrimaryButton(
                key: voltarKey,
                rotulo: ListaTextos.voltarALista,
                larguraTotal: true,
                onPressed: onVoltar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
