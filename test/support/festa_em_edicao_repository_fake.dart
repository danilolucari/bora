import 'dart:async';

import 'package:bora/core/festas/festas.dart';

/// Duplo à mão da porta de edição de festa (**AD-021**: `mocktail` só para SDK
/// de terceiro; porta de domínio tem fake próprio).
///
/// Guarda **o que foi gravado e em que ordem** — é o que torna afirmável que
/// `criarFesta` foi chamado uma vez só, e que a última gravação carrega o
/// estado mais novo.
///
/// A emissão do stream é **explícita** ([emitir]): gravar não ecoa de volta,
/// para que o teste decida quando a mudança vinda de fora chega à tela.
class FestaEmEdicaoRepositoryFake implements FestaEmEdicaoRepository {
  FestaEmEdicaoRepositoryFake({Map<String, FestaEmEdicao>? festas})
      : _festas = {...?festas};

  final Map<String, FestaEmEdicao> _festas;
  final Map<String, StreamController<FestaEmEdicao?>> _controllers = {};

  /// Os rascunhos passados a [criarFesta], na ordem.
  final List<FestaEmEdicao> criadas = [];

  /// Os pares `(id, festa)` passados a [salvarFesta], na ordem.
  final List<(String, FestaEmEdicao)> salvas = [];

  /// O id que a próxima [criarFesta] devolve.
  String proximoId = 'festa-1';

  @override
  Stream<FestaEmEdicao?> observarFesta(String id) =>
      Stream<FestaEmEdicao?>.multi((assinante) {
        assinante.add(_festas[id]);

        final inscricao = _controllerDe(id).stream.listen(
              assinante.add,
              onError: assinante.addError,
              onDone: assinante.close,
            );
        assinante.onCancel = inscricao.cancel;
      });

  @override
  Future<String> criarFesta(FestaEmEdicao rascunho) async {
    criadas.add(rascunho);

    final id = proximoId;
    _festas[id] = rascunho;

    return id;
  }

  @override
  Future<void> salvarFesta(String id, FestaEmEdicao festa) async {
    salvas.add((id, festa));
    _festas[id] = festa;
  }

  /// Empurra uma emissão para quem estiver ouvindo [id] — a mudança que chega
  /// de fora com a tela aberta.
  void emitir(String id, FestaEmEdicao? festa) {
    if (festa == null) {
      _festas.remove(id);
    } else {
      _festas[id] = festa;
    }

    _controllerDe(id).add(festa);
  }

  Future<void> dispose() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
  }

  StreamController<FestaEmEdicao?> _controllerDe(String id) =>
      _controllers.putIfAbsent(
        id,
        StreamController<FestaEmEdicao?>.broadcast,
      );
}
