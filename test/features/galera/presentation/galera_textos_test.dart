import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/presentation/galera_textos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/rn30_estado_inicial_tipado.dart';
import '../../../support/galera_de_teste.dart';

const String _arquivoDosTextos =
    'lib/features/galera/presentation/galera_textos.dart';

/// A pessoa de [nome] na fixture de RN-30.
Pessoa _daFixture(String nome) =>
    pessoasRn30Tipadas.firstWhere((pessoa) => pessoa.nome == nome);

void main() {
  group('GAL-01, GAL-06 — a cabeça da tela e o card do link', () {
    test('o título é "A GALERA" nas duas plataformas', () {
      expect(GaleraTextos.titulo, 'A GALERA');
    });

    test('a label do card do link é "LINK PRA CONVIDAR"', () {
      expect(GaleraTextos.labelDoLink, 'LINK PRA CONVIDAR');
    });

    test('o botão do card é "COPIAR 🔗"', () {
      expect(GaleraTextos.copiar, 'COPIAR 🔗');
    });

    test('a label do segmented é "QUEM ABRIR O LINK PODE…"', () {
      expect(GaleraTextos.quemAbrirPode, 'QUEM ABRIR O LINK PODE…');
    });

    test('a seção das pessoas é "PESSOAS" e o badge é "VOCÊ"', () {
      expect(GaleraTextos.secaoPessoas, 'PESSOAS');
      expect(GaleraTextos.badgeVoce, 'VOCÊ');
    });

    test('o CTA do rodapé é "+ CONVIDAR MAIS GENTE 🔗"', () {
      expect(GaleraTextos.convidarMaisGente, '+ CONVIDAR MAIS GENTE 🔗');
    });
  });

  group('GAL-01 AC2, GAL-03 — a URL do convite, RN-23', () {
    test('o código da fixture monta "bora.app/c/rafa18"', () {
      expect(GaleraTextos.urlDoConvite('rafa18'), 'bora.app/c/rafa18');
      expect(
        GaleraTextos.urlDoConvite(conviteRn30Tipado.codigo),
        'bora.app/c/rafa18',
      );
    });

    test('outro código muda a URL — o prefixo não é a resposta inteira', () {
      expect(GaleraTextos.urlDoConvite('ana07'), 'bora.app/c/ana07');
    });

    test('código vazio devolve a URL sem sufixo, sem inventar nada', () {
      expect(GaleraTextos.urlDoConvite(''), 'bora.app/c/');
    });

    test(
      'código que exigiria escape sai igual nas duas chamadas — a exibida e a '
      'copiada são a mesma string',
      () {
        const codigo = 'rolê do rafa?&#';

        expect(
          GaleraTextos.urlDoConvite(codigo),
          GaleraTextos.urlDoConvite(codigo),
        );
        expect(GaleraTextos.urlDoConvite(codigo), 'bora.app/c/$codigo');
      },
    );
  });

  group('GAL-02 — as três notas de RN-23, literais', () {
    test('SÓ VER: "convidados só veem a festa e confirmam presença"', () {
      expect(
        GaleraTextos.notaDoNivel(NivelDoLink.soVer),
        'convidados só veem a festa e confirmam presença',
      );
    });

    test('EDITAR LISTA: "convidados marcam o que levam e ajustam a lista"', () {
      expect(
        GaleraTextos.notaDoNivel(NivelDoLink.editarLista),
        'convidados marcam o que levam e ajustam a lista',
      );
    });

    test('CO-ANFITRIÃO: "acesso total: editam tudo e cobram a galera"', () {
      expect(
        GaleraTextos.notaDoNivel(NivelDoLink.coAnfitriao),
        'acesso total: editam tudo e cobram a galera',
      );
    });

    test('as três notas são distintas entre si', () {
      final notas = NivelDoLink.values.map(GaleraTextos.notaDoNivel).toSet();

      expect(notas, hasLength(NivelDoLink.values.length));
    });

    test('os rótulos do segmented são os três de T-05, nessa ordem', () {
      expect(GaleraTextos.niveis, ['SÓ VER', 'EDITAR LISTA', 'CO-ANFITRIÃO']);
    });

    test('a ordem dos rótulos é a de NivelDoLink.values', () {
      expect(
        GaleraTextos.niveis,
        [
          GaleraTextos.rotuloDoNivel(NivelDoLink.soVer),
          GaleraTextos.rotuloDoNivel(NivelDoLink.editarLista),
          GaleraTextos.rotuloDoNivel(NivelDoLink.coAnfitriao),
        ],
      );
    });

    test('"SÓ VER" é o nível do link, e não o rótulo do papel "SÓ VÊ"', () {
      expect(
        GaleraTextos.rotuloDoNivel(NivelDoLink.soVer),
        isNot(GaleraTextos.rotuloDoPapel(PapelNaFesta.soVe)),
      );
    });
  });

  group('GAL-06, GAL-24 — o sub derivado da contagem (A-08, A-10)', () {
    test('com a fixture de RN-30 lê "5 pessoas · 4 confirmadas"', () {
      final galera = galeraDeTeste();

      expect(
        GaleraTextos.subtitulo(
          pessoas: galera.pessoas.length,
          confirmadas: galera.confirmados,
        ),
        '5 pessoas · 4 confirmadas',
      );
    });

    test('com 1 e 1 os dois termos vão para o singular', () {
      expect(
        GaleraTextos.subtitulo(pessoas: 1, confirmadas: 1),
        '1 pessoa · 1 confirmada',
      );
    });

    test('o plural das duas metades é independente: 2 pessoas, 1 confirmada',
        () {
      expect(
        GaleraTextos.subtitulo(pessoas: 2, confirmadas: 1),
        '2 pessoas · 1 confirmada',
      );
    });

    test('ninguém confirmado ainda mantém o plural do zero', () {
      expect(
        GaleraTextos.subtitulo(pessoas: 3, confirmadas: 0),
        '3 pessoas · 0 confirmadas',
      );
    });

    test('sem pessoa nomeada nenhuma o sub é "nenhuma pessoa ainda"', () {
      expect(GaleraTextos.subtitulo(pessoas: 0, confirmadas: 0),
          'nenhuma pessoa ainda');
      expect(
        GaleraTextos.subtitulo(pessoas: 0, confirmadas: 0),
        GaleraTextos.semPessoas,
      );
    });
  });

  group('GAL-13 — a faixa concatena "💡 " e nada mais', () {
    test('o resumo de RN-21 da fixture vira a faixa literal de T-05', () {
      final resumo = resumoDasPreferencias(
        efeitosDasPreferencias(pessoas: pessoasRn30Tipadas, adultos: 6),
      );

      expect(
        GaleraTextos.faixa(resumo),
        '💡 A lista já se ajusta às preferências: 1 veggie 🥗 · '
        '1 sem porco 🚫 · 3 bebem 🍺',
      );
    });

    test('o que entra sai inteiro, com o prefixo e sem mais nada', () {
      expect(GaleraTextos.faixa('qualquer coisa'), '💡 qualquer coisa');
    });

    test('resumo vazio devolve vazio — sem "💡 " solto', () {
      expect(GaleraTextos.faixa(''), isEmpty);
    });
  });

  group('GAL-07, GAL-11 — os rótulos de dieta de RN-21 (A-13)', () {
    test('os três rótulos são os literais da regra, com emoji', () {
      expect(GaleraTextos.rotuloDaDieta(Dieta.tudo), '🍖 Come de tudo');
      expect(GaleraTextos.rotuloDaDieta(Dieta.veggie), '🥗 Veggie');
      expect(GaleraTextos.rotuloDaDieta(Dieta.semPorco), '🚫 Sem porco');
    });

    test('a lista traz os três na ordem de Dieta.values', () {
      expect(
        GaleraTextos.dietas,
        ['🍖 Come de tudo', '🥗 Veggie', '🚫 Sem porco'],
      );
    });
  });

  group('GAL-07 — a sublinha de cada pessoa (A-14)', () {
    test('Rafa, que come de tudo e bebe, lê "🍖 Come de tudo · bebe 🍺"', () {
      expect(
        GaleraTextos.sublinhaDe(_daFixture('Rafa')),
        '🍖 Come de tudo · bebe 🍺',
      );
    });

    test('Léo, veggie e que bebe, lê "🥗 Veggie · bebe 🍺"', () {
      expect(
        GaleraTextos.sublinhaDe(_daFixture('Léo')),
        '🥗 Veggie · bebe 🍺',
      );
    });

    test('Bia, sem porco e abstêmia, lê "🚫 Sem porco · não bebe 🚫"', () {
      expect(
        GaleraTextos.sublinhaDe(_daFixture('Bia')),
        '🚫 Sem porco · não bebe 🚫',
      );
    });

    test('bebida não declarada omite o termo e não deixa separador solto', () {
      expect(
        GaleraTextos.sublinhaDe(pessoaDeTeste('Nina', dieta: Dieta.veggie)),
        '🥗 Veggie',
      );
    });

    test('dieta não declarada omite o termo e mantém a bebida', () {
      expect(
        GaleraTextos.sublinhaDe(pessoaDeTeste('Nina', bebe: false)),
        'não bebe 🚫',
      );
    });

    test('Duda, sem dieta e sem bebida, não tem sublinha — devolve null', () {
      expect(GaleraTextos.sublinhaDe(_daFixture('Duda')), isNull);
    });

    test('a sublinha é corpo de texto, não o botão em caixa alta', () {
      expect(
        GaleraTextos.sublinhaDe(pessoaDeTeste('Nina', bebe: true)),
        isNot(GaleraTextos.bebe),
      );
    });
  });

  group('GAL-10, GAL-12, GAL-16 — a copy do painel', () {
    test('as três seções são as literais de T-05', () {
      expect(GaleraTextos.secaoNivelDeAcesso, 'NÍVEL DE ACESSO');
      expect(GaleraTextos.secaoRestricao, 'RESTRIÇÃO ALIMENTAR');
      expect(GaleraTextos.secaoBebida, 'BEBIDA');
    });

    test('o toggle de bebida é "BEBE 🍺" / "NÃO BEBE 🚫"', () {
      expect(GaleraTextos.bebe, 'BEBE 🍺');
      expect(GaleraTextos.naoBebe, 'NÃO BEBE 🚫');
    });

    test('a nota do anfitrião é literal, ponto final incluído', () {
      expect(
        GaleraTextos.notaDoAnfitriao,
        '👑 Anfitrião manda em tudo — acesso fixo.',
      );
    });
  });

  group('GAL-08, GAL-18 — os rótulos de papel vêm do token', () {
    test('os quatro papéis leem o rótulo de BoraStatus, não um literal novo',
        () {
      expect(
        GaleraTextos.rotuloDoPapel(PapelNaFesta.anfitriao),
        BoraStatus.anfitriao.rotulo,
      );
      expect(
        GaleraTextos.rotuloDoPapel(PapelNaFesta.coAnfitriao),
        BoraStatus.coAnfitriao.rotulo,
      );
      expect(
        GaleraTextos.rotuloDoPapel(PapelNaFesta.convidado),
        BoraStatus.convidado.rotulo,
      );
      expect(
        GaleraTextos.rotuloDoPapel(PapelNaFesta.soVe),
        BoraStatus.soVe.rotulo,
      );
    });

    test('cada papel mapeia para o status de §5 que lhe corresponde', () {
      expect(
        GaleraTextos.statusDoPapel(PapelNaFesta.anfitriao),
        BoraStatus.anfitriao,
      );
      expect(
        GaleraTextos.statusDoPapel(PapelNaFesta.coAnfitriao),
        BoraStatus.coAnfitriao,
      );
      expect(
        GaleraTextos.statusDoPapel(PapelNaFesta.convidado),
        BoraStatus.convidado,
      );
      expect(GaleraTextos.statusDoPapel(PapelNaFesta.soVe), BoraStatus.soVe);
    });

    test('"NÍVEL DE ACESSO" oferece três papéis, e ANFITRIÃO não é um deles',
        () {
      expect(
        GaleraTextos.papeisAtribuiveis,
        [
          PapelNaFesta.convidado,
          PapelNaFesta.coAnfitriao,
          PapelNaFesta.soVe,
        ],
      );
      expect(
        GaleraTextos.papeisAtribuiveis,
        isNot(contains(PapelNaFesta.anfitriao)),
      );
    });

    test('os rótulos oferecidos são os de T-05, na ordem dos papéis', () {
      expect(GaleraTextos.papeis, ['CONVIDADO', 'CO-ANFITRIÃO', 'SÓ VÊ']);
      expect(
        GaleraTextos.papeis,
        isNot(contains(BoraStatus.anfitriao.rotulo)),
      );
    });
  });

  group('RN-29, GAL-25 — o toast e a falha', () {
    test('o toast da cópia é o token de RN-29, não uma segunda cópia', () {
      expect(GaleraTextos.linkCopiado, BoraToastTexts.linkCopiado);
      expect(BoraToastTexts.todos, contains(GaleraTextos.linkCopiado));
    });

    test('a falha é a premissa declarada, na voz de HomeTextos.falha', () {
      expect(GaleraTextos.falha, 'NÃO DEU PRA CARREGAR A GALERA');
    });

    test('o arquivo declara a falha como SPEC_PRECISION_GAP', () {
      expect(
        File(_arquivoDosTextos).readAsStringSync(),
        contains('SPEC_PRECISION_GAP'),
      );
    });
  });
}
