import 'dart:io';

import 'package:bora/core/design_system/design_system.dart';
import 'package:bora/features/montar/domain/secao_da_montagem.dart';
import 'package:bora/features/montar/presentation/montar_textos.dart';
import 'package:flutter_test/flutter_test.dart';

const String _arquivoDosTextos =
    'lib/features/montar/presentation/montar_textos.dart';

void main() {
  group('MONT-01 — a copy literal do formulário', () {
    test('o título é o mesmo nas duas plataformas', () {
      expect(MontarTextos.titulo, 'A CONTA DO ROLÊ');
    });

    test('as três linhas de contagem trazem emoji e rótulo de T-03', () {
      expect(MontarTextos.homens, '👨 Homens');
      expect(MontarTextos.mulheres, '👩 Mulheres');
      expect(MontarTextos.criancas, '🧒 Crianças');
    });

    test('as três seções de chips têm os rótulos de T-03/W-03', () {
      expect(MontarTextos.naGrelha, 'NA GRELHA');
      expect(MontarTextos.naGeladeira, 'NA GELADEIRA');
      expect(MontarTextos.prosFortes, 'PROS FORTES');
    });

    test('cada seção da montagem recebe o rótulo da sua própria copy', () {
      expect(MontarTextos.rotuloDaSecao(SecaoDaMontagem.naGrelha), 'NA GRELHA');
      expect(
        MontarTextos.rotuloDaSecao(SecaoDaMontagem.naGeladeira),
        'NA GELADEIRA',
      );
      expect(
        MontarTextos.rotuloDaSecao(SecaoDaMontagem.prosFortes),
        'PROS FORTES',
      );
    });

    test('o segmented tem as quatro opções na ordem literal', () {
      expect(MontarTextos.opcoesDeDuracao, ['2h', '4h', '6h', 'Dia']);
    });
  });

  group('MONT-09 — os quatro rótulos que divergem por plataforma (A-09)', () {
    test('a seção de pessoas tem uma copy em T-03 e outra em W-03', () {
      expect(
        MontarTextos.secaoDePessoasCompacto,
        'CONFIRMADOS + EXTRAS SEM APP',
      );
      expect(MontarTextos.secaoDePessoasExpandido, 'QUEM CONFIRMOU');
    });

    test('a duração tem uma copy em T-03 e outra em W-03', () {
      expect(MontarTextos.duracaoCompacto, 'QUANTO TEMPO DE FESTA?');
      expect(MontarTextos.duracaoExpandido, 'ATÉ QUE HORAS?');
    });

    test('os dois pares são de fato diferentes — unificar seria desobedecer '
        'uma das specs', () {
      expect(
        MontarTextos.secaoDePessoasCompacto,
        isNot(MontarTextos.secaoDePessoasExpandido),
      );
      expect(
        MontarTextos.duracaoCompacto,
        isNot(MontarTextos.duracaoExpandido),
      );
    });

    test('a identidade do rolê no web é "{NOME} · {DATA}"', () {
      expect(
        MontarTextos.identidadeExpandida(
          nome: 'CHURRAS DO RAFA 🔥',
          data: 'SÁB · 18 JUL',
        ),
        'CHURRAS DO RAFA 🔥 · SÁB · 18 JUL',
      );
    });
  });

  group('MONT-03, MONT-06 — o bloco do dinheiro', () {
    test('o rótulo do bloco é "SAI POR"', () {
      expect(MontarTextos.saiPor, 'SAI POR');
    });

    test('a sublinha de T-03 é "≈ {valor} / cabeça"', () {
      expect(MontarTextos.porCabecaCompacto('R\$ 30'), '≈ R\$ 30 / cabeça');
    });

    test('a sublinha de W-03 é "dividido dá {valor} por cabeça"', () {
      expect(
        MontarTextos.porCabecaExpandido('R\$ 30'),
        'dividido dá R\$ 30 por cabeça',
      );
    });

    test('as duas frases mostram o mesmo valor — só a frase muda', () {
      const valor = 'R\$ 45';

      expect(MontarTextos.porCabecaCompacto(valor), contains(valor));
      expect(MontarTextos.porCabecaExpandido(valor), contains(valor));
      expect(
        MontarTextos.porCabecaCompacto(valor),
        isNot(MontarTextos.porCabecaExpandido(valor)),
      );
    });

    test('nenhuma das duas frases formata o valor — ele passa como veio', () {
      expect(
        MontarTextos.porCabecaCompacto('QUALQUER COISA'),
        '≈ QUALQUER COISA / cabeça',
      );
      expect(
        MontarTextos.porCabecaExpandido('QUALQUER COISA'),
        'dividido dá QUALQUER COISA por cabeça',
      );
    });

    test('a label do card-herói monta "SAI POR · {N} PESSOAS · {duração}"', () {
      expect(
        MontarTextos.labelDoHeroi(pessoas: 7, duracaoHoras: 4),
        'SAI POR · 7 PESSOAS · 4 horas',
      );
    });

    test('a duração da label vem de rotuloDeDuracao — "Dia" vira "Dia todo" '
        '(A-15)', () {
      expect(
        MontarTextos.labelDoHeroi(pessoas: 7, duracaoHoras: 10),
        'SAI POR · 7 PESSOAS · Dia todo',
      );
    });

    test('o arquivo de copy não escreve dinheiro — RN-13 é da camada', () {
      expect(File(_arquivoDosTextos).readAsStringSync(), isNot(contains(r'R$')));
    });
  });

  group('MONT-23 — as saídas da tela', () {
    test('os dois CTAs são os literais de T-03 e W-03', () {
      expect(MontarTextos.fecharLista, 'FECHAR LISTA →');
      expect(MontarTextos.mandarNoGrupo, 'MANDAR NO GRUPO 📲');
    });

    test('a ação secundária do rail é "SALVAR ROLÊ"', () {
      expect(MontarTextos.salvarRole, 'SALVAR ROLÊ');
    });

    test('o toast é o token de RN-29 (L-008)', () {
      expect(MontarTextos.toastRoleSalvo, BoraToastTexts.roleSalvo);
    });

    test('o toast é referência ao token, não literal redigitado', () {
      // `expect(a, b)` sozinho não discrimina: com o literal de RN-29
      // redigitado aqui as duas strings seriam iguais e o teste passaria. O
      // que prova a referência é a fonte do arquivo.
      final fonte = File(_arquivoDosTextos).readAsStringSync();

      expect(fonte, contains('BoraToastTexts.roleSalvo'));
      expect(fonte, isNot(contains('ROLÊ SALVO')));
    });

    test('a lista viva fecha cada categoria com "SUBTOTAL"', () {
      expect(MontarTextos.subtotal, 'SUBTOTAL');
    });
  });
}
