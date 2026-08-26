import 'dart:async';

import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/festa_repository.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:bora/features/home/presentation/bloc/home_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/festas_da_home.dart';
import '../../../../support/recording_app_logger.dart';

/// A festa de RN-30 com um confirmado a mais — o RSVP de RN-28.
ResumoDeFesta get _rn30DepoisDoRsvp => ResumoDeFesta(
      festa: rn30NaHome.festa,
      confirmados: rn30NaHome.confirmados + 1,
      pendentes: rn30NaHome.pendentes - 1,
      iniciais: rn30NaHome.iniciais,
    );

/// Um repositório cujo stream só sabe falhar (HOME-16).
class _RepositorioQueFalha implements FestaRepository {
  final _controlador = StreamController<List<ResumoDeFesta>>();

  @override
  Stream<List<ResumoDeFesta>> observarFestas() => _controlador.stream;

  void falhar(Object erro) => _controlador.addError(erro, StackTrace.current);

  @override
  Future<void> dispose() => _controlador.close();
}

/// Espera o bloc processar as emissões pendentes do stream.
Future<void> _assentar() => Future<void>.delayed(Duration.zero);

void main() {
  late RecordingAppLogger logger;

  setUp(() => logger = RecordingAppLogger());

  HomeBloc blocCom(FestaRepository repositorio) {
    final bloc = HomeBloc(repositorio, logger);
    addTearDown(bloc.close);
    return bloc;
  }

  FestaRepositoryEmMemoria repositorioCom(List<ResumoDeFesta> festas) {
    final repositorio = FestaRepositoryEmMemoria(inicial: festas);
    addTearDown(repositorio.dispose);
    return repositorio;
  }

  group('HOME-19 — a Home nasce lendo o stream, sem ninguém mandar', () {
    test('o estado inicial é carregando', () {
      expect(
        blocCom(repositorioCom(festasDaHome)).state.situacao,
        SituacaoDaHome.carregando,
      );
    });

    test('a semente chega sem evento nenhum da tela', () async {
      final bloc = blocCom(repositorioCom(festasDaHome));

      await _assentar();

      expect(bloc.state.situacao, SituacaoDaHome.comFestas);
    });

    test('separa o que está chegando do que já passou', () async {
      final bloc = blocCom(repositorioCom(festasDaHome));

      await _assentar();

      expect(bloc.state.chegando, [rn30NaHome]);
      expect(bloc.state.passadas, festasPassadas);
      expect(
        bloc.state.passadas.every((f) => f.ehPassada),
        isTrue,
        reason: 'HOME-14: o ARQUIVO é só festa concluída',
      );
    });
  });

  group('HOME-15 — lista vazia é estado, não erro', () {
    test('sem festa nenhuma, a situação é vazia', () async {
      final bloc = blocCom(repositorioCom(const []));

      await _assentar();

      expect(bloc.state.situacao, SituacaoDaHome.vazia);
      expect(bloc.state.chegando, isEmpty);
      expect(bloc.state.passadas, isEmpty);
    });

    test('só festa passada ainda é comFestas, com chegando vazio', () async {
      final bloc = blocCom(repositorioCom(festasPassadas));

      await _assentar();

      expect(
        bloc.state.situacao,
        SituacaoDaHome.comFestas,
        reason: 'HOME-15 AC4: quem tem passada e nenhuma chegando ainda tem o '
            'que mostrar no subtítulo e no arquivo',
      );
      expect(bloc.state.chegando, isEmpty);
      expect(bloc.state.passadas, hasLength(2));
    });
  });

  group('HOME-09/HOME-10 — a confirmação de RN-28 chega pelo stream', () {
    test('a emissão nova troca os contadores sem a tela pedir', () async {
      final repositorio = repositorioCom(festasDaHome);
      final bloc = blocCom(repositorio);
      await _assentar();

      expect(bloc.state.chegando.single.confirmados, 4);
      expect(bloc.state.chegando.single.pendentes, 2);

      repositorio.emitir([_rn30DepoisDoRsvp, ...festasPassadas]);
      await _assentar();

      expect(bloc.state.chegando.single.confirmados, 5);
      expect(bloc.state.chegando.single.pendentes, 1);
    });

    test('D-1: a primeira emissão nunca acusa confirmação nova', () async {
      final bloc = blocCom(repositorioCom(festasDaHome));

      await _assentar();

      expect(
        bloc.state.temConfirmacaoNova(rn30NaHome),
        isFalse,
        reason: 'a Home abriria com o atalho do acerto aceso sem que nada '
            'tivesse acontecido',
      );
    });

    test('D-1: um confirmado a mais acusa confirmação nova', () async {
      final repositorio = repositorioCom(festasDaHome);
      final bloc = blocCom(repositorio);
      await _assentar();

      repositorio.emitir([_rn30DepoisDoRsvp, ...festasPassadas]);
      await _assentar();

      expect(bloc.state.temConfirmacaoNova(_rn30DepoisDoRsvp), isTrue);
    });

    test('D-1: emissão que não aumenta confirmados não acusa nada', () async {
      final repositorio = repositorioCom(festasDaHome);
      final bloc = blocCom(repositorio);
      await _assentar();

      repositorio.emitir(festasDaHome);
      await _assentar();

      expect(
        bloc.state.temConfirmacaoNova(rn30NaHome),
        isFalse,
        reason: 'é o par que discrimina: um flag que ligasse a cada emissão '
            'passaria no teste de cima',
      );
    });

    test('D-1: o atalho não se apaga na emissão seguinte', () async {
      final repositorio = repositorioCom(festasDaHome);
      final bloc = blocCom(repositorio);
      await _assentar();

      repositorio.emitir([_rn30DepoisDoRsvp, ...festasPassadas]);
      await _assentar();
      repositorio.emitir([_rn30DepoisDoRsvp, ...festasPassadas]);
      await _assentar();

      expect(
        bloc.state.temConfirmacaoNova(_rn30DepoisDoRsvp),
        isTrue,
        reason: 'o anfitrião não perde o caminho do acerto porque chegou '
            'outra emissão qualquer',
      );
    });
  });

  group('HOME-16 — a falha vira estado e registro, não tela em branco', () {
    test('o stream falhando leva ao estado falhou', () async {
      final repositorio = _RepositorioQueFalha();
      addTearDown(repositorio.dispose);
      final bloc = blocCom(repositorio);

      repositorio.falhar(StateError('firestore caiu'));
      await _assentar();

      expect(bloc.state.situacao, SituacaoDaHome.falhou);
    });

    test('e o erro vai para o AppLogger (AD-005)', () async {
      final repositorio = _RepositorioQueFalha();
      addTearDown(repositorio.dispose);
      blocCom(repositorio);

      repositorio.falhar(StateError('firestore caiu'));
      await _assentar();

      expect(logger.erros, hasLength(1));
      expect(logger.erros.single.error, isStateError);
      expect(logger.erros.single.stackTrace, isNotNull);
    });

    test('no caminho feliz o logger não registra erro nenhum', () async {
      blocCom(repositorioCom(festasDaHome));

      await _assentar();

      expect(
        logger.erros,
        isEmpty,
        reason: 'é o par que discrimina: um logger chamado sempre passaria no '
            'teste de cima',
      );
    });
  });

  group('a inscrição não vaza', () {
    test('fechar o bloc cancela a inscrição no repositório', () async {
      final repositorio = repositorioCom(festasDaHome);
      final bloc = HomeBloc(repositorio, logger);
      await _assentar();

      await bloc.close();
      repositorio.emitir([_rn30DepoisDoRsvp]);
      await _assentar();

      expect(
        bloc.state.chegando.single.confirmados,
        4,
        reason: 'inscrição vazada contamina o teste seguinte, e um bloc morto '
            'emitindo estado estoura em produção',
      );
    });
  });
}
