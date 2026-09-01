import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../lista_textos.dart';

/// A leitura de mercado de RN-11, indexada pela chave do catálogo.
///
/// Índice de leitura, não regra: a tabela é `const` e a 🌭 Linguiça toscana
/// entra sem chave, porque não tem chip em T-03. Item fora deste mapa é item
/// que RN-11 não cobre — e para ele **nada** é fabricado (LIST-08 AC3).
final Map<ChaveItem, PrecoDeMercado> _leituraPorChave = {
  for (final preco in tabelaDePrecosDeMercado)
    if (preco.chave case final ChaveItem chave) chave: preco,
};

/// A linha de um item no modo PLANEJAR — LIST-03, LIST-08, LIST-12.
///
/// Emoji, nome, quantidade, valor e — só quando a tabela de RN-11 cobre o
/// item — a sublinha "média de N mercados", a micro-label `MÉDIA` e a barra de
/// faixa. Sem cobertura, a linha mostra a quantidade e para por aí: não se
/// inventa faixa para item que a tabela não tem (D-2 · A-03).
///
/// **Nenhuma conta aqui.** Quantidade, valor, extremos e a posição do marcador
/// chegam prontos da camada de cálculo — `rotuloDeQuantidade`,
/// `MoneyFormatter.reais` e `posicaoDoMarcador` (LIST-07).
///
/// **Por que não `BoraListRow` nem `BoraExpandableRow`**: os dois desenham a
/// linha inteira por conta própria, com os slots fixos de §5 — título, valor,
/// caret — e não têm onde receber o ponto de editado, a micro-label e a barra.
/// A linha é composta aqui a partir dos **mesmos tokens** que eles usam
/// (`BoraSpacing.linhaLista`, `BoraTextStyles`, `BoraListCard.tamanhoDoEmoji`)
/// e reusa os glifos de caret de [BoraExpandableRow], para o acordeão desta
/// tela e o de §5 não divergirem no primeiro ajuste.
class LinhaDeItem extends StatelessWidget {
  const LinhaDeItem({
    required this.item,
    this.leitura,
    this.aberta = false,
    this.onAlternar,
    super.key,
  });

  /// RN-12: "Item editado ganha ponto vermelho 8px ao lado do nome".
  static const double ladoDoPontoDeEditado = 8;

  /// A leitura de mercado de [chave], ou `null` quando RN-11 não a cobre.
  static PrecoDeMercado? leituraDeMercadoDe(ChaveItem chave) =>
      _leituraPorChave[chave];

  /// O item **já calculado**, com override aplicado quando existe.
  final ItemDeLista item;

  /// A linha de RN-11 deste item, quando existe.
  ///
  /// Recebida em vez de resolvida aqui dentro para que quem monta a linha
  /// escolha a leitura — é o que torna verificável o caso de faixa degenerada
  /// (`máximo == mínimo`), que a tabela curada não contém.
  final PrecoDeMercado? leitura;

  /// Se o painel de ajuste desta linha está aberto — muda só o caret.
  final bool aberta;

  /// `null` ⇒ a linha não expande e **não** exibe caret: é o caso dos quatro
  /// essenciais de RN-10, que a calculadora reconstrói a cada cálculo e aos
  /// quais override nenhum se aplica.
  final VoidCallback? onAlternar;

  /// O vão horizontal entre os blocos da linha — o mesmo ritmo de §5.
  static double get _vao => BoraListCard.vaoDoEmoji;

  @override
  Widget build(BuildContext context) {
    final leitura = this.leitura;
    final quantidade = rotuloDeQuantidade(item.quantidade, item.unidade);

    return GestureDetector(
      // O alvo é a linha inteira, não só o texto (§5).
      behavior: HitTestBehavior.opaque,
      onTap: onAlternar,
      child: Padding(
        padding: BoraSpacing.linhaLista,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.emoji,
                  style: BoraTextStyles.linhaLista.copyWith(
                    fontSize: BoraListCard.tamanhoDoEmoji,
                  ),
                ),
                SizedBox(width: _vao),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              item.nome,
                              style: BoraTextStyles.linhaLista,
                            ),
                          ),
                          if (item.editado) ...[
                            SizedBox(width: BoraSpacing.tag.left),
                            const _PontoDeEditado(),
                          ],
                        ],
                      ),
                      Text(
                        leitura == null
                            ? quantidade
                            : ListaTextos.mediaDeMercados(
                                quantidade,
                                leitura.fontes,
                              ),
                        style: BoraTextStyles.sublinhaLista,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: _vao),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      MoneyFormatter.reais(item.valor),
                      style: BoraTextStyles.linhaLista,
                    ),
                    if (leitura != null)
                      Text(
                        ListaTextos.media,
                        style: BoraTextStyles.microTag.copyWith(
                          color: BoraColors.primary,
                        ),
                      ),
                  ],
                ),
                if (onAlternar != null) ...[
                  SizedBox(width: BoraSpacing.tag.left),
                  Text(
                    aberta
                        ? BoraExpandableRow.caretAberto
                        : BoraExpandableRow.caretFechado,
                    style: BoraTextStyles.linhaLista,
                  ),
                ],
              ],
            ),
            if (leitura != null) ...[
              SizedBox(height: BoraSpacing.tag.top),
              BoraPriceRangeBar(
                fracao: posicaoDoMarcador(leitura),
                rotuloMin: MoneyFormatter.reais(leitura.minimo),
                rotuloMax: MoneyFormatter.reais(leitura.maximo),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// O ponto vermelho de 8px de RN-12 — o único sinal de que o item foi editado.
///
/// Círculo: é a exceção que §3 abre para dots, ao lado dos avatares.
class _PontoDeEditado extends StatelessWidget {
  const _PontoDeEditado();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LinhaDeItem.ladoDoPontoDeEditado,
      height: LinhaDeItem.ladoDoPontoDeEditado,
      decoration: const BoxDecoration(
        color: BoraColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }
}
