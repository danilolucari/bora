import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/festa_repository.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:flutter_test/flutter_test.dart';

const String _arquivoDaImpl =
    'lib/features/home/data/festa_repository_em_memoria.dart';

/// Alvos que `lib/` não pode importar: código de teste não vai para produção.
const List<String> _alvosProibidos = ['test/', 'fixtures', 'flutter_test'];

/// Casa na **diretiva de import**, nunca em texto solto.
///
/// O doc comment deste arquivo e o da própria implementação citam
/// `test/fixtures/` para explicar a regra. Uma varredura por texto acusaria o
/// próprio comentário — foi o erro que se repetiu três vezes na spec 03.
final RegExp _diretivaDeImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

List<String> _importsDeTesteEm(String conteudoDart) => _diretivaDeImport
    .allMatches(conteudoDart)
    .map((m) => m.group(1)!)
    .where((alvo) => _alvosProibidos.any(alvo.contains))
    .toList();

const Festa _churrasDoRafa = Festa(
  nome: 'CHURRAS DO RAFA 🔥',
  data: 'SÁB · 18 JUL',
  hora: '14H',
  local: 'Laje do Rafa — Vila Madalena',
  duracaoHoras: 4,
);

const ResumoDeFesta _rn30 = ResumoDeFesta(
  festa: _churrasDoRafa,
  confirmados: 4,
  pendentes: 2,
  iniciais: ['R', 'A', 'L'],
);

/// A mesma festa depois do RSVP de RN-28: um confirmado a mais, um pendente
/// a menos.
const ResumoDeFesta _rn30DepoisDoRsvp = ResumoDeFesta(
  festa: _churrasDoRafa,
  confirmados: 5,
  pendentes: 1,
  iniciais: ['R', 'A', 'L'],
);

void main() {
  group('HOME-19 — a porta entrega o estado corrente e as mudanças', () {
    test('quem assina recebe a semente injetada', () async {
      final repositorio = FestaRepositoryEmMemoria(inicial: const [_rn30]);
      addTearDown(repositorio.dispose);

      await expectLater(
        repositorio.observarFestas(),
        emits(const [_rn30]),
      );
    });

    test('sem semente, o primeiro estado é a lista vazia (HOME-15)', () async {
      final repositorio = FestaRepositoryEmMemoria();
      addTearDown(repositorio.dispose);

      await expectLater(
        repositorio.observarFestas(),
        emits(isEmpty),
      );
    });

    test('emitir entrega o estado novo a quem já estava ouvindo (RN-28)',
        () async {
      final repositorio = FestaRepositoryEmMemoria(inicial: const [_rn30]);
      addTearDown(repositorio.dispose);

      final recebidos = <List<ResumoDeFesta>>[];
      final inscricao = repositorio.observarFestas().listen(recebidos.add);
      addTearDown(inscricao.cancel);
      await Future<void>.delayed(Duration.zero);

      repositorio.emitir(const [_rn30DepoisDoRsvp]);
      await Future<void>.delayed(Duration.zero);

      expect(recebidos, [
        const [_rn30],
        const [_rn30DepoisDoRsvp],
      ]);
    });

    test('quem assina depois de uma emissão recebe o último estado, não a '
        'semente', () async {
      final repositorio = FestaRepositoryEmMemoria(inicial: const [_rn30]);
      addTearDown(repositorio.dispose);

      repositorio.emitir(const [_rn30DepoisDoRsvp]);

      await expectLater(
        repositorio.observarFestas(),
        emits(const [_rn30DepoisDoRsvp]),
      );
    });

    test('dois ouvintes ao mesmo tempo recebem a mesma emissão', () async {
      final repositorio = FestaRepositoryEmMemoria(inicial: const [_rn30]);
      addTearDown(repositorio.dispose);

      final primeiro = <List<ResumoDeFesta>>[];
      final segundo = <List<ResumoDeFesta>>[];
      final a = repositorio.observarFestas().listen(primeiro.add);
      final b = repositorio.observarFestas().listen(segundo.add);
      addTearDown(a.cancel);
      addTearDown(b.cancel);
      await Future<void>.delayed(Duration.zero);

      repositorio.emitir(const [_rn30DepoisDoRsvp]);
      await Future<void>.delayed(Duration.zero);

      expect(primeiro.last, const [_rn30DepoisDoRsvp]);
      expect(segundo.last, const [_rn30DepoisDoRsvp]);
    });

    test('depois de dispose, assinar não estoura — o stream só termina',
        () async {
      final repositorio = FestaRepositoryEmMemoria(inicial: const [_rn30]);
      await repositorio.dispose();

      await expectLater(
        repositorio.observarFestas(),
        emitsInOrder([
          const [_rn30],
          emitsDone,
        ]),
      );
    });

    test('a implementação satisfaz a porta', () {
      final repositorio = FestaRepositoryEmMemoria();
      addTearDown(repositorio.dispose);

      expect(repositorio, isA<FestaRepository>());
    });
  });

  group('HOME-19 — a semente entra por injeção, nunca por import de teste', () {
    test('a implementação não importa test/, fixtures nem flutter_test', () {
      final conteudo = File(_arquivoDaImpl).readAsStringSync();

      expect(conteudo, isNotEmpty);
      expect(
        _importsDeTesteEm(conteudo),
        isEmpty,
        reason: 'código de produção dependendo de test/ é o risco que a '
            'injeção da semente existe para evitar',
      );
    });

    test('a varredura acusa um import proibido, se houver', () {
      expect(
        _importsDeTesteEm("import '../../../test/fixtures/rn30.dart';"),
        ['../../../test/fixtures/rn30.dart'],
      );
      expect(
        _importsDeTesteEm("import 'package:flutter_test/flutter_test.dart';"),
        ['package:flutter_test/flutter_test.dart'],
      );
    });

    test('a varredura ignora o alvo proibido citado em comentário', () {
      expect(
        _importsDeTesteEm('/// A semente não vem de test/fixtures/.\n'),
        isEmpty,
        reason: 'casar em texto acusaria o próprio doc comment que explica a '
            'regra — o erro que se repetiu três vezes na spec 03',
      );
    });
  });
}
