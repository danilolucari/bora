import '../../domain/resumo_de_festa.dart';

/// Os eventos da Home vêm **do repositório**, não do usuário.
///
/// A tela não pede nada: ela assina `observarFestas()` e desenha o que chega.
/// Os toques em botão são navegação, e navegação não passa pelo bloc (AD-020).
sealed class HomeEvent {
  const HomeEvent();
}

/// O repositório emitiu um estado novo — a semente ou uma mudança (RN-28).
class FestasRecebidas extends HomeEvent {
  const FestasRecebidas(this.festas);

  final List<ResumoDeFesta> festas;
}

/// O stream do repositório falhou (HOME-16).
class ObservacaoFalhou extends HomeEvent {
  const ObservacaoFalhou(this.erro, this.stackTrace);

  final Object erro;
  final StackTrace stackTrace;
}
