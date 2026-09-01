import '../../../core/calculo/calculo.dart';

/// A festa **como a Home precisa dela** — a entidade mais os números que só
/// esta tela mostra (HOME-19).
///
/// **Compõe [Festa], não a substitui.** A AD-008 fixou `Festa` em
/// `core/calculo/dominio/`, e estado de convite não é atributo de festa.
///
/// Valor imutável com igualdade por conteúdo: o `Stream` de
/// `FestaRepository.observarFestas()` compara emissões para decidir se houve
/// mudança, e uma lista nova com as mesmas iniciais não é mudança.
///
/// `==`/`hashCode` são escritos à mão pelo mesmo motivo de
/// `core/autenticacao/dominio/usuario_logado.dart`: `package:collection` e
/// `package:meta` são dependências transitivas, e importá-las derrubaria
/// `flutter analyze`.
class ResumoDeFesta {
  const ResumoDeFesta({
    required this.id,
    required this.festa,
    this.confirmados = 0,
    this.pendentes = 0,
    this.iniciais = const [],
    this.pessoas,
    this.total,
    ComposicaoDaFesta? composicao,
  })
      // O que o lint sugere (`this._composicao`) é impossível: parâmetro
      // nomeado não pode começar com `_`. O campo é privado de propósito —
      // quem lê usa [composicao], que resolve o default; expor o nulo
      // convidaria cada consumidor a reimplementar o "se não tem, é vazia de
      // 4h". É a única supressão do projeto, e é por impossibilidade.
      // ignore: prefer_initializing_formals
      : _composicao = composicao;

  /// A identidade da festa — o `{festaId}` das rotas `/roles/:festaId/**`.
  ///
  /// SPEC_DEVIATION: o `design.md` não previu este campo. Ele é inevitável:
  /// HOME-07 manda "MONTAR LISTA →" navegar para `/roles/{festaId}/montar`, e
  /// `Festa` não tem id — a spec nunca definiu um, e a entidade mora em
  /// `core/calculo/` (AD-008), fora da fronteira desta spec. Mora aqui porque
  /// é a Home que precisa dele para navegar; no M2 ele é o id do documento do
  /// Firestore.
  ///
  /// É também o que pareia emissões no `HomeBloc`: por nome, duas festas
  /// homônimas do mesmo anfitrião colapsariam numa só.
  final String id;

  final Festa festa;

  /// **AD-022: dado, não derivação.** "Pendente" é quem recebeu o link
  /// (RN-24) e ainda não respondeu — e quem não respondeu não é uma `Pessoa`
  /// nomeada ainda.
  ///
  /// A divergência de RN-30 (5 nomeados, "4 confirmados / 2 pendentes") mora
  /// **inteira no [pendentes]**: [confirmados] coincide com a contagem dos
  /// nomeados em T-05, RN-25, T-07 e T-08, e tem de continuar coincidindo.
  /// Quem alimentar estes campos no M2 grava contador e RSVP na mesma escrita
  /// (RN-28).
  final int confirmados;

  /// Quantos receberam o convite e ainda não responderam. Ver [confirmados].
  final int pendentes;

  /// As iniciais dos avatares empilhados, na ordem de exibição (T-02).
  final List<String> iniciais;

  /// Quantas pessoas foram — só para festa concluída (UC-24).
  /// `null` na festa que está chegando.
  final int? pessoas;

  /// Quanto a festa deu — só para festa concluída (UC-24). Formatado por
  /// `MoneyFormatter` na tela, nunca aqui (RN-13).
  final double? total;

  /// `null` quando ninguém informou composição — ver [composicao].
  final ComposicaoDaFesta? _composicao;

  /// O que a festa vai ter: contagem, pessoas, itens e duração — a entrada da
  /// calculadora (AD-029).
  ///
  /// A Home **não** o lê. Está aqui porque o store precisa dele para que o
  /// registro da festa seja **um só**: guardar a composição num mapa paralelo
  /// dentro do repositório criaria duas fontes para a mesma festa, e a que
  /// `montar` grava divergiria da que a Home lista.
  ///
  /// Sem valor informado, resolve para a **composição vazia de 4 horas** — é
  /// por isso que dois resumos criados sem composição continuam iguais.
  ///
  /// SPEC_DEVIATION: o `montar/design.md` §6.3 desenhou um campo final não
  /// nulo com valor default. Isso não compila: valor default de parâmetro tem
  /// de ser constante, e `ContagemDePessoas` **não** é `const` — o construtor
  /// valida, e construtor `const` não lança.
  /// Reason: campo privado nulo + getter que resolve entrega exatamente o
  /// mesmo contrato público (`composicao` sempre tem valor, e entra em `==`)
  /// sem tirar o `const` de [ResumoDeFesta] — tirá-lo obrigaria a editar cada
  /// `const ResumoDeFesta(...)` da suíte da spec 04, que é justamente o que
  /// esta emenda não pode fazer.
  ComposicaoDaFesta get composicao => _composicao ?? _composicaoVazia;

  bool get ehPassada => festa.status == StatusDaFesta.passada;

  /// Quantos avatares não couberam — o "+N" tracejado de T-02.
  ///
  /// Desconta os avatares **realmente desenhados**, e não [visiveis]: com
  /// menos iniciais do que slots, subtrair os slots contaria gente que a pilha
  /// não mostrou. Com 4 confirmados e 2 iniciais, a pilha desenha 2 e o
  /// excedente é 2 — não 1.
  ///
  /// Nunca negativo: com 3 ou menos confirmados e 3 slots, o excedente é 0 e a
  /// tela não renderiza o "+N".
  int excedenteDeAvatares(int visiveis) =>
      (confirmados - avataresMostrados(visiveis)).clamp(0, confirmados);

  /// Quantos círculos a pilha desenha, dado o teto de [visiveis].
  int avataresMostrados(int visiveis) =>
      iniciais.length < visiveis ? iniciais.length : visiveis;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumoDeFesta &&
          other.id == id &&
          other.festa == festa &&
          other.confirmados == confirmados &&
          other.pendentes == pendentes &&
          _mesmasIniciais(other.iniciais, iniciais) &&
          other.pessoas == pessoas &&
          other.total == total &&
          // O default **resolvido** dos dois lados, nunca o campo cru: dois
          // resumos criados sem composição continuam iguais, que é o que faz
          // a suíte da spec 04 seguir intacta.
          other.composicao == composicao;

  @override
  int get hashCode => Object.hash(
        id,
        festa,
        confirmados,
        pendentes,
        Object.hashAll(iniciais),
        pessoas,
        total,
        composicao,
      );

  static bool _mesmasIniciais(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// A composição de quem não informou nenhuma: festa **vazia de 4 horas**.
///
/// 4h é o default de RN-30 e o ativo do segmented de T-03; contagem 0/0/0 é o
/// estado honesto de abertura de UC-03 E1 — o app não inventa convidado.
///
/// É um `final` de topo, e não o valor default do parâmetro, porque
/// `ContagemDePessoas` **não** é `const`: o construtor valida, e construtor
/// `const` não lança. Assim o construtor de [ResumoDeFesta] continua `const` —
/// que é o que faz a suíte da spec 04 rodar sem uma linha alterada.
final ComposicaoDaFesta _composicaoVazia = ComposicaoDaFesta(
  contagem: ContagemDePessoas(),
  duracaoHoras: 4,
);
