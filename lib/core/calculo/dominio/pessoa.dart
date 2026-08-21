import 'dieta.dart';
import 'papel_na_festa.dart';
import 'status_de_presenca.dart';

/// Uma pessoa nomeada da festa (arquivo 01 §6 · CALC-05).
///
/// Valor imutável: duas pessoas com os mesmos campos são **iguais**, porque a
/// identidade aqui é o próprio [nome] (A-24) — identificador de verdade nasce
/// quando o Firestore entrar.
///
/// [dieta] e [bebe] são **anuláveis** de propósito (A-08): `null` significa
/// *não declarado* e é distinto de [Dieta.tudo] e de `false`. A Duda de RN-30
/// é exatamente esse caso — nem come de tudo, nem é abstêmia; ninguém sabe. É
/// o que impede RN-21 de contá-la como quem não bebe ao dimensionar a cerveja.
///
/// Cor de avatar **não** existe aqui: é token, território da spec 01.
///
/// `==`/`hashCode` são escritos à mão porque `package:meta` é dependência
/// transitiva e importá-la derrubaria `flutter analyze` (A-19).
class Pessoa {
  const Pessoa({
    required this.nome,
    required this.papel,
    required this.status,
    this.dieta,
    this.bebe,
    this.voce = false,
  });

  final String nome;
  final PapelNaFesta papel;
  final StatusDePresenca status;

  /// `null` = dieta não declarada (A-08).
  final Dieta? dieta;

  /// `null` = não se sabe se bebe álcool (A-08).
  final bool? bebe;

  /// Marca a pessoa que está usando o app ("VOCÊ" na copy).
  final bool voce;

  /// Primeira letra do [nome], em caixa alta — o que o avatar mostra.
  String get inicial => nome[0].toUpperCase();

  Pessoa copyWith({
    String? nome,
    PapelNaFesta? papel,
    StatusDePresenca? status,
    Dieta? dieta,
    bool? bebe,
    bool? voce,
  }) =>
      Pessoa(
        nome: nome ?? this.nome,
        papel: papel ?? this.papel,
        status: status ?? this.status,
        dieta: dieta ?? this.dieta,
        bebe: bebe ?? this.bebe,
        voce: voce ?? this.voce,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pessoa &&
          other.nome == nome &&
          other.papel == papel &&
          other.status == status &&
          other.dieta == dieta &&
          other.bebe == bebe &&
          other.voce == voce;

  @override
  int get hashCode => Object.hash(nome, papel, status, dieta, bebe, voce);
}
