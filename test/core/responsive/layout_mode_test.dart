import 'package:bora/core/responsive/layout_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FUND-11 — a fronteira entre compacto e expandido é 900.0', () {
    test('largura menor que 900.0 é compacto', () {
      expect(layoutModeForWidth(899.9), LayoutMode.compact);
    });

    test('largura exatamente 900.0 é expandido — fronteira inclusiva', () {
      expect(layoutModeForWidth(900.0), LayoutMode.expanded);
    });

    test('largura maior que 900.0 é expandido', () {
      expect(layoutModeForWidth(900.1), LayoutMode.expanded);
    });
  });
}
