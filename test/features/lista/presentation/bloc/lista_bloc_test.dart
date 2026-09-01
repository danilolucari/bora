import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/lista/presentation/bloc/lista_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/festa_em_edicao_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';

const String _festaId = 'festa-1';

/// Os sete chips do estado padrão de RN-30.
const Set<ChaveItem> _chipsPadrao = {
  ChaveItem.bovina,
  ChaveItem.frango,
  ChaveItem.paoDeAlho,
  ChaveItem.refrigerante,
  ChaveItem.agua,
  ChaveItem.cerveja,
  ChaveItem.cachaca,
};

const Festa _festaRn30 = Festa(
  nome: 'CHURRAS DO RAFA 🔥',
  data: 'SÁB 18 JUL',
  hora: '14H',
  local: 'Laje do Rafa — Vila Madalena',
  duracaoHoras: 4,
);

/// O estado padrão de RN-30: 3H + 3M + 1C, 4h e os sete chips.
FestaEmEdicao _rn30({
  ContagemDePessoas? contagem,
  Map<ChaveItem, OverrideDeItem> overrides = const {},
}) =>
    FestaEmEdicao(
      festa: _festaRn30,
      composicao: ComposicaoDaFesta(
        contagem:
            contagem ?? ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
        duracaoHoras: 4,
        itensSelecionados: _chipsPadrao,
        overrides: overrides,
      ),
    );

/// Espera o bloc processar os eventos pendentes da fila.
Future<void> _assentar() => Future<void>.delayed(Duration.zero);

void main() {
  late FestaEmEdicaoRepositoryFake festas;
  late RecordingAppLogger logger;

  setUp(() {
    festas = FestaEmEdicaoRepositoryFake(festas: {_festaId: _rn30()});
    logger = RecordingAppLogger();
  });

  tearDown(() => festas.dispose());

  ListaBloc blocDaFesta() {
    final bloc = ListaBloc(festas, logger, festaId: _festaId);
    addTearDown(bloc.close);
    return bloc;
  }

  group('LIST-31 — o ciclo de vida do bloc', () {
    test('abre carregando, sem resultado, em PLANEJAR', () {
      final bloc = blocDaFesta();

      expect(bloc.state.carregando, isTrue);
      expect(bloc.state.resultado, isNull);
      expect(bloc.state.modo, ModoDaLista.planejar);
      expect(bloc.state.chaveExpandida, isNull);
    });

    test('a primeira emissão traz a lista calculada de RN-30', () async {
      final bloc = blocDaFesta();
      await _assentar();

      expect(bloc.state.carregando, isFalse);
      expect(bloc.state.festa, _rn30());
      expect(bloc.state.resultado!.totalComEssenciais, closeTo(270.6, 1e-9));
      expect(bloc.state.resultado!.porAdulto, closeTo(45.1, 1e-9));
      expect(bloc.state.faixaReal!.minimo, closeTo(244.6, 1e-9));
      expect(bloc.state.faixaReal!.maximo, closeTo(342.6, 1e-9));
    });

    test('a tela nunca vê resultado nulo com carregando false', () async {
      final bloc = blocDaFesta();
      final vistos = <ListaState>[];
      final inscricao = bloc.stream.listen(vistos.add);

      await _assentar();
      bloc.add(const ModoAlternado(ModoDaLista.comprar));
      bloc.add(const ItemExpandido(ChaveItem.bovina));
      festas.emitir(_festaId, null);
      await _assentar();
      await inscricao.cancel();

      expect(vistos, isNotEmpty);
      for (final visto in vistos) {
        expect(
          visto.carregando || visto.resultado != null,
          isTrue,
          reason: 'estado com carregando=false e resultado nulo',
        );
      }
    });

    test('fechar o bloc cancela a inscrição na porta', () async {
      final bloc = ListaBloc(festas, logger, festaId: _festaId);
      await _assentar();
      expect(festas.ouvintes, 1);

      await bloc.close();

      expect(festas.ouvintes, 0);
    });
  });

  group('LIST-01 — o modo do segmented', () {
    test('ModoAlternado troca o modo', () async {
      final bloc = blocDaFesta();
      await _assentar();

      bloc.add(const ModoAlternado(ModoDaLista.comprar));
      await _assentar();

      expect(bloc.state.modo, ModoDaLista.comprar);
    });

    test('ModoAlternado não grava na porta', () async {
      final bloc = blocDaFesta();
      await _assentar();

      bloc.add(const ModoAlternado(ModoDaLista.comprar));
      bloc.add(const ModoAlternado(ModoDaLista.planejar));
      await _assentar();

      expect(festas.salvas, isEmpty);
      expect(festas.criadas, isEmpty);
    });

    test('trocar de modo preserva a lista calculada', () async {
      final bloc = blocDaFesta();
      await _assentar();
      final antes = bloc.state.resultado!.totalComEssenciais;

      bloc.add(const ModoAlternado(ModoDaLista.comprar));
      await _assentar();

      expect(bloc.state.resultado!.totalComEssenciais, antes);
    });
  });

  group('LIST-10 — o item expandido', () {
    test('abrir um item guarda a chave dele', () async {
      final bloc = blocDaFesta();
      await _assentar();

      bloc.add(const ItemExpandido(ChaveItem.bovina));
      await _assentar();

      expect(bloc.state.chaveExpandida, ChaveItem.bovina);
    });

    test('abrir um item fecha o anterior — é um campo, não um conjunto',
        () async {
      final bloc = blocDaFesta();
      await _assentar();

      bloc.add(const ItemExpandido(ChaveItem.bovina));
      await _assentar();
      bloc.add(const ItemExpandido(ChaveItem.cerveja));
      await _assentar();

      expect(bloc.state.chaveExpandida, ChaveItem.cerveja);
    });

    test('ItemExpandido(null) fecha o que estava aberto', () async {
      final bloc = blocDaFesta();
      await _assentar();
      bloc.add(const ItemExpandido(ChaveItem.bovina));
      await _assentar();

      bloc.add(const ItemExpandido(null));
      await _assentar();

      expect(bloc.state.chaveExpandida, isNull);
    });

    test('o item aberto sobrevive ao recálculo vindo da porta', () async {
      final bloc = blocDaFesta();
      await _assentar();
      bloc.add(const ItemExpandido(ChaveItem.bovina));
      await _assentar();

      festas.emitir(
        _festaId,
        _rn30(contagem: ContagemDePessoas(homens: 4, mulheres: 3, criancas: 1)),
      );
      await _assentar();

      expect(bloc.state.chaveExpandida, ChaveItem.bovina);
      expect(bloc.state.resultado!.contagem.adultos, 7);
    });

    test('o modo ativo sobrevive ao recálculo vindo da porta', () async {
      final bloc = blocDaFesta();
      await _assentar();
      bloc.add(const ModoAlternado(ModoDaLista.comprar));
      await _assentar();

      festas.emitir(
        _festaId,
        _rn30(contagem: ContagemDePessoas(homens: 4, mulheres: 3, criancas: 1)),
      );
      await _assentar();

      expect(bloc.state.modo, ModoDaLista.comprar);
    });
  });

  group('LIST-31 — festa inexistente e festa sem ninguém', () {
    test('festa que não existe abre vazia, com total 0 e sem faixa', () async {
      final bloc = ListaBloc(festas, logger, festaId: 'nao-existe');
      addTearDown(bloc.close);
      await _assentar();

      expect(bloc.state.carregando, isFalse);
      expect(bloc.state.festa, isNull);
      expect(bloc.state.resultado!.itens, isEmpty);
      expect(bloc.state.resultado!.essenciais, isEmpty);
      expect(bloc.state.resultado!.totalComEssenciais, 0);
      expect(bloc.state.resultado!.porAdulto, 0);
      expect(bloc.state.faixaReal, isNull);
    });

    test('festa com 0 pessoas abre vazia pelo mesmo caminho', () async {
      festas.emitir(_festaId, _rn30(contagem: ContagemDePessoas()));
      final bloc = blocDaFesta();
      await _assentar();

      expect(bloc.state.resultado!.itens, isEmpty);
      expect(bloc.state.resultado!.essenciais, isEmpty);
      expect(bloc.state.resultado!.totalComEssenciais, 0);
      expect(bloc.state.resultado!.porAdulto, 0);
      expect(bloc.state.faixaReal, isNull);
    });

    test('voltar a ter pessoas recalcula, com os essenciais de volta',
        () async {
      festas.emitir(_festaId, _rn30(contagem: ContagemDePessoas()));
      final bloc = blocDaFesta();
      await _assentar();
      expect(bloc.state.resultado!.essenciais, isEmpty);

      festas.emitir(_festaId, _rn30());
      await _assentar();

      expect(bloc.state.resultado!.essenciais, hasLength(4));
      expect(bloc.state.resultado!.totalComEssenciais, closeTo(270.6, 1e-9));
      expect(bloc.state.faixaReal!.minimo, closeTo(244.6, 1e-9));
    });
  });

  group('LIST-32 — o stream que falha', () {
    test('loga em nome de lista e mantém o último estado bom', () async {
      final bloc = blocDaFesta();
      await _assentar();
      final bom = bloc.state.resultado!.totalComEssenciais;

      festas.falharObservacao(
        _festaId,
        StateError('porta caiu'),
        StackTrace.empty,
      );
      await _assentar();

      expect(logger.erros, hasLength(1));
      expect(logger.erros.single.name, 'lista');
      expect(logger.erros.single.error, isA<StateError>());
      expect(bloc.state.carregando, isFalse);
      expect(bloc.state.festa, _rn30());
      expect(bloc.state.resultado!.totalComEssenciais, bom);
      expect(bloc.state.faixaReal!.minimo, closeTo(244.6, 1e-9));
    });

    test('a falha do stream não acende falhouAoSalvar', () async {
      final bloc = blocDaFesta();
      await _assentar();

      festas.falharObservacao(
        _festaId,
        StateError('porta caiu'),
        StackTrace.empty,
      );
      await _assentar();

      expect(bloc.state.falhouAoSalvar, isFalse);
    });
  });

  group('LIST-10 — a igualdade do estado', () {
    test('dois estados com os mesmos campos são iguais', () {
      final a = ListaState(carregando: false, festa: _rn30());
      final b = ListaState(carregando: false, festa: _rn30());

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('modo, item expandido, festa e falha diferenciam o estado', () {
      final base = ListaState(carregando: false, festa: _rn30());

      expect(base, isNot(base.copyWith(modo: ModoDaLista.comprar)));
      expect(base, isNot(base.copyWith(chaveExpandida: ChaveItem.bovina)));
      expect(base, isNot(base.copyWith(falhouAoSalvar: true)));
      expect(
        base,
        isNot(
          base.copyWith(festa: _rn30(contagem: ContagemDePessoas(homens: 1))),
        ),
      );
      expect(base, isNot(const ListaState()));
    });
  });
}
