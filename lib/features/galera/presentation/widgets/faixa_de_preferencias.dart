import 'package:flutter/widgets.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../galera_textos.dart';

/// A faixa amarela de T-05: "faixa amarela borda 2px: '💡 A lista já se ajusta
/// às preferências: {resumo RN-21}'".
///
/// **A frase inteira vem da camada de cálculo** (GAL-13 AC5, GAL-15): a faixa
/// chama `efeitosDasPreferencias` e `resumoDasPreferencias`, e a feature
/// concatena `'💡 '` e **nada mais**. Nenhum termo é montado aqui, nenhum
/// plural é corrigido aqui, e a omissão de termo zerado é de RN-21 — não da
/// tela.
///
/// **Derivada, nunca guardada**: a faixa recebe a [composicao] e recalcula a
/// leitura a cada `build`. Guardar a string faria a faixa envelhecer em
/// silêncio na primeira preferência que mudasse.
///
/// **Não é `BoraDashedNote`**: o componente de §3 é tracejado e branco, e T-05
/// pede faixa amarela de borda 2px. É [BoraSurface] com o amarelo do token.
class FaixaDePreferencias extends StatelessWidget {
  const FaixaDePreferencias({required this.composicao, super.key});

  /// T-05: "borda 2px" — a mesma espessura padrão de §3, nomeada aqui para o
  /// número não virar literal solto.
  static const double espessuraDaBorda = 2;

  /// O registro da festa. `pessoas` traz as preferências declaradas e
  /// `contagem.adultos` é a base de RN-05 que RN-21 ajusta.
  final ComposicaoDaFesta composicao;

  /// O texto da faixa, ou vazio quando não há termo algum a dizer.
  String get texto => GaleraTextos.faixa(
        resumoDasPreferencias(
          efeitosDasPreferencias(
            pessoas: composicao.pessoas,
            adultos: composicao.contagem.adultos,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final texto = this.texto;

    // GAL-13 AC7: nenhum termo maior que zero ⇒ a faixa não renderiza. Uma
    // faixa vazia seria uma promessa de ajuste que não aconteceu.
    if (texto.isEmpty) return const SizedBox.shrink();

    return BoraSurface(
      fundo: BoraColors.yellow,
      larguraDaBorda: espessuraDaBorda,
      padding: BoraSpacing.linhaLista,
      child: Text(
        texto,
        // §1 fixa `ink` como o texto principal; sobre o amarelo, o `text-2`
        // do papel "dica" perderia contraste.
        style: BoraTextStyles.dica.copyWith(color: BoraColors.ink),
      ),
    );
  }
}
