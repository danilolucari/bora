# Cálculo — Validation

**Data**: 2026-08-25
**Spec**: `.specs/features/calculo/spec.md` (CALC-01..CALC-27)
**Diff range**: `c5be425..62c5537` (merge-base `main` → HEAD de `feature/calculo`) — 32 commits: 3 de docs + 28 de task + 1 de esqueleto de validação
**Verifier**: sub-agente independente (autor ≠ verificador), **evidence-or-zero** — re-derivado do `spec.md`, nenhuma alegação de `tasks.md` aceita
**SDK**: Flutter 3.47.1 · Dart 3.13.1 (`C:/SDKs/flutter/bin/flutter`) · Windows 11 + Git Bash
**Worktree**: `C:/repos/lucari/bora-calculo`, branch `feature/calculo`

---

## Veredito

### ✅ **PASS com ressalvas** — nenhum gap bloqueia o merge

A camada faz o que a spec manda. **Os quatro números canônicos do arquivo 03
fecham exatamente** — R$ 211, ≈R$ 30/cabeça, R$ 271, ≈R$ 45/adulto — e os
**Testes A e B de RN-16 saem linha a linha e na ordem certa**, com a ordem
provada como comportamento observável, não como coincidência: a mutação que
ordena credores e devedores por valor (o risco R-2 do design, o "melhoramento"
mais provável que um executor faria) **mata cinco testes**, inclusive a guarda
`isNot([…])` de `casos_literais…:325`. A pergunta do orquestrador sobre essa
guarda tem resposta empírica: **ela morde**.

Sensor executado do zero, sem ler os self-checks dos autores: **17 mutações
comportamentais, 15 mortas**. Dos 2 sobreviventes, um é **equivalente** (não
existe teste capaz de matá-lo) e o outro é um **furo de sensor sobre
comportamento que já está correto** — nenhum dos dois é um defeito de
comportamento no código entregue.

Dos **60 critérios de aceite**, 58 têm prova automatizada ancorada em
`file:line`, 1 é parcial e **1 está sem evidência** (P1-2 AC2 — igualdade de
valor em `ComposicaoDaFesta` e `PrecoDeMercado`). Dos 16 edge cases da spec, 14
plenamente cobertos e 2 com ressalva. Portão verde em **425 testes** e
`flutter analyze` limpo, reexecutado depois de todas as mutações.

**O que mais merece a atenção do dono do projeto não é um bug — é uma decisão
prestes a ser gravada com uma premissa falsa.** A candidata **AD-009** justifica
a política de precisão com *"`(1.15 * 10).round()` devolve 11"*. Em Dart isso é
**falso**: devolve 12, e uma varredura de 2 milhões de pontos mostra que as duas
políticas de arredondamento **nunca divergem**. O código está certo; a razão
declarada não está. Vale corrigir o texto antes de o AD entrar no `STATE.md`
(G-3).

**Disciplina de fronteira: exemplar.** Nada fora de `lib/core/calculo/`,
`test/core/calculo/` e `test/fixtures/rn30_estado_inicial_tipado*` foi tocado em
32 commits; `pubspec.yaml` e o território da spec 01 intactos; a fixture bruta da
fundação com **zero linhas alteradas**, e a contagem de testes subiu 92 → 425 sem
nunca cair. Zero dependência nova.

**Gaps ranqueados** (nenhum bloqueante): **G-1** igualdade de valor faltando em 2
entidades · **G-2** sensor incompleto na tolerância de centavo · **G-3**
premissa falsa em AD-009 · **G-5** doc do barrel reivindicando RN fora de escopo
· **G-4** um commit fora do padrão. Nenhum foi consertado pelo verificador.

---

## Task Completion

As caixas `[x]` de `tasks.md` **não foram aceitas como prova**. Cada task foi
conferida pelo artefato que ela promete entregar (arquivo existente, símbolo
exportado, teste nomeando o `CALC-xx`) e pelo commit correspondente.

| Task | Entrega prometida | Conferido | Status |
|---|---|---|---|
| T1 | `Pessoa` + 4 enums, `dieta`/`bebe` anuláveis | `dominio/{dieta,papel_na_festa,status_de_presenca,status_da_festa,pessoa}.dart` + `pessoa_test.dart` (15 testes) · commit `9f4401b` | ✅ Done |
| T2 | `Festa` sem `link`/`nivelDoLink` | `dominio/festa.dart` + `festa_test.dart` (5) · `732c44c` | ✅ Done |
| T3 | `ContagemDePessoas` com `ArgumentError` | `dominio/contagem_de_pessoas.dart` + 11 testes · `0f2946c` | ✅ Done |
| T4 | `fatorDuracao` | `regras/fator_duracao.dart` + 6 testes · `58ceafd` | ✅ Done |
| T5 | 3 primitivas de precisão | `regras/precisao.dart` + 13 testes · `d58ba0e` | ✅ Done (ver G-3 quanto à **justificativa**, não à entrega) |
| T6 | `MoneyFormatter` + `rotuloDeDuracao` | `formatacao/` + 15 testes · `ce131e7` | ✅ Done |
| T7 | `ChaveItem`, `UnidadeDeItem`, catálogo dos 16 | `dominio/{chave_item,catalogo_de_itens}.dart` + 28 testes · `3596567` | ✅ Done |
| T8 | `ItemDeLista` + `OverrideDeItem` | `dominio/item_de_lista.dart` + 15 testes · `c38b5b7` | ✅ Done |
| T9 | RN-03 | `regras/quantidade_de_carne.dart` + 12 testes · `fd1fec7` | ✅ Done |
| T10 | RN-04, RN-08 | `regras/quantidades_por_pessoa.dart` + 11 testes · `dbb58ca` | ✅ Done |
| T11 | RN-06, RN-07 | `regras/quantidades_de_bebida.dart` + 12 testes · `6ed493a` | ✅ Done |
| T12 | RN-05 com `adultosQueBebem` | `regras/quantidade_de_cerveja.dart` + 8 testes · `da9b45c` | ✅ Done |
| T13 | RN-09 | `regras/quantidade_de_destilado.dart` + 8 testes · `00c50ec` | ✅ Done |
| T14 | RN-10 + `entraNoTotal` | `regras/essenciais.dart` + 9 testes · `30e0d29` | ✅ Done |
| T15 | RN-21 | `regras/preferencias.dart` + 15 testes · `8b80932` | ✅ Done |
| T16 | `ComposicaoDaFesta` + orquestrador | `dominio/composicao_da_festa.dart`, `regras/calculadora_da_festa.dart` + 16 testes · `cdf95fd` | ⚠️ **Done com ressalva** — `ComposicaoDaFesta` entregue sem `==`/`hashCode`/`copyWith` (G-1) |
| T17 | Totais + os casos literais R$ 211 / R$ 271 | `regras/totais.dart` + `casos_literais_do_arquivo_03_test.dart` · `98bd75b` | ✅ Done |
| T18 | RN-12 | `regras/overrides.dart` + 12 testes · `a1a6a65` | ✅ Done |
| T19 | `Despesa` + contribuições | `dominio/despesa.dart`, `regras/contribuicoes.dart` + 14 testes · `e780f94` | ✅ Done |
| T20 | Cota + saldos | `regras/{cota,saldos}.dart`, `dominio/saldo_de_pessoa.dart` + 17 testes · `413cedd` | ✅ Done |
| T21 | `calcularRacha` + Testes A e B | `regras/quem_paga_quem.dart`, `dominio/linha_de_acerto.dart` + 17 testes · `88c7005` | ⚠️ **Done com ressalva** — comportamento correto, sensor incompleto na tolerância (G-2) |
| T22 | RN-17 | `regras/split_de_despesa.dart` + 6 testes · `096fa3d` | ✅ Done |
| T23 | RN-18 | `regras/quitacao.dart` + 7 testes · `e2a3be3` | ✅ Done |
| T24 | Tabela RN-11, 8 linhas | `dominio/{corredor,preco_de_mercado,tabela_de_precos_de_mercado}.dart` + 9 testes · `5c9a7ed` | ⚠️ **Done com ressalva** — `PrecoDeMercado` sem `==` (G-1) |
| T25 | Marcador + faixa | `regras/faixa_de_preco.dart` + 11 testes · `d19414a` | ✅ Done |
| T26 | Totais do pedido | `regras/total_do_pedido.dart` + 9 testes · `bb79361` | ✅ Done |
| T27 | Barrel como porta única | `calculo.dart` + `calculo_test.dart` (5) · `966b492` — a varredura de `:83` exige **todo** arquivo exportado (M14 confirma) | ✅ Done |
| T28 | Fixture RN-30 tipada, sem tocar no bruto | `test/fixtures/rn30_estado_inicial_tipado{,_test}.dart` (14 testes) · `2735a13`; bruto com **0 linhas alteradas** | ✅ Done |

**28/28 tasks entregues** · 3 com ressalva rastreada a gap · **0 pendentes** ·
**0 verificações manuais (M)** — a camada é Dart puro e roda inteira em
`flutter test`, como `tasks.md:15` previu.

---

## Critérios de aceite — evidência ancorada na spec

Re-derivados **do `spec.md`**, história por história, sem consultar o que o
`tasks.md` alega. Critério sem `file:line` + expressão de asserção conta como
**NÃO COBERTO**. Todos os caminhos são relativos à raiz da worktree.

### P1-1 · Contagem, tempo e formatação (7 ACs)

| # | Resultado que a spec exige | Evidência (`file:line` + asserção) | Result |
|---|---|---|---|
| AC1 | `adultos = H+M`, `pessoas = adultos+C`; 3H+3M+1C → 6 / 7 | `test/core/calculo/dominio/contagem_de_pessoas_test.dart:14-15` — `expect(contagem.adultos, 6); expect(contagem.pessoas, 7)` | ✅ PASS |
| AC2 | Contagem negativa rejeitada com erro de argumento | `contagem_de_pessoas_test.dart:35,39,43` — `expect(() => ContagemDePessoas(homens: -1), _recusaCampo('homens'))` (idem `mulheres`, `criancas`); `:49` cobre `copyWith` | ✅ PASS |
| AC3 | 2h→0.5 · 4h→1.0 · 6h→1.5 · 10h→2.5 | `test/core/calculo/regras/fator_duracao_test.dart:7,11,15,19` — `expect(fatorDuracao(2), 0.5)` … `expect(fatorDuracao(10), 2.5)` | ✅ PASS |
| AC4 | `< 2h` (0 inclusive) → exatamente 0.5 | `fator_duracao_test.dart:25,29` — `expect(fatorDuracao(1), 0.5); expect(fatorDuracao(0), 0.5)` | ✅ PASS |
| AC5 | 210.6→`R$ 211` · 30.14→`R$ 30` · 1234→`R$ 1.234` · 0→`R$ 0` | `test/core/calculo/formatacao/money_formatter_test.dart:15,11,29,7` — `expect(MoneyFormatter.reais(210.6), r'R$ 211')` etc.; `:23` cobre 30,5→`R$ 31` (meio afastado do zero) e `:33` o milhão | ✅ PASS |
| AC6 | Nunca centavos nem separador decimal | `money_formatter_test.dart:47-56` — laço sobre 8 valores com `expect(MoneyFormatter.reais(valor), isNot(contains(',')))` | ✅ PASS |
| AC7 | `2/4/6 horas` e 10 → `Dia todo` | `test/core/calculo/formatacao/rotulo_de_duracao_test.dart:7,11,15,19` — `expect(rotuloDeDuracao(10), 'Dia todo')` | ✅ PASS |

### P1-2 · Entidades de domínio compartilhadas (5 ACs)

| # | Resultado que a spec exige | Evidência (`file:line` + asserção) | Result |
|---|---|---|---|
| AC1 | Existem as 9 entidades + 8 enums nomeados na spec | Enums: `dominio/pessoa_test.dart:28-51` (`Dieta`, `PapelNaFesta`, `StatusDePresenca`, `StatusDaFesta` — chaves literais do arquivo 01 §6), `dominio/chave_item_test.dart:8,75` (`ChaveItem` 16 valores, `UnidadeDeItem` 7), `dominio/tabela_de_precos_de_mercado_test.dart:50` (`Corredor`), `regras/saldos_test.dart:97-129` (`SituacaoDeSaldo`). Entidades: `pessoa_test.dart:62`, `festa_test.dart:16`, `contagem_de_pessoas_test.dart:54`, `item_de_lista_test.dart:81`, `despesa_test.dart:19`, `saldos_test.dart:161`, `quem_paga_quem_test.dart:216`, `tabela_de_precos_de_mercado_test.dart:32`. **`ComposicaoDaFesta` só aparece como insumo de outros testes** (`calculo_test.dart:14`, `casos_literais…:23`, `totais_test.dart:89,110`) — sem teste que a nomeie | ⚠️ **PARCIAL** |
| AC2 | Duas entidades com os mesmos campos são `==` e têm o mesmo `hashCode` | Provado para 7 das 9: `contagem_de_pessoas_test.dart:58-59`, `pessoa_test.dart:62`, `festa_test.dart:16`, `item_de_lista_test.dart:81`, `despesa_test.dart:19`, `saldos_test.dart:161`, `quem_paga_quem_test.dart:216`. **`ComposicaoDaFesta` e `PrecoDeMercado` não implementam `==`/`hashCode`** (`grep -c 'bool operator =='` → ausente nos dois arquivos) e nenhum teste afirma igualdade delas | ❌ **NÃO COBERTO** (gap G-1) |
| AC3 | Cópia com campo alterado não muta a original | `contagem_de_pessoas_test.dart:67-70` — `expect(comMaisUmaCrianca.pessoas, 8); expect(contagem.pessoas, 7)`; `pessoa_test.dart:80`, `festa_test.dart:33`, `item_de_lista_test.dart:95`, `quem_paga_quem_test.dart:204`. Campos `final` em todas; entidades sem `copyWith` (`Despesa`, `SaldoDePessoa`, `PrecoDeMercado`, `ComposicaoDaFesta`) tornam o AC vacuamente verdadeiro | ✅ PASS |
| AC4 | `dieta`/`bebe` desconhecidos são `null`, e `null ≠ false` / `≠ tudo` | `pessoa_test.dart:103` (Duda nasce sem os dois), `:108` — `bebe null` distinto de `false`, `:115` — `dieta null` distinta de `Dieta.tudo` | ✅ PASS |
| AC5 | Todo arquivo de `core/calculo/` é Dart puro; o teste de isolamento continua verde | `test/architecture/calculo_isolation_test.dart:44-50` — `expect(violacoesEm(Directory('lib/core/calculo')), isEmpty)`; o próprio arquivo se auto-testa em `:61-74`, criando um infrator real e exigindo que ele seja reportado | ✅ PASS (mutação M9 confirma que morde) |

### P1-3 · Quantidades automáticas da calculadora (12 ACs)

| # | Resultado que a spec exige | Evidência (`file:line` + asserção) | Result |
|---|---|---|---|
| AC1 | Gramas `(H×400+M×300+C×200)×f`, divididas; `kg = max(0,5; →0,1kg)`; 2300÷2 → **1,2 kg** | `regras/quantidade_de_carne_test.dart:11` (2300 g), `:19` (pesos por sexo/criança), `:57` (1,2 kg de cada), `:66` — `expect(kgPorCarne(gramasTotais: 1150, carnesSelecionadas: 1), 1.2)` | ✅ PASS |
| AC2 | Bovina 1,2 kg → R$ 54,00 e Frango → R$ 21,60, exibidos `R$ 54` / `R$ 22` | `casos_literais_do_arquivo_03_test.dart:145-146` — `expect(dinheiro(ChaveItem.bovina), 'R\$ 54'); expect(dinheiro(ChaveItem.frango), 'R\$ 22')`; `:157-162` fixa o 21,60 exato | ✅ PASS |
| AC3 | Sem carne selecionada: nenhum item, valor 0, sem divisão por zero | `quantidade_de_carne_test.dart:82` — `expect(kgPorCarne(gramasTotais: 2300, carnesSelecionadas: 0), 0.0)`; `calculadora_da_festa_test.dart:180` (sem porco na única carne ≡ nenhuma carne) | ✅ PASS |
| AC4 | Pão `max(1, ceil(pessoas×0,5×f))` a R$ 6; 7 pessoas → **4 un / R$ 24** | `regras/quantidades_por_pessoa_test.dart:7` (4 un), `:16,20,24` (pisos e ceil); valor em `casos_literais…:147` — `expect(dinheiro(ChaveItem.paoDeAlho), 'R\$ 24')` | ✅ PASS |
| AC5 | Cerveja `max(1, ceil(bebem×1000×f/350))` a R$ 4; 6 adultos → **18 latas / R$ 72** | `regras/quantidade_de_cerveja_test.dart:7` (18 latas), `:35,43` (fronteiras exatas de 1 e 10 latas); valor em `casos_literais…:150` | ✅ PASS |
| AC6 | Refri `max(1, ceil((A×400+C×500)×f/2000))` a R$ 9; 6A+1C → **2 gf / R$ 18** | `regras/quantidades_de_bebida_test.dart:6` (2 garrafas), `:14` (2000 ml exatos), `:22` (criança pesa 500) ; valor em `casos_literais…:148` | ✅ PASS |
| AC7 | Suco `max(1, ceil((A×250+C×400)×f/1000))` a R$ 8/L | `quantidades_de_bebida_test.dart:44,52,60,64,72,76` — 2 L no padrão, 250/adulto, 400/criança, fronteira de 1000 ml e piso | ✅ PASS |
| AC8 | Água `max(1, ceil(pessoas×400×f/1500))` a R$ 3; 7 pessoas → **2 gf / R$ 6** | `quantidades_por_pessoa_test.dart:38` (2 garrafas), `:54` (1500 ml exatos), `:50` (piso); valor em `casos_literais…:149` | ✅ PASS |
| AC9 | Destilado `ml = adultos×120×f/n`; `max(1, ceil(ml/1000))`; cachaça R$ 15; 6 adultos → 720 ml → **1 gf / R$ 15** | `regras/quantidade_de_destilado_test.dart:7` (1 garrafa), `:19` (dois destilados dividem os mesmos 720 ml), `:31` (10 adultos → 2 gf), `:55` (litro exato não vira 2); preço em `dominio/catalogo_de_itens_test.dart:36` e valor em `casos_literais…:151` | ✅ PASS |
| AC10 | Consumível só-de-adulto com `adultos == 0` → quantidade 0, item fora da lista | `quantidade_de_cerveja_test.dart:53,62` — `expect(latasDeCerveja(adultosQueBebem: 0, fator: 2.5), 0)`; `quantidade_de_destilado_test.dart:69,82`; efeito na lista em `calculadora_da_festa_test.dart:229` | ✅ PASS |
| AC11 | Os 4 essenciais entram sozinhos, marcados, com a fonte da proporção literal | `regras/essenciais_test.dart:11` (são quatro, na ordem), `:23` (defaults 1/3/1/1), `:46` (`essencial: true`), `:52` (cada `fonteDaProporcao` literal de RN-10) | ✅ PASS |
| AC12 | Total dos essenciais soma **só** `entraNoTotal` → **R$ 60**; Copos & pratos visível e fora | `essenciais_test.dart:67` (soma exatamente 60), `:75` (na lista e fora do total), `:96` (sozinho não soma nada); dado declarado em `dominio/catalogo_de_itens_test.dart:158` — copos & pratos é o **único** item fora do total | ✅ PASS |

### P1-4 · Lista calculada, preferências e custo ao vivo (13 ACs)

| # | Resultado que a spec exige | Evidência (`file:line` + asserção) | Result |
|---|---|---|---|
| AC1 | Estado padrão → total **R$ 211** e **≈ R$ 30/cabeça** | `casos_literais_do_arquivo_03_test.dart:170-175` — `expect(resultado.totalDosItens, closeTo(210.6, 0.001)); expect(MoneyFormatter.reais(...), 'R\$ 211')`; `:181-183` — `expect(resultado.contagem.pessoas, 7); expect(resultado.porCabeca, closeTo(30.0857, 0.001)); expect(..., 'R\$ 30')` | ✅ PASS |
| AC2 | Com os essenciais → **R$ 271** e **≈ R$ 45/adulto** (os **dois** números) | `casos_literais…:206-211` — `expect(resultado.totalComEssenciais, closeTo(270.6, 0.001))` + string `R$ 271`; `:217-219` — `expect(resultado.contagem.adultos, 6); expect(resultado.porAdulto, closeTo(45.1, 0.001))` + string `R$ 45` | ✅ PASS |
| AC3 | Ordem canônica do catálogo, estável entre execuções | `regras/calculadora_da_festa_test.dart:56` (os sete chips na ordem canônica), `:103` (duas chamadas devolvem a mesma lista, na mesma ordem); `dominio/catalogo_de_itens_test.dart:175,180` (a ordem cobre o catálogo sem repetir e fecha nos essenciais) | ✅ PASS |
| AC4 | ≥1 veggie → kit de legumes (1 kit, R$ 28) | `regras/preferencias_test.dart:33` (`incluirKitVeggie`), `calculadora_da_festa_test.dart:128` (o kit entra na lista), `:137` (sem veggie não aparece); preço em `catalogo_de_itens_test.dart:42` | ✅ PASS |
| AC5 | ≥1 "sem porco" → suína sai e as gramas se redividem | `calculadora_da_festa_test.dart:146` — tira a suína **e** redivide as gramas entre as restantes; `:180` — sem porco na única carne ≡ nenhuma carne | ✅ PASS |
| AC6 | Cerveja por `adultosQueBebem = max(0, adultos − abstêmios)`; sem nomeados usa `adultos` | `preferencias_test.dart:18` (sem nomeados, RN-05 intacta), `:83` (1 abstêmio entre 6 → base 5), `:105` (mais abstêmios que adultos → 0, nunca negativo); efeito na lista em `calculadora_da_festa_test.dart:199` | ✅ PASS |
| AC7 | `bebe == null` / `dieta == null` não contam como abstêmio nem veggie | `preferencias_test.dart:92` (a Duda não reduz a cerveja), `:65` (dieta não declarada não conta) | ✅ PASS |
| AC8 | `pessoas == 0` → lista vazia, totais 0, nenhum piso `max(1,…)` | `calculadora_da_festa_test.dart:213` — lista vazia sem nenhum piso; `regras/totais_test.dart:87` — total, estimativas e essenciais em 0 | ✅ PASS |
| AC9 | Mesma composição calculada duas vezes → resultados iguais | `test/core/calculo/calculo_test.dart:57` — duas passadas produzem itens, essenciais e totais idênticos; `:73` — composições iguais construídas em separado dão o mesmo total | ✅ PASS |
| AC10 | Passo 0,5 kg carnes · 2 latas cerveja · 1 demais, mínimo = um passo | `regras/overrides_test.dart:23,30,37` (subida) e `:53,60,67` (descida trava em 0,5 kg / 2 latas / 1); passos declarados em `catalogo_de_itens_test.dart:88,94,98` | ✅ PASS |
| AC11 | Preço: passo R$ 1, mínimo R$ 1 | `overrides_test.dart:76` (sobe um real por passo), `:82` — trava em R$ 1, nunca zera nem fica negativo | ✅ PASS |
| AC12 | Override → `editado`; restaurar volta exatamente ao automático e desmarca | `overrides_test.dart:103` (nasce não editado, vira editado), `:111` (restaurar devolve exatamente o valor automático e apaga os dois), `:133` (restaurar não zera o resto); `item_de_lista_test.dart:67,71,75` | ✅ PASS |
| AC13 | Lista informa se há overrides a restaurar | `calculadora_da_festa_test.dart:307` (informa que há) e `:317` (sem ajuste, não há o que restaurar) | ✅ PASS |

### P1-5 · Racha e acerto (14 ACs)

| # | Resultado que a spec exige | Evidência (`file:line` + asserção) | Result |
|---|---|---|---|
| AC1 | Contribuição = itens assumidos + despesas adiantadas | `regras/contribuicoes_test.dart:26` (só itens), `:49` (só despesas), `:62` (as duas somam na mesma pessoa) | ✅ PASS |
| AC2 | Sem item atribuído → contribuição 0, presente no mapa | `contribuicoes_test.dart:85` (fica no mapa com 0,0), `:98` (item sem dono não entra em ninguém), `:111` (nome fora dos participantes é ignorado) | ✅ PASS |
| AC3 | `cota = total ÷ adultos`, criança de fora; 320/4 → **80** | `regras/cota_test.dart:6` (320÷4 = 80), `:10` (380÷4 = 95), `:14` — o divisor são os adultos, nunca as pessoas | ✅ PASS |
| AC4 | `adultos == 0` → cota 0, sem `NaN`/`Infinity` | `cota_test.dart:30` — sem adulto a cota é 0, nunca NaN nem Infinity; `:38` (total zero) | ✅ PASS |
| AC5 | `saldo = contribuição − cota`; tags recebe/paga/no zero na tolerância | `regras/saldos_test.dart:7,27` (saldos dos Testes A e B), `:97,108,119` (as três tags), `:130` (resíduo de meio centavo é "no zero"), `:148` (meio real já é saldo de verdade) | ✅ PASS |
| AC6 | **Teste A**: `LÉO→VOCÊ 80 · BIA→VOCÊ 40 · BIA→ANA 40`, nesta ordem | `casos_literais_do_arquivo_03_test.dart:284-288` — `expect(_acerto(linhas), ['LÉO → VOCÊ · R$ 80', 'BIA → VOCÊ · R$ 40', 'BIA → ANA · R$ 40'])` (lista ordenada: igualdade de `List` é posicional); insumos afirmados em `:252-265` (200/120/0/0, total 320) e `:271` (cota `R$ 80`). Duplicado em `regras/quem_paga_quem_test.dart:24` | ✅ PASS |
| AC7 | **Teste B**: `LÉO→RAFA 35 · BIA→RAFA 70 · BIA→ANA 25`, nesta ordem | `casos_literais…:318-322` — `expect(_acerto(linhas), ['LÉO → RAFA · R$ 35', 'BIA → RAFA · R$ 70', 'BIA → ANA · R$ 25'])`; insumos em `:296-300` (380 e cota `R$ 95`) e `:306-311` (+105/+25/−35/−95, com a ordem dos nomes afirmada). Duplicado em `quem_paga_quem_test.dart:59` | ✅ PASS |
| AC8 | Ordem de entrada, nunca reordenada por valor | `casos_literais…:329-338` — `expect(_acerto(linhas), isNot(['BIA → RAFA · R$ 95', 'LÉO → RAFA · R$ 10', 'LÉO → ANA · R$ 25']))`; **a prova forte está em** `quem_paga_quem_test.dart:100` (trocar a ordem dos credores muda as linhas) e `:120` (o Teste B começa por LÉO, o menor credor). Ver nota de discriminação abaixo | ✅ PASS |
| AC9 | Soma paga = soma recebida; nenhuma linha ≤ 1 centavo | `casos_literais…:343-356` (laço sobre os dois testes, `expect(pago, closeTo(devido, 0.001))` e `closeTo(aReceber, …)`); `quem_paga_quem_test.dart:178` — nenhuma linha emitida vale um centavo ou menos | ✅ PASS |
| AC10 | Sem credores / sem devedores / lista vazia → lista vazia, sem lançar | `quem_paga_quem_test.dart:140,144,148,152` — vazia, só credores, só devedores, todos no zero | ✅ PASS |
| AC11 | Split expõe valor por adulto e N | `regras/split_de_despesa_test.dart:7` (80÷4 = 20), `:50` (N volta junto para a copy), `:77` (divisor são os adultos, criança de fora), `:38` (`adultos == 0` → 0) | ✅ PASS |
| AC12 | Progresso expõe `pagas`, `total`, `valorPago`, `valorDevido`, `fracao` | `regras/quitacao_test.dart:14` (0.0), `:22` (todas pagas → 1.0), `:34` (é dinheiro, não contagem), `:57` (N de M), `:69` (`valorDevido` soma pagas e pendentes) | ✅ PASS |
| AC13 | Sem linhas → fração 1.0, `pagas = 0`, `total = 0` | `quitacao_test.dart:110` — a barra fica cheia, com 0 de 0 | ✅ PASS |
| AC14 | Alternância pendente ⇄ paga reversível e refletida | `quitacao_test.dart:87` — desmarcar devolve o progresso de antes; `quem_paga_quem_test.dart:204` — `copyWith` marca como paga sem mexer em quem paga quem nem quanto | ✅ PASS |

### P2-1 · Preço médio real e total do pedido (5 ACs)

| # | Resultado que a spec exige | Evidência (`file:line` + asserção) | Result |
|---|---|---|---|
| AC1 | As 8 linhas de RN-11, literais (item, corredor, qtd, média, mín, máx, fontes) | `dominio/tabela_de_precos_de_mercado_test.dart:13` (8 itens, ordem, emoji e nome), `:32` (média/mín/máx/fontes), `:50` (corredores), `:66` (rótulo de quantidade literal) | ✅ PASS |
| AC2 | Total média **R$ 286**, faixa **R$ 234 – R$ 356** | `regras/faixa_de_preco_test.dart:69` (média 286), `:73` (faixa 234–356), `:80` (cada total soma a própria coluna) | ✅ PASS |
| AC3 | `(média−mín)/(máx−mín)`, em `[0,1]`; Picanha → 11/29 ≈ 0.379 | `faixa_de_preco_test.dart:29` (0,379), `:34,38` (mín e máx), `:51,55` (clamp), `:59` (toda linha de RN-11 cai em [0,1]) | ✅ PASS |
| AC4 | `máx == mín` → 0.0, sem divisão por zero | `faixa_de_preco_test.dart:42` — devolve 0.0 em vez de dividir por zero | ✅ PASS |
| AC5 | `total = subtotal + frete`; frete 0 → total = subtotal | `regras/total_do_pedido_test.dart:82` (soma o frete), `:90` (frete grátis deixa o total igual ao subtotal); `:35,39,44` (subtotal) e `:64,72` ("PEDIR O QUE FALTA") | ✅ PASS |

### P1-6 · Superfície pública e fixture tipada (4 ACs)

| # | Resultado que a spec exige | Evidência (`file:line` + asserção) | Result |
|---|---|---|---|
| AC1 | Importar **só** o barrel basta para reproduzir R$ 211 | `test/core/calculo/calculo_test.dart:30` — o caso literal se reproduz importando apenas o barrel (o arquivo tem um único import de produção, `calculo.dart`); `:41` — os dois contratos de fronteira chegam prontos; `:83` — varredura que exige **todo** `.dart` de `dominio/`, `regras/` e `formatacao/` exportado | ✅ PASS |
| AC2 | Fixture tipada devolve `Festa`, `List<Pessoa>`, `List<ChaveItem>` derivados do bruto | `test/fixtures/rn30_estado_inicial_tipado_test.dart:21` (festa campo a campo), `:45,56,69,82,89,96` (as 5 pessoas, papéis, status, dietas, bebida, o "você"), `:155` (7 itens na ordem de RN-30), `:184` — **o arquivo tipado não repete nenhum literal de RN-30** (prova a derivação, não a cópia) | ✅ PASS |
| AC3 | `dieta` e `bebe` da Duda chegam `null` | `rn30_estado_inicial_tipado_test.dart:108` (null, não default fabricado), `:127` (tipar não fez as chaves aparecerem no bruto), `:139` (ausente ≠ desconhecida) | ✅ PASS |
| AC4 | A suíte antiga da fixture continua valendo, sem enfraquecimento | `git diff --stat c5be425..HEAD -- test/fixtures/rn30_estado_inicial.dart test/fixtures/rn30_estado_inicial_test.dart` → **vazio**: nenhum dos dois arquivos foi tocado em 32 commits | ✅ PASS |

### Placar

**58 de 60 ACs** com prova automatizada ancorada na spec · **1 ⚠️ parcial**
(P1-2 AC1) · **1 ❌ sem evidência** (P1-2 AC2) · **0 falhando**.

---

## Sensor de discriminação

**Protocolo, cumprido em todas as 17 mutações**: `git status` limpo antes →
editar código de produção (comportamento real, nunca typo) → rodar a suíte que
deveria pegar → `git checkout -- <arquivo>` **imediato** → `git status`
conferido. Nenhum commit em nenhum momento. Estado final auditado ao fim da
tabela.

Os "self-checks de discriminação" relatados pelos batch workers no `tasks.md`
**não foram lidos nem considerados** — cada mutação abaixo foi desenhada e
executada do zero pelo verificador.

| # | `file:line` | Mutação (o comportamento que quebra) | Reação da suíte | Killed? |
|---|---|---|---|---|
| **M1** | `lib/core/calculo/regras/precisao.dart:22` | **Arredondar em kg em vez de em gramas** — `(gramas/100).round()/10` → `(gramas/1000*10).round()/10`, exatamente a política que AD-009 e o risco R-1 declaram fatal | **Nenhum teste falhou** (40/40 verdes em `precisao`, `quantidade_de_carne` e casos literais) | ⚠️ **SOBREVIVEU — mutante equivalente** (ver análise) |
| M2 | `lib/core/calculo/regras/essenciais.dart:33` | Remove o filtro `.where(… .entraNoTotal)`: os quatro essenciais passam a somar 75 | **6 falhas** — `essenciais_test.dart:68` (`Expected: within <0.001> of <60>`), `casos_literais…` (271 e ≈45) | ✅ Killed |
| M3 | `lib/core/calculo/dominio/catalogo_de_itens.dart:216` | `entraNoTotal: false` → `true` em `coposEPratos` — a "leitura (b)" de RN-10, que A-02 promete ser **uma linha** | **8 falhas** em 4 arquivos: `catalogo_de_itens_test.dart:158`, `essenciais_test.dart:67,75,96`, `casos_literais…:191,206,214`, `calculo_test.dart:30` | ✅ Killed |
| **M4** | `lib/core/calculo/regras/quem_paga_quem.dart:49` | **Ordena credores e devedores por valor decrescente** — o risco R-2 do design, o "melhoramento" que um executor faria | **5 falhas**, entre elas `casos_literais…:314` (Teste B na ordem) **e** `:325` (a guarda `isNot([…])`), mais `quem_paga_quem_test.dart:59,100,120` | ✅ Killed — **a guarda anti-ordenação morde** |
| M5 | `lib/core/calculo/regras/calculadora_da_festa.dart:169` | **Unifica os dois divisores de RN-14**: `porCabeca` passa a dividir por `adultos` em vez de `pessoas` | **4 falhas** — `casos_literais…:178` (≈R$ 30), `:225` (o teste "os dois números coexistem, e não se unificam"), `totais_test.dart:108`, `calculo_test.dart:30` | ✅ Killed |
| M6 | `lib/core/calculo/regras/preferencias.dart:80` | Cerveja dimensiona por `adultos` puro, ignorando abstêmios (desfaz A-06) | **3 falhas** — `preferencias_test.dart:83,105`, `calculadora_da_festa_test.dart:199` | ✅ Killed |
| M7 | `lib/core/calculo/regras/preferencias.dart:73` | `bebe == false` → `bebe != true`: **`null` passa a contar como abstêmio** (viola A-08) | **1 falha** — `preferencias_test.dart:92` ("a Duda, que não declarou se bebe, não reduz a cerveja") | ✅ Killed |
| M8 | `lib/core/calculo/formatacao/money_formatter.dart:21` | `valor.round()` → `valor.truncate()`: 210,60 vira `R$ 210` | **8+ falhas** — `money_formatter_test.dart:15,19,23`, `casos_literais…:139,167,203`, `calculo_test.dart:30,41` | ✅ Killed |
| M9 | `lib/core/calculo/formatacao/money_formatter.dart:35` | Separador de milhar agrupa de **4** em 4 dígitos, não de 3 | **3 falhas** — `money_formatter_test.dart:28,32,42` | ✅ Killed |
| M10 | `lib/core/calculo/regras/calculadora_da_festa.dart:110` | Neutraliza a guarda `pessoas == 0` (`== 0` → `< 0`): os pisos `max(1,…)` voltam a rodar numa festa sem ninguém | **2 falhas** — `calculadora_da_festa_test.dart:213`, `totais_test.dart:87` | ✅ Killed |
| M11 | `lib/core/calculo/regras/faixa_de_preco.dart:27` | `máx == mín` devolve **1.0** em vez de 0.0 (troca a saída declarada de A-15) | **1 falha** — `faixa_de_preco_test.dart:42` | ✅ Killed |
| **M12** | `lib/core/calculo/regras/quem_paga_quem.dart:42,44` | **Classificação de credor/devedor por `> 0` / `< 0` em vez da tolerância de um centavo** | **Nenhum teste falhou** — 318/318 verdes | ❌ **SOBREVIVEU — gap real** (ver G-2) |
| M13 | `lib/core/calculo/regras/totais.dart:1` | Insere `import 'package:flutter/foundation.dart';` num arquivo **real** de produção da camada | **2 falhas** — `calculo_isolation_test.dart:44` (e `:61`, que nomeia o infrator) | ✅ Killed — **a guarda de pureza morde em arquivo real, não só no sintético** |
| M14 | `lib/core/calculo/calculo.dart` | Remove `export 'regras/faixa_de_preco.dart';` do barrel | **Falha de compilação** — `calculo_test.dart:48: Error: Method not found: 'posicaoDoMarcador'` | ✅ Killed (a forma mais forte: nem compila) |
| M15 | `lib/core/calculo/regras/cota.dart:16` | Remove a guarda `adultos == 0 ? 0 :` — a cota vira `NaN`/`Infinity` | **2 falhas** — `cota_test.dart:30`, `saldos_test.dart:70` | ✅ Killed |
| M16 | `lib/core/calculo/dominio/catalogo_de_itens.dart:193` | Gelo: `quantidadeDefault: 3` → `1` (default de RN-10) | **8 falhas** — `catalogo_de_itens_test.dart:134`, `essenciais_test.dart:23,35,67`, `casos_literais…:188,203,214`, `calculo_test.dart:30` | ✅ Killed |
| M17 | `test/fixtures/rn30_estado_inicial_tipado.dart:58` | Fabrica default: `bruta['bebe'] as bool?` → `?? false` (a forma clássica de "consertar" um nulo) | **3 falhas** — `rn30_estado_inicial_tipado_test.dart:89,108,207` | ✅ Killed |

**Sensor depth**: P0-full — **17 mutações**, mínimo exigido 10.
**Resultado**: **15 mortas · 2 sobreviveram** (1 equivalente + 1 gap real).

### M1 — análise: mutante **equivalente**, e a razão importa

M1 não morreu, mas **nenhum teste poderia matá-lo**: as duas políticas de
arredondamento são comportamentalmente idênticas em Dart. Verificado com uma
sonda executada fora do repositório (`dart run --packages=…`):

```
1.15 * 10          = 11.5          (não 11.499999…)
(1.15 * 10).round()  = 12          (não 11)
varredura de 0 a 20 kg, passo 0,01 g (2.000.001 pontos):
  divergências entre arredondar-em-gramas e arredondar-em-kg = 0
```

A premissa citada em `precisao.dart:16-21`, no risco **R-1** do `design.md`, na
Tech Decision "Arredondamento de 0,1 kg" e na candidata a **AD-009** —
*"`(1.15 * 10).round()` devolve 11"* — é **factualmente falsa em Dart**. O
produto exato do `double` mais próximo de 1,15 por 10 fica a igual distância de
`11.5` e do vizinho inferior, e o desempate *round-half-to-even* do IEEE-754
escolhe `11.5`, que arredonda para 12.

**O código está certo** — `(gramas/100).round()/10` produz 1,2 kg e o R$ 211
fecha. O defeito é de **justificativa**, não de comportamento, e tem duas
consequências reais:

1. O teste `precisao_test.dart:10` ("1150 g dão 1,2 kg — **meio para cima, sem
   erro de ponto flutuante**") não pode falhar pelo motivo que o próprio nome
   afirma proteger. Ele é verdadeiro, mas vazio como sensor.
2. **AD-009 está prestes a entrar no `.specs/STATE.md` carregando uma premissa
   falsa.** Uma decisão de arquitetura permanente justificada por uma armadilha
   inexistente é dívida de raciocínio: o próximo agente ou confia nela e propaga
   o erro, ou a testa, descobre que é falsa, e passa a duvidar do resto do log.

Ver gap **G-3**.

### Estado da árvore após o sensor

```
git status --porcelain      → apenas ` M .specs/features/calculo/validation.md`
git diff HEAD --stat -- lib test → vazio
```

**Nenhuma mutação ficou para trás. Nenhum código foi commitado.** Portão
re-executado ao final: `flutter analyze` sem issues, `flutter test` **425/425**.

---

## Edge cases

Os 16 edge cases listados em `spec.md` §Edge Cases, um a um.

| # | Edge case da spec | Evidência | Result |
|---|---|---|---|
| 1 | `horas = 2` → f exatamente 0.5; `horas = 0` → 0.5 | `fator_duracao_test.dart:7` e `:29` | ✅ |
| 2 | `pessoas = 0` → lista vazia, totais 0, nenhum piso, nada negativo | `calculadora_da_festa_test.dart:213`; `totais_test.dart:87` (M10 confirma) | ✅ |
| 3 | `adultos = 0` e crianças > 0 → sem cerveja/destilado, com refri e água | `calculadora_da_festa_test.dart:229`; `quantidade_de_cerveja_test.dart:53`; `quantidade_de_destilado_test.dart:69` | ✅ |
| 4 | Nenhuma carne → sem divisão e sem item de carne | `quantidade_de_carne_test.dart:82` | ✅ |
| 5 | "Sem porco" na **única** carne ≡ nenhuma carne | `calculadora_da_festa_test.dart:180` | ✅ |
| 6 | 1150 g → **1,2 kg** (meio para cima), não 1,1 por erro de float | `precisao_test.dart:10`; `quantidade_de_carne_test.dart:66` | ⚠️ **valor certo, sensor vazio** — M1 prova que nenhuma entrada do domínio discrimina a política (G-3) |
| 7 | < 500 g por carne → 0,5 kg | `quantidade_de_carne_test.dart:78` | ✅ |
| 8 | Decremento trava em 0,5 kg / 2 latas / 1 | `overrides_test.dart:53,60,67` | ✅ |
| 9 | Preço trava em R$ 1 | `overrides_test.dart:82` | ✅ |
| 10 | Saldos vazios / só credores / só devedores → lista vazia | `quem_paga_quem_test.dart:140,144,148` | ✅ |
| 11 | Resíduo ≤ R$ 0,01 tratado como zero, **sem gerar linha** | `quem_paga_quem_test.dart:161,168,178` | ⚠️ **PARCIAL** — os três casos cobrem o resíduo do **devedor**; o resíduo do **credor à frente da fila** não é coberto (M12 / G-2) |
| 12 | Todos os saldos zero → nenhuma linha, todos "NO ZERO" | `quem_paga_quem_test.dart:152`; `saldos_test.dart:119` | ✅ |
| 13 | `máx == mín` → posição 0.0 | `faixa_de_preco_test.dart:42` (M11 confirma) | ✅ |
| 14 | Sem linhas de acerto → `0 de 0` com fração 1.0 | `quitacao_test.dart:110` | ✅ |
| 15 | Valor exatamente `.5` arredonda **para cima** (30,5 → 31) | `money_formatter_test.dart:23` (M8 confirma) | ✅ |
| 16 | Milhar com `.`, nunca `,` | `money_formatter_test.dart:29,33` e `:47-56` (M9 confirma) | ✅ |

**14 de 16 plenamente cobertos · 2 com ressalva** (#6 e #11), ambos ligados a
mutantes sobreviventes.

---

## Code Quality

| Princípio | Status |
|---|---|
| Código mínimo, sem feature além do pedido | ✅ — 2.388 linhas de produção para 27 requisitos; nenhuma função sem AC que a peça |
| Sem abstração para uso único | ✅ — `precisao.dart` concentra as três primitivas e é consumido por 6 arquivos; nenhum wrapper de uma chamada só |
| Sem "flexibilidade" desnecessária | ✅ — nenhuma injeção, nenhum ponto de extensão especulativo; tudo função pura |
| Só arquivos exigidos pelas tasks | ✅ — `git diff --name-only c5be425..HEAD` filtrado contra a fronteira declarada em `tasks.md:23-25` retorna **vazio**: nada fora de `lib/core/calculo/`, `test/core/calculo/`, `test/fixtures/rn30_estado_inicial_tipado*` e `.specs/features/calculo/` |
| Não tocou território do workflow paralelo | ✅ — `pubspec.yaml`, `lib/core/design_system/`, `lib/core/routing/`, `.specs/STATE.md`, `.specs/ROADMAP.md` **intocados** |
| Não enfraqueceu a fundação | ✅ — `test/fixtures/rn30_estado_inicial.dart` e `rn30_estado_inicial_test.dart` com **0 linhas alteradas** em 32 commits (`git diff --stat` vazio). A contagem subiu de 92 → 425, nunca caiu |
| Zero dependência nova | ✅ — `dart:math` é o único import de biblioteca em `lib/core/calculo/`; `intl` e `meta` fora, como A-18/A-19 mandam |
| Domínio em PT-BR, utilitário em inglês (`CLAUDE.md`) | ✅ — `Festa`, `Pessoa`, `ItemDeLista`, `Despesa`, `calcularRacha`, `fatorDuracao` com o nome da spec; `MoneyFormatter` em inglês |
| Nenhuma fórmula duplicada fora da camada | ✅ — nenhum literal `0.01`, `/100` de arredondamento ou `.round()` de quantidade fora de `precisao.dart` (conferido por `grep`) |
| Todo teste mapeia a um AC / edge case | ✅ — todo `group` cita `CALC-xx` (ou `FUND-06` no de isolamento) |
| Nenhum teste enfraquecido, pulado ou apagado | ✅ — nenhum `skip:` na suíte; contagem monotônica |
| Commits Conventional em PT-BR, `RN-xx`/`CALC-xx` no corpo | ⚠️ **1 desvio** — ver abaixo |

**Desvio de processo — `62c5537`**
`feat(calculo): add validation specification document for calculation process`
viola três regras do `CLAUDE.md` de uma vez: assunto **em inglês** (a regra é
PT-BR), tipo `feat` para um arquivo de documentação (seria `docs`), e **nenhuma
referência `RN-xx`/`CALC-xx` no corpo** — é o **único** dos 32 commits sem ela
(os outros 31 têm). Pior: o conteúdo que ele commitou era o `validation.md`
**esqueleto vazio**, com nove seções em `_(pendente)_` — um relatório de
verificação em branco entrando na história como se fosse entrega. Este
relatório o substitui integralmente. Nenhum código de produção foi afetado.

---

## Gate Check

- **Comando (Build)**: `flutter analyze && flutter test`
- **`flutter analyze`**: `No issues found!` — exit 0
- **`flutter test`**: **425 passed, 0 failed, 0 skipped** — exit 0
- **Baseline declarado pelo orquestrador**: 425 verdes + analyze limpo — **confirmado de forma independente antes de qualquer mutação**
- **Baseline no início do Execute** (`tasks.md:27`): 92 testes → **delta +333**, monotônico
- **Testes pulados**: nenhum (`grep -r 'skip:' test/` sem resultado em `test/core/calculo/`)
- **`test/architecture/calculo_isolation_test.dart`**: verde, e **provado vivo** por M13 num arquivo real de produção
- **Testes enfraquecidos/apagados**: nenhum — conferido por `git diff --stat`, não por alegação
- **Re-execução após as 17 mutações**: analyze limpo, 425/425 — o portão voltou ao verde
- **Árvore rastreada**: limpa antes, entre cada mutação e ao final

---

## Cobertura pendente / spec-precision gaps

Nenhum destes derruba o portão. Estão ranqueados por consequência, e cada um
está descrito para **outro agente executar** — o verificador não consertou nada.

### G-1 · `ComposicaoDaFesta` e `PrecoDeMercado` sem `==`/`hashCode` — **P1-2 AC2 sem evidência**

- **Severidade**: 🟠 Média — AC explicitamente não cumprido, com efeito prático real
- **O que a spec pede**: `spec.md:122` — *"WHEN duas entidades com os mesmos campos são comparadas THEN SHALL ser iguais (`==`) e ter o mesmo `hashCode` — são valores, não identidades"*, sobre as 9 entidades nomeadas em `spec.md:121`. O `design.md:242` repete: *"Todas imutáveis … `==`/`hashCode` escritos à mão"*.
- **O que existe**: 7 das 9 implementam. `lib/core/calculo/dominio/composicao_da_festa.dart` e `lib/core/calculo/dominio/preco_de_mercado.dart` **não têm `operator ==` nem `hashCode`** (verificado por `grep -c 'bool operator =='`), e nenhum teste afirma igualdade delas.
- **Por que importa, e não é formalidade**: `ComposicaoDaFesta` é a **entrada única** do orquestrador. Um BLoC que faça `if (novaComposicao == composicaoAtual) return;` para evitar recálculo — o padrão óbvio em `flutter_bloc`, e UC-04 recalcula *a cada toque* — vai comparar por identidade e recalcular sempre, ou pior, um `Equatable`/`state == newState` a tratará como sempre-diferente. O `calculo_test.dart:73` já **contorna** a ausência comparando totais em vez das composições, o que é sintoma, não solução.
- **Task para outro agente**: implementar `==`/`hashCode` à mão nas duas (sem `package:meta`, A-19), com igualdade **profunda** para `List<Pessoa>`, `Set<ChaveItem>` e `Map<ChaveItem, OverrideDeItem>` de `ComposicaoDaFesta` (usar comparação elemento a elemento escrita à mão, já que `collection` também não é dependência). Acrescentar `copyWith` a `ComposicaoDaFesta` — é a entrada que a UI mais vai mutar. Testes: duas composições iguais construídas em separado são `==` e compartilham `hashCode`; trocar um item do `Set` quebra a igualdade; `copyWith` não muta a original. Idem para `PrecoDeMercado`.

### G-2 · Tolerância de centavo não discriminada na classificação de credores — **mutante M12 vivo**

- **Severidade**: 🟠 Média — furo de cobertura sobre um AC que a spec afirma duas vezes
- **O que a spec pede**: `spec.md:198` — *"nenhuma linha SHALL ter valor menor ou igual a 1 centavo"* — e `spec.md:256` — *"WHEN um saldo residual é menor ou igual a R$ 0,01 THEN SHALL ser tratado como zero e **não** gerar linha"*.
- **O furo**: trocar `saldo.saldo > toleranciaDeCentavo` por `saldo.saldo > 0` (e o simétrico dos devedores) em `quem_paga_quem.dart:42,44` **não faz nenhum dos 425 testes falhar**. Os três testes de resíduo (`quem_paga_quem_test.dart:161,168,178`) só exercitam resíduo do lado **devedor**, ou credor residual no **fim** da fila — nunca um credor sub-centavo **à frente** de um credor real.
- **Prova de que não é mutante equivalente** (sonda executada fora do repositório, sobre o código **sem** mutação e **com** ela):

  | Entrada `{'ANA': +0.005, 'VOCÊ': +80, 'LÉO': −80.005}` | Saída |
  |---|---|
  | Código atual | 1 linha: `LÉO → VOCÊ 80.0` ✅ |
  | Com M12 | **2 linhas**: `LÉO → ANA 0.005` + `LÉO → VOCÊ 80.0` ❌ linha fantasma de meio centavo |

- **Task para outro agente**: acrescentar a `test/core/calculo/regras/quem_paga_quem_test.dart`, no grupo `CALC-21 — resíduo de centavo não vira cobrança (A-13)`, um teste com um credor de resíduo **na primeira posição** da lista de saldos, afirmando que ele não recebe linha nenhuma e que a saída tem exatamente uma linha. Sugestão de dado: `{'ANA': 0.005, 'VOCÊ': 80.0, 'LÉO': -80.005}` → `['LÉO→VOCÊ']`. **Nenhuma mudança de código de produção é necessária** — o comportamento atual já está correto; falta só o sensor que o protege.

### G-3 · A premissa de AD-009 é factualmente falsa em Dart — **escalar antes de virar AD**

- **Severidade**: 🟡 Baixa em comportamento, 🔴 **Alta em decisão** — está a caminho do log permanente
- **A alegação**, repetida em quatro lugares (`precisao.dart:16-21`, `design.md` risco R-1, `design.md` Tech Decisions, e a candidata **AD-009** que o `design.md:522` manda o orquestrador registrar em `.specs/STATE.md`): *"`(1.15 * 10).round()` devolve **11**, o binário guarda 11,499999…"*.
- **O fato**, medido: em Dart, `1.15 * 10 == 11.5` exatamente e `(1.15 * 10).round() == 12`. O produto exato empata entre `11.5` e o vizinho inferior, e o desempate *round-half-to-even* do IEEE-754 escolhe `11.5`. Varredura de 0 a 20 kg em passos de 0,01 g (2.000.001 pontos): **zero divergência** entre arredondar em gramas e arredondar em kg.
- **Consequência**: o código está correto e o R$ 211 fecha — mas por um motivo diferente do declarado, e o teste `precisao_test.dart:10`, cujo nome promete proteger contra "erro de ponto flutuante", não pode falhar por esse motivo (M1 comprova). Registrar AD-009 com essa justificativa coloca uma premissa falsa no log de decisões do projeto.
- **Task para outro agente / decisão do dono da spec**: **não mudar o código** — `(gramas/100).round()/10` continua a implementação preferida (é mais legível e é a unidade em que RN-03 raciocina). Corrigir a **justificativa** em `precisao.dart:16-21` e no `design.md` (R-1 e Tech Decisions) para algo verdadeiro — p.ex. *"arredondar na unidade em que a regra é enunciada (gramas) evita depender do desempate do IEEE-754; as duas formas coincidem em todo o domínio, verificado por varredura"* — e ajustar o texto de **AD-009** antes de gravá-lo no `.specs/STATE.md`. Renomear o teste `precisao_test.dart:10` para dizer o que ele de fato prova (a fronteira 1149/1150/1151 g), sem a promessa de proteção contra float.

### G-4 · Desvio de processo em `62c5537` — commit fora do padrão do `CLAUDE.md`

- **Severidade**: 🟢 Baixa — cosmético, sem efeito em código
- **O quê**: assunto em inglês, tipo `feat` para documentação, sem `RN-xx`/`CALC-xx` no corpo (único entre 32 commits), e conteúdo era o `validation.md` **em branco**.
- **Task**: nada a fazer no código. Este relatório substitui o arquivo. Se o histórico for reescrito antes do merge, corrigir a mensagem para `docs(calculo): …` em PT-BR; caso contrário, seguir em frente — reescrever história por causa de uma mensagem não compensa.

### G-5 · Doc comment do barrel reivindica escopo que a spec nega

- **Severidade**: 🟢 Baixa — uma linha, mas na porta de entrada da camada
- **O quê**: `lib/core/calculo/calculo.dart:1` — *"Camada de cálculo do BORA — território das regras **RN-01..RN-29**"*. A spec diz o contrário em `spec.md:317`: RN-19 é de `custos`, RN-22/RN-23 de `galera`, RN-24 de `convidado`, RN-25/RN-26/RN-26b de `convite`, RN-28 de `convidado`/`home`, RN-29 de `design-system`. O escopo real é **RN-01..RN-18, RN-20, RN-21**, mais os totais de RN-27 e a tipagem de RN-30.
- **Por que importa**: é a primeira linha que toda feature consumidora lê. Um autor de spec de tela que confie nela pode concluir que os toasts de RN-29 ou o meio de pagamento de RN-19 nascem aqui — exatamente a duplicação de regra que o `CLAUDE.md` proíbe. O resto do arquivo está correto (as omissões estão declaradas em `festa.dart:10`, `linha_de_acerto.dart:6` e `papel_na_festa.dart:3`); só o cabeçalho generaliza demais.
- **Task para outro agente**: trocar a primeira linha por *"território das regras RN-01..RN-18, RN-20 e RN-21, mais os totais de RN-27"*, e acrescentar a frase que já existe nas entidades: as demais RNs têm dono declarado em `spec.md:317`. Uma linha, sem teste novo.

### Cobertura declarada ausente por design (não são gaps)

| Item | Natureza |
|---|---|
| Widget / integration / e2e | `tasks.md:44` declara fora de escopo: `core/calculo` **não pode** importar Flutter (FUND-06), então widget test aqui é impossível por construção. Correto e consistente |
| RN-19, RN-22..RN-29, RN-27 além dos totais | Fora de escopo com **dono nomeado** em `spec.md:317`. Conferido: nenhum vazou para esta camada |
| `ComposicaoDaFesta` sem teste próprio | É consequência de G-1; ao fechar G-1 nasce o arquivo `test/core/calculo/dominio/composicao_da_festa_test.dart` |

---

## Rastreabilidade CALC-xx

| Req | Regra-fonte | Evidência principal | Status |
|---|---|---|---|
| CALC-01 | RN-01 | `contagem_de_pessoas_test.dart:14-15,35-49` | ✅ Verified |
| CALC-02 | RN-02 | `fator_duracao_test.dart:7-29` | ✅ Verified |
| CALC-03 | RN-13 (dinheiro) | `money_formatter_test.dart:7-56` (M8, M9) | ✅ Verified |
| CALC-04 | RN-13 (horas) | `rotulo_de_duracao_test.dart:7-19` | ✅ Verified |
| CALC-05 | arquivo 01 §6 | `pessoa/festa/item_de_lista/chave_item/despesa` tests | ⚠️ **Parcial** — 7 de 9 entidades com igualdade de valor; `ComposicaoDaFesta` e `PrecoDeMercado` sem `==` (G-1) |
| CALC-06 | RN-30 (tipagem) | `rn30_estado_inicial_tipado_test.dart:21-207` (M17) | ✅ Verified |
| CALC-07 | RN-03 | `quantidade_de_carne_test.dart:11-82`; `precisao_test.dart:6-24` | ✅ Verified — comportamento certo; **justificativa** de AD-009 incorreta (G-3) |
| CALC-08 | RN-04 | `quantidades_por_pessoa_test.dart:7-32` | ✅ Verified |
| CALC-09 | RN-05 | `quantidade_de_cerveja_test.dart:7-62` (M6) | ✅ Verified |
| CALC-10 | RN-06 | `quantidades_de_bebida_test.dart:6-40` | ✅ Verified |
| CALC-11 | RN-07 | `quantidades_de_bebida_test.dart:44-80` | ✅ Verified |
| CALC-12 | RN-08 | `quantidades_por_pessoa_test.dart:37-66` | ✅ Verified |
| CALC-13 | RN-09 | `quantidade_de_destilado_test.dart:7-85` | ✅ Verified |
| CALC-14 | RN-10 | `essenciais_test.dart:11-100`; `catalogo_de_itens_test.dart:117-172` (M2, M3, M16) | ✅ Verified |
| CALC-15 | RN-21 | `preferencias_test.dart:18-198`; `calculadora_da_festa_test.dart:56-276` (M6, M7) | ✅ Verified |
| CALC-16 | RN-10 (exemplo), RN-13, RN-14 | `casos_literais_do_arquivo_03_test.dart:167-245`; `totais_test.dart:23-118` (M5, M10) | ✅ Verified — **os 4 números canônicos fecham** |
| CALC-17 | RN-12 | `overrides_test.dart:23-150`; `item_de_lista_test.dart:67-119` | ✅ Verified |
| CALC-18 | RN-20 | `contribuicoes_test.dart:26-167`; `despesa_test.dart:7-46` | ✅ Verified |
| CALC-19 | RN-14 | `cota_test.dart:6-42` (M15) | ✅ Verified |
| CALC-20 | RN-15 | `saldos_test.dart:7-170` | ✅ Verified |
| CALC-21 | RN-16 | `casos_literais…:280-339`; `quem_paga_quem_test.dart:24-226` (M4 mata a ordenação) | ⚠️ **Parcial** — Testes A e B e a **ordem** provados; tolerância de centavo sem sensor na classificação (G-2) |
| CALC-22 | RN-17 | `split_de_despesa_test.dart:7-90` | ✅ Verified |
| CALC-23 | RN-18 | `quitacao_test.dart:14-120` | ✅ Verified |
| CALC-24 | RN-11 (tabela) | `tabela_de_precos_de_mercado_test.dart:13-150` | ✅ Verified |
| CALC-25 | RN-11 (marcador) | `faixa_de_preco_test.dart:29-84` (M11) | ✅ Verified |
| CALC-26 | RN-27 (só totais) | `total_do_pedido_test.dart:35-96` | ✅ Verified |
| CALC-27 | `CLAUDE.md` (Dart puro, porta única) | `calculo_test.dart:30-115`; `calculo_isolation_test.dart:44` (M13, M14) | ✅ Verified |

**25 Verified · 2 Parciais · 0 Needs Fix.**

### Os quatro números canônicos do arquivo 03

| Caso literal | Asserção | Result |
|---|---|---|
| **R$ 211** | `casos_literais…:171,175` — `closeTo(210.6, 0.001)` + `'R$ 211'` | ✅ |
| **≈ R$ 30 / cabeça** | `casos_literais…:182-183` — `closeTo(30.0857, 0.001)` + `'R$ 30'`, sobre **7 pessoas** | ✅ |
| **R$ 271** | `casos_literais…:207,211` — `closeTo(270.6, 0.001)` + `'R$ 271'` | ✅ |
| **≈ R$ 45 / adulto** | `casos_literais…:218-219` — `closeTo(45.1, 0.001)` + `'R$ 45'`, sobre **6 adultos** | ✅ |
| **Teste A de RN-16** | `casos_literais…:284-288` — lista exata e ordenada | ✅ |
| **Teste B de RN-16** | `casos_literais…:318-322` — lista exata e ordenada; M4 prova que a ordem discrimina | ✅ |

### Matriz RN-xx → CALC-xx (a rastreabilidade do arquivo 05 continua verdadeira)

Conferida linha a linha contra `spec.md:302-315`: as 22 RNs em escopo mapeiam
para os 27 `CALC-xx`, e nenhuma RN **fora** de escopo vazou para esta camada —
`grep` por `RN-19`, `RN-22`..`RN-29` em `lib/core/calculo/` só encontra menções
em doc comment declarando a **omissão** (p.ex. `linha_de_acerto.dart` registra
que RN-19 é de `custos`). `LinhaDeAcerto` de fato **não** tem campo de meio de
pagamento, e `PapelNaFesta` existe como enum **sem** tabela de permissões.
