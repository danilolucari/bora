import 'package:bora/features/galera/domain/area_de_transferencia.dart';

/// Duplo escrito à mão da porta da área de transferência (**AD-021**).
///
/// Guarda **o que foi copiado e em que ordem** — é o que torna afirmável que
/// os dois botões de T-05 copiam a mesma URL (GAL-03) — e sabe falhar sob
/// demanda, que é o caminho de GAL-05.
class AreaDeTransferenciaFalsa implements AreaDeTransferencia {
  /// Os textos passados a [copiar], na ordem — inclusive os das tentativas que
  /// falharam. A tentativa é o fato observável; o sucesso é quem chamou que
  /// decide o que fazer com ele.
  final List<String> copiados = [];

  /// Quando não-nulo, é lançado por [copiar] — o canal indisponível de GAL-05.
  Object? erro;

  @override
  Future<void> copiar(String texto) async {
    copiados.add(texto);

    final falha = erro;
    if (falha != null) throw falha;
  }
}
