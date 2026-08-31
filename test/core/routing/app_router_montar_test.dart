import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:bora/features/home/presentation/widgets/comecar_outra.dart';
import 'package:bora/features/montar/domain/rascunho_inicial.dart';
import 'package:bora/features/montar/presentation/pages/montar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_de_teste.dart';
import '../../support/festa_em_edicao_repository_fake.dart';
import '../design_system/support/font_loading.dart';

const String _festaId = 'rafa18';

/// A festa já salva com que `/roles/:festaId/montar` é exercida.
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

Finder _chipDe(ChaveItem chave) => find.byWidgetPredicate(
      (w) =>
          w is BoraSelectionChip && w.rotulo == catalogoDeItens[chave]!.nome,
    );

/// O que a Home enxerga agora, acompanhado **com a tela montada**.
///
/// Assinar antes e ler a última emissão, em vez de `await stream.first` depois:
/// dentro de `testWidgets` o relógio é falso, e esperar por um `Future` de
/// stream que só anda com um quadro trava o teste. De quebra, é o formato que
/// prova o que interessa — a Home vê a festa nova **sem refresh**.
List<ResumoDeFesta> Function() _oQueAHomeVe(FestaRepositoryEmMemoria store) {
  final emissoes = <List<ResumoDeFesta>>[];
  final inscricao = store.observarFestas().listen(emissoes.add);
  addTearDown(inscricao.cancel);

  return () => emissoes.isEmpty ? const [] : emissoes.last;
}

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(carregarFontesArchivo);

  group('MONT-16 — as duas rotas de montar', () {
    testWidgets('/roles/novo abre o rascunho default', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 820));

      await abrirApp(tester, Routes.novoRole, sessao: sessaoDeTeste);

      expect(rotaAtual(), Routes.novoRole);
      expect(find.byKey(MontarPage.pageKey), findsOneWidget);
      expect(find.text(nomeDefaultDoRole), findsOneWidget);
    });

    testWidgets('/roles/:festaId/montar abre a festa **do id da URL**',
        (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 820));

      final porta = FestaEmEdicaoRepositoryFake(
        festas: {_festaId: _festaSalva()},
      );
      addTearDown(porta.dispose);

      await abrirApp(
        tester,
        Routes.montar(_festaId),
        sessao: sessaoDeTeste,
        festasEmEdicao: porta,
      );

      expect(rotaAtual(), Routes.montar(_festaId));
      expect(
        find.text('CHURRAS DO RAFA'),
        findsOneWidget,
        reason: 'com `const MontarPage()` o `:festaId` era descartado e as '
            'duas rotas abriam a mesma tela em branco',
      );
      expect(find.text(nomeDefaultDoRole), findsNothing);
    });

    testWidgets('as duas rotas montam a MESMA tela — por isso o destino se '
        'afirma por rotaAtual() (AD-014)', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 820));

      await abrirApp(tester, Routes.novoRole, sessao: sessaoDeTeste);

      expect(find.byKey(MontarPage.pageKey), findsOneWidget);
      expect(rotaAtual(), Routes.novoRole);
      expect(
        rotaAtual(),
        isNot(Routes.montar(_festaId)),
        reason: 'a chave da página não discrimina as duas rotas; a URL sim',
      );
    });
  });

  group('AD-017 — a guarda de sessão continua valendo em montar', () {
    testWidgets('/roles/novo sem sessão vai para /entrar', (tester) async {
      await abrirApp(tester, Routes.novoRole);

      expect(rotaAtual(), Routes.entrar);
      expect(find.byKey(MontarPage.pageKey), findsNothing);
    });

    testWidgets('/roles/:festaId/montar sem sessão vai para /entrar',
        (tester) async {
      await abrirApp(tester, Routes.montar(_festaId));

      expect(rotaAtual(), Routes.entrar);
    });
  });

  group('MONT-17 + MONT-18 — da Home ao rolê criado, ponta a ponta', () {
    testWidgets('🔥 CHURRASCO chega em /roles/novo montável', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 820));

      await abrirApp(tester, Routes.roles, sessao: sessaoDeTeste);

      await _tocar(tester, find.text(ComecarOutra.churrasco));

      expect(rotaAtual(), Routes.novoRole);
      expect(find.byKey(MontarPage.pageKey), findsOneWidget);
      expect(find.byType(BoraSelectionChip), findsNWidgets(11));
    });

    testWidgets('a primeira mudança leva a rota a /roles/{id}/montar e a '
        'composição segue igual', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 820));

      final store = FestaRepositoryEmMemoria();
      addTearDown(store.dispose);
      final naHome = _oQueAHomeVe(store);

      await abrirApp(
        tester,
        Routes.roles,
        sessao: sessaoDeTeste,
        festas: store,
      );
      await _tocar(tester, find.text(ComecarOutra.churrasco));
      await _tocar(tester, _chipDe(ChaveItem.suina));

      final festas = naHome();

      expect(festas, hasLength(1));
      expect(rotaAtual(), Routes.montar(festas.single.id));
      expect(
        tester.widget<BoraSelectionChip>(_chipDe(ChaveItem.suina)).selecionado,
        isTrue,
        reason: 'a festa é criada **já com a mudança**, e o bloc novo a lê do '
            'store — senão a edição se perderia na remontagem',
      );
    });

    testWidgets('o rolê criado em montar é o mesmo store que a Home lê '
        '(AD-029)', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 820));

      final store = FestaRepositoryEmMemoria();
      addTearDown(store.dispose);
      final naHome = _oQueAHomeVe(store);

      await abrirApp(
        tester,
        Routes.roles,
        sessao: sessaoDeTeste,
        festas: store,
      );

      expect(naHome(), isEmpty);

      await _tocar(tester, find.text(ComecarOutra.churrasco));
      await _tocar(tester, _chipDe(ChaveItem.suina));

      expect(naHome(), hasLength(1));
      expect(naHome().single.festa.nome, nomeDefaultDoRole);
    });
  });

  group('E-5 — abrirApp aceita a porta de edição, com default', () {
    testWidgets('sem dizer nada, a porta de escrita é a mesma do repositório '
        'de leitura', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 820));

      final store = FestaRepositoryEmMemoria();
      addTearDown(store.dispose);
      final naHome = _oQueAHomeVe(store);

      await abrirApp(
        tester,
        Routes.novoRole,
        sessao: sessaoDeTeste,
        festas: store,
      );
      await _tocar(tester, _chipDe(ChaveItem.suina));

      expect(naHome(), hasLength(1));
    });

    testWidgets('a porta de edição pode ser dita à parte', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 820));

      final porta = FestaEmEdicaoRepositoryFake();
      addTearDown(porta.dispose);

      await abrirApp(
        tester,
        Routes.novoRole,
        sessao: sessaoDeTeste,
        festasEmEdicao: porta,
      );
      await _tocar(tester, _chipDe(ChaveItem.suina));

      expect(porta.criadas, hasLength(1));
      expect(rotaAtual(), Routes.montar(porta.proximoId));
    });
  });
}
