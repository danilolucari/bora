import '../../../core/calculo/calculo.dart';
import '../../../core/festas/festas.dart';
import '../domain/chave_de_pessoa.dart';
import '../domain/galera_da_festa.dart';
import '../domain/galera_repository.dart';

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
  const GaleraRepositorioSobreFestas(this._festas);

  final FestaEmEdicaoRepository _festas;

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

  @override
  Future<void> alterarPapel(
    String festaId,
    ChaveDePessoa quem,
    PapelNaFesta papel,
  ) =>
      throw UnimplementedError();

  @override
  Future<void> definirNivelDoLink(String festaId, NivelDoLink nivel) =>
      throw UnimplementedError();

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

    await _festas.salvarFesta(
      festaId,
      festa.copyWith(
        composicao: festa.composicao.copyWith(pessoas: atualizadas),
      ),
    );
  }
}
