import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/lista/presentation/lista_textos.dart';
import '../design_system/design_system.dart';

/// Sub-shell das quatro abas permanentes da festa — Lista · Galera · WhatsApp ·
/// Custos (arquivo 01 §5).
///
/// Vive sobre `StatefulShellRoute.indexedStack` (AD-003): cada aba tem o seu
/// próprio navigator, então trocar de aba **não remonta** a tela nem perde o
/// estado.
///
/// *SPEC_PRECISION_GAP*: **nenhum arquivo de `04` nem de `06` desenha esta
/// barra.** O arquivo 01 §5 só nomeia as quatro abas, em prosa e em sentence
/// case; T-04..T-09 desenham as telas e W-01..W-04 as adaptações web, e nenhum
/// dos dois dá forma, posição, altura ou estado ativo a uma barra de abas. O
/// visual sai **só de tokens do arquivo 02** (A-17): fundo `paper`, a mesma
/// `border-top 2px ink` do rodapé fixo de §5, e o par ativo/inativo do
/// segmented de §5 — `ink`/`cream` no ativo, transparente/`text-2` no inativo.
/// Nenhuma medida nova, nenhuma cor fora dos tokens, nenhuma copy inventada.
///
/// **Os nomes ficam em sentence case**, como o arquivo 01 §5 os escreve — e
/// não em CAIXA ALTA. É por isso que a barra não é um [BoraSegmentedControl],
/// que sobe o rótulo por §7: aqui a copy da spec-fonte manda, como manda em
/// toda esta feature.
///
/// **A Lista não depende desta barra** (A-17): abrir `/roles/:festaId/lista`
/// direto monta a tela inteira, com ou sem o revestimento.
class FestaTabsShell extends StatelessWidget {
  const FestaTabsShell({required this.navigationShell, super.key});

  /// A chave da barra — é por ela que a ausência em `/roles/:festaId/montar`
  /// é afirmável.
  static const Key barraKey = Key('festa-tabs');

  /// A chave da aba de índice [indice], na ordem do arquivo 01 §5.
  static Key chaveDaAba(int indice) => Key('festa-tab-$indice');

  /// O container das abas, entregue pelo `go_router`.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: navigationShell),
        BarraDeAbas(
          indiceAtivo: navigationShell.currentIndex,
          // Sem `initialLocation: true`: tocar a aba corrente **não** a
          // reinicia, e trocar de aba preserva onde a outra estava — é o que
          // o `indexedStack` da AD-003 existe para dar.
          aoTocar: navigationShell.goBranch,
        ),
      ],
    );
  }
}

/// A barra das quatro abas — LIST-35.
///
/// Composta a partir dos tokens do arquivo 02, pelo mesmo critério do rodapé
/// da Lista: quando o catálogo não tem a peça, a feature compõe com os tokens
/// dele, sem número novo e sem tocar `core/design_system/`.
class BarraDeAbas extends StatelessWidget {
  const BarraDeAbas({
    required this.indiceAtivo,
    required this.aoTocar,
    super.key,
  });

  /// O índice da aba correspondente à rota corrente — **exatamente uma**.
  final int indiceAtivo;

  /// Emitido com o índice tocado.
  final ValueChanged<int> aoTocar;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: FestaTabsShell.barraKey,
      decoration: BoxDecoration(
        color: BoraColors.paper,
        // §5: a mesma `border-top 2px ink` do rodapé fixo. A barra separa,
        // não emoldura.
        border: BoraFooterBar.bordaSuperior,
        borderRadius: BoraBorders.raio,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var indice = 0;
                indice < ListaTextos.abasDaFesta.length;
                indice++)
              Expanded(
                child: _Aba(
                  chave: FestaTabsShell.chaveDaAba(indice),
                  rotulo: ListaTextos.abasDaFesta[indice],
                  ativa: indice == indiceAtivo,
                  onTap: () => aoTocar(indice),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Uma aba: o par ativo/inativo do segmented de §5, com o rótulo do arquivo
/// 01 §5.
class _Aba extends StatelessWidget {
  const _Aba({
    required this.chave,
    required this.rotulo,
    required this.ativa,
    required this.onTap,
  });

  final Key chave;
  final String rotulo;
  final bool ativa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: chave,
      // Sem isto o toque no vão transparente da aba inativa se perderia.
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: BoraMotion.estado,
        curve: BoraMotion.curva,
        // §5, segmented: "ativo = fundo `ink` + texto `cream`, inativo =
        // transparente + `text-2`".
        color: ativa ? BoraColors.ink : Colors.transparent,
        // §5 não dá padding à barra de abas — ela não existe lá. Fica o do
        // chip, o vizinho mais próximo, como o próprio segmented faz.
        padding: BoraSpacing.chip,
        alignment: Alignment.center,
        child: Text(
          rotulo,
          textAlign: TextAlign.center,
          style: BoraTextStyles.botao.copyWith(
            color: ativa ? BoraColors.cream : BoraColors.text2,
          ),
        ),
      ),
    );
  }
}
