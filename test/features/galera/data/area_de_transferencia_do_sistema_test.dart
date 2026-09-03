import 'dart:io';

import 'package:bora/features/galera/data/area_de_transferencia_do_sistema.dart';
import 'package:bora/features/galera/domain/area_de_transferencia.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../architecture/calculo_isolation_test.dart'
    show importsProibidosEm;
import '../../../support/area_de_transferencia_falsa.dart';

const String _porta = 'lib/features/galera/domain/area_de_transferencia.dart';

/// Um código de link com caractere que exige escape na URL — o Edge Case da
/// `spec.md`: a string exibida e a copiada têm de ser a mesma.
const String _urlComEscape = 'bora.app/c/rafa 18&x=1';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> chamadas;

  void interceptarOCanal({Object? erro}) {
    chamadas = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (chamada) async {
      chamadas.add(chamada);
      if (erro != null) throw erro;
      return null;
    });
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('A-07 — a porta é Dart puro, o adaptador é quem conhece a plataforma',
      () {
    test('area_de_transferencia.dart não importa Flutter nem Firebase', () {
      expect(importsProibidosEm(File(_porta).readAsStringSync()), isEmpty);
    });

    test('o adaptador satisfaz a porta', () {
      expect(const AreaDeTransferenciaDoSistema(), isA<AreaDeTransferencia>());
    });

    test('o adaptador é const-construível — chega à página por default', () {
      expect(
        identical(
          const AreaDeTransferenciaDoSistema(),
          const AreaDeTransferenciaDoSistema(),
        ),
        isTrue,
      );
    });
  });

  group('GAL-03 — copiar entrega o texto ao Clipboard do sistema', () {
    test('o canal recebe Clipboard.setData com exatamente o texto passado',
        () async {
      interceptarOCanal();

      await const AreaDeTransferenciaDoSistema().copiar('bora.app/c/rafa18');

      expect(chamadas.single.method, 'Clipboard.setData');
      expect(
        (chamadas.single.arguments as Map<Object?, Object?>)['text'],
        'bora.app/c/rafa18',
      );
    });

    test('texto com caractere que exige escape vai idêntico, sem reescrita',
        () async {
      interceptarOCanal();

      await const AreaDeTransferenciaDoSistema().copiar(_urlComEscape);

      expect(
        (chamadas.single.arguments as Map<Object?, Object?>)['text'],
        _urlComEscape,
      );
    });
  });

  group('GAL-05 — a falha do canal chega a quem chamou', () {
    test('a Future completa com erro em vez de completar em silêncio',
        () async {
      interceptarOCanal(erro: PlatformException(code: 'sem-clipboard'));

      await expectLater(
        const AreaDeTransferenciaDoSistema().copiar('bora.app/c/rafa18'),
        throwsA(isA<PlatformException>()),
      );
    });

    test('e a tentativa chegou ao canal — a falha é de lá, não daqui',
        () async {
      interceptarOCanal(erro: PlatformException(code: 'sem-clipboard'));

      await const AreaDeTransferenciaDoSistema()
          .copiar('bora.app/c/rafa18')
          .catchError((Object _) {});

      expect(chamadas.single.method, 'Clipboard.setData');
    });
  });

  group('O duplo que T16 e T24 usam', () {
    test('satisfaz a porta e registra o que foi copiado, na ordem', () async {
      final falsa = AreaDeTransferenciaFalsa();

      expect(falsa, isA<AreaDeTransferencia>());

      await falsa.copiar('bora.app/c/rafa18');
      await falsa.copiar(_urlComEscape);

      expect(falsa.copiados, ['bora.app/c/rafa18', _urlComEscape]);
    });

    test('sabe falhar sob demanda, e a falha propaga', () async {
      final falsa = AreaDeTransferenciaFalsa()..erro = StateError('sem área');

      await expectLater(
        falsa.copiar('bora.app/c/rafa18'),
        throwsA(isA<StateError>()),
      );
    });

    test('sem erro armado, não falha — o par que discrimina', () async {
      final falsa = AreaDeTransferenciaFalsa();

      await expectLater(falsa.copiar('bora.app/c/rafa18'), completes);
    });
  });
}
