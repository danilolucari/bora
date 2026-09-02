import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/galera/domain/chave_de_pessoa.dart';
import 'package:bora/features/galera/presentation/galera_textos.dart';
import 'package:bora/features/galera/presentation/widgets/botao_de_dieta.dart';
import 'package:bora/features/galera/presentation/widgets/painel_da_pessoa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/rn30_estado_inicial_tipado.dart';

const String _arquivoDoPainel =
    'lib/features/galera/presentation/widgets/painel_da_pessoa.dart';

/// As duas viewports do produto: o frame do celular e a janela do web.
const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

/// A chave de teste — distinta do default para que a asserção "emitiu com a
/// chave certa" tenha com o que discriminar.
const ChaveDePessoa _chave = ChaveDePessoa('Ana', 1);

Pessoa _daFixture(String nome) =>
    pessoasRn30Tipadas.firstWhere((pessoa) => pessoa.nome == nome);

/// O que o painel emitiu enquanto o teste o exercitava.
class _Gestos {
  final List<(ChaveDePessoa, PapelNaFesta)> papeis = [];
  final List<(ChaveDePessoa, Dieta)> dietas = [];
  final List<(ChaveDePessoa, bool)> bebidas = [];
}

Future<_Gestos> _montar(
  WidgetTester tester, {
  required Pessoa pessoa,
  bool podeGerenciarPapeis = true,
  Size viewport = _frameCompacto,
}) async {
  final gestos = _Gestos();

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: SingleChildScrollView(
          child: PainelDaPessoa(
            chave: _chave,
            pessoa: pessoa,
            podeGerenciarPapeis: podeGerenciarPapeis,
            onEscolherPapel: (chave, papel) =>
                gestos.papeis.add((chave, papel)),
            onEscolherDieta: (chave, dieta) =>
                gestos.dietas.add((chave, dieta)),
            onAlternarBebida: (chave, bebe) =>
                gestos.bebidas.add((chave, bebe)),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return gestos;
}

Finder _secao(String texto) => find.text(texto);

double _topoDe(WidgetTester tester, Finder finder) =>
    tester.getTopLeft(finder).dy;

/// O segmented cujo primeiro rótulo é [primeiroRotulo].
BoraSegmentedControl _segmentedDe(
  WidgetTester tester,
  String primeiroRotulo,
) =>
    tester
        .widgetList<BoraSegmentedControl>(find.byType(BoraSegmentedControl))
        .firstWhere((controle) => controle.opcoes.first == primeiroRotulo);

void main() {
  final rafa = _daFixture('Rafa');
  final ana = _daFixture('Ana');
  final bia = _daFixture('Bia');
  final duda = _daFixture('Duda');

  group('GAL-10 AC2 — as três seções, nesta ordem', () {
    for (final viewport in _viewports.entries) {
      testWidgets('em ${viewport.key}, nível, restrição e bebida em ordem',
          (tester) async {
        await _montar(tester, pessoa: ana, viewport: viewport.value);

        expect(_secao(GaleraTextos.secaoNivelDeAcesso), findsOneWidget);
        expect(_secao(GaleraTextos.secaoRestricao), findsOneWidget);
        expect(_secao(GaleraTextos.secaoBebida), findsOneWidget);

        final topos = [
          _topoDe(tester, _secao(GaleraTextos.secaoNivelDeAcesso)),
          _topoDe(tester, _secao(GaleraTextos.secaoRestricao)),
          _topoDe(tester, _secao(GaleraTextos.secaoBebida)),
        ];

        expect(topos, orderedEquals(List.of(topos)..sort()));
      });
    }

    testWidgets('a restrição alimentar traz os três botões de RN-21',
        (tester) async {
      await _montar(tester, pessoa: ana);

      expect(find.byType(BotaoDeDieta), findsNWidgets(3));
      expect(find.text(GaleraTextos.rotuloDaDieta(Dieta.tudo)), findsOneWidget);
      expect(
        find.text(GaleraTextos.rotuloDaDieta(Dieta.veggie)),
        findsOneWidget,
      );
      expect(
        find.text(GaleraTextos.rotuloDaDieta(Dieta.semPorco)),
        findsOneWidget,
      );
    });
  });

  group('GAL-17, GAL-18 — o que "NÍVEL DE ACESSO" oferece', () {
    testWidgets('exatamente CONVIDADO, CO-ANFITRIÃO e SÓ VÊ', (tester) async {
      await _montar(tester, pessoa: ana);

      final controle = _segmentedDe(tester, GaleraTextos.papeis.first);

      expect(controle.opcoes, ['CONVIDADO', 'CO-ANFITRIÃO', 'SÓ VÊ']);
      expect(controle.opcoes, hasLength(3));
    });

    testWidgets('ANFITRIÃO não é oferecido em lugar nenhum do painel',
        (tester) async {
      await _montar(tester, pessoa: ana);

      expect(
        find.text(GaleraTextos.rotuloDoPapel(PapelNaFesta.anfitriao)),
        findsNothing,
      );
    });

    testWidgets('o ativo é o papel vigente da pessoa', (tester) async {
      await _montar(tester, pessoa: bia);

      expect(
        _segmentedDe(tester, GaleraTextos.papeis.first).indiceAtivo,
        GaleraTextos.papeisAtribuiveis.indexOf(PapelNaFesta.convidado),
      );
    });
  });

  group('T-05 — o ativo de nível e de bebida é preto', () {
    testWidgets('nenhum dos dois segmenteds é a variante de card escuro',
        (tester) async {
      await _montar(tester, pessoa: ana);

      for (final controle in tester
          .widgetList<BoraSegmentedControl>(find.byType(BoraSegmentedControl))) {
        expect(controle.sobreCardEscuro, isFalse);
      }
    });

    testWidgets('o botão ativo pinta o fundo de ink e o texto de cream',
        (tester) async {
      await _montar(tester, pessoa: ana);

      final ativo = tester.firstWidget<AnimatedContainer>(
        find.ancestor(
          of: find.text(GaleraTextos.rotuloDoPapel(PapelNaFesta.coAnfitriao)),
          matching: find.byType(AnimatedContainer),
        ),
      );

      expect((ativo.decoration! as BoxDecoration).color, BoraColors.ink);
      expect(
        tester
            .widget<Text>(
              find.text(GaleraTextos.rotuloDoPapel(PapelNaFesta.coAnfitriao)),
            )
            .style
            ?.color,
        BoraColors.cream,
      );
    });
  });

  group('GAL-12 — o toggle de bebida', () {
    testWidgets('as duas metades são BEBE 🍺 e NÃO BEBE 🚫', (tester) async {
      await _montar(tester, pessoa: ana);

      final controle = _segmentedDe(tester, GaleraTextos.bebe);

      expect(controle.opcoes, ['BEBE 🍺', 'NÃO BEBE 🚫']);
    });

    testWidgets('quem bebe tem a primeira metade acesa', (tester) async {
      await _montar(tester, pessoa: ana);

      expect(_segmentedDe(tester, GaleraTextos.bebe).indiceAtivo, 0);
    });

    testWidgets('quem não bebe tem a segunda metade acesa', (tester) async {
      await _montar(tester, pessoa: bia);

      expect(_segmentedDe(tester, GaleraTextos.bebe).indiceAtivo, 1);
    });

    testWidgets('quem não declarou não tem metade acesa nenhuma (A-14)',
        (tester) async {
      await _montar(tester, pessoa: duda);

      expect(
        _segmentedDe(tester, GaleraTextos.bebe).indiceAtivo,
        PainelDaPessoa.nenhumAtivo,
      );
    });

    testWidgets('tocar "NÃO BEBE 🚫" emite false com a chave da pessoa',
        (tester) async {
      final gestos = await _montar(tester, pessoa: ana);

      await tester.tap(find.text(GaleraTextos.naoBebe));
      await tester.pumpAndSettle();

      expect(gestos.bebidas, [(_chave, false)]);
    });

    testWidgets('tocar a metade já ativa não emite nada (GAL-28)',
        (tester) async {
      final gestos = await _montar(tester, pessoa: ana);

      await tester.tap(find.text(GaleraTextos.bebe));
      await tester.pumpAndSettle();

      expect(gestos.bebidas, isEmpty);
    });
  });

  group('GAL-11, GAL-17 — as escritas saem com a chave', () {
    testWidgets('escolher uma dieta emite a dieta e a chave', (tester) async {
      final gestos = await _montar(tester, pessoa: ana);

      await tester.tap(find.text(GaleraTextos.rotuloDaDieta(Dieta.veggie)));
      await tester.pumpAndSettle();

      expect(gestos.dietas, [(_chave, Dieta.veggie)]);
      expect(gestos.papeis, isEmpty);
      expect(gestos.bebidas, isEmpty);
    });

    testWidgets('a dieta já ativa não emite (GAL-28)', (tester) async {
      final gestos = await _montar(tester, pessoa: ana);

      await tester.tap(find.text(GaleraTextos.rotuloDaDieta(Dieta.tudo)));
      await tester.pumpAndSettle();

      expect(gestos.dietas, isEmpty);
    });

    testWidgets('escolher um papel emite o papel e a chave', (tester) async {
      final gestos = await _montar(tester, pessoa: ana);

      await tester.tap(
        find.text(GaleraTextos.rotuloDoPapel(PapelNaFesta.soVe)),
      );
      await tester.pumpAndSettle();

      expect(gestos.papeis, [(_chave, PapelNaFesta.soVe)]);
    });

    testWidgets('o papel já ativo não emite (GAL-28)', (tester) async {
      final gestos = await _montar(tester, pessoa: ana);

      await tester.tap(
        find.text(GaleraTextos.rotuloDoPapel(PapelNaFesta.coAnfitriao)),
      );
      await tester.pumpAndSettle();

      expect(gestos.papeis, isEmpty);
    });
  });

  group('GAL-16 — o painel do anfitrião, e o par que discrimina', () {
    testWidgets('o anfitrião vê a nota 👑 literal', (tester) async {
      await _montar(tester, pessoa: rafa);

      expect(
        find.text('👑 Anfitrião manda em tudo — acesso fixo.'),
        findsOneWidget,
      );
    });

    testWidgets('as três seções estão ausentes da árvore, não desabilitadas',
        (tester) async {
      await _montar(tester, pessoa: rafa);

      expect(_secao(GaleraTextos.secaoNivelDeAcesso), findsNothing);
      expect(_secao(GaleraTextos.secaoRestricao), findsNothing);
      expect(_secao(GaleraTextos.secaoBebida), findsNothing);
      expect(find.byType(BoraSegmentedControl), findsNothing);
      expect(find.byType(BotaoDeDieta), findsNothing);
    });

    testWidgets('quem não é anfitrião não vê a nota — o outro lado do par',
        (tester) async {
      await _montar(tester, pessoa: ana);

      expect(find.text(GaleraTextos.notaDoAnfitriao), findsNothing);
    });
  });

  group('GAL-27 AC2 — quem não gerencia papéis', () {
    testWidgets('sem a capacidade, "NÍVEL DE ACESSO" some e os outros ficam',
        (tester) async {
      await _montar(tester, pessoa: ana, podeGerenciarPapeis: false);

      expect(_secao(GaleraTextos.secaoNivelDeAcesso), findsNothing);
      expect(_secao(GaleraTextos.secaoRestricao), findsOneWidget);
      expect(_secao(GaleraTextos.secaoBebida), findsOneWidget);
      expect(find.byType(BotaoDeDieta), findsNWidgets(3));
    });

    testWidgets('com a capacidade, as três seções estão presentes',
        (tester) async {
      await _montar(tester, pessoa: ana);

      expect(_secao(GaleraTextos.secaoNivelDeAcesso), findsOneWidget);
      expect(_secao(GaleraTextos.secaoRestricao), findsOneWidget);
      expect(_secao(GaleraTextos.secaoBebida), findsOneWidget);
    });
  });

  group('Arquivo 02 §5, §8 — a moldura e os literais', () {
    testWidgets('o painel usa a espessura de borda de BoraExpandableRow',
        (tester) async {
      await _montar(tester, pessoa: ana);

      final superficie = tester.widget<BoraSurface>(
        find
            .descendant(
              of: find.byType(PainelDaPessoa),
              matching: find.byType(BoraSurface),
              matchRoot: true,
            )
            .first,
      );

      expect(
        superficie.larguraDaBorda,
        BoraExpandableRow.espessuraDaBordaDoPainel,
      );
      expect(superficie.fundo, BoraColors.paper);
    });

    test('sem literal de cor, de fonte ou de sombra', () {
      final fonte = File(_arquivoDoPainel).readAsStringSync();

      expect(fonte, isNot(contains('Color(0x')));
      expect(fonte, isNot(contains('fontFamily:')));
      expect(fonte, isNot(contains('BoxShadow(')));
    });
  });
}
