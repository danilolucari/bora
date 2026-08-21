/// A contagem de cabeças da festa — RN-01 · CALC-01.
///
/// É o card "CONFIRMADOS + EXTRAS SEM APP" de T-03 **inteiro**: um tipo só,
/// cobrindo confirmados e extras sem app (A-22). Não existe um segundo tipo
/// para "extras" porque somar duas populações exigiria inventar gramas para as
/// pessoas nomeadas — e `Pessoa` não tem sexo nem idade (A-05). As pessoas
/// nomeadas entram no cálculo com **preferências e identidade** (RN-15..RN-21),
/// nunca com cabeça.
///
/// Estado padrão do produto: 3 homens + 3 mulheres + 1 criança → 6 adultos e
/// 7 pessoas.
///
/// **Não é `const`**: o construtor valida, e construtor `const` não lança. O
/// ganho — é impossível existir contagem negativa — vale a perda.
class ContagemDePessoas {
  ContagemDePessoas({
    this.homens = 0,
    this.mulheres = 0,
    this.criancas = 0,
  }) {
    _recusaNegativo(homens, 'homens');
    _recusaNegativo(mulheres, 'mulheres');
    _recusaNegativo(criancas, 'criancas');
  }

  final int homens;
  final int mulheres;
  final int criancas;

  /// RN-01: `adultos = homens + mulheres`.
  int get adultos => homens + mulheres;

  /// RN-01: `pessoas = adultos + crianças`.
  int get pessoas => adultos + criancas;

  ContagemDePessoas copyWith({int? homens, int? mulheres, int? criancas}) =>
      ContagemDePessoas(
        homens: homens ?? this.homens,
        mulheres: mulheres ?? this.mulheres,
        criancas: criancas ?? this.criancas,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContagemDePessoas &&
          other.homens == homens &&
          other.mulheres == mulheres &&
          other.criancas == criancas;

  @override
  int get hashCode => Object.hash(homens, mulheres, criancas);
}

/// Barra contagem negativa **nomeando o campo** — erro de programação, ruidoso
/// por design: a UI nunca desce de 0 (T-03).
void _recusaNegativo(int valor, String campo) {
  if (valor < 0) {
    throw ArgumentError.value(valor, campo, 'não pode ser negativo');
  }
}
