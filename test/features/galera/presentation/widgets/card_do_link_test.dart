import 'dart:io';

import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/presentation/galera_textos.dart';
import 'package:bora/features/galera/presentation/widgets/card_do_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/rn30_estado_inicial_tipado.dart';

const String _arquivoDoCard =
    'lib/features/galera/presentation/widgets/card_do_link.dart';

/// As duas viewports do produto: o frame do celular e a janela do web.
const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

/// O que o card emitiu enquanto o teste o exercitava.
class _Gestos {
  final List<NivelDoLink> niveis = [];
  int copias = 0;
}

Future<_Gestos> _montar(
  WidgetTester tester, {
  ConviteDaFesta? convite,
  bool podeConfigurarNivel = true,
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
          child: CardDoLink(
            convite: convite ?? conviteRn30Tipado,
            onCopiar: () => gestos.copias++,
            onEscolherNivel: gestos.niveis.add,
            podeConfigurarNivel: podeConfigurarNivel,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return gestos;
}

Finder _segmented() => find.byType(BoraSegmentedControl);

Finder _botaoCopiar() => find.byType(BoraSecondaryButton);

BoraSurface _superficieDoCard(WidgetTester tester) => tester.widget<BoraSurface>(
      find.descendant(
        of: find.byType(CardDoLink),
        matching: find.byType(BoraSurface),
        matchRoot: true,
      ).first,
    );

/// O `Text` de [texto] dentro do card — para olhar o estilo, não só a
/// presença (L-034: `find.text` acha texto ilegível).
Text _textoDo(WidgetTester tester, String texto) => tester.widget<Text>(
      find.descendant(
        of: find.byType(CardDoLink),
        matching: find.text(texto),
      ),
    );

/// O topo de [finder] na tela — é por ele que a ordem de T-05 é afirmada.
double _topoDe(WidgetTester tester, Finder finder) =>
    tester.getTopLeft(finder).dy;

void main() {
  final convite = conviteRn30Tipado;

  group('GAL-01 — o card na ordem de T-05', () {
    for (final viewport in _viewports.entries) {
      testWidgets('em ${viewport.key}, os cinco blocos aparecem na ordem',
          (tester) async {
        await _montar(tester, viewport: viewport.value);

        expect(find.text(GaleraTextos.labelDoLink), findsOneWidget);
        expect(find.text(GaleraTextos.urlDoConvite(convite.codigo)),
            findsOneWidget);
        expect(find.text(GaleraTextos.copiar), findsOneWidget);
        expect(find.text(GaleraTextos.quemAbrirPode), findsOneWidget);
        expect(_segmented(), findsOneWidget);

        final topos = [
          _topoDe(tester, find.text(GaleraTextos.labelDoLink)),
          _topoDe(
            tester,
            find.text(GaleraTextos.urlDoConvite(convite.codigo)),
          ),
          _topoDe(tester, _botaoCopiar()),
          _topoDe(tester, find.text(GaleraTextos.quemAbrirPode)),
          _topoDe(tester, _segmented()),
          _topoDe(tester, find.text(GaleraTextos.notaDoNivel(convite.nivel))),
        ];

        expect(topos, orderedEquals(List.of(topos)..sort()));
      });
    }

    testWidgets('o segmented oferece exatamente os três níveis de RN-23',
        (tester) async {
      await _montar(tester);

      final controle = tester.widget<BoraSegmentedControl>(_segmented());

      expect(controle.opcoes, ['SÓ VER', 'EDITAR LISTA', 'CO-ANFITRIÃO']);
      expect(controle.opcoes, hasLength(3));
      expect(controle.sobreCardEscuro, isTrue);
    });

    testWidgets('com a fixture, a URL na tela é bora.app/c/rafa18',
        (tester) async {
      await _montar(tester);

      expect(find.text('bora.app/c/rafa18'), findsOneWidget);
    });
  });

  group('GAL-01 — o card escuro de sombra roxa, contra o token', () {
    testWidgets('o fundo é ink e o acento é purple', (tester) async {
      await _montar(tester);

      final superficie = _superficieDoCard(tester);

      expect(superficie.fundo, BoraColors.ink);
      expect(superficie.acento, BoraAccent.purple);
      expect(superficie.deslocamentoDaSombra, BoraShadows.cardLink.offset.dx);
    });

    testWidgets('o fundo do card é opaco — a sombra dura não vaza por cima',
        (tester) async {
      await _montar(tester);

      expect(_superficieDoCard(tester).fundo.a, 1.0);
    });

    testWidgets('todo texto próprio do card é claro sobre o escuro',
        (tester) async {
      await _montar(tester);

      final claros = {BoraColors.cream, BoraColors.yellow};

      for (final texto in [
        GaleraTextos.labelDoLink,
        GaleraTextos.urlDoConvite(convite.codigo),
        GaleraTextos.quemAbrirPode,
        GaleraTextos.notaDoNivel(convite.nivel),
      ]) {
        expect(_textoDo(tester, texto).style?.color, isIn(claros),
            reason: texto);
      }
    });

    testWidgets('o "COPIAR 🔗" é o botão claro, não o transparente',
        (tester) async {
      await _montar(tester);

      expect(
        tester.widget<BoraSecondaryButton>(_botaoCopiar()).fundoBranco,
        isTrue,
      );
    });

    testWidgets('a URL é sublinhada, como T-05 desenha', (tester) async {
      await _montar(tester);

      expect(
        _textoDo(tester, GaleraTextos.urlDoConvite(convite.codigo))
            .style
            ?.decoration,
        TextDecoration.underline,
      );
    });
  });

  group('GAL-02 — a nota muda com o nível', () {
    for (final nivel in NivelDoLink.values) {
      testWidgets('o nível ${nivel.chave} exibe a nota literal de RN-23',
          (tester) async {
        await _montar(
          tester,
          convite: ConviteDaFesta(codigo: convite.codigo, nivel: nivel),
        );

        expect(find.text(GaleraTextos.notaDoNivel(nivel)), findsOneWidget);

        for (final outro in NivelDoLink.values) {
          if (outro == nivel) continue;
          expect(find.text(GaleraTextos.notaDoNivel(outro)), findsNothing);
        }
      });
    }

    testWidgets('o segmento ativo é o do nível vigente', (tester) async {
      await _montar(
        tester,
        convite: ConviteDaFesta(
          codigo: convite.codigo,
          nivel: NivelDoLink.coAnfitriao,
        ),
      );

      expect(
        tester.widget<BoraSegmentedControl>(_segmented()).indiceAtivo,
        NivelDoLink.values.indexOf(NivelDoLink.coAnfitriao),
      );
    });
  });

  group('GAL-04, GAL-28 — o gesto do nível', () {
    testWidgets('tocar outro nível emite aquele nível', (tester) async {
      final gestos = await _montar(
        tester,
        convite: ConviteDaFesta(
          codigo: convite.codigo,
          nivel: NivelDoLink.editarLista,
        ),
      );

      await tester.tap(find.text(GaleraTextos.rotuloDoNivel(NivelDoLink.soVer)));
      await tester.pumpAndSettle();

      expect(gestos.niveis, [NivelDoLink.soVer]);
    });

    testWidgets('tocar o nível já ativo não emite nada (GAL-28)',
        (tester) async {
      final gestos = await _montar(
        tester,
        convite: ConviteDaFesta(
          codigo: convite.codigo,
          nivel: NivelDoLink.editarLista,
        ),
      );

      await tester.tap(
        find.text(GaleraTextos.rotuloDoNivel(NivelDoLink.editarLista)),
      );
      await tester.pumpAndSettle();

      expect(gestos.niveis, isEmpty);
    });

    testWidgets('trocar de nível não exibe toast algum', (tester) async {
      await _montar(tester);

      await tester.tap(
        find.text(GaleraTextos.rotuloDoNivel(NivelDoLink.coAnfitriao)),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(BoraToastContent.toastKey), findsNothing);
      expect(find.text(GaleraTextos.linkCopiado), findsNothing);
    });

    testWidgets('o "COPIAR 🔗" emite a cópia', (tester) async {
      final gestos = await _montar(tester);

      await tester.tap(_botaoCopiar());
      await tester.pumpAndSettle();

      expect(gestos.copias, 1);
      expect(gestos.niveis, isEmpty);
    });
  });

  group('GAL-27 AC1 — o card de quem não configura o nível', () {
    testWidgets('sem a capacidade, o segmented some e o resto fica',
        (tester) async {
      await _montar(tester, podeConfigurarNivel: false);

      expect(_segmented(), findsNothing);
      expect(
        find.text(GaleraTextos.urlDoConvite(convite.codigo)),
        findsOneWidget,
      );
      expect(find.text(GaleraTextos.copiar), findsOneWidget);
      expect(find.text(GaleraTextos.notaDoNivel(convite.nivel)), findsOneWidget);
    });

    testWidgets('com a capacidade, os três estão presentes — o par que '
        'discrimina', (tester) async {
      await _montar(tester);

      expect(_segmented(), findsOneWidget);
      expect(
        find.text(GaleraTextos.urlDoConvite(convite.codigo)),
        findsOneWidget,
      );
      expect(find.text(GaleraTextos.copiar), findsOneWidget);
    });
  });

  group('GAL-24 AC2 — a festa sem código de link', () {
    testWidgets('sem código, o card não mostra URL e não inventa copy',
        (tester) async {
      await _montar(
        tester,
        convite: const ConviteDaFesta(codigo: '', nivel: NivelDoLink.soVer),
      );

      expect(find.text(GaleraTextos.urlDoConvite('')), findsNothing);
      expect(find.textContaining('bora.app'), findsNothing);
      expect(find.text(GaleraTextos.labelDoLink), findsOneWidget);
      expect(find.text(GaleraTextos.copiar), findsOneWidget);
    });

    testWidgets('sem código, o "COPIAR 🔗" fica inerte', (tester) async {
      final gestos = await _montar(
        tester,
        convite: const ConviteDaFesta(codigo: '', nivel: NivelDoLink.soVer),
      );

      expect(
        tester.widget<BoraSecondaryButton>(_botaoCopiar()).onPressed,
        isNull,
      );

      await tester.tap(_botaoCopiar());
      await tester.pumpAndSettle();

      expect(gestos.copias, 0);
    });
  });

  group('Arquivo 02 §8 — nenhum literal no arquivo', () {
    test('sem literal de cor, de fonte ou de sombra', () {
      final fonte = File(_arquivoDoCard).readAsStringSync();

      expect(fonte, isNot(contains('Color(0x')));
      expect(fonte, isNot(contains('fontFamily:')));
      expect(fonte, isNot(contains('BoxShadow(')));
    });
  });
}
