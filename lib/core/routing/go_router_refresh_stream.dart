import 'dart:async';

import 'package:flutter/foundation.dart';

/// Transforma um `Stream` em `Listenable`, para o `refreshListenable` do
/// `go_router`.
///
/// O `go_router` reavalia os `redirect` quando o `refreshListenable` notifica,
/// mas só aceita `Listenable` — e o estado de sessão chega como `Stream`. Esta
/// ponte é o que faz a guarda de AD-017 acordar sozinha quando alguém entra ou
/// sai, e é por isso que nenhuma feature precisa chamar `context.go` para
/// efeito de login (AD-020).
///
/// O pacote não exporta um utilitário assim; esta é a forma canônica,
/// documentada pelo próprio `go_router`.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _inscricao = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  // O exemplo canônico do `go_router` chama `notifyListeners()` aqui no
  // construtor. Ficou de fora de propósito: nenhum ouvinte existe ainda nesse
  // instante — o roteador só se inscreve depois que este objeto está
  // construído —, então a chamada não pode ter efeito. Manter seria código
  // morto pedindo um teste que passaria sob qualquer implementação.

  late final StreamSubscription<dynamic> _inscricao;

  @override
  void dispose() {
    // Cancelar é o que impede a inscrição de sobreviver ao roteador e
    // contaminar o teste seguinte — o mesmo cuidado que a porta de
    // autenticação leva no seu próprio dispose.
    _inscricao.cancel();
    super.dispose();
  }
}
