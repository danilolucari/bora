import 'package:flutter/widgets.dart';

import '../../../../core/design_system/design_system.dart';

/// O checkbox 26×26 do modo COMPRAR — T-04 · LIST-18.
///
/// "checkbox 26×26 (✓ branco sobre verde)". Desmarcado é o branco de §1 com a
/// borda padrão de §3 e **nenhum** ✓; marcado troca o fundo por
/// [BoraColors.green] — o verde de sucesso financeiro de §1, "checkbox
/// comprado" — e mostra o ✓.
///
/// **Composto dentro da feature** (A-13, `design.md` §7.6): o arquivo 02 não
/// tem checkbox entre os componentes de §5, e criar um lá seria alargar a
/// biblioteca por uma tela. A forma, a borda, o raio e as duas cores vêm dos
/// **tokens** — nenhum literal de cor mora aqui, senão a varredura de pureza
/// da spec 01 morde.
///
/// **Não guarda estado e não tem toque próprio**: quem alterna é a linha
/// inteira (LIST-18), e um alvo de toque só no quadradinho contradiria o
/// requisito.
class CheckboxDaLista extends StatelessWidget {
  const CheckboxDaLista({required this.marcado, super.key});

  /// T-04: "checkbox 26×26".
  static const double lado = 26;

  /// T-04: o glifo do check, branco sobre o verde.
  static const String simboloDoCheck = '✓';

  /// Se o item já está no carrinho.
  final bool marcado;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: lado,
      height: lado,
      child: BoraSurface(
        fundo: marcado ? BoraColors.green : BoraColors.white,
        child: Center(
          child: marcado
              ? Text(
                  simboloDoCheck,
                  style: BoraTextStyles.linhaLista.copyWith(
                    color: BoraColors.white,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
