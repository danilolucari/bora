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

> **Checkpoint de orquestração — 2026-08-20 21:55.** Duas specs em voo, em paralelo,
> cada uma na sua worktree. Este bloco é o ponto de retomada: tudo abaixo está em disco
> e em git. Se a sessão morrer agora, nada se perde além do que estiver a meio de uma task.

- **Features**: `design-system` (spec 01) e `calculo` (spec 02) — **em paralelo**, marco M1 do ROADMAP.
- **Phase / Task**: **Tasks** — `spec.md` e `design.md` das duas concluídos e commitados; `tasks.md` em escrita pelos planners.
- **Worktrees e branches** (ambas partem de `c5be425`, baseline 92 testes verdes e `analyze` limpo, `pub get` já rodado):

  | Worktree | Branch | Commits de planejamento |
  |---|---|---|
  | `/home/lucari/repo/bora-ds` | `feature/design-system` | `204bfcf` spec (DS-01..DS-35) · `893ab67` design |
  | `/home/lucari/repo/bora-calculo` | `feature/calculo` | `1fe3cc3` spec (CALC-01..CALC-27) · `899a547` design |

- **Completed**: decomposição do trabalho em dois workflows isolados; contratos de fronteira fixados (a UI não calcula nem formata — a fração do marcador de RN-11 e a formatação de RN-13 saem de `core/calculo/` prontas); `spec.md` + `design.md` das duas features.
- **In-progress**: `.specs/features/design-system/tasks.md` e `.specs/features/calculo/tasks.md`.
- **Next step**: empacotar as fases em lotes de ~7 tasks → despachar batch workers (sequencial dentro de cada spec, paralelo entre specs) → **Verifier independente por spec** → merge das duas branches em `main` → escrever os ADs e rodar `lessons.py`.

- **Decisões do usuário em 2026-08-20** (já incorporadas às specs, ainda não viradas AD):
  1. Fontes **bundladas** em `assets/fonts/` (Archivo variável + Archivo Black + OFL), não o pacote `google_fonts`.
  2. Catálogo de componentes como **rota interna `/catalogo`**, sem dependência nova.
  3. **RN-10 — leitura (a)**: R$ 271 manda e o parêntese "(22+30+8+15)" do arquivo 03 está errado. Entram no total Carvão 22 + Gelo 30 + Sal 8 = 60; Copos & pratos (R$ 15) aparece na lista e fica **fora** do total. Decidido pela consistência entre dois números independentes (211+60 = 271 e 270,6/6 = 45,1 → ≈R$ 45).

- **Correção técnica registrada** (a premissa de partida do orquestrador estava errada): Archivo é distribuída só como fonte variável, mas **desde o Flutter 3.41 o `FontWeight` ajusta o eixo `wght` sozinho** e a doc oficial recomenda evitar `FontVariation`. SDK deste repo é 3.47.0. Medição empírica confirma (`w800` e `FontVariation('wght',800)` dão largura idêntica). `FontVariation` fica **proibida** no código de produto, policiada por DS-09.

- **ADs propostos, aguardando merge para eu escrever**: `calculo` propõe AD-008 (entidades compartilhadas em `core/calculo/dominio/`), AD-009 (precisão: aritmética em `double`, arredondamento só na formatação) e AD-010 (leitura (a) de RN-10 com `entraNoTotal` declarado); `design-system` propõe quatro (exposição do token, mecanismo de peso da fonte, hand-off de `boraTheme()` para a spec 03, catálogo como rota interna).

- **Blockers**: nenhum ativo. **Evento de limite de uso da conta em 2026-08-20 16:54** derrubou os dois planners no meio da escrita do `design.md`; o reset das 19:40 já passou e ambos foram retomados com sucesso às ~21:51, sem perda — os arquivos estavam em disco e foram commitados.
- **Uncommitted files**: nenhum em `main`. Nas worktrees, apenas o `tasks.md` em escrita.
- **Branch**: `main` intocada desde `c5be425`. O trabalho novo vive nas duas `feature/*`, como o `CLAUDE.md` prescreve — corrige a divergência que a fundação tinha registrado aqui.

### Como retomar do zero

```bash
git worktree list                                   # as duas worktrees devem aparecer
cd /home/lucari/repo/bora-calculo && git log --oneline main..HEAD
cd /home/lucari/repo/bora-ds     && git log --oneline main..HEAD
# em cada worktree, o portão:  flutter analyze && flutter test
# o plano de cada spec:        .specs/features/<nome>/tasks.md  (marca o que já fechou)
```

Cada task fecha em commit atômico, então o último commit de cada branch é o ponto exato de retomada. Ao final das duas: `git merge feature/calculo` e `git merge feature/design-system` em `main`, escrever os ADs acima na seção Decisions e rodar `.claude/skills/tlc-spec-driven/scripts/lessons.py`.
