import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../bloc/montar_event.dart';
import '../bloc/montar_state.dart';
import '../montar_textos.dart';
import 'cabecalho_do_role.dart';
import 'formulario_de_montagem.dart';
import 'rodape_do_custo.dart';

/// T-03 inteiro — a tela Montar no compacto (MONT-01, MONT-02, MONT-03,
/// MONT-14).
///
/// A ordem é a da spec: header com voltar e "A CONTA DO ROLÊ", a identidade do
/// rolê, as cinco seções do formulário rolando, e o rodapé fixo com o "SAI
/// POR".
///
/// **O rodapé não rola.** Ele é irmão da área rolável, não filho dela: é isso
/// que faz o custo ficar à vista enquanto o anfitrião mexe nos controles lá
/// embaixo — e é o que AD-018 torna necessário, porque a quarta seção de chips
/// alonga a rolagem de T-03.
///
/// **Só desenha.** O estado vem pronto do `MontarBloc` e os toques saem por
/// callback; quem navega é a página (AD-020).
class MontarCompacto extends StatelessWidget {
  const MontarCompacto({
    required this.estado,
    required this.aoVoltar,
    required this.aoAlterarContagem,
    required this.aoAlternarItem,
    required this.aoSelecionarDuracao,
    required this.aoAlterarNome,
    required this.aoAlterarData,
    required this.aoFecharLista,
    super.key,
  });

  /// O acionador de voltar do header.
  static const Key chaveDoVoltar = Key('montar-compacto-voltar');

  /// *SPEC_PRECISION_GAP*: T-03 diz "header com voltar" e não dá copy para o
  /// controle. Fica a seta, que é o que o próprio grafo de navegação de `01`
  /// desenha; nenhuma palavra é inventada.
  static const String voltar = '←';

  /// O padding do corpo e do header, no ritmo que T-02 já fixou para a tela
  /// compacta.
  static const EdgeInsets paddingDoHeader = EdgeInsets.fromLTRB(20, 24, 20, 0);
  static const EdgeInsets paddingDoCorpo = EdgeInsets.fromLTRB(20, 20, 20, 32);

  final MontarState estado;

  final VoidCallback aoVoltar;
  final void Function(TipoDeCabeca tipo, int delta) aoAlterarContagem;
  final void Function(ChaveItem chave) aoAlternarItem;
  final void Function(int horas) aoSelecionarDuracao;
  final void Function(String nome) aoAlterarNome;
  final void Function(String data) aoAlterarData;
  final VoidCallback aoFecharLista;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: paddingDoHeader,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BoraSecondaryButton(
                    key: chaveDoVoltar,
                    rotulo: voltar,
                    onPressed: aoVoltar,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      MontarTextos.titulo,
                      style: BoraTextStyles.tituloTela,
                    ),
                  ),
                ],
              ),
              SizedBox(height: FormularioDeMontagem.vaoEntreSecoes),
              CabecalhoDoRole(
                nome: estado.festa.nome,
                data: estado.festa.data,
                aoAlterarNome: aoAlterarNome,
                aoAlterarData: aoAlterarData,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: paddingDoCorpo,
            child: FormularioDeMontagem(
              composicao: estado.composicao,
              rotuloDePessoas: MontarTextos.secaoDePessoasCompacto,
              rotuloDaDuracao: MontarTextos.duracaoCompacto,
              aoAlterarContagem: aoAlterarContagem,
              aoAlternarItem: aoAlternarItem,
              aoSelecionarDuracao: aoSelecionarDuracao,
            ),
          ),
        ),
        RodapeDoCusto(
          resultado: estado.resultado,
          aoFecharLista: aoFecharLista,
        ),
      ],
    );
  }
}
