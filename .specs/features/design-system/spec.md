# Design System "Convite" — Specification

**ID prefix:** `DS` · **Porte:** Grande
**Design:** `.specs/features/design-system/design.md`
**Tasks:** `.specs/features/design-system/tasks.md`
**Spec-fonte:** `.specs/init-spec/02-design-system.md` (§1 a §8) + RN-29 (`.specs/init-spec/03-regras-de-negocio.md`)
**Roadmap:** `.specs/ROADMAP.md` — spec 01, marco M0
**Decisões ativas herdadas:** AD-001..AD-007 (`.specs/STATE.md`)

## Problem Statement

A fundação (spec 00) entregou um app que compila, navega e testa — e deliberadamente **sem um único token**: placeholders sem cor, sem fonte, sem forma. As oito specs de tela (03–10) só podem nascer depois que existir uma camada onde cor, tipografia, forma, sombra, motion e componente sejam **valores nomeados e testados**, e não literais copiados de tela em tela. Sem essa camada, cada tela reinventa o `#FF4D2E`, o `4px 4px 0`, o `2px solid #141414` — e a promessa do arquivo 02 ("o resultado tem que ficar **exatamente igual** ao protótipo") morre por mil desvios de 1px.

O estilo é neo-brutalista e **literal**: radius 0, sombra sem blur, sem gradiente, só Archivo. São regras fáceis de violar por descuido e impossíveis de detectar por revisão de código à distância. Esta spec entrega os tokens, os ~18 componentes do arquivo 02, o toast de RN-29 — e, principalmente, **as leis do arquivo 02 policiadas por teste**, na mesma tradição do `calculo_isolation_test.dart` que a fundação instalou.

## Goals

- [ ] Toda cor, tipo, forma, sombra e duração do arquivo 02 existe como token nomeado em `lib/core/design_system/`, com o valor literal da spec afirmado por teste.
- [ ] Os ~18 componentes de §5 (mais os três elementos de forma de §3 e o toast de RN-29) existem, cada um com widget test que afirma o token **na árvore renderizada**, não no código-fonte.
- [ ] As proibições de §8 são **executáveis**: radius arredondado, sombra com blur, gradiente, cor/fonte fora do token e texto abaixo de 9px quebram `flutter test`, nomeando o arquivo infrator.
- [ ] As duas fontes viajam com o repositório (sem rede, sem CDN, sem pacote novo) e os pesos 400–800 de §2 chegam ao texto rasterizado.
- [ ] `/catalogo` abre em mobile e web mostrando cada componente, para conferência a olho contra o arquivo 02 — o critério de M0 declarado no roadmap.
- [ ] Nenhum componente calcula ou formata nada: a fronteira com `core/calculo/` é policiada por teste de import.

## Out of Scope

Explicitamente excluído. Documentado para evitar scope creep.

| Item | Razão |
|---|---|
| Qualquer tela de produto (T-01..T-09, W-01..W-04) | São as specs 03–10. Esta spec entrega peças, não telas. |
| Qualquer aritmética: quantidade, custo, cota, saldo, fração de faixa de preço, formatação `R$` | Spec 02 `calculo` (RN-01..RN-21, RN-13). Componentes recebem `double` já calculado e `String` já formatada. |
| Qualquer acesso a Firebase, rede ou persistência | Nenhum componente do arquivo 02 tem dado próprio. |
| Redefinir o breakpoint de W-R3 | **AD-007**: mora em `core/responsive/`. Esta spec **consome** `LayoutMode`; não redeclara `900.0`. |
| Aplicar o tema no `BoraApp` (`lib/app.dart`) | `lib/app.dart` não pertence a esta spec (ver §Fronteira de arquivos). `boraTheme()` nasce e é testado aqui; **quem o pluga no app é a spec 03 `entrar`**. |
| Revestir `PlaceholderPage`, `RouteErrorPage`, `AppShell`, `FestaTabsShell` | Ficaram de herança da fundação para "a spec 01 revestir", mas revestir o chrome é decidir layout de tela — e o arquivo 02 não especifica o header do app. Passa para a spec 03/04, que têm T-01/T-02 para se ancorar. |
| Regra "máx. 2 acentos por tela" | É uma regra **de tela**, e telas estão fora. O que esta spec entrega é o mecanismo que a torna possível: acento como conjunto fechado com significado fixo (DS-08). O orçamento por tela é critério das specs 03–10. |
| Golden images | Decisão de design (ver `design.md`): asserção de propriedade nomeia o valor da spec e discrimina melhor; golden exigiria carregar fonte em todo teste e rasterização dependente de plataforma. |
| Dependência nova (widgetbook, google_fonts, storybook) | **D2/AD-002**: catálogo é rota interna, fontes são bundladas. Zero pacote novo. |
| CI | `CLAUDE.md` proíbe criar sem pedido explícito. |

---

## Fronteira de arquivos (dura)

Esta spec roda em paralelo com a spec 02 `calculo`. Para que o merge não colida, os arquivos que ela pode tocar são fechados:

| Pode tocar | Não pode tocar |
|---|---|
| `lib/core/design_system/**` | `lib/core/calculo/**` (spec 02 — colisão de merge garantida) |
| `test/core/design_system/**` | `lib/app.dart`, `lib/main.dart`, `lib/bootstrap/**` |
| `assets/**` | `lib/core/{di,firebase,observability,responsive}/**` |
| `pubspec.yaml` — **só** as seções `assets:` e `fonts:` | `lib/features/**` |
| `lib/core/routing/app_router.dart` e `routes.dart` — **só** a rota do catálogo | `.specs/STATE.md`, `.specs/ROADMAP.md`, `.specs/LESSONS.md`, `.specs/lessons.json` |
| `test/core/routing/**` — **só** o teste da rota do catálogo | qualquer teste existente (92 testes de baseline não podem ser enfraquecidos nem apagados) |

**Baseline a preservar:** `flutter test` = 92 passando · `flutter analyze` = zero issues (verificado em 2026-08-20 no worktree `feature/design-system`).

---

## Assumptions & Open Questions

Toda ambiguidade do arquivo 02 resolvida ou registrada aqui — nada fica silenciosamente indefinido.

| # | Assumption / decisão | Default escolhido | Rationale | Confirmado? |
|---|---|---|---|---|
| A-01 | §2 dá **faixas** de tamanho ("22–24px", "26–40px"); faixa não é testável | Cada papel vira token com o **limite inferior** da faixa; onde a faixa é larga o bastante para ser dois papéis distintos (título de card 26/40, botão 12/16), nascem **dois tokens nomeados nos extremos**. Nenhum valor fora da faixa. | Extremos são literais da spec; um valor no meio seria invenção | n |
| A-02 | §2 permite micro-tag **8.5px**, §8 e o `CLAUDE.md` proíbem texto de UI **abaixo de 9px** — conflito real dentro da spec-fonte | **Piso 9.0px vence.** `microTag` = 9.0–10.5px | §8 é a lista "não fazer" (lei) e o `CLAUDE.md` a repete; 8.5 é o único número do arquivo 02 que a viola | n |
| A-03 | §4 exige o press-sink mas não dá duração | 150ms — a duração de §6 para "botões de estado" | O CTA é botão de estado; inventar outro número criaria uma segunda velocidade no sistema | n |
| A-04 | `transition: all .15s` não declara timing-function | `Curves.ease` (o default do CSS) em todo motion do sistema; `toastIn` já diz `.3s ease` | Tradução fiel do CSS; §6 proíbe mola e bounce | n |
| A-05 | §1 fixa cor de avatar só para as 5 personas de RN-30; uma festa real tem convidado fora da tabela | Nome fora da tabela recebe **um dos mesmos 5 pares**, escolhido por checksum determinístico do nome (soma dos code units mod 5). Mesmo nome ⇒ sempre o mesmo par. | Par fixo tornaria todo desconhecido idêntico numa pilha de avatares; paleta nova violaria "nenhuma cor fora dos tokens" | n |
| A-06 | §7 manda CAIXA ALTA em título/label/botão/toast; §5 diz "placeholder em minúsculas" | O componente aplica `toUpperCase()` nos quatro papéis obrigatórios. Placeholder **não** é transformado. | CAIXA ALTA é lei repetida no `CLAUDE.md`; minúscula de placeholder aparece só como exemplo, e `toLowerCase()` estragaria nome próprio | n |
| A-07 | Estado desabilitado de botão e de stepper não é especificado | `opacity: 0.7`, mantendo a borda sólida (o tracejado de §3 é do **slot vazio**, não do desabilitado) | 0.7 é o único valor de opacidade do arquivo 02; reusá-lo evita inventar um segundo | n |
| A-08 | A sombra do frame (`0 20px 50px -20px`) não mapeia 1:1 de CSS para Skia | Tradução direta: `BoxShadow(offset: (0,20), blurRadius: 50, spreadRadius: -20)`. Nenhum teste afirma o valor de blur — só que é a **única** sombra com `blurRadius > 0` do sistema | Exatidão é cosmética e o frame é palco, não UI | n |
| A-09 | Como os tokens são expostos | Constantes Dart puras como fonte da verdade + `boraTheme()` **derivado** delas. Sem `ThemeExtension`. | Ver `design.md` §Tech Decisions | n |
| A-10 | Eixo `wdth` da fonte variável (62–125, default 100) | Nunca variado; fica no default 100 | §2 não menciona largura | n |
| A-11 | Archivo Black é família estática de um arquivo só | Todo token dessa família usa `FontWeight.w400`; pedir outro peso arriscaria negrito sintético | O arquivo declara subfamília `Regular`; não há eixo | n |
| A-12 | Idioma dos identificadores | Classes, arquivos e pastas em **inglês** (`BoraPrimaryButton`, `components/`); parâmetros e constantes que carregam **copy do produto** em PT-BR (`titulo`, `rotulo`, `BoraToastTexts.linkCopiado`) | `CLAUDE.md`: domínio em PT-BR, resto em inglês — e o código existente já faz exatamente isso (`BoraApp.titulo`, `PlaceholderPage.titulo`) | n |
| A-13 | "Iniciais 800" no avatar — quantas letras? | A **primeira** letra do nome, em CAIXA ALTA | As personas de RN-30 têm um nome só (Rafa, Ana, Léo, Bia, Duda) | n |
| A-14 | O catálogo vai no bundle de produção | Vai, como rota interna sem dado. Esconder atrás de `kDebugMode` é uma linha, e não foi pedido | Decisão D2 do usuário; `coding-principles`: nada além do pedido | **y** |
| A-15 | Cores derivadas (scrim do sheet `rgba(20,10,50,.45)`, preenchimento da enquete `rgba(37,211,102,.18)`, cream 25% do segmented escuro, borda do frame `rgba(0,0,0,.25)`) não estão na tabela de §1 | Viram **tokens nomeados** em `bora_colors.dart`, cada um com o trecho de origem do arquivo 02 no doc comment | Senão a guarda "nenhuma cor fora dos tokens" seria burlada por literal inline | n |
| A-16 | Aplicar `boraTheme()` no app | Fora de escopo: `lib/app.dart` não é desta spec. O catálogo aplica o tema em si mesmo (`Theme(data: boraTheme(), …)`) | Fronteira de arquivos; hand-off declarado para a spec 03 | **y** |

**Open questions:** nenhuma — tudo acima está resolvido ou registrado como assumption.

---

## Contradição resolvida com a instrução de partida (registro obrigatório)

A instrução que abriu este planejamento trazia como "fato técnico já verificado" que *um único TTF variável não responde a `TextStyle.fontWeight` sozinho, e que selecionar 500/600/700/800 exigiria `fontVariations: [FontVariation('wght', N)]`*, pedindo que o comportamento fosse **confirmado na fase de Design**. Foi confirmado — e o resultado é o **oposto**, para o SDK instalado:

- A metade sobre o Google Fonts continua verdadeira: Archivo é distribuída **só como fonte variável** (`fvar` com eixos `wght` 100–900 e `wdth` 62–125, lido do próprio arquivo).
- A consequência para o Flutter **não** vale a partir do Flutter **3.41 stable**: `FontWeight` passou a ajustar o eixo `wght` internamente ([breaking change oficial](https://docs.flutter.dev/release/breaking-changes/font-weight-variation), landed 3.39.0-0.0.pre, stable 3.41), e a orientação da própria doc é **evitar** `FontVariation` para `wght`.
- O SDK deste repositório é **Flutter 3.47.0 / Dart 3.13.0** — acima do corte. A doc da API no SDK local confirma (`engine/src/flutter/lib/ui/text.dart:60`: *"[FontWeight] will set the value of the `wght` axis (producing the same results as explicitly setting that attribute using [FontVariation.weight])"*).
- Medição empírica no próprio worktree (sonda descartada depois): com a fonte carregada, `FontWeight.w900` e `FontWeight.w400` produzem larguras diferentes (416.68 × 383.68 px para a mesma string a 40px) e `FontWeight.w800` produz **exatamente** a mesma largura que `FontVariation('wght', 800)` (401.4395751953125 nos dois).

**Decisão codificada:** o peso é declarado por `TextStyle.fontWeight`, e `FontVariation` é **proibida** no código de produto — proibição policiada por varredura (DS-09). O requisito DS-03 mantém a exigência original do usuário: um teste **prova** que o peso certo chega ao texto rasterizado.

---

## Dimensions Sweep (obrigatório para porte Grande)

| Dimensão | Resolução |
|---|---|
| Input validation & bounds | **DS-27**, **DS-28** — fração fora de `[0,1]` ou não finita é clampada; **DS-04** — piso de 9px; **DS-21** — nome fora da tabela de avatares |
| Failure / partial-failure states | **DS-12** — toast disparado sobre `Overlay` já desmontado não lança; **DS-02** — fonte ausente do bundle quebra o teste de asset em vez de degradar silenciosamente para a fonte do sistema |
| Idempotency / retry / duplicate handling | **DS-12** — segundo toast **substitui** o primeiro (nunca empilha) e cancela o timer anterior; chamar duas vezes com o mesmo texto continua deixando um só |
| Auth boundaries & rate limits | `N/A porque` o design system não conhece usuário, papel nem chamada de rede. Papel aparece só como **rótulo** na tag de status (DS-22); o enforcement é da spec 07 `galera` (RN-22) |
| Concurrency / ordering | **DS-12** (ordem de substituição do toast e cancelamento do timer) e **DS-20** (abrir uma linha fecha a anterior — coordenação entre irmãos) |
| Data lifecycle / expiry | **DS-12** — os 2200 ms do toast são o único TTL do sistema; nenhum componente guarda dado além do próprio estado visual |
| Observability | `N/A porque` nenhum componente do arquivo 02 tem estado de negócio nem efeito colateral. O `AppLogger` de **AD-005** existe para bloc e erro global; instrumentar botão seria invenção fora do pedido |
| External-dependency failure | `N/A porque` **DS-02** elimina a única dependência externa possível: as fontes viajam no repositório, sem CDN, sem `google_fonts`, sem rede em runtime |
| State-transition integrity | **DS-11** (idle → hover → press → idle, com a sombra voltando a 4px), **DS-16** (segmented sempre com exatamente 1 ativo), **DS-20** (no máximo 1 accordion aberto) |

---

## User Stories

### P1-1: Tokens que a tela consome sem inventar valor ⭐ MVP

**User Story**: Como desenvolvedor de uma tela do BORA, quero cor, tipografia, forma, sombra e duração como valores nomeados, para nunca digitar um hex, um tamanho ou uma duração à mão.

**Why P1**: Cada uma das oito specs de tela consome esta camada. Um token errado aqui erra em oito telas; um token ausente vira literal espalhado, e o "exatamente igual ao protótipo" morre por acúmulo.

**Acceptance Criteria**:

1. WHEN os tokens de cor são lidos THEN o sistema SHALL expor os **17 tokens de §1** com o valor hexadecimal literal da tabela (`paper` `#F4EFE3`, `ink` `#141414`, `primary` `#FF4D2E`, `yellow` `#FFD23F`, `purple` `#6C4BF5`, `green` `#0B6B3A`, `wa-green` `#25D366`, `wa-bubble` `#E7DFCB`, `wa-confirm` `#DCF8C6`, `paper-2` `#EFECE5`, `cream` `#F4EFE3`, `white` `#FFFFFF`, `text-2` `#6b6b6b`, `text-3` `#9b9b9b`, `text-body` `#3a3a3a`, `divider` `#14141418`, `divider-2` `#14141422`). *(DS-01)*
2. WHEN uma cor derivada do arquivo 02 é necessária (scrim do bottom sheet, preenchimento da enquete, cream a 25%, borda do frame) THEN ela SHALL existir como **token nomeado**, com o trecho de origem citado, e não como literal inline. *(DS-01)*
3. WHEN a escala tipográfica é lida THEN cada papel de §2 SHALL ter um `TextStyle` nomeado cuja família é `Archivo` ou `Archivo Black`, cujo `fontSize` está **dentro da faixa** declarada para aquele papel, cujo `fontWeight` **não é nulo**, e cujo `letterSpacing`/`height` batem com a spec. *(DS-04)*
4. WHEN qualquer `TextStyle` do sistema é inspecionado THEN seu `fontSize` SHALL ser **≥ 9.0**. *(DS-04)*
5. WHEN as sombras são lidas THEN cada uma SHALL ter `blurRadius == 0`, `spreadRadius == 0` e `offset` igual ao par da tabela de §4 (`(4,4)` CTA, `(5,5)` login/link/grupo, `(6,6)` e `(8,8)` cards, `(8,8)` flyer), com a cor sendo o acento do contexto. *(DS-07)*
6. WHEN as formas e bordas são lidas THEN o sistema SHALL expor `BorderRadius.zero` como a forma padrão, a borda sólida `2px` `ink`, a tracejada `2px` `ink` (dica) e a tracejada `2px` `text-3` com `opacity 0.7` (slot vazio). *(DS-05, DS-06)*
7. WHEN o motion é lido THEN o sistema SHALL expor `150ms` (chips/segmented/botões de estado), `300ms ease` (`toastIn`, com fade e subida de 14px), `300ms` (largura de progresso) e `2200ms` (vida do toast), todos com curva `Curves.ease` e **nenhuma** curva de mola ou bounce. *(DS-10)*
8. WHEN os acentos são lidos THEN o sistema SHALL expor um **conjunto fechado** com significado fixo — vermelho = dinheiro/CTA, roxo = galera/link, `#25D366` = WhatsApp, verde = pago/comprado, amarelo = destaque, `ink` = neutro — e os componentes SHALL receber o acento por esse tipo, nunca por `Color` cru. *(DS-08)*
9. WHEN `boraTheme()` é construído THEN ele SHALL derivar **todos** os seus valores dos tokens acima (fundo `paper`, texto `ink`, famílias Archivo) e SHALL NOT declarar nenhuma cor, fonte ou forma própria. *(DS-35)*

**Independent Test**: teste unitário que lê cada token e compara com o valor literal do arquivo 02; teste que percorre a lista completa de `TextStyle` e afirma família, faixa de tamanho, peso não-nulo e piso de 9px.

---

### P1-2: As duas fontes viajam com o app e o peso certo chega ao pixel ⭐ MVP

**User Story**: Como desenvolvedor, quero Archivo e Archivo Black embarcadas no repositório e os pesos 400–800 realmente aplicados, para que o app não dependa de rede nem renderize com a fonte do sistema.

**Why P1**: `CLAUDE.md`: "Só Archivo e Archivo Black". Uma fonte que falha em carregar não dá erro — dá fallback silencioso, e o protótipo inteiro se desfaz sem ninguém ver.

**Acceptance Criteria**:

1. WHEN o repositório é inspecionado THEN `assets/fonts/` SHALL conter `Archivo[wdth,wght].ttf`, `ArchivoBlack-Regular.ttf` e `OFL.txt`, e o `pubspec.yaml` SHALL declarar as famílias `Archivo` e `Archivo Black` apontando para esses arquivos. *(DS-02)*
2. WHEN um teste pede o asset da fonte variável pelo `rootBundle` THEN ele SHALL receber os bytes do arquivo (prova de que o bundling funciona, inclusive com colchetes e vírgula no nome). *(DS-02)*
3. WHEN a licença é procurada THEN `OFL.txt` SHALL estar ao lado dos `.ttf` — a OFL exige que a licença seja redistribuída junto. *(DS-02)*
4. WHEN o mesmo texto é medido com `FontWeight.w400` e com `FontWeight.w800`, com a fonte Archivo carregada THEN as larguras resultantes SHALL ser **diferentes** — prova de que o eixo `wght` responde ao peso declarado. *(DS-03)*
5. WHEN o mesmo texto é medido com `FontWeight.w800` e com `FontVariation('wght', 800)` THEN as larguras SHALL ser **iguais** — prova de que `fontWeight` e o eixo são o mesmo mecanismo neste SDK. *(DS-03)*
6. WHEN o código de produto é varrido THEN `FontVariation` SHALL NOT aparecer em nenhum arquivo sob `lib/`. *(DS-03, DS-09)*
7. WHEN um token de Archivo Black é inspecionado THEN seu `fontWeight` SHALL ser `w400` — a família é estática e pedir outro peso arriscaria negrito sintético. *(DS-04)*

**Independent Test**: rodar o teste de métrica com `FontLoader`; apagar a linha `fonts:` do `pubspec.yaml` e ver o teste de asset falhar.

---

### P1-3: As leis do arquivo 02 policiadas por teste ⭐ MVP

**User Story**: Como desenvolvedor, quero que radius arredondado, sombra com blur, gradiente, cor fora do token e import proibido **quebrem a suíte**, para que o estilo não se degrade em silêncio ao longo de oito specs de tela.

**Why P1**: A fundação já provou que convenção escrita em documento é violada em silêncio e convenção com teste, não (`calculo_isolation_test.dart`, FUND-06). §8 é uma lista de proibições — proibição sem sensor é decoração.

**Acceptance Criteria**:

1. WHEN qualquer arquivo sob `lib/core/design_system/` usa `BorderRadius.circular`, `BorderRadius.all`, `RoundedRectangleBorder` ou `StadiumBorder` THEN a suíte SHALL falhar **nomeando o arquivo infrator**; `BorderRadius.zero` SHALL passar. *(DS-05)*
2. WHEN o arquivo do frame do celular ou o do avatar usam forma arredondada/circular THEN a suíte SHALL passar — são as **duas únicas exceções** (frame 38px, avatar/dot círculo), declaradas por allowlist de caminho. *(DS-05)*
3. WHEN qualquer `BoxShadow` sob `lib/core/design_system/` tem `blurRadius` diferente de zero fora do arquivo do frame THEN a suíte SHALL falhar nomeando o arquivo. *(DS-07)*
4. WHEN um literal de cor (`Color(0x…`, `Colors.…`) aparece fora de `bora_colors.dart` THEN a suíte SHALL falhar; `Colors.transparent` SHALL ser tolerado (ausência de cor, não cor). *(DS-09)*
5. WHEN um literal de `fontFamily` aparece fora de `bora_text_styles.dart` THEN a suíte SHALL falhar. *(DS-09)*
6. WHEN qualquer `Gradient`, `InkWell`, `InkResponse`, `Curves.elastic*`, `Curves.bounce*` ou `FontVariation` aparece sob `lib/` THEN a suíte SHALL falhar. *(DS-09, DS-10)*
7. WHEN qualquer arquivo sob `lib/core/design_system/` importa `core/calculo/`, `package:firebase…`, `cloud_firestore` ou `package:flutter_bloc` THEN a suíte SHALL falhar nomeando o arquivo. *(DS-34)*
8. WHEN nenhuma violação existe THEN cada uma dessas guardas SHALL passar **e** SHALL afirmar que varreu **≥ 1 arquivo** — nenhuma pode passar vacuamente. *(DS-05, DS-07, DS-09, DS-34)*

**Independent Test**: injetar `BorderRadius.circular(8)` num componente qualquer, rodar `flutter test`, ver falhar apontando o arquivo; remover, ver passar. Repetir com `Color(0xFF00FF00)` e com um import de `core/calculo/`.

---

### P1-4: Mecanismos compartilhados: superfície, press-sink e toast ⭐ MVP

**User Story**: Como desenvolvedor, quero que "borda 2px + sombra dura + radius 0", "afundar no press" e "um toast por vez" existam **uma vez** e sejam reusados, para que nenhum componente precise reimplementá-los (e errar).

**Why P1**: São as três mecânicas que aparecem em quase todo componente de §5. Reimplementadas 18 vezes, divergem 18 vezes.

**Acceptance Criteria**:

1. WHEN a superfície comum é renderizada THEN ela SHALL produzir uma caixa com `BorderRadius.zero`, borda `2px` na cor pedida e, quando houver acento, exatamente um `BoxShadow` com `blurRadius == 0` e o `offset` pedido. *(DS-13)*
2. WHEN um CTA recebe `pointer down` THEN ele SHALL deslocar `Offset(2, 2)` **e** encolher a sombra de `Offset(4, 4)` para `Offset(2, 2)`, em 150ms. *(DS-11)*
3. WHEN o `pointer up` ou o `pointer cancel` acontece THEN o CTA SHALL voltar a `Offset.zero` e a sombra a `Offset(4, 4)`. *(DS-11)*
4. WHEN o ponteiro **entra** na área do CTA num dispositivo com mouse THEN o mesmo afundamento SHALL acontecer (§4: "Hover/press de CTA (obrigatório)"). *(DS-11)*
5. WHEN um CTA está desabilitado (`onPressed == null`) THEN ele SHALL renderizar com `opacity 0.7` e SHALL NOT afundar. *(DS-11)*
6. WHEN um toast é exibido THEN ele SHALL aparecer centralizado a `bottom: 112`, fundo `ink`, texto `cream`, sombra dura no acento do contexto, entrando com fade + subida de 14px em 300ms. *(DS-12)*
7. WHEN 2200ms se passam THEN o toast SHALL sumir sozinho, sem interação. *(DS-12)*
8. WHEN um segundo toast é disparado com o primeiro ainda visível THEN a árvore SHALL conter **exatamente um** toast, mostrando o texto do segundo, e o timer do primeiro SHALL ter sido cancelado. *(DS-12)*
9. WHEN os textos canônicos são lidos THEN o sistema SHALL expor os **11 literais de RN-29**: "LINK COPIADO 🔗", "ROLÊ SALVO ✊", "CONVITE COPIADO 📋", "LISTA NO GRUPO 📲", "ABRINDO O WHATSAPP… 📲", "SALVO NA AGENDA 📅", "LEMBRETE MANDADO NO GRUPO 📲", "COBRANÇA ENVIADA NO PIX 📲", "GRUPO CRIADO NO WHATSAPP ✅", "ENQUETE POSTADA NO GRUPO 📲", "CRIE O GRUPO PRIMEIRO ☝️" — caractere por caractere, emoji incluído. *(DS-12)*
10. WHEN um toast é disparado sobre um `Overlay` já desmontado THEN o sistema SHALL ignorar em vez de lançar. *(DS-12)*
11. WHEN qualquer componente recebe copy de título, label, botão ou toast THEN ele SHALL renderizá-la em CAIXA ALTA, independentemente de como veio. *(DS-32)*

**Independent Test**: widget test que pressiona um botão e lê o `Transform` e o `BoxShadow`; teste de toast que avança o relógio a 2199ms (presente) e 2201ms (ausente) e que dispara dois seguidos.

---

### P1-5: Componentes de ação e entrada ⭐ MVP

**User Story**: Como desenvolvedor de tela, quero botões, chip, segmented, stepper e input prontos, para montar T-01/T-03 sem redesenhar nada.

**Why P1**: São os componentes que M1 (montar e ver o custo) consome imediatamente.

**Acceptance Criteria**:

1. WHEN o botão primário é renderizado THEN ele SHALL ter fundo `ink`, texto `cream`, borda `2px ink`, padding 15–16px e sombra `4px 4px 0` no acento do contexto; na variante de rodapé SHALL ocupar a largura total. *(DS-14)*
2. WHEN o botão secundário é renderizado THEN ele SHALL ter fundo transparente ou branco, borda `2px ink` e texto `ink`; no hover SHALL ganhar fundo `paper` ou sombra dura. *(DS-14)*
3. WHEN o chip de seleção está **não selecionado** THEN SHALL ter fundo branco e texto `ink`; WHEN **selecionado** THEN fundo `ink` e texto `cream`; a troca SHALL levar 150ms; o rótulo SHALL sair em CAIXA ALTA 800/13px com o emoji à esquerda. *(DS-15)*
4. WHEN o segmented control é renderizado THEN o container SHALL ter borda `2px ink` sobre branco, os botões SHALL dividir a largura igualmente separados por divisor `2px` `divider-2`, e **exatamente um** SHALL estar ativo (fundo `ink` + texto `cream`), os demais transparentes com `text-2`. *(DS-16)*
5. WHEN o segmented está sobre card escuro THEN borda e divisores SHALL usar `cream` a 25% e o ativo SHALL mudar **só o texto** para `cream`. *(DS-16)*
6. WHEN o stepper é renderizado THEN os botões SHALL medir 34×34 visualmente, o valor central SHALL ser 800/17px, e a **área tocável** de cada botão SHALL medir **≥ 44px** em ambos os eixos. *(DS-17)*
7. WHEN o stepper é tocado THEN ele SHALL emitir apenas a **intenção** (`onIncrementar` / `onDecrementar`, sem payload) e SHALL NOT calcular o próximo valor — o valor exibido é sempre a propriedade recebida. *(DS-17)*
8. WHEN o input está sem foco THEN a borda SHALL ser `2px ink`; WHEN recebe foco THEN a borda SHALL virar `primary`; o radius SHALL ser zero, o padding 15×16px e o texto 600/15px em qualquer estado. *(DS-18)*

**Independent Test**: widget test por componente, lendo cor/borda/tamanho da árvore renderizada e medindo o alvo de toque do stepper com `tester.getSize`.

---

### P1-6: Componentes de lista, gente e status ⭐ MVP

**User Story**: Como desenvolvedor de tela, quero card de lista, accordion, avatares, tag de status, dica tracejada e tag rotacionada, para montar T-04 e T-05.

**Why P1**: São o corpo visual de `lista` e `galera` — duas das quatro telas do caminho crítico.

**Acceptance Criteria**:

1. WHEN o card de lista é renderizado THEN SHALL ter fundo branco, borda `2px ink` e linhas com padding 12–13×14–16px separadas por `2px solid divider`, emoji 19–20px à esquerda e valor 800/14px à direita. *(DS-19)*
2. WHEN uma linha expansível está fechada THEN o caret SHALL ser `▾`; WHEN aberta THEN `▴`, e o painel SHALL ter fundo `paper` com `border-top 2px`. *(DS-20)*
3. WHEN uma segunda linha do mesmo grupo é aberta THEN a primeira SHALL fechar — **no máximo uma aberta por vez**. *(DS-20)*
4. WHEN a mesma linha aberta é tocada de novo THEN ela SHALL fechar, deixando o grupo sem nenhuma aberta. *(DS-20)*
5. WHEN avatares são empilhados THEN cada um SHALL ser um círculo de 34–40px com borda `2px ink` e a inicial em 800, sobrepostos por `-8` a `-10px`; o último slot `+N` SHALL ser branco com borda **tracejada**. *(DS-21)*
6. WHEN `N == 0` THEN o slot `+N` SHALL NOT ser renderizado. *(DS-21)*
7. WHEN o avatar é de uma das cinco personas THEN as cores SHALL ser as fixas de §1 (Rafa `#FF4D2E`/`#fff`, Ana `#FFD23F`/`#141414`, Léo `#6C4BF5`/`#fff`, Bia `#0B6B3A`/`#fff`, Duda `#141414`/`#F4EFE3`); WHEN é outro nome THEN SHALL receber **um desses mesmos cinco pares**, de forma determinística (o mesmo nome sempre a mesma cor). *(DS-21)*
8. WHEN uma tag de status é renderizada THEN SHALL ter borda `2px ink`, padding 4–6×7–9px, texto 800/9–10.5px com `letter-spacing .5px`, e a cor do seu significado: RECEBE=`ink`, PAGA=`primary`, NO ZERO=branco, ANFITRIÃO=`yellow`, CO-ANFITRIÃO=`purple` com texto branco, CONVIDADO=branco, SÓ VÊ=`wa-bubble` com texto `text-2`. *(DS-22)*
9. WHEN uma dica/nota é renderizada THEN SHALL ter borda `2px dashed ink`, fundo branco, texto 600/12px `text-2` e um emoji-âncora. *(DS-23)*
10. WHEN um slot vazio/desabilitado é renderizado THEN SHALL ter borda `2px dashed` `text-3` e `opacity 0.7`. *(DS-23)*
11. WHEN uma tag rotacionada é renderizada THEN SHALL girar `-2°` (esquerda) ou `+3°` (direita), com fundo `primary` ou `yellow`, posicionada vazando o topo do card em `-13px`. *(DS-24)*

**Independent Test**: widget test por componente; para o accordion, abrir A, abrir B e afirmar que só B está aberto.

---

### P1-7: Componentes de dinheiro e apresentação ⭐ MVP

**User Story**: Como desenvolvedor de tela, quero card-herói, rodapé fixo, barra de faixa de preço, bottom sheet e frame do celular, para montar o rodapé "SAI POR", o sheet de pedido e a apresentação web.

**Why P1**: O card-herói e o rodapé "SAI POR" são a cara da promessa do produto (custo ao vivo) e aparecem já em T-03.

**Acceptance Criteria**:

1. WHEN o card-herói escuro é renderizado THEN SHALL ter fundo `ink`, padding 20–22px, sombra `6px 6px 0 #FF4D2E`, label `yellow` 800/12px `ls 1px`, valor `cream` Archivo Black 40–42px e sublinha `primary` 700/13px. *(DS-25)*
2. WHEN o rodapé fixo é renderizado THEN SHALL ter fundo `paper`, `border-top 2px ink`, padding 14–16px/24px/30px, o bloco "SAI POR" à esquerda (label 800/11px `ls 1px` `text-2` + valor Archivo Black + sublinha vermelha 700/12.5px) e o CTA à direita. *(DS-26)*
3. WHEN o card-herói e o rodapé recebem um valor monetário THEN ele SHALL chegar como **`String` já formatada** — nenhum componente formata `R$`, arredonda nem divide (RN-13 é da spec `calculo`). *(DS-25, DS-26, DS-34)*
4. WHEN a barra de faixa de preço é renderizada THEN o trilho SHALL ter 8px de altura, fundo `paper-2` e borda `2px ink`; o marcador SHALL ter 8×12px, fundo `primary`, borda `2px ink`; os extremos SHALL ser rotulados abaixo em 700/10px `text-3`. *(DS-27)*
5. WHEN a barra de faixa recebe a posição do marcador THEN ela SHALL recebê-la como **fração já calculada** (`double` 0..1, RN-11 é da spec `calculo`) e SHALL apenas pintar. *(DS-27, DS-34)*
6. WHEN a fração recebida é menor que 0, maior que 1, `NaN` ou infinita THEN a barra SHALL clampar para `[0, 1]` (não finito ⇒ `0.0`) sem lançar. *(DS-27)*
7. WHEN o bottom sheet é aberto THEN o overlay SHALL ser `rgba(20,10,50,.45)`, o painel SHALL ficar ancorado embaixo com fundo `paper`, `border-top 2px ink` e padding 22/24/30px, com título Archivo Black 22px e botão ✕ de 32×32 com borda `2px`. *(DS-30)*
8. WHEN o frame do celular é renderizado THEN SHALL medir 390×820, ter radius **38px**, borda `1px rgba(0,0,0,.25)`, `overflow hidden`, header e rodapé fixos e o conteúdo rolando na área central. *(DS-31)*
9. WHEN as sombras do sistema inteiro são inspecionadas THEN a **única** com `blurRadius > 0` SHALL ser a do frame — é o palco, não a UI. *(DS-31, DS-07)*

**Independent Test**: widget test por componente; passar `double.nan` para a barra de faixa e afirmar que renderiza no extremo esquerdo sem exceção.

---

### P1-8: Catálogo conferível a olho ⭐ MVP

**User Story**: Como pessoa revisando o design system, quero abrir `/catalogo` em mobile e web e ver cada componente lado a lado com o arquivo 02, para conferir o que nenhum teste de propriedade consegue afirmar: se **parece** o protótipo.

**Why P1**: É o critério de M0 declarado no `.specs/ROADMAP.md` §1 ("catálogo de componentes renderizando os tokens do arquivo 02") e a decisão D2 do usuário.

**Acceptance Criteria**:

1. WHEN a rota `/catalogo` é aberta THEN o sistema SHALL renderizar a página do catálogo, sem erro. *(DS-33)*
2. WHEN `/catalogo` é aberta THEN o chrome do app (`AppShell.chromeKey`) SHALL estar **ausente** — o catálogo é ferramenta interna, não tela de produto dentro do shell. *(DS-33)*
3. WHEN o catálogo é renderizado THEN ele SHALL conter **ao menos uma instância de cada componente público** do design system, e o teste SHALL falhar nomeando o componente que faltar. *(DS-33)*
4. WHEN o catálogo é renderizado em largura compacta (`< 900`) e em largura expandida (`≥ 900`) THEN ambos SHALL renderizar sem overflow e SHALL usar `LayoutMode` de **AD-007**, sem redeclarar o breakpoint. *(DS-33)*
5. WHEN o catálogo é renderizado THEN ele SHALL aplicar `boraTheme()` a si mesmo — a aplicação do tema no app inteiro é da spec 03. *(DS-33, DS-35)*
6. WHEN o barrel público do design system é lido THEN ele SHALL exportar todo componente e todo token, e o teste SHALL falhar nomeando o que não estiver exportado. *(DS-33)*
7. WHEN as 92 rotas e testes de baseline rodam THEN todos SHALL continuar passando — acrescentar `/catalogo` SHALL NOT alterar nenhuma rota existente. *(DS-33)*

**Independent Test**: `flutter run -d chrome`, abrir `/catalogo`, conferir contra `.specs/init-spec/02-design-system.md` seção por seção (verificação **M**, do usuário).

---

### P2-1: Componentes dos marcos M2 e M3

**User Story**: Como desenvolvedor, quero a barra de progresso de quitação e a opção de enquete estilo WhatsApp, para montar T-07 e T-09 quando M2/M3 chegarem.

**Why P2**: Nenhuma tela de M1 os consome — a barra de progresso é da quitação (RN-18, spec 10 `custos`) e a enquete é da spec 08 `convite`. Entregar o resto do arquivo 02 já desbloqueia M1 inteiro.

**Acceptance Criteria**:

1. WHEN a barra de progresso é renderizada THEN SHALL ter 12px de altura, borda `2px cream` (sobre card escuro) e preenchimento `#25D366`, animando a largura em 300ms. *(DS-28)*
2. WHEN a barra de progresso recebe a fração THEN SHALL recebê-la já calculada (`double` 0..1) e SHALL clampar entrada fora da faixa ou não finita. *(DS-28, DS-34)*
3. WHEN uma opção de enquete é renderizada THEN SHALL ter borda `2px ink`, ou `#25D366` quando for o voto do usuário; a barra de % SHALL preencher o fundo com `rgba(37,211,102,.18)`; o radio SHALL ser circular de 15px (verde quando votado); a % SHALL ficar à direita e a contagem "n votos" abaixo. *(DS-29)*
4. WHEN a opção de enquete recebe a porcentagem e a contagem THEN SHALL recebê-las já calculadas/formatadas. *(DS-29, DS-34)*

**Independent Test**: widget test por componente, com fração 0, 0.5 e 1.

---

## Edge Cases

- WHEN a fração da barra de faixa ou de progresso é `< 0`, `> 1`, `NaN` ou infinita THEN o componente SHALL clampar para `[0, 1]` (não finito ⇒ `0.0`) e renderizar sem exceção.
- WHEN o nome de uma pessoa não está na tabela de cores de avatar de §1 THEN o componente SHALL escolher deterministicamente um dos cinco pares existentes — nunca uma cor nova, nunca uma cor fora dos tokens.
- WHEN um rótulo de botão, chip, tag ou título chega em minúsculas THEN o componente SHALL renderizá-lo em CAIXA ALTA; WHEN chega vazio THEN SHALL renderizar sem exceção.
- WHEN um toast é disparado enquanto outro está visível THEN o anterior SHALL ser removido e seu timer cancelado — nunca dois na tela, nunca um timer órfão derrubando o toast novo antes da hora.
- WHEN um toast é disparado depois que o `Overlay` foi desmontado THEN o sistema SHALL ignorar em silêncio, sem lançar.
- WHEN o segmented control recebe uma única opção THEN SHALL renderizar sem divisor.
- WHEN o stepper está no limite (`onDecrementar == null`) THEN o botão `−` SHALL aparecer com `opacity 0.7` e SHALL NOT emitir intenção ao ser tocado — **sem** calcular limite algum por conta própria.
- WHEN a pilha de avatares recebe `+0` THEN o slot `+N` SHALL ser omitido.
- WHEN um grupo de linhas expansíveis é montado THEN nenhuma SHALL começar aberta.
- WHEN uma guarda de varredura roda num diretório sem nenhum `.dart` THEN ela SHALL **falhar** por varredura vazia, em vez de passar vacuamente (mesma armadilha do risco R-5 da fundação).
- WHEN `flutter test` roda THEN nenhum teste SHALL depender de fonte carregada, exceto os de métrica tipográfica, que carregam a sua com `FontLoader` — porque `flutter test` **não** carrega fontes do `pubspec` automaticamente (verificado no SDK e empiricamente).

---

## Requirement Traceability

| Requirement ID | Story | Fonte (arquivo 02 salvo indicação) | Fase | Status |
|---|---|---|---|---|
| DS-01 | P1-1 | §1 (tabela de cores + cores derivadas) | Tasks | In Tasks |
| DS-02 | P1-2 | §2 ("Fontes Google … Nenhuma outra") + D1 do usuário | Tasks | In Tasks |
| DS-03 | P1-2 | §2 (pesos 400–800) + doc oficial do Flutter | Tasks | In Tasks |
| DS-04 | P1-1, P1-2 | §2 (tabela de papéis) + §8 (piso 9px) | Tasks | In Tasks |
| DS-05 | P1-1, P1-3 | §3 (`border-radius: 0` e as duas exceções) | Tasks | In Tasks |
| DS-06 | P1-1 | §3 (bordas sólida, tracejada e slot vazio) | Tasks | In Tasks |
| DS-07 | P1-1, P1-3 | §4 (tabela de sombras duras) | Tasks | In Tasks |
| DS-08 | P1-1 | §1 (regra de acento) + §8 | Tasks | In Tasks |
| DS-09 | P1-3 | §8 (lista "não fazer") | Tasks | In Tasks |
| DS-10 | P1-1 | §6 (motion) | Tasks | In Tasks |
| DS-11 | P1-4 | §4 ("Hover/press de CTA (obrigatório)") | Tasks | In Tasks |
| DS-12 | P1-4 | §5 (Toast) + **RN-29** | Tasks | In Tasks |
| DS-13 | P1-4 | §3 + §4 (a mecânica comum a quase todo componente) | Tasks | In Tasks |
| DS-14 | P1-5 | §5 (Botão primário, Botão secundário) | Tasks | In Tasks |
| DS-15 | P1-5 | §5 (Chip de seleção) | Tasks | In Tasks |
| DS-16 | P1-5 | §5 (Segmented control) | Tasks | In Tasks |
| DS-17 | P1-5 | §5 (Stepper) | Tasks | In Tasks |
| DS-18 | P1-5 | §5 (Inputs) | Tasks | In Tasks |
| DS-19 | P1-6 | §5 (Card de lista) | Tasks | In Tasks |
| DS-20 | P1-6 | §5 (Linha expansível) | Tasks | In Tasks |
| DS-21 | P1-6 | §5 (Avatares empilhados) + §1 (cores de avatar) | Tasks | In Tasks |
| DS-22 | P1-6 | §5 (Tag de status) | Tasks | In Tasks |
| DS-23 | P1-6 | §3 (Dica/nota, Slot vazio) | Tasks | In Tasks |
| DS-24 | P1-6 | §3 (Tags rotacionadas) | Tasks | In Tasks |
| DS-25 | P1-7 | §5 (Card-herói escuro) | Tasks | In Tasks |
| DS-26 | P1-7 | §5 (Rodapé fixo) | Tasks | In Tasks |
| DS-27 | P1-7 | §5 (Barra de faixa de preço) | Tasks | In Tasks |
| DS-28 | P2-1 | §5 (Barra de progresso) | Tasks | In Tasks |
| DS-29 | P2-1 | §5 (Opção de enquete) | Tasks | In Tasks |
| DS-30 | P1-7 | §5 (Bottom sheet) | Tasks | In Tasks |
| DS-31 | P1-7 | §5 (Frame do celular) + §4 (única sombra suave) | Tasks | In Tasks |
| DS-32 | P1-4 | §7 (voz e copy) + `CLAUDE.md` | Tasks | In Tasks |
| DS-33 | P1-8 | ROADMAP §3 (critério de M0) + D2 do usuário | Tasks | In Tasks |
| DS-34 | P1-3, P1-7 | `CLAUDE.md` ("nunca duplique uma fórmula em componente de UI") | Tasks | In Tasks |
| DS-35 | P1-1 | §1/§2 (nada fora dos tokens) | Tasks | In Tasks |

**ID format:** `DS-NN`
**Status:** Pending → In Design → In Tasks → Implementing → Verified
**Coverage:** 35 requisitos, 35 mapeados a componente + verificação no `design.md`, 35 mapeados a task no `tasks.md` (T1–T32), 0 órfãos.

---

## Success Criteria

- [ ] `flutter analyze` zero issues e `flutter test` verde, com a baseline de 92 testes preservada e nenhum teste existente enfraquecido.
- [ ] Cada valor da tabela de §1 e de §4 aparece afirmado literalmente em teste; cada papel de §2 tem tamanho, peso e espaçamento afirmados dentro da faixa da spec.
- [ ] Injetar `BorderRadius.circular(8)`, `Color(0xFF00FF00)`, um `Gradient` ou um import de `core/calculo/` quebra a suíte nomeando o arquivo — verificado nos dois sentidos.
- [ ] `FontWeight.w800` e `FontVariation('wght', 800)` medem igual; `w400` e `w800` medem diferente — o peso chega ao pixel.
- [ ] `/catalogo` abre em mobile e em web mostrando os ~18 componentes, e o teste de completude falha se algum sumir.
- [ ] Nenhum arquivo fora da fronteira declarada foi tocado; `lib/core/calculo/` continua intacto.

---

## Nota de dependência para as specs seguintes

- **Spec 02 `calculo`** (paralela): dona de toda aritmética e da formatação `R$` (RN-13). Esta spec **não a importa** e recebe `String` já formatada e `double` já calculado. A barra de faixa de preço recebe a fração de RN-11 pronta.
- **Spec 03 `entrar`**: herda `boraTheme()` e é quem o **pluga no `BoraApp`** — `lib/app.dart` está fora da fronteira desta spec. Herda também o revestimento de `PlaceholderPage`/`AppShell`, que a fundação deixou "para a spec 01" mas que depende de layout de tela (T-01/T-02) para ser decidido.
- **Specs 04–10**: consomem tokens e componentes pelo barrel; a regra "máx. 2 acentos por tela" é critério de aceite **delas**, sobre o conjunto fechado de acentos que esta spec entrega.
