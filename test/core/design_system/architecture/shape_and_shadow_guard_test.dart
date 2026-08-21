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
const String _diretorioDoDesignSystem = 'lib/core/design_system';

/// As formas arredondadas proibidas por §3.
const List<String> _formasProibidas = [
  'BorderRadius.circular',
  'BorderRadius.all',
  'RoundedRectangleBorder',
  'StadiumBorder',
  'CircleBorder',
];

/// As duas exceções de §3, por caminho.
///
/// A lista cita arquivos que **ainda não existem**: a guarda nasce na fase 2 e
/// os componentes que ela autoriza nascem nas fases 5–7. Remover um nome daqui
/// quebra a task daquele componente três fases depois.
const Set<String> _formaLiberada = {
  'bora_phone_frame.dart', // §3: o frame do celular, 38px
  'bora_avatar.dart', // §3: avatares e dots, círculo
  'bora_poll_option.dart', // §3: o dot do rádio da enquete, círculo
};

/// Onde o blur de §4 é permitido.
///
/// O frame é a única sombra suave do sistema, e o token dela mora no arquivo
/// de sombras (`design.md` §Estrutura de diretórios). Que ela continue **a
/// única** é o que `bora_shadows_test.dart` afirma, sombra por sombra.
//
// SPEC_DEVIATION: o `tasks.md` enumera a allowlist só com
// `bora_phone_frame.dart`, `bora_avatar.dart` e `bora_poll_option.dart`.
// Motivo: `BoraShadows.frame` (blur 50) é declarada em `bora_shadows.dart`, e
// é ela "o arquivo do frame" a que o AC-3 do `spec.md` se refere para a regra
// de blur. Sem esta entrada a guarda acusaria o próprio token de §4.
const Set<String> _blurLiberado = {
  'bora_phone_frame.dart',
  'bora_shadows.dart',
};

final RegExp _blur = RegExp(r'blurRadius:\s*([^,)\n]*)');
final RegExp _zeroLiteral = RegExp(r'^0(?:\.0+)?\b');

bool _liberado(String caminho, Set<String> allowlist) =>
    allowlist.any(caminho.endsWith);

/// As formas arredondadas de [conteudo], no formato `<arquivo>: <padrão>`.
List<String> violacoesDeFormaEm(String caminho, String conteudo) {
  if (_liberado(caminho, _formaLiberada)) return const [];
  return [
    for (final padrao in _formasProibidas)
      if (conteudo.contains(padrao)) '$caminho: $padrao',
  ];
}

/// As sombras com blur de [conteudo]. Só o literal zero passa: `blurRadius`
/// vindo de expressão não é auditável por varredura.
List<String> violacoesDeBlurEm(String caminho, String conteudo) {
  if (_liberado(caminho, _blurLiberado)) return const [];
  return [
    for (final achado in _blur.allMatches(conteudo))
      if (!_zeroLiteral.hasMatch(achado.group(1)!.trim()))
        '$caminho: blurRadius: ${achado.group(1)!.trim()}',
  ];
}

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
        ...regra(arquivo.path, arquivo.readAsStringSync()),
    ];

/// Escreve [conteudo] num arquivo do design system e o apaga ao fim do teste.
File _injetar(String nome, String conteudo) {
  final infrator = File('$_diretorioDoDesignSystem/$nome');
  addTearDown(() {
    if (infrator.existsSync()) infrator.deleteSync();
  });
  infrator.writeAsStringSync(conteudo);
  return infrator;
}

void main() {
  final designSystem = Directory(_diretorioDoDesignSystem);

  group('DS-05 — forma arredondada não entra no design system', () {
    test('nenhum arquivo sob lib/core/design_system usa forma arredondada', () {
      expect(
        _varrer(designSystem, violacoesDeFormaEm),
        isEmpty,
        reason: '§3: "border-radius: 0 em tudo" — canto arredondado só nas '
            'duas exceções, e elas moram na allowlist',
      );
    });

    test('a varredura não roda vazia: o diretório existe e tem arquivo .dart',
        () {
      expect(designSystem.existsSync(), isTrue);
      expect(
        arquivosDartEm(designSystem),
        isNotEmpty,
        reason: 'guarda sem alvo passa vacuamente — o falso-verde do risco R-4',
      );
    });

    test('forma arredondada injetada faz a varredura falhar nomeando o arquivo',
        () {
      _injetar(
        'guarda_de_forma_infrator_de_teste.dart',
        'const raio = BorderRadius.circular(8);\n',
      );

      final violacoes = _varrer(designSystem, violacoesDeFormaEm);

      expect(violacoes, hasLength(1));
      expect(
        violacoes.single,
        contains('guarda_de_forma_infrator_de_teste.dart'),
      );
      expect(violacoes.single, contains('BorderRadius.circular'));
    });

    test('removida a forma injetada, a varredura volta a passar', () {
      final infrator = _injetar(
        'guarda_de_forma_removido_de_teste.dart',
        'const forma = RoundedRectangleBorder();\n',
      );
      expect(_varrer(designSystem, violacoesDeFormaEm), hasLength(1));

      infrator.deleteSync();

      expect(_varrer(designSystem, violacoesDeFormaEm), isEmpty);
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

    test('a allowlist de §3 libera o avatar, o dot da enquete e o frame', () {
      for (final excecao in _formaLiberada) {
        expect(
          violacoesDeFormaEm(
            'lib/core/design_system/components/$excecao',
            'const forma = CircleBorder();',
          ),
          isEmpty,
          reason: '$excecao é exceção declarada em §3',
        );
      }
    });
  });

  group('DS-07 — sombra com blur não entra na UI', () {
    test('nenhum arquivo sob lib/core/design_system tem sombra com blur', () {
      expect(
        _varrer(designSystem, violacoesDeBlurEm),
        isEmpty,
        reason: '§4: "sempre duras, sem blur" — a do frame é a única suave',
      );
    });

    test('blur diferente de zero faz a varredura falhar nomeando o arquivo',
        () {
      _injetar(
        'guarda_de_blur_infrator_de_teste.dart',
        'const sombra = BoxShadow(blurRadius: 4);\n',
      );

      final violacoes = _varrer(designSystem, violacoesDeBlurEm);

      expect(violacoes, hasLength(1));
      expect(
        violacoes.single,
        contains('guarda_de_blur_infrator_de_teste.dart'),
      );
      expect(violacoes.single, contains('blurRadius: 4'));
    });

    test('removido o blur injetado, a varredura volta a passar', () {
      final infrator = _injetar(
        'guarda_de_blur_removido_de_teste.dart',
        'const sombra = BoxShadow(blurRadius: 12);\n',
      );
      expect(_varrer(designSystem, violacoesDeBlurEm), hasLength(1));

      infrator.deleteSync();

      expect(_varrer(designSystem, violacoesDeBlurEm), isEmpty);
    });

    test('blurRadius zero não é acusado, blur por expressão é', () {
      const arquivo = 'lib/core/design_system/components/qualquer.dart';

      expect(violacoesDeBlurEm(arquivo, 'blurRadius: 0,'), isEmpty);
      expect(violacoesDeBlurEm(arquivo, 'blurRadius: 0.0,'), isEmpty);
      expect(
        violacoesDeBlurEm(arquivo, 'blurRadius: distancia,'),
        ['$arquivo: blurRadius: distancia'],
        reason: 'blur vindo de expressão não é auditável por varredura',
      );
    });

    test('a allowlist de §4 libera o frame e o arquivo que declara a sombra',
        () {
      for (final excecao in _blurLiberado) {
        expect(
          violacoesDeBlurEm(
            'lib/core/design_system/tokens/$excecao',
            'blurRadius: 50,',
          ),
          isEmpty,
          reason: '$excecao carrega a única sombra suave de §4',
        );
      }
    });
  });
}
