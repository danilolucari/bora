# Sua lista (lista turbinada) — Tasks

## Execution Protocol (MANDATORY — do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user — do not proceed without it.**

---

**Spec**: `.specs/features/lista/spec.md` (LIST-01..LIST-35)
**Design**: `.specs/features/lista/design.md`
**Context**: `.specs/features/lista/context.md`
**Status**: Draft
**Baseline**: a suíte verde vigente no merge de `montar` (**≥ 1137 testes**, `flutter analyze` com zero issues). Nenhuma task pode reduzir esse número, enfraquecer teste existente ou apagar teste.

---

## ⛔ Pré-requisito bloqueante — leia antes de dar Execute

**Este `tasks.md` pode ser escrito e revisado agora; o Execute não pode começar antes de `montar` (spec 05) estar mergeada em `main`.** É o §1 do `design.md`, e são três dependências de compilação que não existem no disco:

| O que falta | Onde nasce | Quem usa aqui |
|---|---|---|
| `lib/core/festas/` — `FestaEmEdicao`, `FestaEmEdicaoRepository`, barrel `festas.dart` | `montar` T2/T3 (AD-029) | **Toda** leitura e escrita desta tela (A-15) — T6, T9, T10, T11, T25 |
| `core/calculo/formatacao/rotulo_de_quantidade.dart` | `montar` T5 | A quantidade de cada linha, nos dois modos — T13, T17 |
| `FestaRepositoryEmMemoria` implementando `FestaEmEdicaoRepository` | `montar` T4 | A única impl da porta no M1 — T25 |

Se a ordem inverter, as três peças teriam de nascer aqui e as duas specs colidem nos mesmos arquivos de `core/`. **A T6 (E-c) edita `core/festas/dominio/festa_em_edicao.dart` — é o arquivo de colisão.** Executar depois do merge transforma isso numa edição trivial de arquivo já em `main`.

---

## Test Coverage Matrix

> Gerada do codebase, das diretrizes do projeto e da spec — confirmar antes do Execute.
> **Diretrizes encontradas**: `CLAUDE.md` §Testes (pirâmide completa: unit cobre toda `RN-xx`; cada critério de aceite de `UC-xx` vira widget test; `test/` espelha `lib/`; **teste sai do critério de aceite, nunca da implementação**) · `.specs/STATE.md` AD-005 (log afirmável por duplo), AD-007 (`layoutModeForWidth`), AD-014 (rota nova ⇒ teste que afirma o destino), AD-021 (`mocktail` só para SDK de terceiro; porta de domínio usa fake escrito à mão) · `analysis_options.yaml` (`flutter_lints ^6.0.0`) · `pubspec.yaml` (`flutter_test`, `mocktail`; **sem** `bloc_test` — bloc é testado com `flutter_test` puro, como `test/features/home/presentation/bloc/home_bloc_test.dart`).
> **Sem cobertura por percentual** em lugar nenhum do projeto: o alvo é AC-a-AC, e é ele que vale.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
|---|---|---|---|---|
| Domínio puro de `core/calculo/dominio/**` (E-a, E-b) | unit | Todos os ramos; 1:1 com os AC; igualdade profunda afirmada nos dois sentidos (igual **e** diferente) | `test/core/calculo/dominio/*_test.dart` | `flutter test` |
| Regras de `core/calculo/regras/**` (E-d, E-e, `calcular`) | unit | Todos os ramos; **todo** número derivado afirmado contra a função, nunca contra literal copiado; todo edge case listado tem teste | `test/core/calculo/regras/*_test.dart` | `flutter test` |
| Domínio puro de `core/festas/dominio/**` (E-c) | unit | `copyWith` + `==`/`hashCode` por valor profundo; default vazio não quebra igualdade existente | `test/core/festas/dominio/*_test.dart` | `flutter test` |
| Domínio da feature (`lib/features/lista/domain/**`) | unit | Todos os ramos; 1:1 com os AC; a porta é exercitada por duplo escrito à mão (AD-021) | `test/features/lista/domain/*_test.dart` | `flutter test` |
| Adaptador (`lib/features/lista/data/**`) | unit | Caminho feliz **e** caminho de falha; a falha é observável (sem overlay, sem despesa, log registrado) | `test/features/lista/data/*_test.dart` | `flutter test` |
| BLoC (`lib/features/lista/presentation/bloc/**`) | unit | Um teste por transição de estado; 1:1 com os AC; ordenação, idempotência e falha inclusas | `test/features/lista/presentation/bloc/*_test.dart` | `flutter test` |
| Widget de tela (`lib/features/lista/presentation/{pages,widgets}/**`) | widget | Cada AC de UC-05/UC-06/UC-14/UC-15/UC-16 observável na árvore, nas **duas** viewports (390×820 e 1180×800) | `test/features/lista/presentation/{pages,widgets}/*_test.dart` | `flutter test` |
| Rota (`lib/core/routing/app_router.dart`, `festa_tabs_shell.dart`) | widget (rota) | Destino afirmado por `rotaAtual()`, **não** pelo widget montado (AD-014) | `test/core/routing/*_test.dart` | `flutter test` |
| Fronteira / varredura (guards) | unit (varredura de arquivo) | A violação quebra a suíte **nomeando o arquivo infrator**; **cada regra tem teste contra trecho sintético infrator** — varredura verde contra código limpo não prova que morde | `test/features/lista/architecture/*_test.dart` | `flutter test` |
| Copy (`lista_textos.dart`) | unit | Todo literal das specs 03/04/06 afirmado; comparado com o **token**, nunca com o literal duplicado *(L-008)* | `test/features/lista/presentation/*_test.dart` | `flutter test` |
| Documentação / spec (`.specs/**`) | none | — (sem gate de teste) | — | — |

**Alvo explícito de qualidade desta feature** (`design.md` §11, risco nº 1): **defesa escrita é defesa exercitada.** Piso do stepper, supressão de eco, `null` de `observarFesta`, endereço vazio, guarda do Zé e idempotência do CTA **cada uma** precisa de um teste que **falha se a defesa sair**. Foi o padrão que o sensor do Verifier da spec 04 pegou três vezes; aqui ele é item de checklist, não boa intenção.

## Gate Check Commands

> Descobertas do repositório (`pubspec.yaml`, `analysis_options.yaml`, `CLAUDE.md`) — **não há CI**, tudo roda local.

| Gate Level | When to Use | Command |
|---|---|---|
| **Quick** | Depois de task com teste unit/bloc só | `flutter test test/<caminho do arquivo de teste da task>` |
| **Full** | Depois de task com teste de widget ou de rota | `flutter test test/features/lista test/core/routing` |
| **Build** | Fim de fase, e em **toda** task que toca `lib/core/**` | `flutter analyze && flutter test` |

**Regra de ouro herdada da spec 04 e repetida por `montar`: confira o exit code do `flutter test` explicitamente.** `flutter test | tail` engole o código de saída, e isso já produziu um commit com o gate vermelho neste projeto. Use `flutter test; echo "exit=$?"` ou equivalente.

**Cota:** rodar `python .claude/scripts/cota.py` ao fim de cada task e em toda fronteira de fase (combinado ativo do projeto).

---

## Execution Plan

Fases ordenadas, executadas em sequência; tasks dentro de uma fase executam em ordem.

### Phase 1: As cinco emendas em `core` (6 tasks)

Tudo o que a tela consome e a camada não tem. Nenhuma linha de UI. Toda task aqui roda gate **build**.

```
T1 → T2 → T3 → T4 → T5 → T6
```

### Phase 2: O domínio da feature e a porta de pedido (2 tasks)

Dart + a porta da AD-024, sem Flutter na regra.

```
T7 → T8
```

### Phase 3: O `ListaBloc` (3 tasks)

O único lugar que chama a calculadora.

```
T9 → T10 → T11
```

### Phase 4: Modo PLANEJAR (4 tasks)

O card de itens, a leitura de mercado e a régua de override.

```
T12 → T13 → T14 → T15
```

### Phase 5: Modo COMPRAR (3 tasks)

O checklist por corredor.

```
T16 → T17 → T18
```

### Phase 6: O pedido (4 tasks)

Sheet, cartões, resumo, overlay — atrás da porta.

```
T19 → T20 → T21 → T22
```

### Phase 7: As duas telas, a rota, o guard e as abas (5 tasks)

```
T23 → T24 → T25 → T26 → T27
```

**Empacotamento previsto para o Execute** (~7 tasks por worker, fases inteiras, nunca partidas):

| Batch | Fases | Tasks |
|---|---|---|
| 1 | Phase 1 | T1–T6 (6) |
| 2 | Phase 2 + Phase 3 | T7–T11 (5) |
| 3 | Phase 4 + Phase 5 | T12–T18 (7) |
| 4 | Phase 6 | T19–T22 (4) |
| 5 | Phase 7 | T23–T27 (5) |

Batches rodam **em sequência** — nenhum começa antes de o anterior reportar todas as tasks completas. Ao fim do último, o **Verifier** roda automaticamente (autor ≠ verificador, evidence-or-zero).

> **Nota de cota** (lição registrada em 2026-08-25): worker é sequencial, não fan-out. Cinco workers Opus **em paralelo** estouram a janela de 5h; cinco em sequência, com commit atômico por task, não.

---

## Task Breakdown

### T1: Registrar a AD-030 no `STATE.md`

**What**: Acrescentar a decisão AD-030 (o estado de lista da festa — overrides, carrinho, despesas — mora nas entidades de `core/calculo`/`core/festas`, nunca na feature) à seção `## Decisions` do `.specs/STATE.md`, com o texto que o `design.md` §12 já redigiu.
**Where**: `.specs/STATE.md` (só a seção `## Decisions`, ao fim)
**Depends on**: None
**Reuses**: O formato das AD-023..AD-028 (Decision / Reason / Trade-off / Scope / Date / Status)
**Requirement**: pré-condição estrutural de LIST-15, LIST-20, LIST-27

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `AD-030` existe com os seis campos, `Status: active`
- [x] A **AD-029 de `montar` já está registrada** antes desta — a numeração de `design.md` §12 exige a ordem; se `montar` ainda não a gravou, renumera-se **aqui**, nunca lá
- [x] Nenhuma AD existente é editada (nada vira `superseded`)
- [x] Nenhum arquivo de código é tocado

**Tests**: none (camada "Documentação / spec")
**Gate**: none
**Commit**: `docs(lista): registra a AD-030 do estado de lista na festa`

---

### T2: E-a — o corredor de todo o catálogo

**What**: Campo `Corredor corredor` **obrigatório** em `DefinicaoDeItem`, preenchido nos 16 itens do catálogo, mais o teste de coerência que impede as duas declarações do mesmo fato de divergirem.
**Where**: `lib/core/calculo/dominio/catalogo_de_itens.dart` (modifica) · `lib/core/calculo/dominio/corredor.dart` (atualiza o doc que hoje diz "só existe como atributo de `PrecoDeMercado`")
**Depends on**: T1
**Reuses**: A forma dos campos irmãos `unidade`, `essencial`, `entraNoTotal`; a atribuição literal do `design.md` §6.1
**Requirement**: LIST-17

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] O campo é `required` — item novo sem corredor é **erro de compilação**, não item que some do agrupamento em runtime (é a razão da escolha A de §2.2)
- [x] Os 16 itens têm corredor, exatamente como a tabela do `design.md` §6.1: `acougue` = bovina, suina, frango · `hortifruti` = legumesParaGrelha · `padaria` = paoDeAlho · `bebidas` = refrigerante, suco, agua, cerveja, vodka, cachaca, whisky · `mercearia` = carvao, gelo, salGrosso, coposEPratos
- [x] **Teste de coerência**: para todo `PrecoDeMercado` com `chave != null`, `catalogoDeItens[chave]!.corredor == preco.corredor`; a falha **nomeia o item divergente**
- [x] O teste de coerência cobre as chaves comuns e falha se qualquer uma for reclassificada só de um lado — **correção de contagem no Execute**: a tabela de RN-11 tem 8 linhas, mas só **7** têm `chave` (a 🌭 Linguiça toscana entra com `chave: null`, R-6), então são 7 as chaves comuns; o teste afirma as duas contagens
- [x] Um teste afirma que **todo** `ChaveItem` tem entrada no catálogo com corredor — a cobertura dos 16 não depende de contagem à mão
- [x] O doc de `corredor.dart` deixa de declarar que o corredor dos itens fora de RN-11 "é decisão de `lista`" e passa a apontar para o catálogo
- [x] Gate `build` passa; exit code conferido
- [x] Nenhum teste existente editado; ≥ 6 testes novos

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): dá corredor de mercado a todo item do catálogo`

---

### T3: E-b — o conjunto "no carrinho" na composição

**What**: `Set<ChaveItem> noCarrinho` em `ComposicaoDaFesta` (default vazio, aditivo) e `CalculadoraDaFesta` passando a preencher `ItemDeLista.noCarrinho` a partir dele.
**Where**: `lib/core/calculo/dominio/composicao_da_festa.dart` (modifica) · `lib/core/calculo/regras/calculadora_da_festa.dart` (modifica `_itemDe`)
**Depends on**: T2
**Reuses**: `overrides` como precedente exato de "estado por item reaplicado a cada recálculo"; o helper de `dominio/igualdade.dart` que `itensSelecionados` já usa
**Requirement**: LIST-20 (a metade de domínio)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `noCarrinho` tem default `const {}` — **nenhum** call site existente quebra e nenhum teste existente é editado
- [x] `copyWith` preserva o campo não informado e substitui o informado, inclusive por `{}` vazio
- [x] **Igualdade profunda**: duas composições com o mesmo conjunto são `==`; trocar **um** elemento as separa; `hashCode` acompanha. Sem isso a supressão de eco de T11 não funciona (`design.md` §6.2 / §8.2)
- [x] `calcular` marca `ItemDeLista.noCarrinho = true` **exatamente** para os itens cuja chave está no conjunto, e `false` para os demais — o campo deixa de nascer sempre `false`
- [x] `subtotalDoQueFalta` deixa de ser código morto: teste que monta uma composição com 2 itens marcados e afirma que o subtotal do que falta **exclui** os dois e difere de `subtotalDeItens`
- [x] Chave **órfã** no conjunto (item que a seleção não produz) não cria item nem quebra: o edge case "item marcado some da lista" resolve sem código de limpeza
- [x] `calcular` com 0 pessoas continua devolvendo listas vazias, com ou sem conjunto preenchido
- [x] Gate `build` passa; exit code conferido
- [x] Nenhum teste existente editado; ≥ 8 testes novos

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): leva o carrinho para a composição e para o item calculado`

---

### T4: E-e — `itensCobraveis`, o predicado da AD-010

**What**: `Iterable<ItemDeLista> itensCobraveis(Iterable<ItemDeLista> itens)` filtrando por `DefinicaoDeItem.entraNoTotal` — o único predicado de "entra em dinheiro", usado pelo total, pelo pedido e pela faixa real.
**Where**: `lib/core/calculo/regras/totais.dart` (modifica) · `lib/core/calculo/calculo.dart` (export, se necessário)
**Depends on**: T3
**Reuses**: `totalDosEssenciais`, que já filtra por `entraNoTotal` — a regra existe, o que falta é expô-la
**Requirement**: LIST-04 (a metade de domínio), pré-condição de LIST-09 e LIST-23

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] O doc declara o porquê: 🍽️ Copos & pratos **aparece** na lista e **não soma** (AD-010), e fica fora do total, do pedido (A-19) e da faixa real
- [x] `itensCobraveis` remove exatamente os itens com `entraNoTotal == false` e preserva a **ordem** dos demais
- [x] Lista vazia devolve vazio; lista sem nenhum item excluído devolve todos, na mesma ordem
- [x] Teste que afirma a exclusão de Copos & pratos usando o predicado, não uma reimplementação: **total** e **subtotal do pedido** aqui (`totais_test.dart`); a terceira superfície, a **faixa**, é afirmada na T5, que é onde `faixaRealDaLista` nasce
- [x] `totalExato(itensCobraveis(...))` não muda o resultado dos casos literais já verdes (RN-10: R$ 271 no padrão) — nenhum número da baseline se move
- [x] Gate `build` passa; exit code conferido
- [x] Nenhum teste existente editado; ≥ 5 testes novos

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): expõe o filtro dos itens que entram em dinheiro`

---

### T5: E-d — `FaixaReal` e `faixaRealDaLista`

**What**: A regra da A-03: item coberto por RN-11 contribui com `(mínimo, máximo)` da tabela; item que a tabela não cobre contribui com o próprio `ItemDeLista.valor` nas duas pontas. Soma exata, sem arredondar.
**Where**: `lib/core/calculo/regras/faixa_de_preco.dart` (modifica) · `lib/core/calculo/calculo.dart` (export)
**Depends on**: T4
**Reuses**: `itensCobraveis` (T4), `posicaoDoMarcador` e `totalDeMercado` do mesmo arquivo; a derivação conferida à mão em `design.md` §6.4
**Requirement**: LIST-09

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `FaixaReal { double minimo; double maximo }` **sem campo `media`** — devolver um terceiro número aqui reabriria a D-1 (`design.md` §6.4)
- [x] O doc declara: soma **exata**; quem arredonda é RN-13, uma única vez (AD-009)
- [x] Item coberto contribui com mín/máx da tabela; item não coberto contribui com o próprio `valor` nas **duas** pontas — nenhuma faixa é fabricada
- [x] **Copos & pratos fica fora** das duas pontas (via `itensCobraveis`)
- [x] Aplicada às **oito linhas** da tabela de RN-11 a função **degenera em `totalDeMercado`**: R$ 234 / R$ 356 — afirmado contra `totalDeMercado(tabelaDePrecosDeMercado)`, não contra literal copiado. **Nota do Execute**: a 8ª linha é a 🌭 Linguiça toscana, que entra com `chave: null` (R-6) e por isso não vira `ItemDeLista`; o teste dá a ela uma `ChaveItem` livre, o que deixa as oito cobertas **sem mover um só número** da tabela
- [x] No estado padrão de RN-30 devolve **244,60 / 342,60**, que `MoneyFormatter` exibe como **R$ 245 / R$ 343** — o teste afirma o valor exato da função **e** o formatado
- [x] Lista vazia devolve `(0, 0)`
- [x] Override de preço **não move** a faixa (A-04): mesma lista, com e sem override, mesma `FaixaReal`. **Escopo apurado no Execute**: vale para item **coberto** por RN-11, que é o caso de A-04 ("a faixa não persegue o override"); item **não coberto** contribui com o próprio `ItemDeLista.valor`, que já é o ajustado — os dois casos têm teste
- [x] Gate `build` passa; exit code conferido
- [x] Nenhum teste existente editado; ≥ 8 testes novos

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): soma a faixa real de preço sobre a lista da festa`

---

### T6: E-c — as despesas na festa em edição

**What**: `List<Despesa> despesas` em `FestaEmEdicao` (default vazio, aditivo) — onde a `Despesa` do pedido é persistida para a spec 10 `custos` ler.
**Where**: `lib/core/festas/dominio/festa_em_edicao.dart` (modifica — **arquivo que nasce em `montar`**)
**Depends on**: T5
**Reuses**: `Despesa` de `core/calculo/dominio/`; o `==`/`hashCode` à mão que `FestaEmEdicao` já tem
**Requirement**: LIST-27 (a metade de domínio)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] O doc declara por que fica aqui e **não** em `ComposicaoDaFesta`: despesa não entra em `CalculadoraDaFesta.calcular`, e pô-la na composição mudaria a igualdade que decide se um recálculo é necessário (`design.md` §6.3)
- [x] Default `const []` — nenhum call site de `montar` quebra e **nenhum teste de `montar` é editado**
- [x] `copyWith` preserva a lista não informada
- [x] Igualdade profunda: mesma lista ⇒ `==`; acrescentar uma despesa separa; **ordem** diferente separa
- [x] Duas `FestaEmEdicao` sem despesa continuam iguais — a suíte de `montar` roda intacta
- [x] Gate `build` passa; exit code conferido
- [x] Nenhum teste existente editado; ≥ 5 testes novos

**Tests**: unit
**Gate**: build
**Commit**: `feat(festas): guarda as despesas lançadas na festa em edição`

---

### T7: `ParceiroDeEntrega` e `Pedido`

**What**: O enum dos três parceiros de RN-27 com nome, ETA, frete e o marcador "só bebidas", e o valor `Pedido` que a porta transporta.
**Where**: `lib/features/lista/domain/parceiro_de_entrega.dart` · `lib/features/lista/domain/pedido.dart`
**Depends on**: T6
**Reuses**: `ItemDeLista` de `core/calculo`; os literais de RN-27 transcritos em `design.md` §9
**Requirement**: LIST-22

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] O doc de `pedido.dart` abre com o **SPEC_DEVIATION** declarado: `Pedido` e os parceiros ficam na feature e não em `core/calculo/dominio/` apesar da AD-008, porque a entidade tem **um** consumidor e `total_do_pedido.dart` já atribui parceiros, ETAs e fretes à spec `lista` (`design.md` §6.6)
- [x] Os três parceiros com os literais exatos de RN-27: `iFood Mercado` / `40–60 min` / frete 12 · `Rappi Turbo` / `15–30 min` / frete 9 · `Zé Delivery` / `30–45 min` / frete 0, este com `soBebidas: true`
- [x] A **ordem de declaração** é a de RN-27 (iFood, Rappi, Zé) e um teste a afirma — é ela que determina a ordem dos cartões e a pré-seleção da A-14
- [x] Os fretes são **números**, nunca strings com `R$` — a formatação é de `MoneyFormatter` (o guard de T26 morde `R$`, não números)
- [x] `Pedido` tem `parceiro`, `endereco`, `itens`, `subtotal`, `frete`, `total`, com `==`/`hashCode` por valor
- [x] `Pedido` **não** calcula: `total` é campo, alimentado por `totalDoPedido` fora daqui
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 6 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(lista): declara os parceiros de entrega e o pedido`

---

### T8: `PedidoRepository` e o adaptador falso

**What**: A porta abstrata da **AD-024** e a sua única implementação do MVP, que não faz rede.
**Where**: `lib/features/lista/domain/pedido_repository.dart` · `lib/features/lista/data/pedido_falso.dart`
**Depends on**: T7
**Reuses**: A forma de porta de `FestaRepository` e `AutenticacaoRepository`; `FakeAutenticacaoRepository` como precedente de duplo escrito à mão (AD-021)
**Requirement**: LIST-28

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `Future<Pedido> enviar(Pedido pedido)` é o **único** método da porta
- [x] O doc da porta declara: a única implementação do MVP é falsa (AD-024); quando houver contrato, troca-se o adaptador e **nem a tela nem os testes de aceite mudam**
- [x] O doc de `PedidoFalso` **repete a ressalva de exposição pública da AD-024** no ponto onde alguém a leria (`design.md` §11): a tela afirma "PEDIDO A CAMINHO!" sem pedido
- [x] `PedidoFalso.enviar` devolve o pedido confirmado **sem rede** — nenhum import de `http`, de Firebase ou de `dart:io` no arquivo, afirmado por teste
- [x] O pedido devolvido é **quem alimenta o overlay** (LIST-28 AC2) — o contrato está escrito no doc, e T22 o afirma na árvore
- [x] `PedidoFalsoDeTeste` (duplo escrito à mão, sem `mocktail`) existe em `test/` com um modo de **falha**, e um teste afirma que a falha propaga como exceção — a defesa que T19 e T21 exercitam
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 5 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(lista): abre a porta de pedido com o adaptador falso do MVP`

---

### T9: `ListaBloc` — ciclo de vida, modo e item expandido

**What**: O bloc que assina `observarFesta`, calcula, e guarda modo e item expandido; mais o estado vazio (0 pessoas, festa inexistente) e a falha de stream.
**Where**: `lib/features/lista/presentation/bloc/lista_bloc.dart`, `lista_event.dart`, `lista_state.dart`
**Depends on**: T8
**Reuses**: `HomeBloc` (assinatura de stream, `_aoFalhar` que loga e mantém o último estado bom); `CalculadoraDaFesta.calcular`; `faixaRealDaLista` (T5); `FestaEmEdicaoRepositoryFake` escrito à mão
**Requirement**: LIST-10, LIST-31, LIST-32 (stream)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `ListaState { carregando, festa, resultado, modo, chaveExpandida, faixaReal, falhouAoSalvar }` com `==` por valor
- [x] Antes da primeira emissão o estado é `carregando` — e um teste afirma que a tela nunca vê `resultado` nulo com `carregando: false`
- [x] `ModoAlternado` troca o modo e **não grava** na porta — teste afirma zero chamadas a `salvarFesta`
- [x] `ItemExpandido(chave)` guarda **um** campo, não um `Set`: abrir um item **fecha o anterior** por construção (LIST-10); `ItemExpandido(null)` fecha
- [x] **Item expandido sobrevive ao recálculo**: com um item aberto, um ajuste de outro item não fecha o aberto (edge case da `spec.md`)
- [x] `observarFesta` emitindo `null` produz o estado vazio — card vazio, total 0, `faixaReal` ausente — pelo **mesmo caminho** de 0 pessoas, e **não** redireciona para `/erro` (a rota é válida)
- [x] Composição com 0 pessoas: `resultado.itens` e `.essenciais` vazios, `totalComEssenciais == 0`, `porAdulto == 0` — nenhum essencial aparece, porque a guarda de `calcular` vem antes deles
- [x] Stream que **falha** loga por `logger.logError(name: 'lista')` (afirmado por duplo, AD-005) e **mantém o último estado bom** — o teste falha se o tratamento sair
- [x] Voltar a ter pessoas recalcula normalmente, com os essenciais de volta
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 12 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(lista): cria o bloc da lista com modo, expansão e estado vazio`

---

### T10: `ListaBloc` — os overrides e o RESTAURAR

**What**: Os eventos de ajuste de quantidade e de preço, o RESTAURAR, a gravação na porta e o recálculo ao vivo de total, por adulto e faixa real.
**Where**: `lib/features/lista/presentation/bloc/lista_bloc.dart` (modifica)
**Depends on**: T9
**Reuses**: `comPassoDeQuantidade`, `comPassoDePreco`, `restaurado`, `semOverrides` de `core/calculo/regras/overrides.dart` — **os passos e mínimos de RN-12 já estão dentro delas**
**Requirement**: LIST-11, LIST-13, LIST-14, LIST-15

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `QuantidadeAjustada(chave, passos)` e `PrecoAjustado(chave, passos)` produzem uma `ComposicaoDaFesta` nova → `calcular` → `faixaRealDaLista` → emite → `salvarFesta`. **Não existe segundo caminho de cálculo**
- [x] Os passos vêm do catálogo: **0,5 kg** nas carnes, **2 latas** na cerveja, **1** nos demais — afirmados contra `comPassoDeQuantidade`, nunca contra número copiado
- [x] O passo de preço é **R$ 1** e o mínimo **R$ 1**
- [x] **O piso é exercitado**: decrementar no mínimo **não** muda o estado — o teste falha se a guarda sair (item nº 1 da lista de verificação do Verifier)
- [x] Um ajuste move `valor` da linha, o subtotal, `totalComEssenciais`, `porAdulto` **e** `faixaReal` na **mesma** emissão — sem botão "calcular" (UC-04)
- [x] `resultado.temOverrides` vira `true` no primeiro ajuste e `false` quando o último é desfeito — é ele que T23/T24 leem para exibir o RESTAURAR
- [x] `OverridesRestaurados` zera **todos** de uma vez via `semOverrides()`, e o estado seguinte tem `temOverrides == false`
- [x] O override é gravado por `salvarFesta` a **cada** passo — afirmado contra a porta duplo, e é o que faz LIST-15 (sobrevive à navegação) ser verdade
- [x] Reconstruir o bloc sobre a mesma porta devolve os overrides aplicados — a prova de LIST-15 no nível do bloc
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 12 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(lista): ajusta quantidade e preço e restaura os overrides`

---

### T11: `ListaBloc` — carrinho, despesa do pedido e supressão de eco

**What**: O toggle do carrinho, a `Despesa` de RN-20 nascendo do pedido confirmado, a supressão de eco da porta e o tratamento de falha ao gravar.
**Where**: `lib/features/lista/presentation/bloc/lista_bloc.dart` (modifica)
**Depends on**: T10
**Reuses**: `ComposicaoDaFesta.noCarrinho` (T3), `FestaEmEdicao.despesas` (T6), `Despesa` de `core/calculo`; o `_aoFalhar` de `HomeBloc`
**Requirement**: LIST-20, LIST-27, LIST-32 (gravação), LIST-33, LIST-34

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `ItemAlternadoNoCarrinho(chave)` faz `add`/`remove` num `Set`: marcar duas vezes volta ao estado inicial, **deterministicamente** (LIST-33)
- [x] Marcar **não muda o total** — teste afirma `totalComEssenciais` idêntico antes e depois
- [x] O conjunto é gravado por `salvarFesta`, e reconstruir o bloc sobre a mesma porta devolve os checks — a prova de LIST-20
- [x] `PedidoConfirmado(pedido)` acrescenta **uma** `Despesa` com `quemPagou` = o nome do usuário na festa (**"VOCÊ"** na fixture RN-30), descrição **"Pedido no {parceiro}"** e valor = o **total (subtotal + frete)** — e grava
- [x] `PedidoConfirmado` **não altera** checks nem overrides (A-21) — teste afirma os dois conjuntos idênticos antes e depois
- [x] Dois `PedidoConfirmado` do **mesmo** pedido criam **uma** despesa (LIST-33)
- [x] **Supressão de eco**: emissão do stream **igual** à última `FestaEmEdicao` gravada é descartada; emissão **diferente** é adotada. Teste que dispara um ajuste e injeta o eco no meio, afirmando que o estado **não** regride (LIST-34) — falha se a supressão sair
- [x] Toques rápidos em sequência convergem no estado final correto, sem recálculo obsoleto sobrescrevendo um mais novo
- [x] `salvarFesta` que **falha**: `falhouAoSalvar: true`, `logger.logError(name: 'lista')`, o estado da tela **não** é revertido e a interação segue (LIST-32). *SPEC_PRECISION_GAP declarado em `design.md` §10: nenhuma spec desenha a Lista falhando ao gravar nem dá copy — a evidência é a preservação do estado mais o log*
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 14 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(lista): marca o carrinho e transforma o pedido em despesa`

---

### T12: `ListaTextos` — toda a copy literal, num arquivo só

**What**: Os literais de T-04, RN-27, W-04 e do overlay num arquivo só, com o teste que os afirma contra as specs.
**Where**: `lib/features/lista/presentation/lista_textos.dart`
**Depends on**: T11
**Reuses**: `home_textos.dart` e `montar_textos.dart` como forma; a tabela de `design.md` §9
**Requirement**: LIST-01, LIST-02, LIST-04 (badge), LIST-16 (rótulos), LIST-22, LIST-26

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Todos os literais de `design.md` §9 presentes, **palavra por palavra**: header `SUA LISTA`; segmented `🧮 PLANEJAR` / `🛒 COMPRAR`; as duas dicas tracejadas; `ESSENCIAIS · ENTRAM SOZINHOS`; `AUTO ∝ {fonte}` com as quatro fontes de RN-10; `{quantidade} · média de {N} mercados`; `MÉDIA TOTAL`; `faixa real: de R$ {mín} a R$ {máx}`; `≈ R$ {x} por adulto`; `{N} de {M} no carrinho`; `FAZER PEDIDO 🛒`; `PEDIR O QUE FALTA 🛵`; `RESTAURAR`; os cinco corredores; `{N} itens`; `FAZER PEDIDO`, `ENTREGA POR`, `TROCAR`, `Subtotal`, `Frete`, `Total`, `CONFIRMAR PEDIDO →`; `PEDIDO A CAMINHO!`, `Chega em {ETA} na {endereço}.`, `R$ {total} · rachado no acerto da festa`, `VOLTAR À LISTA`; as quatro abas `Lista · Galera · WhatsApp · Custos`
- [x] Os templates com `R$` **são** parâmetro de formatação, não formatação: o arquivo **não** monta valor — recebe a string já formatada por `MoneyFormatter`. O guard de T26 tem exceção **declarada e nomeada** só para este arquivo, ou os templates são escritos sem o literal `R$` — a decisão é da task, e o `design.md` §13 exige que seja explícita
- [x] **Zero toast** (A-23): um teste afirma que o arquivo não referencia `BoraToastTexts` nem declara texto de toast
- [x] O teste compara com o **token/constante**, nunca com o literal duplicado no teste (L-008)
- [x] Caixa alta onde a spec pede caixa alta; sentence case no corpo das dicas e do overlay
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 10 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(lista): reúne a copy literal da tela num arquivo só`

---

### T13: `LinhaDeItem` — o item de PLANEJAR com a leitura de mercado

**What**: A linha do modo PLANEJAR: emoji, nome, quantidade, valor, ponto vermelho de 8px, sub "média de N mercados", `BoraPriceRangeBar` e o caret ▴ que expande.
**Where**: `lib/features/lista/presentation/widgets/linha_de_item.dart`
**Depends on**: T12
**Reuses**: `BoraListRow`, `BoraExpandableRow`, `BoraPriceRangeBar`, `BoraStatusTag`; `rotuloDeQuantidade` (de `montar`), `MoneyFormatter.reais`, `posicaoDoMarcador`, `tabelaDePrecosDeMercado`
**Requirement**: LIST-03, LIST-08, LIST-12

**Tools**: MCP: NONE · Skill: `run` (conferência visual)

**Done when**:
- [x] Emoji, nome, quantidade (`rotuloDeQuantidade`) e valor (`MoneyFormatter.reais(item.valor)`) renderizam — o valor comparado com o **formatador**, nunca com o literal (L-008)
- [x] Item **coberto** por RN-11 exibe `{quantidade} · média de {N} mercados` com o `N` da coluna Fontes: **4** na Picanha bovina, **3** no Pão de alho, **2** no Gelo
- [x] Item coberto exibe a `BoraPriceRangeBar` com extremos formatados — **R$ 54** e **R$ 83** na Picanha — e a fração comparada com **`posicaoDoMarcador(preco)`**, não com `0.379` (o segundo teste comportamental de `design.md` §13)
- [x] Item **não coberto** (frango, água, suco, destilados, sal grosso, copos & pratos) exibe a quantidade **sem** "média de N mercados" e **sem** barra — nenhuma faixa fabricada
- [x] A micro-label `MÉDIA` renderiza **apenas** nas linhas com leitura de mercado (D-2)
- [x] `máximo == mínimo` renderiza sem dividir por zero, marcador em 0 — a defesa é exercitada
- [x] Item com override **acima do máximo** da faixa: a barra continua com a faixa da tabela e o marcador **dentro do trilho** (L-020 — expressão de teto exercitada acima do teto)
- [x] Item `editado` exibe o **ponto vermelho de 8px** ao lado do nome; item não editado **não** o exibe
- [x] Tocar a linha dispara o callback de expansão; a linha aberta mostra o caret ▴
- [x] Nenhum literal de cor: tudo dos tokens do arquivo 02
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 12 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(lista): desenha a linha do item com a leitura de mercado`

---

### T14: `PainelDeOverride` — os dois steppers

**What**: O painel que abre dentro da linha, com "QUANTIDADE" e "PREÇO" em `BoraStepper`, e o decremento inerte no piso.
**Where**: `lib/features/lista/presentation/widgets/painel_de_override.dart`
**Depends on**: T13
**Reuses**: `BoraStepper` — **`onDecrementar: null` é o piso inerte de RN-12**, não um `if` no widget
**Requirement**: LIST-11 (a metade de UI)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Os dois steppers renderizam com os rótulos literais `QUANTIDADE` e `PREÇO`
- [x] Incrementar e decrementar disparam os callbacks com o sinal correto (`+1` / `-1` passo) — o widget **não** calcula o novo valor
- [x] No piso de quantidade (um passo) o decremento é **inerte**: `onDecrementar` é `null` e o toque não dispara callback — teste que falha se a guarda sair
- [x] No piso de preço (R$ 1) idem
- [x] O valor exibido no stepper de preço vem de `MoneyFormatter`; o de quantidade, de `rotuloDeQuantidade`
- [x] Nenhuma aritmética no arquivo — o guard de T26 cobre, mas o teste desta task afirma o comportamento
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 8 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(lista): abre a régua de quantidade e preço do item`

---

### T15: `CardDePlanejar` — a lista na ordem canônica e os essenciais

**What**: O card único com os itens na `ordemCanonicaDaLista`, o bloco literal "ESSENCIAIS · ENTRAM SOZINHOS" com os quatro de RN-10 e o subtotal de cada categoria.
**Where**: `lib/features/lista/presentation/widgets/card_de_planejar.dart`
**Depends on**: T14
**Reuses**: `BoraListCard`, `LinhaDeItem` (T13), `BoraStatusTag`; `ordemCanonicaDaLista`, `totalExato`, `totalDosEssenciais`, `itensCobraveis` (T4)
**Requirement**: LIST-03, LIST-04, LIST-05

**Tools**: MCP: NONE · Skill: `run` (conferência visual)

**Done when**:
- [x] Os itens renderizam na `ordemCanonicaDaLista`, **sem** nenhum item que a composição não produza
- [x] A categoria literal `ESSENCIAIS · ENTRAM SOZINHOS` contém **os quatro** de RN-10 — 🔥 Carvão, 🧊 Gelo, 🧂 Sal grosso, 🍽️ Copos & pratos — **sem ação nenhuma do usuário**
- [x] Cada essencial tem a badge amarela `AUTO ∝ {fonte}` nas fontes literais: `kg de carne`, `volume de bebida gelada`, `kg de carne`, `nº de pessoas`
- [x] 🍽️ Copos & pratos **aparece** e **não soma**: o subtotal dos essenciais lê **R$ 60** no estado padrão (AD-010), comparado com `MoneyFormatter.reais(totalDosEssenciais(...))`
- [x] Cada categoria exibe o seu subtotal, vindo de `totalExato` / `totalDosEssenciais` — o widget não soma
- [x] Lista vazia (0 pessoas) renderiza o card **vazio**, sem item e **sem copy inventada** (A-11) — nem os essenciais aparecem
- [x] Abrir um item **fecha o anterior** na árvore renderizada (aceite de UC-06, o lado de UI de LIST-10)
- [x] Kit veggie entrando por RN-21 aparece na ordem correta e com a leitura de mercado — o edge case da `spec.md`
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 12 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(lista): monta o card de planejar com os essenciais e os subtotais`

---

### T16: `CheckboxDaLista` — o 26×26

**What**: O checkbox de T-04 composto **dentro da feature** com os tokens do arquivo 02 (A-13).
**Where**: `lib/features/lista/presentation/widgets/checkbox_da_lista.dart`
**Depends on**: T15
**Reuses**: `BoraColors`, `BoraBorders` do arquivo 02; a lição L-008 (comparar com o token, nunca com o literal)
**Requirement**: LIST-18 (a metade do controle)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `SizedBox(26, 26)`, borda 2px `BoraColors.ink`, `borderRadius: 0`
- [x] Desmarcado: fundo branco, sem ✓. Marcado: fundo verde `#0B6B3A`, ✓ branco
- [x] **Nenhum literal de cor no arquivo** — vem dos tokens, senão a varredura de cor da spec 01 morde
- [x] O teste compara com o **token**, nunca com o hexadecimal escrito no teste (L-008)
- [x] **Nenhum componente novo em `core/design_system/`** — teste de fronteira afirma que o arquivo mora na feature
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 5 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(lista): compõe o checkbox 26x26 do modo comprar`

---

### T17: `LinhaDeCompra` — o item marcável a 45%

**What**: A linha do modo COMPRAR: checkbox, emoji, nome, quantidade, valor, e a linha inteira a **45% de opacidade** quando marcada.
**Where**: `lib/features/lista/presentation/widgets/linha_de_compra.dart`
**Depends on**: T16
**Reuses**: `CheckboxDaLista` (T16), `BoraPressSink`, `rotuloDeQuantidade`, `MoneyFormatter.reais`
**Requirement**: LIST-18

**Tools**: MCP: NONE · Skill: `run` (conferência visual)

**Done when**:
- [x] Tocar a linha **inteira** alterna o check (não só o quadradinho)
- [x] Marcada: ✓ branco sobre verde e a linha a **45%** de opacidade — a fração comparada com o token, não com `0.45` escrito no teste
- [x] Desmarcada: volta ao estado normal, opacidade cheia
- [x] O valor exibido não muda ao marcar — marcar é estado de compra, não de preço
- [x] Nenhuma barra de faixa e nenhum painel de override no modo COMPRAR
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 7 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(lista): desenha a linha marcável do modo comprar`

---

### T18: `CardDeComprar` — os cinco corredores na ordem de RN-27

**What**: O agrupamento por corredor na ordem fixa AÇOUGUE → HORTIFRÚTI → PADARIA → BEBIDAS → MERCEARIA, com a contagem "{N} itens" e corredor vazio não renderizando.
**Where**: `lib/features/lista/presentation/widgets/card_de_comprar.dart`
**Depends on**: T17
**Reuses**: `LinhaDeCompra` (T17), `DefinicaoDeItem.corredor` (T2), `ListaTextos` (T12)
**Requirement**: LIST-16, LIST-17

**Tools**: MCP: NONE · Skill: `run` (conferência visual)

**Done when**:
- [x] A ordem dos cinco corredores é a de RN-27 e **não depende do `index` do enum** — a ordem é da feature, declarada como lista literal, e um teste a afirma
- [x] A ordem é **estável**: marcar itens **não** reordena nada
- [x] Cada grupo exibe o rótulo em caixa alta e a contagem `{N} itens`
- [x] Corredor **sem item não renderiza** — teste com uma composição só de bebidas afirma que os outros quatro rótulos estão ausentes da árvore
- [x] Os itens fora de RN-11 caem no corredor do catálogo (T2): carnes em AÇOUGUE, suco/água/destilados em BEBIDAS, sal grosso e copos & pratos em MERCEARIA
- [x] O kit veggie de RN-21 cai em HORTIFRÚTI
- [x] Lista vazia renderiza **nenhum** grupo
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 10 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(lista): agrupa a lista por corredor do mercado`

---

### T19: `PedidoBloc` — parceiro, endereço, resumo e idempotência

**What**: O bloc que nasce com a sheet e morre com ela: seleção de parceiro, troca de endereço, o resumo `subtotal + frete = total` e o envio idempotente.
**Where**: `lib/features/lista/presentation/bloc/pedido_bloc.dart`, `pedido_event.dart`, `pedido_state.dart`
**Depends on**: T18
**Reuses**: `subtotalDeItens`, `subtotalDoQueFalta`, `totalDoPedido` de `core/calculo`; `itensCobraveis` (T4); `PedidoRepository` (T8); `PedidoFalsoDeTeste`
**Requirement**: LIST-21 (endereço), LIST-23, LIST-24, LIST-25, LIST-28, LIST-32, LIST-33

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Nasce com `itens` e `enderecoDaFesta` como parâmetros de construção e **`ParceiroDeEntrega.ifood` pré-selecionado** (A-14)
- [x] `Total = Subtotal + Frete` vindo de `totalDoPedido` — o bloc **não** soma. Estado padrão de RN-30, lista inteira: iFood **271 / 12 / 283**; Rappi total **280**; Zé frete **0**
- [x] `Copos & pratos` fica **fora** do subtotal (A-19), via `itensCobraveis`
- [x] Aberto pelo modo COMPRAR leva **apenas os não marcados** (`subtotalDoQueFalta`), e o subtotal reflete só eles
- [x] `EnderecoTrocado` vale **só para este pedido**; endereço **vazio** volta a `enderecoDaFesta` no próprio handler, nunca fica vazio (A-08) — defesa exercitada por teste
- [x] O Zé é **inerte** enquanto houver item fora do corredor BEBIDAS, e **selecionável** quando o pedido só tem bebidas — os dois lados testados (A-09)
- [x] **Idempotência**: `PedidoEnviado` é ignorado quando `enviando || confirmado != null`; dois disparos rápidos ⇒ **um** `enviar` no duplo, **um** `Pedido` confirmado (LIST-33) — teste que falha se a guarda sair
- [x] Falha da porta: **sem** `confirmado`, `falhou: true`, `logger.logError(name: 'lista')`, e o CTA volta a ativo. *SPEC_PRECISION_GAP declarado: T-04 não desenha erro de pedido e RN-29 não dá toast — a evidência é a ausência de overlay e de despesa mais o log*
- [x] O `Pedido` confirmado é o **que a porta devolveu**, não um montado pelo bloc (LIST-28 AC2)
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 14 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(lista): calcula e envia o pedido atrás da porta`

---

### T20: `CartaoDeParceiro` — o cartão-radio

**What**: O cartão de parceiro com nome, ETA e frete, o estado selecionado, e `onPressed: null` quando inerte.
**Where**: `lib/features/lista/presentation/widgets/cartao_de_parceiro.dart`
**Depends on**: T19
**Reuses**: `BoraPressSink`, `BoraSecondaryButton`; `ParceiroDeEntrega` (T7); `MoneyFormatter.reais` para o frete
**Requirement**: LIST-22, LIST-24

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Nome, ETA e frete renderizam com os literais de RN-27; o frete formatado por `MoneyFormatter`, e o do Zé lido como **grátis** conforme a copy de `design.md` §9
- [x] O qualificador literal **(só bebidas)** aparece no cartão do Zé, **sempre** — mesmo inerte (A-09: a explicação **é** o qualificador)
- [x] Selecionado × não selecionado são visualmente distintos, e o press afunda `translate(2px,2px)` com a sombra de 4px→2px
- [x] Inerte: `onPressed: null`, o toque **não** dispara callback e **nenhuma copy de erro nova** aparece — defesa exercitada
- [x] Nenhum literal de cor; tudo dos tokens
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 7 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(lista): desenha o cartão de parceiro de entrega`

---

### T21: `SheetDePedido` — um conteúdo, dois invólucros

**What**: O conteúdo da sheet FAZER PEDIDO — endereço + TROCAR, "ENTREGA POR" com os três cartões, resumo Subtotal/Frete/Total, "CONFIRMAR PEDIDO →" — montado em `BoraBottomSheet` (compacto) **ou** `BoraSurface` em `showDialog` (expandido).
**Where**: `lib/features/lista/presentation/widgets/sheet_de_pedido.dart`
**Depends on**: T20
**Reuses**: `BoraBottomSheet`, `BoraSurface`, `BoraPrimaryButton`, `BoraTextField`; `CartaoDeParceiro` (T20), `PedidoBloc` (T19), `ListaTextos` (T12)
**Requirement**: LIST-21, LIST-22, LIST-23, LIST-25

**Tools**: MCP: NONE · Skill: `run` (conferência visual nas duas larguras)

**Done when**:
- [x] Título **`FAZER PEDIDO`** (A-18), igual nos dois modos de entrada, com o botão ✕
- [x] Linha 📍 com o endereço da festa — **"Laje do Rafa — Vila Madalena"** na fixture — e o `TROCAR` vermelho sublinhado ao lado
- [x] `TROCAR` abre a edição; o endereço novo vale só para este pedido e **não** altera a festa — teste afirma zero escrita na porta de festa
- [x] Os **três** cartões na ordem de RN-27, com **iFood Mercado** pré-selecionado ao abrir
- [x] O resumo exibe Subtotal, Frete e Total formatados por `MoneyFormatter`; trocar de parceiro atualiza os três
- [x] ✕ **ou toque fora** fecha **sem pedir**: nenhuma `Despesa`, nenhuma alteração na lista (UC-16 A1) — teste afirma os dois caminhos
- [x] **Um conteúdo, dois invólucros**: o mesmo widget de conteúdo é montado nos dois, e um teste afirma que compacto e expandido renderizam os **mesmos** literais e os **mesmos** números
- [x] Aberta pelo COMPRAR mostra só os não marcados, com o subtotal refletindo só eles
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 12 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(lista): monta a sheet de pedido nos dois invólucros`

---

### T22: `OverlayDePedido` — "PEDIDO A CAMINHO! 🛵"

**What**: O overlay de tela cheia com 🛵, título, ETA + endereço inteiro, a linha vermelha do total e "VOLTAR À LISTA".
**Where**: `lib/features/lista/presentation/widgets/overlay_de_pedido.dart`
**Depends on**: T21
**Reuses**: `BoraSurface`, `BoraPrimaryButton`; `ListaTextos` (T12); o `Pedido` devolvido pela porta
**Requirement**: LIST-26

**Tools**: MCP: NONE · Skill: `run` (conferência visual)

**Done when**:
- [x] As quatro linhas literais: 🛵 · `PEDIDO A CAMINHO!` · `Chega em {ETA} na {endereço}.` · `R$ {total} · rachado no acerto da festa` · CTA `VOLTAR À LISTA`
- [x] O **endereço inteiro** — `Laje do Rafa — Vila Madalena`, não `Laje do Rafa` (D-6): o mesmo string que a sheet mostrou
- [x] ETA, endereço e total vêm do `Pedido` que a **porta devolveu** (LIST-28 AC2) — teste com um duplo que devolve ETA diferente afirma que a tela mostra o da porta, não uma constante do widget
- [x] O total formatado por `MoneyFormatter.reais(pedido.total)`
- [x] **Sem selo de "simulado"** e sem qualquer marca de que o pedido não é real (LIST-28 AC4 — consequência declarada da AD-024)
- [x] `VOLTAR À LISTA` fecha o overlay e **não** o repete; o modo de origem, os checks e os overrides ficam intactos
- [x] O overlay **só** existe depois de um pedido confirmado — não há caminho que o monte sem `Pedido`
- [x] Gate `full` passa; exit code conferido
- [x] ≥ 8 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(lista): anuncia o pedido a caminho em tela cheia`

---

### T23: `ListaCompacta` — T-04 inteiro em 390×820

**What**: A tela compacta: header, segmented, dica do modo, corpo do modo ativo e o `BoraFooterBar` com total, faixa/contador, "por adulto", RESTAURAR e CTA.
**Where**: `lib/features/lista/presentation/widgets/lista_compacta.dart`
**Depends on**: T22
**Reuses**: `BoraSegmentedControl`, `BoraDashedNote`, `BoraFooterBar`; `CardDePlanejar` (T15), `CardDeComprar` (T18), `SheetDePedido` (T21), `OverlayDePedido` (T22), `ListaTextos` (T12)
**Requirement**: LIST-01, LIST-02, LIST-05, LIST-06, LIST-14, LIST-19, LIST-25, LIST-31

**Tools**: MCP: NONE · Skill: `run` (conferência visual em 390×820)

**Done when**:
- [ ] Header `SUA LISTA` e o segmented com `🧮 PLANEJAR` / `🛒 COMPRAR`, **PLANEJAR ativo por default**
- [ ] A dica tracejada de cada modo, literal
- [ ] **Aceite de UC-05 na tela**, estado padrão de RN-30: rótulo `MÉDIA TOTAL`, valor **`R$ 271`**, linha **`≈ R$ 45 por adulto`** e CTA `FAZER PEDIDO 🛒` — o valor comparado com `MoneyFormatter.reais(resultado.totalComEssenciais)` (primeiro teste comportamental de `design.md` §13, que mata formatador escrito à mão)
- [ ] A linha `faixa real: de R$ 245 a R$ 343` no rodapé de PLANEJAR, comparada com `faixaRealDaLista`
- [ ] Rodapé de COMPRAR: `{N} de {M} no carrinho`, o total e `PEDIR O QUE FALTA 🛵`; marcar um item atualiza o contador **imediatamente** e o **total não muda**
- [ ] `RESTAURAR` existe **só** quando há override e **some no mesmo frame** em que o último é desfeito — **sem diálogo e sem toast** (A-10); os dois lados testados
- [ ] Alternar PLANEJAR ⇄ COMPRAR **preserva** checks, overrides e item expandido (aceite de UC-15)
- [ ] Lista vazia: card vazio, `R$ 0`, `≈ R$ 0 por adulto`, **faixa real ausente** da árvore, CTA **inerte** (a sheet não abre), e COMPRAR lê `0 de 0 no carrinho` com nenhum grupo
- [ ] Nada falta (tudo marcado): CTA inerte, a sheet **não** abre, **nenhum toast** (A-07) — defesa exercitada
- [ ] **Nenhum `BoraToast` na árvore**, em nenhuma ação da tela (A-23)
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 16 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(lista): monta a tela compacta de T-04`

---

### T24: `ListaExpandida` — W-04 em grid `1fr / 370px`

**What**: A tela expandida: card de itens na coluna principal e o rail sticky com segmented no topo, total, faixa/contador, "por adulto" e CTA.
**Where**: `lib/features/lista/presentation/widgets/lista_expandida.dart`
**Depends on**: T23
**Reuses**: Os mesmos widgets de corpo de T23 — **um estado, duas plataformas**; o rail de `montar` como forma, **sem tocá-lo**
**Requirement**: LIST-01, LIST-06, LIST-09, LIST-14, LIST-19, LIST-29, LIST-31

**Tools**: MCP: NONE · Skill: `run` (conferência visual em 1180×800)

**Done when**:
- [ ] Grid `1fr / 370px` (A-16 / D-3): card de itens à esquerda, rail à direita
- [ ] O rail é **sticky** e tem, **nesta ordem**: segmented → bloco de total do modo ativo → `faixa real` (PLANEJAR) *ou* `{N} de {M} no carrinho` (COMPRAR) → `≈ R$ {x} por adulto` → CTA. A ordem é afirmada por teste, não presumida
- [ ] O rodapé fixo mobile **não existe** em expandido (W-R2) — a **ausência** de `BoraFooterBar` é afirmada
- [ ] O pedido abre como **modal central** (`BoraSurface` em `showDialog`), não como bottom sheet
- [ ] O card de itens rola no documento e a página **nunca** rola horizontalmente (W-R4)
- [ ] Os mesmos números de T23 renderizam aqui: `R$ 271`, `≈ R$ 45 por adulto`, `faixa real: de R$ 245 a R$ 343` (W-R1)
- [ ] Lista vazia em expandido: card vazio, `R$ 0`, faixa ausente, CTA inerte
- [ ] `RESTAURAR` no rail segue a mesma regra de existência de T23
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 12 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(lista): monta a tela expandida de W-04 com o rail sticky`

---

### T25: `ListaPage`, fiação de rota e injeção

**What**: A página com **um** `BlocProvider` acima da escolha de layout, o `builder` de `/roles/:festaId/lista` no `app_router.dart` e o registro no `injector.dart`.
**Where**: `lib/features/lista/presentation/pages/lista_page.dart` (substitui o placeholder) · `lib/core/routing/app_router.dart` (**só** o `builder` da rota) · `lib/core/di/injector.dart` (**só** registro dos próprios)
**Depends on**: T24
**Reuses**: `layoutModeForWidth` (AD-007); `HomePage.pageKey` e o precedente E-4 de `montar`; `FestaRepositoryEmMemoria` como impl da porta
**Requirement**: LIST-15, LIST-20, LIST-30, LIST-31

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `ListaPage({festaId, festas, pedidos, logger})` + `static const pageKey`
- [ ] **Um `BlocProvider` só**, acima da escolha `ListaCompacta` / `ListaExpandida` — é o que faz LIST-30 ser verdade **por construção**, não por evento de restauração
- [ ] **Cruzar ~900px com a tela montada** preserva modo ativo, checks, overrides **e** item expandido (W-R3 / W-R1) — o teste redimensiona e afirma os quatro
- [ ] Navegar para outra rota **dentro da festa** e voltar preserva overrides e checks (aceite de UC-06 e UC-15) — a prova de LIST-15 e LIST-20 no nível da rota
- [ ] O teste de rota afirma o destino por `rotaAtual()`, **não** pelo widget montado (AD-014)
- [ ] `/roles/:festaId` continua caindo em `/roles/:festaId/lista` como default
- [ ] `/roles/**` sem sessão continua redirecionando (guarda de AD-017) — o comportamento herdado não regride
- [ ] `PedidoRepository` resolve para `PedidoFalso` no injector, e a substituição por duplo em teste é possível sem tocar a página
- [ ] Nenhum arquivo de `lib/features/{entrar,home,montar,galera,convite,convidado,custos}/**` é tocado
- [ ] Gate `full` passa; exit code conferido
- [ ] ≥ 10 testes novos

**Tests**: widget (rota)
**Gate**: full
**Commit**: `feat(lista): liga a tela da lista à rota da festa`

---

### T26: O guard que impede a fórmula de vazar

**What**: A varredura de `lib/features/lista/**` no molde de `calculo_isolation_test.dart`, **nomeando o arquivo infrator**, mais os dois testes comportamentais de `design.md` §13.
**Where**: `test/features/lista/architecture/lista_sem_formula_test.dart`
**Depends on**: T25
**Reuses**: `test/architecture/calculo_isolation_test.dart` como forma; a lição de T24 de `montar` (varredura verde contra código limpo não prova que morde)
**Requirement**: LIST-07

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Depois de remover comentários e literais de string, **nenhum** arquivo de `lib/features/lista/**` contém: (2) `.round(` `.floor(` `.ceil(` `.truncate(` `.roundToDouble(` `.toStringAsFixed(` · (3) os operadores `*` `/` `%` · (4) `.fold(` `.reduce(` `.sum` · (5) import de arquivo **interno** de `core/calculo/` ou `core/festas/` — só os barrels `calculo.dart` e `festas.dart`
- [ ] Regra (1): o literal `R$` **sem** stripping de strings. A exceção de `lista_textos.dart` decidida em T12 é **declarada e nomeada** no arquivo do guard, com o motivo — nenhuma exceção silenciosa
- [ ] **Cada uma das cinco regras tem teste próprio contra um trecho sintético infrator** que a faz falhar — o guard prova que morde
- [ ] A mensagem de falha **nomeia o arquivo infrator**
- [ ] Teste comportamental 1: composição de total fracionário (o 210,60 do padrão) → o valor exibido é comparado com **`MoneyFormatter.reais(resultado.totalComEssenciais)`**, o token, nunca o literal (L-008)
- [ ] Teste comportamental 2: a fração passada a `BoraPriceRangeBar` é comparada com **`posicaoDoMarcador(preco)`**, não com `0.379`
- [ ] Teste que afirma **zero `BoraToast`** na árvore da tela, em todos os caminhos (A-23)
- [ ] Gate `build` passa; exit code conferido
- [ ] ≥ 12 testes novos

**Tests**: unit (varredura) + widget (os dois comportamentais)
**Gate**: build
**Commit**: `test(lista): impede a fórmula e o dinheiro de vazarem para a tela`

---

### T27: As quatro abas permanentes da festa

**What**: Revestir o `FestaTabsShell`, hoje cru, com a barra das quatro abas do arquivo 01 §5 — Lista · Galera · WhatsApp · Custos.
**Where**: `lib/core/routing/festa_tabs_shell.dart` (modifica)
**Depends on**: T26
**Reuses**: `StatefulShellRoute.indexedStack` já montado (AD-003); tokens do arquivo 02; `ListaTextos` para os quatro nomes
**Requirement**: LIST-35

**Tools**: MCP: NONE · Skill: `run` (conferência visual)

**Done when**:
- [ ] O doc do arquivo abre com o **SPEC_PRECISION_GAP** declarado: nenhum arquivo de `04` nem de `06` desenha esta barra; o visual sai **só** de tokens do arquivo 02 (A-17)
- [ ] As quatro abas literais `Lista · Galera · WhatsApp · Custos`, com a aba da rota corrente **ativa**
- [ ] Acionar uma aba navega para a rota correspondente **preservando** o estado das outras — teste que ajusta um override na Lista, vai para Galera, volta e afirma o override intacto
- [ ] `/roles/:festaId/lista` aberta **diretamente** renderiza a tela por inteiro, com ou sem a barra (A-17)
- [ ] `/roles/:festaId/montar` **não** exibe a barra (não é aba permanente)
- [ ] `border-radius: 0`, sombra dura, sem gradiente, nenhum literal de cor — os invariantes do arquivo 02
- [ ] Gate `build` passa; exit code conferido
- [ ] ≥ 8 testes novos

**Tests**: widget (rota)
**Gate**: build
**Commit**: `feat(lista): reveste as quatro abas permanentes da festa`

---

## Phase Execution Map

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7

Phase 1:  T1 ──→ T2 ──→ T3 ──→ T4 ──→ T5 ──→ T6
Phase 2:  T7 ──→ T8
Phase 3:  T9 ──→ T10 ──→ T11
Phase 4:  T12 ──→ T13 ──→ T14 ──→ T15
Phase 5:  T16 ──→ T17 ──→ T18
Phase 6:  T19 ──→ T20 ──→ T21 ──→ T22
Phase 7:  T23 ──→ T24 ──→ T25 ──→ T26 ──→ T27
```

Execução estritamente sequencial — não há paralelismo dentro de fase. Um agente (ou worker de batch) faz uma task por vez, em ordem.

---

## Task Granularity Check

| Task | Escopo | Status |
|---|---|---|
| T1 | 1 seção de documento | ✅ Granular |
| T2 | 1 campo + 1 catálogo | ✅ Granular |
| T3 | 1 campo + o ponto único que o lê | ✅ Granular |
| T4 | 1 função | ✅ Granular |
| T5 | 1 valor + 1 função | ✅ Granular |
| T6 | 1 campo | ✅ Granular |
| T7 | 1 enum + 1 valor (mesmo conceito, 2 arquivos) | ⚠️ OK — o enum sem o `Pedido` não tem consumidor; separá-los deixaria um arquivo sem teste de uso |
| T8 | 1 porta + 1 adaptador | ⚠️ OK — porta sem impl não é testável; é o par mínimo |
| T9 | 1 bloc (fatia de ciclo de vida) | ✅ Granular |
| T10 | 1 bloc (fatia de override) | ✅ Granular |
| T11 | 1 bloc (fatia de carrinho e pedido) | ✅ Granular |
| T12 | 1 arquivo de copy | ✅ Granular |
| T13 | 1 widget | ✅ Granular |
| T14 | 1 widget | ✅ Granular |
| T15 | 1 widget | ✅ Granular |
| T16 | 1 widget | ✅ Granular |
| T17 | 1 widget | ✅ Granular |
| T18 | 1 widget | ✅ Granular |
| T19 | 1 bloc | ✅ Granular |
| T20 | 1 widget | ✅ Granular |
| T21 | 1 widget (2 invólucros do **mesmo** conteúdo) | ✅ Granular |
| T22 | 1 widget | ✅ Granular |
| T23 | 1 widget de tela | ✅ Granular |
| T24 | 1 widget de tela | ✅ Granular |
| T25 | 1 fiação (página + rota + injeção) | ⚠️ OK — página, rota e injeção são **a mesma** ligação; separá-las produziria código não testável |
| T26 | 1 arquivo de guard | ✅ Granular |
| T27 | 1 widget de shell | ✅ Granular |

Nenhum ❌. Os três ⚠️ são coesão legítima, não agrupamento preguiçoso — mesmo critério aceito em `montar` (T23 de lá).

**Fatiamento do `ListaBloc` em três tasks (T9, T10, T11):** é um arquivo em três commits, e é deliberado. Cada fatia fecha um conjunto de AC com teste próprio (ciclo de vida · override · carrinho e pedido) e cabe num commit revertível. Escrever o bloc inteiro numa task só produziria ~38 testes num commit e nenhuma fronteira de reversão — exatamente o que a granularidade existe para evitar.

---

## Diagram-Definition Cross-Check

| Task | Depends On (corpo) | Diagrama mostra | Status |
|---|---|---|---|
| T1 | None | (início) | ✅ Match |
| T2 | T1 | T1 → T2 | ✅ Match |
| T3 | T2 | T2 → T3 | ✅ Match |
| T4 | T3 | T3 → T4 | ✅ Match |
| T5 | T4 | T4 → T5 | ✅ Match |
| T6 | T5 | T5 → T6 | ✅ Match |
| T7 | T6 | T6 → T7 (fronteira P1→P2) | ✅ Match |
| T8 | T7 | T7 → T8 | ✅ Match |
| T9 | T8 | T8 → T9 (fronteira P2→P3) | ✅ Match |
| T10 | T9 | T9 → T10 | ✅ Match |
| T11 | T10 | T10 → T11 | ✅ Match |
| T12 | T11 | T11 → T12 (fronteira P3→P4) | ✅ Match |
| T13 | T12 | T12 → T13 | ✅ Match |
| T14 | T13 | T13 → T14 | ✅ Match |
| T15 | T14 | T14 → T15 | ✅ Match |
| T16 | T15 | T15 → T16 (fronteira P4→P5) | ✅ Match |
| T17 | T16 | T16 → T17 | ✅ Match |
| T18 | T17 | T17 → T18 | ✅ Match |
| T19 | T18 | T18 → T19 (fronteira P5→P6) | ✅ Match |
| T20 | T19 | T19 → T20 | ✅ Match |
| T21 | T20 | T20 → T21 | ✅ Match |
| T22 | T21 | T21 → T22 | ✅ Match |
| T23 | T22 | T22 → T23 (fronteira P6→P7) | ✅ Match |
| T24 | T23 | T23 → T24 | ✅ Match |
| T25 | T24 | T24 → T25 | ✅ Match |
| T26 | T25 | T25 → T26 | ✅ Match |
| T27 | T26 | T26 → T27 | ✅ Match |

Nenhuma dependência aponta para fase posterior.

---

## Test Co-location Validation

| Task | Camada criada/modificada | Matriz exige | Task diz | Status |
|---|---|---|---|---|
| T1 | Documentação / spec | none | none | ✅ OK |
| T2 | Domínio puro `core/calculo/dominio` | unit | unit | ✅ OK |
| T3 | Domínio puro + regras `core/calculo` | unit | unit | ✅ OK |
| T4 | Regras `core/calculo/regras` | unit | unit | ✅ OK |
| T5 | Regras `core/calculo/regras` | unit | unit | ✅ OK |
| T6 | Domínio puro `core/festas/dominio` | unit | unit | ✅ OK |
| T7 | Domínio da feature | unit | unit | ✅ OK |
| T8 | Domínio da feature + adaptador | unit | unit | ✅ OK |
| T9 | BLoC | unit | unit | ✅ OK |
| T10 | BLoC | unit | unit | ✅ OK |
| T11 | BLoC | unit | unit | ✅ OK |
| T12 | Copy (`lista_textos.dart`) | unit | unit | ✅ OK |
| T13 | Widget de tela | widget | widget | ✅ OK |
| T14 | Widget de tela | widget | widget | ✅ OK |
| T15 | Widget de tela | widget | widget | ✅ OK |
| T16 | Widget de tela | widget | widget | ✅ OK |
| T17 | Widget de tela | widget | widget | ✅ OK |
| T18 | Widget de tela | widget | widget | ✅ OK |
| T19 | BLoC | unit | unit | ✅ OK |
| T20 | Widget de tela | widget | widget | ✅ OK |
| T21 | Widget de tela | widget | widget | ✅ OK |
| T22 | Widget de tela | widget | widget | ✅ OK |
| T23 | Widget de tela | widget | widget | ✅ OK |
| T24 | Widget de tela | widget | widget | ✅ OK |
| T25 | Widget de tela (página) + rota + injeção | widget (rota) | widget (rota) | ✅ OK |
| T26 | Fronteira / varredura | unit (varredura) | unit + widget | ✅ OK (acima do mínimo) |
| T27 | Rota / shell | widget (rota) | widget (rota) | ✅ OK |

Nenhuma ❌ VIOLATION. **Nenhuma task adia teste para outra** — cada uma entrega o seu código já verificado.

---

## Ferramentas por task (MCP e Skills)

Não há MCP configurado neste projeto — todas as tasks usam as ferramentas nativas. As skills que se aplicam:

| Skill | Onde | Por quê |
|---|---|---|
| `tlc-spec-driven` | **todas** | O protocolo de execução, obrigatório |
| `run` | T13, T15, T17, T18, T20*, T21, T22, T23, T24, T27 | Conferência visual da tela real. **Bloqueio de acesso**: se a captura em 390×820 continuar cortando (pendência aberta desde T-02), **pular e anotar no relatório final** — não travar a task. (*T20 fica opcional: é um cartão dentro da sheet, conferido em T21) |
| `cota` | fim de cada task e de cada fase | Combinado ativo do projeto |
| `code-review` | fim de cada batch | Combinado ativo |

---

## Rastreabilidade — requisito → task

| Requisito | Task(s) |
|---|---|
| LIST-01 | T12, T23, T24 |
| LIST-02 | T12, T23 |
| LIST-03 | T13, T15 |
| LIST-04 | T4, T12, T15 |
| LIST-05 | T15, T23 |
| LIST-06 | T23, T24 |
| LIST-07 | T26 |
| LIST-08 | T13 |
| LIST-09 | T5, T23, T24 |
| LIST-10 | T9, T13, T15 |
| LIST-11 | T10, T14 |
| LIST-12 | T13 |
| LIST-13 | T10 |
| LIST-14 | T10, T23, T24 |
| LIST-15 | T10, T25 |
| LIST-16 | T12, T18 |
| LIST-17 | T2, T18 |
| LIST-18 | T16, T17 |
| LIST-19 | T23, T24 |
| LIST-20 | T3, T11, T25 |
| LIST-21 | T19, T21 |
| LIST-22 | T7, T12, T20, T21 |
| LIST-23 | T19, T21 |
| LIST-24 | T19, T20 |
| LIST-25 | T19, T21, T23 |
| LIST-26 | T12, T22 |
| LIST-27 | T6, T11 |
| LIST-28 | T8, T19, T22 |
| LIST-29 | T24 |
| LIST-30 | T25 |
| LIST-31 | T9, T23, T24 |
| LIST-32 | T9, T11, T19 |
| LIST-33 | T11, T19 |
| LIST-34 | T11 |
| LIST-35 | T27 |

**Cobertura**: 35 de 35 requisitos com task dona. **0 órfãos**, **0 tasks sem requisito** (T1 é pré-condição estrutural declarada de LIST-15/20/27).

---

## Desvios e lacunas que o Execute tem de manter declarados

Vêm do `design.md` §14 e **não podem ser silenciados** durante a implementação:

| Tipo | O quê | Task que o declara |
|---|---|---|
| SPEC_DEVIATION | Cinco emendas em camada declarada fechada (E-a..E-e), contra as duas previstas | T2, T3, T4, T5, T6 — no doc de cada arquivo tocado |
| SPEC_DEVIATION | `Pedido` e os parceiros ficam na feature, não em `core/calculo/dominio/` (AD-008) | T7 |
| SPEC_DEVIATION | Layout web em grid `1fr / 370px` em vez de "dentro do rail de W-03" (D-3 / A-16) | T24 |
| SPEC_DEVIATION | Três acentos na tela contra os 2 do arquivo 02 §8 (D-4 / A-22) | T23 |
| SPEC_PRECISION_GAP | Falha ao gravar não tem copy — a evidência é o estado preservado + o log | T11 |
| SPEC_PRECISION_GAP | Falha do pedido não tem copy nem toast — a evidência é a ausência de overlay e de despesa + o log | T19 |
| SPEC_PRECISION_GAP | `FestaTabsShell` sem desenho em `04` nem `06`; o visual sai só de tokens | T27 |
| Ressalva de produto | A tela afirma "PEDIDO A CAMINHO!" sem pedido (AD-024) — **o produto não vai a público com esta tela ativa** sem revisitar a decisão | T8 (no doc de `PedidoFalso`), T22 |
| Herdado, sem dono | `ItemDeLista.quemLeva` continua sem UI que o escreva (AD-018) | — |

---

## Success Criteria da feature (da `spec.md`, conferidos ao fim)

- [ ] `flutter analyze` zero issues · suíte verde · baseline do merge de `montar` preservada, **+ ~230 testes novos**
- [ ] **Aceite de UC-05 na tela**: os quatro essenciais de RN-10 presentes sem ação do usuário, com badge `AUTO ∝`, rodapé lendo `R$ 271` e `≈ R$ 45 por adulto`
- [ ] **Aceite de UC-14 na tela**: marcador em `(média−mín)/(máx−mín)` — 37,9% na Picanha, extremos R$ 54 e R$ 83 — e a regra da faixa aplicada à tabela devolvendo R$ 286 / R$ 234–356
- [ ] **Aceite de UC-06 na tela**: passos e mínimos de RN-12, ponto vermelho, total ao vivo, RESTAURAR que zera e some, override sobrevivendo à navegação dentro da festa
- [ ] **Aceite de UC-15 na tela**: cinco corredores na ordem de RN-27, check verde a 45% de opacidade, contador correto, check sobrevivendo ao alternar PLANEJAR ⇄ COMPRAR
- [ ] **Aceite de UC-16 na tela**: Total = Subtotal + Frete nos três parceiros, Zé com frete grátis, overlay com ETA e "rachado no acerto da festa", `Despesa` criada com o total (R$ 283)
- [ ] Guard de LIST-07 verde, com as cinco regras provadas contra trecho infrator e a única exceção nomeada
- [ ] W-04 funcional: grid `1fr / 370px`, rail sticky com segmented no topo, modal central, zero scroll horizontal, sem rodapé fixo
- [ ] Festa sem ninguém: card vazio, R$ 0, CTA inerte, sem copy inventada
- [ ] Nenhum toast novo, nenhuma copy fora das specs 03, 04 e 06
- [ ] AD-030 registrada no `STATE.md`, depois da AD-029
