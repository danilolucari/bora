import 'festa_em_edicao.dart';

/// O contrato de **escrita** da festa — sem Flutter, sem Firebase (AD-029).
///
/// É a porta que `montar` usa para criar o rolê de `/roles/novo` e para gravar
/// nome, data e composição enquanto o anfitrião mexe nos controles.
/// `FestaRepository`, em `features/home/domain/`, continua sendo a porta de
/// **leitura da lista** e não é tocada: são dois contratos, sobre o mesmo
/// store, para dois consumidores.
///
/// A implementação do M1 é em memória (**AD-016**); no M2 vira Firestore sem
/// que bloc ou tela saibam.
///
/// **Sem `dispose()`**, de propósito: quem detém o ciclo de vida do store é a
/// porta de leitura, que já o expõe e já está registrada com `dispose` no
/// injector. Duas portas sobre o mesmo objeto com dois `dispose` fechariam o
/// controller duas vezes.
abstract class FestaEmEdicaoRepository {
  /// A festa de [id], **agora e a cada mudança**. `null` = não existe.
  ///
  /// `Stream`, e não `Future`, pela mesma razão da porta de leitura
  /// (**AD-016**): é o contrato que sobrevive à troca para Firestore no M2, em
  /// que a festa muda por fora — um convidado confirmando, outro dispositivo
  /// editando. Ler uma vez e desenhar obrigaria a reescrever a tela depois.
  Stream<FestaEmEdicao?> observarFesta(String id);

  /// Cria a festa e devolve o `festaId` — MONT-17.
  ///
  /// É o que transforma o rascunho de `/roles/novo` em festa persistida na
  /// primeira mudança, e o id devolvido é o que a rota passa a refletir.
  Future<String> criarFesta(FestaEmEdicao rascunho);

  /// Grava nome, data e composição de uma festa existente — MONT-18.
  Future<void> salvarFesta(String id, FestaEmEdicao festa);
}
