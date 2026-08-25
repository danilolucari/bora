import 'dart:math' as math;

import '../dominio/linha_de_acerto.dart';
import '../dominio/saldo_de_pessoa.dart';
import 'precisao.dart';

/// Quanto ainda falta a uma pessoa receber ou pagar enquanto o racha corre.
class _Restante {
  _Restante(this.pessoa, this.valor);

  final String pessoa;
  double valor;
}

/// O algoritmo do racha — RN-16 · CALC-21.
///
/// Separa credores (`saldo > tolerância`) e devedores (`saldo < −tolerância`),
/// percorre os devedores **em ordem** e faz cada um pagar os credores **em
/// ordem**, com `parcela = min(dívida restante, crédito restante)`, avançando o
/// credor quando o crédito dele zera na tolerância.
///
/// ⚠️ **Nunca ordene credores nem devedores por valor.** A ordem de entrada é
/// comportamento observável, e o Teste B de RN-16 discrimina (A-14): com
/// Rafa +105, Ana +25, Léo −35, Bia −95, a ordem de entrada produz
/// `LÉO→RAFA 35 · BIA→RAFA 70 · BIA→ANA 25`, que é o que a spec exige;
/// ordenar por valor decrescente produziria
/// `BIA→RAFA 95 · LÉO→RAFA 10 · LÉO→ANA 25` — três linhas certas na soma e
/// erradas no conteúdo, com a spec violada em silêncio.
///
/// Nenhuma linha de valor até um centavo é emitida: resíduo de `double` não
/// vira cobrança (A-13).
///
/// Sem credores, sem devedores ou sem saldo nenhum, o resultado é lista vazia —
/// nunca lança. E quando o `total` usado nos saldos não bate com a soma das
/// contribuições, o algoritmo esgota o lado menor e para; é o comportamento
/// declarado, não uma exceção.
List<LinhaDeAcerto> calcularRacha(List<SaldoDePessoa> saldos) {
  final credores = <_Restante>[];
  final devedores = <_Restante>[];

  for (final saldo in saldos) {
    if (saldo.saldo > toleranciaDeCentavo) {
      credores.add(_Restante(saldo.pessoa, saldo.saldo));
    } else if (saldo.saldo < -toleranciaDeCentavo) {
      devedores.add(_Restante(saldo.pessoa, -saldo.saldo));
    }
  }

  final linhas = <LinhaDeAcerto>[];
  var indiceDoCredor = 0;

  for (final devedor in devedores) {
    while (indiceDoCredor < credores.length &&
        !ehZeroNaTolerancia(devedor.valor)) {
      final credor = credores[indiceDoCredor];
      final parcela = math.min(devedor.valor, credor.valor);

      // A parcela é sempre maior que um centavo: o `while` só roda com dívida
      // acima da tolerância, e o credor da vez também está acima dela — os que
      // caem abaixo são filtrados na entrada ou saem pelo `indiceDoCredor++`.
      // É o que garante que nenhuma linha de resíduo seja emitida.
      linhas.add(
        LinhaDeAcerto(de: devedor.pessoa, para: credor.pessoa, valor: parcela),
      );

      devedor.valor -= parcela;
      credor.valor -= parcela;

      if (ehZeroNaTolerancia(credor.valor)) indiceDoCredor++;
    }
  }

  return linhas;
}
