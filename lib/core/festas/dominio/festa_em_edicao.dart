import '../../calculo/calculo.dart';

/// A festa **como montar precisa dela**: identidade + composição (AD-029).
///
/// Fala só em tipos de `core/calculo` (AD-008) — é isso que mantém a porta em
/// `core/` sem que ela conheça `ResumoDeFesta`, que é da Home.
///
/// **Sem `id`.** O id é o **endereço**, não atributo: ele viaja no parâmetro
/// de rota e nos argumentos da porta. `Festa` não tem id — a spec nunca
/// definiu um — e esta camada não inventa.
///
/// **[duracaoHoras] aparece nos dois lados** (`Festa.duracaoHoras` e
/// `ComposicaoDaFesta.duracaoHoras`) porque as duas entidades já existiam
/// assim. **A composição manda**: é ela que entra na calculadora. Quem grava
/// espelha o valor no `Festa`, num lugar só.
///
/// Valor imutável, com `==`/`hashCode` escritos à mão (AD-019 · A-19): a
/// igualdade é **profunda** porque as duas partes já a têm, e é comparando
/// duas festas em edição que um consumidor decide se precisa gravar ou
/// recalcular.
class FestaEmEdicao {
  const FestaEmEdicao({required this.festa, required this.composicao});

  /// Nome, data, hora, local e duração — a identidade da festa.
  final Festa festa;

  /// Contagem, pessoas, itens e duração — a entrada da calculadora.
  final ComposicaoDaFesta composicao;

  /// Copia trocando campos. O campo não informado é **preservado**.
  FestaEmEdicao copyWith({Festa? festa, ComposicaoDaFesta? composicao}) =>
      FestaEmEdicao(
        festa: festa ?? this.festa,
        composicao: composicao ?? this.composicao,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FestaEmEdicao &&
          other.festa == festa &&
          other.composicao == composicao;

  @override
  int get hashCode => Object.hash(festa, composicao);
}
