import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/lista/domain/parceiro_de_entrega.dart';
import 'package:bora/features/lista/domain/pedido.dart';
import 'package:bora/features/lista/presentation/bloc/pedido_bloc.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
import 'package:bora/features/lista/presentation/widgets/overlay_de_pedido.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/pedido_falso_de_teste.dart';
import '../../../../support/recording_app_logger.dart';
import '../../support/festa_rn30.dart';

const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

const String _arquivoDoOverlay =
    'lib/features/lista/presentation/widgets/overlay_de_pedido.dart';

/// O endereço inteiro de RN-30 — o mesmo string que a sheet mostrou (D-6).
const String _enderecoDaFesta = 'Laje do Rafa — Vila Madalena';

/// O pedido que a porta devolveu no estado padrão de RN-30 com o iFood.
final Pedido _pedidoRn30 = Pedido(
  parceiro: ParceiroDeEntrega.ifood,
  endereco: _enderecoDaFesta,
  itens: itensCobraveis(resultadoRn30().todosOsItens).toList(),
  subtotal: 270.6,
  frete: 12,
  total: 282.6,
);

Future<List<int>> _montar(
  WidgetTester tester, {
  Pedido? pedido,
  Size viewport = _frameCompacto,
}) async {
  final voltas = <int>[];

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        body: OverlayDePedido(
          pedido: pedido ?? _pedidoRn30,
          onVoltar: () => voltas.add(1),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return voltas;
}

/// Abre o overlay **pela rota**, como a tela o abre.
Future<void> _abrirPelaRota(WidgetTester tester, {Pedido? pedido}) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(_frameCompacto);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: GestureDetector(
              onTap: () => OverlayDePedido.mostrar(
                context,
                pedido: pedido ?? _pedidoRn30,
              ),
              child: const Text('ABRIR'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('ABRIR'));
  await tester.pumpAndSettle();
}

/// Toda a copy que o overlay põe na tela.
List<String> _copyNaArvore(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: find.byType(OverlayDePedido),
        matching: find.byType(Text),
      ),
    )
    .map((texto) => texto.data!)
    .toList();

/// O tamanho de fonte do texto [conteudo].
double _tamanhoDe(WidgetTester tester, String conteudo) =>
    tester.widget<Text>(find.text(conteudo)).style!.fontSize!;

void main() {
  _viewports.forEach((nome, viewport) {
    group('LIST-26 — as quatro linhas e o CTA ($nome)', () {
      testWidgets('🛵, título, ETA + endereço, linha do rateio e o CTA',
          (tester) async {
        await _montar(tester, viewport: viewport);

        expect(find.text(OverlayDePedido.moto), findsOneWidget);
        expect(find.text(ListaTextos.pedidoACaminho), findsOneWidget);
        expect(
          find.text(ListaTextos.chegaEm('40–60 min', _enderecoDaFesta)),
          findsOneWidget,
        );
        expect(
          find.text(
            ListaTextos.rachadoNoAcerto(MoneyFormatter.reais(282.6)),
          ),
          findsOneWidget,
        );
        expect(find.text(ListaTextos.voltarALista), findsOneWidget);
      });

      testWidgets('o endereço sai inteiro, sem encurtar (D-6)', (tester) async {
        await _montar(tester, viewport: viewport);

        expect(
          find.textContaining('Laje do Rafa — Vila Madalena'),
          findsOneWidget,
        );
        expect(find.textContaining('na Laje do Rafa.'), findsNothing);
      });
    });
  });

  group('LIST-26 — o total é formatado pela camada (RN-13)', () {
    testWidgets('282,60 vira o inteiro de MoneyFormatter, não 282,60',
        (tester) async {
      await _montar(tester);

      expect(
        find.text(ListaTextos.rachadoNoAcerto(MoneyFormatter.reais(282.6))),
        findsOneWidget,
      );
      expect(find.textContaining('282,6'), findsNothing);
      expect(find.textContaining('282.6'), findsNothing);
    });
  });

  group('LIST-28 AC2 — a tela mostra o que a porta devolveu', () {
    testWidgets('o ETA é o do pedido confirmado, não o do parceiro escolhido',
        (tester) async {
      // A sheet abre com o iFood (40–60 min); a porta devolve um pedido do
      // Rappi (15–30 min). Um widget com o ETA por constante mostraria o
      // primeiro.
      final daPorta = Pedido(
        parceiro: ParceiroDeEntrega.rappi,
        endereco: 'Rua da Mooca, 300',
        itens: const [],
        subtotal: 100,
        frete: 9,
        total: 109,
      );
      final porta = PedidoFalsoDeTeste(resposta: daPorta);
      final bloc = PedidoBloc(
        porta,
        RecordingAppLogger(),
        itens: resultadoRn30().todosOsItens,
        enderecoDaFesta: _enderecoDaFesta,
      );
      addTearDown(bloc.close);

      expect(bloc.state.parceiro, ParceiroDeEntrega.ifood);
      bloc.add(const PedidoEnviado());
      await bloc.stream.firstWhere((estado) => estado.confirmado != null);

      await _montar(tester, pedido: bloc.state.confirmado);

      expect(
        find.text(ListaTextos.chegaEm('15–30 min', 'Rua da Mooca, 300')),
        findsOneWidget,
      );
      expect(find.textContaining('40–60 min'), findsNothing);
      expect(
        find.text(ListaTextos.rachadoNoAcerto(MoneyFormatter.reais(109))),
        findsOneWidget,
      );
    });

    testWidgets('dois pedidos diferentes dão dois overlays diferentes',
        (tester) async {
      await _montar(tester);
      final primeiro = _copyNaArvore(tester);

      await _montar(
        tester,
        pedido: Pedido(
          parceiro: ParceiroDeEntrega.ze,
          endereco: 'Quadra do Léo',
          itens: const [],
          subtotal: 40,
          frete: 0,
          total: 40,
        ),
      );

      expect(_copyNaArvore(tester), isNot(primeiro));
      expect(
        find.text(ListaTextos.chegaEm('30–45 min', 'Quadra do Léo')),
        findsOneWidget,
      );
    });
  });

  group('LIST-28 AC4 — sem selo de "simulado" (AD-024)', () {
    testWidgets('a árvore tem exatamente as cinco linhas de T-04',
        (tester) async {
      await _montar(tester);

      expect(_copyNaArvore(tester), [
        OverlayDePedido.moto,
        ListaTextos.pedidoACaminho,
        ListaTextos.chegaEm('40–60 min', _enderecoDaFesta),
        ListaTextos.rachadoNoAcerto(MoneyFormatter.reais(282.6)),
        ListaTextos.voltarALista,
      ]);
    });
  });

  group('LIST-26 — "VOLTAR À LISTA" encerra o overlay', () {
    testWidgets('o CTA emite a volta', (tester) async {
      final voltas = await _montar(tester);

      await tester.tap(find.byKey(OverlayDePedido.voltarKey));
      await tester.pumpAndSettle();

      expect(voltas.length, 1);
    });

    testWidgets('fecha o overlay e ele não volta sozinho', (tester) async {
      await _abrirPelaRota(tester);
      expect(find.byType(OverlayDePedido), findsOneWidget);

      await tester.tap(find.byKey(OverlayDePedido.voltarKey));
      await tester.pumpAndSettle();

      expect(find.byType(OverlayDePedido), findsNothing);

      await tester.pumpAndSettle();
      expect(find.byType(OverlayDePedido), findsNothing);
    });

    testWidgets('toque fora não fecha — a saída é só o CTA', (tester) async {
      await _abrirPelaRota(tester);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.byType(OverlayDePedido), findsOneWidget);
    });
  });

  group('LIST-26 — o overlay só existe com um pedido', () {
    test('o pedido é obrigatório e não-nulo no construtor', () {
      final codigo = File(_arquivoDoOverlay).readAsStringSync();

      expect(codigo, contains('required this.pedido'));
      expect(codigo, contains('final Pedido pedido;'));
      expect(codigo, isNot(contains('Pedido? ')));
    });

    test('o overlay não conhece a lista nem a festa', () {
      final codigo = File(_arquivoDoOverlay).readAsStringSync();

      expect(codigo, isNot(contains('lista_bloc')));
      expect(codigo, isNot(contains('core/festas')));
    });
  });

  group('T-04 — as duas medidas literais do overlay', () {
    testWidgets('o 🛵 sai a 56px e o título a 30px', (tester) async {
      await _montar(tester);

      expect(_tamanhoDe(tester, OverlayDePedido.moto), 56);
      expect(_tamanhoDe(tester, ListaTextos.pedidoACaminho), 30);
    });
  });

  group('AD-011 — nenhuma cor fora dos tokens', () {
    test('o arquivo do overlay não tem literal de cor', () {
      final codigo = File(_arquivoDoOverlay).readAsStringSync();

      expect(codigo, isNot(matches(RegExp(r'Color\(0x'))));
      expect(codigo, isNot(matches(RegExp(r'\bColors\.'))));
    });
  });
}
