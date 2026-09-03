import '../../calculo/calculo.dart';
import 'convite_da_festa.dart';

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
///
/// **Duas emendas aditivas convivem aqui**, cada uma de uma spec e cada uma
/// com default para não quebrar call site nenhum: [despesas] (spec 06 `lista`,
/// AD-030) e [convite] (spec 07 `galera`, AD-031). Quem acrescentar a terceira
/// segue a mesma forma — campo com default, dentro de `==`/`hashCode` e de
/// [copyWith].
class FestaEmEdicao {
  const FestaEmEdicao({
    required this.festa,
    required this.composicao,
    this.despesas = const [],
    this.convite = ConviteDaFesta.vazio,
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

  /// O código do link e o nível de quem abrir — RN-23 · AD-031.
  ///
  /// **Fica aqui e não em [ComposicaoDaFesta]** pela mesma fronteira objetiva
  /// da AD-030: `CalculadoraDaFesta.calcular` não consome convite. Quem grava
  /// é a tela A Galera (o segmented de RN-23); quem lê na abertura do link é a
  /// spec 09.
  ///
  /// Entra em `==`/`hashCode`: sem isso, gravar um nível novo produziria uma
  /// festa **igual** à anterior e a emissão do stream seria engolida como eco.
  final ConviteDaFesta convite;

  /// Copia trocando campos. O campo não informado é **preservado**.
  FestaEmEdicao copyWith({
    Festa? festa,
    ComposicaoDaFesta? composicao,
    List<Despesa>? despesas,
    ConviteDaFesta? convite,
  }) =>
      FestaEmEdicao(
        festa: festa ?? this.festa,
        composicao: composicao ?? this.composicao,
        despesas: despesas ?? this.despesas,
        convite: convite ?? this.convite,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FestaEmEdicao &&
          other.festa == festa &&
          other.composicao == composicao &&
          listaIgual(other.despesas, despesas) &&
          other.convite == convite;

  @override
  int get hashCode =>
      Object.hash(festa, composicao, Object.hashAll(despesas), convite);
}
