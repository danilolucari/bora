import 'package:bora/core/design_system/tokens/bora_spacing.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DS-05 — os paddings literais de §5', () {
    test('cada componente tem o padding que §5 declara', () {
      expect(BoraSpacing.botao, const EdgeInsets.all(15),
          reason: 'botão: "padding 15–16px"');
      expect(BoraSpacing.chip,
          const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          reason: 'chip de seleção: "Padding 10px 14px"');
      expect(BoraSpacing.linhaLista,
          const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          reason: 'card de lista: "linhas com padding 12–13px 14–16px"');
      expect(BoraSpacing.cardHeroi, const EdgeInsets.all(20),
          reason: 'card-herói escuro: "padding 20–22px"');
      expect(BoraSpacing.rodape, const EdgeInsets.fromLTRB(24, 14, 24, 30),
          reason: 'rodapé fixo: "padding 14–16px 24px 30px"');
      expect(BoraSpacing.sheet, const EdgeInsets.fromLTRB(24, 22, 24, 30),
          reason: 'bottom sheet: "padding 22px 24px 30px"');
      expect(BoraSpacing.tag,
          const EdgeInsets.symmetric(vertical: 4, horizontal: 7),
          reason: 'tag de status: "padding 4–6px 7–9px"');
      expect(BoraSpacing.toast,
          const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          reason: 'toast: "padding 12px 20px"');
      expect(BoraSpacing.input,
          const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          reason: 'inputs: "padding 15px 16px"');
    });
  });
}
