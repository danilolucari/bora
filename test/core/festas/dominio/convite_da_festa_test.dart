// A porta de entrada da camada é o barrel — este import é, ele mesmo, a
// asserção de que `festas.dart` exporta `ConviteDaFesta`.
import 'package:bora/core/festas/festas.dart';
import 'package:flutter_test/flutter_test.dart';

const ConviteDaFesta _rafa = ConviteDaFesta(
  codigo: 'rafa18',
  nivel: NivelDoLink.editarLista,
);

void main() {
  group('GAL-21 — o convite vazio de uma festa sem link gerado', () {
    test('nasce sem código e no nível de festa nova', () {
      expect(ConviteDaFesta.vazio.codigo, '');
      expect(
        ConviteDaFesta.vazio.nivel,
        NivelDoLink.padraoDeFestaNova,
        reason: 'festa nova é EDITAR LISTA, não o SÓ VER de dado ausente',
      );
    });
  });

  group('AD-031 — o convite é um valor, comparado por conteúdo', () {
    test('dois convites de mesmo código e mesmo nível são iguais', () {
      const outro = ConviteDaFesta(
        codigo: 'rafa18',
        nivel: NivelDoLink.editarLista,
      );

      expect(_rafa, outro);
      expect(_rafa.hashCode, outro.hashCode);
    });

    test('trocar só o código separa os dois', () {
      const outro = ConviteDaFesta(
        codigo: 'rafa19',
        nivel: NivelDoLink.editarLista,
      );

      expect(_rafa, isNot(outro));
      expect(_rafa.hashCode, isNot(outro.hashCode));
    });

    test('trocar só o nível separa os dois', () {
      const outro = ConviteDaFesta(
        codigo: 'rafa18',
        nivel: NivelDoLink.coAnfitriao,
      );

      expect(_rafa, isNot(outro));
      expect(_rafa.hashCode, isNot(outro.hashCode));
    });
  });

  group('AD-031 — copyWith troca o informado e preserva o resto', () {
    test('trocar o nível preserva o código', () {
      final novo = _rafa.copyWith(nivel: NivelDoLink.soVer);

      expect(novo.nivel, NivelDoLink.soVer);
      expect(novo.codigo, 'rafa18');
    });

    test('trocar o código preserva o nível', () {
      final novo = _rafa.copyWith(codigo: 'bia07');

      expect(novo.codigo, 'bia07');
      expect(novo.nivel, NivelDoLink.editarLista);
    });

    test('código vazio é substituição de verdade, não "não informado"', () {
      final novo = _rafa.copyWith(codigo: '');

      expect(
        novo.codigo,
        isEmpty,
        reason: 'a festa que perde o link volta ao card sem URL',
      );
      expect(novo.nivel, NivelDoLink.editarLista);
    });

    test('sem argumento nenhum devolve um convite igual ao original', () {
      expect(_rafa.copyWith(), _rafa);
    });
  });
}
