import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/lista/domain/parceiro_de_entrega.dart';
import 'package:bora/features/lista/domain/pedido.dart';
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

/// O anfitrião de RN-30 — a pessoa marcada como `voce`.
const Pessoa _rafa = Pessoa(
  nome: 'Rafa',
  papel: PapelNaFesta.anfitriao,
  status: StatusDePresenca.confirmado,
  voce: true,
);

/// O estado padrão de RN-30: 3H + 3M + 1C, 4h e os sete chips.
FestaEmEdicao _rn30({
  ContagemDePessoas? contagem,
  List<Pessoa> pessoas = const [],
  Set<ChaveItem> noCarrinho = const {},
  List<Despesa> despesas = const [],
}) =>
    FestaEmEdicao(
      festa: _festaRn30,
      composicao: ComposicaoDaFesta(
        contagem:
            contagem ?? ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
        duracaoHoras: 4,
        pessoas: pessoas,
        itensSelecionados: _chipsPadrao,
        noCarrinho: noCarrinho,
      ),
      despesas: despesas,
    );

Pedido _pedido({
  ParceiroDeEntrega parceiro = ParceiroDeEntrega.ifood,
  double subtotal = 271,
  double frete = 12,
  double total = 283,
}) =>
    Pedido(
      parceiro: parceiro,
      endereco: 'Laje do Rafa — Vila Madalena',
      itens: const [],
      subtotal: subtotal,
      frete: frete,
      total: total,
    );

/// Espera o bloc processar os eventos pendentes da fila.
Future<void> _assentar() => Future<void>.delayed(Duration.zero);

/// O item de [chave] na lista calculada.
ItemDeLista _itemDe(ListaState estado, ChaveItem chave) =>
    estado.resultado!.todosOsItens.firstWhere((item) => item.chave == chave);

void main() {
  late FestaEmEdicaoRepositoryFake festas;
  late RecordingAppLogger logger;

  setUp(() {
    festas = FestaEmEdicaoRepositoryFake(festas: {_festaId: _rn30()});
    logger = RecordingAppLogger();
  });

  tearDown(() => festas.dispose());

  Future<ListaBloc> blocPronto({List<Pessoa> pessoas = const []}) async {
    if (pessoas.isNotEmpty) festas.emitir(_festaId, _rn30(pessoas: pessoas));

    final bloc = ListaBloc(festas, logger, festaId: _festaId);
    addTearDown(bloc.close);
    await _assentar();
    return bloc;
  }

  group('LIST-20 — o carrinho do modo COMPRAR', () {
    test('marcar um item põe a chave no conjunto e acende a linha', () async {
      final bloc = await blocPronto();

      bloc.add(const ItemAlternadoNoCarrinho(ChaveItem.bovina));
      await _assentar();

      expect(bloc.state.festa!.composicao.noCarrinho, {ChaveItem.bovina});
      expect(_itemDe(bloc.state, ChaveItem.bovina).noCarrinho, isTrue);
      expect(_itemDe(bloc.state, ChaveItem.frango).noCarrinho, isFalse);
    });

    test('marcar duas vezes volta ao estado inicial (LIST-33)', () async {
      final bloc = await blocPronto();

      bloc.add(const ItemAlternadoNoCarrinho(ChaveItem.bovina));
      await _assentar();
      bloc.add(const ItemAlternadoNoCarrinho(ChaveItem.bovina));
      await _assentar();

      expect(bloc.state.festa!.composicao.noCarrinho, isEmpty);
      expect(_itemDe(bloc.state, ChaveItem.bovina).noCarrinho, isFalse);
    });

    test('marcar um essencial de RN-10 também vale', () async {
      final bloc = await blocPronto();

      bloc.add(const ItemAlternadoNoCarrinho(ChaveItem.carvao));
      await _assentar();

      expect(_itemDe(bloc.state, ChaveItem.carvao).noCarrinho, isTrue);
    });

    test('marcar não muda o total', () async {
      final bloc = await blocPronto();
      final antes = bloc.state.resultado!.totalComEssenciais;
      final porAdulto = bloc.state.resultado!.porAdulto;

      bloc.add(const ItemAlternadoNoCarrinho(ChaveItem.bovina));
      bloc.add(const ItemAlternadoNoCarrinho(ChaveItem.cerveja));
      await _assentar();

      expect(bloc.state.resultado!.totalComEssenciais, closeTo(antes, 1e-9));
      expect(bloc.state.resultado!.porAdulto, closeTo(porAdulto, 1e-9));
    });

    test('o conjunto é gravado na porta a cada toque', () async {
      final bloc = await blocPronto();

      bloc.add(const ItemAlternadoNoCarrinho(ChaveItem.bovina));
      await _assentar();
      bloc.add(const ItemAlternadoNoCarrinho(ChaveItem.cerveja));
      await _assentar();

      expect(festas.salvas, hasLength(2));
      expect(festas.salvas.last.$2.composicao.noCarrinho, {
        ChaveItem.bovina,
        ChaveItem.cerveja,
      });
    });

    test('um bloc novo sobre a mesma porta acha os checks', () async {
      final primeiro = await blocPronto();
      primeiro.add(const ItemAlternadoNoCarrinho(ChaveItem.bovina));
      await _assentar();
      await primeiro.close();

      final segundo = ListaBloc(festas, logger, festaId: _festaId);
      addTearDown(segundo.close);
      await _assentar();

      expect(segundo.state.festa!.composicao.noCarrinho, {ChaveItem.bovina});
      expect(_itemDe(segundo.state, ChaveItem.bovina).noCarrinho, isTrue);
    });
  });

  group('LIST-27 — o pedido confirmado vira despesa (RN-20)', () {
    test('lança uma despesa com quem pagou, descrição e total', () async {
      final bloc = await blocPronto();

      bloc.add(PedidoConfirmado(_pedido()));
      await _assentar();

      expect(bloc.state.festa!.despesas, hasLength(1));
      final despesa = bloc.state.festa!.despesas.single;
      expect(despesa.quemPagou, 'VOCÊ');
      expect(despesa.descricao, 'Pedido no iFood Mercado');
      expect(despesa.valor, 283);
    });

    test('o valor é o total, não o subtotal', () async {
      final bloc = await blocPronto();

      bloc.add(PedidoConfirmado(_pedido(subtotal: 271, frete: 9, total: 280)));
      await _assentar();

      expect(bloc.state.festa!.despesas.single.valor, 280);
    });

    test('a descrição nomeia o parceiro escolhido', () async {
      final bloc = await blocPronto();

      bloc.add(PedidoConfirmado(_pedido(parceiro: ParceiroDeEntrega.ze)));
      await _assentar();

      expect(
        bloc.state.festa!.despesas.single.descricao,
        'Pedido no Zé Delivery',
      );
    });

    test('quem pagou é a pessoa marcada como voce, quando há uma', () async {
      final bloc = await blocPronto(pessoas: const [_rafa]);

      bloc.add(PedidoConfirmado(_pedido()));
      await _assentar();

      expect(bloc.state.festa!.despesas.single.quemPagou, 'Rafa');
    });

    test('a despesa é gravada na porta', () async {
      final bloc = await blocPronto();

      bloc.add(PedidoConfirmado(_pedido()));
      await _assentar();

      expect(festas.salvas.last.$2.despesas, hasLength(1));
      expect(festas.salvas.last.$2.despesas.single.valor, 283);
    });

    test('confirmar não altera checks nem overrides (A-21)', () async {
      final bloc = await blocPronto();
      bloc.add(const ItemAlternadoNoCarrinho(ChaveItem.bovina));
      bloc.add(const QuantidadeAjustada(ChaveItem.frango, 1));
      await _assentar();
      final carrinho = bloc.state.festa!.composicao.noCarrinho;
      final overrides = bloc.state.festa!.composicao.overrides;

      bloc.add(PedidoConfirmado(_pedido()));
      await _assentar();

      expect(bloc.state.festa!.composicao.noCarrinho, carrinho);
      expect(bloc.state.festa!.composicao.overrides, overrides);
      expect(bloc.state.resultado!.temOverrides, isTrue);
    });

    test('dois PedidoConfirmado do mesmo pedido criam uma despesa (LIST-33)',
        () async {
      final bloc = await blocPronto();

      bloc.add(PedidoConfirmado(_pedido()));
      bloc.add(PedidoConfirmado(_pedido()));
      await _assentar();

      expect(bloc.state.festa!.despesas, hasLength(1));
    });

    test('dois pedidos diferentes criam duas despesas, na ordem', () async {
      final bloc = await blocPronto();

      bloc.add(PedidoConfirmado(_pedido()));
      await _assentar();
      bloc.add(
        PedidoConfirmado(
          _pedido(parceiro: ParceiroDeEntrega.rappi, frete: 9, total: 280),
        ),
      );
      await _assentar();

      expect(
        bloc.state.festa!.despesas.map((despesa) => despesa.descricao).toList(),
        ['Pedido no iFood Mercado', 'Pedido no Rappi Turbo'],
      );
    });
  });

  group('LIST-34 — a supressão de eco e a concorrência', () {
    test('o eco da própria gravação é descartado', () async {
      final bloc = await blocPronto();
      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 1));
      await _assentar();
      final depois = bloc.state;

      festas.emitir(_festaId, festas.salvas.last.$2);
      await _assentar();

      expect(bloc.state, depois);
      expect(_itemDe(bloc.state, ChaveItem.bovina).editado, isTrue);
    });

    test('emissão diferente da porta é adotada', () async {
      final bloc = await blocPronto();

      festas.emitir(
        _festaId,
        _rn30(contagem: ContagemDePessoas(homens: 4, mulheres: 3, criancas: 1)),
      );
      await _assentar();

      expect(bloc.state.resultado!.contagem.adultos, 7);
    });

    test('eco atrasado no meio de uma gravação não regride o estado',
        () async {
      final bloc = await blocPronto();
      festas.travarGravacoes();

      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 1));
      await _assentar();
      final ajustada = _itemDe(bloc.state, ChaveItem.bovina).quantidade;

      // O eco atrasado da festa **anterior** ao ajuste, chegando com a
      // gravação ainda em voo.
      festas.emitir(_festaId, _rn30());
      await _assentar();

      expect(_itemDe(bloc.state, ChaveItem.bovina).editado, isTrue);
      expect(
        _itemDe(bloc.state, ChaveItem.bovina).quantidade,
        closeTo(ajustada, 1e-9),
      );
      expect(bloc.state.festa!.composicao.overrides, hasLength(1));

      festas.liberarGravacoes();
      await _assentar();
    });

    test('toques rápidos convergem no estado final correto', () async {
      final bloc = await blocPronto();
      final base = _itemDe(bloc.state, ChaveItem.bovina).quantidade;
      final passo = catalogoDeItens[ChaveItem.bovina]!.passoDeQuantidade;
      festas.travarGravacoes();

      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 1));
      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 1));
      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 1));
      await _assentar();

      expect(
        _itemDe(bloc.state, ChaveItem.bovina).quantidade,
        closeTo(base + 3 * passo, 1e-9),
      );

      festas.liberarGravacoes();
      await _assentar();

      expect(
        festas.salvas.last.$2.composicao.overrides[ChaveItem.bovina]!.quantidade,
        closeTo(base + 3 * passo, 1e-9),
      );
      expect(
        _itemDe(bloc.state, ChaveItem.bovina).quantidade,
        closeTo(base + 3 * passo, 1e-9),
      );
    });
  });

  group('LIST-32 — a gravação que falha', () {
    test('acende o aviso, loga e a interação segue', () async {
      final bloc = await blocPronto();
      final base = _itemDe(bloc.state, ChaveItem.bovina).quantidade;
      final passo = catalogoDeItens[ChaveItem.bovina]!.passoDeQuantidade;
      festas.erroDeGravacao = StateError('porta caiu');

      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 1));
      await _assentar();
      await _assentar();

      expect(bloc.state.falhouAoSalvar, isTrue);
      expect(logger.erros.single.name, 'lista');
      expect(
        _itemDe(bloc.state, ChaveItem.bovina).quantidade,
        closeTo(base + passo, 1e-9),
      );

      festas.erroDeGravacao = null;
      bloc.add(const QuantidadeAjustada(ChaveItem.bovina, 1));
      await _assentar();
      await _assentar();

      expect(
        _itemDe(bloc.state, ChaveItem.bovina).quantidade,
        closeTo(base + 2 * passo, 1e-9),
      );
      expect(festas.salvas, hasLength(2));
    });
  });
}
