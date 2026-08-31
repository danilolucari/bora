import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/features/montar/domain/rascunho_inicial.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/rn30_estado_inicial_tipado.dart';

const String _arquivoDoRascunho =
    'lib/features/montar/domain/rascunho_inicial.dart';

/// Alvos que `lib/` não pode importar: código de teste não vai para produção.
/// Mesma lista da varredura de `festa_repository_em_memoria_test.dart`.
const List<String> _alvosProibidos = ['test/', 'fixtures', 'flutter_test'];

/// Casa na **diretiva de import**, nunca em texto solto — o doc do arquivo
/// cita `test/fixtures/` para explicar a regra.
final RegExp _diretivaDeImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

List<String> _importsDeTesteEm(String conteudoDart) => _diretivaDeImport
    .allMatches(conteudoDart)
    .map((m) => m.group(1)!)
    .where((alvo) => _alvosProibidos.any(alvo.contains))
    .toList();

/// Uma quarta-feira de julho de 2026 — o sábado seguinte é o 18 de RN-30.
final DateTime _quartaAntesDoSabado18 = DateTime(2026, 7, 15);

void main() {
  group('MONT-15 / A-04 — o rolê que /roles/novo abre', () {
    test('o nome default é CHURRAS NOVO', () {
      final rascunho = rascunhoInicial(hoje: _quartaAntesDoSabado18);

      expect(rascunho.festa.nome, 'CHURRAS NOVO');
      expect(rascunho.festa.nome, nomeDefaultDoRole);
    });

    test('a data é a do próximo sábado, no formato de Festa.data', () {
      final rascunho = rascunhoInicial(hoje: _quartaAntesDoSabado18);

      expect(rascunho.festa.data, festaRn30Tipada.data);
    });

    test('a data acompanha o hoje que entrou', () {
      final rascunho = rascunhoInicial(hoje: DateTime(2026, 12, 31));

      expect(rascunho.festa.data, 'SÁB · 2 JAN');
    });

    test('hora e local nascem vazios — o M1 não coleta nenhum dos dois', () {
      final rascunho = rascunhoInicial(hoje: _quartaAntesDoSabado18);

      expect(rascunho.festa.hora, isEmpty);
      expect(rascunho.festa.local, isEmpty);
    });

    test('UC-03 E1: a contagem abre em 0/0/0', () {
      final contagem = rascunhoInicial(hoje: _quartaAntesDoSabado18)
          .composicao
          .contagem;

      expect(contagem.homens, 0);
      expect(contagem.mulheres, 0);
      expect(contagem.criancas, 0);
      expect(contagem.pessoas, 0);
    });

    test('a festa sem ninguém abre com total zero e lista vazia', () {
      final resultado = CalculadoraDaFesta.calcular(
        rascunhoInicial(hoje: _quartaAntesDoSabado18).composicao,
      );

      expect(resultado.itens, isEmpty);
      expect(resultado.totalDosItens, 0);
      expect(resultado.porCabeca, 0);
    });

    test('a duração default é 4h nos dois lados, sem divergir', () {
      final rascunho = rascunhoInicial(hoje: _quartaAntesDoSabado18);

      expect(rascunho.festa.duracaoHoras, 4);
      expect(
        rascunho.composicao.duracaoHoras,
        rascunho.festa.duracaoHoras,
        reason: 'divergirem faria o card-herói mostrar uma duração enquanto a '
            'conta usa outra',
      );
    });

    test('nenhuma pessoa nomeada e nenhum override no rascunho', () {
      final composicao = rascunhoInicial(hoje: _quartaAntesDoSabado18)
          .composicao;

      expect(composicao.pessoas, isEmpty);
      expect(composicao.overrides, isEmpty);
    });
  });

  group('RN-30 — o template abre com os itens padrão', () {
    test('amarração: itensSelecionados é a lista tipada da fixture', () {
      final rascunho = rascunhoInicial(hoje: _quartaAntesDoSabado18);

      expect(
        rascunho.composicao.itensSelecionados,
        itensPadraoRn30Tipados.toSet(),
        reason: 'a declaração em lib/ e a fixture de RN-30 não podem divergir',
      );
      expect(itensPadraoRn30Tipados, hasLength(7));
    });

    test('são os sete de RN-30, nomeados um a um', () {
      final itens = rascunhoInicial(hoje: _quartaAntesDoSabado18)
          .composicao
          .itensSelecionados;

      expect(itens, {
        ChaveItem.bovina,
        ChaveItem.frango,
        ChaveItem.paoDeAlho,
        ChaveItem.refrigerante,
        ChaveItem.agua,
        ChaveItem.cerveja,
        ChaveItem.cachaca,
      });
    });

    test('nenhum essencial de RN-10 entra selecionado: eles entram sozinhos',
        () {
      final itens = rascunhoInicial(hoje: _quartaAntesDoSabado18)
          .composicao
          .itensSelecionados;

      expect(itens, isNot(contains(ChaveItem.carvao)));
      expect(itens, isNot(contains(ChaveItem.gelo)));
      expect(itens, isNot(contains(ChaveItem.salGrosso)));
      expect(itens, isNot(contains(ChaveItem.coposEPratos)));
    });
  });

  group('lib/ não importa test/fixtures/', () {
    test('o rascunho declara os itens sem depender do dado de teste', () {
      final conteudo = File(_arquivoDoRascunho).readAsStringSync();

      expect(conteudo, isNotEmpty);
      expect(
        _importsDeTesteEm(conteudo),
        isEmpty,
        reason: 'código de produção dependendo de test/ é o que a declaração '
            'em lib/ existe para evitar',
      );
    });

    test('a varredura acusa um import proibido, se houver', () {
      expect(
        _importsDeTesteEm("import '../../../../test/fixtures/rn30.dart';"),
        ['../../../../test/fixtures/rn30.dart'],
      );
      expect(
        _importsDeTesteEm('/// A lista não vem de test/fixtures/.\n'),
        isEmpty,
        reason: 'casar em texto acusaria o próprio doc que explica a regra',
      );
    });
  });
}
