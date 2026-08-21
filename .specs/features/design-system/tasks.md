# Design System "Convite" — Tasks

## Execution Protocol (MANDATORY — do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user — do not proceed without it.**

---

**Spec**: `.specs/features/design-system/spec.md` · **Design**: `.specs/features/design-system/design.md`
**Status**: Draft — aguardando aprovação
**Decisões ativas**: AD-001..AD-007 (`.specs/STATE.md`) + os quatro ADs propostos no `design.md` (DS-1..DS-4), que o orquestrador escreve no `STATE.md` **depois** do merge — nenhuma task toca aquele arquivo.

**Ferramentas do Execute**: **só as ferramentas nativas** — nenhum MCP está configurado nesta sessão e nenhuma skill auxiliar é invocada (por isso todo `Tools:` abaixo diz `MCP: NONE` / `Skill: NONE`). O `Context7` foi tentado na fase de Design e não existe neste ambiente; a verificação técnica foi feita pela fonte do SDK instalado e pela doc oficial (ver `design.md` §Pesquisa). As verificações marcadas **M** ficam com o usuário; o executor **reporta o que não conseguiu verificar** em vez de assumir que passou.

---

## ⛔ Fronteira de arquivos (dura — vale para TODAS as tasks)

Esta spec roda **em paralelo** com a spec 02 `calculo`. Tocar fora da fronteira corrompe os dois workflows no merge.

| Pode tocar | Não pode tocar |
|---|---|
| `lib/core/design_system/**` | `lib/core/calculo/**` — território da spec 02 |
| `test/core/design_system/**` | `lib/app.dart`, `lib/main.dart`, `lib/bootstrap/**` |
| `assets/**` | `lib/core/{di,firebase,observability,responsive}/**` |
| `pubspec.yaml` — **só** as seções `assets:` e `fonts:` dentro do bloco `flutter:` | `lib/features/**` |
| `lib/core/routing/app_router.dart` e `routes.dart` — **só** a rota do catálogo (T10) | `.specs/STATE.md`, `.specs/ROADMAP.md`, `.specs/LESSONS.md`, `.specs/lessons.json` |
| `test/core/routing/app_router_catalogo_test.dart` — **só** este arquivo novo | qualquer teste existente |

**Baseline a preservar, verificada em 2026-08-20 no worktree `feature/design-system`:** `flutter test` = **92 passando** · `flutter analyze` = **zero issues**. Nenhuma task pode reduzir a contagem nem enfraquecer, pular ou apagar teste existente. Toda task reporta a contagem nova (baseline + os testes que ela acrescenta).

**Nenhuma dependência nova no `pubspec.yaml`.** AD-002 (zero codegen) e a decisão D2 do usuário: as fontes são arquivos, o catálogo é rota.

---

## Test Coverage Matrix

> Gerada de guidelines do projeto + spec + amostragem do código existente. **Guidelines encontradas**: `CLAUDE.md` (§Decisões de engenharia → "Testes: pirâmide completa", "cada critério de aceite de `UC-xx` vira widget test", "`test/` espelha a estrutura de `lib/`", "Teste sai do critério de aceite, nunca da implementação", "`flutter_lints` rodando local, sem CI"), `analysis_options.yaml` (inclui `package:flutter_lints/flutter.yaml`). Não há `CONTRIBUTING.md`, `docs/`, config de runner nem workflow de CI. **Amostragem** (11 arquivos de teste existentes): `test/core/routing/app_router_publico_test.dart`, `app_router_shell_test.dart`, `invite_code_format_test.dart`, `test/architecture/calculo_isolation_test.dart`, `project_structure_test.dart`, `test/core/responsive/layout_mode_test.dart`, `responsive_builder_test.dart`, `test/core/di/injector_test.dart`, `test/core/observability/app_bloc_observer_test.dart`, `test/bootstrap/app_bootstrap_test.dart`, `test/fixtures/rn30_estado_inicial_test.dart` — estilo: `group` por requisito (`FUND-07 — …`), `expect` com `reason`, helper `_abrir(tester, location)`, asserção de propriedade sobre a árvore. **Esse estilo é piso, não teto.**

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
|---|---|---|---|---|
| Tokens Dart puros (`tokens/bora_{colors,shadows,borders,spacing,motion,accent}.dart`) | unit | **Todo token 1:1 com o valor literal do arquivo 02** — cada hex de §1, cada par de offset de §4, cada duração de §6, cada padding de §5. Toda cor derivada de A-15 com o alfa afirmado | `test/core/design_system/tokens/*_test.dart` | `flutter test` |
| Escala tipográfica (`tokens/bora_text_styles.dart`) | unit | A lista `BoraTextStyles.todos` percorrida inteira: família ∈ {Archivo, Archivo Black}, `fontSize` dentro da faixa de §2 do papel, `fontSize >= 9.0`, `fontWeight != null`, Archivo Black sempre `w400`, `letterSpacing`/`height` da tabela | `test/core/design_system/tokens/bora_text_styles_test.dart` | `flutter test` |
| Métrica tipográfica (prova de DS-03) | unit | Larguras medidas com `FontLoader` local: `w400 != w800` e `w800 == FontVariation('wght',800)`. **Único** lugar da suíte que carrega fonte | `test/core/design_system/tokens/font_weight_axis_test.dart` | `flutter test` |
| Tema derivado (`tokens/bora_theme.dart`) | unit | Cada campo do `ThemeData` remontando ao token de origem; nenhum literal próprio; sem splash | `test/core/design_system/tokens/bora_theme_test.dart` | `flutter test` |
| Componentes (`components/**`) | widget | **Cada AC de `DS-xx` vira widget test**, afirmando o token **na árvore renderizada** (`BoxDecoration.border.top.width == 2.0`, `border.top.color == BoraColors.ink`, `borderRadius == BorderRadius.zero`, `boxShadow.single.blurRadius == 0`, `offset == Offset(4,4)`, translação `(2,2)` no press) + **todo edge case listado** no `spec.md` (clamp de fração, `+0` sem slot, rótulo vazio, desabilitado, 1 opção sem divisor) | `test/core/design_system/components/*_test.dart` | `flutter test` |
| Catálogo (`catalog/**`) | widget | Rota abre e **afirma o destino** + ausência do chrome do app; completude (todo componente público presente, falhando com o nome do que faltou); compacto (`< 900`) e expandido (`>= 900`); barrel exporta tudo | `test/core/design_system/catalog/*_test.dart` · `test/core/routing/app_router_catalogo_test.dart` | `flutter test` |
| Rota nova em `lib/core/routing/` | widget | Mesma expectativa que a fundação passou a exigir depois da validação: **toda rota acrescentada tem teste que a abre e afirma o destino** — nunca uma rota alcançável sem destino afirmado | `test/core/routing/app_router_catalogo_test.dart` | `flutter test` |
| Guardas de arquitetura (varredura de fonte) | unit | As proibições de §3/§4/§8 e a fronteira com `calculo` executáveis: falha **nomeando o arquivo infrator**; cada guarda afirma que **varreu ≥1 arquivo** (anti-vácuo, risco R-4/R-5); verificada nos dois sentidos (injetar violação ⇒ falha; remover ⇒ passa) | `test/core/design_system/architecture/*_test.dart` | `flutter test` |
| Asset de fonte (`assets/fonts/**` + seção `fonts:` do `pubspec.yaml`) | unit | Os dois `.ttf` carregam pelo `rootBundle`; `OFL.txt` presente ao lado; as duas famílias declaradas | `test/core/design_system/tokens/bora_fonts_test.dart` | `flutter test` |
| Helpers de teste (`test/core/design_system/support/**`) | none | São utilitário de teste, não camada de produção — verificados por serem usados pelos testes que os chamam | — | gate de build |
| Golden images | **fora de escopo** | Decisão de design: asserção de propriedade discrimina melhor (nomeia o valor da spec violado) e não depende de fonte carregada nem de rasterização por plataforma. Ver `design.md` §Exploração de abordagens e risco R-1 | — | — |
| `integration_test/` (e2e) | **fora de escopo** | Nenhum `DS-xx` pede fluxo ponta-a-ponta; a pirâmide do `CLAUDE.md` reserva e2e para os fluxos de produto (montar → convidar → confirmar → acerto), que nascem da spec 05 em diante | — | — |

## Gate Check Commands

> Derivados do `CLAUDE.md` e **executados de verdade** no worktree em 2026-08-20 (baseline 92 testes / analyze limpo). Não são comandos supostos.

| Gate Level | When to Use | Command |
|---|---|---|
| Quick | Após tasks com unit e/ou widget test | `flutter test` |
| Full | Idem — não há suíte e2e nesta spec, então Full ≡ Quick | `flutter test` |
| Build | Fim de fase, tasks de config/asset e qualquer task que mexa em `pubspec.yaml` ou em `lib/core/routing/` | `flutter analyze && flutter test` |
| Manual (M) | DS-33 (conferência a olho do catálogo contra o arquivo 02, mobile **e** web) | `flutter run` · `flutter run -d chrome` → abrir `/catalogo` |

**Regra em todo gate:** `flutter analyze` precisa terminar com **zero issues**, a contagem de testes não pode cair abaixo de 92 + os acrescentados, e nenhum teste pode ser enfraquecido, pulado (`skip:`) ou apagado para o portão passar.

---

## Execution Plan

Fases ordenadas, executadas em sequência; dentro da fase, as tasks rodam na ordem numérica. Nenhuma fase passa de ~10 tasks (a maior tem 6).

### Phase 1: Tokens (T1–T6)

O vocabulário. Nada acima existe sem isto, e é aqui que os valores literais do arquivo 02 entram no código uma única vez.

```
T1 ─┬→ T3 → T4
T2 ─┴→ T5 → T6
```

### Phase 2: Guardas e casa do catálogo (T7–T10)

As leis de §8 viram sensor **antes** dos componentes existirem, para que a fase 3 em diante já nasça policiada. A rota do catálogo entra aqui para que cada componente tenha onde se registrar.

```
T5, T6 → T7
T6 ────→ T8
T6 ────→ T9
T6 ────→ T10
```

### Phase 3: Mecanismos compartilhados (T11–T13)

As três mecânicas que quase todo componente reusa. Erradas aqui, erradas 18 vezes.

```
T11 → T12
T6 ─→ T13
```

### Phase 4: Ação e entrada (T14–T18)

Os componentes que M1 consome primeiro (T-01 e T-03).

```
T12 → T14
T11 → T15 → T16 → T17 → T18
```

### Phase 5: Lista, gente e status (T19–T24)

O corpo visual de T-04 e T-05.

```
T11 → T19 → T20
T7, T2 → T21
T11 → T22 → T23 → T24
```

### Phase 6: Dinheiro e progresso (T25–T29)

O rodapé "SAI POR", a faixa de preço e os dois componentes de M2/M3 (P2 da spec).

```
T11 → T25
T14 → T26
T11 → T27 → T28
T7, T11 → T29
```

### Phase 7: Apresentação e fechamento (T30–T32)

O sheet, o palco e a conferência.

```
T14 → T30
T7 ─→ T31
T10, T31 → T32
```

---

## Task Breakdown

### T1: Fontes Archivo e Archivo Black bundladas no repositório

**What**: copiar os três arquivos de fonte para `assets/fonts/`, declarar as duas famílias no `pubspec.yaml` e provar por teste que o asset carrega.
**Where**: `assets/fonts/Archivo[wdth,wght].ttf`, `assets/fonts/ArchivoBlack-Regular.ttf`, `assets/fonts/OFL.txt`, `pubspec.yaml` (só `assets:` e `fonts:`), `test/core/design_system/tokens/bora_fonts_test.dart`
**Depends on**: None
**Reuses**: bloco `flutter:` já existente no `pubspec.yaml` (o `uses-material-design: true` fica onde está)
**Requirement**: DS-02

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] Os três arquivos foram copiados de `/tmp/claude-1000/-home-lucari-repo-bora/71175ab6-b93d-42f3-97d8-ca762642386b/scratchpad/fonts/` para `assets/fonts/`: `Archivo[wdth,wght].ttf` (658.596 bytes), `ArchivoBlack-Regular.ttf` (90.988 bytes) e `OFL.txt` — a OFL exige que a licença seja redistribuída **junto** com as fontes
- [x] `pubspec.yaml` declara, dentro do bloco `flutter:` já existente, `assets: - assets/fonts/` e duas famílias: `Archivo` → o `.ttf` variável e `Archivo Black` → o estático. **Sem descritor `weight:`** — cada família tem um arquivo só, e é o `FontWeight` que move o eixo `wght` (ver `design.md` §Pesquisa)
- [x] Nenhuma dependência foi adicionada, removida ou reordenada no `pubspec.yaml`; só as duas seções acima mudaram
- [x] O teste afirma: `rootBundle.load` dos dois `.ttf` devolve bytes (`lengthInBytes > 0`), `assets/fonts/OFL.txt` existe e carrega, e o `pubspec.yaml` declara exatamente as famílias `Archivo` e `Archivo Black`
- [x] Gate: `flutter analyze && flutter test` passa
- [x] Novos testes: ≥3 · contagem total ≥95

**Tests**: unit
**Gate**: build
**Commit**: `feat(design-system): embarca as fontes archivo no repositório`

---

### T2: Tokens de cor de §1 e as cores derivadas

**What**: criar o **único** arquivo do projeto autorizado a conter literal de cor, com os 17 tokens de §1, as cinco cores derivadas de A-15 e a tabela de avatares.
**Where**: `lib/core/design_system/tokens/bora_colors.dart`, `test/core/design_system/tokens/bora_colors_test.dart`
**Depends on**: None
**Reuses**: tabela de valores ARGB já convertida no `design.md` §Components → `BoraColors` (o worker **não** recalcula alfa)
**Requirement**: DS-01, DS-21

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] Os 17 tokens de §1 existem com o ARGB da tabela do `design.md`; `paper` e `cream` existem os **dois**, com o mesmo valor e papéis diferentes (é o que a spec-fonte diz)
- [x] `divider` = `Color(0x18141414)` e `divider2` = `Color(0x22141414)` — o `#14141418` de §1 é RGBA, o alfa é o **último** par no CSS e o **primeiro** byte no Dart
- [x] As cinco derivadas de A-15 existem como token nomeado, cada uma com o trecho de origem no doc comment: `sheetScrim` `0x73140A32` (§5, `rgba(20,10,50,.45)` — **não** é `ink`), `pollFill` `0x2E25D366`, `creamQuarter` `0x40F4EFE3`, `frameBorder` `0x40000000`, `frameShadow` `0x59140A32`
- [x] `avatarPairs` traz os cinco pares fixos de §1 (Rafa, Ana, Léo, Bia, Duda) e `avatarPairFor(String nome)` devolve o par da tabela; nome fora da tabela devolve um dos **mesmos cinco** pares por checksum determinístico (A-05)
- [x] O teste afirma **cada** token contra o hex literal do arquivo 02, e afirma que `avatarPairFor` é determinístico (mesmo nome ⇒ mesmo par, duas chamadas) e nunca devolve cor fora dos cinco pares
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥6

**Tests**: unit
**Gate**: quick
**Commit**: `feat(design-system): define os tokens de cor do arquivo 02`

---

### T3: Escala tipográfica de §2

**What**: criar o **único** arquivo com literal de `fontFamily`, com um `TextStyle` por papel de §2 e a lista `todos` que os testes percorrem.
**Where**: `lib/core/design_system/tokens/bora_text_styles.dart`, `test/core/design_system/tokens/bora_text_styles_test.dart`
**Depends on**: T1, T2
**Reuses**: tabela de 24 papéis no `design.md` §Components → `BoraTextStyles` (família, size, weight, ls, height, cor e a faixa de §2 que o teste afirma)
**Requirement**: DS-04, DS-03

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] Os 24 tokens da tabela existem com exatamente os valores declarados
- [x] `microTag` usa **9.0**, não 8.5: §8 e o `CLAUDE.md` proíbem texto de UI abaixo de 9px, e o piso vence a faixa de §2 (A-02) — o doc comment registra o conflito e a resolução
- [x] Todo token de `Archivo Black` usa `FontWeight.w400` (A-11); nenhum token tem `fontWeight` nulo
- [x] **Nenhum** `FontVariation` no arquivo: o peso é declarado por `fontWeight` e o Flutter 3.47 move o eixo `wght` (ver `design.md` §Pesquisa e risco R-3)
- [x] `static const List<TextStyle> todos` contém **todos** os estilos declarados — a lista é contrato: estilo fora dela escapa da verificação
- [x] O teste percorre `todos` e afirma, para cada um: família ∈ {`Archivo`, `Archivo Black`}, `fontSize >= 9.0`, `fontWeight != null`, e `fontSize`/`letterSpacing`/`height` dentro da faixa de §2 daquele papel — com `reason` nomeando o papel
- [x] O teste afirma que `todos.length` bate com o número de estilos públicos declarados (senão a lista apodrece silenciosamente)
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥6

**Tests**: unit
**Gate**: quick
**Commit**: `feat(design-system): define a escala tipográfica archivo`

---

### T4: Prova de que o peso chega ao texto rasterizado

**What**: o teste de métrica que prova DS-03 — com a fonte carregada, `FontWeight` move o eixo `wght` — mais o helper local de `FontLoader`.
**Where**: `test/core/design_system/support/font_loading.dart`, `test/core/design_system/tokens/font_weight_axis_test.dart`
**Depends on**: T1, T3
**Reuses**: `FontLoader` de `package:flutter_test`; `rootBundle` já provado em T1
**Requirement**: DS-03

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `font_loading.dart` expõe um helper que carrega as duas famílias com `FontLoader` a partir do `rootBundle` — **local**, sem `flutter_test_config.dart` global (risco R-1: `flutter test` não carrega fonte do `pubspec`, e um config global mudaria o comportamento de toda a suíte, inclusive dos 92 testes de baseline)
- [x] O teste mede a largura da mesma string com `TextPainter` e afirma: largura(`FontWeight.w400`) **≠** largura(`FontWeight.w800`) — o eixo responde
- [x] O teste afirma: largura(`FontWeight.w800`) **==** largura(`FontVariation('wght', 800)`) — os dois caminhos são o mesmo mecanismo neste SDK. É este teste que avisa se o SDK do projeto um dia recuar para <3.41
- [x] O teste afirma que a família `Archivo Black` produz largura diferente de `Archivo` w400 — prova que a segunda família carregou de fato, e não caiu em fallback
- [x] As asserções usam pares de peso com diferença de largura **folgada** (w400 × w800 × w900), nunca vizinhos como w400 × w600, cuja diferença é de fração de pixel
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥3

**Tests**: unit
**Gate**: quick
**Commit**: `feat(design-system): prova que o peso da fonte variável chega ao texto`

---

### T5: Sombras, bordas, espaçamentos e o conjunto fechado de acentos

**What**: os tokens de forma de §3, de sombra de §4, os paddings literais de §5 e o `enum BoraAccent` com significado fixo.
**Where**: `lib/core/design_system/tokens/bora_shadows.dart`, `bora_borders.dart`, `bora_spacing.dart`, `bora_accent.dart` + espelho em `test/core/design_system/tokens/`
**Depends on**: T2
**Reuses**: `BoraColors` (T2); tabelas de §3, §4 e §5 do arquivo 02
**Requirement**: DS-05, DS-06, DS-07, DS-08

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `BoraShadows.hard(Color, double)` devolve `BoxShadow` com `blurRadius: 0` e `spreadRadius: 0`, e existem as constantes nomeadas dos usos de §4 (CTA 4 · login/link/grupo 5 · card branco 6 e 8 · card-herói 6 · flyer 8 · bolha WA 4)
- [x] `BoraShadows.frame` é a **única** com blur: `offset (0,20)`, `blurRadius 50`, `spreadRadius -20`, cor `frameShadow` — e o doc comment diz por quê (é o palco, não a UI)
- [x] `BoraBorders` expõe `raio = BorderRadius.zero`, `solida(cor)` com `width: 2`, `padraoInk`, `frame` (1px `frameBorder`), os descritores de tracejado `dicaTracejada` (2px `ink`) e `slotTracejado` (2px `text3`) e `opacidadeDesabilitado = 0.7`
- [x] `BoraSpacing` traz os paddings literais de §5 (botão, chip, linha de lista, card-herói, rodapé, sheet, tag, toast, input)
- [x] `BoraAccent` é um enum fechado (`primary`, `purple`, `waGreen`, `green`, `yellow`, `ink`) com `Color get cor` e o significado fixo de cada um no doc comment (vermelho = dinheiro/CTA · roxo = galera/link · `#25D366` = WhatsApp · verde = pago/comprado · amarelo = destaque · `ink` = neutro)
- [x] Os testes afirmam: `blurRadius == 0` e `spreadRadius == 0` em toda sombra dura; o `offset` de cada uma contra a tabela de §4; `BoraBorders.raio == BorderRadius.zero`; larguras de borda 2.0 (e 1.0 só no frame); cada `BoraAccent.cor` apontando para o token certo
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥8

**Tests**: unit
**Gate**: quick
**Commit**: `feat(design-system): define formas, sombras duras e acentos`

---

### T6: Motion, tema derivado e barrel público

**What**: as durações de §6, o `ThemeData` derivado dos tokens e o barrel que as telas vão importar.
**Where**: `lib/core/design_system/tokens/bora_motion.dart`, `bora_theme.dart`, `lib/core/design_system/design_system.dart` + espelho em `test/core/design_system/tokens/`
**Depends on**: T2, T3, T5
**Reuses**: `BoraColors`, `BoraTextStyles`, `BoraBorders`
**Requirement**: DS-10, DS-35

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `BoraMotion` expõe `estado = 150ms`, `toastIn = 300ms`, `progresso = 300ms`, `toastVida = 2200ms`, `toastSubida = 14.0` e `curva = Curves.ease` (A-04: o default do CSS `transition` é `ease`)
- [x] `boraTheme()` deriva **todo** valor dos tokens: `scaffoldBackgroundColor`/`canvasColor` = `paper`, `fontFamily` = `Archivo`, `textTheme` mapeando `BoraTextStyles`, `colorScheme` a partir de `BoraColors`, `splashFactory: NoSplash.splashFactory` (§8 não tem ripple)
- [x] `bora_theme.dart` **não contém literal de cor nem de `fontFamily`** — os dois só existem em `bora_colors.dart` e `bora_text_styles.dart` (é o que as guardas de T7/T8 vão policiar)
- [x] `design_system.dart` exporta os tokens desta fase; cada task seguinte acrescenta a sua linha de export
- [x] O teste afirma cada duração contra §6; afirma que `boraTheme().scaffoldBackgroundColor == BoraColors.paper`, que a família do `textTheme` é `Archivo` e que o splash é `NoSplash`
- [x] Gate: `flutter analyze && flutter test` passa (fim da Phase 1)
- [x] Novos testes: ≥5

**Tests**: unit
**Gate**: build
**Commit**: `feat(design-system): define motion e o tema derivado dos tokens`

---

### T7: Guarda de forma e de sombra

**What**: o teste de varredura que faz canto arredondado e sombra com blur **quebrarem a suíte**, com a allowlist das duas exceções do arquivo 02.
**Where**: `test/core/design_system/architecture/shape_and_shadow_guard_test.dart`
**Depends on**: T5, T6
**Reuses**: mecânica de `test/architecture/calculo_isolation_test.dart` (varredura com `dart:io`, mensagem que **nomeia o arquivo infrator**, asserção anti-vácuo)
**Requirement**: DS-05, DS-07

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] A varredura percorre `lib/core/design_system/` e falha ao encontrar `BorderRadius.circular`, `BorderRadius.all`, `RoundedRectangleBorder`, `StadiumBorder` ou `CircleBorder`; `BorderRadius.zero` passa
- [x] A varredura falha ao encontrar `blurRadius:` com valor diferente de zero
- [x] A **allowlist é por caminho** e já contempla arquivos que ainda não existem, porque é ela que autoriza as exceções que as fases 5–7 vão criar: `bora_phone_frame.dart` (radius 38 + a única sombra suave), `bora_avatar.dart` e `bora_poll_option.dart` (`BoxShape.circle`). O doc comment do teste cita §3 ("Exceções: avatares e dots… e o frame do celular")
- [x] O teste afirma que **varreu ≥1 arquivo** — sem isso passaria vacuamente (risco R-4)
- [x] Verificado à mão nos dois sentidos: injetar `BorderRadius.circular(8)` num arquivo de token faz falhar nomeando o arquivo; remover faz passar. O mesmo com `blurRadius: 4`
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥4

**Tests**: unit
**Gate**: quick
**Commit**: `feat(design-system): policia radius zero e sombra sem blur por teste`

---

### T8: Guarda de pureza de token

**What**: o teste de varredura que faz cor fora do token, fonte fora do token, gradiente, ripple, curva de mola e `FontVariation` quebrarem a suíte.
**Where**: `test/core/design_system/architecture/token_purity_guard_test.dart`
**Depends on**: T2, T3, T6
**Reuses**: mesma mecânica de T7
**Requirement**: DS-09, DS-10, DS-03

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] Falha ao encontrar literal de cor (`Color(0x…`, `Colors.`) em qualquer arquivo de `lib/core/design_system/` que não seja `bora_colors.dart`; `Colors.transparent` é tolerado (ausência de cor, não cor) e a tolerância está documentada no teste
- [x] Falha ao encontrar literal de `fontFamily:` fora de `bora_text_styles.dart`
- [x] Falha ao encontrar, em **qualquer** arquivo sob `lib/`: `Gradient`, `InkWell`, `InkResponse`, `Curves.elastic`, `Curves.bounce` ou `FontVariation` — as proibições de §8 e §6, mais a decisão de DS-03 (o peso é `fontWeight`, e `FontVariation` mascararia erro de peso)
- [x] Cada regra falha com mensagem que **nomeia o arquivo e o padrão** encontrado
- [x] O teste afirma que varreu ≥1 arquivo em cada escopo
- [x] Verificado à mão nos dois sentidos com `Color(0xFF00FF00)` e com `fontFamily: 'Roboto'`
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥5

**Tests**: unit
**Gate**: quick
**Commit**: `feat(design-system): policia cor, fonte e motion fora do token`

---

### T9: Guarda de fronteira com `calculo` e com a infraestrutura

**What**: o teste que impede o design system de importar a camada de cálculo, o Firebase ou o BLoC — a tradução executável de "nunca duplique uma fórmula em componente de UI".
**Where**: `test/core/design_system/architecture/design_system_boundary_test.dart`
**Depends on**: T6
**Reuses**: `test/architecture/calculo_isolation_test.dart` — este é o **espelho** dele, olhando do outro lado da fronteira
**Requirement**: DS-34

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] Falha se qualquer arquivo sob `lib/core/design_system/` importar `core/calculo/` (relativo ou por `package:`), `package:firebase…`, `cloud_firestore` ou `package:flutter_bloc`, nomeando o arquivo infrator
- [x] O doc comment do teste explica a fronteira: RN-11 (posição do marcador) e RN-13 (formatação `R$`) são da spec 02; os componentes recebem `double` já calculado e `String` já formatada
- [x] O teste afirma que varreu ≥1 arquivo
- [x] Verificado à mão nos dois sentidos: acrescentar `import '../../calculo/calculo.dart';` num arquivo de token faz falhar; remover faz passar
- [x] `lib/core/calculo/` **não foi tocado** por esta task nem por nenhuma outra desta spec
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥3

**Tests**: unit
**Gate**: quick
**Commit**: `feat(design-system): policia a fronteira com a camada de cálculo`

---

### T10: Rota `/catalogo` e a casa das seções

**What**: registrar a rota interna do catálogo, criar a página com a seção de tokens e o registro onde cada componente vai se inscrever.
**Where**: `lib/core/design_system/catalog/catalog_page.dart`, `catalog_sections.dart`, `lib/core/routing/routes.dart` (+1 constante), `lib/core/routing/app_router.dart` (+1 `GoRoute`), `test/core/routing/app_router_catalogo_test.dart`, `test/core/design_system/catalog/catalog_page_test.dart`
**Depends on**: T6
**Reuses**: `buildAppRouter` e a zona sem shell de `/entrar`/`/erro`; `AppShell.chromeKey`; o helper `_abrir(tester, location)` de `test/core/routing/app_router_publico_test.dart`; `ResponsiveBuilder`/`LayoutMode` de AD-007
**Requirement**: DS-33

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `Routes.catalogo = '/catalogo'` acrescentada **ao fim** da lista existente; nenhuma constante existente foi tocada ou reordenada
- [x] Uma `GoRoute` nova em `buildAppRouter`, irmã de `/entrar` e `/erro` — **fora de qualquer shell** (o catálogo não é tela de produto e o chrome do app ainda é placeholder da fundação)
- [x] `CatalogPage` envolve o conteúdo em `Theme(data: boraTheme(), …)` — o tema não é aplicado no `BoraApp`, que está fora da fronteira desta spec (A-16)
- [x] `catalog_sections.dart` expõe a lista de seções, cada uma com `titulo`, `referencia` (o trecho do arquivo 02, ex. `'§5 · Stepper'`) e `builder`; começa com a seção de tokens (cores, tipografia, sombras)
- [x] O layout usa `ResponsiveBuilder`/`LayoutMode` de **AD-007**; o breakpoint **não** é redeclarado nem reexportado
- [x] `app_router_catalogo_test.dart` abre `/catalogo` e **afirma o destino**: `find.byKey(Key('catalogo'))` presente, `AppShell.chromeKey` **ausente**, `RouteErrorPage.pageKey` ausente e `tester.takeException()` nulo — atende ao aviso da validação da fundação (nenhuma rota alcançável sem destino afirmado)
- [x] O teste da página afirma que ela renderiza em largura compacta (`< 900`) e expandida (`>= 900`) sem overflow
- [x] Os 92 testes de baseline continuam passando — nenhuma rota existente mudou
- [x] Gate: `flutter analyze && flutter test` passa (fim da Phase 2; a task mexe em `lib/core/routing/`)
- [x] Novos testes: ≥5

**Tests**: widget
**Gate**: build
**Commit**: `feat(design-system): abre a rota interna do catálogo`

---

### T11: `BoraSurface` — a superfície comum

**What**: o mecanismo "radius 0 + borda 2px + sombra dura", existindo uma vez só.
**Where**: `lib/core/design_system/components/bora_surface.dart`, `test/core/design_system/components/bora_surface_test.dart`, `test/core/design_system/support/pump_component.dart`, `catalog_sections.dart` (+1 seção), `design_system.dart` (+1 export)
**Depends on**: T5, T6
**Reuses**: `BoraColors`, `BoraBorders`, `BoraShadows`, `BoraAccent`
**Requirement**: DS-13

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `BoraSurface` renderiza `BoxDecoration` com `borderRadius: BorderRadius.zero`, borda de 2px na cor pedida e, quando há acento, **exatamente uma** `BoxShadow` dura
- [x] `pump_component.dart` monta um componente isolado com `boraTheme()` — é o helper que as fases 4–7 reusam
- [x] O teste lê a `BoxDecoration` **da árvore renderizada** e afirma: `borderRadius == BorderRadius.zero`, `border.top.width == 2.0`, `border.top.color == BoraColors.ink`, `boxShadow.length == 1`, `boxShadow.single.blurRadius == 0`, `boxShadow.single.offset == Offset(4, 4)`
- [x] O teste afirma que sem acento **não há sombra alguma** (e não uma sombra transparente)
- [x] Seção registrada em `catalog_sections.dart` e export acrescentado ao barrel
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥4

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria a superfície comum de borda e sombra dura`

---

### T12: `BoraPressSink` — o afundamento obrigatório do CTA

**What**: o mecanismo de §4: `translate(2,2)` e sombra encolhendo de 4px para 2px, no press **e** no hover.
**Where**: `lib/core/design_system/components/bora_press_sink.dart`, `test/core/design_system/components/bora_press_sink_test.dart`, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T11
**Reuses**: `BoraSurface`, `BoraMotion`, `BoraAccent`
**Requirement**: DS-11

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] No `pointer down` o widget desloca `Offset(2, 2)` **e** a sombra passa de `Offset(4, 4)` para `Offset(2, 2)`, em `BoraMotion.estado` (150ms) com `BoraMotion.curva`
- [x] No `pointer up` e no `pointer cancel` volta a `Offset.zero` e `Offset(4, 4)`
- [x] Com mouse, `onEnter` afunda igual e `onExit` volta (§4: "Hover/press de CTA (**obrigatório**)")
- [x] `onPressed == null` ⇒ `Opacity(0.7)` (A-07) e **não** afunda em press nem em hover
- [x] O teste usa `tester.startGesture` e lê a translação do `Transform`/`Matrix4` e o `offset` do `BoxShadow` da árvore — nos dois estados, ida e volta
- [x] Seção registrada no catálogo e export no barrel
- [x] Gate: `flutter test` passa (fim da Phase 3 é T13; este gate é quick)
- [x] Novos testes: ≥5

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria o press que afunda o cta`

---

### T13: `BoraToast` e os textos canônicos de RN-29

**What**: o toast de 2200ms, um por vez, e as 11 strings literais de RN-29.
**Where**: `lib/core/design_system/components/bora_toast.dart`, `bora_toast_texts.dart`, `test/core/design_system/components/bora_toast_test.dart`, `bora_toast_texts_test.dart`, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T6
**Reuses**: `BoraColors`, `BoraTextStyles.toast`, `BoraShadows`, `BoraMotion`, `Overlay` do framework
**Requirement**: DS-12, DS-32

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] O visual é um widget próprio (`BoraToastContent`, com `Key('bora-toast')`), separado do controlador de `Overlay` — assim o catálogo mostra o toast **estático** sem depender de botão, e o teste de aparência não precisa do overlay
- [x] `BoraToast.mostrar(context, texto:, acento:)` insere **uma** `OverlayEntry` centralizada em `bottom: 112`, fundo `ink`, texto `cream` 800/13 `ls .5`, sombra dura no acento, entrando com fade + subida de 14px em 300ms `ease`
- [x] Depois de `BoraMotion.toastVida` (2200ms) o toast some **sozinho**, sem interação
- [x] Um segundo `mostrar` com o primeiro visível **substitui**: a árvore tem exatamente **um** toast, com o texto do segundo, e o `Timer` do primeiro foi cancelado (senão ele derrubaria o novo antes da hora)
- [x] `mostrar` com `Overlay` ausente/desmontado retorna em silêncio, sem lançar (`Overlay.maybeOf` + checagem de `mounted` antes de `remove()` — risco R-8)
- [x] `BoraToastTexts` traz as **11** constantes de RN-29 **caractere por caractere, emoji incluído** ("LINK COPIADO 🔗", "ROLÊ SALVO ✊", "CONVITE COPIADO 📋", "LISTA NO GRUPO 📲", "ABRINDO O WHATSAPP… 📲", "SALVO NA AGENDA 📅", "LEMBRETE MANDADO NO GRUPO 📲", "COBRANÇA ENVIADA NO PIX 📲", "GRUPO CRIADO NO WHATSAPP ✅", "ENQUETE POSTADA NO GRUPO 📲", "CRIE O GRUPO PRIMEIRO ☝️") mais `todos` para o teste percorrer — repare no **reticências unicode** de "ABRINDO O WHATSAPP… 📲"
- [x] O teste de tempo afirma presente em 2199ms e ausente logo depois de 2200ms; o teste de substituição dispara dois seguidos; o teste de texto compara as 11 strings com os literais de RN-29
- [x] Nenhum `Timer` pendente ao fim de cada teste
- [x] Seção registrada no catálogo e export no barrel
- [x] Gate: `flutter analyze && flutter test` passa (fim da Phase 3)
- [x] Novos testes: ≥8

**Tests**: widget
**Gate**: build
**Commit**: `feat(design-system): cria o toast de instância única com os textos de rn-29`

---

### T14: Botões primário e secundário

**What**: os dois botões de §5, ambos afundando pelo mecanismo de T12.
**Where**: `lib/core/design_system/components/bora_primary_button.dart`, `bora_secondary_button.dart` + espelho de testes, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T12
**Reuses**: `BoraPressSink`, `BoraSurface`, `BoraTextStyles.botao`/`botaoGrande`, `BoraSpacing.botao`
**Requirement**: DS-14, DS-32

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] Primário: fundo `ink`, texto `cream`, borda 2px `ink`, padding de §5, sombra `4px 4px 0` no acento do contexto; `larguraTotal: true` ocupa a largura do pai (o CTA do rodapé)
- [x] Secundário: fundo transparente ou branco, borda 2px `ink`, texto `ink`; no hover ganha fundo `paper` **ou** sombra dura — nunca radius
- [x] Os dois aplicam `toUpperCase()` no rótulo (DS-32): entra `bora`, sai `BORA`
- [x] Rótulo vazio renderiza sem exceção
- [x] `onPressed == null` ⇒ opacidade 0.7 e nenhum callback disparado ao tocar
- [x] Os testes afirmam cor de fundo, cor de texto, largura de borda, offset da sombra e o texto renderizado em CAIXA ALTA, lendo a árvore
- [x] Seções registradas no catálogo e exports no barrel
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥7

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria os botões primário e secundário`

---

### T15: `BoraSelectionChip` — chip de seleção

**What**: o chip de itens da festa, com os dois estados de §5.
**Where**: `lib/core/design_system/components/bora_selection_chip.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T11
**Reuses**: `BoraSurface`, `BoraTextStyles.chip`, `BoraSpacing.chip`, `BoraMotion.estado`
**Requirement**: DS-15, DS-32

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] Não selecionado: fundo branco, texto `ink`. Selecionado: fundo `ink`, texto `cream`
- [x] Padding 10×14, texto 800/13 em CAIXA ALTA, emoji **à esquerda** do rótulo
- [x] A troca de estado usa `BoraMotion.estado` (150ms) — o `.15s` de §6
- [x] O teste afirma os dois estados lendo cor de fundo e cor do texto da árvore, afirma a ordem emoji→rótulo e afirma o rótulo em CAIXA ALTA
- [x] Seção registrada no catálogo (os dois estados lado a lado) e export no barrel
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥4

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria o chip de seleção`

---

### T16: `BoraSegmentedControl` — segmented control

**What**: o segmented de §5, com a variante sobre card escuro.
**Where**: `lib/core/design_system/components/bora_segmented_control.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T15
**Reuses**: `BoraSurface`, `BoraColors.divider2`/`creamQuarter`, `BoraTextStyles.botao`
**Requirement**: DS-16, DS-32

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] Container com borda 2px `ink` sobre branco; botões dividindo a largura igualmente (`flex: 1`), separados por divisor de 2px `divider2`
- [x] **Exatamente um** ativo: fundo `ink` + texto `cream`; inativos transparentes com `text2`
- [x] Variante `sobreCardEscuro: true`: borda e divisores em `creamQuarter` (cream 25%) e o ativo muda **só o texto** para `cream`
- [x] Com `n` opções há `n - 1` divisores; com 1 opção há **zero** divisores (edge case da spec)
- [x] Tocar uma opção chama `onSelecionar` com o índice — o componente **não** guarda o índice ativo (é prop)
- [x] Os testes afirmam contagem de divisores, o par ativo/inativo nas duas variantes e o caso de 1 opção
- [x] Seção registrada no catálogo (as duas variantes) e export no barrel
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥5

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria o segmented control`

---

### T17: `BoraStepper` — stepper sem aritmética

**What**: o `− n +` de §5, com alvo de toque ≥44px e **nenhuma conta** dentro do componente.
**Where**: `lib/core/design_system/components/bora_stepper.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T16
**Reuses**: `BoraSurface`, `BoraTextStyles.stepperValor`, `BoraColors`
**Requirement**: DS-17, DS-34

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Botões 34×34 visualmente: `−` branco com borda `ink`; `+` fundo `ink` com texto `cream` (hover `primary`). Valor central 800/17
- [ ] O **alvo de toque** de cada botão mede ≥44px nos dois eixos, via padding — afirmado com `tester.getSize` sobre o detector de gesto, não sobre a caixa visual
- [ ] `onIncrementar`/`onDecrementar` são `VoidCallback` **sem payload**: o componente não calcula `valor + 1` nem conhece mínimo, máximo ou passo (RN-12 é da spec `calculo`). O valor exibido é sempre a prop recebida
- [ ] `onDecrementar == null` ⇒ o `−` aparece com opacidade 0.7 e não emite nada ao ser tocado
- [ ] O teste afirma: tocar `+` chama `onIncrementar` exatamente uma vez e **o valor exibido não muda sozinho** (prova de que não há estado interno nem aritmética)
- [ ] Seção registrada no catálogo e export no barrel
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥5

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria o stepper com alvo de toque acessível`

---

### T18: `BoraTextField` — input

**What**: o input de §5, com o foco trocando a borda para `primary`.
**Where**: `lib/core/design_system/components/bora_text_field.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T17
**Reuses**: `BoraSurface`, `BoraTextStyles.input`, `BoraSpacing.input`, `BoraColors.primary`
**Requirement**: DS-18

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Sem foco: fundo branco, borda 2px `ink`, radius zero, padding 15×16, texto 600/15
- [ ] Com foco: a borda vira `primary`, mantendo largura 2px e radius zero
- [ ] O placeholder **não** é transformado (A-06: minúscula em placeholder é exemplo de §5, não lei de §7 — `toLowerCase()` estragaria nome próprio); a seção do catálogo usa os literais "seu e-mail" e "senha"
- [ ] O teste afirma a cor da borda antes e depois de `requestFocus`, lendo a árvore
- [ ] Seção registrada no catálogo e export no barrel
- [ ] Gate: `flutter analyze && flutter test` passa (fim da Phase 4)
- [ ] Novos testes: ≥4

**Tests**: widget
**Gate**: build
**Commit**: `feat(design-system): cria o input com foco vermelho`

---

### T19: `BoraListCard` — card de lista

**What**: o card branco com linhas separadas por divisor, de §5.
**Where**: `lib/core/design_system/components/bora_list_card.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T11
**Reuses**: `BoraSurface`, `BoraColors.divider`, `BoraTextStyles.linhaLista`/`sublinhaLista`, `BoraSpacing.linhaLista`
**Requirement**: DS-19

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Fundo branco, borda 2px `ink`; cada linha com padding 12–13×14–16, emoji 19–20px à esquerda, título/sublinha à esquerda e valor 800/14 à direita
- [ ] Entre linhas há divisor de **2px** na cor `divider`; com `n` linhas há `n - 1` divisores, e com 1 linha há **zero**
- [ ] O valor da direita chega como `String` já formatada — o componente não formata `R$` (RN-13 é da spec `calculo`)
- [ ] O teste afirma contagem de divisores, largura e cor do divisor, e a posição do emoji e do valor
- [ ] Seção registrada no catálogo e export no barrel
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥4

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria o card de lista`

---

### T20: `BoraExpandableGroup` / `BoraExpandableRow` — accordion

**What**: a linha expansível de §5, com a regra de **uma aberta por vez**.
**Where**: `lib/core/design_system/components/bora_expandable_row.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T19
**Reuses**: visual de linha de `BoraListCard`, `BoraColors.paper`, `BoraBorders`
**Requirement**: DS-20

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Caret `▾` quando fechada e `▴` quando aberta — os glifos literais de §5, afirmados no teste
- [ ] Painel aberto com fundo `paper` e `border-top` de 2px
- [ ] O **grupo** guarda qual linha está aberta: abrir a segunda **fecha** a primeira; tocar a que já está aberta **fecha** e deixa o grupo sem nenhuma; o grupo começa com **nenhuma** aberta
- [ ] O teste cobre os três casos acima afirmando presença/ausência do painel de cada linha
- [ ] Seção registrada no catálogo (grupo de três linhas) e export no barrel
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥5

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria a linha expansível com uma aberta por vez`

---

### T21: `BoraAvatar` / `BoraStackedAvatars` — avatares empilhados

**What**: o avatar circular (uma das duas exceções de forma) e a pilha com o slot `+N` tracejado.
**Where**: `lib/core/design_system/components/bora_avatar.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T2, T7
**Reuses**: `BoraColors.avatarPairFor` (T2), a allowlist de forma de T7, `BoraBorders`
**Requirement**: DS-21

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Avatar circular de 34–40px com borda 2px `ink` e a inicial em 800 — **exceção de forma autorizada por §3**, e o arquivo já está na allowlist de T7
- [ ] A inicial é a **primeira letra** do nome, em CAIXA ALTA (A-13)
- [ ] As cinco personas usam os pares fixos de §1; nome fora da tabela recebe um dos **mesmos cinco** pares, sempre o mesmo para o mesmo nome
- [ ] Pilha com sobreposição negativa de `-8` a `-10px`; último slot `+N` branco com borda **tracejada**
- [ ] `extras == 0` ⇒ o slot `+N` **não** é renderizado (edge case da spec)
- [ ] O teste afirma: forma circular, cor de fundo e de texto de cada persona, determinismo do fallback (duas chamadas, mesma cor), sobreposição negativa e ausência do slot com `+0`
- [ ] A guarda de T7 continua passando (o arquivo está na allowlist, e só ele)
- [ ] Seção registrada no catálogo e export no barrel
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥6

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria os avatares empilhados`

---

### T22: `BoraStatusTag` — tag de status

**What**: a pill quadrada de §5 com os sete significados.
**Where**: `lib/core/design_system/components/bora_status_tag.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T11
**Reuses**: `BoraSurface`, `BoraTextStyles.microTag`, `BoraSpacing.tag`
**Requirement**: DS-22, DS-32

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `enum BoraStatus { recebe, paga, noZero, anfitriao, coAnfitriao, convidado, soVe }`, cada um com o par fundo/texto de §5: RECEBE = `ink` · PAGA = `primary` · NO ZERO = branco · ANFITRIÃO = `yellow` · CO-ANFITRIÃO = `purple` com texto branco · CONVIDADO = branco · SÓ VÊ = `waBubble` com texto `text2`
- [ ] Borda 2px `ink`, padding 4–6×7–9, texto 800/9–10.5 com `letterSpacing .5` — o token `microTag`, cujo tamanho já respeita o piso de 9px (A-02)
- [ ] O rótulo sai em CAIXA ALTA
- [ ] O teste percorre os **sete** valores do enum e afirma o par de cores de cada um — um teste que falha se alguém acrescentar um status sem cor
- [ ] Seção registrada no catálogo (os sete lado a lado) e export no barrel
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥4

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria a tag de status`

---

### T23: `BoraDashedNote` e `BoraEmptySlot` — os dois tracejados de §3

**What**: a dica/nota com emoji-âncora e o slot vazio/desabilitado, ambos com borda tracejada desenhada à mão.
**Where**: `lib/core/design_system/components/bora_dashed_note.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T22
**Reuses**: `BoraColors`, `BoraTextStyles.dica`, `BoraBorders.dicaTracejada`/`slotTracejado`
**Requirement**: DS-23

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] O tracejado é um `CustomPainter` próprio (~30 linhas): o Flutter **não** tem `BorderStyle.dashed`, e a alternativa (pacote novo ou imagem) violaria AD-002 (risco R-10)
- [ ] Dica/nota: borda 2px tracejada `ink`, fundo branco, texto 600/12 `text2`, sempre com emoji-âncora (💡 📊 ✅) à esquerda
- [ ] Slot vazio/desabilitado: borda 2px tracejada `text3` e `opacity 0.7`
- [ ] Radius zero nos dois — a guarda de T7 continua passando (nenhum dos dois entra na allowlist)
- [ ] O teste afirma o painter, as cores e as larguras dos dois; afirma a presença do emoji na dica
- [ ] Seções registradas no catálogo e exports no barrel
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥4

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria a dica tracejada e o slot vazio`

---

### T24: `BoraRotatedTag` — tag rotacionada

**What**: a tag que vaza o topo do card, girada `-2°` ou `+3°`.
**Where**: `lib/core/design_system/components/bora_rotated_tag.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T23
**Reuses**: `BoraSurface`, `BoraTextStyles.microTag`, `BoraAccent`
**Requirement**: DS-24, DS-32

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Rotação de `-2°` (variante esquerda) e `+3°` (direita), convertidas para **radianos** (`-2 * pi / 180` e `3 * pi / 180`) — grau cru em `Transform.rotate` seria erro silencioso
- [ ] Fundo `primary` ou `yellow` (pelo `BoraAccent`), borda 2px `ink`, radius zero
- [ ] Posicionada vazando o topo do card em `-13px`
- [ ] Texto em CAIXA ALTA no token `microTag`
- [ ] O teste afirma o ângulo em radianos lendo o `Transform` da árvore e afirma o deslocamento de `-13`
- [ ] Seção registrada no catálogo (as duas inclinações) e export no barrel
- [ ] Gate: `flutter analyze && flutter test` passa (fim da Phase 5)
- [ ] Novos testes: ≥4

**Tests**: widget
**Gate**: build
**Commit**: `feat(design-system): cria a tag rotacionada`

---

### T25: `BoraHeroCard` — card-herói escuro

**What**: o card escuro do dinheiro, de §5.
**Where**: `lib/core/design_system/components/bora_hero_card.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T11
**Reuses**: `BoraSurface`, `BoraShadows.cardHeroi`, `BoraTextStyles.heroiLabel`/`valorHeroi`/`heroiSublinha`
**Requirement**: DS-25, DS-32, DS-34

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Fundo `ink`, padding 20–22, sombra `6px 6px 0` `primary` (`blurRadius 0`)
- [ ] Label `yellow` 800/12 `ls 1` em CAIXA ALTA; valor `cream` Archivo Black 40; sublinha `primary` 700/13
- [ ] O valor chega como **`String` já formatada** — o componente não formata `R$`, não arredonda e não divide (DS-34; RN-13 é da spec `calculo`). A assinatura usa `valorFormatado`, não `num`
- [ ] O teste afirma cor de fundo, offset e blur da sombra, e as três cores de texto; afirma que passar `'R$ 211'` renderiza `'R$ 211'` intacto
- [ ] Seção registrada no catálogo e export no barrel
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥4

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria o card-herói escuro`

---

### T26: `BoraFooterBar` — rodapé fixo com CTA

**What**: a barra de rodapé de §5, com o bloco "SAI POR" à esquerda e o CTA à direita.
**Where**: `lib/core/design_system/components/bora_footer_bar.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T14, T25
**Reuses**: `BoraPrimaryButton` (slot do CTA), `BoraTextStyles.rodapeLabel`/`valorRodape`/`rodapeSublinha`, `BoraSpacing.rodape`
**Requirement**: DS-26, DS-32, DS-34

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Fundo `paper`, **`border-top` de 2px `ink`** — só o topo, não a borda inteira (erro fácil de cometer com `BoraSurface`)
- [ ] Padding 14–16 / 24 / 30; bloco à esquerda com label 800/11 `ls 1` `text2` em CAIXA ALTA + valor Archivo Black + sublinha `primary` 700/12.5; CTA à direita como `Widget` recebido
- [ ] O valor chega como `String` já formatada (DS-34)
- [ ] O teste afirma que existe borda **apenas** no topo, com 2px `ink`, e afirma os três estilos de texto
- [ ] Seção registrada no catálogo (com um `BoraPrimaryButton` de CTA) e export no barrel
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥4

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria o rodapé fixo com cta`

---

### T27: `BoraPriceRangeBar` — barra de faixa de preço

**What**: o trilho mín/máx de §5, que **recebe a fração pronta** e só pinta.
**Where**: `lib/core/design_system/components/bora_price_range_bar.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T26
**Reuses**: `BoraColors.paper2`/`primary`, `BoraBorders`, `BoraTextStyles.extremosFaixa`
**Requirement**: DS-27, DS-34

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Trilho de 8px de altura, fundo `paper2`, borda 2px `ink`; marcador de 8×12 com fundo `primary` e borda 2px `ink`; extremos rotulados abaixo em 700/10 `text3`
- [ ] A posição do marcador chega como `double fracao` **já calculada** — `(média−mín)/(máx−mín)` é RN-11 e pertence à spec `calculo` (DS-34). A assinatura **não** aceita `media`, `min` nem `max` numéricos; os rótulos dos extremos chegam como `String` já formatada
- [ ] Fração `< 0` ⇒ 0; `> 1` ⇒ 1; `NaN` ou infinita ⇒ `0.0` — sem lançar (edge case da spec; `min == max` produziria NaN lá na origem)
- [ ] O teste cobre `0.0`, `0.5`, `1.0`, `-0.3`, `1.7`, `double.nan` e `double.infinity`, afirmando a posição resultante do marcador
- [ ] Seção registrada no catálogo (três frações) e export no barrel
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥5

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria a barra de faixa de preço`

---

### T28: `BoraProgressBar` — barra de progresso de quitação

**What**: a barra de §5 que anima a largura em 300ms. **P2** da spec (marco M3).
**Where**: `lib/core/design_system/components/bora_progress_bar.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T27
**Reuses**: `BoraColors.waGreen`/`cream`, `BoraMotion.progresso`
**Requirement**: DS-28, DS-34

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Altura 12px, borda 2px `cream` (a variante sobre card escuro), preenchimento `waGreen`, animação de largura em `BoraMotion.progresso` (300ms)
- [ ] A fração chega já calculada (RN-18 é da spec `calculo`) e sofre o **mesmo clamp** de T27, incluindo não-finito
- [ ] O teste afirma a largura do preenchimento em `0.0`, `0.5` e `1.0` e cobre os casos fora da faixa
- [ ] Seção registrada no catálogo e export no barrel
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥4

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria a barra de progresso de quitação`

---

### T29: `BoraPollOption` — opção de enquete estilo WhatsApp

**What**: a opção de enquete de §5. **P2** da spec (marco M2).
**Where**: `lib/core/design_system/components/bora_poll_option.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T7, T28
**Reuses**: `BoraSurface`, `BoraColors.waGreen`/`pollFill`, a allowlist de forma de T7 (o radio é circular)
**Requirement**: DS-29, DS-34

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Borda 2px `ink`; `waGreen` quando `meuVoto` é verdadeiro
- [ ] Barra de % preenchendo o fundo com `pollFill` (`rgba(37,211,102,.18)`), largura pela fração recebida
- [ ] Radio **circular** de 15px, verde quando votado — **exceção de forma autorizada por §3** ("dots"), e o arquivo está na allowlist de T7
- [ ] Percentual à direita e contagem "n votos" abaixo, ambos chegando como **`String` já formatada** (DS-34)
- [ ] A fração sofre o mesmo clamp de T27/T28
- [ ] O teste afirma a borda nos dois estados, a largura do preenchimento e a forma circular do radio
- [ ] A guarda de T7 continua passando
- [ ] Seção registrada no catálogo (votado e não votado) e export no barrel
- [ ] Gate: `flutter analyze && flutter test` passa (fim da Phase 6)
- [ ] Novos testes: ≥5

**Tests**: widget
**Gate**: build
**Commit**: `feat(design-system): cria a opção de enquete`

---

### T30: `BoraBottomSheet` — bottom sheet

**What**: o sheet ancorado embaixo, de §5, com o scrim arroxeado.
**Where**: `lib/core/design_system/components/bora_bottom_sheet.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T14
**Reuses**: `BoraColors.sheetScrim`/`paper`, `BoraTextStyles.tituloSheet`, `BoraSpacing.sheet`, `BoraBorders`
**Requirement**: DS-30, DS-32

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] Overlay com `BoraColors.sheetScrim` (`rgba(20,10,50,.45)`) — **não** é `ink` com opacidade; é um preto-arroxeado, e o doc comment registra isso
- [ ] Painel ancorado embaixo, fundo `paper`, `border-top` de 2px `ink`, padding 22/24/30, radius **zero**
- [ ] Título Archivo Black 22 em CAIXA ALTA + botão ✕ de 32×32 com borda 2px
- [ ] Tocar o ✕ (ou o scrim) fecha o sheet
- [ ] O teste afirma a cor do scrim, a borda só no topo, o tamanho do ✕ e o fechamento
- [ ] Seção registrada no catálogo (com um botão que abre o sheet) e export no barrel
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥5

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria o bottom sheet`

---

### T31: `BoraPhoneFrame` — o palco

**What**: o frame de apresentação 390×820 — as **duas** exceções do sistema (radius 38 e a única sombra suave) num arquivo só.
**Where**: `lib/core/design_system/components/bora_phone_frame.dart` + teste, `catalog_sections.dart`, `design_system.dart`
**Depends on**: T7, T30
**Reuses**: `BoraShadows.frame`, `BoraBorders.frame`, a allowlist de T7
**Requirement**: DS-31, DS-07

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] 390×820, `borderRadius` de **38**, borda de 1px `frameBorder` (`rgba(0,0,0,.25)`), `clipBehavior` que corta o conteúdo
- [ ] Coluna flex: header fixo, conteúdo rolando no meio (`Expanded` + scroll), rodapé fixo
- [ ] A sombra é `BoraShadows.frame` — a **única** do sistema com `blurRadius > 0`, e o doc comment diz por quê ("é o palco, não a UI", §4)
- [ ] O teste afirma o tamanho 390×820, o radius 38, a largura de borda 1.0 e que a sombra tem `blurRadius > 0`; afirma que o conteúdo central rola e que header/rodapé não
- [ ] O teste de T7 continua passando com este arquivo na allowlist — e falharia se qualquer **outro** arquivo tentasse a mesma coisa
- [ ] Seção registrada no catálogo e export no barrel
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥4

**Tests**: widget
**Gate**: quick
**Commit**: `feat(design-system): cria o frame do celular`

---

### T32: Catálogo completo, responsivo e verificado por completude

**What**: fechar o catálogo — layout compacto e expandido, e o teste que falha nomeando qualquer componente ou export que faltar.
**Where**: `lib/core/design_system/catalog/catalog_page.dart`, `catalog_sections.dart`, `lib/core/design_system/design_system.dart`, `test/core/design_system/catalog/catalog_completude_test.dart`
**Depends on**: T10, T31
**Reuses**: as seções registradas por T11–T31; `ResponsiveBuilder`/`LayoutMode` (AD-007); `BoraPhoneFrame` (para a seção que mostra o palco)
**Requirement**: DS-33

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] O catálogo renderiza **todas** as seções registradas, cada uma com o título e a referência ao trecho do arquivo 02 (`'§5 · Stepper'`), para que a conferência a olho seja seção-a-seção contra a spec-fonte
- [ ] Layout compacto (`< 900`) rola numa coluna; expandido (`>= 900`) usa largura maior sem overflow — os dois pelo `LayoutMode` de **AD-007**, sem redeclarar o breakpoint
- [ ] O teste de completude percorre uma lista canônica de tipos de componente e afirma `find.byType(...)` para **cada** um, falhando com o **nome** do que faltou — é isto que impede um componente de existir sem lugar de conferência
- [ ] O mesmo teste afirma que o barrel `design_system.dart` exporta todo componente e todo token, falhando com o nome do que não estiver exportado
- [ ] Os dois layouts são exercitados com `tester.view.physicalSize` nas duas larguras, afirmando ausência de overflow (`tester.takeException()` nulo)
- [ ] Os 92 testes de baseline continuam passando; contagem final reportada
- [ ] Gate: `flutter analyze && flutter test` passa (fim da Phase 7)
- [ ] Novos testes: ≥4
- [ ] **M** — `flutter run` e `flutter run -d chrome`, abrir `/catalogo` e conferir cada seção contra `.specs/init-spec/02-design-system.md` — **pendente com o usuário**: não há device nem navegador neste ambiente (risco R-11). O executor **reporta como não verificado**, não assume que passou

**Tests**: widget
**Gate**: build
**Commit**: `feat(design-system): fecha o catálogo com verificação de completude`

---

## Phase Execution Map

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7

Phase 1:  T1 ──→ T3 ──→ T4
          T2 ──→ T5 ──→ T6
Phase 2:  T7    T8    T9    T10
Phase 3:  T11 ─→ T12        T13
Phase 4:  T14   T15 ─→ T16 ─→ T17 ─→ T18
Phase 5:  T19 ─→ T20   T21   T22 ─→ T23 ─→ T24
Phase 6:  T25   T26 ─→ T27 ─→ T28 ─→ T29
Phase 7:  T30   T31   T32
```

Execução é estritamente sequencial — sem paralelismo dentro da fase. As setas são **dependência**, não agenda: tasks sem seta entre si ainda rodam na ordem numérica.

**Packing previsto para o Execute** (32 tasks, orçamento ~7 por lote, corte só em fronteira de fase):

| Lote | Fases | Tasks | Total |
|---|---|---|---|
| 1 | Phase 1 | T1–T6 | 6 |
| 2 | Phase 2 + Phase 3 | T7–T13 | 7 |
| 3 | Phase 4 | T14–T18 | 5 |
| 4 | Phase 5 | T19–T24 | 6 |
| 5 | Phase 6 + Phase 7 | T25–T32 | 8 |

Mais de um lote ⇒ **a oferta de sub-agentes será apresentada no início do Execute** (offer-then-confirm; nada é despachado sem aceite). O Verifier roda automaticamente depois de T32, sem pergunta.

---

## Task Granularity Check

| Task | Scope | Status |
|---|---|---|
| T1 | 1 asset + 1 seção de config + 1 teste | ✅ Granular |
| T2 | 1 arquivo de token | ✅ Granular |
| T3 | 1 arquivo de token | ✅ Granular |
| T4 | 1 helper + 1 teste de mecanismo | ✅ Granular |
| T5 | 4 arquivos de token do mesmo conceito (forma/sombra/espaço/acento) | ⚠️ Coesos — OK (são tabelas irmãs de §3/§4/§5 e o teste de sombra referencia o acento) |
| T6 | 1 motion + 1 tema derivado + barrel | ⚠️ 3 coesos — OK (o tema não tem teste próprio sem o motion, e o barrel nasce vazio sem eles) |
| T7 | 1 guarda | ✅ Granular |
| T8 | 1 guarda | ✅ Granular |
| T9 | 1 guarda | ✅ Granular |
| T10 | 1 página + 1 rota + 1 registro | ⚠️ Coesos — OK (a rota sem página não é verificável; merge backward prescrito pela skill) |
| T11 | 1 componente + 1 helper de teste | ✅ Granular |
| T12 | 1 componente | ✅ Granular |
| T13 | 1 componente + 1 tabela de copy | ⚠️ 2 coesos — OK (os textos sem o toast não têm onde ser afirmados no render) |
| T14 | 2 widgets irmãos | ⚠️ 2 coesos — OK (compartilham o `BoraPressSink` e o teste de CAIXA ALTA) |
| T15..T22 | 1 componente cada | ✅ Granular |
| T23 | 2 widgets que compartilham o mesmo `CustomPainter` tracejado | ⚠️ 2 coesos — OK |
| T24..T31 | 1 componente cada | ✅ Granular |
| T32 | 1 layout + 1 teste de completude | ✅ Granular |

Nenhum ❌: as tasks ⚠️ agrupam de 2 a 4 arquivos do **mesmo conceito**, e o agrupamento existe para que nenhuma task produza código não verificado.

## Diagram-Definition Cross-Check

| Task | Depends On (corpo) | Diagrama mostra | Status |
|---|---|---|---|
| T1 | None | entrada da Phase 1 | ✅ |
| T2 | None | entrada da Phase 1 | ✅ |
| T3 | T1, T2 | T1 → T3 (T2 entra pelo ramo de tokens da mesma fase) | ✅ |
| T4 | T1, T3 | T3 → T4 (T1 herdado na cadeia T1→T3) | ✅ |
| T5 | T2 | T2 → T5 | ✅ |
| T6 | T2, T3, T5 | T5 → T6 (T2 e T3 herdados na cadeia) | ✅ |
| T7 | T5, T6 | T5, T6 → T7 | ✅ |
| T8 | T2, T3, T6 | T6 → T8 (T2 e T3 herdados) | ✅ |
| T9 | T6 | T6 → T9 | ✅ |
| T10 | T6 | T6 → T10 | ✅ |
| T11 | T5, T6 | Phase 3 entra depois da Phase 2; T11 é a raiz da fase | ✅ |
| T12 | T11 | T11 → T12 | ✅ |
| T13 | T6 | T6 → T13 | ✅ |
| T14 | T12 | T12 → T14 | ✅ |
| T15 | T11 | T11 → T15 | ✅ |
| T16 | T15 | T15 → T16 | ✅ |
| T17 | T16 | T16 → T17 | ✅ |
| T18 | T17 | T17 → T18 | ✅ |
| T19 | T11 | T11 → T19 | ✅ |
| T20 | T19 | T19 → T20 | ✅ |
| T21 | T2, T7 | T2, T7 → T21 | ✅ |
| T22 | T11 | T11 → T22 | ✅ |
| T23 | T22 | T22 → T23 | ✅ |
| T24 | T23 | T23 → T24 | ✅ |
| T25 | T11 | T11 → T25 | ✅ |
| T26 | T14, T25 | T14 → T26 (T25 é irmão imediato na fase) | ✅ |
| T27 | T26 | T26 → T27 | ✅ |
| T28 | T27 | T27 → T28 | ✅ |
| T29 | T7, T28 | T7, T28 → T29 | ✅ |
| T30 | T14 | T14 → T30 | ✅ |
| T31 | T7, T30 | T7 → T31 (T30 é irmão imediato na fase) | ✅ |
| T32 | T10, T31 | T10, T31 → T32 | ✅ |

Nenhuma dependência aponta para fase posterior.

## Test Co-location Validation

| Task | Camada criada/modificada | Matriz exige | Task diz | Status |
|---|---|---|---|---|
| T1 | Asset de fonte + seção do `pubspec.yaml` | unit (linha "Asset de fonte") | unit | ✅ |
| T2 | Token Dart puro | unit | unit | ✅ |
| T3 | Escala tipográfica | unit | unit | ✅ |
| T4 | Métrica tipográfica (+ helper de teste) | unit | unit | ✅ |
| T5 | Tokens Dart puros | unit | unit | ✅ |
| T6 | Motion + tema derivado | unit | unit | ✅ |
| T7 | Guarda de arquitetura | unit | unit | ✅ |
| T8 | Guarda de arquitetura | unit | unit | ✅ |
| T9 | Guarda de arquitetura | unit | unit | ✅ |
| T10 | Catálogo + **rota nova** | widget (a maior exigência entre as duas camadas) | widget | ✅ |
| T11–T31 | Componentes | widget | widget | ✅ |
| T32 | Catálogo | widget | widget | ✅ |

Nenhuma ❌ VIOLATION e **nenhum `Tests: none`** nesta spec.

Dois esclarecimentos, para o Verifier não tratar como anomalia:

1. **T7, T8 e T9 entregam apenas testes.** Não é deferimento de teste de outra task — é o inverso: a *entrega* desses requisitos (DS-05, DS-07, DS-09, DS-34) **é** o sensor. §8 é uma lista de proibições, e proibição sem sensor não é implementável de outro jeito. Cada um é verificado nos dois sentidos (injetar violação ⇒ falha; remover ⇒ passa), como a fundação fez em T3/FUND-06.
2. **T32 fecha com um teste de completude** sobre código que as tasks anteriores já entregaram **com os seus próprios testes**. O teste de completude cobre uma propriedade que nenhuma task individual pode afirmar — "nada ficou de fora do catálogo nem do barrel" — e vem junto do layout responsivo, que é código de produção.

**Helpers de teste** (`test/core/design_system/support/`) aparecem em T4 e T11 com `Tests: unit`/`widget` porque nascem **dentro** da task que os usa; a matriz os classifica como camada sem teste próprio, e é assim que ficam.

---

## Cobertura dos requisitos

| Req | Task(s) | Req | Task(s) |
|---|---|---|---|
| DS-01 | T2 | DS-19 | T19 |
| DS-02 | T1 | DS-20 | T20 |
| DS-03 | T3, T4, T8 | DS-21 | T2, T21 |
| DS-04 | T3 | DS-22 | T22 |
| DS-05 | T5, T7 | DS-23 | T23 |
| DS-06 | T5 | DS-24 | T24 |
| DS-07 | T5, T7, T31 | DS-25 | T25 |
| DS-08 | T5 | DS-26 | T26 |
| DS-09 | T8 | DS-27 | T27 |
| DS-10 | T6, T8 | DS-28 | T28 |
| DS-11 | T12 | DS-29 | T29 |
| DS-12 | T13 | DS-30 | T30 |
| DS-13 | T11 | DS-31 | T31 |
| DS-14 | T14 | DS-32 | T13, T14, T15, T16, T22, T24, T25, T26, T30 |
| DS-15 | T15 | DS-33 | T10, T32 |
| DS-16 | T16 | DS-34 | T9, T17, T19, T25, T26, T27, T28, T29 |
| DS-17 | T17 | DS-35 | T6 |
| DS-18 | T18 | | |

**35 de 35 requisitos mapeados. Nenhuma task órfã.**

---

## Fora do escopo deste plano (declarado, não esquecido)

- **Aplicar `boraTheme()` no `BoraApp`** — `lib/app.dart` está fora da fronteira desta spec. O tema nasce pronto e testado; a spec 03 `entrar` o pluga (A-16, AD proposto DS-3).
- **Revestir `PlaceholderPage`, `RouteErrorPage`, `AppShell`, `FestaTabsShell`** — a fundação deixou "para a spec 01", mas revestir o chrome é decidir layout de tela, e o arquivo 02 não especifica o header do app. Volta para as specs 03/04, que têm T-01/T-02 para se ancorar.
- **Golden images** — decisão de design registrada; asserção de propriedade discrimina melhor e não depende de fonte carregada.
- **`integration_test/`** — nenhum `DS-xx` pede fluxo ponta-a-ponta.
- **Regra "máx. 2 acentos por tela"** — é critério de tela; esta spec entrega o conjunto fechado de acentos que a torna verificável.
- **Qualquer aritmética ou formatação `R$`** — spec 02 `calculo`, rodando em paralelo. Nenhum arquivo desta spec importa `core/calculo/`, e a guarda de T9 policia.
- **CI** — `CLAUDE.md` proíbe criar sem pedido explícito.
