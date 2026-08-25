# Home — Seus rolês — Specification

**ID prefix:** `HOME` · **Porte:** **Grande** (revisto — ver §Porte)
**Design:** `.specs/features/home/design.md` (a produzir)
**Tasks:** `.specs/features/home/tasks.md` (a produzir)
**Context:** `.specs/features/home/context.md`
**Spec-fonte:** T-02 (`04-telas-ux.md`) · W-02 + §Header de app + W-R1..W-R5 (`06-telas-web.md`) · UC-02, UC-24 (`05-casos-de-uso.md`) · RN-28, RN-30 (`03-regras-de-negocio.md`)
**Roadmap:** `.specs/ROADMAP.md` — spec 04, marco M1
**Decisões ativas herdadas:** AD-001..AD-017 · **AD-013** (revestimento do shell) · **AD-016** (dado em memória no M1)
**Depende de:** spec 03 `entrar` — sem sessão não há Home, e o redirect da AD-017 é o que traz o usuário aqui

## Problem Statement

Depois do login, o usuário cai em `/roles` — hoje um `PlaceholderPage` sem cor dentro de um `AppShell` que é literalmente um `KeyedSubtree` vazio. A Home é o painel do produto: é dela que saem os dois caminhos do M1 ("MONTAR LISTA →" para a festa que existe, "🔥 CHURRASCO" para começar outra) e é nela que a promessa de tempo real do BORA aparece pela primeira vez — RN-28 diz que quando um convidado confirma, o contador do anfitrião muda **sem refresh** e o atalho amarelo do acerto aparece sozinho.

O M1 não tem quem produza essa confirmação: quem a produz é o `convidado` (spec 09), no M2. Mas o **lado consumidor** nasce aqui, e nasce reativo — se a Home ler um valor uma vez e desenhar, o M2 vai ter que reescrevê-la. A spec entrega a Home lendo um **stream**, cuja implementação no M1 é em memória (AD-016) e no M2 vira Firestore sem a tela saber.

Esta spec também cumpre a segunda metade da AD-013: revestir o `AppShell` (o header de app de `06`) e o `PlaceholderPage` — o chrome que toda tela logada do M1 usa.

## Goals

- [ ] `/roles` renderiza T-02 em compacto e W-02 em expandido, com a copy literal das specs 04 e 06.
- [ ] O header de app de `06` existe, sticky, com logo, ação contextual "+ NOVO ROLÊ" e avatar amarelo com a inicial do usuário logado.
- [ ] Os contadores "N confirmados · N pendentes" são **reativos**: mudam sem remontar a tela e sem ação do usuário (RN-28, lado consumidor).
- [ ] `FestaRepository` existe como **porta abstrata** com implementação em memória semeada pela fixture RN-30 — a troca por Firestore no M2 não toca em bloc nem em tela.
- [ ] "🎈 NIVER · EM BREVE" não é clicável; "🔥 CHURRASCO" leva a Montar; "MONTAR LISTA →" leva à festa que existe.
- [ ] Quem não tem festa nenhuma vê um estado vazio próprio, e não uma tela quebrada.
- [ ] O arquivo de festas passadas mostra nome, nº de pessoas e total (aceite de UC-24).

## Out of Scope

| Item | Razão |
|---|---|
| Produzir a confirmação de RN-28 | Spec 09 `convidado` (M2). Aqui nasce só o **lado consumidor**, como o roadmap já recorta. |
| Firestore, models, serialização, security rules | **AD-016**: M1 é em memória. A porta abstrata é o que esta spec entrega. |
| Tela de convite / "+ CONVIDAR" | Spec 08 `convite` (UC-07). O botão existe em T-02 e navega para o placeholder da rota `/roles/:festaId/whatsapp`. |
| Tela de acerto / "💸 VER O ACERTO DA FESTA →" | Spec 10 `custos` (UC-19..23). O atalho existe e navega para o placeholder de `/roles/:festaId/custos`. |
| Montar a festa (steppers, chips, duração, custo) | Spec 05 `montar`. A Home só **navega** para lá. |
| Criar festa de tipo NIVER | "EM BREVE" é literal da spec: o slot existe e é explicitamente não clicável. |
| Editar ou excluir festa a partir da Home | Nenhuma tela de 04 ou 06 oferece essas ações. |
| Detalhe de festa passada (tocar numa linha do ARQUIVO) | UC-24 só exige que o histórico **mostre** nome, nº de pessoas e total. Nenhuma spec desenha o destino. |
| Revestir `FestaTabsShell` | Nenhuma tela do M1 monta as abas da festa. Passa para a spec 06 `lista`. |
| Logout pelo avatar | O header de `06` descreve o avatar como elemento, sem ação. Nenhuma spec define o destino. |

---

## Fronteira de arquivos

| Pode tocar | Não pode tocar |
|---|---|
| `lib/features/home/**` | `lib/core/calculo/**` · `lib/core/design_system/**` |
| `lib/core/routing/app_shell.dart` (header de app) | `lib/core/routing/{app_router,routes,festa_tabs_shell}.dart` |
| `lib/core/routing/placeholder_page.dart` (revestimento) | `lib/app.dart` (spec 03) · `lib/features/entrar/**` |
| `lib/core/di/injector.dart` — **só** registro dos próprios | `lib/features/{montar,lista,galera,convite,convidado,custos}/**` |
| `test/features/home/**`, `test/core/routing/{app_shell,placeholder_page}*` | `.specs/{STATE,ROADMAP,LESSONS}.md`, `.specs/lessons.json` |
| `test/fixtures/**` — **só** estender com as festas passadas (A-04) | qualquer teste existente — baseline não pode ser enfraquecido nem apagado |

---

## Assumptions & Open Questions

| # | Assumption / decisão | Default escolhido | Rationale | Confirmado? |
|---|---|---|---|---|
| A-01 | **G8** — origem dos dados | `FestaRepository` é **porta abstrata**; a impl do M1 é em memória, semeada pela fixture RN-30. Firestore no M2 | Confirmado no Discuss da spec 03 (AD-016). A porta é o que torna a troca barata | **y** (2026-08-25) |
| A-02 | RN-28 não tem produtor no M1 | A Home consome um **`Stream`**, não um `Future`. A impl em memória expõe um método de teste que empurra a confirmação, e o AC é afirmado por ele | Ler uma vez e desenhar faria o M2 reescrever a tela. O stream é o contrato que sobrevive à troca de impl | n |
| A-03 | Nenhuma spec descreve a Home **sem festa** | Estado vazio próprio: sub vira "nenhuma festa chegando", o card da festa não renderiza, "COMEÇAR OUTRA" permanece e o ARQUIVO renderiza vazio | Usuário recém-cadastrado (P2 da spec 03) chega aqui com zero festas; sem estado vazio a tela quebra no primeiro uso real | **y** (2026-08-25) |
| A-04 | T-02 diz "2 passadas" e W-02 tem seção ARQUIVO, mas RN-30 define **uma** festa ativa e nenhuma passada | Estender a fixture com **duas** festas concluídas, uma delas a "Churras da laje · 14 pessoas · R$ 612" literal de UC-24, a outra inventada e **marcada como assumption** | Sem elas, "2 passadas" e o ARQUIVO ficam sem dado e o aceite de UC-24 fica sem prova. *(L-002: não afirmar como literal de spec um valor que a spec não define — a segunda festa é declarada aqui como default, não como literal.)* | **y** (2026-08-25) |
| A-05 | O sub "1 festa chegando · 2 passadas" tem números fixos na spec | É **derivado** da contagem real: `{n} festa(s) chegando · {n} passada(s)`, com singular/plural correto. Com a fixture, dá exatamente a string literal de T-02 | Um literal fixo mentiria em qualquer outro estado; o aceite continua sendo a string de T-02, agora como *consequência* do dado | n |
| A-06 | "+ NOVO ROLÊ" (header web) e "🔥 CHURRASCO" (card) fazem a mesma coisa | Ambos navegam para `/roles/novo` | `06` §Header de app diz "na Home a ação é + NOVO ROLÊ" e T-02 diz que CHURRASCO é "clicável → Montar" — mesmo destino, dois pontos de entrada | n |
| A-07 | `06` §Header de app dá "+ NOVO ROLÊ" só no web; T-02 não tem header de app | Em compacto o header de app **não** renderiza a ação — a entrada para criar rolê é o card "🔥 CHURRASCO", como T-02 desenha | T-02 não tem barra de app nenhuma; inventá-la no mobile contrariaria o layout literal |  n |
| A-08 | O avatar do header usa `#FFD23F` — literal de cor no arquivo 06 | `BoraColors.yellow` (= `0xFFFFD23F`), token já existente | O guard de pureza da spec 01 proíbe literal de cor fora de `bora_colors.dart`; o valor coincide | n |
| A-09 | Orçamento de acento do arquivo 02: **máx. 2 por tela** | A Home usa **vermelho** (pendentes, "+ NOVO ROLÊ", valores do arquivo, CTA primário) e **amarelo** (avatar, atalho do acerto) — exatamente 2 | O verde e o roxo não aparecem em T-02 nem em W-02; a regra fica satisfeita sem escolha | n |
| A-10 | "+ CONVIDAR" e o atalho do acerto apontam para telas que não existem no M1 | Navegam para os placeholders de `/roles/:festaId/whatsapp` e `/roles/:festaId/custos` | A rota existe desde a fundação; o destino é a spec 08/10. Navegar para placeholder é honesto e testável — botão inerte não seria | n |
| A-11 | O ARQUIVO só aparece em W-02; T-02 fala em "2 passadas" no sub, sem lista | Em compacto, o arquivo **não** renderiza como lista — só conta no sub. Em expandido, renderiza a seção ARQUIVO | Literal às duas specs; o mobile não desenha a seção | n |
| A-12 | Tocar numa linha do ARQUIVO | **Não navega** — é informação, não ação | Nenhuma spec desenha o destino; inventar rota furaria o mapa canônico da AD-003 | n |

**Open questions:** nenhuma — tudo resolvido ou registrado acima.

---

## Varredura de dimensões implícitas (porte Grande — todas cobertas)

| Dimensão | Cobertura |
|---|---|
| Input validation & bounds | **N/A** — a Home não tem entrada de dado do usuário; toda interação é navegação |
| Failure / partial-failure | HOME-16 (repositório falha → estado de erro visível, não tela branca) |
| Idempotency / retry / duplicate | HOME-17 (toque duplo em "MONTAR LISTA →" navega uma vez) |
| Auth boundaries & rate limits | Herdado de ENT-15..18 (AD-017): `/roles` sem sessão redireciona. **Rate limit: N/A** |
| Concurrency / ordering | HOME-10 (atualização de contador chegando enquanto a tela está montada é aplicada sem remontar) |
| Data lifecycle / expiry | HOME-05 (festa concluída sai de "chegando" e entra no arquivo — a transição de `StatusDaFesta` é o único ciclo de vida da tela). **Expiração: N/A** |
| Observability | HOME-16 (falha do repositório registrada no `AppLogger`, AD-005) |
| External-dependency failure | Coberto por HOME-16 — no M1 o repositório é em memória, mas o contrato de falha nasce agora para o M2 não improvisar |
| State-transition integrity | HOME-09/HOME-10 (a chegada da confirmação muda contadores **e** expõe o atalho, juntos — nunca um sem o outro) |

---

## User Stories

### P1: O chrome do app logado ⭐ MVP

**User Story**: Como anfitrião, quero um header consistente em toda tela logada, para saber sempre onde estou e como criar um rolê.

**Why P1**: É a metade da AD-013 que sobrou, e todas as telas do M1 sob `/roles` dependem dele.

**Acceptance Criteria**:
1. WHEN qualquer rota sob `/roles` é montada em viewport expandida THEN o `AppShell` SHALL renderizar a barra de `06` §Header de app: fundo `paper`, borda inferior de 2px `ink`, logo "BORA." e o avatar do usuário — sticky no topo.
2. WHEN o header renderiza o avatar THEN SHALL usar o amarelo do token (A-08) com borda de 2px e a **inicial do usuário logado**.
3. WHEN a rota corrente é a Home em viewport expandida THEN a ação contextual do header SHALL ser "+ NOVO ROLÊ", navegando para `/roles/novo` (A-06).
4. WHEN a rota corrente é a Home THEN o header SHALL **não** exibir o botão voltar — a Home é a raiz do app logado.
5. WHEN o `AppShell` é varrido por teste THEN SHALL conter **zero** literal de cor, fonte ou sombra.

**Independent Test**: montar uma rota sob `/roles` nos dois viewports e afirmar presença, ordem e tokens dos elementos do header; afirmar a inicial vinda de um usuário-duplo.

---

### P1: Ver o painel de rolês ⭐ MVP

**User Story**: Como anfitrião, quero ver minha festa que está chegando com quem já confirmou, para saber como está o rolê.

**Why P1**: É o fluxo principal de UC-02 e a tela que recebe todo login.

**Acceptance Criteria**:
1. WHEN `/roles` abre em compacto THEN SHALL renderizar, na ordem de T-02: título "SEUS ROLÊS", o subtítulo derivado (A-05), o card da festa e a seção "COMEÇAR OUTRA".
2. WHEN o card da festa renderiza THEN SHALL conter a tag de data rotacionada +3° ("SÁB · 18 JUL" com a fixture), o nome da festa, os avatares empilhados com o "+N" tracejado, a linha "{n} confirmados · {n} pendentes" com **pendentes em vermelho**, e os botões "+ CONVIDAR" (secundário) e "MONTAR LISTA →" (primário).
3. WHEN `/roles` abre em expandido THEN SHALL renderizar W-02: título "SEUS ROLÊS" à esquerda e o subtítulo à direita na mesma linha, e o grid de duas colunas com o card da festa à esquerda e "COMEÇAR OUTRA" + "ARQUIVO" à direita.
4. WHEN a fixture RN-30 é a fonte THEN o subtítulo SHALL ler exatamente "1 festa chegando · 2 passadas" e a linha de contadores exatamente "4 confirmados · 2 pendentes" — os literais de T-02/W-02, agora como consequência do dado.
5. WHEN "MONTAR LISTA →" é acionado THEN SHALL navegar para `/roles/{festaId}/montar` (UC-02 → UC-03).
6. WHEN "+ CONVIDAR" é acionado THEN SHALL navegar para `/roles/{festaId}/whatsapp` (A-10).

**Independent Test**: repositório-duplo com a fixture RN-30; afirmar cada literal nos dois viewports e a rota de destino de cada botão.

---

### P1: O contador muda sozinho ⭐ MVP

**User Story**: Como anfitrião, quero ver a confirmação da galera aparecer sem precisar atualizar a tela, para acompanhar o rolê enchendo.

**Why P1**: É RN-28, a promessa de tempo real do produto. E é o requisito que decide a arquitetura: stream, não leitura única.

**Acceptance Criteria**:
1. WHEN a Home está montada e uma confirmação chega THEN os contadores SHALL passar de "4 confirmados · 2 pendentes" para "5 confirmados · 1 pendente" **sem** remontagem da tela e **sem** ação do usuário.
2. WHEN a confirmação chega THEN o botão amarelo full-width "💸 VER O ACERTO DA FESTA →" SHALL aparecer no card (RN-28 / T-02).
3. WHEN não há confirmação nova THEN o botão amarelo SHALL **não** estar presente — é o par discriminante do AC2.
4. WHEN o atalho amarelo é acionado THEN SHALL navegar para `/roles/{festaId}/custos` (A-10).
5. WHEN a confirmação chega THEN os avatares empilhados e o "+N" SHALL refletir a nova contagem.
6. WHEN a mesma regra é exercida em viewport expandida THEN SHALL valer igual (W-02: "Regra RN-28 vale igual").

**Independent Test**: repositório em memória com a fixture; empurrar uma confirmação pelo stream (A-02) e afirmar contadores novos, atalho presente e ausência do atalho no estado anterior — nos dois viewports, sem `pumpWidget` novo.

---

### P1: Começar outro rolê ⭐ MVP

**User Story**: Como anfitrião, quero começar um churrasco novo direto da Home, para não procurar onde criar.

**Why P1**: É a pré-condição de UC-03 ("festa criada ou template CHURRASCO tocado") — sem ela, a spec 05 `montar` não tem entrada.

**Acceptance Criteria**:
1. WHEN a seção "COMEÇAR OUTRA" renderiza THEN SHALL conter o card "🔥 CHURRASCO" e o slot "🎈 NIVER · EM BREVE" em grid de 2 colunas.
2. WHEN "🔥 CHURRASCO" é acionado THEN SHALL navegar para `/roles/novo`.
3. WHEN "🎈 NIVER · EM BREVE" é acionado THEN **nada** SHALL acontecer: sem navegação, sem toast, sem mudança de estado — e o slot SHALL renderizar tracejado e esmaecido (aceite literal de UC-02).
4. WHEN a seção renderiza em expandido THEN SHALL ocupar a coluna direita do grid de W-02, acima do ARQUIVO.

**Independent Test**: tocar cada card e afirmar a rota corrente depois — mudou para `/roles/novo` no primeiro, **inalterada** no segundo. *(O par presente/ausente é o que discrimina "não clicável".)*

---

### P2: O arquivo de festas passadas

**User Story**: Como anfitrião, quero ver os rolês que já rolaram com quanto deram, para lembrar do histórico.

**Why P2**: UC-24 é secundário a UC-02 e não bloqueia nenhum fluxo do M1; o aceite pede só exibição.

**Acceptance Criteria**:
1. WHEN a Home abre em expandido THEN a seção "ARQUIVO" SHALL renderizar uma linha por festa concluída, com emoji, nome, "· {n} pessoas" e o valor total em vermelho à direita (W-02).
2. WHEN a fixture é a fonte THEN uma das linhas SHALL ler "Churras da laje · 14 pessoas" com total "R$ 612" (literal de UC-24).
3. WHEN o valor total é exibido THEN SHALL usar a formatação de RN-13 vinda de `core/calculo` — inteiro, sem centavos, `pt-BR`.
4. WHEN a Home abre em compacto THEN o arquivo SHALL contar no subtítulo e **não** renderizar como lista (A-11).
5. WHEN uma linha do arquivo é acionada THEN **nada** SHALL acontecer (A-12).

**Independent Test**: afirmar as três colunas de cada linha contra a fixture, a formatação vinda de `MoneyFormatter`, e a ausência da seção em compacto.

---

### P2: A Home de quem não tem festa

**User Story**: Como usuário recém-cadastrado, quero uma Home que faça sentido mesmo vazia, para saber o que fazer primeiro.

**Why P2**: Não bloqueia UC-02 (que pressupõe festa), mas é o primeiro contato de todo usuário que passa pelo cadastro da spec 03.

**Acceptance Criteria**:
1. WHEN o usuário não tem festa nenhuma THEN o card da festa SHALL **não** renderizar e o subtítulo SHALL ler "nenhuma festa chegando" (A-03).
2. WHEN o usuário não tem festa nenhuma THEN a seção "COMEÇAR OUTRA" SHALL continuar presente e funcional — é o único caminho adiante.
3. WHEN o usuário não tem festa passada THEN a seção "ARQUIVO" (expandido) SHALL renderizar vazia, sem linha e sem erro.
4. WHEN o usuário tem festa passada mas nenhuma chegando THEN o subtítulo SHALL ler "nenhuma festa chegando · {n} passadas" (A-05 aplicado às duas metades).

**Independent Test**: repositório-duplo vazio; afirmar ausência do card, o subtítulo, a presença de "COMEÇAR OUTRA" e que a tela renderiza sem exceção.

---

### P2: Placeholder revestido

**User Story**: Como usuário, quero que as telas ainda não construídas pareçam o BORA, para não achar que o app quebrou.

**Why P2**: Cumpre a AD-013. Não bloqueia nenhum fluxo, mas quatro rotas alcançáveis a partir da Home ainda caem em placeholder no M1.

**Acceptance Criteria**:
1. WHEN um `PlaceholderPage` é montado THEN SHALL renderizar com os tokens do arquivo 02 (fundo `paper`, título Archivo Black caixa alta) e **nenhum** literal de cor ou fonte próprio.
2. WHEN um `PlaceholderPage` é montado THEN SHALL preservar a `keyFor(id)` que a fundação instalou — os testes de rota existentes dependem dela e não podem ser enfraquecidos.

**Independent Test**: montar um placeholder e afirmar os tokens na árvore renderizada e a chave preservada.

---

## Edge Cases

- WHEN há mais festas chegando do que uma THEN a Home SHALL renderizar um card por festa, na ordem do repositório, e o subtítulo SHALL pluralizar corretamente.
- WHEN a festa tem 0 pendentes THEN a linha SHALL ler "{n} confirmados · 0 pendentes" — sem esconder o termo e sem texto especial (nenhuma spec define um).
- WHEN a festa tem mais confirmados do que avatares exibidos THEN o "+N" tracejado SHALL mostrar o excedente.
- WHEN a festa tem 3 ou menos confirmados THEN o "+N" SHALL **não** renderizar.
- WHEN a viewport cruza 900px com a Home montada THEN SHALL trocar de layout preservando o estado do stream — sem recarregar o repositório.
- WHEN o nome da festa é longo o bastante para estourar o card THEN SHALL quebrar ou truncar sem overflow de layout, e **nunca** produzir scroll horizontal (W-R4).

---

## Requirement Traceability

| ID | História | Origem na spec-fonte | Fase | Status |
|---|---|---|---|---|
| HOME-01 | P1-1 AC1,AC2 | `06` §Header de app | Design | Pending |
| HOME-02 | P1-1 AC3,AC4 | `06` §Header de app / A-06 | Design | Pending |
| HOME-03 | P1-1 AC5 | AD-011 (guard de pureza) | Design | Pending |
| HOME-04 | P1-2 AC1,AC2 | T-02 | Design | Pending |
| HOME-05 | P1-2 AC3 | W-02 | Design | Pending |
| HOME-06 | P1-2 AC4 | T-02 / RN-30 / A-05 | Design | Pending |
| HOME-07 | P1-2 AC5 | UC-02 passo 2 | Design | Pending |
| HOME-08 | P1-2 AC6 | UC-02 passo 2 / A-10 | Design | Pending |
| HOME-09 | P1-3 AC1,AC5 | RN-28 / UC-02 A1 | Design | Pending |
| HOME-10 | P1-3 AC2,AC3,AC6 | RN-28 / T-02 / W-02 | Design | Pending |
| HOME-11 | P1-3 AC4 | A-10 | Design | Pending |
| HOME-12 | P1-4 AC1,AC2,AC4 | T-02 / W-02 | Design | Pending |
| HOME-13 | P1-4 AC3 | UC-02 (aceite) | Design | Pending |
| HOME-14 | P2-1 AC1..AC5 | W-02 / UC-24 | Design | Pending |
| HOME-15 | P2-2 AC1..AC4 | A-03 | Design | Pending |
| HOME-16 | dimensões: failure, observability | AD-004 / AD-005 | Design | Pending |
| HOME-17 | dimensão: idempotência | — | Design | Pending |
| HOME-18 | P2-3 AC1,AC2 | AD-013 | Design | Pending |
| HOME-19 | A-01 / A-02 (porta + stream) | AD-016 / RN-28 | Design | Pending |

**Cobertura:** 19 requisitos · 0 mapeados a tasks (Design pendente) · 0 órfãos.

---

## Porte — revisão pós-Discuss

O roadmap classificou `home` como **Médio** (Design inline, Tasks inline). Sobe para **Grande**:

1. **`FestaRepository` é herdado por seis specs.** A porta, o formato do stream e a decisão de reatividade (A-02) são consumidos por `montar`, `lista`, `galera`, `convite`, `convidado` e `custos`, e precisam sobreviver à troca da impl em memória por Firestore no M2. Escolha herdada por seis specs é decisão de arquitetura.
2. **O `AppShell` é o chrome de todas as telas logadas.** Errar o header aqui custa retrabalho em sete telas.

Somados às duas plataformas, ao estado vazio, ao arquivo e ao revestimento do placeholder, o corte estimado é de **~11 tasks**, acima do limite de 8. **Design e Tasks passam a ser formais.**

---

## Success Criteria

- [ ] `flutter analyze` = zero issues · suíte inteira verde, baseline preservada.
- [ ] Aceite de UC-02 verificável: contadores refletem RSVP em tempo real e "NIVER · EM BREVE" não é clicável.
- [ ] Aceite de UC-24 verificável: o histórico mostra nome, nº de pessoas e total.
- [ ] Trocar a impl de `FestaRepository` não exige mudar nenhum arquivo de `presentation/`.
- [ ] Nenhum literal de cor, fonte ou sombra em `lib/features/home/**` nem no `AppShell`.
- [ ] Máx. 2 acentos na tela: vermelho e amarelo (A-09).
