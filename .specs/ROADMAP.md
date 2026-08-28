# ROADMAP — BORA.

> Decomposição da especificação (`.specs/init-spec/`) em **specs de feature** para o fluxo da skill `tlc-spec-driven`.
> Cada spec listada aqui vai, **em momento próprio**, passar por: Specify (+ Discuss quando indicado) → Design → Tasks → Execute.
> Este arquivo é o mapa; ele **não substitui** o `spec.md` de cada feature — apenas define recorte, ordem, dependências e porte.
> Decisão registrada em `.specs/STATE.md` como **AD-001**.

---

## 1. Fases e marcos

```
M0 · FUNDAÇÃO            M1 · MONTA E VÊ O CUSTO      M2 · CHAMA A GALERA         M3 · RACHA A CONTA
┌──────────────────┐     ┌─────────────────────┐      ┌──────────────────┐        ┌───────────────┐
│ 00 fundacao      │     │ 03 entrar           │      │ 07 galera        │        │ 10 custos     │
│ 01 design-system │ ──► │ 04 home             │ ──►  │ 08 convite       │  ──►   │               │
│ 02 calculo       │     │ 05 montar           │      │ 09 convidado     │        │               │
└──────────────────┘     │ 06 lista            │      └──────────────────┘        └───────────────┘
                         └─────────────────────┘
```

| Marco | Entrega de valor | Critério verificável |
|---|---|---|
| **M0** | App roda com tema e cálculo testados | `flutter test` verde com os casos literais do arquivo 03: R$ 211/≈R$ 30, R$ 271/≈R$ 45, testes A e B de RN-16; catálogo de componentes renderizando os tokens do arquivo 02 |
| **M1** | Anfitrião monta o churras e vê custo ao vivo, mobile + web | Fluxo UC-01 → UC-03 → UC-06 → UC-16 demonstrável; aceite de UC-03 bate exatamente; W-03 (tela única com rail) funcional |
| **M2** | Loop social completo sem download | Link aberto em navegador anônimo confirma presença (UC-08/09) e a Home do anfitrião atualiza **sem refresh** (RN-28) |
| **M3** | A promessa do produto fecha | Testes A e B de RN-16 reproduzidos na tela; quitação (RN-18) e cobrança (RN-23/UC-23) funcionais |

Dentro de M0, `design-system` e `calculo` são independentes — podem andar em paralelo. `entrar` + `home` também dependem só de M0.

> ## ✅ M0 fechado em 2026-08-25
>
> As três specs da fundação estão implementadas, validadas por Verifier independente e
> **mergeadas em `main`**: `flutter analyze` limpo e **742 testes verdes** — 92 da `fundacao`,
> 344 de `calculo`, 306 de `design-system`.
>
> O critério verificável de M0 bate: os casos literais do arquivo 03 (R$ 211 / ≈R$ 30 e
> R$ 271 / ≈R$ 45) e os Testes A e B de RN-16 estão na suíte como testes literais, e o catálogo
> de componentes renderiza os tokens do arquivo 02 na rota interna `/catalogo`.
>
> **Sem ressalva pendente.** O que os testes provam — cada token com o valor literal da spec —
> está provado por asserção sobre a árvore. O que eles **não** provam é se o conjunto parece o
> protótipo: golden images ficaram fora de escopo por decisão, e nenhum teste da suíte afirma
> aparência. Essa metade foi fechada por **conferência humana**: o usuário validou o `/catalogo`
> em **2026-08-25** nas duas plataformas — web (Chrome 151) e mobile (emulador `Pixel_10`).
> **DS-33 verificada.**

> ## 🟢 M1 em Execute — 2026-08-26 (histórico)
>
> **Spec 03 `entrar` e spec 04 `home` estão completas, validadas e mergeadas na `main`**,
> cada uma com Verifier independente em PASS. A `main` está com **1137 testes verdes** e
> `flutter analyze` limpo. As duas entraram por merge local com `--no-ff`, na ordem da
> dependência (`582f63e` e `34eb1dc`), em vez de PR — o `gh` CLI não está instalado na
> máquina. A `main` local ainda **não foi empurrada**.
>
> Falta do M1: **`montar`** (tem spec e context; falta o design) e **`lista`** (nunca
> especificada). A conferência visual com a skill `run` está pendente para as quatro telas
> já construídas — T-01, W-01, T-02 e W-02.

> ## 🟡 M1 em Specify — 2026-08-25 (histórico)
>
> As specs **03 `entrar`**, **04 `home`** e **05 `montar`** estão **especificadas** (spec + context),
> com o Discuss rodado e quatro decisões registradas: **AD-015** (auth), **AD-016** (dados do M1),
> **AD-017** (guarda de sessão) e **AD-018** ("PROS FORTES" nas duas plataformas; "QUEM LEVA?" fora
> do M1). **Nenhuma linha de código foi escrita** — o próximo passo das três é Design formal.
>
> `entrar` e `home` subiram de Médio para **Grande** (ver ✱✱): Design e Tasks deixam de ser inline.
>
> **A spec 06 `lista` também é do M1 e ainda não foi especificada.** Ela tem Discuss marcado
> (zonas cinzentas G2 e G3) e fica para sessão própria — o critério de M1 no quadro abaixo
> menciona UC-06 e UC-16, que são dela.


> ## ✅ Specify de todas as onze specs concluído — 2026-08-27 (histórico)
>
> As cinco que faltavam — **06 `lista`, 07 `galera`, 08 `convite`, 09 `convidado` e
> 10 `custos`** — foram especificadas nesta sessão. **Todas as onze specs do ROADMAP têm
> agora `spec.md`.** Nenhuma linha de código foi escrita: o trabalho todo é documento.
>
> Antes disso, as **seis zonas cinzentas de §4 foram fechadas com o usuário** e viraram
> **AD-023..AD-028** (`849e0f2`). O Discuss das quatro specs que o exigiam rodou por elas.
>
> | Spec | Commit | Requisitos | Assumptions | Divergências |
> |---|---|---|---|---|
> | 06 `lista` | `1e55911` | LIST-01..35 | 23 | 7 |
> | 07 `galera` | `309a14f` + `8034819` | GAL-01..28 | 19 | — |
> | 08 `convite` | `95754d6` | CVT-01..37 | 28 | 7 |
> | 09 `convidado` | `81055fa` | CVD-01..44 | 26 | 7 |
> | 10 `custos` | `fa92fd8` | CUST-01..37 | 22 | 6 |
>
> **181 requisitos rastreáveis, 118 assumptions e 27 divergências da spec-fonte**, cada
> uma com default e racional no arquivo que a carrega. Duas fecham pendências antigas: a
> **D-5** da spec 04 (dono era a 09) e a **premissa A-16** de `calculo` (dono era a 10).
>
> **Próximo passo das cinco é Design**, na ordem de dependência de §2: `lista` e `galera`
> em paralelo → `convite` e `convidado` → `custos`. Detalhe no `## Handoff` do `STATE.md`.


> ## ✅ Design das onze specs concluído — 2026-08-28
>
> **As onze specs do ROADMAP têm agora `spec.md` + `design.md`.** As quatro que faltavam —
> **07 `galera`, 08 `convite`, 09 `convidado` e 10 `custos`** — foram desenhadas em sessões
> paralelas, e a `main` recebeu tudo por merge. Continua sem uma linha de código novo: o
> trabalho todo é documento, e a baseline segue **1137 testes verdes** com `flutter analyze`
> limpo (conferido em 2026-08-28).
>
> | Spec | Commit do design | Requisitos | AD nova proposta | Tasks |
> |---|---|---|---|---|
> | 05 `montar` | `e7cd070` | MONT-01..24 | **AD-029** — porta de edição em `core/festas/` | ✅ 24 em 7 fases |
> | 06 `lista` | `2854cff` | LIST-01..35 | **AD-030** — estado de lista nas entidades de `core/` | ✅ 27 em 7 fases |
> | 07 `galera` | `02d4571` | GAL-01..28 | **AD-031** — dado do link em `core/festas/`, regra de RN-22 em `permissoes.dart` | ✅ 27 em 5 fases |
> | 08 `convite` | `b4ef1fd` | CVT-01..37 | **AD-032** — `share_plus` atrás de `CompartilhadorDeTexto` | ⬜ |
> | 09 `convidado` | `4b8cefd` | CVD-01..44 | **AD-033** (um documento por festa, RSVP só pela Function) · **AD-034** (identidade do portador; anônimo nunca vira `UsuarioLogado`) | ⬜ |
> | 10 `custos` | `9ca798e` | CUST-01..37 | **AD-035** (estado do acerto derivado na leitura, marcação por par) · **AD-036** (`fimPrevisto` contra relógio injetado) | ⬜ |
>
> **Cobertura requisito → componente: 100% nas seis** (24/24, 35/35, 28/28, 37/37, 44/44, 37/37), zero órfãos.
>
> **Nenhuma dessas oito AD está registrada** no `STATE.md` — o log ativo para na **AD-028**.
> Cada uma é gravada na primeira task do Execute da sua spec, **na ordem numérica**. A reserva
> está no `STATE.md`, logo abaixo da AD-028; quem inverter a ordem renumera a sua, nunca a
> anterior.
>
> **O gargalo é um só: `montar` não foi executada.** `lib/core/festas/` não existe no disco,
> e as cinco specs seguintes o declaram como pré-requisito bloqueante de compilação. As
> `lib/features/{montar,lista,galera,convite,convidado,custos}/` têm hoje só `PlaceholderPage`.
>
> **Próximo passo:** Execute de `montar` (24 tasks, `tasks.md` pronto) → Execute de `lista`
> (27 tasks) → Execute de `galera` (27 tasks, `tasks.md` pronto desde 2026-08-28) → Tasks +
> Execute de `convite` → `convidado` → `custos`. As specs 09 e 10 declaram-se **não
> paralelizáveis**: reescrevem a camada de dados que as anteriores consomem.
>
> **Três specs já têm `tasks.md`** (05, 06 e 07) e **nenhuma** entrou em Execute — o gargalo
> não é planejamento, é o merge de `montar`.

---

## 2. Tabela mestre das specs

Porte segue o auto-sizing da skill (Pequeno / Médio / Grande / Complexo). "Discuss" marcado = há zona cinzenta que precisa de decisão do usuário **antes** do design (detalhe na §4).

| ID | Spec (pasta em `.specs/features/`) | Camada alvo em `lib/` | Escopo (telas · UCs · RNs) | Porte | Discuss | Design | Tasks | Depende de |
|---|---|---|---|---|---|---|---|---|
| 00 | `fundacao` | raiz do projeto | scaffold Flutter + Firebase (emulador) + rotas + DI/BlocObserver + lint + fixture RN-30 + README | **Grande** ✱ | ✅ feito | sim | sim | — |
| 01 | `design-system` | `core/design_system/` | arquivo 02 inteiro: tokens, tipografia, formas, sombras, ~18 componentes, motion · RN-29 (componente toast) | Grande | — | sim | sim | 00 |
| 02 | `calculo` | `core/calculo/` | RN-01..RN-21 (fórmulas, overrides, saldos, quem-paga-quem, efeitos de preferência) · RN-13 (formatação) · entidades de domínio compartilhadas | Grande | — | sim | sim | 00 |
| 03 | `entrar` | `features/entrar/` | T-01, W-01 · UC-01 · **AD-013** (tema no `BoraApp`) | **Grande** ✱✱ | ✅ feito | ✅ feito | ✅ feito | 00, 01 |
| — | **`entrar` mergeada** | — | 16 tasks · Verifier PASS · 947 testes · `582f63e` | — | — | — | — | — |
| 04 | `home` | `features/home/` | T-02, W-02 · UC-02, UC-24 · RN-28 (consumo) | **Grande** ✱✱ | ✅ feito | ✅ feito | ✅ feito | 00, 01, 03 |
| — | **`home` mergeada** | — | 16 tasks · Verifier PASS 19/19 · 1137 testes · `34eb1dc` | — | — | — | — | — |
| 05 | `montar` | `features/montar/` | T-03, W-03 · UC-03, UC-04 · RN-01..10, RN-21 (consumo) | Grande | ✅ feito | ✅ feito | ✅ feito | 01, 02, 04 |
| 06 | `lista` | `features/lista/` | T-04, W-03/W-04 · UC-05, UC-06, UC-14, UC-15, UC-16 · RN-10, RN-11, RN-12, RN-27 | Grande | ✅ feito | ✅ feito | ✅ feito | 01, 02, 05 |
| 07 | `galera` | `features/galera/` | T-05, W-04 · UC-11, UC-12, UC-13 · RN-21, RN-22, RN-23 | Grande | — | ✅ feito | ✅ feito | 01, 02, 04 |
| 08 | `convite` | `features/convite/` | T-06, T-07, W-04 · UC-07, UC-17, UC-18 · RN-25, RN-26, RN-26b | **Complexo** | ✅ feito | ✅ feito | sim | 06, 07 |
| 09 | `convidado` | `features/convidado/` | T-08, W-04 (standalone) · UC-08, UC-09, UC-10 · RN-20, RN-23 (consumo), RN-24, RN-28 | **Complexo** | ✅ feito | ✅ feito | sim | 02, 06, 07 |
| 10 | `custos` | `features/custos/` | T-09, W-04 · UC-19..UC-23 · RN-14..RN-19 (consumo), RN-20 | Grande | ✅ feito | ✅ feito | sim | 02, 09 |

✱ **Revisão pós-Specify (2026-08-12):** a spec 00 subiu de Médio para Grande. O Discuss ampliou o "pronto" da fundação para incluir navegação, DI + BlocObserver, README e espelho de testes (~10 tasks), e essas escolhas — pacote de rotas, container de DI, wiring do emulador — são herdadas por todas as dez specs seguintes. Escolha herdada por dez specs é decisão de arquitetura, então **Design deixou de ser pulado**. Ver `.specs/features/fundacao/spec.md` §Porte.

✱✱ **Revisão pós-Specify (2026-08-25):** `entrar` e `home` subiram de **Médio para Grande**, pelo mesmo critério que subiu a `fundacao` — não por volume de tela, mas porque cada uma origina uma escolha que as specs seguintes herdam. Em `entrar`: a guarda de sessão da **AD-017**, que passa a governar a navegação de sete specs, e a porta `AutenticacaoRepository`. Em `home`: a porta `FestaRepository` e o formato do stream de RN-28 (**AD-016**), consumidos por seis specs e obrigados a sobreviver à troca da impl em memória por Firestore no M2. **Design e Tasks deixam de ser inline nas duas.** Corte estimado: ~11 tasks cada, ~12 em `montar` — **~34 no M1 sem a spec 06**, o que aciona a oferta de sub-agentes no Execute de cada spec.


**Reserva de numeração de AD (2026-08-28).** Os designs propuseram oito decisões que **ainda não estão registradas** no `STATE.md` — o log ativo para na **AD-028**. Cada uma é gravada na primeira task do Execute da sua spec: **AD-029** (`montar`) · **AD-030** (`lista`) · **AD-031** (`galera`) · **AD-032** (`convite`) · **AD-033/AD-034** (`convidado`) · **AD-035/AD-036** (`custos`). A ordem é a da coluna "Depende de"; quem executar fora de ordem renumera **a sua**, nunca a anterior. Tabela completa em `.specs/STATE.md`, logo abaixo da AD-028.

Notas de recorte:

- **`convite` cobre T-06 e T-07** (mensagem por blocos + grupo/enquetes) — é o mesmo domínio WhatsApp e o mapa de telas do arquivo 01 os trata como uma unidade. Dentro do spec, a mensagem por blocos (UC-07) é P1 e grupo/enquetes (UC-17/18) é P2 — dá para entregar em fatias.
- **`entrar` e `home` não estão na lista de features do CLAUDE.md** (montar, galera, lista, convite, custos, convidado), mas T-01/T-02 e UC-01/02/24 precisam morar em algum lugar. O roadmap as adiciona como features próprias; se o design preferir fundi-las (ex.: `home` dentro de uma feature `festa`), registrar como AD no STATE.md.
- **Acoplamento montar ⇄ lista no web:** W-03 funde as duas numa tela só ("não existe passo Fechar lista" no web). O design de `montar` já precisa contemplar o rail; por isso as duas specs são consecutivas e a 06 depende da 05.
- **Entidades compartilhadas** (`Festa`, `Pessoa`, `ItemDeLista`, `Despesa`): a spec `calculo` define onde vivem (candidato natural: `core/calculo/`, Dart puro). Decisão de design a registrar como AD.

---

## 3. Detalhe por spec

### 00 · `fundacao` — Grande · **Specify + Design + Tasks concluídos** (T1–T18) → `.specs/features/fundacao/`
Scaffold do projeto: Flutter multi-plataforma (mobile + web), `pubspec.yaml` com `flutter_lints`, estrutura de pastas da Clean Architecture (CLAUDE.md) com o isolamento de `core/calculo/` **policiado por teste**, navegação com todas as rotas em placeholder (incluindo a pública `/c/:codigo` fora do shell autenticado) e o breakpoint de W-R3, DI + BlocObserver, wiring do Firebase **emulator-first**, fixture RN-30 como dado bruto e README de setup. Sem tela de produto, sem token, sem fórmula. 20 requisitos (FUND-01..20).

Decisões do Discuss: SDK Flutter é pré-requisito externo (instalado à mão, versão registrada no README) · Firebase emulator-first, projeto na nuvem adiado · RN-30 é fixture de teste/demo, **não** seed de onboarding (resolve G7).

⚠️ **Pré-condição bloqueante:** o SDK Flutter/Dart não está instalado na máquina (verificado em 2026-08-12). O Execute não começa antes de `flutter --version` responder.

### 01 · `design-system` — Grande · **Concluída e mergeada** (T1–T32, 2026-08-25) → `.specs/features/design-system/`
`core/design_system/`: todos os tokens do arquivo 02 (cores, tipografia Archivo/Archivo Black, formas radius-0, sombras duras) como tema Flutter, mais o catálogo de componentes: botões primário/secundário (com press que afunda), chip de seleção, segmented, stepper, card de lista, accordion (1 aberto por vez), avatares empilhados, tag de status, **toast (RN-29: 2200 ms, 1 por vez)**, rodapé CTA, card-herói escuro, bottom sheet, barra de faixa de preço, opção de enquete, barra de progresso, inputs, frame do celular. Critério: página-catálogo (widgetbook ou similar interno) onde cada componente é conferível contra o arquivo 02. Nenhuma RN de cálculo aqui.

### 02 · `calculo` — Grande · **Concluída e mergeada** (T1–T28, 2026-08-25) → `.specs/features/calculo/`
`core/calculo/`, **Dart puro, sem Flutter e sem Firebase**. Implementa RN-01..RN-21: contagem de pessoas, fator de duração, quantidades por item, essenciais automáticos, preço médio/faixa, overrides com passos e mínimos, formatação R$ (RN-13), cota justa, saldos, algoritmo quem-paga-quem (RN-16), split de despesa, quitação, "eu levo" como contribuição (RN-20), efeitos de preferências (RN-21: kit veggie, remove suína, cerveja por quem bebe). Os exemplos numéricos do arquivo 03 entram como **testes literais**. Define as entidades de domínio em PT-BR. É a spec mais crítica do produto: tudo que mexe com dinheiro consome esta camada e **nenhuma outra camada recalcula**.

### 03 · `entrar` — Grande · **Specify + Design + Tasks concluídos** (ENT-01..21 · 16 tasks, 2026-08-25) → `.specs/features/entrar/`
T-01/W-01 + UC-01: login e-mail/senha e Google contra o emulador do Auth, pós-login sempre na Home, "CRIAR CONTA" como **modo alternado da mesma tela** (sem rota nova) e guarda de sessão no roteador. A **primeira task é plugar `boraTheme()` no `BoraApp`**, cumprindo a **AD-013** — antes disso o app roda sem tema. Herda também o revestimento do `RouteErrorPage`.

Decisões do Discuss: **AD-015** resolve a zona cinzenta **G1** — vale a spec (e-mail/senha + Google), telefone é **descartado** e o `CLAUDE.md` é corrigido · **AD-016** resolve **G8** — auth real no emulador, dado de festa em memória, Firestore no M2 · **AD-017** — redirect por sessão em `app_router.dart`, com `/c/:codigo`, `/erro` e `/catalogo` sempre livres.

Porte revisto para **Grande** (✱✱): a guarda de sessão e a porta `AutenticacaoRepository` são herdadas por sete specs.

Do Design saíram **AD-019** (a autenticação mora em `lib/core/autenticacao/`, não na feature — `core/routing` e a spec 04 a consomem) e **AD-020** (navegação pós-login é **consequência da guarda**, nunca `context.go` imperativo). O Design também corrigiu a spec: nenhum AC exigia que a senha fosse obscurecida — virou **ENT-21**. Corte final: **16 tasks em 5 fases**, dois batches (T1–T8 infraestrutura, T9–T16 tela). Pronto para Execute.

### 04 · `home` — Grande · **Concluída e validada** (16 tasks, 2026-08-26) → `.specs/features/home/`

Verifier independente em **PASS na 3ª iteração**: 19/19 requisitos com evidência que
discrimina, 37 mutações com 32 mortas em três rodadas de sensor, e duas rodadas de
`code-review` que fecharam 17 defeitos reais — entre eles um que teria posto **sublinhado
duplo amarelo** em todo texto do header no app real. Três decisões nasceram no Execute:
**AD-022** (contadores são dado, com a transição de RN-28 como aceite), **D-1** (o flag de
confirmação nova mora no bloc) e o `id` de `ResumoDeFesta`, que a spec nunca definiu e a
rota exige. Pendências declaradas no `validation.md`, com destaque para o avatar de 40px de
W-02, que é **requisito deferido** e não imprecisão de spec.

### 04 · `home` — Grande · **Specify concluído** (HOME-01..19, 2026-08-25) → `.specs/features/home/`
T-02/W-02 + UC-02, UC-24: painel de rolês com card da festa ativa, contadores confirmados/pendentes **em tempo real** (lado consumidor de RN-28, via **`Stream`** — a impl do M1 é em memória por **AD-016**, e vira Firestore no M2 sem a tela saber), atalho amarelo do acerto, seção "COMEÇAR OUTRA" (NIVER não clicável) e arquivo de festas passadas. Herda da **AD-013** o revestimento do `AppShell` (o header de app de `06`) e do `PlaceholderPage`.

Decisões do Specify: a fixture RN-30 ganha **duas festas concluídas** — uma delas a "Churras da laje · 14 pessoas · R$ 612" literal de UC-24 — porque sem elas "2 passadas", a seção ARQUIVO e o aceite de UC-24 ficam sem dado; e a Home ganha **estado vazio próprio**, que é o que vê todo usuário recém-cadastrado.

Porte revisto para **Grande** (✱✱): a porta `FestaRepository` e o formato do stream são herdados por seis specs. ~11 tasks. Design e Tasks formais.

### 05 · `montar` — Grande · **Specify + Design + Tasks concluídos** (MONT-01..24 · 24 tasks em 7 fases, 2026-08-27) → `.specs/features/montar/`
T-03/W-03 + UC-03, UC-04: steppers de extras sem app, chips de itens, segmented de duração e rodapé "SAI POR" recalculando **a cada toque** via `core/calculo`. No web, a tela única com rail sticky (card-herói + lista viva). Aceite: o exemplo literal do arquivo 03 (**R$ 211 / ≈R$ 30 por cabeça**) renderizado **na tela**, nas duas plataformas.

Decisões do Specify (**AD-018**): **"PROS FORTES" passa a existir nas duas plataformas** — o arquivo 04 a marcava como web-only, mas sem o chip 🍹 CACHAÇA o total mobile fecha R$ 196 e o aceite de UC-03 fica impossível na própria tela que ele descreve · o seletor **"QUEM LEVA?" fica fora do M1**, junto com a dica 💡 que o instrui, entrando com `galera`/`lista` já no formato popover que W-03 pede · o rodapé mostra o total **sem** essenciais (R$ 211/≈R$ 30 por pessoa); o R$ 271/≈R$ 45 por adulto é da tela Lista, e os dois não se unificam · `/roles/novo` abre um **rascunho** com nome e data default editáveis no header, resolvendo a pré-condição de UC-03 que nenhuma tela da spec-fonte cobria.

### 06 · `lista` — Grande · **Specify + Design + Tasks concluídos** (LIST-01..35 · 27 tasks em 7 fases, 2026-08-28) → `.specs/features/lista/`
T-04 + UC-05, UC-06, UC-14, UC-15, UC-16: modos PLANEJAR (média real, faixa mín/máx, overrides com ponto vermelho e RESTAURAR) ⇄ COMPRAR (checklist por corredor, ordem fixa RN-27, contador do carrinho) + sheet de pedido por delivery e overlay "PEDIDO A CAMINHO!". Estado dos checks persiste ao alternar modos; overrides sobrevivem à navegação. ~~**Zonas cinzentas:** origem dos dados de "média de N mercados perto de você" (RN-11) e integração de delivery (RN-27).~~ ✅ **Resolvidas** em 2026-08-27 pelas **AD-023** e **AD-024** (§4, G2 e G3).

Do Design (**AD-030** proposta): o estado de lista da festa — overrides, carrinho, despesas — mora nas entidades de `core/`, nunca na feature. Cinco emendas em `core` nascem aqui (corredor no catálogo, `noCarrinho` na composição, `itensCobraveis`, `faixaRealDaLista`, `despesas` na festa). As zonas cinzentas G2 e G3 já vinham resolvidas por **AD-023** (tabela de preços curada em Dart puro) e **AD-024** (pedido inteiro atrás de porta, com adaptador falso). **27 tasks em 7 fases, 5 batches sequenciais** — Execute bloqueado até `montar` mergear.

### 07 · `galera` — Grande · **Specify + Design + Tasks concluídos** (GAL-01..28 · 27 tasks em 5 fases, 2026-08-28) → `.specs/features/galera/`
T-05 + UC-11, UC-12, UC-13: card do link com nível (RN-23), pessoas com preferências (RN-21) e papéis (RN-22), accordion de edição, faixa-resumo "A lista já se ajusta…". As preferências **realimentam a calculadora** — este spec liga a UI ao efeito RN-21 já implementado em `calculo`. RN-22 (tabela de permissões) nasce aqui como regra de domínio, mas o enforcement é transversal (cada feature respeita o papel; security rules do Firestore entram na spec `convidado`).

Do Design (**AD-031** proposta): o **dado** do acesso (`codigo`, `NivelDoLink`) mora em `core/festas/`, e a **regra** RN-22 × RN-23 mora em `lib/features/galera/domain/permissoes.dart` — consultável, nunca reimplementada. As specs 08, 09 e 10 a importam, e o acoplamento feature↔feature fica registrado como candidato à promoção para `core/` no M2. Lacuna declarada: a bebida é toggle de dois estados e não volta a "não declarado" (T-05 literal), o que muda a cerveja de RN-21. **27 tasks em 5 fases, 5 batches sequenciais** — Execute bloqueado até `montar` mergear, e os dois arquivos de colisão com `lista` (`festa_em_edicao.dart`, `composicao_da_festa.dart`) estão declarados nas tasks T3 e T4.

### 08 · `convite` — Complexo · **Specify + Design concluídos** (CVT-01..37, design em 2026-08-28) · **Tasks pendente** → `.specs/features/convite/`
T-06 + T-07 + UC-07, UC-17, UC-18: mensagem por blocos com preview fiel de bolha (RN-26b), criação de grupo só com confirmados (RN-25), enquetes com voto trocável e trava "CRIE O GRUPO PRIMEIRO" (RN-26). ~~**Zona cinzenta central:** a API pública do WhatsApp não permite criar grupo nem postar enquete programaticamente.~~ ✅ **Resolvida** em 2026-08-27 pela **AD-025** (§4, G4): grupo e enquete são **estado do BORA**; o WhatsApp recebe texto por share sheet / `wa.me`.

Do Design (**AD-032** proposta): `share_plus` como canal único de saída de texto, atrás da porta `CompartilhadorDeTexto`. A zona cinzenta G4 já vinha resolvida por **AD-025** (grupo e enquete são estado do BORA). **Achado do design:** `ItemDeLista.quemLeva` existe e é consumido por RN-20, mas **nenhuma spec o preenchia** — `ComposicaoDaFesta` não tinha campo de origem. A emenda E-3 abre o canal (`atribuicoes`, aditivo); quem escreve continua sendo a spec 09. Sem ela, CVT-04 ("Rafa leva") seria insatisfazível até com a fixture RN-30.

### 09 · `convidado` — Complexo · **Specify + Design concluídos** (CVD-01..44, design em 2026-08-28) · **Tasks pendente** → `.specs/features/convidado/`
T-08 (standalone, sem header de app) + UC-08, UC-09, UC-10: link público `bora.app/c/xxx` abre flyer **sem conta** (auth anônima), RSVP BORA!/NÃO VOU, escolha "eu levo" que desconta da cota (RN-20), confirmação refletindo na Home do anfitrião em tempo real (RN-28). Envolve Hosting (rota pública), Functions (gerar link, notificar anfitrião), security rules por papel do link (RN-23 + RN-22). ~~**Zonas cinzentas:** modelo de segurança do link e identidade do convidado anônimo.~~ ✅ **Resolvidas** em 2026-08-27 pela **AD-026** (§4, G5): link perpétuo, papel lido no instante da abertura, identidade = uid anônimo persistido no dispositivo. É a feature mais crítica do diferencial "responde sem baixar nada".

Do Design (**AD-033** e **AD-034** propostas, com duas decisões do usuário em 2026-08-28): **um documento por festa**, `convites/{codigo}` como índice, e o RSVP escrito **só pela Cloud Function**; a identidade do portador é o uid anônimo do Firebase, que **nunca vira `UsuarioLogado`**. É onde Firestore, Hosting e Functions entram de fato (fecha **G8**), e traz `cloud_functions` — a primeira dependência de produção nova desde o M0. **Não é paralelizável com nenhuma outra spec:** reescreve a camada de dados que as quatro anteriores consomem. Deploy de Functions exige plano Blaze — pré-condição de ida ao ar, não de desenvolvimento.

### 10 · `custos` — Grande · **Specify + Design concluídos** (CUST-01..37, design em 2026-08-28) · **Tasks pendente** → `.specs/features/custos/`
T-09 + UC-19..UC-23: as duas faces da tela (custos da festa com despesas/split/progresso; acerto pós-festa com saldos e quem-paga-quem), meio de pagamento, marcar pago, cobrar pendentes. Toda a aritmética vem de `calculo` (RN-14..RN-18); aceite ancorado nos testes A e B de RN-16. ~~**Zonas cinzentas:** de onde nascem as despesas, e o que "cobrar no Pix" significa.~~ ✅ **Resolvidas** em 2026-08-27 pelas **AD-027** e **AD-028** (§4, G6): despesa nunca se cria à mão (nasce de "EU LEVO", do pedido e do que o anfitrião assume) e a cobrança é **aviso + estado**, sem chave Pix e sem app de banco.

Do Design (**AD-035** e **AD-036** propostas): o estado do acerto (meio de pagamento + marcação **por par**, com o valor no instante da marcação) mora em `core/festas`, é derivado na leitura e escrito por caminho de campo — chave por par é o que sobrevive à regeneração das linhas de RN-16 a cada despesa nova; e o momento da festa vira dado (`fimPrevisto`) lido contra um **relógio injetado**, nunca um controle na tela. Lacunas declaradas: `fimPrevisto` nasce sem quem o preencha (nenhuma tela coleta data/hora reais — `Festa.data` é rótulo), então a face ACERTO degrada para o `status`; e o lembrete de UC-23 não alcança ninguém, por decisão de **AD-028**.

---

## 4. Zonas cinzentas globais (insumo para os Discuss)

Registradas aqui para nenhuma se perder; cada uma é resolvida no Discuss da spec indicada e vira entrada em "Assumptions & Open Questions" do respectivo `spec.md` (ou AD no STATE.md se for transversal).

| # | Zona cinzenta | Spec dona |
|---|---|---|
| ~~G1~~ | ✅ **Resolvida** (2026-08-25, **AD-015**): vale a spec — **e-mail/senha + Google**. Telefone/SMS é **descartado**, não adiado: T-01, W-01 e UC-01 não o mencionam e não há UI desenhada para ele. O `CLAUDE.md` foi corrigido. | `entrar` |
| ~~G2~~ | ✅ **Resolvida** (2026-08-27, **AD-023**): **tabela curada em Dart puro**. A tabela de RN-11 vira fixture tipada em `core/calculo` sobre `PrecoDeMercado`; sem geolocalização e sem consulta — "perto de você" e o `N` de "média de N mercados" são copy e coluna da própria tabela. | `lista` |
| ~~G3~~ | ✅ **Resolvida** (2026-08-27, **AD-024**): **fluxo completo atrás de porta, com adaptador falso**. Sheet, parceiros, subtotal+frete, overlay e a despesa de RN-20 são todos reais; a chamada ao parceiro não. Copy de T-04 fica literal, sem selo de "simulado". | `lista` |
| ~~G4~~ | ✅ **Resolvida** (2026-08-27, **AD-025**): **grupo e enquete são estado do BORA**; o WhatsApp recebe texto por share sheet / `wa.me`. Ação única, voto trocável, `%` e a trava "CRIE O GRUPO PRIMEIRO ☝️" continuam verdadeiros e testáveis. | `convite` |
| ~~G5~~ | ✅ **Resolvida** (2026-08-27, **AD-026**): link **perpétuo**, sem expiração nem revogação; papel lido **no instante da abertura**; identidade do anônimo = uid da auth anônima persistido no dispositivo. Portador do código com papel vigente é modelo de ameaça **aceito**. | `convidado` |
| ~~G6~~ | ✅ **Resolvida** (2026-08-27, **AD-027** e **AD-028**): despesa **não se cria à mão** — nasce de "EU LEVO" (RN-20), do pedido de delivery e do que o anfitrião assume; T-09 não ganha "+ DESPESA". E a cobrança é **aviso + estado**, sem chave Pix, sem BR Code, sem app de banco. | `custos` |
| ~~G7~~ | ✅ **Resolvida** (2026-08-12): RN-30 é **fixture de teste/demo** em Dart puro, não seed de onboarding — nenhum usuário novo ganha festa de exemplo. Nasce como dado bruto na `fundacao` e é tipada pela spec `calculo`. | `fundacao` |
| ~~G8~~ | ✅ **Resolvida** (2026-08-25, **AD-016**): o projeto na nuvem continua adiado. No M1, **auth é real contra o emulador e dado de festa é em memória**, atrás de `FestaRepository` como porta abstrata semeada pela fixture RN-30. **Firestore, Hosting e Functions entram no M2**, com a spec `convidado` — que é quem produz o realtime de RN-28 e a rota pública. | `convidado` |

---

## 5. Matriz de cobertura (nada órfão)

**Telas → spec:** T-01→`entrar` · T-02→`home` · T-03→`montar` · T-04→`lista` · T-05→`galera` · T-06/T-07→`convite` · T-08→`convidado` · T-09→`custos` · W-01→`entrar` · W-02→`home` · W-03→`montar`+`lista` · W-04→distribuída (lista, galera, convite, convidado, custos). Regras W-R1..W-R5 são transversais e entram como critérios nas specs de tela.

**UCs → spec:** UC-01→`entrar` · UC-02, UC-24→`home` · UC-03, UC-04→`montar` (UC-04 também `lista`) · UC-05, UC-06, UC-14, UC-15, UC-16→`lista` · UC-07, UC-17, UC-18→`convite` · UC-08, UC-09, UC-10→`convidado` · UC-11, UC-12, UC-13→`galera` · UC-19..UC-23→`custos`.

**RNs → implementação / consumo:**

| RN | Implementa | Consomem |
|---|---|---|
| RN-01..RN-10 | `calculo` | `montar`, `lista` |
| RN-11, RN-12 | `calculo` | `lista`, `montar` (rail web) |
| RN-13 | `calculo` (formatador) | todas |
| RN-14..RN-18 | `calculo` | `custos`, `convidado` |
| RN-19 | `custos` (estado de UI) | — |
| RN-20 | `calculo` | `convidado`, `custos` |
| RN-21 | `calculo` (efeitos) | `galera`, `montar`, `lista` |
| RN-22 | `galera` (domínio) | transversal + security rules em `convidado` |
| RN-23 | `galera` | `convidado` |
| RN-24 | `convidado` | — |
| RN-25, RN-26, RN-26b | `convite` | — |
| RN-27 | `lista` (ordem/parceiros; totais em `calculo`) | — |
| RN-28 | `convidado` (origem) | `home` (consumo realtime) |
| RN-29 | `design-system` (componente) | todas (textos canônicos) |
| RN-30 | `fundacao` (fixture) | testes e demo |

---

## 6. Como usar este roadmap

1. Ao iniciar uma spec: `tlc-spec-driven` → Specify da feature, partindo do recorte da §3 e resolvendo as zonas cinzentas da §4 no Discuss.
2. O `spec.md` resultante mora em `.specs/features/<nome>/` com IDs rastreáveis; design e tasks seguem o porte da tabela mestre.
3. Ordem sugerida é a numeração (00→10), respeitando as dependências da tabela — mas dentro de cada marco há paralelismo possível (§1).
4. Se um recorte se provar errado durante o Specify de uma feature, atualizar este arquivo **e** registrar a mudança como AD no `STATE.md` — o roadmap deve continuar verdadeiro, como a matriz do arquivo 05.
