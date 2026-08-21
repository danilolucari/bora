import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A guarda de pureza de token: §8 do arquivo 02 e a decisão de DS-03.
///
/// §8 é a lista "não fazer": gradientes, cor fora do token, "fontes fora de
/// Archivo/Archivo Black"; §6 proíbe mola e bounce ("sem spring"); o `ripple`
/// do Material não existe no estilo seco de §4, onde o feedback de toque é o
/// afundamento do CTA. DS-03 acrescenta a proibição do eixo tipográfico: desde
/// o Flutter 3.41 o peso é `fontWeight`, e declarar o eixo à mão mascararia
/// erro de peso.
///
/// As duas primeiras regras varrem **`lib/` inteira**, não só o design system:
/// é o que os doc comments de `bora_colors.dart` e de `bora_text_styles.dart`
/// prometem quando dizem "o **único** arquivo do projeto autorizado". O escopo
/// exigido pelo `tasks.md` (`lib/core/design_system/`) está contido nele, e o
/// teste anti-vácuo afirma que os dois lados foram varridos.
const String _diretorioDeLib = 'lib';
const String _diretorioDoDesignSystem = 'lib/core/design_system';

/// O único arquivo autorizado a conter literal de cor.
const String _arquivoDeCor = 'bora_colors.dart';

/// O único arquivo autorizado a conter literal de família de fonte.
const String _arquivoDeFonte = 'bora_text_styles.dart';

/// O atalho de cor do Material.
///
/// O lookbehind existe porque `BoraColors.` **contém** `Colors.`: sem ele a
/// guarda acusaria o próprio arquivo de tokens. `Colors.transparent` é
/// tolerado — é ausência de cor, não cor, e não há token para "nada".
final RegExp _atalhoDeCor = RegExp(r'(?<!Bora)Colors\.(?!transparent)\w*');

/// `fontFamily:` seguido de aspas — a família digitada à mão. Ler o token
/// (`fontFamily: BoraTextStyles.familiaUi`) não é literal e passa.
final RegExp _familiaLiteral = RegExp('''fontFamily:\\s*['"]''');

/// As proibições de §8 e §6 mais o eixo tipográfico de DS-03, válidas em
/// **qualquer** arquivo sob `lib/`.
const List<String> _proibidosGlobais = [
  'Gradient', // §8: "sem gradientes"
  'InkWell', // §8: o ripple do Material não existe no estilo seco
  'InkResponse',
  'Curves.elastic', // §6: "sem spring"
  'Curves.bounce',
  'FontVariation', // DS-03: o peso é fontWeight, e o eixo mascararia o erro
];

/// Literais de cor em [conteudo], no formato `<arquivo>: <padrão>`.
List<String> violacoesDeCorEm(String caminho, String conteudo) {
  if (caminho.endsWith(_arquivoDeCor)) return const [];
  return [
    if (conteudo.contains('Color(0x')) '$caminho: Color(0x',
    for (final achado in _atalhoDeCor.allMatches(conteudo))
      '$caminho: ${achado.group(0)}',
  ];
}

/// Literais de família de fonte em [conteudo].
List<String> violacoesDeFonteEm(String caminho, String conteudo) {
  if (caminho.endsWith(_arquivoDeFonte)) return const [];
  return [
    for (final achado in _familiaLiteral.allMatches(conteudo))
      '$caminho: ${achado.group(0)!.trim()}',
  ];
}

/// Padrões de §8/§6/DS-03 em [conteudo]. Sem allowlist: não há exceção.
List<String> violacoesGlobaisEm(String caminho, String conteudo) => [
      for (final padrao in _proibidosGlobais)
        if (conteudo.contains(padrao)) '$caminho: $padrao',
    ];

List<File> arquivosDartEm(Directory diretorio) => diretorio
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

List<String> _varrer(
  Directory diretorio,
  List<String> Function(String caminho, String conteudo) regra,
) =>
    [
      for (final arquivo in arquivosDartEm(diretorio))
        ...?switch (_conteudoDe(arquivo)) {
          final String conteudo => regra(arquivo.path, conteudo),
          null => null,
        },
    ];

/// O conteúdo de [arquivo], ou `null` se ele sumiu entre listar e ler.
///
/// Arquivo que deixa de existir no meio da varredura não faz parte do código:
/// `calculo_isolation_test.dart` cria e apaga um infrator temporário sob
/// `lib/` enquanto esta varredura roda, e ler o que já sumiu quebraria a
/// suíte sem provar nada. Nenhuma outra falha de leitura é engolida.
String? _conteudoDe(File arquivo) {
  try {
    return arquivo.readAsStringSync();
  } on PathNotFoundException {
    return null;
  }
}

/// Um diretório **isolado** com um arquivo `.dart` infrator dentro.
///
/// A injeção não acontece dentro de `lib/`: os três guardas varrem os mesmos
/// diretórios em paralelo, e um arquivo aparecendo e sumindo no meio da
/// varredura do vizinho deixava a suíte instável. A regra exercitada é a
/// mesma — muda só onde o arquivo mora.
Directory _diretorioComInfrator(String nome, String conteudo) {
  final diretorio = Directory.systemTemp.createTempSync('bora_guarda_');
  addTearDown(() {
    if (diretorio.existsSync()) diretorio.deleteSync(recursive: true);
  });
  File('${diretorio.path}/$nome').writeAsStringSync(conteudo);
  return diretorio;
}

void main() {
  final lib = Directory(_diretorioDeLib);

  group('DS-09 — cor só existe em bora_colors.dart', () {
    test('nenhum arquivo de lib/ tem literal de cor fora do arquivo de cor',
        () {
      expect(
        _varrer(lib, violacoesDeCorEm),
        isEmpty,
        reason: '§8: nenhuma cor fora dos tokens — quem precisa de cor lê '
            'BoraColors',
      );
    });

    test('literal de cor injetado é acusado nomeando o arquivo, e removê-lo '
        'faz passar', () {
      final diretorio = _diretorioComInfrator(
        'pureza_de_cor_infrator_de_teste.dart',
        'const verde = Color(0xFF00FF00);\n',
      );

      final violacoes = _varrer(diretorio, violacoesDeCorEm);
      expect(violacoes, hasLength(1));
      expect(violacoes.single, contains('pureza_de_cor_infrator_de_teste.dart'));
      expect(violacoes.single, contains('Color(0x'));

      arquivosDartEm(diretorio).single.deleteSync();

      expect(_varrer(diretorio, violacoesDeCorEm), isEmpty);
    });

    test('o atalho do Material é acusado, BoraColors não, e transparent passa',
        () {
      const arquivo = 'lib/core/design_system/components/qualquer.dart';

      expect(
        violacoesDeCorEm(arquivo, 'color: Colors.red,'),
        ['$arquivo: Colors.red'],
        reason: 'o atalho do Material é cor fora do token',
      );
      expect(
        violacoesDeCorEm(arquivo, 'color: BoraColors.primary,'),
        isEmpty,
        reason: 'BoraColors. contém Colors. — a guarda não pode confundir os '
            'dois',
      );
      expect(
        violacoesDeCorEm(arquivo, 'color: Colors.transparent,'),
        isEmpty,
        reason: 'transparent é ausência de cor, não cor: não há token para '
            '"nada"',
      );
    });
  });

  group('DS-09 — família de fonte só existe em bora_text_styles.dart', () {
    test('nenhum arquivo de lib/ tem literal de fontFamily fora do arquivo de '
        'tipografia', () {
      expect(
        _varrer(lib, violacoesDeFonteEm),
        isEmpty,
        reason: '§8: "fontes fora de Archivo/Archivo Black" não entram — a '
            'família se lê do token',
      );
    });

    test('fontFamily literal injetado é acusado nomeando o arquivo, e removê-lo '
        'faz passar', () {
      final diretorio = _diretorioComInfrator(
        'pureza_de_fonte_infrator_de_teste.dart',
        "const estilo = TextStyle(fontFamily: 'Roboto');\n",
      );

      final violacoes = _varrer(diretorio, violacoesDeFonteEm);
      expect(violacoes, hasLength(1));
      expect(
        violacoes.single,
        contains('pureza_de_fonte_infrator_de_teste.dart'),
      );
      expect(violacoes.single, contains('fontFamily:'));

      arquivosDartEm(diretorio).single.deleteSync();

      expect(_varrer(diretorio, violacoesDeFonteEm), isEmpty);
    });

    test('fontFamily lendo o token não é acusado', () {
      expect(
        violacoesDeFonteEm(
          'lib/core/design_system/tokens/bora_theme.dart',
          'fontFamily: BoraTextStyles.familiaUi,',
        ),
        isEmpty,
        reason: 'o tema deriva do token: não é literal',
      );
    });
  });

  group('DS-09/DS-10/DS-03 — gradiente, ripple, mola e eixo de fonte', () {
    test('nenhum arquivo sob lib/ usa padrão proibido de §8, §6 ou DS-03', () {
      expect(
        _varrer(lib, violacoesGlobaisEm),
        isEmpty,
        reason: '§8 proíbe gradiente e ripple, §6 proíbe mola e bounce, e '
            'DS-03 proíbe declarar o eixo tipográfico à mão',
      );
    });

    test('cada padrão proibido é detectado nomeando o arquivo e o padrão', () {
      const arquivo = 'lib/features/montar/presentation/pages/montar_page.dart';

      for (final padrao in _proibidosGlobais) {
        expect(
          violacoesGlobaisEm(arquivo, 'algo com $padrao aqui'),
          ['$arquivo: $padrao'],
          reason: '$padrao é proibido em qualquer lugar de lib/',
        );
      }
    });

    test('Curves.ease, a curva do sistema, não é acusada', () {
      expect(
        violacoesGlobaisEm(
          'lib/core/design_system/tokens/bora_motion.dart',
          'static const Curve curva = Curves.ease;',
        ),
        isEmpty,
        reason: 'A-04: ease é a curva de todo o motion — só mola e bounce '
            'estão fora',
      );
    });
  });

  group('DS-09 — as varreduras não rodam vazias', () {
    test('lib/ tem arquivo .dart dentro e fora do design system', () {
      final caminhos = arquivosDartEm(lib).map((f) => f.path).toList();

      expect(caminhos, isNotEmpty, reason: 'guarda sem alvo passa vacuamente');
      expect(
        caminhos.where((c) => c.startsWith(_diretorioDoDesignSystem)),
        isNotEmpty,
        reason: 'o escopo exigido pelo tasks.md precisa estar dentro da '
            'varredura',
      );
      expect(
        caminhos.where((c) => !c.startsWith(_diretorioDoDesignSystem)),
        isNotEmpty,
        reason: 'a varredura global de §8 alcança lib/ inteira, não só o '
            'design system',
      );
    });
  });
}
