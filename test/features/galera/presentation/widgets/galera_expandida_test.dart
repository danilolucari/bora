import 'dart:io';
import 'dart:ui';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/domain/galera_da_festa.dart';
import 'package:bora/features/galera/presentation/galera_textos.dart';
import 'package:bora/features/galera/presentation/pages/galera_page.dart';
import 'package:bora/features/galera/presentation/widgets/card_do_link.dart';
import 'package:bora/features/galera/presentation/widgets/faixa_de_preferencias.dart';
import 'package:bora/features/galera/presentation/widgets/galera_compacta.dart';
import 'package:bora/features/galera/presentation/widgets/galera_expandida.dart';
import 'package:bora/features/galera/presentation/widgets/linha_de_pessoa.dart';
import 'package:bora/features/galera/presentation/widgets/painel_da_pessoa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/area_de_transferencia_falsa.dart';
import '../../../../support/galera_de_teste.dart';
import '../../../../support/galera_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';

const String _arquivoDaTela =
    'lib/features/galera/presentation/widgets/galera_expandida.dart';

/// As três larguras que W-R3 e W-R4 nomeiam: o frame do celular, a fronteira
/// de AD-007 e a janela do web.
const Size _frameCompacto = Size(390, 820);
const Size _naFronteira = Size(900, 800);
const Size _janelaExpandida = Size(1180, 800);

/// Logo abaixo da fronteira de AD-007 — o colapso de W-R3.
const Size _abaixoDaFronteira = Size(890, 800);

const String _urlDaFixture = 'bora.app/c/rafa18';

class _Palco {
  const _Palco(this.porta, this.area);

  final GaleraRepositoryFake porta;
  final AreaDeTransferenciaFalsa area;
}

/// Abre a página **de verdade**, e não o widget solto: é a página que escolhe
/// o layout pelo `ResponsiveBuilder`, e é ela que o teste precisa exercitar
/// para que a travessia dos 900px signifique alguma coisa (L-030).
Future<_Palco> _abrir(
  WidgetTester tester, {
  GaleraDaFesta? galera,
  Size janela = _janelaExpandida,
}) async {
  final porta = GaleraRepositoryFake(inicial: galera ?? galeraDeTeste());
  addTearDown(porta.dispose);

  final area = AreaDeTransferenciaFalsa();

  addTearDown(BoraToast.esconder);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);

  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: GaleraPage(
        festaId: idDaFestaDeTeste,
        galera: porta,
        logger: RecordingAppLogger(),
        area: area,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return _Palco(porta, area);
}

Future<void> _redimensionar(WidgetTester tester, Size janela) async {
  await tester.binding.setSurfaceSize(janela);
  await tester.pumpAndSettle();
}

Finder _linhaDe(String nome) => find.byWidgetPredicate(
      (widget) => widget is LinhaDePessoa && widget.pessoa.nome == nome,
    );

Finder _painelDe(String nome) => find.byWidgetPredicate(
      (widget) => widget is PainelDaPessoa && widget.pessoa.nome == nome,
    );

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

/// A sublinha da linha de [nome], como a tela a escreve.
String? _sublinhaDe(WidgetTester tester, String nome) =>
    GaleraTextos.sublinhaDe(
      tester.widget<LinhaDePessoa>(_linhaDe(nome)).pessoa,
    );

/// A cor do fundo da linha de [nome] — é por ela que o hover é observável.
Color _fundoDaLinha(WidgetTester tester, String nome) =>
    tester
        .widget<ColoredBox>(
          find.descendant(
            of: _linhaDe(nome),
            matching: find.byType(ColoredBox),
          ),
        )
        .color;

void main() {
  group('GAL-22 AC1 — as duas colunas de W-04', () {
    testWidgets('a 1180 a tela é a expandida, e o compacto não existe',
        (tester) async {
      await _abrir(tester);

      expect(find.byType(GaleraExpandida), findsOneWidget);
      expect(find.byType(GaleraCompacta), findsNothing);
    });

    testWidgets('a coluna esquerda mede exatamente 370px', (tester) async {
      await _abrir(tester);

      expect(
        tester.getSize(find.byKey(GaleraExpandida.colunaKey)).width,
        GaleraExpandida.larguraDaColuna,
      );
      expect(GaleraExpandida.larguraDaColuna, 370);
    });

    testWidgets('o card do link mora dentro da coluna esquerda',
        (tester) async {
      await _abrir(tester);

      expect(
        find.descendant(
          of: find.byKey(GaleraExpandida.colunaKey),
          matching: find.byType(CardDoLink),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a lista de pessoas mora fora da coluna esquerda',
        (tester) async {
      await _abrir(tester);

      expect(find.byType(LinhaDePessoa), findsNWidgets(5));
      expect(
        find.descendant(
          of: find.byKey(GaleraExpandida.colunaKey),
          matching: find.byType(LinhaDePessoa),
        ),
        findsNothing,
      );
    });
  });

  group('GAL-22 AC2 — o CTA no rail, e nenhum rodapé fixo (W-R2)', () {
    testWidgets('o CTA está na coluna esquerda, abaixo do card',
        (tester) async {
      await _abrir(tester);

      expect(
        find.descendant(
          of: find.byKey(GaleraExpandida.colunaKey),
          matching: find.byKey(GaleraExpandida.ctaKey),
        ),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(find.byKey(GaleraExpandida.ctaKey)).dy,
        greaterThan(tester.getTopLeft(find.byType(CardDoLink)).dy),
      );
    });

    testWidgets('nenhum rodapé fixo existe na árvore', (tester) async {
      await _abrir(tester);

      expect(find.byType(RodapeDaGalera), findsNothing);
      expect(find.byType(BoraFooterBar), findsNothing);
      expect(find.byKey(RodapeDaGalera.ctaKey), findsNothing);
    });

    testWidgets('a 390 o rodapé fixo volta e a coluna de 370px some — o par '
        'que discrimina', (tester) async {
      await _abrir(tester, janela: _frameCompacto);

      expect(find.byType(RodapeDaGalera), findsOneWidget);
      expect(find.byKey(RodapeDaGalera.ctaKey), findsOneWidget);
      expect(find.byKey(GaleraExpandida.colunaKey), findsNothing);
      expect(find.byKey(GaleraExpandida.ctaKey), findsNothing);
    });

    testWidgets('o CTA do rail copia a mesma URL de RN-23', (tester) async {
      final palco = await _abrir(tester);

      await _tocar(tester, find.byKey(GaleraExpandida.ctaKey));

      expect(palco.area.copiados, [_urlDaFixture]);

      BoraToast.esconder();
    });
  });

  group('GAL-23 AC3 — cruzar a fronteira preserva o estado', () {
    testWidgets('de 1180 para 890, o accordion aberto continua aberto',
        (tester) async {
      await _abrir(tester);

      await _tocar(tester, _linhaDe('Ana'));
      expect(_painelDe('Ana'), findsOneWidget);

      await _redimensionar(tester, _abaixoDaFronteira);

      expect(find.byType(GaleraCompacta), findsOneWidget);
      expect(_painelDe('Ana'), findsOneWidget);
    });

    testWidgets('de 1180 para 890, o nível selecionado continua selecionado',
        (tester) async {
      final palco = await _abrir(tester);

      palco.porta.emitir(
        galeraDeTeste(
          convite: const ConviteDaFesta(
            codigo: 'rafa18',
            nivel: NivelDoLink.coAnfitriao,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _redimensionar(tester, _abaixoDaFronteira);

      expect(
        tester
            .widget<BoraSegmentedControl>(
              find.descendant(
                of: find.byType(CardDoLink),
                matching: find.byType(BoraSegmentedControl),
              ),
            )
            .indiceAtivo,
        NivelDoLink.values.indexOf(NivelDoLink.coAnfitriao),
      );
    });

    testWidgets('900 é expandido e 890 é compacto — a fronteira de AD-007',
        (tester) async {
      await _abrir(tester, janela: _naFronteira);
      expect(find.byType(GaleraExpandida), findsOneWidget);

      await _redimensionar(tester, _abaixoDaFronteira);
      expect(find.byType(GaleraCompacta), findsOneWidget);
      expect(find.byType(GaleraExpandida), findsNothing);
    });
  });

  group('GAL-23 AC5 — a mudança feita num layout vale no outro', () {
    testWidgets('a dieta trocada a 390 aparece na tela expandida',
        (tester) async {
      final palco = await _abrir(tester, janela: _frameCompacto);

      expect(_sublinhaDe(tester, 'Bia'), '🚫 Sem porco · não bebe 🚫');

      await _tocar(tester, _linhaDe('Bia'));
      await _tocar(tester, find.text(GaleraTextos.rotuloDaDieta(Dieta.veggie)));

      expect(palco.porta.dietas.single.$3, Dieta.veggie);

      // A porta é a fonte da verdade: a mudança só chega à tela pelo stream.
      palco.porta.emitir(
        galeraDeTeste(
          pessoas: [
            for (final pessoa in galeraDeTeste().pessoas)
              pessoa.nome == 'Bia'
                  ? Pessoa(
                      nome: pessoa.nome,
                      papel: pessoa.papel,
                      status: pessoa.status,
                      dieta: Dieta.veggie,
                      bebe: pessoa.bebe,
                      voce: pessoa.voce,
                    )
                  : pessoa,
          ],
        ),
      );
      await tester.pumpAndSettle();

      await _redimensionar(tester, _janelaExpandida);

      expect(find.byType(GaleraExpandida), findsOneWidget);
      expect(_sublinhaDe(tester, 'Bia'), '🥗 Veggie · não bebe 🚫');
      expect(
        find.text('💡 A lista já se ajusta às preferências: '
            '2 veggie 🥗 · 3 bebem 🍺'),
        findsOneWidget,
      );
    });

    testWidgets('a faixa amarela do expandido é a mesma de T-05',
        (tester) async {
      await _abrir(tester);

      expect(find.byType(FaixaDePreferencias), findsOneWidget);
      expect(
        find.text('💡 A lista já se ajusta às preferências: '
            '1 veggie 🥗 · 1 sem porco 🚫 · 3 bebem 🍺'),
        findsOneWidget,
      );
    });
  });

  group('GAL-23 AC4 — nunca há scroll horizontal', () {
    for (final janela in [_janelaExpandida, _naFronteira, _frameCompacto]) {
      testWidgets('a ${janela.width.toInt()}px, nenhuma rolagem lateral',
          (tester) async {
        await _abrir(tester, janela: janela);

        final horizontais = tester
            .widgetList<Scrollable>(find.byType(Scrollable))
            .where(
              (rolagem) =>
                  rolagem.axisDirection == AxisDirection.left ||
                  rolagem.axisDirection == AxisDirection.right,
            );

        expect(horizontais, isEmpty);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('GAL-22 AC6 — hover no expandido', () {
    testWidgets('a linha de pessoa acende sob o ponteiro e apaga ao sair',
        (tester) async {
      await _abrir(tester);

      expect(_fundoDaLinha(tester, 'Ana'), LinhaDePessoa.fundoEmRepouso);

      final ponteiro = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(
        ponteiro.hover(tester.getCenter(_linhaDe('Ana'))),
      );
      await tester.pumpAndSettle();

      expect(_fundoDaLinha(tester, 'Ana'), LinhaDePessoa.fundoNoHover);
      expect(
        LinhaDePessoa.fundoNoHover,
        isNot(LinhaDePessoa.fundoEmRepouso),
        reason: 'hover que não muda nada não é estado de hover',
      );

      await tester.sendEventToBinding(ponteiro.hover(Offset.zero));
      await tester.pumpAndSettle();

      expect(_fundoDaLinha(tester, 'Ana'), LinhaDePessoa.fundoEmRepouso);
    });

    testWidgets('a linha de pessoa mostra o cursor de clique', (tester) async {
      await _abrir(tester);

      final regiao = tester.widget<MouseRegion>(
        find
            .descendant(of: _linhaDe('Ana'), matching: find.byType(MouseRegion))
            .first,
      );

      expect(regiao.cursor, SystemMouseCursors.click);
    });

    testWidgets('o CTA e o "COPIAR 🔗" trazem o hover do BoraPressSink',
        (tester) async {
      await _abrir(tester);

      expect(
        find.descendant(
          of: find.byKey(GaleraExpandida.ctaKey),
          matching: find.byType(MouseRegion),
        ),
        findsWidgets,
      );
      expect(
        find.descendant(
          of: find.byType(BoraSecondaryButton),
          matching: find.byType(MouseRegion),
        ),
        findsWidgets,
      );
    });
  });

  group('Arquivo 02 §8 — nenhum literal no arquivo', () {
    test('sem literal de cor, de fonte ou de sombra', () {
      final fonte = File(_arquivoDaTela).readAsStringSync();

      expect(fonte, isNot(contains('Color(0x')));
      expect(fonte, isNot(contains('fontFamily:')));
      expect(fonte, isNot(contains('BoxShadow(')));
    });
  });
}
