import 'dart:ui';

/// O par de cores de um avatar: fundo e texto das iniciais.
///
/// Arquivo 02 §1, "Cores de avatar (fixas por pessoa)".
typedef BoraAvatarPair = ({Color fundo, Color texto});

/// Os tokens de cor do arquivo 02 §1, mais as cores derivadas de §3/§4/§5.
///
/// Este é o **único** arquivo do projeto autorizado a conter um literal de cor
/// (DS-09): qualquer `Color(0x…)` fora daqui quebra a guarda de pureza.
abstract final class BoraColors {
  /// `#F4EFE3` — fundo de todas as telas e barras fixas.
  static const paper = Color(0xFFF4EFE3);

  /// `#EFECE5` — preenchimentos neutros (trilho de barra, chips de fundo).
  static const paper2 = Color(0xFFEFECE5);

  /// `#141414` — texto principal, bordas, botões primários, cards escuros.
  static const ink = Color(0xFF141414);

  /// `#F4EFE3` — texto sobre [ink]. Mesmo valor de [paper], papel diferente:
  /// §1 declara os dois tokens, e é por token que a tela pede a cor.
  static const cream = Color(0xFFF4EFE3);

  /// `#FF4D2E` — ação/acento principal: sombras de CTA, tags de data, valores
  /// "por cabeça", marcador de média.
  static const primary = Color(0xFFFF4D2E);

  /// `#FFD23F` — destaques: labels em card escuro, tag AUTO, papel ANFITRIÃO.
  static const yellow = Color(0xFFFFD23F);

  /// `#6C4BF5` — contexto convidado/link/galera.
  static const purple = Color(0xFF6C4BF5);

  /// `#0B6B3A` — sucesso financeiro: checkbox comprado, botão PAGO ✓.
  static const green = Color(0xFF0B6B3A);

  /// `#25D366` — tudo WhatsApp: sombras, botão criar grupo, voto.
  static const waGreen = Color(0xFF25D366);

  /// `#E7DFCB` — fundo de conversa WhatsApp (preview).
  static const waBubble = Color(0xFFE7DFCB);

  /// `#DCF8C6` — chip "grupo criado".
  static const waConfirm = Color(0xFFDCF8C6);

  /// `#FFFFFF` — cards e listas.
  static const white = Color(0xFFFFFFFF);

  /// `#6b6b6b` — texto secundário, labels de seção.
  static const text2 = Color(0xFF6B6B6B);

  /// `#9b9b9b` — texto terciário, mín/máx.
  static const text3 = Color(0xFF9B9B9B);

  /// `#3a3a3a` — parágrafos.
  static const textBody = Color(0xFF3A3A3A);

  /// `#141414` @ 9% (`#14141418`) — separador de linhas em lista (2px).
  ///
  /// O hex de §1 é RGBA: o alfa é o **último** par no CSS e o **primeiro**
  /// byte no Dart.
  static const divider = Color(0x18141414);

  /// `#141414` @ 13% (`#14141422`) — divisor interno de segmented (2px).
  static const divider2 = Color(0x22141414);

  // --- Cores derivadas (A-15) -------------------------------------------
  // §1 não as tabela, mas elas aparecem literais em §3/§4/§5. Viram token
  // nomeado para que "nenhuma cor fora dos tokens" não seja burlada por
  // literal inline.

  /// §5 bottom sheet, "Overlay `rgba(20,10,50,.45)`".
  ///
  /// Repare que **não** é [ink] com alfa: é um preto-arroxeado próprio.
  static const sheetScrim = Color(0x73140A32);

  /// §5 opção de enquete, "barra de % preenchendo o fundo com
  /// `rgba(37,211,102,.18)`" — [waGreen] a 18%.
  static const pollFill = Color(0x2E25D366);

  /// §5 segmented control, variante sobre card escuro: "borda e divisores em
  /// `cream`/25%".
  static const creamQuarter = Color(0x40F4EFE3);

  /// §5 frame do celular, "`border 1px rgba(0,0,0,.25)`".
  static const frameBorder = Color(0x40000000);

  /// §4 frame do celular, "`0 20px 50px -20px rgba(20,10,50,.35)`" — a cor da
  /// única sombra suave do sistema.
  static const frameShadow = Color(0x59140A32);

  /// As cores de avatar fixas por pessoa (§1), na ordem em que §1 as declara.
  ///
  /// O "+N" da pilha não entra aqui: §1 o descreve como branco com borda
  /// tracejada, e é a borda que o define.
  static const Map<String, BoraAvatarPair> avatarPairs = {
    'Rafa': (fundo: primary, texto: white),
    'Ana': (fundo: yellow, texto: ink),
    'Léo': (fundo: purple, texto: white),
    'Bia': (fundo: green, texto: white),
    'Duda': (fundo: ink, texto: cream),
  };

  /// O par de cores do avatar de [nome].
  ///
  /// Nome da tabela de §1 recebe o par de §1. Nome de fora recebe **um dos
  /// mesmos cinco pares**, escolhido pela soma dos code units módulo 5
  /// (A-05): o mesmo nome cai sempre no mesmo par, e nenhuma cor nova entra
  /// no sistema.
  static BoraAvatarPair avatarPairFor(String nome) {
    final fixo = avatarPairs[nome];
    if (fixo != null) {
      return fixo;
    }
    final pares = avatarPairs.values.toList(growable: false);
    final checksum =
        nome.codeUnits.fold<int>(0, (soma, unidade) => soma + unidade);
    return pares[checksum % pares.length];
  }
}
