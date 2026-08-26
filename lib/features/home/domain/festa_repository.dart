import 'resumo_de_festa.dart';

/// O contrato de leitura da Home — sem Flutter, sem Firebase (HOME-19).
///
/// **Um método de leitura só.** A Home não cria, não edita e não apaga festa:
/// `/roles/novo` é da spec 05 `montar`. Porta com método que ninguém chama é
/// contrato inventado, e este é herdado por seis specs.
///
/// A implementação do M1 é em memória (**AD-016**); no M2 vira Firestore sem
/// que bloc ou tela saibam. É essa troca que a porta torna barata.
abstract class FestaRepository {
  /// As festas do usuário, **agora e a cada mudança**.
  ///
  /// `Stream`, e não `Future`, por causa de RN-28: o contador do anfitrião
  /// muda **sem refresh** quando um convidado confirma. Ler uma vez e desenhar
  /// faria a spec 09 reescrever a Home inteira (A-02).
  Stream<List<ResumoDeFesta>> observarFestas();

  /// Libera o que a implementação mantiver aberto. Inscrição vazada contamina
  /// o teste seguinte — a mesma razão de `AutenticacaoRepository.dispose`.
  Future<void> dispose();
}
