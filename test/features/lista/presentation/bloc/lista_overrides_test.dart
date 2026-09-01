import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/lista/presentation/bloc/lista_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/festa_em_edicao_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';

const String _festaId = 'festa-1';

const String _arquivoDoBloc =
    'lib/features/lista/presentation/bloc/lista_bloc.dart';

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
FestaEmEdicao _rn30({Map<ChaveItem, OverrideDeItem> overrides = const {}}) =>
    FestaEmEdicao(
      festa: _festaRn30,
      composicao: ComposicaoDaFesta(
        contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
        duracaoHoras: 4,
        itensSelecionados: _chipsPadrao,
        overrides: overrides,
      ),
    );

/// Espera o bloc processar os eventos pendentes da fila.
Future<void> _assentar() => Future<void>.delayed(Duration.zero);

/// O item de [chave] na lista calculada.
ItemDeLista _itemDe(ListaState estado, ChaveItem chave) =>
    estado.resultado!.itens.firstWhere((item) => item.chave == chave);

/// O essencial de [chave] — ele mora em `todosOsItens`, nunca em `itens`.
ItemDeLista _essencialDe(ListaState estado, ChaveItem chave) =>
    estado.resultado!.todosOsItens.firstWhere((item) => item.chave == chave);

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

  Future<ListaBloc> blocPronto() async {
    final bloc = blocDaFesta();
    await _assentar();
    return bloc;
  }

  group('LIST-11 — o stepper de quantidade (RN-12)', () {
    for (final chave in [ChaveItem.bovina, ChaveItem.cerveja, ChaveItem.paoDeAlho]) {
      test('o passo de ${chave.name} é o do catálogo', () async {
        final bloc = await blocPronto();
        final antes = _itemDe(bloc.state, chave);

        bloc.add(QuantidadeAjustada(chave, 1));
        await _assentar();

        final depois = _itemDe(bloc.state, chave);
        expect(
          depois.quantidade,
          closeTo(comPassoDeQuantidade(antes, 1).quantidade, 1e-9),
        );
        expect(
          depois.quantidade - antes.quantidade,
          closeTo(catalogoDeItens[chave]!.passoDeQuantidade, 1e-9),
        );
      });
    }

    test('o piso é um passo, e o decremento no piso fica inerte', () async {
      final bloc = await blocPronto();
      final passo = catalogoDeItens[ChaveItem.bovina]!.passoDeQuantidade;

      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, -100));
      await _assentar();

      expect(_itemDe(bloc.state, ChaveItem.bovina).quantidade, closeTo(passo, 1e-9));

      final noPiso = bloc.state;
      final gravacoes = festas.salvas.length;
      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, -1));
      await _assentar();

      expect(_itemDe(bloc.state, ChaveItem.bovina).quantidade, closeTo(passo, 1e-9));
      expect(bloc.state, noPiso);
      expect(festas.salvas, hasLength(gravacoes));
    });
  });

  group('LIST-11 — o stepper de preço (RN-12)', () {
    test('um passo de preço vale R\$ 1', () async {
      final bloc = await blocPronto();
      final antes = _itemDe(bloc.state, ChaveItem.bovina);

      bloc.add(const PrecoAjustado(ChaveItem.bovina, 1));
      await _assentar();

      final depois = _itemDe(bloc.state, ChaveItem.bovina);
      expect(depois.preco, closeTo(comPassoDePreco(antes, 1).preco, 1e-9));
      expect(depois.preco - antes.preco, closeTo(1, 1e-9));
    });

    test('o piso do preço é R\$ 1, e o decremento no piso fica inerte',
        () async {
      final bloc = await blocPronto();

      bloc.add(const PrecoAjustado(ChaveItem.bovina, -1000));
      await _assentar();

      expect(_itemDe(bloc.state, ChaveItem.bovina).preco, closeTo(1, 1e-9));

      final noPiso = bloc.state;
      final gravacoes = festas.salvas.length;
      bloc.add(const PrecoAjustado(ChaveItem.bovina, -1));
      await _assentar();

      expect(_itemDe(bloc.state, ChaveItem.bovina).preco, closeTo(1, 1e-9));
      expect(bloc.state, noPiso);
      expect(festas.salvas, hasLength(gravacoes));
    });
  });

  group('RN-10 — os essenciais não recebem override', () {
    // A defesa mora em `_itemAjustavel`, que percorre `resultado.itens` e não
    // `todosOsItens`: a calculadora reconstrói os quatro essenciais a cada
    // cálculo por `essenciaisAutomaticos()` e nunca lhes aplica override, então
    // guardar um seria gravar na composição um ajuste que a tela nunca mostra.
    // O efeito é invisível na tela — `temOverrides` deriva de `item.editado`,
    // e o essencial reconstruído nunca fica `editado` —, e por isso o sensor
    // tem de ser aqui: o que discrimina é a **composição gravada**.
    for (final chave in [ChaveItem.carvao, ChaveItem.coposEPratos]) {
      test('ajustar ${chave.name} não grava override nem toca a porta',
          () async {
        final bloc = await blocPronto();
        final antes = bloc.state;
        final quantidade = _essencialDe(bloc.state, chave).quantidade;

        bloc.add(QuantidadeAjustada(chave, 1));
        bloc.add(PrecoAjustado(chave, 1));
        await _assentar();

        expect(bloc.state.festa!.composicao.overrides, isEmpty);
        expect(
          festas.salvas,
          isEmpty,
          reason: 'sem override não há mudança, e sem mudança não há gravação',
        );
        expect(
          _essencialDe(bloc.state, chave).quantidade,
          closeTo(quantidade, 1e-9),
        );
        expect(_essencialDe(bloc.state, chave).editado, isFalse);
        expect(bloc.state, antes);
      });
    }
  });

  group('LIST-13 — o recálculo ao vivo (UC-04)', () {
    test('um ajuste move linha, total, por adulto e faixa na mesma emissão',
        () async {
      final bloc = await blocPronto();
      final antes = bloc.state;
      final linhaAntes = _itemDe(antes, ChaveItem.frango);
      final emitidos = <ListaState>[];
      final inscricao = bloc.stream.listen(emitidos.add);

      // O frango não tem linha em RN-11, então o próprio valor dele entra nas
      // duas pontas da faixa — é o ajuste que **move** a faixa real (A-03).
      bloc.add(const PrecoAjustado(ChaveItem.frango, 1));
      await _assentar();
      await inscricao.cancel();

      expect(emitidos, hasLength(1));
      final depois = emitidos.single;
      expect(
        _itemDe(depois, ChaveItem.frango).valor,
        greaterThan(linhaAntes.valor),
      );
      expect(
        depois.resultado!.totalDosItens,
        greaterThan(antes.resultado!.totalDosItens),
      );
      expect(
        depois.resultado!.totalComEssenciais,
        greaterThan(antes.resultado!.totalComEssenciais),
      );
      expect(
        depois.resultado!.porAdulto,
        greaterThan(antes.resultado!.porAdulto),
      );
      expect(depois.faixaReal!.minimo, greaterThan(antes.faixaReal!.minimo));
      expect(depois.faixaReal!.maximo, greaterThan(antes.faixaReal!.maximo));
    });

    test('o bloc é o único caminho de cálculo da tela', () {
      final fonte = File(_arquivoDoBloc)
          .readAsStringSync()
          .replaceAll(RegExp('//.*'), '');

      expect(
        RegExp(r'CalculadoraDaFesta\.calcular\(').allMatches(fonte).length,
        1,
      );
      expect(RegExp(r'faixaRealDaLista\(').allMatches(fonte).length, 1);
    });
  });

  group('LIST-14 — o RESTAURAR (RN-12 · UC-06 A1)', () {
    test('sem ajuste nenhum, temOverrides é false', () async {
      final bloc = await blocPronto();

      expect(bloc.state.resultado!.temOverrides, isFalse);
    });

    test('o primeiro ajuste acende temOverrides', () async {
      final bloc = await blocPronto();

      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 1));
      await _assentar();

      expect(bloc.state.resultado!.temOverrides, isTrue);
      expect(_itemDe(bloc.state, ChaveItem.bovina).editado, isTrue);
    });

    test('RESTAURAR desfaz todos os ajustes de uma vez', () async {
      final bloc = await blocPronto();
      final original = bloc.state.resultado!.totalComEssenciais;
      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 2));
      bloc.add(const PrecoAjustado(ChaveItem.cerveja, 3));
      await _assentar();
      expect(bloc.state.festa!.composicao.overrides, hasLength(2));

      bloc.add(const OverridesRestaurados());
      await _assentar();

      expect(bloc.state.festa!.composicao.overrides, isEmpty);
      expect(bloc.state.resultado!.temOverrides, isFalse);
      expect(_itemDe(bloc.state, ChaveItem.bovina).editado, isFalse);
      expect(_itemDe(bloc.state, ChaveItem.cerveja).editado, isFalse);
      expect(
        bloc.state.resultado!.totalComEssenciais,
        closeTo(original, 1e-9),
      );
    });

    test('RESTAURAR grava a composição sem overrides na porta', () async {
      final bloc = await blocPronto();
      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 1));
      await _assentar();

      bloc.add(const OverridesRestaurados());
      await _assentar();

      expect(festas.salvas.last.$2.composicao.overrides, isEmpty);
    });

    test('RESTAURAR sem override nenhum não grava (LIST-33)', () async {
      final bloc = await blocPronto();

      bloc.add(const OverridesRestaurados());
      await _assentar();

      expect(festas.salvas, isEmpty);
    });
  });

  group('LIST-15 — o override sobrevive à navegação', () {
    test('cada passo grava na porta, e a última gravação é a mais nova',
        () async {
      final bloc = await blocPronto();

      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 1));
      await _assentar();
      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 1));
      await _assentar();
      bloc.add(const PrecoAjustado(ChaveItem.cerveja, 1));
      await _assentar();

      expect(festas.salvas, hasLength(3));
      expect(festas.salvas.map((gravacao) => gravacao.$1), [
        _festaId,
        _festaId,
        _festaId,
      ]);
      expect(
        festas.salvas.last.$2.composicao.overrides.keys,
        containsAll([ChaveItem.bovina, ChaveItem.cerveja]),
      );
    });

    test('um bloc novo sobre a mesma porta acha os overrides aplicados',
        () async {
      final primeiro = await blocPronto();
      primeiro.add(const QuantidadeAjustada(ChaveItem.bovina, 2));
      await _assentar();
      final ajustada = _itemDe(primeiro.state, ChaveItem.bovina).quantidade;
      await primeiro.close();

      final segundo = ListaBloc(festas, logger, festaId: _festaId);
      addTearDown(segundo.close);
      await _assentar();

      expect(
        _itemDe(segundo.state, ChaveItem.bovina).quantidade,
        closeTo(ajustada, 1e-9),
      );
      expect(segundo.state.resultado!.temOverrides, isTrue);
    });
  });

  group('LIST-32 — a gravação que falha', () {
    test('loga em nome de lista, acende o aviso e não reverte a tela',
        () async {
      final bloc = await blocPronto();
      festas.erroDeGravacao = StateError('porta caiu');

      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 1));
      await _assentar();
      await _assentar();

      expect(logger.erros, hasLength(1));
      expect(logger.erros.single.name, 'lista');
      expect(bloc.state.falhouAoSalvar, isTrue);
      expect(bloc.state.resultado!.temOverrides, isTrue);
      expect(_itemDe(bloc.state, ChaveItem.bovina).editado, isTrue);
    });
  });
}
