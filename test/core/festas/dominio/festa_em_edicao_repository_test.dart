import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
// O barrel é a porta de entrada — este import é, ele mesmo, a asserção de que
// `festas.dart` exporta também a porta, e não só o valor.
import 'package:bora/core/festas/festas.dart';
import 'package:flutter_test/flutter_test.dart';

const String _barrel = 'lib/core/festas/festas.dart';
const String _dominio = 'lib/core/festas/dominio';

final RegExp _diretivaDeImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

List<String> _alvosDe(String conteudoDart) =>
    _diretivaDeImport.allMatches(conteudoDart).map((m) => m.group(1)!).toList();

Festa _festa({String nome = 'CHURRAS NOVO'}) => Festa(
      nome: nome,
      data: 'SÁB · 18 JUL',
      hora: '',
      local: '',
      duracaoHoras: 4,
    );

FestaEmEdicao _rascunho({String nome = 'CHURRAS NOVO'}) => FestaEmEdicao(
      festa: _festa(nome: nome),
      composicao: ComposicaoDaFesta(
        contagem: ContagemDePessoas(),
        duracaoHoras: 4,
      ),
    );

/// Duplo escrito à mão para a porta de domínio (**AD-021**): `mocktail` é só
/// para SDK de terceiro.
///
/// **A ausência de `dispose` aqui é a asserção do critério "a porta não
/// declara `dispose`"**: se `FestaEmEdicaoRepository` o exigisse, este arquivo
/// não compilaria — e o teste que não compila não passa. O ciclo de vida do
/// store é da porta de leitura, que já o expõe.
class _FestaEmEdicaoFake implements FestaEmEdicaoRepository {
  final Map<String, FestaEmEdicao> _festas = {};
  int _proximoId = 0;

  @override
  Stream<FestaEmEdicao?> observarFesta(String id) =>
      Stream<FestaEmEdicao?>.value(_festas[id]);

  @override
  Future<String> criarFesta(FestaEmEdicao rascunho) async {
    final id = 'festa-${_proximoId++}';
    _festas[id] = rascunho;
    return id;
  }

  @override
  Future<void> salvarFesta(String id, FestaEmEdicao festa) async {
    _festas[id] = festa;
  }
}

void main() {
  group('AD-029 — a porta de edição declara os três métodos do design §6.2',
      () {
    test('uma implementação com os três métodos satisfaz a porta', () {
      expect(_FestaEmEdicaoFake(), isA<FestaEmEdicaoRepository>());
    });

    test('observarFesta entrega a festa de um id, agora e a cada mudança',
        () async {
      final FestaEmEdicaoRepository porta = _FestaEmEdicaoFake();
      final id = await porta.criarFesta(_rascunho());

      await expectLater(porta.observarFesta(id), emits(_rascunho()));
    });

    test('observarFesta de festa inexistente emite null — "não existe"',
        () async {
      final FestaEmEdicaoRepository porta = _FestaEmEdicaoFake();

      await expectLater(porta.observarFesta('nao-existe'), emits(isNull));
    });

    test('criarFesta devolve o festaId da festa criada (MONT-17)', () async {
      final FestaEmEdicaoRepository porta = _FestaEmEdicaoFake();

      final id = await porta.criarFesta(_rascunho());

      expect(id, isA<String>());
      expect(id, isNotEmpty);
    });

    test('salvarFesta grava sobre um id existente e não devolve valor (MONT-18)',
        () async {
      final FestaEmEdicaoRepository porta = _FestaEmEdicaoFake();
      final id = await porta.criarFesta(_rascunho());

      await porta.salvarFesta(id, _rascunho(nome: 'CHURRAS DO RAFA 🔥'));

      await expectLater(
        porta.observarFesta(id),
        emits(_rascunho(nome: 'CHURRAS DO RAFA 🔥')),
      );
    });
  });

  group('AD-029 — o barrel é a única porta de entrada da camada', () {
    test('exporta exatamente os arquivos de dominio/, e nada além deles', () {
      final exportados = _alvosDe(File(_barrel).readAsStringSync()).toSet();
      final arquivosDeDominio = Directory(_dominio)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .map((f) => 'dominio/${f.uri.pathSegments.last}')
          .toSet();

      expect(arquivosDeDominio, hasLength(3));
      expect(
        exportados,
        arquivosDeDominio,
        reason: 'arquivo de dominio/ fora do barrel some da porta; export a '
            'mais abre uma segunda entrada',
      );
    });
  });
}
