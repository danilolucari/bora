import 'package:flutter/painting.dart';

import 'bora_colors.dart';

/// O conjunto **fechado** de acentos do sistema (§1 e §8).
///
/// Cada acento tem significado fixo, e é por isso que componente nenhum
/// recebe `Color` cru: receber `BoraAccent` é o que torna possível a regra de
/// tela "máx. 2 cores de acento", que as specs de tela cobram.
enum BoraAccent {
  /// Vermelho `#FF4D2E` — dinheiro e CTA geral: sombras de CTA, tags de data,
  /// valores "por cabeça", marcador de média.
  primary(BoraColors.primary),

  /// Roxo `#6C4BF5` — galera e link: card do link, banner do convidado, papel
  /// CO-ANFITRIÃO.
  purple(BoraColors.purple),

  /// `#25D366` — tudo WhatsApp: criar grupo, voto, barra de quitação.
  waGreen(BoraColors.waGreen),

  /// Verde `#0B6B3A` — pago/comprado: checkbox comprado, botão PAGO ✓.
  green(BoraColors.green),

  /// Amarelo `#FFD23F` — destaque: label em card escuro, tag AUTO, papel
  /// ANFITRIÃO.
  yellow(BoraColors.yellow),

  /// `#141414` — neutro: a sombra dura sem contexto de acento.
  ink(BoraColors.ink);

  const BoraAccent(this.cor);

  /// A cor do acento, sempre um token de §1.
  final Color cor;
}
