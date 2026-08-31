import '../../../../core/calculo/calculo.dart';
import '../../../../core/festas/festas.dart';

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

/// O nome do rolê foi editado no header — MONT-15 (P1-5 AC3, AC6).
class NomeAlterado extends MontarEvent {
  const NomeAlterado(this.nome);

  final String nome;
}

/// A data do rolê foi editada no header — MONT-15.
///
/// Texto livre: `Festa.data` é **rótulo**, não `DateTime` (A-23), e nenhuma
/// tela de `04`/`06` desenha date picker.
class DataAlterada extends MontarEvent {
  const DataAlterada(this.data);

  final String data;
}

/// O repositório emitiu a festa observada — interno, MONT-16, MONT-18.
///
/// `null` = a festa de [MontarBloc] não existe: a rota é válida, o dado é que
/// não está lá.
class FestaRecebida extends MontarEvent {
  const FestaRecebida(this.festa);

  final FestaEmEdicao? festa;
}

/// `criarFesta` devolveu o id do rolê recém-criado — interno, MONT-17.
///
/// É por ele que o `festaId` entra no estado, e é o estado que a página
/// observa para trocar a URL do rascunho pela da festa.
class FestaCriada extends MontarEvent {
  const FestaCriada(this.festaId);

  final String festaId;
}
