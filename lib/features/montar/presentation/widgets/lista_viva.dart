import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/secao_da_montagem.dart';
import '../montar_textos.dart';
import 'formulario_de_montagem.dart';
import 'secao_de_chips.dart';

/// A lista viva do rail de W-03 — MONT-11, MONT-13, MONT-24.
///
/// Uma seção por categoria **não vazia**: o rótulo da seção e um
/// [BoraListCard] com uma linha por item e a linha final "SUBTOTAL". As
/// categorias são as **mesmas três do formulário** (A-07), e o item entra na
/// que `secaoDe` disser — é a mesma declaração que dirige os chips, então a
/// lista nunca mostra um item numa categoria em que o chip não está.
///
/// **Só desenha.** Cada quantidade vem de `rotuloDeQuantidade`, cada valor de
/// [MoneyFormatter.reais] e cada subtotal de `totalExato` — todos da camada de
/// cálculo. Este arquivo não soma, não divide e não arredonda (MONT-08).
///
/// **Sem essenciais** (A-06): a lista mostra `resultado.itens`, que são os
/// escolhidos mais o kit que RN-21 acrescenta. Carvão, gelo, sal grosso e
/// copos & pratos entram sozinhos na tela Lista (RN-10, UC-05) — mostrá-los
/// aqui faria a soma dos subtotais divergir do card-herói na mesma tela.
///
/// **Sem "QUEM LEVA?" e sem a dica 💡** (A-02, **AD-018**): a atribuição
/// depende dos confirmados, que nascem na spec 07, e o próprio W-03 declara o
/// botão que cicla como lacuna a substituir. Sem o botão, a dica seria
/// instrução falsa.
class ListaViva extends StatelessWidget {
  const ListaViva({required this.resultado, super.key});

  /// W-03: a lista viva é um bloco de `max-height: 330px, overflow-y: auto` —
  /// ela rola **dentro de si**, e a página nunca rola por causa dela (W-R4).
  static const double alturaMaxima = 330;

  /// O vão entre uma categoria e a seguinte.
  ///
  /// W-03 não o declara. Fica o mesmo ritmo que o formulário já usa entre
  /// seções, para nenhum número novo entrar no sistema.
  static const double vaoEntreCategorias =
      FormularioDeMontagem.vaoEntreSecoes;

  /// A saída da calculadora que a tela está mostrando. O widget **reflete**:
  /// ele não guarda lista própria nem recalcula nada.
  final ResultadoDoCalculo resultado;

  /// Os itens de [secao], **na ordem de `ordemCanonicaDaLista`**.
  ///
  /// A ordem é lida da ordem canônica em vez de herdada da ordem em que os
  /// itens chegaram: assim ela é propriedade da lista, e não consequência
  /// acidental de como a calculadora percorreu o catálogo.
  List<ItemDeLista> itensDa(SecaoDaMontagem secao) => [
        for (final chave in ordemCanonicaDaLista)
          if (secaoDe(chave) == secao)
            ...resultado.itens.where((item) => item.chave == chave),
      ];

  @override
  Widget build(BuildContext context) {
    final categorias = <SecaoDaMontagem, List<ItemDeLista>>{
      for (final secao in SecaoDaMontagem.values)
        if (itensDa(secao).isNotEmpty) secao: itensDa(secao),
    };

    // Festa sem ninguém, ou nenhum chip marcado: nenhum card, e nenhum
    // rótulo de categoria órfão (UC-03 E1).
    if (categorias.isEmpty) return const SizedBox.shrink();

    final secoes = categorias.keys.toList();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: alturaMaxima),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var indice = 0; indice < secoes.length; indice++) ...[
              if (indice > 0) const SizedBox(height: vaoEntreCategorias),
              _Categoria(
                secao: secoes[indice],
                itens: categorias[secoes[indice]]!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Uma categoria da lista: o rótulo da seção e o card com as linhas.
class _Categoria extends StatelessWidget {
  const _Categoria({required this.secao, required this.itens});

  final SecaoDaMontagem secao;
  final List<ItemDeLista> itens;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MontarTextos.rotuloDaSecao(secao),
          style: BoraTextStyles.labelSecao,
        ),
        SizedBox(height: SecaoDeChips.vao),
        BoraListCard(
          linhas: [
            for (final item in itens)
              BoraListRow(
                emoji: item.emoji,
                titulo: item.nome,
                sublinha: rotuloDeQuantidade(item.quantidade, item.unidade),
                valor: MoneyFormatter.reais(item.valor),
              ),
            // O subtotal é uma linha do próprio card, **sem emoji-âncora**:
            // W-03 diz "categorias com subtotal" e §5 do arquivo 02 proíbe
            // componente novo. O valor sai de `totalExato`, que arredonda uma
            // vez só, na formatação (AD-009) — somar as parcelas já
            // arredondadas daria outro número.
            BoraListRow(
              emoji: '',
              titulo: MontarTextos.subtotal,
              valor: MoneyFormatter.reais(totalExato(itens)),
            ),
          ],
        ),
      ],
    );
  }
}
