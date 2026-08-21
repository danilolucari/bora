import 'chave_item.dart';
import 'contagem_de_pessoas.dart';
import 'item_de_lista.dart';
import 'pessoa.dart';

/// Tudo o que a calculadora precisa saber para montar a lista — CALC-15,
/// CALC-16.
///
/// É a **entrada única** de `CalculadoraDaFesta.calcular`: quem vai
/// ([contagem] e [pessoas]), por quanto tempo ([duracaoHoras]), o que vai ter
/// ([itensSelecionados]) e o que o anfitrião ajustou à mão ([overrides]).
///
/// [contagem] e [pessoas] respondem perguntas **diferentes** e nunca se somam
/// (A-05): a contagem é o card "CONFIRMADOS + EXTRAS SEM APP" de T-03 e é a
/// única fonte de cabeças; as pessoas nomeadas entram com preferências e
/// identidade, porque `Pessoa` não tem sexo nem idade. Somar as duas exigiria
/// inventar gramas para os nomeados.
class ComposicaoDaFesta {
  const ComposicaoDaFesta({
    required this.contagem,
    required this.duracaoHoras,
    this.pessoas = const [],
    this.itensSelecionados = const {},
    this.overrides = const {},
  });

  /// As cabeças da festa (RN-01).
  final ContagemDePessoas contagem;

  /// Duração em horas, que vira o fator de RN-02.
  final int duracaoHoras;

  /// As pessoas nomeadas, que entram com **preferências** (RN-21), não com
  /// cabeça.
  final List<Pessoa> pessoas;

  /// Os chips marcados em T-03. Os essenciais de RN-10 **não** precisam estar
  /// aqui: entram sozinhos.
  final Set<ChaveItem> itensSelecionados;

  /// Ajustes manuais por item (RN-12), quando existem.
  final Map<ChaveItem, OverrideDeItem> overrides;
}
