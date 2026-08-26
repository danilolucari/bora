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

> ## 🟢 M1 em Execute — 2026-08-26
>
> **Spec 03 `entrar` e spec 04 `home` estão completas e validadas**, cada uma com Verifier
> independente em PASS: `entrar` com 947 testes, `home` com **1136** (+189). As duas vivem em
> branches empilhadas — `feature/home` nasceu de `feature/entrar` — e **nenhum dos dois PRs
> foi aberto**, porque o `gh` CLI não está instalado na máquina.
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


---

## 2. Tabela mestre das specs

Porte segue o auto-sizing da skill (Pequeno / Médio / Grande / Complexo). "Discuss" marcado = há zona cinzenta que precisa de decisão do usuário **antes** do design (detalhe na §4).

| ID | Spec (pasta em `.specs/features/`) | Camada alvo em `lib/` | Escopo (telas · UCs · RNs) | Porte | Discuss | Design | Tasks | Depende de |
|---|---|---|---|---|---|---|---|---|
| 00 | `fundacao` | raiz do projeto | scaffold Flutter + Firebase (emulador) + rotas + DI/BlocObserver + lint + fixture RN-30 + README | **Grande** ✱ | ✅ feito | sim | sim | — |
| 01 | `design-system` | `core/design_system/` | arquivo 02 inteiro: tokens, tipografia, formas, sombras, ~18 componentes, motion · RN-29 (componente toast) | Grande | — | sim | sim | 00 |
| 02 | `calculo` | `core/calculo/` | RN-01..RN-21 (fórmulas, overrides, saldos, quem-paga-quem, efeitos de preferência) · RN-13 (formatação) · entidades de domínio compartilhadas | Grande | — | sim | sim | 00 |
| 03 | `entrar` | `features/entrar/` | T-01, W-01 · UC-01 · **AD-013** (tema no `BoraApp`) | **Grande** ✱✱ | ✅ feito | ✅ feito | ✅ feito | 00, 01 |
| — | **`entrar` concluída** | — | 16 tasks · Verifier PASS · 947 testes · PR por abrir | — | — | — | — | — |
| 04 | `home` | `features/home/` | T-02, W-02 · UC-02, UC-24 · RN-28 (consumo) | **Grande** ✱✱ | ✅ feito | ✅ feito | ✅ feito | 00, 01, 03 |
| — | **`home` concluída** | — | 16 tasks · Verifier PASS 19/19 · 1136 testes · PR por abrir | — | — | — | — | — |
| 05 | `montar` | `features/montar/` | T-03, W-03 · UC-03, UC-04 · RN-01..10, RN-21 (consumo) | Grande | ✅ feito | sim | sim | 01, 02, 04 |
| 06 | `lista` | `features/lista/` | T-04, W-03/W-04 · UC-05, UC-06, UC-14, UC-15, UC-16 · RN-10, RN-11, RN-12, RN-27 | Grande | **sim** | sim | sim | 01, 02, 05 |
| 07 | `galera` | `features/galera/` | T-05, W-04 · UC-11, UC-12, UC-13 · RN-21, RN-22, RN-23 | Grande | — | sim | sim | 01, 02, 04 |
| 08 | `convite` | `features/convite/` | T-06, T-07, W-04 · UC-07, UC-17, UC-18 · RN-25, RN-26, RN-26b | **Complexo** | **sim** | sim + pesquisa | sim | 06, 07 |
| 09 | `convidado` | `features/convidado/` | T-08, W-04 (standalone) · UC-08, UC-09, UC-10 · RN-20, RN-23 (consumo), RN-24, RN-28 | **Complexo** | **sim** | sim + pesquisa | sim | 02, 06, 07 |
| 10 | `custos` | `features/custos/` | T-09, W-04 · UC-19..UC-23 · RN-14..RN-19 (consumo), RN-20 | Grande | **sim** | sim | sim | 02, 09 |

✱ **Revisão pós-Specify (2026-08-12):** a spec 00 subiu de Médio para Grande. O Discuss ampliou o "pronto" da fundação para incluir navegação, DI + BlocObserver, README e espelho de testes (~10 tasks), e essas escolhas — pacote de rotas, container de DI, wiring do emulador — são herdadas por todas as dez specs seguintes. Escolha herdada por dez specs é decisão de arquitetura, então **Design deixou de ser pulado**. Ver `.specs/features/fundacao/spec.md` §Porte.

✱✱ **Revisão pós-Specify (2026-08-25):** `entrar` e `home` subiram de **Médio para Grande**, pelo mesmo critério que subiu a `fundacao` — não por volume de tela, mas porque cada uma origina uma escolha que as specs seguintes herdam. Em `entrar`: a guarda de sessão da **AD-017**, que passa a governar a navegação de sete specs, e a porta `AutenticacaoRepository`. Em `home`: a porta `FestaRepository` e o formato do stream de RN-28 (**AD-016**), consumidos por seis specs e obrigados a sobreviver à troca da impl em memória por Firestore no M2. **Design e Tasks deixam de ser inline nas duas.** Corte estimado: ~11 tasks cada, ~12 em `montar` — **~34 no M1 sem a spec 06**, o que aciona a oferta de sub-agentes no Execute de cada spec.


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

### 05 · `montar` — Grande · **Specify concluído** (MONT-01..24, 2026-08-25) → `.specs/features/montar/`
T-03/W-03 + UC-03, UC-04: steppers de extras sem app, chips de itens, segmented de duração e rodapé "SAI POR" recalculando **a cada toque** via `core/calculo`. No web, a tela única com rail sticky (card-herói + lista viva). Aceite: o exemplo literal do arquivo 03 (**R$ 211 / ≈R$ 30 por cabeça**) renderizado **na tela**, nas duas plataformas.

Decisões do Specify (**AD-018**): **"PROS FORTES" passa a existir nas duas plataformas** — o arquivo 04 a marcava como web-only, mas sem o chip 🍹 CACHAÇA o total mobile fecha R$ 196 e o aceite de UC-03 fica impossível na própria tela que ele descreve · o seletor **"QUEM LEVA?" fica fora do M1**, junto com a dica 💡 que o instrui, entrando com `galera`/`lista` já no formato popover que W-03 pede · o rodapé mostra o total **sem** essenciais (R$ 211/≈R$ 30 por pessoa); o R$ 271/≈R$ 45 por adulto é da tela Lista, e os dois não se unificam · `/roles/novo` abre um **rascunho** com nome e data default editáveis no header, resolvendo a pré-condição de UC-03 que nenhuma tela da spec-fonte cobria.

### 06 · `lista` — Grande, com Discuss
T-04 + UC-05, UC-06, UC-14, UC-15, UC-16: modos PLANEJAR (média real, faixa mín/máx, overrides com ponto vermelho e RESTAURAR) ⇄ COMPRAR (checklist por corredor, ordem fixa RN-27, contador do carrinho) + sheet de pedido por delivery e overlay "PEDIDO A CAMINHO!". Estado dos checks persiste ao alternar modos; overrides sobrevivem à navegação. **Zonas cinzentas:** origem dos dados de "média de N mercados perto de você" (RN-11 — a tabela da spec é fixture; o produto real precisa de fonte de preços + localização) e integração de delivery (RN-27 — iFood/Rappi/Zé não têm API pública de pedido; decidir o que é real vs. simulado).

### 07 · `galera` — Grande
T-05 + UC-11, UC-12, UC-13: card do link com nível (RN-23), pessoas com preferências (RN-21) e papéis (RN-22), accordion de edição, faixa-resumo "A lista já se ajusta…". As preferências **realimentam a calculadora** — este spec liga a UI ao efeito RN-21 já implementado em `calculo`. RN-22 (tabela de permissões) nasce aqui como regra de domínio, mas o enforcement é transversal (cada feature respeita o papel; security rules do Firestore entram na spec `convidado`).

### 08 · `convite` — Complexo, com Discuss
T-06 + T-07 + UC-07, UC-17, UC-18: mensagem por blocos com preview fiel de bolha (RN-26b), criação de grupo só com confirmados (RN-25), enquetes com voto trocável e trava "CRIE O GRUPO PRIMEIRO" (RN-26). **Zona cinzenta central:** a API pública do WhatsApp **não permite criar grupo nem postar enquete programaticamente** — o Discuss precisa decidir o que RN-25/RN-26 significam no produto real (deep link `wa.me`/share sheet + estado interno? Cloud API com template? simulação assumida?). O design exige pesquisa (Knowledge Verification Chain) antes de fixar abordagem.

### 09 · `convidado` — Complexo, com Discuss
T-08 (standalone, sem header de app) + UC-08, UC-09, UC-10: link público `bora.app/c/xxx` abre flyer **sem conta** (auth anônima), RSVP BORA!/NÃO VOU, escolha "eu levo" que desconta da cota (RN-20), confirmação refletindo na Home do anfitrião em tempo real (RN-28). Envolve Hosting (rota pública), Functions (gerar link, notificar anfitrião), security rules por papel do link (RN-23 + RN-22). **Zonas cinzentas:** modelo de segurança do link (qualquer portador entra com o papel configurado — expiração? revogação? troca de nível após aberturas?), identidade do convidado anônimo entre sessões/dispositivos. É a feature mais crítica do diferencial "responde sem baixar nada".

### 10 · `custos` — Grande, com Discuss
T-09 + UC-19..UC-23: as duas faces da tela (custos da festa com despesas/split/progresso; acerto pós-festa com saldos e quem-paga-quem), meio de pagamento, marcar pago, cobrar pendentes. Toda a aritmética vem de `calculo` (RN-14..RN-18); aceite ancorado nos testes A e B de RN-16. **Zonas cinzentas:** a spec **não tem UC de criar/editar despesa** (UC-19 só lista — de onde nascem as despesas além do pedido RN-20?) e a cobrança "no Pix" precisa de definição (Pix copia-e-cola? deep link? só notificação?).

---

## 4. Zonas cinzentas globais (insumo para os Discuss)

Registradas aqui para nenhuma se perder; cada uma é resolvida no Discuss da spec indicada e vira entrada em "Assumptions & Open Questions" do respectivo `spec.md` (ou AD no STATE.md se for transversal).

| # | Zona cinzenta | Spec dona |
|---|---|---|
| ~~G1~~ | ✅ **Resolvida** (2026-08-25, **AD-015**): vale a spec — **e-mail/senha + Google**. Telefone/SMS é **descartado**, não adiado: T-01, W-01 e UC-01 não o mencionam e não há UI desenhada para ele. O `CLAUDE.md` foi corrigido. | `entrar` |
| G2 | Fonte real dos preços médios "de N mercados perto de você" (RN-11) — dado vivo ou tabela curada? | `lista` |
| G3 | Delivery iFood/Rappi/Zé (RN-27): integração real inexistente — simular, linkar ou cortar do MVP? | `lista` |
| G4 | WhatsApp (RN-25/26): grupo e enquete não são criáveis por API pública — o que é real no produto? | `convite` |
| G5 | Segurança do link público: expiração, revogação, mudança de nível pós-abertura, identidade do anônimo | `convidado` |
| G6 | Origem das despesas (não há UC de criação) e mecânica real da cobrança Pix | `custos` |
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
