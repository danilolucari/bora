import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';
import 'package:flutter_test/flutter_test.dart';

/// `const` no teste é a prova de que o construtor de [ResumoDeFesta] é `const`
/// — o mesmo padrão de `test/core/calculo/dominio/festa_test.dart`.
/// O id da festa — o `{festaId}` das rotas.
const String _id = 'rafa18';

const Festa _churrasDoRafa = Festa(
  nome: 'CHURRAS DO RAFA 🔥',
  data: 'SÁB · 18 JUL',
  hora: '14H',
  local: 'Laje do Rafa — Vila Madalena',
  duracaoHoras: 4,
);

const Festa _churrasDaLaje = Festa(
  nome: 'Churras da laje',
  data: 'SÁB · 21 JUN',
  hora: '13H',
  local: 'Laje do Rafa — Vila Madalena',
  duracaoHoras: 4,
  status: StatusDaFesta.passada,
);

/// O estado de RN-30 como a Home o mostra: 4 confirmados e 2 pendentes.
const ResumoDeFesta _rn30 = ResumoDeFesta(
  id: _id,
  festa: _churrasDoRafa,
  confirmados: 4,
  pendentes: 2,
  iniciais: ['R', 'A', 'L'],
);

void main() {
  group('HOME-19 — ResumoDeFesta compõe a Festa sem substituí-la', () {
    test('carrega a entidade de core/calculo inteira, sem copiar campo', () {
      expect(_rn30.festa, _churrasDoRafa);
      expect(_rn30.festa.nome, 'CHURRAS DO RAFA 🔥');
    });

    test('os contadores são dado, e convivem com o que a Festa não sabe', () {
      expect(_rn30.confirmados, 4);
      expect(_rn30.pendentes, 2);
    });

    test('festa que está chegando não tem pessoas nem total (UC-24)', () {
      expect(_rn30.pessoas, isNull);
      expect(_rn30.total, isNull);
    });

    test('sem números informados, tudo nasce zerado e vazio', () {
      const semNumeros = ResumoDeFesta(id: _id, festa: _churrasDoRafa);

      expect(semNumeros.confirmados, 0);
      expect(semNumeros.pendentes, 0);
      expect(semNumeros.iniciais, isEmpty);
    });
  });

  group('HOME-07 — o id é o {festaId} da rota', () {
    test('o resumo carrega o id que a navegação precisa', () {
      expect(_rn30.id, 'rafa18');
    });

    test('duas festas com o mesmo nome e ids diferentes são diferentes', () {
      const homonima = ResumoDeFesta(
        id: 'outra18',
        festa: _churrasDoRafa,
        confirmados: 4,
        pendentes: 2,
        iniciais: ['R', 'A', 'L'],
      );

      expect(
        homonima,
        isNot(_rn30),
        reason: 'repetir o nome do churrasco é comum; por nome, as duas '
            'colapsariam numa só e a confirmação de uma acenderia o atalho '
            'da outra',
      );
    });
  });

  group('HOME-14 — ehPassada separa o arquivo do que está chegando', () {
    test('festa concluída é passada', () {
      const passada = ResumoDeFesta(
        id: _id,
        festa: _churrasDaLaje,
        pessoas: 14,
        total: 612,
      );

      expect(passada.ehPassada, isTrue);
      expect(passada.pessoas, 14);
      expect(passada.total, 612);
    });

    test('festa chegando não é passada — é o par que discrimina', () {
      expect(_rn30.ehPassada, isFalse);
    });
  });

  group('HOME-04 — o "+N" tracejado é o excedente de avatares', () {
    test('com 4 confirmados e 3 avatares visíveis, o excedente é 1', () {
      expect(_rn30.excedenteDeAvatares(3), 1);
    });

    test('com exatamente 3 confirmados e 3 visíveis, o excedente é 0', () {
      const tresConfirmados = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        confirmados: 3,
        iniciais: ['R', 'A', 'L'],
      );

      expect(tresConfirmados.excedenteDeAvatares(3), 0);
    });

    test('com menos confirmados do que slots, o excedente nunca é negativo',
        () {
      const doisConfirmados = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        confirmados: 2,
        iniciais: ['R', 'A'],
      );

      expect(doisConfirmados.excedenteDeAvatares(3), 0);
    });

    test('sem confirmado nenhum, o excedente é 0', () {
      const ninguem = ResumoDeFesta(id: _id, festa: _churrasDoRafa);

      expect(ninguem.excedenteDeAvatares(3), 0);
    });

    test('o excedente desconta os avatares desenhados, não os slots', () {
      const poucasIniciais = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        confirmados: 4,
        iniciais: ['R', 'A'],
      );

      expect(
        poucasIniciais.excedenteDeAvatares(3),
        2,
        reason: 'a pilha desenha 2 círculos, então 2 pessoas ficaram de fora — '
            'descontar os 3 slots contaria gente que a tela não mostrou',
      );
      expect(poucasIniciais.avataresMostrados(3), 2);
    });

    test('com mais iniciais do que slots, a pilha para no teto', () {
      const muitasIniciais = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        confirmados: 6,
        iniciais: ['R', 'A', 'L', 'B', 'D'],
      );

      expect(muitasIniciais.avataresMostrados(3), 3);
      expect(
        muitasIniciais.excedenteDeAvatares(3),
        3,
        reason: '3 desenhados + "+3" = os 6 confirmados; sem o teto a pilha '
            'desenhava 5 círculos e ainda somava "+3"',
      );
    });
  });

  group('HOME-19 — igualdade por valor, porque o Stream compara emissões', () {
    test('dois resumos com os mesmos campos são iguais', () {
      const outro = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        confirmados: 4,
        pendentes: 2,
        iniciais: ['R', 'A', 'L'],
      );

      expect(outro, _rn30);
      expect(outro.hashCode, _rn30.hashCode);
    });

    test('iniciais são comparadas por conteúdo, não por identidade de lista',
        () {
      final listaNova = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        confirmados: 4,
        pendentes: 2,
        iniciais: ['R', 'A', 'L'].toList(),
      );

      expect(
        listaNova,
        _rn30,
        reason: 'uma lista nova com o mesmo conteúdo não é mudança — se fosse, '
            'a Home reconstruiria a cada emissão idêntica do repositório',
      );
      expect(listaNova.hashCode, _rn30.hashCode);
    });

    test('mudar a ordem das iniciais torna os resumos diferentes', () {
      const outraOrdem = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        confirmados: 4,
        pendentes: 2,
        iniciais: ['A', 'R', 'L'],
      );

      expect(outraOrdem, isNot(_rn30));
    });

    test('um confirmado a mais torna os resumos diferentes (RN-28)', () {
      const depoisDoRsvp = ResumoDeFesta(
        id: _id,
        festa: _churrasDoRafa,
        confirmados: 5,
        pendentes: 1,
        iniciais: ['R', 'A', 'L'],
      );

      expect(
        depoisDoRsvp,
        isNot(_rn30),
        reason: 'sem isso a Home não redesenharia quando a confirmação chega',
      );
    });

    test('trocar a festa torna os resumos diferentes', () {
      const outraFesta = ResumoDeFesta(
        id: _id,
        festa: _churrasDaLaje,
        confirmados: 4,
        pendentes: 2,
        iniciais: ['R', 'A', 'L'],
      );

      expect(outraFesta, isNot(_rn30));
    });
  });
}
