import 'precisao.dart';

/// Unidades de pão de alho (RN-04 · CALC-08).
///
/// `max(1, ceil(pessoas × 0,5 × f))` — meio pão por cabeça, criança inclusive,
/// vezes o fator de duração.
///
/// Estado padrão (7 pessoas, f = 1): 3,5 → **4 unidades**, R$ 24.
///
/// O piso de 1 vale enquanto houver plateia; festa sem ninguém é barrada
/// antes, pela guarda de `pessoas == 0` do orquestrador (A-11).
int unidadesDePaoDeAlho({required int pessoas, required double fator}) =>
    unidadesComPisoDeUm(pessoas * 0.5 * fator);

/// Garrafas de 1,5 L de água (RN-08 · CALC-12).
///
/// `max(1, ceil(pessoas × 400 ml × f / 1500))` — 400 ml por cabeça, criança
/// inclusive.
///
/// Estado padrão (7 pessoas, f = 1): 2800 ml ÷ 1500 = 1,867 → **2 garrafas**,
/// R$ 6.
int garrafasDeAgua({required int pessoas, required double fator}) =>
    unidadesComPisoDeUm(pessoas * 400 * fator / 1500);
