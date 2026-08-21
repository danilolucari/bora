import 'dart:math' as math;

import '../dominio/contagem_de_pessoas.dart';
import 'precisao.dart';

/// Piso de quantidade por carne, em kg (RN-03).
const double _minimoDeKgPorCarne = 0.5;

/// Gramas de carne da festa inteira (RN-03 · CALC-07).
///
/// `(homens × 400 + mulheres × 300 + crianças × 200) × f`. Criança come, e
/// come menos — o que **não** entra na conta de criança é o racha (RN-14).
///
/// Estado padrão (3H + 3M + 1C, f = 1): 1200 + 900 + 200 = **2300 g**.
double gramasDeCarne({
  required ContagemDePessoas contagem,
  required double fator,
}) =>
    (contagem.homens * 400 +
        contagem.mulheres * 300 +
        contagem.criancas * 200) *
    fator;

/// Quilos de **cada** carne selecionada (RN-03 · CALC-07).
///
/// As gramas totais se dividem igualmente entre as carnes, e o resultado
/// arredonda para o décimo de quilo com piso de 0,5 kg. O arredondamento passa
/// por [kgArredondadoEmDecimos], que conta em **gramas** — arredondar em kg
/// devolveria 1,1 para 1150 g e quebraria o caso literal de R$ 211.
///
/// Estado padrão com bovina e frango: 2300 ÷ 2 = 1150 g → **1,2 kg** cada.
///
/// Sem nenhuma carne selecionada devolve **0,0**, sem dividir por zero. O piso
/// de 0,5 kg vale enquanto houver plateia; festa sem ninguém é barrada antes,
/// pela guarda de `pessoas == 0` do orquestrador (A-11).
double kgPorCarne({
  required double gramasTotais,
  required int carnesSelecionadas,
}) {
  if (carnesSelecionadas == 0) return 0;

  return math.max(
    _minimoDeKgPorCarne,
    kgArredondadoEmDecimos(gramasTotais / carnesSelecionadas),
  );
}
