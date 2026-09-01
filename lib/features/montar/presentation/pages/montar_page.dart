import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/festas/festas.dart';
import '../../../../core/observability/app_logger.dart';
import '../../../../core/responsive/layout_mode.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/routing/routes.dart';
import '../../domain/rascunho_inicial.dart';
import '../bloc/montar_bloc.dart';
import '../widgets/montar_compacto.dart';
import '../widgets/montar_expandido.dart';

/// T-03 e W-03 — a tela que **é** o produto (MONT-12, MONT-17, MONT-22,
/// MONT-23).
///
/// A porta de edição e o logger chegam **pelo roteador**, como em
/// [HomePage]: a página não resolve `getIt`, porque isso faria todo teste de
/// rota configurar DI só para montar uma tela.
///
/// O bloc vive **acima** do [ResponsiveBuilder]: cruzar os 900px de AD-007
/// com a tela montada reorganiza a árvore sem destruir o estado — é o que
/// torna W-R3 compatível com W-R1 ("mesmo estado nos dois quadros"). Se o
/// bloc descesse para dentro de cada layout, redimensionar a janela zeraria a
/// composição e reassinaria o repositório do zero.
///
/// Aqui a navegação **é** imperativa, e isso não fere a AD-020: ela proíbe
/// navegar por efeito de **sessão**, não por toque em botão.
class MontarPage extends StatelessWidget {
  const MontarPage({
    required this.festas,
    required this.logger,
    this.festaId,
    super.key,
  });

  /// Identificador desta tela.
  static const String id = 'montar';

  /// Chave do destino — é por ela que o teste sabe que a tela está montada.
  ///
  /// **Não** é por ela que o teste de rota afirma o destino: `/roles/novo` e
  /// `/roles/:festaId/montar` montam as duas esta mesma página, então quem
  /// diz para onde se foi é `rotaAtual()` (AD-014).
  static const Key pageKey = Key('montar');

  /// O rolê que a rota carrega, ou `null` em `/roles/novo` — o rascunho que
  /// ainda não existe (MONT-17).
  final String? festaId;

  final FestaEmEdicaoRepository festas;
  final AppLogger logger;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MontarBloc(
        festas,
        logger,
        // O relógio é da borda: o bloc recebe o rascunho pronto, e é isso que
        // torna a data default afirmável sem esperar sábado.
        inicial: rascunhoInicial(hoje: DateTime.now()),
        festaId: festaId,
      ),
      child: Scaffold(
        key: pageKey,
        backgroundColor: BoraColors.paper,
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              BlocListener<MontarBloc, MontarState>(
                // MONT-17: a primeira mudança criou a festa. A URL passa a
                // refletir o `festaId`.
                listenWhen: (anterior, atual) =>
                    anterior.festaId == null && atual.festaId != null,
                listener: (context, estado) =>
                    // `replace`, e não `go`: a URL do rascunho não pode virar
                    // entrada de histórico — voltar do rolê recém-criado tem
                    // de ir para a Home, não para um `/roles/novo` vazio.
                    context.replace(Routes.montar(estado.festaId!)),
              ),
              BlocListener<MontarBloc, MontarState>(
                // MONT-23: um "SALVAR ROLÊ" concluiu. `salvamentos` é
                // contador justamente para que o segundo salvar seguido
                // também tenha toast.
                listenWhen: (anterior, atual) =>
                    atual.salvamentos > anterior.salvamentos,
                listener: (context, estado) => BoraToast.mostrar(
                  context,
                  texto: BoraToastTexts.roleSalvo,
                ),
              ),
            ],
            child: BlocBuilder<MontarBloc, MontarState>(
              builder: (context, estado) => ResponsiveBuilder(
                builder: (context, modo) => modo == LayoutMode.compact
                    ? MontarCompacto(
                        estado: estado,
                        aoVoltar: () => _ir(context, Routes.roles),
                        aoAlterarContagem: (tipo, delta) => _emitir(
                          context,
                          ContagemAlterada(tipo, delta),
                        ),
                        aoAlternarItem: (chave) =>
                            _emitir(context, ItemAlternado(chave)),
                        aoSelecionarDuracao: (horas) =>
                            _emitir(context, DuracaoAlterada(horas)),
                        aoAlterarNome: (nome) =>
                            _emitir(context, NomeAlterado(nome)),
                        aoAlterarData: (data) =>
                            _emitir(context, DataAlterada(data)),
                        aoFecharLista: () => _sairPara(
                          context,
                          estado,
                          Routes.lista,
                        ),
                      )
                    : MontarExpandido(
                        estado: estado,
                        aoAlterarContagem: (tipo, delta) => _emitir(
                          context,
                          ContagemAlterada(tipo, delta),
                        ),
                        aoAlternarItem: (chave) =>
                            _emitir(context, ItemAlternado(chave)),
                        aoSelecionarDuracao: (horas) =>
                            _emitir(context, DuracaoAlterada(horas)),
                        aoMandarNoGrupo: () => _sairPara(
                          context,
                          estado,
                          Routes.whatsapp,
                        ),
                        aoSalvar: () => _emitir(context, const SalvarPedido()),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _emitir(BuildContext context, MontarEvent evento) =>
      context.read<MontarBloc>().add(evento);

  /// As duas saídas que dependem do rolê existir — MONT-22.
  ///
  /// *SPEC_PRECISION_GAP*: nem T-03 nem W-03 dizem o que os CTAs fazem num
  /// rascunho que ainda não foi persistido (`/roles/novo` sem nenhum toque).
  /// Como o destino é `/roles/{festaId}/…`, sem id **não há para onde ir** e
  /// a tela fica onde está. Desabilitar o botão exigiria abrir o contrato dos
  /// dois widgets de saída para `VoidCallback?`, que é mudança de componente
  /// sem spec que a peça.
  void _sairPara(
    BuildContext context,
    MontarState estado,
    String Function(String festaId) rota,
  ) {
    final id = estado.festaId;
    if (id == null) return;

    _ir(context, rota(id));
  }

  /// `go`, e não `push`: dois toques no mesmo botão levam ao mesmo lugar uma
  /// vez só, em vez de empilhar duas cópias da tela (MONT-20, HOME-17).
  void _ir(BuildContext context, String rota) => context.go(rota);
}
