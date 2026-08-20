# Fundação — Validation (iteração 2)

**Data**: 2026-08-20
**Spec**: `.specs/features/fundacao/spec.md` (FUND-01..FUND-20)
**Diff range**: `90a4fe8..HEAD` (HEAD = `9918b04`; 23 commits — 18 de task, 3 de status, 2 de correção)
**Verifier**: sub-agente independente (autor ≠ verificador), evidence-or-zero — re-derivado da spec, não herdado da iteração 1
**SDK**: Flutter 3.47.0 · Dart 3.13.0 (`/home/lucari/SDKs/flutter/bin/flutter`)

**Veredito**: ✅ **PASS**

A iteração 1 falhou por **um** mutante sobrevivente (`/roles/:festaId` sem sufixo)
mais 3 spec-precision gaps. Nesta iteração: o mutante **morre**, o gap de maior
carga (`dieta`/`bebe` da Duda) foi **resolvido na raiz**, e os dois restantes são
decisões conscientes e documentadas — uma cobertura declarada ausente por design,
outra escalada ao usuário. Sensor re-executado do zero: **10 mutações, 10 mortas,
0 sobreviveram**. Portão verde em 92 testes.

Não restou nenhum defeito atribuível ao executor. As 5 pendências **M** são
limites de ambiente (sem device, navegador ou CLI `firebase`), não lacunas de
trabalho.

---

## Task Completion

| Task | Status | Notas |
|---|---|---|
| T1–T18 | ✅ Done | Todos os critérios `[x]` em `tasks.md`, exceto os itens **M** |
| Correção 1 (`73234e8`) | ✅ Done | Fecha o mutante sobrevivente de FUND-09 |
| Correção 2 (`9918b04`) | ✅ Done | Fecha o spec-precision gap #1 (FUND-18/FUND-19) |
| T1 (M) | ⏸️ Pendente | `flutter run` mobile / `-d chrome` — sem device nem navegador |
| T13 (M) | ⏸️ Pendente | R-1: opções sintéticas `demo-bora` no SDK nativo — **não verificado** |
| T16 (M) | ⏸️ Pendente | URL sem `#` e título da aba no navegador real |
| T18 (M) | ⏸️ Pendente | Seguir o README do zero (exige device/navegador e CLI `firebase`) |

---

## Verificação independente das duas correções

Nenhuma das duas foi aceita pela alegação do commit. Ambas foram re-derivadas
com mutação própria.

### `73234e8` — cobre `/roles/:festaId` sem sufixo → **correção real**

O diff acrescenta 11 linhas a `test/core/routing/app_router_shell_test.dart`
(`:90-99`), nenhum arquivo de produção tocado, nenhuma asserção existente
removida.

```dart
// test/core/routing/app_router_shell_test.dart:90-99
group('FUND-09 — /roles/:festaId sem sufixo tem destino', () {
  testWidgets('cai na primeira aba da festa', (tester) async {
    await _abrir(tester, '/roles/$_festaId');
    _apenas('lista', outras: ['galera', 'convite', 'custos', 'home']);
    expect(tester.takeException(), isNull);
  });
});
```

Provado por **duas** mutações independentes, não uma:

- **M1** (a que sobreviveu na iteração 1) — neutralizar o `redirect` do nó
  redirect-only (`app_router.dart:77-79` → `(context, state) => null`): a suíte
  agora **falha**, e o único teste que falha é exatamente o novo. Antes desta
  correção a suíte passava 91/91 com a mesma mutação. **Mutante morto.**
- **M9** — trocar o destino do `redirect` de `Routes.lista` para `Routes.galera`:
  a suíte **falha**. Isso descarta a hipótese de que o novo teste fosse raso
  (afirmando só "não lança"): ele fixa **qual** é o destino, via
  `_apenas('lista', outras: [...])`, que exige o placeholder `lista` montado
  **e** os quatro irmãos ausentes (`app_router_shell_test.dart:20-33`).

### `9918b04` — não inventa dieta/bebida da Duda → **correção real, sem afrouxamento**

Esta é a mudança que merecia suspeita, porque trocar um valor concreto por `null`
numa asserção é a forma clássica de afrouxar um teste. Conferido no diff e por
mutação.

**O diff, linha a linha** (`git show 9918b04 --numstat`): 8+/2- na fixture,
3+/1- no teste. No arquivo de teste, a **única** linha removida foi:

```
-          ['viewer', 'tudo', false],
```

substituída por `['viewer', null, null],` mais 2 linhas de comentário. Nenhum
`expect` apagado, nenhum matcher trocado por um mais frouxo, nenhum teste
removido — a contagem subiu de 91 para 92, nunca caiu.

**A alegação central do commit** ("a asserção de primitivos de FUND-19 não foi
tocada; ausência de chave não introduz valor não-primitivo") foi verificada
empiricamente, não lida:

- **M2** — repor `'dieta': 'tudo', 'bebe': false` no mapa da Duda: a suíte
  **falha** em `FUND-18 … papel, dieta e bebida vêm das personas do arquivo 01 §7`.
  Logo a nova asserção `['viewer', null, null]` **discrimina**: ela proíbe
  ativamente o default fabricado, não apenas tolera a ausência.
- **M3** — introduzir um valor não-primitivo (`'avatar': {'cor': '#141414'}`) no
  mapa da Duda: a suíte **falha** em `FUND-19 … só contém primitivos`. A asserção
  de primitivos (`rn30_estado_inicial_test.dart:122-129`) continua **viva** sobre
  o mapa encurtado — a remoção das duas chaves não criou ponto cego.
- **M10** — declarar as chaves explicitamente como `'dieta': null, 'bebe': null`:
  a suíte **falha**, também em FUND-19. Isso fecha a última brecha teórica: como
  `mapa['chave']` devolve `null` tanto para chave ausente quanto para chave com
  valor nulo, o par FUND-18 + FUND-19 é o que torna "**ausente**" uma afirmação de
  verdade, e não uma ambiguidade.

**Conferência contra a fonte** (`01-produto-e-fluxos.md:66-70`): o arquivo dá
dieta e bebida para Rafa, Ana, Léo e Bia, e descreve a Duda **apenas** como
"**Duda** — só-vê (viewer), avatar `#141414`". A correção está certa quanto à
fonte: os dois campos realmente não existem na spec, e a fixture agora diz isso
em vez de inventar. Como RN-21 dimensiona a cerveja por quem bebe, o `false`
fabricado viraria número errado na spec 02 — a carga alegada é real.

---

## Spec-Anchored Acceptance Criteria

Os ACs tocados pelas correções (FUND-09, FUND-18, FUND-19) foram re-derivados do
zero. Os demais não foram refeitos, mas o portão verde em 92/92 confirma que
nenhum regrediu — e o sensor cobriu 7 deles por mutação.

### ACs re-derivados nesta iteração

| Critério | Resultado que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| **FUND-09 AC3** · rota inexistente → erro legível, nunca branco/exceção | destino de erro, sem exceção | `app_router_publico_test.dart:49` — `expect(find.byKey(RouteErrorPage.pageKey), findsOneWidget)`; `:51` — `expect(tester.takeException(), isNull)`; legibilidade em `route_error_page_test.dart:24` — `expect(find.text('PÁGINA NÃO ENCONTRADA'), findsOneWidget)` | ✅ PASS |
| **FUND-09 AC4** · `/c/` vazio ou malformado cai no mesmo destino | mesma página de erro | `app_router_publico_test.dart:57` (`/c/`), `:65` (`/c/@@@`) — `expect(find.byKey(RouteErrorPage.pageKey), findsOneWidget)`; forma em `invite_code_format_test.dart:15,19,23-25,29,33` | ✅ PASS |
| **FUND-09** · nó `/roles/:festaId` acrescentado pelo desvio (era o furo da it. 1) | URL alcançável tem destino afirmado, sem exceção | `app_router_shell_test.dart:96` — `_apenas('lista', outras: ['galera','convite','custos','home'])`; `:97` — `expect(tester.takeException(), isNull)` | ✅ PASS **(novo)** |
| **FUND-18 AC1** · fixture reproduz RN-30 exatamente | nome, data, hora, local, 4h, 5 pessoas (4+Duda), 4/2 na Home, 7 itens | `rn30_estado_inicial_test.dart:13-17` (`'CHURRAS DO RAFA 🔥'`, `'SÁB · 18 JUL'`, `'14H'`, `'Laje do Rafa — Vila Madalena'`, `4`); `:21-22` (`4`/`2`); `:27` (as 5 nomeadas); `:38` (os 4 confirmados); `:45-46` (Duda `viewer`/`pendente`); `:61` — `['viewer', null, null]`; `:77-85` (os 7 itens); `:94-99` (contadores **não** reconciliam, literal de RN-30) | ✅ PASS **(gap #1 resolvido)** |
| **FUND-19 AC2** · Dart puro e dados brutos | sem import proibido, só primitivos | `rn30_estado_inicial_test.dart:107` — `expect(importsProibidosEm(conteudo), isEmpty)`; `:122-129` — `expect(valor, anyOf(isA<String>(), isA<int>(), isA<bool>()))` para **todo** valor | ✅ PASS (asserção intacta, confirmada viva por M3 e M10) |

### ACs intactos — confirmados pelo portão, sem re-derivação

| História | ACs | Result |
|---|---|---|
| P1-1 | AC3 (`analyze` zero issues), AC4 (`test` ≥1, exit 0) | ✅ PASS · AC1/AC2 ⏸️ M |
| P1-2 | AC1–AC4 (árvore, espelho, isolamento de `core/calculo`) | ✅ PASS (4/4) |
| P1-3 | AC1, AC2, AC5a (título literal), AC6 (fronteira 900.0) | ✅ PASS · AC5b (URL sem `#`) ⏸️ M |
| P1-4 | AC1–AC5 (DI idempotente, reset, transição, erro de bloc, handler global) | ✅ PASS (5/5) |
| P1-5 | AC1 (ordem de boot), AC3 (release falha cedo), AC4 (degradação) | ✅ PASS · AC2 ⏸️ M por design |
| P1-6 | AC1, AC2 | ✅ PASS (2/2) |
| P1-7 | AC1 (README documenta os 5 itens) | ✅ PASS · AC2 ⏸️ M |

**Status**: **23/28 ACs** com prova automatizada ancorada na spec · **5 ⏸️ M**
(limite de ambiente ou ausência declarada) · **0 sem evidência localizada** ·
**0 falhando**.

---

## Spec-precision gaps — estado

| # | Onde | Estado na iteração 2 |
|---|---|---|
| 1 | FUND-18 — `dieta`/`bebe` da Duda | ✅ **RESOLVIDO** por `9918b04`. As chaves saíram da fixture; a asserção passou a exigir ausência, e M2/M3/M10 provam que a exigência discrimina. |
| 2 | FUND-16 AC2 — sem spy em `connectEmulators` | 🔁 **Reclassificado** de "gap" para **cobertura declarada ausente por design** (ver Adjudicação 3). Permanece sob **M**. |
| 3 | FUND-17 AC4 — "handler global" vs `try/catch` do `AppBootstrap` | ⏸️ **ABERTO — pendência de decisão do usuário** (ver Adjudicação 4). Código deliberadamente intocado. |

**Gaps abertos atribuíveis ao executor: nenhum.**

---

## Adjudicações do orquestrador — julgadas

### Adjudicação 3 — FUND-16 AC2 aceito como declarado → **CONCORDO, com ressalva de contabilidade**

**Base factual conferida.** `tasks.md:685` classifica T15 como
"**Adaptador fino de SDK externo**", `Tests: none`; `:690` registra a
justificativa: *"o único `Tests: none` de código (T15) é o que a matriz declara
como camada sem teste unitário — e a justificativa é estrutural, não deferimento:
a parte decidível daquele arquivo já foi extraída e testada em T7 e T8"*. E
`:504`/`:508` repetem no corpo da task. A alegação do orquestrador é fiel ao
artefato.

**Concordo, e a razão não é a autoridade da matriz — é que a matriz está certa.**
Verifiquei que a parte decidível foi mesmo extraída e mesmo testada, por mutação
própria: **M6** (`emulator_config.dart:20`, `isAndroid && !isWeb` → `isAndroid`)
morre em `emulator_config_test.dart`, e a iteração 1 já matara a resolução de
ambiente em `firebase_environment_test.dart`. O que resta em
`firebase_bootstrap.dart` depois dessa extração é chamada direta a singleton de
SDK, sem ramo de decisão — o tipo de código onde um spy testaria o mock, não o
sistema. Forçar o spy contrariaria a matriz aprovada e expandiria o escopo de
T15 sem comprar discriminação real.

**Ressalva (não é discordância):** "declarado sem teste por design" continua
sendo **ausência de prova para aquele AC**, e não prova de correção. O AC pede um
**estado** ("Auth e Firestore apontados para os emuladores"); os testes cobrem os
**insumos** desse estado. Por isso FUND-16 AC2 deve permanecer listado sob
**cobertura pendente (M)** e **não** pode ser promovido a `✅ Verified` sem a
checagem manual — que é exatamente onde este relatório o mantém. Registrado como
**cobertura declarada como ausente por design**, não como defeito.

### Adjudicação 4 — FUND-17 AC4 escalado ao usuário, código intocado → **CONCORDO, sem ressalva**

**Base factual conferida.** `tasks.md:477` de fato já prescrevia o mecanismo:
*"Apenas os passos de Firebase e emulador ficam sob `try/catch`; a exceção vai
para o `AppLogger` e o boot **continua** (FUND-17)"*. O executor seguiu um plano
aprovado; a divergência nasceu entre spec e tasks, antes da implementação.

**Concordo integralmente, e a razão é de princípio**: alinhar o texto do AC para
caber na implementação é mover a trave. Quem escreve a spec decide o que ela
pede; o executor e o verificador não. Escalar foi o movimento correto.

**Reforço técnico que o usuário deve ter em mãos ao decidir** — apurado por
leitura própria de `app_bootstrap.dart:34-54`: os dois caminhos **não competem,
se complementam**, e o AC pode estar em tensão com ele mesmo.

1. `installObservability()` roda em `:36`, **antes** do bloco `try` de `:42-47`.
   Os handlers globais estão armados desde antes do Firebase — então falha
   *pós-boot* (os singletons de Firebase são registrados **lazy** de propósito,
   `injector.dart:36-41`, para o erro aparecer em quem usa o serviço) cai sim no
   handler global.
2. Para a falha *durante* o boot, o `try/catch` não é atalho — é a única forma de
   cumprir a outra metade do próprio AC. Uma exceção `await`ada dentro de `run()`
   é erro tratado: ela não chega a `FlutterError.onError` nem a
   `PlatformDispatcher.onError` a menos que fique **não** tratada — e nesse caso o
   boot aborta, violando o "o app SHALL abrir mesmo assim" que o mesmo AC exige.

Ou seja: exigir literalmente "pelo handler global" na janela de boot exigiria
contrariar o resultado observável que o AC pede. Isso é defeito de redação da
spec, não de implementação — o que fortalece a opção "reescrever o AC" sobre
"mudar o código". **A decisão continua sendo do usuário**; o verificador só
entrega o diagnóstico. O resultado observável que a spec exige (app abre + erro
registrado com stack) está integralmente afirmado em
`app_bootstrap_test.dart:83-84, 96-98`.

---

## Discrimination Sensor

**Protocolo**: árvore rastreada limpa antes de cada mutação · editar → rodar →
`git checkout -- <arquivo>` **imediato** → próxima · `git status` conferido entre
todas e ao final. Nenhum commit. Nenhuma mutação deixada para trás.

| # | `file:line` | Mutação | Teste que reagiu | Killed? |
|---|---|---|---|---|
| **1** | `lib/core/routing/app_router.dart:77-79` | **`redirect` do nó `/roles/:festaId` → sempre `null`** — *a que sobreviveu na iteração 1* | `app_router_shell_test.dart:93` | ✅ **Killed** |
| 2 | `test/fixtures/rn30_estado_inicial.dart:74` | repõe `'dieta': 'tudo', 'bebe': false` na Duda | `rn30_estado_inicial_test.dart:49` | ✅ Killed |
| 3 | `test/fixtures/rn30_estado_inicial.dart:73` | insere valor não-primitivo `'avatar': {'cor': …}` | `rn30_estado_inicial_test.dart:115` | ✅ Killed |
| 4 | `lib/core/responsive/layout_mode.dart:15` | `width < kCompactBreakpoint` → `<=` | `layout_mode_test.dart:11` | ✅ Killed |
| 5 | `lib/core/routing/invite_code_format.dart:5` | `{1,64}` → `{1,65}` | `invite_code_format_test.dart:33` | ✅ Killed |
| 6 | `lib/core/firebase/emulator_config.dart:20` | `isAndroid && !isWeb` → `isAndroid` | `emulator_config_test.dart` (web em Android) | ✅ Killed |
| 7 | `lib/core/di/injector.dart:30` | remove a guarda `if (_configured) return;` | `injector_test.dart` (2 testes) | ✅ Killed |
| 8 | `lib/core/observability/app_bloc_observer.dart:32` | `transition.nextState` → `transition.currentState` | `app_bloc_observer_test.dart` (FUND-13) | ✅ Killed |
| 9 | `lib/core/routing/app_router.dart:78` | destino do `redirect`: `Routes.lista` → `Routes.galera` | `app_router_shell_test.dart:93` | ✅ Killed |
| 10 | `test/fixtures/rn30_estado_inicial.dart:74` | `'dieta': null, 'bebe': null` **explícitos** (chave presente, valor nulo) | `rn30_estado_inicial_test.dart:115` | ✅ Killed |

**Sensor depth**: P0-full (10 mutações, mínimo exigido 5)
**Result**: **10/10 killed — ✅ PASS**

Mutações 1, 2, 3, 9 e 10 foram desenhadas especificamente para atacar as duas
correções: 1 e 9 verificam que `73234e8` fecha o furo **e** fixa o destino
(não só a ausência de exceção); 2, 3 e 10 verificam que `9918b04` endureceu a
asserção em vez de afrouxá-la, cobrindo as três formas de reintroduzir o defeito
(valor fabricado, valor não-primitivo, nulo explícito).

**Estado da árvore após o sensor**: `git diff HEAD` vazio; `git status` mostra
apenas os 3 untracked esperados (`validation.md`, `LESSONS.md`, `lessons.json`).
Portão re-executado ao final: `flutter analyze` sem issues, `flutter test` 92/92.

---

## Edge Cases da spec

- [x] SDK Flutter fora do PATH → resolvido: `flutter --version` responde (3.47.0)
- [x] `/c/:codigo` com caractere inesperado ou tamanho absurdo responde sem lançar — `invite_code_format_test.dart:23-25,33`; `app_router_publico_test.dart:65-67` (M5 confirma a fronteira)
- [x] Janela exatamente a 900.0 px é **expandido**, sem oscilação — `layout_mode_test.dart:11` (M4 confirma)
- [x] `flutter test` passa sem nenhum emulador ativo — confirmado: 92/92 sem processo externo
- [x] Feature futura registra pelo container desta spec — `injector.dart:13` é o único `GetIt` (M7 confirma a idempotência)

---

## Code Quality

| Princípio | Status |
|---|---|
| Código mínimo, sem feature além do pedido | ✅ — as duas correções somam 11 linhas de teste e 6 de comentário; zero linha de produção |
| Sem abstração para uso único | ✅ |
| Sem "flexibilidade" desnecessária | ✅ |
| Só arquivos exigidos pelas tasks | ✅ — `73234e8` toca 1 arquivo, `9918b04` toca 2 |
| Não "melhorou" código alheio | ✅ |
| Segue os padrões declarados | ✅ — commits Conventional em PT-BR com `Refs: FUND-xx` no corpo, conforme CLAUDE.md |
| Spec-anchored outcome check | ✅ — 1 gap resolvido; 1 reclassificado por design; 1 escalado ao usuário |
| Cobertura por camada | ✅ — o nó `/roles/:festaId` acrescentado pelo desvio agora **tem** teste; a lacuna apontada na iteração 1 fechou |
| Todo teste mapeia a um AC / edge case | ✅ — o novo `group` cita `FUND-09` |
| Nenhum teste enfraquecido ou apagado | ✅ — verificado por `--numstat`: 1 linha de asserção substituída por uma **mais** exigente; contagem 91 → 92 |
| Guidelines do projeto seguidos | ✅ — `CLAUDE.md` |

---

## Gate Check

- **Comando (Build)**: `flutter analyze && flutter test`
- **`flutter analyze`**: `No issues found!` — exit 0
- **`flutter test`**: **92 passed, 0 failed, 0 skipped** — exit 0
- **Testes na iteração 1**: 91 · **agora**: 92 — **delta +1** (o teste de `73234e8`)
- **Testes pulados**: nenhum
- **Testes enfraquecidos/apagados**: **nenhum** — conferido no diff, não na alegação
- **Re-execução após as 10 mutações**: analyze limpo, 92/92 — o portão voltou ao verde
- **Árvore rastreada**: limpa antes, entre cada mutação e ao final

---

## Cobertura pendente (verificações M)

Nenhuma é falha do executor. O ambiente não tem device, emulador Android,
navegador nem o CLI `firebase`.

| AC | O que fica sem prova | Natureza | Roteiro |
|---|---|---|---|
| **FUND-01 AC1** | `flutter run` sobe em mobile | limite de ambiente | `README.md:163-178` |
| **FUND-01 AC2** | `flutter run -d chrome` sobe o mesmo app em web | limite de ambiente | `README.md:163-178` |
| **FUND-10 AC5 (metade)** | URL do navegador sem `#` | limite de ambiente | `README.md:180-188` |
| **FUND-16 AC2 (efeito)** | `connectEmulators` de fato apontando Auth/Firestore + **R-1** (SDK nativo aceitar `demo-bora`) | **ausência declarada por design** (matriz T15) + limite de ambiente | `README.md:168-178`, `tasks.md:504-508` |
| **FUND-20 AC2** | seguir o README do zero até o app rodando | limite de ambiente | `README.md` inteiro |

**R-1 continua NÃO VERIFICADO** e segue sendo a pendência de maior consequência:
se o SDK nativo recusar `demoFirebaseOptions` (`invalid GOOGLE_APP_ID`), FUND-16
não fecha em Android/iOS e a decisão emulator-first precisa ser revisitada pelo
dono do projeto.

Observação mantida da iteração 1: `lib/main.dart` não tem teste. A ordem dos
passos é imune a erro de composição (o `AppBootstrap` fixa a sequência e recebe
os passos por parâmetro nomeado), mas a chamada de `configureUrlStrategy()` antes
de `WidgetsFlutterBinding.ensureInitialized()` (`main.dart:17`) só é validável no
navegador — mesma pendência M de FUND-01 AC2 / FUND-10.

---

## Requirement Traceability Update

| Requirement | Status it. 1 | Status it. 2 |
|---|---|---|
| FUND-01 | ⏸️ Pendente (M) | ⏸️ Pendente (M) — sem device/navegador |
| FUND-02 | ✅ Verified | ✅ Verified |
| FUND-03 | ✅ Verified | ✅ Verified |
| FUND-04 | ✅ Verified | ✅ Verified |
| FUND-05 | ✅ Verified | ✅ Verified |
| FUND-06 | ✅ Verified | ✅ Verified |
| FUND-07 | ✅ Verified | ✅ Verified |
| FUND-08 | ✅ Verified | ✅ Verified |
| FUND-09 | ❌ Needs Fix | ✅ **Verified** — mutante morto por `app_router_shell_test.dart:93` |
| FUND-10 | ⚠️ Parcial | ⚠️ Parcial — título ✅; URL sem `#` pendente (M) |
| FUND-11 | ✅ Verified | ✅ Verified |
| FUND-12 | ✅ Verified | ✅ Verified |
| FUND-13 | ✅ Verified | ✅ Verified |
| FUND-14 | ✅ Verified | ✅ Verified |
| FUND-15 | ✅ Verified | ✅ Verified |
| FUND-16 | ⚠️ Parcial | ⚠️ Parcial — AC3 ✅; AC2 **ausência declarada por design** + R-1 (M) |
| FUND-17 | ✅ c/ nota | ✅ Verified — resultado observável afirmado; **mecanismo pendente de decisão do usuário** |
| FUND-18 | ⚠️ c/ gap | ✅ **Verified** — gap da Duda resolvido em `9918b04` |
| FUND-19 | ✅ Verified | ✅ Verified — asserção de primitivos confirmada viva (M3, M10) |
| FUND-20 | ⚠️ Parcial | ⚠️ Parcial — AC1 ✅; AC2 pendente (M) |

---

## Lições

A iteração 2 **não produziu sinal novo**: portão verde, 10/10 mutantes mortos,
nenhum AC falhando, nenhum `SPEC_DEVIATION` novo. Conforme
`references/lessons.md` ("A clean PASS with no signal → record nothing"),
**nenhuma lição nova foi registrada** — e nenhuma das 5 existentes foi duplicada.

Estado das 5 candidatas de `.specs/lessons.json` (script:
`.claude/skills/tlc-spec-driven/scripts/lessons.py`):

| ID | Escopo | O que a iteração 2 diz | Ação |
|---|---|---|---|
| L-001 | routing | **Confirmada na prática** — a correção seguiu a regra e matou o mutante | mantida candidate |
| L-002 | fixtures | **Confirmada na prática** — o default fabricado saiu da fixture | mantida candidate |
| L-003 | firebase | **Confirmada** — a ausência foi declarada e o AC ficou listado sob M, como a lição manda | mantida candidate |
| L-004 | observability | ⚠️ **Parcialmente refutada pela prática** — ver nota abaixo | mantida candidate, sinalizada |
| L-005 | routing | **Confirmada na prática** — o nó acrescentado pelo desvio ganhou teste | mantida candidate |

As cinco permanecem `candidate` por **mecânica do script, não por omissão**:
`recurrence = len(features)` (lessons.py:230-232) conta **features distintas**, e
`promote_threshold=2`. Como esta iteração é a mesma feature `fundacao`, nenhuma
pode ser promovida daqui — a promoção depende de a mesma lição reaparecer na
próxima spec. Re-adicioná-las seria ruído sem efeito.

**Nota sobre L-004** — *"Quando a implementação alcança o resultado do AC por
outro mecanismo que não o nomeado, alinhe o texto do AC em vez de deixar a
divergência só no design"*. A prática desta iteração contradiz o verbo: o
orquestrador **não** alinhou o texto do AC, e agiu certo — alinhar a spec ao
código é mover a trave, e a decisão é do dono da spec. A lição, como está
redigida, orientaria um agente futuro a fazer o que aqui foi (corretamente)
recusado. O script não expõe comando de reescrita (`add`/`penalize`/`prune`/
`list`/`status`) e `lessons.json` não pode ser editado à mão, então a correção
fica **registrada aqui para o mantenedor**: o texto deveria ler algo como
*"…escale a divergência ao dono da spec em vez de reescrever o AC para caber na
implementação"*. `penalize` não se aplica — vale para lição `confirmed` que
falhou ao ser aplicada, e L-004 é `candidate`.

---

## Summary

**Overall**: ✅ **Pronto** — o gap bloqueante da iteração 1 está fechado e provado fechado

**Spec-anchored check**: 23/28 ACs com prova automatizada batendo a spec · 5 sob
verificação **M** · **1 spec-precision gap aberto** (FUND-17 AC4, decisão do
usuário) · 0 sem evidência
**Sensor**: 10 mutações, **10 mortas, 0 sobreviveram** — inclusive a que
sobrevivia na iteração 1
**Gate**: 92 passed, 0 failed · `flutter analyze` sem issues

**O que mudou desde a iteração 1**: `/roles/:festaId` — a URL alcançável nascida
do `SPEC_DEVIATION` de rotas — passou a ter destino afirmado, e duas mutações
independentes provam que a asserção discrimina destino, não só ausência de
exceção. A fixture RN-30 parou de inventar `dieta` e `bebe` para a Duda: as
chaves saíram, a asserção passou a **exigir** ausência, e três mutações provam
que ela não foi afrouxada — inclusive a versão sutil (nulo explícito) que a
leitura do diff sozinha não pegaria.

**O que continua aberto, e de quem é**:
1. **FUND-17 AC4** — a spec nomeia "handler global"; a implementação registra
   pelo `try/catch` do boot. Diagnóstico entregue (os caminhos se complementam, e
   a leitura literal do AC colide com o próprio AC). **Decisão do usuário.**
2. **FUND-16 AC2 + R-1** — cobertura declarada ausente por design pela matriz;
   fecha na checagem manual. **Depende de ambiente.**
3. **4 verificações M** de mobile/web/README. **Dependem de ambiente.**

**Next steps**: com device/navegador e o CLI `firebase` disponíveis, rodar o
Checklist de verificação manual do `README.md:157-198` — prioridade para **R-1**,
a única pendência capaz de derrubar uma decisão de arquitetura. E fechar com o
usuário a redação de FUND-17 AC4.
