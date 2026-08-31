import 'package:bora/app.dart';
import 'package:bora/core/autenticacao/autenticacao.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/festa_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_autenticacao_repository.dart';
import 'recording_app_logger.dart';

/// O roteador que a última chamada de [abrirApp] montou.
///
/// Guardado para que [rotaAtual] exista: sem ele, todo teste de navegação
/// tinha de afirmar o **destino renderizado**, e duas rotas diferentes podem
/// renderizar a mesma tela — `/roles/novo` e `/roles/:festaId/montar` montam
/// os dois a `MontarPage`. Foi por isso que três mutantes de navegação
/// sobreviveram ao Verifier.
GoRouter? _ultimoRouter;

/// A URL que está montada agora.
///
/// É o que afirma **para onde** um toque levou, e não só que a tela mudou.
String rotaAtual() => _ultimoRouter!.routerDelegate.currentConfiguration.uri
    .toString();

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
  FestaRepository? festas,
  FestaEmEdicaoRepository? festasEmEdicao,
}) async {
  final autenticacao = FakeAutenticacaoRepository(sessaoInicial: sessao);
  addTearDown(autenticacao.dispose);

  // A porta de festas entrou pela mesma razão que a de sessão (E-3): o
  // roteador a exige para montar a Home. O default é o repositório vazio, e
  // não um nulo tolerado — a Home tem estado vazio próprio (HOME-15), então
  // toda rota continua montável sem o teste dizer nada sobre festas.
  final repositorio = festas ?? FestaRepositoryEmMemoria();
  addTearDown(repositorio.dispose);

  // A porta de escrita é a **mesma instância**, quando o duplo de leitura a
  // implementa — é o caso do store em memória, e é o que faz "criar em montar
  // aparece na Home" valer também no teste de ponta a ponta (AD-029). Um duplo
  // só-leitura, como o `FestaRepositoryQueFalha`, ganha um store próprio: com
  // `default` em vez de parâmetro obrigatório, nenhum teste existente muda.
  final emEdicao = festasEmEdicao ?? _portaDeEdicao(repositorio);

  final router = buildAppRouter(
    autenticacao: autenticacao,
    festas: repositorio,
    festasEmEdicao: emEdicao,
    logger: RecordingAppLogger(),
    initialLocation: location,
  );
  _ultimoRouter = router;
  addTearDown(() => _ultimoRouter = null);

  await tester.pumpWidget(BoraApp(router: router));
  await tester.pumpAndSettle();

  return autenticacao;
}

/// A porta de escrita de [repositorio], ou um store próprio quando ele só
/// sabe ler.
FestaEmEdicaoRepository _portaDeEdicao(FestaRepository repositorio) {
  if (repositorio is FestaEmEdicaoRepository) {
    return repositorio as FestaEmEdicaoRepository;
  }

  final proprio = FestaRepositoryEmMemoria();
  addTearDown(proprio.dispose);

  return proprio;
}

/// Uma sessão qualquer, para os testes que só precisam de "está logado".
const UsuarioLogado sessaoDeTeste = FakeAutenticacaoRepository.usuarioPadrao;
