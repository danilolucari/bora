/// A **única** forma de escrever dinheiro no produto — RN-13 · CALC-03.
///
/// Contrato de fronteira com a spec 01 `design-system`: a UI **nunca** formata
/// dinheiro por conta própria. Ela recebe a string pronta ou chama
/// [MoneyFormatter.reais]; nenhum componente conhece a regra de arredondamento
/// nem o separador de milhar.
///
/// Feito à mão, sem `package:intl` (A-18): o `pubspec.yaml` é território do
/// workflow paralelo e nenhuma dependência nova pode entrar.
abstract final class MoneyFormatter {
  /// `R$ ` + [valor] arredondado a **inteiro**, em pt-BR: `R$ 211`,
  /// `R$ 1.234`, `R$ 0`, `-R$ 5`.
  ///
  /// Sem centavos e sem separador decimal, por RN-13. O arredondamento
  /// acontece **uma única vez**, aqui — a aritmética interna da camada nunca
  /// arredonda antes, e total é sempre o arredondamento da soma exata, nunca a
  /// soma de parcelas já arredondadas.
  ///
  /// Meio afastado do zero: 30,5 vira 31. O sinal vem **antes** do `R$`.
  static String reais(num valor) {
    final inteiro = valor.round();
    final sinal = inteiro < 0 ? '-' : '';

    return '${sinal}R\$ ${_comSeparadorDeMilhar(inteiro.abs())}';
  }
}

/// Agrupa [valor] de três em três dígitos, da direita para a esquerda, com o
/// `.` do pt-BR.
String _comSeparadorDeMilhar(int valor) {
  final digitos = valor.toString();
  final agrupado = StringBuffer();

  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) agrupado.write('.');
    agrupado.write(digitos[i]);
  }

  return agrupado.toString();
}
