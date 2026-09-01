import 'dart:async';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/lista/domain/parceiro_de_entrega.dart';
import 'package:bora/features/lista/domain/pedido.dart';
import 'package:bora/features/lista/domain/pedido_repository.dart';
import 'package:bora/features/lista/presentation/bloc/pedido_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/pedido_falso_de_teste.dart';
import '../../../../support/recording_app_logger.dart';
import '../../support/festa_rn30.dart';

/// O local da festa de RN-30 — o endereço com que a sheet abre.
const String _enderecoDaFesta = 'Laje do Rafa — Vila Madalena';

/// Espera o bloc processar os eventos pendentes da fila.
Future<void> _assentar() => Future<void>.delayed(Duration.zero);

/// Uma porta que **não responde** até mandarem: é o que torna afirmável o que
/// acontece com um envio em voo (LIST-33).
class _PortaQueTrava implements PedidoRepository {
  final List<Pedido> enviados = [];
  final List<Completer<Pedido>> respostas = [];

  @override
  Future<Pedido> enviar(Pedido pedido) {
    enviados.add(pedido);
    final resposta = Completer<Pedido>();
    respostas.add(resposta);

    return resposta.future;
  }

  /// Libera o primeiro envio em voo, confirmando o que recebeu.
  void confirmarOPrimeiro() => respostas.first.complete(enviados.first);
}

/// Uma lista só de bebidas, montada à mão: a calculadora sempre acrescenta os
/// quatro essenciais de RN-10, e o lado "o Zé é selecionável" precisa de um
/// pedido que não os tenha.
List<ItemDeLista> _soDeBebidas() {
  final padrao = resultadoRn30();

  return [
    itemDe(padrao, ChaveItem.refrigerante),
    itemDe(padrao, ChaveItem.agua),
    itemDe(padrao, ChaveItem.cerveja),
  ];
}

void main() {
  late PedidoFalsoDeTeste porta;
  late RecordingAppLogger logger;

  setUp(() {
    porta = PedidoFalsoDeTeste();
    logger = RecordingAppLogger();
  });

  PedidoBloc blocCom({
    List<ItemDeLista>? itens,
    PedidoRepository? pedidos,
    bool apenasOQueFalta = false,
  }) {
    final bloc = PedidoBloc(
      pedidos ?? porta,
      logger,
      itens: itens ?? resultadoRn30().todosOsItens,
      enderecoDaFesta: _enderecoDaFesta,
      apenasOQueFalta: apenasOQueFalta,
    );
    addTearDown(bloc.close);

    return bloc;
  }

  group('LIST-22 — a sheet abre pronta', () {
    test('o iFood Mercado já vem selecionado (A-14)', () {
      expect(blocCom().state.parceiro, ParceiroDeEntrega.ifood);
    });

    test('o endereço abre com o da festa', () {
      expect(blocCom().state.endereco, _enderecoDaFesta);
    });
  });

  group('LIST-23 — subtotal + frete = total', () {
    test('o estado padrão de RN-30 com o iFood dá 271 + 12 = 283', () {
      final bloc = blocCom();

      expect(MoneyFormatter.reais(bloc.state.subtotal), r'R$ 271');
      expect(MoneyFormatter.reais(bloc.state.frete), r'R$ 12');
      expect(MoneyFormatter.reais(bloc.state.total), r'R$ 283');
    });

    test('trocar para o Rappi dá total 280', () async {
      final bloc = blocCom()..add(const ParceiroSelecionado(
          ParceiroDeEntrega.rappi,
        ));
      await _assentar();

      expect(bloc.state.parceiro, ParceiroDeEntrega.rappi);
      expect(MoneyFormatter.reais(bloc.state.frete), r'R$ 9');
      expect(MoneyFormatter.reais(bloc.state.total), r'R$ 280');
    });

    test('o Zé entra com frete 0, e o total é o próprio subtotal', () async {
      final bloc = blocCom(itens: _soDeBebidas())
        ..add(const ParceiroSelecionado(ParceiroDeEntrega.ze));
      await _assentar();

      expect(bloc.state.frete, 0);
      expect(bloc.state.total, bloc.state.subtotal);
    });
  });

  group('LIST-23 — 🍽️ Copos & pratos fica fora (A-19)', () {
    test('a lista de origem tem Copos & pratos', () {
      // Sem isto, os dois testes abaixo passariam com a filtragem removida.
      expect(
        resultadoRn30().todosOsItens.map((item) => item.chave),
        contains(ChaveItem.coposEPratos),
      );
    });

    test('o subtotal não conta os R\$ 15 de Copos & pratos', () {
      final semFiltro = subtotalDeItens(resultadoRn30().todosOsItens);

      expect(MoneyFormatter.reais(semFiltro), r'R$ 286');
      expect(MoneyFormatter.reais(blocCom().state.subtotal), r'R$ 271');
    });

    test('Copos & pratos não vai no pedido enviado', () async {
      blocCom().add(const PedidoEnviado());
      await _assentar();

      expect(
        porta.enviados.single.itens.map((item) => item.chave),
        isNot(contains(ChaveItem.coposEPratos)),
      );
    });
  });

  group('LIST-25 — aberto pelo COMPRAR leva só o que falta (UC-16 A2)', () {
    final comCarrinho = resultadoRn30(
      noCarrinho: const {ChaveItem.cerveja, ChaveItem.carvao},
    ).todosOsItens;

    test('o subtotal desconta os itens já marcados', () {
      final inteiro = subtotalDeItens(itensCobraveis(comCarrinho));
      final cerveja = comCarrinho
          .firstWhere((item) => item.chave == ChaveItem.cerveja)
          .valor;
      final carvao =
          comCarrinho.firstWhere((item) => item.chave == ChaveItem.carvao).valor;

      final bloc = blocCom(itens: comCarrinho, apenasOQueFalta: true);

      expect(bloc.state.subtotal, closeTo(inteiro - cerveja - carvao, 0.001));
    });

    test('os itens marcados não vão no pedido', () async {
      blocCom(itens: comCarrinho, apenasOQueFalta: true)
          .add(const PedidoEnviado());
      await _assentar();

      final chaves = porta.enviados.single.itens.map((item) => item.chave);

      expect(chaves, isNot(contains(ChaveItem.cerveja)));
      expect(chaves, isNot(contains(ChaveItem.carvao)));
      expect(chaves, contains(ChaveItem.bovina));
    });

    test('sem o modo COMPRAR, os marcados continuam no pedido', () async {
      blocCom(itens: comCarrinho).add(const PedidoEnviado());
      await _assentar();

      expect(
        porta.enviados.single.itens.map((item) => item.chave),
        contains(ChaveItem.cerveja),
      );
    });
  });

  group('LIST-21 — o endereço vale só para este pedido (A-08)', () {
    test('o endereço novo é o que vai no pedido', () async {
      blocCom()
        ..add(const EnderecoTrocado('Rua da Mooca, 300'))
        ..add(const PedidoEnviado());
      await _assentar();

      expect(porta.enviados.single.endereco, 'Rua da Mooca, 300');
    });

    test('endereço vazio volta ao da festa', () async {
      final bloc = blocCom()
        ..add(const EnderecoTrocado('Rua da Mooca, 300'))
        ..add(const EnderecoTrocado(''));
      await _assentar();

      expect(bloc.state.endereco, _enderecoDaFesta);
    });

    test('endereço só com espaços volta ao da festa', () async {
      final bloc = blocCom()..add(const EnderecoTrocado('   '));
      await _assentar();

      expect(bloc.state.endereco, _enderecoDaFesta);
    });
  });

  group('LIST-24 — a guarda do Zé Delivery (A-09)', () {
    test('com item fora de BEBIDAS o Zé não pode ser escolhido', () {
      expect(blocCom().state.podeEscolher(ParceiroDeEntrega.ze), isFalse);
    });

    test('selecionar o Zé com carne no pedido não muda nada', () async {
      final bloc = blocCom()
        ..add(const ParceiroSelecionado(ParceiroDeEntrega.ze));
      await _assentar();

      expect(bloc.state.parceiro, ParceiroDeEntrega.ifood);
      expect(MoneyFormatter.reais(bloc.state.total), r'R$ 283');
    });

    test('com o pedido só de bebidas o Zé é escolhido normalmente', () async {
      final bloc = blocCom(itens: _soDeBebidas())
        ..add(const ParceiroSelecionado(ParceiroDeEntrega.ze));
      await _assentar();

      expect(bloc.state.podeEscolher(ParceiroDeEntrega.ze), isTrue);
      expect(bloc.state.parceiro, ParceiroDeEntrega.ze);
    });

    test('os outros dois parceiros nunca são barrados', () {
      final estado = blocCom().state;

      expect(estado.podeEscolher(ParceiroDeEntrega.ifood), isTrue);
      expect(estado.podeEscolher(ParceiroDeEntrega.rappi), isTrue);
    });
  });

  group('LIST-33 — confirmar duas vezes cria um pedido só', () {
    test('dois toques com o envio em voo produzem um enviar', () async {
      final trava = _PortaQueTrava();
      final bloc = blocCom(pedidos: trava)
        ..add(const PedidoEnviado())
        ..add(const PedidoEnviado());
      await _assentar();

      expect(trava.enviados.length, 1);
      expect(bloc.state.enviando, isTrue);

      trava.confirmarOPrimeiro();
      await _assentar();

      expect(trava.enviados.length, 1);
      expect(bloc.state.enviando, isFalse);
      expect(bloc.state.confirmado, isNotNull);
    });

    test('confirmar de novo depois de confirmado não reenvia', () async {
      final bloc = blocCom()..add(const PedidoEnviado());
      await _assentar();

      bloc.add(const PedidoEnviado());
      await _assentar();

      expect(porta.enviados.length, 1);
    });
  });

  group('LIST-28 — o confirmado é o que a porta devolveu (AC2)', () {
    test('o estado guarda o pedido da porta, não o que foi enviado', () async {
      final daPorta = Pedido(
        parceiro: ParceiroDeEntrega.rappi,
        endereco: 'Endereço que só a porta conhece',
        itens: const [],
        subtotal: 100,
        frete: 9,
        total: 109,
      );
      porta.resposta = daPorta;

      final bloc = blocCom()..add(const PedidoEnviado());
      await _assentar();

      expect(bloc.state.confirmado, daPorta);
      expect(bloc.state.confirmado!.endereco, 'Endereço que só a porta conhece');
    });
  });

  group('LIST-32 — a porta que falha', () {
    test('não confirma, acende a falha e devolve o CTA ao ativo', () async {
      porta.erroAoEnviar = Exception('sem rede');

      final bloc = blocCom()..add(const PedidoEnviado());
      await _assentar();

      expect(bloc.state.confirmado, isNull);
      expect(bloc.state.falhou, isTrue);
      expect(bloc.state.enviando, isFalse);
    });

    test('a falha vai para o AppLogger em "lista" (AD-005)', () async {
      porta.erroAoEnviar = Exception('sem rede');

      blocCom().add(const PedidoEnviado());
      await _assentar();

      expect(logger.erros.single.name, 'lista');
      expect(logger.erros.single.stackTrace, isNotNull);
    });

    test('depois da falha, um novo toque tenta de novo', () async {
      porta.erroAoEnviar = Exception('sem rede');

      final bloc = blocCom()..add(const PedidoEnviado());
      await _assentar();

      porta.erroAoEnviar = null;
      bloc.add(const PedidoEnviado());
      await _assentar();

      expect(porta.enviados.length, 2);
      expect(bloc.state.confirmado, isNotNull);
      expect(bloc.state.falhou, isFalse);
    });
  });
}
