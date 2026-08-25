import 'precisao.dart';

/// Latas de cerveja (RN-05 · CALC-09).
///
/// `max(1, ceil(adultosQueBebem × 1000 ml × f / 350))` — um litro por cabeça
/// que bebe, em lata de 350 ml, a R$ 4 cada.
///
/// **O parâmetro é `adultosQueBebem`, não `adultos`, de propósito.** RN-05
/// dimensiona por adultos, mas RN-21 substitui essa base por quem bebe assim
/// que houver pessoas nomeadas; quem calcula a substituição é
/// `efeitosDasPreferencias` (A-06), que devolve
/// `max(0, adultos − nomeados com bebe == false)`. Sem pessoas nomeadas esse
/// número **é** `adultos`, e RN-05 fica intacta — por isso a regra não precisa
/// saber qual dos dois mundos a chamou.
///
/// Estado padrão (6 adultos, f = 1): 6000 ml ÷ 350 = 17,14 → **18 latas**,
/// R$ 72.
///
/// Ninguém que beba ⇒ **0 latas**, não 1: o piso de RN-05 existe para não
/// comprar "0,4 lata" quando há plateia, não para comprar cerveja para plateia
/// nenhuma (A-12). É o caso da festa só de crianças.
int latasDeCerveja({required int adultosQueBebem, required double fator}) {
  if (adultosQueBebem == 0) return 0;

  return unidadesComPisoDeUm(adultosQueBebem * 1000 * fator / 350);
}
