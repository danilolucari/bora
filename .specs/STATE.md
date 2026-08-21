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

> **SESSÃO PAUSADA em 2026-08-21 15:05, a pedido do usuário.** Todos os agentes foram parados.
> Este bloco é auto-suficiente: quem retomar não precisa de nada além dele, do `tasks.md` de cada
> spec e do git. **57 das 60 tasks estão commitadas e verificadas.**

### Panorama

| Spec | Tasks | Testes | Commits à frente de `main` | Estado |
|---|---|---|---|---|
| 02 `calculo` | **28 / 28** ✅ | **425** verdes | 31 | Implementação **completa**. Falta só a validação independente. |
| 01 `design-system` | **29 / 32** | **378** verdes | 33 | Faltam T30, T31, T32. |

`main` está em `9b270b4`, limpa, **sem nenhum código das duas specs** — só os documentos de orquestração.
Baseline histórica do projeto: 92 testes (fundação). Hoje somam **803** nas duas branches.

### Worktrees

| Caminho | Branch | Último commit |
|---|---|---|
| `/home/lucari/repo/bora` | `main` | `9b270b4` |
| `/home/lucari/repo/bora-calculo` | `feature/calculo` | `2735a13` (T28) |
| `/home/lucari/repo/bora-ds` | `feature/design-system` | `bd7953b` (T29) |

⚠️ **Não rode `git clean` em nenhuma delas.** Há dois arquivos não-commitados que são trabalho legítimo em curso:
- `bora-calculo/.specs/features/calculo/validation.md` — 61 linhas, **esqueleto com as 9 seções já criadas** pelo Verifier (que escrevia incrementalmente por causa do risco de limite). O Verifier foi interrompido logo no começo da apuração; o conteúdo das seções está vazio.
- `bora-ds/lib/core/design_system/components/bora_bottom_sheet.dart` — 136 linhas, **T30 em andamento**. O worker havia decidido: scrim usa o token `sheetScrim` (não `ink`) e o painel tem borda só no topo. Não há teste ainda.

### O que falta, em ordem

1. **`design-system` T30–T32** (retomar o lote 5): T30 bottom sheet (parcial em disco), T31 frame do celular (as duas exceções do sistema: radius 38 e a única sombra com blur), T32 completude do catálogo — o teste tem de **falhar se um componente sumir** das seções. Baseline ao retomar: **378** testes.
2. **Verifier de `calculo`** — agente novo, autor ≠ verificador, evidence-or-zero, sensor P0 com **≥10 mutações**. Foi despachado e interrompido; o prompt completo está descrito no item "Contrato do Verifier" abaixo.
3. **Verifier de `design-system`** — mesmo rigor, depois de T32.
4. **Corrigir gaps** que os Verifiers apontarem (loop fix→re-verify, no máximo 3 iterações antes de escalar).
5. **Merge** de `feature/calculo` e depois `feature/design-system` em `main`. Os dois workflows respeitaram fronteiras disjuntas de arquivo — só `design-system` tocou `pubspec.yaml` e `lib/core/routing/` — então não deve haver conflito de código.
6. **Escrever os 7 ADs** de `.specs/features/ads-pendentes.md` na seção Decisions acima, **já renumerados** (`calculo` 008–010, `design-system` 011–014), e **apagar aquele arquivo**.
7. **Rodar** `.claude/skills/tlc-spec-driven/scripts/lessons.py` com as lições que os Verifiers destilarem.
8. **Atualizar o `ROADMAP.md`**: marcar as specs 01 e 02 como concluídas e registrar que o marco **M0 fechou**.

### Contrato do Verifier (vale para as duas specs)

Agente **novo**, que não implementou nada. Instruções essenciais:
- **Não aceitar nenhuma alegação dos batch workers**, inclusive os "self-checks de discriminação" que eles relataram — self-check de autor não substitui o sensor.
- Re-derivar a cobertura a partir do `spec.md` com **evidence-or-zero**: critério sem `file:line` + expressão da asserção conta como **não coberto**.
- **Sensor P0**: ≥10 mutações comportamentais em estado descartável. Protocolo: árvore limpa antes de cada uma → editar → rodar → `git checkout -- <arquivo>` **imediato** → `git status` conferido entre todas e ao final. Nenhum commit de código, nenhuma mutação deixada para trás.
- **O Verifier não conserta.** Gap vira task ranqueada para outro agente.
- Escrever `.specs/features/<spec>/validation.md` **incrementalmente em disco** (risco de limite) e commitá-lo.
- Espelhar o formato de `.specs/features/fundacao/validation.md`.

**Pontos que o Verifier de `calculo` precisa atacar:** os quatro números canônicos (R$ 211 · ≈R$ 30/cabeça · R$ 271 · ≈R$ 45/adulto), os Testes A e B de RN-16 com **ordem** (e se a guarda anti-ordenação em `casos_literais_do_arquivo_03_test.dart` discrimina mesmo), a política de precisão de AD-009 (a armadilha `(1.15*10).round() == 11`), RN-14 (criança fora do racha; os dois divisores coexistindo), `entraNoTotal` como dado declarado, a cerveja por `adultos − abstêmios`, a pureza Dart puro, a fixture RN-30 e o barrel como porta única.

**Pontos para o de `design-system`:** os valores literais de §1 e §4 afirmados um a um, o press-sink (translate 2,2 + sombra 4→2), o toast (1 por vez, 2200 ms, substitui sem empilhar), as três guardas de varredura (se ainda mordem), a fronteira com `calculo` (DS-27 recebe a fração pronta e não calcula), e as exceções de radius/blur.

### Pendências manuais (M) — não automatizáveis neste ambiente

- **DS-33** — a conferência visual "parece o protótipo?". Não há device nem navegador aqui. Roteiro: `flutter run` e `flutter run -d chrome`, abrir `/catalogo`, conferir cada seção contra `.specs/init-spec/02-design-system.md`. **Testes verdes provam que cada token tem o valor literal da spec; não provam que o conjunto parece certo.**
- **FUND-17 AC4** (herdada da fundação) — a spec nomeia "handler global" mas a implementação registra pelo `try/catch` do boot. Diagnóstico completo em `.specs/features/fundacao/validation.md`. **Decisão do usuário, ainda pendente.**

### Decisões do usuário nesta sessão (2026-08-20 / 21)

1. Fontes **bundladas** em `assets/fonts/` (Archivo variável + Archivo Black + OFL), não o pacote `google_fonts`.
2. Catálogo de componentes como **rota interna `/catalogo`**, sem dependência nova.
3. **RN-10 leitura (a)**: R$ 271 manda; entram Carvão 22 + Gelo 30 + Sal 8 = 60; Copos & pratos aparece na lista e fica **fora** do total. O parêntese "(22+30+8+15)" do arquivo 03 está errado.
4. Execução **ponta a ponta**, sem checkpoint de aprovação entre fases.
5. Ao bater no limite de cota, retomar **5 minutos depois** do horário de reset, automaticamente.

### Pergunta aberta, sem bloquear

Premissa **A-16** de `calculo`: `progressoDeQuitacao` **sem nenhuma linha** devolve `1.0` (barra cheia). Está implementado e testado assim, com doc comment registrando que `0.0` seria defensável. A spec `custos` pode trocar em uma linha.

### Histórico de interrupções — o que funcionou

A cota estourou **quatro vezes** (2026-08-20 16:54 · 2026-08-21 ~00:00 · ~09:00 · ~14:00). **Perda acumulada de trabalho: praticamente zero.** O que fez isso funcionar:

1. **Commit atômico ao fim de cada task**, antes de a próxima começar — limita a perda a uma task, sem depender de prever o limite.
2. **Conferir o portão antes de retomar.** O estado do trabalho meio-escrito varia: 3× estava íntegro e verde (o worker morreu entre passar no teste e commitar), 1× não compilava. A instrução de retomada muda conforme o caso.
3. **Retomar por mensagem, nunca por agente novo** — o transcript preserva o contexto e custa muito menos que recomeçar frio.
4. **Esperar reset + 5 min** (`scratchpad/aguardar-reset.sh HH:MM`), para não bater na virada.

### Como retomar

```bash
git worktree list
cd /home/lucari/repo/bora-calculo && git log --oneline main..HEAD && flutter analyze && flutter test   # 425
cd /home/lucari/repo/bora-ds     && git log --oneline main..HEAD && flutter analyze && flutter test   # 378
# o que já fechou está marcado em .specs/features/<spec>/tasks.md
# os 7 ADs esperando merge: .specs/features/ads-pendentes.md
```
