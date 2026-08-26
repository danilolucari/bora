import 'package:flutter/widgets.dart';

import '../tokens/bora_colors.dart';
import '../tokens/bora_text_styles.dart';

/// O logo "BORA." com o ponto vermelho, nos três tamanhos em que o produto o
/// usa.
///
/// Nasceu em `features/entrar/` porque o arquivo 02 define o logo como **papel
/// tipográfico** ([BoraTextStyles.logoHero]), não como componente — e enquanto
/// teve um uso só, morar na feature era o certo. O header de app do arquivo
/// `06` é o segundo uso real, e o próprio doc do original marcava este momento
/// como o da promoção.
///
/// O ponto é o único acento: "BORA" fica em `ink` e o `.` em `primary`.
class BoraMarca extends StatelessWidget {
  /// O logo de T-01: 64px, o tamanho que o arquivo 02 declara para o papel.
  const BoraMarca.compacta({super.key})
      : _tamanho = tamanhoCompacto,
        _espacamento = _espacamentoCompacto;

  /// O logo de W-01: 92px, ls −3px.
  ///
  /// Os dois números vêm do **arquivo 06**, não do 02 — é o "tipografia sobe
  /// um degrau" que a spec web declara como adaptação de tela. O design system
  /// é dono do papel; a spec de tela é dona do degrau responsivo.
  const BoraMarca.expandida({super.key})
      : _tamanho = tamanhoExpandido,
        _espacamento = _espacamentoExpandido;

  /// O logo do header de app: 20px (arquivo `06` §Header de app).
  const BoraMarca.header({super.key})
      : _tamanho = tamanhoHeader,
        _espacamento = espacamentoHeader;

  /// Tamanho do logo em T-01 (arquivo 02 §2).
  static const double tamanhoCompacto = 64;

  /// Tamanho do logo em W-01 (arquivo 06).
  static const double tamanhoExpandido = 92;

  /// Tamanho do logo no header de app (arquivo 06 §Header de app).
  static const double tamanhoHeader = 20;

  /// SPEC_PRECISION_GAP: `06` dá o **tamanho** do logo do header (20px) e não
  /// dá a letter-spacing. Adotado o valor do papel de §2 mais próximo em
  /// tamanho — `tituloTela` (22–24px, ls −0.5) —, em vez de um número
  /// inventado. Há teste amarrando os dois: se §2 mudar, isto quebra.
  static const double espacamentoHeader = -0.5;

  static const double _espacamentoCompacto = -2;
  static const double _espacamentoExpandido = -3;

  /// A copy literal — o ponto entra separado para receber o acento.
  static const String nome = 'BORA';
  static const String ponto = '.';

  final double _tamanho;
  final double _espacamento;

  @override
  Widget build(BuildContext context) {
    // O estilo vai no widget `Text`, e não no span raiz: `Text.rich` embrulha
    // o span recebido num span externo que carrega o estilo efetivo, então um
    // estilo posto no raiz fica um nível abaixo do que o texto realmente usa.
    return Text.rich(
      const TextSpan(
        text: nome,
        children: [
          TextSpan(text: ponto, style: TextStyle(color: BoraColors.primary)),
        ],
      ),
      style: BoraTextStyles.logoHero.copyWith(
        fontSize: _tamanho,
        letterSpacing: _espacamento,
        color: BoraColors.ink,
      ),
    );
  }
}
