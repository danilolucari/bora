import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../bloc/lista_bloc.dart';
import '../bloc/pedido_bloc.dart';
import '../lista_textos.dart';
import 'card_de_comprar.dart';
import 'card_de_planejar.dart';

/// T-04 inteiro no compacto — LIST-01, LIST-02, LIST-05, LIST-06, LIST-14,
/// LIST-19, LIST-25, LIST-31.
///
/// A ordem é a da spec: header "SUA LISTA", o segmented "🧮 PLANEJAR / 🛒
/// COMPRAR" com PLANEJAR ativo por default, a dica tracejada do modo, o corpo
/// do modo ativo rolando e o rodapé fixo com o total.
///
/// **O rodapé não rola.** Ele é irmão da área rolável, não filho dela — a
/// mesma estrutura de T-03: o total fica à vista enquanto o anfitrião mexe nos
/// itens lá embaixo.
///
/// **Só desenha.** O estado chega pronto do `ListaBloc` e os toques saem por
/// callback; quem navega e quem abre a sheet é a página (AD-020). Nenhuma
/// conta e nenhum cifrão nascem aqui (LIST-07): total, por adulto e faixa real
/// vêm de `core/calculo` e passam por [MoneyFormatter].
///
// SPEC_DEVIATION: o arquivo 02 §8 limita a **2 acentos por tela** e esta usa
// três — vermelho (CTA, segmented ativo, "MÉDIA", marcador, ponto de editado),
// amarelo (badge `AUTO ∝`) e verde `#0B6B3A` (check do modo COMPRAR).
// Reason: T-04 é literal nos três usos. O verde entra como **estado de
// controle** com significado fixo de §1 ("comprado"), não como cor de
// superfície. A leitura estrita de §8 continua violada — declarado, não
// silenciado (D-4 / A-22).
class ListaCompacta extends StatelessWidget {
  const ListaCompacta({
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

  /// O padding do header e do corpo.
  ///
  /// T-04 não dá medida de margem à tela: fica o ritmo horizontal que o rodapé
  /// fixo de §5 já tem (`BoraSpacing.rodape`), para nenhum número novo entrar
  /// no sistema.
  static final EdgeInsets paddingDoHeader = EdgeInsets.fromLTRB(
    BoraSpacing.rodape.left,
    BoraSpacing.rodape.top,
    BoraSpacing.rodape.right,
    0,
  );

  /// O padding do corpo rolável — o mesmo ritmo, com a folga de baixo de §5.
  static const EdgeInsets paddingDoCorpo = BoraSpacing.sheet;

  /// O vão entre um bloco da cabeça e o seguinte — o ritmo vertical de §5.
  static double get vaoEntreBlocos => BoraSpacing.linhaLista.top;

  /// O estado da tela. Card, dica e rodapé leem o **mesmo** objeto: não há
  /// como um deles ficar para trás (LIST-13).
  final ListaState estado;

  final void Function(ModoDaLista modo) aoAlternarModo;
  final void Function(ChaveItem? chave) aoAlternarItem;
  final void Function(ChaveItem chave, int passos) aoAjustarQuantidade;
  final void Function(ChaveItem chave, int passos) aoAjustarPreco;
  final void Function(ChaveItem chave) aoAlternarNoCarrinho;

  /// "RESTAURAR" — desfaz todos os overrides de uma vez (LIST-14).
  final VoidCallback aoRestaurar;

  /// O CTA de pedido. **Só é acionado quando há o que pedir**: com a lista
  /// vazia, ou com tudo já no carrinho, o botão fica inerte e este callback
  /// não é chamado (LIST-25 · A-07).
  final VoidCallback aoPedir;

  /// A âncora e o corpo de [dica], separados no primeiro espaço.
  ///
  /// A copy de T-04 escreve a dica com o emoji embutido ("📊 Cada preço…") e
  /// [BoraDashedNote] pede a âncora e o corpo em campos separados. O corte
  /// mantém o literal de [ListaTextos] como fonte única: juntando os dois de
  /// volta com um espaço, sai exatamente a string da spec.
  static (String, String) ancoraECorpo(String dica) {
    final corte = dica.indexOf(' ');

    return (dica.substring(0, corte), dica.substring(corte + 1));
  }

  /// A dica tracejada do modo — LIST-02.
  static String dicaDoModo(ModoDaLista modo) => switch (modo) {
        ModoDaLista.planejar => ListaTextos.dicaPlanejar,
        ModoDaLista.comprar => ListaTextos.dicaComprar,
      };

  @override
  Widget build(BuildContext context) {
    final resultado = estado.resultado;

    // Antes da primeira emissão de `observarFesta` não há lista nenhuma para
    // desenhar. T-04 não desenha estado de carregamento e RN-29 não dá copy
    // para ele: em vez de inventar uma, a tela não pinta nada por um frame.
    if (resultado == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: paddingDoHeader,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ListaTextos.titulo, style: BoraTextStyles.tituloTela),
              SizedBox(height: vaoEntreBlocos),
              SegmentedDeModo(modo: estado.modo, aoAlternar: aoAlternarModo),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: paddingDoCorpo,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DicaDoModo(modo: estado.modo),
                SizedBox(height: vaoEntreBlocos),
                CorpoDaLista(
                  estado: estado,
                  resultado: resultado,
                  aoAlternarItem: aoAlternarItem,
                  aoAjustarQuantidade: aoAjustarQuantidade,
                  aoAjustarPreco: aoAjustarPreco,
                  aoAlternarNoCarrinho: aoAlternarNoCarrinho,
                ),
              ],
            ),
          ),
        ),
        RodapeDaLista(
          totais: TotaisDaLista.de(estado, resultado),
          aoRestaurar: aoRestaurar,
          aoPedir: aoPedir,
        ),
      ],
    );
  }
}

/// O segmented "🧮 PLANEJAR / 🛒 COMPRAR" — LIST-01.
///
/// O índice do enum **é** a ordem de [ListaTextos.opcoesDeModo]: PLANEJAR
/// primeiro, e por isso o default de `ListaState.modo` já abre a tela com ele
/// ativo.
class SegmentedDeModo extends StatelessWidget {
  const SegmentedDeModo({
    required this.modo,
    required this.aoAlternar,
    super.key,
  });

  final ModoDaLista modo;
  final void Function(ModoDaLista modo) aoAlternar;

  @override
  Widget build(BuildContext context) {
    return BoraSegmentedControl(
      opcoes: ListaTextos.opcoesDeModo,
      indiceAtivo: modo.index,
      onSelecionar: (indice) => aoAlternar(ModoDaLista.values[indice]),
    );
  }
}

/// A dica tracejada do modo ativo — LIST-02.
class DicaDoModo extends StatelessWidget {
  const DicaDoModo({required this.modo, super.key});

  final ModoDaLista modo;

  @override
  Widget build(BuildContext context) {
    final (ancora, corpo) =
        ListaCompacta.ancoraECorpo(ListaCompacta.dicaDoModo(modo));

    return BoraDashedNote(emoji: ancora, texto: corpo);
  }
}

/// O corpo do modo ativo — o card de PLANEJAR ou o checklist de COMPRAR.
///
/// **Um estado, dois modos**: alternar não recria nada além do corpo, e checks,
/// overrides e item expandido moram na festa e no bloc (LIST-15, LIST-20).
class CorpoDaLista extends StatelessWidget {
  const CorpoDaLista({
    required this.estado,
    required this.resultado,
    required this.aoAlternarItem,
    required this.aoAjustarQuantidade,
    required this.aoAjustarPreco,
    required this.aoAlternarNoCarrinho,
    super.key,
  });

  final ListaState estado;
  final ResultadoDoCalculo resultado;
  final void Function(ChaveItem? chave) aoAlternarItem;
  final void Function(ChaveItem chave, int passos) aoAjustarQuantidade;
  final void Function(ChaveItem chave, int passos) aoAjustarPreco;
  final void Function(ChaveItem chave) aoAlternarNoCarrinho;

  @override
  Widget build(BuildContext context) {
    return switch (estado.modo) {
      ModoDaLista.planejar => CardDePlanejar(
          resultado: resultado,
          chaveExpandida: estado.chaveExpandida,
          aoAlternar: aoAlternarItem,
          aoAjustarQuantidade: aoAjustarQuantidade,
          aoAjustarPreco: aoAjustarPreco,
        ),
      ModoDaLista.comprar => CardDeComprar(
          resultado: resultado,
          aoAlternar: aoAlternarNoCarrinho,
        ),
    };
  }
}

/// Os textos do bloco de total, **iguais** no rodapé de T-04 e no rail de W-04.
///
/// Existe para que compacto e expandido não divirjam no primeiro ajuste: os
/// dois montam este mesmo objeto a partir do mesmo estado (W-R1). Nenhum
/// número é somado aqui — todos saem prontos de [ResultadoDoCalculo], de
/// `faixaRealDaLista` e de [MoneyFormatter] (LIST-07).
class TotaisDaLista {
  const TotaisDaLista({
    required this.rotulo,
    required this.valorFormatado,
    required this.linhaDoModo,
    required this.porAdulto,
    required this.rotuloDoCta,
    required this.podePedir,
    required this.temOverrides,
  });

  /// Monta os textos do [estado] — o **único** ponto que os deriva.
  factory TotaisDaLista.de(ListaState estado, ResultadoDoCalculo resultado) {
    final planejar = estado.modo == ModoDaLista.planejar;
    final itens = resultado.todosOsItens;

    return TotaisDaLista(
      rotulo: ListaTextos.mediaTotal,
      valorFormatado: MoneyFormatter.reais(resultado.totalComEssenciais),
      linhaDoModo: planejar
          ? _faixaReal(estado.faixaReal)
          : ListaTextos.noCarrinho(_marcados(itens), itens.length),
      porAdulto: ListaTextos.porAdulto(
        MoneyFormatter.reais(resultado.porAdulto),
      ),
      rotuloDoCta: planejar
          ? ListaTextos.fazerPedidoComCarrinho
          : ListaTextos.pedirOQueFalta,
      podePedir: PedidoBloc.itensDoPedido(
        itens,
        apenasOQueFalta: !planejar,
      ).isNotEmpty,
      temOverrides: resultado.temOverrides,
    );
  }

  /// T-04: o rótulo do bloco de total.
  ///
  /// *SPEC_PRECISION_GAP*: T-04 dá o rótulo "MÉDIA TOTAL" ao rodapé de
  /// PLANEJAR e não dá rótulo nenhum ao de COMPRAR — onde escreve só "N de M
  /// no carrinho + total". O número é **o mesmo** nos dois modos (marcar é
  /// estado de compra, não de preço), então o produto repete a palavra que já
  /// diz, em vez de inventar uma segunda.
  final String rotulo;

  /// O total da festa com os essenciais, já formatado (LIST-06).
  final String valorFormatado;

  /// "faixa real: de R$ X a R$ Y" em PLANEJAR, "{N} de {M} no carrinho" em
  /// COMPRAR.
  ///
  /// `null` **só** em PLANEJAR com a lista vazia: a linha não renderiza, em
  /// vez de mostrar uma faixa de R$ 0 a R$ 0 (LIST-31 AC2).
  final String? linhaDoModo;

  /// "≈ R$ {x} por adulto" — RN-14, nos dois modos.
  final String porAdulto;

  /// "FAZER PEDIDO 🛒" ou "PEDIR O QUE FALTA 🛵".
  final String rotuloDoCta;

  /// `false` ⇒ o CTA fica **inerte** e a sheet não abre (LIST-25 · A-07):
  /// lista vazia, ou nada por marcar no modo COMPRAR.
  final bool podePedir;

  /// `true` ⇒ o "RESTAURAR" existe no rodapé (LIST-14 · A-10).
  final bool temOverrides;

  static String? _faixaReal(FaixaReal? faixa) => faixa == null
      ? null
      : ListaTextos.faixaReal(
          MoneyFormatter.reais(faixa.minimo),
          MoneyFormatter.reais(faixa.maximo),
        );

  static int _marcados(List<ItemDeLista> itens) =>
      itens.where((item) => item.noCarrinho).length;
}

/// O rodapé fixo de T-04 — LIST-06, LIST-14, LIST-19, LIST-25.
///
// SPEC_DEVIATION: `design.md` §7.4 monta este rodapé com [BoraFooterBar], e
// ele não serve inteiro — tem **uma** sublinha, e T-04 somado a LIST-06 pede
// **duas** ("faixa real"/contador e "≈ R$ x por adulto"), mais o "RESTAURAR"
// de RN-12 ao lado do CTA.
// Reason: composto aqui a partir dos tokens do próprio [BoraFooterBar] —
// `bordaSuperior`, `BoraSpacing.rodape` e os papéis `rodapeLabel`,
// `valorRodape` e `rodapeSublinha`. Nenhum número novo entra no sistema e
// `core/design_system/` não é tocado.
class RodapeDaLista extends StatelessWidget {
  const RodapeDaLista({
    required this.totais,
    required this.aoRestaurar,
    required this.aoPedir,
    super.key,
  });

  /// A chave do CTA de pedido.
  static const Key ctaKey = Key('lista-cta-de-pedido');

  /// A chave do "RESTAURAR" — presente **só** quando há override.
  static const Key restaurarKey = Key('lista-restaurar');

  /// O vão entre o "RESTAURAR" e o CTA.
  static double get vaoEntreAcoes => BoraSpacing.linhaLista.top;

  final TotaisDaLista totais;
  final VoidCallback aoRestaurar;
  final VoidCallback aoPedir;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: BoraColors.paper,
        border: BoraFooterBar.bordaSuperior,
        borderRadius: BoraBorders.raio,
      ),
      child: Padding(
        padding: BoraSpacing.rodape,
        child: Row(
          children: [
            Expanded(child: BlocoDeTotal(totais: totais)),
            SizedBox(width: vaoEntreAcoes),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (totais.temOverrides) ...[
                  BoraSecondaryButton(
                    key: restaurarKey,
                    rotulo: ListaTextos.restaurar,
                    onPressed: aoRestaurar,
                  ),
                  SizedBox(height: vaoEntreAcoes),
                ],
                BoraPrimaryButton(
                  key: ctaKey,
                  rotulo: totais.rotuloDoCta,
                  onPressed: totais.podePedir ? aoPedir : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// As quatro linhas do bloco de total, na ordem literal de T-04 e de W-04:
/// rótulo → valor → faixa real (ou contador) → "por adulto".
class BlocoDeTotal extends StatelessWidget {
  const BlocoDeTotal({required this.totais, super.key});

  final TotaisDaLista totais;

  @override
  Widget build(BuildContext context) {
    final linhaDoModo = totais.linhaDoModo;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(totais.rotulo, style: BoraTextStyles.rodapeLabel),
        Text(totais.valorFormatado, style: BoraTextStyles.valorRodape),
        if (linhaDoModo != null)
          Text(linhaDoModo, style: BoraTextStyles.rodapeSublinha),
        Text(totais.porAdulto, style: BoraTextStyles.rodapeSublinha),
      ],
    );
  }
}
