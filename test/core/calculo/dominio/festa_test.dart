import 'package:bora/core/calculo/dominio/festa.dart';
import 'package:bora/core/calculo/dominio/status_da_festa.dart';
import 'package:flutter_test/flutter_test.dart';

/// `const` no teste é a prova de que o construtor de [Festa] é `const`.
const Festa _churrasDoRafa = Festa(
  nome: 'CHURRAS DO RAFA 🔥',
  data: 'SÁB · 18 JUL',
  hora: '14H',
  local: 'Laje do Rafa — Vila Madalena',
  duracaoHoras: 4,
);

void main() {
  group('CALC-05 — Festa é um valor imutável', () {
    test('duas festas com os mesmos campos são iguais', () {
      const outra = Festa(
        nome: 'CHURRAS DO RAFA 🔥',
        data: 'SÁB · 18 JUL',
        hora: '14H',
        local: 'Laje do Rafa — Vila Madalena',
        duracaoHoras: 4,
      );

      expect(outra, _churrasDoRafa);
      expect(outra.hashCode, _churrasDoRafa.hashCode);
    });

    test('mudar um campo torna as festas diferentes', () {
      expect(_churrasDoRafa.copyWith(duracaoHoras: 6), isNot(_churrasDoRafa));
    });

    test('copyWith devolve uma cópia alterada e não muta a original', () {
      final passada = _churrasDoRafa.copyWith(status: StatusDaFesta.passada);

      expect(passada.status, StatusDaFesta.passada);
      expect(passada.nome, 'CHURRAS DO RAFA 🔥');
      expect(_churrasDoRafa.status, StatusDaFesta.chegando);
    });

    test('status nasce chegando quando não é informado', () {
      expect(_churrasDoRafa.status, StatusDaFesta.chegando);
    });

    test('data e hora são rótulos literais, não DateTime (A-23)', () {
      expect(_churrasDoRafa.data, 'SÁB · 18 JUL');
      expect(_churrasDoRafa.hora, '14H');
    });
  });
}
