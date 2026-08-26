import 'dart:async';

import 'package:bora/features/home/domain/festa_repository.dart';
import 'package:bora/features/home/domain/resumo_de_festa.dart';

/// Uma porta de festas que emite e falha **sob comando** — o duplo de HOME-16.
///
/// Mora em `test/support/` pelo mesmo motivo de `FakeAutenticacaoRepository`:
/// era idêntica em dois arquivos de teste, e duplo duplicado diverge no
/// primeiro ajuste.
///
/// O controller é broadcast de propósito: é o que o `FestaRepositoryEmMemoria`
/// usa, e o erro num broadcast **não** cancela a inscrição de quem ouve — a
/// propriedade que o `HomeBloc` depende para não apagar o que já chegou.
class FestaRepositoryQueFalha implements FestaRepository {
  final _controlador = StreamController<List<ResumoDeFesta>>.broadcast();

  @override
  Stream<List<ResumoDeFesta>> observarFestas() => _controlador.stream;

  void emitir(List<ResumoDeFesta> festas) => _controlador.add(festas);

  void falhar(Object erro) => _controlador.addError(erro, StackTrace.current);

  @override
  Future<void> dispose() => _controlador.close();
}
