import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/festa_repository.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:flutter_test/flutter_test.dart';

/// A segunda porta do store (emenda **E-2** do `montar/design.md`): a mesma
/// instância que a Home lê passa a criar e gravar festa para `montar`.
///
/// Arquivo separado de `festa_repository_em_memoria_test.dart` de propósito:
/// a suíte da spec 04 tem de rodar **intacta**, e é isso que prova que a
/// segunda porta é aditiva.
const String _id = 'rafa18';

const Festa _churrasDoRafa = Festa(
  nome: 'CHURRAS DO RAFA 🔥',
  data: 'SÁB · 18 JUL',
  hora: '14H',
  local: 'Laje do Rafa — Vila Madalena',
  duracaoHoras: 4,
);

/// O registro da Home com os contadores de RN-30: 4 confirmados, 2 pendentes.
const ResumoDeFesta _rn30 = ResumoDeFesta(
  id: _id,
  festa: _churrasDoRafa,
  confirmados: 4,
  pendentes: 2,
  iniciais: ['R', 'A', 'L'],
);

ComposicaoDaFesta _composicaoPadrao({int duracaoHoras = 4}) =>
    ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: duracaoHoras,
      itensSelecionados: {ChaveItem.bovina, ChaveItem.frango},
    );

/// O rascunho que `/roles/novo` abre: nome default e composição vazia de 4h.
FestaEmEdicao _rascunho({
  String nome = 'CHURRAS NOVO',
  ComposicaoDaFesta? composicao,
}) =>
    FestaEmEdicao(
      festa: Festa(
        nome: nome,
        data: 'SÁB · 18 JUL',
        hora: '',
        local: '',
        duracaoHoras: 4,
      ),
      composicao: composicao ??
          ComposicaoDaFesta(contagem: ContagemDePessoas(), duracaoHoras: 4),
    );

FestaRepositoryEmMemoria _store({List<ResumoDeFesta> inicial = const []}) {
  final repositorio = FestaRepositoryEmMemoria(inicial: inicial);
  addTearDown(repositorio.dispose);
  return repositorio;
}

void main() {
  group('MONT-16 — observarFesta entrega a festa de um id', () {
    test('quem assina recebe o estado corrente antes de qualquer mudança',
        () async {
      final repositorio = _store(
        inicial: [
          ResumoDeFesta(
            id: _id,
            festa: _churrasDoRafa,
            composicao: _composicaoPadrao(),
          ),
        ],
      );

      await expectLater(
        repositorio.observarFesta(_id),
        emits(
          FestaEmEdicao(
            festa: _churrasDoRafa,
            composicao: _composicaoPadrao(),
          ),
        ),
      );
    });

    test('festa inexistente emite null — não lança e não fica em silêncio',
        () async {
      final repositorio = _store(inicial: const [_rn30]);

      await expectLater(repositorio.observarFesta('nao-existe'), emits(isNull));
    });

    test('emite de novo a cada salvarFesta (MONT-18)', () async {
      final repositorio = _store(inicial: const [_rn30]);

      final recebidos = <FestaEmEdicao?>[];
      final inscricao = repositorio.observarFesta(_id).listen(recebidos.add);
      addTearDown(inscricao.cancel);
      await Future<void>.delayed(Duration.zero);

      await repositorio.salvarFesta(
        _id,
        FestaEmEdicao(
          festa: _churrasDoRafa,
          composicao: _composicaoPadrao(duracaoHoras: 6),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(recebidos, hasLength(2));
      expect(recebidos.first!.composicao.duracaoHoras, 4);
      expect(recebidos.last!.composicao.duracaoHoras, 6);
    });
  });

  group('MONT-17 — criarFesta faz o rolê existir', () {
    test('devolve um id novo e único a cada chamada', () async {
      final repositorio = _store();

      final primeiro = await repositorio.criarFesta(_rascunho());
      final segundo = await repositorio.criarFesta(_rascunho());

      expect(primeiro, isNotEmpty);
      expect(segundo, isNotEmpty);
      expect(primeiro, isNot(segundo));
    });

    test('o id novo não colide com um id que já veio na semente', () async {
      final repositorio = _store(
        inicial: const [
          ResumoDeFesta(id: 'festa-1', festa: _churrasDoRafa),
          ResumoDeFesta(id: 'festa-2', festa: _churrasDoRafa),
        ],
      );

      final id = await repositorio.criarFesta(_rascunho());

      expect(id, isNot('festa-1'));
      expect(id, isNot('festa-2'));
    });

    test('a festa criada aparece em observarFestas — é o que a faz chegar '
        'na Home', () async {
      final repositorio = _store();

      final id = await repositorio.criarFesta(_rascunho());

      final festas = await repositorio.observarFestas().first;
      expect(festas, hasLength(1));
      expect(festas.single.id, id);
      expect(festas.single.festa.nome, 'CHURRAS NOVO');
    });

    test('a festa criada é observável pelo id, com a composição do rascunho',
        () async {
      final repositorio = _store();
      final rascunho = _rascunho(composicao: _composicaoPadrao());

      final id = await repositorio.criarFesta(rascunho);

      await expectLater(repositorio.observarFesta(id), emits(rascunho));
    });

    test('criar não apaga a festa que já estava na lista', () async {
      final repositorio = _store(inicial: const [_rn30]);

      await repositorio.criarFesta(_rascunho());

      final festas = await repositorio.observarFestas().first;
      expect(festas.map((f) => f.id), contains(_id));
      expect(festas, hasLength(2));
    });

    test('a festa criada nasce sem contador de RSVP (AD-022)', () async {
      final repositorio = _store();

      final id = await repositorio.criarFesta(_rascunho());

      final festas = await repositorio.observarFestas().first;
      final criada = festas.firstWhere((f) => f.id == id);
      expect(criada.confirmados, 0);
      expect(criada.pendentes, 0);
      expect(criada.iniciais, isEmpty);
    });
  });

  group('MONT-18 — salvarFesta grava identidade e composição', () {
    test('grava o nome e a data que montar editou', () async {
      final repositorio = _store(inicial: const [_rn30]);

      await repositorio.salvarFesta(
        _id,
        _rascunho(nome: 'CHURRAS DA LAJE', composicao: _composicaoPadrao()),
      );

      final festas = await repositorio.observarFestas().first;
      expect(festas.single.festa.nome, 'CHURRAS DA LAJE');
    });

    test('grava a composição, que é o que a calculadora consome', () async {
      final repositorio = _store(inicial: const [_rn30]);

      await repositorio.salvarFesta(
        _id,
        _rascunho(composicao: _composicaoPadrao(duracaoHoras: 6)),
      );

      final festas = await repositorio.observarFestas().first;
      expect(festas.single.composicao, _composicaoPadrao(duracaoHoras: 6));
    });

    test('preserva confirmados, pendentes e iniciais — montar não mexe em '
        'contador de RSVP (AD-022)', () async {
      final repositorio = _store(inicial: const [_rn30]);

      await repositorio.salvarFesta(
        _id,
        _rascunho(nome: 'CHURRAS DA LAJE', composicao: _composicaoPadrao()),
      );

      final festas = await repositorio.observarFestas().first;
      expect(festas.single.confirmados, 4);
      expect(festas.single.pendentes, 2);
      expect(festas.single.iniciais, ['R', 'A', 'L']);
    });

    test('preserva pessoas e total da festa concluída (UC-24)', () async {
      final repositorio = _store(
        inicial: const [
          ResumoDeFesta(
            id: _id,
            festa: _churrasDoRafa,
            pessoas: 12,
            total: 340,
          ),
        ],
      );

      await repositorio.salvarFesta(_id, _rascunho());

      final festas = await repositorio.observarFestas().first;
      expect(festas.single.pessoas, 12);
      expect(festas.single.total, 340);
    });

    test('id inexistente é no-op: nenhuma festa fantasma nasce', () async {
      final repositorio = _store(inicial: const [_rn30]);

      await repositorio.salvarFesta('nao-existe', _rascunho());

      final festas = await repositorio.observarFestas().first;
      expect(festas, const [_rn30]);
    });

    test('id inexistente não emite nada para quem está ouvindo', () async {
      final repositorio = _store(inicial: const [_rn30]);

      final recebidos = <List<ResumoDeFesta>>[];
      final inscricao = repositorio.observarFestas().listen(recebidos.add);
      addTearDown(inscricao.cancel);
      await Future<void>.delayed(Duration.zero);

      await repositorio.salvarFesta('nao-existe', _rascunho());
      await Future<void>.delayed(Duration.zero);

      expect(
        recebidos,
        hasLength(1),
        reason: 'emitir sem mudança faria a Home redesenhar à toa',
      );
    });

    test('gravar uma festa não mexe na outra', () async {
      final repositorio = _store(
        inicial: const [
          _rn30,
          ResumoDeFesta(id: 'outra', festa: _churrasDoRafa, confirmados: 1),
        ],
      );

      await repositorio.salvarFesta(
        _id,
        _rascunho(nome: 'CHURRAS DA LAJE', composicao: _composicaoPadrao()),
      );

      final festas = await repositorio.observarFestas().first;
      final outra = festas.firstWhere((f) => f.id == 'outra');
      expect(outra.festa.nome, 'CHURRAS DO RAFA 🔥');
      expect(outra.confirmados, 1);
    });
  });

  group('AD-029 — uma instância, duas portas, o mesmo store', () {
    test('a implementação satisfaz as duas portas', () {
      final repositorio = _store();

      expect(repositorio, isA<FestaRepository>());
      expect(repositorio, isA<FestaEmEdicaoRepository>());
    });

    test('o que montar cria pela porta de escrita, a Home vê pela de leitura',
        () async {
      final repositorio = _store();
      final FestaEmEdicaoRepository escrita = repositorio;
      final FestaRepository leitura = repositorio;

      final id = await escrita.criarFesta(_rascunho());
      await escrita.salvarFesta(
        id,
        _rascunho(nome: 'CHURRAS DA LAJE', composicao: _composicaoPadrao()),
      );

      final festas = await leitura.observarFestas().first;
      expect(festas.single.id, id);
      expect(festas.single.festa.nome, 'CHURRAS DA LAJE');
      expect(festas.single.composicao, _composicaoPadrao());
    });
  });
}
