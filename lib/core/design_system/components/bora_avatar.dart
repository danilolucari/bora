import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_text_styles.dart';

/// O avatar circular de §5: "34–40px, borda 2px `ink`, iniciais 800".
///
/// O círculo é **exceção de forma autorizada por §3** — "Exceções: avatares e
/// dots (círculo, 50%)" —, e este arquivo está por isso na allowlist da
/// guarda de forma.
///
/// A cor não é escolhida aqui: vem de [BoraColors.avatarPairFor], que fixa os
/// pares das cinco personas de §1 e devolve **um desses mesmos cinco** para
/// qualquer outro nome, sempre o mesmo para o mesmo nome (A-05).
class BoraAvatar extends StatelessWidget {
  const BoraAvatar({required this.nome, this.tamanho = tamanhoPadrao, super.key});

  /// §5: "34–40px" — o extremo inferior da faixa, pelo critério de A-01.
  static const double tamanhoPadrao = 34;

  /// A inicial de [nome]: a **primeira** letra, em CAIXA ALTA (A-13).
  ///
  /// As personas de RN-30 têm um nome só (Rafa, Ana, Léo, Bia, Duda), e §5
  /// não pede sobrenome.
  static String inicialDe(String nome) =>
      nome.isEmpty ? '' : nome.substring(0, 1).toUpperCase();

  final String nome;

  /// O diâmetro do círculo, dentro da faixa de §5.
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final par = BoraColors.avatarPairFor(nome);

    return SizedBox(
      width: tamanho,
      height: tamanho,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: par.fundo,
          // §3: a exceção de forma. Não há `borderRadius` junto — círculo e
          // raio não coexistem numa `BoxDecoration`.
          shape: BoxShape.circle,
          border: BoraBorders.padraoInk,
        ),
        child: Center(
          child: Text(
            inicialDe(nome),
            // §5 dá o peso da inicial ("iniciais 800") e não o tamanho: fica
            // o 14px do papel 800 de §2.
            style: BoraTextStyles.linhaLista.copyWith(color: par.texto),
          ),
        ),
      ),
    );
  }
}

/// A pilha de avatares de §5: "sobreposição `margin-left: -8 a -10px`; último
/// slot '+N' branco com borda tracejada".
///
/// [extras] é quanta gente sobrou **além** dos [nomes] mostrados. Zero ⇒ o
/// slot não é desenhado: "+0" não é informação.
class BoraStackedAvatars extends StatelessWidget {
  const BoraStackedAvatars({
    required this.nomes,
    this.extras = 0,
    this.sobreposicao = sobreposicaoPadrao,
    super.key,
  });

  /// §5: "sobreposição `margin-left: -8 a -10px`" — negativa, e no extremo
  /// declarado (A-01).
  static const double sobreposicaoPadrao = -8;

  /// §1: "slot '+N' branco com borda tracejada". §1 não dá cor a essa borda:
  /// fica o tracejado de slot de §3, `2px dashed #9b9b9b`.
  static const BoraDashedBorder bordaDoSlot = BoraBorders.slotTracejado;

  final List<String> nomes;

  /// Quanta gente o "+N" resume. `0` ⇒ sem slot.
  final int extras;

  /// O quanto cada avatar avança sobre o anterior. Negativo, por §5.
  final double sobreposicao;

  bool get _temSlot => extras > 0;

  /// Quantos círculos a pilha desenha, contando o slot "+N".
  int get _quantidade => nomes.length + (_temSlot ? 1 : 0);

  /// O avanço de um círculo para o próximo: o diâmetro menos a sobreposição
  /// de §5.
  double get _passo => BoraAvatar.tamanhoPadrao + sobreposicao;

  @override
  Widget build(BuildContext context) {
    if (_quantidade == 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: BoraAvatar.tamanhoPadrao + (_quantidade - 1) * _passo,
      height: BoraAvatar.tamanhoPadrao,
      child: Stack(
        children: [
          for (var indice = 0; indice < nomes.length; indice++)
            Positioned(
              left: indice * _passo,
              child: BoraAvatar(nome: nomes[indice]),
            ),
          if (_temSlot)
            Positioned(
              left: nomes.length * _passo,
              child: _SlotDeExtras(extras: extras),
            ),
        ],
      ),
    );
  }
}

/// O último slot da pilha: "+N" branco com borda tracejada (§1, §5).
class _SlotDeExtras extends StatelessWidget {
  const _SlotDeExtras({required this.extras});

  final int extras;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: BoraAvatar.tamanhoPadrao,
      height: BoraAvatar.tamanhoPadrao,
      child: CustomPaint(
        // O tracejado vai **por cima** do preenchimento: metade do traço cai
        // dentro do círculo, e um fundo pintado depois o comeria.
        foregroundPainter: BoraDashedCirclePainter(
          cor: BoraStackedAvatars.bordaDoSlot.cor,
          largura: BoraStackedAvatars.bordaDoSlot.largura,
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: BoraColors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '+$extras',
              style: BoraTextStyles.linhaLista.copyWith(
                color: BoraStackedAvatars.bordaDoSlot.cor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// O tracejado circular de §1/§3, desenhado à mão.
///
/// O Flutter não tem `BorderStyle.dashed`, e trazer pacote ou imagem para uma
/// borda violaria AD-002 — então o traço é arco, e o vão é o arco que não se
/// desenha.
class BoraDashedCirclePainter extends CustomPainter {
  const BoraDashedCirclePainter({required this.cor, required this.largura});

  /// O comprimento do traço.
  ///
  /// **Assumption:** o arquivo 02 diz "borda tracejada" e "2px dashed" sem
  /// dar traço nem vão. O valor escolhido é o dobro da espessura de 2px de
  /// §3 — nenhum número novo entra no sistema, e o desenho fica com a
  /// proporção 1:1 entre traço e vão.
  static const double traco = 4;

  /// O comprimento do vão, igual ao [traco] pelo mesmo motivo.
  static const double vao = 4;

  final Color cor;
  final double largura;

  @override
  void paint(Canvas canvas, Size size) {
    final raio = (size.shortestSide - largura) / 2;
    if (raio <= 0) return;

    final circulo = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: raio,
    );
    // Um número inteiro de (traço + vão) fecha a volta sem sobra visível.
    final repeticoes = math.max(
      1,
      (2 * math.pi * raio / (traco + vao)).round(),
    );
    final passo = 2 * math.pi / repeticoes;
    final arcoDoTraco = passo * traco / (traco + vao);
    final pincel = Paint()
      ..color = cor
      ..strokeWidth = largura
      ..style = PaintingStyle.stroke;

    for (var indice = 0; indice < repeticoes; indice++) {
      canvas.drawArc(circulo, indice * passo, arcoDoTraco, false, pincel);
    }
  }

  @override
  bool shouldRepaint(BoraDashedCirclePainter anterior) =>
      anterior.cor != cor || anterior.largura != largura;
}
