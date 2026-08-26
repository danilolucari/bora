import 'dart:async';

import '../domain/festa_repository.dart';
import '../domain/resumo_de_festa.dart';

/// A implementação que o M1 **roda de verdade** (AD-016) — não é duplo de
/// teste.
///
/// A semente entra **por injeção**: quem monta a lista é o `main` ou o teste,
/// nunca este arquivo. É o que impede `lib/` de importar `test/fixtures/`, e
/// há uma varredura de import afirmando isso.
///
/// Em produção a semente é vazia — a fixture RN-30 é dado de teste (G7). O app
/// abre no estado vazio de HOME-15 até a spec 05 criar festa.
class FestaRepositoryEmMemoria implements FestaRepository {
  FestaRepositoryEmMemoria({List<ResumoDeFesta> inicial = const []})
      : _ultimo = inicial;

  final StreamController<List<ResumoDeFesta>> _mudancas =
      StreamController<List<ResumoDeFesta>>.broadcast();

  List<ResumoDeFesta> _ultimo;

  /// Entrega o estado corrente **antes** de acompanhar as mudanças.
  ///
  /// Sem o primeiro `yield`, quem assina depois da semente ficaria numa tela
  /// em branco até a próxima emissão — e o bloc, que assina na construção,
  /// dependeria da ordem em que o teste chama as coisas.
  @override
  Stream<List<ResumoDeFesta>> observarFestas() async* {
    yield _ultimo;
    yield* _mudancas.stream;
  }

  /// Empurra um estado novo para quem já está ouvindo.
  ///
  /// É por aqui que o teste faz a confirmação de RN-28 chegar com a tela
  /// montada, enquanto a spec 09 `convidado` não existe (A-02).
  void emitir(List<ResumoDeFesta> festas) {
    _ultimo = festas;
    _mudancas.add(festas);
  }

  @override
  Future<void> dispose() => _mudancas.close();
}
