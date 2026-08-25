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

> **SESSÃO EM ANDAMENTO — retomada em 2026-08-25.**
> Este bloco substitui o handoff de 2026-08-21, que estava **desatualizado**: as branches
> avançaram depois dele. Tudo abaixo foi re-apurado do git e da suíte, não herdado.
>
> Houve uma pausa por volta das 09:05 BRT, registrada aqui numa versão anterior deste
> arquivo, que foi **um alarme falso** — ver "Monitoria de cota" abaixo. O trabalho seguiu.

### Mudança de ambiente

A sessão anterior rodava em **Linux** (`/home/lucari/repo/...`). Esta roda em **Windows**,
`c:\repos\lucari\bora`, Flutter 3.47.1 / Dart 3.13.1 (SDK em `C:\SDKs\flutter`). As
worktrees foram **recriadas a partir do `origin`**:

| Caminho | Branch | Último commit |
|---|---|---|
| `C:/repos/lucari/bora` | `main` | `a659aec` |
| `C:/repos/lucari/bora-calculo` | `feature/calculo` | `62c5537` |
| `C:/repos/lucari/bora-ds` | `feature/design-system` | `bcd156d` |

Os dois arquivos não-commitados que o handoff antigo mandava preservar **não existem aqui**
— ficaram na outra máquina. Nada se perdeu: o trabalho deles já tinha sido commitado e
chegou pelo remote (`3b4d040` o bottom sheet da T30, `62c5537` o `validation.md`).

### Panorama re-apurado

| Spec | Tasks | Testes | Analyze | Estado |
|---|---|---|---|---|
| 02 `calculo` | **28 / 28** | **425** verdes | limpo | Implementação completa. Falta a validação independente. |
| 01 `design-system` | **31 / 32** | **386** verdes | limpo | Falta só a **T32**. |

### O que esta sessão fez

1. **`fix(design-system)` `179bab0`** — a suíte do DS chegou **vermelha** no Windows:
   `token_purity_guard_test.dart` comparava o path devolvido por `listSync`
   (`lib\core\design_system`) contra a constante escrita com `/`. O teste anti-vácuo — que
   existe justamente para provar que a varredura não passa à toa — falhava, e a guarda se
   declarava vazia numa plataforma e cheia na outra. Normalizado o separador, com sensor
   cobrindo as duas formas de path. **Era bug de teste, não de produto**: as varreduras em si
   usam `endsWith` de nome de arquivo e sempre funcionaram nos dois sistemas.
2. **`feat(design-system)` `bcd156d` — T31, o frame do celular.** 390×820, radius 38, borda
   1px, conteúdo cortado nos cantos; header e rodapé fixos com a área central rolando; sombra
   suave **fora** do recorte. Seção no catálogo e export no barrel. +7 testes (379 → 386). As
   duas allowlists da guarda já nomeavam `bora_phone_frame.dart` desde a fase 2 e seguem verdes.

### O `validation.md` de `calculo` é um esqueleto vazio

`62c5537` commitou `.specs/features/calculo/validation.md` com **todas as nove seções em
`_(pendente)_`** — e com mensagem de commit em inglês, fora da convenção do projeto. **Não é
uma validação.** O Verifier de `calculo` continua integralmente por fazer.

### O que falta, em ordem

1. **`design-system` T32** — catálogo completo, responsivo e verificado por completude.
   Baseline ao retomar: **386** testes. O registro de seções termina em `FRAME DO CELULAR`; a
   lista canônica do teste de completude tem de falhar **nomeando** o componente ou export que
   sumir.
2. **Verifier de `calculo`** — ver "Contrato do Verifier".
3. **Verifier de `design-system`** — mesmo rigor, depois da T32.
4. **Corrigir gaps** dos Verifiers (loop fix→re-verify, máx. 3 iterações antes de escalar).
5. **Merge** de `feature/calculo` e depois `feature/design-system` em `main`. Fronteiras de
   arquivo foram disjuntas — só `design-system` tocou `pubspec.yaml` e `lib/core/routing/`.
6. **Escrever os 7 ADs** de `.specs/features/ads-pendentes.md` na seção Decisions,
   renumerados (`calculo` 008–010, `design-system` 011–014), e **apagar** aquele arquivo.
7. **Rodar** `.claude/skills/tlc-spec-driven/scripts/lessons.py` com as lições dos Verifiers.
   Candidata desta sessão: *guarda que compara path de filesystem contra constante escrita com
   `/` é verde só no POSIX*.
8. **Atualizar o `ROADMAP.md`**: specs 01 e 02 concluídas, marco **M0** fechado.

### Pendência de marcação

As caixas "Done when" de **T30 e T31** ainda estão `- [ ]` no
`.specs/features/design-system/tasks.md` — as duas tasks estão commitadas e verdes, mas o
plano não foi marcado. Marcar junto com a T32, num commit `docs(design-system)`.

### Decisão pendente do usuário: push

`feature/design-system` está **2 commits à frente** de `origin` (`179bab0`, `bcd156d`) e nada
foi enviado — push não foi pedido nesta sessão. Se o trabalho for retomado em outra máquina, é
preciso `git push origin feature/design-system` antes.

### Contrato do Verifier (vale para as duas specs)

Agente **novo**, que não implementou nada. Instruções essenciais:
- **Não aceitar nenhuma alegação dos batch workers**, inclusive os "self-checks de
  discriminação" que eles relataram — self-check de autor não substitui o sensor.
- Re-derivar a cobertura a partir do `spec.md` com **evidence-or-zero**: critério sem
  `file:line` + expressão da asserção conta como **não coberto**.
- **Sensor P0**: ≥10 mutações comportamentais em estado descartável. Protocolo: árvore limpa
  antes de cada uma → editar → rodar → `git checkout -- <arquivo>` **imediato** → `git status`
  conferido entre todas e ao final. Nenhum commit de código, nenhuma mutação deixada para trás.
- **O Verifier não conserta.** Gap vira task ranqueada para outro agente.
- Escrever `.specs/features/<spec>/validation.md` **incrementalmente em disco** (risco de
  limite) e commitá-lo.
- Espelhar o formato de `.specs/features/fundacao/validation.md`.

**Pontos que o Verifier de `calculo` precisa atacar:** os quatro números canônicos
(R$ 211 · ≈R$ 30/cabeça · R$ 271 · ≈R$ 45/adulto), os Testes A e B de RN-16 com **ordem** (e se
a guarda anti-ordenação em `casos_literais_do_arquivo_03_test.dart` discrimina mesmo), a
política de precisão de AD-009 (a armadilha `(1.15*10).round() == 11`), RN-14 (criança fora do
racha; os dois divisores coexistindo), `entraNoTotal` como dado declarado, a cerveja por
`adultos − abstêmios`, a pureza Dart puro, a fixture RN-30 e o barrel como porta única.

**Pontos para o de `design-system`:** os valores literais de §1 e §4 afirmados um a um, o
press-sink (translate 2,2 + sombra 4→2), o toast (1 por vez, 2200 ms, substitui sem empilhar),
as três guardas de varredura (se ainda mordem), a fronteira com `calculo` (DS-27 recebe a
fração pronta e não calcula), e as exceções de radius/blur.

### Pendências manuais (M) — não automatizáveis neste ambiente

- **DS-33** — a conferência visual "parece o protótipo?". Roteiro: `flutter run` e
  `flutter run -d chrome`, abrir `/catalogo`, conferir cada seção contra
  `.specs/init-spec/02-design-system.md`. **Testes verdes provam que cada token tem o valor
  literal da spec; não provam que o conjunto parece certo.**
- **FUND-17 AC4** (herdada da fundação) — a spec nomeia "handler global" mas a implementação
  registra pelo `try/catch` do boot. Diagnóstico em
  `.specs/features/fundacao/validation.md`. **Decisão do usuário, ainda pendente.**

### Decisões do usuário (2026-08-20 / 21)

1. Fontes **bundladas** em `assets/fonts/` (Archivo variável + Archivo Black + OFL), não o
   pacote `google_fonts`.
2. Catálogo de componentes como **rota interna `/catalogo`**, sem dependência nova.
3. **RN-10 leitura (a)**: R$ 271 manda; entram Carvão 22 + Gelo 30 + Sal 8 = 60; Copos & pratos
   aparece na lista e fica **fora** do total. O parêntese "(22+30+8+15)" do arquivo 03 está
   errado.
4. Execução **ponta a ponta**, sem checkpoint de aprovação entre fases.
5. Ao bater no limite de cota, retomar **5 minutos depois** do horário de reset,
   automaticamente.

### Monitoria de cota (montada em 2026-08-25, a pedido do usuário)

**A fonte certa é `~/.claude.json` → `cachedUsageUtilization`** — o mesmo dado que o `/usage`
do Claude Code mostra. Campos que interessam:
`utilization.five_hour.utilization` (% da sessão), `utilization.seven_day.utilization`
(% da semana), `five_hour.resets_at` e `fetchedAtMs`. O próprio Claude Code reescreve esse
cache enquanto a sessão está ativa.

- `scratchpad/monitor-cota.sh` lê esse cache a cada **5 min**.
- Silencioso por padrão; avisa ao cruzar **50/70/80%** e dispara `ALERTA-COTA-85` quando a
  sessão **ou** a semana passam de 85%.
- Dois guardas contra falso-verde: grita se não conseguir ler o cache 3× seguidas, e grita se
  o `fetchedAtMs` ficar parado por mais de 30 min — número velho repetido para sempre parece
  "tudo bem" e não é.
- Log em `scratchpad/cota.log`, último status em `cota-status.json`.
- **A monitoria é da sessão, não do repositório**: quem retomar precisa rearmá-la.

#### O alarme falso de 09:05 — não repetir

A primeira versão do monitor estimava a cota com **`ccusage`**, somando os tokens do bloco de
5h e dividindo pelo **maior bloco já visto no histórico local**. As duas pontas estavam
erradas:

1. `ccusage` soma `cacheReadInputTokens`, que cresce a cada turno porque o contexto inteiro é
   relido — o número infla rápido e não é o que a cota mede.
2. O denominador "maior bloco já observado" **satura em 100% por construção** assim que o
   bloco atual vira o maior. Foi o que aconteceu: o monitor gritou "100%" quando o `/usage`
   real marcava **18%**.

O trabalho chegou a ser pausado por causa disso. **`ccusage` não enxerga o limite da conta e
não serve para esta medida** — use `cachedUsageUtilization`.

### Estado da cota

Medido em 2026-08-25 11:10 BRT, pela fonte certa: **sessão em 18%**, **semana em 3%**.
Reset da janela de 5h: **2026-08-25 13:50 BRT** (16:50 UTC); reset semanal: 30/08 06:00 BRT.
Há folga larga — não há motivo para pausar.

### Pergunta aberta, sem bloquear

Premissa **A-16** de `calculo`: `progressoDeQuitacao` **sem nenhuma linha** devolve `1.0`
(barra cheia). Está implementado e testado assim, com doc comment registrando que `0.0` seria
defensável. A spec `custos` pode trocar em uma linha.

### Como retomar

```bash
export PATH="$PATH:/c/SDKs/flutter/bin"
git worktree list
cd /c/repos/lucari/bora-calculo && flutter test   # 425
cd /c/repos/lucari/bora-ds     && flutter test   # 386
# o que já fechou está em .specs/features/<spec>/tasks.md
# os 7 ADs esperando merge: .specs/features/ads-pendentes.md
```

### Histórico de interrupções — o que funcionou

A cota estourou **quatro vezes** em 2026-08-20/21. Em 2026-08-25 houve uma quinta pausa, mas
por **alarme falso** do monitor — ver "Monitoria de cota".
**Perda acumulada de trabalho: praticamente zero.** O que fez isso funcionar:

1. **Commit atômico ao fim de cada task**, antes de a próxima começar — limita a perda a uma
   task, sem depender de prever o limite.
2. **Conferir o portão antes de retomar.** O estado do trabalho meio-escrito varia: 3× estava
   íntegro e verde, 1× não compilava. E o handoff pode estar velho: desta vez as branches
   tinham avançado além do que ele dizia.
3. **Retomar por mensagem, nunca por agente novo** — o transcript preserva o contexto e custa
   muito menos que recomeçar frio.
4. **Não abrir task que não cabe no que resta de cota.** Melhor parar com o plano preciso do
   que deixar meia task no disco.
