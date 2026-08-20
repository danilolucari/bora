import 'package:flutter/material.dart';

/// Destino provisório de uma rota do mapa de telas.
///
/// Existe para que a navegação inteira (FUND-07) responda antes de qualquer
/// tela de produto existir: cada spec de tela troca o corpo do arquivo da sua
/// feature sem tocar na tabela de rotas.
///
/// Sem cor, fonte, sombra ou espaçamento próprios — revestir é território da
/// spec 01 `design-system`.
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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text(titulo), Text(id)],
        ),
      ),
    );
  }
}
