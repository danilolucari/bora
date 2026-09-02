import 'nivel_do_link.dart';

/// O convite de uma festa: o **código** do link e o **nível** de quem abrir
/// (RN-23 · **AD-031**).
///
/// É só dado. A URL `bora.app/c/<codigo>` **não mora aqui**: ela é montada num
/// lugar só, na camada de copy da `galera`, para a string exibida e a copiada
/// serem a mesma.
///
/// [codigo] a Galera **lê, nunca gera** (A-03): gerar exige unicidade global,
/// que só o servidor da spec 09 garante.
///
/// Valor imutável com `==`/`hashCode` escritos à mão (A-19): `package:meta` é
/// dependência transitiva e importá-la derrubaria o `flutter analyze`.
class ConviteDaFesta {
  const ConviteDaFesta({required this.codigo, required this.nivel});

  /// O código do link — `rafa18` na festa de RN-30. Vazio enquanto a festa não
  /// tem link gerado.
  final String codigo;

  /// O que quem abrir o link vai poder fazer (RN-23).
  final NivelDoLink nivel;

  /// O convite de uma festa que ainda não tem código — festa recém-criada,
  /// antes de a spec 09 gerar o dela.
  ///
  /// Nasce em [NivelDoLink.padraoDeFestaNova]: é festa nova, não dado ausente.
  /// `codigo` vazio ⇒ a tela mostra o card do link sem URL.
  static const ConviteDaFesta vazio =
      ConviteDaFesta(codigo: '', nivel: NivelDoLink.padraoDeFestaNova);

  /// Copia trocando campos. O campo não informado é **preservado**; informar
  /// `codigo: ''` o substitui de verdade.
  ConviteDaFesta copyWith({String? codigo, NivelDoLink? nivel}) =>
      ConviteDaFesta(
        codigo: codigo ?? this.codigo,
        nivel: nivel ?? this.nivel,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConviteDaFesta &&
          other.codigo == codigo &&
          other.nivel == nivel;

  @override
  int get hashCode => Object.hash(codigo, nivel);
}
