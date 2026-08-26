import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

/// A seção "COMEÇAR OUTRA" de T-02 e da coluna direita de W-02.
///
/// Dois cards em grid de duas colunas: churrasco, que leva a Montar, e níver,
/// que é um **slot vazio** — tracejado, esmaecido e explicitamente inerte. O
/// aceite de UC-02 cobra os dois lados: "NIVER · EM BREVE" não é clicável.
class ComecarOutra extends StatelessWidget {
  const ComecarOutra({required this.aoComecarChurrasco, super.key});

  /// A copy literal de T-02.
  static const String titulo = 'COMEÇAR OUTRA';
  static const String churrasco = '🔥 CHURRASCO';
  static const String niver = '🎈 NIVER · EM BREVE';

  /// O vão entre as duas colunas do grid.
  static const double vaoDoGrid = 12;

  final VoidCallback aoComecarChurrasco;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(titulo, style: BoraTextStyles.labelSecao),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BoraPressSink(
                  acento: BoraAccent.primary,
                  padding: BoraSpacing.botao,
                  onPressed: aoComecarChurrasco,
                  child: Center(
                    child: Text(
                      churrasco,
                      textAlign: TextAlign.center,
                      style: BoraTextStyles.botao,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: vaoDoGrid),
              Expanded(
                // `BoraEmptySlot`, e não um botão desabilitado: §3 dá ao slot
                // vazio o tracejado e o `opacity .7`, e a diferença é de
                // significado — "EM BREVE" não é uma ação bloqueada, é uma
                // ação que ainda não existe. E slot não recebe toque nenhum:
                // sem `onPressed`, sem `GestureDetector`, sem toast.
                child: BoraEmptySlot(
                  child: Center(
                    child: Text(
                      niver,
                      textAlign: TextAlign.center,
                      style: BoraTextStyles.botao,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
