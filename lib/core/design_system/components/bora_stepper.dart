import 'package:flutter/widgets.dart';

import '../tokens/bora_borders.dart';
import '../tokens/bora_colors.dart';
import '../tokens/bora_motion.dart';
import '../tokens/bora_text_styles.dart';
import 'bora_surface.dart';

/// O stepper `− n +` de §5: "Botões 34×34: '−' branco borda `ink`; '+' fundo
/// `ink` texto `cream` (hover `#FF4D2E`). Valor central 800 17px.
/// *(Implementação real: garantir alvo de toque ≥44px via padding.)*"
///
/// **Não faz conta.** Os dois callbacks são `VoidCallback` sem payload: o
/// stepper emite a intenção e o valor exibido é sempre [valor], a propriedade
/// recebida. Mínimo, máximo, passo e o `valor + 1` são de RN-12, que mora em
/// `core/calculo` — fórmula em componente de UI é o que o `CLAUDE.md` proíbe
/// (DS-34).
class BoraStepper extends StatelessWidget {
  const BoraStepper({
    required this.valor,
    this.onDecrementar,
    this.onIncrementar,
    super.key,
  });

  /// §5, "Stepper (− n +)": o sinal de menos é o `−` matemático (U+2212), não
  /// o hífen. Constante para que a tela e o teste digitem o mesmo caractere.
  static const String simboloMenos = '−';

  /// O `+` de §5.
  static const String simboloMais = '+';

  /// §5: "Botões 34×34".
  static const double ladoDoBotao = 34;

  /// O alvo de toque mínimo. §5: "garantir alvo de toque ≥44px via padding".
  static const double alvoDeToque = 44;

  /// A folga que o padding acrescenta de cada lado para o botão de
  /// [ladoDoBotao] alcançar o [alvoDeToque] — não é número novo, é a conta
  /// entre os dois números de §5.
  static const double _folgaDeToque = (alvoDeToque - ladoDoBotao) / 2;

  /// O valor exibido. Vem pronto: o stepper nunca o recalcula.
  final int valor;

  /// `null` ⇒ o `−` fica em `opacity .7` (A-07) e não emite nada.
  final VoidCallback? onDecrementar;

  /// `null` ⇒ o `+` fica em `opacity .7` (A-07) e não emite nada.
  final VoidCallback? onIncrementar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _BotaoDoStepper(
          simbolo: simboloMenos,
          fundo: BoraColors.white,
          corDoSimbolo: BoraColors.ink,
          onPressed: onDecrementar,
        ),
        Text('$valor', style: BoraTextStyles.stepperValor),
        _BotaoDoStepper(
          simbolo: simboloMais,
          fundo: BoraColors.ink,
          fundoNoHover: BoraColors.primary,
          corDoSimbolo: BoraColors.cream,
          onPressed: onIncrementar,
        ),
      ],
    );
  }
}

/// Um dos dois botões de §5: quadrado de 34, alvo de toque de 44.
class _BotaoDoStepper extends StatefulWidget {
  const _BotaoDoStepper({
    required this.simbolo,
    required this.fundo,
    required this.corDoSimbolo,
    required this.onPressed,
    this.fundoNoHover,
  });

  final String simbolo;
  final Color fundo;
  final Color corDoSimbolo;

  /// §5 dá hover só ao `+`: "(hover `#FF4D2E`)".
  final Color? fundoNoHover;

  final VoidCallback? onPressed;

  @override
  State<_BotaoDoStepper> createState() => _BotaoDoStepperState();
}

class _BotaoDoStepperState extends State<_BotaoDoStepper> {
  bool _sobHover = false;

  bool get _habilitado => widget.onPressed != null;

  void _pairar(bool valor) {
    if (!_habilitado || _sobHover == valor) return;
    setState(() => _sobHover = valor);
  }

  @override
  Widget build(BuildContext context) {
    final fundo = (_sobHover ? widget.fundoNoHover : null) ?? widget.fundo;

    final Widget botao = MouseRegion(
      onEnter: (_) => _pairar(true),
      onExit: (_) => _pairar(false),
      child: GestureDetector(
        // O alvo de toque é a folga inteira, não só o quadrado pintado.
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.all(BoraStepper._folgaDeToque),
          child: AnimatedContainer(
            duration: BoraMotion.estado,
            curve: BoraMotion.curva,
            width: BoraStepper.ladoDoBotao,
            height: BoraStepper.ladoDoBotao,
            alignment: Alignment.center,
            decoration: BoraSurface.decoracaoDe(fundo: fundo),
            child: Text(
              widget.simbolo,
              style: BoraTextStyles.stepperValor.copyWith(
                color: widget.corDoSimbolo,
              ),
            ),
          ),
        ),
      ),
    );

    if (_habilitado) {
      return botao;
    }
    return Opacity(
      opacity: BoraBorders.opacidadeDesabilitado,
      child: botao,
    );
  }
}
