import '../../domain/chave_de_pessoa.dart';
import '../../domain/galera_da_festa.dart';

/// Em que ponto a tela A GALERA está — GAL-25.
///
/// Três situações e não quatro: **não existe `vazia`**. Festa sem pessoa
/// nomeada é uma festa que carregou (GAL-24 AC2 exige o card do link e o CTA
/// funcionando ali), e a ausência de linhas é consequência de
/// `galera.pessoas` estar vazia — não um estado à parte.
enum SituacaoDaGalera { carregando, comFesta, falhou }

/// O estado da tela A GALERA.
///
/// Igualdade por valor, escrita à mão como em `HomeState` e `ListaState`: sem
/// ela o `emit` do bloc não descarta emissão repetida e **toda** emissão do
/// repositório reconstruiria a lista de pessoas, a faixa amarela e o card do
/// link — inclusive as emissões idênticas que o Firestore vai produzir no M2
/// (AD-016).
///
/// `package:meta` continua fora: é dependência transitiva e importá-la
/// derrubaria o `flutter analyze` (A-19).
class GaleraState {
  const GaleraState({
    this.situacao = SituacaoDaGalera.carregando,
    this.galera,
    this.aberta,
    this.copiasConcluidas = 0,
  });

  final SituacaoDaGalera situacao;

  /// A leitura da festa. `null` enquanto nada chegou do stream.
  final GaleraDaFesta? galera;

  /// A pessoa com o painel aberto, ou `null` com todos fechados.
  ///
  /// **Um campo, não um `Set`**: abrir uma linha fecha a anterior por
  /// construção, que é o "1 aberto por vez" do arquivo 02 §5 (GAL-10 AC1).
  ///
  /// Endereçada por [ChaveDePessoa] e **não** por índice: a emissão do stream
  /// que acrescenta alguém antes dela mudaria o índice e abriria a linha
  /// errada (GAL-26).
  ///
  /// Mora aqui, no bloc, e não no `State` de um widget: é o que faz o painel
  /// sobreviver à emissão do stream (GAL-26) e à travessia dos 900px
  /// (GAL-23 AC3) sem depender de o widget não ser remontado.
  final ChaveDePessoa? aberta;

  /// Quantas cópias do link **deram certo** desde que a tela abriu — o
  /// gatilho do toast de RN-29 (`design.md` §8.2).
  ///
  /// Contador, e não `bool copiou`: com um booleano a segunda cópia seguida
  /// não mudaria o estado, o `BlocListener` não veria transição nenhuma e o
  /// segundo toast não sairia.
  final int copiasConcluidas;

  GaleraState copyWith({
    SituacaoDaGalera? situacao,
    GaleraDaFesta? galera,
    ChaveDePessoa? aberta,
    int? copiasConcluidas,
  }) =>
      GaleraState(
        situacao: situacao ?? this.situacao,
        galera: galera ?? this.galera,
        aberta: aberta ?? this.aberta,
        copiasConcluidas: copiasConcluidas ?? this.copiasConcluidas,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GaleraState &&
          other.situacao == situacao &&
          other.galera == galera &&
          other.aberta == aberta &&
          other.copiasConcluidas == copiasConcluidas;

  @override
  int get hashCode => Object.hash(situacao, galera, aberta, copiasConcluidas);
}
