# Entrar — Tasks

## Execution Protocol (MANDATORY — do not skip)

Implemente estas tasks com a skill `tlc-spec-driven`: **ative-a pelo nome e siga o Execute flow e as Critical Rules dela.** Não procure os arquivos da skill por caminho de filesystem. A skill é a fonte da verdade do fluxo completo (ciclo por task, delegação a sub-agentes, adequacy review, Verifier, sensor de discriminação).

**Se a skill não puder ser ativada, PARE e avise o usuário — não prossiga sem ela.**

---

**Spec**: `.specs/features/entrar/spec.md`
**Design**: `.specs/features/entrar/design.md`
**Status**: **Approved** (2026-08-25) — pronta para Execute. Duplos de SDK com `mocktail` (**AD-021**); skill `run` em T6, T13, T14 e T15; `code-review` ao fim de cada batch.
**Baseline**: `flutter test` = **742 passando** · `flutter analyze` = zero issues (`main`, medido em 2026-08-25)

---

## Test Coverage Matrix

> Gerada do codebase, das guidelines do projeto e da spec — confirmar antes do Execute.
> **Guidelines encontradas**: `CLAUDE.md` §Testes (pirâmide completa; "teste sai do critério de aceite, nunca da implementação"; `test/` espelha `lib/`), `README.md` §Comandos (`flutter analyze` zero issues + `flutter test` todos passando), `analysis_options.yaml` (`flutter_lints`). **Sem** threshold de cobertura e **sem** CI — o `CLAUDE.md` proíbe criar pipeline sem pedido.
> **Amostragem**: 10 arquivos de `test/` (`core/calculo/regras/`, `core/design_system/components/`, `core/design_system/architecture/`, `core/routing/`, `core/di/`, `architecture/`, `app_test.dart`).

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
|---|---|---|---|---|
| Domínio puro — entidades, enums, funções puras (validação, mapeamento de falha, guarda de sessão) | unit | Todos os ramos; 1:1 com os ACs da spec; todo edge case listado tem teste, **incluindo as fronteiras** | `test/core/autenticacao/dominio/*_test.dart`, `test/core/routing/guarda_de_sessao_test.dart`, `test/features/entrar/domain/*_test.dart` | `flutter test` |
| Adaptador de dados — repositório sobre o SDK | unit (**`mocktail`**, AD-021) | Todo caminho de sucesso + **todo código de erro mapeado** + falha genérica + registro no logger + o **catch** (exceção do SDK não vaza) | `test/core/autenticacao/dados/*_test.dart` | `flutter test` |
| BLoC | unit | Uma transição afirmada por evento + todo ramo de falha + o par ocioso/enviando | `test/features/entrar/presentation/bloc/*_test.dart` | `flutter test` |
| Widget de tela e componente | widget | Cada AC de UI **com par discriminante** (presente × ausente); cada literal de copy da spec afirmado | `test/features/entrar/presentation/**/*_test.dart`, `test/core/design_system/components/*_test.dart` | `flutter test` |
| Roteamento — guarda e destinos | widget (integração dentro de `flutter test`) | Toda rota em escopo × **com sessão e sem sessão**; o teste **abre a rota e afirma o destino final**, não o redirect | `test/core/routing/app_router_*_test.dart`, `test/app_test.dart` | `flutter test` |
| Guarda de arquitetura — varredura de `lib/` | unit | A regra **mais** o teste anti-vácuo com mutação injetada (o padrão que a spec 01 instalou) | `test/architecture/*_test.dart`, `test/core/design_system/architecture/*_test.dart` | `flutter test` |
| Barrel, porta abstrata, declaração sem comportamento | none | — (gate de build) | — | `flutter analyze` |

**Regra de asserção herdada do `design.md` §Estratégia de teste** — o teste aponta para a **fonte da verdade daquele valor**:

- **copy da spec** → afirmar o **literal escrito no teste** (`find.text('COMEÇAR →')`). Comparar com `EntrarTextos.cta` faria o teste concordar com qualquer copy.
- **token do design system** → afirmar o **token** (`expect(borda.color, BoraColors.primary)`). Comparar com `Color(0xFFFF4D2E)` não amarra componente a token — foi assim que a spec 01 produziu o GAP-3.

## Gate Check Commands

> Geradas do codebase — confirmar antes do Execute. A suíte inteira roda em ~12s, então "full" não é caro.

| Gate Level | When to Use | Command |
|---|---|---|
| Quick | Task com testes unitários de arquivo isolado | `flutter test test/<caminho do arquivo de teste>` |
| Full | Task que toca rota, DI, `app.dart` ou design system — qualquer coisa que a suíte inteira observa | `flutter test` |
| Build | Fim de fase; task de declaração sem comportamento | `flutter analyze && flutter test` |

Toda task fecha com `flutter analyze` limpo. **Nenhuma task pode reduzir a contagem de testes** — a baseline de 742 só cresce.

---

## Execution Plan

Fases ordenadas, executadas em sequência; tasks dentro de uma fase executam em ordem.

### Fase 1 — Tema e contrato (4 tasks)

O plug da AD-013 e o vocabulário da sessão. Nada aqui toca Firebase.

```
T1 → T2 → T3 → T4
```

### Fase 2 — Adaptador Firebase (2 tasks)

A única parte do projeto que importa `firebase_auth`.

```
T5 → T6
```

### Fase 3 — Guarda de rota (2 tasks)

AD-017 e AD-020. É onde a baseline muda de forma.

```
T7 → T8
```

### Fase 4 — A tela (6 tasks)

T-01 e W-01.

```
T9 → T10 → T11 → T12 → T13 → T14
```

### Fase 5 — Cadastro e erro (2 tasks)

```
T15 → T16
```

---

## Task Breakdown

### T1: Aplicar `boraTheme()` no `BoraApp`

**What**: `MaterialApp.router` passa a receber `theme: boraTheme()`, cumprindo a AD-013.
**Where**: `lib/app.dart` (modificar) · `test/app_test.dart` (estender)
**Depends on**: nenhuma
**Reuses**: `core/design_system/tokens/bora_theme.dart` — o `ThemeData` já testado pela spec 01
**Requirement**: ENT-01, ENT-02

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `BoraApp` passa `theme: boraTheme()`; nenhum valor de tema declarado em `lib/app.dart`
- [ ] Teste afirma que `Theme.of(context)` numa rota montada traz `scaffoldBackgroundColor`, `fontFamily` e `ColorScheme` de `boraTheme()`
- [ ] Teste afirma que o título da aba continua `'bora — a conta do rolê'` (regressão de W-R5/FUND-10)
- [ ] **Verificação por mutação**: inserir um literal de cor em `lib/app.dart` faz `token_purity_guard_test` falhar nomeando o arquivo; árvore restaurada em seguida. *(O guard já varre `lib/` inteira — ENT-02 AC4 não precisa de guard novo, precisa de prova de que o existente o cobre.)*
- [ ] `flutter test` = 742 + novos, todos passando

**Tests**: widget · **Gate**: full
**Commit**: `feat(entrar): aplica o tema do design system no app`

---

### T2: Entidades da sessão e a pasta `core/autenticacao/`

**What**: `UsuarioLogado` e `FalhaDeAutenticacao`, a pasta nova, o barrel, e o structure test exigindo os dois espelhos.
**Where**: `lib/core/autenticacao/dominio/{usuario_logado,falha_de_autenticacao}.dart` · `lib/core/autenticacao/autenticacao.dart` · `test/core/autenticacao/dominio/usuario_logado_test.dart` · `test/architecture/project_structure_test.dart` (modificar — **E-3**)
**Depends on**: nenhuma
**Reuses**: forma de `Pessoa.inicial` (`core/calculo/dominio/pessoa.dart:44`) e o padrão de enum com `chave` de `PapelNaFesta`; forma de barrel de `core/calculo/calculo.dart`
**Requirement**: E-1, E-3 (infraestrutura de ENT-15..18; `UsuarioLogado.inicial` é consumido pela spec 04, HOME-01 AC2)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `UsuarioLogado` com `id`, `email`, `nome?`, `inicial` e igualdade de valor (`==`/`hashCode`)
- [ ] `inicial` testado nos **três** casos: com nome, sem nome (cai no e-mail), e nome vazio (cai no e-mail)
- [ ] `FalhaDeAutenticacao` com os seis valores do design
- [ ] Barrel `autenticacao.dart` exporta o domínio e é a única porta de entrada declarada em doc
- [ ] `project_structure_test.dart` exige `lib/core/autenticacao` **e** `test/core/autenticacao` (E-3 — fortalece a guarda)
- [ ] `flutter analyze` limpo · suíte verde

**Tests**: unit · **Gate**: full *(mexe em `test/architecture/`, que observa a árvore inteira)*
**Commit**: `feat(autenticacao): entidades de sessão e a camada core/autenticacao`

---

### T3: Porta `AutenticacaoRepository` e o duplo de teste

**What**: O contrato de sessão e autenticação, mais o `FakeAutenticacaoRepository` que sustenta toda a suíte da feature.
**Where**: `lib/core/autenticacao/dominio/autenticacao_repository.dart` · `test/support/fake_autenticacao_repository.dart` · `test/support/fake_autenticacao_repository_test.dart`
**Depends on**: T2
**Reuses**: padrão de duplo de `test/support/recording_app_logger.dart`
**Requirement**: infraestrutura de ENT-06, ENT-14, ENT-15..18, ENT-20

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Porta com `sessaoAtual` (snapshot síncrono), `mudancasDeSessao` (`Stream`), `entrarComEmailESenha`, `entrarComGoogle`, `criarConta`, `sair` — todos os métodos de ação devolvendo `Future<void>`
- [ ] Doc na porta registra **por que** `Future<void>`: quem anuncia sucesso é o stream; duas fontes de verdade competiriam
- [ ] `FakeAutenticacaoRepository` permite programar sucesso, uma `FalhaDeAutenticacao` específica, e empurrar/derrubar sessão
- [ ] **O duplo é testado**: emite no stream ao autenticar, atualiza `sessaoAtual` junto, e lança a falha programada. *(Duplo quebrado produz verde falso em todas as tasks seguintes — ele é o substrato da suíte, não acessório.)*
- [ ] Suíte verde

**Tests**: unit · **Gate**: quick — `flutter test test/support/fake_autenticacao_repository_test.dart`
**Commit**: `feat(autenticacao): porta de autenticação e duplo de teste`

---

### T4: Mapeamento puro de código de erro → `FalhaDeAutenticacao`

**What**: A função pura que traduz o `code` do `FirebaseAuthException` para o enum de domínio.
**Where**: `lib/core/autenticacao/dados/falha_de_codigo.dart` · `test/core/autenticacao/dados/falha_de_codigo_test.dart`
**Depends on**: T2
**Reuses**: `FalhaDeAutenticacao` de T2
**Requirement**: ENT-09, ENT-11

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Função pura, **sem import de `firebase_auth`** — recebe `String code`, devolve `FalhaDeAutenticacao`
- [ ] Tabela de teste cobre: `invalid-credential`, **`INVALID_LOGIN_CREDENTIALS`**, `wrong-password`, `user-not-found` → `credencialInvalida`
- [ ] `email-already-in-use` → `emailEmUso` · `weak-password` → `senhaFraca` · `network-request-failed` → `semRede`
- [ ] Código desconhecido e string vazia → `indisponivel` (ramo default afirmado, não presumido)
- [ ] Comentário cita a evidência: `firebase_auth-6.5.7/lib/src/firebase_auth.dart:578-584`, que documenta o código do **emulador** — o ambiente da AD-016
- [ ] Suíte verde

**Tests**: unit · **Gate**: quick — `flutter test test/core/autenticacao/dados/falha_de_codigo_test.dart`
**Commit**: `feat(autenticacao): mapeia código de erro do firebase para falha de domínio`

---

### T5: `FirebaseAutenticacaoRepository` — e-mail/senha, cadastro e sessão

**What**: O adaptador sobre o SDK, mais a dependência de teste que o torna verificável — `mocktail` em `dev_dependencies` (**AD-021**).
**Where**: `pubspec.yaml` + `pubspec.lock` · `lib/core/autenticacao/dados/firebase_autenticacao_repository.dart` · `test/core/autenticacao/dados/firebase_autenticacao_repository_test.dart`
**Depends on**: T3, T4
**Reuses**: `falhaDeCodigo` (T4) · `AppLogger` (AD-005) · `RecordingAppLogger` (`test/support/`)
**Requirement**: ENT-06, ENT-12, ENT-20

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `mocktail` em `dev_dependencies` e `flutter pub get` rodado; **nenhuma dependência de runtime nova** e **nenhum codegen** (AD-002 preservada)
- [ ] `FirebaseAutenticacaoRepository` implementa a porta direto sobre `FirebaseAuth`, recebido pelo construtor: mantém `sessaoAtual` a partir de `authStateChanges()`, mapeia `User → UsuarioLogado`, converte `FirebaseAuthException` em `FalhaDeAutenticacao` via T4
- [ ] Teste com `MockFirebaseAuth` (mocktail) afirma: sucesso emite no stream · cada falha do §Error Handling chega como o enum certo · **toda falha é registrada no `AppLogger`** — ENT-12
- [ ] O teste cobre o **catch**, não só o mapeamento: exceção lançada pelo mock chega ao chamador como `FalhaDeAutenticacao`, não como `FirebaseAuthException` vazando
- [ ] Nenhum arquivo fora de `core/autenticacao/dados/` importa `firebase_auth`
- [ ] Suíte verde

**Tests**: unit · **Gate**: build — `flutter analyze && flutter test` *(mexe no `pubspec.yaml`)*
**Commit**: `feat(autenticacao): adaptador firebase para e-mail, senha e cadastro`

---

### T6: Google com split de plataforma

**What**: `entrarComGoogle` usando `signInWithPopup` no web e `signInWithProvider` no mobile.
**Where**: `lib/core/autenticacao/dados/firebase_autenticacao_repository.dart` (modificar) · teste correspondente
**Depends on**: T5
**Reuses**: `MockFirebaseAuth` de T5
**Requirement**: ENT-14

**Tools**: MCP: NONE · **Skill: `run`** — subir o app no Chrome com o emulador ligado para capturar o código real de cancelamento e conferir o fluxo Google ponta a ponta (A-10)

**Done when**:
- [ ] A escolha de método é uma **função pura testável** sobre `isWeb`, não um `if (kIsWeb)` enterrado — os dois ramos afirmados por teste
- [ ] Comentário cita a evidência de que o web **precisa** de `signInWithPopup`: `firebase_auth_web-6.2.6` não sobrescreve `signInWithProvider`, que cai no `throw UnimplementedError` de `platform_interface_firebase_auth.dart:595`
- [ ] Cancelamento do fluxo devolve `FalhaDeAutenticacao.cancelada` e **não** é tratado como erro
- [ ] ⚠️ **Código real de cancelamento capturado com a skill `run`**: `firebase emulators:start` + `flutter run -d chrome`, fechar o popup do Google e anotar o `code`. O pacote Dart não o documenta (`design.md` §Pesquisa 3). Só se a captura falhar é que o teste cobre o ramo `default` e a task **registra no `validation.md` que o código ficou por verificar** — sem inventar a lista
- [ ] Registrado que a verificação ponta-a-ponta do provider é **manual, no web** (A-10)
- [ ] Suíte verde

**Tests**: unit · **Gate**: full
**Commit**: `feat(autenticacao): entrar com google nas duas plataformas`

---

### T7: A guarda de sessão como função pura

**What**: `guardaDeSessao(rota, temSessao) → destino?` e o `GoRouterRefreshStream`.
**Where**: `lib/core/routing/{guarda_de_sessao.dart,go_router_refresh_stream.dart}` · `test/core/routing/{guarda_de_sessao_test.dart,go_router_refresh_stream_test.dart}`
**Depends on**: T2
**Reuses**: `Routes` (`core/routing/routes.dart`)
**Requirement**: ENT-15, ENT-16, ENT-17, ENT-18

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Função pura, sem `GoRouter` e sem widget — recebe rota e booleano, devolve destino ou `null`
- [ ] **Tabela completa** de casos: cada rota do mapa canônico × com sessão × sem sessão
- [ ] As três livres (`/c/:codigo`, `/erro`, `/catalogo`) afirmadas nos **dois** estados de sessão — ENT-17 AC3
- [ ] `GoRouterRefreshStream` notifica a cada emissão e **cancela a inscrição no `dispose`** (afirmado por teste — inscrição vazada contamina teste seguinte)
- [ ] Suíte verde

**Tests**: unit · **Gate**: quick — `flutter test test/core/routing/`
**Commit**: `feat(entrar): guarda de sessão como regra pura de rota`

---

### T8: Ligar a guarda no roteador, no DI e na baseline

**What**: `buildAppRouter` passa a receber a porta e a usar `redirect` + `refreshListenable`; o injector e os quatro testes que montam o roteador acompanham.
**Where**: `lib/core/routing/app_router.dart` · `lib/core/di/injector.dart` · `test/app_test.dart` (**E-4**) · `test/core/routing/app_router_{publico,shell,catalogo}_test.dart`
**Depends on**: T3, T7
**Reuses**: `guardaDeSessao` (T7) · `FakeAutenticacaoRepository` (T3) · padrão de idempotência do `configureDependencies` (`injector.dart:24`)
**Requirement**: ENT-15, ENT-16, ENT-17, ENT-18 + E-4

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `buildAppRouter` recebe `AutenticacaoRepository` — **parâmetro obrigatório**, para que produção não possa esquecer a guarda
- [ ] `injector.dart` registra a porta e ajusta a fábrica do roteador (o tear-off `buildAppRouter` de `injector.dart:34` deixa de compilar — trocar por closure)
- [ ] Os **quatro** arquivos que chamam `buildAppRouter` passam o duplo; nenhum teste é enfraquecido nem apagado — só reapontado
- [ ] **E-4**: `test/app_test.dart` vira o par — com duplo logado cai em `/roles`, sem sessão cai em `/entrar`
- [ ] Cada rota tem teste que **abre a rota e afirma o destino final** depois do redirect, nos dois estados de sessão *(rota que existe só como redirect precisa do teste que a atravessa — foi mutante sobrevivente na fundação)*
- [ ] Sessão que termina com rota de festa montada leva a `/entrar` — ENT-18
- [ ] `flutter analyze` limpo · suíte verde, contagem ≥ baseline

**Tests**: widget (roteamento) · **Gate**: build — `flutter analyze && flutter test`
**Commit**: `feat(entrar): guarda de sessão governa a navegação do app`

---

### T9: Validação de credenciais

**What**: `validarEmail` e `validarSenha`, puros.
**Where**: `lib/features/entrar/domain/validacao_de_credenciais.dart` · `test/features/entrar/domain/validacao_de_credenciais_test.dart`
**Depends on**: nenhuma
**Reuses**: —
**Requirement**: ENT-08

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Funções puras, sem import de Flutter; enums pequenos de erro (`vazio`/`formato`, `vazia`/`curta`)
- [ ] E-mail: vazio, sem `@`, sem domínio, válido — e **`trim()` das pontas** acontece aqui (edge case da spec)
- [ ] Senha: vazia, 5 caracteres (rejeita), **6 caracteres (aceita)** — a fronteira de A-08 afirmada dos dois lados
- [ ] Suíte verde

**Tests**: unit · **Gate**: quick — `flutter test test/features/entrar/domain/validacao_de_credenciais_test.dart`
**Commit**: `feat(entrar): validação de e-mail e senha`

---

### T10: `EntrarBloc`

**What**: Eventos, estado e a lógica de modo, envio e falha — sem navegar.
**Where**: `lib/features/entrar/presentation/bloc/{entrar_bloc,entrar_event,entrar_state}.dart` · `test/features/entrar/presentation/bloc/entrar_bloc_test.dart`
**Depends on**: T3, T9
**Reuses**: porta (T3) · validadores (T9) · `flutter_bloc` já no `pubspec.yaml`
**Requirement**: ENT-06, ENT-07, ENT-10, ENT-13

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Eventos `ModoAlternado`, `SubmetidoComCredenciais`, `SubmetidoComGoogle`; estado com `modo`, `situacao`, `falha`, erros de validação
- [ ] **O bloc não importa `BuildContext` nem navega** — afirmado por varredura do arquivo (AD-020)
- [ ] `SubmetidoComCredenciais` chama `entrarComEmailESenha` no modo entrar e `criarConta` no modo cadastro — os dois ramos afirmados
- [ ] Validação falhando **não chama o repositório** (afirmado contando as chamadas no duplo) — ENT-08
- [ ] Enviando ⇒ segundo submit é ignorado: **uma** chamada ao repositório — ENT-07/ENT-10
- [ ] `ModoAlternado` limpa a falha anterior — ENT-13
- [ ] Cada `FalhaDeAutenticacao` chega ao estado e devolve `situacao` a ocioso
- [ ] Suíte verde

**Tests**: unit · **Gate**: quick — `flutter test test/features/entrar/presentation/bloc/entrar_bloc_test.dart`
**Commit**: `feat(entrar): bloc da tela de entrar`

---

### T11: `obscureText` no `BoraTextField`

**What**: Parâmetro opcional aditivo no input do design system (**E-2**).
**Where**: `lib/core/design_system/components/bora_text_field.dart` (modificar) · `test/core/design_system/components/bora_text_field_test.dart` (estender)
**Depends on**: nenhuma
**Reuses**: o próprio componente
**Requirement**: ENT-21

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `obscureText` opcional com default `false`; nenhum teste existente do DS muda de comportamento
- [ ] **Par discriminante**: teste afirma `obscureText` verdadeiro quando pedido **e falso por omissão**
- [ ] Registrado no corpo do commit como **SPEC_DEVIATION** contra a spec 01, citando ENT-21 e a emenda E-2
- [ ] Seção do catálogo continua renderizando (o `catalog_completude_test` não pode quebrar)
- [ ] Suíte verde, contagem ≥ baseline

**Tests**: widget · **Gate**: full *(toca o design system, que a suíte inteira observa)*
**Commit**: `feat(design-system): input aceita texto obscurecido`

---

### T12: `MarcaBora` e `DivisorOu`

**What**: Os dois elementos de composição de T-01 que o arquivo 02 não define como componente.
**Where**: `lib/features/entrar/presentation/widgets/{marca_bora,divisor_ou}.dart` · testes correspondentes
**Depends on**: T1
**Reuses**: `BoraTextStyles.logoHero` · `BoraColors` · `pumpComponent` (`test/core/design_system/support/`)
**Requirement**: ENT-03 (parcial), ENT-04 (parcial)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `MarcaBora` renderiza "BORA." com o **ponto em `BoraColors.primary`** e o resto em `ink`, afirmado contra o **token**
- [ ] `MarcaBora` aceita o tamanho por parâmetro: 64 (T-01, o `logoHero` direto) e 92 (W-01, `copyWith` — o degrau responsivo do arquivo 06)
- [ ] `DivisorOu` renderiza o texto "OU" entre duas linhas de 2px com a cor de divisor do token
- [ ] Nenhum literal de cor ou de `fontFamily` (o guard de pureza já varre `lib/` e cobra sozinho)
- [ ] Suíte verde

**Tests**: widget · **Gate**: quick — `flutter test test/features/entrar/presentation/widgets/`
**Commit**: `feat(entrar): marca e divisor da tela de entrar`

---

### T13: `EntrarPage` + `EntrarCompacto` — T-01 completo

**What**: A página dona do bloc, dos controllers e do split responsivo, mais o layout mobile.
**Where**: `lib/features/entrar/presentation/pages/entrar_page.dart` · `lib/features/entrar/presentation/widgets/entrar_compacto.dart` · `lib/features/entrar/presentation/entrar_textos.dart` · testes · `test/core/routing/app_router_publico_test.dart` (**corrigir** — hoje afirma `PlaceholderPage.keyFor('entrar')` em `app_router_publico_test.dart:22`)
**Depends on**: T10, T11, T12
**Reuses**: `BoraTextField`, `BoraPrimaryButton`, `BoraSecondaryButton`, `BoraRotatedTag` · `ResponsiveBuilder` + `LayoutMode` (AD-007)
**Requirement**: ENT-03, ENT-05, ENT-09, ENT-11

**Tools**: MCP: NONE · **Skill: `run`** — conferir T-01 a olho no emulador `Pixel_10`, como o DS-33 foi fechado no M0

**Done when**:
- [ ] **Controllers e `BlocProvider` acima do `ResponsiveBuilder`** — é o que preserva o texto ao cruzar 900px
- [ ] Em viewport compacta, T-01 renderiza na ordem da spec e **cada literal é afirmado**: "A CONTA DO ROLÊ, RESOLVIDA", "Monta o churras, chama a galera e racha a conta. Sem planilha, sem treta.", "seu e-mail", "senha", "COMEÇAR →", "OU", "CONTINUAR COM GOOGLE", "Novo por aqui? CRIAR CONTA"
- [ ] Tag rotacionada usa `BoraRotatedTag.grausAEsquerda` (−2°) — afirmado contra a constante
- [ ] Foco no input troca a borda para `BoraColors.primary`, afirmado contra o **token** — ENT-05
- [ ] Campo senha obscurecido — ENT-21
- [ ] Credencial recusada mostra "E-MAIL OU SENHA INCORRETOS" inline, **preserva o e-mail** e reabilita o CTA — ENT-09
- [ ] Falha de rede/indisponível mostra mensagem e a tela **continua utilizável**, `tester.takeException()` nulo — ENT-11
- [ ] **`app_router_publico_test` reaponta** de `PlaceholderPage.keyFor('entrar')` para a tela real, sem enfraquecer a asserção
- [ ] Suíte verde, contagem ≥ baseline

- [ ] **Conferência visual** com `run`: T-01 renderizado no emulador bate com o arquivo 04 — o que teste de widget não afirma

**Tests**: widget · **Gate**: build — `flutter analyze && flutter test`
**Commit**: `feat(entrar): tela de entrar no mobile`

---

### T14: `EntrarExpandido` — W-01

**What**: O layout de duas colunas do web.
**Where**: `lib/features/entrar/presentation/widgets/entrar_expandido.dart` · teste correspondente
**Depends on**: T13
**Reuses**: `BoraSurface` (`deslocamentoDaSombra: 10`) · `MarcaBora` (92px) · os mesmos controllers de T13
**Requirement**: ENT-04

**Tools**: MCP: NONE · **Skill: `run`** — conferir W-01 a olho em janela 1180×800 no Chrome

**Done when**:
- [ ] Em viewport expandida renderiza as duas colunas: marca à esquerda, card branco à direita
- [ ] Card usa `BoraSurface` com sombra de 10px e borda 2px `ink`, afirmado contra os **tokens**
- [ ] Literais de W-01 afirmados: label "ENTRAR", "COMEÇAR →", **"🌐 ENTRAR COM GOOGLE"** (a copy do web difere da do mobile — A-05), "Novo por aqui? CRIAR CONTA"
- [ ] **Par de plataforma**: teste afirma que a copy do Google é a do mobile em compacto e a do web em expandido
- [ ] Cruzar 900px com texto digitado **preserva o texto e o modo** — o edge case da spec, afirmado redimensionando o viewport sem remontar
- [ ] Sem scroll horizontal (W-R4)
- [ ] Suíte verde

- [ ] **Conferência visual** com `run`: W-01 em 1180×800 bate com o arquivo 06

**Tests**: widget · **Gate**: full
**Commit**: `feat(entrar): tela de entrar no web`

---

### T15: Modo cadastro

**What**: A alternância entrar ⇄ cadastro nos dois layouts.
**Where**: `lib/features/entrar/presentation/widgets/{entrar_compacto,entrar_expandido}.dart` (modificar) · `entrar_textos.dart` · testes
**Depends on**: T14
**Reuses**: `EntrarBloc.ModoAlternado` (T10)
**Requirement**: ENT-20

**Tools**: MCP: NONE · **Skill: `run`** — alternar entrar ⇄ cadastro a olho nas duas plataformas

**Done when**:
- [ ] "CRIAR CONTA" alterna a tela **sem mudar de rota** (rota corrente afirmada antes e depois)
- [ ] Modo cadastro mostra label "CRIAR CONTA", CTA "CRIAR CONTA →", rodapé "Já tem conta? ENTRAR" (A-07)
- [ ] Alternância **preserva o e-mail digitado** e limpa a falha anterior — ENT-13
- [ ] Cadastro com sucesso: a sessão emite e a guarda leva a `/roles` — **sem `context.go` na feature** (AD-020), afirmado pelo destino final
- [ ] E-mail já em uso mostra mensagem inline e **permanece no modo cadastro** — ENT-20 AC4
- [ ] "ENTRAR" do rodapé volta ao modo entrar preservando o e-mail
- [ ] Suíte verde

- [ ] **Conferência visual** com `run`: a alternância não desloca o layout nem pisca

**Tests**: widget · **Gate**: full
**Commit**: `feat(entrar): criar conta na própria tela de entrar`

---

### T16: `RouteErrorPage` revestido

**What**: A tela de erro passa a usar os tokens do arquivo 02.
**Where**: `lib/core/routing/route_error_page.dart` (modificar) · `test/core/routing/route_error_page_test.dart` (estender)
**Depends on**: T1, T8
**Reuses**: `BoraTextStyles`, `BoraColors`, `BoraSecondaryButton`
**Requirement**: ENT-19

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Renderiza com fundo `paper` e título Archivo Black em caixa alta, afirmado contra os **tokens**; `RouteErrorPage.pageKey` preservada
- [ ] CTA secundário "VOLTAR PRO INÍCIO" leva à raiz, afirmado pelo destino final
- [ ] Alcançável **sem sessão** — a guarda não a intercepta (par com T8)
- [ ] Nenhum literal de cor ou fonte (cobrado pelo guard existente)
- [ ] Suíte verde

**Tests**: widget · **Gate**: full
**Commit**: `feat(entrar): reveste a tela de erro com os tokens`

---

## Phase Execution Map

```
Fase 1 → Fase 2 → Fase 3 → Fase 4 → Fase 5

Fase 1:  T1 ──→ T2 ──→ T3 ──→ T4
Fase 2:  T5 ──→ T6
Fase 3:  T7 ──→ T8
Fase 4:  T9 ──→ T10 ──→ T11 ──→ T12 ──→ T13 ──→ T14
Fase 5:  T15 ──→ T16

Grafo de dependências reais (as setas que importam):

  T1 ────────────────────────────────→ T12 ─┐
                                             ├─→ T13 ──→ T14 ──→ T15
  T2 ──→ T3 ──→ T5 ──→ T6                    │
   │      │                                  │
   │      └──────────→ T8                    │
   │                    ↑                    │
   └──→ T7 ─────────────┘                    │
                                             │
  T4 ──→ T5                                  │
  T9 ──→ T10 ─────────────────────────────→ ─┤
  T11 ────────────────────────────────────→ ─┘
  T1 + T8 ──→ T16
```

Execução é estritamente sequencial — não há paralelismo dentro de fase.

**Empacotamento previsto para o Execute** (~7 tasks por worker, fases inteiras):

| Batch | Fases | Tasks | Tema | Ao fechar |
|---|---|---|---|---|
| 1 | 1 + 2 + 3 | T1–T8 (8) | Tema, contrato, adaptador e guarda — nada de UI | **`code-review`** |
| 2 | 4 + 5 | T9–T16 (8) | A tela inteira | **`code-review`** |

São 16 tasks ⇒ mais de um batch ⇒ **oferta de sub-agentes** no Execute. O corte cai em fronteira de fase, e a divisão é semântica: infraestrutura × tela.

**Ordem de fechamento de cada batch**: última task commitada → `code-review` do diff do batch → aplicar o que ele achar → só então o batch seguinte. O **Verifier independente roda uma vez, ao fim de tudo** (T16), e não substitui o `code-review`: um revisa código, o outro re-deriva cobertura contra a spec com evidence-or-zero.

---

## Task Granularity Check

| Task | Escopo | Status |
|---|---|---|
| T1 | 1 arquivo (`app.dart`) | ✅ Granular |
| T2 | 2 entidades + barrel, mesma pasta, mesmo conceito | ✅ Coeso |
| T3 | 1 porta + o duplo dela | ✅ Coeso |
| T4 | 1 função pura | ✅ Granular |
| T5 | 1 adaptador + a dependência de teste que ele exige | ✅ Coeso *(ver nota)* |
| T6 | 1 método do adaptador | ✅ Granular |
| T7 | 2 peças puras de roteamento | ✅ Coeso |
| T8 | 1 fiação + os testes que a assinatura quebra | ✅ Coeso *(merge backward obrigatório — ver nota)* |
| T9 | 2 funções puras, mesmo arquivo | ✅ Coeso |
| T10 | 1 bloc | ✅ Granular |
| T11 | 1 parâmetro em 1 componente | ✅ Granular |
| T12 | 2 widgets pequenos de composição | ✅ Coeso |
| T13 | 1 página + 1 layout — indivisíveis (ver nota) | ✅ Coeso |
| T14 | 1 layout | ✅ Granular |
| T15 | 1 comportamento nos 2 layouts | ✅ Coeso |
| T16 | 1 arquivo | ✅ Granular |

**Nota sobre T8** — mudar a assinatura de `buildAppRouter` quebra a compilação dos 4 arquivos de teste que o chamam. Separá-los numa task própria deixaria a árvore vermelha entre commits, violando "gate passa antes de a task fechar". É *merge backward* pelo manual: a task absorve o que a bloqueia.

**Nota sobre T5** — a adição de `mocktail` ao `pubspec.yaml` cabe na task do adaptador porque é a primeira e única coisa que a exige: separá-la produziria um commit que muda dependência sem nenhum teste novo para justificá-la. A decisão de usá-la está registrada como **AD-021**, e o `run_in_background` do `flutter pub get` **não** conta como gate — o gate é `flutter analyze && flutter test`.

**Nota sobre T13** — `EntrarCompacto` recebe controllers e bloc de `EntrarPage`; sem a página ele não monta e não é testável. Separá-los produziria código não verificado. É *merge backward* também.

---

## Diagram-Definition Cross-Check

| Task | Depends on (corpo) | Diagrama mostra | Status |
|---|---|---|---|
| T1 | — | (raiz) | ✅ |
| T2 | — | (raiz) | ✅ |
| T3 | T2 | T2 → T3 | ✅ |
| T4 | T2 | T2 → T4 | ✅ |
| T5 | T3, T4 | T3 → T5, T4 → T5 | ✅ |
| T6 | T5 | T5 → T6 | ✅ |
| T7 | T2 | T2 → T7 | ✅ |
| T8 | T3, T7 | T3 → T8, T7 → T8 | ✅ |
| T9 | — | (raiz) | ✅ |
| T10 | T3, T9 | T3 → T10, T9 → T10 | ✅ |
| T11 | — | (raiz) | ✅ |
| T12 | T1 | T1 → T12 | ✅ |
| T13 | T10, T11, T12 | T10 → T13, T11 → T13, T12 → T13 | ✅ |
| T14 | T13 | T13 → T14 | ✅ |
| T15 | T14 | T14 → T15 | ✅ |
| T16 | T1, T8 | T1 → T16, T8 → T16 | ✅ |

Nenhuma dependência aponta para fase posterior. ✅

---

## Test Co-location Validation

| Task | Camada criada/modificada | Matriz exige | Task diz | Status |
|---|---|---|---|---|
| T1 | Roteamento/app + guarda de arquitetura | widget | widget | ✅ |
| T2 | Domínio puro + guarda de arquitetura | unit | unit | ✅ |
| T3 | Porta abstrata **+ duplo com comportamento** | none (porta) / unit (duplo) | unit | ✅ *(usa o mais alto)* |
| T4 | Domínio puro | unit | unit | ✅ |
| T5 | Adaptador de dados | unit | unit | ✅ |
| T6 | Adaptador de dados | unit | unit | ✅ |
| T7 | Domínio puro (guarda) | unit | unit | ✅ |
| T8 | Roteamento + DI | widget | widget | ✅ |
| T9 | Domínio puro | unit | unit | ✅ |
| T10 | BLoC | unit | unit | ✅ |
| T11 | Componente do design system | widget | widget | ✅ |
| T12 | Widget | widget | widget | ✅ |
| T13 | Widget de tela + roteamento | widget | widget | ✅ |
| T14 | Widget de tela | widget | widget | ✅ |
| T15 | Widget de tela | widget | widget | ✅ |
| T16 | Widget de tela | widget | widget | ✅ |

**Nenhum `Tests: none`.** Nenhuma task produz código não verificado; nenhum teste é adiado para outra task.

---

## Cobertura de requisitos

| Requisito | Task |
|---|---|
| ENT-01, ENT-02 | T1 |
| ENT-03 | T12, T13 |
| ENT-04 | T14 |
| ENT-05 | T13 |
| ENT-06 | T5, T10 |
| ENT-07, ENT-10 | T10 |
| ENT-08 | T9, T10 |
| ENT-09 | T4, T13 |
| ENT-11 | T4, T13 |
| ENT-12 | T5 |
| ENT-13 | T10, T15 |
| ENT-14 | T6 |
| ENT-15, ENT-16, ENT-17, ENT-18 | T7, T8 |
| ENT-19 | T16 |
| ENT-20 | T5, T15 |
| ENT-21 | T11 |

**21/21 requisitos mapeados. Zero órfãos.** Emendas: E-1 → T2 · E-2 → T11 · E-3 → T2 · E-4 → T8.
