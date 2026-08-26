import 'package:bora/features/home/presentation/home_textos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HOME-06 — o subtítulo é derivado, não literal (A-05)', () {
    test('com a fixture de RN-30, dá a string literal de T-02', () {
      expect(
        HomeTextos.subtitulo(chegando: 1, passadas: 2),
        '1 festa chegando · 2 passadas',
      );
    });

    test('pluraliza a esquerda', () {
      expect(
        HomeTextos.subtitulo(chegando: 3, passadas: 2),
        '3 festas chegando · 2 passadas',
      );
    });

    test('singulariza a direita', () {
      expect(
        HomeTextos.subtitulo(chegando: 1, passadas: 1),
        '1 festa chegando · 1 passada',
      );
    });
  });

  group('HOME-15 — o subtítulo de quem não tem festa', () {
    test('sem nada, lê só a metade da esquerda', () {
      expect(
        HomeTextos.subtitulo(chegando: 0, passadas: 0),
        'nenhuma festa chegando',
      );
    });

    test('com passadas e nenhuma chegando, as duas metades valem (AC4)', () {
      expect(
        HomeTextos.subtitulo(chegando: 0, passadas: 2),
        'nenhuma festa chegando · 2 passadas',
      );
    });

    test('sem passada nenhuma, a metade da direita não aparece', () {
      expect(
        HomeTextos.subtitulo(chegando: 1, passadas: 0),
        '1 festa chegando',
      );
      expect(
        HomeTextos.subtitulo(chegando: 1, passadas: 0),
        isNot(contains('0 passadas')),
        reason: '"· 0 passadas" seria ruído, e nenhuma spec o escreve',
      );
    });
  });
}
