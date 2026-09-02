import 'chave_item.dart';
import 'contagem_de_pessoas.dart';
import 'igualdade.dart';
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
    this.noCarrinho = const {},
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

  /// As chaves marcadas como "já tá no carrinho" no modo COMPRAR da tela
  /// Lista — RN-27 · AD-030.
  ///
  /// Mora aqui, e não em [ItemDeLista], porque o item é **reconstruído a cada
  /// recálculo**: guardar o check nele o perderia no primeiro toque de
  /// stepper. Irmão de [overrides] — mesmo escopo de vida, mesma reaplicação
  /// por `CalculadoraDaFesta.calcular`.
  ///
  /// Chave **órfã** (marcada e depois removida da seleção) não cria item nem
  /// quebra nada: o conjunto é lido por `contains`, nunca percorrido para
  /// montar a lista. É o que faz o edge case "item marcado some da lista"
  /// resolver sem código de limpeza.
  final Set<ChaveItem> noCarrinho;

  /// Copia trocando campos. O campo não informado é **preservado**; informar
  /// uma coleção vazia a substitui de verdade.
  ComposicaoDaFesta copyWith({
    ContagemDePessoas? contagem,
    int? duracaoHoras,
    List<Pessoa>? pessoas,
    Set<ChaveItem>? itensSelecionados,
    Map<ChaveItem, OverrideDeItem>? overrides,
    Set<ChaveItem>? noCarrinho,
  }) =>
      ComposicaoDaFesta(
        contagem: contagem ?? this.contagem,
        duracaoHoras: duracaoHoras ?? this.duracaoHoras,
        pessoas: pessoas ?? this.pessoas,
        itensSelecionados: itensSelecionados ?? this.itensSelecionados,
        overrides: overrides ?? this.overrides,
        noCarrinho: noCarrinho ?? this.noCarrinho,
      );

  /// Valor, não identidade (CALC-05) — e por valor **profundo**: como esta é a
  /// entrada única de `CalculadoraDaFesta.calcular`, é comparando duas
  /// composições que um consumidor decide se precisa recalcular. Com o `==` de
  /// identidade das coleções, duas composições idênticas nunca seriam iguais e
  /// esse consumidor recalcularia sempre.
  ///
  /// [pessoas] compara **na ordem**: a ordem de entrada é comportamento
  /// observável no racha (A-14), então duas composições que só diferem na
  /// ordem não são a mesma.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComposicaoDaFesta &&
          contagem == other.contagem &&
          duracaoHoras == other.duracaoHoras &&
          listaIgual(pessoas, other.pessoas) &&
          conjuntoIgual(itensSelecionados, other.itensSelecionados) &&
          mapaIgual(overrides, other.overrides) &&
          conjuntoIgual(noCarrinho, other.noCarrinho);

  @override
  int get hashCode => Object.hash(
        contagem,
        duracaoHoras,
        Object.hashAll(pessoas),
        Object.hashAllUnordered(itensSelecionados),
        hashDeMapa(overrides),
        Object.hashAllUnordered(noCarrinho),
      );
}
