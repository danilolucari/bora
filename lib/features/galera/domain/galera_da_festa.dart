import '../../../core/calculo/calculo.dart';
import '../../../core/festas/festas.dart';

/// O que a tela A GALERA lê de uma festa: quem está nela, o que cada um come
/// e bebe, e com que acesso o link entra — o modelo de leitura de GAL-09.
///
/// Carrega a [ComposicaoDaFesta] **inteira**, e não só a lista de pessoas,
/// por dois motivos: `efeitosDasPreferencias` exige `adultos`, que vem de
/// `contagem`; e a escrita é `composicao.copyWith(pessoas: …)` — com a lista
/// solta, o adaptador teria de remontar a composição do zero e apagaria em
/// silêncio todo campo que outra spec acrescentar.
///
/// [confirmados] é **derivado** e nunca gravado: a Galera não escreve contador
/// (GAL-09 AC9, AD-022). Quem grava contador é a spec 09, na mesma escrita do
/// RSVP.
///
/// Dart puro: nenhum import de Flutter (GAL-19 AC7).
class GaleraDaFesta {
  const GaleraDaFesta({
    required this.festaId,
    required this.convite,
    required this.composicao,
  });

  /// O `{festaId}` da rota `/roles/:festaId/galera`.
  final String festaId;

  /// O código do link e o nível de quem abrir — RN-23.
  final ConviteDaFesta convite;

  /// Contagem, pessoas, itens e duração — o mesmo registro que a calculadora
  /// lê. É o que faz GAL-14 ser consequência do desenho, não disciplina.
  final ComposicaoDaFesta composicao;

  /// As pessoas nomeadas, **na ordem do repositório** (A-15).
  ///
  /// A ordem é comportamento observável: T-05 desenha uma linha por pessoa na
  /// ordem em que elas chegaram, e reordenar aqui trocaria as linhas de lugar
  /// a cada emissão do stream.
  List<Pessoa> get pessoas => composicao.pessoas;

  /// Quantas pessoas nomeadas estão **confirmadas** — o `{n} confirmadas` do
  /// sub de T-05 (GAL-09 AC8).
  ///
  /// Conta [StatusDePresenca.confirmado] e só ele: quem `recusou` e quem está
  /// `pendente` aparecem em [pessoas] — são pessoas da festa — e **não**
  /// entram nesta conta. É o número que tem de bater com o `confirmados` do
  /// `ResumoDeFesta` da mesma festa (AD-022).
  int get confirmados {
    var total = 0;
    for (final pessoa in pessoas) {
      if (pessoa.status == StatusDePresenca.confirmado) total++;
    }
    return total;
  }

  /// Valor, não identidade: o bloc guarda esta leitura no estado, e sem
  /// igualdade profunda **toda** emissão do repositório — inclusive a idêntica
  /// — reconstruiria a lista inteira. `==`/`hashCode` escritos à mão porque
  /// `package:meta` é dependência transitiva (A-19).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GaleraDaFesta &&
          other.festaId == festaId &&
          other.convite == convite &&
          other.composicao == composicao;

  @override
  int get hashCode => Object.hash(festaId, convite, composicao);
}
