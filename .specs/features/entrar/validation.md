# Entrar — Validation

**Spec**: `.specs/features/entrar/spec.md` (21 requisitos, ENT-01..ENT-21)
**Design**: `.specs/features/entrar/design.md` · **Tasks**: `.specs/features/entrar/tasks.md`
**Verifier**: sub-agente independente (autor ≠ verificador) · cobertura re-derivada do zero contra a spec, a cada iteração

| Iteração | Data | Range | Testes | Veredito |
|---|---|---|---|---|
| 1 | 2026-08-26 | `2f46d7ae..1dc4fe9` (17 commits) | 922 | ❌ **FAIL** — 10/21 ✅, 7 ❌ · sensor 11/16 |
| 2 | 2026-08-26 | `1dc4fe9..6f81b0c` (correções) | **945** | ✅ **PASS com ressalvas** — 16/21 ✅, 5 ⚠️, **0 ❌** · sensor **19/24** |

O histórico da iteração 1 está preservado **na íntegra** ao fim deste arquivo: o registro do que estava errado é o que prova que o sensor discrimina.

---

# Iteração 2 — 2026-08-26

**Diff range**: `1dc4fe9..6f81b0c` — commit `6f81b0c` "fix(entrar): fecha os gaps do Verifier independente"
(o range também contém `c01d520 docs(home): design da spec 04`, fora do escopo desta feature)

## Veredito: ✅ **PASS — com ressalvas**

**Checagem spec-anchored**: **16/21 ✅ · 5 ⚠️ parciais · 0 ❌**
**Gate**: `flutter analyze` zero issues · `flutter test` **945 passando, 0 falhando, 0 skipped** (922 → 945, +23)
**Sensor (P0-full, re-executado inteiro)**: **24 mutações · 19 mortas · 5 sobreviveram** — nenhuma sobrevivente é Blocker ou Major

O Blocker e os quatro Majors da iteração 1 estão **fechados e verificados empiricamente**: os quatro mutantes que antes atravessavam a suíte inteira agora morrem. O que sobra é Minor — um edge case afirmado por estrutura em vez de comportamento, uma geometria de AC não afirmada, e três meias-ACs que a iteração 1 marcou ⚠️ e que não entraram na lista numerada de fixes (falha minha de priorização, registrada abaixo).

**Terceira iteração não se justifica**: nada do que resta bloqueia UC-01 nem a spec 04. Ver §Ressalvas para o encaminhamento.

---

## Os 8 gaps da iteração 1 — conferidos um a um, no código

Não aceitei o resumo do implementador: cada item abaixo foi lido no diff e submetido a mutação.

| # | Gap da iteração 1 | Severidade | Correção | Prova empírica | Status |
|---|---|---|---|---|---|
| 1 | ENT-07/ENT-10 sem cobertura alguma | **Blocker** | `travaDeEnvio` (`Completer`) no duplo (`test/support/fake_autenticacao_repository.dart:46,89`) + grupo "o CTA fica inerte enquanto envia" (`test/features/entrar/presentation/pages/entrar_page_test.dart:252-330`) + "com o envio pendurado, um segundo submit não chama de novo" (`entrar_bloc_test.dart:196-221`) | **M10 e M11, que antes sobreviviam aos 922, agora morrem** | ✅ **Fechado** |
| 2 | ENT-04 (W-01) praticamente sem cobertura | Major | Arquivo novo `test/features/entrar/presentation/widgets/entrar_expandido_test.dart` (11 testes) + `EntrarExpandido.cardKey` (`lib/…/entrar_expandido.dart:45`) | **M15 (sombra 10→4) agora morre**; M20 (inverter o ramo responsivo) também morre | ✅ **Fechado** (ver ressalva R-2) |
| 3 | "navega para `/roles`" nunca composta | Major | Arquivo novo `test/features/entrar/entrar_fluxo_test.dart` — `abrirApp` + `enterText` + `tap`, pelos três caminhos, com par negativo | Ver §Cobertura, ENT-06 / ENT-14 AC2 / ENT-20 AC3 | ✅ **Fechado** |
| 4 | ENT-19 AC2 não discriminava | Major | `test/core/routing/route_error_page_tokens_test.dart:55` passou ao literal `'VOLTAR PRO INÍCIO'` e `:60-64` afirma o destino real | **M12 (`/roles` → `/catalogo`) agora morre** | ✅ **Fechado** |
| 5 | payload/conjunção no `trim` | Minor | `registros` com argumentos (`fake_autenticacao_repository.dart:38,87`) + `entrar_bloc_test.dart:65-75` afirma `email` **e** `senha` | **M21 (`emailNormalizado` sem `trim`) morre** | ✅ **Fechado** |
| 6 | Edge cases (900px, teclado, W-R4) | Minor | Grupo "edge cases da spec" (`entrar_page_test.dart:332-379`) | 900px ✅ real; **teclado ⚠️ raso — M22 sobreviveu**; W-R4 parcial | ⚠️ **Parcial** (ver R-1) |
| 7 | Guard de forma/sombra com alcance curto | Minor | `shape_and_shadow_guard_test.dart:15` passou de `lib/core/design_system` para `lib` | **M23 (canto arredondado injetado em `lib/features/entrar/`) morre nomeando o arquivo** — a guarda ampliada tem dentes de verdade | ✅ **Fechado** |
| 8 | Teste enganoso do bloc | Minor | `entrar_bloc_test.dart:302-317` agora `await assentar()` e afirma `ModoDeEntrada.cadastro` | M7 continua morrendo; o teste deixou de passar sob handler vazio | ✅ **Fechado** |

**Sobre a declaração de spec-precision de ENT-07 ("exibir estado de carregando")** — pedido explícito de julgamento: **é honesta, não é desculpa.** Três razões, verificadas: (a) o `reason` em `entrar_page_test.dart:293-299` declara o gap no lugar certo — junto da asserção que o congela, que é o padrão que L-002 instalou neste projeto; (b) a afirmação sobre o arquivo 02 confere — não há spinner, indicador de progresso nem `CircularProgressIndicator` em `lib/core/design_system/`, e §8 proíbe motion novo; (c) **a declaração não substitui asserção nenhuma**: o esmaecido é afirmado contra o token (`BoraBorders.opacidadeDesabilitado`, `entrar_page_test.dart:292`), e o `onPressed isNull` é afirmado à parte (`:279-286`). Declarar gap e ainda assim fixar o comportamento observável é o oposto de desculpa. Fica registrado como **SP-4** abaixo.

---

## Cobertura dos 21 requisitos — re-derivada (evidence-or-zero)

Só os requisitos cujo status **mudou** desde a iteração 1 aparecem com evidência detalhada; os demais foram reconferidos e mantêm a evidência já tabulada no histórico.

| Req | Iter. 1 | `file:line` + asserção (iteração 2) | Iter. 2 |
|---|---|---|---|
| ENT-02 | ⚠️ | AC4 completo: cor/fonte por `token_purity_guard_test.dart:20` (`lib/`) **e agora sombra/forma** por `shape_and_shadow_guard_test.dart:15` — `const String _diretorioDeLib = 'lib'`, com anti-vácuo em `:163-168`. M23 prova os dentes | ✅ **PASS** |
| ENT-04 | ❌ | `entrar_expandido_test.dart:48-53` — `EntrarExpandido findsOneWidget` + `EntrarCompacto findsNothing` (par de breakpoint em `:57-65`) · `:87-93` — `expect(cardDoFormulario(tester).deslocamentoDaSombra, EntrarExpandido.sombraDoCard)` + `expect(EntrarExpandido.sombraDoCard, 10)` · `:100-103` — `acento == BoraAccent.ink`, `corDaBorda == BoraColors.ink`, `larguraDaBorda == 2`, `fundo == BoraColors.white` · `:109-110` padding `EdgeInsets.all(30)` · `:118-121` largura 340 · `:129-133` os 5 literais de W-01 · `:139-146` tag e apresentação · `:77-78` marca em 92px / ls −3 | ⚠️ **Quase-PASS** — falta só "marca à **esquerda**, card à **direita**" (R-2) |
| ENT-06 | ❌ | `test/features/entrar/entrar_fluxo_test.dart:43-50` — dentro do roteador real: `expect(find.byKey(PlaceholderPage.keyFor('home')), findsOneWidget)` + `EntrarPage.pageKey findsNothing`, com **par negativo** em `:65-72` (credencial recusada ⇒ permanece em `/entrar` e mostra a mensagem) | ✅ **PASS** |
| ENT-07 | ❌ | `entrar_page_test.dart:279-286` — `expect(…BoraPrimaryButton….onPressed, isNull)` **durante** o envio pendurado · `:288-299` — `expect(…Opacity….opacity, BoraBorders.opacidadeDesabilitado)` contra o token · par ocioso em `:322-329` (`isNotNull` depois do envio) | ✅ **PASS** (com SP-4 declarado) |
| ENT-10 | ❌ | `entrar_page_test.dart:262-268` — dois `tap` com `pump` entre eles ⇒ `expect(autenticacao.chamadas, hasLength(1))` · bloc: `entrar_bloc_test.dart:212-217` — segundo `add` durante o envio ⇒ `hasLength(1)`, com `expect(bloc.state.enviando, isTrue)` em `:209` provando que o estado intermediário existe | ✅ **PASS** |
| ENT-14 | ❌ | AC1 inalterado ✅ · **AC2 fechado**: `entrar_fluxo_test.dart:86-91` — tocar "CONTINUAR COM GOOGLE" ⇒ Home · split de plataforma inalterado ✅ (M5 morre) · **AC3 "sem navegar" continua sem asserção** | ⚠️ **Parcial** (R-4) |
| ENT-19 | ❌ | AC2 fechado: `route_error_page_tokens_test.dart:55` — `tester.tap(find.text('VOLTAR PRO INÍCIO'))` (literal) · `:60-64` — `expect(find.byKey(PlaceholderPage.keyFor('home')), findsOneWidget)` + `RouteErrorPage.pageKey findsNothing`. M12 morre | ✅ **PASS** |
| ENT-20 | ❌ | AC3 fechado: `entrar_fluxo_test.dart:109-114` — alternar, preencher, tocar "CRIAR CONTA →" ⇒ Home. AC1 e AC4 inalterados ✅ | ✅ **PASS** |
| ENT-01, 05, 08, 09, 11, 12, 15, 16, 18, 21 | ✅ | reconferidos: evidência inalterada, mutações correspondentes (M1, M2, M3, M6, M9, M13, M14, M16) **continuam morrendo** | ✅ **PASS** |
| ENT-03 | ⚠️ | inalterado — os 8 literais ✅, **"na ordem de T-01"** segue sem asserção (`grep getTopLeft` em `test/features/entrar/` = vazio) | ⚠️ (R-3) |
| ENT-13 | ⚠️ | AC2 ✅ inalterado · **AC5** — `entrar_cadastro_test.dart:86-95` continua afirmando só a copy restaurada, não o e-mail preservado no sentido cadastro→entrar | ⚠️ (R-5) |
| ENT-17 | ⚠️ | inalterado — AC3 ✅; AC4 segue afirmado em duas metades (`app_test.dart:29` × `firebase_autenticacao_repository_test.dart:77-80`) | ⚠️ (aceito) |

**Placar**: 16 ✅ · 5 ⚠️ · **0 ❌** (era 10 ✅ · 4 ⚠️ · 7 ❌)

### Edge cases

| Edge case | Iter. 2 |
|---|---|
| Duplo toque ⇒ uma autenticação | ✅ **Fechado** — `entrar_page_test.dart:262-268` |
| E-mail aparado antes do envio (payload) | ✅ **Fechado** — `entrar_bloc_test.dart:65-75` afirma o **valor**; M21 morre |
| Cruzar 900px preservando texto e modo | ✅ **Fechado** — `entrar_page_test.dart:334-357`: redimensiona **depois** do `pumpWidget` e afirma o texto do controller **e** o modo (`'CRIAR CONTA →'`) |
| Teclado cobre o CTA ⇒ rola sem overflow | ⚠️ **Raso** — `entrar_page_test.dart:359-365` afirma só `find.byType(SingleChildScrollView), findsOneWidget`. **M22 (trocar por `NeverScrollableScrollPhysics`) sobreviveu**: o teste prova que existe um scroll view, não que ele rola (R-1) |
| Sem scroll horizontal (W-R4) | ⚠️ **Parcial** — `entrar_page_test.dart:367-377`: `expect(scroll.scrollDirection, Axis.vertical)` é tautológico (é o default), mas o `expect(tester.takeException(), isNull)` em 1180×800 **de fato** pegaria um `RenderFlex overflowed`. Metade real, metade decorativa |
| Firebase não inicializou / senha de 6 chars | ✅ inalterados |

---

## Discrimination Sensor — iteração 2 (tier P0, suíte inteira re-executada)

Método idêntico: **cópia temporária do arquivo**, nunca `git stash` (a árvore é compartilhada). `git status --porcelain` confirmado vazio após **cada** mutação.

### As 16 da iteração 1, re-executadas

| # | Alvo | Iter. 1 | Iter. 2 |
|---|---|---|---|
| M1 | `guarda_de_sessao.dart:31` — inverte `!temSessao` | ✅ Morto | ✅ Morto |
| M2 | `guarda_de_sessao.dart:38` — prefixo vira igualdade exata | ✅ Morto | ✅ Morto |
| M3 | `falha_de_codigo.dart:52` — tira `INVALID_LOGIN_CREDENTIALS` | ✅ Morto | ✅ Morto |
| M4 | `falha_de_codigo.dart:41` — encolhe `codigosDeCancelamento` | ❌ Sobreviveu | ❌ **Sobreviveu — declarado** (inalterado, ver §Limites) |
| M5 | `metodo_de_google.dart:30` — inverte `isWeb` | ✅ Morto | ✅ Morto |
| M6 | `validacao_de_credenciais.dart:46` — `<` → `<=` | ✅ Morto | ✅ Morto |
| M7 | `entrar_bloc.dart:38` — `ModoAlternado` não limpa | ✅ Morto | ✅ Morto |
| M8 | `entrar_bloc.dart:74` — ignora o modo | ✅ Morto | ✅ Morto |
| M9 | `firebase_autenticacao_repository.dart:104` — `rethrow` | ✅ Morto | ✅ Morto |
| **M10** | `formulario_de_entrada.dart:71` — CTA nunca inerte | ❌ **Sobreviveu (922/922)** | ✅ **MORTO** — `entrar_page_test.dart` "durante o envio o CTA fica desabilitado e esmaecido" |
| **M11** | `entrar_bloc.dart:51` — remove a guarda de envio | ❌ **Sobreviveu (922/922)** | ✅ **MORTO** |
| **M12** | `route_error_page.dart:65` — destino `/roles` → `/catalogo` | ❌ **Sobreviveu** | ✅ **MORTO** — "o CTA de volta leva para a raiz do app" |
| M13 | `app.dart:27` — remove o tema | ✅ Morto | ✅ Morto |
| M14 | `entrar_state.dart:43` — `mostraFalha` inclui `cancelada` | ✅ Morto | ✅ Morto |
| **M15** | `entrar_expandido.dart:34` — sombra 10 → 4 | ❌ **Sobreviveu (922/922)** | ✅ **MORTO** — "sombra de 10px, e não a do CTA" |
| M16 | `formulario_de_entrada.dart:61` — senha legível | ✅ Morto | ✅ Morto |

**Os 4 sobreviventes não declarados da iteração 1 morreram todos.** O único sobrevivente remanescente do conjunto original é M4, que já era declarado.

### As 8 novas — apontadas contra as próprias correções

| # | `file:line` | Mutação | Testes | Morto? |
|---|---|---|---|---|
| M17 | `formulario_de_entrada.dart:78` | botão do Google nunca inerte (`onPressed: aoEntrarComGoogle`) | suíte inteira | ❌ Sobreviveu *(isolado)* |
| M18 | `entrar_bloc.dart:90` | remove `if (state.enviando) return;` de `_aoSubmeterGoogle` | suíte inteira | ❌ Sobreviveu *(isolado)* |
| M19 | M17 **+** M18 juntas | Google sem guarda nenhuma, nos dois níveis | suíte inteira | ✅ **Morto** — "o botão do Google também fica inerte durante o envio" |
| M20 | `entrar_page.dart:76` | inverte o ramo responsivo (`modo == compact` → `!=`) | suíte inteira | ✅ Morto |
| M21 | `validacao_de_credenciais.dart:50` | `emailNormalizado` deixa de aparar | suíte inteira | ✅ Morto |
| M22 | `entrar_compacto.dart:37` | scroll view com `NeverScrollableScrollPhysics` | `test/features/entrar/` | ❌ **Sobreviveu** → R-1 |
| M23 | `divisor_ou.dart` | injeta `BorderRadius.circular(8)` num arquivo de feature | `test/core/design_system/architecture/` | ✅ **Morto** — a guarda ampliada nomeia o infrator |
| M24 | `entrar_expandido.dart:52` | `textDirection: TextDirection.rtl` no `Row` — troca os lados das colunas | suíte inteira | ❌ **Sobreviveu** → R-2 |

**Profundidade**: P0-full · **Resultado: 24 mutações, 19 mortas, 5 sobreviventes**

**Sobre M17/M18**: os dois guardas do caminho Google são **redundantes** — cada um sozinho já impede o segundo login, então mutação única não discrimina. M19 prova que o comportamento **está** coberto: apagar os dois quebra a suíte. Não é buraco de cobertura do requisito; é uma observação de que o teste `entrar_page_test.dart:307-320` afirma o efeito agregado (`chamadas hasLength(1)`) e **não** o `onPressed isNull` do botão secundário, apesar do nome prometer "fica inerte". O CTA primário tem as duas asserções; o Google, só a de efeito.

---

## Ressalvas remanescentes (ranqueadas) — nenhuma é Blocker ou Major

| # | Ressalva | Requisito | `file:line` | O que falta |
|---|---|---|---|---|
| **R-1** | Edge case do teclado fechado com **teste estrutural**, não comportamental | edge case da spec | `test/features/entrar/presentation/pages/entrar_page_test.dart:359-365` | O teste afirma que **existe** um `SingleChildScrollView`; trocar sua física por `NeverScrollableScrollPhysics` sobrevive (M22). Falta montar com `viewInsets` de teclado (ou altura reduzida) e provar que o CTA fica alcançável — `scrollUntilVisible` + `takeException()` nulo |
| **R-2** | ENT-04 AC2 diz "marca à **esquerda** … card à **direita**"; os lados não são afirmados | ENT-04 | `test/features/entrar/presentation/widgets/entrar_expandido_test.dart:44-80` | Tudo o mais do card está afirmado contra token, mas **M24 (inverter os lados via `rtl`) sobrevive aos 945**. Falta uma asserção de posição: `tester.getTopLeft(find.byType(MarcaBora)).dx < tester.getTopLeft(find.byKey(EntrarExpandido.cardKey)).dx` |
| **R-3** | ENT-03 AC1 diz "na **ordem** de T-01"; a ordem não é afirmada | ENT-03 | `entrar_page_test.dart:44-88` | Os 8 literais estão ✅; a sequência vertical não. Uma asserção de `dy` crescente entre marca → tag → apresentação → campos → CTA → divisor → Google → rodapé fecharia |
| **R-4** | ENT-14 AC3 diz "sem navegar"; só "sem erro" e "ocioso" são afirmados | ENT-14 | `entrar_page_test.dart:224-238` (fora do roteador) | Falta o caso no `entrar_fluxo_test.dart`: cancelar dentro do roteador ⇒ `EntrarPage.pageKey` continua montada |
| **R-5** | ENT-13 AC5 diz "voltar ao modo entrar **preservando o e-mail**" | ENT-13 | `entrar_cadastro_test.dart:86-95` | Só a copy restaurada é afirmada. Falta `expect(…controller?.text, 'rafa@bora.app')` no sentido cadastro→entrar (o sentido inverso já está em `:105-110`) |
| **R-6** | Botão do Google: efeito afirmado, estado do widget não | ENT-07 | `entrar_page_test.dart:307-320` | Acrescentar `expect(…BoraSecondaryButton….onPressed, isNull)` durante o envio, como o CTA primário já tem — mataria M17 isoladamente |
| **R-7** | SP-2/SP-3 (copy inventada) seguem **sem declaração** | — | `lib/features/entrar/presentation/entrar_textos.dart:51-54,68-71` | `grep SPEC_PRECISION entrar_textos.dart` = vazio. Nove strings sem origem na spec-fonte, tratadas como se tivessem |
| **R-8** | `tasks.md` sem `**Status**` em T5..T16 | — | `.specs/features/entrar/tasks.md` | 5 linhas `**Status**` para 16 tasks. Rastreabilidade task↔commit só no git |
| **R-9** | Conferências manuais de T6/T13/T14/T15 (skill `run`) | ENT-14 / A-10 | — | Sem evidência de execução. Registrado, como T6 exigia, que os 4 `codigosDeCancelamento` seguem **por verificar** e que o Google ponta-a-ponta depende de conferência manual no web |

**Nota de honestidade sobre a iteração 1**: R-3, R-4 e R-5 apareceram na tabela de ACs da iteração 1 como ⚠️, mas **não** entraram na lista numerada de Fix Plans. O implementador corrigiu os 8 itens numerados — corrigiu o que foi pedido. A omissão é do relatório anterior, não da execução.

**Encaminhamento sugerido**: R-1 a R-6 cabem num único commit de teste (~40 linhas, nenhuma mudança de produção); R-7 e R-8 são registro documental. Nada disso justifica uma terceira iteração de fix→re-verify — vale como *cleanup* antes de a spec 04 encostar em `AppShell`/`PlaceholderPage`, que é quando ENT-04 e ENT-03 voltam a ser tocados.

---

## Limites declarados — reconferidos

**1. `codigosDeCancelamento`** — inalterado e **continua honesto**. `lib/core/autenticacao/dados/falha_de_codigo.dart:31-40` declara que os quatro códigos não foram verificados empiricamente e que o teste cobre o **mecanismo**; `test/core/autenticacao/dados/falha_de_codigo_test.dart:59-63` itera sobre a própria constante (auto-referencial por construção), com anti-vácuo em `:74-81`. **M4 sobrevive de novo — como esperado e como declarado.** `'popup-closed-by-user'` segue ancorado por literal em `firebase_autenticacao_repository_test.dart:193`. **Registrado formalmente, como T6 exigia: a captura do código real com a skill `run` não foi feita nas duas iterações; os quatro códigos permanecem por verificar.**

**2. `SPEC_PRECISION_GAP` em `UsuarioLogado.inicial`** — inalterado, honesto, com correção de origem entregue em T5. Ver histórico.

**3. ENT-07 "coberto na UI, não no bloc"** — era **falso** na iteração 1 e agora é **verdadeiro e provado nos dois níveis**: a UI tem asserção própria (`onPressed isNull` + opacidade contra token) e o bloc tem a sua (segundo `add` com envio pendurado). M10 e M11 morrem separadamente.

**4. SP-4 — "exibir estado de carregando" (ENT-07 AC5)** — spec-precision gap **novo e declarado nesta iteração**, em `entrar_page_test.dart:293-299`. A spec pede "estado de carregando" sem definir a forma; o arquivo 02 não tem indicador de progresso e §8 proíbe inventar motion. O implementado — botão inerte + `BoraBorders.opacidadeDesabilitado` — é afirmado contra o token. **Julgado honesto.**

---

## Code Quality — iteração 2

| Princípio | Status |
|---|---|
| Nada além do pedido | ✅ — a única mudança de produção é `EntrarExpandido.cardKey` (`entrar_expandido.dart:39-46`), com justificativa correta: o input também é `BoraSurface` e um finder por tipo afirmaria o widget errado em silêncio |
| Fronteira de arquivos respeitada | ✅ — 8 arquivos tocados, 7 deles de teste |
| Nenhum teste existente enfraquecido | ✅ — 922 → **945** (+23), zero skips, zero deleções. O único teste reescrito (`entrar_bloc_test.dart:302`) ficou **mais** forte |
| Guarda ampliada não relaxa nada | ✅ — `shape_and_shadow_guard_test.dart` passou de `lib/core/design_system` a `lib/`: superconjunto estrito, com o anti-vácuo preservado. M23 confirma |
| Asserções contra **token**, copy contra **literal** | ✅ — `BoraAccent.ink`, `BoraColors.ink/white`, `BoraBorders.opacidadeDesabilitado`, `MarcaBora.tamanhoExpandido` de um lado; `'VOLTAR PRO INÍCIO'`, `'COMEÇAR →'`, `'🌐 ENTRAR COM GOOGLE'` do outro. A troca de `RouteErrorPage.voltar` pelo literal corrige a violação apontada |
| Regra payload/conjunção | ✅ — `ChamadaDeAutenticacao` guarda `email` e `senha`; `entrar_bloc_test.dart:65-75` e `entrar_expandido_test.dart:160-161` afirmam **valores** |
| Todo teste mapeia a AC / edge / done-when | ⚠️ — R-1 e o `scrollDirection` de W-R4 são estruturais; o resto mapeia |
| Correção introduziu asserção frágil? | ⚠️ — duas: `expect(scroll.scrollDirection, Axis.vertical)` (`entrar_page_test.dart:374`) é tautológico (é o default do widget) e `expect(EntrarExpandido.larguraDoCard, 340)` / `expect(EntrarExpandido.sombraDoCard, 10)` são asserções sobre a constante. Estas últimas **não** são frágeis por si — vêm em par com a asserção de que o widget de fato recebe a constante (`:87`, `:118`), o que é o padrão certo: uma prende ao valor da spec, a outra prende ao uso |

---

## Gate Check — iteração 2

- **Comando (Build)**: `flutter analyze && flutter test`
- **`flutter analyze`**: `No issues found! (ran in 1.4s)`
- **`flutter test`**: `00:14 +945: All tests passed!`
- **Antes da feature**: 742 · **iteração 1**: 922 · **iteração 2**: **945** · delta total **+203**
- **Skipped**: nenhum · **Failures**: nenhuma
- **Árvore após as 24 mutações**: `git status --porcelain` vazio

---

## Requirement Traceability — final

| Requisito | Iteração 1 | Iteração 2 |
|---|---|---|
| ENT-01 | ✅ Verified | ✅ Verified |
| ENT-02 | ⚠️ Parcial | ✅ **Verified** |
| ENT-03 | ⚠️ Parcial | ⚠️ Parcial — R-3 (ordem) |
| ENT-04 | ❌ Needs Fix | ⚠️ **Quase-Verified** — R-2 (lados das colunas) |
| ENT-05 | ✅ Verified | ✅ Verified |
| ENT-06 | ❌ Needs Fix | ✅ **Verified** |
| ENT-07 | ❌ Needs Fix | ✅ **Verified** (SP-4 declarado) |
| ENT-08 | ✅ Verified | ✅ Verified |
| ENT-09 | ✅ Verified | ✅ Verified |
| ENT-10 | ❌ Needs Fix | ✅ **Verified** |
| ENT-11 | ✅ Verified | ✅ Verified |
| ENT-12 | ✅ Verified | ✅ Verified |
| ENT-13 | ⚠️ Parcial | ⚠️ Parcial — R-5 (AC5) |
| ENT-14 | ❌ Needs Fix | ⚠️ Parcial — AC1/AC2 ✅, R-4 ("sem navegar") |
| ENT-15 | ✅ Verified | ✅ Verified |
| ENT-16 | ✅ Verified | ✅ Verified |
| ENT-17 | ⚠️ Parcial | ⚠️ Parcial — AC4 por composição (aceito) |
| ENT-18 | ✅ Verified | ✅ Verified |
| ENT-19 | ❌ Needs Fix | ✅ **Verified** |
| ENT-20 | ❌ Needs Fix | ✅ **Verified** |
| ENT-21 | ✅ Verified | ✅ Verified |

---

## Summary — iteração 2

**Overall**: ✅ **Ready, com ressalvas Minor**

**Spec-anchored**: 16/21 ✅ · 5 ⚠️ · **0 ❌** · 4 spec-precision gaps declarados (SP-1, SP-4 no código; SP-2/SP-3 pendentes de declaração — R-7)
**Sensor**: **19/24 mortas** — os 4 sobreviventes não declarados da iteração 1 morreram; restam 1 declarado (M4), 2 redundantes cobertos em conjunto (M17/M18 ⇒ M19 morre) e 2 Minor reais (M22, M24)
**Gate**: 945 passando, 0 falhando, 0 skipped, `analyze` limpo

**O que mudou de verdade**: a feature deixou de ter mecanismo invisível. Na iteração 1 quatro comportamentos podiam ser apagados sem que nada acusasse — o CTA que se desabilita, a guarda de envio, a sombra do card e o destino do CTA de erro. Todos os quatro agora têm sensor. O padrão que produziu aqueles gaps — *asserção de "a chamada aconteceu" ou "saiu da tela", nunca do valor/estado que a spec define* — foi corrigido na raiz: o duplo passou a guardar argumentos, o `Completer` tornou o estado intermediário observável, e as asserções de destino passaram a nomear o destino.

**O que continua aberto**: cinco meias-ACs e um edge case afirmado por estrutura. Nenhum bloqueia UC-01. R-1 a R-6 são ~40 linhas de teste sem mudança de produção.

**Next steps**: fechar R-1..R-6 num commit de teste antes da spec 04 (que reencosta em ENT-03/ENT-04 via `AppShell`); registrar R-7 e R-8; manter R-9 como pendência de conferência manual declarada. **Não** abrir iteração 3 do ciclo fix→re-verify.

---
---

## Iteração 3 — ressalvas R-1 e R-2 fechadas (2026-08-26)

Fechadas **pelo implementador**, depois do PASS da iteração 2, e cada uma com
a mutação correspondente confirmada:

| Ressalva | Correção | Mutação | Resultado |
|---|---|---|---|
| **R-1** — teclado provado por teste estrutural | `entrar_page_test.dart` — viewport de 300px (onde o CTA nasce **fora** da área visível, afirmado como pré-condição), `drag`, e a prova é o **movimento**: `depois < antes` e `depois < altura` | **M22** — `NeverScrollableScrollPhysics` no `SingleChildScrollView` | ✅ **morre** |
| **R-2** — lados de W-01 não afirmados | `entrar_expandido_test.dart` — `getTopLeft(MarcaBora).dx < getTopLeft(cardKey).dx`, mais o gap de 74px entre as colunas | **M24** — `textDirection: TextDirection.rtl` no `Row` | ✅ **morre** |

**Nota sobre a primeira tentativa de R-1**, registrada porque o erro é
instrutivo: a correção inicial usava viewport de 420px e afirmava
`bottom <= 420`. **M22 sobreviveu de novo** — diagnóstico mostrou o CTA em
`bottom=423`, três pixels fora, então a asserção quase passava sem rolagem
nenhuma. Trocar "está visível" por "**moveu**" é o que deu dentes ao teste.

**Suíte: 947** · `flutter analyze` limpo · árvore restaurada e verificada após
cada mutação.

**Sensor consolidado: 24 mutações · 21 mortas · 3 sobreviventes** — M4
(declarada: `codigosDeCancelamento`, auto-referencial por construção e
registrada como não verificada empiricamente) e M17/M18, redundantes entre si
e cobertas em conjunto por M19.

---

# Histórico — Iteração 1 (2026-08-26) — ❌ FAIL

**Data**: 2026-08-26
**Spec**: `.specs/features/entrar/spec.md` (21 requisitos, ENT-01..ENT-21)
**Design**: `.specs/features/entrar/design.md` · **Tasks**: `.specs/features/entrar/tasks.md`
**Diff range**: `2f46d7ae7565c71fad3d609658280c53ded6a9f8..1dc4fe9` — 17 commits, 58 arquivos
**Verifier**: sub-agente independente (autor ≠ verificador) · cobertura re-derivada do zero contra a spec

## Veredito: ❌ **FAIL**

**Checagem spec-anchored**: 10/21 requisitos ✅ · 4 ⚠️ parciais · **7 ❌ com gap**
**Gate**: `flutter analyze` zero issues · `flutter test` **922 passando, 0 falhando, 0 skipped**
**Sensor (tier P0)**: **16 mutações injetadas · 11 mortas · 5 sobreviveram** (1 delas declarada e honesta)

O FAIL não vem do gate — vem de **ENT-07/ENT-10 não terem cobertura em lugar nenhum** (as duas mutações que apagam o mecanismo passam pelos 922 testes), de **ENT-04 (W-01) ter só duas asserções num layout inteiro**, e de **a metade "navega para `/roles`" de ENT-06/ENT-14/ENT-20 nunca ser composta em teste**.

---

## Task Completion

| Task | Status | Notas |
|---|---|---|
| T1–T4 | ✅ Done | `Status` registrado no `tasks.md`; commits `f6a1a30`, `499b4d3`, `3834323`, `3d26de9` |
| T5–T16 | ✅ Commitadas / ⚠️ sem `Status` no `tasks.md` | Os 12 commits existem no range, mas nenhuma das tasks T5..T16 teve a linha `**Status**` preenchida. A rastreabilidade task↔commit ficou só no histórico do git |
| T6 (`run` — captura do código real de cancelamento) | ⚠️ Não executada | O done-when previa capturar o `code` real com emulador + Chrome, **ou** registrar aqui que ficou por verificar. Registrado abaixo, §Limites declarados |
| T13/T14/T15 (`run` — conferência visual) | ⚠️ Sem evidência | Nenhum artefato, nota ou registro no repositório indica que a conferência a olho em `Pixel_10` / Chrome 1180×800 foi feita |

---

## Critérios de aceite — evidência ancorada na spec

Regra: **evidence-or-zero**. Critério sem `file:line` + expressão de asserção conta como NÃO coberto.
Caminhos relativos à raiz do repositório.

### P1-1 — O app veste os tokens

| Critério | Resultado que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| ENT-01 AC1 — `MaterialApp.router` recebe `theme: boraTheme()` | o mesmo `ThemeData` da spec 01, sem valor redeclarado em `lib/app.dart` | impl `lib/app.dart:27` — `theme: boraTheme()` · `test/app_test.dart:84` — `expect(tema.scaffoldBackgroundColor, BoraColors.paper)` | ✅ PASS (mutação 13 morta) |
| ENT-01 AC2 — tela sob o roteador lê `scaffoldBackgroundColor`, `fontFamily` e `ColorScheme` do tema | os valores de `boraTheme()`, sem `Theme()` local | `test/app_test.dart:91` — `expect(tema.textTheme.bodyLarge?.fontFamily, BoraTextStyles.familiaUi)` · `:93` — `titleLarge?.fontFamily == BoraTextStyles.familiaDisplay` · `:102-105` — `colorScheme.primary/onPrimary/surface/onSurface` contra os tokens | ✅ PASS |
| ENT-02 AC3 — título da aba continua `'bora — a conta do rolê'` | literal de W-R5 | `test/app_test.dart:116` — `expect(app.title, 'bora — a conta do rolê')` (literal, não constante) · duplicado em `test/core/routing/app_router_publico_test.dart:76` | ✅ PASS |
| ENT-02 AC4 — `lib/app.dart` com **zero** literal de cor, `fontFamily` e **sombra** | varredura acusa qualquer um dos três | cor + fonte: `test/core/design_system/architecture/token_purity_guard_test.dart:20` — varre `_diretorioDeLib = 'lib'` (`Color(0x`, `Colors.*`, `fontFamily: '…'`). **Sombra: sem cobertura** — `test/core/design_system/architecture/shape_and_shadow_guard_test.dart:15` limita o escopo a `lib/core/design_system` | ⚠️ **Parcial** — dois dos três termos do AC varridos. Sem violação viva (`grep BoxShadow\|BorderRadius lib/app.dart lib/features/entrar/` = vazio), mas a guarda é mais estreita do que o AC afirma |

### P1-2 — Entrar com e-mail e senha

| Critério | Resultado que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| ENT-03 AC1 — T-01 compacto: logo com ponto vermelho | "BORA." com o ponto no acento | `test/features/entrar/presentation/widgets/marca_bora_test.dart:26` — `expect(_logo(tester).textSpan!.toPlainText(), 'BORA.')` · `:34` — `_logo(...).style?.color == BoraColors.ink` · `:41` — `_ponto(...).style?.color == BoraColors.primary` | ✅ PASS |
| ENT-03 AC1 — tag rotacionada −2° | `BoraRotatedTag.grausAEsquerda` (−2°) | `test/features/entrar/presentation/pages/entrar_page_test.dart:83` — `expect(tag.aEsquerda, isTrue)` · `:84` — `expect(tag.anguloEmRadianos, BoraRotatedTag.radianosDe(-2))` | ✅ PASS |
| ENT-03 AC1 — os oito literais de T-01 | copy literal | `entrar_page_test.dart:46` `'A CONTA DO ROLÊ, RESOLVIDA'` · `:48-52` parágrafo completo · `:59` `'seu e-mail'` · `:60` `'senha'` · `:61` `'COMEÇAR →'` · `:62` `'OU'` · `:64` `'CONTINUAR COM GOOGLE'` · `:74` `'Novo por aqui? '` · `:75` `'CRIAR CONTA'` — todos `find.text('<literal>')`, nunca contra `EntrarTextos` | ✅ PASS |
| ENT-03 AC1 — **"na ordem de T-01"** | ordem vertical dos elementos | — nenhuma asserção de ordem/posição na árvore | ⚠️ **Gap de cobertura** — a ordem é parte literal do AC e não é afirmada |
| ENT-04 AC2 — W-01: duas colunas, marca à esquerda, **card branco** à direita | layout de duas colunas do arquivo 06 | — nenhuma asserção de layout: nada afirma `EntrarExpandido` montado, `MarcaBora.expandida` na árvore da página, a coluna dupla, ou o card. `entrar_expandido.dart` não tem arquivo de teste (`test/features/entrar/presentation/widgets/` só tem `marca_bora_test.dart`) | ❌ **GAP** |
| ENT-04 AC2 — card com `BoraSurface`, sombra 10px, borda 2px `ink` (T14 done-when) | `deslocamentoDaSombra: 10`, `BoraAccent.ink`, afirmados **contra o token** | impl `lib/features/entrar/presentation/widgets/entrar_expandido.dart:34,82-84` — **nenhuma asserção**. **Mutação 15 (`sombraDoCard` 10 → 4) sobreviveu aos 922 testes** | ❌ **GAP** |
| ENT-04 AC2 — literais de W-01 no viewport expandido | label "ENTRAR", "COMEÇAR →", "🌐 ENTRAR COM GOOGLE", "Novo por aqui? CRIAR CONTA" | `entrar_page_test.dart:301` — `expect(find.text('ENTRAR'), findsOneWidget)` · `:288` — `'🌐 ENTRAR COM GOOGLE'` · `:290-291` — par de plataforma (`'CONTINUAR COM GOOGLE'` → `findsNothing`). **"COMEÇAR →" e "Novo por aqui? CRIAR CONTA" não são afirmados no expandido** | ⚠️ **Parcial** (2 de 4 literais) |
| ENT-04 — sem scroll horizontal (W-R4, T14 done-when) | nenhum overflow horizontal em 1180×800 | — sem asserção | ⚠️ **Gap de cobertura** |
| ENT-05 AC3 — foco pinta a borda de vermelho | borda passa de `ink` para o acento vermelho do token | `entrar_page_test.dart:268` — `expect((decoracaoDoPrimeiroCampo().border! as Border).top.color, BoraColors.ink)` (sem foco) · `:276` — `… == BoraColors.primary` (com foco). Par discriminante contra o **token** | ✅ PASS |
| ENT-06 AC4 — credenciais válidas: **autenticar** | chama `entrarComEmailESenha` com o par digitado | `entrar_page_test.dart:111` — `expect(autenticacao.chamadas, ['entrarComEmailESenha'])` · adaptador com payload: `test/core/autenticacao/dados/firebase_autenticacao_repository_test.dart:125-130` — `verify(() => auth.signInWithEmailAndPassword(email: 'rafa@bora.app', password: 'segredo')).called(1)` | ✅ PASS |
| ENT-06 AC4 — credenciais válidas: **navegar para `/roles`** | rota corrente vira `/roles` (Independent Test da spec: "preencher os inputs, tocar COMEÇAR → e afirmar que a rota corrente virou `/roles`") | — **nenhum teste compõe a cadeia**. As duas metades existem separadas e nunca se encontram: `entrar_page_test.dart:132` afirma que a tela **não** navega (montada sem roteador), e `test/app_test.dart:68` provoca a sessão por `autenticacao.mudarSessao(sessaoDeTeste)`, **pulando o formulário**. Nenhum arquivo usa `abrirApp` + `enterText` juntos (`grep -l abrirApp test/ \| xargs grep -l enterText` → vazio) | ❌ **GAP** |
| ENT-07 AC5 — durante a autenticação o CTA **exibe estado de carregando** | estado de carregando visível | impl: nenhum indicador — o único efeito é `onPressed: null`, que rende opacidade .7 no `BoraPrimaryButton`. Sem asserção | ❌ **GAP** (também de implementação: "carregando" ficou reduzido a "desabilitado") |
| ENT-07 AC5 / ENT-10 — **não aceitar novo acionamento** | duplo toque executa **uma** autenticação | impl `lib/features/entrar/presentation/widgets/formulario_de_entrada.dart:71` — `onPressed: estado.enviando ? null : aoSubmeter` · impl `lib/features/entrar/presentation/bloc/entrar_bloc.dart:51` — `if (state.enviando) return;`. **Nenhuma asserção em nenhum dos dois.** `test/features/entrar/presentation/bloc/entrar_bloc_test.dart:158-166` declara por escrito que a garantia "está afirmada no teste de widget de T13" — **esse teste não existe**. Empírico: **mutações 10 e 11 sobreviveram aos 922 testes** | ❌ **GAP — o mais grave** |
| ENT-21 AC6 — senha obscurecida | texto digitado nunca legível | `entrar_page_test.dart:97` — `expect(campos[1].obscureText, isTrue)` com par `:96` — `expect(campos[0].obscureText, isFalse)` · componente: `test/core/design_system/components/bora_text_field_test.dart:186` — `expect(tester.widget<TextField>(…).obscureText, isTrue)` e `:202` — `isFalse` por omissão | ✅ PASS (mutação 16 morta) |

### P1-3 — Entrar com Google

| Critério | Resultado que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| ENT-14 AC1 — botão presente com a copy da plataforma | "CONTINUAR COM GOOGLE" compacto, "🌐 ENTRAR COM GOOGLE" expandido (A-05) | `entrar_page_test.dart:64` (compacto, literal) · `:288` (expandido, literal) · `:290-291` par de plataforma | ✅ PASS |
| ENT-14 AC2 — Google conclui → **navega para `/roles`** | mesmo destino do e-mail/senha | `entrar_page_test.dart:120` — `expect(autenticacao.chamadas, ['entrarComGoogle'])` afirma só a chamada. **Nenhum teste leva o botão do Google até `/roles`** | ❌ **GAP** (mesma composição não feita de ENT-06) |
| ENT-14 AC3 — cancelar → estado ocioso, **sem erro** e **sem navegar** | nada de mensagem, rota inalterada | sem erro: `entrar_page_test.dart:229-234` — `expect(find.byKey(FormularioDeEntrada.mensagemDeFalhaKey), findsNothing)` ✅ · ocioso: `entrar_bloc_test.dart:206-226` (loop sobre `FalhaDeAutenticacao.values`, inclui `cancelada`) — `expect(bloc.state.enviando, isFalse)` ✅ · `entrar_bloc_test.dart:235-240` — `expect(bloc.state.mostraFalha, isFalse)` ✅ (mutação 14 morta). **"sem navegar": sem asserção** — o teste monta a tela fora do roteador | ⚠️ **Parcial** |
| ENT-14 — split de plataforma (T6) | web → `signInWithPopup`; mobile → `signInWithProvider` | `test/core/autenticacao/dados/metodo_de_google_test.dart:8` `popup` · `:17` `provider` · `:26-31` anti-vácuo `isNot` · adaptador: `firebase_autenticacao_repository_test.dart:172-173` — `verify(signInWithPopup).called(1)` + `verifyNever(signInWithProvider)` e `:185-186` o inverso | ✅ PASS (mutação 5 morta) |
| ENT-14 — cancelamento vira `cancelada`, não erro | `FalhaDeAutenticacao.cancelada` | `firebase_autenticacao_repository_test.dart:195-198` — `expectLater(repositorio.entrarComGoogle(), throwsA(FalhaDeAutenticacao.cancelada))` com `code: 'popup-closed-by-user'` literal | ✅ PASS — **mecanismo**; a lista de códigos não (ver §Limites declarados) |

### P1-4 — A sessão manda na navegação

| Critério | Resultado que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| ENT-15 AC1 — `/roles/**` sem sessão → `/entrar` | destino `/entrar` | `test/core/routing/guarda_de_sessao_test.dart:30-34` — `expect(guardaDeSessao(rota: rota, temSessao: false), Routes.entrar)` sobre as **7** rotas protegidas (`:6-14`) · `:106-113` prefixo por segmento (`/rolesiando` passa) · integração: `test/app_test.dart:37` — `expect(find.byKey(EntrarPage.pageKey), findsOneWidget)` + `:42` `Home findsNothing` | ✅ PASS (mutações 1 e 2 mortas) |
| ENT-16 AC2 — `/entrar` com sessão → `/roles` | destino `/roles` | `guarda_de_sessao_test.dart:46` — `expect(guardaDeSessao(rota: Routes.entrar, temSessao: true), Routes.roles)` · integração: `test/app_test.dart:72` — `expect(find.byKey(PlaceholderPage.keyFor('home')), findsOneWidget)` após a sessão começar | ✅ PASS |
| ENT-17 AC3 — `/c/:codigo`, `/erro`, `/catalogo` abrem com **e** sem sessão | `null` (sem desvio) nos dois estados | `guarda_de_sessao_test.dart:62` e `:67-72` — loop sobre `_rotasLivres` (`:16-24`, inclui rota inexistente) nos **dois** estados · `:76` qualquer código de convite · integração: `app_router_publico_test.dart:38-39` (`/c/rafa18` sem sessão não cai em `/entrar` nem no erro) · `app_router_catalogo_test.dart:23` · `route_error_page_tokens_test.dart:71` | ✅ PASS |
| ENT-17 AC4 — reabrir com sessão ativa cai direto em `/roles` | Home, sem passar por `/entrar` | `test/app_test.dart:29` — `expect(find.byKey(PlaceholderPage.keyFor('home')), findsOneWidget)` com `sessao: sessaoDeTeste` · persistência: `firebase_autenticacao_repository_test.dart:77-80` — `expect(repositorio.sessaoAtual, const UsuarioLogado(id:'u1', email:'rafa@bora.app', nome:'Rafa'))` a partir de `_auth.currentUser` na construção (`firebase_autenticacao_repository.dart:27`) | ⚠️ **Parcial** — as duas metades (SDK persiste × app abre na Home) são afirmadas separadas; "reabertura" real não é simulável em `flutter test`. Aceitável, mas é composição inferida, não afirmada |
| ENT-18 AC5 — sessão termina com rota de festa montada → `/entrar` | redirect reavaliado | `test/app_test.dart:52-60` — `autenticacao.mudarSessao(null)` → `expect(find.byKey(EntrarPage.pageKey), findsOneWidget)` · ponte: `test/core/routing/go_router_refresh_stream_test.dart:22` — `expect(avisos, 2)` e `:35-40` — `expect(avisos, 0)` após `dispose` | ✅ PASS |

### P1-5 — Erro não trava a tela

| Critério | Resultado que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| ENT-08 AC1 — e-mail inválido / senha < 6 → validação inline, **sem** chamar o repositório | mensagem visível + zero chamadas | domínio: `test/features/entrar/domain/validacao_de_credenciais_test.dart:22` `ErroDeEmail.formato` (5 formas) · `:27` espaço no meio · `:31-32` domínio com ponto nas pontas · `:56` `ErroDeSenha.curta` para `'12345'` · bloc: `entrar_bloc_test.dart:101-106` — `erroDeEmail == ErroDeEmail.formato` + `chamadas isEmpty` · `:115-116` idem senha · UI: `entrar_page_test.dart:152-153` — `find.text('E-MAIL INVÁLIDO')` + `chamadas isEmpty` · `:164-165` — `find.text('MÍNIMO DE 6 CARACTERES')` | ✅ PASS (mutação 6 morta) |
| ENT-08 AC2 — campo vazio → validação inline, sem repositório | idem | `validacao_de_credenciais_test.dart:11-17` (`''` e `'   '` → `vazio`) · `:52` `vazia` · bloc: `entrar_bloc_test.dart:123-125` — os dois erros de uma vez + `chamadas isEmpty` · UI: `entrar_cadastro_test.dart:138` — `find.text('INFORME SEU E-MAIL')` | ✅ PASS |
| ENT-09 AC3 — credencial recusada → **"E-MAIL OU SENHA INCORRETOS"** inline, e-mail mantido, CTA ocioso | os três, literalmente (A-06) | `entrar_page_test.dart:187` — `expect(find.text('E-MAIL OU SENHA INCORRETOS'), findsOneWidget)` (literal) · `:189-191` — `expect(tester.widget<TextField>(…).controller?.text, 'rafa@bora.app')` · `:198-204` — `expect(…BoraPrimaryButton….onPressed, isNotNull)` · mapeamento: `test/core/autenticacao/dados/falha_de_codigo_test.dart:19-25` (4 formas) | ✅ PASS (mutação 3 morta) |
| ENT-11 AC4 — rede/Firebase indisponível → mensagem, tela utilizável, **sem exceção não tratada** | mensagem + `takeException()` nulo | `entrar_page_test.dart:210-211` — `find.byKey(FormularioDeEntrada.mensagemDeFalhaKey)` + `expect(tester.takeException(), isNull)` · `:218-219` — `find.text('NÃO DEU PRA ENTRAR AGORA')` + `takeException` nulo · adaptador: `firebase_autenticacao_repository_test.dart:231-234` — `StateError` → `throwsA(FalhaDeAutenticacao.indisponivel)` · default: `falha_de_codigo_test.dart:44-55` (4 códigos, inclui string vazia) | ✅ PASS (mutação 9 morta) |
| ENT-12 AC5 — toda falha de auth registrada no `AppLogger` | uma entrada, com nome próprio | `firebase_autenticacao_repository_test.dart:249` — `expect(logger.erros, hasLength(1))` · `:250-253` — `expect(logger.erros.single.name, FirebaseAutenticacaoRepository.nomeDoRegistro)` · controle negativo `:263` — sucesso ⇒ `logger.erros isEmpty` | ✅ PASS — o registro é do helper compartilhado `_traduzindoFalha` (`firebase_autenticacao_repository.dart:103,106`), então uma amostra cobre os dois ramos |

### P2-1 — Criar conta sem sair da tela

| Critério | Resultado que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| ENT-20 AC1 — "CRIAR CONTA" alterna o modo **sem mudar de rota** | label "CRIAR CONTA", CTA "CRIAR CONTA →", rodapé "Já tem conta? ENTRAR" | `test/features/entrar/presentation/pages/entrar_cadastro_test.dart:47` `'CRIAR CONTA →'` · `:48` `'Já tem conta? '` · `:49` `'ENTRAR'` · `:51-54` par ausente (`'COMEÇAR →'` → `findsNothing`) · `:64-68` — `expect(find.byKey(EntrarPage.pageKey), findsOneWidget)` (mesma tela) · label do card no web `:81` | ✅ PASS |
| ENT-13 AC2 — alternar preserva o e-mail e limpa o erro anterior | e-mail intacto, mensagem some | e-mail: `entrar_cadastro_test.dart:105-110` — `expect(…controller?.text, 'rafa@bora.app')` · falha: `:125-130` — `mensagemDeFalhaKey → findsNothing` · validação: `:142` — `find.text('INFORME SEU E-MAIL') → findsNothing` · bloc: `entrar_bloc_test.dart:285-291` (`falha isNull`, `modo == cadastro`) e `:302-303` | ✅ PASS (mutação 7 morta) |
| ENT-13 AC5 — "ENTRAR" do rodapé volta ao modo entrar **preservando o e-mail** | copy restaurada **e** e-mail intacto | copy: `entrar_cadastro_test.dart:93-94` — `'COMEÇAR →'` + `'Novo por aqui? '`. **Preservação do e-mail no sentido cadastro→entrar: sem asserção** (só o sentido entrar→cadastro é afirmado, `:105-110`) | ⚠️ **Parcial** |
| ENT-20 AC3 — cadastro conclui → autentica **e navega para `/roles`** | mesmo destino dos demais | autentica: `entrar_cadastro_test.dart:156-161` — `expect(autenticacao.chamadas, ['criarConta'])` + `expect(autenticacao.sessaoAtual, isNotNull)`; bloc: `entrar_bloc_test.dart:47-52`. **Navegação para `/roles`: sem asserção** — mesma cadeia não composta de ENT-06/ENT-14 | ❌ **GAP** |
| ENT-20 AC4 — e-mail em uso → mensagem inline, **permanece no modo cadastro** | mensagem + modo mantido | `entrar_cadastro_test.dart:175` — `expect(find.text('JÁ EXISTE CONTA COM ESSE E-MAIL'), findsOneWidget)` · `:177-181` — `find.text('CRIAR CONTA →') → findsOneWidget` (modo mantido) · mapeamento: `falha_de_codigo_test.dart:36-40` (`email-already-in-use` → `emailEmUso`) | ✅ PASS — mas ver ⚠️ spec-precision abaixo sobre o texto |

### P2-2 — A tela de erro veste os tokens

| Critério | Resultado que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| ENT-19 AC1 — tokens do arquivo 02, sem literal próprio | fundo `paper`, título Archivo Black caixa alta | `test/core/routing/route_error_page_tokens_test.dart:21` — `expect(scaffold.backgroundColor, BoraColors.paper)` · `:30` — `expect(titulo.style?.fontFamily, BoraTextStyles.familiaDisplay)` · `:31` — `fontSize == BoraTextStyles.tituloTela.fontSize` · sem literal: `token_purity_guard_test.dart:20` (varre `lib/`) | ✅ PASS |
| ENT-19 AC2 — CTA secundário **"VOLTAR PRO INÍCIO"** que **leva à raiz** | a copy literal + destino `/roles` | copy: `route_error_page_tokens_test.dart:54` usa `find.text(RouteErrorPage.voltar)` — **a constante de produção, não o literal**, o que viola a regra de asserção do próprio `tasks.md` ("copy da spec → afirmar o literal escrito no teste"). Destino: `:57-58` afirma só `find.byKey(RouteErrorPage.pageKey) → findsNothing` ("saiu da tela"), **não** que chegou à raiz. Empírico: **mutação 12 (destino `/roles` → `/catalogo`) sobreviveu** | ❌ **GAP** |
| ENT-19 AC3 — alcançável **sem sessão** | a guarda não intercepta | `route_error_page_tokens_test.dart:68-76` — `abrirApp(tester, '/rota-que-nao-existe')` sem sessão → `expect(find.byKey(RouteErrorPage.pageKey), findsOneWidget)` · regra pura: `guarda_de_sessao_test.dart:94-104` | ✅ PASS |

---

## Edge Cases da spec

| Edge case | Evidência | Result |
|---|---|---|
| Duplo toque rápido em "COMEÇAR →" executa **uma** autenticação | — nenhuma asserção. Mutações 10 e 11 sobreviveram aos 922 testes | ❌ **NÃO coberto** |
| E-mail com espaços nas pontas é aparado antes da validação e **do envio** | validação: `validacao_de_credenciais_test.dart:39` — `expect(validarEmail('  rafa@bora.app  '), isNull)` · normalização: `:46` — `expect(emailNormalizado('  rafa@bora.app  '), 'rafa@bora.app')`. **Envio: `entrar_bloc_test.dart:55-66` afirma que a chamada aconteceu (`chamadas == ['entrarComEmailESenha']`), não o valor enviado** — o duplo só registra o nome do método (`test/support/fake_autenticacao_repository.dart:35,51`) | ⚠️ **Parcial — violação da regra payload/conjunção** |
| Cruzar 900px com a tela montada preserva texto e modo, sem remontar | — nenhum teste redimensiona o viewport **depois** do `pumpWidget`; `tester.view.physicalSize` só aparece nos helpers `abrir` (`entrar_page_test.dart:29`, `entrar_cadastro_test.dart:22`), antes da montagem. A garantia estrutural existe (`entrar_page.dart:43-44`, controllers acima do `ResponsiveBuilder`) mas não é afirmada | ❌ **NÃO coberto** (era done-when explícito de T14) |
| Teclado cobre o CTA ⇒ conteúdo rola, sem overflow | — sem asserção. Impl: `SingleChildScrollView` em `entrar_compacto.dart:37` | ❌ **NÃO coberto** |
| Firebase não inicializou ⇒ tela abre e o CTA falha com mensagem | `entrar_page_test.dart:214-220` — `find.text('NÃO DEU PRA ENTRAR AGORA')` + `takeException() isNull` · `firebase_autenticacao_repository_test.dart:227-236` — `StateError('Firebase não inicializado')` → `FalhaDeAutenticacao.indisponivel` | ✅ Coberto |
| Senha com exatamente 6 caracteres é aceita (fronteira inclusiva) | `validacao_de_credenciais_test.dart:59-67` — `expect(validarSenha('123456'), isNull)` + `expect(minimoDeSenha, 6)`, com o lado de baixo em `:56` | ✅ Coberto (mutação 6 morta) |

---

## Spec-precision gaps (a spec não define resultado preciso — não passar em silêncio)

| # | Onde | O que falta na spec | Como o código resolveu |
|---|---|---|---|
| SP-1 | `lib/core/autenticacao/dominio/usuario_logado.dart:35-39` | inicial de usuário **sem nome e sem e-mail** | `'?'`, com `SPEC_PRECISION_GAP` declarado no doc e ecoado no `reason` do teste (`test/core/autenticacao/dominio/usuario_logado_test.dart:43-46`). **Declarado honestamente** ✅ |
| SP-2 | `lib/features/entrar/presentation/entrar_textos.dart:51-54` | a spec fixa **só** "E-MAIL OU SENHA INCORRETOS" (A-06). Os textos de `emailEmUso`, `senhaFraca`, `semRede` e `indisponivel` **não têm origem na spec** | inventados: `'JÁ EXISTE CONTA COM ESSE E-MAIL'`, `'ESCOLHA UMA SENHA MAIS FORTE'`, `'SEM CONEXÃO — TENTE DE NOVO'`, `'NÃO DEU PRA ENTRAR AGORA'`. Coerentes com o padrão de caixa alta, mas **não declarados como desvio em lugar nenhum** ⚠️ |
| SP-3 | `lib/features/entrar/presentation/entrar_textos.dart:68-71` | a spec não dá texto para os erros de validação inline | inventados: `'INFORME SEU E-MAIL'`, `'E-MAIL INVÁLIDO'`, `'INFORME SUA SENHA'`, `'MÍNIMO DE 6 CARACTERES'`. Mesmo caso de SP-2 ⚠️ |
| SP-4 | ENT-07 AC5 | "exibir estado de carregando" não define **o quê** (spinner? troca de rótulo? opacidade?) | reduzido a `onPressed: null` ⇒ opacidade .7 do `BoraPrimaryButton`. A leitura é defensável, mas a spec não a autoriza explicitamente, e nenhum teste a fixa ⚠️ |
| SP-5 | ENT-14 AC3 | "voltar ao estado ocioso" | o estado vai para `SituacaoDeEnvio.falhou` (com `falha = cancelada` e `mostraFalha == false`), não para `ocioso`. Observacionalmente equivalente (`enviando == false`, sem mensagem), mas não é literalmente "ocioso" ⚠️ |

---

## Discrimination Sensor — tier **P0** (auth = caminho crítico)

Método: **cópia temporária do arquivo** (`cp` → mutação → `flutter test` → restaurar → `git status` vazio). **Sem `git stash`** — a árvore é compartilhada. `git status --porcelain` e `git diff --stat` confirmados vazios após **cada** mutação e ao fim.

| # | `file:line` | Mutação | Testes rodados | Morto? |
|---|---|---|---|---|
| 1 | `lib/core/routing/guarda_de_sessao.dart:31` | `if (!temSessao)` → `if (temSessao)` | `guarda_de_sessao_test` + `app_test` | ✅ Morto (23 falhas) |
| 2 | `lib/core/routing/guarda_de_sessao.dart:38-39` | `_ehProtegida` deixa de casar o prefixo: só `rota == Routes.roles` | `test/core/routing/` + `app_test` | ✅ Morto (`/roles/rafa18/lista sem sessão vai para /entrar`) |
| 3 | `lib/core/autenticacao/dados/falha_de_codigo.dart:52` | remove `'INVALID_LOGIN_CREDENTIALS'` do casamento | `test/core/autenticacao/` | ✅ Morto (2 arquivos: mapeamento + adaptador) |
| 4 | `lib/core/autenticacao/dados/falha_de_codigo.dart:41-46` | remove `'user-cancelled'` e `'web-context-canceled'` de `codigosDeCancelamento` | `test/core/autenticacao/` + `test/features/entrar/` | ❌ **Sobreviveu — declarado** (ver §Limites) |
| 5 | `lib/core/autenticacao/dados/metodo_de_google.dart:30-31` | inverte `isWeb` (popup ⇄ provider) | `test/core/autenticacao/` | ✅ Morto (5 falhas) |
| 6 | `lib/features/entrar/domain/validacao_de_credenciais.dart:46` | `senha.length < minimoDeSenha` → `<=` | `test/features/entrar/` | ✅ Morto (3 falhas) |
| 7 | `lib/features/entrar/presentation/bloc/entrar_bloc.dart:38-40` | `ModoAlternado` deixa de limpar falha e validação | `test/features/entrar/` | ✅ Morto (4 falhas) |
| 8 | `lib/features/entrar/presentation/bloc/entrar_bloc.dart:74-82` | ignora o modo: chama sempre `entrarComEmailESenha` | `test/features/entrar/` | ✅ Morto (2 falhas) |
| 9 | `lib/core/autenticacao/dados/firebase_autenticacao_repository.dart:104` | `throw falhaDeCodigo(erro.code)` → `rethrow` (exceção do SDK vaza) | `test/core/autenticacao/` | ✅ Morto (8 falhas) |
| 10 | `lib/features/entrar/presentation/widgets/formulario_de_entrada.dart:71` | `onPressed: estado.enviando ? null : aoSubmeter` → `onPressed: aoSubmeter` | **suíte inteira (`test/`)** | ❌ **SOBREVIVEU — 922/922 passaram** |
| 11 | `lib/features/entrar/presentation/bloc/entrar_bloc.dart:51` | remove `if (state.enviando) return;` | **suíte inteira (`test/`)** | ❌ **SOBREVIVEU — 922/922 passaram** |
| 12 | `lib/core/routing/route_error_page.dart:65` | `context.go(Routes.roles)` → `context.go(Routes.catalogo)` | `test/core/routing/` + `app_test` | ❌ **SOBREVIVEU** |
| 13 | `lib/app.dart:27` | remove `theme: boraTheme()` | `app_test` + `test/features/entrar/` | ✅ Morto (3 falhas) |
| 14 | `lib/features/entrar/presentation/bloc/entrar_state.dart:43-44` | `mostraFalha` deixa de excluir `cancelada` | `test/features/entrar/` | ✅ Morto |
| 15 | `lib/features/entrar/presentation/widgets/entrar_expandido.dart:34` | `sombraDoCard = 10` → `4` | **suíte inteira (`test/`)** | ❌ **SOBREVIVEU — 922/922 passaram** |
| 16 | `lib/features/entrar/presentation/widgets/formulario_de_entrada.dart:61` | `obscureText: true` → `false` no campo senha | `test/features/entrar/` + `bora_text_field_test` | ✅ Morto |

**Profundidade**: P0-full (16 mutações ≥ 5 exigidas) · **Resultado: 11/16 mortas — ❌ FAIL** (4 sobreviventes não declarados + 1 declarado)

---

## Limites declarados pelo implementador — conferidos, um a um

**1. `codigosDeCancelamento` marcado como "não verificado empiricamente"** — ✅ **Confere, e está honesto.**
O doc em `lib/core/autenticacao/dados/falha_de_codigo.dart:31-40` diz textualmente que os quatro códigos vêm da lista pública do SDK JS/nativo, que a varredura de `firebase_auth-6.5.7`, `firebase_auth_web-6.2.6` e `firebase_auth_platform_interface-9.0.6` não os encontrou, e que **"o que está testado aqui é o mecanismo, não a exatidão desta lista"**. O teste corresponde: `test/core/autenticacao/dados/falha_de_codigo_test.dart:59-63` itera sobre a **própria constante de produção** — é auto-referencial por construção e não pode acusar lista errada —, e o anti-vácuo em `:74-81` (`expect(codigosDeCancelamento, isNotEmpty)`) impede que o grupo passe rodando zero casos. A **mutação 4 confirma empiricamente**: encolher o conjunto não quebra nada. **O teste não finge verificar a lista.** Um elemento fica ancorado por fora: `'popup-closed-by-user'` é literal em `firebase_autenticacao_repository_test.dart:193`.
**Pendência de processo**: o done-when de T6 dizia "só se a captura falhar é que o teste cobre o ramo default e a task **registra no `validation.md`** que o código ficou por verificar". **Fica aqui registrado**: a captura com a skill `run` (emulador + Chrome, fechar o popup) **não foi feita**, e os quatro códigos seguem por verificar. Igualmente registrado, por A-10: a verificação ponta-a-ponta do provider Google **depende de conferência manual, no web**.

**2. `SPEC_PRECISION_GAP` em `UsuarioLogado.inicial`** — ✅ **Confere, e está honesto.**
Declarado em `lib/core/autenticacao/dominio/usuario_logado.dart:35-39`, com o teste correspondente em `test/core/autenticacao/dominio/usuario_logado_test.dart:37-47` afirmando `'?'` e repetindo o gap no `reason`. A correção de origem prometida a T5 foi entregue: `firebase_autenticacao_repository.dart:123` (`usuario.email ?? ''`) com o teste em `firebase_autenticacao_repository_test.dart:104-114`, que afirma `email == ''` e `inicial == 'R'` (cai no `displayName`).

**3. ENT-07 "deliberadamente coberto na UI (`onPressed: null`), não no bloc"** — ❌ **NÃO confere. A cobertura não existe em lugar nenhum.**
O mecanismo está implementado nos dois lugares (`formulario_de_entrada.dart:71` e `entrar_bloc.dart:51`), mas **nenhum teste do repositório o observa**. `test/features/entrar/presentation/bloc/entrar_bloc_test.dart:158-166` argumenta por escrito que a garantia "está afirmada no teste de widget de T13" — esse teste **não existe**: a única asserção sobre `onPressed` na feature é `entrar_page_test.dart:198-204`, que afirma `isNotNull` **depois** da falha, e passaria com o CTA nunca desabilitado. As mutações **10 e 11** provam: apagar qualquer um dos dois mecanismos deixa os **922 testes verdes**. O argumento do comentário sobre o transformador de eventos é correto para o `add()` programático — e é exatamente por isso que a asserção tinha de existir na UI, e ela não foi escrita.

---

## Code Quality

| Princípio | Status |
|---|---|
| Nada além do pedido | ✅ |
| Sem abstração para uso único | ✅ — `FormularioDeEntrada` é usado pelos dois layouts; `metodo_de_google.dart` é justificado por um bug que só aparece em runtime no navegador |
| Sem "flexibilidade" desnecessária | ✅ — `isWeb` injetável em `firebase_autenticacao_repository.dart:25` é a costura mínima para alcançar os dois ramos |
| Só arquivos necessários tocados | ✅ — fronteira de arquivos respeitada; as 4 emendas (E-1..E-4) foram usadas como autorizadas |
| Não "melhorou" código alheio | ✅ — os testes de rota existentes foram **reapontados**, não afrouxados (`app_router_publico_test.dart:21` troca `PlaceholderPage.keyFor('entrar')` por `EntrarPage.pageKey`, asserção equivalente) |
| Segue os padrões existentes | ✅ — domínio em PT-BR, infra em inglês; guards de arquitetura no padrão da spec 01 |
| Checagem spec-anchored (valor afirmado = valor da spec) | ⚠️ — falha em ENT-19 AC2 (copy pela constante de produção, destino não afirmado) e no edge case do `trim` (payload não afirmado) |
| Coverage Expectation por camada | ⚠️ — domínio ✅ 1:1; **widget de tela ❌**: `entrar_expandido.dart` não tem arquivo de teste próprio, contrariando a matriz ("cada AC de UI **com par discriminante**"); roteamento ✅ (rota aberta e destino final afirmado, nos dois estados de sessão) |
| Regra payload/conjunção | ❌ — `entrar_bloc_test.dart:55-66` afirma que a chamada ocorreu, não o e-mail aparado que chegou; o duplo não guarda argumentos (`fake_autenticacao_repository.dart:35`) |
| Todo teste mapeia a um AC / edge / done-when | ⚠️ — **`entrar_bloc_test.dart:264-269`** ("alterna entrar para cadastro e de volta") afirma `expect(bloc.state.modo, ModoDeEntrada.entrar)` **síncrono**, logo após `bloc.add(const ModoAlternado())`: ele afirma que o evento ainda **não** foi processado. Passaria com um handler no-op, e o nome promete o oposto do que o corpo verifica. Teste enganoso |
| Guidelines documentadas seguidas | ✅ `CLAUDE.md` §Testes, §Design system · `tasks.md` §Test Coverage Matrix (com as exceções acima) |
| Nenhum teste existente enfraquecido | ✅ — 742 → **922** (+180). Zero skips, zero deleções |

---

## Gate Check

- **Comando (Build)**: `flutter analyze && flutter test`
- **`flutter analyze`**: `No issues found! (ran in 1.7s)` — zero issues
- **`flutter test`**: `00:14 +922: All tests passed!`
- **Testes antes da feature**: 742 · **depois**: 922 · **delta**: **+180**
- **Skipped**: nenhum · **Failures**: nenhuma
- **Integridade**: nenhuma contagem reduzida, nenhuma asserção enfraquecida detectada na leitura do diff dos testes existentes
- **Árvore ao fim do sensor**: `git status --porcelain` vazio · `git diff --stat` vazio

---

## Fix Plans

### Fix 1 — ENT-07 / ENT-10 sem sensor: o duplo toque não é observado por nenhum teste — **Blocker**

- **Root cause**: a asserção foi delegada por comentário (`entrar_bloc_test.dart:158-166`) a um "teste de widget de T13" que nunca foi escrito. Os dois mecanismos (`formulario_de_entrada.dart:71`, `entrar_bloc.dart:51`) são invisíveis à suíte.
- **Fix task**:
  1. Em `test/features/entrar/presentation/pages/entrar_page_test.dart`, com o duplo devolvendo um `Future` que o teste controla (o `FakeAutenticacaoRepository` precisa de uma costura para segurar a conclusão), afirmar **durante** o envio: `expect(tester.widget<BoraPrimaryButton>(…).onPressed, isNull)` e `expect(tester.widget<BoraSecondaryButton>(…).onPressed, isNull)` — com o par ocioso (`isNotNull`) já existente em `:198-204`.
  2. Afirmar o edge case literal da spec: dois `tap` em sequência sem `pumpAndSettle` entre eles ⇒ `expect(autenticacao.chamadas, hasLength(1))`.
  3. No bloc, cobrir a guarda interna com `add` concorrente enquanto o primeiro envio está pendente ⇒ **uma** chamada.
  4. Decidir e fixar ENT-07 AC5 primeira metade: se "estado de carregando" é a opacidade .7 do botão desabilitado, escrever o teste que o afirma; se é outra coisa, é implementação faltando.
- **Verificação**: as mutações 10 e 11 desta tabela passam a morrer.

### Fix 2 — ENT-04 / W-01 praticamente sem cobertura — **Major**

- **Root cause**: T14 fechou sem o arquivo de teste que a matriz exige para widget de tela. `entrar_expandido.dart` (114 linhas) tem duas asserções indiretas em `entrar_page_test.dart:288,301`.
- **Fix task**: criar `test/features/entrar/presentation/widgets/entrar_expandido_test.dart` afirmando, no viewport 1180×800: as duas colunas (marca à esquerda, card à direita); `BoraSurface` com `deslocamentoDaSombra == EntrarExpandido.sombraDoCard` e `acento == BoraAccent.ink` **contra o token**; `MarcaBora.expandida` na árvore; os literais `'COMEÇAR →'` e `'Novo por aqui? '` + `'CRIAR CONTA'`; ausência de overflow horizontal (W-R4).
- **Verificação**: a mutação 15 passa a morrer.

### Fix 3 — a metade "navega para `/roles`" de ENT-06, ENT-14 AC2 e ENT-20 AC3 nunca é composta — **Major**

- **Root cause**: a AD-020 tornou a navegação **consequência** do stream de sessão; as duas metades foram testadas em arquivos diferentes e a cadeia inteira nunca é atravessada. É exatamente o que o Independent Test de cada história pede.
- **Fix task**: um teste que use `abrirApp(tester, Routes.entrar)` (roteador de verdade), preencha os campos, toque "COMEÇAR →" e afirme `find.byKey(PlaceholderPage.keyFor('home')), findsOneWidget`. Repetir para o botão do Google (ENT-14 AC2) e para "CRIAR CONTA →" (ENT-20 AC3). Acrescentar o par de ENT-14 AC3: cancelar ⇒ a rota **não** muda (`EntrarPage.pageKey` continua montada).

### Fix 4 — ENT-19 AC2: destino do CTA de erro não é afirmado, e a copy não é literal — **Major**

- **Root cause**: `route_error_page_tokens_test.dart:57-58` afirma "saiu da tela de erro"; qualquer destino passa. E `:54` usa `RouteErrorPage.voltar` no lugar do literal da spec.
- **Fix task**: trocar por `find.text('VOLTAR PRO INÍCIO')` e afirmar o destino final (`find.byKey(PlaceholderPage.keyFor('home')), findsOneWidget`).
- **Verificação**: a mutação 12 passa a morrer.

### Fix 5 — edge case do `trim` sem asserção de payload — **Minor**

- **Root cause**: `FakeAutenticacaoRepository` registra só o nome do método (`test/support/fake_autenticacao_repository.dart:35`), então `entrar_bloc_test.dart:55-66` não pode afirmar o valor enviado.
- **Fix task**: registrar também os argumentos no duplo e afirmar `expect(autenticacao.emailEnviado, 'rafa@bora.app')` para a entrada `'  rafa@bora.app  '`.

### Fix 6 — dois edge cases da spec sem teste nenhum — **Minor**

- Cruzar 900px com a tela montada preservando texto e modo (done-when de T14): redimensionar `tester.view.physicalSize` **depois** do `pumpWidget`, dar `pump`, e afirmar o texto do controller e o modo corrente.
- Teclado cobrindo o CTA: montar com altura reduzida / `viewInsets` e afirmar `tester.takeException()` nulo com o CTA alcançável por `scrollUntilVisible`.

### Fix 7 — teste enganoso no bloc — **Minor**

- `test/features/entrar/presentation/bloc/entrar_bloc_test.dart:264-269`: o corpo afirma o estado **antes** do evento ser processado; o nome promete a alternância de ida e volta. Reescrever com `await assentar()` e afirmar `cadastro`, ou removê-lo (o caso de ida e volta já está em `:306-312`).

### Fix 8 — registrar SP-2/SP-3 e fechar as pendências de processo — **Minor**

- Declarar em `spec.md` (ou como `SPEC_PRECISION_GAP` no `entrar_textos.dart`) que os textos de `emailEmUso`, `senhaFraca`, `semRede`, `indisponivel` e os quatro de validação inline **não têm origem na spec-fonte**.
- Preencher `**Status**` de T5..T16 no `tasks.md`.
- Executar (ou declarar não executada) a conferência visual com `run` de T13/T14/T15 e a captura do código de cancelamento de T6.
- Estender o `shape_and_shadow_guard` a `lib/` inteira, ou corrigir ENT-02 AC4 para o escopo que a guarda realmente cobre.

---

## Requirement Traceability Update

| Requisito | Status anterior | Novo status |
|---|---|---|
| ENT-01 | Implementing | ✅ Verified |
| ENT-02 | Implementing | ⚠️ Parcial — AC4 só cobre cor e fonte; sombra fora do escopo da guarda |
| ENT-03 | Implementing | ⚠️ Parcial — todos os literais ✅; "na ordem de T-01" sem asserção |
| ENT-04 | Implementing | ❌ Needs Fix — layout de W-01 e tokens do card sem cobertura (mutante 15 vivo) |
| ENT-05 | Implementing | ✅ Verified |
| ENT-06 | Implementing | ❌ Needs Fix — autentica ✅, navega para `/roles` sem asserção |
| ENT-07 | Implementing | ❌ Needs Fix — **sem cobertura alguma** (mutantes 10 e 11 vivos) |
| ENT-08 | Implementing | ✅ Verified |
| ENT-09 | Implementing | ✅ Verified |
| ENT-10 | Implementing | ❌ Needs Fix — mesmo mecanismo de ENT-07 |
| ENT-11 | Implementing | ✅ Verified |
| ENT-12 | Implementing | ✅ Verified |
| ENT-13 | Implementing | ⚠️ Parcial — AC2 ✅; AC5 sem asserção do e-mail no retorno |
| ENT-14 | Implementing | ❌ Needs Fix — AC1 ✅, split de plataforma ✅; AC2 (destino) e "sem navegar" de AC3 sem asserção |
| ENT-15 | Implementing | ✅ Verified |
| ENT-16 | Implementing | ✅ Verified |
| ENT-17 | Implementing | ⚠️ Parcial — AC3 ✅; AC4 afirmado em duas metades separadas |
| ENT-18 | Implementing | ✅ Verified |
| ENT-19 | Implementing | ❌ Needs Fix — AC1 e AC3 ✅; AC2 sem literal e sem destino (mutante 12 vivo) |
| ENT-20 | Implementing | ❌ Needs Fix — AC1 e AC4 ✅; AC3 sem asserção de destino |
| ENT-21 | Implementing | ✅ Verified |

---

## Summary

**Overall**: ❌ **Not Ready**

**Checagem spec-anchored**: 10/21 ✅ · 4 ⚠️ · 7 ❌ · 5 spec-precision gaps sinalizados
**Sensor**: 11/16 mutações mortas — 4 sobreviventes não declarados + 1 declarado
**Gate**: 922 passando, 0 falhando, 0 skipped · `analyze` zero issues

**O que funciona de verdade** — com evidência discriminante:
- A guarda de sessão. Tabela completa por rota × estado, integração que abre a rota e afirma o **destino final**, e as duas mutações mais óbvias (inverter a condição, encolher o prefixo) morrem. ENT-15..ENT-18 é o pedaço mais sólido da feature.
- A camada de dados: mapeamento de código, split de plataforma do Google, o `catch` que impede a `FirebaseAuthException` de vazar, e o registro no `AppLogger`. Todas as mutações injetadas aí morreram.
- Validação de credenciais com a fronteira dos dois lados, e a falha chegando à tela com a copy literal de A-06.
- O tema plugado e provado **na árvore montada**, não só na função.

**O que não funciona**: a feature tem 180 testes novos e mesmo assim três mecanismos podem ser apagados sem que nada acuse — o CTA que se desabilita durante o envio, a guarda de envio em curso no bloc, e a sombra do card de W-01. E o destino do CTA da tela de erro pode ir para qualquer lugar. Em todos os quatro casos o padrão é o mesmo: **a asserção existe para "a chamada aconteceu" ou "saiu da tela", nunca para o valor/estado que a spec define**.

**Next steps**: rotear os Fixes 1–4 (Blocker/Major) para o implementador, re-despachar o Verifier. Fixes 5–8 podem entrar na mesma rodada. Limite de 3 iterações fix→re-verify antes de escalar.
