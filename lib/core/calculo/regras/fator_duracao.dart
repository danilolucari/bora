import 'dart:math' as math;

/// Fator de duração da festa — RN-02 · CALC-02.
///
/// Baseline 4h: `f = max(0.5, horas / 4)`. **Todo** consumível multiplica por
/// ele — 2h → 0.5 · 4h → 1 · 6h → 1.5 · dia todo (10h) → 2.5.
///
/// O piso de 0.5 é regra de negócio, não defesa: uma festa de uma hora ainda
/// compra metade do baseline.
///
/// O nome é o vocabulário da spec e do `CLAUDE.md` — não renomear.
double fatorDuracao(num horas) => math.max(0.5, horas / 4);
