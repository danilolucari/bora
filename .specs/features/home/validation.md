# Home — Validation

**Spec**: `.specs/features/home/spec.md`
**Verifier**: sub-agente independente (autor ≠ verificador) · cobertura re-derivada do zero contra a spec, a cada iteração

| Iteração | Data | Range | Testes | Veredito |
|---|---|---|---|---|
| 1 | 2026-08-26 | `feature/entrar..4e4a069` (25 commits) | 1128 | ❌ FAIL — 5 mutantes sobreviventes |
| 2 | 2026-08-26 | `feature/entrar..1601979` (26 commits) | **1131** | ❌ **FAIL — 4 mutantes novos, nenhum Blocker** |

O histórico da iteração 1 está preservado **na íntegra** ao fim deste arquivo: o registro do que estava errado é o que prova que o sensor discrimina.

---

# Iteração 2 — 2026-08-26

**Diff range**: `feature/entrar..HEAD` · commit de correção **`1601979`** (`fix(home): testes de navegação passam a afirmar a URL, não a tela`)
**Escopo da correção**: **test-only** — 6 arquivos, todos sob `test/`. **Zero linha de `lib/` mudou** (`git show --stat 1601979` confirma).

## Veredito: ❌ **FAIL — sem Blocker, sem defeito de produção**

Os **cinco gaps da iteração 1 estão fechados e verificados empiricamente por mim**: os cinco mutantes que antes atravessavam a suíte inteira agora morrem. A causa-raiz que eu tinha isolado (nenhum teste lia a URL) foi atacada na raiz, e não sintoma a sintoma.

O que faz esta rodada continuar vermelha são **quatro mutantes novos**, que escolhi contra alvos que a rodada de correção não antecipou. Todos são da mesma família: **defesa escrita no código, documentada em comentário, e nunca exercida por teste** — ou asserção que confere o objeto errado. **Nenhum é defeito de produção**: nos quatro casos o código está certo e é o teste que não o protege.

**Terceira iteração se justifica** — ao contrário do que aconteceu na spec 03 — porque dois dos quatro (N1, N7) atingem **HOME-04**, que é P1 MVP. O conserto é **um commit test-only de ~35 linhas**, sem tocar em `lib/`.

---

## Gate Check — iteração 2

| Gate | Comando | Exit code | Resultado |
|---|---|---|---|
| Analyze | `flutter analyze` | **0** | `No issues found!` |
| Full | `flutter test` | **0** | **1131 passaram**, 0 falharam, 0 skipped |

- **Antes da feature**: 947 · **iteração 1**: 1128 · **iteração 2**: **1131** · delta total **+184**
- Contagem só cresceu. Nenhum teste removido; as 5 asserções trocadas em `1601979` foram **substituídas por asserções mais fortes** (chave da tela → URL), e as antigas foram mantidas como complemento em 3 dos 5 casos.

---

## Os 5 gaps da iteração 1 — conferidos um a um, com mutação própria

Não reaproveitei o resultado declarado pelo coordenador. Re-injetei as cinco mutações eu mesmo, em estado descartável, e restaurei a árvore depois de cada uma.

| # | Mutação da iteração 1 | Correção verificada no código | Prova empírica (minha) | Status |
|---|---|---|---|---|
| **M3** | `context.go(rota)` → `context.push(rota)` | `home_page_test.dart:236-247` — `skipOffstage: false` **e** `expect(rotaAtual(), Routes.montar(rn30NaHome.id))` | ❌ → ✅ **Morto (6 falhas)**. A cópia empilhada offstage que eu tinha exposto por probe agora é vista | ✅ Fechado |
| **M8** | `Routes.montar(resumo.id)` → `Routes.novoRole` | `home_page_test.dart:138-145` — `expect(rotaAtual(), Routes.montar(rn30NaHome.id))` | ❌ → ✅ **Morto (3 falhas)** | ✅ Fechado |
| **M9** | header `Routes.novoRole` → `Routes.montar('rafa18')` | `app_shell_acao_test.dart:55-63` — `expect(rotaAtual(), Routes.novoRole)` | ❌ → ✅ **Morto (1 falha)** | ✅ Fechado |
| **M10** | `whatsapp`/`custos` com id fixo `'festa-errada'` | `home_page_test.dart:158`, `:170` — `expect(rotaAtual(), Routes.whatsapp(rn30NaHome.id))` / `Routes.custos(...)` | ❌ → ✅ **Morto (2 falhas)** | ✅ Fechado |
| **M15** | ARQUIVO trocado de lugar com COMEÇAR OUTRA | `arquivo_de_festas_test.dart:123-141` — `expect(arquivo.top, greaterThan(comecar.bottom))` + `expect(arquivo.left, closeTo(comecar.left, 1))`; `:143-151` — `expect(arquivo.left, greaterThan(card.right))` | ❌ → ✅ **Morto (1 falha)**, nomeando o grupo `HOME-05 AC3` | ✅ Fechado |

**A infraestrutura que fechou M3/M8/M9/M10**: `test/support/app_de_teste.dart:12-25` guarda o `GoRouter` montado e expõe `rotaAtual()` = `routerDelegate.currentConfiguration.uri.toString()`, com `addTearDown(() => _ultimoRouter = null)`. É a correção na causa-raiz que eu tinha apontado, não quatro remendos.

**O teste que eu pedi indiretamente e apareceu**: `home_page_test.dart:206-226` — duas festas, toque no **segundo** card, `expect(rotaAtual(), Routes.montar(outra.id))`. É o caso que um id fixo atravessava, e é onde o `ResumoDeFesta.id` (a SPEC_DEVIATION) finalmente prova que serve para alguma coisa. **Gap declarado na iteração 1 sobre a SPEC_DEVIATION: fechado.**

**Achado minor #5 (token da sombra)**: `card_da_festa_test.dart:108-120` deixou de pinar `BoraShadows.distanciaCardHeroi` e agora afirma `CardDaFesta.distanciaDaSombra` **e** o amarra a `BoraShadows.cardBranco.offset.dx`. ✅ Fechado.

---

## Discrimination Sensor — iteração 2

Tier **P0-estendido**. Todas as mutações em estado descartável (edição + `git checkout --`), com `git status --porcelain` conferido vazio de `lib/`/`test/` após cada uma.

### As 5 da iteração 1, re-executadas

| # | Alvo | Killed? |
|---|---|---|
| M3 | `home_page.dart:86` `go` → `push` | ✅ **Morto** (6) |
| M8 | `home_page.dart:79` `Routes.montar(resumo.id)` → `Routes.novoRole` | ✅ **Morto** (3) |
| M9 | `app_shell.dart:160` `Routes.novoRole` → `Routes.montar('rafa18')` | ✅ **Morto** (1) |
| M10 | `home_page.dart:76,82` id fixo em whatsapp/custos | ✅ **Morto** (2) |
| M15 | `home_expandida.dart:99-105` ARQUIVO ↔ COMEÇAR OUTRA | ✅ **Morto** (1) |

**5/5 mortos.** As correções discriminam de fato.

### As 7 novas — alvos que a rodada de correção não antecipou

| # | Arquivo:linha | Mutação | Killed? |
|---|---|---|---|
| **N1** | `card_da_festa.dart:108` | remove o teto da pilha: `resumo.iniciais.take(avataresVisiveis).toList()` → `resumo.iniciais.toList()` | ❌ **SOBREVIVEU** |
| N2 | `home_expandida.dart:37-38` | `flexDaEsquerda`/`flexDaDireita` trocados (115 ↔ 85) | ✅ Morto (1) |
| N3 | `home_textos.dart:62` | `quantos == 1` → `quantos != 1` (plural invertido) | ✅ Morto (28) |
| N4 | `home_textos.dart:52` | guarda de situação do subtítulo → `true` (a Home volta a dizer "nenhuma festa" enquanto falha) | ✅ Morto (2) |
| **N5** | `app_shell.dart:84-85` | remove o `SafeArea(bottom: false)` do shell | ❌ **SOBREVIVEU** |
| **N6** | `festa_repository_em_memoria.dart:57` | `_ultimo = List.of(festas)` → `_ultimo = festas` (`emitir` guarda a lista de quem chamou) | ❌ **SOBREVIVEU** |
| **N7** | `card_da_festa.dart:164` | acrescenta `style: TextStyle(color: BoraColors.primary)` ao span dos **confirmados** | ❌ **SOBREVIVEU** |

**Resultado da iteração 2: 12 mutações, 8 mortas, 4 sobreviventes.**
(Acumulado sobre as duas iterações: 27 mutações, 23 mortas.)

---

## Os 4 sobreviventes novos — ranqueados

### N7 — a asserção do "vermelho só nos pendentes" confere o objeto errado · **Major**

**Requisito**: HOME-04 AC2 — "a linha `{n} confirmados · {n} pendentes` com **pendentes em vermelho**". A-09 fixa o significado do vermelho e limita a tela a 2 acentos.

`card_da_festa_test.dart:136-139` tenta ser o par discriminante:

```
expect(linha.style?.color ?? BoraColors.ink, isNot(BoraColors.primary))
```

Mas `linha.style` é o `style:` do **widget `Text.rich`** (`BoraTextStyles.linhaLista`), não o `style` do `TextSpan` raiz que carrega o texto dos confirmados. Pintar o span raiz de vermelho — que é como um implementador erraria ao "deixar a linha toda vermelha" a partir do span — **passa despercebido**. A asserção cobre o caso "linha inteira vermelha via `Text.style`" e deixa passar "confirmados vermelhos via `textSpan.style`".

**Fix**: afirmar o span raiz, não o widget — `expect((linha.textSpan! as TextSpan).style?.color ?? BoraColors.ink, isNot(BoraColors.primary))`, mantendo a asserção atual.

### N1 — o teto da pilha de avatares é defesa documentada e nunca exercida · **Major**

**Requisito**: HOME-04 AC2 (avatares empilhados com o "+N") · HOME-09 AC5.

`card_da_festa.dart:106-108` traz o comentário: *"Capado no teto: sem isto a pilha desenhava **todas** as iniciais e ainda somava o '+N' calculado sobre 3, mostrando mais círculos do que gente confirmada."* Removi o teto e **134 testes passaram**.

Motivo: **nenhum teste de widget alimenta o card com mais de 3 iniciais.** A fixture já corta em três (`festas_da_home.dart:66` — `.take(3)`), e todo `ResumoDeFesta` construído à mão em `test/features/home/presentation/**` usa 1 ou 3 iniciais. O caso de 5 iniciais existe **só no domínio** (`resumo_de_festa_test.dart:159-167`, que exercita `avataresMostrados(3)`), e o domínio não é onde o `.take()` do widget mora.

Não é mutante equivalente: com 5 iniciais e 6 confirmados, a pilha desenharia 5 círculos **mais** "+3" = 8 avatares para 6 confirmados. E o produto chega nesse estado de imediato — RN-30 já tem 4 pessoas confirmadas nomeadas.

**Fix**: um teste de widget com `iniciais: ['R','A','L','B','D']`, afirmando `findsNWidgets(3)` de `BoraAvatar` dentro do card e o "+3" ao lado.

### N5 — o `SafeArea` do shell não tem teste, e a alegação de regressão do `tasks.md` é falsa aqui · **Major**

Removi o `SafeArea(bottom: false)` do `AppShell` (`app_shell.dart:84-85`) e **245 testes passaram**.

Busca que fiz antes de declarar ausente:
- `grep -rn "MediaQuery\|viewPadding\|EdgeInsets.only(top" test/core/routing/ test/features/home/` → **vazio**
- `grep -rn "SafeArea\|safe area\|status bar" test/` → **vazio**

Nenhum teste do repositório define padding de `MediaQuery`, então o `SafeArea` é inobservável em toda a suíte.

**Isto contradiz uma alegação do `tasks.md`.** A §"Rodada de `code-review` do batch 1" afirma que os sete achados foram fechados *"cada um com teste de regressão que falha sem a correção"*. Dois deles são exatamente esta área — *"Barra sem `SafeArea`, desenhada atrás da status bar"* (`bf55f82`) e o commit `4e4a069` (*"inset do topo consumido uma vez"*). **Nenhum dos dois deixou teste que discrimine.** O código está certo; a rede não existe.

**Fix**: montar o shell dentro de um `MediaQuery` com `padding: EdgeInsets.only(top: 44)` e afirmar (a) que o topo da barra respeita o inset e (b) que o conteúdo da rota **não** o aplica uma segunda vez — que é o defeito específico de `4e4a069`.

### N6 — a cópia defensiva de `emitir` não tem teste, ao contrário da irmã · **Minor**

`festa_repository_em_memoria.dart:54-58` documenta *"Cópia nas duas pontas"*, mas só a semente tem teste (`festa_repository_em_memoria_test.dart:174` — "a lista da semente não muda o repositório por fora"). A cópia de `emitir` não tem, e removê-la passa.

Observação de precisão que já valia na iteração 1: o comentário diz "nas duas pontas", mas o código faz **uma** cópia — `_ultimo = List.of(festas)` e em seguida `_mudancas.add(_ultimo)`, entregando ao assinante a **mesma instância** que o repositório guarda. Severidade real baixa (nenhum chamador atual muta a lista), mas é assimetria entre o que o comentário promete e o que o teste protege.

**Fix**: espelhar o teste da semente para `emitir` — emitir uma lista mutável, mutá-la por fora, afirmar que o estado do repositório não mudou.

---

## Cobertura dos 19 requisitos — re-derivada (evidence-or-zero)

Só os requisitos cujo status **mudou** aparecem com evidência detalhada; os demais foram reconferidos e mantêm a evidência tabulada no histórico da iteração 1.

| Req | Iter. 1 | `file:line` + asserção (iteração 2) | Iter. 2 |
|---|---|---|---|
| HOME-02 | ❌ | `app_shell_acao_test.dart:56-63` — `expect(rotaAtual(), Routes.novoRole)` | ✅ **PASS** |
| HOME-04 | ✅ | `card_da_festa_test.dart:136-139` afirma `linha.style`, não `linha.textSpan.style` (N7); nenhum teste de widget com >3 iniciais (N1) | ❌ **Needs Fix** |
| HOME-05 | ⚠️ parcial | `arquivo_de_festas_test.dart:130-140` — `expect(arquivo.top, greaterThan(comecar.bottom))`, `expect(arquivo.left, closeTo(comecar.left, 1))`; `:147-150` — `expect(arquivo.left, greaterThan(card.right))` | ✅ **PASS** |
| HOME-07 | ❌ | `home_page_test.dart:139-145` — `expect(rotaAtual(), Routes.montar(rn30NaHome.id))`; `:206-226` — segundo card leva a `Routes.montar(outra.id)` | ✅ **PASS** |
| HOME-08 | ❌ | `home_page_test.dart:158` — `expect(rotaAtual(), Routes.whatsapp(rn30NaHome.id))` | ✅ **PASS** |
| HOME-11 | ❌ | `home_page_test.dart:170` — `expect(rotaAtual(), Routes.custos(rn30NaHome.id))` | ✅ **PASS** |
| HOME-12 | ❌ | AC2: `home_page_test.dart:180-187` — `expect(rotaAtual(), Routes.novoRole)` + `expect(rotaAtual(), isNot(contains(rn30NaHome.id)))`; AC4: `arquivo_de_festas_test.dart:130-140` | ✅ **PASS** |
| HOME-17 | ❌ | `home_page_test.dart:238-247` — `expect(find.byKey(keyFor('montar'), skipOffstage: false), findsOneWidget)` + `expect(rotaAtual(), Routes.montar(rn30NaHome.id))` | ✅ **PASS** |

**Requisitos com evidência que discrimina: 18/19** (era 13/19). O único aberto é **HOME-04**, e por dois mutantes de força-de-teste, não por defeito de código.

### Edge cases — reconferidos

Os 6 edge cases da spec continuam com evidência (tabela na iteração 1). **Um deles ficou mais fraco do que eu registrei**: *"WHEN a festa tem mais confirmados do que avatares exibidos THEN o '+N' SHALL mostrar o excedente"* está afirmado no domínio (`resumo_de_festa_test.dart:148`) e no widget só com ≤3 iniciais — é a mesma lacuna de N1. Reclassificado de ✅ para ⚠️ **parcial**.

---

## Os 8 spec-precision gaps — quais fecharam, quais continuam, qual muda de categoria

| # | Item | Situação na iteração 2 |
|---|---|---|
| 1 | ls do logo de 20px do header (`06` não dá) | 🔵 **Continua — corretamente declarado.** Ancorado em `BoraTextStyles.tituloTela.letterSpacing` com asserção que quebra se §2 mudar. Não vira gap |
| 2 | "primário compacto" de `06` (padding 9×14 / sombra 3px vs. tokens de §4) | 🔵 **Continua — corretamente declarado** em `app_shell.dart:113-117`. A spec e os tokens de fato se contradizem; escolher o token é a decisão certa |
| 3 | botão voltar "quando aplicável", sem critério | 🔵 **Continua — corretamente declarado** em `app_shell.dart:151-154`. Não desenhar em rota alguma é a leitura conservadora certa (AD-003) |
| 4 | emoji do ARQUIVO | 🔵 **Continua — corretamente declarado** em `arquivo_de_festas.dart:22-26` |
| 5 | cor dos avatares da pilha | 🔵 **Continua — corretamente declarado** em `card_da_festa.dart:98-103` |
| 6 | copy da falha da Home | 🔵 **Continua — corretamente declarado** em `home_textos.dart:14-20` |
| 7 | **"sticky"** (P1-1 AC1) — gap **não declarado** que eu levantei na iteração 1 | ✅ **Fechado como item declarado.** `app_shell_test.dart:186-191` agora nomeia o `SPEC_PRECISION_GAP` e argumenta por quê: a barra não é um `SliverAppBar` — ou está fora do scroll, ou não está. **Aceito**: a asserção de proxy é a mais forte disponível |
| 8 | avatares de 40px de W-02 — **DEFERIDO** | 🟠 **Deve mudar de categoria.** Não é spec-precision gap: **W-02 define 40px com precisão**. É um **requisito deferido** — implementação conhecidamente incompleta de HOME-05 —, e arquivá-lo entre imprecisões da spec esconde que existe um degrau de W-02 por entregar. Deve virar item rastreado com dono (extensão de `BoraStackedAvatars`, emenda de fronteira própria), não nota de imprecisão |

**Resumo**: 6 continuam abertos e corretamente declarados (não são gaps — são a spec que não define), 1 fechou virando item declarado (#7), 1 precisa ser reclassificado de "spec-precision" para "deferido" (#8).

---

## Code Quality — iteração 2

| Princípio | Status |
|---|---|
| Correção test-only, sem mexer em produção para passar no Verifier | ✅ — `git show --stat 1601979`: 6 arquivos, todos em `test/` |
| Nenhum teste enfraquecido ou removido | ✅ — 1128 → 1131; as 5 asserções trocadas viraram asserções mais fortes |
| Correção na causa-raiz, não sintoma a sintoma | ✅ — um helper (`rotaAtual()`) fechou 4 dos 5 mutantes |
| `reason` dos testes descreve o que a asserção **de fato** detecta | ✅ — o `reason` errado de HOME-17 que eu apontei foi reescrito |
| Sem scope creep | ✅ |
| Spec-anchored outcome check | ⚠️ — HOME-04 AC2 confere o objeto errado (N7) |

---

## Fix Plans — iteração 3 (todos test-only, ~35 linhas, zero mudança em `lib/`)

### Fix 1 — N7: afirmar o span, não o widget (Major)
`card_da_festa_test.dart:136-139` — acrescentar `expect((linha.textSpan! as TextSpan).style?.color ?? BoraColors.ink, isNot(BoraColors.primary))`. **Done when**: N7 morre. **Cobre**: HOME-04 AC2.

### Fix 2 — N1: exercitar o teto da pilha (Major)
`card_da_festa_test.dart` — caso com `iniciais: ['R','A','L','B','D']` e `confirmados: 6`: `expect(descendant(CardDaFesta, BoraAvatar), findsNWidgets(3))` + `expect(find.text('+3'), findsOneWidget)`. **Done when**: N1 morre. **Cobre**: HOME-04 AC2, HOME-09 AC5, edge case do "+N".

### Fix 3 — N5: dar rede ao `SafeArea` (Major)
`app_shell_test.dart` — montar sob `MediaQuery(data: …padding: EdgeInsets.only(top: 44))` e afirmar (a) topo da barra respeitando o inset e (b) conteúdo da rota **sem** segunda aplicação. **Done when**: N5 morre. **Cobre**: a regressão de `4e4a069` e a de `bf55f82`.

### Fix 4 — N6: espelhar o teste de cópia para `emitir` (Minor)
`festa_repository_em_memoria_test.dart` — emitir lista mutável, mutar por fora, afirmar estado inalterado. Alinhar o comentário de `emitir` ("nas duas pontas") com o que o código faz (uma cópia). **Done when**: N6 morre.

### Fix 5 — Reclassificar o degrau de 40px (documental)
Tirar de "SPEC_PRECISION_GAP" e registrar como **requisito deferido** de HOME-05, com dono.

---

## Requirement Traceability — iteração 2

| Requisito | Iteração 1 | Iteração 2 |
|---|---|---|
| HOME-01 | ✅ (⚠️ sticky) | ✅ Verified (sticky declarado) |
| HOME-02 | ❌ Needs Fix | ✅ **Verified** |
| HOME-03 | ✅ | ✅ Verified |
| HOME-04 | ✅ | ❌ **Needs Fix** (N7, N1) |
| HOME-05 | ❌ Needs Fix | ✅ **Verified** (⚠️ degrau de 40px deferido) |
| HOME-06 | ✅ | ✅ Verified |
| HOME-07 | ❌ Needs Fix | ✅ **Verified** |
| HOME-08 | ❌ Needs Fix | ✅ **Verified** |
| HOME-09 | ✅ | ⚠️ Verified (AC5 parcial — ver N1) |
| HOME-10 | ✅ | ✅ Verified |
| HOME-11 | ❌ Needs Fix | ✅ **Verified** |
| HOME-12 | ❌ Needs Fix | ✅ **Verified** |
| HOME-13 | ✅ | ✅ Verified |
| HOME-14 | ✅ | ✅ Verified |
| HOME-15 | ✅ | ✅ Verified |
| HOME-16 | ✅ (⚠️ copy) | ✅ Verified |
| HOME-17 | ❌ Needs Fix | ✅ **Verified** |
| HOME-18 | ✅ | ✅ Verified |
| HOME-19 | ✅ | ✅ Verified (⚠️ cópia de `emitir` — ver N6) |

---

## Summary — iteração 2

**Overall**: ❌ **Not Ready — sem Blocker, sem defeito de produção**

**Spec-anchored check**: **18/19** requisitos com evidência que discrimina (era 13/19)
**Sensor**: **12 mutações, 8 mortas, 4 sobreviventes** — as 5 da iteração 1 morreram todas
**Gate**: analyze exit 0 · test exit 0, **1131 passaram**

**O que funciona agora e não funcionava**: a camada de navegação inteira. `rotaAtual()` fez os testes afirmarem **para onde** o toque leva, e não que a tela mudou — inclusive o caso de duas festas, que é onde o `ResumoDeFesta.id` justifica a SPEC_DEVIATION que o criou. A geometria de W-02 ganhou asserção. HOME-17 passou a enxergar a página empilhada offstage que eu tinha exposto por probe. O token da sombra deixou de pinar o card errado.

**O que falta**: quatro defesas escritas no código e nunca exercidas — o teto da pilha de avatares, o `SafeArea` do shell, a cópia de `emitir` — e uma asserção que confere o objeto errado (o vermelho dos confirmados). É uma família só: **comentário promete, teste não protege**. Nos quatro casos o código de produção está correto; o risco é a próxima mudança quebrar sem ninguém ver.

**Achado que a rodada anterior declarou e não se sustenta**: o `tasks.md` afirma que os sete achados do `code-review` foram fechados "cada um com teste de regressão que falha sem a correção". Para os dois achados de `SafeArea`/inset, **isso é falso** — nenhum teste do repositório sequer define padding de `MediaQuery`.

**Next steps**: um commit test-only fechando Fix 1–4 (~35 linhas) e o registro documental do Fix 5. Nada disso toca `lib/`, e nada bloqueia UC-02 nem a entrada da spec 05.

---
---

# Histórico — Iteração 1 (2026-08-26)

> Preservado na íntegra. O registro do que estava errado é o que prova que o sensor discrimina.


**Date**: 2026-08-26
**Spec**: `.specs/features/home/spec.md`
**Diff range**: `feature/entrar..HEAD` (branch `feature/home`) — 25 commits, `5ad64a7`..`4e4a069`
**Verifier**: sub-agente independente (author ≠ verifier), cobertura re-derivada com **evidence-or-zero**
**Veredito**: ❌ **FAIL** — 5 mutantes sobreviventes e 2 ACs sem evidência

---

## Gate Check

| Gate | Comando | Exit code | Resultado |
|---|---|---|---|
| Analyze | `flutter analyze` | **0** | `No issues found!` |
| Full | `flutter test` | **0** | **1128 passaram**, 0 falharam, 0 skipped |

- **Test count antes da feature** (declarado pelo autor para `feature/entrar`): 947
- **Test count depois**: **1128** — delta **+181**
- **Integridade da suíte**: 2 `testWidgets` e 10 `expect(` aparecem como removidos no diff. **Nenhum é perda**:
  - 2 `testWidgets` + 4 `expect` do `DivisorOu` foram **relocados verbatim** para `test/features/entrar/presentation/widgets/divisor_ou_test.dart` (arquivo novo, 36 linhas) quando `marca_bora_test.dart` virou `bora_marca_test.dart`.
  - 3 `expect` são a migração **E-4** (`PlaceholderPage.keyFor('home')` → `HomePage.pageKey`), cada um substituído por asserção idêntica em força.
  - 3 `expect` são o rename **E-6** (`MarcaBora.*` → `BoraMarca.*`), idem.
- Baseline declarada pelo autor (analyze limpo + 1128 verdes) **confirmada de forma independente**.

---

## Verificação do contexto declarado pelo autor

| Declaração | Verificado? | Evidência |
|---|---|---|
| **AD-022** — o aceite é a transição `4/2 → 5/1`, não a string estática | ✅ | `test/features/home/presentation/pages/home_page_test.dart:105-118` e `test/features/home/presentation/widgets/home_expandida_test.dart:176-183`. Sensor M1 (inverter `confirmacaoNova`) **matou** 10 testes ⇒ a transição de fato discrimina uma implementação derivada |
| **D-1** — flag de "confirmação nova" mora no `HomeBloc`, pareado por `id` | ✅ | `lib/features/home/presentation/bloc/home_bloc.dart:66-88`; par por id afirmado em `home_bloc_test.dart:301-307` (`temConfirmacaoNova(homonima)` é `isFalse`). `ResumoDeFesta` não carrega o flag |
| **SPEC_DEVIATION** — `ResumoDeFesta.id` acrescentado | ✅ existe e está documentado (`resumo_de_festa.dart:28-39`) | ⚠️ **mas o id não tem prova de chegar à URL** — ver mutantes M8/M10 |
| **SPEC_DEVIATION** — festas passadas em `festas_da_home.dart`, não no bruto de RN-30 | ✅ | `git diff feature/entrar..HEAD -- test/fixtures/rn30_estado_inicial*.dart` = **vazio**. `rn30_estado_inicial.dart`, `rn30_estado_inicial_test.dart` e `rn30_estado_inicial_tipado.dart` estão **intocados**. A declaração "fonte literal: RN-30" segue verdadeira |
| **E-3/E-4** — migração de chave sem enfraquecer asserção | ✅ | Diff é substituição pura de chave. O par ENT-15/16 está intacto: `test/app_test.dart:29` (`findsOneWidget` com sessão) × `test/app_test.dart:42` (`findsNothing` sem sessão) |
| **E-5** — `BoraAvatar` com par de cores opcional | ✅ aditivo | `bora_avatar.dart`: construtor ganhou `this.par`, default `BoraColors.avatarPairFor(nome)`. Nenhuma asserção da spec 01 removida (+49 linhas de teste, 0 removidas) |
| **E-6** — `MarcaBora` → `BoraMarca` com `.header()` | ✅ | Rename com `similarity index 50%`; toda asserção preservada ou relocada. Anti-vácuo do `.header()` em `bora_marca_test.dart` ("o header é menor que os outros dois tamanhos") |
| **Duas rodadas de `code-review`, 10 achados corrigidos com regressão** | ✅ para as 3 que sondei | M6 (poda de `comConfirmacaoNova`) → **morto**; M7 (`Material` do header) → **morto**; "falha não zera o estado" → morto por M1/M6 colaterais. As regressões **discriminam de fato** |

---

## Spec-Anchored Acceptance Criteria

### P1-1: O chrome do app logado

| Criterion | Spec-defined outcome | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — barra de `06` em expandido: fundo `paper`, borda inferior 2px `ink`, logo "BORA.", avatar, sticky no topo | `paper`; `width: 2`, `color: ink`; logo presente; barra acima do conteúdo | `test/core/routing/app_shell_test.dart:101` — `expect(find.byKey(AppShell.headerKey), findsOneWidget)`; `:144-146` — `expect(decoracao.color, BoraColors.paper)`, `expect(borda.bottom.width, 2)`, `expect(borda.bottom.color, BoraColors.ink)`; `:199` — `expect(logo, findsOneWidget)`; `:184-185` — `expect(getBottomLeft(headerKey).dy, lessThanOrEqualTo(getTopLeft(conteúdo).dy))` | ✅ PASS |
| AC1 — "sticky" | spec diz "sticky"; nenhuma spec define comportamento sob scroll | `app_shell_test.dart:184` afirma **ordem vertical**, não persistência sob rolagem | ⚠️ **Spec-precision gap** — "sticky" é afirmado por proxy (a barra vive fora do que rola). Nenhum teste rola a página e reafirma a barra |
| AC2 — avatar amarelo do token, borda 2px, **inicial do usuário logado** | `BoraColors.yellow`; `width: 2`; letra derivada de `UsuarioLogado.inicial` | `app_shell_test.dart:233` — `expect(circulo.color, BoraColors.yellow)`; `:237` — `expect(circulo.border!.top.width, 2)`; `:245-250` — `expect(find.text('A'), findsOneWidget)` + `expect(find.text('R'), findsNothing)` (par discriminante com outro usuário); `:263-267` — anti-vácuo: `expect(BoraColors.avatarPairFor('R').fundo, isNot(BoraColors.yellow))` | ✅ PASS |
| AC3 — na Home em expandido a ação é "+ NOVO ROLÊ", navegando para `/roles/novo` | destino **`/roles/novo`** | `test/core/routing/app_shell_acao_test.dart:38` — `expect(_acao, findsOneWidget)`; `:56` — `expect(find.byKey(PlaceholderPage.keyFor('montar')), findsOneWidget)` | ❌ **GAP** — a asserção do destino é a **chave do placeholder**, e `/roles/novo` e `/roles/:id/montar` renderizam **o mesmo** `MontarPage`/`keyFor('montar')` (`app_router.dart:99-114`). Mutante **M9 sobreviveu** |
| AC4 — sem botão voltar na Home | ausência de `BackButton`/`arrow_back` | `app_shell_acao_test.dart:97-110` — `expect(find.descendant(of: headerKey, matching: find.byType(BackButton)), findsNothing)` e idem para `Icons.arrow_back` | ✅ PASS |
| AC5 — zero literal de cor, fonte ou sombra no `AppShell` | nenhum literal | `test/core/design_system/architecture/token_purity_guard_test.dart:136` — `expect(_varrer(lib, violacoesDeCorEm), isEmpty)` (varre `lib/` **inteira**, sem allowlist) + anti-vácuo injetado em `:143-158` | ✅ PASS (cobertura herdada da spec 01, mas real) |

### P1-2: Ver o painel de rolês

| Criterion | Spec-defined outcome | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — ordem de T-02 em compacto | título → subtítulo → card → COMEÇAR OUTRA | `home_page_test.dart:51-53` — `expect(titulo, lessThan(sub)); expect(sub, lessThan(card)); expect(card, lessThan(comecar))` | ✅ PASS |
| AC2 — tag +3°, nome, avatares + "+N" tracejado, contadores com pendentes em vermelho, os dois botões | `aEsquerda: false` (= +3°); "+1"; `BoraColors.primary` só nos pendentes; primário > secundário | `card_da_festa_test.dart:99-102` — `expect(widget<BoraRotatedTag>(…).aEsquerda, isFalse)`; `:72` — `expect(find.text('CHURRAS DO RAFA 🔥'), findsOneWidget)`; `:183` — `expect(find.text('+1'), findsOneWidget)`; `:133-139` — `expect(trechos.last.text, '2 pendentes')`, `expect(trechos.last.style?.color, BoraColors.primary)`, `expect(linha.style?.color ?? ink, isNot(primary))`; `:146-152` — `expect(find.text('+ CONVIDAR'), findsOneWidget)`, `expect(find.text('MONTAR LISTA →'), findsOneWidget)`, `expect(sizePrimário.width, greaterThan(sizeSecundário.width))` | ✅ PASS |
| AC3 — W-02: título à esquerda / subtítulo à direita na mesma linha; grid 2 colunas, card à esquerda, COMEÇAR OUTRA **+ ARQUIVO** à direita | os dois na mesma linha; card.right < comecar.left; ARQUIVO na coluna direita | `home_expandida_test.dart:73-79` — `expect(titulo.right, lessThan(sub.left))`, `expect(sub.top, lessThan(titulo.bottom))`; `:89-90` — `expect(linha.crossAxisAlignment, CrossAxisAlignment.baseline)`; `:114-119` — `expect(card.right, lessThan(comecar.left))`, `expect(card.width, greaterThan(comecar.width))` | ⚠️ **PARCIAL** — a posição do **ARQUIVO** na coluna direita **não é afirmada em lugar nenhum** (busca: `grep -rn "ArquivoDeFestas" test/` → só `arquivo_de_festas_test.dart` e `home_estados_test.dart:89-94`, nenhuma asserção geométrica). Mutante **M15 sobreviveu** |
| AC4 — com a fixture, subtítulo = "1 festa chegando · 2 passadas" e contadores = "4 confirmados · 2 pendentes" | as duas strings literais | `home_page_test.dart:61` — `expect(find.text('1 festa chegando · 2 passadas'), findsOneWidget)`; `:67` — `expect(find.text('4 confirmados · 2 pendentes'), findsOneWidget)`; par anti-literal-fixo em `:76-81` — `expect(find.text('1 festa chegando · 1 passada'), findsOneWidget)` | ✅ PASS |
| AC5 — "MONTAR LISTA →" navega para `/roles/{festaId}/montar` | destino contém o **festaId** | `home_page_test.dart:139` — `expect(find.byKey(PlaceholderPage.keyFor('montar')), findsOneWidget)` | ❌ **GAP** — o `{festaId}` nunca é afirmado. Mutante **M8 sobreviveu** (`Routes.montar(resumo.id)` → `Routes.novoRole`) |
| AC6 — "+ CONVIDAR" navega para `/roles/{festaId}/whatsapp` | destino contém o **festaId** | `home_page_test.dart:149` — `expect(find.byKey(PlaceholderPage.keyFor('convite')), findsOneWidget)` | ❌ **GAP** — a rota certa é afirmada, o `{festaId}` não. Mutante **M10 sobreviveu** |

### P1-3: O contador muda sozinho

| Criterion | Spec-defined outcome | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — `4/2 → 5/1` sem remontagem e sem ação do usuário | as duas strings, na mesma árvore montada | `home_page_test.dart:105` — `expect(find.text('4 confirmados · 2 pendentes'), findsOneWidget)`; `:112` (após `repositorio.emitir(...)`, sem `pumpWidget`) — `expect(find.text('5 confirmados · 1 pendente'), findsOneWidget)`; unit em `home_bloc_test.dart:105-106` — `expect(bloc.state.chegando.single.confirmados, 5)`, `expect(…pendentes, 1)` | ✅ PASS |
| AC2 — o atalho amarelo aparece com a confirmação | "💸 VER O ACERTO DA FESTA →" presente | `home_page_test.dart:118` — `expect(find.text(CardDaFesta.verOAcerto), findsOneWidget)`; `card_da_festa_test.dart:248` — `expect(find.text('💸 VER O ACERTO DA FESTA →'), findsOneWidget)` | ✅ PASS |
| AC3 — sem confirmação nova, o atalho **não** está presente (par discriminante) | ausência | `card_da_festa_test.dart:254-259` — `expect(find.text('💸 VER O ACERTO DA FESTA →'), findsNothing)`; `home_page_test.dart:106` — idem antes da emissão; `home_bloc_test.dart:114-119` — `expect(bloc.state.temConfirmacaoNova(rn30NaHome), isFalse)` na primeira emissão | ✅ PASS |
| AC4 — o atalho navega para `/roles/{festaId}/custos` | destino contém o **festaId** | `home_page_test.dart:160` — `expect(find.byKey(PlaceholderPage.keyFor('custos')), findsOneWidget)` | ❌ **GAP** — `{festaId}` não afirmado. Mutante **M10 sobreviveu** |
| AC5 — avatares e "+N" refletem a nova contagem | "+1" → "+2" | `home_page_test.dart:123` — `expect(find.text('+1'), findsOneWidget)`; `:128` — `expect(find.text('+2'), findsOneWidget)` | ✅ PASS |
| AC6 — vale igual em expandido | mesma transição e mesmo atalho em 1180×800 | `home_expandida_test.dart:176-183` — `expect(find.text('4 confirmados · 2 pendentes'), findsOneWidget)`, `expect(find.text(verOAcerto), findsNothing)` → emitir → `expect(find.text('5 confirmados · 1 pendente'), findsOneWidget)`, `expect(find.text(verOAcerto), findsOneWidget)` | ✅ PASS |

### P1-4: Começar outro rolê

| Criterion | Spec-defined outcome | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — grid 2 colunas com "🔥 CHURRASCO" e "🎈 NIVER · EM BREVE" | as duas copies, lado a lado | `comecar_outra_test.dart:34-35` — `expect(find.text('🔥 CHURRASCO'), findsOneWidget)`, `expect(find.text('🎈 NIVER · EM BREVE'), findsOneWidget)`; `:44-49` — `expect(esquerda.right, lessThan(direita.left))`, `expect(esquerda.center.dy, closeTo(direita.center.dy, 1))` | ✅ PASS |
| AC2 — "🔥 CHURRASCO" navega para `/roles/novo` | destino `/roles/novo` | `home_page_test.dart:169` — `expect(find.byKey(PlaceholderPage.keyFor('montar')), findsOneWidget)`; callback em `comecar_outra_test.dart:70` — `expect(comecou, 1)` | ❌ **GAP** — mesmo defeito do AC3 de P1-1: `keyFor('montar')` não distingue `/roles/novo` de `/roles/:id/montar` |
| AC3 — "🎈 NIVER" inerte: sem navegação, sem toast, sem estado; tracejado e esmaecido | callback não dispara; rota inalterada; `BoraEmptySlot` com `opacidadeDesabilitado` | `comecar_outra_test.dart:82-92` — `expect(comecou, 0)`, `expect(tester.takeException(), isNull)`; `:104-112` — `expect(widget<Opacity>(…).opacity, BoraBorders.opacidadeDesabilitado)`; `:118-130` — `expect(descendant(EmptySlot, BoraPressSink), findsNothing)`; `home_page_test.dart:180-185` — `expect(find.byKey(HomePage.pageKey), findsOneWidget)` + `expect(find.byKey(keyFor('montar')), findsNothing)`. Mutante **M4 morto** por estes dois | ✅ PASS |
| AC4 — em expandido ocupa a coluna direita, **acima do ARQUIVO** | comecar à direita do card **e** acima do ARQUIVO | `home_expandida_test.dart:114` — `expect(card.right, lessThan(comecar.left))` | ⚠️ **PARCIAL** — "acima do ARQUIVO" sem evidência. Mutante **M15 sobreviveu** |

### P2-1: O arquivo de festas passadas

| Criterion | Spec-defined outcome | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — uma linha por festa concluída: emoji, nome, "· {n} pessoas", total em vermelho à direita | N linhas; emoji por linha; `BoraColors.primary`; total à direita do nome | `arquivo_de_festas_test.dart:59-65` — `expect(descendant(ArquivoDeFestas, Row), findsNWidgets(festasPassadas.length))`; `:111-117` — `expect(descendant(…, find.text(ArquivoDeFestas.emoji)), findsNWidgets(2))`; `:80` — `expect(widget<Text>(total).style?.color, BoraColors.primary)`; `:83-87` — `expect(getRect(total).left, greaterThan(nome.left))` | ✅ PASS |
| AC2 — uma linha lê "Churras da laje · 14 pessoas" com total "R$ 612" | as duas strings literais de UC-24 | `arquivo_de_festas_test.dart:72` — `expect(find.text('Churras da laje · 14 pessoas'), findsOneWidget)`; `:78-79` — `expect(find.text('R\$ 612'), findsOneWidget)` | ✅ PASS |
| AC3 — total formatado por RN-13 vindo de `core/calculo` | `MoneyFormatter.reais`, inteiro, sem centavos | `arquivo_de_festas_test.dart:94-99` — `expect(find.text(MoneyFormatter.reais(festasPassadas.first.total!)), findsOneWidget)`; `:100-105` — `expect(find.text('612'), findsNothing)`, `expect(find.textContaining('612,00'), findsNothing)`. Mutante **M13 morto** | ✅ PASS |
| AC4 — em compacto o arquivo só conta no subtítulo | seção ausente | `arquivo_de_festas_test.dart:176-181` — `expect(find.byType(ArquivoDeFestas), findsNothing)`, `expect(find.text('Churras da laje · 14 pessoas'), findsNothing)`; `:188` — `expect(find.text('1 festa chegando · 2 passadas'), findsOneWidget)` | ✅ PASS |
| AC5 — tocar numa linha não faz nada | rota inalterada | `arquivo_de_festas_test.dart:161-167` — `expect(find.byKey(HomePage.pageKey), findsOneWidget)`, `expect(tester.takeException(), isNull)` | ✅ PASS |

### P2-2: A Home de quem não tem festa

| Criterion | Spec-defined outcome | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — sem festa: card ausente, subtítulo "nenhuma festa chegando" | ausência + string literal | `home_estados_test.dart:55-57` — `expect(find.byType(CardDaFesta), findsNothing)`, `expect(find.byKey(HomePage.pageKey), findsOneWidget)`, `expect(tester.takeException(), isNull)`; `:64` — `expect(find.text('nenhuma festa chegando'), findsOneWidget)` — **nos dois viewports** (loop `_viewports`) | ✅ PASS |
| AC2 — "COMEÇAR OUTRA" presente **e funcional** | seção presente + o toque navega | `home_estados_test.dart:71` — `expect(find.byType(ComecarOutra), findsOneWidget)`; `:76-81` — após tap: `expect(find.byKey(PlaceholderPage.keyFor('montar')), findsOneWidget)` | ✅ PASS |
| AC3 — ARQUIVO renderiza vazio, sem linha e sem erro | seção presente, 0 linhas, sem exceção | `home_estados_test.dart:89-99` — `expect(find.byType(ArquivoDeFestas), findsOneWidget)`, `expect(descendant(…, text(emoji)), findsNothing)`, `expect(tester.takeException(), isNull)` | ✅ PASS |
| AC4 — passadas sem nenhuma chegando: "nenhuma festa chegando · {n} passadas" | string literal | `home_estados_test.dart:112-116` — `expect(find.text('nenhuma festa chegando · 2 passadas'), findsOneWidget)`, `expect(find.byType(CardDaFesta), findsNothing)` — nos dois viewports | ✅ PASS |

### P2-3: Placeholder revestido

| Criterion | Spec-defined outcome | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — tokens do arquivo 02, nenhum literal | `BoraColors.paper`; `BoraTextStyles.tituloTela` (Archivo Black) | `placeholder_page_test.dart:39-44` — `expect(widget<Scaffold>(…).backgroundColor, BoraColors.paper)`; `:52-53` — `expect(estilo, BoraTextStyles.tituloTela)`, `expect(estilo.fontFamily, BoraTextStyles.familiaDisplay)`; `:73` — `expect(widget<Text>(find.text('home')).style, BoraTextStyles.dica)` | ✅ PASS |
| AC2 — `keyFor(id)` preservada | chave intacta | `placeholder_page_test.dart:84-89` — `expect(find.byKey(PlaceholderPage.keyFor('home')), findsOneWidget)`; `:30-31` — par: `keyFor('galera')` `findsNothing` | ✅ PASS |

### Requisitos de dimensão implícita

| Requisito | Spec-defined outcome | `file:line` + asserção | Result |
|---|---|---|---|
| **HOME-16** — falha → estado visível **e** `AppLogger` | mensagem na tela; `logError` chamado uma vez | `home_bloc_test.dart:177` — `expect(bloc.state.situacao, SituacaoDaHome.falhou)`; `:188-190` — `expect(logger.erros, hasLength(1))`, `expect(logger.erros.single.error, isStateError)`, `expect(…stackTrace, isNotNull)`; par em `:198-203` — `expect(logger.erros, isEmpty)` no caminho feliz; UI em `home_estados_test.dart:139-149` — `findsNothing` antes, `expect(find.text(HomeTextos.falha), findsOneWidget)` depois, nos dois viewports | ✅ PASS |
| **HOME-16** — copy da falha | **nenhuma spec define a frase** | `home_textos.dart:14-20` declara `SPEC_PRECISION_GAP` | ⚠️ **Spec-precision gap** (declarado pelo autor, confirmado) |
| **HOME-17** — toque duplo navega uma vez | uma única instância da tela de destino | `home_page_test.dart:199-205` — `expect(find.byKey(PlaceholderPage.keyFor('montar')), findsOneWidget)` | ❌ **GAP** — mutante **M3 (`go` → `push`) sobreviveu**. Probe: com `push`, `find.byKey(...)` = **1** e `find.byKey(..., skipOffstage: false)` = **2** — a segunda cópia empilhada fica offstage e o `findsOneWidget` default não a vê. O `reason` do teste ("com `push`… empilharia uma segunda cópia") descreve um efeito que a asserção **não** detecta |
| **HOME-19** — porta + stream + impl em memória | semente entregue; emissão nova; assinante tardio; `dispose`; `lib/` não importa `test/` | `festa_repository_em_memoria_test.dart:95` — `expect(recebidos, [...])`; `:129-130` — dois ouvintes recebem a mesma emissão; `:164` — emissão durante a entrega da semente não se perde; `:193` — `expect(repositorio, isA<FestaRepository>())`; `:202-224` — varredura de import + anti-vácuo (acusa import proibido, ignora citação em comentário). `resumo_de_festa_test.dart` cobre igualdade por valor e todas as fronteiras do `clamp` | ✅ PASS |

---

## Edge Cases

| Edge case | `file:line` + asserção | Result |
|---|---|---|
| Mais de uma festa chegando ⇒ um card por festa, plural certo | `home_page_test.dart:96-97` — `expect(find.byType(CardDaFesta), findsNWidgets(2))`, `expect(find.text('2 festas chegando · 2 passadas'), findsOneWidget)` | ✅ |
| 0 pendentes ⇒ "{n} confirmados · 0 pendentes" | `card_da_festa_test.dart:227-232` — `expect(find.text('5 confirmados · 0 pendentes'), findsOneWidget)` | ✅ |
| Mais confirmados que avatares ⇒ "+N" mostra o excedente | `card_da_festa_test.dart:207` — `expect(find.text('+3'), findsOneWidget)` (6 confirmados); `resumo_de_festa_test.dart:148` — `expect(poucasIniciais.excedenteDeAvatares(3), 2)` | ✅ |
| 3 ou menos confirmados ⇒ sem "+N" | `card_da_festa_test.dart:189-201` — `expect(widget<BoraStackedAvatars>(…).extras, 0)` + `expect(find.textContaining(RegExp(r'^\+\d')), findsNothing)` | ✅ |
| Cruzar 900px preserva o estado do stream | `home_expandida_test.dart:199-210` — após `setSurfaceSize`: `expect(find.byType(HomeExpandida), findsOneWidget)`, `expect(find.text('5 confirmados · 1 pendente'), findsOneWidget)`, `expect(find.text(verOAcerto), findsOneWidget)` | ✅ |
| Nome longo ⇒ sem overflow, sem scroll horizontal | `card_da_festa_test.dart:310-314` — `expect(tester.takeException(), isNull)`, `expect(getRect(card).right, lessThanOrEqualTo(getRect(Scaffold).right))`; `home_expandida_test.dart:220-222` | ✅ |

**Todos os 6 edge cases da spec têm evidência.**

---

## Discrimination Sensor

Todas as mutações rodaram em estado descartável (edição + `git checkout --`), com `git status --porcelain` vazio confirmado após cada uma. Árvore real nunca alterada.

| # | Arquivo:linha | Mutação | Killed? |
|---|---|---|---|
| M1 | `home_bloc.dart:77` | `(anteriores[id] ?? confirmados) < confirmados` → `>=` | ✅ **Morto** (10 falhas) |
| M2 | `resumo_de_festa.dart:80` | `confirmados - avataresMostrados(visiveis)` → `confirmados - visiveis` | ✅ **Morto** (`resumo_de_festa_test.dart:148`) |
| M3 | `home_page.dart:86` | `context.go(rota)` → `context.push(rota)` | ❌ **SOBREVIVEU** |
| M4 | `comecar_outra.dart:56` | envolve `BoraEmptySlot` num `GestureDetector(onTap: aoComecarChurrasco)` | ✅ **Morto** (`comecar_outra_test.dart:82` + `home_page_test.dart:180`) |
| M5 | `home_textos.dart:32` | `subtitulo()` retorna a string fixa `'1 festa chegando · 2 passadas'` | ✅ **Morto** (12 falhas) |
| M6 | `home_bloc.dart:86` | remove `.where(idsQueChegam.contains)` da poda | ✅ **Morto** (`home_bloc_test.dart:276`) |
| M7 | `app_shell.dart:131` | remove o `Material` acima da barra | ✅ **Morto** (`app_shell_test.dart:127`) |
| M8 | `home_page.dart:79` | `Routes.montar(resumo.id)` → `Routes.novoRole` | ❌ **SOBREVIVEU** |
| M9 | `app_shell.dart:160` | `context.go(Routes.novoRole)` → `context.go(Routes.montar('rafa18'))` | ❌ **SOBREVIVEU** |
| M10 | `home_page.dart:76,82` | `Routes.whatsapp(resumo.id)`/`Routes.custos(resumo.id)` → id fixo `'festa-errada'` | ❌ **SOBREVIVEU** |
| M11 | `arquivo_de_festas.dart:90` | total: `BoraColors.primary` → `BoraColors.ink` | ✅ **Morto** |
| M12 | `card_da_festa.dart:171` | pendentes: `BoraColors.primary` → `BoraColors.ink` | ✅ **Morto** |
| M13 | `arquivo_de_festas.dart:88` | `MoneyFormatter.reais(total)` → `'R$ ${resumo.total}'` | ✅ **Morto** (2 falhas) |
| M14 | `card_da_festa.dart:146` | `aEsquerda: false` → `true` (tag −3° em vez de +3°) | ✅ **Morto** |
| M15 | `home_expandida.dart:99-105` | ARQUIVO trocado de lugar com COMEÇAR OUTRA na coluna direita | ❌ **SOBREVIVEU** |

**Sensor depth**: P0-estendido (15 mutações; o mínimo do tier default é 1–3)
**Result**: **10/15 mortos, 5 sobreviventes** — ❌ **FAIL**

**Causa-raiz comum de M3, M8, M9, M10**: nenhum teste da Home afirma a **URL** resultante. `abrirApp` (`test/support/app_de_teste.dart:20-49`) devolve só o duplo de autenticação, não o `GoRouter`, então nenhum teste tem como ler `router.routerDelegate.currentConfiguration.uri`. Todas as asserções de destino usam `PlaceholderPage.keyFor(...)`, e `/roles/novo` e `/roles/:festaId/montar` compartilham o mesmo `MontarPage` (`app_router.dart:99-114`) — logo compartilham a chave. O `ResumoDeFesta.id` foi acrescentado (SPEC_DEVIATION) **exatamente** porque HOME-07 exige `/roles/{festaId}/montar`, e nada prova que ele chega à URL.

---

## Code Quality

| Princípio | Status |
|---|---|
| Sem features além do pedido | ✅ — os itens de Out of Scope não aparecem; `FestaRepository` tem um método só |
| Sem abstração para uso único | ✅ — `_temAcao` deliberadamente não generalizado (registrado no `tasks.md`) |
| Sem "flexibilidade" desnecessária | ✅ |
| Só arquivos necessários tocados | ✅ — a fronteira do `spec.md` foi respeitada; as saídas dela estão declaradas como E-3..E-6 **antes** do Execute |
| Não "melhorou" código alheio | ✅ — `rn30_estado_inicial*.dart` intocados; `BoraAvatar` e `BoraMarca` só aditivos |
| Segue padrões existentes | ✅ — mesmo formato de `entrar` (bloc acima do `ResponsiveBuilder`, porta pelo roteador, textos centralizados) |
| Spec-anchored outcome check | ⚠️ — 4 ACs de navegação afirmam um proxy (chave do placeholder), não o destino que a spec define |
| Coverage Expectation por camada | ✅ domínio 1:1 com ACs; ⚠️ rotas: happy path coberto, **destino preciso não** |
| Todo teste mapeia a um requisito | ✅ — todos os grupos citam `HOME-xx`, `FUND-xx`, `W-Rx` ou edge case |
| Guidelines documentadas seguidas | ✅ — `CLAUDE.md` §Testes; `flutter_lints`; sem CI criada |

---

## SPEC_PRECISION_GAPs (declarados pelo autor — todos confirmados)

| # | Onde | O que a spec não define |
|---|---|---|
| 1 | `bora_marca.dart` / `bora_marca_test.dart` | a `letter-spacing` do logo de 20px do header (`06` dá só o tamanho) — ancorada em `BoraTextStyles.tituloTela.letterSpacing` com asserção que quebra se §2 mudar |
| 2 | `app_shell.dart:113-117` | "primário compacto" de `06` (padding 9×14, sombra 3px) contra os tokens de §4 — mantido o primário do design system |
| 3 | `app_shell.dart:151-154` | botão voltar "quando aplicável" sem critério em spec nenhuma — não desenhado em rota alguma |
| 4 | `arquivo_de_festas.dart:22-26` | de onde vem o emoji de cada linha do ARQUIVO — constante `🔥` no M1 |
| 5 | `card_da_festa.dart:98-103` | a cor de cada avatar da pilha — deriva da inicial via `avatarPairFor` |
| 6 | `home_textos.dart:14-20` | a copy da falha da Home — herda a voz de `EntrarTextos.indisponivel` |
| 7 | **novo, não declarado**: "sticky" (P1-1 AC1) | nenhuma spec define o comportamento sob scroll; o teste afirma ordem vertical, não persistência |
| 8 | **DEFERIDO** `card_da_festa.dart:51-55` | avatares de 40px de W-02 — `BoraStackedAvatars` é fixo em 34px; exige emenda de fronteira no design system |

---

## Achado menor (não é gap de requisito)

`card_da_festa_test.dart:111` afirma `expect(superficie.deslocamentoDaSombra, BoraShadows.distanciaCardHeroi)`, mas o código lê de `BoraShadows.cardBranco.offset.dx` (`card_da_festa.dart:40`), e o doc do próprio código diz explicitamente "lidos do token do card branco, **e não** do card-herói escuro… quem mexesse na sombra do herói arrastaria a do card da Home junto". Os dois tokens valem 6 hoje, então o teste passa — mas ele **pina o token errado** e, se os dois divergirem, falhará por um motivo que o código já se propôs a evitar.

---

## Fix Plans

### Fix 1 — Afirmar a **URL**, não a chave do placeholder (Blocker)
- **Root cause**: `abrirApp` não expõe o `GoRouter`; `/roles/novo` e `/roles/:id/montar` compartilham `PlaceholderPage.keyFor('montar')`.
- **Fix task**: fazer `abrirApp` (`test/support/app_de_teste.dart`) devolver também o `GoRouter` (ou um `ValueGetter<String>` da location corrente) e trocar, em `home_page_test.dart:139/149/160/169` e `app_shell_acao_test.dart:56`, a asserção de chave por `expect(location, Routes.montar(rn30NaHome.id))` / `Routes.whatsapp(...)` / `Routes.custos(...)` / `Routes.novoRole`. Manter a asserção de chave como complemento.
- **Done when**: M8, M9 e M10 passam a ser mortos.
- **Cobre**: HOME-07 AC5, HOME-08 AC6, HOME-11 AC4, HOME-02 AC3, HOME-12 AC2.

### Fix 2 — HOME-17 tem de matar `push` (Blocker)
- **Root cause**: `findsOneWidget` pula widgets offstage; a cópia empilhada por `push` fica offstage.
- **Fix task**: em `home_page_test.dart:199`, usar `find.byKey(PlaceholderPage.keyFor('montar'), skipOffstage: false)` com `findsOneWidget`, ou afirmar que a Home **não** está mais na árvore nem offstage (`expect(find.byKey(HomePage.pageKey, skipOffstage: false), findsNothing)`).
- **Done when**: M3 vira morto.
- **Cobre**: HOME-17.

### Fix 3 — Posição do ARQUIVO em W-02 (Major)
- **Root cause**: nenhuma asserção geométrica sobre `ArquivoDeFestas`.
- **Fix task**: em `home_expandida_test.dart`, acrescentar `expect(getRect(ComecarOutra).bottom, lessThanOrEqualTo(getRect(ArquivoDeFestas).top))` e `expect(getRect(CardDaFesta).right, lessThan(getRect(ArquivoDeFestas).left))`.
- **Done when**: M15 vira morto.
- **Cobre**: HOME-05 AC3, HOME-12 AC4.

### Fix 4 — Token de sombra do card (Minor)
- **Fix task**: trocar `BoraShadows.distanciaCardHeroi` por `BoraShadows.cardBranco.offset.dx` em `card_da_festa_test.dart:111`.

---

## Requirement Traceability Update

| Requisito | Status anterior | Novo status |
|---|---|---|
| HOME-01 | Pending | ✅ Verified (⚠️ "sticky" = spec-precision gap) |
| HOME-02 | Pending | ❌ Needs Fix (M9) |
| HOME-03 | Pending | ✅ Verified |
| HOME-04 | Pending | ✅ Verified |
| HOME-05 | Pending | ❌ Needs Fix (ARQUIVO sem evidência de posição — M15) |
| HOME-06 | Pending | ✅ Verified |
| HOME-07 | Pending | ❌ Needs Fix (M8) |
| HOME-08 | Pending | ❌ Needs Fix (M10) |
| HOME-09 | Pending | ✅ Verified |
| HOME-10 | Pending | ✅ Verified |
| HOME-11 | Pending | ❌ Needs Fix (M10) |
| HOME-12 | Pending | ❌ Needs Fix (AC2 = M9/M8; AC4 = M15) |
| HOME-13 | Pending | ✅ Verified |
| HOME-14 | Pending | ✅ Verified |
| HOME-15 | Pending | ✅ Verified |
| HOME-16 | Pending | ✅ Verified (⚠️ copy = spec-precision gap) |
| HOME-17 | Pending | ❌ Needs Fix (M3) |
| HOME-18 | Pending | ✅ Verified |
| HOME-19 | Pending | ✅ Verified |

---

## Summary

**Overall**: ❌ **Not Ready**

**Spec-anchored check**: **13/19 requisitos com evidência que bate o resultado da spec**; 6 com gap (HOME-02, HOME-05, HOME-07, HOME-08, HOME-11, HOME-12) e 1 requisito (HOME-17) sem discriminação. 8 spec-precision gaps flagados (7 declarados pelo autor + "sticky").
**Sensor**: **10/15 mortos, 5 sobreviventes**.
**Gate**: `flutter analyze` exit 0, `flutter test` exit 0 — 1128 passaram, 0 falharam.

**O que funciona**: o contrato (`ResumoDeFesta`, porta, impl em memória) tem cobertura unit exemplar, incluindo a varredura de import com anti-vácuo. A promessa de RN-28 é afirmada como **transição** nos dois viewports, e o par presente/ausente do atalho amarelo discrimina de verdade — AD-022 se sustenta empiricamente. O header, a inércia do NIVER, o estado vazio, a falha e o revestimento do placeholder estão todos com par discriminante. Os 6 edge cases da spec têm evidência. A migração E-4/E-5/E-6 não perdeu nem enfraqueceu asserção nenhuma, e o bruto de RN-30 está intocado.

**O que falha**: a camada de **navegação**. Quatro requisitos definem destinos que contêm `{festaId}`, e nenhum teste lê a URL — todos afirmam a chave de um placeholder que duas rotas diferentes compartilham. É o mesmo defeito quatro vezes, e é justamente onde a SPEC_DEVIATION do `ResumoDeFesta.id` prometeu valor. Junto disso, HOME-17 afirma idempotência com um matcher que não vê a página empilhada, e a posição do ARQUIVO em W-02 nunca é afirmada.

**Next steps**: aplicar Fix 1 e Fix 2 (Blocker), depois Fix 3 (Major) e Fix 4 (Minor); re-rodar o sensor sobre M3, M8, M9, M10 e M15.
