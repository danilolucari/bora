/// RN-22 e RN-23 como **regra de domínio consultável** — a metade "regra" da
/// **AD-031**, cujo dado (`NivelDoLink`, `ConviteDaFesta`) mora em
/// `core/festas/`.
///
/// **Dart puro: nenhum import de Flutter** (GAL-19 AC7). É o que permite à
/// spec 09 traduzir esta mesma tabela em security rules do Firestore sem
/// arrastar UI junto.
///
/// `convite`, `convidado` e `custos` **consultam** estas funções. Nenhuma
/// feature reimplementa a tabela: três cópias divergem uma a uma sem que
/// nenhum teste perceba.
library;

import '../../../core/calculo/calculo.dart';
import '../../../core/festas/festas.dart';

/// As oito coisas que um papel pode ou não fazer numa festa — RN-22.
///
/// As seis primeiras saem das linhas literais de RN-22. As duas últimas são a
/// diferença que a regra deixou implícita entre ANFITRIÃO ("tudo") e
/// CO-ANFITRIÃO ("edita tudo e cobra a galera"), e que os atores de UC-12
/// ("somente anfitrião") e UC-13 ("anfitrião") fixam (A-19).
enum Capacidade {
  verAFesta,
  confirmarPresenca,
  marcarOQueLeva,
  ajustarALista,
  editarTudo,
  cobrarAGalera,
  gerenciarPapeis,
  configurarNivelDoLink,
}

/// RN-22, linha a linha.
///
/// `const` e **privado**: o acesso é por [capacidadesDe] e [pode]. Sendo
/// `const`, o conjunto devolvido é imutável de verdade — mutá-lo lança.
const Map<PapelNaFesta, Set<Capacidade>> _tabelaRn22 = {
  // "tudo — Anfitrião manda em tudo, acesso fixo 👑"
  PapelNaFesta.anfitriao: {
    Capacidade.verAFesta,
    Capacidade.confirmarPresenca,
    Capacidade.marcarOQueLeva,
    Capacidade.ajustarALista,
    Capacidade.editarTudo,
    Capacidade.cobrarAGalera,
    Capacidade.gerenciarPapeis,
    Capacidade.configurarNivelDoLink,
  },
  // "edita tudo e cobra a galera" — menos as duas exclusivas do dono (A-19).
  PapelNaFesta.coAnfitriao: {
    Capacidade.verAFesta,
    Capacidade.confirmarPresenca,
    Capacidade.marcarOQueLeva,
    Capacidade.ajustarALista,
    Capacidade.editarTudo,
    Capacidade.cobrarAGalera,
  },
  // "marca o que leva e ajusta a lista"
  PapelNaFesta.convidado: {
    Capacidade.verAFesta,
    Capacidade.confirmarPresenca,
    Capacidade.marcarOQueLeva,
    Capacidade.ajustarALista,
  },
  // "vê a festa e confirma presença"
  PapelNaFesta.soVe: {
    Capacidade.verAFesta,
    Capacidade.confirmarPresenca,
  },
};

/// As capacidades de [papel] — o conjunto é **imutável**.
Set<Capacidade> capacidadesDe(PapelNaFesta papel) => _tabelaRn22[papel]!;

/// Se [papel] pode [capacidade] — a pergunta que as specs 08, 09 e 10 fazem
/// em vez de reimplementar RN-22.
bool pode(PapelNaFesta papel, Capacidade capacidade) =>
    capacidadesDe(papel).contains(capacidade);

/// O papel com que entra quem abrir um link de [nivel] — RN-23 lido contra
/// RN-22 (GAL-20 AC5).
///
/// **Só a tradução.** Quem aplica o papel na abertura do link é a spec 09; e o
/// papel de quem já entrou **não** muda quando o nível muda (AD-026).
PapelNaFesta papelDoNivel(NivelDoLink nivel) => switch (nivel) {
      NivelDoLink.soVer => PapelNaFesta.soVe,
      NivelDoLink.editarLista => PapelNaFesta.convidado,
      NivelDoLink.coAnfitriao => PapelNaFesta.coAnfitriao,
    };

/// O papel de quem está usando o app, pela marca `voce` de [Pessoa].
///
/// **Sem ninguém marcado, devolve [PapelNaFesta.anfitriao]** — premissa P-1,
/// declarada. Razão: `/roles/:festaId/**` está atrás da guarda de sessão
/// (AD-017) e é a área do dono do rolê; uma festa sem pessoa nomeada é uma
/// festa recém-criada, e GAL-24 AC2 exige que o card do link e o CTA
/// continuem funcionais ali.
///
/// Não contraria a A-12: menor privilégio lá trata de **dado desconhecido que
/// concede acesso a estranhos**; aqui o sujeito é o dono autenticado da rota.
/// A autorização de verdade é servidora e nasce na spec 09.
PapelNaFesta papelDoUsuario(List<Pessoa> pessoas) {
  for (final pessoa in pessoas) {
    if (pessoa.voce) return pessoa.papel;
  }
  return PapelNaFesta.anfitriao;
}
