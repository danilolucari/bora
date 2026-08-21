import '../dominio/saldo_de_pessoa.dart';
import 'cota.dart';

/// O saldo de cada pessoa em relação à cota justa — RN-15 · CALC-20.
///
/// `saldo = contribuição − cota`, com a cota vinda de [cotaPorAdulto]: o mesmo
/// valor para todo mundo, e **criança sempre de fora** (RN-14).
///
/// A ordem da lista é a ordem de [contribuicoes], que por sua vez é a ordem dos
/// participantes (RN-20). Isso não é detalhe de implementação: é a ordem em que
/// `calcularRacha` vai percorrer credores e devedores, e ela decide **quais**
/// linhas de acerto saem (A-14). Nada aqui reordena.
List<SaldoDePessoa> calcularSaldos({
  required Map<String, double> contribuicoes,
  required double total,
  required int adultos,
}) {
  final cota = cotaPorAdulto(total: total, adultos: adultos);

  return [
    for (final entrada in contribuicoes.entries)
      SaldoDePessoa(
        pessoa: entrada.key,
        contribuicao: entrada.value,
        cota: cota,
        saldo: entrada.value - cota,
      ),
  ];
}
