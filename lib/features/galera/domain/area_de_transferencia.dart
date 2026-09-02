/// A área de transferência do sistema, atrás de uma porta — A-07.
///
/// É a **única dependência externa** desta tela, e a razão de ela ter porta é
/// GAL-05: o contrato de falha precisa ser afirmável em teste, e um
/// `Clipboard.setData` chamado direto do bloc não é.
///
/// Dart puro: nenhum import de Flutter (GAL-19 AC7). Quem importa
/// `flutter/services.dart` é o adaptador, em `data/`.
abstract class AreaDeTransferencia {
  /// Põe [texto] na área de transferência.
  ///
  /// **A falha propaga.** Quem trata é o `GaleraBloc`: sem toast de sucesso,
  /// falha registrada e a URL ainda na tela para cópia à mão (GAL-05).
  /// Engolir o erro aqui apagaria esse critério — a tela não teria como saber
  /// que a cópia não aconteceu.
  Future<void> copiar(String texto);
}
