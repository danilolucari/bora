import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../../domain/resumo_de_festa.dart';
import '../bloc/home_state.dart';
import '../home_textos.dart';
import 'card_da_festa.dart';
import 'comecar_outra.dart';

/// T-02 — a Home no mobile.
///
/// Só desenha: o estado vem pronto do `HomeBloc` e os toques saem por
/// callback. A ordem é a de T-02: título → subtítulo → card da festa →
/// "COMEÇAR OUTRA".
///
/// O arquivo de festas passadas **não** renderiza aqui (A-11): T-02 só o conta
/// no subtítulo, e a seção ARQUIVO é desenhada em W-02.
class HomeCompacta extends StatelessWidget {
  const HomeCompacta({
    required this.estado,
    required this.aoConvidar,
    required this.aoMontarLista,
    required this.aoVerOAcerto,
    required this.aoComecarChurrasco,
    super.key,
  });

  /// T-02: "Título 'SEUS ROLÊS' 30px".
  ///
  /// O tamanho vem da spec de tela, não do arquivo 02 — é o mesmo critério do
  /// degrau de `BoraMarca`: o design system é dono do papel tipográfico, e a
  /// spec de tela é dona do degrau. W-02 sobe o mesmo título para 40px.
  static const double tamanhoDoTitulo = 30;

  final HomeState estado;
  final void Function(ResumoDeFesta) aoConvidar;
  final void Function(ResumoDeFesta) aoMontarLista;
  final void Function(ResumoDeFesta) aoVerOAcerto;
  final VoidCallback aoComecarChurrasco;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HomeTextos.titulo,
            style: BoraTextStyles.tituloCard.copyWith(
              fontSize: tamanhoDoTitulo,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            HomeTextos.subtitulo(
              chegando: estado.chegando.length,
              passadas: estado.passadas.length,
            ),
            style: BoraTextStyles.corpo,
          ),
          const SizedBox(height: 28),
          if (estado.situacao == SituacaoDaHome.falhou) ...[
            // HOME-16: falha é mensagem na tela, não tela em branco — e
            // "COMEÇAR OUTRA" continua abaixo, acessível.
            Text(HomeTextos.falha, style: BoraTextStyles.dica),
            const SizedBox(height: 20),
          ],
          for (final resumo in estado.chegando) ...[
            CardDaFesta(
              resumo: resumo,
              confirmacaoNova: estado.temConfirmacaoNova(resumo),
              aoConvidar: () => aoConvidar(resumo),
              aoMontarLista: () => aoMontarLista(resumo),
              aoVerOAcerto: () => aoVerOAcerto(resumo),
            ),
            const SizedBox(height: 32),
          ],
          ComecarOutra(aoComecarChurrasco: aoComecarChurrasco),
        ],
      ),
    );
  }
}
