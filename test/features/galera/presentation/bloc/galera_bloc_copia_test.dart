import 'dart:io';

import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/domain/galera_da_festa.dart';
import 'package:bora/features/galera/presentation/bloc/galera_bloc.dart';
import 'package:bora/features/galera/presentation/galera_textos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/rn30_estado_inicial_tipado.dart';
import '../../../../support/area_de_transferencia_falsa.dart';
import '../../../../support/galera_de_teste.dart';
import '../../../../support/galera_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';
import 'galera_bloc_test.dart' show assentar;

const String _arquivoDeEventos =
    'lib/features/galera/presentation/bloc/galera_event.dart';

/// Um código **distinto do `rafa18` da fixture**: é ele que separa "montou a
/// URL da festa corrente" de "devolveu uma URL fixa que por acaso confere com
/// a fixture" (L-031).
const String _outroCodigo = 'zeca99';

final RegExp _classeDeEvento =
    RegExp(r'^class (\w+) extends GaleraEvent', multiLine: true);

/// Os eventos declarados em [fonte] cujo nome fala de cópia.
List<String> eventosDeCopiaEm(String fonte) => _classeDeEvento
    .allMatches(fonte)
    .map((m) => m.group(1)!)
    .where((nome) => nome.contains('Copiad'))
    .toList();

void main() {
  late RecordingAppLogger logger;
  late AreaDeTransferenciaFalsa area;

  setUp(() {
    logger = RecordingAppLogger();
    area = AreaDeTransferenciaFalsa();
  });

  GaleraRepositoryFake repositorioCom(GaleraDaFesta? inicial) {
    final repositorio = GaleraRepositoryFake(inicial: inicial);
    addTearDown(repositorio.dispose);
    return repositorio;
  }

  GaleraBloc blocCom(GaleraRepositoryFake repositorio) {
    final bloc = GaleraBloc(idDaFestaDeTeste, repositorio, area, logger);
    addTearDown(() async {
      if (!bloc.isClosed) await bloc.close();
    });
    return bloc;
  }

  /// Um bloc já assentado sobre a leitura — a tela carregada.
  Future<GaleraBloc> carregado([GaleraDaFesta? galera]) async {
    final bloc = blocCom(repositorioCom(galera ?? galeraDeTeste()));
    await assentar();
    return bloc;
  }

  group('GAL-03 — copiar escreve a URL da festa corrente', () {
    test('a URL escrita é a do código da festa', () async {
      final bloc = await carregado();

      bloc.add(const LinkCopiado());
      await assentar();

      expect(
        area.copiados,
        [GaleraTextos.urlDoConvite(conviteRn30Tipado.codigo)],
      );
    });

    test('outra festa, outro código: a URL acompanha o registro', () async {
      final bloc = await carregado(
        galeraDeTeste(
          convite: const ConviteDaFesta(
            codigo: _outroCodigo,
            nivel: NivelDoLink.soVer,
          ),
        ),
      );

      bloc.add(const LinkCopiado());
      await assentar();

      expect(area.copiados, [GaleraTextos.urlDoConvite(_outroCodigo)]);
      expect(
        area.copiados.single,
        isNot(GaleraTextos.urlDoConvite(conviteRn30Tipado.codigo)),
        reason: 'URL fixa passaria no teste anterior e falha aqui',
      );
    });

    test('existe um evento de cópia só — os dois botões usam o mesmo', () {
      expect(
        eventosDeCopiaEm(File(_arquivoDeEventos).readAsStringSync()),
        ['LinkCopiado'],
      );
    });
  });

  group('GAL-03 — o contador é o gatilho do toast', () {
    test('a cópia que dá certo incrementa de 1', () async {
      final bloc = await carregado();

      bloc.add(const LinkCopiado());
      await assentar();

      expect(bloc.state.copiasConcluidas, 1);
    });

    test('duas cópias seguidas levam o contador a 2', () async {
      final bloc = await carregado();

      bloc.add(const LinkCopiado());
      await assentar();
      bloc.add(const LinkCopiado());
      await assentar();

      expect(
        bloc.state.copiasConcluidas,
        2,
        reason: 'com um `bool copiou` o segundo toast não sairia',
      );
      expect(area.copiados, hasLength(2));
    });

    test('copiar não mexe na galera nem no painel aberto', () async {
      final galera = galeraDeTeste();
      final bloc = await carregado(galera);

      bloc.add(const LinkCopiado());
      await assentar();

      expect(bloc.state.galera, galera);
      expect(bloc.state.aberta, isNull);
      expect(bloc.state.situacao, SituacaoDaGalera.comFesta);
    });
  });

  group('GAL-05 — a área de transferência falha', () {
    test('o contador fica inalterado', () async {
      final bloc = await carregado();
      area.erro = 'canal indisponível';

      bloc.add(const LinkCopiado());
      await assentar();

      expect(bloc.state.copiasConcluidas, 0);
    });

    test('a falha é registrada com o name da feature', () async {
      final bloc = await carregado();
      area.erro = 'canal indisponível';

      bloc.add(const LinkCopiado());
      await assentar();

      expect(logger.erros, hasLength(1));
      expect(logger.erros.single.error, 'canal indisponível');
      expect(logger.erros.single.name, 'galera');
    });

    test('o estado fica **idêntico** — nenhum campo de erro novo', () async {
      final bloc = await carregado();
      area.erro = 'canal indisponível';
      final antes = bloc.state;

      bloc.add(const LinkCopiado());
      await assentar();

      expect(bloc.state, antes);
    });

    test('a cópia seguinte, que dá certo, leva o contador a 1', () async {
      final bloc = await carregado();
      area.erro = 'canal indisponível';
      bloc.add(const LinkCopiado());
      await assentar();

      area.erro = null;
      bloc.add(const LinkCopiado());
      await assentar();

      expect(bloc.state.copiasConcluidas, 1);
      expect(logger.erros, hasLength(1));
    });
  });

  group('Festa sem link — SPEC_PRECISION_GAP declarado', () {
    test('código vazio não copia e não incrementa', () async {
      final bloc = await carregado(
        galeraDeTeste(convite: ConviteDaFesta.vazio),
      );

      bloc.add(const LinkCopiado());
      await assentar();

      expect(area.copiados, isEmpty);
      expect(bloc.state.copiasConcluidas, 0);
    });

    test('com a tela ainda carregando não copia e não incrementa', () async {
      final bloc = blocCom(repositorioCom(galeraDeTeste()));

      bloc.add(const LinkCopiado());
      await assentar();

      expect(area.copiados, isEmpty);
      expect(bloc.state.copiasConcluidas, 0);
    });
  });
}
