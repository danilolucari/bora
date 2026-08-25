import 'package:bora/core/calculo/dominio/dieta.dart';
import 'package:bora/core/calculo/dominio/papel_na_festa.dart';
import 'package:bora/core/calculo/dominio/pessoa.dart';
import 'package:bora/core/calculo/dominio/status_de_presenca.dart';
import 'package:bora/core/calculo/regras/preferencias.dart';
import 'package:flutter_test/flutter_test.dart';

Pessoa _pessoa(String nome, {Dieta? dieta, bool? bebe}) => Pessoa(
      nome: nome,
      papel: PapelNaFesta.convidado,
      status: StatusDePresenca.confirmado,
      dieta: dieta,
      bebe: bebe,
    );

void main() {
  group('CALC-15 — sem pessoas nomeadas, RN-05 fica intacta', () {
    test('a cerveja continua dimensionando pelos adultos', () {
      final efeitos = efeitosDasPreferencias(pessoas: [], adultos: 6);

      expect(
        efeitos.adultosQueBebem,
        6,
        reason: 'sem nomeados não há abstêmio conhecido a subtrair (A-06)',
      );
      expect(efeitos.incluirKitVeggie, isFalse);
      expect(efeitos.removerSuina, isFalse);
      expect(efeitos.bebem, 0);
    });
  });

  group('CALC-15 — dieta muda a lista (RN-21)', () {
    test('uma pessoa veggie já inclui o kit de legumes', () {
      final efeitos = efeitosDasPreferencias(
        pessoas: [_pessoa('ANA', dieta: Dieta.veggie)],
        adultos: 6,
      );

      expect(efeitos.veggies, 1);
      expect(efeitos.incluirKitVeggie, isTrue);
    });

    test('uma pessoa sem porco já remove a suína', () {
      final efeitos = efeitosDasPreferencias(
        pessoas: [_pessoa('LÉO', dieta: Dieta.semPorco)],
        adultos: 6,
      );

      expect(efeitos.semPorco, 1);
      expect(efeitos.removerSuina, isTrue);
    });

    test('comer de tudo não inclui kit nem remove suína', () {
      final efeitos = efeitosDasPreferencias(
        pessoas: [_pessoa('BIA', dieta: Dieta.tudo)],
        adultos: 6,
      );

      expect(efeitos.veggies, 0);
      expect(efeitos.semPorco, 0);
      expect(efeitos.incluirKitVeggie, isFalse);
      expect(efeitos.removerSuina, isFalse);
    });

    test('dieta não declarada não conta como veggie nem como sem porco', () {
      final efeitos = efeitosDasPreferencias(
        pessoas: [_pessoa('DUDA')],
        adultos: 6,
      );

      expect(
        efeitos.veggies,
        0,
        reason: 'null é ausência, não preferência declarada (A-08)',
      );
      expect(efeitos.semPorco, 0);
      expect(efeitos.incluirKitVeggie, isFalse);
      expect(efeitos.removerSuina, isFalse);
    });
  });

  group('CALC-15 — a cerveja dimensiona por quem bebe (A-06)', () {
    test('um abstêmio entre 6 adultos deixa 5 bases de cerveja', () {
      final efeitos = efeitosDasPreferencias(
        pessoas: [_pessoa('RAFA', bebe: false)],
        adultos: 6,
      );

      expect(efeitos.adultosQueBebem, 5);
    });

    test('a Duda, que não declarou se bebe, não reduz a cerveja', () {
      final efeitos = efeitosDasPreferencias(
        pessoas: [_pessoa('DUDA')],
        adultos: 6,
      );

      expect(
        efeitos.adultosQueBebem,
        6,
        reason: 'bebe == null não é abstêmia (A-08)',
      );
    });

    test('mais abstêmios que adultos param em 0, nunca negativo', () {
      final efeitos = efeitosDasPreferencias(
        pessoas: [
          _pessoa('A', bebe: false),
          _pessoa('B', bebe: false),
          _pessoa('C', bebe: false),
        ],
        adultos: 2,
      );

      expect(efeitos.adultosQueBebem, 0);
    });

    test('quem bebe e a base da cerveja são dois números diferentes', () {
      final efeitos = efeitosDasPreferencias(
        pessoas: [_pessoa('ANA', bebe: true)],
        adultos: 6,
      );

      expect(
        efeitos.bebem,
        1,
        reason: 'o resumo de RN-21 conta só as nomeadas que declararam beber',
      );
      expect(
        efeitos.adultosQueBebem,
        6,
        reason: 'nomear quem bebe não pode derrubar 18 latas para 3',
      );
    });
  });

  group('CALC-15 — resumo agregado de RN-21', () {
    test('com os três termos, sai a copy literal da regra', () {
      const efeitos = EfeitosDasPreferencias(
        veggies: 2,
        semPorco: 1,
        bebem: 3,
        adultosQueBebem: 6,
      );

      expect(
        resumoDasPreferencias(efeitos),
        'A lista já se ajusta às preferências: 2 veggie 🥗 · 1 sem porco 🚫 · '
            '3 bebem 🍺',
      );
    });

    test('termo zerado é omitido, junto com o separador', () {
      const efeitos = EfeitosDasPreferencias(
        veggies: 0,
        semPorco: 1,
        bebem: 3,
        adultosQueBebem: 6,
      );

      expect(
        resumoDasPreferencias(efeitos),
        'A lista já se ajusta às preferências: 1 sem porco 🚫 · 3 bebem 🍺',
      );
    });

    test('só um termo sobrando sai sem separador nenhum', () {
      const efeitos = EfeitosDasPreferencias(
        veggies: 1,
        semPorco: 0,
        bebem: 0,
        adultosQueBebem: 6,
      );

      expect(
        resumoDasPreferencias(efeitos),
        'A lista já se ajusta às preferências: 1 veggie 🥗',
      );
    });

    test('com os três zerados não sobra frase nenhuma', () {
      const efeitos = EfeitosDasPreferencias(
        veggies: 0,
        semPorco: 0,
        bebem: 0,
        adultosQueBebem: 6,
      );

      expect(resumoDasPreferencias(efeitos), isEmpty);
    });

    test('o resumo usa quem bebe, não a base da cerveja', () {
      const efeitos = EfeitosDasPreferencias(
        veggies: 0,
        semPorco: 0,
        bebem: 2,
        adultosQueBebem: 5,
      );

      expect(
        resumoDasPreferencias(efeitos),
        'A lista já se ajusta às preferências: 2 bebem 🍺',
      );
    });
  });
}
