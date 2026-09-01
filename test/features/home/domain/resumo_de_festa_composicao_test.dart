import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:flutter_test/flutter_test.dart';

/// O campo aditivo `composicao` (emenda **E-3** do `montar/design.md`): o
/// registro da festa no store passa a carregar o que `montar` grava.
///
/// Arquivo separado de `resumo_de_festa_test.dart` de propósito: a suíte da
/// spec 04 tem de rodar **intacta**, sem uma linha editada, e é isso que prova
/// que o campo é de fato aditivo.
const String _id = 'rafa18';

const Festa _churrasDoRafa = Festa(
  nome: 'CHURRAS DO RAFA 🔥',
  data: 'SÁB · 18 JUL',
  hora: '14H',
  local: 'Laje do Rafa — Vila Madalena',
  duracaoHoras: 4,
);

ComposicaoDaFesta _composicaoPadrao({int duracaoHoras = 4}) =>
    ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: duracaoHoras,
      itensSelecionados: {ChaveItem.bovina, ChaveItem.cerveja},
    );

void main() {
  group('E-3 — a composição entra no resumo com default', () {
    test('sem composição informada, o default é a festa vazia de 4 horas', () {
      const semComposicao = ResumoDeFesta(id: _id, festa: _churrasDoRafa);

      expect(semComposicao.composicao.contagem.pessoas, 0);
      expect(semComposicao.composicao.duracaoHoras, 4);
      expect(semComposicao.composicao.itensSelecionados, isEmpty);
      expect(semComposicao.composicao.pessoas, isEmpty);
    });

    test('a composição informada é preservada inteira', () {
      final comComposicao = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        composicao: _composicaoPadrao(),
      );

      expect(comComposicao.composicao, _composicaoPadrao());
    });

    test('o construtor continua const — é o que mantém a suíte da 04 intacta',
        () {
      const resumo = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        confirmados: 4,
        pendentes: 2,
        iniciais: ['R', 'A', 'L'],
      );

      expect(resumo.confirmados, 4);
      expect(resumo.composicao.duracaoHoras, 4);
    });
  });

  group('E-3 — a composição entra em == e hashCode', () {
    test('dois resumos sem composição continuam iguais', () {
      const a = ResumoDeFesta(id: _id, festa: _churrasDoRafa, confirmados: 4);
      const b = ResumoDeFesta(id: _id, festa: _churrasDoRafa, confirmados: 4);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('resumo sem composição é igual ao que informa o próprio default', () {
      const semComposicao = ResumoDeFesta(id: _id, festa: _churrasDoRafa);
      final comODefault = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        composicao: ComposicaoDaFesta(
          contagem: ContagemDePessoas(),
          duracaoHoras: 4,
        ),
      );

      expect(comODefault, semComposicao);
      expect(comODefault.hashCode, semComposicao.hashCode);
    });

    test('dois resumos que só diferem na composição não são iguais', () {
      final a = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        composicao: _composicaoPadrao(),
      );
      final b = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        composicao: _composicaoPadrao(duracaoHoras: 6),
      );

      expect(
        a,
        isNot(b),
        reason: 'sem isso o store emitiria a composição nova e o Stream a '
            'trataria como emissão repetida',
      );
    });

    test('resumo com composição não é igual ao resumo sem composição', () {
      const semComposicao = ResumoDeFesta(id: _id, festa: _churrasDoRafa);
      final comComposicao = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        composicao: _composicaoPadrao(),
      );

      expect(comComposicao, isNot(semComposicao));
    });

    test('duas composições de conteúdo igual não separam os resumos', () {
      final a = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        composicao: _composicaoPadrao(),
      );
      final b = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        composicao: _composicaoPadrao(),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
