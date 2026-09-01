import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/lista/presentation/lista_textos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/cifrao_na_fonte.dart';

const String _arquivoDosTextos =
    'lib/features/lista/presentation/lista_textos.dart';

/// As quatro fontes de RN-10, **lidas do catálogo** — nunca redigitadas aqui.
///
/// A ordem é a de `ordemCanonicaDaLista`: carvão, gelo, sal grosso, copos.
List<String> _fontesDosEssenciais() => [
      for (final chave in ordemCanonicaDaLista)
        if (catalogoDeItens[chave]!.fonteDaProporcao case final String fonte)
          fonte,
    ];

void main() {
  group('LIST-01, LIST-02 — a cabeça da tela', () {
    test('o título é "SUA LISTA" nas duas plataformas', () {
      expect(ListaTextos.titulo, 'SUA LISTA');
    });

    test('o segmented tem as duas opções literais, PLANEJAR primeiro', () {
      expect(ListaTextos.modoPlanejar, '🧮 PLANEJAR');
      expect(ListaTextos.modoComprar, '🛒 COMPRAR');
      expect(ListaTextos.opcoesDeModo, ['🧮 PLANEJAR', '🛒 COMPRAR']);
    });

    test('a dica de PLANEJAR é a copy literal de T-04', () {
      expect(
        ListaTextos.dicaPlanejar,
        '📊 Cada preço é a média real de mercados perto de você — a barra '
        'mostra o mín/máx que a galera achou.',
      );
    });

    test('a dica de COMPRAR é a copy literal de T-04', () {
      expect(
        ListaTextos.dicaComprar,
        '✅ Organizado por corredor do mercado — marque o que já tá no '
        'carrinho.',
      );
    });

    test('as duas dicas são diferentes — cada modo tem a sua', () {
      expect(ListaTextos.dicaPlanejar, isNot(ListaTextos.dicaComprar));
    });
  });

  group('LIST-04 — a categoria dos essenciais e a badge', () {
    test('a categoria é "ESSENCIAIS · ENTRAM SOZINHOS"', () {
      expect(
        ListaTextos.categoriaDosEssenciais,
        'ESSENCIAIS · ENTRAM SOZINHOS',
      );
    });

    test('a badge monta "AUTO ∝ {fonte}" nas quatro fontes de RN-10', () {
      expect(
        _fontesDosEssenciais().map(ListaTextos.autoProporcional).toList(),
        [
          'AUTO ∝ kg de carne',
          'AUTO ∝ volume de bebida gelada',
          'AUTO ∝ kg de carne',
          'AUTO ∝ nº de pessoas',
        ],
      );
    });

    test('a badge não formata a fonte — ela passa como veio', () {
      expect(
        ListaTextos.autoProporcional('QUALQUER COISA'),
        'AUTO ∝ QUALQUER COISA',
      );
    });
  });

  group('LIST-08, LIST-11 — a linha de PLANEJAR', () {
    test(
      'a sublinha da linha coberta é "{quantidade} · média de N mercados"',
      () {
        expect(
          ListaTextos.mediaDeMercados('1,2 kg', 4),
          '1,2 kg · média de 4 mercados',
        );
      },
    );

    test('a sublinha recebe a quantidade pronta — não a formata', () {
      expect(
        ListaTextos.mediaDeMercados('QUALQUER COISA', 2),
        'QUALQUER COISA · média de 2 mercados',
      );
    });

    test('a micro-label do valor é "MÉDIA"', () {
      expect(ListaTextos.media, 'MÉDIA');
    });

    test('os dois steppers do painel são "QUANTIDADE" e "PREÇO"', () {
      expect(ListaTextos.quantidade, 'QUANTIDADE');
      expect(ListaTextos.preco, 'PREÇO');
    });
  });

  group('LIST-06, LIST-09, LIST-14 — o rodapé de PLANEJAR', () {
    test('o rótulo do rodapé é "MÉDIA TOTAL"', () {
      expect(ListaTextos.mediaTotal, 'MÉDIA TOTAL');
    });

    test('a faixa real é "faixa real: de {mín} a {máx}", já formatados', () {
      expect(
        ListaTextos.faixaReal(
          MoneyFormatter.reais(244.6),
          MoneyFormatter.reais(342.6),
        ),
        'faixa real: de R\$ 245 a R\$ 343',
      );
    });

    test('a faixa real não formata nada — os extremos passam como vieram', () {
      expect(ListaTextos.faixaReal('UM', 'OUTRO'), 'faixa real: de UM a OUTRO');
    });

    test('o "por adulto" é "≈ {valor} por adulto", já formatado', () {
      expect(
        ListaTextos.porAdulto(MoneyFormatter.reais(45.1)),
        '≈ R\$ 45 por adulto',
      );
    });

    test('o "por adulto" não formata o valor — ele passa como veio', () {
      expect(
        ListaTextos.porAdulto('QUALQUER COISA'),
        '≈ QUALQUER COISA por adulto',
      );
    });

    test('o CTA de PLANEJAR e o "RESTAURAR" são os literais de T-04', () {
      expect(ListaTextos.fazerPedidoComCarrinho, 'FAZER PEDIDO 🛒');
      expect(ListaTextos.restaurar, 'RESTAURAR');
    });
  });

  group('LIST-16, LIST-19 — os corredores e o rodapé de COMPRAR', () {
    test('os cinco corredores têm o rótulo em caixa alta de RN-27', () {
      expect(
        Corredor.values.map(ListaTextos.rotuloDoCorredor).toList(),
        ['AÇOUGUE', 'HORTIFRÚTI', 'PADARIA', 'BEBIDAS', 'MERCEARIA'],
      );
    });

    test('a contagem do grupo é "{N} itens"', () {
      expect(ListaTextos.itensNoCorredor(3), '3 itens');
      expect(ListaTextos.itensNoCorredor(1), '1 itens');
    });

    test('o contador do rodapé é "{N} de {M} no carrinho"', () {
      expect(ListaTextos.noCarrinho(2, 7), '2 de 7 no carrinho');
    });

    test('o CTA de COMPRAR é "PEDIR O QUE FALTA 🛵"', () {
      expect(ListaTextos.pedirOQueFalta, 'PEDIR O QUE FALTA 🛵');
    });

    test('os dois CTAs de rodapé são diferentes — um por modo', () {
      expect(
        ListaTextos.fazerPedidoComCarrinho,
        isNot(ListaTextos.pedirOQueFalta),
      );
    });
  });

  group('LIST-22, LIST-23 — a sheet do pedido', () {
    test('o título, a seção e a ação do endereço são os literais de T-04', () {
      expect(ListaTextos.tituloDoPedido, 'FAZER PEDIDO');
      expect(ListaTextos.entregaPor, 'ENTREGA POR');
      expect(ListaTextos.trocar, 'TROCAR');
    });

    test('as três linhas do resumo ficam em sentence case', () {
      expect(ListaTextos.subtotal, 'Subtotal');
      expect(ListaTextos.frete, 'Frete');
      expect(ListaTextos.total, 'Total');
    });

    test('o CTA da sheet é "CONFIRMAR PEDIDO →"', () {
      expect(ListaTextos.confirmarPedido, 'CONFIRMAR PEDIDO →');
    });
  });

  group('LIST-26 — o overlay do pedido', () {
    test('o título é "PEDIDO A CAMINHO!"', () {
      expect(ListaTextos.pedidoACaminho, 'PEDIDO A CAMINHO!');
    });

    test('a linha do ETA traz o endereço inteiro, sem encurtar (D-6)', () {
      expect(
        ListaTextos.chegaEm('40–60 min', 'Laje do Rafa — Vila Madalena'),
        'Chega em 40–60 min na Laje do Rafa — Vila Madalena.',
      );
    });

    test('a linha do rateio é "{total} · rachado no acerto da festa"', () {
      expect(
        ListaTextos.rachadoNoAcerto(MoneyFormatter.reais(102)),
        'R\$ 102 · rachado no acerto da festa',
      );
    });

    test('a linha do rateio não formata o total — ele passa como veio', () {
      expect(
        ListaTextos.rachadoNoAcerto('QUALQUER COISA'),
        'QUALQUER COISA · rachado no acerto da festa',
      );
    });

    test('o CTA do overlay é "VOLTAR À LISTA"', () {
      expect(ListaTextos.voltarALista, 'VOLTAR À LISTA');
    });
  });

  group('LIST-35 — as abas permanentes da festa', () {
    test('as quatro abas são as do arquivo 01 §5, na ordem', () {
      expect(
        ListaTextos.abasDaFesta,
        ['Lista', 'Galera', 'WhatsApp', 'Custos'],
      );
    });
  });

  group('LIST-07, A-23 — o que este arquivo não pode conter', () {
    test('o arquivo de copy não escreve dinheiro — RN-13 é da camada', () {
      expect(cifraoEm(File(_arquivoDosTextos).readAsStringSync()), isEmpty);
    });

    test('zero toast: nem referência ao token, nem texto de toast (A-23)', () {
      final fonte = File(_arquivoDosTextos).readAsStringSync();

      expect(fonte, isNot(contains('BoraToastTexts')));
      expect(fonte, isNot(contains('BoraToast')));
    });
  });
}
