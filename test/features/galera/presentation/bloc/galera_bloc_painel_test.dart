import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/galera/domain/chave_de_pessoa.dart';
import 'package:bora/features/galera/domain/galera_da_festa.dart';
import 'package:bora/features/galera/presentation/bloc/galera_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/galera_de_teste.dart';
import '../../../../support/galera_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';
import 'galera_bloc_test.dart' show assentar;

/// As chaves da fixture de RN-30 — Rafa(0), Ana(1), Léo(2), **Bia(3)**,
/// Duda(4).
///
/// A Bia é a aberta em quase todos os testes de propósito: ela está **no meio**
/// da lista, então acrescentar alguém antes dela muda o índice sem mudar a
/// chave — que é a distinção que GAL-26 cobra.
const ChaveDePessoa _bia = ChaveDePessoa('Bia', 0);
const ChaveDePessoa _leo = ChaveDePessoa('Léo', 0);

/// Duas homônimas, com dietas **diferentes**: é a dieta que diz qual das duas
/// a chave resolveu, e sem essa diferença a asserção não discriminaria.
final List<Pessoa> _duasAnas = [
  pessoaDeTeste('Ana', dieta: Dieta.tudo),
  pessoaDeTeste('Ana', dieta: Dieta.veggie),
  pessoaDeTeste('Zeca', dieta: Dieta.semPorco),
];

void main() {
  late RecordingAppLogger logger;

  setUp(() => logger = RecordingAppLogger());

  GaleraRepositoryFake repositorioCom(GaleraDaFesta? inicial) {
    final repositorio = GaleraRepositoryFake(inicial: inicial);
    addTearDown(repositorio.dispose);
    return repositorio;
  }

  GaleraBloc blocCom(GaleraRepositoryFake repositorio) {
    final bloc = GaleraBloc(idDaFestaDeTeste, repositorio, logger);
    addTearDown(() async {
      if (!bloc.isClosed) await bloc.close();
    });
    return bloc;
  }

  /// Um bloc já assentado sobre [galera] — o ponto de partida de todo teste
  /// daqui, que sempre começa com a tela carregada.
  Future<(GaleraBloc, GaleraRepositoryFake)> carregado([
    GaleraDaFesta? galera,
  ]) async {
    final repositorio = repositorioCom(galera ?? galeraDeTeste());
    final bloc = blocCom(repositorio);
    await assentar();
    return (bloc, repositorio);
  }

  group('GAL-10 AC1 — um painel aberto por vez', () {
    test('tocar uma linha com tudo fechado abre aquela linha', () async {
      final (bloc, _) = await carregado();

      bloc.add(const LinhaAlternada(_bia));
      await assentar();

      expect(bloc.state.aberta, _bia);
    });

    test('tocar outra linha fecha a primeira e abre a segunda', () async {
      final (bloc, _) = await carregado();
      bloc.add(const LinhaAlternada(_bia));
      await assentar();

      bloc.add(const LinhaAlternada(_leo));
      await assentar();

      expect(bloc.state.aberta, _leo);
      expect(bloc.state.aberta, isNot(_bia));
    });

    test('tocar a linha já aberta fecha', () async {
      final (bloc, _) = await carregado();
      bloc.add(const LinhaAlternada(_bia));
      await assentar();

      bloc.add(const LinhaAlternada(_bia));
      await assentar();

      expect(bloc.state.aberta, isNull);
    });

    test('abrir uma linha não mexe na galera nem no contador', () async {
      final galera = galeraDeTeste();
      final (bloc, _) = await carregado(galera);

      bloc.add(const LinhaAlternada(_bia));
      await assentar();

      expect(bloc.state.galera, galera);
      expect(bloc.state.situacao, SituacaoDaGalera.comFesta);
      expect(bloc.state.copiasConcluidas, 0);
    });
  });

  group('GAL-26 — a emissão do stream não fecha o painel aberto', () {
    test('alguém entrando **antes** da aberta mantém a mesma pessoa aberta',
        () async {
      final (bloc, repositorio) = await carregado();
      bloc.add(const LinhaAlternada(_bia));
      await assentar();
      final indiceAntes =
          ChaveDePessoa.indiceEm(bloc.state.galera!.pessoas, _bia);

      repositorio.emitir(
        galeraDeTeste(
          pessoas: [pessoaDeTeste('Zeca'), ...pessoasRn30DaGalera(bloc)],
        ),
      );
      await assentar();

      final indiceDepois =
          ChaveDePessoa.indiceEm(bloc.state.galera!.pessoas, _bia);

      expect(bloc.state.aberta, _bia);
      expect(indiceAntes, 3);
      expect(
        indiceDepois,
        4,
        reason: 'a linha andou de lugar — é o que separa chave de índice',
      );
      expect(bloc.state.galera!.pessoas[indiceDepois!].nome, 'Bia');
    });

    test('a lista nova entra no estado sem derrubar o painel', () async {
      final (bloc, repositorio) = await carregado();
      bloc.add(const LinhaAlternada(_bia));
      await assentar();

      final depois = galeraDeTeste(
        pessoas: [...pessoasRn30DaGalera(bloc), pessoaDeTeste('Zeca')],
      );
      repositorio.emitir(depois);
      await assentar();

      expect(bloc.state.galera, depois);
      expect(bloc.state.aberta, _bia);
    });

    test('emissão idêntica não fecha o painel', () async {
      final (bloc, repositorio) = await carregado();
      bloc.add(const LinhaAlternada(_bia));
      await assentar();

      repositorio.emitir(galeraDeTeste());
      await assentar();

      expect(bloc.state.aberta, _bia);
    });

    test('outra pessoa sumindo do registro não fecha o painel aberto',
        () async {
      final (bloc, repositorio) = await carregado();
      bloc.add(const LinhaAlternada(_bia));
      await assentar();

      repositorio.emitir(
        galeraDeTeste(
          pessoas: [
            for (final pessoa in pessoasRn30DaGalera(bloc))
              if (pessoa.nome != 'Léo') pessoa,
          ],
        ),
      );
      await assentar();

      expect(bloc.state.aberta, _bia);
    });

    test('a pessoa aberta sumindo do registro fecha o painel, sem exceção',
        () async {
      final (bloc, repositorio) = await carregado();
      bloc.add(const LinhaAlternada(_bia));
      await assentar();

      repositorio.emitir(
        galeraDeTeste(
          pessoas: [
            for (final pessoa in pessoasRn30DaGalera(bloc))
              if (pessoa.nome != 'Bia') pessoa,
          ],
        ),
      );
      await assentar();

      expect(bloc.state.aberta, isNull);
      expect(bloc.state.situacao, SituacaoDaGalera.comFesta);
      expect(logger.erros, isEmpty);
    });
  });

  group('GAL-26 — homônimas são linhas distintas', () {
    test('abrir a segunda Ana abre a segunda, não a primeira', () async {
      final (bloc, _) = await carregado(galeraDeTeste(pessoas: _duasAnas));

      bloc.add(const LinhaAlternada(ChaveDePessoa('Ana', 1)));
      await assentar();

      final indice =
          ChaveDePessoa.indiceEm(bloc.state.galera!.pessoas, bloc.state.aberta!);

      expect(bloc.state.aberta, const ChaveDePessoa('Ana', 1));
      expect(bloc.state.galera!.pessoas[indice!].dieta, Dieta.veggie);
    });

    test('com a segunda Ana aberta, tocar a primeira abre a primeira',
        () async {
      final (bloc, _) = await carregado(galeraDeTeste(pessoas: _duasAnas));
      bloc.add(const LinhaAlternada(ChaveDePessoa('Ana', 1)));
      await assentar();

      bloc.add(const LinhaAlternada(ChaveDePessoa('Ana', 0)));
      await assentar();

      final indice =
          ChaveDePessoa.indiceEm(bloc.state.galera!.pessoas, bloc.state.aberta!);

      expect(bloc.state.aberta, const ChaveDePessoa('Ana', 0));
      expect(bloc.state.galera!.pessoas[indice!].dieta, Dieta.tudo);
    });

    test('a emissão que remove a primeira Ana **fecha** a segunda aberta',
        () async {
      final (bloc, repositorio) =
          await carregado(galeraDeTeste(pessoas: _duasAnas));
      bloc.add(const LinhaAlternada(ChaveDePessoa('Ana', 1)));
      await assentar();

      repositorio.emitir(galeraDeTeste(pessoas: [_duasAnas[1], _duasAnas[2]]));
      await assentar();

      expect(
        bloc.state.aberta,
        isNull,
        reason: 'sobrou uma Ana só: a chave Ana#1 não endereça mais ninguém, '
            'e manter o painel aberto o penduraria na Ana errada',
      );
    });
  });
}

/// As pessoas que estão no estado do bloc agora.
List<Pessoa> pessoasRn30DaGalera(GaleraBloc bloc) => bloc.state.galera!.pessoas;
