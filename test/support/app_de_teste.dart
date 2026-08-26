import 'package:bora/app.dart';
import 'package:bora/core/autenticacao/autenticacao.dart';
import 'package:bora/core/routing/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_autenticacao_repository.dart';

/// Monta o app inteiro em [location], com a sessão que o teste pedir.
///
/// Existe porque a guarda de AD-017 tornou a sessão parte da montagem: desde
/// que `buildAppRouter` exige a porta, **todo teste de rota precisa dizer se
/// há sessão** — e essa passou a ser metade do que a rota decide. Concentrar a
/// fiação aqui evita quatro cópias divergindo.
///
/// Devolve o duplo para que o teste possa mudar a sessão com a tela montada,
/// que é como ENT-18 é afirmado.
Future<FakeAutenticacaoRepository> abrirApp(
  WidgetTester tester,
  String location, {
  UsuarioLogado? sessao,
}) async {
  final autenticacao = FakeAutenticacaoRepository(sessaoInicial: sessao);
  addTearDown(autenticacao.dispose);

  await tester.pumpWidget(
    BoraApp(
      router: buildAppRouter(
        autenticacao: autenticacao,
        initialLocation: location,
      ),
    ),
  );
  await tester.pumpAndSettle();

  return autenticacao;
}

/// Uma sessão qualquer, para os testes que só precisam de "está logado".
const UsuarioLogado sessaoDeTeste = FakeAutenticacaoRepository.usuarioPadrao;
