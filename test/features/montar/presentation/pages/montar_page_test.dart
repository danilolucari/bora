import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/core/routing/placeholder_page.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:bora/features/montar/domain/rascunho_inicial.dart';
import 'package:bora/features/montar/presentation/montar_textos.dart';
import 'package:bora/features/montar/presentation/pages/montar_page.dart';
import 'package:bora/features/montar/presentation/widgets/montar_compacto.dart';
import 'package:bora/features/montar/presentation/widgets/montar_expandido.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/support/font_loading.dart';
import '../../../../support/festa_em_edicao_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';

const Size _janelaCompacta = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

/// A festa já existente com que as saídas são exercidas.
const String _festaExistente = 'festa-7';

/// O que a última montagem instalou — o roteador, para afirmar a rota, e a
/// porta, para inspecionar o que foi gravado.
class _Palco {
  _Palco(this.router, this.festas);

  final GoRouter router;
  final FestaEmEdicaoRepositoryFake festas;

  String get rotaAtual =>
      router.routerDelegate.currentConfiguration.uri.toString();

  /// Quantas telas estão empilhadas agora. Uma navegação que **empilhasse** o
  /// rascunho deixaria duas, e o voltar cairia num `/roles/novo` vazio.
  int get telasEmpilhadas =>
      router.routerDelegate.currentConfiguration.matches.length;

  /// Há para onde voltar dentro do roteador?
  bool get podeVoltar => router.routerDelegate.canPop();
}

FestaEmEdicao _festaSalva() => FestaEmEdicao(
      festa: Festa(
        nome: 'CHURRAS DO RAFA',
        data: 'SÁB · 18 JUL',
        hora: '',
        local: '',
        duracaoHoras: duracaoDefaultDoRole,
      ),
      composicao: ComposicaoDaFesta(
        contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
        duracaoHoras: duracaoDefaultDoRole,
        itensSelecionados: itensPadraoDoRole,
      ),
    );

Future<_Palco> _abrir(
  WidgetTester tester, {
  String location = Routes.novoRole,
  Size janela = _janelaCompacta,
  Map<String, FestaEmEdicao>? festas,
}) async {
  final porta = FestaEmEdicaoRepositoryFake(festas: festas);

  addTearDown(porta.dispose);
  addTearDown(BoraToast.esconder);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);

  MontarPage pagina(String? festaId) => MontarPage(
        festaId: festaId,
        festas: porta,
        logger: RecordingAppLogger(),
      );

  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: Routes.roles,
        builder: (context, state) =>
            const PlaceholderPage(id: 'roles', titulo: 'ROLÊS'),
      ),
      GoRoute(
        path: Routes.novoRole,
        builder: (context, state) => pagina(null),
      ),
      GoRoute(
        path: Routes.montarPattern,
        builder: (context, state) =>
            pagina(state.pathParameters[Routes.paramFestaId]),
      ),
      GoRoute(
        path: Routes.listaPattern,
        builder: (context, state) =>
            const PlaceholderPage(id: 'lista', titulo: 'LISTA'),
      ),
      GoRoute(
        path: Routes.whatsappPattern,
        builder: (context, state) =>
            const PlaceholderPage(id: 'whatsapp', titulo: 'WHATSAPP'),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MaterialApp.router(routerConfig: router, theme: boraTheme()),
  );
  await tester.pumpAndSettle();

  return _Palco(router, porta);
}

/// O chip do item, achado pelo nome do catálogo — o rótulo renderizado traz o
/// emoji junto.
Finder _chipDe(ChaveItem chave) => find.byWidgetPredicate(
      (w) =>
          w is BoraSelectionChip && w.rotulo == catalogoDeItens[chave]!.nome,
    );

void main() {
  setUpAll(carregarFontesArchivo);

  group('MONT-15 — /roles/novo abre montável', () {
    testWidgets('a tela monta com o rascunho default e a chave da página',
        (tester) async {
      await _abrir(tester);

      expect(find.byKey(MontarPage.pageKey), findsOneWidget);
      expect(find.text(nomeDefaultDoRole), findsOneWidget);
      expect(find.byType(MontarCompacto), findsOneWidget);
    });

    testWidgets('a festa existente abre com a composição salva, não com um '
        'rascunho novo', (tester) async {
      final palco = await _abrir(
        tester,
        location: Routes.montar(_festaExistente),
        festas: {_festaExistente: _festaSalva()},
      );

      expect(palco.rotaAtual, Routes.montar(_festaExistente));
      expect(find.text('CHURRAS DO RAFA'), findsOneWidget);
      expect(find.text(r'R$ 211'), findsOneWidget);
    });
  });

  group('W-R3 + W-R1 — o bloc vive acima do ResponsiveBuilder', () {
    testWidgets('cruzar 900px troca o layout e preserva a composição inteira',
        (tester) async {
      await _abrir(
        tester,
        location: Routes.montar(_festaExistente),
        festas: {_festaExistente: _festaSalva()},
      );

      // Uma mudança feita no compacto: sai a cerveja.
      await tester.ensureVisible(_chipDe(ChaveItem.cerveja));
      await tester.pumpAndSettle();
      await tester.tap(_chipDe(ChaveItem.cerveja));
      await tester.pumpAndSettle();

      final totalNoCompacto = tester
          .widget<BoraFooterBar>(find.byType(BoraFooterBar))
          .valorFormatado;

      await tester.binding.setSurfaceSize(_janelaExpandida);
      await tester.pumpAndSettle();

      expect(find.byType(MontarExpandido), findsOneWidget);
      expect(find.byType(MontarCompacto), findsNothing);
      expect(
        tester.widget<BoraHeroCard>(find.byType(BoraHeroCard)).valorFormatado,
        totalNoCompacto,
        reason: 'o bloc acima do ResponsiveBuilder é o que faz a composição '
            'atravessar a fronteira de AD-007 inteira',
      );
      expect(
        tester.widget<BoraSelectionChip>(_chipDe(ChaveItem.cerveja)).selecionado,
        isFalse,
      );
    });
  });

  group('MONT-22 — as saídas da tela', () {
    testWidgets('"FECHAR LISTA →" vai para /roles/{festaId}/lista',
        (tester) async {
      final palco = await _abrir(
        tester,
        location: Routes.montar(_festaExistente),
        festas: {_festaExistente: _festaSalva()},
      );

      await tester.tap(find.text(MontarTextos.fecharLista));
      await tester.pumpAndSettle();

      expect(palco.rotaAtual, Routes.lista(_festaExistente));
    });

    testWidgets('"MANDAR NO GRUPO 📲" vai para /roles/{festaId}/whatsapp',
        (tester) async {
      final palco = await _abrir(
        tester,
        location: Routes.montar(_festaExistente),
        janela: _janelaExpandida,
        festas: {_festaExistente: _festaSalva()},
      );

      await tester.tap(find.text(MontarTextos.mandarNoGrupo));
      await tester.pumpAndSettle();

      expect(palco.rotaAtual, Routes.whatsapp(_festaExistente));
    });

    testWidgets('o voltar do header vai para a Home', (tester) async {
      final palco = await _abrir(
        tester,
        location: Routes.montar(_festaExistente),
        festas: {_festaExistente: _festaSalva()},
      );

      await tester.tap(find.byKey(MontarCompacto.chaveDoVoltar));
      await tester.pumpAndSettle();

      expect(palco.rotaAtual, Routes.roles);
    });

    testWidgets('sem festaId ainda não há para onde fechar a lista — a tela '
        'fica onde está', (tester) async {
      final palco = await _abrir(tester);

      await tester.tap(find.text(MontarTextos.fecharLista));
      await tester.pumpAndSettle();

      expect(palco.rotaAtual, Routes.novoRole);
      expect(tester.takeException(), isNull);
    });
  });

  group('MONT-20 — o toque duplo navega uma vez', () {
    testWidgets('dois toques em "FECHAR LISTA →" abrem uma tela só',
        (tester) async {
      final palco = await _abrir(
        tester,
        location: Routes.montar(_festaExistente),
        festas: {_festaExistente: _festaSalva()},
      );

      await tester.tap(find.text(MontarTextos.fecharLista));
      await tester.tap(
        find.text(MontarTextos.fecharLista),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(PlaceholderPage.keyFor('lista'), skipOffstage: false),
        findsOneWidget,
        reason: '`skipOffstage: false` é o que discrimina: com `push`, a '
            'segunda cópia empilhada fica fora de tela',
      );
      expect(palco.rotaAtual, Routes.lista(_festaExistente));
      expect(tester.takeException(), isNull);
    });
  });

  group('MONT-23 — "SALVAR ROLÊ" e o toast de RN-29', () {
    testWidgets('salvar mostra o toast canônico, comparado com o token',
        (tester) async {
      await _abrir(
        tester,
        location: Routes.montar(_festaExistente),
        janela: _janelaExpandida,
        festas: {_festaExistente: _festaSalva()},
      );

      await tester.tap(find.text(MontarTextos.salvarRole));
      await tester.pumpAndSettle();

      expect(find.byKey(BoraToast.toastKey), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(BoraToast.toastKey),
          matching: find.text(BoraToastTexts.roleSalvo.toUpperCase()),
        ),
        findsOneWidget,
        reason: 'o literal de RN-29 mora no token — comparar com uma string '
            'escrita aqui faria o teste concordar com qualquer copy (L-008)',
      );

      BoraToast.esconder();
    });

    testWidgets('o toast é 1 por vez e some sozinho', (tester) async {
      await _abrir(
        tester,
        location: Routes.montar(_festaExistente),
        janela: _janelaExpandida,
        festas: {_festaExistente: _festaSalva()},
      );

      await tester.tap(find.text(MontarTextos.salvarRole));
      await tester.pumpAndSettle();
      await tester.tap(find.text(MontarTextos.salvarRole));
      await tester.pumpAndSettle();

      expect(find.byKey(BoraToast.toastKey), findsOneWidget);

      await tester.pump(BoraMotion.toastVida);
      await tester.pumpAndSettle();

      expect(find.byKey(BoraToast.toastKey), findsNothing);
    });

    testWidgets('salvar grava e não navega', (tester) async {
      final palco = await _abrir(
        tester,
        location: Routes.montar(_festaExistente),
        janela: _janelaExpandida,
        festas: {_festaExistente: _festaSalva()},
      );

      await tester.tap(find.text(MontarTextos.salvarRole));
      await tester.pumpAndSettle();

      expect(
        palco.festas.salvas.map((par) => par.$1),
        contains(_festaExistente),
      );
      expect(palco.rotaAtual, Routes.montar(_festaExistente));

      BoraToast.esconder();
    });
  });

  group('MONT-17 — o rascunho vira festa e a URL passa a refletir o id', () {
    testWidgets('a primeira mudança leva a rota a /roles/{festaId}/montar',
        (tester) async {
      final palco = await _abrir(tester);

      expect(palco.rotaAtual, Routes.novoRole);

      await tester.ensureVisible(_chipDe(ChaveItem.suina));
      await tester.pumpAndSettle();
      await tester.tap(_chipDe(ChaveItem.suina));
      await tester.pumpAndSettle();

      expect(palco.festas.criadas, hasLength(1));
      expect(palco.rotaAtual, Routes.montar(palco.festas.proximoId));
    });

    testWidgets('o rascunho não fica atrás: não há para onde voltar',
        (tester) async {
      final palco = await _abrir(tester);

      expect(palco.telasEmpilhadas, 1);

      await tester.ensureVisible(_chipDe(ChaveItem.suina));
      await tester.pumpAndSettle();
      await tester.tap(_chipDe(ChaveItem.suina));
      await tester.pumpAndSettle();

      expect(
        palco.telasEmpilhadas,
        1,
        reason: 'com `push`, `/roles/novo` continuaria embaixo e o voltar '
            'cairia num rascunho vazio',
      );
      expect(palco.podeVoltar, isFalse);
    });

    testWidgets('a composição sobrevive à troca de rota', (tester) async {
      final palco = await _abrir(tester);

      await tester.ensureVisible(_chipDe(ChaveItem.suina));
      await tester.pumpAndSettle();
      await tester.tap(_chipDe(ChaveItem.suina));
      await tester.pumpAndSettle();

      expect(palco.rotaAtual, Routes.montar(palco.festas.proximoId));
      expect(
        tester.widget<BoraSelectionChip>(_chipDe(ChaveItem.suina)).selecionado,
        isTrue,
        reason: 'criarFesta grava o estado **já com a mudança**, e o bloc '
            'novo lê do store',
      );
    });
  });
}
