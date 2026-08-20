# Fundação — Tasks

## Execution Protocol (MANDATORY — do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user — do not proceed without it.**

---

**Spec**: `.specs/features/fundacao/spec.md` · **Design**: `.specs/features/fundacao/design.md`
**Status**: Draft — aguardando aprovação
**Decisões ativas**: AD-001..AD-007 (`.specs/STATE.md`)

**Ferramentas do Execute** (confirmado pelo usuário em 2026-08-13): **só as ferramentas nativas** — nenhum MCP está configurado nesta sessão e nenhuma skill auxiliar é invocada (por isso todo `Tools:` abaixo diz `MCP: NONE` / `Skill: NONE`). As verificações marcadas **M** ficam com o usuário; o executor **reporta o que não conseguiu verificar** em vez de assumir que passou. O despacho em sub-agentes é decidido no início do Execute, com o packing já calculado.

---

## ⛔ Pré-condição bloqueante do Execute

**O SDK Flutter/Dart não está instalado nesta máquina** (verificado 2026-08-12: `flutter`, `dart` e `firebase` fora do PATH). T1 começa verificando `flutter --version`; **se não responder, o Execute para na primeira task** — instalar o SDK é responsabilidade externa, fora do escopo da spec.

> ✅ **Resolvida em 2026-08-20**: `flutter --version` responde — **Flutter 3.47.0 · channel stable · Dart 3.13.0 · DevTools 2.60.0** (`/home/lucari/SDKs/flutter/bin/flutter`). É esta a versão do scaffold, e é ela que T18 documenta no README. O `pubspec.yaml` gerado fixou `environment: sdk: ^3.13.0`.
>
> ⚠️ **O CLI `firebase` continua fora do PATH**: `firebase emulators:start` não é executável neste ambiente, então toda verificação que dependa dele (T15 e T18) fica com o usuário.

Consequências para este plano, declaradas em vez de escondidas:

- Nenhum comando de gate abaixo pôde ser executado para validação. Eles vêm dos requisitos FUND-01/02/03 e do `CLAUDE.md`, **não** de um manifesto lido do repositório (não existe `pubspec.yaml` ainda).
- As versões de pacote não são digitadas à mão: T1 usa `flutter pub add`, que resolve contra o SDK instalado (risco R-7 do design).
- Toda verificação marcada **M (manual)** exige dispositivo/emulador ou navegador.

---

## Test Coverage Matrix

> Gerada de guidelines do projeto + spec. **Guidelines encontradas**: `CLAUDE.md` (§Decisões de engenharia → "Testes: pirâmide completa", "`test/` espelha a estrutura de `lib/`", "Teste sai do critério de aceite, nunca da implementação", "`flutter_lints` rodando local, sem CI"). Não há `CONTRIBUTING.md`, `docs/`, config de runner nem workflow de CI. **Não há teste algum no repositório** — a matriz vem das guidelines e dos ACs, não de amostragem.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
|---|---|---|---|---|
| `lib/core/calculo/` (Dart puro, RN-xx) | unit | Todas as RN-xx 1:1 com os exemplos literais do arquivo 03 — **nenhuma nesta spec** (só o barrel; território da spec 02) | `test/core/calculo/**/*_test.dart` | `flutter test` |
| Lógica Dart em `lib/core/` (di, routing helpers, observability, firebase config, responsive) | unit | Todos os ramos; 1:1 com os ACs FUND-xx; todo edge case listado na spec tem teste | `test/core/**/*_test.dart` | `flutter test` |
| Composição/boot (`lib/bootstrap/`, `lib/main.dart`) | unit | Ordem determinística (FUND-15) + degradação de dependência externa (FUND-17) | `test/bootstrap/*_test.dart` | `flutter test` |
| Widgets e rotas (`lib/core/routing/` widgets, `lib/features/*/presentation/`) | widget | Cada AC de tela vira widget test (CLAUDE.md): rota feliz + rota inexistente + edge (`/c/` vazio, código malformado) + ausência de shell na rota pública | `test/**/*_test.dart` | `flutter test` |
| Fixtures (`test/fixtures/`) | unit | Campo a campo contra o texto de RN-30 + varredura de import proibido | `test/fixtures/*_test.dart` | `flutter test` |
| Estrutura do projeto (árvore `lib/`↔`test/`, isolamento de `core/calculo/`) | unit | FUND-04/05/06 — a convenção é policiada por teste, não por documento | `test/architecture/*_test.dart` | `flutter test` |
| **Adaptador fino de SDK externo** (`FirebaseBootstrap`, `url_strategy_web.dart`) | none | Sem teste unitário **por decisão de design**: são wrappers de 3 linhas sobre singletons (`Firebase.initializeApp`, `useAuthEmulator`, `usePathUrlStrategy`). A parte decidível foi extraída para funções puras testadas (`FirebaseEnvironment.resolve`, `EmulatorConfig.host`, portas). Verificação: gate de build + checklist manual do README | — | `flutter analyze` (+ M) |
| Config (`pubspec.yaml`, `analysis_options.yaml`, `firebase.json`, `.firebaserc`, `.gitkeep`) | none | Gate de build; exceto onde a spec exige teste de estrutura (linha acima) | — | `flutter analyze` |
| `integration_test/` (e2e) | **fora de escopo** | Nenhum FUND-01..20 pede fluxo ponta-a-ponta; o `CLAUDE.md` prevê `integration_test/` para os fluxos de produto (montar → convidar → confirmar → acerto), que nascem da spec 05 em diante | — | — |

## Gate Check Commands

> Derivados dos requisitos FUND-01/02/03 e do `CLAUDE.md`. **Não verificados localmente** — sem SDK (ver pré-condição).

| Gate Level | When to Use | Command |
|---|---|---|
| Quick | Após tasks com unit e/ou widget test | `flutter test` |
| Full | Idem — não há suíte e2e nesta spec, então Full ≡ Quick | `flutter test` |
| Build | Fim de fase, tasks de config e tasks com `Tests: none` | `flutter analyze && flutter test` |
| Manual (M) | FUND-01, FUND-10 (URL sem `#`), FUND-17 (emulador no ar/fora), FUND-20 | `flutter run` · `flutter run -d chrome` · `firebase emulators:start` |

**Regra em todo gate:** `flutter analyze` precisa terminar com **zero issues** (FUND-02) e nenhum teste pode ser enfraquecido, pulado ou apagado para o portão passar.

---

## Execution Plan

Fases ordenadas, executadas em sequência; dentro da fase, as tasks rodam na ordem numérica.

### Phase 1: Chão que compila (T1–T3)

Sem isto nada mais é verificável — o portão de aceite do projeto inteiro nasce aqui.

```
T1 → T2 → T3
```

### Phase 2: Núcleo de plataforma (T4–T8)

Peças de `core/` sem UI e sem rota: observabilidade, responsividade e configuração do Firebase. Todas testáveis isoladamente.

```
T1 ─┬→ T4 → T5
    ├→ T6
    ├→ T7
    └→ T8
```

### Phase 3: Navegação (T9–T12)

A tabela de rotas completa com placeholders. Divide-se na costura real do design: zona pública/erro primeiro, shell autenticado depois.

```
T1 ─→ T9 ─┐
T1 ─→ T10 ┴→ T11 → T12
T2 ───────────┘
```

### Phase 4: Composição (T13–T16)

Onde as peças viram um app que sobe: DI, ordem de boot, wiring real do Firebase e o `main.dart`.

```
T4, T12 → T13 ─┐
T4 → T14 ──────┤
T7, T8 → T15 ──┴→ T16
T11 ───────────┘
```

### Phase 5: Fixture e documentação (T17–T18)

```
T2 → T17
T16 → T18
```

---

## Task Breakdown

### T1: Scaffold do projeto Flutter com lint e portão de teste

**What**: criar o projeto Flutter na raiz do repositório, com as dependências do AD-002/AD-004, `flutter_lints` ativo e um smoke test que prova que `flutter test` executa de verdade.
**Where**: `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `lib/main.dart`, `lib/app.dart`, `test/app_test.dart`, `android/`, `ios/`, `web/`
**Depends on**: None
**Reuses**: `flutter create` (scaffold), `flutter_lints` (só `include:` no `analysis_options.yaml`)
**Requirement**: FUND-01, FUND-02, FUND-03

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `flutter --version` responde (**se não responder, PARAR** — pré-condição da spec) e a versão é anotada para o README de T18
- [x] `flutter create --org app --project-name bora --platforms=android,ios,web .` executado na raiz (applicationId `app.bora`, assumption confirmada da spec)
- [x] Dependências adicionadas via `flutter pub add` (nunca versão digitada à mão — risco R-7): `flutter_bloc`, `go_router`, `get_it`, `firebase_core`, `firebase_auth`, `cloud_firestore`; `flutter_web_plugins` declarado como `sdk: flutter` no `pubspec.yaml` (não é instalável por `pub add`)
- [x] `pubspec.lock` versionado (não entra no `.gitignore`)
- [x] `analysis_options.yaml` inclui `package:flutter_lints/flutter.yaml`
- [x] O contador gerado por `flutter create` foi **removido**: `lib/app.dart` expõe `BoraApp` mínimo e `lib/main.dart` só chama `runApp`; `test/widget_test.dart` gerado foi substituído por `test/app_test.dart`
- [x] `flutter analyze` → **zero issues**
- [x] Gate: `flutter analyze && flutter test` passa
- [x] Novos testes: ≥1 (smoke: `BoraApp` monta sem exceção)
- [ ] **M** — `flutter run` sobe em mobile e `flutter run -d chrome` sobe em web, a partir do mesmo `lib/main.dart` — **pendente com o usuário**: sem device, emulador Android ou navegador no ambiente de execução

**Tests**: widget
**Gate**: build
**Commit**: `feat(fundacao): cria projeto flutter com lint e portão de teste`

---

### T2: Árvore Clean Architecture com espelho em `test/`

**What**: criar a estrutura de pastas do CLAUDE.md (+ AD-006) com `.gitkeep` em toda pasta sem `.dart`, e o teste que a policia.
**Where**: `lib/core/{design_system,calculo,di,routing,observability,firebase,responsive}/`, `lib/features/{entrar,home,montar,lista,galera,convite,convidado,custos}/{domain,data,presentation}/`, espelho em `test/`, `test/architecture/project_structure_test.dart`
**Depends on**: T1
**Reuses**: `dart:io` (varredura de diretórios) — mesma técnica que T3
**Requirement**: FUND-04, FUND-05

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `lib/core/design_system/` e `lib/core/calculo/` existem, mais as quatro pastas de infraestrutura do design
- [x] As **oito** features existem, cada uma com `domain/`, `data/` e `presentation/` (seis do CLAUDE.md + `entrar` e `home` por AD-006)
- [x] `test/` espelha `lib/` (exceto `test/architecture/`, `test/support/` e `test/fixtures/`, que são transversais — desvio declarado no design)
- [x] `.gitkeep` em toda pasta sem `.dart` — risco R-4: sem isso a árvore some no clone limpo, que é exatamente onde FUND-04/05 são verificados
- [x] `project_structure_test.dart` falha se qualquer pasta exigida sumir, e nomeia a pasta faltante
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥3 (pastas de `core/`, oito features com as três camadas, espelho de `test/`)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(fundacao): cria árvore clean architecture com espelho de testes`

---

### T3: Isolamento de `core/calculo/` policiado por teste

**What**: criar o barrel de `core/calculo/` e o teste que quebra a suíte quando um import proibido entra na pasta.
**Where**: `lib/core/calculo/calculo.dart`, `test/architecture/calculo_isolation_test.dart`
**Depends on**: T2
**Reuses**: técnica de varredura de T2
**Requirement**: FUND-06

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `lib/core/calculo/calculo.dart` existe como barrel com doc comment — **nenhuma fórmula** (território da spec 02); serve para a varredura não rodar vazia
- [x] O teste falha quando encontra `package:flutter/…`, `dart:ui`, `package:firebase…`, `cloud_firestore` ou `package:flutter_bloc` sob `lib/core/calculo/`, e a mensagem **nomeia o arquivo infrator**
- [x] O teste afirma que o diretório existe **e** que varreu ≥1 arquivo `.dart` — sem isso passaria vacuamente (risco R-5)
- [x] Verificado à mão nos dois sentidos: injetar `import 'package:flutter/material.dart';` faz falhar; remover faz passar
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥3 (sem infrator passa · com infrator falha nomeando · varredura não vazia)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(fundacao): policia isolamento de core/calculo por teste`

---

### T4: `AppLogger` e `AppBlocObserver`

**What**: o sink único de observabilidade (interface + implementação de debug) e o observador global de BLoC que escreve nele.
**Where**: `lib/core/observability/app_logger.dart`, `lib/core/observability/app_bloc_observer.dart`, `test/support/recording_app_logger.dart`, `test/core/observability/app_bloc_observer_test.dart`
**Depends on**: T1
**Reuses**: `BlocObserver` do pacote `bloc`, `dart:developer.log`
**Requirement**: FUND-13

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `AppLogger` define `logEvent` e `logError(Object, StackTrace?)`; `DebugAppLogger` usa `dart:developer`
- [x] `AppBlocObserver` registra transição identificando **bloc, evento e estado resultante** (FUND-13 AC3) e cobre `Cubit` via `onChange`
- [x] `AppBlocObserver.onError` registra **exceção e stack trace** (FUND-13 AC4)
- [x] `RecordingAppLogger` (duplo de teste) guarda o que foi registrado — é a costura que torna o AC afirmável
- [x] Teste usa um bloc de mentira que emite estado e depois lança, como manda o Independent Test da spec
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥4 (transição com os três dados · `onChange` de cubit · erro com exceção · erro com stack)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(fundacao): adiciona observador global de bloc`

---

### T5: Handler global de erro não capturado

**What**: instalar `FlutterError.onError` e `platformDispatcher.onError` escrevendo no `AppLogger`.
**Where**: `lib/core/observability/global_error_handler.dart`, `test/core/observability/global_error_handler_test.dart`
**Depends on**: T4
**Reuses**: `AppLogger` (T4), mecanismo nativo do framework — **sem** `runZonedGuarded` (não é observável em teste)
**Requirement**: FUND-14

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `installGlobalErrorHandlers(AppLogger)` atribui os dois handlers; o do `platformDispatcher` retorna `true`
- [x] Teste dispara `FlutterError.onError!(details)` e `platformDispatcher.onError!(erro, stack)` e afirma que o `RecordingAppLogger` recebeu ambos com exceção e stack
- [x] Teste restaura os handlers originais no `tearDown` (não vaza estado global para os outros testes)
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥3 (erro de framework · erro assíncrono da plataforma · handler retorna `true`)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(fundacao): registra erro não capturado no logger global`

---

### T6: Modo de layout responsivo (mecanismo de W-R3)

**What**: o breakpoint de 900.0 px como função pura, mais o widget que expõe o modo à árvore.
**Where**: `lib/core/responsive/layout_mode.dart`, `lib/core/responsive/responsive_builder.dart`, `test/core/responsive/layout_mode_test.dart`, `test/core/responsive/responsive_builder_test.dart`
**Depends on**: T1
**Reuses**: `LayoutBuilder` do framework
**Requirement**: FUND-11

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `kCompactBreakpoint = 900.0`, `enum LayoutMode { compact, expanded }`, `layoutModeForWidth(double)` — `layout_mode.dart` é Dart puro (sem import de Flutter)
- [x] Fronteira exata: `899.9` → compacto, `900.0` → **expandido**, `900.1` → expandido (edge case literal da spec: 900.0 é expandido, sem oscilação)
- [x] `ResponsiveBuilder` entrega o modo correto ao redimensionar cruzando 900
- [x] Mora em `core/responsive/`, **não** em `core/design_system/` (AD-007) — nenhuma cor, fonte ou token aqui
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥5 (três da fronteira + largura pequena/grande no widget)

**Tests**: unit + widget
**Gate**: quick
**Commit**: `feat(fundacao): adiciona modo de layout compacto e expandido`

---

### T7: Emulator Suite declarado e refletido em Dart

**What**: `firebase.json` com os emuladores, e as constantes Dart que o app usa — cruzadas por teste para não divergirem.
**Where**: `firebase.json`, `.firebaserc`, `lib/core/firebase/emulator_config.dart`, `test/core/firebase/emulator_config_test.dart`
**Depends on**: T1
**Reuses**: padrão de portas do Emulator Suite (auth 9099, firestore 8080)
**Requirement**: FUND-16

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `firebase.json` declara os emuladores de auth e firestore (a spec fixa o arquivo como fonte, não os números)
- [x] `.firebaserc` aponta para o projeto `demo-bora` (AD-004)
- [x] `EmulatorConfig` expõe as portas e `host({required bool isAndroid, required bool isWeb})` → `10.0.2.2` no emulador Android, `localhost` no resto (risco R-8)
- [x] Teste **lê `firebase.json`** e afirma que as portas batem com as constantes Dart (risco R-6)
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥4 (porta auth ↔ json · porta firestore ↔ json · host Android · host web/iOS)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(fundacao): declara emuladores do firebase e espelha em dart`

---

### T8: Opções sintéticas do Firebase e falha explícita em release

**What**: as `FirebaseOptions` do projeto `demo-bora` e a função que decide quais opções valem — lançando em release sem projeto real.
**Where**: `lib/core/firebase/demo_firebase_options.dart`, `lib/core/firebase/firebase_environment.dart`, `test/core/firebase/firebase_environment_test.dart`
**Depends on**: T1
**Reuses**: `FirebaseOptions` de `firebase_core`
**Requirement**: FUND-16

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `demoFirebaseOptions` usa `projectId: 'demo-bora'` e valores sintéticos **bem formados** (`appId` no formato `1:<sender>:<plataforma>:<hash>`) — risco R-1
- [x] `FirebaseEnvironment.resolve({required bool isRelease, String? projectIdFromEnv})` devolve as opções demo fora de release
- [x] Em release sem `--dart-define=BORA_FIREBASE_PROJECT_ID` (ou com valor `demo-*`) **lança `StateError` com mensagem explícita** apontando o README (FUND-16 AC3)
- [x] O flag de release é **parâmetro**, nunca `kReleaseMode` lido direto — é o que torna os dois ramos testáveis
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥4 (debug devolve demo · release sem env lança · release com `demo-` lança · release com projeto real devolve opções)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(fundacao): resolve opções do firebase por ambiente`

---

### T9: Validação estrutural do código de convite

**What**: a função pura que decide se `:codigo` é bem formado — robustez de rota, **não** validação semântica (essa é da spec 09).
**Where**: `lib/core/routing/invite_code_format.dart`, `test/core/routing/invite_code_format_test.dart`
**Depends on**: T1
**Reuses**: nenhum
**Requirement**: FUND-09

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `isWellFormedInviteCode(String?)` aceita `[A-Za-z0-9_-]{1,64}` e recusa `null`, vazio, caractere inesperado e tamanho absurdo
- [ ] Documentado no arquivo que "existe? expirou?" é da spec 09 — aqui só a forma
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥6 (`rafa18` válido · `null` · vazio · caractere inesperado · 64 chars válido · 65 chars inválido)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(fundacao): valida forma do código de convite na rota`

---

### T10: Destinos genéricos — placeholder e erro

**What**: os dois widgets que toda rota desta spec usa como destino, sem nenhum token da spec 01.
**Where**: `lib/core/routing/placeholder_page.dart`, `lib/core/routing/route_error_page.dart`, `test/core/routing/placeholder_page_test.dart`, `test/core/routing/route_error_page_test.dart`
**Depends on**: T1
**Reuses**: `Scaffold`/`Text` do framework
**Requirement**: FUND-07, FUND-09

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `PlaceholderPage({required String id, required String titulo})` renderiza texto identificável e expõe `Key('placeholder:$id')`
- [ ] `RouteErrorPage({required String location})` renderiza mensagem **legível** com a URL tentada e `Key('route-error')` — nunca tela em branco
- [ ] Sem cor, fonte ou sombra fora do default do framework — a spec 01 reveste depois
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥3 (placeholder mostra id e título · chave presente · erro mostra a location)

**Tests**: widget
**Gate**: quick
**Commit**: `feat(fundacao): adiciona destinos de placeholder e erro`

---

### T11: Zona pública — `/entrar`, `/c/:codigo`, erro e `MaterialApp.router`

**What**: o roteador com as rotas que vivem fora de qualquer shell, o destino de erro e o `app.dart` no formato final (título da aba incluso).
**Where**: `lib/core/routing/routes.dart`, `lib/core/routing/app_router.dart`, `lib/app.dart` (modificar), `lib/features/entrar/presentation/pages/entrar_page.dart`, `lib/features/convidado/presentation/pages/convidado_page.dart`, `test/core/routing/app_router_publico_test.dart`
**Depends on**: T2, T9, T10
**Reuses**: `go_router` (`errorBuilder`, path params, `redirect`), `PlaceholderPage`/`RouteErrorPage` (T10), `isWellFormedInviteCode` (T9)
**Requirement**: FUND-07, FUND-08, FUND-09, FUND-10

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `Routes` declara os caminhos do mapa canônico do design (`/entrar`, `/roles`, `/roles/novo`, `/roles/:festaId/…`, `/c/:codigo`, `/erro`) com construtores para os que têm parâmetro
- [ ] `buildAppRouter({String initialLocation})` registra `/entrar`, `/c/:codigo` e `/erro`, com `errorBuilder` → `RouteErrorPage`
- [ ] `/c/:codigo` com código válido renderiza o placeholder do convidado **sem exigir autenticação**
- [ ] `/c/<malformado>` cai no destino de erro via `redirect`; `/c/` (sem código) cai no mesmo destino via `errorBuilder`
- [ ] Rota inexistente cai no destino de erro — sem exceção não tratada
- [ ] `app.dart` usa `MaterialApp.router` com `title: 'bora — a conta do rolê'` (literal de W-R5) e recebe o `GoRouter` por parâmetro (testável sem DI)
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥6 (`/entrar` · `/c/rafa18` renderiza convidado · `/c/` → erro · `/c/@@@` → erro · `/rota-que-nao-existe` → erro · título literal do `MaterialApp`)

**Tests**: widget
**Gate**: quick
**Commit**: `feat(fundacao): registra rotas públicas e destino de erro`

---

### T12: Shell do app e abas permanentes da festa

**What**: o `ShellRoute` do chrome e o `StatefulShellRoute.indexedStack` das quatro abas, com as seis páginas placeholder restantes.
**Where**: `lib/core/routing/app_shell.dart`, `lib/core/routing/festa_tabs_shell.dart`, `lib/core/routing/app_router.dart` (modificar), `lib/features/{home,montar,lista,galera,convite,custos}/presentation/pages/*_page.dart`, `test/core/routing/app_router_shell_test.dart`
**Depends on**: T2, T11
**Reuses**: `ShellRoute` e `StatefulShellRoute.indexedStack` do `go_router`, `PlaceholderPage` (T10)
**Requirement**: FUND-07, FUND-08

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `AppShell` expõe `static const chromeKey = Key('app-shell-chrome')` e envolve `/roles`, `/roles/novo` e `/roles/:festaId/montar`
- [ ] `FestaTabsShell` envolve as quatro abas (`lista`, `galera`, `whatsapp`, `custos`) em `StatefulShellRoute.indexedStack` (AD-003)
- [ ] Cada uma das sete rotas do shell renderiza o placeholder identificável da sua tela, sem erro
- [ ] Teste afirma o par discriminante de FUND-08: `chromeKey` **presente** em `/roles` e **ausente** em `/c/rafa18`
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥8 (uma navegação por rota do shell + o par presente/ausente do chrome)

**Tests**: widget
**Gate**: quick
**Commit**: `feat(fundacao): adiciona shell do app e abas da festa`

---

### T13: Container de dependências idempotente

**What**: o único container do projeto — configuração idempotente e reset para teste.
**Where**: `lib/core/di/injector.dart`, `test/core/di/injector_test.dart`
**Depends on**: T4, T12
**Reuses**: `GetIt.reset()` (entrega FUND-12 AC2 sem código nosso), `AppLogger` (T4), `buildAppRouter` (T12)
**Requirement**: FUND-12

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `configureDependencies({AppLogger? logger, GoRouter Function()? routerFactory})` registra `AppLogger` (singleton), `GoRouter` (lazy) e `FirebaseAuth`/`FirebaseFirestore` (lazy — resolução tardia, para que Firebase caído não derrube o boot)
- [ ] Chamada **duas vezes** no mesmo processo: sem exceção e sem registro duplicado (guarda por flag privada, não por `isRegistered<T>` — um teste pode pré-registrar um duplo)
- [ ] `resetDependencies()` devolve o container ao estado vazio **e** zera a flag, permitindo testes em qualquer ordem
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥4 (registra · dupla chamada não lança · dupla chamada não duplica a instância · após reset o container está vazio e reconfigurável)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(fundacao): adiciona container de dependências resetável`

---

### T14: Ordem de inicialização e degradação do Firebase

**What**: o `AppBootstrap` com os passos injetados — a costura que torna ordem e degradação afirmáveis sem Firebase real.
**Where**: `lib/bootstrap/app_bootstrap.dart`, `test/bootstrap/app_bootstrap_test.dart`
**Depends on**: T4
**Reuses**: `AppLogger` (T4)
**Requirement**: FUND-15, FUND-17

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `AppBootstrap.run(startApp)` executa na ordem: binding → observabilidade → Firebase → emuladores → DI → `startApp` (a inserção da observabilidade entre binding e Firebase está justificada no design: sem handler armado, FUND-17 não teria onde registrar)
- [ ] `startApp` é **sempre o último** — nenhum widget monta antes de as dependências existirem (FUND-15 AC1)
- [ ] Apenas os passos de Firebase e emulador ficam sob `try/catch`; a exceção vai para o `AppLogger` e o boot **continua** (FUND-17)
- [ ] Nenhum import de Firebase neste arquivo — todos os passos entram como closures
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥4 (ordem exata dos seis passos · Firebase lança → app abre mesmo assim · falha registrada no logger · emulador lança → mesmo comportamento)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(fundacao): fixa ordem de boot e degradação do firebase`

---

### T15: Adaptador do Firebase para os emuladores

**What**: o wrapper fino que chama `Firebase.initializeApp` e aponta Auth/Firestore para os emuladores.
**Where**: `lib/core/firebase/firebase_bootstrap.dart`
**Depends on**: T7, T8
**Reuses**: `FirebaseEnvironment.resolve` (T8), `EmulatorConfig` (T7)
**Requirement**: FUND-16, FUND-17

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `initialize()` chama `Firebase.initializeApp(options: FirebaseEnvironment.resolve(...))`
- [ ] `connectEmulators()` chama `useAuthEmulator` e `useFirestoreEmulator` com host e portas de `EmulatorConfig`, **só** em debug/teste — nunca contra infraestrutura remota (FUND-16 AC2)
- [ ] Nenhuma decisão nova mora aqui: qual opção, qual host e qual porta já foram decididos (e testados) em T7/T8 — este arquivo só chama
- [ ] `Tests: none` conforme a matriz (adaptador fino sobre singleton); a verificação é o gate de build + a checagem manual de T18
- [ ] Gate: `flutter analyze && flutter test` passa
- [ ] **M** — risco R-1: verificar empiricamente que `Firebase.initializeApp` com as opções sintéticas sobe em **mobile e web**. Se o SDK nativo rejeitar (`invalid GOOGLE_APP_ID`), **parar e escalar** — o fallback (opções reais por `--dart-define`) contraria o emulator-first e é decisão do usuário, não do executor

**Tests**: none (matriz: adaptador fino de SDK externo)
**Gate**: build
**Commit**: `feat(fundacao): aponta firebase para o emulator suite`

---

### T16: `main.dart` e URL limpa no web

**What**: a composição final — import condicional da estratégia de URL e o `main` que amarra bootstrap, DI e `runApp`.
**Where**: `lib/core/routing/url_strategy/{url_strategy.dart,url_strategy_stub.dart,url_strategy_web.dart}`, `lib/main.dart` (modificar), `test/core/routing/url_strategy_test.dart`, `test/app_test.dart` (modificar)
**Depends on**: T11, T13, T14, T15
**Reuses**: `usePathUrlStrategy()` de `flutter_web_plugins`, `AppBootstrap` (T14), `configureDependencies` (T13), `FirebaseBootstrap` (T15)
**Requirement**: FUND-01, FUND-10, FUND-15

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `configureUrlStrategy()` sai de um **import condicional** (`export … if (dart.library.js_interop) …`) — risco R-2: a doc oficial não garante que `flutter_web_plugins` compile no alvo mobile, e FUND-01 exige o mesmo `main.dart` nas duas plataformas
- [ ] `main.dart` compõe `AppBootstrap` com os passos reais e roda `BoraApp(router: getIt<GoRouter>())`
- [ ] Smoke test atualizado: o app monta com o roteador real e cai em `/roles`
- [ ] Gate: `flutter analyze && flutter test` passa
- [ ] Novos testes: ≥2 (stub não lança na VM · smoke com roteador real)
- [ ] **M** — `flutter run` em mobile **e** `flutter run -d chrome`; no navegador, a URL reflete a rota **sem `#`** e a aba mostra `bora — a conta do rolê` (metade não automatizável de FUND-10, risco R-9)

**Tests**: unit + widget
**Gate**: build
**Commit**: `feat(fundacao): compõe boot do app e url limpa no web`

---

### T17: Fixture do estado inicial (RN-30)

**What**: o churrasco do Rafa como dado bruto Dart puro, conferido campo a campo contra RN-30.
**Where**: `test/fixtures/rn30_estado_inicial.dart`, `test/fixtures/rn30_estado_inicial_test.dart`
**Depends on**: T2
**Reuses**: técnica de varredura de import de T3; texto literal de RN-30 (arquivo 03) e das personas (arquivo 01 §7)
**Requirement**: FUND-18, FUND-19

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] A fixture reproduz RN-30 **literalmente**: "CHURRAS DO RAFA 🔥", "SÁB · 18 JUL", "14H", "Laje do Rafa — Vila Madalena", duração 4h, 5 pessoas nomeadas (4 confirmadas + Duda), 4 confirmados / 2 pendentes na Home, e os itens bovina, frango, pão de alho, refrigerante, água, cerveja, cachaça
- [ ] Dados **brutos** (`Map`/`List` de primitivos): nenhuma entidade `Festa`/`Pessoa`/`ItemDeLista` — a tipagem é da spec 02 (FUND-19)
- [ ] Sem import de Flutter e sem import de Firebase, verificado por varredura no próprio teste
- [ ] Os números `4 confirmados / 2 pendentes` convivem com as 5 pessoas nomeadas **sem reconciliação** — são o texto literal de RN-30
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥5 (campos da festa · contagem e nomes das pessoas · status de Duda · lista de itens padrão · varredura de import)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(fundacao): adiciona fixture do estado inicial`

---

### T18: README de setup

**What**: a única memória da versão do SDK e o roteiro que faz um clone limpo rodar.
**Where**: `README.md`
**Depends on**: T16
**Reuses**: versão do SDK anotada em T1; portas de `firebase.json` (T7)
**Requirement**: FUND-20

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Documenta: versão do Flutter usada no scaffold (+ a `sdk:` constraint do `pubspec.yaml`), como rodar em mobile, como rodar em web, como subir o Emulator Suite e como executar `flutter analyze` e `flutter test`
- [ ] Inclui a checklist das verificações **manuais** desta spec: URL sem `#` no navegador, título da aba, e o par emulador no ar / emulador derrubado (FUND-17)
- [ ] Diz que o SDK **não** é versionado no repositório e que essa é a razão de a versão estar aqui (decisão do Discuss)
- [ ] Gate: `flutter analyze && flutter test` passa
- [ ] **M** — seguir o README do zero, sem consultar a spec, e chegar ao app rodando

**Tests**: none (documentação)
**Gate**: build
**Commit**: `docs(fundacao): adiciona readme de setup`

---

## Phase Execution Map

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5

Phase 1:  T1 ──→ T2 ──→ T3
Phase 2:  T4 ──→ T5     T6     T7     T8
Phase 3:  T9     T10 ──→ T11 ──→ T12
Phase 4:  T13    T14    T15 ──→ T16
Phase 5:  T17    T18
```

Execução é estritamente sequencial — sem paralelismo dentro da fase. As setas são **dependência**, não agenda: tasks sem seta entre si ainda rodam na ordem numérica.

**Packing previsto para o Execute** (18 tasks, orçamento ~7 por lote, corte só em fronteira de fase):

| Lote | Fases | Tasks | Total |
|---|---|---|---|
| 1 | Phase 1 + Phase 2 | T1–T8 | 8 |
| 2 | Phase 3 + Phase 4 | T9–T16 | 8 |
| 3 | Phase 5 | T17–T18 | 2 |

Mais de um lote ⇒ **a oferta de sub-agentes será apresentada no início do Execute** (offer-then-confirm; nada é despachado sem aceite). O Verifier roda automaticamente depois de T18, sem pergunta.

---

## Task Granularity Check

| Task | Scope | Status |
|---|---|---|
| T1 | 1 scaffold (comando + config) | ✅ Granular |
| T2 | 1 árvore + 1 teste | ✅ Granular |
| T3 | 1 barrel + 1 teste | ✅ Granular |
| T4 | 1 conceito (observabilidade de bloc): interface + impl + observador | ⚠️ 3 arquivos coesos — OK (a interface sem o observador não teria teste próprio) |
| T5 | 1 função | ✅ Granular |
| T6 | 1 função pura + 1 widget | ⚠️ 2 coesos — OK |
| T7 | 1 config + 1 classe de constantes | ⚠️ 2 coesos — OK (o teste cruza os dois) |
| T8 | 1 constante + 1 função | ⚠️ 2 coesos — OK |
| T9 | 1 função | ✅ Granular |
| T10 | 2 widgets irmãos | ⚠️ 2 coesos — OK |
| T11 | 1 zona de rotas + `app.dart` | ⚠️ Coeso — as páginas sozinhas não são verificáveis sem o roteador (merge forward prescrito) |
| T12 | 1 zona de rotas (shell + abas) | ⚠️ Coeso — mesma razão |
| T13 | 1 arquivo | ✅ Granular |
| T14 | 1 classe | ✅ Granular |
| T15 | 1 adaptador | ✅ Granular |
| T16 | 1 import condicional + `main.dart` | ⚠️ 2 coesos — OK (o `main` é o único consumidor) |
| T17 | 1 fixture + 1 teste | ✅ Granular |
| T18 | 1 arquivo | ✅ Granular |

Nenhum ❌: as tasks marcadas ⚠️ agrupam de 2 a 3 arquivos do **mesmo conceito**, e o agrupamento existe para que nenhuma task produza código não verificado.

## Diagram-Definition Cross-Check

| Task | Depends On (corpo) | Diagrama mostra | Status |
|---|---|---|---|
| T1 | None | entrada da Phase 1 | ✅ |
| T2 | T1 | T1 → T2 | ✅ |
| T3 | T2 | T2 → T3 | ✅ |
| T4 | T1 | T1 → T4 | ✅ |
| T5 | T4 | T4 → T5 | ✅ |
| T6 | T1 | T1 → T6 | ✅ |
| T7 | T1 | T1 → T7 | ✅ |
| T8 | T1 | T1 → T8 | ✅ |
| T9 | T1 | T1 → T9 | ✅ |
| T10 | T1 | T1 → T10 | ✅ |
| T11 | T2, T9, T10 | T2, T9, T10 → T11 | ✅ |
| T12 | T2, T11 | T11 → T12 (T2 herdado da Phase 1) | ✅ |
| T13 | T4, T12 | T4, T12 → T13 | ✅ |
| T14 | T4 | T4 → T14 | ✅ |
| T15 | T7, T8 | T7, T8 → T15 | ✅ |
| T16 | T11, T13, T14, T15 | T11, T13, T14, T15 → T16 | ✅ |
| T17 | T2 | T2 → T17 | ✅ |
| T18 | T16 | T16 → T18 | ✅ |

Nenhuma dependência aponta para fase posterior.

## Test Co-location Validation

| Task | Camada criada/modificada | Matriz exige | Task diz | Status |
|---|---|---|---|---|
| T1 | Config + composição mínima | none (config) / widget (smoke de `app.dart`) | widget | ✅ |
| T2 | Estrutura do projeto | unit (`test/architecture/`) | unit | ✅ |
| T3 | Estrutura + `core/calculo/` | unit (`test/architecture/`) | unit | ✅ |
| T4 | Lógica em `core/observability/` | unit | unit | ✅ |
| T5 | Lógica em `core/observability/` | unit | unit | ✅ |
| T6 | Lógica em `core/responsive/` + widget | unit + widget | unit + widget | ✅ |
| T7 | Config + lógica em `core/firebase/` | unit | unit | ✅ |
| T8 | Lógica em `core/firebase/` | unit | unit | ✅ |
| T9 | Lógica em `core/routing/` | unit | unit | ✅ |
| T10 | Widgets de `core/routing/` | widget | widget | ✅ |
| T11 | Rotas + widgets + `app.dart` | widget | widget | ✅ |
| T12 | Rotas + widgets | widget | widget | ✅ |
| T13 | Lógica em `core/di/` | unit | unit | ✅ |
| T14 | Composição/boot | unit | unit | ✅ |
| T15 | **Adaptador fino de SDK externo** | none | none | ✅ |
| T16 | Adaptador (url_strategy) + composição | unit + widget | unit + widget | ✅ |
| T17 | Fixture | unit | unit | ✅ |
| T18 | Documentação | none | none | ✅ |

Nenhuma ❌ VIOLATION. O único `Tests: none` de código (T15) é o que a matriz declara como camada sem teste unitário — e a justificativa é estrutural, não deferimento: a parte decidível daquele arquivo já foi extraída e testada em T7 e T8.

---

## Cobertura dos requisitos

| Req | Task(s) | Req | Task(s) |
|---|---|---|---|
| FUND-01 | T1, T16 | FUND-11 | T6 |
| FUND-02 | T1 | FUND-12 | T13 |
| FUND-03 | T1 | FUND-13 | T4 |
| FUND-04 | T2 | FUND-14 | T5 |
| FUND-05 | T2 | FUND-15 | T14, T16 |
| FUND-06 | T3 | FUND-16 | T7, T8, T15 |
| FUND-07 | T10, T11, T12 | FUND-17 | T14, T15 |
| FUND-08 | T11, T12 | FUND-18 | T17 |
| FUND-09 | T9, T10, T11 | FUND-19 | T17 |
| FUND-10 | T11, T16 | FUND-20 | T18 |

**20 de 20 requisitos mapeados. Nenhuma task órfã.**

---

## Fora do escopo deste plano (declarado, não esquecido)

- `integration_test/` — nenhum FUND-xx pede fluxo ponta-a-ponta; a pirâmide do `CLAUDE.md` prevê e2e para os fluxos de produto, que nascem da spec 05 em diante.
- Tela, token, componente ou fórmula — specs 01 e 02.
- `flutterfire configure`, projeto na nuvem, Hosting, Functions e CI — adiados por decisão do Discuss / proibidos sem pedido explícito (`CLAUDE.md`).
