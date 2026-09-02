import 'package:flutter/services.dart';

import '../domain/area_de_transferencia.dart';

/// A área de transferência de verdade — o **único** arquivo da feature que
/// importa `flutter/services.dart`.
///
/// `const`, e sem estado: chega à página por default, e não pelo roteador
/// (`design.md` §7.3). É serviço de plataforma sem configuração e sem ciclo de
/// vida; o repositório, que tem estado, continua vindo do roteador.
///
/// Não captura a falha do canal de propósito — ver [AreaDeTransferencia.copiar]
/// e GAL-05.
class AreaDeTransferenciaDoSistema implements AreaDeTransferencia {
  const AreaDeTransferenciaDoSistema();

  @override
  Future<void> copiar(String texto) =>
      Clipboard.setData(ClipboardData(text: texto));
}
