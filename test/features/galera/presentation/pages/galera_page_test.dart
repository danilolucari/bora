import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/domain/galera_da_festa.dart';
import 'package:bora/features/galera/presentation/bloc/galera_bloc.dart';
import 'package:bora/features/galera/presentation/galera_textos.dart';
import 'package:bora/features/galera/presentation/pages/galera_page.dart';
import 'package:bora/features/galera/presentation/widgets/card_do_link.dart';
import 'package:bora/features/galera/presentation/widgets/galera_compacta.dart';
import 'package:bora/features/galera/presentation/widgets/linha_de_pessoa.dart';
import 'package:bora/features/galera/presentation/widgets/painel_da_pessoa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/rn30_estado_inicial_tipado.dart';
import '../../../../support/area_de_transferencia_falsa.dart';
import '../../../../support/galera_de_teste.dart';
import '../../../../support/galera_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';

/// As duas viewports do produto.
const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

const String _urlDaFixture = 'bora.app/c/rafa18';

/// O que ficou por trás da página montada.
class _Palco {
  const _Palco(this.porta, this.area, this.logger);

  final GaleraRepositoryFake porta;
  final AreaDeTransferenciaFalsa area;
  final RecordingAppLogger logger;
}

Future<_Palco> _abrir(
  WidgetTester tester, {
  GaleraDaFesta? galera,
  Size janela = _frameCompacto,
  String festaId = idDaFestaDeTeste,
  Object? erroDeCopia,
}) async {
  final porta = GaleraRepositoryFake(inicial: galera ?? galeraDeTeste());
  addTearDown(porta.dispose);

  final area = AreaDeTransferenciaFalsa()..erro = erroDeCopia;
  final logger = RecordingAppLogger();

  addTearDown(BoraToast.esconder);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);

  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: GaleraPage(
        festaId: festaId,
        galera: porta,
        logger: logger,
        area: area,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return _Palco(porta, area, logger);
}

Finder _linhaDe(String nome) => find.byWidgetPredicate(
      (widget) => widget is LinhaDePessoa && widget.pessoa.nome == nome,
    );

Finder _painelDe(String nome) => find.byWidgetPredicate(
      (widget) => widget is PainelDaPessoa && widget.pessoa.nome == nome,
    );

Finder _botaoCopiar() => find.descendant(
      of: find.byType(CardDoLink),
      matching: find.byType(BoraSecondaryButton),
    );

Finder _ctaDoRodape() => find.byKey(RodapeDaGalera.ctaKey);

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

/// O estado que a tela está desenhando agora.
GaleraState _estado(WidgetTester tester) =>
    tester.widget<GaleraCompacta>(find.byType(GaleraCompacta)).estado;

/// Redimensiona a janela **com a tela montada** — sem `pumpWidget` novo, que
/// é o que faz a asserção ser sobre a sobrevivência do estado (GAL-23 AC3).
Future<void> _redimensionar(WidgetTester tester, Size janela) async {
  await tester.binding.setSurfaceSize(janela);
  await tester.pumpAndSettle();
}

/// Uma pessoa da fixture com a marca `voce` trocada — o par de GAL-27 AC3.
List<Pessoa> _comVoceEm(String nome) => [
      for (final pessoa in pessoasRn30Tipadas)
        Pessoa(
          nome: pessoa.nome,
          papel: pessoa.papel,
          status: pessoa.status,
          dieta: pessoa.dieta,
          bebe: pessoa.bebe,
          voce: pessoa.nome == nome,
        ),
    ];

void main() {
  group('GAL-23 — a página monta a tela nas duas viewports', () {
    for (final viewport in _viewports.entries) {
      testWidgets('em ${viewport.key}, a Galera renderiza sob a pageKey',
          (tester) async {
        await _abrir(tester, janela: viewport.value);

        expect(find.byKey(GaleraPage.pageKey), findsOneWidget);
        expect(find.text(GaleraTextos.titulo), findsOneWidget);
        expect(find.text('5 pessoas · 4 confirmadas'), findsOneWidget);
      });
    }

    testWidgets('a página assina a porta com o festaId que recebeu',
        (tester) async {
      final palco = await _abrir(tester, festaId: 'outra-festa');

      expect(palco.porta.observados, ['outra-festa']);
    });
  });

  group('GAL-23 AC3, AC5 — o bloc mora acima do ResponsiveBuilder', () {
    testWidgets('cruzar os 900px preserva o painel aberto', (tester) async {
      await _abrir(tester);

      await _tocar(tester, _linhaDe('Ana'));
      expect(_painelDe('Ana'), findsOneWidget);

      await _redimensionar(tester, _janelaExpandida);

      expect(_estado(tester).aberta?.nome, 'Ana');
      expect(_painelDe('Ana'), findsOneWidget);
    });

    testWidgets('cruzar os 900px preserva o nível selecionado no card',
        (tester) async {
      final palco = await _abrir(tester);

      // Escopado ao card: "CO-ANFITRIÃO" é rótulo de nível **e** de papel, e
      // a tag da Ana escreve a mesma palavra na seção PESSOAS.
      await _tocar(
        tester,
        find.descendant(
          of: find.byType(CardDoLink),
          matching:
              find.text(GaleraTextos.rotuloDoNivel(NivelDoLink.coAnfitriao)),
        ),
      );
      palco.porta.emitir(
        galeraDeTeste(
          convite: const ConviteDaFesta(
            codigo: 'rafa18',
            nivel: NivelDoLink.coAnfitriao,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _redimensionar(tester, _janelaExpandida);

      expect(_estado(tester).galera?.convite.nivel, NivelDoLink.coAnfitriao);
      expect(
        find.text(GaleraTextos.notaDoNivel(NivelDoLink.coAnfitriao)),
        findsOneWidget,
      );
      expect(
        find.text(GaleraTextos.notaDoNivel(NivelDoLink.editarLista)),
        findsNothing,
      );
    });

    testWidgets('a travessia não reassina a porta — o bloc é o mesmo',
        (tester) async {
      final palco = await _abrir(tester);

      await _redimensionar(tester, _janelaExpandida);
      await _redimensionar(tester, _frameCompacto);

      expect(palco.porta.observados, [idDaFestaDeTeste]);
    });
  });

  group('GAL-03 AC6 — "COPIAR 🔗" grava a URL e mostra o toast', () {
    testWidgets('a URL completa vai para a área de transferência',
        (tester) async {
      final palco = await _abrir(tester);

      await _tocar(tester, _botaoCopiar());

      expect(palco.area.copiados, [_urlDaFixture]);

      BoraToast.esconder();
    });

    testWidgets('o toast de RN-29 aparece com a copy literal', (tester) async {
      await _abrir(tester);

      await _tocar(tester, _botaoCopiar());

      expect(find.byKey(BoraToastContent.toastKey), findsOneWidget);
      expect(find.text(GaleraTextos.linkCopiado.toUpperCase()), findsOneWidget);

      BoraToast.esconder();
    });

    testWidgets('o toast some sozinho na duração que BoraToast fixa',
        (tester) async {
      await _abrir(tester);

      await _tocar(tester, _botaoCopiar());
      expect(find.byKey(BoraToastContent.toastKey), findsOneWidget);

      await tester.pump(BoraMotion.toastVida);
      await tester.pumpAndSettle();

      expect(find.byKey(BoraToastContent.toastKey), findsNothing);
    });
  });

  group('GAL-03 AC7 — o CTA do rodapé produz o mesmo efeito', () {
    testWidgets('a mesma URL vai para a porta', (tester) async {
      final palco = await _abrir(tester);

      await _tocar(tester, _ctaDoRodape());

      expect(palco.area.copiados, [_urlDaFixture]);

      BoraToast.esconder();
    });

    testWidgets('o mesmo toast aparece', (tester) async {
      await _abrir(tester);

      await _tocar(tester, _ctaDoRodape());

      expect(find.byKey(BoraToastContent.toastKey), findsOneWidget);
      expect(find.text(GaleraTextos.linkCopiado.toUpperCase()), findsOneWidget);

      BoraToast.esconder();
    });
  });

  group('GAL-28 e RN-29 — um toast por vez', () {
    testWidgets('duas cópias seguidas deixam um toast só na árvore',
        (tester) async {
      final palco = await _abrir(tester);

      await _tocar(tester, _botaoCopiar());
      await _tocar(tester, _ctaDoRodape());

      expect(palco.area.copiados, [_urlDaFixture, _urlDaFixture]);
      expect(find.byKey(BoraToastContent.toastKey), findsOneWidget);
      expect(_estado(tester).copiasConcluidas, 2);

      BoraToast.esconder();
    });
  });

  group('GAL-05 — a área de transferência que falha', () {
    testWidgets('nenhum toast é exibido', (tester) async {
      await _abrir(tester, erroDeCopia: StateError('canal indisponível'));

      await _tocar(tester, _botaoCopiar());

      expect(find.byKey(BoraToastContent.toastKey), findsNothing);
      expect(find.text(GaleraTextos.linkCopiado.toUpperCase()), findsNothing);
      expect(_estado(tester).copiasConcluidas, 0);
    });

    testWidgets('a falha é registrada no logger', (tester) async {
      final palco =
          await _abrir(tester, erroDeCopia: StateError('canal indisponível'));

      await _tocar(tester, _botaoCopiar());

      expect(palco.logger.erros, hasLength(1));
      expect(palco.logger.erros.single.name, 'galera');
    });

    testWidgets('a URL continua na tela para cópia à mão', (tester) async {
      await _abrir(tester, erroDeCopia: StateError('canal indisponível'));

      await _tocar(tester, _botaoCopiar());

      expect(find.text(_urlDaFixture), findsOneWidget);
    });
  });

  group('GAL-25 — a falha do repositório na página', () {
    testWidgets('a mensagem aparece e a tela não fica branca', (tester) async {
      final palco = await _abrir(tester);

      palco.porta.falhar(StateError('sem rede'), StackTrace.current);
      await tester.pumpAndSettle();

      expect(find.text(GaleraTextos.falha), findsOneWidget);
      expect(find.byType(CardDoLink), findsOneWidget);
      expect(palco.logger.erros, hasLength(1));
    });
  });

  group('GAL-27 AC3 — o par que discrimina, trocando só quem é "você"', () {
    testWidgets('com Rafa (anfitrião) os dois controles estão presentes',
        (tester) async {
      await _abrir(tester, galera: galeraDeTeste(pessoas: _comVoceEm('Rafa')));

      expect(find.text(GaleraTextos.quemAbrirPode), findsOneWidget);
      expect(find.byType(BoraSegmentedControl), findsOneWidget);

      await _tocar(tester, _linhaDe('Ana'));

      expect(find.text(GaleraTextos.secaoNivelDeAcesso), findsOneWidget);
    });

    testWidgets('com Ana (co-anfitriã) os dois controles somem da árvore',
        (tester) async {
      await _abrir(tester, galera: galeraDeTeste(pessoas: _comVoceEm('Ana')));

      expect(
        find.descendant(
          of: find.byType(CardDoLink),
          matching: find.byType(BoraSegmentedControl),
        ),
        findsNothing,
      );

      await _tocar(tester, _linhaDe('Léo'));

      expect(find.text(GaleraTextos.secaoNivelDeAcesso), findsNothing);
      expect(find.text(GaleraTextos.secaoRestricao), findsOneWidget);
      expect(find.text(GaleraTextos.secaoBebida), findsOneWidget);
    });

    testWidgets('com Ana, a URL e o "COPIAR 🔗" continuam funcionando',
        (tester) async {
      final palco = await _abrir(
        tester,
        galera: galeraDeTeste(pessoas: _comVoceEm('Ana')),
      );

      expect(find.text(_urlDaFixture), findsOneWidget);

      await _tocar(tester, _botaoCopiar());

      expect(palco.area.copiados, [_urlDaFixture]);

      BoraToast.esconder();
    });
  });

  group('GAL-11, GAL-12 — o gesto da tela chega à porta', () {
    testWidgets('escolher uma dieta escreve na porta com a chave da pessoa',
        (tester) async {
      final palco = await _abrir(tester);

      await _tocar(tester, _linhaDe('Bia'));
      await _tocar(tester, find.text(GaleraTextos.rotuloDaDieta(Dieta.veggie)));

      expect(palco.porta.dietas, hasLength(1));
      final (festa, chave, dieta) = palco.porta.dietas.single;
      expect(festa, idDaFestaDeTeste);
      expect(chave.nome, 'Bia');
      expect(dieta, Dieta.veggie);
    });

    testWidgets('o toggle de bebida escreve o valor desejado', (tester) async {
      final palco = await _abrir(tester);

      await _tocar(tester, _linhaDe('Bia'));
      await _tocar(tester, find.text(GaleraTextos.bebe));

      expect(palco.porta.bebidas, hasLength(1));
      final (festa, chave, bebe) = palco.porta.bebidas.single;
      expect(festa, idDaFestaDeTeste);
      expect(chave.nome, 'Bia');
      expect(bebe, isTrue);
    });
  });
}
