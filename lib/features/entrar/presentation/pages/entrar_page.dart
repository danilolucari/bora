import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/autenticacao/autenticacao.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/responsive/layout_mode.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../bloc/entrar_bloc.dart';
import '../widgets/entrar_compacto.dart';
import '../widgets/entrar_expandido.dart';

/// T-01 e W-01 — a porta de entrada do app.
///
/// **Não navega.** Autenticar muda a sessão, o `refreshListenable` acorda e a
/// guarda de rota leva para a Home (AD-020). Os três caminhos — e-mail/senha,
/// Google e cadastro — terminam no mesmo lugar porque terminam no mesmo
/// mecanismo.
class EntrarPage extends StatefulWidget {
  const EntrarPage({required this.autenticacao, super.key});

  /// Identificador desta tela.
  static const String id = 'entrar';

  /// Chave do destino — é por ela que o teste de rota afirma que chegou aqui.
  static const Key pageKey = Key('entrar');

  /// A porta chega **pelo roteador**, que já a tem para a guarda de AD-017.
  ///
  /// A página não busca no container: resolver `getIt` aqui dentro faria todo
  /// teste de rota precisar configurar DI para montar uma tela, e acoplaria a
  /// tela ao container sem necessidade — quem monta a rota já sabe a resposta.
  final AutenticacaoRepository autenticacao;

  @override
  State<EntrarPage> createState() => _EntrarPageState();
}

class _EntrarPageState extends State<EntrarPage> {
  /// Os controladores vivem **acima** do `ResponsiveBuilder`.
  ///
  /// Se descessem para dentro de cada layout, cruzar 900px destruiria e
  /// recriaria os campos, e o texto digitado sumiria — o edge case da spec.
  final _email = TextEditingController();
  final _senha = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EntrarBloc(widget.autenticacao),
      child: Scaffold(
        key: EntrarPage.pageKey,
        backgroundColor: BoraColors.paper,
        body: BlocBuilder<EntrarBloc, EntrarState>(
          builder: (context, estado) {
            void submeter() => context.read<EntrarBloc>().add(
                  SubmetidoComCredenciais(
                    email: _email.text,
                    senha: _senha.text,
                  ),
                );
            void entrarComGoogle() =>
                context.read<EntrarBloc>().add(const SubmetidoComGoogle());
            void alternarModo() =>
                context.read<EntrarBloc>().add(const ModoAlternado());

            // O bloc e os controladores ficam acima daqui: o `ResponsiveBuilder`
            // só escolhe o enquadramento, e trocar de layout não recria estado.
            return ResponsiveBuilder(
              builder: (context, modo) => modo == LayoutMode.compact
                  ? EntrarCompacto(
                      estado: estado,
                      email: _email,
                      senha: _senha,
                      aoSubmeter: submeter,
                      aoEntrarComGoogle: entrarComGoogle,
                      aoAlternarModo: alternarModo,
                    )
                  : EntrarExpandido(
                      estado: estado,
                      email: _email,
                      senha: _senha,
                      aoSubmeter: submeter,
                      aoEntrarComGoogle: entrarComGoogle,
                      aoAlternarModo: alternarModo,
                    ),
            );
          },
        ),
      ),
    );
  }
}
