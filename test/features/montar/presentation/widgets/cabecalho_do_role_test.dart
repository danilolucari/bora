import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/montar/presentation/widgets/cabecalho_do_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';

/// Conta as rotas empilhadas — A-03 exige edição **na própria tela**: nenhuma
/// navegação, nenhuma tela nova.
class _ObservadorDeRotas extends NavigatorObserver {
  int empilhadas = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previous) {
    empilhadas++;
    super.didPush(route, previous);
  }
}

/// O que o header devolveu, por campo.
class _Emitidos {
  final List<String> nomes = [];
  final List<String> datas = [];
}

const String _nomeInicial = 'CHURRAS NOVO';
const String _dataInicial = 'SÁB · 18 JUL';

late _ObservadorDeRotas _observador;

Future<_Emitidos> _montar(
  WidgetTester tester, {
  String nome = _nomeInicial,
  String data = _dataInicial,
}) async {
  final emitidos = _Emitidos();
  _observador = _ObservadorDeRotas();

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(const Size(390, 820));
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      navigatorObservers: [_observador],
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: CabecalhoDoRole(
            nome: nome,
            data: data,
            aoAlterarNome: emitidos.nomes.add,
            aoAlterarData: emitidos.datas.add,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return emitidos;
}

/// Tira o foco do campo — no produto, tocar em qualquer outro lugar da tela.
Future<void> _sairDoCampo(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontesArchivo);

  group('MONT-15 — fora de edição, nome e data são texto', () {
    testWidgets('mostra os dois valores que recebeu', (tester) async {
      await _montar(tester);

      expect(find.text(_nomeInicial), findsOneWidget);
      expect(find.text(_dataInicial), findsOneWidget);
      expect(find.byType(BoraTextField), findsNothing);
    });
  });

  group('MONT-15 / A-03 — editar acontece na própria tela', () {
    testWidgets('acionar o nome troca o rótulo por um campo, sem empilhar '
        'rota', (tester) async {
      await _montar(tester);
      final rotasAntes = _observador.empilhadas;

      await tester.tap(find.byKey(CabecalhoDoRole.chaveDoNome));
      await tester.pumpAndSettle();

      expect(find.byKey(CabecalhoDoRole.chaveDoCampoDoNome), findsOneWidget);
      expect(find.byType(BoraTextField), findsOneWidget);
      expect(_observador.empilhadas, rotasAntes);
      expect(find.byType(CabecalhoDoRole), findsOneWidget);
    });

    testWidgets('acionar a data abre o campo da data, e só ele',
        (tester) async {
      await _montar(tester);

      await tester.tap(find.byKey(CabecalhoDoRole.chaveDaData));
      await tester.pumpAndSettle();

      expect(find.byKey(CabecalhoDoRole.chaveDoCampoDaData), findsOneWidget);
      expect(find.byKey(CabecalhoDoRole.chaveDoCampoDoNome), findsNothing);
      expect(find.text(_nomeInicial), findsOneWidget);
    });

    testWidgets('o campo abre com o valor atual dentro', (tester) async {
      await _montar(tester);

      await tester.tap(find.byKey(CabecalhoDoRole.chaveDoNome));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<BoraTextField>(
              find.byKey(CabecalhoDoRole.chaveDoCampoDoNome),
            )
            .controller
            .text,
        _nomeInicial,
      );
    });
  });

  group('MONT-15 — confirmar emite; o header não guarda o valor', () {
    testWidgets('sair do campo confirma o nome digitado', (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(find.byKey(CabecalhoDoRole.chaveDoNome));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(CabecalhoDoRole.chaveDoCampoDoNome),
        'CHURRAS DA LAJE',
      );
      await _sairDoCampo(tester);

      expect(emitidos.nomes, ['CHURRAS DA LAJE']);
    });

    testWidgets('confirmado, o header volta a exibir o valor que recebeu — '
        'quem muda a verdade é o bloc', (tester) async {
      await _montar(tester);

      await tester.tap(find.byKey(CabecalhoDoRole.chaveDoNome));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(CabecalhoDoRole.chaveDoCampoDoNome),
        'CHURRAS DA LAJE',
      );
      await _sairDoCampo(tester);

      expect(find.text(_nomeInicial), findsOneWidget);
      expect(find.text('CHURRAS DA LAJE'), findsNothing);
      expect(find.byType(BoraTextField), findsNothing);
    });

    testWidgets('nome apagado por completo é emitido vazio — o default é do '
        'bloc', (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(find.byKey(CabecalhoDoRole.chaveDoNome));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(CabecalhoDoRole.chaveDoCampoDoNome),
        '',
      );
      await _sairDoCampo(tester);

      expect(emitidos.nomes, ['']);
    });

    testWidgets('a data editada é emitida em CAIXA ALTA', (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(find.byKey(CabecalhoDoRole.chaveDaData));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(CabecalhoDoRole.chaveDoCampoDaData),
        'sáb · 25 jul',
      );
      await _sairDoCampo(tester);

      expect(emitidos.datas, ['SÁB · 25 JUL']);
    });

    testWidgets('editar o nome não emite data, e vice-versa', (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(find.byKey(CabecalhoDoRole.chaveDoNome));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(CabecalhoDoRole.chaveDoCampoDoNome),
        'OUTRO NOME',
      );
      await _sairDoCampo(tester);

      expect(emitidos.nomes, ['OUTRO NOME']);
      expect(emitidos.datas, isEmpty);
    });
  });

  group('MONT-15 — sair sem confirmar não perde nada nem grava lixo', () {
    testWidgets('abrir e sair sem escrever não emite evento nenhum',
        (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(find.byKey(CabecalhoDoRole.chaveDoNome));
      await tester.pumpAndSettle();
      await _sairDoCampo(tester);

      expect(emitidos.nomes, isEmpty);
      expect(emitidos.datas, isEmpty);
      expect(find.text(_nomeInicial), findsOneWidget);
    });

    testWidgets('digitar o mesmo valor que já estava lá também não grava',
        (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(find.byKey(CabecalhoDoRole.chaveDaData));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(CabecalhoDoRole.chaveDoCampoDaData),
        _dataInicial,
      );
      await _sairDoCampo(tester);

      expect(emitidos.datas, isEmpty);
    });

    testWidgets('o que foi digitado não se perde ao sair — sair é confirmar',
        (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(find.byKey(CabecalhoDoRole.chaveDoNome));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(CabecalhoDoRole.chaveDoCampoDoNome),
        'CHURRAS DA VIRADA',
      );
      await _sairDoCampo(tester);

      expect(emitidos.nomes, ['CHURRAS DA VIRADA']);
    });
  });
}
