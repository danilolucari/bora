import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A guarda de forma e de sombra do arquivo 02, §3 e §4.
///
/// §3: "`border-radius: 0` em **tudo** (botões, cards, inputs, chips).
/// Exceções: avatares e dots (círculo, 50%) e o frame do celular (38px)".
/// §4: as sombras são "sempre duras, sem blur", e a do frame é "a única sombra
/// suave permitida — é o 'palco', não a UI".
///
/// Proibição sem sensor é decoração: aqui as duas leis viram varredura que
/// quebra a suíte **nomeando o arquivo infrator**, na mesma mecânica de
/// `test/architecture/calculo_isolation_test.dart`.
/// A varredura cobre **`lib/` inteira**, não só o design system.
///
/// Começou apontando para `lib/core/design_system` porque, quando a spec 01
/// rodou, era o único código que existia. A partir da spec 03 há tela de
/// produto em `lib/features/` e tema em `lib/app.dart`, e §3/§4 valem para
/// elas igual — canto arredondado e sombra com blur são proibidos no app
/// inteiro, não só na biblioteca. O Verifier de `entrar` apontou o alcance
/// curto (gap nº 7); ampliar fortalece a guarda, não a relaxa.
const String _diretorioDeLib = 'lib';

/// As formas arredondadas proibidas por §3.
///
/// `BoxShape.circle` entra na lista para que o círculo também seja policiado:
/// §3 autoriza círculo em avatares e dots, e sem ele na lista qualquer
/// componente poderia virar círculo sem a guarda notar.
const List<String> _formasProibidas = [
  'BorderRadius.circular',
  'BorderRadius.all',
  'RoundedRectangleBorder',
  'StadiumBorder',
  'CircleBorder',
  'BoxShape.circle',
];

/// As exceções de §3, por arquivo **e por forma exata**.
///
/// A allowlist não libera o arquivo: libera **a forma** que §3 autoriza naquele
/// arquivo. A diferença não é acadêmica — liberando o arquivo,
/// `BorderRadius.circular(8)`, que não é círculo nem 38, passava despercebido
/// dentro do avatar, e a guarda dizia que §3 estava cumprida.
///
/// São as **duas** exceções que §3 declara — radius 38 e círculo —, espalhadas
/// por três arquivos porque o círculo vale para avatar e para o dot da enquete.
/// O que se conta são as formas, não as entradas do mapa.
///
/// A lista cita arquivos que **ainda não existem** quando a guarda nasce (fase
/// 2) e que chegam nas fases 5–7. Remover um nome daqui quebra a task daquele
/// componente três fases depois.
const Map<String, Set<String>> _excecoesDeForma = {
  // §3: o frame do celular, 38px — e **só** 38.
  'bora_phone_frame.dart': {'BorderRadius.all(Radius.circular(38))'},
  // §3: avatares e dots, círculo.
  'bora_avatar.dart': {'BoxShape.circle'},
  // §3: o dot do rádio da enquete, círculo.
  'bora_poll_option.dart': {'BoxShape.circle'},
  // §3: o ponto vermelho de 8px do item editado (RN-12), círculo — dot, pela
  // mesma exceção do avatar e do rádio.
  'linha_de_item.dart': {'BoxShape.circle'},
};

/// [conteudo] sem as formas que §3 autoriza em [caminho].
///
/// Remover a forma exata **antes** de varrer é o que faz a allowlist ser sobre
/// forma e não sobre arquivo: o que sobra é sempre violação, inclusive dentro
/// do arquivo que tem exceção.
String semAsExcecoesDeForma(String caminho, String conteudo) {
  for (final excecao in _excecoesDeForma.entries) {
    if (!caminho.endsWith(excecao.key)) continue;
    for (final permitida in excecao.value) {
      conteudo = conteudo.replaceAll(permitida, '');
    }
  }
  return conteudo;
}

final RegExp _blur = RegExp(r'blurRadius:\s*([^,)\n]*)');
final RegExp _zeroLiteral = RegExp(r'^0(?:\.0+)?\b');

/// As formas arredondadas de [conteudo], no formato `<arquivo>: <padrão>`.
List<String> violacoesDeFormaEm(String caminho, String conteudo) {
  final restante = semAsExcecoesDeForma(caminho, conteudo);
  return [
    for (final padrao in _formasProibidas)
      if (restante.contains(padrao)) '$caminho: $padrao',
  ];
}

/// As sombras com blur não-zero de [conteudo]. Só o literal zero passa:
/// `blurRadius` vindo de expressão não é auditável por varredura.
///
/// **Sem allowlist de arquivo.** §4 diz que a do frame é a única sombra suave
/// do sistema, e "única" é uma afirmação sobre a contagem, não sobre onde ela
/// mora: liberando `bora_shadows.dart` inteiro, uma **segunda** sombra com blur
/// entrava ali com a suíte verde. Quem afirma a unicidade é o teste que conta.
List<String> blursNaoZeroEm(String caminho, String conteudo) => [
      for (final achado in _blur.allMatches(conteudo))
        if (!_zeroLiteral.hasMatch(achado.group(1)!.trim()))
          '$caminho: blurRadius: ${achado.group(1)!.trim()}',
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

  group('DS-05 — forma arredondada não entra no design system', () {
    test('nenhum arquivo sob lib/core/design_system usa forma arredondada', () {
      expect(
        _varrer(lib, violacoesDeFormaEm),
        isEmpty,
        reason: '§3: "border-radius: 0 em tudo" — canto arredondado só nas '
            'duas exceções, e elas moram na allowlist',
      );
    });

    test('a varredura não roda vazia: o diretório existe e tem arquivo .dart',
        () {
      expect(lib.existsSync(), isTrue);
      expect(
        arquivosDartEm(lib),
        isNotEmpty,
        reason: 'guarda sem alvo passa vacuamente — o falso-verde do risco R-4',
      );
    });

    test('forma arredondada injetada faz a varredura falhar nomeando o arquivo',
        () {
      final diretorio = _diretorioComInfrator(
        'guarda_de_forma_infrator_de_teste.dart',
        'const raio = BorderRadius.circular(8);\n',
      );

      final violacoes = _varrer(diretorio, violacoesDeFormaEm);

      expect(violacoes, hasLength(1));
      expect(
        violacoes.single,
        contains('guarda_de_forma_infrator_de_teste.dart'),
      );
      expect(violacoes.single, contains('BorderRadius.circular'));
    });

    test('removida a forma injetada, a varredura volta a passar', () {
      final diretorio = _diretorioComInfrator(
        'guarda_de_forma_removido_de_teste.dart',
        'const forma = RoundedRectangleBorder();\n',
      );
      expect(_varrer(diretorio, violacoesDeFormaEm), hasLength(1));

      arquivosDartEm(diretorio).single.deleteSync();

      expect(_varrer(diretorio, violacoesDeFormaEm), isEmpty);
    });

    test('cada forma da lista proibida de §3 é detectada', () {
      for (final padrao in _formasProibidas) {
        expect(
          violacoesDeFormaEm('lib/core/design_system/qualquer.dart', padrao),
          ['lib/core/design_system/qualquer.dart: $padrao'],
          reason: '$padrao é canto arredondado e §3 proíbe',
        );
      }
    });

    test('BorderRadius.zero e Border.all não são acusados', () {
      expect(
        violacoesDeFormaEm(
          'lib/core/design_system/tokens/bora_borders.dart',
          'BorderRadius.zero; Border.all(color: cor, width: 2);',
        ),
        isEmpty,
        reason: '§3 é radius zero e borda de 2px: são a lei, não a violação',
      );
    });

    test('a exceção de §3 libera a forma exata no arquivo dela', () {
      expect(
        violacoesDeFormaEm(
          'lib/core/design_system/components/bora_phone_frame.dart',
          'static const raio = BorderRadius.all(Radius.circular(38));',
        ),
        isEmpty,
        reason: '§3: o frame do celular é exceção declarada, com 38px',
      );
      for (final circular in ['bora_avatar.dart', 'bora_poll_option.dart']) {
        expect(
          violacoesDeFormaEm(
            'lib/core/design_system/components/$circular',
            'decoration: BoxDecoration(shape: BoxShape.circle),',
          ),
          isEmpty,
          reason: '§3: avatares e dots são círculo por exceção declarada',
        );
      }
    });

    test('a exceção é da forma, não do arquivo: outra forma no mesmo arquivo '
        'é acusada', () {
      // O buraco que esta guarda tinha: liberando o arquivo inteiro,
      // `BorderRadius.circular(8)` — que não é círculo nem 38 — passava dentro
      // do avatar, e a guarda ainda dizia que §3 estava cumprida.
      expect(
        violacoesDeFormaEm(
          'lib/core/design_system/components/bora_avatar.dart',
          'shape: BoxShape.circle, borderRadius: BorderRadius.circular(8),',
        ),
        ['lib/core/design_system/components/bora_avatar.dart: '
            'BorderRadius.circular'],
        reason: '§3 autoriza o círculo do avatar, não um canto de 8px nele',
      );
      expect(
        violacoesDeFormaEm(
          'lib/core/design_system/components/bora_phone_frame.dart',
          'static const raio = BorderRadius.all(Radius.circular(24));',
        ),
        ['lib/core/design_system/components/bora_phone_frame.dart: '
            'BorderRadius.all'],
        reason: '§3 dá 38 ao frame — 24 não é a exceção declarada',
      );
    });

    test('a forma liberada num arquivo não vale no arquivo do vizinho', () {
      expect(
        violacoesDeFormaEm(
          'lib/core/design_system/components/bora_list_card.dart',
          'decoration: BoxDecoration(shape: BoxShape.circle),',
        ),
        ['lib/core/design_system/components/bora_list_card.dart: '
            'BoxShape.circle'],
        reason: 'o círculo é exceção de avatar e dot, não do sistema inteiro',
      );
    });
  });

  group('DS-07 — a do frame é a única sombra suave do sistema', () {
    test('há exatamente uma sombra com blur, e ela é a do frame', () {
      final comBlur = _varrer(lib, blursNaoZeroEm);

      expect(
        comBlur,
        hasLength(1),
        reason: '§4: "a do frame é a única sombra suave permitida" — e '
            '"única" é afirmação sobre a contagem, não sobre onde ela mora',
      );
      expect(comBlur.single, contains('bora_shadows.dart'));
      expect(
        comBlur.single,
        contains('blurRadius: 50'),
        reason: '§4, frame do celular: `0 20px 50px -20px rgba(20,10,50,.35)`',
      );
    });

    test('uma segunda sombra suave é contada, mesmo no arquivo de sombras', () {
      // O buraco que esta guarda tinha: `bora_shadows.dart` estava liberado
      // inteiro, e uma segunda sombra com blur entrava ali com a suíte verde.
      // Agora quem prova a unicidade é a contagem acima, e ela enxerga esta.
      const arquivo = 'lib/core/design_system/tokens/bora_shadows.dart';

      expect(
        blursNaoZeroEm(arquivo, 'blurRadius: 50,\nblurRadius: 12,'),
        [
          '$arquivo: blurRadius: 50',
          '$arquivo: blurRadius: 12',
        ],
      );
    });

    test('blur diferente de zero é acusado nomeando o arquivo', () {
      final diretorio = _diretorioComInfrator(
        'guarda_de_blur_infrator_de_teste.dart',
        'const sombra = BoxShadow(blurRadius: 4);\n',
      );

      final violacoes = _varrer(diretorio, blursNaoZeroEm);

      expect(violacoes, hasLength(1));
      expect(
        violacoes.single,
        contains('guarda_de_blur_infrator_de_teste.dart'),
      );
      expect(violacoes.single, contains('blurRadius: 4'));
    });

    test('removido o blur injetado, a varredura volta a passar', () {
      final diretorio = _diretorioComInfrator(
        'guarda_de_blur_removido_de_teste.dart',
        'const sombra = BoxShadow(blurRadius: 12);\n',
      );
      expect(_varrer(diretorio, blursNaoZeroEm), hasLength(1));

      arquivosDartEm(diretorio).single.deleteSync();

      expect(_varrer(diretorio, blursNaoZeroEm), isEmpty);
    });

    test('blurRadius zero não é acusado, blur por expressão é', () {
      const arquivo = 'lib/core/design_system/components/qualquer.dart';

      expect(blursNaoZeroEm(arquivo, 'blurRadius: 0,'), isEmpty);
      expect(blursNaoZeroEm(arquivo, 'blurRadius: 0.0,'), isEmpty);
      expect(
        blursNaoZeroEm(arquivo, 'blurRadius: distancia,'),
        ['$arquivo: blurRadius: distancia'],
        reason: 'blur vindo de expressão não é auditável por varredura',
      );
    });
  });
}
