import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../montar_textos.dart';

/// O rodapé fixo de T-03 — o "SAI POR" (MONT-03, MONT-05, MONT-06, MONT-07).
///
/// Os dois números saem prontos de [ResultadoDoCalculo] e viram texto por
/// [MoneyFormatter.reais]: o rodapé **não soma, não divide e não arredonda**.
/// RN-13 ("dinheiro é sempre o inteiro arredondado") mora na camada de
/// cálculo, e é ela quem escreve o cifrão.
///
/// A sublinha usa `porCabeca` — total **sem** essenciais dividido por
/// **pessoas**, criança inclusive (A-05, RN-14). O `porAdulto`, que divide por
/// adultos e soma os essenciais, é o número da tela Lista: os dois coexistem
/// de propósito e mostrar o segundo aqui quebraria o aceite de UC-03.
class RodapeDoCusto extends StatelessWidget {
  const RodapeDoCusto({
    required this.resultado,
    required this.aoFecharLista,
    super.key,
  });

  /// A saída da calculadora que a tela está mostrando.
  final ResultadoDoCalculo resultado;

  /// O toque no CTA. Quem navega é a página (AD-020).
  final VoidCallback aoFecharLista;

  @override
  Widget build(BuildContext context) {
    return BoraFooterBar(
      label: MontarTextos.saiPor,
      valorFormatado: MoneyFormatter.reais(resultado.totalDosItens),
      sublinha: MontarTextos.porCabecaCompacto(
        MoneyFormatter.reais(resultado.porCabeca),
      ),
      cta: BoraPrimaryButton(
        rotulo: MontarTextos.fecharLista,
        onPressed: aoFecharLista,
      ),
    );
  }
}
