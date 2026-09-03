import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/domain/chave_de_pessoa.dart';
import 'package:bora/features/galera/domain/galera_da_festa.dart';
import 'package:bora/features/galera/presentation/bloc/galera_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/area_de_transferencia_falsa.dart';
import '../../../../support/galera_de_teste.dart';
import '../../../../support/galera_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';
import 'galera_bloc_test.dart' show assentar, semDocumentacao;

const String _arquivo =
    'lib/features/galera/presentation/bloc/galera_bloc.dart';

/// O id que o bloc recebe, **diferente** do `festaId` da leitura semeada
/// (`festa-1`): sem essa diferença, um bloc que escrevesse em
/// `galera.festaId` em vez de no id que lhe deram passaria igual.
const String _idDoBloc = 'festa-42';

/// A Bia de RN-30: dieta `semPorco`, `bebe: false`, papel `convidado`.
///
/// Todo valor pedido nos testes é **distinto** do que ela já tem — é o que
/// separa "delegou" de "não fez nada" e de "escreveu o valor errado".
const ChaveDePessoa _bia = ChaveDePessoa('Bia', 0);

/// Uma chave que não endereça ninguém na fixture.
const ChaveDePessoa _fantasma = ChaveDePessoa('Zeca', 0);

/// Operadores que só apareceriam no bloc se uma fórmula de RN-03, RN-05 ou
/// RN-21 tivesse sido reescrita aqui — GAL-15 AC11.
const List<String> _operadoresDeFormula = ['*', '/'];

/// A fonte sem doc **e sem as diretivas de import**: `import '../..'` tem
/// barra e acusaria todo arquivo do projeto.
String semDocumentacaoNemImports(String fonte) => semDocumentacao(fonte)
    .split('\n')
    .where((linha) {
      final limpa = linha.trimLeft();
      return !limpa.startsWith('import ') && !limpa.startsWith('export ');
    })
    .join('\n');

/// Os operadores de fórmula presentes no código de [fonte].
List<String> formulaEm(String fonte) {
  final codigo = semDocumentacaoNemImports(fonte);
  return [
    for (final operador in _operadoresDeFormula)
      if (codigo.contains(operador)) operador,
  ];
}

void main() {
  late RecordingAppLogger logger;

  setUp(() => logger = RecordingAppLogger());

  GaleraRepositoryFake repositorioCom(GaleraDaFesta? inicial) {
    final repositorio = GaleraRepositoryFake(inicial: inicial);
    addTearDown(repositorio.dispose);
    return repositorio;
  }

  GaleraBloc blocCom(GaleraRepositoryFake repositorio) {
    final bloc =
        GaleraBloc(_idDoBloc, repositorio, AreaDeTransferenciaFalsa(), logger);
    addTearDown(() async {
      if (!bloc.isClosed) await bloc.close();
    });
    return bloc;
  }

  /// Um bloc já assentado sobre a fixture — a tela carregada.
  Future<(GaleraBloc, GaleraRepositoryFake)> carregado([
    GaleraDaFesta? galera,
  ]) async {
    final repositorio = repositorioCom(galera ?? galeraDeTeste());
    final bloc = blocCom(repositorio);
    await assentar();
    return (bloc, repositorio);
  }

  group('GAL-11, GAL-12, GAL-17, GAL-04 — cada gesto vira a escrita dele', () {
    test('a dieta escolhida vai para alterarDieta, com chave e valor',
        () async {
      final (bloc, repositorio) = await carregado();

      bloc.add(const DietaEscolhida(_bia, Dieta.veggie));
      await assentar();

      expect(repositorio.dietas, [(_idDoBloc, _bia, Dieta.veggie)]);
      expect(repositorio.escritas, 1);
    });

    test('a bebida alternada vai para alterarBebida, com chave e valor',
        () async {
      final (bloc, repositorio) = await carregado();

      bloc.add(const BebidaAlternada(_bia, true));
      await assentar();

      expect(repositorio.bebidas, [(_idDoBloc, _bia, true)]);
      expect(repositorio.escritas, 1);
    });

    test('o papel escolhido vai para alterarPapel, com chave e valor',
        () async {
      final (bloc, repositorio) = await carregado();

      bloc.add(const PapelEscolhido(_bia, PapelNaFesta.coAnfitriao));
      await assentar();

      expect(repositorio.papeis, [(_idDoBloc, _bia, PapelNaFesta.coAnfitriao)]);
      expect(repositorio.escritas, 1);
    });

    test('o nível escolhido vai para definirNivelDoLink, sem pessoa nenhuma',
        () async {
      final (bloc, repositorio) = await carregado();

      bloc.add(const NivelEscolhido(NivelDoLink.coAnfitriao));
      await assentar();

      expect(repositorio.niveis, [(_idDoBloc, NivelDoLink.coAnfitriao)]);
      expect(repositorio.escritas, 1);
    });

    test('e numa festa que ainda não tem pessoa nomeada nenhuma, igual',
        () async {
      // P1-2 AC4, literal: "a tela não tem nenhuma pessoa nomeada e o nível é
      // alterado ⇒ o comportamento é o mesmo — só o nível muda". O teste
      // acima diz "sem pessoa nenhuma" no sentido de *o evento não carrega
      // chave*; aqui a **festa** é que está vazia.
      final (bloc, repositorio) =
          await carregado(galeraDeTeste(pessoas: const []));

      bloc.add(const NivelEscolhido(NivelDoLink.coAnfitriao));
      await assentar();

      expect(repositorio.niveis, [(_idDoBloc, NivelDoLink.coAnfitriao)]);
      expect(repositorio.escritas, 1);
    });
  });

  group('A fonte da verdade continua sendo o stream', () {
    test('escrever não muda o estado enquanto o stream não emite', () async {
      final galera = galeraDeTeste();
      final (bloc, _) = await carregado(galera);
      final antes = bloc.state;

      bloc.add(const DietaEscolhida(_bia, Dieta.veggie));
      await assentar();

      expect(bloc.state, antes);
      expect(bloc.state.galera, galera);
    });

    test('a mudança aparece quando o stream emite', () async {
      final (bloc, repositorio) = await carregado();
      bloc.add(const DietaEscolhida(_bia, Dieta.veggie));
      await assentar();

      final depois = galeraDeTeste(
        pessoas: [
          for (final pessoa in bloc.state.galera!.pessoas)
            if (pessoa.nome == 'Bia')
              pessoa.copyWith(dieta: Dieta.veggie)
            else
              pessoa,
        ],
      );
      repositorio.emitir(depois);
      await assentar();

      expect(bloc.state.galera!.pessoas[3].dieta, Dieta.veggie);
    });
  });

  group('GAL-28 — a opção já ativa não vira escrita', () {
    test('a dieta que a pessoa já tem não chama a porta', () async {
      final (bloc, repositorio) = await carregado();

      bloc.add(const DietaEscolhida(_bia, Dieta.semPorco));
      await assentar();

      expect(repositorio.dietas, isEmpty);
    });

    test('a bebida que a pessoa já tem não chama a porta', () async {
      final (bloc, repositorio) = await carregado();

      bloc.add(const BebidaAlternada(_bia, false));
      await assentar();

      expect(repositorio.bebidas, isEmpty);
    });

    test('o papel que a pessoa já tem não chama a porta', () async {
      final (bloc, repositorio) = await carregado();

      bloc.add(const PapelEscolhido(_bia, PapelNaFesta.convidado));
      await assentar();

      expect(repositorio.papeis, isEmpty);
    });

    test('o nível que a festa já tem não chama a porta', () async {
      final (bloc, repositorio) = await carregado();

      bloc.add(const NivelEscolhido(NivelDoLink.editarLista));
      await assentar();

      expect(repositorio.niveis, isEmpty);
    });

    test('a dieta não declarada da Duda é diferente de "come de tudo"',
        () async {
      final (bloc, repositorio) = await carregado();

      bloc.add(const DietaEscolhida(ChaveDePessoa('Duda', 0), Dieta.tudo));
      await assentar();

      expect(
        repositorio.dietas,
        [(_idDoBloc, const ChaveDePessoa('Duda', 0), Dieta.tudo)],
        reason: 'não declarado não é `tudo` (A-08): declarar é uma mudança',
      );
    });
  });

  group('Não se escreve no escuro', () {
    test('com a tela ainda carregando, nenhuma das quatro escreve', () async {
      final repositorio = repositorioCom(galeraDeTeste());
      final bloc = blocCom(repositorio);

      bloc
        ..add(const DietaEscolhida(_bia, Dieta.veggie))
        ..add(const BebidaAlternada(_bia, true))
        ..add(const PapelEscolhido(_bia, PapelNaFesta.coAnfitriao))
        ..add(const NivelEscolhido(NivelDoLink.coAnfitriao));
      await assentar();

      expect(repositorio.escritas, 0);
    });

    test('com a situação em falhou, nenhuma das quatro escreve', () async {
      final (bloc, repositorio) = await carregado();
      repositorio.falhar('porta caiu', StackTrace.empty);
      await assentar();
      expect(bloc.state.situacao, SituacaoDaGalera.falhou);

      bloc
        ..add(const DietaEscolhida(_bia, Dieta.veggie))
        ..add(const BebidaAlternada(_bia, true))
        ..add(const PapelEscolhido(_bia, PapelNaFesta.coAnfitriao))
        ..add(const NivelEscolhido(NivelDoLink.coAnfitriao));
      await assentar();

      expect(repositorio.escritas, 0);
    });

    test('a chave que não endereça ninguém não escreve', () async {
      final (bloc, repositorio) = await carregado();

      bloc
        ..add(const DietaEscolhida(_fantasma, Dieta.veggie))
        ..add(const BebidaAlternada(_fantasma, true))
        ..add(const PapelEscolhido(_fantasma, PapelNaFesta.coAnfitriao));
      await assentar();

      expect(repositorio.escritas, 0);
    });
  });

  group('A porta falha: registra e não muda nada', () {
    test('a falha vai para o logger com o name da feature', () async {
      final (bloc, repositorio) = await carregado();
      repositorio.erroDeEscrita = 'gravação recusada';

      bloc.add(const DietaEscolhida(_bia, Dieta.veggie));
      await assentar();

      expect(logger.erros, hasLength(1));
      expect(logger.erros.single.error, 'gravação recusada');
      expect(logger.erros.single.name, 'galera');
    });

    test('o estado fica **idêntico** ao de antes da escrita', () async {
      final (bloc, repositorio) = await carregado();
      repositorio.erroDeEscrita = 'gravação recusada';
      final antes = bloc.state;

      bloc.add(const DietaEscolhida(_bia, Dieta.veggie));
      await assentar();

      expect(bloc.state, antes);
      expect(bloc.state.situacao, SituacaoDaGalera.comFesta);
    });

    test('a falha de uma escrita não impede a seguinte', () async {
      final (bloc, repositorio) = await carregado();
      repositorio.erroDeEscrita = 'gravação recusada';
      bloc.add(const DietaEscolhida(_bia, Dieta.veggie));
      await assentar();

      repositorio.erroDeEscrita = null;
      bloc.add(const BebidaAlternada(_bia, true));
      await assentar();

      expect(repositorio.bebidas, [(_idDoBloc, _bia, true)]);
      expect(logger.erros, hasLength(1));
    });
  });

  group('GAL-15 AC11 — nenhuma fórmula desceu para o bloc', () {
    test('o código do bloc não tem operador de fórmula', () {
      expect(formulaEm(File(_arquivo).readAsStringSync()), isEmpty);
    });

    test('a varredura morde: um trecho infrator sintético é acusado', () {
      expect(
        formulaEm('final gramas = pessoas * 0.4 / horas;'),
        containsAll(_operadoresDeFormula),
      );
    });
  });
}
