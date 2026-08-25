import 'package:bora/core/calculo/dominio/dieta.dart';
import 'package:bora/core/calculo/dominio/papel_na_festa.dart';
import 'package:bora/core/calculo/dominio/pessoa.dart';
import 'package:bora/core/calculo/dominio/status_da_festa.dart';
import 'package:bora/core/calculo/dominio/status_de_presenca.dart';
import 'package:flutter_test/flutter_test.dart';

/// `const` no teste é a prova de que o construtor de [Pessoa] é `const`: se
/// deixar de ser, este arquivo não compila.
const Pessoa _rafa = Pessoa(
  nome: 'Rafa',
  papel: PapelNaFesta.anfitriao,
  status: StatusDePresenca.confirmado,
  dieta: Dieta.tudo,
  bebe: true,
  voce: true,
);

const Pessoa _duda = Pessoa(
  nome: 'Duda',
  papel: PapelNaFesta.soVe,
  status: StatusDePresenca.pendente,
);

void main() {
  group('CALC-05 — os enums do domínio carregam as chaves do arquivo 01 §6',
      () {
    test('Dieta tem tudo, veggie e semporco', () {
      expect(Dieta.values.map((d) => d.chave).toList(),
          ['tudo', 'veggie', 'semporco']);
      expect(Dieta.porChave('semporco'), Dieta.semPorco);
    });

    test('PapelNaFesta tem host, cohost, guest e viewer', () {
      expect(PapelNaFesta.values.map((p) => p.chave).toList(),
          ['host', 'cohost', 'guest', 'viewer']);
      expect(PapelNaFesta.porChave('cohost'), PapelNaFesta.coAnfitriao);
    });

    test('StatusDePresenca tem confirmado, pendente e recusou', () {
      expect(StatusDePresenca.values.map((s) => s.chave).toList(),
          ['confirmado', 'pendente', 'recusou']);
      expect(StatusDePresenca.porChave('recusou'), StatusDePresenca.recusou);
    });

    test('StatusDaFesta tem chegando e passada', () {
      expect(
          StatusDaFesta.values.map((s) => s.chave).toList(),
          ['chegando', 'passada']);
      expect(StatusDaFesta.porChave('passada'), StatusDaFesta.passada);
    });

    test('porChave devolve null para chave desconhecida', () {
      expect(Dieta.porChave('vegano'), isNull);
      expect(PapelNaFesta.porChave('admin'), isNull);
      expect(StatusDePresenca.porChave('talvez'), isNull);
      expect(StatusDaFesta.porChave('amanha'), isNull);
    });
  });

  group('CALC-05 — Pessoa é um valor imutável', () {
    test('duas pessoas com os mesmos campos são iguais', () {
      const outra = Pessoa(
        nome: 'Rafa',
        papel: PapelNaFesta.anfitriao,
        status: StatusDePresenca.confirmado,
        dieta: Dieta.tudo,
        bebe: true,
        voce: true,
      );

      expect(outra, _rafa);
      expect(outra.hashCode, _rafa.hashCode);
    });

    test('mudar um campo torna as pessoas diferentes', () {
      expect(_rafa.copyWith(nome: 'Rafael'), isNot(_rafa));
    });

    test('copyWith devolve uma cópia alterada e não muta a original', () {
      final confirmada = _duda.copyWith(status: StatusDePresenca.confirmado);

      expect(confirmada.status, StatusDePresenca.confirmado);
      expect(confirmada.nome, 'Duda');
      expect(_duda.status, StatusDePresenca.pendente);
    });

    test('inicial é a primeira letra do nome em caixa alta', () {
      expect(_rafa.inicial, 'R');
      expect(_duda.inicial, 'D');
      expect(
        const Pessoa(
          nome: 'léo',
          papel: PapelNaFesta.convidado,
          status: StatusDePresenca.confirmado,
        ).inicial,
        'L',
      );
    });
  });

  group('CALC-05 — dieta e bebida não declaradas são null (A-08)', () {
    test('a Duda de RN-30 nasce sem dieta e sem bebida', () {
      expect(_duda.dieta, isNull);
      expect(_duda.bebe, isNull);
    });

    test('bebe null é distinto de bebe false', () {
      final abstemia = _duda.copyWith(bebe: false);

      expect(abstemia.bebe, isFalse);
      expect(abstemia, isNot(_duda));
    });

    test('dieta null é distinta de Dieta.tudo', () {
      final comeDeTudo = _duda.copyWith(dieta: Dieta.tudo);

      expect(comeDeTudo.dieta, Dieta.tudo);
      expect(comeDeTudo, isNot(_duda));
    });
  });
}
