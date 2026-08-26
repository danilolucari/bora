import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/routing/routes.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:bora/features/home/presentation/pages/home_page.dart';
import 'package:bora/features/home/presentation/widgets/arquivo_de_festas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';
import '../../../../fixtures/festas_da_home.dart';
import '../../../../support/app_de_teste.dart';

const Size _janelaExpandida = Size(1180, 800);
const Size _janelaCompacta = Size(390, 820);

Future<void> _abrirHome(
  WidgetTester tester, {
  Size janela = _janelaExpandida,
}) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);

  final repositorio = FestaRepositoryEmMemoria(inicial: festasDaHome);
  await abrirApp(
    tester,
    Routes.roles,
    sessao: sessaoDeTeste,
    festas: repositorio,
  );
}

/// Abre a Home no web semeada só com as [passadas] pedidas.
Future<void> _abrirCom(
  WidgetTester tester,
  List<ResumoDeFesta> passadas,
) async {
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(_janelaExpandida);

  await abrirApp(
    tester,
    Routes.roles,
    sessao: sessaoDeTeste,
    festas: FestaRepositoryEmMemoria(inicial: passadas),
  );
}

void main() {
  setUpAll(carregarFontesArchivo);

  group('HOME-14 — o ARQUIVO de UC-24', () {
    testWidgets('tem o título e uma linha por festa concluída',
        (tester) async {
      await _abrirHome(tester);

      expect(find.text('ARQUIVO'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ArquivoDeFestas),
          matching: find.byType(Row),
        ),
        findsNWidgets(festasPassadas.length),
      );
    });

    testWidgets('a linha de UC-24 lê "Churras da laje · 14 pessoas"',
        (tester) async {
      await _abrirHome(tester);

      expect(find.text('Churras da laje · 14 pessoas'), findsOneWidget);
    });

    testWidgets('com o total "R\$ 612" à direita, em vermelho', (tester) async {
      await _abrirHome(tester);

      final total = find.text('R\$ 612');
      expect(total, findsOneWidget);
      expect(tester.widget<Text>(total).style?.color, BoraColors.primary);

      final nome = tester.getRect(find.text('Churras da laje · 14 pessoas'));
      expect(
        tester.getRect(total).left,
        greaterThan(nome.left),
        reason: 'W-02: "valor vermelho à direita"',
      );
    });

    testWidgets('o total passa pelo formatador de RN-13, não por texto à mão',
        (tester) async {
      await _abrirHome(tester);

      expect(
        find.text(MoneyFormatter.reais(festasPassadas.first.total!)),
        findsOneWidget,
        reason: 'RN-13 vem inteira de core/calculo: a UI nunca formata '
            'dinheiro por conta própria',
      );
      expect(
        find.text('612'),
        findsNothing,
        reason: 'sem "R\$" seria número solto, não dinheiro',
      );
      expect(find.textContaining('612,00'), findsNothing);
    });

    testWidgets('cada linha abre com o emoji da festa', (tester) async {
      await _abrirHome(tester);

      expect(
        find.descendant(
          of: find.byType(ArquivoDeFestas),
          matching: find.text(ArquivoDeFestas.emoji),
        ),
        findsNWidgets(festasPassadas.length),
      );
    });
  });

  group('HOME-14 — a linha não inventa dado que não tem', () {
    testWidgets('festa passada sem pessoas nem total não escreve "null"',
        (tester) async {
      final incompleta = ResumoDeFesta(
        id: 'incompleta',
        festa: festasPassadas.first.festa,
      );
      await _abrirCom(tester, [incompleta]);

      expect(find.textContaining('null'), findsNothing);
      expect(
        find.textContaining('R\$ 0'),
        findsNothing,
        reason: 'um `?? 0` transformaria dado faltando num zero plausível, '
            'que é pior do que a ausência',
      );
      expect(find.textContaining(incompleta.festa.nome), findsOneWidget);
    });

    testWidgets('uma pessoa só lê "1 pessoa", no singular', (tester) async {
      final deUmaPessoa = ResumoDeFesta(
        id: 'sozinho',
        festa: festasPassadas.first.festa,
        pessoas: 1,
        total: 40,
      );
      await _abrirCom(tester, [deUmaPessoa]);

      expect(find.textContaining('· 1 pessoa'), findsOneWidget);
      expect(find.textContaining('1 pessoas'), findsNothing);
    });
  });

  group('HOME-14 AC5 — a linha é informação, não ação (A-12)', () {
    testWidgets('tocar numa linha não tira o usuário da Home', (tester) async {
      await _abrirHome(tester);

      await tester.tap(find.text('Churras da laje · 14 pessoas'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(HomePage.pageKey),
        findsOneWidget,
        reason: 'nenhuma spec desenha o destino, e inventar rota furaria o '
            'mapa canônico de AD-003',
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('HOME-14 AC4 — em compacto o arquivo só conta no subtítulo (A-11)',
      () {
    testWidgets('a seção não renderiza no mobile', (tester) async {
      await _abrirHome(tester, janela: _janelaCompacta);

      expect(
        find.byType(ArquivoDeFestas),
        findsNothing,
        reason: 'T-02 não desenha a lista — é o par que discrimina A-11',
      );
      expect(find.text('Churras da laje · 14 pessoas'), findsNothing);
    });

    testWidgets('mas as passadas continuam contadas no subtítulo',
        (tester) async {
      await _abrirHome(tester, janela: _janelaCompacta);

      expect(find.text('1 festa chegando · 2 passadas'), findsOneWidget);
    });
  });
}
