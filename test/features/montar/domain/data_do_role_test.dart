import 'dart:io';

import 'package:bora/features/montar/domain/data_do_role.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fixtures/rn30_estado_inicial_tipado.dart';

const String _arquivoDoDominio = 'lib/features/montar/domain/data_do_role.dart';

/// A fonte sem comentário de linha — o doc do arquivo **cita** o relógio para
/// explicar por que ele não está lá, e citar não é chamar.
String _semComentarios(String fonte) =>
    fonte.replaceAll(RegExp(r'//.*'), '');

/// Um sábado de cada mês de 2026, escrito à mão — a entrada do teste dos 12
/// meses não pode sair da própria função que ele verifica.
final List<(DateTime, String)> _umSabadoPorMes = [
  (_Sabados.janeiro, 'SÁB · 17 JAN'),
  (_Sabados.fevereiro, 'SÁB · 21 FEV'),
  (_Sabados.marco, 'SÁB · 21 MAR'),
  (_Sabados.abril, 'SÁB · 18 ABR'),
  (_Sabados.maio, 'SÁB · 16 MAI'),
  (_Sabados.junho, 'SÁB · 20 JUN'),
  (_Sabados.julho, 'SÁB · 18 JUL'),
  (_Sabados.agosto, 'SÁB · 15 AGO'),
  (_Sabados.setembro, 'SÁB · 19 SET'),
  (_Sabados.outubro, 'SÁB · 17 OUT'),
  (_Sabados.novembro, 'SÁB · 21 NOV'),
  (_Sabados.dezembro, 'SÁB · 19 DEZ'),
];

/// Sábados reais de 2026, um por mês.
abstract final class _Sabados {
  static final janeiro = DateTime(2026, 1, 17);
  static final fevereiro = DateTime(2026, 2, 21);
  static final marco = DateTime(2026, 3, 21);
  static final abril = DateTime(2026, 4, 18);
  static final maio = DateTime(2026, 5, 16);
  static final junho = DateTime(2026, 6, 20);
  static final julho = DateTime(2026, 7, 18);
  static final agosto = DateTime(2026, 8, 15);
  static final setembro = DateTime(2026, 9, 19);
  static final outubro = DateTime(2026, 10, 17);
  static final novembro = DateTime(2026, 11, 21);
  static final dezembro = DateTime(2026, 12, 19);
}

void main() {
  group('MONT-15 / A-04 — proximoSabado', () {
    test('num sábado, devolve o sábado que vem — não hoje', () {
      expect(proximoSabado(_Sabados.julho), DateTime(2026, 7, 25));
    });

    test('num domingo, devolve o sábado dali a 6 dias', () {
      // 19 de julho de 2026 é o domingo seguinte ao sábado 18.
      expect(proximoSabado(DateTime(2026, 7, 19)), DateTime(2026, 7, 25));
    });

    test('numa sexta, devolve o sábado do dia seguinte', () {
      expect(proximoSabado(DateTime(2026, 7, 17)), _Sabados.julho);
    });

    test('os cinco dias úteis caem no sábado da mesma semana', () {
      final esperado = DateTime(2026, 7, 18);

      expect(proximoSabado(DateTime(2026, 7, 13)), esperado, reason: 'segunda');
      expect(proximoSabado(DateTime(2026, 7, 14)), esperado, reason: 'terça');
      expect(proximoSabado(DateTime(2026, 7, 15)), esperado, reason: 'quarta');
      expect(proximoSabado(DateTime(2026, 7, 16)), esperado, reason: 'quinta');
      expect(proximoSabado(DateTime(2026, 7, 17)), esperado, reason: 'sexta');
    });

    test('a virada de mês não quebra o rótulo', () {
      final sabado = proximoSabado(DateTime(2026, 7, 30));

      expect(sabado, DateTime(2026, 8, 1));
      expect(rotuloDeSabado(sabado), 'SÁB · 1 AGO');
    });

    test('a virada de ano não quebra o rótulo', () {
      final sabado = proximoSabado(DateTime(2026, 12, 31));

      expect(sabado, DateTime(2027, 1, 2));
      expect(rotuloDeSabado(sabado), 'SÁB · 2 JAN');
    });

    test('em qualquer dia de um ano bissexto o resultado é um sábado à frente,'
        ' a no máximo 7 dias', () {
      var dia = DateTime(2028, 1, 1);

      while (dia.isBefore(DateTime(2029, 1, 1))) {
        final sabado = proximoSabado(dia);

        expect(sabado.weekday, DateTime.saturday, reason: '$dia');
        expect(sabado.isAfter(dia), isTrue, reason: '$dia');
        expect(sabado.difference(dia).inDays, lessThanOrEqualTo(7),
            reason: '$dia');

        dia = DateTime(dia.year, dia.month, dia.day + 1);
      }
    });

    test('o relógio entra por parâmetro: nada de DateTime.now() no domínio',
        () {
      final fonte = _semComentarios(File(_arquivoDoDominio).readAsStringSync());

      expect(fonte, contains('DateTime proximoSabado(DateTime hoje)'));
      expect(
        fonte,
        isNot(contains('DateTime.now()')),
        reason: 'com o relógio de dentro, o default só seria testável no '
            'sábado',
      );
    });

    test('o mesmo hoje devolve sempre o mesmo sábado', () {
      expect(
        proximoSabado(DateTime(2026, 7, 15)),
        proximoSabado(DateTime(2026, 7, 15)),
      );
    });
  });

  group('MONT-15 / A-04 — o rótulo casa com o formato de Festa.data', () {
    test('18 de julho de 2026 sai exatamente como a data de RN-30', () {
      expect(
        rotuloDeSabado(_Sabados.julho),
        festaRn30Tipada.data,
        reason: 'o formato é o de T-02, comparado com a fixture e não com um '
            'literal reescrito no teste',
      );
    });

    test('os 12 meses têm abreviação em CAIXA ALTA e em pt-BR', () {
      for (final (sabado, esperado) in _umSabadoPorMes) {
        expect(rotuloDeSabado(sabado), esperado, reason: '${sabado.month}');
      }
    });

    test('dia de um dígito sai sem zero à esquerda', () {
      expect(rotuloDeSabado(DateTime(2026, 8, 1)), 'SÁB · 1 AGO');
    });

    test('formatar um dia que não é sábado é erro, não rótulo mentiroso', () {
      expect(
        () => rotuloDeSabado(DateTime(2026, 7, 19)),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
