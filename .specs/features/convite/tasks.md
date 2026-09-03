# O convite (mensagem, grupo e enquetes) — Tasks

## Execution Protocol (MANDATORY — do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user — do not proceed without it.**

---

**Spec**: `.specs/features/convite/spec.md` (CVT-01..CVT-37)
**Design**: `.specs/features/convite/design.md`
**Context**: `.specs/features/convite/context.md`
**Status**: Draft
**Baseline**: a `main` de 2026-09-03 — **2451 testes verdes** e `flutter analyze` em zero issues (conferido no merge de `galera`, `3ff81f5`). Nenhuma task pode reduzir esse número, enfraquecer teste existente ou apagar teste.

---

## ✅ O pré-requisito bloqueante de `design.md` §1 está satisfeito

O `design.md` foi escrito em 2026-08-28, quando `lib/core/festas/` não existia. **Reconferido no disco em 2026-09-03** — as três specs de que esta depende já estão mergeadas em `main`:

| O que `design.md` §1 exigia | Onde está hoje | Estado |
|---|---|---|
| `FestaEmEdicao`, `FestaEmEdicaoRepository`, barrel | `lib/core/festas/` (4 arquivos em `dominio/`) | ✅ existe |
| `FestaEmEdicao.convite` → `ConviteDaFesta.codigo` | `lib/core/festas/dominio/convite_da_festa.dart` | ✅ existe |
| `capacidadesDe` / `pode` / `papelDoUsuario` | `lib/features/galera/domain/permissoes.dart` | ✅ existe |
| `ComposicaoDaFesta.noCarrinho` (E-b de `lista`) | `composicao_da_festa.dart:26` | ✅ existe — a **E-3 desta spec convive**, aditiva, em linha diferente |
| `ComposicaoDaFesta.atribuicoes` → `ItemDeLista.quemLeva` | **não existe** | ⬜ **é a T2 desta spec** |

`lib/features/convite/` continua com o `ConvitePage` placeholder e três `.gitkeep`. **O Execute pode começar.**

---

## Test Coverage Matrix

> Gerada do codebase, das diretrizes do projeto e da spec — confirmar antes do Execute.
> **Diretrizes encontradas**: `CLAUDE.md` §Testes (pirâmide completa; unit cobre toda `RN-xx`; cada critério de aceite de `UC-xx` vira widget test; `test/` espelha `lib/`; **teste sai do critério de aceite, nunca da implementação**) · `CLAUDE.md` §Restrições ("nunca duplique uma fórmula em componente de UI") · `.specs/STATE.md` **AD-005** (log afirmável por duplo), **AD-014** (rota nova afirma o **destino**), **AD-021** (`mocktail` só sobre SDK de terceiro; porta de domínio usa duplo escrito à mão), **AD-016/AD-025/AD-026** · `analysis_options.yaml` (`flutter_lints ^6.0.0`) · `pubspec.yaml` (`flutter_test`, `mocktail`; **sem** `bloc_test` — bloc é testado com `flutter_test` puro, como `test/features/galera/presentation/bloc/galera_bloc_test.dart`).
> **Sem cobertura por percentual** em lugar nenhum do projeto: o alvo é AC-a-AC, e é ele que vale.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
|---|---|---|---|---|
| `core/festas/dominio/**` (E-2) | unit | Todos os ramos; 1:1 com os AC; `==`/`hashCode` afirmados nos **dois** sentidos (igual **e** diferente); `copyWith` preserva **todo** campo não informado — inclusive os de `lista` (`despesas`) e `galera` (`convite`) | `test/core/festas/dominio/*_test.dart` | `flutter test` |
| `core/calculo/dominio/**` + `regras/**` (E-3) | unit | O canal novo afirmado ponta a ponta (composição → `CalculadoraDaFesta` → `ItemDeLista.quemLeva`); **nenhuma fórmula muda**, e um teste afirma que os números canônicos de RN-13/RN-14 seguem iguais | `test/core/calculo/**/*_test.dart` | `flutter test` |
| `features/convite/domain/**` (Dart puro) | unit | Todos os ramos; 1:1 com os AC; **ausência de import de Flutter é parte da cobertura**; onde há tabela (RN-26), célula a célula escrita à mão, nunca laço sobre a própria tabela | `test/features/convite/domain/*_test.dart` | `flutter test` |
| `features/convite/data/**` (adaptadores) | unit | Caminho feliz **e** caminho de falha; idempotência afirmada por **contagem de gravações**, nunca por "a tela não mudou"; o efeito a jusante afirmado sobre o registro real, não sobre o duplo | `test/features/convite/data/*_test.dart` | `flutter test` |
| `features/convite/presentation/bloc/**` | unit | Um teste por transição; 1:1 com os AC; preservação de estado, idempotência, reentrância e falha inclusas; **toast só depois do `await`** afirmado por **ordem**, não por presença | `test/features/convite/presentation/bloc/*_test.dart` | `flutter test` |
| `features/convite/presentation/{pages,widgets}/**` | widget | Cada AC de UC-07/UC-17/UC-18 observável na árvore, nas **duas** viewports (390×820 e 1180×800); ausência afirmada com `findsNothing`, nunca por omissão de asserção | `test/features/convite/presentation/{pages,widgets}/*_test.dart` | `flutter test` |
| Copy (`convite_textos.dart`) | unit | Todo literal de T-06/T-07/RN-25/RN-26 afirmado; comparado com a **constante**, nunca com o literal duplicado; os quatro toasts **não** são redeclarados — vêm de `BoraToastTexts` | `test/features/convite/domain/convite_textos_test.dart` | `flutter test` |
| `core/routing/**` (E-4) | widget (rota) | Destino afirmado por `rotaAtual()` e pela página real, **não** pelo placeholder (AD-014); as duas rotas abertas **direto**, sem barra de abas (CVT-37 AC4) | `test/core/routing/*_test.dart` | `flutter test` |
| `core/di/injector.dart` | unit | As três portas resolvem, e a que tem estado resolve como **singleton sobre a mesma instância** da festa | `test/core/di/*_test.dart` | `flutter test` |
| Guards de fronteira (varredura) | unit (varredura de arquivo) | A violação quebra a suíte **nomeando o arquivo infrator**; **cada regra tem teste contra trecho sintético infrator** (anti-vácuo) e o separador de path é **normalizado** (`\` × `/`, bug real `179bab0`) | `test/features/convite/architecture/*_test.dart` | `flutter test` |
| `pubspec.yaml` · `.specs/**` | none | — (gate de build, sem teste) | — | — |

## Gate Check Commands

> Descobertas do repositório (`pubspec.yaml`, `analysis_options.yaml`, `CLAUDE.md`) — **não há CI**, tudo roda local.

| Gate Level | When to Use | Command |
|---|---|---|
| **Quick** | Depois de task com teste unit/bloc só | `flutter test test/<caminho do arquivo de teste da task>` |
| **Full** | Depois de task com teste de widget ou de rota | `flutter test test/features/convite test/core/routing` |
| **Build** | Fim de fase, e em **toda** task que toca `lib/core/**` ou `pubspec.yaml` | `flutter analyze && flutter test` |

**Regra de ouro herdada das specs 04–07: confira o exit code do `flutter test` explicitamente.** `flutter test | tail` engole o código de saída, e isso já produziu um commit com o gate vermelho neste projeto. Use `flutter test; echo "exit=$?"`.

**Não rode `dart format`** — o formatter do Dart 3.13 usa o estilo "tall" e reescreve dezenas de arquivos já commitados (aviso operacional do `STATE.md`).

**Cota:** rodar `python .claude/scripts/cota.py` ao fim de cada task e em toda fronteira de fase (combinado ativo do projeto).

---

## ⚠️ Cinco resoluções que este plano toma e o `design.md` não tinha como tomar

Levantadas ao conferir o design contra o código real de 2026-09-03. Cada uma **preserva o comportamento observável dos 37 critérios** e está declarada aqui para que ninguém a "conserte" adiante sem saber que foi vista.

| # | O que o design diz | O que o código real diz | Resolução |
|---|---|---|---|
| **R-1** | `FestaEmEdicao.votos` é `Map<ModeloDeEnquete, int>` (§6.1), com `ModeloDeEnquete` em `features/convite/domain/` (§6.2) | Isso faria **`core/festas/` importar uma feature** — inversão que nenhuma camada do projeto faz | O **enum** `ModeloDeEnquete` (com `chave`/`porChave`) sobe para `core/festas/dominio/`; **o catálogo de RN-26 fica na feature**. É o precedente literal de `papel_na_festa.dart` ("só o enum: a tabela é domínio de `galera`") e de `NivelDoLink`. **T3** |
| **R-2** | `montarMensagem({..., required String codigo})` monta o link com `GaleraTextos.urlDoConvite` (§5.2, §6.4) | `galera_textos.dart` importa `design_system` → **Flutter**. `convite/domain/` é Dart puro (§13) e não pode importá-lo | `montarMensagem` recebe **`required String urlDoConvite`**, já pronta; quem chama `GaleraTextos.urlDoConvite(codigo)` é o `ConviteBloc` (presentation → presentation). Continua **uma** fonte do host. **T7**, **T12** |
| **R-3** | CVT-35: CONVIDADO e SÓ VÊ "não alcançam as duas telas" | Não existe guarda de rota por papel no projeto (a de AD-017 é de **sessão**), e a fronteira da spec proíbe alteração em `core/routing/**` que não seja aninhar a rota filha | O bloqueio é **da ação, não da rota**: sem `Capacidade.editarTudo`, os três CTAs ficam desabilitados e os handlers não chamam porta nenhuma — mesmo tratamento de CVT-08/CVT-22, **sem copy nova**. **SPEC_DEVIATION declarado**: virar bloqueio de rota exigiria copy que T-06/T-07 não desenham. **T26** |
| **R-4** | — | `test/core/festas/dominio/festa_em_edicao_repository_test.dart:119` afirma `arquivosDeDominio, hasLength(4)` | A E-2 acrescenta dois arquivos → **6**. **Só o número muda**; a asserção que discrimina (`exportados == arquivosDeDominio`) segue exata. **T3** |
| **R-5** | — | `test/core/routing/app_router_shell_test.dart:89` afirma que `/roles/:festaId/whatsapp` renderiza o **placeholder** `convite` | O placeholder deixa de existir. O teste passa a afirmar a **`WhatsappPage` real** — asserção **mais forte**, nunca mais fraca. **T24** |

---

## Execution Plan

As fases são ordenadas e rodam em sequência — cada uma termina antes da próxima começar, e as tasks de uma fase executam em ordem.

### Fase 1 — A decisão, a dependência e as duas emendas de dado

Nada de UI. Abre o canal de `quemLeva` (sem o qual **CVT-04 é impossível**), dá à festa o grupo e os votos, e fixa a copy.

```
T1 → T2 → T3 → T4
```

### Fase 2 — O domínio puro: RN-26 e RN-26b

Dart puro, sem árvore de widgets. É aqui que as duas aritméticas da feature nascem — e é o único lugar onde elas podem morar (§13).

```
T5 → T6 → T7 → T8
```

### Fase 3 — As três portas e seus adaptadores

```
T9 → T10 → T11
```

### Fase 4 — T-06: o bloc e a tela da mensagem

```
T12 → T13 → T14 → T15 → T16 → T17
```

### Fase 5 — T-07: o grupo, as enquetes e a tela

```
T18 → T19 → T20 → T21 → T22 → T23
```

### Fase 6 — Fiação, permissões e guards

```
T24 → T25 → T26 → T27 → T28
```

---

## Task Breakdown

### T1: Registrar a AD-032 e trazer o `share_plus`

**What**: Acrescentar a decisão **AD-032** (canal único de saída de texto: `share_plus` atrás de `CompartilhadorDeTexto`, com o mapeamento de `ShareResultStatus` num lugar só) à seção `## Decisions` do `.specs/STATE.md`, com o texto que o `design.md` §12 já redigiu; e declarar `share_plus: ^13.3.0` no `pubspec.yaml` (**E-1**).
**Where**: `.specs/STATE.md` (só a seção `## Decisions`) · `pubspec.yaml` · `pubspec.lock`
**Depends on**: None
**Reuses**: O formato das AD-023..AD-031 (Decision / Reason / Trade-off / Scope / Date / Status) e a reserva de numeração de `.specs/STATE.md` §"Reserva de numeração — AD-029..AD-036"
**Requirement**: pré-condição estrutural de CVT-11, CVT-13, CVT-29, CVT-31, CVT-36

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `AD-032` existe com os seis campos, `Status: active`, com o texto de `design.md` §12 — inclusive o mapeamento das quatro linhas (`success`→`abriu`, `unavailable`→`abriu`, `dismissed`→`cancelou`, exceção→`falhou`)
- [ ] A linha da AD-032 sai da tabela de reserva, como fizeram `montar`, `lista` e `galera`
- [ ] **A numeração é conferida no momento de gravar**: o log ativo termina em AD-031; se outra spec tiver gravado a sua nesse meio-tempo, renumera-se **aqui**, nunca lá
- [ ] Nenhuma AD existente é editada (nada vira `superseded`)
- [ ] `share_plus: ^13.3.0` no `pubspec.yaml`, resolvido por `flutter pub get`; **nenhuma versão existente muda** — conferir o diff do `pubspec.lock` e declará-lo no corpo do commit
- [ ] Gate `build` passa com a **baseline intacta em 2451**; exit code conferido
- [ ] ⚠️ `flutter pub get` precisa de rede. Se a resolução falhar, **pare e reporte** — não troque de pacote nem fixe versão por conta própria (a escolha é do usuário, `design.md` §2.3)

**Tests**: none (camadas "Documentação / spec" e `pubspec.yaml`)
**Gate**: build
**Commit**: `chore(convite): adota o share_plus como canal único de saída de texto`

---

### T2: E-3 — o canal de "quem leva", da composição até o item

**What**: `ComposicaoDaFesta` ganha `atribuicoes` (`Map<ChaveItem, String>`, default `const {}`, dentro de `copyWith`/`==`/`hashCode`), e `CalculadoraDaFesta` passa a preencher `ItemDeLista.quemLeva` a partir dela. **Nenhuma fórmula muda.**
**Where**: `lib/core/calculo/dominio/composicao_da_festa.dart` · `lib/core/calculo/regras/calculadora_da_festa.dart` (`_itemDe`) · `test/core/calculo/**`
**Depends on**: T1
**Reuses**: A forma **literal** da E-b de `lista` — `noCarrinho` (`composicao_da_festa.dart:26,58,83,91,112,121`): campo com default, em `copyWith`, em `==` e no `hashCode` por `hashAllUnordered`/comparador profundo
**Requirement**: CVT-04 (pré-condição), CVT-15

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `atribuicoes` existe com default `const {}` e **nenhum call site** existente precisa mudar
- [ ] `copyWith` **preserva** `atribuicoes` quando não informado, e o troca por mapa vazio quando informado vazio — os dois casos com teste próprio (é a armadilha que a E-b de `lista` documenta em `composicao_da_festa.dart:67`)
- [ ] `==`/`hashCode` afirmados nos **dois** sentidos: duas composições com atribuições iguais são iguais; diferindo só na atribuição, **diferentes**
- [ ] `CalculadoraDaFesta.calcular` com `atribuicoes: {chave: 'Rafa'}` devolve o `ItemDeLista` daquela chave com `quemLeva == 'Rafa'`, e **todos** os demais com `quemLeva == null`
- [ ] Chave atribuída que **não** está em `itensSelecionados` não produz item nenhum e não lança
- [ ] Um teste afirma que **os números canônicos não mudaram** com o campo novo: o estado padrão segue em **R$ 211 / ≈R$ 30** e os essenciais em **R$ 271 / ≈R$ 45** (RN-13/RN-14)
- [ ] `aplicarOverrides` continua preservando `quemLeva` (regressão sobre `overrides.dart:57`)
- [ ] Gate `build` passa; exit code conferido
- [ ] ≥ 8 testes novos

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): liga a atribuição da composição ao dono do item`

---

### T3: E-2 — o grupo do rolê, os votos e o enum de modelo na festa

**What**: `GrupoDoRole` (só `nome`), o enum `ModeloDeEnquete` com `chave`/`porChave` (**R-1**), e os dois campos novos em `FestaEmEdicao`: `grupo` (`GrupoDoRole?`, default `null`) e `votos` (`Map<ModeloDeEnquete, int>`, default `const {}`), os dois em `copyWith`/`==`/`hashCode` e exportados pelo barrel.
**Where**: `lib/core/festas/dominio/grupo_do_role.dart` (novo) · `lib/core/festas/dominio/modelo_de_enquete.dart` (novo) · `lib/core/festas/dominio/festa_em_edicao.dart` · `lib/core/festas/festas.dart` · `test/core/festas/dominio/**`
**Depends on**: T1
**Reuses**: As duas emendas aditivas que já convivem em `festa_em_edicao.dart` — `despesas` (`lista`, AD-030) e `convite` (`galera`, AD-031); e a forma de `NivelDoLink.chave`/`porChave` (chave de serialização escrita à mão, **nunca** derivada de `name`)
**Requirement**: CVT-17, CVT-18, CVT-19, CVT-20, CVT-27

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `GrupoDoRole` guarda **só** `nome` — **nenhum campo de membros** (A-04: membros são derivados na leitura), com doc comment dizendo por quê
- [ ] `ModeloDeEnquete` tem os três valores com chave de serialização própria; `porChave` devolve `null` para chave desconhecida
- [ ] **A existência do grupo é o `null`** — nenhum booleano paralelo que possa discordar do nome; um teste afirma que não existe outro campo de existência
- [ ] `FestaEmEdicao.copyWith(grupo: ...)` **preserva** `despesas` e `convite`, e `copyWith(despesas: ...)` **preserva** `grupo` e `votos` — as quatro direções com teste próprio (é o defeito que `galera` E-3 pagou para aprender)
- [ ] `==`/`hashCode` nos dois sentidos para `grupo` e para `votos` (mapa comparado por valor, não por identidade)
- [ ] O barrel `festas.dart` exporta os dois arquivos novos
- [ ] **R-4 declarado no commit**: `festa_em_edicao_repository_test.dart:119` passa de `hasLength(4)` para `hasLength(6)`. Só o número; a asserção `exportados == arquivosDeDominio` **não** é tocada
- [ ] Nenhum import de Flutter nos arquivos novos
- [ ] Gate `build` passa; exit code conferido
- [ ] ≥ 12 testes novos

**Tests**: unit
**Gate**: build
**Commit**: `feat(festas): dá à festa o grupo do rolê e os votos das enquetes`

---

### T4: `ConviteTextos` — a copy literal de T-06 e T-07, num arquivo só

**What**: `convite_textos.dart` em `features/convite/domain/`, Dart puro, com as 19 constantes e funções de `design.md` §9 — incluindo os plurais derivados de A-14 (`chipDoGrupo`, `confirmadosEntram`).
**Where**: `lib/features/convite/domain/convite_textos.dart` (novo) · `test/features/convite/domain/convite_textos_test.dart` (novo)
**Depends on**: T1
**Reuses**: `galera_textos.dart` e `home_textos.dart` como forma (copy junta, nomeada, com o literal da spec-fonte no doc comment) — **sem** o import de `design_system` que aqueles têm, porque aqui a camada é Dart puro
**Requirement**: CVT-01, CVT-02, CVT-05, CVT-16, CVT-18, CVT-22, CVT-23, CVT-28

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] As 19 entradas de `design.md` §9 existem com o literal exato de T-06/T-07/RN-25
- [ ] `chipDoGrupo(nome, n)` segue o **template de RN-25** (`✅ "{nome}" · {n} membros`), com o nome **como gravado** — **D-1/A-13**, com o racional no doc comment; testado com `n = 0, 1, 2, 4`
- [ ] `confirmadosEntram(n)` dá `1 confirmado entra no grupo` para 1 e `{n} confirmados entram no grupo` para 0 e para ≥2 — o zero testado explicitamente (A-21)
- [ ] **Os quatro toasts não são redeclarados**: um teste de varredura afirma que nenhum dos literais de `BoraToastTexts.{abrindoWhatsapp, grupoCriado, enquetePostada, crieOGrupoPrimeiro}` aparece neste arquivo
- [ ] Nenhum import de Flutter, de `design_system` ou de `share_plus`
- [ ] Cada asserção compara com a **constante**, nunca com o literal redigitado (L-008)
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 20 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): fixa a copy literal de T-06 e T-07`

---

### T5: O catálogo de RN-26 — três modelos, literais

**What**: `enquetes.dart` em `features/convite/domain/`: `ModeloDeEnqueteDefinicao`, `OpcaoDeEnquete` e o `const catalogoDeEnquetes` com os três modelos, perguntas, opções e **votos-base literais** de RN-26 (5/2/1 · 6/2 · 3/1).
**Where**: `lib/features/convite/domain/enquetes.dart` (novo) · `test/features/convite/domain/enquetes_test.dart` (novo)
**Depends on**: T3, T4
**Reuses**: `ModeloDeEnquete` de `core/festas` (T3) · os rótulos dos três toggles de `ConviteTextos` (T4) — **uma** fonte para o rótulo que a tela mostra
**Requirement**: CVT-24

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Os três modelos existem com a pergunta literal (`QUE HORAS COMEÇA?` · `MELHOR DATA?` · `QUEM LEVA A CAIXA DE SOM?`) e as opções literais de RN-26
- [ ] Os votos-base são **5/2/1**, **6/2** e **3/1**, afirmados **célula a célula escrita à mão** — nunca por laço sobre o próprio catálogo (o laço concorda com qualquer catálogo, inclusive um errado)
- [ ] O doc comment repete **A-02/D-3** no código: os votos-base somam 8, 8 e 4 votantes contra os 4 confirmados de RN-30, e são **fixture de demo** — é o aviso que impede alguém de "consertar" os números adiante
- [ ] O catálogo é `const` e cobre os três valores do enum; um teste afirma que **nenhum** valor de `ModeloDeEnquete` fica de fora (modelo novo quebra a suíte)
- [ ] Nenhum import de Flutter
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 12 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): traz os três modelos de enquete de RN-26`

---

### T6: A aritmética de RN-26 — percentual, voto trocável e o texto da enquete

**What**: `LinhaDaEnquete`, `linhasDaEnquete(modelo, votoDoUsuario)` (`% = round(votos/total×100)`, `fracao`, plural de `contagemFormatada`) e `textoDaEnquete(modelo, voto)` — a serialização de A-17: pergunta em CAIXA ALTA e uma linha por opção com rótulo e `%`, **sem link, sem assinatura, sem nome de grupo**.
**Where**: `lib/features/convite/domain/resultado_da_enquete.dart` (novo) · `test/features/convite/domain/resultado_da_enquete_test.dart` (novo)
**Depends on**: T5
**Reuses**: O catálogo de T5 · a forma de plural de `ConviteTextos` (T4)
**Requirement**: CVT-24, CVT-25, CVT-26, CVT-29

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Sem voto do usuário, os três modelos exibem **63/25/13**, **75/25** e **75/25** — os literais de RN-26, escritos à mão
- [ ] `HORÁRIO` com voto em `14h` (índice 0) dá **6/2/1** e **67/22/11**, e a soma exibida é **100 ou 101**; um teste afirma que **101 é resultado correto** e não é normalizado (**D-7**)
- [ ] **Trocar move o +1**: votar em 0 e depois em 1 mantém o total em base+1 — afirmado pelo **total**, não só pelos percentuais
- [ ] Tocar a opção já votada é **no-op**: mesma lista de linhas, mesmo total, voto **não** removido (não existe desvoto — A-02)
- [ ] `meuVoto` é `true` **só** na opção votada, e em nenhuma com `votoDoUsuario == null`
- [ ] `fracao` é `votos/total` sem arredondamento — a barra do componente recebe a fração, e **quem arredonda é só o percentual** (AD-009)
- [ ] `contagemFormatada` dá `1 voto` para 1 e `{n} votos` para 0 e ≥2
- [ ] `textoDaEnquete` devolve a pergunta em caixa alta + uma linha por opção com o `%` atual, e um teste afirma que a string **não contém** `bora.app`, `http` nem o nome do grupo
- [ ] Nenhum import de Flutter
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 22 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): calcula o percentual das enquetes de RN-26`

---

### T7: `MensagemDoConvite` — o modelo, a projeção de texto e os blocos FLYER e LINK

**What**: `BlocoDaMensagem`, `EnfaseDaLinha`, `LinhaDaMensagem`, `MensagemDoConvite` (com `vazia`), `textoDe(m)` e `montarMensagem(...)` cobrindo os blocos **FLYER** e **LINK** na ordem fixa do enum. A assinatura recebe `urlDoConvite` pronta (**R-2**).
**Where**: `lib/features/convite/domain/mensagem.dart` (novo) · `test/features/convite/domain/mensagem_test.dart` (novo)
**Depends on**: T4
**Reuses**: `Festa.nome/data/hora/local` de `core/calculo` · `ConviteTextos` (T4)
**Requirement**: CVT-03, CVT-05, CVT-06 (dado), CVT-08, CVT-12

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] O modelo carrega **estilo como dado** (`EnfaseDaLinha`) e **nenhuma cor** — um teste afirma que o arquivo não importa `design_system` nem `package:flutter`
- [ ] Bloco FLYER: as duas linhas da mini-arte (`CHURRAS` / `DO RAFA 🔥`) e a linha `SÁB · 18 JUL · 14H · LAJE DO RAFA`, **derivadas** de `Festa` — trocar o nome ou o local na fixture muda a linha (teste que discrimina derivação de literal)
- [ ] Bloco LINK: a linha do link com `EnfaseDaLinha.link` e, depois, `confirma e escolhe o que levar 👆`
- [ ] `ativos` vazio ⇒ `linhas.isEmpty` e `vazia == true` (**CVT-08**)
- [ ] A ordem é sempre FLYER → LINK, **independente da ordem de inserção** no `Set` — testado com o conjunto montado ao contrário
- [ ] `textoDe` junta com `\n` e **ignora a ênfase**: um teste afirma que a string **não contém** `*`, `_` nem qualquer marcação (o WhatsApp não interpretaria)
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 16 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): monta a mensagem do convite por blocos`

---

### T8: O bloco LISTA — donos, órfãos e o custo por cabeça

**What**: `montarMensagem` passa a compor o bloco **LISTA** (RN-26b): uma linha por dono (`" + "`), **uma** linha órfã (`" · "`) e a linha de custo — sempre que o bloco está ativo.
**Where**: `lib/features/convite/domain/mensagem.dart` (modificar) · `test/features/convite/domain/mensagem_lista_test.dart` (novo)
**Depends on**: T2, T7
**Reuses**: `ItemDeLista.valor`/`.quemLeva` e `ResultadoDoCalculo.porCabeca` (recebido pronto) · `MoneyFormatter.reais` para RN-13
**Requirement**: CVT-04, CVT-12, CVT-15

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Uma linha por dono, itens juntados por **`" + "`**, terminando em `— {Nome} leva` com `EnfaseDaLinha.dono`
- [ ] **Uma só** linha órfã, com **todos** os sem-dono juntados por **`" · "`**, terminando em `— quem leva?` com `EnfaseDaLinha.orfao` — os dois separadores afirmados em asserções separadas (**D-5/A-11**)
- [ ] A linha de custo usa `MoneyFormatter.reais(porCabeca)` e renderiza **sempre** que o bloco está ativo, **inclusive com `R$ 0`** (A-12)
- [ ] Lista vazia ⇒ **só** a linha de custo; todos com dono ⇒ **nenhuma** linha órfã (`findsNothing` equivalente: a lista de linhas não contém `quem leva?`); nenhum com dono ⇒ nenhuma linha de dono
- [ ] A **ordem** das linhas de dono e dos órfãos é a **ordem do repositório**, nunca reordenada — teste com uma ordem não-alfabética que a saída preserva
- [ ] **Nenhuma divisão** neste arquivo: `porCabeca` chega pronto; um teste afirma que trocar o valor de entrada troca a linha, e a varredura de T27 cobre a ausência de aritmética
- [ ] Com a fixture RN-30 + atribuições semeadas, a bolha inteira dos três blocos bate linha a linha com o literal de T-06
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 16 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): compõe o bloco da lista com quem leva o quê`

---

### T9: A porta `Relogio` e o `HH:mm` sem `intl`

**What**: `abstract class Relogio { DateTime get agora; }`, `RelogioDoSistema` e `horaFormatada(DateTime)` em `HH:mm` 24h, por `padLeft`.
**Where**: `lib/features/convite/domain/relogio.dart` (novo) · `test/features/convite/domain/relogio_test.dart` (novo)
**Depends on**: T1
**Reuses**: A forma "porta de plataforma com default `const`" de `galera` §7.3 (`AreaDeTransferencia` / `AreaDeTransferenciaDoSistema`)
**Requirement**: CVT-10, CVT-28

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `horaFormatada` dá `14:02` e `14:05` (os dois literais de T-06 e T-07), `00:00` à meia-noite, `09:07` com zero à esquerda nos dois campos e `23:59`
- [ ] **Sem `intl`** e sem import de Flutter — afirmado por varredura do arquivo
- [ ] `RelogioDoSistema.agora` devolve `DateTime.now()`; o duplo de teste devolve o instante injetado
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 7 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): congela a hora do preview atrás de um relógio injetado`

---

### T10: A porta do canal e o adaptador do `share_plus`

**What**: `enum ResultadoDoCompartilhamento { abriu, cancelou, falhou }` + `abstract class CompartilhadorDeTexto` em `domain/`, e `CompartilhadorDoSistema` em `data/` — **o único arquivo da feature que importa `share_plus`** —, com o mapeamento da AD-032.
**Where**: `lib/features/convite/domain/compartilhador_de_texto.dart` (novo) · `lib/features/convite/data/compartilhador_do_sistema.dart` (novo) · `test/features/convite/data/compartilhador_do_sistema_test.dart` (novo)
**Depends on**: T1
**Reuses**: `area_de_transferencia_do_sistema.dart` de `galera` como forma de adaptador de plataforma + o seu teste como forma de duplo · **AD-021**: `mocktail` é legítimo aqui porque `share_plus` é SDK de terceiro
**Requirement**: CVT-11, CVT-13, CVT-31, CVT-36

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] O mapeamento das **quatro** linhas da AD-032 tem um teste cada: `success`→`abriu`, **`unavailable`→`abriu`**, `dismissed`→`cancelou`, exceção→`falhou`
- [ ] O teste de `unavailable` carrega no nome ou no comentário **por que** é sucesso (é o caminho feliz do web — `design.md` §2.3); mapear para `falhou` tem de quebrar a suíte
- [ ] O `catch` é `on Exception` e **não** `catch (_)`: um teste afirma que um `Error` **sobe** em vez de virar `falhou`
- [ ] O texto compartilhado chega ao SDK **sem alteração** — afirmado sobre o argumento capturado
- [ ] `domain/` não importa `share_plus`; **só** o arquivo de `data/` importa
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 8 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): abre o canal de compartilhamento atrás de uma porta`

---

### T11: `ConviteRepository` e o adaptador sobre a festa

**What**: A porta (`observar`, `criarGrupo` idempotente devolvendo `bool`, `votar`) em `domain/`, e `ConviteRepositorioSobreFestas` em `data/` — *read-modify-write* sobre `FestaEmEdicaoRepository` usando **só `copyWith`**.
**Where**: `lib/features/convite/domain/convite_repository.dart` (novo) · `lib/features/convite/data/convite_repositorio_sobre_festas.dart` (novo) · `test/features/convite/data/convite_repositorio_sobre_festas_test.dart` (novo)
**Depends on**: T3, T5
**Reuses**: `galera_repositorio_sobre_festas.dart` — a **mesma** forma, inclusive a lição da E-3 de `galera`: nunca reconstruir `FestaEmEdicao` campo a campo
**Requirement**: CVT-17, CVT-19, CVT-20, CVT-21, CVT-26, CVT-27, CVT-37

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `observar` repassa o stream da festa; erro do stream **propaga** (quem trata é o bloc)
- [ ] `criarGrupo` grava `GrupoDoRole(nome: festa.nome)` e devolve `true`; a **segunda** chamada devolve `false` e **não grava** — afirmado por **contagem de gravações** no duplo, não por "o estado não mudou" (**CVT-19**)
- [ ] `criarGrupo` **preserva** `despesas`, `convite`, `composicao` e `votos` — teste que grava com todos os quatro preenchidos e confere os quatro depois (é o defeito que a `galera` pagou para aprender: o carrinho apagado em silêncio)
- [ ] `votar` grava o índice por modelo; votar de novo no mesmo modelo **substitui**; votar em outro modelo **não toca** no primeiro (**CVT-27**)
- [ ] `votar` também preserva `grupo`, `despesas` e `convite`
- [ ] Um teste afirma o efeito a jusante **sobre o registro real** (`FestaRepositoryEmMemoria`), não só sobre o duplo — a lição L-034 do handoff de `galera`
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 14 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): guarda o grupo e os votos no registro da festa`

---

### T12: `ConviteState` e o `ConviteBloc` — leitura, blocos e hora congelada

**What**: O estado de T-06 e os handlers `FestaRecebida`, `ObservacaoFalhou` e `BlocoAlternado`; a hora é lida **uma vez** na construção; a mensagem é recomposta a cada emissão preservando os blocos ativos.
**Where**: `lib/features/convite/presentation/bloc/convite_{bloc,event,state}.dart` (novos) · `test/features/convite/presentation/bloc/convite_bloc_test.dart` (novo)
**Depends on**: T7, T9, T11
**Reuses**: `GaleraState`/`GaleraBloc` como forma (situação em três valores, `==`/`hashCode` à mão, L-011) · `GaleraTextos.urlDoConvite(codigo)` para a URL do bloco LINK (**R-2**)
**Requirement**: CVT-01, CVT-02, CVT-07, CVT-08, CVT-10, CVT-28 (parte remota), CVT-37

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] O estado nasce com **os três blocos ativos** (A-15) e situação `carregando`
- [ ] `FestaRecebida` compõe a mensagem e emite `pronta`; `nomeDoGrupo` é **não-nulo só quando o grupo existe** (CVT-01)
- [ ] `BlocoAlternado` liga/desliga só o bloco tocado, preservando os outros dois; as **8 combinações** têm asserção
- [ ] Tocar um bloco **já** no estado desejado **não emite estado novo** — afirmado por contagem de emissões, não por igualdade de campo (**CVT-07**)
- [ ] `horaCongelada` é lida **uma vez**: alternar blocos cinco vezes com o relógio avançando **não** muda a hora (**CVT-10**)
- [ ] Emissão nova do stream (alguém confirma, alguém assume item) **recompõe a mensagem preservando os blocos ativos** — nenhum toque descartado (**CVT-28**)
- [ ] `ObservacaoFalhou` → situação `falhou` **e** `logError` no `AppLogger` duplo (AD-005)
- [ ] `==`/`hashCode` do estado nos dois sentidos; emissão idêntica é descartada
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 18 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): liga os blocos da mensagem ao estado da tela`

---

### T13: `ConviteBloc` — o envio, a reentrância e o contrato de falha

**What**: O handler `EnvioPedido`: guarda de `enviando` e de `mensagem.vazia`, chamada ao canal, e o toast emitido **depois** do `await` — com os três desfechos da AD-032.
**Where**: `lib/features/convite/presentation/bloc/convite_bloc.dart` (modificar) · `test/features/convite/presentation/bloc/convite_bloc_envio_test.dart` (novo)
**Depends on**: T10, T12
**Reuses**: O contador `copiasConcluidas` de `GaleraState` como forma do gatilho de toast (contador, **não** booleano — senão o segundo toast seguido não sai)
**Requirement**: CVT-11, CVT-12, CVT-13, CVT-14, CVT-36

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] O texto entregue ao canal é **exatamente** `textoDe(state.mensagem)` — afirmado sobre o argumento capturado, nas 8 combinações de blocos (**CVT-12**)
- [ ] O toast só existe no desfecho `abriu`, e um teste afirma a **ordem**: nenhuma emissão de toast antes de o `Future` do canal completar (**CVT-11**)
- [ ] `cancelou` ⇒ **sem toast e sem log**; `falhou` ⇒ **sem toast, sem copy de erro** e **com** `logError` (**CVT-13**)
- [ ] O log **não contém** o texto montado nem o link: teste que procura `bora.app` e o nome da festa no que chegou ao `AppLogger` duplo e afirma **ausência** (**CVT-36**)
- [ ] Duplo `EnvioPedido` em sequência ⇒ **uma** chamada ao canal e **um** toast (**CVT-14**)
- [ ] `EnvioPedido` com `mensagem.vazia` ⇒ **zero** chamadas à porta (defesa em profundidade de CVT-08)
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 14 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): envia a mensagem montada pelo canal de compartilhamento`

---

### T14: `BolhaDaConversa` — a moldura que as duas telas dividem

**What**: O widget do fundo de conversa `#E7DFCB`, a bolha branca ≤300px alinhada à direita (borda 2px, sombra dura 4px preta), a hora + `✓✓` no rodapé e a legenda central. Recebe a legenda e o conteúdo por parâmetro — serve T-06 e T-07.
**Where**: `lib/features/convite/presentation/widgets/bolha_da_conversa.dart` (novo) · `test/features/convite/presentation/widgets/bolha_da_conversa_test.dart` (novo)
**Depends on**: T4
**Reuses**: `BoraSurface` (borda/sombra), `BoraColors`, `BoraShadows`, `BoraTextStyles` — **composto, nunca estendido** (AD-011)
**Requirement**: CVT-06, CVT-09, CVT-28 (moldura), CVT-32

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Fundo `#E7DFCB`, bolha branca, borda 2px e sombra dura 4px preta — cada valor lido do **token**, nunca do literal redigitado
- [ ] `maxWidth` de **300px** afirmado por medida da caixa renderizada, nas **duas** viewports (390×820 e 1180×800) — em 1180 a bolha **não** estica (**CVT-32**)
- [ ] Alinhada à direita; hora + `✓✓` no rodapé com a string injetada (`14:02` e `14:05` nos dois testes)
- [ ] Conteúdo longo: **sem** `TextOverflow.ellipsis` na árvore, **sem** scroll horizontal (`tester.takeException()` nulo e nenhum overflow), altura cresce (**CVT-09**)
- [ ] Sem conteúdo, a bolha **não** renderiza e a legenda permanece (`findsNothing` para a bolha, `findsOneWidget` para a legenda) — **CVT-08**
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 12 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(convite): desenha a bolha de conversa do preview`

---

### T15: `LinhasDaMensagem` — a ênfase virando token

**What**: O widget que traduz cada `EnfaseDaLinha` no estilo do design system e renderiza as linhas da mensagem dentro da bolha.
**Where**: `lib/features/convite/presentation/widgets/linhas_da_mensagem.dart` (novo) · `test/features/convite/presentation/widgets/linhas_da_mensagem_test.dart` (novo)
**Depends on**: T7
**Reuses**: `BoraColors.tomate`/`ink`/`amarelo`, `BoraTextStyles` — a tradução é **um `switch` num lugar só**
**Requirement**: CVT-03, CVT-04, CVT-05

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Cada um dos sete valores de `EnfaseDaLinha` tem asserção própria sobre o estilo aplicado — **nenhum** valor sem teste (adicionar um valor novo sem tratá-lo quebra a suíte)
- [ ] `orfao` renderiza em vermelho; `link` renderiza **sublinhado**; `dono` em negrito; `arteTitulo`/`arteData` com o pigmento da mini-arte — todos lidos do token
- [ ] A mini-arte escura do flyer aparece com as duas linhas de título e a linha amarela (**CVT-03**)
- [ ] O widget **não** monta texto: um teste com linhas injetadas à mão afirma que a árvore mostra exatamente os textos recebidos, sem acrescentar nem juntar
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 12 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(convite): renderiza as linhas da mensagem com a ênfase de cada uma`

---

### T16: `SeletorDeBlocos` — os três toggles aditivos de "NO PACOTE"

**What**: A seção rotulada "NO PACOTE" com os três `BoraSelectionChip` aditivos.
**Where**: `lib/features/convite/presentation/widgets/seletor_de_blocos.dart` (novo) · `test/features/convite/presentation/widgets/seletor_de_blocos_test.dart` (novo)
**Depends on**: T4, T7
**Reuses**: `BoraSelectionChip` (`rotulo`, `emoji`, `selecionado`, `onTap`) — os toggles de `montar` como precedente de uso
**Requirement**: CVT-02, CVT-07

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Os três chips existem com os rótulos de `ConviteTextos` e o label "NO PACOTE"
- [ ] Com os três ativos, os três estão `selecionado` — afirmado sobre a propriedade do componente, não sobre a cor pintada
- [ ] **Aditivo**: desligar um deixa os outros dois ativos (**D-6/A-15**); um teste afirma as 8 combinações de `selecionado`
- [ ] O toque chama `onAlternar` com o bloco correspondente — **um** callback por toque, afirmado por contagem
- [ ] Nas duas viewports, sem overflow
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 10 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(convite): dá à tela os três toggles do pacote da mensagem`

---

### T17: `ConvitePage` — T-06 nas duas larguras

**What**: A página de T-06: provider do bloc **acima** do `ResponsiveBuilder`, header com voltar + título + sub condicional, o seletor, a bolha, o CTA e o toast; layout compacto com rodapé-CTA fixo e expandido em coluna ≤560px sem rodapé fixo.
**Where**: `lib/features/convite/presentation/pages/convite_page.dart` (reescrever o placeholder) · `test/features/convite/presentation/pages/convite_page_test.dart` (novo)
**Depends on**: T12, T13, T14, T15, T16
**Reuses**: `home_page.dart:48` (bloc **acima** do `ResponsiveBuilder` — cruzar 900px não pode destruir o bloc) · `BoraPrimaryButton` + `BoraPressSink` · `BoraToast` + `BoraToastTexts` · `layoutModeForWidth` (AD-007)
**Requirement**: CVT-01, CVT-08, CVT-11, CVT-14, CVT-32, CVT-33

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Header com controle de voltar, título `MANDAR NO GRUPO`, e o sub `GRUPO: {nome}` **só** quando o grupo existe — `findsNothing` quando não existe (**CVT-01**)
- [ ] Com os três blocos ativos e o relógio em **14:02**, a bolha inteira de T-06 renderiza nas duas viewports (**Success Criteria** da spec)
- [ ] Com os três desligados: bolha ausente, legenda presente, CTA com `onPressed: null` — e o press **não afunda** (`BoraPressSink` sem gesto) e **zero** chamadas à porta (**CVT-08**)
- [ ] O toast `ABRINDO O WHATSAPP… 📲` aparece **só** no desfecho `abriu`, some sozinho e nunca empilha dois (**CVT-11/CVT-14**)
- [ ] **Expandido (1180×800)**: coluna ≤560px, **sem** rodapé-CTA fixo, CTA no fluxo (**W-R2**); **compacto (390×820)**: rodapé fixo de volta (**W-R3**)
- [ ] Sem scroll horizontal em nenhuma das duas larguras; rolagem só do documento (**W-R4**)
- [ ] Cruzar 900px **preserva** os blocos ativos — teste que alterna a viewport com um bloco desligado e afirma que ele continua desligado (**CVT-33**)
- [ ] O botão de voltar faz `pop` — o bloc **não** navega (AD-020)
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 20 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(convite): entrega a tela de montar o convite`

---

### T18: `WhatsappState` e o `WhatsappBloc` — leitura, confirmados e criar o grupo

**What**: O estado de T-07 e os handlers `FestaRecebida`, `ObservacaoFalhou` e `GrupoPedido`; membros **derivados** dos confirmados a cada emissão.
**Where**: `lib/features/convite/presentation/bloc/whatsapp_{bloc,event,state}.dart` (novos) · `test/features/convite/presentation/bloc/whatsapp_bloc_test.dart` (novo)
**Depends on**: T4, T11
**Reuses**: `GaleraBloc` como forma · `StatusDePresenca` de `core/calculo` para filtrar confirmados
**Requirement**: CVT-16, CVT-17, CVT-18, CVT-19, CVT-20, CVT-21, CVT-22, CVT-37

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `confirmados` contém **só** quem está confirmado — nenhum pendente, nenhum extra sem app, nenhuma criança sem nome (**CVT-17**), afirmado com uma fixture que tem os quatro tipos
- [ ] `GrupoPedido` chama `criarGrupo` uma vez e emite o gatilho do toast; a **segunda** vez **não** chama a porta e **não** reemite (**CVT-19**), por contagem
- [ ] `GrupoPedido` **sem nenhum confirmado** ⇒ **zero** chamadas à porta (**CVT-22**)
- [ ] Emissão nova com 5 confirmados ⇒ a contagem sobe e `nomeDoGrupo` **continua não-nulo** — o chip nunca volta a ser botão (**CVT-21**); e quem deixa de estar confirmado **sai** da contagem
- [ ] `ObservacaoFalhou` → `falhou` + `logError` (AD-005)
- [ ] `==`/`hashCode` do estado nos dois sentidos, com a lista de confirmados comparada por valor
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 18 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): cria o grupo do rolê com quem confirmou`

---

### T19: `WhatsappBloc` — o modelo exclusivo e o voto trocável

**What**: Os handlers `ModeloSelecionado` (exclusivo, `horario` na abertura) e `VotoDado` (grava pelo repositório; `linhas` é getter derivado).
**Where**: `lib/features/convite/presentation/bloc/whatsapp_bloc.dart` (modificar) · `test/features/convite/presentation/bloc/whatsapp_bloc_enquete_test.dart` (novo)
**Depends on**: T6, T18
**Reuses**: `linhasDaEnquete` (T6) — o bloc **não** calcula percentual
**Requirement**: CVT-23, CVT-25, CVT-26, CVT-27, CVT-28

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] O estado nasce em `horario`; `ModeloSelecionado` é **exclusivo** — selecionar DATA desmarca HORÁRIO (**D-6/A-15**)
- [ ] Selecionar o modelo **já** ativo **não emite** estado novo (por contagem de emissões)
- [ ] `VotoDado` grava pelo repositório e as `linhas` refletem **67/22/11** depois de votar em `14h` (**CVT-25**)
- [ ] Votar noutra opção **move** o voto; tocar a já votada é **no-op** — nenhuma gravação a mais, por contagem (**CVT-26**)
- [ ] Votar em HORÁRIO, ir a DATA, votar, voltar a HORÁRIO: **os dois votos preservados** (**CVT-27**), afirmado pelas linhas dos dois modelos
- [ ] Emissão remota do stream **preserva** modelo ativo e voto (**CVT-28**)
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 16 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): troca de modelo de enquete sem perder voto`

---

### T20: `WhatsappBloc` — postar a enquete e a trava sem grupo

**What**: O handler `PostagemPedida`: a guarda de "sem grupo" **antes** de montar o texto, e o mesmo contrato de falha da T13.
**Where**: `lib/features/convite/presentation/bloc/whatsapp_bloc.dart` (modificar) · `test/features/convite/presentation/bloc/whatsapp_bloc_postagem_test.dart` (novo)
**Depends on**: T6, T10, T19
**Reuses**: `textoDaEnquete` (T6) · o contrato de desfecho da T13 — **mesmo** mapeamento, **mesma** disciplina de toast
**Requirement**: CVT-29, CVT-30, CVT-31, CVT-36

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] **Sem grupo**: toast `CRIE O GRUPO PRIMEIRO ☝️`, **zero** chamadas à porta (contagem), **nenhum** estado alterado, e a guarda vem **antes** da montagem — um teste afirma que o texto **não** é montado (**CVT-30**)
- [ ] **Com grupo**: o canal recebe `textoDaEnquete` **só do modelo selecionado** (**A-16**), e a string não tem link nem assinatura (**A-17**)
- [ ] O toast `ENQUETE POSTADA NO GRUPO 📲` só no desfecho `abriu`, e **depois** do `await`
- [ ] `cancelou`/`falhou` ⇒ sem toast de sucesso, sem copy de erro, **voto e modelo intactos**, `logError` no caso de falha (**CVT-31**)
- [ ] A tentativa bloqueada é registrada no `AppLogger` **sem** o texto e **sem** o link (**CVT-36**)
- [ ] Duplo toque ⇒ uma chamada, um toast (`postando`)
- [ ] Gate `quick` passa; exit code conferido
- [ ] ≥ 14 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(convite): posta a enquete e trava quem não criou o grupo`

---

### T21: `CardDoGrupo` — o botão que vira chip e não volta

**What**: O card branco com sombra verde-WhatsApp: título, avatares dos confirmados, a linha derivada e o botão ⇄ chip.
**Where**: `lib/features/convite/presentation/widgets/card_do_grupo.dart` (novo) · `test/features/convite/presentation/widgets/card_do_grupo_test.dart` (novo)
**Depends on**: T4, T18
**Reuses**: `BoraAvatar`, `BoraPrimaryButton`, `BoraSurface`, `BoraColors.waGreen`, `BoraShadows` · `card_do_link.dart` de `galera` como forma de card com sombra de acento
**Requirement**: CVT-16, CVT-18, CVT-19, CVT-21, CVT-22

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Sem grupo: `💬 CRIAR GRUPO DO ROLÊ`, avatares **só** dos confirmados, a linha `4 confirmados entram no grupo` e o botão `CRIAR GRUPO "CHURRAS DO RAFA 🔥"`
- [ ] Com grupo: o chip `✅ "CHURRAS DO RAFA 🔥" · 4 membros` sobre `#DCF8C6`, e o botão **ausente** (`findsNothing`) — **CVT-18/CVT-19**
- [ ] Com 5 confirmados e o grupo criado: `· 5 membros`, e o botão **continua ausente** (**CVT-21**)
- [ ] Zero confirmados: sem avatares, linha `0 confirmados entram no grupo`, botão com `onPressed: null` que **não afunda** (**CVT-22**)
- [ ] Um confirmado: `1 confirmado entra no grupo` e, criado, `· 1 membro` (**A-14**)
- [ ] Nome longo: o chip quebra ou elide **sem** alterar o nome recebido e **sem** abreviação inventada; a contagem continua na árvore
- [ ] Nas duas viewports, sem overflow
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 14 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(convite): desenha o card do grupo do rolê`

---

### T22: `SeletorDeModelos` e o preview votável da enquete

**What**: Os três `BoraSelectionChip` exclusivos de "ENQUETES PRO GRUPO" e o conteúdo da bolha da enquete: cabeçalho, pergunta, as opções em `BoraPollOption` e a legenda.
**Where**: `lib/features/convite/presentation/widgets/seletor_de_modelos.dart` (novo) · `lib/features/convite/presentation/widgets/preview_da_enquete.dart` (novo) · `test/features/convite/presentation/widgets/preview_da_enquete_test.dart` (novo)
**Depends on**: T4, T6
**Reuses**: `BoraPollOption` — já recebe `fracao`, `percentualFormatado`, `contagemFormatada`, `meuVoto`, `onVotar`, e **DS-34 já proíbe que ele calcule**: o widget recebe as `LinhaDaEnquete` prontas
**Requirement**: CVT-23, CVT-24, CVT-25, CVT-26, CVT-28

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Três chips **exclusivos** com `horario` selecionado na abertura (**CVT-23**); selecionar outro desmarca o anterior
- [ ] Os três modelos renderizam pergunta, opções e percentuais **literais** de RN-26: `63%/25%/13%`, `75%/25%`, `75%/25%` (**CVT-24**), lidos da árvore
- [ ] Depois de votar em `14h`, a árvore mostra `67%/22%/11%` (**CVT-25**)
- [ ] `meuVoto` marca **uma** opção; tocar a votada chama `onVotar` e a árvore **não muda** (**CVT-26**)
- [ ] Cabeçalho `📊 ENQUETE · você`, hora `14:05 ✓✓` e legenda `toque numa opção pra votar 👆` (**CVT-28**)
- [ ] **Nenhuma divisão no widget**: as frações e percentuais chegam prontos — coberto também pela varredura da T27
- [ ] Nas duas viewports, sem overflow
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 16 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(convite): mostra as três enquetes com voto ao vivo`

---

### T23: `WhatsappPage` — T-07 nas duas larguras

**What**: A página de T-07: header `WHATSAPP` + sub, o card do grupo, a seção de enquetes, a bolha do preview, o CTA de postar e os toasts; compacto com rodapé fixo, expandido em coluna ≤560px.
**Where**: `lib/features/convite/presentation/pages/whatsapp_page.dart` (novo) · `test/features/convite/presentation/pages/whatsapp_page_test.dart` (novo)
**Depends on**: T14, T18, T19, T20, T21, T22
**Reuses**: A mesma forma da T17 (bloc acima do `ResponsiveBuilder`) · `BolhaDaConversa` da T14 — **um** widget para as duas telas
**Requirement**: CVT-16, CVT-18, CVT-29, CVT-30, CVT-32, CVT-33, CVT-34

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Header `WHATSAPP` + sub `grupo do rolê + enquetes num toque` (**CVT-16**)
- [ ] Criar o grupo produz o chip **e** o toast `GRUPO CRIADO NO WHATSAPP ✅`; um segundo toque não produz um segundo toast (**CVT-18/CVT-19**)
- [ ] Postar sem grupo mostra `CRIE O GRUPO PRIMEIRO ☝️` e **zero** chamadas à porta, afirmado da página (**CVT-30**)
- [ ] **Expandido**: coluna ≤560px, bolha ≤300px, **sem** rodapé fixo; **compacto**: rodapé fixo (**CVT-32/CVT-33**)
- [ ] Sem scroll horizontal nas duas larguras
- [ ] Cruzar 900px **preserva** grupo, modelo ativo e voto (**CVT-34** — o estado mora no repositório, e este teste é o que prova)
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 18 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(convite): entrega a tela do grupo e das enquetes`

---

### T24: E-4/E-5 — a renomeação, a rota filha e o alcance direto

**What**: `ConvitePage` (placeholder) vira `WhatsappPage` na aba; a rota filha `convite` passa a montar a `ConvitePage` real; `Routes.mensagemDoConvite(festaId)`; `buildAppRouter` recebe `required ConviteRepository convite`; `abrirApp` ganha o parâmetro opcional com default (**E-5**).
**Where**: `lib/core/routing/app_router.dart` · `lib/core/routing/routes.dart` · `test/support/app_de_teste.dart` · `test/core/routing/app_router_shell_test.dart` (ajuste **R-5**) · `test/core/routing/convite_rotas_test.dart` (novo)
**Depends on**: T17, T23
**Reuses**: O `festas:` opcional com default de `abrirApp` (spec 04) como forma do parâmetro novo · **AD-014**: o teste de rota afirma o **destino**
**Requirement**: CVT-37 AC4, CVT-01, CVT-16

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `/roles/:festaId/whatsapp` renderiza a **`WhatsappPage`** e `/roles/:festaId/whatsapp/convite` renderiza a **`ConvitePage`**, cada uma afirmada por `rotaAtual()` **e** pela página presente
- [ ] A rota filha está **dentro do mesmo `StatefulShellBranch`** — um teste afirma que ir para a filha e voltar **preserva a aba selecionada** (é o que a A-18 comprou)
- [ ] As duas rotas abrem **direto**, sem barra de abas revestindo o shell (**CVT-37 AC4**)
- [ ] `Routes.mensagemDoConvite(festaId)` existe e é a **única** fonte do path — nenhum literal de rota no widget
- [ ] Nenhuma outra rota do mapa da AD-003 muda — teste de regressão sobre as demais abas
- [ ] **R-5 declarado no commit**: `app_router_shell_test.dart:89` deixa de afirmar o placeholder e passa a afirmar a `WhatsappPage`. Asserção **mais forte**; nenhuma outra é tocada
- [ ] Gate `build` passa; exit code conferido
- [ ] ≥ 10 testes novos

**Tests**: widget (rota)
**Gate**: build
**Commit**: `feat(convite): aninha a mensagem do convite sob a aba do WhatsApp`

---

### T25: O injector — as três portas registradas

**What**: `configureDependencies` registra `ConviteRepository` (singleton sobre a **mesma** instância de `FestaEmEdicaoRepository`), `CompartilhadorDeTexto` e `Relogio`, e passa a porta de convite a `buildAppRouter`.
**Where**: `lib/core/di/injector.dart` · `test/core/di/injector_test.dart` (estender)
**Depends on**: T24
**Reuses**: `injector.dart:77-92` — a forma literal do registro do `GaleraRepository` sobre `getIt<FestaEmEdicaoRepository>()`
**Requirement**: CVT-20, CVT-34 (pré-condição)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] As três portas resolvem depois de `configureDependencies()`
- [ ] `ConviteRepository` resolve como **singleton**, e um teste afirma que ele opera sobre a **mesma instância** de festa que a Home e a Galera leem — grava o grupo por uma porta e lê pela outra (é o que faz **CVT-20** valer fora do teste de widget)
- [ ] `resetDependencies()` continua idempotente (FUND-12) com os registros novos
- [ ] Gate `build` passa; exit code conferido
- [ ] ≥ 6 testes novos

**Tests**: unit
**Gate**: build
**Commit**: `feat(convite): registra as portas do convite no container`

---

### T26: CVT-35 — quem fala pela festa para fora

**What**: Os três CTAs consultam `pode(papelDoUsuario(pessoas), Capacidade.editarTudo)`; sem a capacidade ficam desabilitados e os handlers **não** chamam porta nenhuma. **A tabela de RN-22 é consumida, nunca redefinida.**
**Where**: `lib/features/convite/presentation/bloc/{convite,whatsapp}_bloc.dart` (modificar) · as duas páginas (estado do CTA) · `test/features/convite/presentation/permissoes_das_acoes_test.dart` (novo)
**Depends on**: T13, T18, T20
**Reuses**: `capacidadesDe`/`pode`/`papelDoUsuario` de `features/galera/domain/permissoes.dart` (AD-031)
**Requirement**: CVT-35

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Os **quatro** papéis têm teste: ANFITRIÃO e CO-ANFITRIÃO habilitam as três ações; CONVIDADO e SÓ VÊ desabilitam as três
- [ ] Com papel sem capacidade, **zero** chamadas ao compartilhador e ao repositório (contagem) — defesa em profundidade, além do botão desabilitado
- [ ] Um teste de varredura afirma que **nenhum arquivo desta feature** contém uma tabela de papéis própria (nenhuma menção literal a `coAnfitriao` fora do consumo de `permissoes.dart`)
- [ ] **SPEC_DEVIATION declarado no commit e no cabeçalho do arquivo de teste** (**R-3**): CVT-35 diz "não alcançam as telas"; o bloqueio entregue é **da ação**. Bloquear a rota exigiria copy que T-06/T-07 não desenham e uma alteração em `core/routing/**` que a fronteira da spec proíbe
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 12 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(convite): restringe as ações do convite a quem manda na festa`

---

### T27: Os guards — a fórmula não vaza e o domínio é Dart puro

**What**: Os dois testes de varredura de `design.md` §13: nenhuma aritmética em `features/convite/presentation/**`, e nenhum import de Flutter/`share_plus`/Firebase em `features/convite/domain/**`.
**Where**: `test/features/convite/architecture/convite_guards_test.dart` (novo)
**Depends on**: T17, T23
**Reuses**: `test/features/galera/architecture/galera_guards_test.dart` e o `token_purity_guard_test.dart` do design system — **inclusive as duas lições que eles pagaram**
**Requirement**: CVT-15, CVT-25 (fronteira), CVT-24

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] A varredura de `presentation/**` recusa `/`, `*`, `round(`, `toStringAsFixed` e `%` em contexto aritmético, e a falha **nomeia o arquivo infrator**
- [ ] **Teste anti-vácuo**: um trecho sintético infrator é submetido à mesma função de varredura e ela **acusa** — sem isso a varredura passa por estar vazia (lição de `a5932d9`)
- [ ] **Separador de path normalizado** (`\` × `/`) antes de qualquer comparação, com asserção nas **duas** formas — é o bug real que deixou a suíte do DS vermelha só no Windows (`179bab0`)
- [ ] A varredura de `domain/**` recusa `package:flutter`, `package:share_plus` e `firebase`, também com caso sintético infrator
- [ ] A allowlist, se existir, autoriza **forma** e não **arquivo** (lição de `a5932d9`: allowlist por arquivo deixa a segunda violação entrar com a suíte verde)
- [ ] Gate `build` passa; exit code conferido
- [ ] ≥ 10 testes novos

**Tests**: unit (varredura)
**Gate**: build
**Commit**: `test(convite): guarda a fronteira da aritmética e do domínio puro`

---

### T28: O fio de UC-07 — o que o preview mostra é o que o WhatsApp recebe

**What**: O teste ponta a ponta do invariante de **CVT-12**: percorrer as 8 combinações de blocos na `ConvitePage` real, extrair os textos **da árvore renderizada** e compará-los com a string que a porta de compartilhamento recebeu.
**Where**: `test/features/convite/presentation/fio_do_convite_test.dart` (novo)
**Depends on**: T17, T24
**Reuses**: `abrirApp` (T24) para montar pela **rota**, não pelo widget solto — é a lição L-034 do handoff de `galera`: **mutar o adaptador que o app roda**, não o duplo
**Requirement**: CVT-12, CVT-34

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Nas **8** combinações, a lista de textos lida da árvore **é igual, em ordem**, às linhas da string entregue à porta — a igualdade é afirmada linha a linha, não por `contains`
- [ ] O teste é **fail-closed**: uma sonda documentada no arquivo mostra que, removendo uma linha do preview **ou** do serializador, ele fica **vermelho** (é o que separa este teste de um que passaria com os dois lados vazios)
- [ ] O caminho passa pelo `ConviteRepositorioSobreFestas` real sobre `FestaRepositoryEmMemoria`, **não** por duplo de repositório
- [ ] ⚠️ Se o `await` do adaptador não drenar sob o `FakeAsync` do widget tester, use `tester.runAsync` — o precedente e o porquê estão em `galera_route_test.dart` e no handoff do `STATE.md`
- [ ] O mesmo estado (grupo, modelo, voto) é afirmado nas **duas** larguras (**CVT-34**)
- [ ] Gate `build` passa com a suíte inteira; exit code conferido
- [ ] ≥ 12 testes novos

**Tests**: widget
**Gate**: build
**Commit**: `test(convite): amarra o preview ao texto que sai para o WhatsApp`

---

## Phase Execution Map

```
Fase 1 → Fase 2 → Fase 3 → Fase 4 → Fase 5 → Fase 6

Fase 1:  T1 ──→ T2 ──→ T3 ──→ T4
Fase 2:  T5 ──→ T6 ──→ T7 ──→ T8
Fase 3:  T9 ──→ T10 ──→ T11
Fase 4:  T12 ──→ T13 ──→ T14 ──→ T15 ──→ T16 ──→ T17
Fase 5:  T18 ──→ T19 ──→ T20 ──→ T21 ──→ T22 ──→ T23
Fase 6:  T24 ──→ T25 ──→ T26 ──→ T27 ──→ T28
```

**Grafo de dependências reais** (é ele, e não a ordem, que o cross-check confere):

```
T1 ─┬─→ T2 ─────────────┐
    ├─→ T3 ─┬─→ T5 ─→ T6 ├─→ ...
    ├─→ T4 ─┘            │
    ├─→ T9               │
    └─→ T10              │
T4 ─→ T7 ─┬─→ T8 ←───────┘ (T2, T7)
          ├─→ T15
          └─→ T16 ←── T4
T3, T5 ──→ T11
T7, T9, T11 ──→ T12 ──→ T13 ←── T10
T4 ──→ T14
T12, T13, T14, T15, T16 ──→ T17
T4, T11 ──→ T18 ──→ T19 ←── T6
T19, T10, T6 ──→ T20
T4, T18 ──→ T21
T4, T6 ──→ T22
T14, T18, T19, T20, T21, T22 ──→ T23
T17, T23 ──→ T24 ──→ T25
T13, T18, T20 ──→ T26
T17, T23 ──→ T27
T17, T24 ──→ T28
```

**Como o Execute empacota:** 28 tasks. As fases têm 4, 4, 3, 6, 6 e 5 tasks; empacotadas em lotes de ~7 (fases inteiras, nunca partidas), dão **~5 lotes sequenciais**. Como isso é mais de um lote, o Execute **oferece** sub-agentes antes de despachar — e cada lote só começa depois de o anterior reportar todas as tasks concluídas.

---

## Task Granularity Check

| Task | Escopo | Status |
|---|---|---|
| T1 | 1 decisão + 1 dependência (2 arquivos, coesos: a AD **é** a escolha do pacote) | ✅ Granular |
| T2 | 1 campo + 1 linha de preenchimento (2 arquivos da mesma emenda) | ✅ Granular |
| T3 | 2 entidades + 2 campos (uma emenda só, E-2) | ✅ Granular |
| T4 | 1 arquivo de copy | ✅ Granular |
| T5 | 1 catálogo constante | ✅ Granular |
| T6 | 1 entidade + 2 funções puras do mesmo arquivo | ✅ Granular |
| T7 | 1 modelo + 2 funções (2 blocos dos 3) | ✅ Granular |
| T8 | 1 bloco da mesma função | ✅ Granular |
| T9 | 1 porta + 1 adaptador + 1 formatador | ✅ Granular |
| T10 | 1 porta + 1 adaptador | ✅ Granular |
| T11 | 1 porta + 1 adaptador | ✅ Granular |
| T12 | 1 bloc + 1 estado (3 handlers de leitura) | ✅ Granular |
| T13 | 1 handler | ✅ Granular |
| T14 | 1 widget | ✅ Granular |
| T15 | 1 widget | ✅ Granular |
| T16 | 1 widget | ✅ Granular |
| T17 | 1 página | ✅ Granular |
| T18 | 1 bloc + 1 estado | ✅ Granular |
| T19 | 2 handlers coesos (modelo e voto são a mesma máquina) | ✅ Granular |
| T20 | 1 handler | ✅ Granular |
| T21 | 1 widget | ✅ Granular |
| T22 | 2 widgets coesos (seletor + preview que ele governa) | ⚠️ OK — coesos, mesmo arquivo de teste |
| T23 | 1 página | ✅ Granular |
| T24 | 1 emenda de rota (4 arquivos, uma mudança só) | ✅ Granular |
| T25 | 1 arquivo de registro | ✅ Granular |
| T26 | 1 regra atravessando 4 arquivos existentes | ⚠️ OK — é **uma** decisão aplicada; separar por CTA daria três commits que só juntos satisfazem CVT-35 |
| T27 | 1 arquivo de guard | ✅ Granular |
| T28 | 1 arquivo de teste | ✅ Granular |

Nenhum ❌. As duas ⚠️ são coesas por dependência, não por conveniência.

---

## Diagram-Definition Cross-Check

| Task | Depends On (corpo) | Diagrama mostra | Status |
|---|---|---|---|
| T1 | None | (raiz) | ✅ Match |
| T2 | T1 | T1 → T2 | ✅ Match |
| T3 | T1 | T1 → T3 | ✅ Match |
| T4 | T1 | T1 → T4 | ✅ Match |
| T5 | T3, T4 | T3 → T5, T4 → T5 | ✅ Match |
| T6 | T5 | T5 → T6 | ✅ Match |
| T7 | T4 | T4 → T7 | ✅ Match |
| T8 | T2, T7 | T2 → T8, T7 → T8 | ✅ Match |
| T9 | T1 | T1 → T9 | ✅ Match |
| T10 | T1 | T1 → T10 | ✅ Match |
| T11 | T3, T5 | T3 → T11, T5 → T11 | ✅ Match |
| T12 | T7, T9, T11 | T7/T9/T11 → T12 | ✅ Match |
| T13 | T10, T12 | T12 → T13, T10 → T13 | ✅ Match |
| T14 | T4 | T4 → T14 | ✅ Match |
| T15 | T7 | T7 → T15 | ✅ Match |
| T16 | T4, T7 | T4 → T16, T7 → T16 | ✅ Match |
| T17 | T12, T13, T14, T15, T16 | os cinco → T17 | ✅ Match |
| T18 | T4, T11 | T4 → T18, T11 → T18 | ✅ Match |
| T19 | T6, T18 | T18 → T19, T6 → T19 | ✅ Match |
| T20 | T6, T10, T19 | T19/T10/T6 → T20 | ✅ Match |
| T21 | T4, T18 | T4 → T21, T18 → T21 | ✅ Match |
| T22 | T4, T6 | T4 → T22, T6 → T22 | ✅ Match |
| T23 | T14, T18, T19, T20, T21, T22 | os seis → T23 | ✅ Match |
| T24 | T17, T23 | T17 → T24, T23 → T24 | ✅ Match |
| T25 | T24 | T24 → T25 | ✅ Match |
| T26 | T13, T18, T20 | os três → T26 | ✅ Match |
| T27 | T17, T23 | T17 → T27, T23 → T27 | ✅ Match |
| T28 | T17, T24 | T17 → T28, T24 → T28 | ✅ Match |

**Nenhuma dependência aponta para fase posterior.** As três que cruzam fases para trás — T8←T2, T12←T7/T9/T11, T19←T6, T20←T6/T10, T22←T6 — apontam todas para fases anteriores.

---

## Test Co-location Validation

| Task | Camada criada/modificada | Matriz exige | Task diz | Status |
|---|---|---|---|---|
| T1 | `.specs/**`, `pubspec.yaml` | none | none | ✅ OK |
| T2 | `core/calculo/dominio` + `regras` | unit | unit | ✅ OK |
| T3 | `core/festas/dominio` | unit | unit | ✅ OK |
| T4 | Copy (`convite_textos.dart`) | unit | unit | ✅ OK |
| T5 | `convite/domain` | unit | unit | ✅ OK |
| T6 | `convite/domain` | unit | unit | ✅ OK |
| T7 | `convite/domain` | unit | unit | ✅ OK |
| T8 | `convite/domain` | unit | unit | ✅ OK |
| T9 | `convite/domain` | unit | unit | ✅ OK |
| T10 | `convite/domain` + `convite/data` | unit | unit | ✅ OK |
| T11 | `convite/domain` + `convite/data` | unit | unit | ✅ OK |
| T12 | `convite/presentation/bloc` | unit | unit | ✅ OK |
| T13 | `convite/presentation/bloc` | unit | unit | ✅ OK |
| T14 | `convite/presentation/widgets` | widget | widget | ✅ OK |
| T15 | `convite/presentation/widgets` | widget | widget | ✅ OK |
| T16 | `convite/presentation/widgets` | widget | widget | ✅ OK |
| T17 | `convite/presentation/pages` | widget | widget | ✅ OK |
| T18 | `convite/presentation/bloc` | unit | unit | ✅ OK |
| T19 | `convite/presentation/bloc` | unit | unit | ✅ OK |
| T20 | `convite/presentation/bloc` | unit | unit | ✅ OK |
| T21 | `convite/presentation/widgets` | widget | widget | ✅ OK |
| T22 | `convite/presentation/widgets` | widget | widget | ✅ OK |
| T23 | `convite/presentation/pages` | widget | widget | ✅ OK |
| T24 | `core/routing` + `test/support` | widget (rota) | widget (rota) | ✅ OK |
| T25 | `core/di` | unit | unit | ✅ OK |
| T26 | `bloc` + `pages` | widget (a mais alta das duas) | widget | ✅ OK |
| T27 | Guards de fronteira | unit (varredura) | unit (varredura) | ✅ OK |
| T28 | `pages` (teste de fio) | widget | widget | ✅ OK |

**Nenhuma ❌ VIOLATION.** Nenhuma task adia teste para outra: as duas que só testam (T27, T28) **não criam código de produção** — elas afirmam fronteira e invariante sobre código que as tasks anteriores já entregaram com os próprios testes.

---

## Contagem e rastreabilidade

**28 tasks · 6 fases · ~5 lotes de execução.**

| Requisito | Task(s) | Requisito | Task(s) |
|---|---|---|---|
| CVT-01 | T4, T12, T17, T24 | CVT-20 | T11, T25 |
| CVT-02 | T4, T12, T16 | CVT-21 | T11, T18, T21 |
| CVT-03 | T7, T15 | CVT-22 | T4, T18, T21 |
| CVT-04 | T2, T8, T15 | CVT-23 | T4, T19, T22 |
| CVT-05 | T4, T7, T15 | CVT-24 | T5, T6, T22, T27 |
| CVT-06 | T7, T14 | CVT-25 | T6, T19, T22, T27 |
| CVT-07 | T12, T16 | CVT-26 | T6, T11, T19, T22 |
| CVT-08 | T7, T12, T14, T17 | CVT-27 | T3, T11, T19 |
| CVT-09 | T14 | CVT-28 | T9, T12, T14, T19, T22 |
| CVT-10 | T9, T12, T14 | CVT-29 | T6, T20, T23 |
| CVT-11 | T1, T10, T13, T17 | CVT-30 | T20, T23 |
| CVT-12 | T7, T8, T13, T28 | CVT-31 | T1, T10, T20 |
| CVT-13 | T1, T10, T13 | CVT-32 | T14, T17, T23 |
| CVT-14 | T13, T17 | CVT-33 | T17, T23 |
| CVT-15 | T2, T8, T27 | CVT-34 | T23, T25, T28 |
| CVT-16 | T4, T18, T21, T23, T24 | CVT-35 | T26 |
| CVT-17 | T3, T11, T18 | CVT-36 | T1, T10, T13, T20 |
| CVT-18 | T3, T4, T18, T21, T23 | CVT-37 | T11, T12, T18, T24 |
| CVT-19 | T3, T11, T18, T21, T23 | | |

**Cobertura: 37 de 37, zero órfãos.** Cada requisito tem ao menos uma task que o entrega **e** ao menos uma que o afirma por teste.

---

## Antes do Execute — o que precisa de resposta

1. **MCPs e Skills por task.** Todas as 28 estão marcadas `MCP: NONE · Skill: NONE`: o trabalho é Flutter/Dart local, sem API externa e sem biblioteca desconhecida. **Exceção candidata:** a T10 é a primeira integração com `share_plus` neste projeto — o **context7** pode confirmar a API de `SharePlus.instance.share(ShareParams(...))` e os valores de `ShareResultStatus` na versão 13.3.0, em vez de confiar no que o design registrou de memória.
2. **Sub-agentes.** 28 tasks empacotam em ~5 lotes sequenciais — acima do limite de um lote, então o Execute **oferece** os workers. A decisão é do usuário. Lembrete do `STATE.md`: workers rodam **em sequência**, um lote por vez, com `/usage` pedido na fronteira de cada um.
3. **As cinco resoluções R-1..R-5** acima — em especial a **R-3**, que entrega CVT-35 como bloqueio de ação e não de rota. É a única que altera comportamento observável em relação à letra da spec.
