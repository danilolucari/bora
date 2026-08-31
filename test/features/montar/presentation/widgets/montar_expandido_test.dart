import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/montar/domain/rascunho_inicial.dart';
import 'package:bora/features/montar/presentation/bloc/montar_event.dart';
import 'package:bora/features/montar/presentation/bloc/montar_state.dart';
import 'package:bora/features/montar/presentation/montar_textos.dart';
import 'package:bora/features/montar/presentation/widgets/formulario_de_montagem.dart';
import 'package:bora/features/montar/presentation/widgets/lista_viva.dart';
import 'package:bora/features/montar/presentation/widgets/montar_expandido.dart';
import 'package:bora/features/montar/presentation/widgets/rail_do_custo.dart';
import 'package:bora/features/montar/presentation/widgets/secao_de_duracao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/design_system/support/font_loading.dart';

/// A janela de referência de W-03.
const Size _janelaExpandida = Size(1180, 800);

/// A menor janela ainda expandida — a fronteira de AD-007.
const Size _janelaEstreita = Size(900, 800);

/// O estado padrão de RN-30, o do aceite de UC-03.
ComposicaoDaFesta _composicaoRn30() => ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: duracaoDefaultDoRole,
      itensSelecionados: itensPadraoDoRole,
    );

/// Tudo o que a tela devolveu — nenhuma navegação sai daqui (AD-020).
class _Emitidos {
  int envios = 0;
  int salvamentos = 0;
  final List<int> duracoes = [];
  final List<(TipoDeCabeca, int)> contagem = [];
}

/// O palco faz o papel que a página fará: guarda a composição, recalcula pela
/// calculadora e reconstrói. É o que permite afirmar que **uma** interação
/// atualiza os dois lados da tela.
class _Palco extends StatefulWidget {
  const _Palco({
    required this.inicial,
    required this.emitidos,
    this.festa,
  });

  final ComposicaoDaFesta inicial;
  final _Emitidos emitidos;

  /// A festa que o palco reflete. `null` = o rascunho de `/roles/novo`, cujo
  /// nome e data **são** os defaults — por isso ela é parâmetro: com o
  /// rascunho sozinho, um título chumbado no widget seria indistinguível do
  /// título que lê `festa.nome` (P1-5 AC3).
  final Festa? festa;

  @override
  State<_Palco> createState() => _PalcoState();
}

class _PalcoState extends State<_Palco> {
  late ComposicaoDaFesta _composicao = widget.inicial;

  MontarState get _estado => MontarState(
        festa: widget.festa ?? rascunhoInicial(hoje: DateTime(2026, 7, 15)).festa,
        composicao: _composicao,
        resultado: CalculadoraDaFesta.calcular(_composicao),
      );

  void _alternar(ChaveItem chave) {
    final itens = {..._composicao.itensSelecionados};
    if (!itens.remove(chave)) itens.add(chave);

    setState(() {
      _composicao = ComposicaoDaFesta(
        contagem: _composicao.contagem,
        duracaoHoras: _composicao.duracaoHoras,
        itensSelecionados: itens,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BoraColors.paper,
      body: MontarExpandido(
        estado: _estado,
        aoAlterarContagem: (tipo, delta) =>
            widget.emitidos.contagem.add((tipo, delta)),
        aoAlternarItem: _alternar,
        aoSelecionarDuracao: widget.emitidos.duracoes.add,
        aoMandarNoGrupo: () => widget.emitidos.envios++,
        aoSalvar: () => widget.emitidos.salvamentos++,
      ),
    );
  }
}

Future<_Emitidos> _montar(
  WidgetTester tester, {
  Size janela = _janelaExpandida,
  ComposicaoDaFesta? composicao,
  Festa? festa,
}) async {
  final emitidos = _Emitidos();

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(janela);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: _Palco(
        inicial: composicao ?? _composicaoRn30(),
        emitidos: emitidos,
        festa: festa,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return emitidos;
}

double _esquerdaDe(WidgetTester tester, Finder alvo) =>
    tester.getTopLeft(alvo).dx;

BoraHeroCard _heroi(WidgetTester tester) =>
    tester.widget<BoraHeroCard>(find.byType(BoraHeroCard));

String _identidadeEsperada() {
  final festa = rascunhoInicial(hoje: DateTime(2026, 7, 15)).festa;
  return MontarTextos.identidadeExpandida(
    nome: festa.nome,
    data: festa.data,
  );
}

void main() {
  setUpAll(carregarFontesArchivo);

  group('MONT-09 — a linha de título de W-03', () {
    testWidgets('"A CONTA DO ROLÊ" à esquerda e "{NOME} · {DATA}" à direita',
        (tester) async {
      await _montar(tester);

      final titulo = find.text(MontarTextos.titulo);
      final identidade = find.text(_identidadeEsperada());

      expect(titulo, findsOneWidget);
      expect(identidade, findsOneWidget);
      expect(
        _esquerdaDe(tester, titulo),
        lessThan(_esquerdaDe(tester, identidade)),
      );
      expect(
        tester.getTopLeft(titulo).dy,
        lessThan(tester.getTopLeft(find.byType(FormularioDeMontagem)).dy),
      );
    });

    testWidgets('o título sobe o degrau web de 34px sobre o papel de T-03',
        (tester) async {
      await _montar(tester);

      final estilo = tester.widget<Text>(find.text(MontarTextos.titulo)).style!;

      expect(estilo.fontSize, MontarExpandido.tamanhoDoTitulo);
      expect(estilo.fontFamily, BoraTextStyles.tituloTela.fontFamily);
    });

    // P1-5 AC3: "o título da festa SHALL refletir a mudança onde ele aparece
    // — no header mobile e **na linha de título do web**". A metade mobile é
    // afirmada na página; esta é a metade web, e ela só discrimina se a festa
    // montada tiver nome e data **diferentes** dos defaults do rascunho.
    testWidgets('MONT-15 AC3: a identidade é a da festa montada, não o '
        'default do rascunho', (tester) async {
      const nome = 'CHURRAS DO RAFA 🔥';
      // Diferente do default do rascunho, que para `hoje` = 15/07/2026 é
      // justamente 'SÁB · 18 JUL' — coincidir com ele não discriminaria nada.
      const data = 'SEX · 25 DEZ';

      await _montar(
        tester,
        festa: const Festa(
          nome: nome,
          data: data,
          hora: '',
          local: '',
          duracaoHoras: duracaoDefaultDoRole,
        ),
      );

      final padrao = rascunhoInicial(hoje: DateTime(2026, 7, 15)).festa;

      expect(nome, isNot(nomeDefaultDoRole));
      expect(data, isNot(padrao.data));
      expect(
        find.text(MontarTextos.identidadeExpandida(nome: nome, data: data)),
        findsOneWidget,
      );
      expect(
        find.textContaining(nomeDefaultDoRole),
        findsNothing,
        reason: 'a linha de título lê festa.nome; um literal chumbado no '
            'widget continuaria mostrando o default depois de o anfitrião '
            'renomear o rolê',
      );
      expect(find.textContaining(padrao.data), findsNothing);
    });
  });

  group('MONT-09 — os rótulos são os de W-03, não os do mobile (A-09)', () {
    testWidgets('QUEM CONFIRMOU e ATÉ QUE HORAS? no lugar dos rótulos de T-03',
        (tester) async {
      await _montar(tester);

      expect(find.text(MontarTextos.secaoDePessoasExpandido), findsOneWidget);
      expect(find.text(MontarTextos.duracaoExpandido), findsOneWidget);
      expect(find.text(MontarTextos.secaoDePessoasCompacto), findsNothing);
      expect(find.text(MontarTextos.duracaoCompacto), findsNothing);
    });

    testWidgets('as três seções de chips e os 11 chips são os mesmos de T-03 '
        '(W-R1)', (tester) async {
      await _montar(tester);

      expect(find.byType(FormularioDeMontagem), findsOneWidget);
      expect(find.text(MontarTextos.naGrelha), findsWidgets);
      expect(find.text(MontarTextos.naGeladeira), findsWidgets);
      expect(find.text(MontarTextos.prosFortes), findsWidgets);
      expect(find.byType(BoraSelectionChip), findsNWidgets(11));
    });

    testWidgets('o segmented respeita o teto de 360px de W-03',
        (tester) async {
      await _montar(tester);

      final secao = tester.widget<SecaoDeDuracao>(
        find.byType(SecaoDeDuracao),
      );

      expect(secao.larguraMaxima, MontarExpandido.larguraMaximaDaDuracao);
      expect(
        tester.getSize(find.byType(BoraSegmentedControl)).width,
        lessThanOrEqualTo(MontarExpandido.larguraMaximaDaDuracao),
      );
    });
  });

  group('MONT-13 — o web não tem o rodapé fixo do mobile (W-R2)', () {
    testWidgets('não existe BoraFooterBar na árvore', (tester) async {
      await _montar(tester);

      expect(find.byType(BoraFooterBar), findsNothing);
      expect(find.text(MontarTextos.fecharLista), findsNothing);
      expect(find.byType(RailDoCusto), findsOneWidget);
      expect(find.text(MontarTextos.mandarNoGrupo), findsOneWidget);
    });

    testWidgets('rolar o formulário não move o card-herói — o rail é sticky',
        (tester) async {
      await _montar(tester);

      final heroiAntes = tester.getTopLeft(find.byType(BoraHeroCard)).dy;
      final secaoAntes =
          tester.getTopLeft(find.text(MontarTextos.naGrelha).first).dy;

      await tester.drag(
        find.text(MontarTextos.secaoDePessoasExpandido),
        const Offset(0, -150),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getTopLeft(find.text(MontarTextos.naGrelha).first).dy,
        lessThan(secaoAntes),
      );
      expect(tester.getTopLeft(find.byType(BoraHeroCard)).dy, heroiAntes);
    });
  });

  group('MONT-13 — zero scroll horizontal (W-R4)', () {
    for (final janela in [_janelaExpandida, _janelaEstreita]) {
      testWidgets('em ${janela.width.toInt()}x${janela.height.toInt()} '
          'nenhuma rolagem é horizontal', (tester) async {
        await _montar(tester, janela: janela);

        final rolagens =
            tester.widgetList<Scrollable>(find.byType(Scrollable));

        expect(rolagens, isNotEmpty);
        for (final rolagem in rolagens) {
          expect(
            axisDirectionToAxis(rolagem.axisDirection),
            Axis.vertical,
            reason: 'W-R4: rolagem só no documento e na lista viva — nunca '
                'na horizontal',
          );
        }
      });

      testWidgets('em ${janela.width.toInt()}x${janela.height.toInt()} '
          'a tela cabe na largura da janela', (tester) async {
        await _montar(tester, janela: janela);

        final tela = tester.getRect(find.byType(MontarExpandido));

        expect(tela.left, greaterThanOrEqualTo(0));
        expect(tela.right, lessThanOrEqualTo(janela.width));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('numa janela larga o container para no teto de 1060px de W-03',
        (tester) async {
      await _montar(tester, janela: const Size(1600, 900));

      final formulario = tester.getRect(find.byType(FormularioDeMontagem));
      final rail = tester.getRect(find.byType(RailDoCusto));

      expect(
        rail.right - formulario.left,
        lessThanOrEqualTo(
          MontarExpandido.larguraDoContainer -
              MontarExpandido.paddingDoContainer.horizontal,
        ),
      );
      expect(rail.width, RailDoCusto.largura);
    });
  });

  group('MONT-12 — card-herói e lista viva recalculam na mesma interação', () {
    testWidgets('um toque no chip 🍺 CERVEJA muda o total e a lista num pump '
        'só', (tester) async {
      await _montar(tester);

      final cerveja = catalogoDeItens[ChaveItem.cerveja]!.nome;
      final naLista = find.descendant(
        of: find.byType(ListaViva),
        matching: find.text(cerveja),
      );
      final chip = find.byWidgetPredicate(
        (w) => w is BoraSelectionChip && w.rotulo == cerveja,
      );
      final totalAntes = _heroi(tester).valorFormatado;

      expect(naLista, findsOneWidget);

      await tester.ensureVisible(chip);
      await tester.pumpAndSettle();
      await tester.tap(chip);
      await tester.pump();

      expect(_heroi(tester).valorFormatado, isNot(totalAntes));
      expect(
        naLista,
        findsNothing,
        reason: 'MONT-12: os dois leem o mesmo state.resultado, então não há '
            'como um ficar para trás',
      );
    });

    testWidgets('o aceite de UC-03 aparece na tela expandida', (tester) async {
      await _montar(tester);

      final resultado = CalculadoraDaFesta.calcular(_composicaoRn30());

      expect(
        _heroi(tester).valorFormatado,
        MoneyFormatter.reais(resultado.totalDosItens),
      );
      expect(find.text(r'R$ 211'), findsOneWidget);
      expect(
        find.text(
          MontarTextos.porCabecaExpandido(
            MoneyFormatter.reais(resultado.porCabeca),
          ),
        ),
        findsOneWidget,
      );
    });
  });

  group('MONT-22 — as saídas de W-03 saem por callback (AD-020)', () {
    testWidgets('MANDAR NO GRUPO 📲 e SALVAR ROLÊ emitem, cada um o seu',
        (tester) async {
      final emitidos = await _montar(tester);

      await tester.tap(find.byType(BoraPrimaryButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BoraSecondaryButton));
      await tester.pumpAndSettle();

      expect(emitidos.envios, 1);
      expect(emitidos.salvamentos, 1);
    });

    testWidgets('mexer no segmented emite as horas da opção tocada',
        (tester) async {
      final emitidos = await _montar(tester);

      final seisHoras = find.text(MontarTextos.opcoesDeDuracao[2].toUpperCase());

      await tester.ensureVisible(seisHoras);
      await tester.pumpAndSettle();
      await tester.tap(seisHoras);
      await tester.pumpAndSettle();

      expect(emitidos.duracoes, [6]);
    });
  });
}
