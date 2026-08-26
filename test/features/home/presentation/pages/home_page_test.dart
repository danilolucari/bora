import 'package:bora/core/routing/placeholder_page.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:bora/features/home/presentation/pages/home_page.dart';
import 'package:bora/features/home/presentation/widgets/card_da_festa.dart';
import 'package:bora/features/home/presentation/widgets/comecar_outra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';
import '../../../../fixtures/festas_da_home.dart';
import '../../../../support/app_de_teste.dart';

/// A festa de RN-30 com um confirmado a mais — o RSVP de RN-28.
ResumoDeFesta get _rn30DepoisDoRsvp => ResumoDeFesta(
  id: rn30NaHome.id,
  festa: rn30NaHome.festa,
  confirmados: rn30NaHome.confirmados + 1,
  pendentes: rn30NaHome.pendentes - 1,
  iniciais: rn30NaHome.iniciais,
);

/// Abre o app na Home, semeado com a fixture, e devolve o repositório para
/// que o teste possa empurrar a confirmação com a tela montada (A-02).
Future<FestaRepositoryEmMemoria> _abrirHome(
  WidgetTester tester, {
  List<ResumoDeFesta>? festas,
}) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(const Size(390, 820));

  final repositorio = FestaRepositoryEmMemoria(inicial: festas ?? festasDaHome);
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

  group('HOME-06 — T-02 na ordem da spec', () {
    testWidgets('título, subtítulo, card e "COMEÇAR OUTRA", nessa ordem', (
      tester,
    ) async {
      await _abrirHome(tester);

      final titulo = tester.getTopLeft(find.text('SEUS ROLÊS')).dy;
      final sub = tester
          .getTopLeft(find.text('1 festa chegando · 2 passadas'))
          .dy;
      final card = tester.getTopLeft(find.byType(CardDaFesta)).dy;
      final comecar = tester.getTopLeft(find.byType(ComecarOutra)).dy;

      expect(titulo, lessThan(sub));
      expect(sub, lessThan(card));
      expect(card, lessThan(comecar));
    });

    testWidgets('o subtítulo lê o literal de T-02, vindo do dado', (
      tester,
    ) async {
      await _abrirHome(tester);

      expect(find.text('1 festa chegando · 2 passadas'), findsOneWidget);
    });

    testWidgets('a linha de contadores lê o literal de RN-30', (tester) async {
      await _abrirHome(tester);

      expect(find.text('4 confirmados · 2 pendentes'), findsOneWidget);
    });

    testWidgets('o subtítulo acompanha o dado, não um literal fixo', (
      tester,
    ) async {
      await _abrirHome(tester, festas: [rn30NaHome, festasPassadas.first]);

      expect(
        find.text('1 festa chegando · 1 passada'),
        findsOneWidget,
        reason:
            'é o par que discrimina A-05: uma string escrita à mão '
            'passaria no teste da fixture e mentiria em qualquer outro estado',
      );
    });

    testWidgets('mais de uma festa chegando vira mais de um card', (
      tester,
    ) async {
      final outra = ResumoDeFesta(
        id: 'outra18',
        festa: rn30NaHome.festa.copyWith(nome: 'CHURRAS DA BIA 🔥'),
        confirmados: 2,
        pendentes: 1,
        iniciais: const ['B'],
      );
      await _abrirHome(tester, festas: [rn30NaHome, outra, ...festasPassadas]);

      expect(find.byType(CardDaFesta), findsNWidgets(2));
      expect(find.text('2 festas chegando · 2 passadas'), findsOneWidget);
    });
  });

  group('HOME-09/HOME-10 — a confirmação chega sem remontar a tela', () {
    testWidgets('4/2 vira 5/1 e o atalho do acerto entra', (tester) async {
      final repositorio = await _abrirHome(tester);

      expect(find.text('4 confirmados · 2 pendentes'), findsOneWidget);
      expect(find.text(CardDaFesta.verOAcerto), findsNothing);

      repositorio.emitir([_rn30DepoisDoRsvp, ...festasPassadas]);
      await tester.pumpAndSettle();

      expect(
        find.text('5 confirmados · 1 pendente'),
        findsOneWidget,
        reason:
            'RN-28: sem pumpWidget novo e sem ação do usuário — é a '
            'transição, e não a string estática, que é o aceite (AD-022)',
      );
      expect(find.text(CardDaFesta.verOAcerto), findsOneWidget);
    });

    testWidgets('os avatares acompanham a nova contagem', (tester) async {
      final repositorio = await _abrirHome(tester);
      expect(find.text('+1'), findsOneWidget);

      repositorio.emitir([_rn30DepoisDoRsvp, ...festasPassadas]);
      await tester.pumpAndSettle();

      expect(find.text('+2'), findsOneWidget);
    });
  });

  group('HOME-07, HOME-08, HOME-11, HOME-12 — para onde cada toque leva', () {
    testWidgets('"MONTAR LISTA →" abre montar da festa', (tester) async {
      await _abrirHome(tester);

      await tester.tap(find.text(CardDaFesta.montarLista));
      await tester.pumpAndSettle();

      expect(find.byKey(PlaceholderPage.keyFor('montar')), findsOneWidget);
      expect(find.byKey(HomePage.pageKey), findsNothing);
    });

    testWidgets('"+ CONVIDAR" abre a aba de whatsapp da festa', (tester) async {
      await _abrirHome(tester);

      await tester.tap(find.text(CardDaFesta.convidar));
      await tester.pumpAndSettle();

      expect(find.byKey(PlaceholderPage.keyFor('convite')), findsOneWidget);
    });

    testWidgets('o atalho do acerto abre os custos da festa', (tester) async {
      final repositorio = await _abrirHome(tester);
      repositorio.emitir([_rn30DepoisDoRsvp, ...festasPassadas]);
      await tester.pumpAndSettle();

      await tester.tap(find.text(CardDaFesta.verOAcerto));
      await tester.pumpAndSettle();

      expect(find.byKey(PlaceholderPage.keyFor('custos')), findsOneWidget);
    });

    testWidgets('"🔥 CHURRASCO" abre /roles/novo', (tester) async {
      await _abrirHome(tester);

      await tester.tap(find.text(ComecarOutra.churrasco));
      await tester.pumpAndSettle();

      expect(find.byKey(PlaceholderPage.keyFor('montar')), findsOneWidget);
    });

    testWidgets('"🎈 NIVER · EM BREVE" não leva a lugar nenhum', (
      tester,
    ) async {
      await _abrirHome(tester);

      await tester.tap(find.text(ComecarOutra.niver));
      await tester.pumpAndSettle();

      expect(
        find.byKey(HomePage.pageKey),
        findsOneWidget,
        reason: 'aceite de UC-02: a rota corrente fica inalterada',
      );
      expect(find.byKey(PlaceholderPage.keyFor('montar')), findsNothing);
    });
  });

  group('HOME-17 — o toque duplo navega uma vez', () {
    testWidgets('dois toques em "MONTAR LISTA →" abrem uma tela só', (
      tester,
    ) async {
      await _abrirHome(tester);

      await tester.tap(find.text(CardDaFesta.montarLista));
      await tester.tap(find.text(CardDaFesta.montarLista), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.byKey(PlaceholderPage.keyFor('montar')),
        findsOneWidget,
        reason:
            'com `push` no lugar de `go`, o segundo toque empilharia uma '
            'segunda cópia da tela',
      );
      expect(tester.takeException(), isNull);
    });
  });
}
