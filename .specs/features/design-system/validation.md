# Design System "Convite" — Validation

**Data**: 2026-08-25
**Spec**: `.specs/features/design-system/spec.md` (DS-01..DS-35)
**Diff range**: `a50f5cd..18fd815` na branch `feature/design-system` (worktree `C:/repos/lucari/bora-ds`)
**Verifier**: sub-agente independente (autor ≠ verificador), evidence-or-zero — cobertura re-derivada do `spec.md`, nenhuma alegação de `tasks.md` ou de mensagem de commit aceita como prova
**SDK**: Flutter 3.47.1 · Dart 3.13.1 (`C:/SDKs/flutter/bin/flutter`), Windows 11

**Veredito**: ⚠️ **PASS COM RESSALVAS**

O portão está verde e a spec está substancialmente coberta: **395 testes passando**,
`flutter analyze` sem nenhum issue, e o sensor de discriminação matou **21 de 23
mutações**. Os valores literais de §1 e §4, o press-sink de §4, o toast de §5/RN-29
e a fronteira com `calculo` estão todos afirmados na árvore renderizada, com
`file:line` e expressão de asserção — não por alegação.

As ressalvas são **duas mutações sobreviventes**, ambas na mesma classe de defeito:
**allowlist de varredura larga demais**. As guardas de §3 e §4 liberam por
**arquivo**, não pela **forma específica** que a spec autoriza — então dentro de um
arquivo allowlistado qualquer violação passa. A pior delas (GAP-1) permite uma
**segunda sombra com blur** entrar no sistema com a suíte inteira verde, o que
contradiz literalmente o AC-9 de P1-7 ("a **única** com `blurRadius > 0` SHALL ser
a do frame").

Nenhuma delas é regressão de comportamento hoje: o código de produto está correto.
São **sensores com furo** — a lei continua escrita, mas parou de ser policiada
naquele ponto. Como a premissa desta spec é justamente "proibição sem sensor é
decoração", os dois furos viram task.

**DS-33 (conferência visual "parece o protótipo?") NÃO é verificável neste
ambiente** — não há device nem navegador. Reportado como **não verificado**; não
assumido como aprovado.

---

## Task Completion

| Task | Status | Notas |
|---|---|---|
| T1–T32 | ✅ Done | 250 de 251 checkboxes marcados em `tasks.md` |
| T32 (**M**) | ⏸️ **Não verificado** | `flutter run` / `-d chrome` em `/catalogo` conferindo seção a seção contra `.specs/init-spec/02-design-system.md` — sem device nem navegador neste ambiente (risco R-11 do próprio `tasks.md`, linha 1032). **Não assumido como passou.** |

Fronteira de arquivos respeitada: `lib/core/calculo/` intacto (só o `calculo.dart`
e o `.gitkeep` da fundação), `lib/app.dart`, `lib/main.dart` e `lib/bootstrap/**`
não tocados. A baseline de 92 testes da fundação continua no verde dentro dos 395.

---

## Escrutínio dos três commits de autor não-independente

Os três saíram da sessão principal, não dos batch workers. Nenhum foi aceito pela
alegação: os três foram re-derivados com sensor próprio.

### `179bab0` — normaliza separador de path na guarda de pureza → **alegação VERDADEIRA**

A alegação era: *bug de teste, não de produto; as varreduras em si sempre
funcionaram nos dois SOs*. Verificado por dois caminhos independentes.

**1. Desfiz a normalização e rodei o arquivo** (probe, restaurado em seguida):

```
sed -i 's|arquivosDartEm(lib).map((f) => caminhoNormalizado(f.path))|arquivosDartEm(lib).map((f) => f.path)|'
```

Falhou **exatamente um** teste — `DS-09 — as varreduras não rodam vazias / lib/ tem
arquivo .dart dentro e fora do design system`. Os três testes de varredura
(`nenhum arquivo de lib/ tem literal de cor…`, `…fontFamily…`, `…padrão proibido…`)
**continuaram passando**. O bug era, de fato, só do teste anti-vácuo.

**2. Provei que as varreduras são separator-independent na prática.** Nas mutações
M10, M11 e M12 as violações injetadas foram **detectadas e reportadas com path do
Windows**, com contrabarra:

- `'lib\\core\\design_system\\components\\bora_status_tag.dart: Color(0x'`
- `'lib/core/design_system\\components\\bora_hero_card.dart: package:bora/core/calculo/calculo.dart'`
- `'lib\\features\\montar\\presentation\\pages\\montar_page.dart: Gradient'`

A razão estrutural é auditável: a lógica de path das três guardas é
`caminho.endsWith(<basename>)` — `token_purity_guard_test.dart:52,62` e
`shape_and_shadow_guard_test.dart:57` — e `endsWith` de nome de arquivo não depende
de separador. `design_system_boundary_test.dart` não tem lógica de path nenhuma.

**Veredito**: correção legítima e bem escopada. O diff toca só o arquivo de teste,
não afrouxa nenhuma asserção, e ainda **acrescenta** um teste do normalizador nos
dois formatos mais um caminho de fora do escopo (`token_purity_guard_test.dart:283`)
— que é justamente a asserção que impede a normalização de alargar o escopo.

### `bcd156d` — T31, `BoraPhoneFrame` → **correção real, exceções bem contidas**

Verificado por mutação própria (**M15**): baixei o radius de 38 para 24 e
`bora_phone_frame_test.dart` falhou nomeando `DS-31 — … tem radius 38 e borda de
1px na cor do frame`. O componente carrega as duas exceções declaradas e ambas
estão citadas com o trecho de §3/§4 no doc comment (`bora_phone_frame.dart:14-20`).

**Ressalva**: a exceção está correta no *produto*, mas a *guarda* que a autoriza é
larga demais — ver **GAP-2**. Não é defeito deste commit; é do desenho da allowlist,
que nasceu na fase 2 (T7).

### `4b21801` — T32, completude do catálogo → **alegação REPRODUZIDA literalmente**

A mensagem de commit alega: *"removida a seção do frame do catálogo, o teste falha
nomeando BoraPhoneFrame (bora_phone_frame.dart)"*. **Refiz a mutação eu mesmo**
(**M13**), curto-circuitando `_construirFrameDoCelular` em
`catalog_sections.dart:766`. Saída:

```
Actual: ['BoraPhoneFrame (bora_phone_frame.dart)']
```

Três testes falharam, nas duas larguras mais o sensor de nome. A alegação é
**exata, caractere por caractere**. O desenho do teste também resiste ao ataque
óbvio: a lista de tipos é **escrita à mão** (`catalog_completude_test.dart:38-63`),
de propósito, porque uma lista derivada da árvore concordaria com qualquer catálogo
— inclusive um vazio; e há um sensor anti-vácuo com um `Placeholder` que o catálogo
comprovadamente não usa (`catalog_completude_test.dart:127-140`).

**Nenhum dos três commits foi encontrado inflando cobertura ou afrouxando asserção.**

---

## Sensor de discriminação — 23 mutações

Protocolo por mutação: `git status` limpo → editar **código de produção** para
quebrar comportamento real → rodar → `git checkout -- <arquivo>` imediato →
`git status`. Nenhuma mutação ficou para trás; nenhum código foi commitado.

| # | Arquivo de produção mutado | Mutação | Resultado |
|---|---|---|---|
| M1 | `tokens/bora_colors.dart` | `primary` `0xFFFF4D2E` → `0xFFFF4D2F` | ☠️ **morta** — 2 testes (DS-01, DS-21) |
| M2 | `tokens/bora_shadows.dart` | `cardHeroi` distância 6 → 8 | ☠️ **morta** — DS-07 "offset e a cor da tabela de §4" |
| M3 | `components/bora_press_sink.dart` | `afundamento` fixo em `0.0` (CTA não desce) | ☠️ **morta** — DS-11 press + DS-11 hover |
| M4 | `components/bora_press_sink.dart` | sombra não encolhe no press (fica em 4px) | ☠️ **morta** — 4 testes DS-11 |
| M5 | `tokens/bora_motion.dart` | `toastVida` 2200 → 3000 ms | ☠️ **morta** — 4 testes (DS-10 + DS-12) |
| M6 | `components/bora_toast.dart` | remove `_cancelar()` de `mostrar` (toast empilha) | ☠️ **morta** — 2 testes DS-12 "1 por vez" |
| M7 | `components/bora_toast_texts.dart` | `linkCopiado` perde o emoji 🔗 | ☠️ **morta** — 2 testes DS-12 RN-29 |
| M8 | `components/bora_toast.dart` | toast sem `toUpperCase()` | ☠️ **morta** — DS-12 CAIXA ALTA |
| M9 | `components/bora_list_card.dart` | injeta `BorderRadius.circular(8)` real | ☠️ **morta** — guarda de forma DS-05 |
| M10 | `components/bora_status_tag.dart` | injeta `Color(0xFF00FF00)` real | ☠️ **morta** — DS-09, **nomeando o arquivo** |
| M11 | `components/bora_hero_card.dart` | injeta `import package:bora/core/calculo/calculo.dart` | ☠️ **morta** — DS-34, **nomeando o arquivo** |
| M12 | `features/montar/.../montar_page.dart` | injeta `LinearGradient` **fora** do design system | ☠️ **morta** — DS-09 global (prova que a varredura alcança `lib/` inteira) |
| M13 | `catalog/catalog_sections.dart` | catálogo deixa de montar `BoraPhoneFrame` | ☠️ **morta** — 3 testes DS-33, msg `['BoraPhoneFrame (bora_phone_frame.dart)']` |
| M14 | `tokens/bora_text_styles.dart` | `microTag` 9.0 → 8.5 px (viola o piso de A-02/§8) | ☠️ **morta** — 4 testes DS-04 |
| M15 | `components/bora_phone_frame.dart` | radius 38 → 24 | ☠️ **morta** — DS-31 |
| M16 | `components/bora_price_range_bar.dart` | remove o clamp (`=> fracao`) | ☠️ **morta** — 4 testes DS-27 (NaN, ±∞, >1, <0) |
| M17 | `components/bora_expandable_row.dart` | `_abertaEm = indice` (reabrir não fecha) | ☠️ **morta** — DS-20 |
| **M18** | `tokens/bora_shadows.dart` | **2ª sombra com blur, sem anotação de tipo** | 🧟 **SOBREVIVEU** — ver GAP-1 |
| **M19** | `components/bora_avatar.dart` | **`BorderRadius.circular(8)` não-circular em arquivo allowlistado** | 🧟 **SOBREVIVEU** — ver GAP-2 |
| M20 | `components/bora_primary_button.dart` | rótulo sem `toUpperCase()` | ☠️ **morta** — 2 testes (DS-14, DS-32) |
| M21 | `components/bora_stepper.dart` | `alvoDeToque` 44 → 34 | ☠️ **morta** — DS-17 |
| M22 | `components/bora_status_tag.dart` | ANFITRIÃO deixa de ser `yellow` | ☠️ **morta** — DS-22 |
| M23 | `components/bora_segmented_control.dart` | variante escura passa a pintar fundo no ativo | ☠️ **morta** — DS-16 |

**Placar: 21 mortas / 2 sobreviventes / 23 executadas.**

Estado final da árvore após todas as mutações: `git status` **limpo**,
`flutter analyze` **No issues found**, `flutter test` **395 passando**.

### 🧟 M18 — segunda sombra com blur entra com a suíte inteira verde

Mutação aplicada em `lib/core/design_system/tokens/bora_shadows.dart`:

```dart
static final sombraMoleClandestina =
    BoxShadow(color: BoraColors.ink, offset: const Offset(3, 3), blurRadius: 12);
```

Resultado: **`flutter test` = 395 passando, All tests passed.** Rodado contra a
suíte inteira, não só contra os dois arquivos de guarda.

Dois furos se somam, e é preciso os dois para o mutante viver:

1. `shape_and_shadow_guard_test.dart:48-51` — `_blurLiberado` allowlista o arquivo
   `bora_shadows.dart` **inteiro**. Está marcado como `SPEC_DEVIATION` e o motivo
   declarado é legítimo (senão a guarda acusaria o próprio token do frame), mas o
   alargamento é do arquivo, não da sombra do frame.
2. `bora_shadows_test.dart:119` — a checagem de completude usa
   `RegExp(r'static (?:final|const) BoxShadow (\w+) =')`, que **exige a anotação de
   tipo**. `static final x = BoxShadow(...)` não casa e escapa do contrato.

Contradiz literalmente o AC-9 de P1-7 (`spec.md:267`): *"WHEN as sombras do sistema
inteiro são inspecionadas THEN a **única** com `blurRadius > 0` SHALL ser a do
frame"*. Hoje essa frase é verdadeira por sorte, não por sensor.

### 🧟 M19 — canto arredondado não-circular passa dentro de arquivo allowlistado

Mutação aplicada em `lib/core/design_system/components/bora_avatar.dart`:

```dart
final cardArredondadoNoAvatar = BorderRadius.circular(8);
```

Resultado: guarda de forma **e** teste do avatar **passaram**.

Causa: `shape_and_shadow_guard_test.dart:56-66` — `_liberado()` libera por
`caminho.endsWith(<arquivo>)`. Uma vez na allowlist, o arquivo fica liberado para
**qualquer** forma arredondada, não só para a que §3 autoriza. Vale igual para
`bora_phone_frame.dart` e `bora_poll_option.dart`.

§3 autoriza forma específica ("avatares e dots (círculo, 50%) e o frame do celular
(38px)"), não arquivo inteiro. E `spec.md:170` (DS-05 AC-2) fala em "as **duas
únicas exceções**" — a allowlist tem **três** arquivos.

---

## Critérios de aceite — evidência ancorada

Cada linha foi re-derivada do `spec.md`. Critério sem `file:line` + expressão de
asserção conta como não coberto.

### P1-1 · Tokens (DS-01, DS-04..DS-08, DS-10, DS-35)

| AC | Evidência | Expressão |
|---|---|---|
| 1 — 17 cores literais de §1 | `test/core/design_system/tokens/bora_colors_test.dart:8-38` | `expect(BoraColors.paper.toARGB32(), 0xFFF4EFE3)` … 17 asserções, uma por token |
| 2 — cores derivadas viram token | `bora_colors_test.dart:68-109` | `expect(BoraColors.sheetScrim.toARGB32(), 0x73140A32)`; `pollFill 0x2E25D366`; `creamQuarter 0x40F4EFE3`; `frameBorder 0x40000000`; `frameShadow 0x59140A32` |
| 3 — cada papel de §2 dentro da faixa | `bora_text_styles_test.dart:292,338` | grupos "cada papel de §2 tem o valor da tabela" e "o tamanho de cada papel fica dentro da faixa de §2" |
| 4 — piso de 9.0px | `bora_text_styles_test.dart:338` | "nenhum texto de UI fica abaixo de 9px" + "a micro-tag usa o piso de 9px, não os 8.5px de §2" |
| 5 — sombras de §4 sem blur, offsets da tabela | `bora_shadows_test.dart:57-91` | `expect(contrato.sombra.blurRadius, 0.0)` e `expect(contrato.sombra.offset, contrato.deslocamento)` sobre a tabela `_duras` de 8 usos |
| 6 — formas e bordas | `bora_borders_test.dart:7-70` | raio zero; sólida 2px `ink`; tracejada 2px `ink`; slot 2px `text-3` + `opacidade 0.7`; frame 1px |
| 7 — motion 150/300/300/2200 + `Curves.ease` | `bora_motion_test.dart:6` | grupo "as durações de §6" |
| 8 — acento é conjunto fechado | `bora_accent_test.dart:6-35` | seis acentos, `expect(BoraAccent.values, <BoraAccent>[…])` |
| 9 — `boraTheme()` só deriva | `bora_theme_test.dart:12-77` | fundo `paper`, famílias do token, `colorScheme` dos tokens, e leitura do próprio arquivo negando `Color(0x` e `fontFamily: '` |

**Verificação numérica independente das cores derivadas** (conferidas contra o CSS
de §3/§4/§5, não contra o código): `rgba(20,10,50,.45)` → α = `.45×255` = 114.75 →
`0x73`, RGB `140A32` ⇒ `0x73140A32` ✓ · `rgba(37,211,102,.18)` → α = 45.9 → `0x2E`
⇒ `0x2E25D366` ✓ · cream 25% → α = 63.75 → `0x40` ⇒ `0x40F4EFE3` ✓ ·
`rgba(0,0,0,.25)` ⇒ `0x40000000` ✓ · `rgba(20,10,50,.35)` → α = 89.25 → `0x59` ⇒
`0x59140A32` ✓. E os divisores: `#14141418` é **RGBA** no CSS, então α = `0x18` = 24
= 9.4% ≈ os 9% da tabela ⇒ `0x18141414` ✓; `#14141422` → α = `0x22` = 34 = 13.3% ≈
13% ⇒ `0x22141414` ✓. O teste ainda krava a armadilha explicitamente
(`bora_colors_test.dart:49-65`: `isNot(0x14141418)`, "lido como ARGB daria um azul
opaco"). **Os 17 valores de §1 e os 9 de §4 conferem um a um.**

### P1-2 · Fontes e peso (DS-02, DS-03)

| AC | Evidência | Expressão |
|---|---|---|
| 1 — os 3 arquivos + pubspec | `bora_fonts_test.dart:64-77` | `expect(_valoresDe('family'), ['Archivo','Archivo Black'])` e `_valoresDe('asset')` apontando para `assets/fonts/` |
| 2 — bytes pelo `rootBundle` | `bora_fonts_test.dart:31-51` | `rootBundle.load('assets/fonts/Archivo[wdth,wght].ttf')`, `expect(…lengthInBytes, 658596)` — colchete e vírgula no nome inclusos |
| 3 — OFL ao lado | `bora_fonts_test.dart:53-62` | `expect(licenca, contains('SIL Open Font License'))` |
| 4 — w400 ≠ w800 medido | `font_weight_axis_test.dart:24-43` | `expect((pesada - leve).abs(), greaterThan(1.0))` com `FontLoader` |
| 5 — w800 == `FontVariation('wght',800)` | `font_weight_axis_test.dart:66-86` | `expect(porPeso, porEixo)` |
| 6 — `FontVariation` ausente de `lib/` | `token_purity_guard_test.dart:41-48,229` | `'FontVariation'` em `_proibidosGlobais`, varrido sobre `lib/` |
| 7 — Archivo Black sempre w400 | `bora_text_styles_test.dart:338` | "todo estilo de Archivo Black usa w400" |

A contradição registrada em `spec.md:88-97` (o "fato técnico" da instrução de
partida, invertido pelo Flutter 3.41+) está **confirmada empiricamente pelo teste
que roda**, não só argumentada: o AC-5 é exatamente a medição que prova o oposto do
que a instrução afirmava. Nota: `FontVariation` aparece em
`font_weight_axis_test.dart:75`, mas isso é **conforme** — a proibição de AC-6 é
sobre `lib/`, e o teste precisa do eixo para provar a equivalência.

### P1-3 · Guardas (DS-05, DS-07, DS-09, DS-34)

| AC | Evidência | Sensor executado |
|---|---|---|
| 1 — forma arredondada quebra nomeando arquivo | `shape_and_shadow_guard_test.dart:130`; `_formasProibidas:18-24` | **M9** ✓ |
| 2 — frame e avatar passam | `shape_and_shadow_guard_test.dart:199-210` | ⚠️ passa, mas **largo demais** — GAP-2 |
| 3 — blur fora do frame quebra | `shape_and_shadow_guard_test.dart:214` | ⚠️ **furado** — GAP-1 (M18) |
| 4 — `Color(0x`/`Colors.` fora do arquivo de cor | `token_purity_guard_test.dart:134`; `_atalhoDeCor:33` | **M10** ✓ — msg nomeia `bora_status_tag.dart` |
| 5 — `fontFamily` literal fora do arquivo de tipo | `token_purity_guard_test.dart:186` | lookbehind `(?<!Bora)` verificado em `:161-182` |
| 6 — `Gradient`/`InkWell`/mola/`FontVariation` em `lib/` | `token_purity_guard_test.dart:229` | **M12** ✓ — pegou em `lib/features/` |
| 7 — import de `calculo`/Firebase/bloc | `design_system_boundary_test.dart:91` | **M11** ✓ — msg nomeia `bora_hero_card.dart` |
| 8 — nenhuma guarda passa vacuamente | `shape_and_shadow_guard_test.dart:139-147`; `token_purity_guard_test.dart:263-281`; `design_system_boundary_test.dart:100-108` | ✓ — e o anti-vácuo de pureza exige alvo **dentro e fora** do design system |

**Nota de desenho**: os testes "infrator injetado" das três guardas injetam num
diretório temporário (`Directory.systemTemp`), não em `lib/`. Isso prova a **regra**,
não a **varredura real**. As mutações M9–M12 fecham essa lacuna: injetei em
arquivos de produção de verdade e as três guardas morderam. O anti-vácuo cobre o
resto. Sem M9–M12, esse conjunto seria evidência parcial.

### P1-4 · Press-sink e toast (DS-11, DS-12, DS-13, DS-32)

| AC | Evidência | Expressão |
|---|---|---|
| 1 — superfície: radius 0, borda 2px, 1 sombra dura | `bora_surface_test.dart:21-53` | + `:54` "sem acento não há sombra alguma, e não uma transparente" |
| 2 — press: `translate(2,2)` **e** sombra 4→2 em 150ms | `bora_press_sink_test.dart:58-82` | `expect(_translacao(tester), Matrix4.translationValues(2,2,0))` **e** `expect(_sombra(tester), const Offset(2,2))` |
| 3 — up e cancel voltam a (0,0)/4px | `bora_press_sink_test.dart:84-111` | dois testes, `gesto.up()` e `gesto.cancel()` |
| 4 — hover afunda igual | `bora_press_sink_test.dart:132-145` | `PointerDeviceKind.mouse`, `moveTo(getCenter(...))` |
| 5 — desabilitado: `.7` e não afunda | `bora_press_sink_test.dart:185-220` | `expect(opacidade.opacity, 0.7)` + press e hover sem deslocamento |
| 6 — toast: `bottom:112`, `ink`/`cream`, sombra dura, fade+14px/300ms | `bora_toast_test.dart:64-108`, `:110-129`, `:131-165` | `expect(tela.height - toast.bottom, 112.0)`; `expect(_translacao(tester), Matrix4.translationValues(0, 14, 0))` |
| 7 — some sozinho em 2200ms | `bora_toast_test.dart:183-205` | presente em 2199ms, ausente em 2201ms — as duas bordas |
| 8 — 2º substitui, timer do 1º cancelado | `bora_toast_test.dart:209-256` | `findsOneWidget` + o teste do timer órfão em `:232` |
| 9 — os 11 literais de RN-29 | `bora_toast_texts_test.dart:5` | conferido também **contra a fonte**: `03-regras-de-negocio.md` RN-29 ⇒ os 11 batem caractere a caractere, emoji incluído (`…`, `☝️`, `✅`) |
| 10 — `Overlay` desmontado não lança | `bora_toast_test.dart:260-298` | `expect(() => …, returnsNormally)` + `expect(tester.takeException(), isNull)` |
| 11 — copy em CAIXA ALTA | `bora_toast_test.dart:167-179` | entra minúscula, sai `BoraToastTexts.linkCopiado` |

O press-sink de §4 é a mecânica mais escrutinada da spec e está **integralmente
coberta**: as duas metades do afundamento (translate **e** sombra) são asseridas
juntas, a volta é coberta nos dois caminhos (up e cancel), o hover é coberto com
ponteiro de mouse real, e há até asserção de que o afundamento é **transição** e
não salto (`bora_press_sink_test.dart:165-181`: no meio dos 150ms a sombra está
estritamente entre 2 e 4). M3 e M4 confirmaram que as duas metades são
independentemente sensíveis.

### P1-5 · Ação e entrada (DS-14..DS-18)

`bora_primary_button_test.dart:51,149,176` · `bora_secondary_button_test.dart:30,117,139` ·
`bora_selection_chip_test.dart:46,93,134,181` · `bora_segmented_control_test.dart:68,106,150,181,212,231` ·
`bora_stepper_test.dart:58` + "o alvo de toque acessível" · `bora_text_field_test.dart`.
Sensores: **M20** (CAIXA ALTA do botão), **M21** (alvo de toque 44), **M23**
(variante escura do segmented). DS-17 AC-7 ("emite só a intenção, não calcula")
coberto por `bora_stepper.dart:44` (`final int valor` recebido) + o teste
"o limite vem de fora (A-07)".

### P1-6 · Lista, gente e status (DS-19..DS-24)

`bora_list_card_test.dart:56,78,117,217,234` · `bora_expandable_row_test.dart:41,127,192` ·
`bora_avatar_test.dart:29,68,128` · `bora_status_tag_test.dart:43,74,122` ·
`bora_dashed_note_test.dart:28,98,146` · `bora_rotated_tag_test.dart:72,100,127,154`.
Sensores: **M17** (accordion), **M22** (cor de status). Os ângulos de §3 estão
literais em `bora_rotated_tag.dart:31,34,37` (`-2`, `3`, `-13`) com conversão
explícita grau→radiano em `:40`. As 5 personas de §1 e o fallback determinístico de
A-05 estão em `bora_colors_test.dart:112-178`, incluindo "nenhum nome recebe cor
fora dos cinco pares".

### P1-7 · Dinheiro e apresentação (DS-25..DS-27, DS-30, DS-31)

| AC | Evidência |
|---|---|
| 1 — card-herói | `bora_hero_card_test.dart:40-86`, `:88` — `expect(decoracao.boxShadow!.single.offset, const Offset(6,6))` |
| 2 — rodapé fixo | `bora_footer_bar_test.dart:48,105` |
| 3 — dinheiro chega **formatado** | `bora_hero_card_test.dart:172`, `bora_footer_bar_test.dart:182`, `bora_list_card_test.dart:217` — "valor sem R$ não ganha R$, e não é arredondado nem transformado" |
| 4 — trilho e marcador | `bora_price_range_bar_test.dart:53,73` |
| 5 — recebe fração pronta, só pinta | `bora_price_range_bar.dart:25-31` — a assinatura **não aceita** `media`/`min`/`max`, só `fracao`, `rotuloMin`, `rotuloMax` |
| 6 — clampa <0, >1, NaN, ±∞ | `bora_price_range_bar_test.dart:143-180` — **M16** ✓ |
| 7 — bottom sheet | `bora_bottom_sheet_test.dart:72,144` |
| 8 — frame 390×820, radius 38, borda 1px | `bora_phone_frame_test.dart:52` — **M15** ✓ |
| 9 — **a única sombra com blur é a do frame** | `bora_shadows_test.dart:101-113` | ⚠️ **furado** — GAP-1 |

**DS-27/DS-34 (fronteira com `calculo`) está bem fechada.** A prova mais forte não
é o teste, é a **assinatura**: `BoraPriceRangeBar` não aceita nenhum número que
permitisse recalcular RN-11, e `bora_price_range_bar.dart:12-16` diz isso
explicitamente ("API que aceitasse número convidaria a fórmula a ser reescrita
aqui"). O mesmo vale para `BoraProgressBar` (DS-28) e `BoraPollOption` (DS-29).
Somado a **M11** (import proibido morde), a fronteira está policiada nos dois
sentidos: por API e por varredura.

### P1-8 · Catálogo (DS-33)

| AC | Evidência | Status |
|---|---|---|
| 1 — `/catalogo` renderiza | `test/core/routing/app_router_catalogo_test.dart:19` | ✅ |
| 2 — chrome do app **ausente** | `app_router_catalogo_test.dart:27-32` — `expect(find.byKey(AppShell.chromeKey), findsNothing)` | ✅ |
| 3 — cada componente público presente, falha nomeando | `catalog_completude_test.dart:87-141` | ✅ — **M13** |
| 4 — compacto e expandido, `LayoutMode` de AD-007 | `catalog_page_test.dart:72-101` — `find.byType(ResponsiveBuilder)`, 390 e 1180 | ✅ — `grep 900 lib/core/design_system/` = **vazio**, não redeclara |
| 5 — aplica `boraTheme()` em si | `catalog_page_test.dart:22-42` | ✅ |
| 6 — barrel exporta tudo, nos dois sentidos | `catalog_completude_test.dart:143-195` | ✅ — inclusive "export apontando para arquivo que sumiu" |
| 7 — baseline de rotas intacta | `app_router_catalogo_test.dart` "a rota nova não muda as existentes" | ✅ — 395 verdes |
| **M** — **"parece o protótipo?"** | — | ⛔ **NÃO VERIFICADO** |

---

## Edge cases da spec

Os 11 edge cases de `spec.md:310-322`, um a um:

| Edge case | Coberto | Onde |
|---|---|---|
| fração `<0`, `>1`, `NaN`, `∞` clampa | ✅ | `bora_price_range_bar_test.dart:143`; `bora_progress_bar_test.dart:117` — **M16** |
| nome fora da tabela ⇒ um dos 5 pares, determinístico | ✅ | `bora_colors_test.dart:143-177` |
| rótulo minúsculo ⇒ CAIXA ALTA; vazio não lança | ✅ | `bora_hero_card_test.dart:156` ("label vazio renderiza sem exceção") + 8 grupos DS-32 — **M8, M20** |
| toast novo remove o anterior e cancela o timer | ✅ | `bora_toast_test.dart:232` — **M6** |
| toast após `Overlay` desmontado ignora em silêncio | ✅ | `bora_toast_test.dart:285-298` |
| segmented com uma opção só, sem divisor | ✅ | `bora_segmented_control_test.dart:150` |
| stepper no limite: `.7` e não emite | ✅ | `bora_stepper_test.dart` "o limite vem de fora (A-07)" |
| pilha com `+0` omite o slot | ✅ | `bora_avatar_test.dart:128` "com +0 o slot não é renderizado" |
| nenhuma linha começa aberta | ✅ | `bora_expandable_row_test.dart:127` |
| guarda em diretório sem `.dart` **falha** | ✅ | os três anti-vácuos |
| nenhum teste depende de fonte, exceto os de métrica | ✅ | só `font_weight_axis_test.dart` usa `carregarFontesArchivo` |

**11 de 11 cobertos.** Nenhum edge case ficou órfão.

---

## Code Quality

- **Fronteira de arquivos**: respeitada. `lib/core/calculo/` intacto; `lib/app.dart`,
  `lib/main.dart`, `lib/bootstrap/**` e `lib/core/{di,firebase,observability,responsive}/**`
  não tocados. `app_router.dart` e `routes.dart` tocados **só** para a rota do catálogo.
- **Nenhum teste existente enfraquecido**: os 92 da fundação continuam no verde
  dentro dos 395.
- **`SPEC_DEVIATION` declarados**: 2 nesta spec (`bora_shadows.dart:24` — a sombra
  do CTA vira distância, não constante, porque §4 deixa a cor em aberto;
  `shape_and_shadow_guard_test.dart:43` — `bora_shadows.dart` entra na allowlist de
  blur). Ambos com motivo escrito. O segundo é a causa raiz de **GAP-1**: o desvio
  é legítimo no objetivo, largo demais na execução.
- **PT-BR/inglês (A-12)**: consistente — classes e arquivos em inglês
  (`BoraPrimaryButton`, `components/`), parâmetros de copy em PT-BR (`titulo`,
  `rotulo`, `BoraToastTexts.linkCopiado`), como o `CLAUDE.md` manda.
- **Doc comments citam a spec**: praticamente todo token e componente carrega o
  trecho de §1–§8 que o justifica. Isso é o que tornou esta verificação auditável
  sem adivinhação.
- **Ponto fraco menor**: `BoraHeroCard` redeclara a distância 6 de §4
  (`bora_hero_card.dart:29`) em vez de ler `BoraShadows.cardHeroi` — ver GAP-3.

---

## Gate Check

| Portão | Resultado |
|---|---|
| `flutter analyze` | ✅ **No issues found!** (1.5s) |
| `flutter test` | ✅ **395 passando**, All tests passed |
| Baseline de 92 testes da fundação | ✅ preservada |
| `git status` ao fim das 23 mutações | ✅ **limpo** — nenhuma mutação deixada para trás |
| Código de produção commitado pelo Verifier | ✅ **nenhum** |

---

## Cobertura pendente e spec-precision gaps

### ⛔ Não verificável neste ambiente

**DS-33 — conferência visual "parece o protótipo?"** (`tasks.md:1032`, verificação
**M**). Exige `flutter run` em device e `flutter run -d chrome` em navegador,
abrindo `/catalogo` e conferindo seção a seção contra
`.specs/init-spec/02-design-system.md`. **Não há device nem navegador neste
ambiente.** Reportado como **NÃO VERIFICADO** — explicitamente **não** assumido
como aprovado.

Isto importa mais nesta spec do que na fundação: o objetivo declarado do arquivo 02
é *"o resultado tem que ficar **exatamente igual** ao protótipo"*, e a spec assume
por decisão de design (`spec.md:38`) que golden images ficam fora. Logo **nenhum
teste desta suíte afirma aparência** — só propriedades nomeadas. Tudo que a suíte
prova é que os **valores** estão certos; que o **conjunto** parece o protótipo
continua não provado por máquina, por desenho. É uma lacuna consciente, mas é uma
lacuna.

### Spec-precision gaps

1. **`spec.md:170` (DS-05 AC-2) diz "as duas únicas exceções"; a allowlist tem
   três arquivos.** O terceiro (`bora_poll_option.dart`) é defensável pelo texto
   de §3 — "avatares e **dots** (círculo, 50%)", e o radio da enquete é um dot de
   15px — mas o `spec.md` não o previu. Ou o `spec.md` passa a dizer três, ou o dot
   da enquete passa a reusar o círculo do avatar. Hoje spec e código discordam na
   contagem.
2. **A regra "máx. 2 acentos por tela"** está declarada Out of Scope
   (`spec.md:37`), corretamente — é regra **de tela** e as telas são as specs 03–10.
   O mecanismo que a torna possível (acento como conjunto fechado, DS-08) **está**
   entregue e testado. Registrado aqui para que não seja lido como lacuna desta spec.
3. **`bora_fonts_test.dart:37,48` afirma tamanho de arquivo em bytes exatos**
   (658596 / 90988). Discrimina bem hoje, mas quebra se a fonte for reotimizada
   sem mudar de identidade. Não é defeito — é escolha frágil; vale um comentário
   dizendo que o número é um fingerprint, não um requisito.

---

## Gaps ranqueados — tasks para outro agente

O Verifier **não conserta nada**. Os quatro itens abaixo saem daqui como task.

### 🔴 GAP-1 (Alta) — fechar o furo da segunda sombra com blur

**Sintoma**: `static final x = BoxShadow(..., blurRadius: 12)` entra em
`lib/core/design_system/tokens/bora_shadows.dart` com **395 testes verdes**
(mutação M18). Viola `spec.md:267` (P1-7 AC-9 · DS-31/DS-07).

**Causa raiz (dupla)**:
- `test/core/design_system/architecture/shape_and_shadow_guard_test.dart:48-51` —
  `_blurLiberado` allowlista o arquivo inteiro.
- `test/core/design_system/tokens/bora_shadows_test.dart:119` — o regex de
  completude exige a anotação `BoxShadow` e não vê a declaração sem tipo.

**Correção sugerida** (qualquer uma fecha; as duas juntas são mais firmes):
(a) trocar a allowlist de arquivo por allowlist de **símbolo** — em
`bora_shadows.dart`, tolerar blur só na declaração chamada `frame`; e/ou
(b) fazer a checagem de completude ser **em runtime, por reflexão sobre a API
pública**, ou relaxar o regex para `static (?:final|const) (?:BoxShadow )?(\w+) =
\s*(?:const )?BoxShadow`. **Critério de pronto**: a mutação M18 passa a matar.

### 🟠 GAP-2 (Média) — estreitar a allowlist de forma para a forma, não o arquivo

**Sintoma**: `BorderRadius.circular(8)` — que não é círculo nem 38 — passa dentro
de `bora_avatar.dart` (mutação M19). Vale igual para `bora_phone_frame.dart` e
`bora_poll_option.dart`.

**Causa raiz**: `shape_and_shadow_guard_test.dart:56-66`, `_liberado()` libera por
`endsWith` de caminho, e §3 autoriza **forma**, não arquivo.

**Correção sugerida**: allowlist por par (arquivo, padrão) — `bora_avatar.dart` e
`bora_poll_option.dart` liberam só `CircleBorder`/`BoxShape.circle`;
`bora_phone_frame.dart` libera só `Radius.circular(38)`. **Critério de pronto**:
M19 passa a matar, e a mutação inversa (o círculo legítimo do avatar) continua
passando.

### 🟡 GAP-3 (Baixa) — `BoraHeroCard` redeclara a distância de §4

**Sintoma**: `BoraShadows.cardHeroi` e `BoraHeroCard.deslocamentoDaSombra`
(`bora_hero_card.dart:29`) são duas cópias independentes do mesmo `6` de §4. Mudar
o token **não** muda o que o card renderiza (foi o que M2 revelou: o teste do card
continuou verde). As duas cópias estão certas hoje; nada impede que divirjam.

**Correção sugerida**: o componente lê o token, ou um teste afirma
`BoraHeroCard.deslocamentoDaSombra == BoraShadows.cardHeroi.offset.dx`.
Nota de contexto: as outras constantes nomeadas de `BoraShadows` (`loginGrande`,
`cardGrupo`, `cardBrancoGrande`, `flyer`, `bolhaWa`) hoje não têm consumidor — isso
é **legítimo**, são a oferta da biblioteca para as specs 03–10, não código morto.

### ⚪ GAP-4 (Informativa) — reconciliar a contagem de exceções de §3

`spec.md:170` diz "duas únicas exceções"; a allowlist tem três arquivos. Ajustar o
texto do `spec.md` ou o desenho do dot da enquete. Sem impacto de comportamento.

---

## Rastreabilidade DS-01..DS-35

Status re-derivado do `spec.md`, não herdado do `tasks.md`. **Verified** exige
`file:line` + expressão de asserção; **Verified com ressalva** significa coberto,
porém com sensor furado ou evidência parcial.

| ID | Verificação | Sensor | Status |
|---|---|---|---|
| DS-01 | `bora_colors_test.dart:8,68` — 17 tokens + 5 derivadas, hex literal | M1 | ✅ Verified |
| DS-02 | `bora_fonts_test.dart:30` — `rootBundle`, pubspec, OFL | — | ✅ Verified |
| DS-03 | `font_weight_axis_test.dart:23` — medição com `FontLoader`; `token_purity_guard_test.dart:229` | M12 | ✅ Verified |
| DS-04 | `bora_text_styles_test.dart:292,338,398` — faixa, peso, piso 9px, contrato | M14 | ✅ Verified |
| DS-05 | `bora_borders_test.dart:7`; `shape_and_shadow_guard_test.dart:129` | M9 ✓ / **M19 🧟** | ⚠️ **Verified com ressalva** — GAP-2 |
| DS-06 | `bora_borders_test.dart:17` — sólida, tracejada, slot, frame | — | ✅ Verified |
| DS-07 | `bora_shadows_test.dart:57,93,116`; `shape_and_shadow_guard_test.dart:213` | M2 ✓ / **M18 🧟** | ⚠️ **Verified com ressalva** — GAP-1 |
| DS-08 | `bora_accent_test.dart:6` — conjunto fechado de 6 | — | ✅ Verified |
| DS-09 | `token_purity_guard_test.dart:133,185,228,263` | M10, M12 | ✅ Verified |
| DS-10 | `bora_motion_test.dart:6`; `bora_press_sink_test.dart:149` | M5 | ✅ Verified |
| DS-11 | `bora_press_sink_test.dart:57,131,148,184` — press, hover, cancel, disabled | M3, M4 | ✅ Verified |
| DS-12 | `bora_toast_test.dart:63,182,208,259`; `bora_toast_texts_test.dart:5` | M5, M6, M7, M8 | ✅ Verified |
| DS-13 | `bora_surface_test.dart:20,142` | — | ✅ Verified |
| DS-14 | `bora_primary_button_test.dart:51,176`; `bora_secondary_button_test.dart:30,139` | M20 | ✅ Verified |
| DS-15 | `bora_selection_chip_test.dart:46,93,134,181` | — | ✅ Verified |
| DS-16 | `bora_segmented_control_test.dart:68,106,150,181,212` | M23 | ✅ Verified |
| DS-17 | `bora_stepper_test.dart:58` + alvo de toque ≥44 | M21 | ✅ Verified |
| DS-18 | `bora_text_field_test.dart` — foco vira `primary`, radius 0 | — | ✅ Verified |
| DS-19 | `bora_list_card_test.dart:56,78,117,234` | — | ✅ Verified |
| DS-20 | `bora_expandable_row_test.dart:41,127,192` | M17 | ✅ Verified |
| DS-21 | `bora_avatar_test.dart:29,68,128`; `bora_colors_test.dart:112` | M1 | ✅ Verified |
| DS-22 | `bora_status_tag_test.dart:43,74` — 7 significados | M22 | ✅ Verified |
| DS-23 | `bora_dashed_note_test.dart:28,98,146` | — | ✅ Verified |
| DS-24 | `bora_rotated_tag_test.dart:72,100,127` — −2°/+3°/−13px | — | ✅ Verified |
| DS-25 | `bora_hero_card_test.dart:40,88,172` | M2 | ✅ Verified |
| DS-26 | `bora_footer_bar_test.dart:48,105,182` | — | ✅ Verified |
| DS-27 | `bora_price_range_bar_test.dart:53,73,103,143,181` | M16 | ✅ Verified |
| DS-28 | `bora_progress_bar_test.dart:47,81,117,143` | — | ✅ Verified |
| DS-29 | `bora_poll_option_test.dart:70,93,140,172,216` | — | ✅ Verified |
| DS-30 | `bora_bottom_sheet_test.dart:72,144` | — | ✅ Verified |
| DS-31 | `bora_phone_frame_test.dart:52,115` — 390×820, radius 38, borda 1px | M15 ✓ / **M18 🧟** | ⚠️ **Verified com ressalva** — a "única sombra suave" não é policiada (GAP-1) |
| DS-32 | 8 grupos DS-32 (botões, chip, tag, hero, rodapé, segmented, toast) | M8, M20 | ✅ Verified |
| DS-33 | `catalog_completude_test.dart:87,143,197`; `catalog_page_test.dart:21,45,72`; `app_router_catalogo_test.dart:19,27` | M13 | ⚠️ **Verified, exceto a conferência visual (M) — NÃO VERIFICADA** |
| DS-34 | `design_system_boundary_test.dart:90` + assinaturas sem número | M11 | ✅ Verified |
| DS-35 | `bora_theme_test.dart:12`; `design_system_test.dart:6` | — | ✅ Verified |

**Cobertura: 35 de 35 requisitos com evidência ancorada. 0 sem evidência.**
31 ✅ Verified · 3 ⚠️ com ressalva de sensor (DS-05, DS-07, DS-31) · 1 ⚠️ com
verificação **M** pendente (DS-33).

---

## Summary

| Métrica | Valor |
|---|---|
| Veredito | ⚠️ **PASS COM RESSALVAS** |
| Critérios sem evidência | **0** de 35 |
| Mutações executadas | **23** |
| Mutações mortas | **21** |
| Mutações sobreviventes | **2** (M18, M19 — mesma causa raiz: allowlist por arquivo) |
| Edge cases da spec cobertos | **11 de 11** |
| `flutter analyze` | ✅ No issues found |
| `flutter test` | ✅ 395 passando |
| Árvore ao fim | ✅ limpa — nenhuma mutação deixada para trás |
| Commits de autor não-independente | 3 auditados, **3 confirmados legítimos** |
| Gaps abertos | 4 (1 alta, 1 média, 1 baixa, 1 informativa) |
| Não verificável neste ambiente | DS-33 verificação **M** (sem device/navegador) |

**Por que não é PASS limpo**: a spec se define pela frase "proibição sem sensor é
decoração" (`spec.md:165`). Duas proibições de §3/§4 — as duas mais literais do
estilo neo-brutalista, canto reto e sombra sem blur — têm hoje sensores com furo
demonstrado por mutação. O produto está correto; a **guarda** não está. Corrigidos
GAP-1 e GAP-2, esta spec vira PASS sem ressalva, restando só a conferência visual
que depende do usuário.

