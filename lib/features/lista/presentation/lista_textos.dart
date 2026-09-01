import '../../../core/calculo/calculo.dart';

/// A copy literal de T-04, RN-27, W-04 e do overlay do pedido, num arquivo só.
///
/// Existe pela mesma razão de `home_textos.dart` e `montar_textos.dart`: os
/// dois layouts desenham a **mesma** tela, e literal espalhado por widget
/// diverge no primeiro ajuste. Os testes afirmam o literal escrito neles,
/// porque a fonte da verdade da copy é a spec — comparar uma constante com ela
/// mesma faria o teste concordar com qualquer copy, inclusive a errada.
///
/// **Nenhum valor de dinheiro nasce aqui, e o cifrão não aparece.** As três
/// frases que a spec escreve com o cifrão — a faixa real, o "por adulto" e a
/// linha do overlay — recebem a string **já formatada** por `MoneyFormatter`.
/// É a escolha declarada que o `design.md` §13 cobra: em vez de pedir ao guard
/// de LIST-07 uma exceção nomeada para este arquivo, o arquivo simplesmente
/// não escreve dinheiro. RN-13 é da camada de cálculo, e o guard vale aqui
/// como vale em todo o resto da feature.
///
/// **Zero toast** (A-23). RN-29 não tem texto canônico para nenhuma ação desta
/// tela, e inventar um seria copy nossa num produto de copy literal — por isso
/// este arquivo não cita o token de toast do design system nem declara texto
/// de toast nenhum. O teste afirma a ausência varrendo a fonte.
abstract final class ListaTextos {
  // --- Cabeça da tela (LIST-01, LIST-02) ---------------------------------

  /// T-04 e W-04: o título da tela, o mesmo nas duas plataformas.
  static const String titulo = 'SUA LISTA';

  /// T-04: a opção "🧮 PLANEJAR" do segmented — o modo default.
  static const String modoPlanejar = '🧮 PLANEJAR';

  /// T-04: a opção "🛒 COMPRAR" do segmented.
  static const String modoComprar = '🛒 COMPRAR';

  /// As duas opções do segmented, **na ordem literal** de T-04.
  static const List<String> opcoesDeModo = [modoPlanejar, modoComprar];

  /// T-04: a dica tracejada do modo PLANEJAR. Corpo em sentence case (§7).
  static const String dicaPlanejar =
      '📊 Cada preço é a média real de mercados perto de você — a barra '
      'mostra o mín/máx que a galera achou.';

  /// T-04: a dica tracejada do modo COMPRAR.
  static const String dicaComprar =
      '✅ Organizado por corredor do mercado — marque o que já tá no carrinho.';

  // --- Modo PLANEJAR (LIST-04, LIST-08, LIST-11) -------------------------

  /// T-04 e RN-10: o rótulo da categoria dos quatro essenciais.
  static const String categoriaDosEssenciais = 'ESSENCIAIS · ENTRAM SOZINHOS';

  /// RN-10: a badge amarela do essencial — `AUTO ∝ {fonte}`.
  ///
  /// [fonte] é metadado do catálogo (`DefinicaoDeItem.fonteDaProporcao`), não
  /// conta: RN-10 nomeia a proporção e não dá fórmula nenhuma (D-5).
  static String autoProporcional(String fonte) => 'AUTO ∝ $fonte';

  /// T-04 e RN-11: a sublinha da linha **coberta** pela tabela de mercado.
  ///
  /// [quantidade] chega pronta de `rotuloDeQuantidade`; [fontes] é a coluna
  /// "Fontes" da própria tabela (AD-023).
  static String mediaDeMercados(String quantidade, int fontes) =>
      '$quantidade · média de $fontes mercados';

  /// T-04: a micro-label vermelha ao lado do valor.
  ///
  /// Renderiza **apenas** nas linhas com leitura de mercado, nomeando o bloco
  /// de faixa (D-2): linha sem cobertura em RN-11 não tem média para nomear.
  static const String media = 'MÉDIA';

  /// RN-12: o rótulo do primeiro stepper do painel de ajuste.
  static const String quantidade = 'QUANTIDADE';

  /// RN-12: o rótulo do segundo stepper.
  static const String preco = 'PREÇO';

  /// A linha final de cada categoria do card — UC-05 ("cada categoria exibe o
  /// seu subtotal").
  ///
  /// *SPEC_PRECISION_GAP*: T-04 pede o subtotal por categoria e não dá rótulo
  /// para ele. Fica o literal que W-03 já usa na mesma função, na lista viva
  /// da tela Montar — em vez de inventar uma palavra nova, o produto repete a
  /// que ele já diz.
  static const String subtotalDaCategoria = 'SUBTOTAL';

  /// T-04: o rótulo do rodapé no modo PLANEJAR.
  static const String mediaTotal = 'MÉDIA TOTAL';

  /// T-04 e LIST-09: a linha da faixa real do rodapé.
  ///
  /// Os dois extremos chegam **já formatados** por `MoneyFormatter` — este
  /// arquivo não escreve dinheiro.
  static String faixaReal(String minimoFormatado, String maximoFormatado) =>
      'faixa real: de $minimoFormatado a $maximoFormatado';

  /// T-04 e RN-14: a linha do "por adulto" do rodapé, nos dois modos.
  ///
  /// [valorFormatado] chega pronto de `MoneyFormatter.reais`.
  static String porAdulto(String valorFormatado) =>
      '≈ $valorFormatado por adulto';

  /// T-04: o CTA do rodapé no modo PLANEJAR.
  static const String fazerPedidoComCarrinho = 'FAZER PEDIDO 🛒';

  /// RN-12: a ação que desfaz **todos** os overrides de uma vez.
  static const String restaurar = 'RESTAURAR';

  // --- Modo COMPRAR (LIST-16, LIST-19) -----------------------------------

  /// O rótulo em caixa alta de [corredor] — RN-27.
  ///
  /// `switch` exaustivo de propósito: um corredor novo **quebra a compilação**
  /// aqui, em vez de aparecer sem nome na tela. A **ordem** em que os cinco
  /// aparecem não é deste arquivo — ela é do card de COMPRAR.
  static String rotuloDoCorredor(Corredor corredor) => switch (corredor) {
        Corredor.acougue => 'AÇOUGUE',
        Corredor.hortifruti => 'HORTIFRÚTI',
        Corredor.padaria => 'PADARIA',
        Corredor.bebidas => 'BEBIDAS',
        Corredor.mercearia => 'MERCEARIA',
      };

  /// T-04: a contagem ao lado do rótulo do corredor.
  ///
  /// *SPEC_PRECISION_GAP*: T-04 escreve "N itens" e não dá a forma singular.
  /// O literal fica como a spec o escreve — flexionar aqui seria inventar copy
  /// que nenhuma spec declara.
  static String itensNoCorredor(int itens) => '$itens itens';

  /// T-04: o contador do rodapé no modo COMPRAR.
  static String noCarrinho(int marcados, int total) =>
      '$marcados de $total no carrinho';

  /// T-04: o CTA do rodapé no modo COMPRAR.
  static const String pedirOQueFalta = 'PEDIR O QUE FALTA 🛵';

  // --- Sheet do pedido (LIST-21..LIST-23) --------------------------------

  /// T-04: o título da sheet.
  static const String tituloDoPedido = 'FAZER PEDIDO';

  /// T-04: o rótulo da seção dos cartões-radio de parceiro.
  static const String entregaPor = 'ENTREGA POR';

  /// T-04: a ação vermelha sublinhada ao lado do endereço.
  static const String trocar = 'TROCAR';

  /// T-04: as três linhas do resumo, em sentence case.
  static const String subtotal = 'Subtotal';
  static const String frete = 'Frete';
  static const String total = 'Total';

  /// T-04: o CTA da sheet.
  static const String confirmarPedido = 'CONFIRMAR PEDIDO →';

  // --- Overlay do pedido (LIST-26) ---------------------------------------

  /// T-04: o título do overlay de tela cheia.
  static const String pedidoACaminho = 'PEDIDO A CAMINHO!';

  /// T-04: a linha do ETA.
  ///
  /// [endereco] é o endereço **inteiro** que a sheet mostrou — "Laje do Rafa
  /// — Vila Madalena", não "Laje do Rafa" (D-6).
  static String chegaEm(String eta, String endereco) =>
      'Chega em $eta na $endereco.';

  /// T-04: a linha vermelha do overlay.
  ///
  /// [totalFormatado] chega pronto de `MoneyFormatter.reais`.
  static String rachadoNoAcerto(String totalFormatado) =>
      '$totalFormatado · rachado no acerto da festa';

  /// T-04: o CTA que encerra o overlay.
  static const String voltarALista = 'VOLTAR À LISTA';

  // --- Abas permanentes da festa (LIST-35) -------------------------------

  /// Arquivo 01 §5: as quatro abas, **na ordem literal**. Corpo em sentence
  /// case, como a spec-fonte as escreve.
  static const List<String> abasDaFesta = [
    'Lista',
    'Galera',
    'WhatsApp',
    'Custos',
  ];
}
