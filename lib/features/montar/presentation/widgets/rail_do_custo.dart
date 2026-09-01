import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../montar_textos.dart';
import 'formulario_de_montagem.dart';
import 'lista_viva.dart';

/// O rail sticky de W-03 — MONT-10, MONT-13, MONT-23.
///
/// Quatro blocos, **nesta ordem**: o card-herói escuro, a lista viva, o CTA
/// "MANDAR NO GRUPO 📲" e a ação secundária "SALVAR ROLÊ".
///
/// **Sticky por construção**, e não por plugin: o rail é uma coluna de largura
/// fixa que o layout monta **fora** da área rolável (W-R2). Ele não tem
/// rolagem própria — a única coisa que rola aqui dentro é a [ListaViva], nos
/// 330px que W-03 lhe dá (W-R4). Envolvê-lo num scroll seria justamente
/// desfazer o "o card-herói escuro nunca sai do viewport".
///
/// **Só desenha.** O total e o por-cabeça saem prontos de
/// [ResultadoDoCalculo] e viram texto por [MoneyFormatter.reais]; a duração
/// vira rótulo por `rotuloDeDuracao`. Este arquivo não soma, não divide e não
/// arredonda (MONT-08).
///
/// **Não navega** (AD-020): os dois botões emitem, e quem chama `context.go`
/// é a página. "SALVAR ROLÊ" é a saída de W-03 que **não** sai da tela — A-14:
/// "salvar sem mandar no grupo".
class RailDoCusto extends StatelessWidget {
  const RailDoCusto({
    required this.resultado,
    required this.duracaoHoras,
    required this.aoMandarNoGrupo,
    required this.aoSalvar,
    super.key,
  });

  /// W-03: "Grid `1fr / 370px`" — a coluna da direita tem 370px.
  static const double largura = 370;

  /// O vão entre um bloco do rail e o seguinte.
  ///
  /// W-03 não o declara. Fica o mesmo ritmo que o formulário já usa entre
  /// seções — pela mesma razão de [ListaViva.vaoEntreCategorias]: nenhum
  /// número novo entra no sistema.
  static const double vaoEntreBlocos = FormularioDeMontagem.vaoEntreSecoes;

  /// A saída da calculadora que a tela está mostrando. O rail **reflete**: os
  /// três blocos leem o mesmo objeto, então não há como um ficar para trás
  /// (MONT-12).
  final ResultadoDoCalculo resultado;

  /// A duração da composição, em horas — o `{duração}` do rótulo do herói.
  ///
  /// Vem por parâmetro porque [ResultadoDoCalculo] não a carrega: ele guarda
  /// o `fator` de RN-02, que é outra coisa. Derivar as horas do fator seria
  /// conta na apresentação (MONT-08).
  final int duracaoHoras;

  /// O toque no CTA. Quem navega é a página (AD-020).
  final VoidCallback aoMandarNoGrupo;

  /// O toque em "SALVAR ROLÊ" — persiste **sem navegar** (P2-1 AC3).
  final VoidCallback aoSalvar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: largura,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BoraHeroCard(
            label: MontarTextos.labelDoHeroi(
              pessoas: resultado.contagem.pessoas,
              duracaoHoras: duracaoHoras,
            ),
            valorFormatado: MoneyFormatter.reais(resultado.totalDosItens),
            sublinha: MontarTextos.porCabecaExpandido(
              MoneyFormatter.reais(resultado.porCabeca),
            ),
          ),
          const SizedBox(height: vaoEntreBlocos),
          ListaViva(resultado: resultado),
          const SizedBox(height: vaoEntreBlocos),
          BoraPrimaryButton(
            rotulo: MontarTextos.mandarNoGrupo,
            onPressed: aoMandarNoGrupo,
            larguraTotal: true,
          ),
          const SizedBox(height: vaoEntreBlocos),
          BoraSecondaryButton(
            rotulo: MontarTextos.salvarRole,
            onPressed: aoSalvar,
          ),
        ],
      ),
    );
  }
}
