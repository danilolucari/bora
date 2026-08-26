import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

/// O logo "BORA." com o ponto vermelho — T-01 e W-01.
///
/// Não é componente do design system de propósito: o arquivo 02 define o logo
/// como **papel tipográfico** (`BoraTextStyles.logoHero`), não como
/// componente. Enquanto ele tiver um uso só, mora aqui. Quando a spec 04
/// precisar do logo 20px do header de app, aparece o segundo uso real e a
/// promoção para `core/design_system/` passa a valer a pena.
///
/// O ponto é o único acento: "BORA" fica em `ink` e o `.` em `primary`.
class MarcaBora extends StatelessWidget {
  /// O logo de T-01: 64px, o tamanho que o arquivo 02 declara para o papel.
  const MarcaBora.compacta({super.key})
      : _tamanho = tamanhoCompacto,
        _espacamento = _espacamentoCompacto;

  /// O logo de W-01: 92px, ls −3px.
  ///
  /// Os dois números vêm do **arquivo 06**, não do 02 — é o "tipografia sobe
  /// um degrau" que a spec web declara como adaptação de tela. O design system
  /// é dono do papel; a spec de tela é dona do degrau responsivo.
  const MarcaBora.expandida({super.key})
      : _tamanho = tamanhoExpandido,
        _espacamento = _espacamentoExpandido;

  /// Tamanho do logo em T-01 (arquivo 02 §2).
  static const double tamanhoCompacto = 64;

  /// Tamanho do logo em W-01 (arquivo 06).
  static const double tamanhoExpandido = 92;

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
