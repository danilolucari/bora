import 'package:flutter/widgets.dart';

import '../components/bora_surface.dart';
import '../tokens/bora_accent.dart';
import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_shadows.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';

/// Uma seção do catálogo: o título, o trecho do arquivo 02 que ela prova e
/// como ela se desenha.
typedef BoraCatalogSection = ({
  String titulo,
  String referencia,
  WidgetBuilder builder,
});

/// O registro das seções do catálogo (DS-33).
///
/// Cada task de componente acrescenta **uma** linha aqui: é o que impede um
/// componente de ficar pronto sem lugar onde ser conferido a olho contra o
/// arquivo 02. É esta lista que o teste de completude percorre.
const List<BoraCatalogSection> secoes = <BoraCatalogSection>[
  (
    titulo: 'TOKENS',
    referencia: '§1 · §2 · §4',
    builder: _construirTokens,
  ),
  (
    titulo: 'SUPERFÍCIE',
    referencia: '§3 · §4 · superfície comum',
    builder: _construirSuperficie,
  ),
];

/// As cores de §1, na ordem em que a tabela as declara.
const Map<String, Color> _cores = <String, Color>{
  'paper': BoraColors.paper,
  'ink': BoraColors.ink,
  'primary': BoraColors.primary,
  'yellow': BoraColors.yellow,
  'purple': BoraColors.purple,
  'green': BoraColors.green,
  'waGreen': BoraColors.waGreen,
  'white': BoraColors.white,
};

/// Papéis de §2, cada um mostrado no próprio estilo.
const List<(String, TextStyle)> _tipos = <(String, TextStyle)>[
  ('tituloTela', BoraTextStyles.tituloTela),
  ('tituloCard', BoraTextStyles.tituloCard),
  ('linhaLista', BoraTextStyles.linhaLista),
  ('corpo', BoraTextStyles.corpo),
  ('microTag', BoraTextStyles.microTag),
];

/// Sombras duras de §4, com a distância que a tabela declara.
final List<(String, BoxShadow)> _sombras = <(String, BoxShadow)>[
  ('cardLink 5px', BoraShadows.cardLink),
  ('cardBranco 6px', BoraShadows.cardBranco),
  ('cardHeroi 6px', BoraShadows.cardHeroi),
];

Widget _construirTokens(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const _Subtitulo('CORES · §1'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final cor in _cores.entries)
            _AmostraDeCor(nome: cor.key, cor: cor.value),
        ],
      ),
      const _Subtitulo('TIPOGRAFIA · §2'),
      for (final tipo in _tipos)
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(tipo.$1.toUpperCase(), style: tipo.$2),
        ),
      const _Subtitulo('SOMBRAS · §4'),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final sombra in _sombras)
            _AmostraDeSombra(nome: sombra.$1, sombra: sombra.$2),
        ],
      ),
    ],
  );
}

class _Subtitulo extends StatelessWidget {
  const _Subtitulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(texto, style: BoraTextStyles.labelSecao),
    );
  }
}

class _AmostraDeCor extends StatelessWidget {
  const _AmostraDeCor({required this.nome, required this.cor});

  final String nome;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 40,
          decoration: BoxDecoration(
            color: cor,
            border: BoraBorders.padraoInk,
            borderRadius: BoraBorders.raio,
          ),
        ),
        Text(nome, style: BoraTextStyles.microTag),
      ],
    );
  }
}

class _AmostraDeSombra extends StatelessWidget {
  const _AmostraDeSombra({required this.nome, required this.sombra});

  final String nome;
  final BoxShadow sombra;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: BoraSpacing.chip,
      decoration: BoxDecoration(
        color: BoraColors.white,
        border: BoraBorders.padraoInk,
        borderRadius: BoraBorders.raio,
        boxShadow: [sombra],
      ),
      child: Text(nome, style: BoraTextStyles.microTag),
    );
  }
}

Widget _construirSuperficie(BuildContext context) {
  return Wrap(
    spacing: 24,
    runSpacing: 24,
    children: [
      BoraSurface(
        padding: BoraSpacing.chip,
        child: Text('SEM SOMBRA', style: BoraTextStyles.microTag),
      ),
      BoraSurface(
        acento: BoraAccent.primary,
        padding: BoraSpacing.chip,
        child: Text('4px NO PRIMARY', style: BoraTextStyles.microTag),
      ),
      BoraSurface(
        acento: BoraAccent.purple,
        deslocamentoDaSombra: 5,
        padding: BoraSpacing.chip,
        child: Text('5px NO PURPLE', style: BoraTextStyles.microTag),
      ),
    ],
  );
}
