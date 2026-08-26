import 'package:flutter/material.dart';

import '../design_system/design_system.dart';

/// Destino provisório de uma rota do mapa de telas.
///
/// Existe para que a navegação inteira (FUND-07) responda antes de qualquer
/// tela de produto existir: cada spec de tela troca o corpo do arquivo da sua
/// feature sem tocar na tabela de rotas.
///
/// Revestido pela spec 04, cumprindo a segunda metade da AD-013: o arquivo 02
/// não desenha uma tela "em breve", então nada aqui é inventado além do
/// arranjo — fundo `paper`, título no papel de título de tela e o id na dica,
/// tudo por token. O mesmo critério do `RouteErrorPage`.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({required this.id, required this.titulo, super.key});

  /// Identificador estável da tela — `home`, `lista`, `convidado`, …
  final String id;

  /// Rótulo legível na tela.
  final String titulo;

  /// Chave que diz **qual** placeholder está montado.
  static Key keyFor(String id) => Key('placeholder:$id');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: keyFor(id),
      backgroundColor: BoraColors.paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // O título sai **como veio**. Caixa alta é lei de §7 para copy, e
            // a tabela de rotas já passa a copy em caixa alta — mas o título
            // do convidado interpola o código do convite (`CONVIDADO ·
            // rafa18`), que é dado de URL (RN-24) e não copy. Um
            // `toUpperCase()` aqui viraria `RAFA18` e mentiria sobre o link.
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: BoraTextStyles.tituloTela,
            ),
            const SizedBox(height: 8),
            Text(id, textAlign: TextAlign.center, style: BoraTextStyles.dica),
          ],
        ),
      ),
    );
  }
}
