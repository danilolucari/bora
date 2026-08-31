import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/montar/domain/rascunho_inicial.dart';
import 'package:bora/features/montar/presentation/bloc/montar_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/festa_em_edicao_repository_fake.dart';

const String _id = 'festa-1';

/// Uma quarta-feira qualquer: o rascunho não depende de quando o teste roda.
final DateTime _hoje = DateTime(2026, 7, 15);

/// Um rolê já salvo, **diferente do rascunho em todos os campos** — é o que
/// permite afirmar que a tela carregou o salvo e não abriu um rascunho novo.
FestaEmEdicao _festaSalva() => FestaEmEdicao(
      festa: const Festa(
        nome: 'CHURRAS DO RAFA 🔥',
        data: 'SÁB · 18 JUL',
        hora: '14H',
        local: 'Laje do Rafa — Vila Madalena',
        duracaoHoras: 6,
      ),
      composicao: ComposicaoDaFesta(
        contagem: ContagemDePessoas(homens: 2, mulheres: 1),
        duracaoHoras: 6,
        itensSelecionados: const {ChaveItem.bovina, ChaveItem.cerveja},
      ),
    );

/// Duas rodadas de fila: a mudança emite, `criarFesta` responde num
/// `Future`, e o `FestaCriada` que ele dispara é mais um evento do bloc.
Future<void> _assentar() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

void main() {
  late FestaEmEdicaoRepositoryFake festas;

  setUp(() => festas = FestaEmEdicaoRepositoryFake());
  tearDown(() => festas.dispose());

  FestaEmEdicao rascunho() => rascunhoInicial(hoje: _hoje);

  MontarBloc blocCom({String? festaId}) {
    final bloc = MontarBloc(festas, inicial: rascunho(), festaId: festaId);
    addTearDown(bloc.close);
    return bloc;
  }

  group('MONT-17 — /roles/novo abre um rascunho e não cria festa', () {
    test('o estado abre com o rascunho e sem festaId', () {
      final bloc = blocCom();

      expect(bloc.state.festaId, isNull);
      expect(bloc.state.festa.nome, nomeDefaultDoRole);
      expect(bloc.state.composicao, rascunho().composicao);
    });

    test('abrir a tela e não mexer em nada não grava rolê nenhum', () async {
      blocCom();

      await _assentar();

      expect(festas.criadas, isEmpty);
      expect(festas.salvas, isEmpty);
    });

    test('a primeira mudança chama criarFesta uma vez só', () async {
      final bloc = blocCom();

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      await _assentar();

      expect(festas.criadas, hasLength(1));
    });

    test('o rascunho gravado já vai com a mudança dentro', () async {
      final bloc = blocCom();

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      await _assentar();

      expect(festas.criadas.single.composicao.contagem.homens, 1);
    });

    test('o estado passa a carregar o festaId devolvido', () async {
      final bloc = blocCom();
      festas.proximoId = 'festa-42';

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      await _assentar();

      expect(bloc.state.festaId, 'festa-42');
    });

    test('a segunda mudança não cria outra festa — ela grava', () async {
      final bloc = blocCom();

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      await _assentar();
      bloc.add(const ContagemAlterada(TipoDeCabeca.mulheres, 1));
      await _assentar();

      expect(festas.criadas, hasLength(1));
      expect(festas.salvas, hasLength(1));
      expect(festas.salvas.single.$1, _id);
    });

    test('o que é gravado na segunda mudança traz as duas', () async {
      final bloc = blocCom();

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      await _assentar();
      bloc.add(const ContagemAlterada(TipoDeCabeca.mulheres, 1));
      await _assentar();

      final gravada = festas.salvas.single.$2;

      expect(gravada.composicao.contagem.homens, 1);
      expect(gravada.composicao.contagem.mulheres, 1);
    });

    test('a mudança de nome também basta para criar a festa', () async {
      final bloc = blocCom();

      bloc.add(const NomeAlterado('CHURRAS DA LAJE'));
      await _assentar();

      expect(festas.criadas, hasLength(1));
      expect(festas.criadas.single.festa.nome, 'CHURRAS DA LAJE');
    });
  });

  group('MONT-16 — abrir /roles/{festaId}/montar carrega o que está salvo', () {
    test('a composição é a salva, não a de um rascunho novo', () async {
      festas.emitir(_id, _festaSalva());
      final bloc = blocCom(festaId: _id);

      await _assentar();

      expect(bloc.state.composicao, _festaSalva().composicao);
      expect(
        bloc.state.composicao,
        isNot(rascunho().composicao),
        reason: 'abrir uma festa existente não pode zerar o que ela tem',
      );
    });

    test('nome, data e duração são os salvos, não os defaults', () async {
      festas.emitir(_id, _festaSalva());
      final bloc = blocCom(festaId: _id);

      await _assentar();

      expect(bloc.state.festa.nome, 'CHURRAS DO RAFA 🔥');
      expect(bloc.state.festa.data, 'SÁB · 18 JUL');
      expect(bloc.state.festa.duracaoHoras, 6);
      expect(bloc.state.festaId, _id);
    });

    test('o resultado é recalculado sobre a composição carregada', () async {
      festas.emitir(_id, _festaSalva());
      final bloc = blocCom(festaId: _id);

      await _assentar();

      expect(
        bloc.state.resultado.totalDosItens,
        CalculadoraDaFesta.calcular(_festaSalva().composicao).totalDosItens,
      );
    });

    test('festaId inexistente abre montável, como rascunho, sem quebrar',
        () async {
      final bloc = blocCom(festaId: 'nao-existe');

      await _assentar();

      expect(bloc.state.composicao, rascunho().composicao);
      expect(bloc.state.festa.nome, nomeDefaultDoRole);
      expect(
        bloc.state.festaId,
        isNull,
        reason: 'sem festa por trás, a próxima mudança tem de criar uma',
      );
    });

    test('MONT-18: a emissão do repositório com a tela aberta atualiza o '
        'estado', () async {
      festas.emitir(_id, _festaSalva());
      final bloc = blocCom(festaId: _id);
      await _assentar();

      final deFora = _festaSalva().copyWith(
        composicao: ComposicaoDaFesta(
          contagem: ContagemDePessoas(homens: 5, mulheres: 5, criancas: 2),
          duracaoHoras: 6,
          itensSelecionados: const {ChaveItem.bovina, ChaveItem.cerveja},
        ),
      );
      festas.emitir(_id, deFora);
      await _assentar();

      expect(bloc.state.composicao.contagem.homens, 5);
      expect(bloc.state.resultado.contagem.pessoas, 12);
      expect(bloc.state.festaId, _id);
    });

    test('a emissão do repositório não é regravada — sem laço de escrita',
        () async {
      festas.emitir(_id, _festaSalva());
      final bloc = blocCom(festaId: _id);
      await _assentar();

      festas.emitir(_id, _festaSalva());
      await _assentar();

      expect(bloc.state.festaId, _id);
      expect(festas.salvas, isEmpty);
      expect(festas.criadas, isEmpty);
    });
  });

  group('MONT-15 — nome e data são editáveis no header', () {
    test('o nome editado passa a ser o do estado e o gravado', () async {
      festas.emitir(_id, _festaSalva());
      final bloc = blocCom(festaId: _id);
      await _assentar();

      bloc.add(const NomeAlterado('CHURRAS DA VIRADA'));
      await _assentar();

      expect(bloc.state.festa.nome, 'CHURRAS DA VIRADA');
      expect(festas.salvas.single.$2.festa.nome, 'CHURRAS DA VIRADA');
    });

    test('P1-5 AC6: nome apagado por completo volta ao default', () async {
      final bloc = blocCom();

      bloc.add(const NomeAlterado('CHURRAS DA VIRADA'));
      await _assentar();
      bloc.add(const NomeAlterado(''));
      await _assentar();

      expect(bloc.state.festa.nome, 'CHURRAS NOVO');
      expect(bloc.state.festa.nome, nomeDefaultDoRole);
    });

    test('nome só de espaços conta como apagado por completo', () async {
      final bloc = blocCom();

      bloc.add(const NomeAlterado('   '));
      await _assentar();

      expect(bloc.state.festa.nome, nomeDefaultDoRole);
    });

    test('a data editada é normalizada para CAIXA ALTA', () async {
      final bloc = blocCom();

      bloc.add(const DataAlterada('sáb · 25 jul'));
      await _assentar();

      expect(bloc.state.festa.data, 'SÁB · 25 JUL');
      expect(festas.criadas.single.festa.data, 'SÁB · 25 JUL');
    });

    test('editar o nome não mexe na composição nem no resultado', () async {
      final bloc = blocCom();
      final antes = bloc.state.resultado.totalDosItens;

      bloc.add(const NomeAlterado('OUTRO NOME'));
      await _assentar();

      expect(bloc.state.composicao, rascunho().composicao);
      expect(bloc.state.resultado.totalDosItens, antes);
    });
  });

  group('a duração gravada não diverge entre Festa e ComposicaoDaFesta', () {
    test('o que vai para o repositório tem as duas iguais', () async {
      final bloc = blocCom();

      bloc.add(const DuracaoAlterada(10));
      await _assentar();

      final gravada = festas.criadas.single;

      expect(gravada.composicao.duracaoHoras, 10);
      expect(
        gravada.festa.duracaoHoras,
        gravada.composicao.duracaoHoras,
        reason: 'divergirem no que é gravado é a divergência que sobrevive ao '
            'recarregar a tela',
      );
    });
  });
}
