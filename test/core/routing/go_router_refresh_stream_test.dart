import 'dart:async';

import 'package:bora/core/routing/go_router_refresh_stream.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StreamController<int> fonte;

  setUp(() => fonte = StreamController<int>.broadcast());
  tearDown(() => fonte.close());

  group('AD-020 — a ponte que faz a guarda acordar sozinha', () {
    test('cada emissão do stream vira uma notificação', () async {
      final ponte = GoRouterRefreshStream(fonte.stream);
      var avisos = 0;
      ponte.addListener(() => avisos++);

      fonte.add(1);
      fonte.add(2);
      await Future<void>.delayed(Duration.zero);

      expect(avisos, 2);
      ponte.dispose();
    });

    test('depois de dispose, emissão não notifica mais', () async {
      final ponte = GoRouterRefreshStream(fonte.stream);
      var avisos = 0;
      ponte.addListener(() => avisos++);

      ponte.dispose();
      fonte.add(1);
      await Future<void>.delayed(Duration.zero);

      expect(
        avisos,
        0,
        reason: 'inscrição que sobrevive ao roteador contamina o teste '
            'seguinte',
      );
    });
  });
}
