import 'package:bora/core/calculo/dominio/chave_item.dart';
import 'package:bora/core/calculo/dominio/composicao_da_festa.dart';
import 'package:bora/core/calculo/dominio/contagem_de_pessoas.dart';
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
}) =>
    ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: criancas),
      duracaoHoras: 4,
      pessoas: [...pessoas],
      itensSelecionados: {...itens},
      overrides: {...overrides},
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
}
