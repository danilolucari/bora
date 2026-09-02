import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:flutter_test/flutter_test.dart';

/// **O round-trip pelo adaptador que o app roda de verdade** — não por duplo.
///
/// `FestaEmEdicao` tem quatro campos, e três specs os escrevem: identidade e
/// composição (`montar`), `despesas` (`lista`, AD-030) e `convite` (`galera`,
/// AD-031). O registro por onde tudo passa é o [ResumoDeFesta]: o que ele não
/// carrega, `salvarFesta` reconstrói no default e `observarFesta` devolve
/// errado — **em silêncio**.
///
/// Foi o que aconteceu: `despesas` e `convite` não eram campos do resumo, e a
/// suíte inteira ficou verde porque toda asserção das specs 06 e 07 passa por
/// duplo. Estes testes são a única cobertura que atravessa o adaptador real,
/// campo por campo — e por isso a asserção é sempre **por campo**, nunca
/// `expect(lida, rascunho)`: a igualdade inteira esconde qual campo caiu.
const Festa _festa = Festa(
  nome: 'CHURRAS DO RAFA 🔥',
  data: 'SÁB · 18 JUL',
  hora: '14H',
  local: 'Laje do Rafa — Vila Madalena',
  duracaoHoras: 4,
);

/// Valores **distintos de todo default** (L-031): o nível não é o de
/// `ConviteDaFesta.vazio` e o código não é vazio. Um mutante que fixe o
/// default tem de morrer.
const ConviteDaFesta _convite = ConviteDaFesta(
  codigo: 'rafa18',
  nivel: NivelDoLink.editarLista,
);

const List<Despesa> _despesas = [
  Despesa(quemPagou: 'Rafa', descricao: 'Delivery do açougue', valor: 187),
  Despesa(quemPagou: 'Bia', descricao: 'Gelo', valor: 30),
];

ComposicaoDaFesta _composicao() => ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: 4,
      itensSelecionados: {ChaveItem.bovina, ChaveItem.frango},
    );

FestaEmEdicao _completa() => FestaEmEdicao(
      festa: _festa,
      composicao: _composicao(),
      despesas: _despesas,
      convite: _convite,
    );

FestaRepositoryEmMemoria _store({List<ResumoDeFesta> inicial = const []}) {
  final repositorio = FestaRepositoryEmMemoria(inicial: inicial);
  addTearDown(repositorio.dispose);
  return repositorio;
}

void main() {
  group('criarFesta preserva os quatro campos do rascunho', () {
    test('as despesas do rascunho chegam na leitura', () async {
      final store = _store();
      final id = await store.criarFesta(_completa());

      final lida = await store.observarFesta(id).first;

      expect(lida!.despesas, _despesas);
    });

    test('o convite do rascunho chega na leitura', () async {
      final store = _store();
      final id = await store.criarFesta(_completa());

      final lida = await store.observarFesta(id).first;

      expect(lida!.convite.codigo, 'rafa18');
      expect(lida.convite.nivel, NivelDoLink.editarLista);
    });
  });

  group('salvarFesta grava os campos que o editor mexe', () {
    test('as despesas gravadas voltam na leitura seguinte', () async {
      final store = _store();
      final id = await store.criarFesta(
        FestaEmEdicao(festa: _festa, composicao: _composicao()),
      );
      expect((await store.observarFesta(id).first)!.despesas, isEmpty);

      await store.salvarFesta(
        id,
        FestaEmEdicao(
          festa: _festa,
          composicao: _composicao(),
          despesas: _despesas,
        ),
      );

      expect((await store.observarFesta(id).first)!.despesas, _despesas);
    });

    test('o nível do link gravado volta na leitura seguinte — GAL-04',
        () async {
      final store = _store();
      final id = await store.criarFesta(
        FestaEmEdicao(festa: _festa, composicao: _composicao()),
      );

      await store.salvarFesta(
        id,
        FestaEmEdicao(
          festa: _festa,
          composicao: _composicao(),
          convite: _convite,
        ),
      );

      final lida = await store.observarFesta(id).first;
      expect(lida!.convite.nivel, NivelDoLink.editarLista);
      expect(lida.convite.codigo, 'rafa18');
    });

    test('gravar despesa não apaga o convite, e vice-versa', () async {
      final store = _store();
      final id = await store.criarFesta(_completa());

      await store.salvarFesta(
        id,
        (await store.observarFesta(id).first)!
            .copyWith(despesas: const <Despesa>[]),
      );

      final lida = await store.observarFesta(id).first;
      expect(lida!.despesas, isEmpty);
      expect(lida.convite, _convite);
    });

    test(
        'o stream reemite com o convite novo — sem isso o segmented de T-05 '
        'volta ao valor antigo', () async {
      final store = _store();
      final id = await store.criarFesta(
        FestaEmEdicao(festa: _festa, composicao: _composicao()),
      );

      final emissoes = <NivelDoLink?>[];
      final inscricao = store
          .observarFesta(id)
          .listen((f) => emissoes.add(f?.convite.nivel));
      await Future<void>.delayed(Duration.zero);

      await store.salvarFesta(
        id,
        FestaEmEdicao(
          festa: _festa,
          composicao: _composicao(),
          convite: _convite,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await inscricao.cancel();

      expect(emissoes.last, NivelDoLink.editarLista);
    });
  });

  group('salvarFesta segue preservando o que não é do editor — AD-022', () {
    test('contadores e iniciais sobrevivem à gravação do convite', () async {
      const semente = ResumoDeFesta(
        id: 'rafa18',
        festa: _festa,
        confirmados: 4,
        pendentes: 2,
        iniciais: ['R', 'A', 'L'],
      );
      final store = _store(inicial: const [semente]);

      await store.salvarFesta(
        'rafa18',
        FestaEmEdicao(
          festa: _festa,
          composicao: _composicao(),
          convite: _convite,
        ),
      );

      final resumo = (await store.observarFestas().first).single;
      expect(resumo.confirmados, 4);
      expect(resumo.pendentes, 2);
      expect(resumo.iniciais, ['R', 'A', 'L']);
    });
  });

  group('os campos novos entram na igualdade do ResumoDeFesta', () {
    const base = ResumoDeFesta(id: 'rafa18', festa: _festa);

    test('dois resumos sem despesa nem convite continuam iguais', () {
      expect(base, const ResumoDeFesta(id: 'rafa18', festa: _festa));
      expect(
        base.hashCode,
        const ResumoDeFesta(id: 'rafa18', festa: _festa).hashCode,
      );
    });

    test('convite diferente torna os resumos diferentes', () {
      const outro = ResumoDeFesta(
        id: 'rafa18',
        festa: _festa,
        convite: _convite,
      );
      expect(outro, isNot(base));
    });

    test('despesa diferente torna os resumos diferentes', () {
      const outro = ResumoDeFesta(
        id: 'rafa18',
        festa: _festa,
        despesas: _despesas,
      );
      expect(outro, isNot(base));
    });

    test('mesma despesa em lista nova continua igual — igualdade é profunda',
        () {
      const a = ResumoDeFesta(
        id: 'rafa18',
        festa: _festa,
        despesas: [Despesa(quemPagou: 'Rafa', descricao: 'Gelo', valor: 30)],
      );
      const b = ResumoDeFesta(
        id: 'rafa18',
        festa: _festa,
        despesas: [Despesa(quemPagou: 'Rafa', descricao: 'Gelo', valor: 30)],
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a ordem das despesas conta', () {
      const a = ResumoDeFesta(id: 'rafa18', festa: _festa, despesas: _despesas);
      const b = ResumoDeFesta(
        id: 'rafa18',
        festa: _festa,
        despesas: [
          Despesa(quemPagou: 'Bia', descricao: 'Gelo', valor: 30),
          Despesa(
            quemPagou: 'Rafa',
            descricao: 'Delivery do açougue',
            valor: 187,
          ),
        ],
      );
      expect(a, isNot(b));
    });
  });
}
