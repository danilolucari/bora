import 'package:flutter/material.dart'
    show MaterialLocalizations, MaterialType, Material, showGeneralDialog;
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/responsive/layout_mode.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../domain/parceiro_de_entrega.dart';
import '../../domain/pedido.dart';
import '../bloc/pedido_bloc.dart';
import '../lista_textos.dart';
import 'cartao_de_parceiro.dart';

/// A sheet "FAZER PEDIDO" — T-04 · W-04 · LIST-21, LIST-22, LIST-23, LIST-25.
///
/// **Um conteúdo, dois invólucros.** [ConteudoDoPedido] é montado igual nos
/// dois modos; o que muda é a moldura — `BoraBottomSheet` ancorado embaixo no
/// compacto, `BoraSurface` centrada no expandido (W-04: "modal central").
/// Dois conteúdos divergiriam no primeiro ajuste, e é o teste de "os mesmos
/// literais e os mesmos números" que impede isso.
///
/// O título é **`FAZER PEDIDO` nos dois pontos de entrada** (A-18), inclusive
/// quando a sheet foi aberta por "PEDIR O QUE FALTA 🛵": T-04 dá um título só
/// à sheet, e trocá-lo por modo seria copy nossa.
class SheetDePedido extends StatelessWidget {
  const SheetDePedido({
    required this.expandido,
    this.onFechar,
    this.aoConfirmar,
    super.key,
  });

  /// A chave do painel expandido — o irmão de `BoraBottomSheet.panelKey`.
  static const Key painelExpandidoKey = Key('sheet-de-pedido-expandido');

  /// A chave do ✕ do painel expandido.
  static const Key fecharExpandidoKey = Key('sheet-de-pedido-fechar');

  /// A largura do modal central do expandido.
  ///
  /// *SPEC_PRECISION_GAP*: W-04 pede "modal central" e não dá medida. Fica a
  /// largura em que T-04 desenhou esta sheet — `BoraPhoneFrame.largura`, o
  /// 390 de §5 — em vez de um número novo: o conteúdo é o mesmo, e a medida
  /// para a qual ele foi desenhado já existe no sistema.
  static double get larguraDoModal => BoraPhoneFrame.largura;

  /// `true` ⇒ modal central de W-04; `false` ⇒ bottom sheet de §5.
  final bool expandido;

  /// Fecha a sheet. `null` quando ela aparece parada, fora de uma rota.
  final VoidCallback? onFechar;

  /// Chamado **uma vez**, com o pedido que a porta devolveu (LIST-28 AC2).
  ///
  /// É por aqui que o overlay e a `Despesa` de RN-20 nascem — a sheet não
  /// monta nem uma coisa nem outra.
  final ValueChanged<Pedido>? aoConfirmar;

  /// Abre a sheet no invólucro que a largura pede — AD-007.
  ///
  /// O `PedidoBloc` é criado **aqui e morre com a rota** (`design.md` §2.3):
  /// é o que faz "o endereço trocado vale só para este pedido" (A-08) ser
  /// verdade por construção.
  ///
  /// Toque fora fecha (`barrierDismissible`), e fechar não pede nada — nenhuma
  /// `Despesa`, nenhuma alteração na lista (UC-16 A1).
  static Future<void> mostrar(
    BuildContext context, {
    required PedidoBloc Function(BuildContext) criarBloc,
    ValueChanged<Pedido>? aoConfirmar,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierColor: BoraColors.sheetScrim,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      // §6 não descreve motion de sheet e §8 proíbe inventar um — a mesma
      // escolha que `BoraBottomSheet.mostrar` já fez.
      transitionDuration: Duration.zero,
      pageBuilder: (contextoDaRota, _, _) => BlocProvider<PedidoBloc>(
        create: criarBloc,
        // A largura vem das **restrições**, não do `MediaQuery`: é o mesmo
        // `ResponsiveBuilder` que a `ListaPage` usa, e é ele que faz o
        // invólucro trocar junto com a tela quando a janela cruza os 900px.
        child: ResponsiveBuilder(
          builder: (_, modo) {
            final expandido = modo == LayoutMode.expanded;

            return Align(
              alignment:
                  expandido ? Alignment.center : Alignment.bottomCenter,
              child: Material(
                type: MaterialType.transparency,
                child: SheetDePedido(
                  expandido: expandido,
                  aoConfirmar: aoConfirmar,
                  onFechar: () => Navigator.of(contextoDaRota).pop(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aoConfirmar = this.aoConfirmar;

    final painel = expandido ? _modalCentral() : _bottomSheet();

    if (aoConfirmar == null) return painel;

    return BlocListener<PedidoBloc, PedidoState>(
      listenWhen: (antes, depois) =>
          antes.confirmado == null && depois.confirmado != null,
      listener: (context, state) => aoConfirmar(state.confirmado!),
      child: painel,
    );
  }

  /// O invólucro compacto: o bottom sheet de §5, com o título e o ✕ dele.
  Widget _bottomSheet() => SizedBox(
        width: double.infinity,
        child: BoraBottomSheet(
          titulo: ListaTextos.tituloDoPedido,
          onFechar: onFechar,
          conteudo: (_) => const ConteudoDoPedido(),
        ),
      );

  /// O invólucro expandido: a mesma cabeça, numa superfície central de W-04.
  ///
  /// O título e o ✕ repetem as medidas de `BoraBottomSheet` — o mesmo
  /// `BoraTextStyles.tituloSheet`, o mesmo `tamanhoDoFechar` de 32 e o mesmo
  /// `BoraSpacing.sheet`. Nenhuma medida nova nasce aqui.
  Widget _modalCentral() => SizedBox(
        width: larguraDoModal,
        child: BoraSurface(
          key: painelExpandidoKey,
          fundo: BoraColors.paper,
          padding: BoraSpacing.sheet,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ListaTextos.tituloDoPedido,
                      style: BoraTextStyles.tituloSheet,
                    ),
                  ),
                  GestureDetector(
                    key: fecharExpandidoKey,
                    onTap: onFechar,
                    child: SizedBox(
                      width: BoraBottomSheet.tamanhoDoFechar,
                      height: BoraBottomSheet.tamanhoDoFechar,
                      child: BoraSurface(
                        fundo: BoraColors.paper,
                        child: Center(
                          child: Text(
                            _fechar,
                            style: BoraTextStyles.botao
                                .copyWith(color: BoraColors.ink),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const ConteudoDoPedido(),
            ],
          ),
        ),
      );
}

/// O glifo do botão de fechar, o mesmo de §5.
const String _fechar = '✕';

/// O conteúdo da sheet, montado igual nos dois invólucros — LIST-21..LIST-25.
///
/// Endereço + `TROCAR`, "ENTREGA POR" com os três cartões de RN-27, o resumo
/// Subtotal/Frete/Total e "CONFIRMAR PEDIDO →".
///
/// **Não soma e não formata dinheiro por conta própria**: os três números vêm
/// prontos do `PedidoBloc` e passam pelo `MoneyFormatter` (RN-13 · LIST-07).
class ConteudoDoPedido extends StatefulWidget {
  const ConteudoDoPedido({super.key});

  /// A chave do "TROCAR".
  static const Key trocarKey = Key('pedido-trocar');

  /// A chave do campo de endereço, aberto pelo "TROCAR".
  static const Key campoDoEnderecoKey = Key('pedido-endereco');

  /// A chave do CTA "CONFIRMAR PEDIDO →".
  static const Key confirmarKey = Key('pedido-confirmar');

  /// A chave do bloco Subtotal/Frete/Total.
  static const Key resumoKey = Key('pedido-resumo');

  /// T-04: o pino da linha do endereço.
  static const String pino = '📍';

  /// O vão vertical entre os blocos — o mesmo ritmo de §5.
  static double get vao => BoraSpacing.linhaLista.top;

  @override
  State<ConteudoDoPedido> createState() => _ConteudoDoPedidoState();
}

class _ConteudoDoPedidoState extends State<ConteudoDoPedido> {
  final TextEditingController _controle = TextEditingController();
  bool _editando = false;

  @override
  void dispose() {
    _controle.dispose();
    super.dispose();
  }

  /// "TROCAR" abre a edição e, no toque seguinte, **aplica** o que foi
  /// digitado.
  ///
  /// *SPEC_PRECISION_GAP*: T-04 desenha o "TROCAR" e não desenha como a edição
  /// termina. O mesmo botão fecha e aplica, em vez de um "OK" que nenhuma spec
  /// escreve — inventar copy num produto de copy literal é o pior dos dois.
  ///
  /// O endereço aplicado vazio volta ao da festa, e quem decide isso é o
  /// `PedidoBloc` (A-08): a defesa é regra, não disciplina de widget.
  void _alternarEdicao(String endereco) {
    if (_editando) {
      context.read<PedidoBloc>().add(EnderecoTrocado(_controle.text));
      setState(() => _editando = false);
      return;
    }

    _controle.text = endereco;
    setState(() => _editando = true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PedidoBloc, PedidoState>(
      builder: (context, state) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: ConteudoDoPedido.vao),
          _linhaDoEndereco(context, state),
          SizedBox(height: ConteudoDoPedido.vao),
          Text(ListaTextos.entregaPor, style: BoraTextStyles.labelSecao),
          for (final parceiro in ParceiroDeEntrega.values) ...[
            SizedBox(height: ConteudoDoPedido.vao),
            CartaoDeParceiro(
              parceiro: parceiro,
              selecionado: state.parceiro == parceiro,
              onSelecionar: state.podeEscolher(parceiro)
                  ? () => context
                      .read<PedidoBloc>()
                      .add(ParceiroSelecionado(parceiro))
                  : null,
            ),
          ],
          SizedBox(height: ConteudoDoPedido.vao),
          Column(
            // Agrupado e nomeado porque o mesmo valor aparece duas vezes na
            // sheet: o frete do iFood é o mesmo número no cartão e no resumo,
            // e um `find.text` cru acharia os dois.
            key: ConteudoDoPedido.resumoKey,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _linhaDoResumo(ListaTextos.subtotal, state.subtotal),
              _linhaDoResumo(ListaTextos.frete, state.frete),
              _linhaDoResumo(ListaTextos.total, state.total),
            ],
          ),
          SizedBox(height: ConteudoDoPedido.vao),
          BoraPrimaryButton(
            key: ConteudoDoPedido.confirmarKey,
            rotulo: ListaTextos.confirmarPedido,
            larguraTotal: true,
            // Inerte enquanto o envio está em voo (LIST-33): a idempotência é
            // do bloc, e o botão apagado é o que o usuário vê dela.
            onPressed: state.enviando
                ? null
                : () => context.read<PedidoBloc>().add(const PedidoEnviado()),
          ),
        ],
      ),
    );
  }

  /// T-04: "linha 📍 'Laje do Rafa — Vila Madalena' com 'TROCAR' vermelho
  /// sublinhado".
  Widget _linhaDoEndereco(BuildContext context, PedidoState state) => Row(
        children: [
          Text(
            ConteudoDoPedido.pino,
            style: BoraTextStyles.linhaLista.copyWith(
              fontSize: BoraListCard.tamanhoDoEmoji,
            ),
          ),
          SizedBox(width: BoraListCard.vaoDoEmoji),
          Expanded(
            child: _editando
                ? BoraTextField(
                    key: ConteudoDoPedido.campoDoEnderecoKey,
                    controller: _controle,
                    placeholder: state.endereco,
                  )
                : Text(state.endereco, style: BoraTextStyles.corpo),
          ),
          SizedBox(width: BoraListCard.vaoDoEmoji),
          GestureDetector(
            key: ConteudoDoPedido.trocarKey,
            behavior: HitTestBehavior.opaque,
            onTap: () => _alternarEdicao(state.endereco),
            child: Text(
              ListaTextos.trocar,
              style: BoraTextStyles.botao.copyWith(
                color: BoraColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: BoraColors.primary,
              ),
            ),
          ),
        ],
      );

  /// Uma linha do resumo: o rótulo à esquerda, o valor formatado à direita.
  ///
  /// Sem padding próprio — o ritmo entre as três linhas é o da entrelinha de
  /// §2, e uma medida nova aqui seria número fora dos tokens.
  Widget _linhaDoResumo(String rotulo, double valor) => Row(
        children: [
          Expanded(child: Text(rotulo, style: BoraTextStyles.corpo)),
          Text(MoneyFormatter.reais(valor), style: BoraTextStyles.linhaLista),
        ],
      );
}
