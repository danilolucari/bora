import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/montar/domain/rascunho_inicial.dart';
import 'package:bora/features/montar/presentation/bloc/montar_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/festa_em_edicao_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';

const String _arquivoDoBloc =
    'lib/features/montar/presentation/bloc/montar_bloc.dart';

const String _id = 'festa-1';

final DateTime _hoje = DateTime(2026, 7, 15);

/// Um rolê já salvo, para que as gravações do teste sejam todas `salvarFesta`.
FestaEmEdicao _festaSalva() => FestaEmEdicao(
      festa: const Festa(
        nome: 'CHURRAS DO RAFA 🔥',
        data: 'SÁB · 18 JUL',
        hora: '14H',
        local: 'Laje do Rafa — Vila Madalena',
        duracaoHoras: 4,
      ),
      composicao: ComposicaoDaFesta(
        contagem: ContagemDePessoas(),
        duracaoHoras: 4,
        itensSelecionados: const {ChaveItem.bovina},
      ),
    );

/// Roda a fila de eventos e os `Future` das gravações algumas vezes — a
/// gravação coalescida encadeia evento → future → evento.
Future<void> _assentar([int voltas = 4]) async {
  for (var i = 0; i < voltas; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late FestaEmEdicaoRepositoryFake festas;
  late RecordingAppLogger logger;

  setUp(() {
    festas = FestaEmEdicaoRepositoryFake();
    logger = RecordingAppLogger();
  });
  tearDown(() => festas.dispose());

  MontarBloc blocCom({String? festaId}) {
    final bloc = MontarBloc(
      festas,
      logger,
      inicial: rascunhoInicial(hoje: _hoje),
      festaId: festaId,
    );
    addTearDown(bloc.close);
    return bloc;
  }

  Future<MontarBloc> naFestaSalva() async {
    festas.emitir(_id, _festaSalva());
    final bloc = blocCom(festaId: _id);
    await _assentar();
    return bloc;
  }

  /// Os `homens` de cada gravação, na ordem em que elas começaram.
  List<int> homensGravados() =>
      [for (final (_, festa) in festas.salvas) festa.composicao.contagem.homens];

  group('MONT-21 — rajada de toques não produz gravação obsoleta', () {
    Future<MontarBloc> comRajadaDe(int toques) async {
      final bloc = await naFestaSalva();
      festas.travarGravacoes();

      for (var i = 0; i < toques; i++) {
        bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      }
      await _assentar();

      festas.liberarGravacoes();
      await _assentar();

      return bloc;
    }

    test('cinco mudanças em rajada dão no máximo duas gravações', () async {
      await comRajadaDe(5);

      expect(festas.salvas.length, lessThanOrEqualTo(2));
      expect(
        festas.salvas,
        hasLength(2),
        reason: 'a primeira escrita e a coalescida — cinco seriam cinco '
            'chances de uma chegar fora de ordem, e uma só seria a mudança '
            'do fim da rajada perdida',
      );
    });

    test('a última gravação carrega o estado mais novo', () async {
      final bloc = await comRajadaDe(5);

      expect(bloc.state.composicao.contagem.homens, 5);
      expect(
        festas.salvas.last.$2.composicao.contagem.homens,
        5,
        reason: 'a última escrita tem de ser a do estado final, não a de um '
            'toque do meio',
      );
    });

    test('nenhuma gravação com valor antigo chega depois de uma com valor novo',
        () async {
      await comRajadaDe(5);

      final gravados = homensGravados();

      expect(
        gravados,
        orderedEquals(List.of(gravados)..sort()),
        reason: 'uma escrita fora de ordem faz a lista voltar ao que era com '
            'o dedo ainda na tela',
      );
    });

    test('mudanças espaçadas gravam uma a uma, sem coalescer', () async {
      final bloc = await naFestaSalva();

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      await _assentar();
      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      await _assentar();

      expect(homensGravados(), [1, 2]);
    });
  });

  group('MONT-19 — a falha ao gravar não perde o estado nem trava a tela', () {
    Future<MontarBloc> depoisDeFalharGravando() async {
      final bloc = await naFestaSalva();
      festas.erroDeGravacao = Exception('sem rede');

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      await _assentar();

      return bloc;
    }

    test('o erro e o stack vão para o AppLogger, com name montar', () async {
      await depoisDeFalharGravando();

      expect(logger.erros, hasLength(1));
      expect(logger.erros.single.error, isA<Exception>());
      expect(logger.erros.single.stackTrace, isNotNull);
      expect(logger.erros.single.name, 'montar');
    });

    test('a composição e a festa da tela não são revertidas', () async {
      final bloc = await depoisDeFalharGravando();

      expect(bloc.state.composicao.contagem.homens, 1);
      expect(bloc.state.festa.nome, _festaSalva().festa.nome);
      expect(
        bloc.state.resultado.totalDosItens,
        CalculadoraDaFesta.calcular(bloc.state.composicao).totalDosItens,
      );
    });

    test('falhouAoSalvar fica true', () async {
      final bloc = await depoisDeFalharGravando();

      expect(bloc.state.falhouAoSalvar, isTrue);
    });

    test('a interação continua: a mudança seguinte recalcula', () async {
      final bloc = await depoisDeFalharGravando();

      bloc.add(const ContagemAlterada(TipoDeCabeca.mulheres, 2));
      await _assentar();

      expect(bloc.state.composicao.contagem.mulheres, 2);
      expect(bloc.state.resultado.contagem.pessoas, 3);
    });

    test('e tenta gravar de novo', () async {
      final bloc = await depoisDeFalharGravando();
      final tentativas = festas.salvas.length;

      bloc.add(const ContagemAlterada(TipoDeCabeca.mulheres, 1));
      await _assentar();

      expect(festas.salvas.length, greaterThan(tentativas));
    });

    test('falhouAoSalvar volta a false quando uma gravação conclui', () async {
      final bloc = await depoisDeFalharGravando();
      expect(bloc.state.falhouAoSalvar, isTrue);

      festas.erroDeGravacao = null;
      bloc.add(const ContagemAlterada(TipoDeCabeca.mulheres, 1));
      await _assentar();

      expect(bloc.state.falhouAoSalvar, isFalse);
    });

    test('recalcular sem gravar não apaga o aviso de falha', () async {
      final bloc = await depoisDeFalharGravando();

      bloc.add(const ContagemAlterada(TipoDeCabeca.mulheres, 1));
      await Future<void>.delayed(Duration.zero);

      expect(
        bloc.state.falhouAoSalvar,
        isTrue,
        reason: 'a falha só sai quando uma gravação conclui de verdade',
      );
    });

    test('a falha do stream de observarFesta segue o mesmo caminho', () async {
      final bloc = await naFestaSalva();

      festas.falharObservacao(_id, Exception('stream caiu'), StackTrace.current);
      await _assentar();

      expect(logger.erros, hasLength(1));
      expect(logger.erros.single.name, 'montar');
      expect(bloc.state.falhouAoSalvar, isTrue);
    });

    test('e mantém o último estado bom na tela', () async {
      final bloc = await naFestaSalva();
      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 3));
      await _assentar();

      festas.falharObservacao(_id, Exception('stream caiu'), StackTrace.current);
      await _assentar();

      expect(bloc.state.composicao.contagem.homens, 3);
      expect(bloc.state.festa.nome, _festaSalva().festa.nome);
      expect(bloc.state.festaId, _id);
    });
  });

  group('MONT-23 — SALVAR ROLÊ grava e sinaliza, sem navegar', () {
    test('o pedido grava o estado corrente', () async {
      final bloc = await naFestaSalva();

      bloc.add(const SalvarPedido());
      await _assentar();

      expect(festas.salvas, hasLength(1));
      expect(festas.salvas.single.$1, _id);
    });

    test('o sucesso é sinalizado no estado', () async {
      final bloc = await naFestaSalva();
      expect(bloc.state.salvamentos, 0);

      bloc.add(const SalvarPedido());
      await _assentar();

      expect(bloc.state.salvamentos, 1);
    });

    test('dois pedidos seguidos sinalizam duas vezes', () async {
      final bloc = await naFestaSalva();

      bloc.add(const SalvarPedido());
      await _assentar();
      bloc.add(const SalvarPedido());
      await _assentar();

      expect(
        bloc.state.salvamentos,
        2,
        reason: 'com um booleano, o segundo toque não teria toast',
      );
    });

    test('uma mudança comum não sinaliza salvamento', () async {
      final bloc = await naFestaSalva();

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      await _assentar();

      expect(festas.salvas, hasLength(1));
      expect(bloc.state.salvamentos, 0);
    });

    test('o pedido que falha não sinaliza sucesso', () async {
      final bloc = await naFestaSalva();
      festas.erroDeGravacao = Exception('sem rede');

      bloc.add(const SalvarPedido());
      await _assentar();

      expect(bloc.state.salvamentos, 0);
      expect(bloc.state.falhouAoSalvar, isTrue);
    });

    test('AD-020: o bloc não navega — nenhuma rota sai daqui', () {
      final fonte = File(_arquivoDoBloc)
          .readAsStringSync()
          .replaceAll(RegExp(r'//.*'), '');

      expect(fonte, isNot(contains('context.go')));
      expect(fonte, isNot(contains('context.push')));
      expect(fonte, isNot(contains('go_router')));
    });
  });

  group('ciclo de vida — a inscrição não vaza', () {
    test('close() cancela a inscrição do repositório', () async {
      final bloc = await naFestaSalva();
      expect(festas.ouvintes, 1);

      await bloc.close();

      expect(festas.ouvintes, 0);
    });

    test('sem festaId não há inscrição para vazar', () async {
      blocCom();
      await _assentar();

      expect(festas.ouvintes, 0);
    });
  });
}
