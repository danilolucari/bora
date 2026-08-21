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

> **Checkpoint de orquestração — 2026-08-20 22:10.** Duas specs em voo, em paralelo, cada uma
> na sua worktree. **Planejamento das duas concluído; Execute em curso.** Tudo abaixo está em
> disco e em git — se a sessão morrer agora, perde-se no máximo a task corrente de cada lote.

- **Features**: `design-system` (spec 01) e `calculo` (spec 02) — **em paralelo**, marco M1 do ROADMAP.
- **Phase**: **Execute**, lote 1 de cada spec despachado.

| Worktree | Branch | Planejamento (commitado) | Tasks | Lotes |
|---|---|---|---|---|
| `/home/lucari/repo/bora-calculo` | `feature/calculo` | `1fe3cc3` spec · `899a547` design · `8c9d404` tasks | **28** em 6 fases | 5 lotes: 6 / 7 / 5 / 5 / 5 |
| `/home/lucari/repo/bora-ds` | `feature/design-system` | `204bfcf` spec · `893ab67` design · `9c69f5b` tasks | **32** em 7 fases | 5 lotes: 6 / 7 / 5 / 6 / 8 |

Ambas partem de `c5be425`; baseline em cada uma: **92 testes verdes**, `flutter analyze` limpo, `pub get` feito.

- **Completed**: Specify + Design + Tasks das duas specs; contratos de fronteira fixados (a UI não calcula nem formata — a fração do marcador de RN-11 e a formatação de RN-13 saem prontas de `core/calculo/`); os sete ADs propostos persistidos.
- **In-progress**: lote 1 de cada spec (fase 1, T1–T6 nas duas).
- **Next step**: receber o resumo de cada lote → checkpoint → despachar o lote seguinte (sequencial dentro da spec, paralelo entre specs) → ao fim de cada spec, **Verifier independente** → merge das duas branches em `main` → colar os ADs → rodar `lessons.py`.

- **⚠️ ADs pendentes**: os sete textos estão em **`.specs/features/ads-pendentes.md`**, já com a **colisão de numeração resolvida** (os dois planners propuseram AD-008/009/010 para coisas diferentes; `calculo` ficou com 008–010 e `design-system` com 011–014). Colar na seção Decisions no merge e **apagar o arquivo**.

- **Decisões do usuário em 2026-08-20** (já incorporadas às specs): fontes **bundladas** em `assets/fonts/`, não `google_fonts` · catálogo como **rota interna `/catalogo`** · **RN-10 leitura (a)**: R$ 271 manda, entram Carvão 22 + Gelo 30 + Sal 8 = 60, Copos & pratos fica fora do total · execução **ponta a ponta** sem checkpoint de aprovação entre fases.

- **Pergunta aberta ao usuário** (não bloqueia; cai na fase 4 de `calculo`, task T23): premissa A-16 de `calculo` — progresso de quitação **sem nenhuma linha** devolve `1.0` (barra cheia). O planner declarou e testou, mas sinalizou que um cliente poderia querer `0.0` (barra vazia) quando ainda não há despesa.

- **Blockers**: nenhum ativo. **Evento de limite de uso da conta em 2026-08-20 16:54** derrubou os dois planners; o reset das 19:40 passou e ambos foram retomados às ~21:51 sem perda.
- **Proteção ativa**: autosave em background espelha trabalho não-commitado das três árvores para o scratchpad a cada 2 min. Protocolo de limite: checkpoint → dormir até o horário de reset informado no erro → retomar do último commit de cada branch.
- **Uncommitted files**: nenhum em `main`.
- **Branch**: `main` intocada em código desde `c5be425` (só docs de orquestração). O código novo vive nas duas `feature/*`, como o `CLAUDE.md` prescreve.

### Como retomar do zero

```bash
git worktree list                                   # as duas worktrees devem aparecer
cd /home/lucari/repo/bora-calculo && git log --oneline main..HEAD
cd /home/lucari/repo/bora-ds     && git log --oneline main..HEAD
# em cada worktree, o portão:  flutter analyze && flutter test
# o plano de cada spec:        .specs/features/<nome>/tasks.md  (as caixas marcadas dizem onde parou)
```

Cada task fecha em commit atômico, então o último commit de cada branch é o ponto exato de retomada.
