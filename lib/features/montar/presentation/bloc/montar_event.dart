import '../../../../core/calculo/calculo.dart';

/// Qual das três linhas do card "CONFIRMADOS + EXTRAS SEM APP" mudou.
///
/// As três de T-03 — não há uma quarta, e a contagem inteira governa o
/// cálculo enquanto não existirem pessoas nomeadas (A-10).
enum TipoDeCabeca { homens, mulheres, criancas }

/// Os eventos da tela Montar.
///
/// **O bloc não navega** (AD-020): os dois CTAs de saída são navegação comum
/// e quem chama `context.go` é a página.
sealed class MontarEvent {
  const MontarEvent();
}

/// Um stepper subiu ou desceu — MONT-02, MONT-14.
///
/// [delta] é ±1: nenhuma spec define auto-repeat, e o piso de 0 é aplicado no
/// handler (UC-03 E1).
class ContagemAlterada extends MontarEvent {
  const ContagemAlterada(this.tipo, this.delta);

  final TipoDeCabeca tipo;
  final int delta;
}

/// Um chip foi tocado — MONT-02, MONT-20.
///
/// **Alterna**, não liga: `Set.add`/`remove` torna o toque repetido
/// determinístico por construção, sem estado paralelo para desincronizar.
class ItemAlternado extends MontarEvent {
  const ItemAlternado(this.chave);

  final ChaveItem chave;
}

/// O segmented de duração mudou — 2h, 4h, 6h ou "Dia" (10h, RN-02).
class DuracaoAlterada extends MontarEvent {
  const DuracaoAlterada(this.horas);

  final int horas;
}
