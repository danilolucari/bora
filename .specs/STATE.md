# STATE

## Decisions

### AD-001
- **Decision**: A especificação `init-spec` foi decomposta em 11 specs de feature (00 `fundacao`, 01 `design-system`, 02 `calculo`, 03 `entrar`, 04 `home`, 05 `montar`, 06 `lista`, 07 `galera`, 08 `convite`, 09 `convidado`, 10 `custos`), organizadas em 4 marcos (M0 fundação → M1 monta e vê o custo → M2 chama a galera → M3 racha a conta), conforme `.specs/ROADMAP.md`.
- **Reason**: Recorte 1:1 com a estrutura feature-first do CLAUDE.md e com a matriz de rastreabilidade do arquivo 05; `design-system` e `calculo` viram specs próprias porque todas as telas dependem delas e as RN-xx precisam nascer testáveis em Dart puro antes de qualquer UI.
- **Trade-off**: `entrar` e `home` viram features fora da lista original do CLAUDE.md (que não previa onde T-01/T-02 morariam); `convite` fica Complexo por absorver T-06 + T-07 em vez de dividir em duas specs menores.
- **Scope**: todo o projeto — ordem de trabalho, dependências entre specs e cobertura de RN/UC/telas.
- **Date**: 2026-08-12
- **Status**: active

### AD-002
- **Decision**: Navegação com **`go_router`** e injeção de dependência com **`get_it` manual — zero codegen** no projeto (sem `injectable`, sem `auto_route`, sem `build_runner`). Container único em `lib/core/di/injector.dart`: `configureDependencies()` idempotente por flag privada + `resetDependencies()` sobre `GetIt.reset()`.
- **Reason**: `go_router` é do time do Flutter e entrega `errorBuilder`, path params e URL limpa no web sem código nosso; `get_it.reset()` satisfaz FUND-12 direto. Zero codegen mantém o ciclo de teste das dez specs seguintes sem `dart run build_runner` obrigatório.
- **Trade-off**: mais boilerplate de registro manual por feature e navegação por string (não tipada) — aceito em troca de diff limpo e teste sem etapa de geração.
- **Scope**: todas as features; nenhuma cria seu próprio container.
- **Date**: 2026-08-13
- **Status**: active

### AD-003
- **Decision**: Esqueleto de navegação em três zonas — `/entrar`, `/c/:codigo` e `/erro` **fora de qualquer shell**; `ShellRoute` (chrome do app) em volta de `/roles`, `/roles/novo` e `/roles/:festaId/montar`; e, aninhado, `StatefulShellRoute.indexedStack` para as quatro abas permanentes da festa (`/roles/:festaId/{lista,galera,whatsapp,custos}`). Mapa de rotas canônico em `.specs/features/fundacao/design.md`.
- **Reason**: `/c/:codigo` sem auth e sem chrome é estrutural (RN-24: o convidado não tem conta) e caro de retrofitar; o `indexedStack` preserva o estado de cada aba, que é o que as specs 06–10 exigem. Base `/roles` vem de W-R5.
- **Trade-off**: mais estrutura do que a fundação precisa hoje (todas as telas são placeholder); em troca as specs 03–10 só trocam o corpo de `features/<x>/presentation/pages/<x>_page.dart` sem tocar em `app_router.dart`.
- **Scope**: todas as specs de tela.
- **Date**: 2026-08-13
- **Status**: active

### AD-004
- **Decision**: Firebase **emulator-first com opções sintéticas**: `FirebaseOptions` de projeto `demo-bora` escritas à mão (sem `flutterfire configure`), emuladores declarados em `firebase.json` e cruzados por teste com as constantes de `EmulatorConfig` (host `10.0.2.2` no emulador Android, `localhost` no resto). Em **release sem** `--dart-define=BORA_FIREBASE_PROJECT_ID` real, `FirebaseEnvironment.resolve` lança `StateError` explícito. Falha do Firebase ou do emulador é **degradação**: o app abre e o erro vai para o logger global.
- **Reason**: mantém toda a fundação verificável offline, sem credencial e sem custo (context.md), e evita que um build de release alcance silenciosamente um projeto inexistente.
- **Trade-off**: projeto `demo-` com FlutterFire é área de atrito conhecido no nativo (flutterfire#9507, #12965) e não pôde ser verificado sem SDK — a task de Firebase verifica empiricamente em mobile e web antes de seguir; se o SDK nativo rejeitar, o fallback (opções reais por `--dart-define`) contraria o emulator-first e volta como decisão do usuário.
- **Scope**: todo acesso a Auth/Firestore até a feature que primeiro precisar publicar.
- **Date**: 2026-08-13
- **Status**: active

### AD-005
- **Decision**: Observabilidade atrás de uma interface própria — `AppLogger` (`logEvent` / `logError`) com `DebugAppLogger` em produção e duplo de gravação em teste; `AppBlocObserver` e `installGlobalErrorHandlers` (`FlutterError.onError` + `platformDispatcher.onError`, sem `runZonedGuarded`) escrevem **só** nela. A instalação acontece logo após o binding, antes do Firebase.
- **Reason**: sem a interface, "o observador registrou" não é afirmável em teste — e FUND-13/14/17 dependem exatamente dessa afirmação. Armar os handlers antes do Firebase é o que torna a queda do emulador observável.
- **Trade-off**: uma indireção a mais em vez de `print`/`debugPrint` direto.
- **Scope**: todo log de bloc e todo erro não capturado do app.
- **Date**: 2026-08-13
- **Status**: active

### AD-006
- **Decision**: `entrar` e `home` existem como **features próprias** em `lib/features/`, ao lado das seis do CLAUDE.md (`montar`, `lista`, `galera`, `convite`, `convidado`, `custos`) — oito pastas, cada uma com `domain/`, `data/`, `presentation/`.
- **Reason**: materializa em código o recorte do AD-001, que já as tratava como specs 03 e 04.
- **Trade-off**: diverge da lista literal de features do CLAUDE.md (que não dizia onde T-01/T-02 morariam); a alternativa (fundir `home` numa feature `festa`) foi descartada por afastar código e spec.
- **Scope**: árvore de `lib/features/` e o espelho em `test/`.
- **Date**: 2026-08-13
- **Status**: active

### AD-007
- **Decision**: O breakpoint de W-R3 mora em `lib/core/responsive/` (`kCompactBreakpoint = 900.0`, `enum LayoutMode { compact, expanded }`, `layoutModeForWidth`), **não** em `core/design_system/`. Fronteira: `< 900.0` compacto, `>= 900.0` expandido.
- **Reason**: `core/design_system/` é território da spec 01, e o modo de layout precisa ser consumível (e testável) sem depender de tema. O `~900px` do arquivo 06 era prosa; um AC precisa de fronteira única.
- **Trade-off**: mais uma pasta em `core/`; a spec 01 reexporta se quiser tratar o breakpoint como token.
- **Scope**: toda decisão de layout responsivo do produto.
- **Date**: 2026-08-13
- **Status**: active

## Handoff

- **Feature**: `fundacao` (`.specs/features/fundacao/`) — **CONCLUÍDA** ✅
- **Phase / Task**: **Execute concluído** — T1–T18 implementadas e commitadas (3 lotes de sub-agentes), mais 2 tasks de correção vindas do Verifier. Validação independente **PASS** na iteração 2.
- **Completed**: ROADMAP.md, STATE.md (AD-001..AD-007), fundacao/{context,spec,design,tasks,validation}.md, e o código: `pubspec.yaml`, árvore Clean Architecture (`lib/core/` + 8 features), `core/observability/`, `core/responsive/`, `core/firebase/`, `core/routing/` (rotas públicas + shell + abas), `core/di/`, `bootstrap/`, `main.dart`, fixture RN-30 e README de setup.
- **In-progress** (file:line): none
- **Next step**: **spec 01 `design-system`** (tokens e componentes do arquivo 02) ou **spec 02 `calculo`** (RN-xx em Dart puro) — as duas destravam todas as telas. Ver `.specs/ROADMAP.md`, marco M1.
- **Blockers**: nenhum. **Checklist manual do README executada em 2026-08-20** (Android físico moto g15 / API 35 + Chrome 151 + Emulator Suite), com os resultados abaixo.
- **Verificações manuais — resultado**:
  - ✅ **FUND-01** — `flutter run` instalou e abriu no Android físico (`Installing build/app/outputs/flutter-apk/app-debug.apk`, `Flutter run key commands`, MainActivity renderizando 1080x2400) e `flutter build web` saiu com exit 0. Mesmo `lib/main.dart` nas duas plataformas.
  - ✅ **R-1 RESOLVIDO — o risco caiu a favor do AD-004.** O SDK **nativo** aceitou as opções sintéticas de `demo-bora`: log do device traz `I/FirebaseApp: Device unlocked: initializing all Firebase APIs for app [DEFAULT]`, sem nenhum `invalid GOOGLE_APP_ID` nem `FirebaseException`. No web, zero erro de console. **O emulator-first não precisa de fallback**; `--dart-define` com projeto real segue desnecessário.
  - ✅ **FUND-10** — em Chrome real, via servidor com fallback SPA: título exatamente `bora — a conta do rolê`; URLs **sem `#`** (`/roles`, `/c/rafa18`, `/rota-que-nao-existe`); `/rota-que-nao-existe` renderiza "PÁGINA NÃO ENCONTRADA — Esse endereço não leva a nenhuma tela do bora." com a URL tentada, **nunca tela branca**; `/c/rafa18` mostra "CONVIDADO · rafa18" e a URL **permanece** em `/c/rafa18`, provando que não há redirect para login. Bônus: `/roles/rafa18` redireciona para `/roles/rafa18/lista` — a rota do mutante corrigido em 73234e8, confirmada em navegador.
  - ⚠️ **FUND-17 — metade verificada, metade ainda não observável.** O que importa está provado: com emuladores **no ar** e com eles **derrubados**, o app abre e navega igual — degradação, não crash. Mas o "erro de conexão aparece no log pelo handler global" **não se manifesta**: `useAuthEmulator`/`useFirestoreEmulator` só configuram host, não conectam de imediato, e como **toda tela desta spec é placeholder**, nada lê ou escreve no Firestore. Não é defeito — o critério só fica observável quando a primeira feature tocar dados de verdade (spec 05 em diante). Reverificar lá.
  - ⬜ **FUND-20 AC2** — seguir o README do zero num clone limpo: não executado (exigiria clonar em outra máquina/pasta e refazer o setup).
- **Decisão pendente do usuário**: **FUND-17 AC4** diz que o erro do Firebase é registrado "pelo handler global", mas a implementação o registra pelo `try/catch` do `AppBootstrap`, no mesmo `AppLogger` (mecanismo prescrito por T14). O resultado observável do AC está afirmado em teste. O Verifier apontou que a leitura literal do AC colide consigo mesma — uma exceção que chegasse ao handler global abortaria o boot, violando o "app abre mesmo assim" do próprio AC. Alinhar o texto do AC é decisão do usuário; o código não foi tocado.
- **Uncommitted files**: none
- **Branch**: main (os 23 commits da fundação foram para `main`, seguindo o histórico já existente; o `CLAUDE.md` prescreve `feature/nome` — divergência declarada, não corrigida por conta própria)
