import 'package:bora/core/responsive/layout_mode.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/home/presentation/widgets/card_da_festa.dart';
import 'package:bora/features/home/presentation/widgets/comecar_outra.dart';
import 'package:bora/features/home/presentation/widgets/home_compacta.dart';
import 'package:bora/features/home/presentation/widgets/home_expandida.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';
import '../../../../fixtures/festas_da_home.dart';
import '../../../../support/app_de_teste.dart';

const Size _janelaExpandida = Size(1180, 800);
const Size _janelaCompacta = Size(390, 820);

ResumoDeFesta get _rn30DepoisDoRsvp => ResumoDeFesta(
      id: rn30NaHome.id,
      festa: rn30NaHome.festa,
      confirmados: rn30NaHome.confirmados + 1,
      pendentes: rn30NaHome.pendentes - 1,
      iniciais: rn30NaHome.iniciais,
    );

Future<FestaRepositoryEmMemoria> _abrirHome(
  WidgetTester tester, {
  Size janela = _janelaExpandida,
}) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);

  final repositorio = FestaRepositoryEmMemoria(inicial: festasDaHome);
  await abrirApp(
    tester,
    Routes.roles,
    sessao: sessaoDeTeste,
    festas: repositorio,
  );

  return repositorio;
}

void main() {
  setUpAll(carregarFontesArchivo);

  group('HOME-05 — W-02 é o mesmo estado em outro arranjo', () {
    testWidgets('em expandido monta a Home do web, não a do mobile',
        (tester) async {
      await _abrirHome(tester);

      expect(find.byType(HomeExpandida), findsOneWidget);
      expect(find.byType(HomeCompacta), findsNothing);
    });

    testWidgets('em compacto monta a do mobile — é o par que discrimina',
        (tester) async {
      await _abrirHome(tester, janela: _janelaCompacta);

      expect(find.byType(HomeCompacta), findsOneWidget);
      expect(find.byType(HomeExpandida), findsNothing);
    });

    testWidgets('título à esquerda e subtítulo à direita, na mesma linha',
        (tester) async {
      await _abrirHome(tester);

      final titulo = tester.getRect(find.text('SEUS ROLÊS'));
      final sub = tester.getRect(find.text('1 festa chegando · 2 passadas'));

      expect(titulo.right, lessThan(sub.left));
      expect(
        sub.top,
        lessThan(titulo.bottom),
        reason: 'W-02 põe os dois na mesma linha, não empilhados',
      );
      expect(sub.bottom, greaterThan(titulo.top));

      // A baseline compartilhada não é legível da árvore — as duas caixas têm
      // descidas diferentes, então `bottom` não serve de prova. O que dá para
      // afirmar é o alinhamento pedido ao `Row`.
      final linha = tester.widget<Row>(
        find
            .ancestor(of: find.text('SEUS ROLÊS'), matching: find.byType(Row))
            .first,
      );
      expect(linha.crossAxisAlignment, CrossAxisAlignment.baseline);
      expect(linha.textBaseline, TextBaseline.alphabetic);
    });

    testWidgets('o título sobe o degrau de W-02: 40px', (tester) async {
      await _abrirHome(tester);

      expect(
        tester.widget<Text>(find.text('SEUS ROLÊS')).style!.fontSize,
        HomeExpandida.tamanhoDoTitulo,
      );
      expect(
        HomeExpandida.tamanhoDoTitulo,
        greaterThan(HomeCompacta.tamanhoDoTitulo),
        reason: 'W-R1: a tipografia sobe um degrau no web',
      );
    });

    testWidgets('o card fica à esquerda e "COMEÇAR OUTRA" à direita',
        (tester) async {
      await _abrirHome(tester);

      final card = tester.getRect(find.byType(CardDaFesta));
      final comecar = tester.getRect(find.byType(ComecarOutra));

      expect(card.right, lessThan(comecar.left));
      expect(
        card.width,
        greaterThan(comecar.width),
        reason: 'W-02: grid 1.15fr / 0.85fr — a coluna do card é a maior',
      );
    });
  });

  group('HOME-05 — o card também sobe o degrau de W-02', () {
    testWidgets('sombra de 8px, padding de 28px e título de 38px',
        (tester) async {
      await _abrirHome(tester);

      final superficie = tester.widget<BoraSurface>(
        find
            .descendant(
              of: find.byType(CardDaFesta),
              matching: find.byType(BoraSurface),
            )
            .first,
      );

      expect(
        superficie.deslocamentoDaSombra,
        CardDaFesta.distanciaDaSombraNoWeb,
        reason: 'W-02: "sombra 8px preta"',
      );
      expect(superficie.padding, CardDaFesta.paddingNoWeb);
      expect(
        tester.widget<Text>(find.text('CHURRAS DO RAFA 🔥')).style!.fontSize,
        CardDaFesta.tamanhoDoTituloNoWeb,
      );
    });

    testWidgets('e o mobile fica no degrau de T-02 — é o par que discrimina',
        (tester) async {
      await _abrirHome(tester, janela: _janelaCompacta);

      final superficie = tester.widget<BoraSurface>(
        find
            .descendant(
              of: find.byType(CardDaFesta),
              matching: find.byType(BoraSurface),
            )
            .first,
      );

      expect(superficie.deslocamentoDaSombra, CardDaFesta.distanciaDaSombra);
      expect(superficie.padding, CardDaFesta.padding);
      expect(
        CardDaFesta.distanciaDaSombraNoWeb,
        greaterThan(CardDaFesta.distanciaDaSombra),
      );
    });
  });

  group('HOME-10 AC6 — "Regra RN-28 vale igual" no web', () {
    testWidgets('a transição 4/2 → 5/1 e o atalho valem em expandido',
        (tester) async {
      final repositorio = await _abrirHome(tester);

      expect(find.text('4 confirmados · 2 pendentes'), findsOneWidget);
      expect(find.text(CardDaFesta.verOAcerto), findsNothing);

      repositorio.emitir([_rn30DepoisDoRsvp, ...festasPassadas]);
      await tester.pumpAndSettle();

      expect(find.text('5 confirmados · 1 pendente'), findsOneWidget);
      expect(find.text(CardDaFesta.verOAcerto), findsOneWidget);
    });
  });

  group('cruzar 900px preserva o estado do stream', () {
    testWidgets('o layout troca e a confirmação já recebida continua lá',
        (tester) async {
      final repositorio = await _abrirHome(tester, janela: _janelaCompacta);
      repositorio.emitir([_rn30DepoisDoRsvp, ...festasPassadas]);
      await tester.pumpAndSettle();
      expect(find.byType(HomeCompacta), findsOneWidget);
      expect(find.text(CardDaFesta.verOAcerto), findsOneWidget);

      await tester.binding.setSurfaceSize(_janelaExpandida);
      await tester.pumpAndSettle();

      expect(find.byType(HomeExpandida), findsOneWidget);
      expect(
        find.text('5 confirmados · 1 pendente'),
        findsOneWidget,
        reason: 'o bloc vive acima do ResponsiveBuilder: se descesse, cruzar '
            '900px reassinaria o repositório do zero',
      );
      expect(
        find.text(CardDaFesta.verOAcerto),
        findsOneWidget,
        reason: 'e o que ele sabia sobre confirmação nova se perderia junto',
      );
    });
  });

  group('W-R4 — a janela de 1180x800 não rola na horizontal', () {
    testWidgets('o conteúdo cabe na largura da janela', (tester) async {
      await _abrirHome(tester);

      final home = tester.getRect(find.byType(HomeExpandida));

      expect(home.left, greaterThanOrEqualTo(0));
      expect(home.right, lessThanOrEqualTo(_janelaExpandida.width));
      expect(tester.takeException(), isNull);
    });

    testWidgets('o container respeita o teto de 1040px de W-02',
        (tester) async {
      await _abrirHome(tester, janela: const Size(1600, 900));

      final card = tester.getRect(find.byType(CardDaFesta));
      final comecar = tester.getRect(find.byType(ComecarOutra));
      final conteudo = comecar.right - card.left;

      expect(
        conteudo,
        lessThanOrEqualTo(
          HomeExpandida.larguraDoContainer -
              HomeExpandida.paddingDoContainer.horizontal,
        ),
        reason: 'W-02: "Container 1040px" — numa janela larga o conteúdo '
            'centraliza em vez de esticar',
      );
    });
  });

  group('a fronteira de AD-007 é a mesma do resto do app', () {
    testWidgets('em 900px já é a Home do web', (tester) async {
      await _abrirHome(tester, janela: const Size(kCompactBreakpoint, 800));

      expect(find.byType(HomeExpandida), findsOneWidget);
    });

    testWidgets('um pixel abaixo, ainda é a do mobile', (tester) async {
      await _abrirHome(
        tester,
        janela: const Size(kCompactBreakpoint - 1, 800),
      );

      expect(find.byType(HomeCompacta), findsOneWidget);
    });
  });
}
