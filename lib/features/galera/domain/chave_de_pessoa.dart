import '../../../core/calculo/calculo.dart';

/// O endereço estável de uma linha da seção PESSOAS: o nome mais a
/// **ocorrência** entre homônimos.
///
/// Existe porque a identidade de [Pessoa] é o próprio nome (A-24 de `calculo`)
/// e duas pessoas de mesmo nome renderizam como linhas distintas (Edge Case da
/// `spec.md`). Endereçar a escrita só pelo nome mudaria a dieta das duas Anas
/// de uma vez; endereçar pelo índice da lista quebraria assim que o RSVP
/// acrescentasse alguém.
///
/// Dart puro: nenhum import de Flutter (GAL-19 AC7).
class ChaveDePessoa {
  const ChaveDePessoa(this.nome, this.ocorrencia);

  final String nome;

  /// Quantas pessoas de mesmo [nome] vêm **antes** desta na lista: 0 para a
  /// primeira, 1 para a segunda.
  final int ocorrencia;

  /// As chaves de [pessoas], **na ordem do repositório** (A-15).
  static List<ChaveDePessoa> de(List<Pessoa> pessoas) {
    final vistos = <String, int>{};
    final chaves = <ChaveDePessoa>[];

    for (final pessoa in pessoas) {
      final ocorrencia = vistos[pessoa.nome] ?? 0;
      vistos[pessoa.nome] = ocorrencia + 1;
      chaves.add(ChaveDePessoa(pessoa.nome, ocorrencia));
    }

    return chaves;
  }

  /// O índice de [chave] em [pessoas], ou `null` se ela não existe mais.
  ///
  /// O `null` é o caso de a pessoa sumir entre a abertura do painel e a
  /// escrita: quem escreve **não grava nada** em vez de acertar a linha
  /// errada.
  static int? indiceEm(List<Pessoa> pessoas, ChaveDePessoa chave) {
    var ocorrencia = 0;

    for (var i = 0; i < pessoas.length; i++) {
      if (pessoas[i].nome != chave.nome) continue;
      if (ocorrencia == chave.ocorrencia) return i;
      ocorrencia++;
    }

    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChaveDePessoa &&
          other.nome == nome &&
          other.ocorrencia == ocorrencia;

  @override
  int get hashCode => Object.hash(nome, ocorrencia);

  @override
  String toString() => '$nome#$ocorrencia';
}
