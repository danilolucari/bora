import 'dart:async';

import 'package:bora/core/routing/placeholder_page.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/festa_repository.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:bora/features/home/presentation/home_textos.dart';
import 'package:bora/features/home/presentation/pages/home_page.dart';
import 'package:bora/features/home/presentation/widgets/arquivo_de_festas.dart';
import 'package:bora/features/home/presentation/widgets/card_da_festa.dart';
import 'package:bora/features/home/presentation/widgets/comecar_outra.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/design_system/support/font_loading.dart';
import '../../../fixtures/festas_da_home.dart';
import '../../../support/app_de_teste.dart';

const Size _janelaExpandida = Size(1180, 800);
const Size _janelaCompacta = Size(390, 820);

/// Os dois viewports, para os casos que a spec manda valer nos dois.
const List<(String, Size)> _viewports = [
  ('mobile', _janelaCompacta),
  ('web', _janelaExpandida),
];

/// Um repositório que emite e falha sob comando (HOME-16).
class _RepositorioQueFalha implements FestaRepository {
  final _controlador = StreamController<List<ResumoDeFesta>>.broadcast();

  @override
  Stream<List<ResumoDeFesta>> observarFestas() => _controlador.stream;

  void emitir(List<ResumoDeFesta> festas) => _controlador.add(festas);

  void falhar(Object erro) => _controlador.addError(erro, StackTrace.current);

  @override
  Future<void> dispose() => _controlador.close();
}

Future<void> _abrir(
  WidgetTester tester,
  FestaRepository repositorio, {
  required Size janela,
}) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);
  await abrirApp(
    tester,
    Routes.roles,
    sessao: sessaoDeTeste,
    festas: repositorio,
  );
}

Future<void> _abrirVazia(WidgetTester tester, {required Size janela}) =>
    _abrir(tester, FestaRepositoryEmMemoria(), janela: janela);

void main() {
  setUpAll(carregarFontesArchivo);

  group('HOME-15 — a Home de quem não tem festa nenhuma', () {
    for (final (nome, janela) in _viewports) {
      testWidgets('no $nome, o card não renderiza e a tela não quebra',
          (tester) async {
        await _abrirVazia(tester, janela: janela);

        expect(find.byType(CardDaFesta), findsNothing);
        expect(find.byKey(HomePage.pageKey), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('no $nome, o subtítulo lê "nenhuma festa chegando"',
          (tester) async {
        await _abrirVazia(tester, janela: janela);

        expect(find.text('nenhuma festa chegando'), findsOneWidget);
      });

      testWidgets('no $nome, "COMEÇAR OUTRA" continua presente e funcional',
          (tester) async {
        await _abrirVazia(tester, janela: janela);

        expect(find.byType(ComecarOutra), findsOneWidget);

        await tester.tap(find.text(ComecarOutra.churrasco));
        await tester.pumpAndSettle();

        expect(
          find.byKey(PlaceholderPage.keyFor('montar')),
          findsOneWidget,
          reason: 'é o único caminho adiante de quem acabou de se cadastrar — '
              'presente mas inerte seria pior que ausente',
        );
      });
    }

    testWidgets('sem passada nenhuma, o ARQUIVO renderiza vazio e sem erro',
        (tester) async {
      await _abrirVazia(tester, janela: _janelaExpandida);

      expect(find.byType(ArquivoDeFestas), findsOneWidget);
      expect(find.text(ArquivoDeFestas.titulo), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ArquivoDeFestas),
          matching: find.text(ArquivoDeFestas.emoji),
        ),
        findsNothing,
        reason: 'AC3: sem linha e sem erro',
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('HOME-15 AC4 — passadas sem nenhuma chegando', () {
    for (final (nome, janela) in _viewports) {
      testWidgets('no $nome, o subtítulo usa as duas metades', (tester) async {
        await _abrir(
          tester,
          FestaRepositoryEmMemoria(inicial: festasPassadas),
          janela: janela,
        );

        expect(
          find.text('nenhuma festa chegando · 2 passadas'),
          findsOneWidget,
        );
        expect(find.byType(CardDaFesta), findsNothing);
      });
    }

    testWidgets('e o arquivo mostra as duas linhas no web', (tester) async {
      await _abrir(
        tester,
        FestaRepositoryEmMemoria(inicial: festasPassadas),
        janela: _janelaExpandida,
      );

      expect(find.text('Churras da laje · 14 pessoas'), findsOneWidget);
    });
  });

  group('HOME-16 — a falha é mensagem na tela, não tela em branco', () {
    for (final (nome, janela) in _viewports) {
      testWidgets('no $nome, a mensagem aparece e o caminho adiante fica',
          (tester) async {
        final repositorio = _RepositorioQueFalha();
        addTearDown(repositorio.dispose);
        await _abrir(tester, repositorio, janela: janela);

        expect(
          find.text(HomeTextos.falha),
          findsNothing,
          reason: 'é o par que discrimina: uma mensagem sempre visível '
              'passaria no teste de baixo',
        );

        repositorio.falhar(StateError('conexão caiu'));
        await tester.pumpAndSettle();

        expect(find.text(HomeTextos.falha), findsOneWidget);
        expect(
          find.byType(ComecarOutra),
          findsOneWidget,
          reason: 'o design manda "COMEÇAR OUTRA" continuar acessível na '
              'falha — sem ele a tela vira beco sem saída',
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('a Home não diz "nenhuma festa" enquanto falha em carregar',
        (tester) async {
      final repositorio = _RepositorioQueFalha();
      addTearDown(repositorio.dispose);
      await _abrir(tester, repositorio, janela: _janelaCompacta);

      repositorio.falhar(StateError('conexão caiu'));
      await tester.pumpAndSettle();

      expect(
        find.text('nenhuma festa chegando'),
        findsNothing,
        reason: 'afirmar que o usuário não tem rolê nenhum no mesmo instante '
            'em que se diz que não deu para carregar é a tela se contradizendo',
      );
      expect(find.text(HomeTextos.falha), findsOneWidget);
    });

    testWidgets('e também não diz enquanto ainda está carregando',
        (tester) async {
      final repositorio = _RepositorioQueFalha();
      addTearDown(repositorio.dispose);
      await _abrir(tester, repositorio, janela: _janelaCompacta);

      expect(
        find.text('nenhuma festa chegando'),
        findsNothing,
        reason: 'com fonte assíncrona, a Home piscaria o estado de quem acabou '
            'de se cadastrar antes de o dado chegar',
      );

      repositorio.emitir(const []);
      await tester.pumpAndSettle();

      expect(
        find.text('nenhuma festa chegando'),
        findsOneWidget,
        reason: 'é o par: com a lista vazia confirmada, aí sim',
      );
    });

    testWidgets('a falha não apaga da tela o que já tinha chegado',
        (tester) async {
      final repositorio = _RepositorioQueFalha();
      addTearDown(repositorio.dispose);
      await _abrir(tester, repositorio, janela: _janelaCompacta);

      repositorio.emitir(festasDaHome);
      await tester.pumpAndSettle();
      expect(find.byType(CardDaFesta), findsOneWidget);

      repositorio.falhar(StateError('conexão caiu'));
      await tester.pumpAndSettle();

      expect(
        find.text('4 confirmados · 2 pendentes'),
        findsOneWidget,
        reason: 'o stream é broadcast e o erro não cancela a inscrição: o que '
            'já chegou continua verdadeiro',
      );
      expect(find.text(HomeTextos.falha), findsOneWidget);
    });
  });
}
