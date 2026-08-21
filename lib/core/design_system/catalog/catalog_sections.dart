import 'package:flutter/widgets.dart';

import '../components/bora_list_card.dart';
import '../components/bora_press_sink.dart';
import '../components/bora_primary_button.dart';
import '../components/bora_secondary_button.dart';
import '../components/bora_segmented_control.dart';
import '../components/bora_selection_chip.dart';
import '../components/bora_stepper.dart';
import '../components/bora_surface.dart';
import '../components/bora_text_field.dart';
import '../components/bora_toast.dart';
import '../components/bora_toast_texts.dart';
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
  (
    titulo: 'AFUNDAMENTO DO CTA',
    referencia: '§4 · hover/press',
    builder: _construirAfundamento,
  ),
  (
    titulo: 'TOAST',
    referencia: '§5 · Toast · RN-29',
    builder: _construirToast,
  ),
  (
    titulo: 'BOTÕES',
    referencia: '§5 · botão primário e secundário',
    builder: _construirBotoes,
  ),
  (
    titulo: 'CHIP DE SELEÇÃO',
    referencia: '§5 · chip de seleção · §6',
    builder: _construirChips,
  ),
  (
    titulo: 'SEGMENTED CONTROL',
    referencia: '§5 · segmented control',
    builder: _construirSegmented,
  ),
  (
    titulo: 'STEPPER',
    referencia: '§5 · stepper (− n +)',
    builder: _construirStepper,
  ),
  (
    titulo: 'INPUTS',
    referencia: '§5 · inputs',
    builder: _construirInputs,
  ),
  (
    titulo: 'CARD DE LISTA',
    referencia: '§5 · card de lista',
    builder: _construirCardDeLista,
  ),
];

/// Itens de festa nos dois estados de §5 — rótulo, emoji e se está marcado.
const List<(String, String, bool)> _itens = <(String, String, bool)>[
  ('carne bovina', '🥩', true),
  ('frango', '🍗', true),
  ('pão de alho', '🥖', false),
  ('cerveja', '🍺', false),
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

Widget _construirAfundamento(BuildContext context) {
  return Wrap(
    spacing: 24,
    runSpacing: 24,
    children: [
      BoraPressSink(
        acento: BoraAccent.primary,
        onPressed: () {},
        padding: BoraSpacing.botao,
        child: Text('TOQUE PARA AFUNDAR', style: BoraTextStyles.botao),
      ),
      BoraPressSink(
        acento: BoraAccent.primary,
        padding: BoraSpacing.botao,
        child: Text('DESABILITADO', style: BoraTextStyles.botao),
      ),
    ],
  );
}

Widget _construirToast(BuildContext context) {
  return Wrap(
    spacing: 16,
    runSpacing: 16,
    children: [
      for (final texto in BoraToastTexts.todos)
        BoraToastContent(texto: texto),
    ],
  );
}

Widget _construirBotoes(BuildContext context) {
  return Wrap(
    spacing: 24,
    runSpacing: 24,
    children: [
      BoraPrimaryButton(rotulo: 'bora marcar', onPressed: () {}),
      BoraPrimaryButton(
        rotulo: 'chamar a galera',
        acento: BoraAccent.purple,
        onPressed: () {},
      ),
      const BoraPrimaryButton(rotulo: 'sem ação'),
      BoraSecondaryButton(rotulo: 'agora não', onPressed: () {}),
      BoraSecondaryButton(
        rotulo: 'no branco',
        fundoBranco: true,
        onPressed: () {},
      ),
    ],
  );
}

Widget _construirChips(BuildContext context) {
  return Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      for (final item in _itens)
        BoraSelectionChip(
          rotulo: item.$1,
          emoji: item.$2,
          selecionado: item.$3,
        ),
    ],
  );
}

Widget _construirSegmented(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 300,
        child: BoraSegmentedControl(
          opcoes: const ['todos', 'quem paga', 'quem recebe'],
          indiceAtivo: 0,
          onSelecionar: (_) {},
        ),
      ),
      const SizedBox(height: 16),
      BoraSurface(
        fundo: BoraColors.ink,
        padding: BoraSpacing.chip,
        child: SizedBox(
          width: 300,
          child: BoraSegmentedControl(
            opcoes: const ['todos', 'quem paga', 'quem recebe'],
            indiceAtivo: 1,
            sobreCardEscuro: true,
            onSelecionar: (_) {},
          ),
        ),
      ),
    ],
  );
}

Widget _construirStepper(BuildContext context) {
  return Wrap(
    spacing: 32,
    runSpacing: 16,
    children: [
      BoraStepper(valor: 3, onDecrementar: () {}, onIncrementar: () {}),
      // No limite de baixo quem decide é a tela: o stepper só recebe o
      // callback nulo e esmaece o "−".
      BoraStepper(valor: 0, onIncrementar: () {}),
    ],
  );
}

Widget _construirInputs(BuildContext context) {
  return const Wrap(
    spacing: 16,
    runSpacing: 16,
    children: [
      // Os dois literais de §5, em minúsculas: o placeholder não é
      // transformado (A-06).
      _CampoDeCatalogo(placeholder: 'seu e-mail'),
      _CampoDeCatalogo(placeholder: 'senha'),
    ],
  );
}

/// Um input do catálogo, dono do próprio controlador.
///
/// O controlador precisa de vida e de `dispose`, e a seção é uma função —
/// por isso o campo vira widget.
class _CampoDeCatalogo extends StatefulWidget {
  const _CampoDeCatalogo({required this.placeholder});

  final String placeholder;

  @override
  State<_CampoDeCatalogo> createState() => _CampoDeCatalogoState();
}

class _CampoDeCatalogoState extends State<_CampoDeCatalogo> {
  final TextEditingController _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: BoraTextField(
        controller: _controlador,
        placeholder: widget.placeholder,
      ),
    );
  }
}

/// A largura em que os componentes de linha aparecem no catálogo: o `Wrap` e
/// o modo expandido dariam largura demais para uma lista de festa.
const double _larguraDeLista = 320;

Widget _construirCardDeLista(BuildContext context) {
  return const SizedBox(
    width: _larguraDeLista,
    child: BoraListCard(
      linhas: [
        BoraListRow(emoji: '🥩', titulo: 'carne bovina', valor: 'R\$ 96'),
        BoraListRow(
          emoji: '🍺',
          titulo: 'cerveja',
          sublinha: '12 latas',
          valor: 'R\$ 60',
        ),
        BoraListRow(emoji: '🥖', titulo: 'pão de alho', valor: 'R\$ 18'),
      ],
    ),
  );
}
