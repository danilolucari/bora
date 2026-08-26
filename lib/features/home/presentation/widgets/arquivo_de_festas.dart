import 'package:flutter/material.dart';

import '../../../../core/calculo/calculo.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/resumo_de_festa.dart';
import '../home_textos.dart';

/// A seção "ARQUIVO" de W-02 — o histórico de UC-24.
///
/// Uma linha por festa concluída: emoji · nome + "· N pessoas" · o total em
/// vermelho à direita. É **informação, não ação**: tocar numa linha não navega
/// (A-12), porque nenhuma spec desenha o destino.
///
/// Só existe em expandido (A-11): T-02 conta as passadas no subtítulo e não
/// desenha a lista.
class ArquivoDeFestas extends StatelessWidget {
  const ArquivoDeFestas({required this.passadas, super.key});

  /// A copy literal de W-02.
  static const String titulo = 'ARQUIVO';

  /// SPEC_PRECISION_GAP: W-02 abre cada linha com um emoji e não diz de onde
  /// ele vem. No M1 toda festa é churrasco — "🎈 NIVER" é "EM BREVE" e não é
  /// clicável —, então o emoji é constante da linha, e não dado. Quando existir
  /// tipo de festa, ele vira campo.
  static const String emoji = '🔥';

  final List<ResumoDeFesta> passadas;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(titulo, style: BoraTextStyles.labelSecao),
        const SizedBox(height: 10),
        BoraSurface(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final passada in passadas)
                _LinhaDoArquivo(resumo: passada),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinhaDoArquivo extends StatelessWidget {
  const _LinhaDoArquivo({required this.resumo});

  final ResumoDeFesta resumo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: BoraSpacing.linhaLista,
      child: Row(
        children: [
          const Text(ArquivoDeFestas.emoji),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              // A contagem só entra quando existe. `pessoas` é anulável, e
              // interpolar direto escrevia "null pessoas" na tela; um `?? 0`
              // seria pior, porque transformaria dado faltando num zero
              // plausível.
              [
                resumo.festa.nome,
                if (resumo.pessoas != null)
                  HomeTextos.contagem(resumo.pessoas!, 'pessoa'),
              ].join(' · '),
              style: BoraTextStyles.linhaLista,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          if (resumo.total != null)
            Text(
              // RN-13 vem inteira de `core/calculo`: a UI nunca formata
              // dinheiro por conta própria, e nenhum componente conhece a
              // regra de arredondamento.
              MoneyFormatter.reais(resumo.total!),
              style: BoraTextStyles.linhaLista.copyWith(
                color: BoraColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
