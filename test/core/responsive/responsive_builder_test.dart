import 'package:bora/core/responsive/layout_mode.dart';
import 'package:bora/core/responsive/responsive_builder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Frame do celular e janela do web declarados no CLAUDE.md.
const Size _janelaMobile = Size(390, 820);
const Size _janelaWeb = Size(1180, 800);

void main() {
  group('FUND-11 — o modo chega à árvore de widgets', () {
    testWidgets('janela estreita entrega o modo compacto', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(_janelaMobile);
      final modos = <LayoutMode>[];

      await tester.pumpWidget(
        ResponsiveBuilder(
          builder: (context, mode) {
            modos.add(mode);
            return const SizedBox.shrink();
          },
        ),
      );

      expect(modos.last, LayoutMode.compact);
    });

    testWidgets('redimensionar cruzando 900 troca o modo', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(_janelaMobile);
      final modos = <LayoutMode>[];

      await tester.pumpWidget(
        ResponsiveBuilder(
          builder: (context, mode) {
            modos.add(mode);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(modos.last, LayoutMode.compact);

      await tester.binding.setSurfaceSize(_janelaWeb);
      await tester.pump();

      expect(modos.last, LayoutMode.expanded);
    });
  });
}
