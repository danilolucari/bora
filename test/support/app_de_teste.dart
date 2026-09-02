import 'package:bora/app.dart';
import 'package:bora/core/autenticacao/autenticacao.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:bora/features/galera/data/galera_repositorio_sobre_festas.dart';
import 'package:bora/features/galera/domain/galera_repository.dart';
import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/festa_repository.dart';
import 'package:bora/features/lista/data/pedido_falso.dart';
import 'package:bora/features/lista/domain/pedido_repository.dart';
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

/// Navega o app montado para [location].
///
/// Existe porque as quatro abas permanentes ainda não têm barra para tocar
/// (LIST-35 é a última task da spec 06): sem ela, "sai da tela e volta" não
/// teria como ser exercido pela rota. Vai pelo **roteador**, que é o mesmo
/// caminho que a barra usará.
Future<void> irPara(WidgetTester tester, String location) async {
  _ultimoRouter!.go(location);
  await tester.pumpAndSettle();
}

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
  GaleraRepository? galera,
  PedidoRepository? pedidos,
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

  // A porta de pedido entrou pela mesma razão das duas anteriores (E-4): o
  // roteador a exige para montar a Lista. O default é o adaptador falso do
  // M1 — trocá-lo por um duplo é um parâmetro, **sem tocar a página**.
  // A porta da Galera entrou pela mesma razão das anteriores (E-2): o roteador
  // a exige para montar T-05. O default é a **vista sobre a mesma porta de
  // edição** — é o que faz a preferência mudada na Galera aparecer na Lista
  // sem que o teste combine nada. Trocá-la por um duplo é um parâmetro, sem
  // tocar a página; com `default`, nenhum teste existente muda.
  final logger = RecordingAppLogger();

  final router = buildAppRouter(
    autenticacao: autenticacao,
    festas: repositorio,
    festasEmEdicao: emEdicao,
    galera: galera ?? GaleraRepositorioSobreFestas(emEdicao, logger),
    pedidos: pedidos ?? const PedidoFalso(),
    logger: logger,
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
