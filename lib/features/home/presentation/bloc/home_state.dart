import '../../domain/resumo_de_festa.dart';

/// Em que ponto a Home está — HOME-15, HOME-16.
enum SituacaoDaHome { carregando, comFestas, vazia, falhou }

/// O estado da Home: o que está chegando, o que já passou, e se chegou
/// confirmação nova.
///
/// Igualdade por valor, escrita à mão como em `EntrarState` e em
/// `ResumoDeFesta`: sem ela o `emit` do bloc não descarta emissão repetida, e
/// **toda** emissão do repositório reconstruiria o card, a pilha de avatares e
/// o ARQUIVO — inclusive as emissões idênticas que o Firestore vai produzir no
/// M2 (AD-016).
class HomeState {
  const HomeState({
    this.situacao = SituacaoDaHome.carregando,
    this.chegando = const [],
    this.passadas = const [],
    this.comConfirmacaoNova = const {},
  });

  final SituacaoDaHome situacao;

  /// As festas que ainda vão acontecer, na ordem do repositório.
  final List<ResumoDeFesta> chegando;

  /// O ARQUIVO de UC-24.
  final List<ResumoDeFesta> passadas;

  /// Os nomes das festas que ganharam confirmação desde a emissão anterior
  /// (**D-1**).
  ///
  /// Guardado aqui, e não em `ResumoDeFesta`, porque "nova" é propriedade de
  /// **duas emissões**, e o bloc é a única camada que vê as duas. Pôr o flag
  /// no dado obrigaria a fonte — Firestore, no M2 — a saber o que o anfitrião
  /// já tinha visto: estado de UI vazando para o banco.
  ///
  /// Identificado por nome porque `Festa` não tem id: a spec nunca definiu um
  /// (A-21 deixou de fora só link e nível). Quando a spec 09 criar a
  /// identidade da festa, é aqui que ela entra.
  final Set<String> comConfirmacaoNova;

  /// `true` quando [resumo] ganhou confirmação desde a emissão anterior —
  /// é o que faz o atalho amarelo do acerto aparecer (RN-28, T-02).
  ///
  /// A tela pergunta ao estado em vez de comparar nomes: a regra de
  /// pareamento é do bloc.
  bool temConfirmacaoNova(ResumoDeFesta resumo) =>
      comConfirmacaoNova.contains(resumo.festa.nome);

  HomeState copyWith({
    SituacaoDaHome? situacao,
    List<ResumoDeFesta>? chegando,
    List<ResumoDeFesta>? passadas,
    Set<String>? comConfirmacaoNova,
  }) =>
      HomeState(
        situacao: situacao ?? this.situacao,
        chegando: chegando ?? this.chegando,
        passadas: passadas ?? this.passadas,
        comConfirmacaoNova: comConfirmacaoNova ?? this.comConfirmacaoNova,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeState &&
          other.situacao == situacao &&
          _mesmaLista(other.chegando, chegando) &&
          _mesmaLista(other.passadas, passadas) &&
          _mesmoConjunto(other.comConfirmacaoNova, comConfirmacaoNova);

  @override
  int get hashCode => Object.hash(
        situacao,
        Object.hashAll(chegando),
        Object.hashAll(passadas),
        Object.hashAllUnordered(comConfirmacaoNova),
      );

  static bool _mesmaLista(List<ResumoDeFesta> a, List<ResumoDeFesta> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _mesmoConjunto(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}
