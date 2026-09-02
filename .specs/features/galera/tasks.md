# A galera — Tasks

## Execution Protocol (MANDATORY — do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user — do not proceed without it.**

---

**Spec**: `.specs/features/galera/spec.md` (GAL-01..GAL-28)
**Design**: `.specs/features/galera/design.md`
**Context**: `.specs/features/galera/context.md`
**Status**: Draft
**Baseline**: a suíte verde vigente no merge de `montar` — e de `lista`, se ela entrar antes (**≥ 1137 testes**, conferidos em `main` em 2026-08-28, com `flutter analyze` em zero issues). Nenhuma task pode reduzir esse número, enfraquecer teste existente ou apagar teste.

---

## ⛔ Pré-requisito bloqueante — leia antes de dar Execute

**Este `tasks.md` pode ser escrito e revisado agora; o Execute não pode começar antes de `montar` (spec 05) estar mergeada em `main`.** É o §1 do `design.md`, conferido de novo no disco: `lib/core/festas/` **não existe** e `lib/features/galera/` tem só o `PlaceholderPage`.

| O que falta | Onde nasce | Quem usa aqui |
|---|---|---|
| `lib/core/festas/` — `FestaEmEdicao`, `FestaEmEdicaoRepository`, barrel `festas.dart` | `montar` (**AD-029**) | **Toda** leitura e escrita desta tela — T3, T9, T10, T26 |
| `FestaRepositoryEmMemoria` implementando `FestaEmEdicaoRepository` | `montar` | A única impl da porta no M1/M2-pré-09 — T9, T10, T26 |
| `ResumoDeFesta.composicao` | `montar` | É o que faz a festa ser **um registro só** — a razão de GAL-09 e GAL-14 serem verdade — T8, T10 |
| `buildAppRouter` já recebendo a porta de edição | `montar` | A fiação da `GaleraPage` (E-2) — T26 |

**Dois arquivos de colisão com `lista` (spec 06), as duas em emenda aditiva:**

| Arquivo | `lista` acrescenta | esta spec acrescenta | Task daqui |
|---|---|---|---|
| `lib/core/festas/dominio/festa_em_edicao.dart` | `despesas` (E-c dela) | `convite` (E-1) | **T3** |
| `lib/core/calculo/dominio/composicao_da_festa.dart` | `noCarrinho` (E-b dela) | `copyWith` (E-3) | **T4** |

As emendas dos dois lados são **aditivas com default** — o conflito é textual, não semântico. Quem mergear depois rebaseia. Se possível, **`galera` executa depois de `lista`**; se executar antes, T4 nasce sabendo que `noCarrinho` vai chegar — é exatamente o campo que a ausência de `copyWith` apagaria em silêncio.

---

## Test Coverage Matrix

> Gerada do codebase, das diretrizes do projeto e da spec — confirmar antes do Execute.
> **Diretrizes encontradas**: `CLAUDE.md` §Testes (pirâmide completa: unit cobre toda `RN-xx`; cada critério de aceite de `UC-xx` vira widget test; `test/` espelha `lib/`; **teste sai do critério de aceite, nunca da implementação**) · `.specs/STATE.md` AD-005 (log afirmável por duplo), AD-007 (`layoutModeForWidth`), AD-014 (rota nova ⇒ teste que afirma o **destino**, não o widget montado), AD-021 (`mocktail` só para SDK de terceiro; porta de domínio usa duplo escrito à mão) · `analysis_options.yaml` (`flutter_lints ^6.0.0`) · `pubspec.yaml` (`flutter_test`, `mocktail`; **sem** `bloc_test` — bloc é testado com `flutter_test` puro, como `test/features/home/presentation/bloc/home_bloc_test.dart`).
> **Sem cobertura por percentual** em lugar nenhum do projeto: o alvo é AC-a-AC, e é ele que vale.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
|---|---|---|---|---|
| Domínio puro de `core/festas/dominio/**` (E-1) | unit | Todos os ramos; 1:1 com os AC; `==`/`hashCode` por valor afirmados nos **dois** sentidos (igual **e** diferente); default novo não quebra igualdade existente | `test/core/festas/dominio/*_test.dart` | `flutter test` |
| Domínio de `core/calculo/dominio/**` (E-3) | unit | `copyWith` preserva **todo** campo não informado e substitui o informado, inclusive por valor vazio; nenhum comportamento novo | `test/core/calculo/dominio/*_test.dart` | `flutter test` |
| Domínio da feature (`lib/features/galera/domain/**`) | unit | Todos os ramos; 1:1 com os AC; **Dart puro** — ausência de import de Flutter é parte da cobertura (GAL-19 AC7); onde há tabela, célula a célula escrita à mão, nunca laço sobre a própria tabela | `test/features/galera/domain/*_test.dart` | `flutter test` |
| Adaptador (`lib/features/galera/data/**`) | unit | Caminho feliz **e** caminho de falha; idempotência afirmada por **contagem de gravações**, não por "a tela não mudou"; o efeito a jusante (`CalculadoraDaFesta.calcular` sobre o registro) afirmado onde a spec o promete | `test/features/galera/data/*_test.dart` | `flutter test` |
| BLoC (`lib/features/galera/presentation/bloc/**`) | unit | Um teste por transição de estado; 1:1 com os AC; preservação de estado, idempotência e falha inclusas | `test/features/galera/presentation/bloc/*_test.dart` | `flutter test` |
| Widget de tela (`lib/features/galera/presentation/{pages,widgets}/**`) | widget | Cada AC de UC-11/UC-12/UC-13 observável na árvore, nas **duas** viewports (390×820 e 1180×800); ausência afirmada com `findsNothing`, nunca por omissão de asserção | `test/features/galera/presentation/{pages,widgets}/*_test.dart` | `flutter test` |
| Copy (`galera_textos.dart`) | unit | Todo literal de T-05/RN-21/RN-23/RN-29 afirmado; comparado com o **token/constante**, nunca com o literal duplicado *(L-008)* | `test/features/galera/presentation/*_test.dart` | `flutter test` |
| Rota (`lib/core/routing/app_router.dart`) | widget (rota) | Destino afirmado por `rotaAtual()`, **não** pelo widget montado (AD-014) | `test/core/routing/*_test.dart` | `flutter test` |
| Fronteira / varredura (guards) | unit (varredura de arquivo) | A violação quebra a suíte **nomeando o arquivo infrator**; **cada regra tem teste contra trecho sintético infrator** — varredura verde contra código limpo não prova que morde | `test/features/galera/architecture/*_test.dart` | `flutter test` |
| Fixture (`test/fixtures/**`) | unit | Todo campo novo afirmado contra o literal da spec-fonte; **nenhuma** asserção existente editada | `test/fixtures/*_test.dart` | `flutter test` |
| Documentação / spec (`.specs/**`) | none | — (sem gate de teste) | — | — |

**Alvo explícito de qualidade desta feature** (`design.md` §11): **defesa escrita é defesa exercitada.** A recusa do alvo anfitrião, a chave que sumiu do registro, a idempotência das quatro escritas, o `null` de `observarFesta`, a falha da área de transferência e a ausência dos controles no não-anfitrião — **cada uma** precisa de um teste que **falha se a defesa sair**. Foi o padrão que o sensor do Verifier da spec 04 pegou três vezes; aqui é item de checklist, não boa intenção.

## Gate Check Commands

> Descobertas do repositório (`pubspec.yaml`, `analysis_options.yaml`, `CLAUDE.md`) — **não há CI**, tudo roda local.

| Gate Level | When to Use | Command |
|---|---|---|
| **Quick** | Depois de task com teste unit/bloc só | `flutter test test/<caminho do arquivo de teste da task>` |
| **Full** | Depois de task com teste de widget ou de rota | `flutter test test/features/galera test/core/routing` |
| **Build** | Fim de fase, e em **toda** task que toca `lib/core/**` | `flutter analyze && flutter test` |

**Regra de ouro herdada da spec 04 e repetida por `montar` e `lista`: confira o exit code do `flutter test` explicitamente.** `flutter test | tail` engole o código de saída, e isso já produziu um commit com o gate vermelho neste projeto. Use `flutter test; echo "exit=$?"` ou equivalente.

**Cota:** rodar `python .claude/scripts/cota.py` ao fim de cada task e em toda fronteira de fase (combinado ativo do projeto).

---

## Execution Plan

Fases ordenadas, executadas em sequência; tasks dentro de uma fase executam em ordem.

### Phase 1: O dado do acesso e a regra de RN-22 (7 tasks)

`core/festas`, a emenda em `core/calculo` e o domínio puro da feature. Nenhuma linha de UI; nada do que nasce aqui importa Flutter. Toda task que toca `lib/core/**` roda gate **build**.

```
T1 → T2 → T3 → T4 → T5 → T6 → T7
```

### Phase 2: A porta, o adaptador e a área de transferência (5 tasks)

O registro único vira leitura, e as quatro escritas com intenção. É onde GAL-14 e GAL-09 deixam de ser promessa.

```
T8 → T9 → T10 → T11 → T12
```

### Phase 3: O `GaleraBloc` (4 tasks)

Um bloc só, acima do `ResponsiveBuilder`. Não navega, não calcula.

```
T13 → T14 → T15 → T16
```

### Phase 4: A copy e os widgets de T-05 (6 tasks)

```
T17 → T18 → T19 → T20 → T21 → T22
```

### Phase 5: As duas telas, a rota e os guards (5 tasks)

```
T23 → T24 → T25 → T26 → T27
```

**Empacotamento previsto para o Execute** (~7 tasks por worker, fases inteiras, nunca partidas):

| Batch | Fases | Tasks |
|---|---|---|
| 1 | Phase 1 | T1–T7 (7) |
| 2 | Phase 2 | T8–T12 (5) |
| 3 | Phase 3 | T13–T16 (4) |
| 4 | Phase 4 | T17–T22 (6) |
| 5 | Phase 5 | T23–T27 (5) |

Batches rodam **em sequência** — nenhum começa antes de o anterior reportar todas as tasks completas. Ao fim do último, o **Verifier** roda automaticamente (autor ≠ verificador, evidence-or-zero).

> **Nota de cota** (lição registrada em 2026-08-25): worker é sequencial, não fan-out. Cinco workers Opus **em paralelo** estouram a janela de 5h; cinco em sequência, com commit atômico por task, não.

---

## Task Breakdown

### T1: Registrar a AD-031 no `STATE.md`

**What**: Acrescentar a decisão **AD-031** (o dado do acesso — `codigo`, `NivelDoLink` — em `core/festas/`; a regra RN-22 × RN-23 em `features/galera/domain/permissoes.dart`, consultável e nunca reimplementada) à seção `## Decisions` do `.specs/STATE.md`, com o texto que o `design.md` §12 já redigiu.
**Where**: `.specs/STATE.md` (só a seção `## Decisions`, ao fim)
**Depends on**: None
**Reuses**: O formato das AD-023..AD-028 (Decision / Reason / Trade-off / Scope / Date / Status) e a reserva de numeração de `.specs/STATE.md` §"Reserva de numeração — AD-029..AD-036"
**Requirement**: pré-condição estrutural de GAL-19, GAL-20, GAL-21

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `AD-031` existe com os seis campos, `Status: active`, com o texto de `design.md` §12
- [x] **A numeração é conferida no momento de gravar**: a reserva dá AD-029 a `montar` e AD-030 a `lista`; se alguma delas ainda não gravou a sua, renumera-se **aqui**, nunca lá — e a linha correspondente da reserva sai
- [x] Nenhuma AD existente é editada (nada vira `superseded`)
- [x] Nenhum arquivo de código é tocado

**Tests**: none (camada "Documentação / spec")
**Gate**: none
**Commit**: `docs(galera): registra a AD-031 do modelo de acesso`

---

### T2: `NivelDoLink` — o enum de RN-23 e as duas resoluções

**What**: `enum NivelDoLink { soVer, editarLista, coAnfitriao }` com `chave`, `porChave`, `resolver` (ausente/desconhecido ⇒ `soVer`) e `padraoDeFestaNova` (`editarLista`).
**Where**: `lib/core/festas/dominio/nivel_do_link.dart` (novo) · `lib/core/festas/festas.dart` (export)
**Depends on**: T1
**Reuses**: A forma de `Dieta.porChave` e `PapelNaFesta.porChave` em `core/calculo/dominio/` — `null` para chave desconhecida, quem converte decide
**Requirement**: GAL-21 (AC6, AC7 da história P1-6)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Os três valores existem com as chaves de serialização do `design.md` §6.1, e **nenhuma** delas é derivada de `name` — chave é contrato de dado, `name` é detalhe de linguagem
- [x] `porChave` devolve o valor para cada uma das três chaves e `null` para chave desconhecida
- [x] `resolver(null)` e `resolver('qualquer-coisa')` devolvem **`soVer`** — os dois casos com teste próprio (A-12, menor privilégio)
- [x] `resolver` das três chaves válidas devolve o nível correspondente
- [x] `padraoDeFestaNova` é **`editarLista`**, e um teste afirma que ele **difere** de `resolver(null)` — o par que discrimina as duas situações que a A-12 separou de propósito
- [x] Nenhum import de Flutter no arquivo
- [x] Gate `build` passa; exit code conferido
- [x] ≥ 8 testes novos (10). **Desvio declarado**: `test/core/festas/dominio/festa_em_edicao_repository_test.dart` afirma a contagem de arquivos de `dominio/` (`hasLength(2)`); o arquivo novo a torna 3. Só o número mudou — a asserção que discrimina (`exportados == arquivosDeDominio`) segue exata

**Tests**: unit
**Gate**: build
**Commit**: `feat(festas): dá à festa os três níveis de link de RN-23`

---

### T3: E-1 — `ConviteDaFesta` e o campo `convite` na festa

**What**: `class ConviteDaFesta { String codigo; NivelDoLink nivel }` com `vazio`, `copyWith`, `==`/`hashCode`; e `FestaEmEdicao` ganhando `final ConviteDaFesta convite` com default `ConviteDaFesta.vazio`, dentro de `==`/`hashCode` e de `copyWith`.
**Where**: `lib/core/festas/dominio/convite_da_festa.dart` (novo) · `lib/core/festas/dominio/festa_em_edicao.dart` (modifica) · `lib/core/festas/festas.dart` (export)
**Depends on**: T2
**Reuses**: `NivelDoLink` (T2); a forma de igualdade profunda à mão que `ComposicaoDaFesta` e `HomeState` já usam (A-19 de `calculo`)
**Requirement**: pré-condição de GAL-01, GAL-04, GAL-21

**Tests**: unit
**Gate**: build

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `ConviteDaFesta.vazio` tem `codigo` vazio e `nivel == NivelDoLink.padraoDeFestaNova`
- [x] Igualdade profunda afirmada nos **dois** sentidos: dois convites de mesmo código e nível são `==`; trocar **só** o código separa; trocar **só** o nível separa; `hashCode` acompanha nos três casos
- [x] `copyWith` preserva o campo não informado e substitui o informado — inclusive `codigo: ''`
- [x] O campo `convite` de `FestaEmEdicao` tem default — **nenhum** call site existente quebra e **nenhum** teste existente é editado
- [x] Duas `FestaEmEdicao` idênticas exceto pelo `convite` são **diferentes** — sem isso a emissão do stream após `definirNivelDoLink` seria engolida como eco
- [x] `copyWith` de `FestaEmEdicao` preserva o `convite` não informado
- [x] **Este é arquivo de colisão com `lista` (E-c dela)**: a emenda é aditiva e o doc do arquivo registra as duas
- [x] Gate `build` passa; exit code conferido
- [x] ≥ 10 testes novos (13). **Desvio declarado**: a contagem de arquivos de `dominio/` no teste do barrel vai a 4 — só o número; a asserção que discrimina segue exata

**Commit**: `feat(festas): põe o convite (código e nível) no registro da festa`

---

### T4: E-3 — `copyWith` na `ComposicaoDaFesta`

**What**: Um `copyWith` em `ComposicaoDaFesta` cobrindo **todos** os campos existentes, para que a escrita da Galera troque `pessoas` sem remontar a composição campo a campo.
**Where**: `lib/core/calculo/dominio/composicao_da_festa.dart` (modifica)
**Depends on**: T3
**Reuses**: A forma de `copyWith` que `Festa` e `Pessoa` já têm em `core/calculo/dominio/`
**Requirement**: GAL-15 (AC12 — o override sobrevive), pré-condição de GAL-11, GAL-12, GAL-17

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `copyWith` aceita **todos** os campos da composição e preserva os não informados — um teste por campo, não um teste que troca tudo de uma vez *(cinco testes novos; `noCarrinho` já tem os seus em `composicao_da_festa_test.dart:170-199`, escritos pela spec 06, e não é reescrito)*
- [x] `overrides` sobrevive a `copyWith(pessoas: ...)`: composição com override, troca de `pessoas`, override **idêntico** depois — é o AC12 de GAL-15 na camada onde ele é verdade
- [x] Substituir um campo por valor **vazio** (`{}` / `[]`) funciona e não é confundido com "não informado"
- [x] Um teste afirma que a composição devolvida é `==` à original quando `copyWith()` é chamado **sem argumento nenhum**
- [x] Nenhuma aritmética, nenhum campo novo, nenhuma regra — a emenda é estrutural (a proibição da `spec.md` é sobre fórmula de RN-xx)
- [x] O doc do arquivo registra que este método é a defesa contra apagar em silêncio campo que outra spec acrescentar (`noCarrinho` de `lista`)
- [x] **Arquivo de colisão com `lista` (E-b dela)** — a emenda é aditiva
- [x] Gate `build` passa; exit code conferido
- [x] Nenhum teste existente editado; ≥ 6 testes novos (10). **Nota de execução**: o `copyWith` em si já tinha chegado com a E-b da spec 06 (`70ded5a`), cobrindo os seis campos; esta task acrescenta o doc da defesa, o SPEC_DEVIATION de E-3 e a cobertura que a Done-when exige

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): dá copyWith à composição da festa`

---

### T5: `permissoes.dart` — RN-22 como tabela consultável

**What**: `enum Capacidade` (as oito de RN-22), o mapa `const` privado da tabela, `capacidadesDe(PapelNaFesta)`, `pode(papel, capacidade)`, `papelDoNivel(NivelDoLink)` e `papelDoUsuario(List<Pessoa>)` — Dart puro, sem import de Flutter.
**Where**: `lib/features/galera/domain/permissoes.dart` (novo)
**Depends on**: T4
**Reuses**: `PapelNaFesta` de `core/calculo/dominio/` (que declara por escrito que a tabela é domínio de `galera`); `NivelDoLink` (T2)
**Requirement**: GAL-19, GAL-20, base de GAL-27

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] As oito capacidades existem com os nomes do `design.md` §6.3
- [x] **As 32 células de RN-22 são afirmadas uma a uma, com valores escritos à mão** — 4 papéis × 8 capacidades, `pode(...)` esperado `true`/`false` em cada. **Nunca** um laço sobre o mapa, que compararia a tabela consigo mesma e passaria com ela inteira errada
- [x] ANFITRIÃO tem as oito; CO-ANFITRIÃO tem seis e **não** tem `gerenciarPapeis` nem `configurarNivelDoLink` (A-19); CONVIDADO tem quatro; SÓ VÊ tem duas
- [x] `capacidadesDe` devolve conjunto **imutável** — tentar mutá-lo lança, e há teste que prova
- [x] `papelDoNivel`: `soVer → soVe`, `editarLista → convidado`, `coAnfitriao → coAnfitriao` — os três com teste próprio (GAL-20 AC5)
- [x] `papelDoUsuario` devolve o papel de quem está marcado `voce`; **sem ninguém marcado devolve `anfitriao`** — premissa P-1 do `design.md` §14, declarada no doc da função
- [x] **Zero import de Flutter** no arquivo (GAL-19 AC7) — afirmado aqui por inspeção e por varredura em T27
- [x] Gate `quick` passa; exit code conferido (suíte inteira também: 2014 verdes)
- [x] ≥ 38 testes novos — **46**: as 32 células + 6 de tamanho/imutabilidade/exclusivas + 4 de `papelDoNivel` + 3 de `papelDoUsuario` + 1 de pureza

**Tests**: unit
**Gate**: quick
**Commit**: `feat(galera): traz RN-22 como tabela de permissões consultável`

---

### T6: `ChaveDePessoa` — o endereço estável da linha

**What**: `class ChaveDePessoa { String nome; int ocorrencia }` com `==`/`hashCode`, `ChaveDePessoa.de(List<Pessoa>)` e `ChaveDePessoa.indiceEm(List<Pessoa>, ChaveDePessoa)`.
**Where**: `lib/features/galera/domain/chave_de_pessoa.dart` (novo)
**Depends on**: T5
**Reuses**: `Pessoa` de `core/calculo/dominio/` (identidade pelo nome, A-24 de `calculo`)
**Requirement**: base de GAL-10, GAL-26; e o Edge Case dos homônimos

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `de([Ana, Léo, Ana])` devolve `Ana#0`, `Léo#0`, `Ana#1`, **na ordem do repositório** (A-15)
- [x] Duas chaves de mesmo nome e ocorrência são `==`; mesmo nome com ocorrência diferente **não** são; `hashCode` acompanha
- [x] `indiceEm` devolve o índice certo para **cada uma** das duas Anas — o teste que discrimina "chave por nome" de "chave por nome + ocorrência"
- [x] `indiceEm` devolve `null` para chave que não existe mais na lista (a pessoa sumiu entre abrir o painel e escrever)
- [x] Acrescentar pessoa **ao fim** não muda a chave de ninguém — a única mutação que o produto produz (RSVP acrescenta; remover não é oferecido, A-04)
- [x] Nenhum import de Flutter
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 8 testes novos (11)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(galera): dá endereço estável a cada linha de pessoa`

---

### T7: A fixture de RN-30 ganha código e nível do link

**What**: Estender a fixture do estado inicial de RN-30 com `codigo: 'rafa18'` e o nível do link da festa, e a leitura tipada correspondente — sem tocar em nenhuma asserção existente.
**Where**: `test/fixtures/rn30_estado_inicial.dart` (modifica) · `test/fixtures/rn30_estado_inicial_tipado.dart` (modifica) · os `_test.dart` dos dois
**Depends on**: T6
**Reuses**: A forma da fixture tipada, que **deriva** do bruto e nunca copia literal (o doc do arquivo é explícito)
**Requirement**: GAL-01 AC2 (a URL literal `bora.app/c/rafa18`), A-03, A-12

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] O bruto ganha `codigo: 'rafa18'` — literal de RN-23/RN-26b — e o nível inicial da festa do Rafa
- [x] A leitura tipada **deriva** os dois do bruto; nenhum literal de RN-30 é redigitado no arquivo tipado
- [x] O nível da fixture é `NivelDoLink.padraoDeFestaNova` (`editarLista`) e há teste que o afirma **contra a constante**, não contra o literal *(L-008)*
- [x] As asserções existentes da fixture (inclusive "todo valor é primitivo" e a ausência de `dieta`/`bebe` na Duda) continuam **intocadas** e verdes — a prova de mutação que a fundação já pagou não é reescrita
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 4 testes novos (6), 0 editados — o diff da task é 74 inserções e 0 remoções

**Tests**: unit
**Gate**: quick
**Commit**: `test(fixtures): põe o código e o nível do link na festa de RN-30`

---

### T8: `GaleraDaFesta` e a porta `GaleraRepository`

**What**: O modelo de leitura `GaleraDaFesta { festaId, convite, composicao }` com `pessoas` e `confirmados` derivados, mais a porta abstrata com `observarGalera` e as quatro escritas com intenção.
**Where**: `lib/features/galera/domain/galera_da_festa.dart` (novo) · `lib/features/galera/domain/galera_repository.dart` (novo)
**Depends on**: T7
**Reuses**: `ComposicaoDaFesta`, `Pessoa`, `StatusDePresenca` de `core/calculo`; `ConviteDaFesta` (T3); `ChaveDePessoa` (T6); a forma da porta `FestaRepository` da spec 04
**Requirement**: GAL-09 (AC8, AC9), base de GAL-06

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `confirmados` conta **exatamente** as pessoas nomeadas com status confirmado; com a fixture RN-30 dá **4**
- [x] O par que discrimina: uma composição com uma pessoa `recusou` e outra `pendente` conta **só** as confirmadas — recusou aparece em `pessoas` e **não** em `confirmados` (Edge Case)
- [x] `pessoas` devolve a lista da composição **na ordem dela**, sem reordenar (A-15)
- [x] A porta declara `observarGalera(festaId) → Stream<GaleraDaFesta?>` e **exatamente** quatro escritas: `alterarDieta`, `alterarBebida`, `alterarPapel`, `definirNivelDoLink`
- [x] **Nenhum** método da porta toca `status` de pessoa nem contador algum — é a forma que torna GAL-09 AC9 afirmável, e o doc da porta diz isso
- [x] Nenhum import de Flutter em `domain/`
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 8 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(galera): modela a leitura da galera e a porta de escrita`

---

### T9: O adaptador — preferências, e o efeito delas na lista

**What**: `GaleraRepositorioSobreFestas` sobre `FestaEmEdicaoRepository`: `observarGalera` e as escritas `alterarDieta` / `alterarBebida`, cada uma lendo o registro **no instante da chamada**, comparando antes de gravar e escrevendo só `pessoas`.
**Where**: `lib/features/galera/data/galera_repositorio_sobre_festas.dart` (novo)
**Depends on**: T8
**Reuses**: `FestaEmEdicaoRepository` (AD-029); `ComposicaoDaFesta.copyWith` (T4); `ChaveDePessoa.indiceEm` (T6); `Pessoa.copyWith`; `FestaRepositoryEmMemoria` como duplo real nos testes
**Requirement**: GAL-11, GAL-12, GAL-14, metade de GAL-28

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `observarGalera` mapeia `FestaEmEdicao?` em `GaleraDaFesta?`, propagando o `convite` e a composição inteira; `null` continua `null`
- [x] `alterarDieta` troca a dieta **da pessoa endereçada pela chave** e de **nenhuma outra** — afirmado com duas homônimas na lista
- [x] `alterarBebida` idem para `bebe`
- [x] A escrita lê o registro por `observarFesta(id).first` **na hora** — um teste que altera o registro por fora entre a leitura da tela e a escrita prova que o valor novo **não** é sobrescrito
- [x] A escrita usa `copyWith` e **preserva `overrides`** — composição com override, `alterarDieta`, override idêntico depois (GAL-15 AC12 no ponto de escrita)
- [x] **GAL-14 afirmado a jusante, sobre o registro depois da escrita**, chamando `CalculadoraDaFesta.calcular`: (a) tornar alguém veggie faz aparecer "Legumes p/ grelha (kit veggie)" e desfazer faz sumir; (b) tirar o "sem porco" de todos traz a carne suína selecionada de volta, e pôr de novo a remove; (c) desmarcar a bebida de alguém **reduz** a cerveja, e o valor bate com o que `calcular` devolve — nunca com número copiado
- [x] **Idempotência (GAL-28)**: `alterarDieta` com a dieta já vigente e `alterarBebida` com o mesmo valor **não** chamam `salvarFesta` — afirmado por **contagem de gravações** num duplo que conta
- [x] Chave que não existe mais no registro ⇒ **nenhuma** gravação, nenhuma exceção
- [x] Nenhuma constante de RN-03/RN-05/RN-21 neste arquivo — a aritmética é toda de `core/calculo`
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 16 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(galera): escreve dieta e bebida no registro único da festa`

---

### T10: O adaptador — papel e nível do link, e o que eles não tocam

**What**: `alterarPapel` (com a recusa do alvo anfitrião) e `definirNivelDoLink` (que escreve **só** `convite.nivel`) no mesmo adaptador, mais a prova de que nenhuma das quatro escritas mexe em contador ou em papel alheio.
**Where**: `lib/features/galera/data/galera_repositorio_sobre_festas.dart` (modifica)
**Depends on**: T9
**Reuses**: O caminho *read-modify-write* de T9; `AppLogger` (AD-005) pelo duplo `RecordingAppLogger`; `ResumoDeFesta` da spec 04 para a asserção de GAL-09
**Requirement**: GAL-04, GAL-09 (AC8, AC9), GAL-17, GAL-18, metade de GAL-28

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `alterarPapel` troca o papel da pessoa endereçada; o papel de **todas** as outras permanece idêntico, item a item
- [x] **GAL-18**: `alterarPapel` cujo alvo tem papel corrente `anfitriao` **não grava** (contagem de gravações inalterada) e registra no logger; a festa continua com **exatamente 1** anfitrião depois
- [x] Nenhuma assinatura da porta permite atribuir `PapelNaFesta.anfitriao` — e há teste que tenta e prova que o registro não muda
- [x] **GAL-04**: `definirNivelDoLink` muda `convite.nivel` e deixa **toda** a lista de `pessoas` idêntica — comparação item a item, não "a lista ainda tem 5"
- [x] `definirNivelDoLink` **não** toca `codigo`
- [x] **GAL-09**: depois de cada uma das **quatro** escritas, `ResumoDeFesta.confirmados` da mesma festa continua inalterado **e igual** à contagem de confirmados de `GaleraDaFesta` — 4 com a fixture
- [x] **Idempotência (GAL-28)**: papel igual e nível igual ⇒ nenhuma gravação, por contagem
- [x] Falha de `salvarFesta` ⇒ log registrado, exceção não vaza para quem chamou
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 14 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(galera): escreve papel e nível sem retroagir sobre quem já entrou`

---

### T11: O guard de fonte única — a Galera lê o mesmo registro que a Home

**What**: A bateria de testes que fixa a propriedade estrutural do `design.md` §2.1: uma escrita da Galera é visível na Home e na calculadora sem sincronia nenhuma, porque o registro é um só.
**Where**: `test/features/galera/data/fonte_unica_test.dart` (novo)
**Depends on**: T10
**Reuses**: `FestaRepositoryEmMemoria` implementando as duas portas; `HomeBloc`/`ResumoDeFesta` da spec 04; `CalculadoraDaFesta`
**Requirement**: GAL-09, GAL-14 (a garantia, não a mecânica)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Um `FestaRepositoryEmMemoria` semeado pela fixture alimenta ao mesmo tempo a porta da Home e a da Galera, e o teste **não** cria segundo store
- [x] `alterarDieta` pela porta da Galera ⇒ a emissão seguinte de `observarFestas` (Home) carrega a composição nova — o par que discrimina de "dois registros paralelos"
- [x] A mesma escrita ⇒ `CalculadoraDaFesta.calcular` sobre o registro devolve a lista ajustada
- [x] Um teste **negativo declarado**: montar a Galera sobre um store próprio faz a asserção anterior falhar — a prova de que o teste morde (comentado no arquivo como o motivo de o desenho ser o B do §2.1, não executado como teste que falha)
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 6 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `test(galera): prova que Home, lista e galera leem o mesmo registro`

---

### T12: `AreaDeTransferencia` — porta e adaptador do sistema

**What**: A porta `AreaDeTransferencia { Future<void> copiar(String) }` em `domain/` e `AreaDeTransferenciaDoSistema` em `data/` sobre `Clipboard.setData` — o único arquivo da feature que importa `flutter/services.dart`.
**Where**: `lib/features/galera/domain/area_de_transferencia.dart` (novo) · `lib/features/galera/data/area_de_transferencia_do_sistema.dart` (novo)
**Depends on**: T11
**Reuses**: O padrão porta+adaptador de `AppLogger` (AD-005); `TestDefaultBinaryMessenger` para interceptar `SystemChannels.platform` no teste
**Requirement**: base de GAL-03 e GAL-05 (A-07)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] A porta é Dart puro, em `domain/`, sem import de Flutter
- [x] O adaptador é `const`-construível (chega à página por default, `design.md` §7.3)
- [x] Teste do adaptador intercepta o canal de plataforma e afirma que `Clipboard.setData` recebeu **exatamente** o texto passado
- [x] Falha do canal ⇒ a `Future` **completa com erro** (quem trata é o bloc, T16) — teste que prova, porque engolir o erro aqui apagaria GAL-05
- [x] Um duplo de teste (`AreaDeTransferenciaFalsa`) registra o que foi copiado e sabe falhar sob demanda — é o que T16 e T24 usam
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 6 testes novos

**Tests**: unit
**Gate**: full
**Commit**: `feat(galera): põe a área de transferência atrás de uma porta`

---

### T13: `GaleraState` e o `GaleraBloc` que assina o stream

**What**: O estado (`situacao`, `galera`, `aberta`, `copiasConcluidas`, com `==`/`hashCode` à mão) e o bloc que assina `observarGalera` **na construção**, tratando `GaleraRecebida`, `ObservacaoFalhou` e o `null` do stream.
**Where**: `lib/features/galera/presentation/bloc/galera_state.dart` · `galera_event.dart` · `galera_bloc.dart` (novos)
**Depends on**: T12
**Reuses**: `HomeBloc` — assinatura na construção, `_aoFalhar` com `AppLogger`, estado com igualdade à mão; `RecordingAppLogger`
**Requirement**: GAL-25, base de GAL-06

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] O bloc assina o stream **sem** evento de "carregar" — RN-28 chega sem a tela pedir
- [x] Estado inicial é `carregando`; emissão do repositório leva a `comFesta` com a galera dentro
- [x] Erro no stream ⇒ `situacao == falhou`, `logger.logError(name: 'galera')` registrado, e **o que já havia chegado continua no estado** (`copyWith`, como no `HomeBloc`)
- [x] `observarFesta` emitindo `null` (festa inexistente) ⇒ mesmo estado `falhou`, sem copy nova (`design.md` §14)
- [x] Igualdade de estado afirmada nos dois sentidos — dois estados iguais são `==`, trocar **qualquer** um dos quatro campos separa (sem isso, T14 e T22 reconstroem a tela a cada emissão)
- [x] `close()` cancela a assinatura — teste que prova que emissão depois do `close` não vira `add` em bloc fechado
- [x] O bloc **não navega** (AD-020) e não importa `go_router`
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 10 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(galera): assina a galera da festa num bloc só`

---

### T14: O bloc — um painel aberto por vez, por chave

**What**: `LinhaAlternada(chave)` (abre, e fecha se já era a aberta) e a preservação de `aberta` em `GaleraRecebida` — mantida se a chave ainda existe, descartada se sumiu.
**Where**: `lib/features/galera/presentation/bloc/galera_bloc.dart` (modifica) · `galera_event.dart` (modifica)
**Depends on**: T13
**Reuses**: `ChaveDePessoa` (T6); a intenção de `BoraExpandableGroup` ("1 aberta por vez"), sem usar o widget (`design.md` §2.3)
**Requirement**: GAL-10 (AC1), GAL-26

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `LinhaAlternada(A)` com nada aberto ⇒ `aberta == A`; em seguida `LinhaAlternada(B)` ⇒ `aberta == B` e A fechada — **um** aberto por vez
- [x] `LinhaAlternada(A)` com A já aberta ⇒ `aberta == null`
- [x] **GAL-26**: emissão nova do stream **com uma pessoa acrescentada antes** da aberta na lista ⇒ `aberta` continua sendo **a mesma pessoa** — o par que discrimina chave de índice
- [x] Emissão nova em que a pessoa aberta **sumiu** ⇒ `aberta == null`, sem exceção
- [x] Emissão nova ⇒ a linha aberta **não** é fechada e nenhum campo de edição em curso é derrubado (o estado não guarda rascunho: a asserção é que `aberta` sobrevive e a lista nova está no estado)
- [x] Duas homônimas: abrir a segunda Ana mantém aberta **a segunda**, não a primeira
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 8 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(galera): guarda o painel aberto pela chave da pessoa`

---

### T15: O bloc — as quatro escritas delegadas à porta

**What**: `DietaEscolhida`, `BebidaAlternada`, `PapelEscolhido` e `NivelEscolhido` chamando a porta, sem tocar no estado diretamente — a fonte da verdade continua sendo o stream.
**Where**: `lib/features/galera/presentation/bloc/galera_bloc.dart` (modifica) · `galera_event.dart` (modifica)
**Depends on**: T14
**Reuses**: A porta `GaleraRepository` (T8); um duplo escrito à mão que registra as chamadas (AD-021)
**Requirement**: GAL-04 (na UI), GAL-11, GAL-12, GAL-17, GAL-28 (no bloc)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Cada um dos quatro eventos chama **o método correspondente** da porta, com a chave e o valor certos — quatro testes, um por evento
- [x] O bloc **não** muta o estado por conta própria depois de escrever: a mudança só aparece quando o stream emite (teste que escreve e afirma o estado **inalterado** até a emissão)
- [x] Escolher a opção **já ativa** não chama a porta — a idempotência de GAL-28 tem guarda **nos dois lados**, bloc e adaptador
- [x] Escrita com `situacao != comFesta` (ainda carregando, ou falhou) não chama a porta
- [x] Falha da porta ⇒ `logger.logError` e o estado não muda; nenhuma copy de erro é inventada (`design.md` §10)
- [x] **Nenhuma aritmética** nova no bloc — só `efeitosDasPreferencias` e `resumoDasPreferencias` de `core/calculo`, chamados sem recomposição
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 12 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(galera): liga os quatro gestos da tela à porta de escrita`

---

### T16: O bloc — copiar o link e o contador que dispara o toast

**What**: `LinkCopiado` chamando `area.copiar(url)`; sucesso incrementa `copiasConcluidas`, falha registra no logger e **não** incrementa.
**Where**: `lib/features/galera/presentation/bloc/galera_bloc.dart` (modifica) · `galera_event.dart` (modifica)
**Depends on**: T15
**Reuses**: `AreaDeTransferencia` e o duplo falso (T12); `GaleraTextos.urlDoConvite` chega em T17 — aqui a URL é montada pela mesma função que T17 vai fixar, e o teste compara com ela (não com literal)
**Requirement**: GAL-03 (a mecânica), GAL-05

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `LinkCopiado` escreve na porta **a URL completa** da festa corrente; com a fixture, `bora.app/c/rafa18`
- [x] Sucesso ⇒ `copiasConcluidas` incrementa de 1
- [x] **Duas cópias seguidas ⇒ contador em 2** — o par que discrimina de um `bool copiou`, que perderia o segundo toast (`design.md` §8.2)
- [x] **GAL-05**: falha da área de transferência ⇒ contador **inalterado**, `logger.logError` registrado, estado sem campo de erro novo
- [x] `LinkCopiado` com festa sem código (`codigo` vazio) ⇒ não copia e não incrementa (`design.md` §14)
- [x] O evento é **o mesmo** para os dois botões da tela — não existe segundo evento de cópia (é o que impede GAL-03 AC6 e AC7 de divergirem)
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 8 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(galera): copia o link e conta as cópias para o toast`

---

### T17: `galera_textos.dart` — toda a copy num arquivo só

**What**: As constantes e as quatro funções de copy do `design.md` §9: `titulo`, `subtitulo(pessoas, confirmadas)`, `semPessoas`, `labelDoLink`, `urlDoConvite(codigo)`, `copiar`, `quemAbrirPode`, `niveis`, `notaDoNivel(nivel)`, `faixa(resumo)`, `secaoPessoas`, `badgeVoce`, `sublinhaDe(pessoa)`, `dietas`, as três seções do painel, `bebe`/`naoBebe`, `notaDoAnfitriao`, `convidarMaisGente`, `linkCopiado`, `falha`.
**Where**: `lib/features/galera/presentation/galera_textos.dart` (novo)
**Depends on**: T16
**Reuses**: `home_textos.dart` e `entrar_textos.dart` como forma; `BoraStatus.rotulo` para os rótulos de papel e `BoraToastTexts` para "LINK COPIADO 🔗" — **não** redigitados
**Requirement**: GAL-01, GAL-02, GAL-06, GAL-07 (a copy), GAL-13 (a moldura), GAL-24

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] **Todo** literal da tabela do `design.md` §9 afirmado, um teste por constante, contra o texto literal de T-05/RN-21/RN-23
- [x] As **três notas de RN-23** literais, caractere a caractere, uma por nível (GAL-02)
- [x] `urlDoConvite('rafa18') == 'bora.app/c/rafa18'`; a mesma função é a única fonte da URL exibida **e** da copiada (Edge Case do escape) — teste com código que exige escape afirma que as duas são a **mesma string**
- [x] `subtitulo`: singular e plural corretos nos dois termos; com a fixture dá **exatamente** `5 pessoas · 4 confirmadas`; com 1 e 1 dá `1 pessoa · 1 confirmada`; com 0 dá `nenhuma pessoa ainda` (A-08, A-10)
- [x] `sublinhaDe`: `{dieta} · bebe 🍺` e `{dieta} · não bebe 🚫`; dieta ausente ⇒ omite o termo; bebida ausente ⇒ omite o termo; **os dois ausentes ⇒ devolve `null`/vazio** (o caso da Duda, A-14)
- [x] Os rótulos de dieta são os de RN-21 com emoji (A-13): `🍖 Come de tudo`, `🥗 Veggie`, `🚫 Sem porco`
- [x] `linkCopiado` e os rótulos de papel vêm das constantes do design system — teste compara com **o token**, nunca com literal duplicado *(L-008)*
- [x] `faixa(resumo)` concatena `'💡 '` e **nada mais**; com resumo vazio devolve vazio
- [x] `falha` está documentado no arquivo como **SPEC_PRECISION_GAP** (`design.md` §14)
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 24 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(galera): fixa a copy literal de T-05, RN-21 e RN-23`

---

### T18: `CardDoLink` — o card escuro de sombra roxa

**What**: O widget do card do link: fundo `ink` com acento roxo, label amarela, URL sublinhada, "COPIAR 🔗", o label "QUEM ABRIR O LINK PODE…", o segmented dos três níveis e a nota dinâmica — com `podeConfigurarNivel` removendo o segmented da árvore.
**Where**: `lib/features/galera/presentation/widgets/card_do_link.dart` (novo)
**Depends on**: T17
**Reuses**: `BoraSurface`, `BoraSegmentedControl(sobreCardEscuro: true)`, `BoraSecondaryButton`, tokens de `BoraColors`/`BoraTextStyles`/`BoraSpacing`/`BoraAccent`; `GaleraTextos` (T17)
**Requirement**: GAL-01, GAL-02, GAL-27 (AC1)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Renderiza, na ordem de T-05: label "LINK PRA CONVIDAR", a URL, "COPIAR 🔗", "QUEM ABRIR O LINK PODE…", o segmented com **exatamente três** opções — `SÓ VER`, `EDITAR LISTA`, `CO-ANFITRIÃO`
- [x] O fundo é `BoraColors.ink` e o acento é o roxo — afirmado **contra o token**, não contra literal de cor
- [x] Com a fixture, a URL na tela é `bora.app/c/rafa18`
- [x] Percorrer os três níveis troca a nota para a de RN-23 correspondente — três asserções literais (GAL-02)
- [x] Tocar uma opção emite o evento de nível; tocar a **já ativa** não emite (GAL-28 na UI)
- [x] Trocar de nível **não** exibe toast algum
- [x] **GAL-27 AC1**: com `podeConfigurarNivel: false` o segmented some da árvore (`findsNothing`) e URL + "COPIAR 🔗" **continuam**; com `true` os três estão presentes — o par que discrimina
- [x] `codigo` vazio ⇒ card sem URL e "COPIAR 🔗" inerte, sem copy nova (`design.md` §14)
- [x] Nenhum literal de cor, fonte ou sombra no arquivo
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 14 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(galera): monta o card do link com os três níveis de RN-23`

---

### T19: `LinhaDePessoa` — avatar, badge, sublinha, tag e caret

**What**: O card-linha de uma pessoa, com o mapa `PapelNaFesta → BoraStatus` e o caret nos dois estados.
**Where**: `lib/features/galera/presentation/widgets/linha_de_pessoa.dart` (novo)
**Depends on**: T18
**Reuses**: `BoraAvatar`, `BoraStatusTag` + `BoraStatus`, as constantes `caretAberto`/`caretFechado` de `BoraExpandableRow` (`design.md` §2.3), `GaleraTextos.sublinhaDe`
**Requirement**: GAL-07, GAL-08, metade de GAL-10

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Renderiza avatar, nome, tag de papel e caret para toda pessoa
- [x] Badge "VOCÊ" presente **só** para quem é `voce`, ausente (`findsNothing`) para os demais — o par que discrimina (GAL-07 AC4)
- [x] A sublinha é a de `GaleraTextos.sublinhaDe`; a Duda (sem dieta e sem bebida) renderiza **sem** sublinha
- [x] **GAL-08**: cada um dos quatro papéis mapeia para o `BoraStatus` de §5 — ANFITRIÃO amarelo, CO-ANFITRIÃO roxo com texto branco, CONVIDADO branco, SÓ VÊ `wa-bubble`/`text-2`. Quatro asserções **contra o token do enum**, nunca contra literal de cor *(L-008)*
- [x] O caret usa a constante de `BoraExpandableRow` e difere entre aberto e fechado — teste nos dois estados
- [x] Tocar a linha emite a alternância; nada é decidido dentro do widget
- [x] Nome longo não estoura o layout (sem overflow no `tester.takeException()`), e duas homônimas renderizam como **duas** linhas distintas (Edge Case)
- [x] Nenhum literal de cor, fonte ou sombra
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 14 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(galera): desenha a linha de pessoa com papel e preferências`

---

### T20: `BotaoDeDieta` — o botão de ativo vermelho

**What**: O botão de restrição alimentar sobre `BoraSurface`, com o par de cores que `BoraStatus.paga` já fixou (`fundo: primary, texto: ink`) no estado ativo — a composição que nenhum componente do arquivo 02 entrega pronta.
**Where**: `lib/features/galera/presentation/widgets/botao_de_dieta.dart` (novo)
**Depends on**: T19
**Reuses**: `BoraSurface`, `BoraPressSink` (o afundar de 2px do arquivo 02), os tokens do par `primary`/`ink`
**Requirement**: metade de GAL-11 (a superfície do gesto)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Renderiza emoji + rótulo literal de RN-21 (A-13)
- [x] Estado ativo usa `fundo: primary, texto: ink`; inativo usa o par neutro — afirmado **contra os tokens**
- [x] O press afunda `translate(2px, 2px)` com a sombra caindo de 4px para 2px (arquivo 02 §CTA)
- [x] Tocar emite a escolha; tocar o **já ativo** não emite (GAL-28)
- [x] A geometria do `BoraSegmentedControl` **não** é replicada — são três botões numa linha, como T-05 desenha (`design.md` §5.3)
- [x] O doc do arquivo registra que uma variante `BoraSegmentedControl(acentoAtivo:)` é candidata ao design system numa spec futura, e por que não é feita aqui
- [x] Nenhum literal de cor, fonte ou sombra
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 8 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(galera): compõe o botão de restrição alimentar`

---

### T21: `PainelDaPessoa` — os três controles, e o ramo do anfitrião

**What**: O painel expandido: para o anfitrião, **só** a nota 👑; para os demais, "NÍVEL DE ACESSO" (condicionado a `podeGerenciarPapeis`), "RESTRIÇÃO ALIMENTAR" e "BEBIDA".
**Where**: `lib/features/galera/presentation/widgets/painel_da_pessoa.dart` (novo)
**Depends on**: T20
**Reuses**: `BoraSegmentedControl` (nível de acesso e bebida, ativo `ink`), `BotaoDeDieta` (T20), `BoraSurface` para o painel com `espessuraDaBordaDoPainel` de `BoraExpandableRow`
**Requirement**: GAL-11, GAL-12, GAL-16, GAL-17 (na UI), GAL-27 (AC2)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Painel de não-anfitrião tem as três seções **nesta ordem**: NÍVEL DE ACESSO, RESTRIÇÃO ALIMENTAR, BEBIDA (GAL-10 AC2)
- [x] "NÍVEL DE ACESSO" oferece exatamente `CONVIDADO`, `CO-ANFITRIÃO`, `SÓ VÊ` — **`ANFITRIÃO` não é oferecido em lugar nenhum** (GAL-18 na UI)
- [x] O ativo de "NÍVEL DE ACESSO" e o de "BEBIDA" são pretos (`ink`), afirmado contra o token
- [x] **GAL-16**: painel do anfitrião exibe a nota `👑 Anfitrião manda em tudo — acesso fixo.` **e as três seções estão ausentes da árvore** (`findsNothing`) — não desabilitadas. É o par que discrimina de "desabilitado"
- [x] O toggle "BEBIDA" alterna entre `BEBE 🍺` e `NÃO BEBE 🚫` e emite a alternância
- [x] Escolher dieta/bebida/papel emite o evento correspondente com a **chave** da pessoa
- [x] **GAL-27 AC2**: com `podeGerenciarPapeis: false`, "NÍVEL DE ACESSO" some da árvore e RESTRIÇÃO ALIMENTAR + BEBIDA **continuam**; com `true`, as três estão presentes
- [x] Nenhum literal de cor, fonte ou sombra
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 16 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(galera): abre o painel de acesso, dieta e bebida de cada pessoa`

---

### T22: `FaixaDePreferencias` — a faixa amarela de RN-21

**What**: A faixa `BoraSurface` amarela de borda 2px exibindo `'💡 ' + resumoDasPreferencias(...)`, ausente quando o resumo é vazio.
**Where**: `lib/features/galera/presentation/widgets/faixa_de_preferencias.dart` (novo)
**Depends on**: T21
**Reuses**: `resumoDasPreferencias` e `efeitosDasPreferencias` de `core/calculo/regras/preferencias.dart`; `BoraSurface` amarelo (**não** `BoraDashedNote`, `design.md` §5.3); `GaleraTextos.faixa`
**Requirement**: GAL-13

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Com a fixture RN-30 a faixa lê **exatamente** `💡 A lista já se ajusta às preferências: 1 veggie 🥗 · 1 sem porco 🚫 · 3 bebem 🍺`
- [x] O texto é comparado com **o retorno de `resumoDasPreferencias`**, não com literal reescrito — a asserção do literal existe uma vez, como caso da fixture (GAL-13 AC5, AC6)
- [x] Termo zerado é omitido — teste com só veggie, e teste com só bebem
- [x] **Nenhum termo maior que zero ⇒ a faixa não renderiza** (`findsNothing`, GAL-13 AC7)
- [x] Mudar a composição de preferências troca a string exibida — a faixa é derivada, nunca guardada
- [x] A borda é 2px e o fundo é o amarelo do token; nenhum literal de cor
- [x] A feature **não** recompõe a frase: um teste de varredura (fechado em T27) e a inspeção do arquivo garantem que só `'💡 '` é concatenado
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 8 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(galera): mostra a faixa de preferências que RN-21 devolve`

---

### T23: `GaleraCompacta` — T-05 inteira

**What**: O layout compacto: header com título e sub, card do link, faixa, seção "PESSOAS" com as linhas e o painel aberto, e a `BoraFooterBar` com "+ CONVIDAR MAIS GENTE 🔗".
**Where**: `lib/features/galera/presentation/widgets/galera_compacta.dart` (novo)
**Depends on**: T22
**Reuses**: `CardDoLink` (T18), `FaixaDePreferencias` (T22), `LinhaDePessoa` (T19), `PainelDaPessoa` (T21), `BoraFooterBar`, `BoraPrimaryButton(acento: purple, larguraTotal: true)`
**Requirement**: GAL-06, GAL-09 (AC9), GAL-10 (AC1), GAL-24, GAL-25 (o estado visível), GAL-03 (AC7 na UI)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Header exibe `A GALERA` e o sub derivado; com a fixture, `5 pessoas · 4 confirmadas` (GAL-06)
- [x] Uma linha por pessoa nomeada, **na ordem do repositório** — a ordem é afirmada, não só a contagem (A-15)
- [x] **Um** painel aberto por vez: abrir a segunda linha fecha a primeira (`findsNothing` no conteúdo da primeira)
- [x] **GAL-09 AC9**: a tela **não** exibe contagem de pendentes nem representação do pendente sem nome — asserção de ausência sobre o texto "pendente" e sobre qualquer sexta linha
- [x] **GAL-24 AC1**: festa só com o anfitrião ⇒ uma linha, sub `1 pessoa · 1 confirmada`, faixa com o que sobrar
- [x] **GAL-24 AC2**: festa sem pessoa nomeada ⇒ sub `nenhuma pessoa ainda`, seção PESSOAS sem linhas e **sem copy inventada**, faixa ausente, card do link e CTA presentes e funcionais
- [x] **GAL-25**: com o repositório em falha, a tela mostra o estado de falha (`GaleraTextos.falha`) — **nunca** tela branca — e o card do link continua presente
- [x] O CTA do rodapé emite **o mesmo evento** de cópia que "COPIAR 🔗" (GAL-03 AC7)
- [x] A seção rola no documento, sem altura fixa e sem scroll horizontal a 390px
- [x] Nenhum literal de cor, fonte ou sombra
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 16 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(galera): monta a tela T-05 no layout compacto`

---

### T24: `GaleraPage` — bloc, responsivo e o toast da cópia

**What**: A página: `BlocProvider` → `BlocBuilder` → `ResponsiveBuilder`, com `pageKey`, as dependências chegando pelo roteador e um `BlocListener` sobre `copiasConcluidas` que dispara `BoraToast.mostrar`.
**Where**: `lib/features/galera/presentation/pages/galera_page.dart` (substitui o `PlaceholderPage`)
**Depends on**: T23
**Reuses**: `HomePage` como forma (deps pelo roteador, `pageKey`, bloc acima do `ResponsiveBuilder`); `BoraToast` + `BoraToastTexts`; `AreaDeTransferenciaDoSistema` como default `const` (T12)
**Requirement**: GAL-03 (AC6, AC7), GAL-05, GAL-23 (AC5), GAL-25, GAL-27 (a fiação de `papelDoUsuario`)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `GaleraPage({required festaId, required galera, required logger, area = const AreaDeTransferenciaDoSistema()})` com `static const Key pageKey = Key('galera')` (AD-014)
- [ ] O bloc é criado **acima** do `ResponsiveBuilder` — teste que cruza 900px e afirma que o painel aberto e o nível selecionado **sobrevivem**, sem `pumpWidget` novo (GAL-23 AC3/AC5)
- [ ] **GAL-03 AC6**: tocar "COPIAR 🔗" grava a URL completa na porta de área de transferência **e** mostra o toast `LINK COPIADO 🔗`; a duração é a de `BoraToast` (2200 ms de RN-29), afirmada pelo componente, não redigitada
- [ ] **GAL-03 AC7**: tocar "+ CONVIDAR MAIS GENTE 🔗" produz **o mesmo** efeito — mesma URL na porta, mesmo toast
- [ ] Duas cópias seguidas ⇒ **um toast por vez**, o segundo substituindo o primeiro (RN-29, GAL-28)
- [ ] **GAL-05**: com a porta de área de transferência falhando, **nenhum** toast é exibido (`findsNothing`), a falha é registrada no logger e a URL continua visível na tela
- [ ] `podeConfigurarNivel` e `podeGerenciarPapeis` saem de `papelDoUsuario` + `pode(...)` de `permissoes.dart` — a página **não** decide permissão por conta própria
- [ ] **GAL-27 AC3**: montar duas vezes com o mesmo repositório, trocando só quem é `voce` (Rafa ⇒ presentes; Ana co-anfitriã ⇒ ausentes) — o par que discrimina
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 16 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(galera): põe a Galera de pé com bloc, responsivo e toast`

---

### T25: `GaleraExpandida` — W-04 em duas colunas

**What**: O layout expandido: coluna esquerda de **370px** com o card do link e o CTA logo abaixo, lista de pessoas com accordions à direita, **sem** rodapé fixo.
**Where**: `lib/features/galera/presentation/widgets/galera_expandida.dart` (novo) · `galera_page.dart` (liga o ramo expandido)
**Depends on**: T24
**Reuses**: Os mesmos `CardDoLink`, `FaixaDePreferencias`, `LinhaDePessoa`, `PainelDaPessoa` do compacto — copy duplicada em dois arquivos diverge no primeiro ajuste (`design.md` §7.5); `layoutModeForWidth` (AD-007)
**Requirement**: GAL-22, GAL-23

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] A 1180×800: duas colunas, a esquerda com **370px** medidos (`tester.getSize`), o card do link dentro dela
- [ ] **GAL-22 AC2**: o CTA "+ CONVIDAR MAIS GENTE 🔗" está na coluna **esquerda**, abaixo do card, e **não existe** `BoraFooterBar` na árvore (`findsNothing`, W-R2/A-17)
- [ ] A 390×820 o rodapé fixo **volta** e a coluna de 370px não existe — o par que discrimina
- [ ] **GAL-23 AC3**: cruzar de 1180 para 890 preserva o accordion aberto e o nível selecionado (mesma montagem, só resize)
- [ ] **GAL-23 AC4**: nenhum scroll horizontal em 1180, 900 e 390 — afirmado pela ausência de overflow e pelo `ScrollController` do eixo horizontal inexistente
- [ ] **GAL-23 AC5**: a mesma mudança feita no compacto aparece no expandido — mesmo bloc, mesma fonte (teste que altera e redimensiona)
- [ ] Todo elemento clicável tem estado de hover no expandido (GAL-22 AC6)
- [ ] Nenhum literal de cor, fonte ou sombra
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 12 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(galera): adapta a Galera para W-04 em duas colunas`

---

### T26: E-2 e E-4 — a fiação: injector, roteador e o teste de rota

**What**: Registrar `GaleraRepository` no injector sobre `getIt<FestaEmEdicaoRepository>()`, passar a porta a `buildAppRouter`, fazer o `builder` de `galera` ler `state.pathParameters['festaId']` e montar a `GaleraPage`, e dar a `abrirApp` o parâmetro opcional correspondente.
**Where**: `lib/core/di/injector.dart` (modifica) · `lib/core/routing/app_router.dart` (modifica) · `test/support/app_de_teste.dart` (modifica)
**Depends on**: T25
**Reuses**: O precedente de `HomePage(festas:, logger:)` (spec 04) e o parâmetro `festas:` que `abrirApp` já ganhou; `rotaAtual()` (AD-014)
**Requirement**: pré-condição de alcance de GAL-01..GAL-27; A-18 (alcançável sem barra de abas)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] O `builder` de `galera` deixa de montar `const GaleraPage()` e passa `festaId`, a porta e o logger
- [ ] Abrir `/roles/:festaId/galera` **direto** renderiza a tela — sem depender do `FestaTabsShell` revestido, que é da spec 06 (A-18)
- [ ] **AD-014**: o teste de rota afirma o **destino** por `rotaAtual()`, não pelo widget montado; e afirma `GaleraPage.pageKey` presente
- [ ] `festaId` diferente chega diferente à página — teste com dois ids que prova que o parâmetro não é ignorado (foi exatamente o mutante que sobreviveu na fundação, L-001)
- [ ] A rota continua atrás da guarda de sessão (AD-017): sem sessão, redireciona — teste que prova
- [ ] `abrirApp` ganha o parâmetro **opcional com default**; **nenhum** teste existente é editado
- [ ] O injector registra a porta como lazy singleton sobre a porta de edição, sem `dispose` próprio (o dono do ciclo de vida é a porta de leitura da Home, `design.md` §7.1)
- [ ] Gate `build` passa; exit code conferido
- [ ] ≥ 8 testes novos, 0 editados

**Tests**: widget (rota)
**Gate**: build
**Commit**: `feat(galera): liga a Galera à rota da festa e ao injector`

---

### T27: Os três guards de fronteira da feature

**What**: A varredura sobre `lib/features/galera/**` que impede (1) fórmula de RN-03/RN-05/RN-21 vazando para a feature, (2) literal de cor, fonte ou sombra, e (3) import de Flutter em `domain/`.
**Where**: `test/features/galera/architecture/galera_guards_test.dart` (novo)
**Depends on**: T26
**Reuses**: `test/architecture/calculo_isolation_test.dart` como molde (varredura que **nomeia o arquivo infrator**); os guards de pureza de token da spec 01
**Requirement**: GAL-15 (AC11), GAL-19 (AC7)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Guard 1 — depois de remover comentários e literais de string, nenhum arquivo de `lib/features/galera/**` contém as constantes de RN-03/RN-05 (`0.4`, `0.3`, `0.15`, `0.5` e as demais), `adultosQueBebem` reescrito, `max(0, adultos -`, nem `math.`
- [ ] Guard 2 — nenhum arquivo contém a frase `A lista já se ajusta às preferências` como **template com interpolação**; a frase inteira vem de `resumoDasPreferencias` (GAL-13 AC5)
- [ ] Guard 3 — nenhum literal de cor (`0xFF...`, `Color(`), fonte ou sombra fora dos tokens
- [ ] Guard 4 — nenhum arquivo de `lib/features/galera/domain/**` importa `package:flutter/` (GAL-19 AC7, a condição para a spec 09 traduzir a tabela em security rules)
- [ ] **Cada uma das quatro regras tem teste contra trecho sintético infrator** — varredura verde contra código limpo não prova que morde *(a lição que o sensor da spec 04 e o L-007 já cobraram)*
- [ ] A allowlist, se existir, libera **a forma exata**, nunca o arquivo inteiro *(L-007)*
- [ ] A comparação de caminho normaliza o separador — guard que compara path com barra normal fica verde no POSIX e vermelho no Windows *(L-006)*
- [ ] A falha nomeia o arquivo infrator na mensagem
- [ ] Gate `build` passa; exit code conferido
- [ ] ≥ 12 testes novos

**Tests**: unit (varredura)
**Gate**: build
**Commit**: `test(galera): guarda a fronteira de fórmula, token e Flutter`

---

## Phase Execution Map

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5

Phase 1:  T1 → T2 → T3 → T4 → T5 → T6 → T7
Phase 2:  T8 → T9 → T10 → T11 → T12
Phase 3:  T13 → T14 → T15 → T16
Phase 4:  T17 → T18 → T19 → T20 → T21 → T22
Phase 5:  T23 → T24 → T25 → T26 → T27
```

Execução estritamente sequencial — não há paralelismo dentro de fase. Um agente (ou worker de batch) trabalha uma task por vez, em ordem.

---

## Pre-Approval Check 1 — Granularidade

| Task | Escopo | Status |
|---|---|---|
| T1 | 1 seção de doc | ✅ Granular |
| T2 | 1 enum | ✅ Granular |
| T3 | 1 valor + 1 campo (mesmo assunto) | ✅ Coeso |
| T4 | 1 método | ✅ Granular |
| T5 | 1 arquivo de domínio puro (1 tabela + 4 funções do mesmo assunto) | ✅ Coeso |
| T6 | 1 classe | ✅ Granular |
| T7 | 1 fixture (bruto + tipado derivado) | ✅ Coeso |
| T8 | 1 modelo + 1 porta abstrata que o usa | ✅ Coeso |
| T9 | 1 adaptador, 2 escritas do mesmo assunto (preferências) | ✅ Coeso |
| T10 | mesmo adaptador, 2 escritas do mesmo assunto (acesso) | ✅ Coeso |
| T11 | 1 arquivo de teste de propriedade estrutural | ✅ Granular |
| T12 | 1 porta + 1 adaptador | ✅ Coeso |
| T13 | 1 bloc + 1 estado (assinatura e falha) | ✅ Coeso |
| T14 | 1 evento + a preservação que ele exige | ✅ Granular |
| T15 | 4 eventos de delegação idênticos em forma | ✅ Coeso |
| T16 | 1 evento + 1 campo de estado | ✅ Granular |
| T17 | 1 arquivo de copy | ✅ Granular |
| T18 | 1 widget | ✅ Granular |
| T19 | 1 widget | ✅ Granular |
| T20 | 1 widget | ✅ Granular |
| T21 | 1 widget | ✅ Granular |
| T22 | 1 widget | ✅ Granular |
| T23 | 1 widget de layout | ✅ Granular |
| T24 | 1 página | ✅ Granular |
| T25 | 1 widget de layout + o ramo que o liga | ✅ Coeso |
| T26 | 1 fiação (3 arquivos, uma mudança só) | ✅ Coeso |
| T27 | 1 arquivo de guard | ✅ Granular |

Nenhuma task cria dois componentes independentes. **0 ❌.**

## Pre-Approval Check 2 — Diagrama × definição

| Task | `Depends on` (corpo) | Diagrama | Status |
|---|---|---|---|
| T1 | None | — (raiz da Phase 1) | ✅ |
| T2 | T1 | T1 → T2 | ✅ |
| T3 | T2 | T2 → T3 | ✅ |
| T4 | T3 | T3 → T4 | ✅ |
| T5 | T4 | T4 → T5 | ✅ |
| T6 | T5 | T5 → T6 | ✅ |
| T7 | T6 | T6 → T7 | ✅ |
| T8 | T7 | T7 → T8 (fronteira P1→P2) | ✅ |
| T9 | T8 | T8 → T9 | ✅ |
| T10 | T9 | T9 → T10 | ✅ |
| T11 | T10 | T10 → T11 | ✅ |
| T12 | T11 | T11 → T12 | ✅ |
| T13 | T12 | T12 → T13 (fronteira P2→P3) | ✅ |
| T14 | T13 | T13 → T14 | ✅ |
| T15 | T14 | T14 → T15 | ✅ |
| T16 | T15 | T15 → T16 | ✅ |
| T17 | T16 | T16 → T17 (fronteira P3→P4) | ✅ |
| T18 | T17 | T17 → T18 | ✅ |
| T19 | T18 | T18 → T19 | ✅ |
| T20 | T19 | T19 → T20 | ✅ |
| T21 | T20 | T20 → T21 | ✅ |
| T22 | T21 | T21 → T22 | ✅ |
| T23 | T22 | T22 → T23 (fronteira P4→P5) | ✅ |
| T24 | T23 | T23 → T24 | ✅ |
| T25 | T24 | T24 → T25 | ✅ |
| T26 | T25 | T25 → T26 | ✅ |
| T27 | T26 | T26 → T27 | ✅ |

Nenhuma task depende de task em fase posterior. **0 ❌.**

## Pre-Approval Check 3 — Co-locação de teste

| Task | Camada criada/alterada | Matriz exige | Task diz | Status |
|---|---|---|---|---|
| T1 | Documentação / spec | none | none | ✅ |
| T2 | `core/festas/dominio` | unit | unit | ✅ |
| T3 | `core/festas/dominio` | unit | unit | ✅ |
| T4 | `core/calculo/dominio` | unit | unit | ✅ |
| T5 | domínio da feature | unit | unit | ✅ |
| T6 | domínio da feature | unit | unit | ✅ |
| T7 | fixture | unit | unit | ✅ |
| T8 | domínio da feature | unit | unit | ✅ |
| T9 | adaptador | unit | unit | ✅ |
| T10 | adaptador | unit | unit | ✅ |
| T11 | adaptador (propriedade) | unit | unit | ✅ |
| T12 | domínio + adaptador | unit | unit | ✅ |
| T13 | BLoC | unit | unit | ✅ |
| T14 | BLoC | unit | unit | ✅ |
| T15 | BLoC | unit | unit | ✅ |
| T16 | BLoC | unit | unit | ✅ |
| T17 | copy | unit | unit | ✅ |
| T18 | widget de tela | widget | widget | ✅ |
| T19 | widget de tela | widget | widget | ✅ |
| T20 | widget de tela | widget | widget | ✅ |
| T21 | widget de tela | widget | widget | ✅ |
| T22 | widget de tela | widget | widget | ✅ |
| T23 | widget de tela | widget | widget | ✅ |
| T24 | widget de tela | widget | widget | ✅ |
| T25 | widget de tela | widget | widget | ✅ |
| T26 | rota + suporte de teste | widget (rota) | widget (rota) | ✅ |
| T27 | guard | unit (varredura) | unit | ✅ |

Nenhuma task adia teste para outra. **0 ❌.**

---

## MCPs e Skills por task

Nenhuma task precisa de MCP: não há biblioteca externa nova (`context7` seria consulta sem pergunta) e todo o código sai da spec, do design e de padrões que já existem no repositório. As skills combinadas do projeto continuam valendo:

| Skill | Quando | Por quê |
|---|---|---|
| `tlc-spec-driven` | toda task | O Execute inteiro — protocolo obrigatório no topo deste arquivo |
| `cota` | fim de cada task e de cada fase | Combinado ativo do projeto |
| `code-review` | fim de cada batch | Combinado ativo |

**Confirme antes do Execute** se algum MCP deve entrar — a matriz acima é a resposta do agente, não uma pergunta pulada.

---

## Rastreabilidade — requisito → task

| Requisito | Task(s) |
|---|---|
| GAL-01 | T7, T17, T18 |
| GAL-02 | T17, T18 |
| GAL-03 | T16, T23, T24 |
| GAL-04 | T10, T15 |
| GAL-05 | T12, T16, T24 |
| GAL-06 | T17, T23 |
| GAL-07 | T17, T19 |
| GAL-08 | T19 |
| GAL-09 | T8, T10, T11, T23 |
| GAL-10 | T6, T14, T21, T23 |
| GAL-11 | T9, T15, T20, T21 |
| GAL-12 | T9, T15, T21 |
| GAL-13 | T17, T22 |
| GAL-14 | T9, T11 |
| GAL-15 | T4, T9, T27 |
| GAL-16 | T21 |
| GAL-17 | T10, T15, T21 |
| GAL-18 | T10, T21 |
| GAL-19 | T5, T27 |
| GAL-20 | T5 |
| GAL-21 | T2, T3 |
| GAL-22 | T25 |
| GAL-23 | T24, T25 |
| GAL-24 | T17, T23 |
| GAL-25 | T13, T23 |
| GAL-26 | T14 |
| GAL-27 | T18, T21, T24 |
| GAL-28 | T9, T10, T15, T18, T20 |

**Cobertura**: 28 de 28 requisitos com task dona. **0 órfãos**, **0 tasks sem requisito** (T1 é pré-condição estrutural declarada de GAL-19/20/21; T11 e T26 são pré-condições de alcance declaradas).

---

## Desvios e lacunas que o Execute tem de manter declarados

Vêm do `design.md` §14 e da `spec.md` §Divergências — **não podem ser silenciados** durante a implementação:

| Tipo | O quê | Task que o declara |
|---|---|---|
| SPEC_DEVIATION | Quatro emendas fora da fronteira original (E-1 `core/festas`, E-2 roteador, E-3 `composicao_da_festa`, E-4 `app_de_teste`) | T3, T4, T26 — no doc de cada arquivo tocado |
| SPEC_DEVIATION | A A-01 pediu porta com store próprio; o desenho a implementa **sem store**, como vista sobre o registro da festa (§2.1) | T9 — no doc do adaptador |
| SPEC_DEVIATION | Três acentos na tela contra os 2 do arquivo 02 §8 — roxo e amarelo estruturais, vermelho como estado ativo (D-2 / A-16) | T20, T23 |
| SPEC_DEVIATION | `BoraExpandableRow`/`Group` **não** são usados como widget, só as constantes (§2.3) | T19, T21 |
| SPEC_PRECISION_GAP | `GaleraTextos.falha` — nenhuma tela de `04`/`06` desenha a Galera falhando; a frase copia a voz de `HomeTextos.falha` | T17 |
| SPEC_PRECISION_GAP | Festa inexistente (`null` do stream) cai no mesmo estado `falhou`, sem copy própria | T13 |
| SPEC_PRECISION_GAP | `codigo` vazio: card sem URL, "COPIAR 🔗" inerte, sem copy nova — não há AC para o caso | T18 |
| Premissa declarada | **P-1**: `papelDoUsuario` sem ninguém marcado `voce` devolve `anfitriao` (§14) | T5 |
| Consequência aceita | A bebida **não volta** a "não declarado" depois do primeiro toque — toggle de dois estados, como T-05 desenha; muda a cerveja de RN-21 | T21 |
| Herdado, sem dono | O seletor "QUEM LEVA?" (AD-018) mora na `lista`; esta spec entrega só a matéria-prima (a lista de confirmados) | — |

---

## Success Criteria da feature (da `spec.md`, conferidos ao fim)

- [ ] `flutter analyze` zero issues · suíte verde · baseline do merge de `montar`/`lista` preservada, **+ ~280 testes novos**
- [ ] **Aceite de UC-11 verificável**: kit veggie quando há veggie, sem suína quando há "sem porco", cerveja dimensionada por quem bebe — afirmado sobre o registro, via `core/calculo`
- [ ] **Aceite de UC-12 verificável**: as 32 células de RN-22 célula a célula, e E1 com a nota 👑 e os três controles **ausentes**
- [ ] **Aceite de UC-13 verificável**: trocar o nível não retroage sobre o papel de ninguém, e os dois botões copiam o mesmo link com o mesmo toast
- [ ] Nenhuma fórmula de RN-03, RN-05 ou RN-21 em `lib/features/galera/` — varredura com trecho infrator provando que morde
- [ ] Nenhum literal de cor, fonte ou sombra em `lib/features/galera/**`
- [ ] `lib/features/galera/domain/` é Dart puro — sem import de Flutter, para a spec 09 traduzir RN-22 em security rules
- [ ] Trocar a impl de `GaleraRepository` por Firestore não exige mudar nenhum arquivo de `presentation/`
- [ ] Toda copy é literal de T-05 / RN-21 / RN-23 / RN-29, exceto os três defaults declarados (`nenhuma pessoa ainda`, o plural do sub, `GaleraTextos.falha`)
- [ ] AD-031 registrada no `STATE.md`, com a numeração conferida no momento de gravar
