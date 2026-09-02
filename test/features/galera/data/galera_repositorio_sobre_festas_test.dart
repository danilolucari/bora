import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/data/galera_repositorio_sobre_festas.dart';
import 'package:bora/features/galera/domain/chave_de_pessoa.dart';
import 'package:bora/features/galera/domain/galera_da_festa.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/rn30_estado_inicial_tipado.dart';
import '../../../support/festa_em_edicao_repository_fake.dart';
import '../../../support/recording_app_logger.dart';

const String _arquivo =
    'lib/features/galera/data/galera_repositorio_sobre_festas.dart';

const String _id = 'festa-1';

const ChaveDePessoa _rafa = ChaveDePessoa('Rafa', 0);
const ChaveDePessoa _leo = ChaveDePessoa('Léo', 0);
const ChaveDePessoa _bia = ChaveDePessoa('Bia', 0);

/// Um override de RN-12 com valor **distinto de todo default** — 9,5 kg de
/// bovina não coincide com nenhuma quantidade automática do estado padrão.
const Map<ChaveItem, OverrideDeItem> _overrides = {
  ChaveItem.bovina: OverrideDeItem(quantidade: 9.5),
};

const Set<ChaveItem> _noCarrinho = {ChaveItem.agua};

ComposicaoDaFesta _composicao({
  List<Pessoa>? pessoas,
  Set<ChaveItem>? itens,
  Map<ChaveItem, OverrideDeItem> overrides = const {},
  Set<ChaveItem> noCarrinho = const {},
}) =>
    ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: 4,
      pessoas: pessoas ?? pessoasRn30Tipadas,
      itensSelecionados: itens ?? itensPadraoRn30Tipados.toSet(),
      overrides: overrides,
      noCarrinho: noCarrinho,
    );

FestaEmEdicao _festa({
  List<Pessoa>? pessoas,
  Set<ChaveItem>? itens,
  Map<ChaveItem, OverrideDeItem> overrides = const {},
  Set<ChaveItem> noCarrinho = const {},
}) =>
    FestaEmEdicao(
      festa: festaRn30Tipada,
      composicao: _composicao(
        pessoas: pessoas,
        itens: itens,
        overrides: overrides,
        noCarrinho: noCarrinho,
      ),
      convite: conviteRn30Tipado,
    );

/// A lista de RN-30 com uma pessoa trocada — o registro de partida de cada
/// cenário, montado sem tocar na fixture.
List<Pessoa> _comPessoa(int indice, Pessoa pessoa) =>
    List.of(pessoasRn30Tipadas)..[indice] = pessoa;

Pessoa _pessoa(String nome, {Dieta? dieta, bool? bebe}) => Pessoa(
      nome: nome,
      papel: PapelNaFesta.convidado,
      status: StatusDePresenca.confirmado,
      dieta: dieta,
      bebe: bebe,
    );

/// O código do arquivo, sem doc nem comentário de linha.
String _semComentarios(String fonte) => fonte
    .split('\n')
    .where((linha) => !linha.trimLeft().startsWith('//'))
    .join('\n');

final RegExp _literalNumerico = RegExp(r'\b\d+(?:\.\d+)?\b');

/// Os literais numéricos que aparecem no **código** da fonte — nenhum, aqui:
/// toda aritmética de RN-03, RN-05 e RN-21 mora em `core/calculo`.
List<String> literaisNumericosEm(String fonte) => _literalNumerico
    .allMatches(_semComentarios(fonte))
    .map((m) => m.group(0)!)
    .toList();

void main() {
  late FestaEmEdicaoRepositoryFake fake;
  late GaleraRepositorioSobreFestas porta;

  void semear(FestaEmEdicao festa) {
    fake = FestaEmEdicaoRepositoryFake(festas: {_id: festa});
    porta = GaleraRepositorioSobreFestas(fake, RecordingAppLogger());
  }

  Future<GaleraDaFesta> lerGalera() async =>
      (await porta.observarGalera(_id).first)!;

  Future<ComposicaoDaFesta> lerComposicao() async =>
      (await lerGalera()).composicao;

  setUp(() => semear(_festa()));

  group('GAL-09 — observarGalera mapeia o registro da festa', () {
    test('propaga o festaId, o convite e a composição inteira', () async {
      final galera = await lerGalera();

      expect(galera.festaId, _id);
      expect(galera.convite.codigo, 'rafa18');
      expect(galera.convite.nivel, NivelDoLink.editarLista);
      expect(galera.composicao, _composicao());
    });

    test('a composição chega com overrides e noCarrinho, não só as pessoas',
        () async {
      semear(_festa(overrides: _overrides, noCarrinho: _noCarrinho));

      final composicao = await lerComposicao();

      expect(composicao.overrides, _overrides);
      expect(composicao.noCarrinho, _noCarrinho);
    });

    test('festa inexistente continua null — "não existe", não festa vazia',
        () async {
      await expectLater(porta.observarGalera('nao-existe'), emits(isNull));
    });
  });

  group('GAL-11 — alterarDieta troca a dieta de quem a chave endereça', () {
    test('a Bia passa de sem porco a tudo', () async {
      await porta.alterarDieta(_id, _bia, Dieta.tudo);

      expect((await lerComposicao()).pessoas[3].dieta, Dieta.tudo);
    });

    test('nenhuma outra pessoa muda — item a item', () async {
      await porta.alterarDieta(_id, _bia, Dieta.tudo);

      final pessoas = (await lerComposicao()).pessoas;
      expect(pessoas[0], pessoasRn30Tipadas[0]);
      expect(pessoas[1], pessoasRn30Tipadas[1]);
      expect(pessoas[2], pessoasRn30Tipadas[2]);
      expect(pessoas[4], pessoasRn30Tipadas[4]);
    });

    test('com duas Anas na lista, só a endereçada muda', () async {
      semear(_festa(pessoas: [
        _pessoa('Ana', dieta: Dieta.tudo),
        _pessoa('Léo', dieta: Dieta.tudo),
        _pessoa('Ana', dieta: Dieta.tudo),
      ]));

      const segundaAna = ChaveDePessoa('Ana', 1);
      await porta.alterarDieta(_id, segundaAna, Dieta.veggie);

      final pessoas = (await lerComposicao()).pessoas;
      expect(pessoas[0].dieta, Dieta.tudo);
      expect(pessoas[2].dieta, Dieta.veggie);
    });
  });

  group('GAL-12 — alterarBebida troca o bebe de quem a chave endereça', () {
    test('o Léo deixa de beber', () async {
      await porta.alterarBebida(_id, _leo, false);

      expect((await lerComposicao()).pessoas[2].bebe, isFalse);
    });

    test('nenhuma outra pessoa muda — item a item', () async {
      await porta.alterarBebida(_id, _leo, false);

      final pessoas = (await lerComposicao()).pessoas;
      expect(pessoas[0], pessoasRn30Tipadas[0]);
      expect(pessoas[1], pessoasRn30Tipadas[1]);
      expect(pessoas[3], pessoasRn30Tipadas[3]);
      expect(pessoas[4], pessoasRn30Tipadas[4]);
    });

    test('com duas Anas na lista, só a endereçada muda', () async {
      semear(_festa(pessoas: [
        _pessoa('Ana', bebe: true),
        _pessoa('Ana', bebe: true),
      ]));

      await porta.alterarBebida(_id, const ChaveDePessoa('Ana', 0), false);

      final pessoas = (await lerComposicao()).pessoas;
      expect(pessoas[0].bebe, isFalse);
      expect(pessoas[1].bebe, isTrue);
    });
  });

  group('A escrita lê o registro no instante da chamada, nunca um snapshot',
      () {
    test('o que mudou por fora entre a leitura e a escrita sobrevive',
        () async {
      // A tela leu o registro — e ficou com ele na mão.
      expect((await lerComposicao()).pessoas[2].bebe, isTrue);

      // Nesse meio tempo, outra tela gravou que o Léo não bebe.
      fake.emitir(
        _id,
        _festa(pessoas: _comPessoa(2, _pessoa('Léo', bebe: false))),
      );

      // Só agora a Galera escreve a dieta da Bia.
      await porta.alterarDieta(_id, _bia, Dieta.tudo);

      final pessoas = (await lerComposicao()).pessoas;
      expect(
        pessoas[2].bebe,
        isFalse,
        reason: 'gravar por cima de um snapshot antigo apagaria a escrita '
            'que chegou no meio',
      );
      expect(pessoas[3].dieta, Dieta.tudo);
    });
  });

  group('GAL-15 AC12 — a escrita toca só pessoas, e o override sobrevive', () {
    test('overrides e noCarrinho continuam idênticos depois de alterarDieta',
        () async {
      semear(_festa(overrides: _overrides, noCarrinho: _noCarrinho));

      await porta.alterarDieta(_id, _bia, Dieta.tudo);

      final composicao = await lerComposicao();
      expect(composicao.overrides, _overrides);
      expect(composicao.noCarrinho, _noCarrinho);
    });

    test('contagem, duração e itens selecionados continuam idênticos',
        () async {
      await porta.alterarBebida(_id, _leo, false);

      final composicao = await lerComposicao();
      expect(composicao.contagem, _composicao().contagem);
      expect(composicao.duracaoHoras, 4);
      expect(composicao.itensSelecionados, itensPadraoRn30Tipados.toSet());
    });

    test('a identidade da festa e o convite continuam idênticos', () async {
      await porta.alterarDieta(_id, _bia, Dieta.tudo);

      final (_, gravada) = fake.salvas.single;
      expect(gravada.festa, festaRn30Tipada);
      expect(gravada.convite, conviteRn30Tipado);
    });
  });

  group('GAL-14 — o efeito a jusante, sobre o registro, por core/calculo', () {
    test('uma pessoa veggie faz o kit de legumes entrar na lista', () async {
      // Ninguém veggie: o Léo de RN-30 é o único, e entra aqui como "tudo".
      semear(_festa(pessoas: _comPessoa(2, _pessoa('Léo', dieta: Dieta.tudo))));

      expect(await _temKitVeggie(lerComposicao), isFalse);

      await porta.alterarDieta(_id, _leo, Dieta.veggie);
      expect(await _temKitVeggie(lerComposicao), isTrue);

      await porta.alterarDieta(_id, _leo, Dieta.tudo);
      expect(await _temKitVeggie(lerComposicao), isFalse);
    });

    test('o kit entra com o nome literal de RN-11', () async {
      final itens = CalculadoraDaFesta.calcular(await lerComposicao()).itens;

      expect(
        itens.firstWhere((i) => i.chave == ChaveItem.legumesParaGrelha).nome,
        'Legumes p/ grelha (kit veggie)',
      );
    });

    test('tirar o "sem porco" de todos traz a suína selecionada de volta',
        () async {
      semear(_festa(itens: {...itensPadraoRn30Tipados, ChaveItem.suina}));

      expect(await _temSuina(lerComposicao), isFalse);

      await porta.alterarDieta(_id, _bia, Dieta.tudo);
      expect(await _temSuina(lerComposicao), isTrue);

      await porta.alterarDieta(_id, _bia, Dieta.semPorco);
      expect(await _temSuina(lerComposicao), isFalse);
    });

    test('desmarcar a bebida de alguém reduz a cerveja', () async {
      final antes = await _cerveja(lerComposicao);

      await porta.alterarBebida(_id, _leo, false);

      expect(await _cerveja(lerComposicao), lessThan(antes));
    });

    test('e a cerveja bate com a de um registro montado com o mesmo dado',
        () async {
      await porta.alterarBebida(_id, _leo, false);

      final equivalente = _composicao(
        pessoas: _comPessoa(
          2,
          pessoasRn30Tipadas[2].copyWith(bebe: false),
        ),
      );

      expect(
        await _cerveja(lerComposicao),
        CalculadoraDaFesta.calcular(equivalente)
            .itens
            .firstWhere((i) => i.chave == ChaveItem.cerveja)
            .quantidade,
      );
    });
  });

  group('GAL-28 — tocar a opção já vigente não grava nada', () {
    test('alterarDieta com a dieta que a pessoa já tem não chama salvarFesta',
        () async {
      await porta.alterarDieta(_id, _bia, Dieta.semPorco);

      expect(fake.salvas, isEmpty);
    });

    test('alterarBebida com o valor que a pessoa já tem não chama salvarFesta',
        () async {
      await porta.alterarBebida(_id, _bia, false);

      expect(fake.salvas, isEmpty);
    });

    test('e o controle positivo: valor diferente grava exatamente uma vez',
        () async {
      await porta.alterarDieta(_id, _bia, Dieta.tudo);
      await porta.alterarBebida(_id, _bia, true);

      expect(fake.salvas, hasLength(2));
    });

    test('não declarado é diferente de declarado: a Duda grava ao declarar',
        () async {
      await porta.alterarBebida(_id, const ChaveDePessoa('Duda', 0), false);

      expect(fake.salvas, hasLength(1));
      expect((await lerComposicao()).pessoas[4].bebe, isFalse);
    });
  });

  group('As recusas do caminho de escrita, cada uma com o seu caso', () {
    test('chave de nome que não existe no registro não grava nem lança',
        () async {
      const fulano = ChaveDePessoa('Fulano', 0);
      await porta.alterarDieta(_id, fulano, Dieta.tudo);

      expect(fake.salvas, isEmpty);
      expect((await lerComposicao()).pessoas, pessoasRn30Tipadas);
    });

    test('ocorrência que sumiu do registro não grava nem lança', () async {
      await porta.alterarBebida(_id, const ChaveDePessoa('Rafa', 1), false);

      expect(fake.salvas, isEmpty);
      expect((await lerComposicao()).pessoas[0], pessoasRn30Tipadas[0]);
    });

    test('festa que não existe não grava nem lança', () async {
      await porta.alterarDieta('nao-existe', _rafa, Dieta.veggie);

      expect(fake.salvas, isEmpty);
    });
  });

  group('GAL-15 AC11 — nenhuma fórmula de RN-03/RN-05/RN-21 mora aqui', () {
    test('o adaptador não tem literal numérico nenhum no código', () {
      expect(
        literaisNumericosEm(File(_arquivo).readAsStringSync()),
        isEmpty,
        reason: 'quantidade e proporção saem de core/calculo — um número '
            'aqui é uma segunda fonte da mesma regra',
      );
    });

    test('a varredura morde: uma constante de RN-03 seria reportada', () {
      const infrator = '''
/// RN-03 manda 400 g por adulto.
const int gramasPorAdulto = 400;
''';

      expect(literaisNumericosEm(infrator), ['400']);
    });
  });
}

Future<bool> _temKitVeggie(Future<ComposicaoDaFesta> Function() ler) async =>
    CalculadoraDaFesta.calcular(await ler())
        .itens
        .any((i) => i.chave == ChaveItem.legumesParaGrelha);

Future<bool> _temSuina(Future<ComposicaoDaFesta> Function() ler) async =>
    CalculadoraDaFesta.calcular(await ler())
        .itens
        .any((i) => i.chave == ChaveItem.suina);

Future<double> _cerveja(Future<ComposicaoDaFesta> Function() ler) async =>
    CalculadoraDaFesta.calcular(await ler())
        .itens
        .firstWhere((i) => i.chave == ChaveItem.cerveja)
        .quantidade;
