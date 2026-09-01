import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../bloc/montar_event.dart';
import '../montar_textos.dart';

/// O card "CONFIRMADOS + EXTRAS SEM APP" de T-03 — as três linhas de stepper
/// (MONT-01, MONT-02, MONT-14).
///
/// **Não guarda contagem.** O valor exibido é sempre o de [contagem], que vem
/// do `MontarBloc`; o card só emite a intenção por [aoAlterar]. Um contador
/// próprio aqui viraria uma segunda verdade, e a tela mostraria um número
/// enquanto a conta usa outro.
///
/// O piso de 0 de UC-03 E1 é expresso do jeito que o design system já resolve:
/// no zero o `−` daquela linha recebe `onDecrementar: null`, e o
/// [BoraStepper] o deixa em `opacidadeDesabilitado` sem emitir nada. A guarda
/// **é** o `null` — não há um `if` paralelo dentro do callback.
class CardDeContagem extends StatelessWidget {
  const CardDeContagem({
    required this.contagem,
    required this.aoAlterar,
    super.key,
  });

  /// As três linhas, **na ordem de T-03**: homens, mulheres, crianças.
  static const List<TipoDeCabeca> linhas = [
    TipoDeCabeca.homens,
    TipoDeCabeca.mulheres,
    TipoDeCabeca.criancas,
  ];

  /// O piso de UC-03 E1: no zero o decremento fica inerte.
  static const int piso = 0;

  final ContagemDePessoas contagem;

  /// Emitido com o tipo da linha e o passo (`1` ou `-1`). Nenhuma spec define
  /// auto-repeat, então o passo é sempre de uma cabeça por acionamento.
  final void Function(TipoDeCabeca tipo, int delta) aoAlterar;

  /// Quantas cabeças [tipo] tem agora, lidas de [contagem].
  int valorDe(TipoDeCabeca tipo) => switch (tipo) {
        TipoDeCabeca.homens => contagem.homens,
        TipoDeCabeca.mulheres => contagem.mulheres,
        TipoDeCabeca.criancas => contagem.criancas,
      };

  /// O rótulo literal de [tipo] em T-03, emoji incluído.
  static String rotuloDe(TipoDeCabeca tipo) => switch (tipo) {
        TipoDeCabeca.homens => MontarTextos.homens,
        TipoDeCabeca.mulheres => MontarTextos.mulheres,
        TipoDeCabeca.criancas => MontarTextos.criancas,
      };

  @override
  Widget build(BuildContext context) {
    return BoraSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var indice = 0; indice < linhas.length; indice++) ...[
            // O mesmo divisor entre linhas do card de lista de §5: com três
            // linhas há dois divisores, e nenhum acima da primeira.
            if (indice > 0)
              const SizedBox(
                height: BoraListCard.espessuraDoDivisor,
                child: ColoredBox(color: BoraColors.divider),
              ),
            _LinhaDeContagem(
              tipo: linhas[indice],
              valor: valorDe(linhas[indice]),
              aoAlterar: aoAlterar,
            ),
          ],
        ],
      ),
    );
  }
}

/// Uma linha do card: o rótulo à esquerda, o stepper à direita.
class _LinhaDeContagem extends StatelessWidget {
  const _LinhaDeContagem({
    required this.tipo,
    required this.valor,
    required this.aoAlterar,
  });

  final TipoDeCabeca tipo;
  final int valor;
  final void Function(TipoDeCabeca tipo, int delta) aoAlterar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: BoraSpacing.linhaLista,
      child: Row(
        children: [
          Expanded(
            child: Text(
              CardDeContagem.rotuloDe(tipo),
              style: BoraTextStyles.linhaLista,
            ),
          ),
          BoraStepper(
            valor: valor,
            // UC-03 E1: no piso o `−` não existe como ação.
            onDecrementar:
                valor == CardDeContagem.piso ? null : () => aoAlterar(tipo, -1),
            onIncrementar: () => aoAlterar(tipo, 1),
          ),
        ],
      ),
    );
  }
}
