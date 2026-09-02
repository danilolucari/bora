/// Os três níveis de link de RN-23 — o que quem abrir o link vai poder fazer
/// na festa (**AD-031**).
///
/// Aqui mora só o **dado**. A **nota** literal de cada nível é copy da tela, e
/// a tradução nível → [PapelNaFesta] é **regra**: as duas moram em
/// `lib/features/galera/`, do mesmo jeito que `papel_na_festa.dart` já declara
/// para a tabela de RN-22.
///
/// Dart puro: sem import de Flutter e sem import de Firebase (AD-029).
enum NivelDoLink {
  soVer('sover'),
  editarLista('editarlista'),
  coAnfitriao('coanfitriao');

  const NivelDoLink(this.chave);

  /// A chave de serialização do nível.
  ///
  /// É escrita à mão, **nunca derivada de [name]**: a chave é contrato de dado
  /// — vai para o Firestore na spec 09 e volta de lá — enquanto `name` é
  /// detalhe da linguagem. Renomear o valor do enum não pode reescrever o que
  /// já está gravado. O mesmo motivo de `Dieta.chave` e `PapelNaFesta.chave`.
  final String chave;

  /// O nível de [chave], ou `null` se a chave não existir.
  ///
  /// `null` para chave desconhecida é o padrão de `Dieta.porChave` e
  /// `PapelNaFesta.porChave`: **quem converte decide** o que fazer com o
  /// desconhecido, em vez de receber um default inventado. Quem converte, aqui,
  /// é [resolver].
  static NivelDoLink? porChave(String chave) {
    for (final nivel in values) {
      if (nivel.chave == chave) return nivel;
    }
    return null;
  }

  /// O nível gravado no dado, resolvido por **menor privilégio** — GAL-21.
  ///
  /// Ausente (`null`) ou desconhecido resolve para [soVer]: dado corrompido ou
  /// de versão futura **nunca** concede edição por falta de informação (A-12).
  ///
  /// Não confundir com [padraoDeFestaNova]: são duas situações diferentes e por
  /// isso são dois nomes, não um default só.
  static NivelDoLink resolver(String? chave) =>
      chave == null ? soVer : (porChave(chave) ?? soVer);

  /// O nível com que uma festa **nova** nasce — A-12.
  ///
  /// [editarLista] porque o fluxo canônico do produto (RN-24 → UC-09 → RN-20,
  /// "o que você levar desconta da sua parte") exige que o convidado marque
  /// itens: com [soVer] a promessa não funcionaria sem configuração. É default
  /// de **produto**, e por isso difere do [resolver] de dado ausente, que é
  /// menor privilégio.
  static const NivelDoLink padraoDeFestaNova = editarLista;
}
