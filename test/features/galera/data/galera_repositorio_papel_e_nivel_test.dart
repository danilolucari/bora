import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/data/galera_repositorio_sobre_festas.dart';
import 'package:bora/features/galera/domain/chave_de_pessoa.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/rn30_estado_inicial_tipado.dart';
import '../../../support/festa_em_edicao_repository_fake.dart';
import '../../../support/recording_app_logger.dart';

const String _id = 'festa-1';

const ChaveDePessoa _rafa = ChaveDePessoa('Rafa', 0);
const ChaveDePessoa _duda = ChaveDePessoa('Duda', 0);

ComposicaoDaFesta _composicao([List<Pessoa>? pessoas]) => ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: 4,
      pessoas: pessoas ?? pessoasRn30Tipadas,
      itensSelecionados: itensPadraoRn30Tipados.toSet(),
    );

FestaEmEdicao _festa([List<Pessoa>? pessoas]) => FestaEmEdicao(
      festa: festaRn30Tipada,
      composicao: _composicao(pessoas),
      convite: conviteRn30Tipado,
    );

int _anfitrioes(List<Pessoa> pessoas) =>
    pessoas.where((p) => p.papel == PapelNaFesta.anfitriao).length;

void main() {
  late FestaEmEdicaoRepositoryFake fake;
  late RecordingAppLogger logger;
  late GaleraRepositorioSobreFestas porta;

  Future<ComposicaoDaFesta> lerComposicao() async =>
      (await porta.observarGalera(_id).first)!.composicao;

  Future<ConviteDaFesta> lerConvite() async =>
      (await porta.observarGalera(_id).first)!.convite;

  setUp(() {
    fake = FestaEmEdicaoRepositoryFake(festas: {_id: _festa()});
    logger = RecordingAppLogger();
    porta = GaleraRepositorioSobreFestas(fake, logger);
  });

  group('GAL-17 — alterarPapel troca o papel de quem a chave endereça', () {
    test('a Duda passa de só-vê a co-anfitriã', () async {
      await porta.alterarPapel(_id, _duda, PapelNaFesta.coAnfitriao);

      final duda = (await lerComposicao()).pessoas[4];
      expect(duda.papel, PapelNaFesta.coAnfitriao);
    });

    test('o papel de todas as outras permanece idêntico, item a item',
        () async {
      await porta.alterarPapel(_id, _duda, PapelNaFesta.coAnfitriao);

      final pessoas = (await lerComposicao()).pessoas;
      expect(pessoas[0].papel, PapelNaFesta.anfitriao);
      expect(pessoas[1].papel, PapelNaFesta.coAnfitriao);
      expect(pessoas[2].papel, PapelNaFesta.convidado);
      expect(pessoas[3].papel, PapelNaFesta.convidado);
    });

    test('e nada além do papel muda na pessoa endereçada', () async {
      await porta.alterarPapel(_id, _duda, PapelNaFesta.convidado);

      final duda = (await lerComposicao()).pessoas[4];
      expect(duda.nome, 'Duda');
      expect(duda.status, StatusDePresenca.pendente);
      expect(duda.dieta, isNull);
      expect(duda.bebe, isNull);
    });
  });

  group('GAL-18 — o anfitrião não perde o papel', () {
    test('rebaixar o anfitrião não grava nada', () async {
      await porta.alterarPapel(_id, _rafa, PapelNaFesta.convidado);

      expect(fake.salvas, isEmpty);
      expect((await lerComposicao()).pessoas[0].papel, PapelNaFesta.anfitriao);
    });

    test('a recusa é registrada, e é a recusa da remoção', () async {
      await porta.alterarPapel(_id, _rafa, PapelNaFesta.convidado);

      expect(logger.eventos, hasLength(1));
      expect(logger.eventos.single.name, 'galera');
      expect(logger.eventos.single.message, contains('o alvo é o anfitrião'));
    });

    test('a festa continua com exatamente 1 anfitrião', () async {
      await porta.alterarPapel(_id, _rafa, PapelNaFesta.soVe);

      expect(_anfitrioes((await lerComposicao()).pessoas), 1);
    });
  });

  group('GAL-18 — o papel de anfitrião não é atribuível a ninguém', () {
    test('atribuir anfitrião à Duda não muda o registro', () async {
      await porta.alterarPapel(_id, _duda, PapelNaFesta.anfitriao);

      expect(fake.salvas, isEmpty);
      expect((await lerComposicao()).pessoas[4].papel, PapelNaFesta.soVe);
    });

    test('a recusa é registrada, e é a recusa da atribuição — sensor próprio',
        () async {
      await porta.alterarPapel(_id, _duda, PapelNaFesta.anfitriao);

      expect(logger.eventos, hasLength(1));
      expect(logger.eventos.single.name, 'galera');
      expect(
        logger.eventos.single.message,
        contains('não é atribuível'),
        reason: 'as duas guardas de GAL-18 têm mensagens distintas — uma não '
            'pode passar de carona na outra',
      );
    });

    test('e a festa continua com exatamente 1 anfitrião', () async {
      await porta.alterarPapel(_id, _duda, PapelNaFesta.anfitriao);

      expect(_anfitrioes((await lerComposicao()).pessoas), 1);
    });

    test('nem numa festa que ainda não tem anfitrião nenhum', () async {
      fake = FestaEmEdicaoRepositoryFake(festas: {
        _id: _festa([
          const Pessoa(
            nome: 'Ana',
            papel: PapelNaFesta.convidado,
            status: StatusDePresenca.confirmado,
          ),
        ]),
      });
      porta = GaleraRepositorioSobreFestas(fake, logger);

      await porta.alterarPapel(_id, const ChaveDePessoa('Ana', 0),
          PapelNaFesta.anfitriao);

      expect(fake.salvas, isEmpty);
      expect(_anfitrioes((await lerComposicao()).pessoas), 0);
    });
  });

  group('GAL-04 — definirNivelDoLink escreve só o nível', () {
    test('o nível do convite passa a ser o escolhido', () async {
      await porta.definirNivelDoLink(_id, NivelDoLink.coAnfitriao);

      expect((await lerConvite()).nivel, NivelDoLink.coAnfitriao);
    });

    test('toda a lista de pessoas continua idêntica — item a item', () async {
      await porta.definirNivelDoLink(_id, NivelDoLink.soVer);

      final pessoas = (await lerComposicao()).pessoas;
      for (var i = 0; i < pessoasRn30Tipadas.length; i++) {
        expect(pessoas[i], pessoasRn30Tipadas[i]);
      }
    });

    test('o código do link não é tocado', () async {
      await porta.definirNivelDoLink(_id, NivelDoLink.soVer);

      expect((await lerConvite()).codigo, 'rafa18');
    });

    test('festa que não existe não grava nem lança', () async {
      await porta.definirNivelDoLink('nao-existe', NivelDoLink.soVer);

      expect(fake.salvas, isEmpty);
    });
  });

  group('GAL-28 — papel e nível já vigentes não geram gravação', () {
    test('alterarPapel com o papel que a pessoa já tem não grava', () async {
      await porta.alterarPapel(_id, _duda, PapelNaFesta.soVe);

      expect(fake.salvas, isEmpty);
    });

    test('definirNivelDoLink com o nível já gravado não grava', () async {
      await porta.definirNivelDoLink(_id, NivelDoLink.editarLista);

      expect(fake.salvas, isEmpty);
    });

    test('o controle positivo: valores diferentes gravam uma vez cada',
        () async {
      await porta.alterarPapel(_id, _duda, PapelNaFesta.convidado);
      await porta.definirNivelDoLink(_id, NivelDoLink.coAnfitriao);

      expect(fake.salvas, hasLength(2));
    });
  });

  group('A falha de salvarFesta é registrada e não vaza', () {
    test('alterarPapel com o repositório falhando registra e não lança',
        () async {
      fake.erroDeGravacao = StateError('sem rede');

      await expectLater(
        porta.alterarPapel(_id, _duda, PapelNaFesta.convidado),
        completes,
      );
      expect(logger.erros, hasLength(1));
      expect(logger.erros.single.name, 'galera');
      expect(logger.erros.single.error, isA<StateError>());
    });

    test('definirNivelDoLink com o repositório falhando registra e não lança',
        () async {
      fake.erroDeGravacao = StateError('sem rede');

      await expectLater(
        porta.definirNivelDoLink(_id, NivelDoLink.soVer),
        completes,
      );
      expect(logger.erros, hasLength(1));
      expect(logger.erros.single.name, 'galera');
    });
  });

  group('GAL-09 — nenhuma das quatro escritas mexe no contador da festa', () {
    late FestaRepositoryEmMemoria memoria;

    setUp(() {
      memoria = FestaRepositoryEmMemoria(inicial: [
        ResumoDeFesta(
          id: _id,
          festa: festaRn30Tipada,
          confirmados: 4,
          pendentes: 2,
          composicao: _composicao(),
        ),
      ]);
      porta = GaleraRepositorioSobreFestas(memoria, logger);
      addTearDown(memoria.dispose);
    });

    Future<void> conferirOContador() async {
      final resumo = (await memoria.observarFestas().first).single;
      final galera = (await porta.observarGalera(_id).first)!;

      expect(resumo.confirmados, 4);
      expect(resumo.pendentes, 2);
      expect(galera.confirmados, resumo.confirmados);
    }

    test('depois de alterarDieta', () async {
      await porta.alterarDieta(_id, _duda, Dieta.veggie);
      await conferirOContador();
    });

    test('depois de alterarBebida', () async {
      await porta.alterarBebida(_id, _duda, true);
      await conferirOContador();
    });

    test('depois de alterarPapel', () async {
      await porta.alterarPapel(_id, _duda, PapelNaFesta.convidado);
      await conferirOContador();
    });

    test('depois de definirNivelDoLink', () async {
      await porta.definirNivelDoLink(_id, NivelDoLink.coAnfitriao);
      await conferirOContador();
    });
  });
}
