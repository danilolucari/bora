import '../dominio/despesa.dart';
import '../dominio/item_de_lista.dart';

/// Quanto cada participante já colocou na festa — RN-20 · CALC-18.
///
/// A copy do produto é literal: *"O que você levar desconta da sua parte no
/// racha"*. A contribuição de uma pessoa é a soma do [ItemDeLista.valor] dos
/// itens que ela assumiu ([ItemDeLista.quemLeva]) **mais** o valor das
/// despesas que ela adiantou ([Despesa.quemPagou]).
///
/// Duas garantias que o resto da fase 4 consome:
///
/// - **Todo participante aparece no mapa**, mesmo sem ter levado nada — com
///   `0.0`, nunca ausente e nunca `null`. É o que faz LÉO e BIA existirem como
///   devedores nos Testes A e B de RN-16.
/// - **A ordem do mapa é a ordem de [participantes]**, e ela é comportamento
///   observável: é a ordem em que RN-16 percorre credores e devedores (A-14).
///   O literal de mapa do Dart preserva a ordem de inserção; nada aqui
///   reordena por valor.
///
/// Item sem dono e nome que não está em [participantes] são simplesmente
/// ignorados: a contribuição é sempre de alguém que está no racha.
Map<String, double> contribuicoesPorPessoa({
  required Iterable<String> participantes,
  Iterable<ItemDeLista> itens = const [],
  Iterable<Despesa> despesas = const [],
}) {
  final contribuicoes = <String, double>{
    for (final participante in participantes) participante: 0,
  };

  void somar(String? pessoa, double valor) {
    if (pessoa == null) return;
    final atual = contribuicoes[pessoa];
    if (atual == null) return;
    contribuicoes[pessoa] = atual + valor;
  }

  for (final item in itens) {
    somar(item.quemLeva, item.valor);
  }
  for (final despesa in despesas) {
    somar(despesa.quemPagou, despesa.valor);
  }

  return contribuicoes;
}

/// A soma **exata** de tudo que a galera colocou — RN-20 · CALC-18.
///
/// Sem arredondar em passo nenhum, pela política de precisão da camada: no
/// Teste A de RN-16, 200 + 120 + 0 + 0 = 320.
double totalDasContribuicoes(Map<String, double> contribuicoes) =>
    contribuicoes.values.fold<double>(0, (soma, valor) => soma + valor);
