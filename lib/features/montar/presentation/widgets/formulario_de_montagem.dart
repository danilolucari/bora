import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/secao_da_montagem.dart';
import '../bloc/montar_event.dart';
import 'card_de_contagem.dart';
import 'secao_de_chips.dart';
import 'secao_de_duracao.dart';

/// As cinco seções do formulário, **escritas uma vez só** — MONT-01, W-R1.
///
/// T-03 e W-03 são arranjos diferentes da mesma tela, e a diferença entre eles
/// é de **rótulo**, não de estrutura: quatro literais divergem (A-09) e o
/// resto é idêntico. Por isso os rótulos entram por parâmetro e este widget
/// não sabe em que layout está — nenhuma consulta a viewport, nenhum
/// `LayoutMode`. É isso que faz W-R1 ser estrutural em vez de disciplina.
///
/// A ordem é a de T-03: contagem → NA GRELHA → NA GELADEIRA → PROS FORTES →
/// duração. "PROS FORTES" está nas **duas** plataformas (**AD-018**): sem ela
/// o mobile não alcançaria os R$ 211 do aceite de UC-03.
class FormularioDeMontagem extends StatelessWidget {
  const FormularioDeMontagem({
    required this.composicao,
    required this.rotuloDePessoas,
    required this.rotuloDaDuracao,
    required this.aoAlterarContagem,
    required this.aoAlternarItem,
    required this.aoSelecionarDuracao,
    this.larguraMaximaDaDuracao,
    super.key,
  });

  /// O vão entre uma seção e a seguinte.
  static const double vaoEntreSecoes = 24;

  /// A composição que a tela está mostrando. O formulário **reflete** — ele
  /// não guarda contagem, seleção nem duração próprias.
  final ComposicaoDaFesta composicao;

  /// "CONFIRMADOS + EXTRAS SEM APP" (T-03) ou "QUEM CONFIRMOU" (W-03).
  final String rotuloDePessoas;

  /// "QUANTO TEMPO DE FESTA?" (T-03) ou "ATÉ QUE HORAS?" (W-03).
  final String rotuloDaDuracao;

  final void Function(TipoDeCabeca tipo, int delta) aoAlterarContagem;
  final void Function(ChaveItem chave) aoAlternarItem;
  final void Function(int horas) aoSelecionarDuracao;

  /// O teto de largura do segmented de duração, quando a plataforma declara
  /// um — W-03 dá "máx 360px" e T-03 não dá nenhum. Só atravessa; quem o
  /// aplica é a [SecaoDeDuracao].
  final double? larguraMaximaDaDuracao;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotuloDePessoas, style: BoraTextStyles.labelSecao),
        SizedBox(height: SecaoDeChips.vao),
        CardDeContagem(
          contagem: composicao.contagem,
          aoAlterar: aoAlterarContagem,
        ),
        for (final secao in SecaoDaMontagem.values) ...[
          const SizedBox(height: vaoEntreSecoes),
          SecaoDeChips(
            secao: secao,
            selecionados: composicao.itensSelecionados,
            aoAlternar: aoAlternarItem,
          ),
        ],
        const SizedBox(height: vaoEntreSecoes),
        SecaoDeDuracao(
          rotulo: rotuloDaDuracao,
          duracaoHoras: composicao.duracaoHoras,
          aoSelecionar: aoSelecionarDuracao,
          larguraMaxima: larguraMaximaDaDuracao,
        ),
      ],
    );
  }
}
