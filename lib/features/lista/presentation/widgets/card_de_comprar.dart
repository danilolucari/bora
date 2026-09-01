import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../lista_textos.dart';
import 'card_de_planejar.dart';
import 'linha_de_compra.dart';

/// O checklist por corredor do modo COMPRAR — T-04 · RN-27 · LIST-16,
/// LIST-17.
///
/// Um card por corredor **com item**, na ordem em que se anda pelo mercado.
/// Corredor vazio não renderiza: rótulo sem linha nenhuma seria promessa de
/// item que a lista não tem.
///
/// A ordem é **estável**: os corredores saem de [ordemDosCorredores] e os
/// itens da [CardDePlanejar.naOrdemCanonica], as duas independentes do estado
/// de compra — marcar um item não reordena nada (A-12).
///
/// O checklist mostra **toda** a lista, inclusive os quatro essenciais de
/// RN-10: carvão, gelo e sal grosso são compra de mercearia como qualquer
/// outra, e escondê-los faria o anfitrião voltar em casa sem eles.
class CardDeComprar extends StatelessWidget {
  const CardDeComprar({
    required this.resultado,
    required this.aoAlternar,
    super.key,
  });

  /// A ordem dos corredores de RN-27: AÇOUGUE → HORTIFRÚTI → PADARIA →
  /// BEBIDAS → MERCEARIA.
  ///
  /// **Lista literal, e não `Corredor.values`.** A ordem é decisão desta
  /// spec — `corredor.dart` diz isso por escrito — e amarrá-la ao `index` do
  /// enum faria uma reordenação do enum, feita por outro motivo qualquer,
  /// mudar em silêncio o caminho de quem está no mercado.
  static const List<Corredor> ordemDosCorredores = [
    Corredor.acougue,
    Corredor.hortifruti,
    Corredor.padaria,
    Corredor.bebidas,
    Corredor.mercearia,
  ];

  /// O vão entre um corredor e o seguinte — o mesmo ritmo vertical de §5.
  static double get vaoEntreCorredores => BoraSpacing.linhaLista.top;

  /// A saída da calculadora que a tela está mostrando.
  final ResultadoDoCalculo resultado;

  /// Pede para alternar o item de [chave] no carrinho.
  final void Function(ChaveItem chave) aoAlternar;

  /// Os itens de [corredor], na ordem canônica da lista.
  ///
  /// O corredor vem do **catálogo** (`DefinicaoDeItem.corredor`), que cobre os
  /// dezesseis itens — inclusive frango, água, suco, destilados, sal grosso e
  /// copos & pratos, que a tabela de RN-11 não alcança (LIST-17).
  List<ItemDeLista> itensDe(Corredor corredor) => [
        for (final item in CardDePlanejar.naOrdemCanonica(
          resultado.todosOsItens,
        ))
          if (catalogoDeItens[item.chave]!.corredor == corredor) item,
      ];

  @override
  Widget build(BuildContext context) {
    final grupos = <Corredor, List<ItemDeLista>>{
      for (final corredor in ordemDosCorredores)
        if (itensDe(corredor).isNotEmpty) corredor: itensDe(corredor),
    };

    // Lista vazia: nenhum grupo, e nenhum rótulo de corredor órfão (LIST-31).
    if (grupos.isEmpty) return const SizedBox.shrink();

    final corredores = grupos.keys.toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var indice = 0; indice < corredores.length; indice++) ...[
          if (indice > 0) SizedBox(height: vaoEntreCorredores),
          GrupoDoCorredor(
            corredor: corredores[indice],
            itens: grupos[corredores[indice]]!,
            aoAlternar: aoAlternar,
          ),
        ],
      ],
    );
  }
}

/// Um corredor do checklist: o rótulo em caixa alta, a contagem e as linhas.
class GrupoDoCorredor extends StatelessWidget {
  const GrupoDoCorredor({
    required this.corredor,
    required this.itens,
    required this.aoAlternar,
    super.key,
  });

  final Corredor corredor;

  /// Os itens deste corredor — **nunca** vazio: grupo sem item não é montado.
  final List<ItemDeLista> itens;

  final void Function(ChaveItem chave) aoAlternar;

  @override
  Widget build(BuildContext context) {
    return BoraSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: BoraSpacing.linhaLista,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ListaTextos.rotuloDoCorredor(corredor),
                    style: BoraTextStyles.labelSecao,
                  ),
                ),
                Text(
                  ListaTextos.itensNoCorredor(itens.length),
                  style: BoraTextStyles.sublinhaLista,
                ),
              ],
            ),
          ),
          for (final item in itens) ...[
            const SizedBox(
              height: BoraListCard.espessuraDoDivisor,
              child: ColoredBox(color: BoraColors.divider),
            ),
            LinhaDeCompra(
              item: item,
              marcado: item.noCarrinho,
              onAlternar: () => aoAlternar(item.chave),
            ),
          ],
        ],
      ),
    );
  }
}
