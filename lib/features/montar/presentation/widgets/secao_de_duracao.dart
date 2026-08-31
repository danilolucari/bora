import 'package:flutter/widgets.dart';

import '../../../../core/design_system/design_system.dart';
import '../montar_textos.dart';

/// O bloco da duração da festa: label + segmented 2h / 4h / 6h / Dia
/// (MONT-01, MONT-02).
///
/// O [rotulo] entra por parâmetro porque ele **diverge por plataforma**
/// (A-09): T-03 escreve "QUANTO TEMPO DE FESTA?" e W-03 escreve "ATÉ QUE
/// HORAS?". Resolver a diferença aqui dentro obrigaria o widget a saber em
/// que layout ele está — que é exatamente o que W-R1 evita.
///
/// O widget **não** muda sozinho: o ativo é [duracaoHoras], que vem do bloc, e
/// tocar só emite [aoSelecionar]. É o mesmo contrato do
/// [BoraSegmentedControl].
class SecaoDeDuracao extends StatelessWidget {
  const SecaoDeDuracao({
    required this.rotulo,
    required this.duracaoHoras,
    required this.aoSelecionar,
    super.key,
  });

  /// As horas de cada opção, **na ordem dos rótulos**.
  ///
  /// "Dia" vale **10 horas** — o valor que RN-02 usa para o dia todo e que
  /// `rotuloDeDuracao` devolve como "Dia todo" (A-15). O mapa mora aqui
  /// porque é o que traduz o toque na tela para o parâmetro do cálculo;
  /// nenhuma conta é feita com ele.
  static const List<int> horasPorOpcao = [2, 4, 6, 10];

  /// O rótulo da seção, literal da plataforma que montou o formulário.
  final String rotulo;

  /// A duração ativa agora, em horas.
  final int duracaoHoras;

  /// Emitido com as **horas** da opção tocada — não com o índice: quem recebe
  /// fala em duração, não em posição de botão.
  final void Function(int horas) aoSelecionar;

  /// A posição da opção ativa, ou `-1` quando [duracaoHoras] não é nenhuma
  /// das quatro. Nesse caso o segmented não acende nenhuma — mentir sobre
  /// qual está ativa seria pior do que não acender.
  int get indiceAtivo => horasPorOpcao.indexOf(duracaoHoras);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(rotulo, style: BoraTextStyles.labelSecao),
        SizedBox(height: BoraSpacing.chip.top),
        BoraSegmentedControl(
          opcoes: MontarTextos.opcoesDeDuracao,
          indiceAtivo: indiceAtivo,
          onSelecionar: (indice) => aoSelecionar(horasPorOpcao[indice]),
        ),
      ],
    );
  }
}
