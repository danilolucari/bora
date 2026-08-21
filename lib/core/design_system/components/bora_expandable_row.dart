import 'package:flutter/widgets.dart';

import '../tokens/bora_colors.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';

/// Uma linha do [BoraExpandableGroup]: o título que aparece fechada e o
/// painel que ela abre.
typedef BoraExpandableItem = ({String titulo, Widget painel});

/// A linha expansível de §5: "Caret `▾` fechado / `▴` aberto; painel aberto
/// com fundo `paper` e `border-top 2px`".
///
/// A linha é **controlada**: ela não guarda se está aberta. Quem guarda é o
/// [BoraExpandableGroup], porque a regra de §5 — "Só 1 aberta por vez (abrir
/// fecha a anterior)" — é uma regra entre irmãs, e uma linha sozinha não teria
/// como cumpri-la.
class BoraExpandableRow extends StatelessWidget {
  const BoraExpandableRow({
    required this.titulo,
    required this.aberta,
    required this.onAlternar,
    required this.painel,
    super.key,
  });

  /// §5: o caret da linha fechada. O glifo é literal — é o que o protótipo
  /// desenha, e é o que o teste procura.
  static const String caretFechado = '▾';

  /// §5: o caret da linha aberta.
  static const String caretAberto = '▴';

  /// §5: "painel aberto com fundo `paper` e `border-top 2px`". §5 não dá cor
  /// a essa borda: fica a padrão de §3, `2px solid #141414`.
  static const double espessuraDaBordaDoPainel = 2;

  /// O nome da linha, no papel "Nome/linha de lista" de §2.
  final String titulo;

  /// Se o painel está à mostra. É propriedade, não estado.
  final bool aberta;

  /// Emitido quando a cabeça da linha é tocada — abrir e fechar são a mesma
  /// intenção; quem decide o que ela significa é o grupo.
  final VoidCallback onAlternar;

  /// O conteúdo que aparece quando [aberta]. Fechada, ele **não** é montado.
  final Widget painel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          // O alvo é a linha inteira, não só o texto.
          behavior: HitTestBehavior.opaque,
          onTap: onAlternar,
          child: Padding(
            padding: BoraSpacing.linhaLista,
            child: Row(
              children: [
                Expanded(
                  child: Text(titulo, style: BoraTextStyles.linhaLista),
                ),
                Text(
                  aberta ? caretAberto : caretFechado,
                  style: BoraTextStyles.linhaLista,
                ),
              ],
            ),
          ),
        ),
        if (aberta)
          DecoratedBox(
            decoration: const BoxDecoration(
              color: BoraColors.paper,
              border: Border(
                top: BorderSide(
                  color: BoraColors.ink,
                  width: espessuraDaBordaDoPainel,
                ),
              ),
            ),
            child: Padding(padding: BoraSpacing.linhaLista, child: painel),
          ),
      ],
    );
  }
}

/// O grupo de linhas expansíveis de §5: "Só 1 aberta por vez (abrir fecha a
/// anterior)".
///
/// O grupo é o dono do estado — guarda **qual** linha está aberta, e não um
/// booleano por linha: é essa forma que torna "duas abertas" um estado
/// impossível de representar, em vez de um estado a evitar.
class BoraExpandableGroup extends StatefulWidget {
  const BoraExpandableGroup({required this.linhas, super.key});

  final List<BoraExpandableItem> linhas;

  @override
  State<BoraExpandableGroup> createState() => _BoraExpandableGroupState();
}

class _BoraExpandableGroupState extends State<BoraExpandableGroup> {
  /// O índice da linha aberta. `null` ⇒ nenhuma — e é assim que o grupo
  /// começa.
  int? _abertaEm;

  void _alternar(int indice) {
    setState(() => _abertaEm = _abertaEm == indice ? null : indice);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var indice = 0; indice < widget.linhas.length; indice++)
          BoraExpandableRow(
            titulo: widget.linhas[indice].titulo,
            painel: widget.linhas[indice].painel,
            aberta: _abertaEm == indice,
            onAlternar: () => _alternar(indice),
          ),
      ],
    );
  }
}
