import 'precisao.dart';

/// Garrafas de 2 L de refrigerante (RN-06 · CALC-10).
///
/// `max(1, ceil((adultos × 400 ml + crianças × 500 ml) × f / 2000))`. Criança
/// bebe **mais** refrigerante que adulto — os 500 ml são literais de RN-06.
///
/// Estado padrão (6 adultos + 1 criança, f = 1): 2900 ml ÷ 2000 = 1,45 →
/// **2 garrafas**, R$ 18.
///
/// O piso de 1 vale enquanto houver plateia; festa sem ninguém é barrada
/// antes, pela guarda de `pessoas == 0` do orquestrador (A-11).
int garrafasDeRefrigerante({
  required int adultos,
  required int criancas,
  required double fator,
}) =>
    unidadesComPisoDeUm((adultos * 400 + criancas * 500) * fator / 2000);

/// Litros de suco (RN-07 · CALC-11).
///
/// `max(1, ceil((adultos × 250 ml + crianças × 400 ml) × f / 1000))`. Também
/// aqui a criança bebe mais que o adulto.
///
/// A R$ 8/L. Estado padrão (6 adultos + 1 criança, f = 1): 1900 ml → **2 L**.
int litrosDeSuco({
  required int adultos,
  required int criancas,
  required double fator,
}) =>
    unidadesComPisoDeUm((adultos * 250 + criancas * 400) * fator / 1000);
