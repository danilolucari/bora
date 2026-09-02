import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/galera/presentation/widgets/faixa_de_preferencias.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/galera_de_teste.dart';

const String _arquivoDaFaixa =
    'lib/features/galera/presentation/widgets/faixa_de_preferencias.dart';

/// As duas viewports do produto: o frame do celular e a janela do web.
const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

/// O resumo que `core/calculo` devolve para [composicao] — a **mesma** função
/// que a faixa consome. É contra ela que a asserção compara, e não contra uma
/// frase reescrita no teste (GAL-13 AC5).
String _resumoDe(ComposicaoDaFesta composicao) => resumoDasPreferencias(
      efeitosDasPreferencias(
        pessoas: composicao.pessoas,
        adultos: composicao.contagem.adultos,
      ),
    );

Future<void> _montar(
  WidgetTester tester, {
  required ComposicaoDaFesta composicao,
  Size viewport = _frameCompacto,
}) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: FaixaDePreferencias(composicao: composicao),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// A composição da fixture com as pessoas trocadas — tudo o mais igual.
ComposicaoDaFesta _com(List<Pessoa> pessoas) =>
    galeraDeTeste(pessoas: pessoas).composicao;

/// O arquivo da faixa **sem os comentários** — é o código que a guarda de
/// GAL-15 olha, no molde de `design.md` §13: o doc **cita** a frase de T-05 de
/// propósito, e citar não é montar.
String _codigoDaFaixa() => File(_arquivoDaFaixa)
    .readAsLinesSync()
    .where((linha) => !linha.trimLeft().startsWith('//'))
    .join('\n');

Finder _superficie() => find.descendant(
      of: find.byType(FaixaDePreferencias),
      matching: find.byType(BoraSurface),
    );

void main() {
  final daFixture = galeraDeTeste().composicao;

  group('GAL-13 AC6 — a faixa da fixture de RN-30', () {
    for (final viewport in _viewports.entries) {
      testWidgets('em ${viewport.key}, lê a frase literal de T-05',
          (tester) async {
        await _montar(tester, composicao: daFixture, viewport: viewport.value);

        expect(
          find.text(
            '💡 A lista já se ajusta às preferências: 1 veggie 🥗 · '
            '1 sem porco 🚫 · 3 bebem 🍺',
          ),
          findsOneWidget,
        );
      });
    }

    testWidgets('o texto é o que resumoDasPreferencias devolve, com "💡 "',
        (tester) async {
      await _montar(tester, composicao: daFixture);

      expect(find.text('💡 ${_resumoDe(daFixture)}'), findsOneWidget);
    });
  });

  group('GAL-13 AC5 — os termos zerados somem, como RN-21 manda', () {
    testWidgets('só veggie: a faixa traz um termo e não os outros dois',
        (tester) async {
      final composicao = _com([pessoaDeTeste('Nina', dieta: Dieta.veggie)]);

      await _montar(tester, composicao: composicao);

      expect(find.text('💡 ${_resumoDe(composicao)}'), findsOneWidget);
      expect(find.textContaining('veggie 🥗'), findsOneWidget);
      expect(find.textContaining('sem porco 🚫'), findsNothing);
      expect(find.textContaining('bebem 🍺'), findsNothing);
    });

    testWidgets('só quem bebe: a faixa traz o termo da bebida sozinho',
        (tester) async {
      final composicao = _com([pessoaDeTeste('Nina', bebe: true)]);

      await _montar(tester, composicao: composicao);

      expect(find.text('💡 ${_resumoDe(composicao)}'), findsOneWidget);
      expect(find.textContaining('bebem 🍺'), findsOneWidget);
      expect(find.textContaining('veggie 🥗'), findsNothing);
    });

    testWidgets('a faixa é derivada: trocar a dieta troca a string exibida',
        (tester) async {
      final antes = _com([pessoaDeTeste('Nina', dieta: Dieta.veggie)]);
      final depois = _com([pessoaDeTeste('Nina', dieta: Dieta.semPorco)]);

      await _montar(tester, composicao: antes);
      expect(find.text('💡 ${_resumoDe(antes)}'), findsOneWidget);

      await _montar(tester, composicao: depois);

      expect(find.text('💡 ${_resumoDe(depois)}'), findsOneWidget);
      expect(find.text('💡 ${_resumoDe(antes)}'), findsNothing);
    });
  });

  group('GAL-13 AC7 — sem termo nenhum, a faixa não renderiza', () {
    testWidgets('festa sem pessoa nomeada não desenha faixa alguma',
        (tester) async {
      final composicao = _com([]);

      await _montar(tester, composicao: composicao);

      expect(_resumoDe(composicao), isEmpty);
      expect(_superficie(), findsNothing);
      expect(find.textContaining('💡'), findsNothing);
    });

    testWidgets('pessoa sem preferência declarada também não desenha faixa',
        (tester) async {
      await _montar(tester, composicao: _com([pessoaDeTeste('Duda')]));

      expect(_superficie(), findsNothing);
    });

    testWidgets('uma preferência declarada já traz a faixa de volta — o par '
        'que discrimina', (tester) async {
      await _montar(
        tester,
        composicao: _com([pessoaDeTeste('Duda', dieta: Dieta.veggie)]),
      );

      expect(_superficie(), findsOneWidget);
    });
  });

  group('T-05 — a faixa amarela de borda 2px', () {
    testWidgets('o fundo é o amarelo do token e a borda tem 2px',
        (tester) async {
      await _montar(tester, composicao: daFixture);

      final superficie = tester.widget<BoraSurface>(_superficie());

      expect(superficie.fundo, BoraColors.yellow);
      expect(superficie.larguraDaBorda, 2);
      expect(superficie.acento, isNull);
    });

    testWidgets('o texto é escuro sobre o amarelo — não é o text-2 da dica',
        (tester) async {
      await _montar(tester, composicao: daFixture);

      final texto = tester.widget<Text>(
        find.descendant(
          of: find.byType(FaixaDePreferencias),
          matching: find.byType(Text),
        ),
      );

      expect(texto.style?.color, BoraColors.ink);
      expect(texto.style?.color, isNot(BoraColors.text2));
    });
  });

  group('GAL-15 — a feature não recompõe a frase', () {
    test('o código não contém o template de RN-21 nem termo do resumo', () {
      final codigo = _codigoDaFaixa();

      expect(codigo, isNot(contains('já se ajusta às preferências:')));
      expect(codigo, isNot(contains('veggie 🥗')));
      expect(codigo, isNot(contains('sem porco 🚫')));
      expect(codigo, isNot(contains('bebem 🍺')));
    });

    test('a única concatenação é a de GaleraTextos.faixa', () {
      final codigo = _codigoDaFaixa();

      expect(codigo, contains('GaleraTextos.faixa('));
      expect(codigo, isNot(contains('💡')));
      expect(codigo, isNot(contains('math.')));
    });

    test('sem literal de cor, de fonte ou de sombra', () {
      final fonte = File(_arquivoDaFaixa).readAsStringSync();

      expect(fonte, isNot(contains('Color(0x')));
      expect(fonte, isNot(contains('fontFamily:')));
      expect(fonte, isNot(contains('BoxShadow(')));
    });
  });
}
