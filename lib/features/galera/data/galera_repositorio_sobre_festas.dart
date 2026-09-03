import '../../../core/calculo/calculo.dart';
import '../../../core/festas/festas.dart';
import '../../../core/observability/app_logger.dart';
import '../domain/chave_de_pessoa.dart';
import '../domain/galera_da_festa.dart';
import '../domain/galera_repository.dart';

/// O `name` de tudo o que este adaptador registra no [AppLogger] (AD-005).
const String _nome = 'galera';

/// GAL-18, pela ida: ninguém **recebe** o papel de anfitrião.
///
/// A referência a RN-22 fica no doc, e não na mensagem, porque a varredura de
/// GAL-15 AC11 lê o arquivo inteiro atrás de literal numérico — e um "RN-22"
/// dentro de uma string é indistinguível de uma constante de fórmula.
const String _anfitriaoNaoEhAtribuivel =
    'papel de anfitrião recusado: o anfitrião é fixo e não é atribuível por '
    'caminho nenhum';

/// GAL-18, pela volta: o anfitrião não **perde** o papel (RN-22, "fixo, 1").
const String _anfitriaoNaoEhRemovivel =
    'troca de papel recusada: o alvo é o anfitrião da festa, e o papel dele é '
    'fixo';

/// A implementação da porta da Galera **sobre o registro da festa** — não
/// sobre um store próprio.
///
/// SPEC_DEVIATION: a A-01 da `spec.md` pediu "porta própria com impl em
/// memória sobre a mesma fonte de dado da Home", escrita antes de a
/// `FestaEmEdicaoRepository` existir. O desenho a honra no que ela quis dizer
/// — a porta é própria, é reativa e mora em `domain/` — mas a implementação
/// **não tem store**: é uma vista sobre o registro que já existe
/// (`design.md` §2.1, abordagem B).
/// Reason: com store paralelo, mudar a dieta da Bia não mudaria a lista da
/// festa (GAL-14 falharia) e dois registros da mesma festa divergiriam sem
/// que nada avisasse (GAL-09 falharia). Sendo vista, GAL-14 é consequência
/// estrutural em vez de disciplina.
///
/// **Nenhuma aritmética mora aqui.** As quantidades de RN-03, RN-05 e RN-21
/// saem inteiras de `core/calculo` sobre o registro que esta classe grava
/// (GAL-15 AC11).
class GaleraRepositorioSobreFestas implements GaleraRepository {
  const GaleraRepositorioSobreFestas(this._festas, this._logger);

  final FestaEmEdicaoRepository _festas;
  final AppLogger _logger;

  @override
  Stream<GaleraDaFesta?> observarGalera(String festaId) =>
      _festas.observarFesta(festaId).map(
            (festa) => festa == null
                ? null
                : GaleraDaFesta(
                    festaId: festaId,
                    convite: festa.convite,
                    composicao: festa.composicao,
                  ),
          );

  @override
  Future<void> alterarDieta(
    String festaId,
    ChaveDePessoa quem,
    Dieta dieta,
  ) =>
      _trocarPessoa(
        festaId,
        quem,
        (pessoa) =>
            pessoa.dieta == dieta ? null : pessoa.copyWith(dieta: dieta),
      );

  @override
  Future<void> alterarBebida(
    String festaId,
    ChaveDePessoa quem,
    bool bebe,
  ) =>
      _trocarPessoa(
        festaId,
        quem,
        (pessoa) => pessoa.bebe == bebe ? null : pessoa.copyWith(bebe: bebe),
      );

  /// Troca o papel de quem [quem] endereça — GAL-17 — e **recusa** o anfitrião
  /// pelos dois lados (GAL-18).
  ///
  /// São **duas** recusas, não uma: a de fora impede que alguém *receba* o
  /// papel de anfitrião; a de dentro impede que o anfitrião corrente o *perca*.
  /// Uma não cobre a outra, e cada uma registra a sua própria mensagem — quem
  /// tentar chegar ao controle por outro caminho encontra a recusa no domínio,
  /// independentemente de quem pede (Edge Case da `spec.md`).
  @override
  Future<void> alterarPapel(
    String festaId,
    ChaveDePessoa quem,
    PapelNaFesta papel,
  ) async {
    if (papel == PapelNaFesta.anfitriao) {
      _logger.logEvent(_anfitriaoNaoEhAtribuivel, name: _nome);
      return;
    }

    await _trocarPessoa(festaId, quem, (pessoa) {
      if (pessoa.papel == PapelNaFesta.anfitriao) {
        _logger.logEvent(_anfitriaoNaoEhRemovivel, name: _nome);
        return null;
      }

      return pessoa.papel == papel ? null : pessoa.copyWith(papel: papel);
    });
  }

  /// Grava o nível de quem abrir o link — GAL-04.
  ///
  /// Escreve **só** `convite.nivel`: `pessoas` não é argumento e não é tocada,
  /// então o papel de quem já entrou não retroage (AD-026). O `codigo` é
  /// preservado pelo `copyWith` do convite — a Galera lê o código, nunca o
  /// gera (A-03).
  @override
  Future<void> definirNivelDoLink(String festaId, NivelDoLink nivel) async {
    final festa = await _festas.observarFesta(festaId).first;
    if (festa == null) return;
    if (festa.convite.nivel == nivel) return;

    await _gravar(
      festaId,
      festa.copyWith(convite: festa.convite.copyWith(nivel: nivel)),
    );
  }

  /// O *read-modify-write* de uma pessoa: lê o registro **no instante da
  /// chamada**, aplica [troca] na pessoa endereçada e grava.
  ///
  /// **Ler agora, e não um snapshot guardado**, é o que evita o clobber: um
  /// painel aberto há um minuto gravaria por cima do que a tela Lista escreveu
  /// nesse minuto. Assim a janela é o próprio turno do event loop.
  ///
  /// Três recusas, cada uma com motivo próprio:
  /// - festa inexistente ⇒ não grava (não há o que atualizar);
  /// - chave que sumiu do registro ⇒ não grava, em vez de acertar a linha
  ///   errada (`ChaveDePessoa.indiceEm`);
  /// - [troca] devolvendo `null` ⇒ o valor já é o vigente e **nenhuma**
  ///   gravação acontece (GAL-28).
  ///
  /// Grava por `copyWith` nas duas pontas: só `pessoas` muda, e todo campo que
  /// outra spec acrescentar à composição ou à festa sobrevive sem que este
  /// arquivo o conheça — é o que faz o override de RN-12 continuar valendo
  /// (GAL-15 AC12).
  Future<void> _trocarPessoa(
    String festaId,
    ChaveDePessoa quem,
    Pessoa? Function(Pessoa) troca,
  ) async {
    final festa = await _festas.observarFesta(festaId).first;
    if (festa == null) return;

    final pessoas = festa.composicao.pessoas;
    final indice = ChaveDePessoa.indiceEm(pessoas, quem);
    if (indice == null) return;

    final trocada = troca(pessoas[indice]);
    if (trocada == null) return;

    final atualizadas = List.of(pessoas)..[indice] = trocada;

    await _gravar(
      festaId,
      festa.copyWith(
        composicao: festa.composicao.copyWith(pessoas: atualizadas),
      ),
    );
  }

  /// A única gravação do adaptador.
  ///
  /// A falha é **registrada e não vaza**: a fonte da verdade é o stream, então
  /// quem chamou não tem o que desfazer — a UI simplesmente não reflete a
  /// mudança, e nenhuma copy de erro é inventada (`design.md` §10). Deixar a
  /// exceção subir quebraria o toque num botão de dieta com um erro não
  /// tratado.
  Future<void> _gravar(String festaId, FestaEmEdicao festa) async {
    try {
      await _festas.salvarFesta(festaId, festa);
    } catch (erro, stack) {
      _logger.logError(erro, stack, name: _nome);
    }
  }
}
