import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/data/galera_repositorio_sobre_festas.dart';
import 'package:bora/features/galera/domain/chave_de_pessoa.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/festa_repository.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:bora/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/rn30_estado_inicial_tipado.dart';
import '../../../support/recording_app_logger.dart';

const String _id = 'festa-1';
const ChaveDePessoa _leo = ChaveDePessoa('Léo', 0);
const ChaveDePessoa _bia = ChaveDePessoa('Bia', 0);

ComposicaoDaFesta _composicao() => ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: 4,
      pessoas: pessoasRn30Tipadas,
      itensSelecionados: {...itensPadraoRn30Tipados, ChaveItem.suina},
    );

ResumoDeFesta _resumo() => ResumoDeFesta(
      id: _id,
      festa: festaRn30Tipada,
      confirmados: 4,
      pendentes: 2,
      composicao: _composicao(),
    );

bool _temKitVeggie(ComposicaoDaFesta composicao) =>
    CalculadoraDaFesta.calcular(composicao)
        .itens
        .any((i) => i.chave == ChaveItem.legumesParaGrelha);

bool _temSuina(ComposicaoDaFesta composicao) =>
    CalculadoraDaFesta.calcular(composicao)
        .itens
        .any((i) => i.chave == ChaveItem.suina);

/// A propriedade estrutural do `design.md` §2.1: **a festa é um registro só**.
///
/// A Home lê pela `FestaRepository`, a Galera escreve pela `GaleraRepository`,
/// e as duas portas são a **mesma instância** de `FestaRepositoryEmMemoria` —
/// não há sincronia nenhuma entre elas porque não há o que sincronizar. É
/// disso que GAL-09 e GAL-14 são consequência, e não de disciplina.
///
/// O último grupo é a razão pela qual o desenho é a abordagem **B** de §2.1 e
/// não a **A**: com um store próprio para a Galera, a escrita não chega à Home
/// e as duas visões da mesma festa divergem sem que nada avise. Ele é
/// executado como asserção da divergência — nunca como teste que se espera
/// vermelho —, e é o que prova que as asserções positivas acima não passam à
/// toa.
void main() {
  late FestaRepositoryEmMemoria store;
  late GaleraRepositorioSobreFestas galera;

  setUp(() {
    store = FestaRepositoryEmMemoria(inicial: [_resumo()]);
    galera = GaleraRepositorioSobreFestas(store, RecordingAppLogger());
    addTearDown(store.dispose);
  });

  Future<ComposicaoDaFesta> composicaoNaHome() async =>
      (await store.observarFestas().first).single.composicao;

  group('Uma instância, duas portas, o mesmo registro', () {
    test('o store semeado pela fixture serve as duas portas de uma vez', () {
      expect(store, isA<FestaRepository>());
      expect(store, isA<FestaEmEdicaoRepository>());
    });

    test('a Home e a Galera partem da mesma composição', () async {
      final naGalera = (await galera.observarGalera(_id).first)!.composicao;

      expect(naGalera, await composicaoNaHome());
    });
  });

  group('GAL-09/GAL-14 — a escrita da Galera chega à Home sem sincronia', () {
    test('alterarDieta pela Galera muda a composição que a Home lista',
        () async {
      await galera.alterarDieta(_id, _bia, Dieta.tudo);

      expect((await composicaoNaHome()).pessoas[3].dieta, Dieta.tudo);
    });

    test('e o HomeBloc, que assina o stream, recebe a composição nova',
        () async {
      final bloc = HomeBloc(store, RecordingAppLogger());
      addTearDown(bloc.close);
      await Future<void>.delayed(Duration.zero);

      await galera.alterarDieta(_id, _bia, Dieta.tudo);
      await Future<void>.delayed(Duration.zero);

      final naHome = bloc.state.chegando.single.composicao;
      expect(naHome.pessoas[3].dieta, Dieta.tudo);
    });

    test('o contador da Home não é tocado pela escrita da Galera', () async {
      await galera.alterarPapel(_id, _bia, PapelNaFesta.coAnfitriao);

      final resumo = (await store.observarFestas().first).single;
      expect(resumo.confirmados, 4);
      expect(resumo.pendentes, 2);
    });
  });

  group('GAL-14 — e a calculadora, sobre o mesmo registro, já se ajusta', () {
    test('tirar o "sem porco" da Bia traz a suína selecionada de volta',
        () async {
      expect(_temSuina(await composicaoNaHome()), isFalse);

      await galera.alterarDieta(_id, _bia, Dieta.tudo);

      expect(_temSuina(await composicaoNaHome()), isTrue);
    });

    test('tirar o veggie do Léo faz o kit de legumes sair da lista', () async {
      expect(_temKitVeggie(await composicaoNaHome()), isTrue);

      await galera.alterarDieta(_id, _leo, Dieta.tudo);

      expect(_temKitVeggie(await composicaoNaHome()), isFalse);
    });
  });

  group('O par que discrimina: com dois stores, a Home não vê a escrita', () {
    test('a Galera sobre um store próprio deixa a Home no dado antigo',
        () async {
      final storeDaGalera = FestaRepositoryEmMemoria(inicial: [_resumo()]);
      addTearDown(storeDaGalera.dispose);
      final galeraApartada =
          GaleraRepositorioSobreFestas(storeDaGalera, RecordingAppLogger());

      await galeraApartada.alterarDieta(_id, _bia, Dieta.tudo);

      expect(
        (await storeDaGalera.observarFestas().first)
            .single
            .composicao
            .pessoas[3]
            .dieta,
        Dieta.tudo,
      );
      expect(
        (await composicaoNaHome()).pessoas[3].dieta,
        Dieta.semPorco,
        reason: 'é exatamente esta divergência que a abordagem A de §2.1 '
            'produziria — e o motivo de o desenho ser a B',
      );
    });

    test('e a lista da Home continuaria sem a suína, com a Galera dizendo que '
        'sim', () async {
      final storeDaGalera = FestaRepositoryEmMemoria(inicial: [_resumo()]);
      addTearDown(storeDaGalera.dispose);
      final galeraApartada =
          GaleraRepositorioSobreFestas(storeDaGalera, RecordingAppLogger());

      await galeraApartada.alterarDieta(_id, _bia, Dieta.tudo);

      final apartada =
          (await storeDaGalera.observarFestas().first).single.composicao;
      expect(_temSuina(apartada), isTrue);
      expect(_temSuina(await composicaoNaHome()), isFalse);
    });
  });
}
