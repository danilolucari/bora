import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:bora/features/home/presentation/widgets/card_da_festa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';
import '../../../../fixtures/festas_da_home.dart';

/// Monta o card num palco largo o bastante para os dois botões caberem lado a
/// lado, como T-02 desenha.
Future<void> _montar(
  WidgetTester tester,
  ResumoDeFesta resumo, {
  bool confirmacaoNova = false,
  VoidCallback? aoConvidar,
  VoidCallback? aoMontarLista,
  VoidCallback? aoVerOAcerto,
  Size janela = const Size(390, 820),
}) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: CardDaFesta(
            resumo: resumo,
            confirmacaoNova: confirmacaoNova,
            aoConvidar: aoConvidar ?? () {},
            aoMontarLista: aoMontarLista ?? () {},
            aoVerOAcerto: aoVerOAcerto ?? () {},
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// A superfície do próprio card: os botões também usam `BoraSurface`, e a do
/// card é a primeira da árvore por estar acima deles.
Finder get _superficieDoCard => find.byType(BoraSurface).first;

ResumoDeFesta _com({
  int confirmados = 4,
  int pendentes = 2,
  List<String>? iniciais,
  String? nome,
}) =>
    ResumoDeFesta(
      id: rn30NaHome.id,
      festa: nome == null
          ? rn30NaHome.festa
          : rn30NaHome.festa.copyWith(nome: nome),
      confirmados: confirmados,
      pendentes: pendentes,
      iniciais: iniciais ?? rn30NaHome.iniciais,
    );

void main() {
  setUpAll(carregarFontesArchivo);

  group('HOME-04 — o card de T-02', () {
    testWidgets('mostra o nome da festa e a tag de data vazando o topo',
        (tester) async {
      await _montar(tester, rn30NaHome);

      expect(find.text('CHURRAS DO RAFA 🔥'), findsOneWidget);
      expect(find.text('SÁB · 18 JUL'), findsOneWidget);

      // A caixa do `BoraRotatedTag` fica na altura do card; quem sobe é o
      // conteúdo pintado. Por isso a medida é do **texto** da tag.
      final tag = tester.getRect(find.text('SÁB · 18 JUL'));
      final card = tester.getRect(_superficieDoCard);
      final vazamento = card.top - tag.top;

      expect(
        vazamento,
        greaterThan(0),
        reason: '§3: a tag é "posicionada vazando o card"',
      );
      expect(
        vazamento,
        lessThan(2 * -BoraRotatedTag.vazamentoDoTopo),
        reason: 'o vazamento é do componente, que já sobe os 13px sozinho — '
            'somar `top: -13` aqui subia 26 e a tag podia cortar no topo da '
            'rolagem',
      );
    });

    testWidgets('a tag é a rotacionada de +3° de T-02', (tester) async {
      await _montar(tester, rn30NaHome);

      expect(
        tester.widget<BoraRotatedTag>(find.byType(BoraRotatedTag)).aEsquerda,
        isFalse,
        reason: 'T-02: "tag de data rotacionada +3°", que é a da direita',
      );
    });

    testWidgets('o card é branco com a sombra dura de 6px preta',
        (tester) async {
      await _montar(tester, rn30NaHome);
      final superficie = tester.widget<BoraSurface>(_superficieDoCard);

      expect(superficie.fundo, BoraColors.white);
      expect(superficie.deslocamentoDaSombra, BoraShadows.distanciaCardHeroi);
      expect(
        superficie.acento,
        BoraAccent.ink,
        reason: 'T-02: "sombra 6px preta"',
      );
    });

    testWidgets('a linha lê "4 confirmados · 2 pendentes"', (tester) async {
      await _montar(tester, rn30NaHome);

      expect(find.text('4 confirmados · 2 pendentes'), findsOneWidget);
    });

    testWidgets('só os pendentes saem em vermelho', (tester) async {
      await _montar(tester, rn30NaHome);

      final linha = tester.widget<Text>(
        find.text('4 confirmados · 2 pendentes'),
      );
      final trechos = (linha.textSpan! as TextSpan).children!.cast<TextSpan>();

      expect(trechos.last.text, '2 pendentes');
      expect(trechos.last.style?.color, BoraColors.primary);
      expect(
        linha.style?.color ?? BoraColors.ink,
        isNot(BoraColors.primary),
        reason: 'T-02 pinta de vermelho só o número que cobra ação',
      );
    });

    testWidgets('os dois botões de T-02 estão lá, com o primário maior',
        (tester) async {
      await _montar(tester, rn30NaHome);

      expect(find.text('+ CONVIDAR'), findsOneWidget);
      expect(find.text('MONTAR LISTA →'), findsOneWidget);
      expect(
        tester.getSize(find.byType(BoraPrimaryButton)).width,
        greaterThan(tester.getSize(find.byType(BoraSecondaryButton)).width),
        reason: 'T-02: o primário tem flex 1.4 contra 1 do secundário',
      );
    });

    testWidgets('os toques voltam por callback — o card não navega',
        (tester) async {
      var convidou = 0;
      var montou = 0;
      await _montar(
        tester,
        rn30NaHome,
        aoConvidar: () => convidou++,
        aoMontarLista: () => montou++,
      );

      await tester.tap(find.text('+ CONVIDAR'));
      await tester.tap(find.text('MONTAR LISTA →'));
      await tester.pumpAndSettle();

      expect(convidou, 1);
      expect(montou, 1);
    });
  });

  group('HOME-04 — a pilha de avatares e o "+N"', () {
    testWidgets('com 4 confirmados e 3 avatares, o slot lê "+1"',
        (tester) async {
      await _montar(tester, _com(confirmados: 4));

      expect(find.text('R'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('L'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('com 3 confirmados, não há "+N"', (tester) async {
      await _montar(tester, _com(confirmados: 3));

      expect(
        tester
            .widget<BoraStackedAvatars>(find.byType(BoraStackedAvatars))
            .extras,
        0,
      );
      expect(
        find.textContaining(RegExp(r'^\+\d')),
        findsNothing,
        reason: 'é o par que discrimina: um "+N" sempre desenhado passaria no '
            'teste de cima. O padrão exige dígito depois do "+" para não '
            'casar com o botão "+ CONVIDAR"',
      );
    });

    testWidgets('com 6 confirmados, o slot lê "+3"', (tester) async {
      await _montar(tester, _com(confirmados: 6));

      expect(find.text('+3'), findsOneWidget);
    });
  });

  group('HOME-04 — a copy dos contadores tem singular', () {
    testWidgets('depois do RSVP, lê "5 confirmados · 1 pendente"',
        (tester) async {
      await _montar(tester, _com(confirmados: 5, pendentes: 1));

      expect(
        find.text('5 confirmados · 1 pendente'),
        findsOneWidget,
        reason: 'T-02 dá as duas formas literalmente: "2 pendentes" antes e '
            '"1 pendente" depois da confirmação',
      );
    });

    testWidgets('com 0 pendentes, o termo continua na tela', (tester) async {
      await _montar(tester, _com(confirmados: 5, pendentes: 0));

      expect(
        find.text('5 confirmados · 0 pendentes'),
        findsOneWidget,
        reason: 'edge case da spec: sem esconder o termo e sem texto especial, '
            'que nenhuma spec define',
      );
    });

    testWidgets('com 1 confirmado, o singular vale dos dois lados',
        (tester) async {
      await _montar(tester, _com(confirmados: 1, pendentes: 1));

      expect(find.text('1 confirmado · 1 pendente'), findsOneWidget);
    });
  });

  group('HOME-10 — o atalho do acerto entra com a confirmação (RN-28)', () {
    testWidgets('com confirmação nova, o atalho amarelo aparece',
        (tester) async {
      await _montar(tester, rn30NaHome, confirmacaoNova: true);

      expect(find.text('💸 VER O ACERTO DA FESTA →'), findsOneWidget);
    });

    testWidgets('sem confirmação nova, ele não está na tela', (tester) async {
      await _montar(tester, rn30NaHome);

      expect(
        find.text('💸 VER O ACERTO DA FESTA →'),
        findsNothing,
        reason: 'P1-3 AC3 é o par discriminante: um teste que só afirmasse a '
            'presença passaria com o botão sempre visível',
      );
    });

    testWidgets('é amarelo e ocupa a largura toda do card', (tester) async {
      await _montar(tester, rn30NaHome, confirmacaoNova: true);

      final atalho = find.ancestor(
        of: find.text('💸 VER O ACERTO DA FESTA →'),
        matching: find.byType(BoraPressSink),
      );

      expect(
        tester.widget<BoraPressSink>(atalho).fundo,
        BoraColors.yellow,
        reason: 'T-02: "botão amarelo full-width"',
      );
      expect(
        tester.getSize(atalho).width,
        tester.getSize(find.byType(BoraPrimaryButton)).width +
            tester.getSize(find.byType(BoraSecondaryButton)).width +
            10,
        reason: 'full-width é a largura dos dois botões mais o vão entre eles',
      );
    });

    testWidgets('o toque volta por callback', (tester) async {
      var viu = 0;
      await _montar(
        tester,
        rn30NaHome,
        confirmacaoNova: true,
        aoVerOAcerto: () => viu++,
      );

      await tester.tap(find.text('💸 VER O ACERTO DA FESTA →'));
      await tester.pumpAndSettle();

      expect(viu, 1);
    });
  });

  group('W-R4 — nome longo não estoura o card', () {
    testWidgets('trunca sem overflow e sem scroll horizontal', (tester) async {
      await _montar(
        tester,
        _com(
          nome: 'CHURRAS DE CONFRATERNIZAÇÃO DO PESSOAL DA LAJE DA VILA '
              'MADALENA COM TODO MUNDO 🔥',
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(_superficieDoCard).right,
        lessThanOrEqualTo(tester.getRect(find.byType(Scaffold)).right),
      );
    });
  });
}
