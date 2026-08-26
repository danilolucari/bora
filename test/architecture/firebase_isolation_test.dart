import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Os únicos lugares de `lib/` autorizados a importar `firebase_auth`.
///
/// A regra é a **AD-019**: uma feature nunca fala com o SDK, fala com a porta
/// `AutenticacaoRepository`. Se isso vazar, cada tela vira um ponto de
/// acoplamento com o Firebase e a suíte deixa de rodar sem emulador — que é
/// exatamente o que a AD-016 comprou.
///
/// As três exceções não são arbitrárias:
/// - o **adaptador**, que existe para ser o tradutor;
/// - o **injector**, que precisa do tipo para registrar;
/// - o **bootstrap do Firebase**, que liga o emulador antes de qualquer tela.
const List<String> _autorizadosAImportarAuth = [
  'lib/core/autenticacao/dados/firebase_autenticacao_repository.dart',
  'lib/core/di/injector.dart',
  'lib/core/firebase/firebase_bootstrap.dart',
];

/// Caminho com o separador do sistema trocado por `/`.
///
/// `listSync` devolve `lib\core` no Windows, e as constantes acima usam `/` —
/// comparar sem normalizar deixa a guarda verde no POSIX e vermelha no Windows
/// (lição L-006).
String _normalizado(String caminho) => caminho.replaceAll(r'\', '/');

List<File> _arquivosDart(Directory diretorio) => diretorio
    .listSync(recursive: true)
    .whereType<File>()
    .where((arquivo) => arquivo.path.endsWith('.dart'))
    .toList();

List<String> infratoresEm(Iterable<(String, String)> arquivos) => [
      for (final (caminho, conteudo) in arquivos)
        if (!_autorizadosAImportarAuth.contains(caminho) &&
            conteudo.contains("import 'package:firebase_auth"))
          caminho,
    ];

void main() {
  group('AD-019 — o SDK de auth não vaza da camada de dados', () {
    test('nenhum arquivo de lib/ importa firebase_auth fora dos três autorizados',
        () {
      final arquivos = _arquivosDart(Directory('lib')).map(
        (arquivo) => (_normalizado(arquivo.path), arquivo.readAsStringSync()),
      );

      expect(
        infratoresEm(arquivos),
        isEmpty,
        reason: 'feature fala com AutenticacaoRepository, nunca com o SDK — é '
            'o que mantém a suíte rodando sem emulador (AD-016)',
      );
    });

    test('nenhuma feature importa firebase_auth', () {
      final features = Directory('lib/features');
      final arquivos = _arquivosDart(features).map(
        (arquivo) => (_normalizado(arquivo.path), arquivo.readAsStringSync()),
      );

      expect(infratoresEm(arquivos), isEmpty);
    });

    test('a varredura acusa o infrator nomeando o arquivo', () {
      const intruso = 'lib/features/entrar/presentation/pages/entrar_page.dart';

      expect(
        infratoresEm([(intruso, "import 'package:firebase_auth/firebase_auth.dart';")]),
        [intruso],
        reason: 'anti-vácuo: guarda que não acusa ninguém passaria à toa',
      );
    });

    test('os três autorizados continuam liberados', () {
      const linha = "import 'package:firebase_auth/firebase_auth.dart';";

      expect(
        infratoresEm([for (final caminho in _autorizadosAImportarAuth) (caminho, linha)]),
        isEmpty,
      );
    });

    test('a allowlist não guarda arquivo que sumiu', () {
      final ausentes = _autorizadosAImportarAuth
          .where((caminho) => !File(caminho).existsSync())
          .toList();

      expect(
        ausentes,
        isEmpty,
        reason: 'allowlist apontando para arquivo inexistente é buraco silencioso',
      );
    });
  });
}
