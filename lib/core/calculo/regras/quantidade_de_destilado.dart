import 'precisao.dart';

/// Garrafas de 1 L de **cada** destilado selecionado (RN-09 · CALC-13).
///
/// `ml por destilado = adultos × 120 × f / nº selecionados`, e
/// `garrafas = max(1, ceil(ml / 1000))`. Os 120 ml por adulto se **dividem**
/// entre os destilados escolhidos: quem escolhe vodka e cachaça não bebe o
/// dobro, bebe metade de cada.
///
/// Estado padrão (6 adultos, f = 1, só cachaça): 720 ml → **1 garrafa**,
/// R$ 15.
///
/// Só adultos, por RN-09. Sem adulto **ou** sem destilado selecionado devolve
/// **0**, sem dividir por zero: o piso de 1 garrafa vale quando há quem beba
/// (A-12).
int garrafasPorDestilado({
  required int adultos,
  required double fator,
  required int destiladosSelecionados,
}) {
  if (adultos == 0 || destiladosSelecionados == 0) return 0;

  final ml = adultos * 120 * fator / destiladosSelecionados;

  return unidadesComPisoDeUm(ml / 1000);
}
