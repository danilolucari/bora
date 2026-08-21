import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_component.dart';

/// A largura do palco onde o card se estica.
const double _larguraDoPalco = 320;

const List<BoraListRow> _tresLinhas = [
  BoraListRow(emoji: '🥩', titulo: 'carne bovina', valor: 'R\$ 96'),
  BoraListRow(
    emoji: '🍺',
    titulo: 'cerveja',
    sublinha: '12 latas',
    valor: 'R\$ 60',
  ),
  BoraListRow(emoji: '🥖', titulo: 'pão de alho', valor: 'R\$ 18'),
];

/// A decoração do card: a superfície mais externa da subárvore.
BoxDecoration _cartao(WidgetTester tester) {
  final caixa = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(BoraListCard),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return caixa.decoration as BoxDecoration;
}

/// Os divisores da árvore: as caixas pintadas na cor `divider` de §1.
Finder _divisores() => find.descendant(
      of: find.byType(BoraListCard),
      matching: find.byWidgetPredicate(
        (widget) => widget is ColoredBox && widget.color == BoraColors.divider,
      ),
    );

TextStyle _estilo(WidgetTester tester, String texto) =>
    tester.widget<Text>(find.text(texto)).style!;

Future<void> _montar(
  WidgetTester tester, {
  List<BoraListRow> linhas = _tresLinhas,
}) {
  return pumpComponent(
    tester,
    SizedBox(width: _larguraDoPalco, child: BoraListCard(linhas: linhas)),
  );
}

void main() {
  group('DS-19 — a caixa do card', () {
    testWidgets('fundo branco, borda 2px ink, canto reto', (tester) async {
      await _montar(tester);

      final decoracao = _cartao(tester);

      expect(
        decoracao.color,
        BoraColors.white,
        reason: '§5: "Fundo branco, borda 2px ink"',
      );
      expect(decoracao.border!.top.width, 2.0);
      expect(decoracao.border!.top.color, BoraColors.ink);
      expect(decoracao.borderRadius, BorderRadius.zero, reason: '§3');
      expect(
        decoracao.boxShadow,
        isNull,
        reason: '§5 não dá sombra ao card de lista',
      );
    });
  });

  group('DS-19 — os divisores entre linhas', () {
    testWidgets('com 3 linhas há 2 divisores de 2px na cor divider',
        (tester) async {
      await _montar(tester);

      final divisores = _divisores();

      expect(
        divisores,
        findsNWidgets(2),
        reason: '§5: com n linhas há n-1 divisores',
      );
      expect(
        tester.getSize(divisores.first).height,
        2.0,
        reason: '§5: "separadas por 2px solid divider"',
      );
      expect(
        tester.getSize(divisores.first).width,
        _larguraDoPalco,
        reason: 'o divisor atravessa a linha inteira',
      );
    });

    testWidgets('com 1 linha não há divisor nenhum', (tester) async {
      await _montar(
        tester,
        linhas: const [BoraListRow(emoji: '🥩', titulo: 'carne bovina')],
      );

      expect(
        _divisores(),
        findsNothing,
        reason: 'edge case da spec: uma linha só não tem o que separar',
      );
      expect(find.text('carne bovina'), findsOneWidget);
    });
  });

  group('DS-19 — o desenho da linha', () {
    testWidgets('padding 12×14 e emoji colado na margem esquerda',
        (tester) async {
      await _montar(tester);

      final cartao = tester.getRect(find.byType(BoraListCard));
      final emoji = tester.getRect(find.text('🥩'));

      expect(
        emoji.left,
        cartao.left + BoraSpacing.linhaLista.left,
        reason: '§5: "linhas com padding 12–13px 14–16px", emoji à esquerda',
      );
      expect(BoraSpacing.linhaLista.top, 12.0);
      expect(BoraSpacing.linhaLista.left, 14.0);
      expect(
        emoji.top,
        greaterThanOrEqualTo(cartao.top + BoraSpacing.linhaLista.top),
      );
      expect(
        _estilo(tester, '🥩').fontSize,
        BoraListCard.tamanhoDoEmoji,
        reason: '§5: "emoji 19–20px à esquerda"',
      );
      expect(BoraListCard.tamanhoDoEmoji, 19.0);
    });

    testWidgets('título e sublinha à esquerda, depois do emoji',
        (tester) async {
      await _montar(tester);

      final emoji = tester.getRect(find.text('🍺'));
      final titulo = tester.getRect(find.text('cerveja'));
      final sublinha = tester.getRect(find.text('12 latas'));

      expect(
        titulo.left,
        greaterThanOrEqualTo(emoji.right),
        reason: '§5: o emoji é o que fica à esquerda',
      );
      expect(
        sublinha.left,
        titulo.left,
        reason: '§2: a sublinha alinha com o nome da linha',
      );
      expect(sublinha.top, greaterThanOrEqualTo(titulo.bottom));
      expect(
        _estilo(tester, 'cerveja').fontSize,
        14.0,
        reason: '§2: "Nome/linha de lista: Archivo 800 14px ink"',
      );
      expect(_estilo(tester, 'cerveja').fontWeight, FontWeight.w800);
      expect(_estilo(tester, 'cerveja').color, BoraColors.ink);
      expect(
        _estilo(tester, '12 latas').color,
        BoraColors.text2,
        reason: '§2: "sublinha 600 11.5–12px text-2"',
      );
      expect(_estilo(tester, '12 latas').fontWeight, FontWeight.w600);
    });

    testWidgets('o valor fica à direita, em 800 14px', (tester) async {
      await _montar(tester);

      final cartao = tester.getRect(find.byType(BoraListCard));
      final valor = tester.getRect(find.text('R\$ 96'));

      expect(
        valor.right,
        cartao.right - BoraSpacing.linhaLista.right,
        reason: '§5: "valor 800 14px à direita"',
      );
      expect(
        valor.left,
        greaterThan(tester.getRect(find.text('carne bovina')).right),
      );
      expect(_estilo(tester, 'R\$ 96').fontSize, 14.0);
      expect(_estilo(tester, 'R\$ 96').fontWeight, FontWeight.w800);
    });

    testWidgets('linha sem sublinha e sem valor desenha só emoji e título',
        (tester) async {
      await _montar(
        tester,
        linhas: const [BoraListRow(emoji: '🧊', titulo: 'gelo')],
      );

      expect(find.text('🧊'), findsOneWidget);
      expect(find.text('gelo'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(BoraListCard),
          matching: find.byType(Text),
        ),
        findsNWidgets(2),
        reason: 'sublinha e valor nulos não viram Text vazio',
      );
    });
  });

  group('DS-34 — o card não formata dinheiro', () {
    testWidgets('o valor sai exatamente como chegou', (tester) async {
      await _montar(
        tester,
        linhas: const [BoraListRow(emoji: '🥩', titulo: 'carne', valor: '211')],
      );

      expect(
        find.text('211'),
        findsOneWidget,
        reason: 'RN-13 é da spec calculo: o componente não põe "R\$" nem '
            'arredonda — desenha a String que recebeu',
      );
      expect(find.text('R\$ 211'), findsNothing);
    });
  });

  group('DS-19 — a linha é tocável', () {
    testWidgets('tocar a linha emite o onTap dela', (tester) async {
      final tocadas = <String>[];
      await _montar(
        tester,
        linhas: [
          BoraListRow(
            emoji: '🥩',
            titulo: 'carne bovina',
            onTap: () => tocadas.add('carne bovina'),
          ),
          BoraListRow(
            emoji: '🍺',
            titulo: 'cerveja',
            onTap: () => tocadas.add('cerveja'),
          ),
        ],
      );

      await tester.tap(find.text('cerveja'));
      await tester.pumpAndSettle();

      expect(tocadas, ['cerveja']);
    });
  });
}
