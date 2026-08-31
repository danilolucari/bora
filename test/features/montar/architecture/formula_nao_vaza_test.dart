import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/montar/domain/rascunho_inicial.dart';
import 'package:bora/features/montar/presentation/bloc/montar_state.dart';
import 'package:bora/features/montar/presentation/widgets/montar_compacto.dart';
import 'package:bora/features/montar/presentation/widgets/montar_expandido.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../core/design_system/support/font_loading.dart';
import '../../../support/cifrao_na_fonte.dart';

const String _diretorioDeMontar = 'lib/features/montar';

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
/// string. Comentário que cita "R$ 211" para explicar o aceite de UC-03 não
/// escreve nada em tela nenhuma — e três arquivos desta feature o fazem, de
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
  RegraDaFronteira('importa arquivo interno de core/calculo', _importaInterno),
];

/// Regra 1, sobre as **duas** formas do cifrão na fonte — ver
/// [formasDoCifraoNaFonte]. Procurar só a contígua deixava passar exatamente
/// a forma que um infrator escreveria (`Text('R\$ …')`).
List<String> _escreveDinheiro(String fonte) => cifraoEm(semComentarios(fonte));

/// Regra 2, com a **família inteira** de arredondamento e conversão: quem quer
/// o inteiro de RN-13 sem passar por `MoneyFormatter` chega lá por qualquer
/// uma delas, e `.toInt(` é a mais curta.
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

List<String> _fazConta(String fonte) =>
    _ocorrenciasDe(codigoDe(fonte), ['*', '/', '%']);

List<String> _somaLista(String fonte) =>
    _ocorrenciasDe(codigoDe(fonte), ['.fold(', '.reduce(', '.sum']);

List<String> _importaInterno(String fonte) => _diretivaDeImport
    .allMatches(fonte)
    .map((m) => m.group(1)!)
    .where(
      (alvo) =>
          alvo.contains('core/calculo/') &&
          !alvo.endsWith('core/calculo/calculo.dart'),
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

/// O estado da tela para uma composição — o resultado sai da calculadora, que
/// é a única fonte de conta do app.
MontarState _estadoCom(ComposicaoDaFesta composicao) => MontarState(
      festa: rascunhoInicial(hoje: DateTime(2026, 7, 15)).festa,
      composicao: composicao,
      resultado: CalculadoraDaFesta.calcular(composicao),
    );

/// O estado padrão de RN-30 — o total dele é **210,60**, com centavos.
ComposicaoDaFesta _composicaoRn30() => ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: duracaoDefaultDoRole,
      itensSelecionados: itensPadraoDoRole,
    );

void main() {
  setUpAll(carregarFontesArchivo);

  group('MONT-08 — lib/features/montar/** não faz conta nem formata dinheiro',
      () {
    test('nenhum arquivo viola nenhuma das cinco regras de §13', () {
      expect(
        violacoesEm(Directory(_diretorioDeMontar)),
        isEmpty,
        reason: 'a fórmula é da camada de cálculo: se um número faltar, ele '
            'nasce em core/calculo, não aqui',
      );
    });

    test('a varredura não roda vazia: o diretório existe e tem arquivo .dart',
        () {
      final diretorio = Directory(_diretorioDeMontar);

      expect(diretorio.existsSync(), isTrue);
      expect(arquivosDartEm(diretorio).length, greaterThan(10));
    });

    test('as cinco regras de §13 estão declaradas', () {
      expect(regrasDaFronteira, hasLength(5));
    });
  });

  group('MONT-08 — cada regra pega o caso que devia pegar', () {
    test('regra 1: a tela que escreve o cifrão é acusada', () {
      final violacoes = violacoesNaFonte(
        "Text('R\$ \$total');",
        'infrator.dart',
      );

      expect(violacoes, hasLength(1));
      expect(violacoes.single, contains('infrator.dart'));
      expect(violacoes.single, contains('escreve R\$ na tela'));
    });

    test('regra 1: a fonte como ela se escreve em Dart — com o cifrão '
        'escapado — é acusada', () {
      // Os três caracteres que estão **no disco** quando alguém escreve
      // `Text('R\$ ${total}')`: `R`, barra invertida, `$`. É a única forma de
      // pôr o cifrão numa string comum, e era por onde a regra 1 passava.
      final violacoes = violacoesNaFonte(
        r"Text('R\$ ${resultado.totalDosItens}');",
        'infrator.dart',
      );

      expect(
        violacoes.where((v) => v.contains('escreve R\$ na tela')),
        hasLength(1),
        reason: 'a varredura lê a fonte do disco, onde o cifrão está '
            'escapado — não a string já desescapada',
      );
      expect(
        violacoes.where((v) => v.contains('escreve R\$ na tela')).single,
        contains('infrator.dart'),
      );
    });

    test('regra 1: as duas formas do cifrão na fonte estão declaradas', () {
      expect(formasDoCifraoNaFonte, hasLength(2));
      expect(cifraoEm(r'const cifrao = "R\$";'), isNotEmpty);
      expect(cifraoEm(r"const cifrao = r'R$';"), isNotEmpty);
      expect(cifraoEm("Text(MoneyFormatter.reais(total));"), isEmpty);
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
        final violacoes = violacoesNaFonte(infrator, 'infrator.dart');

        expect(
          violacoes.map((v) => v).join(),
          contains('arredonda ou formata número'),
          reason: '$infrator deveria ser acusado',
        );
      }
    });

    test('regra 3: a conta escrita no widget é acusada', () {
      for (final infrator in [
        'final v = total / pessoas;',
        'final v = quantidade * fator;',
        'final v = total % 2;',
      ]) {
        expect(
          violacoesNaFonte(infrator, 'infrator.dart').join(),
          contains('faz conta'),
          reason: '$infrator deveria ser acusado',
        );
      }
    });

    test('regra 3: a conta escondida dentro de uma interpolação é acusada',
        () {
      expect(
        violacoesNaFonte(r"Text('${total / pessoas}');", 'infrator.dart')
            .join(),
        contains('faz conta'),
        reason: 'o miolo de uma interpolação é código, e é onde uma conta se '
            'esconderia de uma varredura que jogasse a string inteira fora',
      );
    });

    test('regra 4: a soma da lista feita à mão é acusada', () {
      for (final infrator in [
        'final v = itens.fold(0.0, soma);',
        'final v = valores.reduce(soma);',
        'final v = valores.sum;',
      ]) {
        expect(
          violacoesNaFonte(infrator, 'infrator.dart').join(),
          contains('soma lista'),
          reason: '$infrator deveria ser acusado',
        );
      }
    });

    test('regra 5: o import de arquivo interno da camada é acusado', () {
      final violacoes = violacoesNaFonte(
        "import '../../../../core/calculo/regras/calculadora_da_festa.dart';",
        'infrator.dart',
      );

      expect(
        violacoes.join(),
        contains('importa arquivo interno de core/calculo'),
      );
      expect(violacoes.join(), contains('calculadora_da_festa.dart'));
    });

    test('a mensagem nomeia o arquivo e a regra, uma linha por violação', () {
      final violacoes = violacoesNaFonte(
        'final v = total / pessoas.round();',
        'lib/features/montar/x.dart',
      );

      expect(violacoes, hasLength(2));
      expect(
        violacoes,
        containsAll([
          'lib/features/montar/x.dart: arredonda ou formata número (.round()',
          'lib/features/montar/x.dart: faz conta (/)',
        ]),
      );
    });
  });

  group('MONT-08 — a varredura não acusa o inocente', () {
    test('o import do barrel não é conta nem import interno', () {
      expect(
        violacoesNaFonte(
          "import '../../../../core/calculo/calculo.dart';",
          'limpo.dart',
        ),
        isEmpty,
        reason: 'as duas barras do caminho estão dentro de uma string, e o '
            'barrel é a porta legítima da camada',
      );
    });

    test('comentário que cita a fórmula e o R\$ do aceite não é violação', () {
      expect(
        violacoesNaFonte(
          '/// O aceite de UC-03 dá R\$ 211, que é total / pessoas.\n'
          '// 50% do fator * 2\n'
          '/* R\$ 271 por adulto */\n'
          'final estado = bloc.state;',
          'limpo.dart',
        ),
        isEmpty,
      );
    });

    test('string comum com barra não vira divisão', () {
      expect(
        violacoesNaFonte("const rotulo = 'por cabeça / por adulto';",
            'limpo.dart'),
        isEmpty,
      );
    });
  });

  group('MONT-08 — o teste comportamental: o valor da tela é o da camada', () {
    testWidgets('em T-03, o total com centavos é o de MoneyFormatter',
        (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(390, 820));

      final estado = _estadoCom(_composicaoRn30());

      await tester.pumpWidget(
        MaterialApp(
          theme: boraTheme(),
          home: Scaffold(
            body: MontarCompacto(
              estado: estado,
              aoVoltar: () {},
              aoAlterarContagem: (_, _) {},
              aoAlternarItem: (_) {},
              aoSelecionarDuracao: (_) {},
              aoAlterarNome: (_) {},
              aoAlterarData: (_) {},
              aoFecharLista: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final total = estado.resultado.totalDosItens;

      expect(total, closeTo(210.6, 0.001));
      expect(
        tester.widget<BoraFooterBar>(find.byType(BoraFooterBar)).valorFormatado,
        MoneyFormatter.reais(total),
      );
      expect(
        find.text(MoneyFormatter.reais(total)),
        findsOneWidget,
        reason: 'um formatador próprio que truncasse mostraria outro número e '
            'passaria na varredura — é aqui que ele morre',
      );
      expect(MoneyFormatter.reais(total), isNot(r'R$ 210'));
    });

    testWidgets('em W-03, o card-herói mostra o mesmo número da camada',
        (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(const Size(1180, 800));

      final estado = _estadoCom(_composicaoRn30());

      await tester.pumpWidget(
        MaterialApp(
          theme: boraTheme(),
          home: Scaffold(
            body: MontarExpandido(
              estado: estado,
              aoAlterarContagem: (_, _) {},
              aoAlternarItem: (_) {},
              aoSelecionarDuracao: (_) {},
              aoMandarNoGrupo: () {},
              aoSalvar: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final resultado = estado.resultado;

      expect(
        tester.widget<BoraHeroCard>(find.byType(BoraHeroCard)).valorFormatado,
        MoneyFormatter.reais(resultado.totalDosItens),
      );
      expect(
        tester.widget<BoraHeroCard>(find.byType(BoraHeroCard)).sublinha,
        contains(MoneyFormatter.reais(resultado.porCabeca)),
      );
      expect(MoneyFormatter.reais(resultado.porCabeca), r'R$ 30');
    });
  });
}
