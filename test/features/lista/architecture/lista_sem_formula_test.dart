import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/lista/presentation/bloc/lista_bloc.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
import 'package:bora/features/lista/presentation/widgets/checkbox_da_lista.dart';
import 'package:bora/features/lista/presentation/widgets/linha_de_item.dart';
import 'package:bora/features/lista/presentation/widgets/lista_compacta.dart';
import 'package:bora/features/lista/presentation/widgets/lista_expandida.dart';
import 'package:bora/features/lista/presentation/widgets/painel_de_override.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/cifrao_na_fonte.dart';
import '../../../support/festa_em_edicao_repository_fake.dart';
import '../../../support/recording_app_logger.dart';
import '../support/festa_rn30.dart';

const String _diretorioDaLista = 'lib/features/lista';

/// Os arquivos isentos da regra 1 — **e a lista é vazia de propósito**.
///
/// A T12 podia ter pedido uma exceção nomeada para `lista_textos.dart`: as três
/// frases que a spec escreve com o cifrão (a faixa real, o "por adulto" e a
/// linha do overlay) passam por lá. Em vez disso, o arquivo de copy recebe as
/// strings **já formatadas** por `MoneyFormatter` e nunca escreve o cifrão —
/// então RN-13 continua sendo só da camada de cálculo e o guard vale na feature
/// inteira, sem buraco.
///
/// Fica declarado e nomeado aqui porque a alternativa era uma exceção
/// silenciosa: quem lesse o guard não saberia que a decisão existiu.
const List<String> arquivosIsentosDaRegra1 = [];

/// O código de [fonte], **sem comentários e sem o conteúdo das strings**.
///
/// É o que impede o falso positivo mais óbvio: `import '../../x.dart'` tem
/// duas barras e não é divisão nenhuma. Comentário também sai — este projeto
/// documenta a regra citando a fórmula, e prosa não é conta.
///
/// O que **não** sai é o miolo de uma interpolação: `'${a / b}'` é código
/// escrito dentro de uma string, e é exatamente por onde uma conta se
/// esconderia de uma varredura ingênua.
String codigoDe(String fonte) {
  final buffer = StringBuffer();
  var i = 0;

  bool ehLetra(int indice) {
    if (indice < 0 || indice >= fonte.length) return false;
    return RegExp('[A-Za-z0-9_]').hasMatch(fonte[indice]);
  }

  while (i < fonte.length) {
    final c = fonte[i];

    if (c == '/' && i + 1 < fonte.length && fonte[i + 1] == '/') {
      while (i < fonte.length && fonte[i] != '\n') {
        i++;
      }
      continue;
    }

    if (c == '/' && i + 1 < fonte.length && fonte[i + 1] == '*') {
      i += 2;
      while (i + 1 < fonte.length &&
          !(fonte[i] == '*' && fonte[i + 1] == '/')) {
        i++;
      }
      i += 2;
      continue;
    }

    // Uma string começa aqui: `'`, `"`, ou o `r` cru de `r'…'`.
    final cru = c == 'r' &&
        !ehLetra(i - 1) &&
        i + 1 < fonte.length &&
        (fonte[i + 1] == "'" || fonte[i + 1] == '"');
    if (cru || c == "'" || c == '"') {
      if (cru) i++;

      final aspa = fonte[i];
      final tripla = fonte.startsWith(aspa * 3, i);
      final fim = tripla ? aspa * 3 : aspa;
      i += fim.length;

      while (i < fonte.length && !fonte.startsWith(fim, i)) {
        if (!cru && fonte[i] == r'\') {
          i += 2;
          continue;
        }

        // Interpolação com chaves: o miolo é código e volta para a varredura.
        if (!cru && fonte.startsWith(r'${', i)) {
          i += 2;
          var profundidade = 1;
          while (i < fonte.length && profundidade > 0) {
            if (fonte[i] == '{') profundidade++;
            if (fonte[i] == '}') profundidade--;
            if (profundidade > 0) buffer.write(fonte[i]);
            i++;
          }
          continue;
        }

        i++;
      }
      i += fim.length;
      continue;
    }

    buffer.write(c);
    i++;
  }

  return buffer.toString();
}

/// A fonte sem comentários, **com as strings inteiras**.
///
/// É a leitura da regra 1 do `design.md` §13 ("sem stripping"): o que ela
/// proíbe é a tela **escrever** o cifrão, e o cifrão só chega à tela por uma
/// string. Comentário que cita "R$ 271" para explicar o aceite de UC-05 não
/// escreve nada em tela nenhuma — e vários arquivos desta feature o fazem, de
/// propósito, citando a spec.
String semComentarios(String fonte) => fonte
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .replaceAll(RegExp('//.*'), '');

final RegExp _diretivaDeImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

/// Uma das cinco regras de `design.md` §13.
class RegraDaFronteira {
  const RegraDaFronteira(this.nome, this.achados);

  /// O nome que aparece na mensagem de falha, junto do arquivo infrator.
  final String nome;

  /// O que a regra encontrou na fonte **crua** — vazio quando está limpa.
  final List<String> Function(String fonte) achados;
}

List<String> _ocorrenciasDe(String texto, List<String> proibidos) => [
      for (final proibido in proibidos)
        if (texto.contains(proibido)) proibido,
    ];

/// As cinco regras, na ordem de `design.md` §13.
const List<RegraDaFronteira> regrasDaFronteira = [
  RegraDaFronteira('escreve R\$ na tela', _escreveDinheiro),
  RegraDaFronteira('arredonda ou formata número', _arredonda),
  RegraDaFronteira('faz conta', _fazConta),
  RegraDaFronteira('soma lista', _somaLista),
  RegraDaFronteira(
    'importa arquivo interno de core/calculo ou core/festas',
    _importaInterno,
  ),
];

/// Regra 1, sobre as **duas** formas do cifrão na fonte — ver
/// [formasDoCifraoNaFonte]. Em Dart o cifrão só existe numa string comum
/// **escapado** (`R\$`, três caracteres no disco) ou numa raw string (`r'R$'`).
/// Uma varredura que procurasse só a forma contígua deixaria passar exatamente
/// a forma que um infrator escreveria — foi o furo real de MONT-08 (GAP-1).
List<String> _escreveDinheiro(String fonte) => cifraoEm(semComentarios(fonte));

/// Regra 2, com a **família inteira** de arredondamento e conversão: quem quer
/// o inteiro de RN-13 sem passar por `MoneyFormatter` chega lá por qualquer uma
/// delas, e `.toInt(` é a mais curta. §13 nomeia seis; as demais são a mesma
/// regra escrita por extenso, e nenhuma delas tem uso legítimo nesta feature.
List<String> _arredonda(String fonte) => _ocorrenciasDe(codigoDe(fonte), [
      '.round(',
      '.floor(',
      '.ceil(',
      '.truncate(',
      '.roundToDouble(',
      '.floorToDouble(',
      '.ceilToDouble(',
      '.truncateToDouble(',
      '.toInt(',
      '.toStringAsFixed(',
      '.toStringAsPrecision(',
    ]);

/// Regra 3: subtotal, "por adulto", fator e fração do marcador vêm prontos.
List<String> _fazConta(String fonte) =>
    _ocorrenciasDe(codigoDe(fonte), ['*', '/', '%']);

/// Regra 4: somar itens é `totalExato` / `subtotalDeItens` / `faixaRealDaLista`.
List<String> _somaLista(String fonte) =>
    _ocorrenciasDe(codigoDe(fonte), ['.fold(', '.reduce(', '.sum']);

/// Regra 5: os barrels `calculo.dart` e `festas.dart` são as **únicas** portas
/// das duas camadas.
List<String> _importaInterno(String fonte) => _diretivaDeImport
    .allMatches(fonte)
    .map((m) => m.group(1)!)
    .where(
      (alvo) =>
          (alvo.contains('core/calculo/') &&
              !alvo.endsWith('core/calculo/calculo.dart')) ||
          (alvo.contains('core/festas/') &&
              !alvo.endsWith('core/festas/festas.dart')),
    )
    .toList();

List<File> arquivosDartEm(Directory diretorio) => diretorio
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

/// Uma linha por violação, no formato `<arquivo>: <regra> (<achado>)` — é o
/// que nomeia **o arquivo e a regra** quando a suíte quebra.
List<String> violacoesEm(Directory diretorio) => [
      for (final arquivo in arquivosDartEm(diretorio))
        ...violacoesNaFonte(arquivo.readAsStringSync(), arquivo.path),
    ];

List<String> violacoesNaFonte(String fonte, String caminho) => [
      for (final regra in regrasDaFronteira)
        for (final achado in regra.achados(fonte))
          '$caminho: ${regra.nome} ($achado)',
    ];

const Size _frameCompacto = Size(390, 820);
const Size _janelaExpandida = Size(1180, 800);
const String _festaId = 'rafa18';

FestaEmEdicao _festaRn30() => FestaEmEdicao(
      festa: Festa(
        nome: 'CHURRAS DO RAFA',
        data: 'SÁB · 18 JUL',
        hora: '14H',
        local: 'Laje do Rafa — Vila Madalena',
        duracaoHoras: 4,
      ),
      composicao: composicaoRn30(),
    );

/// Monta a tela no modo compacto ou expandido, com o bloc real.
Future<ListaBloc> _montarTela(
  WidgetTester tester, {
  Size viewport = _frameCompacto,
}) async {
  final porta = FestaEmEdicaoRepositoryFake(festas: {_festaId: _festaRn30()});
  addTearDown(porta.dispose);

  final bloc = ListaBloc(porta, RecordingAppLogger(), festaId: _festaId);
  addTearDown(bloc.close);

  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.binding.setSurfaceSize(viewport);
  await tester.pumpWidget(
    MaterialApp(
      theme: boraTheme(),
      home: Scaffold(
        backgroundColor: BoraColors.paper,
        body: BlocBuilder<ListaBloc, ListaState>(
          bloc: bloc,
          builder: (context, estado) => viewport == _frameCompacto
              ? ListaCompacta(
                  estado: estado,
                  aoAlternarModo: (modo) => bloc.add(ModoAlternado(modo)),
                  aoAlternarItem: (chave) => bloc.add(ItemExpandido(chave)),
                  aoAjustarQuantidade: (chave, passos) =>
                      bloc.add(QuantidadeAjustada(chave, passos)),
                  aoAjustarPreco: (chave, passos) =>
                      bloc.add(PrecoAjustado(chave, passos)),
                  aoAlternarNoCarrinho: (chave) =>
                      bloc.add(ItemAlternadoNoCarrinho(chave)),
                  aoRestaurar: () => bloc.add(const OverridesRestaurados()),
                  aoPedir: () {},
                )
              : ListaExpandida(
                  estado: estado,
                  aoAlternarModo: (modo) => bloc.add(ModoAlternado(modo)),
                  aoAlternarItem: (chave) => bloc.add(ItemExpandido(chave)),
                  aoAjustarQuantidade: (chave, passos) =>
                      bloc.add(QuantidadeAjustada(chave, passos)),
                  aoAjustarPreco: (chave, passos) =>
                      bloc.add(PrecoAjustado(chave, passos)),
                  aoAlternarNoCarrinho: (chave) =>
                      bloc.add(ItemAlternadoNoCarrinho(chave)),
                  aoRestaurar: () => bloc.add(const OverridesRestaurados()),
                  aoPedir: () {},
                ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return bloc;
}

void main() {
  group('LIST-07 — lib/features/lista/** não faz conta nem formata dinheiro',
      () {
    test('nenhum arquivo viola nenhuma das cinco regras de §13', () {
      expect(
        violacoesEm(Directory(_diretorioDaLista)),
        isEmpty,
        reason: 'a fórmula é da camada de cálculo: se um número faltar, ele '
            'nasce em core/calculo, não aqui',
      );
    });

    test('a varredura não roda vazia: o diretório existe e tem arquivo .dart',
        () {
      final diretorio = Directory(_diretorioDaLista);

      expect(diretorio.existsSync(), isTrue);
      expect(arquivosDartEm(diretorio).length, greaterThan(15));
    });

    test('as cinco regras de §13 estão declaradas', () {
      expect(regrasDaFronteira, hasLength(5));
    });

    test('a regra 1 não tem exceção: lista_textos.dart não escreve o cifrão',
        () {
      final copy = File('$_diretorioDaLista/presentation/lista_textos.dart');

      expect(copy.existsSync(), isTrue);
      expect(
        arquivosIsentosDaRegra1,
        isEmpty,
        reason: 'a T12 fez o arquivo de copy receber a string já formatada, '
            'então nenhuma isenção é necessária — e nenhuma é silenciosa',
      );
      expect(
        violacoesNaFonte(copy.readAsStringSync(), copy.path),
        isEmpty,
        reason: 'o arquivo de copy passa pela varredura como qualquer outro',
      );
    });
  });

  group('LIST-07 — cada regra pega o caso que devia pegar', () {
    test('regra 1: a raw string com o cifrão contíguo é acusada', () {
      final violacoes = violacoesNaFonte(
        "Text(r'R\$ 271');",
        'lib/features/lista/infrator.dart',
      );

      expect(violacoes, hasLength(1));
      expect(violacoes.single, contains('lib/features/lista/infrator.dart'));
      expect(violacoes.single, contains('escreve R\$ na tela'));
    });

    test('regra 1: a fonte como ela se escreve em Dart — com o cifrão '
        'escapado — é acusada', () {
      // Os três caracteres que estão **no disco** quando alguém escreve
      // `Text('R\$ ${total}')`: `R`, barra invertida, `$`. É a única forma de
      // pôr o cifrão numa string comum, e é por onde o guard de MONT-08
      // passava antes de GAP-1 ser fechado.
      final violacoes = violacoesNaFonte(
        r"Text('R\$ ${resultado.totalComEssenciais}');",
        'lib/features/lista/infrator.dart',
      );

      expect(
        violacoes.where((v) => v.contains('escreve R\$ na tela')),
        hasLength(1),
        reason: 'a varredura lê a fonte do disco, onde o cifrão está '
            'escapado — não a string já desescapada',
      );
      expect(
        violacoes.where((v) => v.contains('escreve R\$ na tela')).single,
        contains('lib/features/lista/infrator.dart'),
      );
    });

    test('regra 1: as duas formas do cifrão na fonte estão declaradas', () {
      expect(formasDoCifraoNaFonte, hasLength(2));
      expect(cifraoEm(r'const cifrao = "R\$";'), isNotEmpty);
      expect(cifraoEm(r"const cifrao = r'R$';"), isNotEmpty);
      expect(cifraoEm('Text(MoneyFormatter.reais(total));'), isEmpty);
    });

    test('regra 2: o arredondamento próprio é acusado', () {
      for (final infrator in [
        'final v = total.round();',
        'final v = total.floor();',
        'final v = total.ceil();',
        'final v = total.truncate();',
        'final v = total.roundToDouble();',
        'final v = total.floorToDouble();',
        'final v = total.ceilToDouble();',
        'final v = total.truncateToDouble();',
        'final v = total.toInt();',
        'final v = total.toStringAsFixed(2);',
        'final v = total.toStringAsPrecision(3);',
      ]) {
        expect(
          violacoesNaFonte(infrator, 'lib/features/lista/infrator.dart').join(),
          contains('arredonda ou formata número'),
          reason: '$infrator deveria ser acusado',
        );
      }
    });

    test('regra 3: a conta escrita no widget é acusada', () {
      for (final infrator in [
        'final v = totalComEssenciais / adultos;',
        'final v = quantidade * fator;',
        'final v = total % 2;',
      ]) {
        expect(
          violacoesNaFonte(infrator, 'lib/features/lista/infrator.dart').join(),
          contains('faz conta'),
          reason: '$infrator deveria ser acusado',
        );
      }
    });

    test('regra 3: a conta escondida dentro de uma interpolação é acusada',
        () {
      expect(
        violacoesNaFonte(
          r"Text('${(media - minimo) / (maximo - minimo)}');",
          'lib/features/lista/infrator.dart',
        ).join(),
        contains('faz conta'),
        reason: 'o miolo de uma interpolação é código, e é onde a fração do '
            'marcador se esconderia de uma varredura ingênua',
      );
    });

    test('regra 4: a soma da lista feita à mão é acusada', () {
      for (final infrator in [
        'final v = itens.fold(0.0, soma);',
        'final v = valores.reduce(soma);',
        'final v = valores.sum;',
      ]) {
        expect(
          violacoesNaFonte(infrator, 'lib/features/lista/infrator.dart').join(),
          contains('soma lista'),
          reason: '$infrator deveria ser acusado',
        );
      }
    });

    test('regra 5: o import de arquivo interno das duas camadas é acusado',
        () {
      for (final (infrator, arquivo) in [
        (
          "import '../../../../core/calculo/regras/totais.dart';",
          'totais.dart',
        ),
        (
          "import '../../../../core/festas/dominio/festa_em_edicao.dart';",
          'festa_em_edicao.dart',
        ),
      ]) {
        final violacoes = violacoesNaFonte(
          infrator,
          'lib/features/lista/infrator.dart',
        );

        expect(
          violacoes.join(),
          contains('importa arquivo interno de core/calculo ou core/festas'),
          reason: '$infrator deveria ser acusado',
        );
        expect(violacoes.join(), contains(arquivo));
      }
    });

    test('a varredura de diretório acha o infrator no disco e o nomeia', () {
      // Fecha o laço entre as regras e `violacoesEm`: as regras já mordem
      // trecho sintético, mas nada provava que a **varredura de diretório**
      // chegaria até um arquivo de verdade. O infrator nasce e morre num
      // diretório temporário — a árvore real nunca é mutada.
      final temporario = Directory.systemTemp.createTempSync('lista-guard');
      addTearDown(() => temporario.deleteSync(recursive: true));

      File('${temporario.path}/infrator.dart').writeAsStringSync(
        [
          'final porAdulto = total / adultos;',
          r"Text('R\$ ${porAdulto}');",
        ].join('\n'),
      );
      File('${temporario.path}/limpo.dart').writeAsStringSync(
        'Text(MoneyFormatter.reais(total));',
      );

      final violacoes = violacoesEm(temporario);

      expect(violacoes, hasLength(2));
      expect(violacoes.every((v) => v.contains('infrator.dart')), isTrue);
      expect(violacoes.join(), contains('faz conta'));
      expect(violacoes.join(), contains('escreve R\$ na tela'));
      expect(violacoes.join(), isNot(contains('limpo.dart')));
    });

    test('a mensagem nomeia o arquivo e a regra, uma linha por violação', () {
      final violacoes = violacoesNaFonte(
        'final v = totalComEssenciais / adultos.round();',
        'lib/features/lista/x.dart',
      );

      expect(violacoes, hasLength(2));
      expect(
        violacoes,
        containsAll([
          'lib/features/lista/x.dart: arredonda ou formata número (.round()',
          'lib/features/lista/x.dart: faz conta (/)',
        ]),
      );
    });
  });

  group('LIST-07 — a varredura não acusa o inocente', () {
    test('os dois barrels são a porta legítima das camadas', () {
      expect(
        violacoesNaFonte(
          "import '../../../../core/calculo/calculo.dart';\n"
          "import '../../../../core/festas/festas.dart';",
          'limpo.dart',
        ),
        isEmpty,
      );
    });

    test('comentário que cita a fórmula e o R\$ do aceite não é violação', () {
      expect(
        violacoesNaFonte(
          '/// O aceite de UC-05 dá R\$ 271, que é total / adultos.\n'
          '// 50% do fator * 2\n'
          '/* faixa real: de R\$ 245 a R\$ 343 */\n'
          'final estado = bloc.state;',
          'limpo.dart',
        ),
        isEmpty,
      );
    });
  });

  group('LIST-07 — o comportamento: o número da tela é o da camada', () {
    testWidgets('o total fracionário do estado padrão é o de MoneyFormatter',
        (tester) async {
      final bloc = await _montarTela(tester);
      final resultado = bloc.state.resultado!;

      expect(resultado.totalDosItens, closeTo(210.6, 0.001));
      expect(resultado.totalComEssenciais, closeTo(270.6, 0.001));
      expect(
        find.descendant(
          of: find.byType(BlocoDeTotal),
          matching:
              find.text(MoneyFormatter.reais(resultado.totalComEssenciais)),
        ),
        findsOneWidget,
        reason: 'um formatador próprio que truncasse mostraria outro número e '
            'passaria na varredura — é aqui que ele morre',
      );
      expect(MoneyFormatter.reais(resultado.totalComEssenciais), r'R$ 271');
      expect(MoneyFormatter.reais(resultado.totalComEssenciais), isNot(r'R$ 270'));
    });

    testWidgets('a fração da barra de faixa é a de posicaoDoMarcador',
        (tester) async {
      await _montarTela(tester);

      final leitura = LinhaDeItem.leituraDeMercadoDe(ChaveItem.bovina)!;
      final barra = tester.widget<BoraPriceRangeBar>(
        find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is LinhaDeItem && widget.item.chave == ChaveItem.bovina,
          ),
          matching: find.byType(BoraPriceRangeBar),
        ),
      );

      expect(
        barra.fracao,
        posicaoDoMarcador(leitura),
        reason: 'uma divisão feita no widget passaria na regra 3 se escrita '
            'como propriedade de outra classe, e morre aqui',
      );
      expect(
        barra.fracao,
        closeTo(0.379, 0.001),
        reason: 'UC-14: o marcador da Picanha fica a 37,9% do trilho',
      );
      expect(barra.rotuloMin, MoneyFormatter.reais(leitura.minimo));
      expect(barra.rotuloMax, MoneyFormatter.reais(leitura.maximo));
    });
  });

  group('A-23 — a tela não tem toast, nem na fonte nem na árvore', () {
    test('nenhum arquivo da feature cita BoraToast', () {
      final citam = [
        for (final arquivo in arquivosDartEm(Directory(_diretorioDaLista)))
          if (semComentarios(arquivo.readAsStringSync()).contains('BoraToast'))
            arquivo.path,
      ];

      expect(
        citam,
        isEmpty,
        reason: 'RN-29 não tem texto canônico para nenhuma ação desta tela, e '
            'inventar um seria copy nossa num produto de copy literal',
      );
    });

    testWidgets('em W-04, nenhuma ação da tela põe um BoraToast na árvore',
        (tester) async {
      await _montarTela(tester, viewport: _janelaExpandida);

      await tester.tap(find.byType(LinhaDeItem).first);
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is BotaoDePasso &&
              widget.simbolo == BoraStepper.simboloMais,
        ).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(RailDaLista.restaurarKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text(ListaTextos.modoComprar.toUpperCase()));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxDaLista).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(RailDaLista.ctaKey));
      await tester.pumpAndSettle();

      expect(find.byKey(BoraToastContent.toastKey), findsNothing);
      expect(find.byType(BoraToastContent), findsNothing);
    });
  });
}
