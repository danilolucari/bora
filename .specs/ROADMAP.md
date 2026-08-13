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

---

## 2. Tabela mestre das specs

Porte segue o auto-sizing da skill (Pequeno / Médio / Grande / Complexo). "Discuss" marcado = há zona cinzenta que precisa de decisão do usuário **antes** do design (detalhe na §4).

| ID | Spec (pasta em `.specs/features/`) | Camada alvo em `lib/` | Escopo (telas · UCs · RNs) | Porte | Discuss | Design | Tasks | Depende de |
|---|---|---|---|---|---|---|---|---|
| 00 | `fundacao` | raiz do projeto | scaffold Flutter + Firebase + rotas + lint + fixtures (RN-30) | Médio | — | skip | inline | — |
| 01 | `design-system` | `core/design_system/` | arquivo 02 inteiro: tokens, tipografia, formas, sombras, ~18 componentes, motion · RN-29 (componente toast) | Grande | — | sim | sim | 00 |
| 02 | `calculo` | `core/calculo/` | RN-01..RN-21 (fórmulas, overrides, saldos, quem-paga-quem, efeitos de preferência) · RN-13 (formatação) · entidades de domínio compartilhadas | Grande | — | sim | sim | 00 |
| 03 | `entrar` | `features/entrar/` | T-01, W-01 · UC-01 | Médio | **sim** | inline | inline | 00, 01 |
| 04 | `home` | `features/home/` | T-02, W-02 · UC-02, UC-24 · RN-28 (consumo) | Médio | — | inline | inline | 00, 01, 03 |
| 05 | `montar` | `features/montar/` | T-03, W-03 · UC-03, UC-04 · RN-01..10, RN-21 (consumo) | Grande | — | sim | sim | 01, 02, 04 |
| 06 | `lista` | `features/lista/` | T-04, W-03/W-04 · UC-05, UC-06, UC-14, UC-15, UC-16 · RN-10, RN-11, RN-12, RN-27 | Grande | **sim** | sim | sim | 01, 02, 05 |
| 07 | `galera` | `features/galera/` | T-05, W-04 · UC-11, UC-12, UC-13 · RN-21, RN-22, RN-23 | Grande | — | sim | sim | 01, 02, 04 |
| 08 | `convite` | `features/convite/` | T-06, T-07, W-04 · UC-07, UC-17, UC-18 · RN-25, RN-26, RN-26b | **Complexo** | **sim** | sim + pesquisa | sim | 06, 07 |
| 09 | `convidado` | `features/convidado/` | T-08, W-04 (standalone) · UC-08, UC-09, UC-10 · RN-20, RN-23 (consumo), RN-24, RN-28 | **Complexo** | **sim** | sim + pesquisa | sim | 02, 06, 07 |
| 10 | `custos` | `features/custos/` | T-09, W-04 · UC-19..UC-23 · RN-14..RN-19 (consumo), RN-20 | Grande | **sim** | sim | sim | 02, 09 |

Notas de recorte:

- **`convite` cobre T-06 e T-07** (mensagem por blocos + grupo/enquetes) — é o mesmo domínio WhatsApp e o mapa de telas do arquivo 01 os trata como uma unidade. Dentro do spec, a mensagem por blocos (UC-07) é P1 e grupo/enquetes (UC-17/18) é P2 — dá para entregar em fatias.
- **`entrar` e `home` não estão na lista de features do CLAUDE.md** (montar, galera, lista, convite, custos, convidado), mas T-01/T-02 e UC-01/02/24 precisam morar em algum lugar. O roadmap as adiciona como features próprias; se o design preferir fundi-las (ex.: `home` dentro de uma feature `festa`), registrar como AD no STATE.md.
- **Acoplamento montar ⇄ lista no web:** W-03 funde as duas numa tela só ("não existe passo Fechar lista" no web). O design de `montar` já precisa contemplar o rail; por isso as duas specs são consecutivas e a 06 depende da 05.
- **Entidades compartilhadas** (`Festa`, `Pessoa`, `ItemDeLista`, `Despesa`): a spec `calculo` define onde vivem (candidato natural: `core/calculo/`, Dart puro). Decisão de design a registrar como AD.

---

## 3. Detalhe por spec

### 00 · `fundacao` — Médio
Scaffold do projeto: Flutter multi-plataforma (mobile + web), `pubspec.yaml` com `flutter_lints`, estrutura de pastas da Clean Architecture (CLAUDE.md), inicialização Firebase (Auth, Firestore, Hosting, Functions — só o wiring), `AppRouter`, fixture do estado inicial (RN-30) para testes e demo. Sem tela de produto. Design skip — as decisões já estão no CLAUDE.md; tasks inline.

### 01 · `design-system` — Grande
`core/design_system/`: todos os tokens do arquivo 02 (cores, tipografia Archivo/Archivo Black, formas radius-0, sombras duras) como tema Flutter, mais o catálogo de componentes: botões primário/secundário (com press que afunda), chip de seleção, segmented, stepper, card de lista, accordion (1 aberto por vez), avatares empilhados, tag de status, **toast (RN-29: 2200 ms, 1 por vez)**, rodapé CTA, card-herói escuro, bottom sheet, barra de faixa de preço, opção de enquete, barra de progresso, inputs, frame do celular. Critério: página-catálogo (widgetbook ou similar interno) onde cada componente é conferível contra o arquivo 02. Nenhuma RN de cálculo aqui.

### 02 · `calculo` — Grande
`core/calculo/`, **Dart puro, sem Flutter e sem Firebase**. Implementa RN-01..RN-21: contagem de pessoas, fator de duração, quantidades por item, essenciais automáticos, preço médio/faixa, overrides com passos e mínimos, formatação R$ (RN-13), cota justa, saldos, algoritmo quem-paga-quem (RN-16), split de despesa, quitação, "eu levo" como contribuição (RN-20), efeitos de preferências (RN-21: kit veggie, remove suína, cerveja por quem bebe). Os exemplos numéricos do arquivo 03 entram como **testes literais**. Define as entidades de domínio em PT-BR. É a spec mais crítica do produto: tudo que mexe com dinheiro consome esta camada e **nenhuma outra camada recalcula**.

### 03 · `entrar` — Médio, com Discuss
T-01/W-01 + UC-01: login e-mail/senha e Google, pós-login sempre na Home. **Zona cinzenta bloqueante:** o CLAUDE.md decidiu "Auth Google + telefone", mas a spec (T-01, UC-01) mostra e-mail/senha + Google e não menciona telefone — conflito real a resolver no Discuss antes de implementar. Inclui "CRIAR CONTA".

### 04 · `home` — Médio
T-02/W-02 + UC-02, UC-24: painel de rolês com card da festa ativa, contadores confirmados/pendentes **em tempo real** (lado consumidor de RN-28, via stream do Firestore), atalho amarelo do acerto, seção "COMEÇAR OUTRA" (NIVER não clicável) e arquivo de festas passadas.

### 05 · `montar` — Grande
T-03/W-03 + UC-03, UC-04: steppers de extras sem app, chips de itens (grelha/geladeira/fortes — fortes só no web mobile-first? conferir no Specify: o arquivo 04 põe "PROS FORTES" como web-only em T-03), segmented de duração, rodapé "SAI POR" recalculando **a cada toque** via `core/calculo`. No web, é a tela única com rail sticky (card-herói + lista viva + "QUEM LEVA?"). Aceite: exemplo literal do arquivo 03 (R$ 211 / ≈R$ 30). Atenção à evolução pendente registrada em W-03: o seletor "quem leva" deve ser popover/sheet com lista de confirmados, não o botão que cicla.

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
| G1 | Auth: e-mail/senha (spec 04/05) × "Google + telefone" (CLAUDE.md) | `entrar` |
| G2 | Fonte real dos preços médios "de N mercados perto de você" (RN-11) — dado vivo ou tabela curada? | `lista` |
| G3 | Delivery iFood/Rappi/Zé (RN-27): integração real inexistente — simular, linkar ou cortar do MVP? | `lista` |
| G4 | WhatsApp (RN-25/26): grupo e enquete não são criáveis por API pública — o que é real no produto? | `convite` |
| G5 | Segurança do link público: expiração, revogação, mudança de nível pós-abertura, identidade do anônimo | `convidado` |
| G6 | Origem das despesas (não há UC de criação) e mecânica real da cobrança Pix | `custos` |
| G7 | RN-30 (estado inicial "Churras do Rafa"): fixture de demo/teste ou seed de onboarding do produto? | `fundacao` |

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
