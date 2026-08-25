import 'package:flutter/widgets.dart';

import '../tokens/bora_colors.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';
import 'bora_surface.dart';

/// Os sete significados da tag de status de §5, cada um com o par de cores
/// que a spec fixa para ele.
///
/// O par mora **no enum**, e não numa tabela ao lado: com `fundo` e `texto`
/// obrigatórios no construtor, um status sem cor não compila.
///
/// §5 nomeia a cor do texto só onde ela foge do padrão — "CO-ANFITRIÃO=
/// `purple` com texto branco" e "SÓ VÊ=`wa-bubble` com texto `text-2`". Nos
/// outros cinco vale o texto principal de §1, `ink`; e sobre fundo `ink` vale
/// o token que §1 define exatamente para isso: "`cream` — texto sobre `ink`".
enum BoraStatus {
  /// §5: "RECEBE=fundo `ink`".
  recebe(rotulo: 'RECEBE', fundo: BoraColors.ink, texto: BoraColors.cream),

  /// §5: "PAGA=fundo `primary`".
  paga(rotulo: 'PAGA', fundo: BoraColors.primary, texto: BoraColors.ink),

  /// §5: "NO ZERO=branco".
  noZero(rotulo: 'NO ZERO', fundo: BoraColors.white, texto: BoraColors.ink),

  /// §5: "ANFITRIÃO=`yellow`".
  anfitriao(
    rotulo: 'ANFITRIÃO',
    fundo: BoraColors.yellow,
    texto: BoraColors.ink,
  ),

  /// §5: "CO-ANFITRIÃO=`purple`/texto branco".
  coAnfitriao(
    rotulo: 'CO-ANFITRIÃO',
    fundo: BoraColors.purple,
    texto: BoraColors.white,
  ),

  /// §5: "CONVIDADO=branco".
  convidado(
    rotulo: 'CONVIDADO',
    fundo: BoraColors.white,
    texto: BoraColors.ink,
  ),

  /// §5: "SÓ VÊ=`wa-bubble`/texto `text-2`".
  soVe(rotulo: 'SÓ VÊ', fundo: BoraColors.waBubble, texto: BoraColors.text2);

  const BoraStatus({
    required this.rotulo,
    required this.fundo,
    required this.texto,
  });

  /// A copy literal de §5, em CAIXA ALTA (§7).
  final String rotulo;

  final Color fundo;
  final Color texto;
}

/// A tag de status de §5: "(pill quadrada) Borda 2px `ink`, padding 4–6px
/// 7–9px, 800 9–10.5px ls .5px".
///
/// "Pill **quadrada**": o nome vem do formato de pastilha, mas a forma é a de
/// §3 — canto reto, como todo o resto do sistema.
class BoraStatusTag extends StatelessWidget {
  const BoraStatusTag({required this.status, super.key});

  /// O significado da tag. É ele que traz as cores — a tela não escolhe cor
  /// de status.
  final BoraStatus status;

  @override
  Widget build(BuildContext context) {
    return BoraSurface(
      fundo: status.fundo,
      padding: BoraSpacing.tag,
      child: Text(
        // §7 e DS-32: label sai em CAIXA ALTA, venha como vier.
        status.rotulo.toUpperCase(),
        style: BoraTextStyles.microTag.copyWith(color: status.texto),
      ),
    );
  }
}
