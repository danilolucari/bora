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
    required this.festa,
    this.confirmados = 0,
    this.pendentes = 0,
    this.iniciais = const [],
    this.pessoas,
    this.total,
  });

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

  bool get ehPassada => festa.status == StatusDaFesta.passada;

  /// Quantos avatares não couberam — o "+N" tracejado de T-02.
  ///
  /// Nunca negativo: com 3 ou menos confirmados e 3 slots visíveis o
  /// excedente é 0, e a tela não renderiza o "+N".
  int excedenteDeAvatares(int visiveis) =>
      (confirmados - visiveis).clamp(0, confirmados);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumoDeFesta &&
          other.festa == festa &&
          other.confirmados == confirmados &&
          other.pendentes == pendentes &&
          _mesmasIniciais(other.iniciais, iniciais) &&
          other.pessoas == pessoas &&
          other.total == total;

  @override
  int get hashCode => Object.hash(
        festa,
        confirmados,
        pendentes,
        Object.hashAll(iniciais),
        pessoas,
        total,
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
