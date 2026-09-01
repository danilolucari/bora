import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../bloc/lista_bloc.dart';
import '../lista_textos.dart';
import 'lista_compacta.dart';

/// W-04 — a lista turbinada no expandido (LIST-01, LIST-06, LIST-09, LIST-14,
/// LIST-19, LIST-29, LIST-31).
///
/// Grid `1fr / 370px`: o card de itens na coluna principal, que rola, e o rail
/// à direita, que não. **Sem rodapé fixo** (W-R2): o CTA mora no rail.
///
/// **As duas telas montam o mesmo corpo.** [CorpoDaLista], [SegmentedDeModo] e
/// [BlocoDeTotal] vêm de `lista_compacta.dart` — um estado, dois arranjos, que
/// é o que torna W-R1 estrutural em vez de disciplina. Se o expandido montasse
/// widgets próprios, os dois divergiriam no primeiro ajuste.
///
// SPEC_DEVIATION: W-04 escreve que a lista turbinada mora "dentro do rail de
// W-03", com o segmented no topo do rail.
// Reason: o rail de W-03 tem 370px e já está construído e fechado pela spec 05
// (card-herói + lista viva), e nele não cabem barra de faixa, steppers duplos e
// checklist por corredor. Fica o grid `1fr / 370px` que o **próprio** W-04 dá a
// "Custos & acerto", a outra tela de lista longa com total. O que W-04 fixa é
// preservado literalmente: segmented no topo do rail e sheet como modal central
// (D-3 / A-16).
class ListaExpandida extends StatelessWidget {
  const ListaExpandida({
    required this.estado,
    required this.aoAlternarModo,
    required this.aoAlternarItem,
    required this.aoAjustarQuantidade,
    required this.aoAjustarPreco,
    required this.aoAlternarNoCarrinho,
    required this.aoRestaurar,
    required this.aoPedir,
    super.key,
  });

  /// W-04: "Grid `1fr / 370px`" — a coluna da direita tem 370px.
  static const double larguraDoRail = 370;

  /// O padding do container e o vão entre as duas colunas.
  ///
  /// W-04 não dá medida a esta tela: fica o ritmo de §5 (`BoraSpacing.sheet`),
  /// para nenhum número novo entrar no sistema.
  static const EdgeInsets paddingDoContainer = BoraSpacing.sheet;

  /// O vão entre a linha de título e o grid, e entre as duas colunas.
  static double get vaoDoGrid => BoraSpacing.sheet.left;

  final ListaState estado;

  final void Function(ModoDaLista modo) aoAlternarModo;
  final void Function(ChaveItem? chave) aoAlternarItem;
  final void Function(ChaveItem chave, int passos) aoAjustarQuantidade;
  final void Function(ChaveItem chave, int passos) aoAjustarPreco;
  final void Function(ChaveItem chave) aoAlternarNoCarrinho;
  final VoidCallback aoRestaurar;
  final VoidCallback aoPedir;

  @override
  Widget build(BuildContext context) {
    final resultado = estado.resultado;
    if (resultado == null) return const SizedBox.shrink();

    return Padding(
      padding: paddingDoContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // W-04 não dá degrau tipográfico à esta tela — só W-03 o escreve, e
          // para o próprio título dele. Fica o papel de título de tela do
          // arquivo 02, sem número novo.
          Text(ListaTextos.titulo, style: BoraTextStyles.tituloTela),
          SizedBox(height: vaoDoGrid),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "1fr": a coluna principal é o que sobra, e é ela quem rola —
                // rolagem só no documento, nunca de lado (W-R4).
                Expanded(
                  child: SingleChildScrollView(
                    child: CorpoDaLista(
                      estado: estado,
                      resultado: resultado,
                      aoAlternarItem: aoAlternarItem,
                      aoAjustarQuantidade: aoAjustarQuantidade,
                      aoAjustarPreco: aoAjustarPreco,
                      aoAlternarNoCarrinho: aoAlternarNoCarrinho,
                    ),
                  ),
                ),
                SizedBox(width: vaoDoGrid),
                RailDaLista(
                  modo: estado.modo,
                  totais: TotaisDaLista.de(estado, resultado),
                  aoAlternarModo: aoAlternarModo,
                  aoRestaurar: aoRestaurar,
                  aoPedir: aoPedir,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// O rail sticky de W-04 — LIST-29.
///
/// A ordem é a literal de W-04, de cima para baixo: **segmented** → bloco de
/// total do modo ativo → "faixa real" (PLANEJAR) *ou* "{N} de {M} no carrinho"
/// (COMPRAR) → "≈ R$ {x} por adulto" → CTA. As três últimas linhas moram no
/// [BlocoDeTotal], o mesmo que o rodapé compacto usa.
///
/// **Sticky por construção**, e não por plugin: o rail é uma coluna de largura
/// fixa que o layout monta **fora** da área rolável (W-R2). Ele não tem rolagem
/// própria — envolvê-lo num scroll seria desfazer o "o total nunca sai do
/// viewport".
///
/// **Sem [BoraFooterBar] e sem [RodapeDaLista]**: o rodapé fixo mobile não
/// existe no web, e o CTA mora aqui (W-R2).
class RailDaLista extends StatelessWidget {
  const RailDaLista({
    required this.modo,
    required this.totais,
    required this.aoAlternarModo,
    required this.aoRestaurar,
    required this.aoPedir,
    super.key,
  });

  /// A chave do CTA do rail.
  static const Key ctaKey = Key('lista-rail-cta-de-pedido');

  /// A chave do "RESTAURAR" do rail — presente **só** quando há override.
  static const Key restaurarKey = Key('lista-rail-restaurar');

  /// O vão entre um bloco do rail e o seguinte.
  static double get vaoEntreBlocos => BoraSpacing.linhaLista.top;

  final ModoDaLista modo;
  final TotaisDaLista totais;
  final void Function(ModoDaLista modo) aoAlternarModo;
  final VoidCallback aoRestaurar;
  final VoidCallback aoPedir;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ListaExpandida.larguraDoRail,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedDeModo(modo: modo, aoAlternar: aoAlternarModo),
          SizedBox(height: vaoEntreBlocos),
          BlocoDeTotal(totais: totais),
          SizedBox(height: vaoEntreBlocos),
          if (totais.temOverrides) ...[
            BoraSecondaryButton(
              key: restaurarKey,
              rotulo: ListaTextos.restaurar,
              onPressed: aoRestaurar,
            ),
            SizedBox(height: vaoEntreBlocos),
          ],
          BoraPrimaryButton(
            key: ctaKey,
            rotulo: totais.rotuloDoCta,
            larguraTotal: true,
            onPressed: totais.podePedir ? aoPedir : null,
          ),
        ],
      ),
    );
  }
}
