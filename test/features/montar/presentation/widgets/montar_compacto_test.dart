import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/montar/domain/rascunho_inicial.dart';
import 'package:bora/features/montar/presentation/bloc/montar_event.dart';
import 'package:bora/features/montar/presentation/bloc/montar_state.dart';
import 'package:bora/features/montar/presentation/widgets/cabecalho_do_role.dart';
import 'package:bora/features/montar/presentation/widgets/formulario_de_montagem.dart';
import 'package:bora/features/montar/presentation/widgets/montar_compacto.dart';
import 'package:bora/features/montar/presentation/widgets/rodape_do_custo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';

const Size _janelaCompacta = Size(390, 820);

/// Tudo o que a tela devolveu — nenhuma navegação sai daqui (AD-020).
class _Emitidos {
  int voltas = 0;
  int fechamentos = 0;
  final List<(TipoDeCabeca, int)> contagem = [];
  final List<ChaveItem> itens = [];
  final List<int> duracoes = [];
}

/// O estado da tela para uma composição — o resultado sai da calculadora, que
/// é a única fonte de conta do app.
MontarState _estadoCom(ComposicaoDaFesta composicao) => MontarState(
      festa: rascunhoInicial(hoje: DateTime(2026, 7, 15)).festa,
      composicao: composicao,
      resultado: CalculadoraDaFesta.calcular(composicao),
    );

/// O estado padrão de RN-30, o do aceite de UC-03.
ComposicaoDaFesta get _composicaoRn30 => ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: duracaoDefaultDoRole,
      itensSelecionados: itensPadraoDoRole,
    );

/// A festa sem ninguém, com os chips do template marcados — UC-03 E1.
ComposicaoDaFesta get _composicaoSemNinguem => ComposicaoDaFesta(
      contagem: ContagemDePessoas(),
      duracaoHoras: duracaoDefaultDoRole,
      itensSelecionados: itensPadraoDoRole,
    );

Future<_Emitidos> _montar(
  WidgetTester tester, {
  ComposicaoDaFesta? composicao,
}) async {
  final emitidos = _Emitidos();

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(_janelaCompacta);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: MontarCompacto(
          estado: _estadoCom(composicao ?? _composicaoRn30),
          aoVoltar: () => emitidos.voltas++,
          aoAlterarContagem: (tipo, delta) =>
              emitidos.contagem.add((tipo, delta)),
          aoAlternarItem: emitidos.itens.add,
          aoSelecionarDuracao: emitidos.duracoes.add,
          aoAlterarNome: (_) {},
          aoAlterarData: (_) {},
          aoFecharLista: () => emitidos.fechamentos++,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return emitidos;
}

double _topoDe(WidgetTester tester, Finder alvo) =>
    tester.getTopLeft(alvo).dy;

void main() {
  setUpAll(carregarFontesArchivo);

  group('MONT-01 — T-03 em 390×820, na ordem da spec', () {
    testWidgets('voltar, título, identidade, formulário e rodapé, nessa ordem',
        (tester) async {
      await _montar(tester);

      final ordem = [
        _topoDe(tester, find.byKey(MontarCompacto.chaveDoVoltar)),
        _topoDe(tester, find.text('A CONTA DO ROLÊ')),
        _topoDe(tester, find.byType(CabecalhoDoRole)),
        _topoDe(tester, find.byType(FormularioDeMontagem)),
        _topoDe(tester, find.byType(RodapeDoCusto)),
      ];

      expect(ordem, orderedEquals(List<double>.from(ordem)..sort()));
    });

    testWidgets('a identidade do rolê mostra nome e data', (tester) async {
      await _montar(tester);

      expect(find.text(nomeDefaultDoRole), findsOneWidget);
      expect(find.byType(CabecalhoDoRole), findsOneWidget);
    });

    testWidgets('as cinco seções e os 11 chips estão na tela — AD-018 inclusa',
        (tester) async {
      await _montar(tester);

      expect(find.text('CONFIRMADOS + EXTRAS SEM APP'), findsOneWidget);
      expect(find.text('NA GRELHA'), findsOneWidget);
      expect(find.text('NA GELADEIRA'), findsOneWidget);
      expect(find.text('PROS FORTES'), findsOneWidget);
      expect(find.text('QUANTO TEMPO DE FESTA?'), findsOneWidget);
      expect(find.byType(BoraSelectionChip), findsNWidgets(11));
    });

    testWidgets('nenhum overflow em 390×820, com tudo montado',
        (tester) async {
      await _montar(tester);

      expect(tester.takeException(), isNull);
    });
  });

  group('MONT-03 — o rodapé é fixo, e o formulário rola por baixo dele', () {
    testWidgets('rolar move o formulário e não move o rodapé', (tester) async {
      await _montar(tester);

      final rodapeAntes = tester.getRect(find.byType(RodapeDoCusto));
      final grelhaAntes = tester.getTopLeft(find.text('NA GRELHA')).dy;

      await tester.drag(find.text('NA GRELHA'), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(tester.getTopLeft(find.text('NA GRELHA')).dy,
          lessThan(grelhaAntes));
      expect(tester.getRect(find.byType(RodapeDoCusto)), rodapeAntes);
    });

    testWidgets('o SAI POR continua visível depois de rolar', (tester) async {
      await _montar(tester);

      await tester.drag(find.text('NA GRELHA'), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.text('SAI POR'), findsOneWidget);
      expect(find.text('R\$ 211'), findsOneWidget);
    });

    testWidgets('o rodapé encosta no fim da tela', (tester) async {
      await _montar(tester);

      expect(
        tester.getRect(find.byType(RodapeDoCusto)).bottom,
        _janelaCompacta.height,
      );
    });
  });

  group('MONT-05 — o aceite de UC-03 na tela compacta', () {
    testWidgets('o estado padrão de RN-30 dá R\$ 211 e ≈ R\$ 30 / cabeça',
        (tester) async {
      await _montar(tester);

      expect(find.text('R\$ 211'), findsOneWidget);
      expect(find.text('≈ R\$ 30 / cabeça'), findsOneWidget);
    });
  });

  // P1-2 AC1 / UC-04: "sem botão 'calcular'". O aceite é uma **ausência**, e
  // ausência só se prova afirmando que ela não está lá — sem isto, plantar um
  // CTA "CALCULAR" na tela não acusa nada, ou acusa por acidente noutro teste.
  group('MONT-04 / UC-04 — não existe passo de "calcular" na tela compacta', () {
    testWidgets('nenhum controle da tela oferece "calcular"', (tester) async {
      await _montar(tester);

      expect(
        find.textContaining(RegExp('CALCULAR', caseSensitive: false)),
        findsNothing,
        reason: 'o custo recalcula a cada toque: um botão de confirmar a '
            'conta seria um passo que UC-04 nega',
      );
    });
  });

  group('MONT-14 / UC-03 E1 — a festa sem ninguém', () {
    testWidgets('o rodapé mostra o zero de MoneyFormatter nos dois valores',
        (tester) async {
      await _montar(tester, composicao: _composicaoSemNinguem);

      expect(find.text(MoneyFormatter.reais(0)), findsOneWidget);
      expect(
        find.text('≈ ${MoneyFormatter.reais(0)} / cabeça'),
        findsOneWidget,
      );
    });

    testWidgets('o − fica inerte nas três linhas', (tester) async {
      await _montar(tester, composicao: _composicaoSemNinguem);

      final steppers = tester.widgetList<BoraStepper>(find.byType(BoraStepper));

      expect(steppers, hasLength(3));
      expect(steppers.every((s) => s.onDecrementar == null), isTrue);
    });

    testWidgets('tocar o − no piso não emite nada', (tester) async {
      final emitidos = await _montar(tester, composicao: _composicaoSemNinguem);

      for (var linha = 0; linha < 3; linha++) {
        await tester.tap(
          find.descendant(
            of: find.byType(BoraStepper).at(linha),
            matching: find.text(BoraStepper.simboloMenos),
          ),
        );
      }

      expect(emitidos.contagem, isEmpty);
    });

    testWidgets('com gente, o − volta a existir', (tester) async {
      await _montar(tester);

      final steppers = tester.widgetList<BoraStepper>(find.byType(BoraStepper));

      expect(steppers.every((s) => s.onDecrementar != null), isTrue);
    });
  });

  group('MONT-22 — as saídas da tela emitem intenção, e não navegam', () {
    testWidgets('o voltar emite a intenção de voltar', (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(find.byKey(MontarCompacto.chaveDoVoltar));

      expect(emitidos.voltas, 1);
      expect(emitidos.fechamentos, 0);
    });

    testWidgets('o CTA do rodapé emite fechar lista', (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(find.text('FECHAR LISTA →'));

      expect(emitidos.fechamentos, 1);
      expect(emitidos.voltas, 0);
    });

    testWidgets('os controles do formulário chegam inteiros à tela',
        (tester) async {
      final emitidos = await _montar(tester);

      await tester.ensureVisible(find.text('🍺 CERVEJA'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('🍺 CERVEJA'));

      // O segmented mora no fim da rolagem — AD-018 alongou T-03, e chegar
      // nele é rolar, como o anfitrião faz.
      await tester.ensureVisible(find.text('2H'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2H'));

      expect(emitidos.itens, [ChaveItem.cerveja]);
      expect(emitidos.duracoes, [2]);
    });
  });
}
