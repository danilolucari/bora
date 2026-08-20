/// Mapa de rotas canônico do BORA — herdado pelas specs de tela 03–10.
///
/// A base `/roles` vem de W-R5 (`bora.app/roles`) e `/c/:codigo` vem do link de
/// RN-22/RN-24 (`bora.app/c/rafa18`). Quem tem parâmetro ganha um construtor,
/// para que nenhuma tela monte URL concatenando string à mão.
abstract final class Routes {
  /// Nome do parâmetro de rota que identifica a festa.
  static const String paramFestaId = 'festaId';

  /// Nome do parâmetro de rota que carrega o código do convite.
  static const String paramCodigo = 'codigo';

  /// T-01 — fora de qualquer shell.
  static const String entrar = '/entrar';

  /// T-02 home — dentro do shell do app.
  static const String roles = '/roles';

  /// T-03 montar, para um rolê que ainda não existe.
  static const String novoRole = '/roles/novo';

  /// Destino de erro (FUND-09) — fora de qualquer shell.
  static const String erro = '/erro';

  /// T-03 montar, para um rolê existente.
  static const String montarPattern = '/roles/:$paramFestaId/montar';

  /// T-04 — aba permanente da festa.
  static const String listaPattern = '/roles/:$paramFestaId/lista';

  /// T-05 — aba permanente da festa.
  static const String galeraPattern = '/roles/:$paramFestaId/galera';

  /// T-06/T-07 — aba permanente da festa.
  static const String whatsappPattern = '/roles/:$paramFestaId/whatsapp';

  /// T-09 — aba permanente da festa.
  static const String custosPattern = '/roles/:$paramFestaId/custos';

  /// T-08 convidado — **fora de qualquer shell e sem autenticação**.
  static const String convidadoPattern = '/c/:$paramCodigo';

  static String montar(String festaId) => '/roles/$festaId/montar';

  static String lista(String festaId) => '/roles/$festaId/lista';

  static String galera(String festaId) => '/roles/$festaId/galera';

  static String whatsapp(String festaId) => '/roles/$festaId/whatsapp';

  static String custos(String festaId) => '/roles/$festaId/custos';

  static String convidado(String codigo) => '/c/$codigo';
}
