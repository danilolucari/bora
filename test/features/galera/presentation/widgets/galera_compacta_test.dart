import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/domain/galera_da_festa.dart';
import 'package:bora/features/galera/presentation/bloc/galera_bloc.dart';
import 'package:bora/features/galera/presentation/galera_textos.dart';
import 'package:bora/features/galera/presentation/widgets/card_do_link.dart';
import 'package:bora/features/galera/presentation/widgets/faixa_de_preferencias.dart';
import 'package:bora/features/galera/presentation/widgets/galera_compacta.dart';
import 'package:bora/features/galera/presentation/widgets/linha_de_pessoa.dart';
import 'package:bora/features/galera/presentation/widgets/painel_da_pessoa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/rn30_estado_inicial_tipado.dart';
import '../../../../support/area_de_transferencia_falsa.dart';
import '../../../../support/galera_de_teste.dart';
import '../../../../support/galera_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';

const String _arquivoDaTela =
    'lib/features/galera/presentation/widgets/galera_compacta.dart';

/// As duas viewports do produto: o frame do celular e a janela do web.
const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);

const Map<String, Size> _viewports = {
  'compacto': _frameCompacto,
  'expandido': _janelaExpandida,
};

/// A URL literal de RN-23 para a festa da fixture.
const String _urlDaFixture = 'bora.app/c/rafa18';

/// O que a tela tem por trás: a porta, a área de transferência e o bloc real.
///
/// O bloc é o **de verdade**, e não um estado de mentira montado pelo teste:
/// "1 painel aberto por vez" é regra entre linhas irmãs e mora no bloc — um
/// harness que guardasse a chave aberta por conta própria estaria testando o
/// próprio harness (L-030).
class _Cenario {
  const _Cenario(this.bloc, this.porta, this.area);

  final GaleraBloc bloc;
  final GaleraRepositoryFake porta;
  final AreaDeTransferenciaFalsa area;
}

Future<_Cenario> _montar(
  WidgetTester tester, {
  GaleraDaFesta? galera,
  Size viewport = _frameCompacto,
  CapacidadesDaGalera? capacidades,
}) async {
  final porta = GaleraRepositoryFake(inicial: galera ?? galeraDeTeste());
  addTearDown(porta.dispose);

  final area = AreaDeTransferenciaFalsa();
  final bloc = GaleraBloc(
    idDaFestaDeTeste,
    porta,
    area,
    RecordingAppLogger(),
  );
  addTearDown(bloc.close);

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: SafeArea(
          child: BlocBuilder<GaleraBloc, GaleraState>(
            bloc: bloc,
            builder: (context, estado) => GaleraCompacta(
              estado: estado,
              capacidades: capacidades ??
                  CapacidadesDaGalera.de(
                    estado.galera?.pessoas ?? const [],
                  ),
              aoCopiar: () => bloc.add(const LinkCopiado()),
              aoEscolherNivel: (nivel) => bloc.add(NivelEscolhido(nivel)),
              aoAlternarLinha: (chave) => bloc.add(LinhaAlternada(chave)),
              aoEscolherPapel: (chave, papel) =>
                  bloc.add(PapelEscolhido(chave, papel)),
              aoEscolherDieta: (chave, dieta) =>
                  bloc.add(DietaEscolhida(chave, dieta)),
              aoAlternarBebida: (chave, bebe) =>
                  bloc.add(BebidaAlternada(chave, bebe)),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return _Cenario(bloc, porta, area);
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

Future<void> _tocarLinha(WidgetTester tester, String nome) async {
  final linha = _linhaDe(nome);
  await tester.ensureVisible(linha);
  await tester.pumpAndSettle();
  await tester.tap(linha);
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

double _topoDe(WidgetTester tester, Finder finder) =>
    tester.getTopLeft(finder).dy;

/// Os nomes das linhas, **na ordem da árvore** — é o que afirma A-15.
List<String> _nomesNaTela(WidgetTester tester) => tester
    .widgetList<LinhaDePessoa>(find.byType(LinhaDePessoa))
    .map((linha) => linha.pessoa.nome)
    .toList();

void main() {
  group('GAL-06 — o header de T-05', () {
    for (final viewport in _viewports.entries) {
      testWidgets('em ${viewport.key}, o título e o sub da fixture',
          (tester) async {
        await _montar(tester, viewport: viewport.value);

        expect(find.text(GaleraTextos.titulo), findsOneWidget);
        expect(find.text('5 pessoas · 4 confirmadas'), findsOneWidget);
      });
    }

    testWidgets('o sub é o que GaleraTextos deriva do dado, não um literal',
        (tester) async {
      await _montar(tester);

      expect(
        find.text(GaleraTextos.subtitulo(pessoas: 5, confirmadas: 4)),
        findsOneWidget,
      );
      expect(find.text(GaleraTextos.semPessoas), findsNothing);
    });
  });

  group('GAL-01, GAL-13 — os blocos de T-05 na ordem', () {
    for (final viewport in _viewports.entries) {
      testWidgets('em ${viewport.key}, header → card → faixa → PESSOAS → CTA',
          (tester) async {
        await _montar(tester, viewport: viewport.value);

        final topos = [
          _topoDe(tester, find.text(GaleraTextos.titulo)),
          _topoDe(tester, find.byType(CardDoLink)),
          _topoDe(tester, find.byType(FaixaDePreferencias)),
          _topoDe(tester, find.text(GaleraTextos.secaoPessoas)),
          _topoDe(tester, find.byType(RodapeDaGalera)),
        ];

        expect(topos, orderedEquals(List.of(topos)..sort()));
      });
    }

    testWidgets('a faixa amarela lê o resumo literal de RN-21 com a fixture',
        (tester) async {
      await _montar(tester);

      expect(
        find.text('💡 A lista já se ajusta às preferências: '
            '1 veggie 🥗 · 1 sem porco 🚫 · 3 bebem 🍺'),
        findsOneWidget,
      );
    });
  });

  group('GAL-09 — a seção PESSOAS', () {
    testWidgets('uma linha por pessoa nomeada, na ordem do repositório (A-15)',
        (tester) async {
      await _montar(tester);

      expect(_nomesNaTela(tester), ['Rafa', 'Ana', 'Léo', 'Bia', 'Duda']);
      expect(
        _nomesNaTela(tester),
        isNot(['Ana', 'Bia', 'Duda', 'Léo', 'Rafa']),
        reason: 'a ordem é a do repositório, não a alfabética',
      );
    });

    testWidgets('AC9: nenhuma contagem de pendentes e nenhuma sexta linha',
        (tester) async {
      await _montar(tester);

      expect(find.byType(LinhaDePessoa), findsNWidgets(5));
      expect(find.textContaining('pendente'), findsNothing);
      expect(find.textContaining('Pendente'), findsNothing);
      expect(find.textContaining('PENDENTE'), findsNothing);
    });
  });

  group('GAL-10 AC1 — um painel aberto por vez', () {
    testWidgets('tocar a linha abre o painel daquela pessoa', (tester) async {
      await _montar(tester);

      expect(find.byType(PainelDaPessoa), findsNothing);

      await _tocarLinha(tester, 'Ana');

      expect(_painelDe('Ana'), findsOneWidget);
      expect(find.byType(PainelDaPessoa), findsOneWidget);
    });

    testWidgets('abrir a segunda linha fecha a primeira', (tester) async {
      await _montar(tester);

      await _tocarLinha(tester, 'Ana');
      await _tocarLinha(tester, 'Léo');

      expect(_painelDe('Ana'), findsNothing);
      expect(_painelDe('Léo'), findsOneWidget);
      expect(find.text(GaleraTextos.secaoRestricao), findsOneWidget);
    });

    testWidgets('tocar a linha já aberta fecha o painel', (tester) async {
      await _montar(tester);

      await _tocarLinha(tester, 'Ana');
      await _tocarLinha(tester, 'Ana');

      expect(find.byType(PainelDaPessoa), findsNothing);
      expect(find.text(GaleraTextos.secaoRestricao), findsNothing);
    });
  });

  group('GAL-24 AC1 — a festa só com o anfitrião', () {
    testWidgets('uma linha, o sub no singular e a faixa com o que sobrou',
        (tester) async {
      await _montar(
        tester,
        galera: galeraDeTeste(pessoas: [pessoasRn30Tipadas.first]),
      );

      expect(find.byType(LinhaDePessoa), findsOneWidget);
      expect(find.text('1 pessoa · 1 confirmada'), findsOneWidget);
      expect(
        find.text('💡 A lista já se ajusta às preferências: 1 bebem 🍺'),
        findsOneWidget,
      );
    });
  });

  group('GAL-24 AC2 — a festa sem pessoa nomeada', () {
    testWidgets('o sub é "nenhuma pessoa ainda" e a seção fica sem linhas',
        (tester) async {
      await _montar(tester, galera: galeraDeTeste(pessoas: const []));

      expect(find.text(GaleraTextos.semPessoas), findsOneWidget);
      expect(find.text(GaleraTextos.secaoPessoas), findsOneWidget);
      expect(find.byType(LinhaDePessoa), findsNothing);
      expect(find.byType(PainelDaPessoa), findsNothing);
    });

    testWidgets('a faixa amarela some e o card do link + CTA permanecem',
        (tester) async {
      await _montar(tester, galera: galeraDeTeste(pessoas: const []));

      expect(find.byType(FaixaDePreferencias), findsNothing);
      expect(find.byType(CardDoLink), findsOneWidget);
      expect(find.text(_urlDaFixture), findsOneWidget);
      expect(find.byKey(RodapeDaGalera.ctaKey), findsOneWidget);
    });

    testWidgets('o CTA da festa vazia continua funcional', (tester) async {
      final cenario =
          await _montar(tester, galera: galeraDeTeste(pessoas: const []));

      await _tocar(tester, find.byKey(RodapeDaGalera.ctaKey));

      expect(cenario.area.copiados, [_urlDaFixture]);
    });
  });

  group('GAL-25 — a falha do repositório', () {
    testWidgets('a mensagem aparece e o card do link continua na tela',
        (tester) async {
      final cenario = await _montar(tester);

      cenario.porta.falhar(StateError('sem rede'), StackTrace.current);
      await tester.pumpAndSettle();

      expect(find.text(GaleraTextos.falha), findsOneWidget);
      expect(find.byType(CardDoLink), findsOneWidget);
      expect(find.text(_urlDaFixture), findsOneWidget);
      expect(find.byKey(RodapeDaGalera.ctaKey), findsOneWidget);
    });

    testWidgets('sem falha, a mensagem não está na árvore — o par que '
        'discrimina', (tester) async {
      await _montar(tester);

      expect(find.text(GaleraTextos.falha), findsNothing);
      expect(find.byType(FaixaDeFalhaDaGalera), findsNothing);
    });

    testWidgets('a mensagem de falha é legível: cor de token, opaca',
        (tester) async {
      final cenario = await _montar(tester);

      cenario.porta.falhar(StateError('sem rede'), StackTrace.current);
      await tester.pumpAndSettle();

      final texto = tester.widget<Text>(find.text(GaleraTextos.falha));

      expect(texto.style?.color, BoraColors.text2);
      expect(texto.style?.color?.a, 1.0);
    });
  });

  group('GAL-03 AC7 — os dois botões copiam o mesmo link', () {
    testWidgets('o CTA do rodapé copia a mesma URL que o "COPIAR 🔗"',
        (tester) async {
      final cenario = await _montar(tester);

      await _tocar(tester, _botaoCopiar());
      await _tocar(tester, find.byKey(RodapeDaGalera.ctaKey));

      expect(cenario.area.copiados, [_urlDaFixture, _urlDaFixture]);
    });

    testWidgets('o CTA do rodapé traz a copy e o acento roxo de T-05',
        (tester) async {
      await _montar(tester);

      final cta = tester.widget<BoraPrimaryButton>(
        find.byKey(RodapeDaGalera.ctaKey),
      );

      expect(cta.rotulo, GaleraTextos.convidarMaisGente);
      expect(cta.acento, BoraAccent.purple);
      expect(cta.larguraTotal, isTrue);
      expect(cta.onPressed, isNotNull);
    });

    testWidgets('sem código de link, o CTA do rodapé fica inerte',
        (tester) async {
      final cenario = await _montar(
        tester,
        galera: galeraDeTeste(
          convite: const ConviteDaFesta(codigo: '', nivel: NivelDoLink.soVer),
        ),
      );

      expect(
        tester
            .widget<BoraPrimaryButton>(find.byKey(RodapeDaGalera.ctaKey))
            .onPressed,
        isNull,
      );

      await _tocar(tester, find.byKey(RodapeDaGalera.ctaKey));

      expect(cenario.area.copiados, isEmpty);
    });
  });

  group('GAL-27 AC2 — a Galera de quem não gerencia papéis', () {
    testWidgets('sem a capacidade, "NÍVEL DE ACESSO" some e os outros ficam',
        (tester) async {
      await _montar(
        tester,
        capacidades: const CapacidadesDaGalera(
          podeConfigurarNivel: true,
          podeGerenciarPapeis: false,
        ),
      );

      await _tocarLinha(tester, 'Ana');

      expect(find.text(GaleraTextos.secaoNivelDeAcesso), findsNothing);
      expect(find.text(GaleraTextos.secaoRestricao), findsOneWidget);
      expect(find.text(GaleraTextos.secaoBebida), findsOneWidget);
    });

    testWidgets('com a capacidade, as três seções estão presentes',
        (tester) async {
      await _montar(
        tester,
        capacidades: const CapacidadesDaGalera(
          podeConfigurarNivel: true,
          podeGerenciarPapeis: true,
        ),
      );

      await _tocarLinha(tester, 'Ana');

      expect(find.text(GaleraTextos.secaoNivelDeAcesso), findsOneWidget);
      expect(find.text(GaleraTextos.secaoRestricao), findsOneWidget);
      expect(find.text(GaleraTextos.secaoBebida), findsOneWidget);
    });

    testWidgets('CapacidadesDaGalera sai da tabela de RN-22, papel a papel',
        (tester) async {
      const donos = {
        PapelNaFesta.anfitriao: true,
        PapelNaFesta.coAnfitriao: false,
        PapelNaFesta.convidado: false,
        PapelNaFesta.soVe: false,
      };

      for (final entrada in donos.entries) {
        final capacidades = CapacidadesDaGalera.de([
          Pessoa(
            nome: 'Quem',
            papel: entrada.key,
            status: StatusDePresenca.confirmado,
            voce: true,
          ),
        ]);

        expect(capacidades.podeConfigurarNivel, entrada.value,
            reason: '${entrada.key}');
        expect(capacidades.podeGerenciarPapeis, entrada.value,
            reason: '${entrada.key}');
      }
    });
  });

  group('W-R4 e §5 — a seção rola no documento, nunca de lado', () {
    for (final viewport in _viewports.entries) {
      testWidgets('em ${viewport.key}, nenhum scroll horizontal e sem overflow',
          (tester) async {
        await _montar(tester, viewport: viewport.value);

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

    testWidgets('a última linha é alcançável por rolagem a 390px',
        (tester) async {
      await _montar(tester);

      await tester.ensureVisible(_linhaDe('Duda'));
      await tester.pumpAndSettle();

      expect(_linhaDe('Duda'), findsOneWidget);
      expect(find.byKey(RodapeDaGalera.ctaKey), findsOneWidget);
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
