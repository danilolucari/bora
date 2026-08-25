import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A largura do palco. A borda de 2px de cada lado é pintada por trás do
/// conteúdo, então a barra de % percorre `320 − 4`.
const double _larguraDoPalco = 320;
const double _larguraInterna = _larguraDoPalco - 4;

Finder _opcao() => find.byType(BoraPollOption);

/// A caixa da opção: a superfície mais externa da subárvore.
BoxDecoration _caixa(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find.descendant(of: _opcao(), matching: find.byType(DecoratedBox)).first,
  );
  return caixa.decoration as BoxDecoration;
}

/// A barra de % que preenche o fundo.
Finder _preenchimento() => find.descendant(
      of: _opcao(),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == BoraColors.pollFill,
      ),
    );

/// O radio: a única caixa circular da subárvore.
Finder _radio() => find.descendant(
      of: _opcao(),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      ),
    );

BoxDecoration _decoracaoDoRadio(WidgetTester tester) =>
    tester.widget<DecoratedBox>(_radio()).decoration as BoxDecoration;

Future<void> _montar(
  WidgetTester tester, {
  String texto = 'sábado 20h',
  double fracao = 0.5,
  String percentualFormatado = '50%',
  String contagemFormatada = '6 votos',
  bool meuVoto = false,
  VoidCallback? onVotar,
}) {
  return pumpComponent(
    tester,
    SizedBox(
      width: _larguraDoPalco,
      child: BoraPollOption(
        texto: texto,
        fracao: fracao,
        percentualFormatado: percentualFormatado,
        contagemFormatada: contagemFormatada,
        meuVoto: meuVoto,
        onVotar: onVotar,
      ),
    ),
  );
}

void main() {
  group('DS-29 — a borda nos dois estados', () {
    testWidgets('sem o meu voto a borda é 2px ink, canto reto', (tester) async {
      await _montar(tester);

      final decoracao = _caixa(tester);

      expect(decoracao.border!.top.color, BoraColors.ink, reason: '§5');
      expect(decoracao.border!.top.width, 2.0);
      expect(decoracao.borderRadius, BorderRadius.zero, reason: '§3');
    });

    testWidgets('sendo o meu voto a borda vira #25D366', (tester) async {
      await _montar(tester, meuVoto: true);

      expect(
        _caixa(tester).border!.top.color,
        BoraColors.waGreen,
        reason: '§5: "#25D366 quando é seu voto"',
      );
      expect(_caixa(tester).border!.top.width, 2.0);
    });
  });

  group('DS-29 — a barra de % preenche o fundo', () {
    testWidgets('a largura é a fração recebida, na cor pollFill',
        (tester) async {
      await _montar(tester, fracao: 0.5);

      expect(
        tester.widget<ColoredBox>(_preenchimento()).color,
        BoraColors.pollFill,
        reason: '§5: "preenchendo o fundo com rgba(37,211,102,.18)"',
      );
      expect(tester.getSize(_preenchimento()).width, _larguraInterna / 2);
      expect(
        tester.getRect(_preenchimento()).left,
        tester.getRect(_opcao()).left + 2,
        reason: 'a barra cresce da esquerda e não cobre a borda de §3',
      );
    });

    testWidgets('0.0 não preenche e 1.0 preenche a largura interna inteira',
        (tester) async {
      await _montar(tester, fracao: 0);
      expect(tester.getSize(_preenchimento()).width, 0.0);

      await _montar(tester, fracao: 1);
      expect(tester.getSize(_preenchimento()).width, _larguraInterna);
    });

    testWidgets('fração fora da faixa clampa e a não finita não preenche',
        (tester) async {
      await _montar(tester, fracao: -0.3);
      expect(tester.getSize(_preenchimento()).width, 0.0);
      expect(tester.takeException(), isNull);

      await _montar(tester, fracao: 1.7);
      expect(tester.getSize(_preenchimento()).width, _larguraInterna);
      expect(tester.takeException(), isNull);

      await _montar(tester, fracao: double.nan);
      expect(tester.getSize(_preenchimento()).width, 0.0);
      expect(tester.takeException(), isNull);

      await _montar(tester, fracao: double.infinity);
      expect(tester.getSize(_preenchimento()).width, 0.0);
      expect(tester.takeException(), isNull);
    });
  });

  group('DS-29 — o radio é redondo, de 15px', () {
    testWidgets('círculo de 15×15 com contorno ink quando não votado',
        (tester) async {
      await _montar(tester);

      expect(
        _decoracaoDoRadio(tester).shape,
        BoxShape.circle,
        reason: '§3: "avatares e dots (círculo, 50%)" é a exceção de forma',
      );
      expect(
        tester.getSize(_radio()),
        const Size(15, 15),
        reason: '§5: "radio circular 15px"',
      );
      expect(_decoracaoDoRadio(tester).border!.top.color, BoraColors.ink);
      expect(_decoracaoDoRadio(tester).border!.top.width, 2.0);
    });

    testWidgets('votado, o radio fica verde', (tester) async {
      await _montar(tester, meuVoto: true);

      expect(
        _decoracaoDoRadio(tester).color,
        BoraColors.waGreen,
        reason: '§5: "verde quando votado"',
      );
      expect(_decoracaoDoRadio(tester).border!.top.color, BoraColors.waGreen);
      expect(_decoracaoDoRadio(tester).shape, BoxShape.circle);
    });
  });

  group('DS-29 e DS-34 — texto, percentual e contagem', () {
    testWidgets('o radio abre a linha, o percentual fecha à direita e a '
        'contagem fica abaixo', (tester) async {
      await _montar(tester);

      final radio = tester.getRect(_radio());
      final texto = tester.getRect(find.text('sábado 20h'));
      final percentual = tester.getRect(find.text('50%'));
      final contagem = tester.getRect(find.text('6 votos'));
      final opcao = tester.getRect(_opcao());

      expect(radio.left, lessThan(texto.left));
      expect(
        percentual.left,
        greaterThanOrEqualTo(texto.right),
        reason: '§5: "% à direita"',
      );
      expect(percentual.right, opcao.right - BoraSpacing.linhaLista.right);
      expect(
        contagem.top,
        greaterThanOrEqualTo(percentual.bottom),
        reason: '§5: contagem "n votos" abaixo',
      );
      expect(contagem.left, radio.left);
    });

    testWidgets('percentual e contagem saem exatamente como chegaram',
        (tester) async {
      await _montar(
        tester,
        percentualFormatado: '33%',
        contagemFormatada: '4 votos',
      );

      expect(
        find.text('33%'),
        findsOneWidget,
        reason: 'DS-34: quem conta os votos é de fora — a opção só desenha',
      );
      expect(find.text('4 votos'), findsOneWidget);
      expect(find.text('4'), findsNothing);
    });
  });

  group('DS-29 — votar', () {
    testWidgets('tocar a opção emite onVotar', (tester) async {
      var votos = 0;
      await _montar(tester, onVotar: () => votos++);

      await tester.tap(find.text('sábado 20h'));
      await tester.pumpAndSettle();

      expect(votos, 1);
    });

    testWidgets('sem onVotar, tocar não lança', (tester) async {
      await _montar(tester);

      await tester.tap(find.text('sábado 20h'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
