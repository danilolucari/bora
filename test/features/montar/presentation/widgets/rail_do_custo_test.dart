import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/montar/domain/rascunho_inicial.dart';
import 'package:bora/features/montar/presentation/montar_textos.dart';
import 'package:bora/features/montar/presentation/widgets/lista_viva.dart';
import 'package:bora/features/montar/presentation/widgets/rail_do_custo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';

/// A janela de referência de W-03.
const Size _janelaExpandida = Size(1180, 800);

/// O estado padrão de RN-30, o do aceite de UC-03.
ComposicaoDaFesta _composicaoRn30({int? duracaoHoras}) => ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: duracaoHoras ?? duracaoDefaultDoRole,
      itensSelecionados: itensPadraoDoRole,
    );

/// Tudo o que o rail devolveu — nenhuma navegação sai daqui (AD-020).
class _Emitidos {
  int envios = 0;
  int salvamentos = 0;
}

Future<(_Emitidos, ResultadoDoCalculo)> _montar(
  WidgetTester tester, {
  ComposicaoDaFesta? composicao,
}) async {
  final emitidos = _Emitidos();
  final entrada = composicao ?? _composicaoRn30();
  final resultado = CalculadoraDaFesta.calcular(entrada);

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(_janelaExpandida);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: Align(
          alignment: Alignment.topRight,
          child: RailDoCusto(
            resultado: resultado,
            duracaoHoras: entrada.duracaoHoras,
            aoMandarNoGrupo: () => emitidos.envios++,
            aoSalvar: () => emitidos.salvamentos++,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return (emitidos, resultado);
}

double _topoDe(WidgetTester tester, Finder alvo) => tester.getTopLeft(alvo).dy;

BoraHeroCard _heroi(WidgetTester tester) =>
    tester.widget<BoraHeroCard>(find.byType(BoraHeroCard));

void main() {
  setUpAll(carregarFontesArchivo);

  group('MONT-10 — a ordem dos quatro blocos do rail (W-03)', () {
    testWidgets('card-herói, lista viva, MANDAR NO GRUPO e SALVAR ROLÊ, '
        'nessa ordem de cima para baixo', (tester) async {
      await _montar(tester);

      final ordem = [
        _topoDe(tester, find.byType(BoraHeroCard)),
        _topoDe(tester, find.byType(ListaViva)),
        _topoDe(tester, find.byType(BoraPrimaryButton)),
        _topoDe(tester, find.byType(BoraSecondaryButton)),
      ];

      expect(ordem, orderedEquals(List<double>.from(ordem)..sort()));
    });

    testWidgets('a lista viva do rail mostra os itens da mesma composição',
        (tester) async {
      final (_, resultado) = await _montar(tester);

      expect(find.byType(ListaViva), findsOneWidget);
      expect(
        tester.widget<ListaViva>(find.byType(ListaViva)).resultado,
        same(resultado),
        reason: 'card-herói e lista viva leem o mesmo objeto — é o que faz '
            'MONT-12 ser estrutural',
      );
    });
  });

  group('MONT-10 — o card-herói escuro', () {
    testWidgets('a label é "SAI POR · {N} PESSOAS · {duração}" com N vindo da '
        'contagem', (tester) async {
      final (_, resultado) = await _montar(tester);

      expect(resultado.contagem.pessoas, 7);
      expect(
        _heroi(tester).label,
        MontarTextos.labelDoHeroi(pessoas: 7, duracaoHoras: 4),
      );
      expect(
        find.text(
          MontarTextos.labelDoHeroi(pessoas: 7, duracaoHoras: 4).toUpperCase(),
        ),
        findsOneWidget,
      );
    });

    testWidgets('o total é o de MoneyFormatter — R\$ 211 com o estado de '
        'RN-30', (tester) async {
      final (_, resultado) = await _montar(tester);

      expect(
        _heroi(tester).valorFormatado,
        MoneyFormatter.reais(resultado.totalDosItens),
      );
      expect(find.text(r'R$ 211'), findsOneWidget);
    });

    testWidgets('a sublinha é "dividido dá R\$ {x} por cabeça", com o mesmo '
        'número do compacto', (tester) async {
      final (_, resultado) = await _montar(tester);

      final porCabeca = MoneyFormatter.reais(resultado.porCabeca);

      expect(
        _heroi(tester).sublinha,
        MontarTextos.porCabecaExpandido(porCabeca),
      );
      expect(
        find.text(MontarTextos.porCabecaExpandido(porCabeca)),
        findsOneWidget,
      );
      expect(porCabeca, r'R$ 30');
    });

    testWidgets('o total com centavos exibe o inteiro de RN-13', (tester) async {
      final (_, resultado) = await _montar(tester);

      expect(resultado.totalDosItens, closeTo(210.6, 0.001));
      expect(_heroi(tester).valorFormatado, isNot(contains(',')));
    });
  });

  group('MONT-07 — a duração no rótulo do herói (RN-13, A-15)', () {
    testWidgets('10 horas exibe "Dia todo", e não "10 horas"', (tester) async {
      await _montar(tester, composicao: _composicaoRn30(duracaoHoras: 10));

      final label = _heroi(tester).label;

      expect(label, contains(rotuloDeDuracao(10)));
      expect(label, isNot(contains('10 horas')));
      expect(find.text(label.toUpperCase()), findsOneWidget);
    });

    testWidgets('2 horas exibe o rótulo de rotuloDeDuracao', (tester) async {
      await _montar(tester, composicao: _composicaoRn30(duracaoHoras: 2));

      expect(_heroi(tester).label, contains(rotuloDeDuracao(2)));
    });
  });

  group('MONT-23 — as duas saídas do rail', () {
    testWidgets('MANDAR NO GRUPO 📲 é o CTA primário, full-width, e emite a '
        'saída uma vez por toque', (tester) async {
      final (emitidos, _) = await _montar(tester);

      final cta = tester.widget<BoraPrimaryButton>(
        find.byType(BoraPrimaryButton),
      );

      expect(cta.rotulo, MontarTextos.mandarNoGrupo);
      expect(cta.larguraTotal, isTrue);

      await tester.tap(find.byType(BoraPrimaryButton));
      await tester.pumpAndSettle();

      expect(emitidos.envios, 1);
      expect(emitidos.salvamentos, 0);
    });

    testWidgets('SALVAR ROLÊ é ação secundária e emite sem navegar',
        (tester) async {
      final (emitidos, _) = await _montar(tester);

      final secundario = tester.widget<BoraSecondaryButton>(
        find.byType(BoraSecondaryButton),
      );

      expect(secundario.rotulo, MontarTextos.salvarRole);
      expect(find.byType(BoraPrimaryButton), findsOneWidget);

      await tester.tap(find.byType(BoraSecondaryButton));
      await tester.pumpAndSettle();

      expect(emitidos.salvamentos, 1);
      expect(
        emitidos.envios,
        0,
        reason: 'salvar não manda no grupo — A-14: "salvar sem mandar no '
            'grupo"',
      );
    });
  });

  group('MONT-13 — o rail tem 370px e não rola com a página', () {
    testWidgets('a largura renderizada é a de W-03', (tester) async {
      await _montar(tester);

      expect(RailDoCusto.largura, 370);
      expect(tester.getSize(find.byType(RailDoCusto)).width, 370);
    });

    testWidgets('a única rolagem dentro do rail é a da lista viva',
        (tester) async {
      await _montar(tester);

      final rolagens = find.descendant(
        of: find.byType(RailDoCusto),
        matching: find.byType(Scrollable),
      );

      expect(rolagens, findsOneWidget);
      expect(
        find.descendant(of: find.byType(ListaViva), matching: rolagens),
        findsOneWidget,
        reason: 'o rail é sticky por construção: envolvê-lo num scroll faria '
            'o card-herói sair do viewport (W-R2)',
      );
    });
  });

  group('MONT-08 — o rail não faz conta e não escreve dinheiro', () {
    /// A fonte sem comentários e sem literais de string — é neles que `/` e
    /// `//` aparecem legitimamente.
    String fonteSemComentariosNemStrings() => File(
          'lib/features/montar/presentation/widgets/rail_do_custo.dart',
        )
            .readAsStringSync()
            .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
            .replaceAll(RegExp('^[ \t]*///?.*\$', multiLine: true), '')
            .replaceAll(RegExp(r'''(['"]).*?\1'''), '');

    test('a varredura não roda vazia: o código sobrevive à limpeza', () {
      final fonte = fonteSemComentariosNemStrings();

      // Sem isto, uma limpeza que apagasse o arquivo inteiro passaria no teste
      // seguinte sem ter olhado nada.
      expect(fonte, contains('class RailDoCusto'));
      expect(fonte, contains('BoraHeroCard('));
      expect(fonte, contains('MoneyFormatter.reais('));
    });

    test('nenhum operador de conta fora de comentário e de string', () {
      final fonte = fonteSemComentariosNemStrings();

      for (final proibido in ['*', '/', '%', '.fold(', '.reduce(', '.sum']) {
        expect(
          fonte,
          isNot(contains(proibido)),
          reason: 'conta em widget: "$proibido" em rail_do_custo.dart',
        );
      }
    });

    test('o arquivo não escreve R\$ nem arredonda', () {
      final fonte = File(
        'lib/features/montar/presentation/widgets/rail_do_custo.dart',
      ).readAsStringSync();

      expect(fonte, isNot(contains(r'R$')));
      expect(fonte, isNot(contains('.round(')));
      expect(fonte, isNot(contains('.toStringAsFixed(')));
    });

    testWidgets('todo texto com dinheiro fora da lista viva é o de '
        'MoneyFormatter', (tester) async {
      final (_, resultado) = await _montar(tester);

      // Os valores da lista viva são cobrados no teste dela; aqui interessa o
      // que o **rail** escreve por conta própria — o card-herói.
      final exibidos = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(RailDoCusto),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data ?? '')
          .where((texto) => texto.contains(r'R$'))
          .toSet()
          .difference(
            tester
                .widgetList<Text>(
                  find.descendant(
                    of: find.byType(ListaViva),
                    matching: find.byType(Text),
                  ),
                )
                .map((t) => t.data ?? '')
                .toSet(),
          );

      expect(exibidos, {
        MoneyFormatter.reais(resultado.totalDosItens),
        MontarTextos.porCabecaExpandido(
          MoneyFormatter.reais(resultado.porCabeca),
        ),
      });
    });
  });
}
