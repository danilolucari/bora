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
  const FestaEmEdicao({
    required this.festa,
    required this.composicao,
    this.despesas = const [],
  });

  /// Nome, data, hora, local e duração — a identidade da festa.
  final Festa festa;

  /// Contagem, pessoas, itens e duração — a entrada da calculadora.
  final ComposicaoDaFesta composicao;

  /// As despesas já lançadas na festa — RN-20 · AD-030.
  ///
  /// No M1 a única origem é o pedido por delivery da tela Lista (AD-024 ·
  /// AD-027); a spec 10 `custos` lê daqui e o "EU LEVO" da spec 09 escreve
  /// aqui.
  ///
  /// **Fica aqui e não em [ComposicaoDaFesta]** porque despesa não entra em
  /// `CalculadoraDaFesta.calcular`: pô-la na composição faria a entrada da
  /// calculadora carregar dado que a calculadora ignora, e mudaria a
  /// igualdade que decide se um recálculo é necessário — lançar uma despesa
  /// passaria a recalcular a lista inteira à toa. A fronteira é objetiva: "a
  /// calculadora consome?" (AD-030).
  ///
  /// Compara **na ordem**: a ordem em que as despesas foram lançadas é o que
  /// a tela Custos exibe.
  final List<Despesa> despesas;

  /// Copia trocando campos. O campo não informado é **preservado**.
  FestaEmEdicao copyWith({
    Festa? festa,
    ComposicaoDaFesta? composicao,
    List<Despesa>? despesas,
  }) =>
      FestaEmEdicao(
        festa: festa ?? this.festa,
        composicao: composicao ?? this.composicao,
        despesas: despesas ?? this.despesas,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FestaEmEdicao &&
          other.festa == festa &&
          other.composicao == composicao &&
          listaIgual(other.despesas, despesas);

  @override
  int get hashCode => Object.hash(festa, composicao, Object.hashAll(despesas));
}
