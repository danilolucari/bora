import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/observability/app_logger.dart';
import '../../../../core/routing/routes.dart';
import '../../domain/festa_repository.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_compacta.dart';

/// T-02 e W-02 — o painel de rolês, e o destino de todo login.
///
/// A porta e o logger chegam **pelo roteador**, como a de sessão chega à
/// `EntrarPage`: a página não resolve `getIt`, porque isso faria todo teste de
/// rota configurar DI só para montar uma tela.
///
/// Aqui a navegação **é** imperativa, e isso não fere a AD-020: ela proíbe
/// navegar por efeito de **sessão**, não por toque em botão.
class HomePage extends StatelessWidget {
  const HomePage({required this.festas, required this.logger, super.key});

  /// Identificador desta tela.
  static const String id = 'home';

  /// Chave do destino — é por ela que o teste de rota afirma que chegou aqui.
  ///
  /// Substitui a `PlaceholderPage.keyFor('home')` que a fundação usava (E-4),
  /// do mesmo jeito que a spec 03 criou `EntrarPage.pageKey`.
  static const Key pageKey = Key('home');

  final FestaRepository festas;
  final AppLogger logger;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(festas, logger),
      child: Scaffold(
        key: pageKey,
        backgroundColor: BoraColors.paper,
        body: SafeArea(
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, estado) => HomeCompacta(
              estado: estado,
              aoConvidar: (resumo) => _ir(context, Routes.whatsapp(resumo.id)),
              aoMontarLista: (resumo) =>
                  _ir(context, Routes.montar(resumo.id)),
              aoVerOAcerto: (resumo) => _ir(context, Routes.custos(resumo.id)),
              aoComecarChurrasco: () => _ir(context, Routes.novoRole),
            ),
          ),
        ),
      ),
    );
  }

  /// `go`, e não `push`: dois toques no mesmo botão levam ao mesmo lugar uma
  /// vez só, em vez de empilhar duas cópias da tela (HOME-17).
  void _ir(BuildContext context, String rota) => context.go(rota);
}
