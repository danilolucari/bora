import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/di/injector.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/core/routing/festa_tabs_shell.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:bora/features/galera/data/galera_repositorio_sobre_festas.dart';
import 'package:bora/features/galera/domain/galera_repository.dart';
import 'package:bora/features/galera/presentation/galera_textos.dart';
import 'package:bora/features/galera/presentation/pages/galera_page.dart';
import 'package:bora/features/galera/presentation/widgets/card_do_link.dart';
import 'package:bora/features/galera/presentation/widgets/linha_de_pessoa.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/festa_repository.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/rn30_estado_inicial_tipado.dart';
import '../../support/app_de_teste.dart';
import '../../support/festa_em_edicao_repository_fake.dart';
import '../../support/galera_repository_fake.dart';
import '../../support/recording_app_logger.dart';

const Size _janelaCompacta = Size(390, 820);

const String _festaId = 'rafa18';
const String _outraFesta = 'ana27';

/// A festa de RN-30 no registro, com o convite de RN-23.
FestaEmEdicao _festa({String codigo = 'rafa18'}) => FestaEmEdicao(
      festa: Festa(
        nome: 'CHURRAS DO RAFA',
        data: 'SÁB · 18 JUL',
        hora: '14H',
        local: 'Laje do Rafa — Vila Madalena',
        duracaoHoras: 4,
      ),
      convite: ConviteDaFesta(
        codigo: codigo,
        nivel: NivelDoLink.editarLista,
      ),
      composicao: ComposicaoDaFesta(
        contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
        duracaoHoras: 4,
        pessoas: pessoasRn30Tipadas,
        itensSelecionados: itensPadraoRn30Tipados.toSet(),
      ),
    );

/// Abre o app **de verdade** em [location] — a rota é o que está sob teste,
/// então nada de montar a página à mão (AD-014, L-030).
Future<void> _abrir(
  WidgetTester tester, {
  String? location,
  bool comSessao = true,
  Map<String, FestaEmEdicao>? festas,
  GaleraRepository? galera,
}) async {
  final porta = FestaEmEdicaoRepositoryFake(
    festas: festas ?? {_festaId: _festa()},
  );
  addTearDown(porta.dispose);

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(_janelaCompacta);

  await abrirApp(
    tester,
    location ?? Routes.galera(_festaId),
    sessao: comSessao ? sessaoDeTeste : null,
    festasEmEdicao: porta,
    galera: galera,
  );
}

/// Abre o app sobre o **store real** (`FestaRepositoryEmMemoria`), e não sobre
/// o duplo.
///
/// É o único caminho em que a gravação **volta pelo stream**: o duplo registra
/// `salvarFesta` e não reemite, então com ele o round-trip teria de ser
/// simulado por `emitir` — e um teste que empurra o próprio resultado não
/// prova que o gesto chegou lá. Aqui o fio é inteiro: segmented → bloc →
/// `GaleraRepositorioSobreFestas` → registro → stream → tag.
Future<RecordingAppLogger> _abrirSobreOStoreReal(WidgetTester tester) async {
  final base = _festa();
  final store = FestaRepositoryEmMemoria(
    inicial: [
      ResumoDeFesta(
        id: _festaId,
        festa: base.festa,
        composicao: base.composicao,
        convite: base.convite,
      ),
    ],
  );

  // O logger é nosso para que a falha do adaptador seja **visível**: ele
  // registra e contém (`design.md` §10), então sem isto uma gravação que
  // explodisse viraria um teste que "não mudou nada" — indistinguível de um
  // teste que passou.
  final logger = RecordingAppLogger();

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(_janelaCompacta);

  await abrirApp(
    tester,
    Routes.galera(_festaId),
    sessao: sessaoDeTeste,
    festas: store,
    galera: GaleraRepositorioSobreFestas(store, logger),
  );

  return logger;
}

/// Os status das tags **como a árvore os renderiza**, na ordem das linhas.
///
/// Lê o `BoraStatusTag` montado, e não `pessoa.papel`: papel é a entrada, tag
/// é o desfecho que P1-2 AC2 promete não mexer.
List<BoraStatus> _tagsRenderizadas(WidgetTester tester) => tester
    .widgetList<BoraStatusTag>(
      find.descendant(
        of: find.byType(LinhaDePessoa),
        matching: find.byType(BoraStatusTag),
      ),
    )
    .map((tag) => tag.status)
    .toList();

/// O nível que o segmented do card mostra como ativo.
NivelDoLink _nivelNoCard(WidgetTester tester) => NivelDoLink.values[tester
    .widget<BoraSegmentedControl>(
      find.descendant(
        of: find.byType(CardDoLink),
        matching: find.byType(BoraSegmentedControl),
      ),
    )
    .indiceAtivo];

void main() {
  group('P1-2 AC2 — trocar o nível não mexe no papel de quem já entrou', () {
    testWidgets('os três níveis, e as cinco tags idênticas em cada um',
        (tester) async {
      final logger = await _abrirSobreOStoreReal(tester);

      final antes = _tagsRenderizadas(tester);

      expect(antes, hasLength(5));
      expect(
        antes.toSet(),
        hasLength(greaterThan(1)),
        reason: 'lista homogênea passaria mesmo com todo mundo rebaixado',
      );

      for (final nivel in [
        NivelDoLink.coAnfitriao,
        NivelDoLink.soVer,
        NivelDoLink.editarLista,
      ]) {
        final opcao = find.descendant(
          of: find.byType(CardDoLink),
          matching: find.text(GaleraTextos.rotuloDoNivel(nivel)),
        );
        await tester.ensureVisible(opcao);
        await tester.pumpAndSettle();
        await tester.tap(opcao);
        await tester.pumpAndSettle();
        // A gravação atravessa o store real, e o `FakeAsync` do widget tester
        // não roda esse `await` sozinho — é a mesma razão que fez o grupo do
        // injector, mais abaixo, usar `test` em vez de `testWidgets`. Sem este
        // dreno o toque fica pendurado e o teste leria "não mudou nada", que é
        // indistinguível de "a regra funcionou".
        await tester.runAsync(() => Future<void>.delayed(Duration.zero));
        await tester.pumpAndSettle();

        expect(
          _nivelNoCard(tester),
          nivel,
          reason: 'sem isto o teste passaria com o toque não chegando a lugar '
              'nenhum — é o que prova que houve round-trip',
        );
        expect(_tagsRenderizadas(tester), antes);
        expect(logger.erros, isEmpty);
      }
    });
  });

  group('E-2 — /roles/{festaId}/galera monta a tela de T-05', () {
    testWidgets('a rota renderiza a Galera e a URL é a dela', (tester) async {
      await _abrir(tester);

      expect(
        rotaAtual(),
        Routes.galera(_festaId),
        reason: 'AD-014: o destino é afirmado pela URL, não pelo widget',
      );
      expect(find.byKey(GaleraPage.pageKey), findsOneWidget);
      expect(find.text(GaleraTextos.titulo), findsOneWidget);
    });

    testWidgets('A-18: aberta direto, a tela vem por inteiro — com a barra',
        (tester) async {
      await _abrir(tester);

      expect(find.byType(FestaTabsShell), findsOneWidget);
      expect(find.byType(CardDoLink), findsOneWidget);
      expect(find.byType(LinhaDePessoa), findsNWidgets(5));
      expect(find.text('5 pessoas · 4 confirmadas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tela lê a festa da rota: a URL do card é a do convite dela',
        (tester) async {
      await _abrir(tester);

      expect(find.text('bora.app/c/rafa18'), findsOneWidget);
    });
  });

  group('E-2 — o festaId da rota chega diferente à página', () {
    testWidgets('a página recebe o id que está na URL', (tester) async {
      await _abrir(tester);

      expect(
        tester.widget<GaleraPage>(find.byType(GaleraPage)).festaId,
        _festaId,
      );
    });

    testWidgets('outro id na URL vira outro id na página — o par que '
        'discrimina', (tester) async {
      await _abrir(
        tester,
        location: Routes.galera(_outraFesta),
        festas: {_outraFesta: _festa(codigo: 'ana27')},
      );

      expect(rotaAtual(), Routes.galera(_outraFesta));
      expect(
        tester.widget<GaleraPage>(find.byType(GaleraPage)).festaId,
        _outraFesta,
      );
      expect(
        tester.widget<GaleraPage>(find.byType(GaleraPage)).festaId,
        isNot(_festaId),
      );
    });

    testWidgets('a porta é observada com o id da rota, e não com um fixo',
        (tester) async {
      final duplo = GaleraRepositoryFake();
      addTearDown(duplo.dispose);

      await _abrir(
        tester,
        location: Routes.galera(_outraFesta),
        festas: {_outraFesta: _festa(codigo: 'ana27')},
        galera: duplo,
      );

      expect(duplo.observados, [_outraFesta]);
    });

    testWidgets('a festa da rota é a que aparece: o convite é o dela',
        (tester) async {
      await _abrir(
        tester,
        location: Routes.galera(_outraFesta),
        festas: {
          _festaId: _festa(),
          _outraFesta: _festa(codigo: 'ana27'),
        },
      );

      expect(find.text('bora.app/c/ana27'), findsOneWidget);
      expect(find.text('bora.app/c/rafa18'), findsNothing);
    });
  });

  group('AD-017 — a Galera continua atrás da guarda de sessão', () {
    testWidgets('sem sessão, a rota desvia para /entrar', (tester) async {
      await _abrir(tester, comSessao: false);

      expect(rotaAtual(), Routes.entrar);
      expect(find.byKey(GaleraPage.pageKey), findsNothing);
    });

    testWidgets('com sessão, a mesma rota chega ao destino — o par que '
        'discrimina', (tester) async {
      await _abrir(tester);

      expect(rotaAtual(), Routes.galera(_festaId));
      expect(find.byKey(GaleraPage.pageKey), findsOneWidget);
    });
  });

  group('E-2 — o injector registra a porta sobre a porta de edição', () {
    setUp(resetDependencies);
    tearDown(resetDependencies);

    // `test`, e não `testWidgets`: o container não tem árvore, e a leitura do
    // stream aqui é async de verdade — dentro do `FakeAsync` do widget tester
    // ela ficaria esperando um `pump` que não viria.
    test('GaleraRepository é resolvível e é a vista sobre o registro',
        () async {
      await configureDependencies(festasFactory: FestaRepositoryEmMemoria.new);

      expect(getIt.isRegistered<GaleraRepository>(), isTrue);
      expect(
        getIt<GaleraRepository>(),
        isA<GaleraRepositorioSobreFestas>(),
      );
    });

    test('é lazy singleton: a segunda resolução devolve a mesma instância',
        () async {
      await configureDependencies(festasFactory: FestaRepositoryEmMemoria.new);

      expect(
        identical(getIt<GaleraRepository>(), getIt<GaleraRepository>()),
        isTrue,
      );
    });

    test('a porta se apoia na mesma instância da porta de edição', () async {
      await configureDependencies(festasFactory: FestaRepositoryEmMemoria.new);

      final edicao = getIt<FestaEmEdicaoRepository>();
      final leitura = getIt<FestaRepository>();

      expect(identical(edicao, leitura), isTrue);

      // Grava pela porta de edição e lê pela porta da Galera: se a Galera
      // tivesse store próprio, a festa não estaria lá.
      final id = await edicao.criarFesta(_festa());
      final galera = await getIt<GaleraRepository>().observarGalera(id).first;

      expect(galera, isNotNull);
      expect(galera!.convite.codigo, 'rafa18');
      expect(galera.pessoas, hasLength(5));
    });
  });
}
