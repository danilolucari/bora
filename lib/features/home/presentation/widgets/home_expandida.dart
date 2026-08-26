import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/resumo_de_festa.dart';
import '../bloc/home_state.dart';
import '../home_textos.dart';
import 'arquivo_de_festas.dart';
import 'card_da_festa.dart';
import 'comecar_outra.dart';

/// W-02 — a Home no web.
///
/// Mesmo estado, mesmos widgets de T-02: o que muda é o arranjo. O título e o
/// subtítulo dividem uma linha, e o conteúdo vira grid de duas colunas.
class HomeExpandida extends StatelessWidget {
  const HomeExpandida({
    required this.estado,
    required this.aoConvidar,
    required this.aoMontarLista,
    required this.aoVerOAcerto,
    required this.aoComecarChurrasco,
    super.key,
  });

  /// W-02: "Container 1040px".
  static const double larguraDoContainer = 1040;

  /// W-02: "padding 34px 36px 48px".
  static const EdgeInsets paddingDoContainer = EdgeInsets.fromLTRB(36, 34, 36, 48);

  /// W-02: "SEUS ROLÊS 40px" — o degrau web do mesmo papel que T-02 usa em
  /// 30px. O design system é dono do papel; a spec de tela é dona do degrau.
  static const double tamanhoDoTitulo = 40;

  /// W-02: "Grid `1.15fr / 0.85fr`", em inteiros.
  static const int flexDaEsquerda = 115;
  static const int flexDaDireita = 85;

  /// W-02: "gap 28px".
  static const double vaoDoGrid = 28;

  final HomeState estado;
  final void Function(ResumoDeFesta) aoConvidar;
  final void Function(ResumoDeFesta) aoMontarLista;
  final void Function(ResumoDeFesta) aoVerOAcerto;
  final VoidCallback aoComecarChurrasco;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: larguraDoContainer),
          child: Padding(
            padding: paddingDoContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LinhaDeTitulo(estado: estado),
                const SizedBox(height: vaoDoGrid),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: flexDaEsquerda,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final resumo in estado.chegando) ...[
                            CardDaFesta(
                              resumo: resumo,
                              confirmacaoNova:
                                  estado.temConfirmacaoNova(resumo),
                              aoConvidar: () => aoConvidar(resumo),
                              aoMontarLista: () => aoMontarLista(resumo),
                              aoVerOAcerto: () => aoVerOAcerto(resumo),
                            ),
                            const SizedBox(height: vaoDoGrid),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: vaoDoGrid),
                    Expanded(
                      flex: flexDaDireita,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ComecarOutra(
                            aoComecarChurrasco: aoComecarChurrasco,
                          ),
                          const SizedBox(height: vaoDoGrid),
                          // W-02 põe o ARQUIVO abaixo de "COMEÇAR OUTRA", na
                          // mesma coluna.
                          ArquivoDeFestas(passadas: estado.passadas),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// W-02: "'SEUS ROLÊS' 40px à esquerda; o subtítulo 500 14px `text-2` à
/// direita (baseline)".
class _LinhaDeTitulo extends StatelessWidget {
  const _LinhaDeTitulo({required this.estado});

  final HomeState estado;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          HomeTextos.titulo,
          style: BoraTextStyles.tituloCard.copyWith(
            fontSize: HomeExpandida.tamanhoDoTitulo,
          ),
        ),
        const Spacer(),
        Text(
          HomeTextos.subtitulo(
            chegando: estado.chegando.length,
            passadas: estado.passadas.length,
          ),
          style: BoraTextStyles.corpo,
        ),
      ],
    );
  }
}
