import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A pasta inteira da feature — a fronteira que estes guards vigiam.
const String _diretorioDaGalera = 'lib/features/galera';

/// A metade pura da feature: **Dart puro**, para a spec 09 traduzir RN-22 em
/// security rules sem arrastar UI junto (GAL-19 AC7).
const String _diretorioDoDominio = 'lib/features/galera/domain';

/// O caminho com separador **normalizado** para `/`.
///
/// Sem isto o guard fica verde no POSIX e vermelho no Windows, ou pior: a
/// comparação `caminho.contains('galera/domain')` nunca casaria aqui, onde o
/// `Directory.listSync` devolve `lib\features\galera\domain\…` (L-006).
String caminhoNormalizado(String caminho) => caminho.replaceAll(r'\', '/');

/// O código de [fonte], **sem comentários e sem o conteúdo das strings**.
///
/// É o que impede o falso positivo mais óbvio: `import '../../x.dart'` tem
/// duas barras e não é divisão nenhuma. Comentário também sai — esta feature
/// documenta a regra citando a fórmula e a copy de RN-21, e prosa não é
/// código.
///
/// O que **não** sai é o miolo de uma interpolação: `'${a * b}'` é código
/// escrito dentro de uma string, e é exatamente por onde uma conta se
/// esconderia de uma varredura ingênua.
///
/// Copiado, e não importado, do guard de `montar`/`lista`: um guard que
/// depende do arquivo de outra feature morre junto com ele.
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
/// É a leitura das regras 2 e 3: a copy e a cor chegam à tela por uma string
/// ou por um literal, e um comentário que cita a frase de RN-21 para explicar
/// de onde ela vem não escreve nada em tela nenhuma.
String semComentarios(String fonte) => fonte
    .replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '')
    .replaceAll(RegExp('//.*'), '');

final RegExp _diretivaDeImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

/// Uma das quatro regras de fronteira de `design.md` §13.
class RegraDaFronteira {
  const RegraDaFronteira(this.nome, this.achados, {this.soNoDominio = false});

  /// O nome que aparece na mensagem de falha, junto do arquivo infrator.
  final String nome;

  /// O que a regra encontrou — vazio quando o arquivo está limpo.
  final List<String> Function(String fonte) achados;

  /// `true` ⇒ a regra só vale para `domain/` (a pureza de GAL-19 AC7).
  final bool soNoDominio;
}

List<String> _ocorrenciasDe(String texto, List<String> proibidos) => [
      for (final proibido in proibidos)
        if (texto.contains(proibido)) proibido,
    ];

/// Um número **inteiro na fonte**, e não um pedaço de outro maior.
///
/// `contains('400')` acusaria `2400` e `0.400`; a fronteira de dígito é o que
/// faz a regra morder a constante e só ela.
List<String> _numerosProibidosEm(String codigo, List<String> numeros) => [
      for (final numero in numeros)
        if (RegExp('(?<![0-9.])${RegExp.escape(numero)}(?![0-9.])')
            .hasMatch(codigo))
          numero,
    ];

/// As constantes de RN-03 e RN-05 — nas **duas** formas em que a regra as
/// escreve: os gramas/mililitros por pessoa do código de `core/calculo`, e os
/// quilos por pessoa da prosa de `03` (`0.4` kg é `400` g).
///
/// Quem reescrever a quantidade por pessoa aqui chega por uma das duas.
const List<String> constantesDeQuantidade = [
  '0.4',
  '0.3',
  '0.2',
  '0.15',
  '0.5',
  '400',
  '300',
  '250',
  '200',
  '120',
  '350',
  '1500',
  '2000',
  '1000',
];

/// A frase de RN-21, **inteira**.
///
/// Ela vem de `resumoDasPreferencias`, em `core/calculo`, e a feature só
/// concatena o `'💡 '` (GAL-13 AC5). Escrevê-la aqui — ainda mais como
/// template com interpolação — criaria uma segunda cópia da copy da regra,
/// que divergiria no primeiro ajuste sem que nada avisasse.
const String fraseDeRn21 = 'A lista já se ajusta às preferências';

/// As quatro regras, na ordem de `design.md` §13.
const List<RegraDaFronteira> regrasDaFronteira = [
  RegraDaFronteira('reescreve quantidade de RN-03/RN-05', _reescreveQuantidade),
  RegraDaFronteira('reescreve a frase de RN-21', _reescreveAFrase),
  RegraDaFronteira('literal de cor, fonte ou sombra', _literalDeEstilo),
  RegraDaFronteira(
    'importa Flutter no domínio',
    _importaFlutter,
    soNoDominio: true,
  ),
];

/// Regra 1 — a fórmula de RN-03, RN-05 e RN-21 não se escreve aqui.
///
/// `adultosQueBebem` e `max(0, adultos -` são a reescrita literal de RN-21; o
/// `math.` fecha a porta larga, porque não há aritmética legítima a fazer
/// nesta feature.
List<String> _reescreveQuantidade(String fonte) {
  final codigo = codigoDe(fonte);

  return [
    ..._numerosProibidosEm(codigo, constantesDeQuantidade),
    ..._ocorrenciasDe(codigo, [
      'adultosQueBebem',
      'max(0, adultos -',
      'math.',
    ]),
  ];
}

/// Regra 2 — a frase de RN-21 não é recomposta aqui, com ou sem interpolação.
List<String> _reescreveAFrase(String fonte) =>
    _ocorrenciasDe(semComentarios(fonte), [fraseDeRn21]);

/// Regra 3 — nenhuma cor, fonte ou sombra fora dos tokens (arquivo 02 §8).
List<String> _literalDeEstilo(String fonte) =>
    _ocorrenciasDe(semComentarios(fonte), [
      'Color(0x',
      '0xFF',
      'Color.fromARGB(',
      'Color.fromRGBO(',
      'fontFamily:',
      'fontSize:',
      'fontWeight:',
      'TextStyle(',
      'BoxShadow(',
    ]);

/// Regra 4 — `domain/` é Dart puro (GAL-19 AC7).
List<String> _importaFlutter(String fonte) => _diretivaDeImport
    .allMatches(fonte)
    .map((m) => m.group(1)!)
    .where((alvo) => alvo.startsWith('package:flutter/'))
    .toList();

List<File> arquivosDartEm(Directory diretorio) => diretorio
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

/// Se [caminho] está sob `lib/features/galera/domain/`.
bool ehDoDominio(String caminho) =>
    caminhoNormalizado(caminho).contains('$_diretorioDoDominio/');

/// Uma linha por violação, no formato `<arquivo>: <regra> (<achado>)` — é o
/// que nomeia **o arquivo e a regra** quando a suíte quebra.
List<String> violacoesEm(Directory diretorio) => [
      for (final arquivo in arquivosDartEm(diretorio))
        ...violacoesNaFonte(arquivo.readAsStringSync(), arquivo.path),
    ];

List<String> violacoesNaFonte(String fonte, String caminho) {
  final normalizado = caminhoNormalizado(caminho);

  return [
    for (final regra in regrasDaFronteira)
      if (!regra.soNoDominio || ehDoDominio(normalizado))
        for (final achado in regra.achados(fonte))
          '$normalizado: ${regra.nome} ($achado)',
  ];
}

/// Um infrator sintético num diretório temporário — **a árvore real nunca é
/// mutada**.
List<String> violacoesDeUmArquivoTemporario(String fonte, String nome) {
  final temporario = Directory.systemTemp.createTempSync('galera-guard');
  addTearDown(() => temporario.deleteSync(recursive: true));

  File('${temporario.path}/$nome').writeAsStringSync(fonte);

  return violacoesEm(temporario);
}

void main() {
  group('GAL-15 AC11, GAL-19 AC7 — a fronteira da feature está limpa', () {
    test('nenhum arquivo de lib/features/galera viola nenhuma das regras', () {
      expect(
        violacoesEm(Directory(_diretorioDaGalera)),
        isEmpty,
        reason: 'a fórmula é da camada de cálculo e a cor é do token: se um '
            'número faltar, ele nasce em core/calculo, não aqui',
      );
    });

    test('a varredura não roda vazia: o diretório existe e tem arquivo .dart',
        () {
      final diretorio = Directory(_diretorioDaGalera);

      expect(diretorio.existsSync(), isTrue);
      expect(arquivosDartEm(diretorio).length, greaterThan(10));
    });

    test('a varredura alcança o domínio, que é onde a regra 4 vale', () {
      final dominio = Directory(_diretorioDoDominio);

      expect(dominio.existsSync(), isTrue);
      expect(arquivosDartEm(dominio), isNotEmpty);
      expect(
        arquivosDartEm(dominio).every((f) => ehDoDominio(f.path)),
        isTrue,
        reason: 'L-006: o separador do Windows não pode fazer a regra 4 '
            'deixar de casar com os arquivos que ela vigia',
      );
    });

    test('as quatro regras de §13 estão declaradas', () {
      expect(regrasDaFronteira, hasLength(4));
      expect(
        regrasDaFronteira.where((regra) => regra.soNoDominio),
        hasLength(1),
      );
    });

    test('nenhuma isenção existe: não há allowlist de arquivo', () {
      // A alternativa seria liberar um arquivo inteiro, e um arquivo liberado
      // deixa de ser vigiado para **todas** as regras (L-007). Nenhuma foi
      // necessária: a copy vem de `core/calculo` e a cor, do token.
      final fontes = [
        for (final arquivo in arquivosDartEm(Directory(_diretorioDaGalera)))
          arquivo,
      ];

      for (final arquivo in fontes) {
        expect(
          violacoesNaFonte(arquivo.readAsStringSync(), arquivo.path),
          isEmpty,
          reason: '${arquivo.path} passa pela varredura como qualquer outro',
        );
      }
    });
  });

  group('GAL-15 AC11 — a regra 1 morde a fórmula que vazasse', () {
    test('a constante de RN-03 escrita em gramas é acusada', () {
      for (final infrator in [
        'final gramas = homens * 400 + mulheres * 300;',
        'final ml = adultos * 250;',
        'final latas = adultos * 1000 / 350;',
      ]) {
        expect(
          violacoesNaFonte(infrator, 'lib/features/galera/infrator.dart')
              .join(),
          contains('reescreve quantidade de RN-03/RN-05'),
          reason: '$infrator deveria ser acusado',
        );
      }
    });

    test('a constante de RN-03 escrita em quilos é acusada', () {
      for (final infrator in [
        'const porHomem = 0.4;',
        'const porMulher = 0.3;',
        'const piso = 0.5;',
        'const porCrianca = 0.15;',
      ]) {
        expect(
          violacoesNaFonte(infrator, 'lib/features/galera/infrator.dart')
              .join(),
          contains('reescreve quantidade de RN-03/RN-05'),
          reason: '$infrator deveria ser acusado',
        );
      }
    });

    test('RN-21 reescrita à mão é acusada', () {
      for (final infrator in [
        'final base = adultosQueBebem;',
        'final base = max(0, adultos - abstemios);',
        'final piso = math.max(1, unidades);',
      ]) {
        expect(
          violacoesNaFonte(infrator, 'lib/features/galera/infrator.dart')
              .join(),
          contains('reescreve quantidade de RN-03/RN-05'),
          reason: '$infrator deveria ser acusado',
        );
      }
    });

    test('a conta escondida dentro de uma interpolação é acusada', () {
      expect(
        violacoesNaFonte(
          r"Text('${adultos * 400 * fator}');",
          'lib/features/galera/infrator.dart',
        ).join(),
        contains('reescreve quantidade de RN-03/RN-05'),
        reason: 'o miolo de uma interpolação é código, e é onde a fórmula se '
            'esconderia de uma varredura ingênua',
      );
    });

    test('número que não é constante de RN-03/RN-05 não é acusado', () {
      expect(
        violacoesNaFonte(
          'const larguraDaColuna = 370;\nconst borda = 2;',
          'lib/features/galera/limpo.dart',
        ),
        isEmpty,
        reason: 'os 370px de W-04 são medida de layout, não quantidade por '
            'pessoa',
      );
    });

    test('a fronteira de dígito impede o falso positivo', () {
      expect(
        violacoesNaFonte(
          'const codigo = 24000;\nconst outro = 13500;',
          'lib/features/galera/limpo.dart',
        ),
        isEmpty,
        reason: 'contains("400") acusaria 24000 — e um guard que grita à toa '
            'vira guard desligado',
      );
    });
  });

  group('GAL-13 AC5 — a regra 2 morde a frase recomposta', () {
    test('a frase de RN-21 escrita como template é acusada', () {
      final violacoes = violacoesNaFonte(
        "Text('A lista já se ajusta às preferências: \$termos');",
        'lib/features/galera/infrator.dart',
      );

      expect(violacoes, hasLength(1));
      expect(violacoes.single, contains('reescreve a frase de RN-21'));
      expect(violacoes.single, contains('infrator.dart'));
    });

    test('a frase escrita sem interpolação também é acusada', () {
      expect(
        violacoesNaFonte(
          "const frase = 'A lista já se ajusta às preferências';",
          'lib/features/galera/infrator.dart',
        ).join(),
        contains('reescreve a frase de RN-21'),
      );
    });

    test('o comentário que cita a frase para explicar de onde ela vem não é '
        'violação', () {
      expect(
        violacoesNaFonte(
          '/// A faixa lê "💡 A lista já se ajusta às preferências: {resumo}".\n'
          '// A frase inteira vem de resumoDasPreferencias.\n'
          "final texto = GaleraTextos.faixa(resumo);",
          'lib/features/galera/limpo.dart',
        ),
        isEmpty,
      );
    });

    test("só o '💡 ' concatenado passa", () {
      expect(
        violacoesNaFonte(
          r"String faixa(String resumo) => '💡 $resumo';",
          'lib/features/galera/limpo.dart',
        ),
        isEmpty,
      );
    });
  });

  group('Arquivo 02 §8 — a regra 3 morde o literal de estilo', () {
    test('cada forma de literal de cor, fonte ou sombra é acusada', () {
      for (final infrator in [
        'const cor = Color(0xFF6C4BF5);',
        'const cor = Color.fromARGB(255, 20, 20, 20);',
        'const cor = Color.fromRGBO(20, 20, 20, 1);',
        "const estilo = TextStyle(fontFamily: 'Archivo');",
        'const estilo = TextStyle(fontSize: 13);',
        'const estilo = TextStyle(fontWeight: FontWeight.w800);',
        'const sombra = BoxShadow(color: cor, offset: Offset(4, 4));',
      ]) {
        expect(
          violacoesNaFonte(infrator, 'lib/features/galera/infrator.dart')
              .join(),
          contains('literal de cor, fonte ou sombra'),
          reason: '$infrator deveria ser acusado',
        );
      }
    });

    test('o token e o copyWith de cor continuam legítimos', () {
      expect(
        violacoesNaFonte(
          'final estilo = BoraTextStyles.chip.copyWith('
          'color: BoraColors.ink);\n'
          'final fundo = BoraColors.yellow;\n'
          'final sombra = BoraShadows.cardLink;',
          'lib/features/galera/limpo.dart',
        ),
        isEmpty,
      );
    });
  });

  group('GAL-19 AC7 — a regra 4 morde o Flutter no domínio', () {
    test('import de Flutter em domain/ é acusado, nomeando o arquivo', () {
      final violacoes = violacoesNaFonte(
        "import 'package:flutter/material.dart';",
        'lib/features/galera/domain/infrator.dart',
      );

      expect(violacoes, hasLength(1));
      expect(violacoes.single, contains('importa Flutter no domínio'));
      expect(violacoes.single, contains('domain/infrator.dart'));
      expect(violacoes.single, contains('package:flutter/material.dart'));
    });

    test('o mesmo import fora de domain/ **não** é acusado por esta regra',
        () {
      // O par que discrimina: `presentation/` é UI e importa Flutter por
      // ofício. Uma regra que acusasse a feature inteira estaria errada, e
      // uma que não acusasse `domain/` não protegeria a spec 09.
      expect(
        violacoesNaFonte(
          "import 'package:flutter/widgets.dart';",
          'lib/features/galera/presentation/widgets/limpo.dart',
        ),
        isEmpty,
      );
    });

    test('o caminho com separador do Windows continua sendo domínio', () {
      expect(
        violacoesNaFonte(
          "import 'package:flutter/material.dart';",
          r'lib\features\galera\domain\infrator.dart',
        ).join(),
        contains('importa Flutter no domínio'),
        reason: 'L-006: guard que compara path com barra normal fica verde no '
            'POSIX e cego no Windows',
      );
    });

    test('import de Dart puro no domínio não é acusado', () {
      expect(
        violacoesNaFonte(
          "import 'dart:async';\n"
          "import '../../../core/calculo/calculo.dart';",
          'lib/features/galera/domain/limpo.dart',
        ),
        isEmpty,
      );
    });
  });

  group('A varredura de diretório acha o infrator no disco e o nomeia', () {
    test('o arquivo infrator é nomeado e o limpo não é', () {
      final temporario = Directory.systemTemp.createTempSync('galera-guard');
      addTearDown(() => temporario.deleteSync(recursive: true));

      File('${temporario.path}/infrator.dart').writeAsStringSync(
        [
          'final gramas = homens * 400;',
          'const cor = Color(0xFF6C4BF5);',
        ].join('\n'),
      );
      File('${temporario.path}/limpo.dart').writeAsStringSync(
        'final fundo = BoraColors.yellow;',
      );

      final violacoes = violacoesEm(temporario);

      // Três, e não duas: `Color(0xFF6C4BF5)` casa com **as duas** formas do
      // literal de cor, e cada achado vira uma linha. Uma regra que somasse
      // as formas numa linha só esconderia qual delas mordeu.
      expect(violacoes, hasLength(3));
      expect(violacoes.every((v) => v.contains('infrator.dart')), isTrue);
      expect(violacoes.join(), contains('reescreve quantidade de RN-03/RN-05'));
      expect(violacoes.join(), contains('literal de cor, fonte ou sombra'));
      expect(violacoes.join(), isNot(contains('limpo.dart')));
    });

    test('a mensagem traz uma linha por violação, com arquivo e regra', () {
      final violacoes = violacoesDeUmArquivoTemporario(
        "final ml = adultos * 250;\nconst cor = Color(0xFF141414);",
        'x.dart',
      );

      expect(violacoes, hasLength(3));
      expect(
        violacoes.every((v) => v.contains('x.dart')),
        isTrue,
        reason: 'a falha tem de dizer QUAL arquivo infringiu',
      );
      expect(
        violacoes.where((v) => v.contains('reescreve quantidade')),
        hasLength(1),
      );
    });
  });
}
