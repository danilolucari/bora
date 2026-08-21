/// A cota justa da festa — RN-14 · CALC-19.
///
/// `cota = total da festa ÷ nº de adultos participantes`. A copy do produto diz
/// exatamente o que a fórmula faz: *"entre 4 adultos, criança de fora"* —
/// **criança nunca entra no racha**. Total 320 entre 4 adultos dá cota 80, e é
/// dessa cota que saem os saldos do Teste A de RN-16.
///
/// Não confundir com o "≈ R$ X / cabeça" da tela Montar, que divide pelo total
/// de **pessoas** (`estimativaPorCabeca`, em `totais.dart`): os dois números
/// coexistem de propósito e nunca se unificam. A estimativa responde "quanto
/// sai a festa por cabeça"; a cota responde "quem paga quanto", e nessa
/// pergunta a criança nunca aparece.
///
/// Sem adulto nenhum a cota é **0,0** — nunca `NaN` nem `Infinity`.
double cotaPorAdulto({required double total, required int adultos}) =>
    adultos == 0 ? 0 : total / adultos;
