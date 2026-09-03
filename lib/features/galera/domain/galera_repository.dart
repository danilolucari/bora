import '../../../core/calculo/calculo.dart';
import '../../../core/festas/festas.dart';
import 'chave_de_pessoa.dart';
import 'galera_da_festa.dart';

/// O contrato da tela A GALERA — sem Flutter, sem Firebase (GAL-19 AC7).
///
/// **Quatro escritas com intenção, e não um `salvar(estado)`.** A forma da
/// porta é o que torna duas garantias afirmáveis sem depender de disciplina:
///
/// - **GAL-09 AC9** — não existe método que toque `StatusDePresenca` nem
///   contador algum, então a Galera não tem como escrever um. Contador é dado
///   da festa (AD-022) e quem o grava é a spec 09, junto com o RSVP.
/// - **GAL-18** — o papel ANFITRIÃO não é atribuível nem removível por
///   caminho nenhum: `alterarPapel` recusa o alvo cujo papel corrente é
///   anfitrião, e a recusa mora no domínio, não na tela.
///
/// É também a forma que o M2 troca por *field update* do Firestore, uma
/// escrita de cada vez, sem que bloc ou widget saibam.
///
/// **Sem `dispose()`**, pela mesma razão de `FestaEmEdicaoRepository`: o dono
/// do ciclo de vida do store é a porta de leitura da Home, já registrada com
/// `dispose` no injector.
abstract class GaleraRepository {
  /// A galera da festa [festaId], **agora e a cada mudança**. `null` = a festa
  /// não existe.
  ///
  /// `Stream`, e não `Future`, por RN-28: a confirmação que chega com a tela
  /// aberta reflete sem refresh.
  Stream<GaleraDaFesta?> observarGalera(String festaId);

  /// Troca a dieta da pessoa endereçada por [quem] — RN-21, GAL-11.
  ///
  /// Endereça por [ChaveDePessoa] porque a identidade de `Pessoa` é o nome
  /// (A-24): por nome puro, duas homônimas mudariam juntas.
  Future<void> alterarDieta(String festaId, ChaveDePessoa quem, Dieta dieta);

  /// Troca o `bebe` da pessoa endereçada por [quem] — RN-21, GAL-12.
  Future<void> alterarBebida(String festaId, ChaveDePessoa quem, bool bebe);

  /// Troca o papel da pessoa endereçada por [quem] — RN-22, GAL-17.
  ///
  /// **Não** muda o papel de mais ninguém, e **recusa** o alvo que já é
  /// anfitrião (GAL-18).
  Future<void> alterarPapel(
    String festaId,
    ChaveDePessoa quem,
    PapelNaFesta papel,
  );

  /// Grava o nível de quem abrir o link — RN-23, GAL-04.
  ///
  /// Escreve **só** o nível do convite: o papel de quem já entrou não retroage
  /// (AD-026), e nem o código do link nem a lista de pessoas são argumento.
  Future<void> definirNivelDoLink(String festaId, NivelDoLink nivel);
}
