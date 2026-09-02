import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/composicao_da_festa.dart';
import 'package:bora/core/calculo/dominio/contagem_de_pessoas.dart';
import 'package:bora/core/calculo/dominio/dieta.dart';
import 'package:bora/core/calculo/dominio/item_de_lista.dart';
import 'package:bora/core/calculo/dominio/papel_na_festa.dart';
import 'package:bora/core/calculo/dominio/pessoa.dart';
import 'package:bora/core/calculo/dominio/status_de_presenca.dart';
import 'package:flutter_test/flutter_test.dart';

const _rafa = Pessoa(
  nome: 'RAFA',
  papel: PapelNaFesta.anfitriao,
  status: StatusDePresenca.confirmado,
  voce: true,
);
const _bia = Pessoa(
  nome: 'BIA',
  papel: PapelNaFesta.convidado,
  status: StatusDePresenca.confirmado,
);

/// Monta uma composição nova a cada chamada — **instâncias de coleção
/// diferentes** com o mesmo conteúdo. É o que separa igualdade profunda de
/// igualdade por identidade.
ComposicaoDaFesta _composicao({
  int criancas = 1,
  List<Pessoa> pessoas = const [_rafa, _bia],
  Set<ChaveItem> itens = const {ChaveItem.bovina, ChaveItem.cerveja},
  Map<ChaveItem, OverrideDeItem> overrides = const {},
  Set<ChaveItem> noCarrinho = const {},
}) =>
    ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: criancas),
      duracaoHoras: 4,
      pessoas: [...pessoas],
      itensSelecionados: {...itens},
      overrides: {...overrides},
      noCarrinho: {...noCarrinho},
    );

void main() {
  group('CALC-05 — ComposicaoDaFesta é um valor, não uma identidade', () {
    test('duas composições com os mesmos campos são iguais', () {
      expect(_composicao(), _composicao());
      expect(_composicao().hashCode, _composicao().hashCode);
    });

    test('coleções com o mesmo conteúdo em instâncias diferentes são iguais',
        () {
      final a = _composicao();
      final b = _composicao();

      expect(
        identical(a.pessoas, b.pessoas),
        isFalse,
        reason: 'o teste só prova algo se as listas forem instâncias distintas',
      );
      expect(
        a,
        b,
        reason: 'com o == de identidade das coleções, duas composições '
            'idênticas nunca seriam iguais — e quem compara estados para '
            'evitar recálculo recalcularia sempre',
      );
    });

    test('mudar um campo escalar torna as composições diferentes', () {
      expect(_composicao(criancas: 2), isNot(_composicao()));
    });

    test('a ordem de pessoas importa: é comportamento observável (A-14)', () {
      expect(
        _composicao(pessoas: const [_bia, _rafa]),
        isNot(_composicao(pessoas: const [_rafa, _bia])),
      );
    });

    test('a ordem dos itens selecionados não importa: é conjunto', () {
      expect(
        _composicao(itens: const {ChaveItem.cerveja, ChaveItem.bovina}),
        _composicao(itens: const {ChaveItem.bovina, ChaveItem.cerveja}),
      );
    });

    test('um override a mais, ou com outro valor, torna diferentes', () {
      final semOverride = _composicao();
      final comOverride = _composicao(
        overrides: const {ChaveItem.bovina: OverrideDeItem(quantidade: 2)},
      );
      final outroValor = _composicao(
        overrides: const {ChaveItem.bovina: OverrideDeItem(quantidade: 3)},
      );

      expect(comOverride, isNot(semOverride));
      expect(outroValor, isNot(comOverride));
      expect(
        _composicao(
          overrides: const {ChaveItem.bovina: OverrideDeItem(quantidade: 2)},
        ),
        comOverride,
        reason: 'mesmo conteúdo em mapas distintos continua sendo o mesmo '
            'valor',
      );
    });

    test('mapas com as mesmas chaves e valores trocados são diferentes', () {
      final ida = _composicao(
        overrides: const {
          ChaveItem.bovina: OverrideDeItem(quantidade: 2),
          ChaveItem.cerveja: OverrideDeItem(quantidade: 3),
        },
      );
      final volta = _composicao(
        overrides: const {
          ChaveItem.bovina: OverrideDeItem(quantidade: 3),
          ChaveItem.cerveja: OverrideDeItem(quantidade: 2),
        },
      );

      expect(volta, isNot(ida));
      expect(
        volta.hashCode,
        isNot(ida.hashCode),
        reason: 'o hash do mapa junta chave e valor: trocá-los não pode '
            'colidir',
      );
    });
  });

  group('LIST-20 — o conjunto "no carrinho" na composição (AD-030)', () {
    test('o default é vazio: composição montada sem o campo não tem check', () {
      final composicao = ComposicaoDaFesta(
        contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
        duracaoHoras: 4,
      );

      expect(composicao.noCarrinho, isEmpty);
    });

    test('duas composições com o mesmo conjunto são iguais, em instâncias '
        'distintas', () {
      final a = _composicao(noCarrinho: {ChaveItem.bovina, ChaveItem.cerveja});
      final b = _composicao(noCarrinho: {ChaveItem.cerveja, ChaveItem.bovina});

      expect(
        identical(a.noCarrinho, b.noCarrinho),
        isFalse,
        reason: 'o teste só prova algo com conjuntos em instâncias distintas',
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('trocar um elemento do conjunto separa as composições — é disso que '
        'a supressão de eco depende', () {
      expect(
        _composicao(noCarrinho: {ChaveItem.bovina}),
        isNot(_composicao(noCarrinho: {ChaveItem.cerveja})),
      );
      expect(
        _composicao(noCarrinho: {ChaveItem.bovina}),
        isNot(_composicao()),
      );
      expect(
        _composicao(noCarrinho: {ChaveItem.bovina, ChaveItem.cerveja}),
        isNot(_composicao(noCarrinho: {ChaveItem.bovina})),
      );
    });

    test('copyWith preserva o conjunto não informado', () {
      final original = _composicao(noCarrinho: {ChaveItem.bovina});

      expect(original.copyWith(duracaoHoras: 8).noCarrinho, {ChaveItem.bovina});
      expect(original.copyWith().noCarrinho, {ChaveItem.bovina});
    });

    test('copyWith substitui o conjunto informado, inclusive por um vazio', () {
      final original = _composicao(noCarrinho: {ChaveItem.bovina});

      expect(
        original.copyWith(noCarrinho: {ChaveItem.cerveja}).noCarrinho,
        {ChaveItem.cerveja},
      );
      expect(
        original.copyWith(noCarrinho: const {}).noCarrinho,
        isEmpty,
        reason: 'desmarcar o último item tem de chegar à composição',
      );
    });

    test('copyWith preserva os demais campos e troca só o informado', () {
      final original = _composicao(noCarrinho: {ChaveItem.bovina});
      final copia = original.copyWith(noCarrinho: {ChaveItem.cerveja});

      expect(copia.contagem, original.contagem);
      expect(copia.duracaoHoras, original.duracaoHoras);
      expect(copia.pessoas, original.pessoas);
      expect(copia.itensSelecionados, original.itensSelecionados);
      expect(copia.overrides, original.overrides);
      expect(copia.noCarrinho, {ChaveItem.cerveja});
    });
  });

  group('GAL-15 — copyWith preserva todo campo que a chamada não informa', () {
    // `noCarrinho` tem os seus três casos no grupo CALC-05 acima
    // (`copyWith preserva o conjunto não informado`, `copyWith substitui o
    // conjunto informado, inclusive por um vazio` e `copyWith preserva os
    // demais campos e troca só o informado`) e não é reescrito aqui.
    final outraContagem = ContagemDePessoas(homens: 5, mulheres: 1);

    test('trocar a contagem preserva os cinco campos restantes', () {
      final original = _composicao(
        overrides: {ChaveItem.bovina: const OverrideDeItem(quantidade: 9)},
        noCarrinho: {ChaveItem.cerveja},
      );

      final copia = original.copyWith(contagem: outraContagem);

      expect(copia.contagem, outraContagem);
      expect(copia.duracaoHoras, original.duracaoHoras);
      expect(copia.pessoas, original.pessoas);
      expect(copia.itensSelecionados, original.itensSelecionados);
      expect(copia.overrides, original.overrides);
      expect(copia.noCarrinho, original.noCarrinho);
    });

    test('trocar a duração preserva os cinco campos restantes', () {
      final original = _composicao(
        overrides: {ChaveItem.bovina: const OverrideDeItem(quantidade: 9)},
        noCarrinho: {ChaveItem.cerveja},
      );

      final copia = original.copyWith(duracaoHoras: 8);

      expect(copia.duracaoHoras, 8);
      expect(copia.contagem, original.contagem);
      expect(copia.pessoas, original.pessoas);
      expect(copia.itensSelecionados, original.itensSelecionados);
      expect(copia.overrides, original.overrides);
      expect(copia.noCarrinho, original.noCarrinho);
    });

    test('trocar as pessoas preserva os cinco campos restantes', () {
      final original = _composicao(
        overrides: {ChaveItem.bovina: const OverrideDeItem(quantidade: 9)},
        noCarrinho: {ChaveItem.cerveja},
      );

      final copia = original.copyWith(pessoas: const [_rafa]);

      expect(copia.pessoas, const [_rafa]);
      expect(copia.contagem, original.contagem);
      expect(copia.duracaoHoras, original.duracaoHoras);
      expect(copia.itensSelecionados, original.itensSelecionados);
      expect(copia.overrides, original.overrides);
      expect(copia.noCarrinho, original.noCarrinho);
    });

    test('trocar os itens selecionados preserva os cinco campos restantes', () {
      final original = _composicao(
        overrides: {ChaveItem.bovina: const OverrideDeItem(quantidade: 9)},
        noCarrinho: {ChaveItem.cerveja},
      );

      final copia = original.copyWith(itensSelecionados: {ChaveItem.agua});

      expect(copia.itensSelecionados, {ChaveItem.agua});
      expect(copia.contagem, original.contagem);
      expect(copia.duracaoHoras, original.duracaoHoras);
      expect(copia.pessoas, original.pessoas);
      expect(copia.overrides, original.overrides);
      expect(copia.noCarrinho, original.noCarrinho);
    });

    test('trocar os overrides preserva os cinco campos restantes', () {
      final original = _composicao(
        overrides: {ChaveItem.bovina: const OverrideDeItem(quantidade: 9)},
        noCarrinho: {ChaveItem.cerveja},
      );

      final copia = original.copyWith(
        overrides: {ChaveItem.frango: const OverrideDeItem(quantidade: 2)},
      );

      expect(copia.overrides, {
        ChaveItem.frango: const OverrideDeItem(quantidade: 2),
      });
      expect(copia.contagem, original.contagem);
      expect(copia.duracaoHoras, original.duracaoHoras);
      expect(copia.pessoas, original.pessoas);
      expect(copia.itensSelecionados, original.itensSelecionados);
      expect(copia.noCarrinho, original.noCarrinho);
    });

    test('sem argumento nenhum devolve uma composição igual à original', () {
      final original = _composicao(
        overrides: {ChaveItem.bovina: const OverrideDeItem(quantidade: 9)},
        noCarrinho: {ChaveItem.cerveja},
      );

      expect(original.copyWith(), original);
      expect(original.copyWith().hashCode, original.hashCode);
    });
  });

  group('GAL-15 AC12 — o override sobrevive à troca de quem está na festa', () {
    test('trocar pessoas deixa o mapa de overrides idêntico', () {
      final overrides = {
        ChaveItem.bovina: const OverrideDeItem(quantidade: 9),
        ChaveItem.cerveja: const OverrideDeItem(quantidade: 24),
      };
      final original = _composicao(overrides: overrides);

      final depois = original.copyWith(
        pessoas: [_rafa, _bia.copyWith(dieta: Dieta.veggie)],
      );

      expect(
        depois.overrides,
        overrides,
        reason: 'a palavra explícita do usuário (RN-12) não é revogada por '
            'alguém declarar uma preferência (RN-21)',
      );
    });
  });

  group('GAL-15 — coleção vazia substitui de verdade, e não é "não '
      'informado"', () {
    test('pessoas: [] esvazia a lista em vez de preservá-la', () {
      final original = _composicao();

      expect(original.pessoas, isNotEmpty);
      expect(original.copyWith(pessoas: const []).pessoas, isEmpty);
    });

    test('itensSelecionados: {} esvazia o conjunto em vez de preservá-lo', () {
      final original = _composicao();

      expect(original.itensSelecionados, isNotEmpty);
      expect(
        original.copyWith(itensSelecionados: const {}).itensSelecionados,
        isEmpty,
      );
    });

    test('overrides: {} limpa o mapa em vez de preservá-lo', () {
      final original = _composicao(
        overrides: {ChaveItem.bovina: const OverrideDeItem(quantidade: 9)},
      );

      expect(original.overrides, isNotEmpty);
      expect(original.copyWith(overrides: const {}).overrides, isEmpty);
    });
  });
}
