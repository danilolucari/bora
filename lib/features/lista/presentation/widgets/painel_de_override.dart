import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../lista_textos.dart';

/// O painel que abre dentro da linha, com os dois steppers de RN-12 —
/// LIST-11.
///
/// "QUANTIDADE" e "PREÇO", cada um com o valor **já formatado** pela camada de
/// cálculo (`rotuloDeQuantidade` e `MoneyFormatter.reais`) e os dois botões de
/// §5. O widget **não calcula o novo valor**: ele emite `+1` ou `-1` passo, e
/// quem aplica o passo — e o piso — é `comPassoDeQuantidade` /
/// `comPassoDePreco`, em `core/calculo`.
///
/// **O piso de RN-12 não é um `if` daqui.** Quem responde "já está no piso?" é
/// a própria regra: um passo para baixo que devolve o mesmo valor **é** o
/// piso, e então o decremento vira `null` — inerte, em `opacity .7`, sem
/// emitir nada. Nenhum número de piso é redigitado nesta camada.
///
// SPEC_DEVIATION: `tasks.md` T14 manda reusar `BoraStepper`, e este painel
// compõe os dois botões a partir dos tokens dele em vez de montá-lo.
// Reason: `BoraStepper` recebe `int valor` e desenha `'$valor'`, e os valores
// desta tela são `double` — 1,2 kg e o preço em reais. Converter `double` para
// `int` aqui exigiria `.round(` ou `.toInt(`, que o guard de LIST-07 proíbe na
// feature, e exibir o inteiro cru quebraria o próprio critério da task ("o
// valor exibido vem de `MoneyFormatter` / `rotuloDeQuantidade`"). A composição
// usa os **mesmos** tokens de §5 que o componente usa — símbolos, lado do
// botão, alvo de toque, decoração e opacidade de desabilitado —, no mesmo
// precedente que §7.6 abre para o checkbox 26×26 (A-13). Nenhum número novo
// entra no sistema.
class PainelDeOverride extends StatelessWidget {
  const PainelDeOverride({
    required this.item,
    required this.aoAjustarQuantidade,
    required this.aoAjustarPreco,
    super.key,
  });

  /// O item **já calculado**, com o override aplicado quando existe.
  final ItemDeLista item;

  /// Emite `+1` ou `-1` passo de quantidade — nunca o valor novo.
  final void Function(int passos) aoAjustarQuantidade;

  /// Emite `+1` ou `-1` passo de preço.
  final void Function(int passos) aoAjustarPreco;

  /// `true` quando um passo para baixo devolveria a **mesma** quantidade — o
  /// piso de RN-12, respondido pela regra e não por um limite escrito aqui.
  bool get noPisoDeQuantidade =>
      comPassoDeQuantidade(item, -1).quantidade == item.quantidade;

  /// `true` quando um passo para baixo devolveria o **mesmo** preço.
  bool get noPisoDePreco => comPassoDePreco(item, -1).preco == item.preco;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // §5, linha expansível: "painel aberto com fundo `paper` e
      // `border-top 2px`".
      decoration: const BoxDecoration(
        color: BoraColors.paper,
        border: Border(
          top: BorderSide(
            color: BoraColors.ink,
            width: BoraExpandableRow.espessuraDaBordaDoPainel,
          ),
        ),
      ),
      child: Padding(
        padding: BoraSpacing.linhaLista,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EixoDeAjuste(
              rotulo: ListaTextos.quantidade,
              valorFormatado: rotuloDeQuantidade(item.quantidade, item.unidade),
              onDecrementar:
                  noPisoDeQuantidade ? null : () => aoAjustarQuantidade(-1),
              onIncrementar: () => aoAjustarQuantidade(1),
            ),
            SizedBox(height: BoraSpacing.tag.top),
            _EixoDeAjuste(
              rotulo: ListaTextos.preco,
              valorFormatado: MoneyFormatter.reais(item.preco),
              onDecrementar: noPisoDePreco ? null : () => aoAjustarPreco(-1),
              onIncrementar: () => aoAjustarPreco(1),
            ),
          ],
        ),
      ),
    );
  }
}

/// Um dos dois eixos do painel: o rótulo e o stepper `− valor +` de §5.
class _EixoDeAjuste extends StatelessWidget {
  const _EixoDeAjuste({
    required this.rotulo,
    required this.valorFormatado,
    required this.onDecrementar,
    required this.onIncrementar,
  });

  final String rotulo;
  final String valorFormatado;
  final VoidCallback? onDecrementar;
  final VoidCallback? onIncrementar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(rotulo, style: BoraTextStyles.labelSecao)),
        BotaoDePasso(
          simbolo: BoraStepper.simboloMenos,
          fundo: BoraColors.white,
          corDoSimbolo: BoraColors.ink,
          onPressed: onDecrementar,
        ),
        Text(valorFormatado, style: BoraTextStyles.stepperValor),
        BotaoDePasso(
          simbolo: BoraStepper.simboloMais,
          fundo: BoraColors.ink,
          corDoSimbolo: BoraColors.cream,
          onPressed: onIncrementar,
        ),
      ],
    );
  }
}

/// Um dos dois botões do stepper de §5: quadrado de 34, alvo de toque de 44.
///
/// `onPressed` nulo **é** o piso de RN-12: o botão fica em
/// `opacidadeDesabilitado` e o toque não emite nada. Público para que o teste
/// possa afirmar a guarda pelo próprio contrato, e não só pelo efeito.
class BotaoDePasso extends StatelessWidget {
  const BotaoDePasso({
    required this.simbolo,
    required this.fundo,
    required this.corDoSimbolo,
    required this.onPressed,
    super.key,
  });

  /// O glifo, sempre um dos dois de [BoraStepper].
  final String simbolo;

  final Color fundo;
  final Color corDoSimbolo;

  /// `null` ⇒ inerte.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Widget botao = GestureDetector(
      // O alvo de toque é a folga inteira, não só o quadrado pintado (§5).
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        width: BoraStepper.alvoDeToque,
        height: BoraStepper.alvoDeToque,
        child: Center(
          child: Container(
            width: BoraStepper.ladoDoBotao,
            height: BoraStepper.ladoDoBotao,
            alignment: Alignment.center,
            decoration: BoraSurface.decoracaoDe(fundo: fundo),
            child: Text(
              simbolo,
              style: BoraTextStyles.stepperValor.copyWith(color: corDoSimbolo),
            ),
          ),
        ),
      ),
    );

    if (onPressed != null) {
      return botao;
    }
    return Opacity(opacity: BoraBorders.opacidadeDesabilitado, child: botao);
  }
}
