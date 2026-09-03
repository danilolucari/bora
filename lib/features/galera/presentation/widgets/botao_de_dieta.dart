import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../galera_textos.dart';

/// Um dos três botões de "RESTRIÇÃO ALIMENTAR" de T-05: "(🍖/🥗/🚫, **ativo
/// vermelho**)".
///
/// **Por que existe como widget de feature.** Nenhum componente de §5 tem
/// ativo vermelho: o segmented de §5 acende em `ink`. O par de cores do ativo
/// não é inventado — é o que §5 já fixou para fundo `primary` em
/// [BoraStatus.paga] (`fundo: primary, texto: ink`), e nenhuma cor nova entra
/// no sistema.
///
/// **A geometria do [BoraSegmentedControl] não é replicada.** T-05 não chama
/// isto de segmented: são três botões numa linha, sem container de borda única
/// e sem divisor de 2px. Reproduzir a geometria daria um segmented de outra
/// cor, que é justamente a variante que **não** é feita aqui.
///
/// SPEC_DEVIATION registrada: uma variante `BoraSegmentedControl(acentoAtivo:)`
/// é candidata ao design system numa spec futura. Não nasce nesta feature
/// porque a spec 01 está fora da fronteira desta, e emendar o design system a
/// partir de uma tela é o caminho curto para o componente virar o caso de uso
/// de quem o emendou.
class BotaoDeDieta extends StatelessWidget {
  const BotaoDeDieta({
    required this.dieta,
    required this.ativo,
    required this.onEscolher,
    super.key,
  });

  /// §5, [BoraStatus.paga]: o par que a spec já fixou para fundo `primary`.
  static const Color fundoAtivo = BoraColors.primary;

  /// O texto sobre o vermelho — o mesmo par de §5.
  static const Color textoAtivo = BoraColors.ink;

  /// O fundo em repouso: a superfície branca de §3.
  static const Color fundoInativo = BoraColors.white;

  /// O texto em repouso — o `text-2` que §5 dá ao inativo do segmented.
  static const Color textoInativo = BoraColors.text2;

  /// A dieta que este botão oferece — RN-21.
  final Dieta dieta;

  /// Se é a dieta declarada da pessoa.
  final bool ativo;

  /// Emitido com [dieta] — **nunca** quando o botão já está [ativo] (GAL-28).
  final ValueChanged<Dieta> onEscolher;

  void _tocar() {
    // GAL-28: tocar a opção já ativa não muda estado nem emite escrita.
    if (ativo) return;
    onEscolher(dieta);
  }

  @override
  Widget build(BuildContext context) {
    return BoraPressSink(
      // O acento é o neutro de §4: o vermelho já é o estado ativo, e usá-lo
      // também na sombra apagaria a diferença entre aceso e apagado.
      acento: BoraAccent.ink,
      fundo: ativo ? fundoAtivo : fundoInativo,
      padding: BoraSpacing.chip,
      onPressed: _tocar,
      child: Text(
        GaleraTextos.rotuloDaDieta(dieta),
        textAlign: TextAlign.center,
        style: BoraTextStyles.chip.copyWith(
          color: ativo ? textoAtivo : textoInativo,
        ),
      ),
    );
  }
}
