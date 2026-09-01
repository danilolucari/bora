import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/core/routing/festa_tabs_shell.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:bora/features/lista/data/pedido_falso.dart';
import 'package:bora/features/lista/presentation/bloc/lista_bloc.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
import 'package:bora/features/lista/presentation/pages/lista_page.dart';
import 'package:bora/features/lista/presentation/widgets/linha_de_item.dart';
import 'package:bora/features/lista/presentation/widgets/lista_compacta.dart';
import 'package:bora/features/lista/presentation/widgets/painel_de_override.dart';
import 'package:bora/features/montar/presentation/pages/montar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/lista/support/festa_rn30.dart';
import '../../support/app_de_teste.dart';
import '../../support/festa_em_edicao_repository_fake.dart';
import '../../support/recording_app_logger.dart';

const Size _janelaCompacta = Size(390, 820);
const String _festaId = 'rafa18';

/// As quatro rotas das abas, na ordem do arquivo 01 §5.
final List<String> _rotasDasAbas = [
  Routes.lista(_festaId),
  Routes.galera(_festaId),
  Routes.whatsapp(_festaId),
  Routes.custos(_festaId),
];

FestaEmEdicao _festaRn30() => FestaEmEdicao(
      festa: Festa(
        nome: 'CHURRAS DO RAFA',
        data: 'SÁB · 18 JUL',
        hora: '14H',
        local: 'Laje do Rafa — Vila Madalena',
        duracaoHoras: 4,
      ),
      composicao: composicaoRn30(),
    );

Future<FestaEmEdicaoRepositoryFake> _abrir(
  WidgetTester tester, {
  String? location,
}) async {
  final porta = FestaEmEdicaoRepositoryFake(festas: {_festaId: _festaRn30()});
  addTearDown(porta.dispose);

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(_janelaCompacta);

  await abrirApp(
    tester,
    location ?? Routes.lista(_festaId),
    sessao: sessaoDeTeste,
    festasEmEdicao: porta,
  );

  return porta;
}

ListaState _estado(WidgetTester tester) =>
    tester.widget<ListaCompacta>(find.byType(ListaCompacta)).estado;

/// Todas as decorações desenhadas na barra de abas — a dela e as das abas.
List<BoxDecoration> _decoracoesDaBarra(WidgetTester tester) => [
      for (final caixa
          in tester.widgetList<DecoratedBox>(
        find.byKey(FestaTabsShell.barraKey),
      ))
        if (caixa.decoration case final BoxDecoration decoracao) decoracao,
      for (final caixa in tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byKey(FestaTabsShell.barraKey),
          matching: find.byType(DecoratedBox),
        ),
      ))
        if (caixa.decoration case final BoxDecoration decoracao) decoracao,
    ];

/// A decoração da aba de [indice] — o `DecoratedBox` que o `AnimatedContainer`
/// dela pinta, o mesmo caminho que o teste do segmented de §5 usa.
BoxDecoration _decoracaoDaAba(WidgetTester tester, int indice) =>
    tester
        .widget<DecoratedBox>(
          find
              .descendant(
                of: find.byKey(FestaTabsShell.chaveDaAba(indice)),
                matching: find.byType(DecoratedBox),
              )
              .first,
        )
        .decoration as BoxDecoration;

void main() {
  group('LIST-35 — as quatro abas permanentes da festa', () {
    testWidgets('a barra tem os quatro nomes literais do arquivo 01 §5, na '
        'ordem', (tester) async {
      await _abrir(tester);

      expect(find.byKey(FestaTabsShell.barraKey), findsOneWidget);
      expect(ListaTextos.abasDaFesta, ['Lista', 'Galera', 'WhatsApp',
          'Custos']);
      for (var indice = 0; indice < 4; indice++) {
        expect(
          find.descendant(
            of: find.byKey(FestaTabsShell.chaveDaAba(indice)),
            matching: find.text(ListaTextos.abasDaFesta[indice]),
          ),
          findsOneWidget,
          reason: 'a copy é literal e em sentence case, como 01 §5 a escreve',
        );
      }
    });

    for (var indice = 0; indice < 4; indice++) {
      testWidgets('em ${_rotasDasAbas[indice]} a aba '
          '"${ListaTextos.abasDaFesta[indice]}" está ativa e as outras não',
          (tester) async {
        await _abrir(tester, location: _rotasDasAbas[indice]);

        for (var outra = 0; outra < 4; outra++) {
          final texto = tester.widget<Text>(
            find.descendant(
              of: find.byKey(FestaTabsShell.chaveDaAba(outra)),
              matching: find.text(ListaTextos.abasDaFesta[outra]),
            ),
          );

          expect(
            texto.style!.color,
            outra == indice ? BoraColors.cream : BoraColors.text2,
            reason: 'exatamente uma aba ativa, e a cor vem do token',
          );
        }
      });
    }

    testWidgets('tocar uma aba navega para a rota dela', (tester) async {
      await _abrir(tester);

      for (var indice = 1; indice < 4; indice++) {
        await tester.tap(find.byKey(FestaTabsShell.chaveDaAba(indice)));
        await tester.pumpAndSettle();

        expect(
          rotaAtual(),
          _rotasDasAbas[indice],
          reason: 'AD-014: o destino é afirmado pela URL',
        );
      }

      await tester.tap(find.byKey(FestaTabsShell.chaveDaAba(0)));
      await tester.pumpAndSettle();

      expect(rotaAtual(), Routes.lista(_festaId));
    });

    testWidgets('trocar de aba preserva o estado das outras: o override da '
        'Lista continua lá na volta', (tester) async {
      await _abrir(tester);

      await tester.tap(find.byType(LinhaDeItem).first);
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .byWidgetPredicate(
              (widget) =>
                  widget is BotaoDePasso &&
                  widget.simbolo == BoraStepper.simboloMais,
            )
            .first,
      );
      await tester.pumpAndSettle();

      final overrides = _estado(tester).festa!.composicao.overrides;
      final expandida = _estado(tester).chaveExpandida;
      expect(overrides, isNotEmpty);
      expect(expandida, isNotNull);

      await tester.tap(find.byKey(FestaTabsShell.chaveDaAba(1)));
      await tester.pumpAndSettle();
      expect(rotaAtual(), Routes.galera(_festaId));

      await tester.tap(find.byKey(FestaTabsShell.chaveDaAba(0)));
      await tester.pumpAndSettle();

      expect(rotaAtual(), Routes.lista(_festaId));
      expect(_estado(tester).festa!.composicao.overrides, overrides);
      expect(_estado(tester).chaveExpandida, expandida);
      expect(find.byKey(RodapeDaLista.restaurarKey), findsOneWidget);
      expect(find.byType(PainelDeOverride), findsOneWidget);
    });
  });

  group('A-17 — a Lista não depende da barra', () {
    testWidgets('/roles/{festaId}/lista aberta direto renderiza a tela por '
        'inteiro, com a barra', (tester) async {
      await _abrir(tester);

      expect(find.byKey(ListaPage.pageKey), findsOneWidget);
      expect(find.text(ListaTextos.titulo), findsOneWidget);
      expect(find.byKey(RodapeDaLista.ctaKey), findsOneWidget);
      expect(find.byKey(FestaTabsShell.barraKey), findsOneWidget);
    });

    testWidgets('a mesma tela renderiza inteira **sem** a barra', (tester) async {
      final porta = FestaEmEdicaoRepositoryFake(
        festas: {_festaId: _festaRn30()},
      );
      addTearDown(porta.dispose);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(_janelaCompacta);

      await tester.pumpWidget(
        MaterialApp(
          theme: boraTheme(),
          home: ListaPage(
            festaId: _festaId,
            festas: porta,
            pedidos: const PedidoFalso(),
            logger: RecordingAppLogger(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(FestaTabsShell.barraKey), findsNothing);
      expect(find.byKey(ListaPage.pageKey), findsOneWidget);
      expect(find.text(ListaTextos.titulo), findsOneWidget);
      expect(find.byKey(RodapeDaLista.ctaKey), findsOneWidget);
    });

    testWidgets('/roles/{festaId}/montar não exibe a barra — montar não é aba',
        (tester) async {
      await _abrir(tester, location: Routes.montar(_festaId));

      expect(find.byKey(MontarPage.pageKey), findsOneWidget);
      expect(find.byKey(FestaTabsShell.barraKey), findsNothing);
      expect(find.byType(FestaTabsShell), findsNothing);
    });
  });

  group('LIST-35 — os invariantes do arquivo 02 valem na barra', () {
    testWidgets('nenhum canto arredondado, nenhuma sombra com blur e nenhum '
        'gradiente', (tester) async {
      await _abrir(tester);

      final decoracoes = _decoracoesDaBarra(tester);

      expect(decoracoes, isNotEmpty);
      for (final decoracao in decoracoes) {
        expect(decoracao.borderRadius, anyOf(isNull, BoraBorders.raio));
        expect(decoracao.gradient, isNull);
        for (final sombra in decoracao.boxShadow ?? const <BoxShadow>[]) {
          expect(sombra.blurRadius, 0);
        }
      }
    });

    testWidgets('as cores da barra são as dos tokens, comparadas com eles',
        (tester) async {
      await _abrir(tester);

      final barra = tester
          .widget<DecoratedBox>(find.byKey(FestaTabsShell.barraKey))
          .decoration as BoxDecoration;

      expect(barra.color, BoraColors.paper);
      expect(barra.border, BoraFooterBar.bordaSuperior);
      expect(
        (barra.border! as Border).top.width,
        BoraBorders.padraoInk.top.width,
      );
      expect((barra.border! as Border).top.color, BoraColors.ink);

      expect(_decoracaoDaAba(tester, 0).color, BoraColors.ink);
      expect(_decoracaoDaAba(tester, 1).color, Colors.transparent);
    });
  });
}
