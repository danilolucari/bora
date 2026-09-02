import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/galera/domain/chave_de_pessoa.dart';
import 'package:bora/features/galera/domain/galera_da_festa.dart';
import 'package:bora/features/galera/presentation/bloc/galera_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/galera_de_teste.dart';
import '../../../../support/galera_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';

const String _arquivo =
    'lib/features/galera/presentation/bloc/galera_bloc.dart';

/// Um id **distinto do default** do helper: com `festa-1` dos dois lados, um
/// bloc que ignorasse o parâmetro e assinasse um id fixo passaria igual.
const String _outroId = 'festa-42';

/// Identificadores de navegação que não podem aparecer no bloc — AD-020.
const List<String> _identificadoresDeNavegacao = [
  'go_router',
  'GoRouter',
  'Navigator',
  'context.go',
];

/// A fonte sem os comentários de doc — é o **código** que se afirma aqui, não
/// a prosa que o descreve. Sem esta poda, o próprio doc que promete "quem
/// navega é a página" faria a varredura acusar o arquivo que ela protege.
String semDocumentacao(String fonte) => fonte
    .split('\n')
    .where((linha) => !linha.trimLeft().startsWith('///'))
    .join('\n');

/// Os identificadores de navegação presentes no **código** de [fonte].
List<String> navegacaoEm(String fonte) {
  final codigo = semDocumentacao(fonte);
  return [
    for (final proibido in _identificadoresDeNavegacao)
      if (codigo.contains(proibido)) proibido,
  ];
}

/// Espera o bloc processar as emissões pendentes do stream.
///
/// Dois turnos, e não um: os handlers de escrita desta feature são `async`, e
/// com um turno só a asserção correria antes de a porta ter sido chamada.
Future<void> assentar() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  late RecordingAppLogger logger;

  setUp(() => logger = RecordingAppLogger());

  GaleraRepositoryFake repositorioCom(GaleraDaFesta? inicial) {
    final repositorio = GaleraRepositoryFake(inicial: inicial);
    addTearDown(repositorio.dispose);
    return repositorio;
  }

  GaleraBloc blocCom(
    GaleraRepositoryFake repositorio, {
    String festaId = idDaFestaDeTeste,
  }) {
    final bloc = GaleraBloc(festaId, repositorio, logger);
    addTearDown(() async {
      if (!bloc.isClosed) await bloc.close();
    });
    return bloc;
  }

  group('GAL-25 — a Galera nasce lendo o stream, sem ninguém mandar', () {
    test('o estado inicial é carregando, e vazio', () {
      final bloc = blocCom(repositorioCom(galeraDeTeste()));

      expect(bloc.state.situacao, SituacaoDaGalera.carregando);
      expect(bloc.state.galera, isNull);
      expect(bloc.state.aberta, isNull);
      expect(bloc.state.copiasConcluidas, 0);
    });

    test('assina a festa que recebeu, e não uma qualquer', () {
      final repositorio = repositorioCom(galeraDeTeste());

      blocCom(repositorio, festaId: _outroId);

      expect(repositorio.observados, [_outroId]);
    });

    test('a galera chega sem evento nenhum da tela', () async {
      final galera = galeraDeTeste();
      final bloc = blocCom(repositorioCom(galera));

      await assentar();

      expect(bloc.state.situacao, SituacaoDaGalera.comFesta);
      expect(bloc.state.galera, galera);
    });

    test('a emissão seguinte substitui a anterior no estado', () async {
      final repositorio = repositorioCom(galeraDeTeste());
      final bloc = blocCom(repositorio);
      await assentar();

      final depois = galeraDeTeste(
        pessoas: [...pessoasDaGalera(bloc), pessoaDeTeste('Zeca')],
      );
      repositorio.emitir(depois);
      await assentar();

      expect(bloc.state.galera, depois);
      expect(bloc.state.galera!.pessoas.last.nome, 'Zeca');
    });
  });

  group('GAL-25 — o stream falha e a tela não fica branca', () {
    test('a situação passa a falhou', () async {
      final repositorio = repositorioCom(galeraDeTeste());
      final bloc = blocCom(repositorio);
      await assentar();

      repositorio.falhar('porta caiu', StackTrace.empty);
      await assentar();

      expect(bloc.state.situacao, SituacaoDaGalera.falhou);
    });

    test('a falha é registrada no logger com o name da feature', () async {
      final repositorio = repositorioCom(galeraDeTeste());
      blocCom(repositorio);
      await assentar();
      final stack = StackTrace.current;

      repositorio.falhar('porta caiu', stack);
      await assentar();

      expect(logger.erros, hasLength(1));
      expect(logger.erros.single.error, 'porta caiu');
      expect(logger.erros.single.stackTrace, stack);
      expect(logger.erros.single.name, 'galera');
    });

    test('o que já havia chegado continua no estado', () async {
      final galera = galeraDeTeste();
      final repositorio = repositorioCom(galera);
      final bloc = blocCom(repositorio);
      await assentar();

      repositorio.falhar('porta caiu', StackTrace.empty);
      await assentar();

      expect(
        bloc.state.galera,
        galera,
        reason: 'zerar apagaria o card do link e o CTA, que design.md §10 '
            'promete que permanecem',
      );
    });
  });

  group('GAL-25 — festa inexistente cai no mesmo falhou (SPEC_PRECISION_GAP)',
      () {
    test('o null do stream leva a situação a falhou', () async {
      final bloc = blocCom(repositorioCom(null));

      await assentar();

      expect(bloc.state.situacao, SituacaoDaGalera.falhou);
    });

    test('o null do stream não registra erro nenhum no logger', () async {
      blocCom(repositorioCom(null));

      await assentar();

      expect(
        logger.erros,
        isEmpty,
        reason: 'ausência de dado não é exceção; poluir o log de erro '
            'apagaria o sinal da falha de verdade',
      );
    });

    test('o null que chega depois preserva a galera que já estava', () async {
      final galera = galeraDeTeste();
      final repositorio = repositorioCom(galera);
      final bloc = blocCom(repositorio);
      await assentar();

      repositorio.emitir(null);
      await assentar();

      expect(bloc.state.situacao, SituacaoDaGalera.falhou);
      expect(bloc.state.galera, galera);
    });
  });

  group('GAL-25 — close solta o stream', () {
    test('depois do close não sobra assinante', () async {
      final repositorio = repositorioCom(galeraDeTeste());
      final bloc = blocCom(repositorio);
      await assentar();
      expect(repositorio.ouvintes, 1);

      await bloc.close();

      expect(repositorio.ouvintes, 0);
    });

    test('emissão depois do close não vira add em bloc fechado', () async {
      final galera = galeraDeTeste();
      final repositorio = repositorioCom(galera);
      final bloc = blocCom(repositorio);
      await assentar();
      await bloc.close();

      repositorio.emitir(galeraDeTeste(pessoas: [pessoaDeTeste('Zeca')]));
      await assentar();

      expect(bloc.state.galera, galera);
    });
  });

  group('GAL-26 — o estado é valor: emissão idêntica não reconstrói a tela',
      () {
    test('dois estados de campos iguais são iguais, e batem o hashCode', () {
      final galera = galeraDeTeste();
      const aberta = ChaveDePessoa('Bia', 0);

      final a = GaleraState(
        situacao: SituacaoDaGalera.comFesta,
        galera: galera,
        aberta: aberta,
        copiasConcluidas: 7,
      );
      final b = GaleraState(
        situacao: SituacaoDaGalera.comFesta,
        galera: galeraDeTeste(),
        aberta: const ChaveDePessoa('Bia', 0),
        copiasConcluidas: 7,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('trocar a situação separa', () {
      final base = GaleraState(
        situacao: SituacaoDaGalera.comFesta,
        galera: galeraDeTeste(),
      );

      expect(base, isNot(base.copyWith(situacao: SituacaoDaGalera.falhou)));
    });

    test('trocar a galera separa', () {
      final base = GaleraState(
        situacao: SituacaoDaGalera.comFesta,
        galera: galeraDeTeste(),
      );

      final outra = base.copyWith(
        galera: galeraDeTeste(pessoas: [pessoaDeTeste('Zeca')]),
      );

      expect(base, isNot(outra));
    });

    test('trocar a pessoa aberta separa — inclusive entre homônimas', () {
      final base = GaleraState(
        situacao: SituacaoDaGalera.comFesta,
        galera: galeraDeTeste(),
        aberta: const ChaveDePessoa('Ana', 0),
      );

      expect(base, isNot(base.copyWith(aberta: const ChaveDePessoa('Ana', 1))));
    });

    test('trocar o contador de cópias separa', () {
      const base = GaleraState(copiasConcluidas: 3);

      expect(base, isNot(base.copyWith(copiasConcluidas: 7)));
    });
  });

  group('AD-020 — o bloc não navega', () {
    test('a fonte do bloc não menciona navegação', () {
      expect(navegacaoEm(File(_arquivo).readAsStringSync()), isEmpty);
    });

    test('a varredura morde: um trecho infrator sintético é acusado', () {
      expect(
        navegacaoEm("import 'package:go_router/go_router.dart';"),
        contains('go_router'),
      );
    });
  });
}

/// As pessoas que estão no estado do bloc agora — açúcar de leitura para os
/// testes que precisam montar a emissão seguinte a partir da atual.
List<Pessoa> pessoasDaGalera(GaleraBloc bloc) => bloc.state.galera!.pessoas;
