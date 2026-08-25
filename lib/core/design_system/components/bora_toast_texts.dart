/// Os textos canônicos de toast de **RN-29**, literais.
///
/// §7: "títulos, labels, botões e toasts em CAIXA ALTA" e "emojis fazem parte
/// da marca — 1 por elemento, geralmente no fim". Aqui a copy não é parafraseada
/// nem traduzida: é a mesma cadeia de caracteres que RN-29 declara, emoji
/// incluído.
abstract final class BoraToastTexts {
  /// Copiar o link do convite (T-05, T-06).
  static const String linkCopiado = 'LINK COPIADO 🔗';

  /// Salvar o rolê (T-03).
  static const String roleSalvo = 'ROLÊ SALVO ✊';

  /// Copiar o texto do convite (T-06).
  static const String conviteCopiado = 'CONVITE COPIADO 📋';

  /// Mandar a lista no grupo (T-04, T-06).
  static const String listaNoGrupo = 'LISTA NO GRUPO 📲';

  /// Abrir o WhatsApp (T-06, T-07).
  static const String abrindoWhatsapp = 'ABRINDO O WHATSAPP… 📲';

  /// Salvar o rolê na agenda (T-08).
  static const String salvoNaAgenda = 'SALVO NA AGENDA 📅';

  /// Lembrete no grupo (T-07).
  static const String lembreteMandado = 'LEMBRETE MANDADO NO GRUPO 📲';

  /// Cobrança no Pix (T-09).
  static const String cobrancaEnviada = 'COBRANÇA ENVIADA NO PIX 📲';

  /// Grupo criado no WhatsApp (T-06).
  static const String grupoCriado = 'GRUPO CRIADO NO WHATSAPP ✅';

  /// Enquete postada no grupo (T-07).
  static const String enquetePostada = 'ENQUETE POSTADA NO GRUPO 📲';

  /// Tentar postar sem grupo (T-07).
  static const String crieOGrupoPrimeiro = 'CRIE O GRUPO PRIMEIRO ☝️';

  /// Os onze textos, na ordem em que RN-29 os declara.
  ///
  /// A lista é **contrato**: é por ela que o teste percorre a copy inteira. Um
  /// texto que não entre aqui escapa da verificação.
  static const List<String> todos = <String>[
    linkCopiado,
    roleSalvo,
    conviteCopiado,
    listaNoGrupo,
    abrindoWhatsapp,
    salvoNaAgenda,
    lembreteMandado,
    cobrancaEnviada,
    grupoCriado,
    enquetePostada,
    crieOGrupoPrimeiro,
  ];
}
