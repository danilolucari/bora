import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/observability/app_logger.dart';
import '../../../../core/responsive/layout_mode.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../data/area_de_transferencia_do_sistema.dart';
import '../../domain/area_de_transferencia.dart';
import '../../domain/galera_repository.dart';
import '../bloc/galera_bloc.dart';
import '../galera_textos.dart';
import '../widgets/galera_compacta.dart';
import '../widgets/galera_expandida.dart';

/// T-05 e W-04 — a galera da festa (GAL-03, GAL-05, GAL-23, GAL-25, GAL-27).
///
/// A porta e o logger chegam **pelo roteador**, como em `ListaPage` e
/// `MontarPage`: a página não resolve `getIt`, porque isso faria todo teste de
/// rota configurar DI só para montar uma tela (precedente E-4 de `montar`).
///
/// **Um `BlocProvider` só, acima do `ResponsiveBuilder`.** É o que faz
/// GAL-23 AC3 e AC5 serem verdade **por construção**: cruzar os 900px de
/// AD-007 com a tela montada reorganiza a árvore sem destruir o bloc, então o
/// painel aberto e o nível selecionado atravessam a fronteira inteiros. Se o
/// bloc descesse para dentro de cada layout, redimensionar a janela zeraria a
/// tela e reassinaria a porta do zero.
///
/// **Não decide permissão por conta própria** (GAL-27): as duas capacidades
/// saem de [CapacidadesDaGalera.de], que consulta `papelDoUsuario` e `pode` de
/// `permissoes.dart` — a tabela de RN-22 tem um dono só (AD-031).
class GaleraPage extends StatelessWidget {
  const GaleraPage({
    required this.festaId,
    required this.galera,
    required this.logger,
    this.area = const AreaDeTransferenciaDoSistema(),
    super.key,
  });

  /// Identificador desta tela.
  static const String id = 'galera';

  /// Chave do destino — é por ela que o teste sabe que a tela está montada.
  ///
  /// **Não** é por ela que o teste de rota afirma o destino: quem diz para
  /// onde se foi é `rotaAtual()` (AD-014).
  static const Key pageKey = Key('galera');

  /// A festa que a rota carrega.
  final String festaId;

  /// A porta de leitura e escrita da galera (GAL-19 AC7).
  final GaleraRepository galera;

  final AppLogger logger;

  /// A única dependência externa da tela (A-07).
  ///
  /// `const` por default, e não pelo roteador: é serviço de plataforma sem
  /// estado e sem ciclo de vida (`design.md` §7.3). O teste a troca por um
  /// duplo sem tocar em rota nenhuma.
  final AreaDeTransferencia area;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GaleraBloc(festaId, galera, area, logger),
      child: Scaffold(
        key: pageKey,
        backgroundColor: BoraColors.paper,
        body: SafeArea(
          child: BlocListener<GaleraBloc, GaleraState>(
            // GAL-03 AC6 e GAL-05: **só o sucesso** move o contador, então na
            // falha da área de transferência não existe transição — e não
            // existe toast. Contador, e não `bool`: com um booleano a segunda
            // cópia seguida não mudaria o estado e o segundo toast não sairia
            // (RN-29, "1 por vez", o novo substituindo o anterior).
            listenWhen: (anterior, atual) =>
                atual.copiasConcluidas > anterior.copiasConcluidas,
            listener: (context, estado) => BoraToast.mostrar(
              context,
              texto: GaleraTextos.linkCopiado,
            ),
            child: BlocBuilder<GaleraBloc, GaleraState>(
              builder: (context, estado) {
                final capacidades = CapacidadesDaGalera.de(
                  estado.galera?.pessoas ?? const [],
                );

                return ResponsiveBuilder(
                  builder: (context, modo) => modo == LayoutMode.compact
                      ? _compacta(context, estado, capacidades)
                      : _expandida(context, estado, capacidades),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  GaleraCompacta _compacta(
    BuildContext context,
    GaleraState estado,
    CapacidadesDaGalera capacidades,
  ) =>
      GaleraCompacta(
        estado: estado,
        capacidades: capacidades,
        aoCopiar: () => _emitir(context, const LinkCopiado()),
        aoEscolherNivel: (nivel) => _emitir(context, NivelEscolhido(nivel)),
        aoAlternarLinha: (chave) => _emitir(context, LinhaAlternada(chave)),
        aoEscolherPapel: (chave, papel) =>
            _emitir(context, PapelEscolhido(chave, papel)),
        aoEscolherDieta: (chave, dieta) =>
            _emitir(context, DietaEscolhida(chave, dieta)),
        aoAlternarBebida: (chave, bebe) =>
            _emitir(context, BebidaAlternada(chave, bebe)),
      );

  GaleraExpandida _expandida(
    BuildContext context,
    GaleraState estado,
    CapacidadesDaGalera capacidades,
  ) =>
      GaleraExpandida(
        estado: estado,
        capacidades: capacidades,
        aoCopiar: () => _emitir(context, const LinkCopiado()),
        aoEscolherNivel: (nivel) => _emitir(context, NivelEscolhido(nivel)),
        aoAlternarLinha: (chave) => _emitir(context, LinhaAlternada(chave)),
        aoEscolherPapel: (chave, papel) =>
            _emitir(context, PapelEscolhido(chave, papel)),
        aoEscolherDieta: (chave, dieta) =>
            _emitir(context, DietaEscolhida(chave, dieta)),
        aoAlternarBebida: (chave, bebe) =>
            _emitir(context, BebidaAlternada(chave, bebe)),
      );

  void _emitir(BuildContext context, GaleraEvent evento) =>
      context.read<GaleraBloc>().add(evento);
}
