import 'package:flutter/material.dart';

import '../../responsive/layout_mode.dart';
import '../../responsive/responsive_builder.dart';
import '../tokens/bora_spacing.dart';
import '../tokens/bora_text_styles.dart';
import '../tokens/bora_theme.dart';
import 'catalog_sections.dart';

/// O catálogo do design system, na rota interna `/catalogo` (DS-33).
///
/// É o único lugar onde token e componente aparecem juntos, e existe para que
/// a conferência a olho contra o arquivo 02 — no mobile e no web — seja
/// barata. Não é tela de produto: não tem dado, não escreve nada e fica fora
/// do shell do app.
///
/// A página aplica `boraTheme()` **em si mesma** porque o tema ainda não é
/// plugado no `BoraApp`: `lib/app.dart` está fora da fronteira desta spec
/// (A-16), e quem o pluga é a spec 03.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  /// Chave do destino da rota: é por ela que o teste afirma que `/catalogo`
  /// chega à página, e não a uma tela em branco.
  static const Key pageKey = Key('catalogo');

  /// Arquivo 06 §Layout: "container central `max-width: 1040–1060px`, padding
  /// lateral 36px". Onde a spec dá faixa, vale o extremo inferior (A-01).
  static const double _larguraMaxima = 1040;
  static const EdgeInsets _margemExpandida = EdgeInsets.symmetric(
    horizontal: 36,
    vertical: 24,
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: boraTheme(),
      child: Scaffold(
        key: pageKey,
        body: SafeArea(
          // O modo de layout vem de AD-007: o breakpoint mora em
          // `core/responsive/` e não é redeclarado nem reexportado aqui.
          child: ResponsiveBuilder(
            builder: (context, mode) => SingleChildScrollView(
              padding: mode == LayoutMode.compact
                  ? BoraSpacing.linhaLista
                  : _margemExpandida,
              child: _coluna(mode),
            ),
          ),
        ),
      ),
    );
  }

  Widget _coluna(LayoutMode mode) {
    final conteudo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final secao in secoes) _Secao(secao: secao),
      ],
    );

    if (mode == LayoutMode.compact) {
      return conteudo;
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _larguraMaxima),
        child: conteudo,
      ),
    );
  }
}

/// Uma seção do registro, com o título e o trecho do arquivo 02 que ela prova.
class _Secao extends StatelessWidget {
  const _Secao({required this.secao});

  final BoraCatalogSection secao;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(secao.titulo, style: BoraTextStyles.tituloCard),
          Text(secao.referencia, style: BoraTextStyles.microTag),
          secao.builder(context),
        ],
      ),
    );
  }
}
