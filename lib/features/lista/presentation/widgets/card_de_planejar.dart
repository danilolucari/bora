import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../lista_textos.dart';
import 'linha_de_item.dart';
import 'painel_de_override.dart';

/// O card único do modo PLANEJAR — LIST-03, LIST-04, LIST-05.
///
/// Duas categorias dentro de um card só, como T-04 o desenha: os itens
/// escolhidos, na [ordemCanonicaDaLista], e o bloco literal "ESSENCIAIS ·
/// ENTRAM SOZINHOS" com os quatro de RN-10 — que entram **sem ação nenhuma do
/// usuário**, porque quem os põe na lista é a calculadora.
///
/// Cada categoria fecha com o seu subtotal, e **nenhum dos dois é somado
/// aqui**: eles vêm de `totalExato` e de `totalDosEssenciais` (LIST-07). É o
/// que faz 🍽️ Copos & pratos aparecer na lista e não somar (AD-010) — o
/// predicado `entraNoTotal` mora na camada, e a tela nunca o reimplementa.
///
/// **Os essenciais não expandem.** A calculadora os reconstrói a cada cálculo
/// por `essenciaisAutomaticos()` e não lhes aplica override; abrir uma régua
/// que nunca teria efeito seria desenhar um controle mentiroso.
class CardDePlanejar extends StatelessWidget {
  const CardDePlanejar({
    required this.resultado,
    required this.aoAlternar,
    required this.aoAjustarQuantidade,
    required this.aoAjustarPreco,
    this.chaveExpandida,
    super.key,
  });

  /// A saída da calculadora que a tela está mostrando.
  final ResultadoDoCalculo resultado;

  /// O item aberto, ou `null` com todos fechados. É **um** campo: abrir um
  /// fecha o anterior por construção (LIST-10, aceite de UC-06).
  final ChaveItem? chaveExpandida;

  /// Pede para abrir [chave] — ou fechar tudo, com `null`.
  final void Function(ChaveItem? chave) aoAlternar;

  /// Pede `±1` passo de quantidade no item de [chave].
  final void Function(ChaveItem chave, int passos) aoAjustarQuantidade;

  /// Pede `±1` passo de preço no item de [chave].
  final void Function(ChaveItem chave, int passos) aoAjustarPreco;

  /// [itens] na [ordemCanonicaDaLista].
  ///
  /// A ordem é lida da ordem canônica em vez de herdada da ordem em que os
  /// itens chegaram: assim ela é propriedade da lista, e não consequência de
  /// como a calculadora percorreu o catálogo (A-12).
  static List<ItemDeLista> naOrdemCanonica(List<ItemDeLista> itens) => [
        for (final chave in ordemCanonicaDaLista)
          ...itens.where((item) => item.chave == chave),
      ];

  @override
  Widget build(BuildContext context) {
    final escolhidos = naOrdemCanonica(resultado.itens);
    final essenciais = naOrdemCanonica(resultado.essenciais);

    // Festa sem ninguém: card vazio, sem rótulo de categoria órfão e sem copy
    // inventada (LIST-31, A-11).
    if (escolhidos.isEmpty && essenciais.isEmpty) {
      return const BoraSurface(child: SizedBox.shrink());
    }

    return BoraSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in escolhidos) ..._blocoDoItem(item),
          if (escolhidos.isNotEmpty)
            _Rodape(
              rotulo: ListaTextos.subtotalDaCategoria,
              valorFormatado: MoneyFormatter.reais(totalExato(escolhidos)),
            ),
          if (essenciais.isNotEmpty) ...[
            const _Divisor(),
            _Cabecalho(rotulo: ListaTextos.categoriaDosEssenciais),
            for (final item in essenciais) ..._blocoDoEssencial(item),
            _Rodape(
              rotulo: ListaTextos.subtotalDaCategoria,
              valorFormatado:
                  MoneyFormatter.reais(totalDosEssenciais(essenciais)),
            ),
          ],
        ],
      ),
    );
  }

  /// A linha de um item escolhido, com a régua aberta quando for a vez dela.
  List<Widget> _blocoDoItem(ItemDeLista item) {
    final aberta = item.chave == chaveExpandida;

    return [
      const _Divisor(),
      LinhaDeItem(
        item: item,
        leitura: LinhaDeItem.leituraDeMercadoDe(item.chave),
        aberta: aberta,
        onAlternar: () => aoAlternar(aberta ? null : item.chave),
      ),
      if (aberta)
        PainelDeOverride(
          item: item,
          aoAjustarQuantidade: (passos) =>
              aoAjustarQuantidade(item.chave, passos),
          aoAjustarPreco: (passos) => aoAjustarPreco(item.chave, passos),
        ),
    ];
  }

  /// A linha de um essencial: sem régua, e com a badge amarela de RN-10.
  List<Widget> _blocoDoEssencial(ItemDeLista item) {
    final fonte = item.fonteDaProporcao;

    return [
      const _Divisor(),
      LinhaDeItem(
        item: item,
        leitura: LinhaDeItem.leituraDeMercadoDe(item.chave),
      ),
      if (fonte != null) BadgeAuto(fonte: fonte),
    ];
  }
}

/// O separador de §5: `2px solid divider`, entre linhas.
class _Divisor extends StatelessWidget {
  const _Divisor();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: BoraListCard.espessuraDoDivisor,
      child: ColoredBox(color: BoraColors.divider),
    );
  }
}

/// O rótulo de uma categoria — "ESSENCIAIS · ENTRAM SOZINHOS".
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.rotulo});

  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: BoraSpacing.linhaLista,
      child: Text(rotulo, style: BoraTextStyles.labelSecao),
    );
  }
}

/// A linha final de uma categoria: o rótulo e o subtotal **já somado** pela
/// camada de cálculo.
class _Rodape extends StatelessWidget {
  const _Rodape({required this.rotulo, required this.valorFormatado});

  final String rotulo;
  final String valorFormatado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: BoraSpacing.linhaLista,
      child: Row(
        children: [
          Expanded(child: Text(rotulo, style: BoraTextStyles.labelSecao)),
          Text(valorFormatado, style: BoraTextStyles.linhaLista),
        ],
      ),
    );
  }
}

/// A badge amarela `AUTO ∝ {fonte}` de RN-10 — LIST-04.
///
/// Composta aqui a partir dos tokens de §5 pela mesma razão do checkbox 26×26
/// (A-13, `design.md` §7.6): [BoraStatusTag] tira o rótulo do próprio
/// [BoraStatus], e nenhum dos sete significados de §5 é "AUTO". A forma, o
/// padding, a cor e o papel tipográfico são os **mesmos** da tag de status.
class BadgeAuto extends StatelessWidget {
  const BadgeAuto({required this.fonte, super.key});

  /// A fonte da proporção, metadado do catálogo (D-5).
  final String fonte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: BoraSpacing.linhaLista,
      child: Align(
        alignment: Alignment.centerLeft,
        child: BoraSurface(
          fundo: BoraColors.yellow,
          padding: BoraSpacing.tag,
          child: Text(
            ListaTextos.autoProporcional(fonte),
            style: BoraTextStyles.microTag.copyWith(color: BoraColors.ink),
          ),
        ),
      ),
    );
  }
}
