import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/montar/domain/rascunho_inicial.dart';
import 'package:bora/features/montar/presentation/widgets/rodape_do_custo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';

const String _arquivoDoRodape =
    'lib/features/montar/presentation/widgets/rodape_do_custo.dart';

/// O estado padrão de RN-30: 3 homens + 3 mulheres + 1 criança, 4h e os sete
/// itens padrão — a composição do aceite de UC-03.
ComposicaoDaFesta get _composicaoRn30 => ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: duracaoDefaultDoRole,
      itensSelecionados: itensPadraoDoRole,
    );

/// Um `int` cresce por cópia; o contador precisa de uma caixa para o teste
/// enxergar o toque.
class _Contador {
  int toques = 0;
}

Future<_Contador> _montar(
  WidgetTester tester, {
  ComposicaoDaFesta? composicao,
}) async {
  final contador = _Contador();

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(const Size(390, 820));
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: Align(
          alignment: Alignment.bottomCenter,
          child: RodapeDoCusto(
            resultado:
                CalculadoraDaFesta.calcular(composicao ?? _composicaoRn30),
            aoFecharLista: () => contador.toques++,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return contador;
}

void main() {
  setUpAll(carregarFontesArchivo);

  final resultadoRn30 = CalculadoraDaFesta.calcular(_composicaoRn30);

  group('MONT-03 — o rodapé fixo de T-03', () {
    testWidgets('é o rodapé do design system, com o rótulo "SAI POR"',
        (tester) async {
      await _montar(tester);

      expect(find.byType(BoraFooterBar), findsOneWidget);
      expect(find.text('SAI POR'), findsOneWidget);
    });

    testWidgets('traz o CTA "FECHAR LISTA →"', (tester) async {
      await _montar(tester);

      expect(find.text('FECHAR LISTA →'), findsOneWidget);
      expect(find.byType(BoraPrimaryButton), findsOneWidget);
    });
  });

  group('MONT-05 — o aceite de UC-03, na tela', () {
    testWidgets('com o estado padrão de RN-30 o total é R\$ 211',
        (tester) async {
      await _montar(tester);

      expect(find.text('R\$ 211'), findsOneWidget);
    });

    testWidgets('e a sublinha é "≈ R\$ 30 / cabeça"', (tester) async {
      await _montar(tester);

      expect(find.text('≈ R\$ 30 / cabeça'), findsOneWidget);
    });
  });

  group('MONT-07 / RN-13 — todo valor vem de MoneyFormatter', () {
    testWidgets('o total exibido é o token sobre totalDosItens',
        (tester) async {
      await _montar(tester);

      expect(
        tester.widget<BoraFooterBar>(find.byType(BoraFooterBar)).valorFormatado,
        MoneyFormatter.reais(resultadoRn30.totalDosItens),
      );
    });

    testWidgets('a sublinha carrega o token sobre porCabeca', (tester) async {
      await _montar(tester);

      expect(
        tester.widget<BoraFooterBar>(find.byType(BoraFooterBar)).sublinha,
        contains(MoneyFormatter.reais(resultadoRn30.porCabeca)),
      );
    });

    testWidgets('total com centavos aparece como inteiro — 210,60 vira o '
        'arredondado de RN-13', (tester) async {
      await _montar(tester);

      expect(resultadoRn30.totalDosItens, closeTo(210.60, 0.001));
      expect(find.text(MoneyFormatter.reais(210.60)), findsOneWidget);
      expect(find.textContaining(','), findsNothing);
    });

    testWidgets('o rodapé não escreve dinheiro por conta própria',
        (tester) async {
      expect(File(_arquivoDoRodape).readAsStringSync(), isNot(contains(r'R$')));
    });
  });

  group('MONT-06 / RN-14 — o divisor é pessoas, e o rótulo é "/ cabeça"', () {
    testWidgets('mostra o por cabeça, não o por adulto — os dois divergem '
        'nesta composição', (tester) async {
      await _montar(tester);

      expect(
        MoneyFormatter.reais(resultadoRn30.porCabeca),
        isNot(MoneyFormatter.reais(resultadoRn30.porAdulto)),
      );
      expect(
        find.text('≈ ${MoneyFormatter.reais(resultadoRn30.porCabeca)} / cabeça'),
        findsOneWidget,
      );
      expect(
        find.textContaining(MoneyFormatter.reais(resultadoRn30.porAdulto)),
        findsNothing,
      );
    });

    testWidgets('a criança conta no divisor: tirá-la muda o valor por cabeça',
        (tester) async {
      await _montar(
        tester,
        composicao: ComposicaoDaFesta(
          contagem: ContagemDePessoas(homens: 3, mulheres: 3),
          duracaoHoras: duracaoDefaultDoRole,
          itensSelecionados: itensPadraoDoRole,
        ),
      );

      final semCrianca = CalculadoraDaFesta.calcular(
        ComposicaoDaFesta(
          contagem: ContagemDePessoas(homens: 3, mulheres: 3),
          duracaoHoras: duracaoDefaultDoRole,
          itensSelecionados: itensPadraoDoRole,
        ),
      );

      expect(
        find.text('≈ ${MoneyFormatter.reais(semCrianca.porCabeca)} / cabeça'),
        findsOneWidget,
      );
      expect(find.text('≈ R\$ 30 / cabeça'), findsNothing);
    });

    testWidgets('a palavra "adulto" não aparece no rodapé desta tela',
        (tester) async {
      await _montar(tester);

      expect(find.textContaining('adulto'), findsNothing);
    });
  });

  group('MONT-20 — o CTA emite uma vez por toque', () {
    testWidgets('um toque, uma emissão', (tester) async {
      final contador = await _montar(tester);

      await tester.tap(find.text('FECHAR LISTA →'));
      expect(contador.toques, 1);

      await tester.tap(find.text('FECHAR LISTA →'));
      expect(contador.toques, 2);
    });
  });
}
