# Sua lista (lista turbinada) — Validation

**Date**: 2026-09-01
**Spec**: `.specs/features/lista/spec.md` (LIST-01..LIST-35)
**Diff range**: `fc744b5..HEAD` na branch `feature/lista` — 27 commits, `401ec3c`..`6c7fef5`, um por task (T1..T27)
**Verifier**: sub-agente independente (autor ≠ verificador). Cobertura re-derivada do zero a partir da `spec.md`, regra **evidence-or-zero**.

**Veredito**: ❌ **FAIL** — 4 mutantes sobreviventes, dois deles com **AC ponta-a-ponta sem defesa**.

---

## Task Completion

| Task | Status | Notas |
|---|---|---|
| T1..T27 | ✅ Done | `tasks.md` tem **252** critérios `- [x]` e **zero** `- [ ]`. Um commit por task, na ordem. |

---

## Gate Check

- **Comando**: `flutter test` · `flutter analyze`
- **Resultado**: **1926 passaram, 0 falharam, 0 pulados** (exit 0)
- **`flutter analyze`**: `No issues found!` (exit 0)
- **Baseline antes da feature**: 1528 · **depois**: 1926 · **delta**: +398
- **Árvore**: `git status --porcelain` vazio antes e depois de toda a sessão de mutação (verificado ao final — ver §Integridade).

**Test Integrity Check** — `git diff fc744b5..HEAD -- test/` remove **4 linhas**, e todas as quatro são linhas de comentário `///` em `test/core/routing/app_router_shell_test.dart`, substituídas por um comentário atualizado que acrescenta a Lista à mesma explicação de E-4. **Nenhuma asserção afrouxada, nenhum `skip:`, nenhum `findsAny`, nenhum `reason` removido, nenhum teste apagado.** Varredura por `skip:` em `test/features/lista/**`, `test/core/routing/festa_tabs_shell_test.dart` e `test/core/di/injector_test.dart`: zero ocorrências.

---

## Spec-Anchored Acceptance Criteria

Legenda: ✅ o valor afirmado bate com o desfecho que a spec define · ⚠️ spec-precision gap · ❌ sem evidência.

### P1-1 — A lista da festa, com o que ninguém lembra (LIST-01..LIST-07)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 header + segmented, PLANEJAR ativo | "SUA LISTA", "🧮 PLANEJAR"/"🛒 COMPRAR", índice ativo = planejar | `test/features/lista/presentation/widgets/lista_compacta_test.dart:144` — `expect(find.text(ListaTextos.titulo), findsOneWidget)`; `:158` — `expect(…BoraSegmentedControl…indiceAtivo, ModoDaLista.planejar.index)` (roda nos dois viewports) | ✅ |
| AC2 dica tracejada de PLANEJAR, literal | "📊 Cada preço é a média real…" | `lista_compacta_test.dart:189` — `expect('${nota.emoji} ${nota.texto}', ListaTextos.dicaPlanejar)` + `test/features/lista/presentation/lista_textos_test.dart:33` compara a constante com o literal escrito no teste | ✅ |
| AC3 card único, `ordemCanonicaDaLista`, sem item estranho | ordem canônica; nada fora da composição | `card_de_planejar_test.dart:91` — `expect(_chavesNaArvore(tester), esperada)`; `:104` — `isNot(contains(ChaveItem.suina/vodka/legumesParaGrelha))` | ✅ |
| AC4 "ESSENCIAIS · ENTRAM SOZINHOS" com os 4 de RN-10 e badge `AUTO ∝ {fonte}` | as 4 fontes literais | `card_de_planejar_test.dart:117` (categoria + 4 chaves, sem interação); `:145` — `expect(fontes, ['kg de carne','volume de bebida gelada','kg de carne','nº de pessoas'])` | ✅ |
| AC5 Copos & pratos aparece e **não soma**; subtotal dos essenciais = **R$ 60** | R$ 60 | `card_de_planejar_test.dart:188` — `expect(find.text('R\$ 60'), findsOneWidget)`; `:196` — `contains(ChaveItem.coposEPratos)` + `totalDosEssenciais < totalExato` | ✅ |
| AC6 subtotal por categoria + total geral | subtotais + total | `card_de_planejar_test.dart:207` — `find.text(MoneyFormatter.reais(totalExato(padrao.itens)))` + `find.text(SUBTOTAL) findsNWidgets(2)`; rodapé em `lista_compacta_test.dart:216` | ✅ |
| AC7 rodapé "MÉDIA TOTAL" / **R$ 271** / **≈ R$ 45 por adulto** / "FAZER PEDIDO 🛒" | os quatro literais | `lista_compacta_test.dart:214-231` — `_noRodape(MoneyFormatter.reais(resultado.totalComEssenciais)) findsOneWidget` **e** `expect(MoneyFormatter.reais(resultado.totalComEssenciais), r'R$ 271')`; idem `porAdulto` → `r'R$ 45'`; `_cta(tester).rotulo == fazerPedidoComCarrinho`. Web: `lista_expandida_test.dart:283-319` | ✅ |
| AC8 dinheiro sempre por `MoneyFormatter` | inteiro, sem centavos | `lista_sem_formula_test.dart:559-566` — `resultado.totalComEssenciais ≈ 270,6`, a árvore mostra `MoneyFormatter.reais(...)`, e `expect(…, r'R$ 271')` / `isNot(r'R$ 270')` — trava o arredondamento **único** de AD-009 | ✅ |
| AC9 varredura: zero aritmética e zero formatação própria | guard MONT-08 | `lista_sem_formula_test.dart:304` — `expect(violacoesEm(Directory('lib/features/lista')), isEmpty)`, com as 5 regras de §13 e auto-testes por regra | ✅ |

### P1-2 — O preço médio real, com a faixa (LIST-08, LIST-09)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 "{qtd} · média de N mercados", N da coluna Fontes | 4 Picanha, 3 Pão, 2 Gelo | `linha_de_item_test.dart:152-172` — laço `[(bovina,4),(paoDeAlho,3),(gelo,2)]` com `find.text(ListaTextos.mediaDeMercados(rotuloDeQuantidade(...), fontes)) findsOneWidget` | ✅ |
| AC2 barra com extremos **R$ 54 / R$ 83** e marcador em **37,9%** | 0,379 | `linha_de_item_test.dart:181-184` — `rotuloMin == 'R$ 54'`, `rotuloMax == 'R$ 83'`; `lista_sem_formula_test.dart:588-592` — `expect(barra.fracao, closeTo(0.379, 0.001))` | ✅ |
| AC3 item sem linha em RN-11: sem "média de" e sem barra | ausência | `linha_de_item_test.dart:143-146` — `expect(find.textContaining('média de'), findsNothing)` + `expect(_barra(), findsNothing)` | ✅ |
| AC4 rodapé "faixa real: de R$ 245 a R$ 343" | os dois literais derivados | `lista_compacta_test.dart:248-259` — `_noRodape(ListaTextos.faixaReal(...)) findsOneWidget` **e** `expect(…, r'faixa real: de R$ 245 a R$ 343')`; camada: `faixa_de_preco_test.dart:239` (244,60 / 342,60) | ✅ |
| AC5 a mesma regra sobre as 8 linhas → **286 / 234 / 356** | os literais de RN-11 | `faixa_de_preco_test.dart:110-118` — `totalDeMercado(tabelaDePrecosDeMercado).media closeTo(286)`, `.minimo closeTo(234)`, `.maximo closeTo(356)`; degeneração: `:202` "com toda a lista coberta a função degenera em totalDeMercado" | ✅ |
| AC6 override não move a faixa | faixa inalterada | `linha_de_item_test.dart:222-232` — override 900, `rotuloMin/Max` continuam 54/83, `fracao == posicaoDoMarcador(leituraDaBovina)`, `fracaoNoTrilho inInclusiveRange(0,1)`; camada: `faixa_de_preco_test.dart:252` | ✅ |
| AC7 `máximo == mínimo` → marcador em 0, sem divisão por zero | 0 | `linha_de_item_test.dart:201-220` — `expect(_barraDe(tester).fracao, 0)` + `fracaoNoTrilho, 0` | ✅ |

### P1-3 — Corrigir o que a calculadora chutou (LIST-10..LIST-15)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 tocar expande com ▴ e dois steppers; abrir um fecha o anterior | um campo, não conjunto | `card_de_planejar_test.dart:231` (só o expandido abre a régua), `:254` (tocar outra pede a chave dela); `lista_bloc_test.dart:167` — "abrir um item fecha o anterior"; caret: `linha_de_item_test.dart:283` (▴/▾) | ✅ |
| AC2 passo do catálogo (0,5 kg / 2 latas / 1) e mínimo = um passo, decremento inerte no piso | piso = um passo | `lista_overrides_test.dart:79` (laço por chave, passo do catálogo), `:98` — "o piso é um passo, e o decremento no piso fica inerte"; widget: `painel_de_override_test.dart` — `onDecrementar` nulo no piso | ✅ |
| AC3 passo e mínimo de preço = R$ 1 | R$ 1 | `lista_overrides_test.dart:119` e `:131` | ✅ |
| AC4 ponto vermelho de 8px no item editado… | 8px | `linha_de_item_test.dart:251-265` — `getSize(_pontoDeEditado()) == Size(LinhaDeItem.ladoDoPontoDeEditado, …)`; `:266` item sem ajuste não o exibe | ✅ |
| AC4 (2ª cláusula) "…deixa de exibi-lo **quando o ajuste é desfeito**" | ambíguo na spec | Nenhuma asserção. `comPassoDeQuantidade` grava `quantidadeOverride` mesmo quando o valor volta ao automático, e `ItemDeLista.editado` (`item_de_lista.dart:72`) só olha se o override é `null` ⇒ **+1 seguido de −1 mantém o ponto vermelho e o RESTAURAR**. Só o RESTAURAR limpa. | ⚠️ spec-precision gap |
| AC5 recálculo imediato de linha, subtotal, total, por adulto e faixa | mesma emissão | `lista_overrides_test.dart:152` — "um ajuste move linha, total, por adulto e faixa na mesma emissão" | ✅ |
| AC6 RESTAURAR existe só com override | ausente na árvore sem override | `lista_compacta_test.dart:321` — `findsNothing`; `:328` aparece e some no mesmo frame; rail: `lista_expandida_test.dart:346,353` | ✅ |
| AC7 RESTAURAR desfaz tudo, sem diálogo e sem toast | todos de uma vez | `lista_overrides_test.dart:218-237` — `overrides isEmpty`, `temOverrides isFalse`, `editado isFalse` nos dois itens, total volta ao original; sem toast: `lista_compacta_test.dart:369` | ✅ |
| AC8 override sobrevive à navegação dentro da festa | preservado | `lista_page_test.dart:194-232` — sai para `galera`, para `/roles`, volta e `expect(_estado(tester).festa!.composicao.overrides, overrides)` + RESTAURAR de volta na árvore; `festa_tabs_shell_test.dart:161` (troca de aba) | ✅ |

### P1-4 — Comprar no mercado, corredor por corredor (LIST-16..LIST-20)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 dica de COMPRAR literal | "✅ Organizado por corredor…" | `lista_compacta_test.dart:200` — `expect('${nota.emoji} ${nota.texto}', ListaTextos.dicaComprar)` | ✅ |
| AC2 ordem fixa de RN-27, "{N} itens", corredor vazio não renderiza | AÇOUGUE→HORTIFRÚTI→PADARIA→BEBIDAS→MERCEARIA | `card_de_comprar_test.dart:121` (ordem nos dois viewports), `:163` (a lista literal é a de RN-27), `:170` (não lê `Corredor.values` nem `index`), `:194` e `:207` (corredor sem item fora da árvore) | ✅ |
| AC3 item fora de RN-11 cai no corredor do catálogo | carnes AÇOUGUE; água/suco/destilados BEBIDAS; sal/copos MERCEARIA | `card_de_comprar_test.dart:216,228,243`; catálogo: `catalogo_de_itens_test.dart:224` (os 16, corredor a corredor) e `:290` (coerência com a tabela de RN-11) | ✅ |
| AC4 check verde `#0B6B3A`, ✓ branco, 26×26, linha a 45% | as três medidas | `checkbox_da_lista_test.dart:50` (26×26), `:88` (fundo verde + ✓ branco), `:59` (borda 2px `ink`, canto reto); `linha_de_compra_test.dart:129` (opacidade de T-04 ao marcar), `:146` (as duas opacidades diferem) | ✅ |
| AC5 rodapé COMPRAR: "{N} de {M} no carrinho", total, "PEDIR O QUE FALTA 🛵" | os três | `lista_compacta_test.dart:274-292` — `_noRodape(ListaTextos.noCarrinho(0, resultado.todosOsItens.length)) findsOneWidget`, total, e `_cta(tester).rotulo` | ✅ |
| AC6 contador atualiza na hora e o **total não muda** | total inalterado | `lista_compacta_test.dart:294` — "marcar um item atualiza o contador na hora e o total não muda"; bloc: `lista_carrinho_test.dart:135` | ✅ |
| AC7 checks sobrevivem a alternar modo / aba / sair e voltar | preservado | `lista_compacta_test.dart:356`; `lista_page_test.dart:194`; `lista_carrinho_test.dart:163` (bloc novo sobre a mesma porta acha os checks) | ✅ |

### P1-5 — Pedir em um toque (LIST-21..LIST-27)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 sheet com título "FAZER PEDIDO" e ✕ | literal A-18 | `sheet_de_pedido_test.dart:170` (título + ✕), `:359` (o título continua o mesmo aberto pelo COMPRAR) | ✅ |
| AC2 linha 📍 com **"Laje do Rafa — Vila Madalena"** + "TROCAR" vermelho sublinhado | o endereço **da festa** | `sheet_de_pedido_test.dart:178` afirma a linha 📍, mas o `PedidoBloc` é construído **pelo próprio teste** com `enderecoDaFesta: _endereco`. A ligação real `enderecoDaFesta: festa.festa.local` (`lib/features/lista/presentation/pages/lista_page.dart:144`) **não tem teste**: trocá-la por uma constante deixa a suíte inteira verde (mutação M19). "TROCAR" vermelho/sublinhado: `sheet_de_pedido_test.dart:253` ✅; "vale só para este pedido": `pedido_bloc_test.dart:187` + `sheet_de_pedido_test.dart:294` ✅ | ❌ **GAP** (origem do endereço) |
| AC3 três cartões na ordem de RN-27, ETA e frete literais, iFood pré-selecionado | 40–60/12, 15–30/9, 30–45/grátis | `sheet_de_pedido_test.dart:189-205` (ordem == `ParceiroDeEntrega.values`, selecionado == ifood); `parceiro_de_entrega_test.dart:17,24,31` (os três pares ETA/frete literais); `cartao_de_parceiro_test.dart:111,123,140` | ✅ |
| AC4 Subtotal 271 · Frete 12 · Total **283**; Rappi **280**; Zé frete **0** | os três totais | `sheet_de_pedido_test.dart:228-230` (`R$ 271` / `R$ 12` / `R$ 283`), `:245-247` (`R$ 9` / `R$ 280`); `pedido_bloc_test.dart:92-94`, `:105`, `:108` (Zé frete 0, total == subtotal) | ✅ |
| AC5 Zé inerte com item fora de BEBIDAS; selecionável só com bebidas | inerte | `sheet_de_pedido_test.dart:207` — `expect(ze.onSelecionar, isNull)`; regra no bloc: `pedido_bloc_test.dart:214,218,227,236` | ✅ |
| AC6 aberta pelo COMPRAR leva **só os não marcados**; nada faltando ⇒ CTA inerte e sheet não abre | subtotal só do que falta | O CTA inerte está coberto (`lista_compacta_test.dart:436` — `_cta(tester).onPressed isNull`, `palco.pedidos isEmpty`). A **primeira metade** não: `sheet_de_pedido_test.dart:341` e `pedido_bloc_test.dart:150,163` constroem o bloc com `apenasOQueFalta: true` **passado pelo teste**. A ligação real `apenasOQueFalta: estado.modo == ModoDaLista.comprar` (`lista_page.dart:145`) **não tem teste**: fixá-la em `false` deixa a suíte inteira verde (mutação M18) | ❌ **GAP** (o modo não chega ao pedido) |
| AC7 ✕ / toque fora fecham sem pedir | sem despesa | `sheet_de_pedido_test.dart:367,378` — `porta.enviados isEmpty` + `sonda.confirmados isEmpty` | ✅ |
| AC8 overlay com 🛵, "PEDIDO A CAMINHO!", ETA + endereço, linha vermelha, CTA | as cinco linhas | `overlay_de_pedido_test.dart:110` (as quatro linhas + CTA nos dois viewports), `:129` (endereço inteiro, D-6), `:286` (🛵 56px, título 30px) | ✅ |
| AC9 "VOLTAR À LISTA" fecha e volta **no mesmo modo**, checks e overrides intactos | mesmo modo | Fechar: `overlay_de_pedido_test.dart:245` + `lista_page_test.dart:271-275` (`rotaAtual() == Routes.lista`). Checks/overrides intactos: `lista_carrinho_test.dart:232`. A cláusula **"no mesmo modo"** não é afirmada por nenhum teste que abra o fluxo em COMPRAR, confirme e releia `estado.modo` | ⚠️ cláusula sem asserção |
| AC10 `Despesa` com valor = **total** e descrição "Pedido no {parceiro}" | total (subtotal+frete) | `lista_carrinho_test.dart:179` (quemPagou + descricao + total), `:192` ("o valor é o total, não o subtotal"), `:201` (a descrição nomeia o parceiro), `:213` (quemPagou = pessoa `voce`), `:222` (gravada na porta); ponta-a-ponta: `lista_page_test.dart:265` — `porta.salvas.last.$2.despesas.single.valor == enviado.total` | ✅ |
| AC11 confirmar **não** muda os checks | inalterados | `lista_carrinho_test.dart:232` — "confirmar não altera checks nem overrides (A-21)" | ✅ |

### P2-1 — Tudo atrás de uma porta de pedido (LIST-28, LIST-32)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 porta abstrata, adaptador falso, sem rede | um método `enviar` | `pedido_falso_test.dart:50` (a porta declara `enviar` como único método), `:70` (sem import de http/Firebase/dart:io), `:77` (a varredura morde um infrator sintético) | ✅ |
| AC2 o adaptador devolve o pedido e é **ele** que alimenta o overlay | o confirmado é o da porta | `pedido_bloc_test.dart:275` — "o estado guarda o pedido da porta, não o que foi enviado"; `overlay_de_pedido_test.dart:156` — "o ETA é o do pedido confirmado, não o do parceiro escolhido" | ✅ |
| AC3 falha ⇒ sem overlay, sem despesa, erro visível, log | ausência + log | `lista_page_test.dart:280-292` — `find.text(pedidoACaminho) findsNothing` + `salvas.where(despesas.isNotEmpty) isEmpty`; `pedido_bloc_test.dart:295,306,316` | ✅ |
| AC4 copy literal, sem selo de "simulado" | nenhuma marca | `overlay_de_pedido_test.dart:221` — "a árvore tem exatamente as cinco linhas de T-04" | ✅ |

### P2-2 — A lista no computador (LIST-29, LIST-30)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 grid `1fr / 370px` | 370 | `lista_expandida_test.dart:134` — `expect(rail.width, ListaExpandida.larguraDoRail)` + card à esquerda | ✅ |
| AC2 rail sticky, segmented no topo, blocos na ordem de W-04 | a ordem literal | `lista_expandida_test.dart:147-186` — ordem dos cinco blocos, sem repetição (`ordem.toSet() hasLength(ordem.length)`) | ✅ |
| AC3 sem rodapé fixo em expandido | ausente | `lista_expandida_test.dart:228-231` — `RodapeDaLista findsNothing`, `BoraFooterBar findsNothing`, `RailDaLista.ctaKey findsOneWidget` | ✅ |
| AC4 modal central, não bottom sheet | painel expandido | `lista_expandida_test.dart:267-269` — `SheetDePedido.painelExpandidoKey findsOneWidget` + `BoraBottomSheet findsNothing` | ✅ |
| AC5 rola no documento, nunca de lado | zero scroll horizontal | `lista_expandida_test.dart:245-257` — todo `Scrollable` é `Axis.vertical` + `takeException() isNull` | ✅ |
| AC6 cruzar ~900px preserva modo, checks, overrides e item expandido | tudo preservado | `lista_page_test.dart:155-190` — atravessa 900px e reafirma modo, `noCarrinho`, `temOverrides`, `chaveExpandida` e o RESTAURAR | ✅ |
| AC7 os mesmos números nas duas larguras | R$ 271 / ≈R$ 45 / faixa | `lista_expandida_test.dart:274-312` — os mesmos três literais do compacto | ✅ |

### P2-3 — Festa sem ninguém (LIST-31)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 card vazio, sem copy inventada, sem essenciais | vazio | `card_de_planejar_test.dart:219-227` — `LinhaDeItem findsNothing`, `BadgeAuto findsNothing`, categoria e SUBTOTAL `findsNothing` | ✅ |
| AC2 "R$ 0", "≈ R$ 0 por adulto", faixa não renderiza | os dois zeros | `lista_compacta_test.dart:397` (nos dois viewports); `lista_expandida_test.dart:332-334` — `_noRail(r'R$ 0')`, `_noRail(porAdulto(r'R$ 0'))`, `textContaining('faixa real:') findsNothing` | ✅ |
| AC3 CTA inerte, sheet não abre | `onPressed` nulo | `lista_expandida_test.dart:335,340,341`; `lista_compacta_test.dart` idem | ✅ |
| AC4 COMPRAR vazio lê "0 de 0 no carrinho", sem grupo | literal | `lista_compacta_test.dart:422`; `card_de_comprar_test.dart:299` | ✅ |
| AC5 voltar a ter pessoas recalcula com os essenciais | volta | `lista_bloc_test.dart:251` — "voltar a ter pessoas recalcula, com os essenciais de volta" | ✅ |

### P3-1 — As abas permanentes (LIST-35)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 quatro abas literais, ativa a da rota | Lista · Galera · WhatsApp · Custos | `festa_tabs_shell_test.dart:99-136` — os quatro nomes por chave de aba, e um teste por rota afirmando `cream` na ativa e `text2` nas outras | ✅ |
| AC2 tocar navega preservando o estado das outras | `rotaAtual()` | `festa_tabs_shell_test.dart:141-158` — laço tocando as quatro e `expect(rotaAtual(), _rotasDasAbas[indice])` (AD-014); `:161` preserva o override ao trocar de aba | ✅ |
| AC3 `/roles/:festaId/lista` direto renderiza inteiro, com ou sem a barra | renderiza | `festa_tabs_shell_test.dart:199` e `:209` ("a mesma tela renderiza inteira **sem** a barra") | ✅ |

**Status**: **58/61 ✅** · **2 ❌ GAP** (P1-5 AC2 origem do endereço, P1-5 AC6 propagação do modo) · **2 ⚠️ spec-precision/cláusula sem asserção** (P1-3 AC4 2ª cláusula, P1-5 AC9 "mesmo modo").

---

## Edge Cases da `spec.md`

| Edge case | Evidência | Resultado |
|---|---|---|
| Override acima do máximo: faixa não persegue, marcador clampado | `linha_de_item_test.dart:222` | ✅ |
| RN-21 muda a lista sem esta tela recalcular | `calculadora_da_festa_test.dart:131,149,202` | ✅ |
| Kit veggie cai em HORTIFRÚTI com leitura de mercado | `card_de_comprar_test.dart:259` + `card_de_planejar_test.dart:313` | ✅ |
| Item marcado que some da lista: contador reconta | `calculadora_da_festa_test.dart:373` (chave órfã não cria item nem quebra) | ✅ |
| Tudo marcado ⇒ "{M} de {M}" e CTA inerte | `lista_compacta_test.dart:436` | ✅ |
| Duração "Dia" com fator 2,5 | `calculadora_da_festa_test.dart:117` | ✅ |
| Total = arredondamento da soma exata (AD-009), nunca soma de parcelas arredondadas | `totais_test.dart:143` + `lista_sem_formula_test.dart:559` | ✅ |
| Endereço em branco volta ao `Festa.local` | `pedido_bloc_test.dart:196,205` (vazio e só-espaços) | ✅ |
| Nada sobrevive ao restart (AD-016) | comportamento declarado, sem teste — consequência de A-05 | ⚠️ declarado |
| Item expandido continua aberto no recálculo | `lista_bloc_test.dart:192` | ✅ |

---

## Discrimination Sensor

**Profundidade**: P0-full (fluxo de dinheiro + integridade de dado). **21 mutações**, todas em cópia descartável: mutação aplicada no arquivo, teste rodado, `git checkout -- <arquivo>` e `git status` conferido a cada volta.

| # | Arquivo:símbolo | Mutação | Morta? | Quem matou |
|---|---|---|---|---|
| M1 | `lista_bloc.dart` `_aoReceberFesta` | removida a guarda `if (_gravacoesEmVoo > 0) return;` | ✅ Morta | `lista_carrinho_test.dart` — "eco atrasado no meio de uma gravação não regride o estado" |
| M2 | `lista_bloc.dart` `_aoReceberFesta` | removida a guarda `if (evento.festa != null && evento.festa == _ultimaGravada) return;` | ❌ **Sobreviveu** | ninguém — `test/features/lista/**` e `test/core/{routing,festas}/**` seguem verdes |
| M3 | `painel_de_override.dart` `noPisoDeQuantidade` | `=> false` (piso do stepper desligado) | ✅ Morta | `painel_de_override_test.dart` — "no piso de quantidade o decremento é null e o toque é inerte" |
| M4 | `lista_bloc.dart` `_ajustar` | removida a guarda `if (override == festa.composicao.overrides[chave]) return;` | ✅ Morta | `lista_overrides_test.dart` — os dois testes de piso (quantidade e preço) |
| M5 | `pedido_bloc.dart` `_aoEnviar` | removida a idempotência `if (state.enviando \|\| state.confirmado != null) return;` | ✅ Morta | `pedido_bloc_test.dart` — LIST-33, os dois testes |
| M6 | `lista_bloc.dart` `_aoConfirmarPedido` | removida a guarda `if (festa.despesas.contains(despesa)) return;` | ✅ Morta | `lista_carrinho_test.dart` — "dois PedidoConfirmado do mesmo pedido criam uma despesa" |
| M7 | `pedido_bloc.dart` `_aoTrocarEndereco` | endereço vazio deixa de voltar ao da festa | ✅ Morta | `pedido_bloc_test.dart` — "endereço vazio…" e "endereço só com espaços…" |
| M8 | `pedido_bloc.dart` `_aoSelecionarParceiro` | removida `if (!state.podeEscolher(evento.parceiro)) return;` | ✅ Morta | `pedido_bloc_test.dart` — "selecionar o Zé com carne no pedido não muda nada" |
| M9 | `lista_bloc.dart` `_aoReceberFesta` | `if (evento.festa == null) return;` (festa inexistente descartada) | ✅ Morta | `lista_bloc_test.dart` — "festa que não existe abre vazia, com total 0 e sem faixa" |
| M10 | `lista_bloc.dart` `_gravar` | `catch` engole sem `add(GravacaoFalhou(...))` | ✅ Morta | `lista_carrinho_test.dart` + `lista_overrides_test.dart` — LIST-32 |
| M11a | infrator plantado em `lib/features/lista/presentation/widgets/` | `Text('R\$ ${total}')` — cifrão **escapado**, a forma real no disco | ✅ Morta | `lista_sem_formula_test.dart` — "nenhum arquivo viola nenhuma das cinco regras de §13" |
| M11b | idem | `const String prefixo = r'R$ ';` — **raw string** | ✅ Morta | idem |
| M11c | idem | `total.toInt()` e `total.round()` | ✅ Morta | idem |
| M12 | `card_de_comprar.dart` `ordemDosCorredores` | PADARIA e BEBIDAS trocados de lugar | ✅ Morta | `card_de_comprar_test.dart` — LIST-16, três testes |
| M13 | `totais.dart` `itensCobraveis` | devolve **todos** os itens (Copos & pratos entra no dinheiro) | ✅ Morta | 21 falhas — `totais_test.dart`, `faixa_de_preco_test.dart`, `pedido_bloc_test.dart`, `card_de_planejar_test.dart` |
| M14 | `lista_page.dart` `_pedir` | `Navigator.of(context)` em vez de `rootNavigator: true` (o bug da T25) | ✅ Morta | `lista_page_test.dart` — "confirmar o pedido usa o duplo injetado e mostra o overlay…" |
| M15 | `lista_compacta.dart` `TotaisDaLista.de` | `podePedir: true` (CTA nunca inerte) | ✅ Morta | `lista_compacta_test.dart` (3) + `lista_expandida_test.dart` (1) |
| M16 | `lista_bloc.dart` `_itemAjustavel` | percorre `resultado.todosOsItens` (essenciais viram ajustáveis) | ❌ **Sobreviveu** | ninguém |
| M17 | `lista_compacta.dart` `TotaisDaLista.de` | `temOverrides: true` (RESTAURAR sempre visível) | ✅ Morta | `lista_compacta_test.dart` (2) + `lista_expandida_test.dart` (2) |
| M18 | `lista_page.dart:145` | `apenasOQueFalta: false` fixo (o modo COMPRAR deixa de encolher o pedido) | ❌ **Sobreviveu** | ninguém |
| M19 | `lista_page.dart:144` | `enderecoDaFesta: 'Endereco Mutante'` (endereço não vem mais da festa) | ❌ **Sobreviveu** | ninguém |
| M20 | `calculadora_da_festa.dart` | `noCarrinho: false` nos essenciais | ✅ Morta | `calculadora_da_festa_test.dart`, `lista_carrinho_test.dart`, `pedido_bloc_test.dart` (6 falhas) |

**Resultado**: **17/21 mortas · 4 sobreviventes** → ❌ FAIL.

### Leitura dos quatro sobreviventes

- **M18 (Major)** e **M19 (Moderate)** são gaps **reais** de cobertura ponta-a-ponta: os dois únicos argumentos que a `ListaPage` calcula para o `PedidoBloc` — de onde vem o endereço e se o pedido encolhe no modo COMPRAR — não têm nenhum teste. Todo teste de sheet e de bloc **passa esses dois valores à mão**, e o `abrirPelaRota` de `sheet_de_pedido_test.dart:103` não abre por rota nenhuma: ele monta um `GestureDetector` local e chama `SheetDePedido.mostrar` com o bloc que o próprio teste criou.
- **M16 (Minor)**: a defesa "override não se aplica aos essenciais" existe no bloc (`resultado.itens`, não `todosOsItens`) e é declarada por escrito, mas **nenhum teste a exercita**. O único teste correlato é de UI (`card_de_planejar_test.dart:295`, "essencial não expande"), que fecha o caminho pelo widget e não pelo bloc. O efeito colateral da mutação é invisível na tela, porque `ResultadoDoCalculo.temOverrides` deriva de `item.editado` e os essenciais são reconstruídos por `essenciaisAutomaticos()` sem override — mas a composição gravada na porta passaria a carregar um override órfão.
- **M2 (Minor)**: a **primeira** das duas guardas de supressão de eco não tem sensor. O teste que a nomeia (`lista_carrinho_test.dart:279`, "o eco da própria gravação é descartado") afirma `expect(bloc.state, depois)` — e `ListaState.==` exclui `resultado`/`faixaReal` de propósito, então a re-emissão do eco produz um estado **igual** e o próprio `emit` do bloc a descarta. A guarda é uma economia de recálculo, não um comportamento observável: a mutação é comportamentalmente inerte, mas o teste **não prova o que o nome dele promete**.

---

## Auditoria dos desvios declarados

| # | Desvio declarado | Veredito | Evidência |
|---|---|---|---|
| 1 | `BoraStepper` inutilizável: recebe `int` enquanto a régua é `double` | **Procede** | `lib/core/design_system/components/bora_stepper.dart:45` — `final int valor;` e `:64` — `Text('$valor', …)`. Reusá-lo com 1,2 kg exigiria `.round(`/`.toInt(` dentro da feature, que a regra 2 do guard de LIST-07 proíbe (provado por M11c). Reuso × guard são de fato mutuamente exclusivos. `PainelDeOverride` compõe com os **mesmos** tokens (`BoraStepper.simboloMenos/simboloMais/ladoDoBotao/alvoDeToque`, `BoraSurface.decoracaoDe`, `BoraBorders.opacidadeDesabilitado`) e não introduz número novo. Nota menor: o `+` do componente tem `fundoNoHover: BoraColors.primary` e o `BotaoDePasso` não — perda de hover, sem regra de spec a respeito. |
| 2 | Check do carrinho estendido aos **quatro** essenciais de RN-10 | **Procede** | O checklist do modo COMPRAR agrupa `resultado.todosOsItens`, e carvão/gelo/sal caem em MERCEARIA (`catalogo_de_itens_test.dart:224`). Sem a extensão, marcar o carvão se perderia — provado por M20, que mata 6 testes. |
| 3 | Override **não** se aplica aos essenciais (`essenciaisAutomaticos()`) | **Procede na razão, falha na prova** | A razão é correta: a calculadora reconstrói os essenciais a cada cálculo e nunca lhes aplica override, então guardar um seria gravar um ajuste invisível. Mas a guarda do bloc **não tem teste** — ver M16. |
| 4 | `temOverrides` só zera pelo RESTAURAR (P1-3 AC4 admite duas leituras) | **Procede, com gap de spec** | Confirmado no código: `overrides.dart` grava `quantidadeOverride`/`precoOverride` mesmo quando o passo devolve o valor automático, e `item_de_lista.dart:72` define `editado` por `!= null`. UC-06 A1 ata a remoção ao RESTAURAR, o que sustenta a leitura adotada; a 2ª cláusula de AC4 fica sem asserção nas duas leituras. |
| 5 | `RodapeDaLista` composto em vez de `BoraFooterBar` | **Procede** | `bora_footer_bar.dart:42` tem **uma** `final String sublinha`, e T-04 + LIST-06 pedem duas ("faixa real"/contador **e** "≈ R$ x por adulto") mais o RESTAURAR ao lado do CTA. A composição reusa `BoraFooterBar.bordaSuperior` e `BoraSpacing.rodape`. |
| 6 | `CartaoDeParceiro` composto em vez de `BoraSecondaryButton` | **Procede** | O cartão é um radio com dot, nome, qualificador, ETA e frete — não a superfície de um botão de rótulo único. `cartao_de_parceiro_test.dart:296` afirma que o arquivo **não tem literal de cor**, e `:269` que ele afunda `(2,2)` com a sombra de 4→2 (DS-11). |
| 7 | `OverlayDePedido` composto em vez de `BoraSurface` | **Procede** | É overlay de tela cheia com cinco linhas e medidas próprias de T-04 (🛵 56px, título 30px, afirmadas em `overlay_de_pedido_test.dart:286`), não uma superfície de card. |
| 8 | `BadgeAuto` composto em vez de `BoraStatusTag` | **Procede** | `bora_status_tag.dart:18` é um enum **fechado** de sete status com rótulo fixo (`RECEBE`, `PAGA`, …). Ele não consegue renderizar `AUTO ∝ {fonte}`. O badge usa `BoraSurface` com `BoraColors.yellow` (afirmado em `card_de_planejar_test.dart:165`). |
| 9 | `ListaTextos.itensNoCorredor(1)` devolve `"1 itens"` | **Procede como spec-precision gap** | `lista_textos.dart:128`. T-04 escreve "N itens" e não dá o singular. Flexionar inventaria copy; deixar assim exibe "1 itens" em corredor de um item só — feio, e visível ao usuário. Registrado, não corrigido. |
| 10 | Entradas novas na allowlist do guard de forma | **A guarda NÃO afrouxou** | `shape_and_shadow_guard_test.dart:39-52` documenta que a allowlist é **por arquivo e por forma exata**, e `semAsExcecoesDeForma` remove só a string permitida antes de varrer. As duas entradas novas liberam **apenas** `BoxShape.circle` em `linha_de_item.dart` (ponto vermelho de 8px, RN-12) e `cartao_de_parceiro.dart` (dot do radio, T-04) — as duas exceções que §3 declara para dots. `BorderRadius.circular(8)` dentro desses arquivos continuaria acusado. |
| 11 | `Pedido`/`ParceiroDeEntrega` na feature, não em `core/calculo/dominio/` (contra AD-008) | **Procede** | Um consumidor só, e `total_do_pedido.dart` já atribui parceiros/ETAs/fretes à spec `lista`. Declarado em `pedido.dart:1`. |
| 12 | Layout web em grid `1fr / 370px` em vez de "dentro do rail de W-03" (D-3/A-16) | **Procede** | Já declarado na `spec.md`; o rail de `montar` não foi tocado (`lib/features/montar/**` fora do diff). |
| 13 | Três acentos na tela contra os 2 do arquivo 02 §8 (D-4/A-22) | **Procede, declarado** | Vermelho + amarelo estruturais, verde `#0B6B3A` como estado de controle. A leitura estrita de §8 continua violada — declarado em `lista_compacta.dart:27`, não silenciado. |
| 14 | Falha de gravação e falha de pedido sem copy (SPEC_PRECISION_GAP) | **Procede** | Nenhuma tela de `04`/`06` desenha a Lista falhando e RN-29 não tem toast para ela. A evidência do requisito é a preservação do estado + o log (M10 prova que o log e o aviso são discriminados) e a ausência de overlay/despesa (coberto por `lista_page_test.dart:280`). |

---

## O que ninguém tinha verificado

| Verificação | Resultado |
|---|---|
| **AD-014** — a rota de `lista` é afirmada por `rotaAtual()`, não pelo widget | ✅ `lista_page_test.dart:110` — `expect(rotaAtual(), Routes.lista(_festaId), reason: 'AD-014: o destino é afirmado pela URL, não pelo widget')`; `festa_tabs_shell_test.dart:151` idem para as quatro abas. `ListaPage.pageKey` é usada só como "a tela está montada". |
| **AD-011** — `core/design_system/` não foi tocado por esta feature | ✅ `git diff --stat fc744b5..HEAD` não lista **nenhum** arquivo sob `lib/core/design_system/`. O único toque no design system é no **teste** de guarda (allowlist, auditada acima). |
| **AD-011** — nenhuma cor/fonte/sombra fora dos tokens | ✅ `checkbox_da_lista_test.dart:113` e `cartao_de_parceiro_test.dart:296` afirmam ausência de literal de cor nos arquivos; `festa_tabs_shell_test.dart:247,263` afirmam zero canto arredondado / zero blur / cores comparadas com os tokens; o guard global de forma e sombra varre `lib/` inteira e está verde. |
| **`core/calculo/` continua Dart puro** | ✅ Nenhum `package:flutter`, `dart:ui`, `firebase` ou `flutter_bloc` em `lib/core/calculo/**` (só citações em prosa no doc de `calculo.dart`). O guard `calculo_isolation_test.dart` segue verde. |
| **Nenhum teste pré-existente enfraquecido, pulado ou apagado** | ✅ Ver §Gate Check — 4 linhas removidas em `test/`, todas comentário. |
| **O bug da T25 (`rootNavigator: true`) tem teste que o cobre** | ✅ Mutação M14 é **morta** por `lista_page_test.dart:235`. |
| **Regra payload/conjunção** — asserção incide sobre o valor, não sobre a chamada | ✅ em `Despesa` (`lista_carrinho_test.dart:179,192,201,213` afirmam `quemPagou`, `descricao` e `valor` separadamente; `lista_page_test.dart:265` afirma o valor gravado na porta), em `Pedido` (`pedido_test.dart:34` campo a campo; `pedido_bloc_test.dart:275` o confirmado é o **devolvido**), em `FestaEmEdicao` (`festa_em_edicao_test.dart:249-330` — default, igualdade, ordem, `copyWith`) e nos estados dos dois blocs. Não encontrei nenhum caso de "há `emit`, logo há campo". |

---

## Code Quality

| Princípio | Status |
|---|---|
| Código mínimo, sem funcionalidade além do pedido | ✅ |
| Mudanças cirúrgicas; fronteira de arquivos respeitada | ✅ — `lib/core/design_system/**` intocado; `lib/features/{entrar,home,montar,galera,convite,convidado,custos}/**` intocados; `app_router.dart` só no `builder` da rota e na assinatura de `buildAppRouter`; `injector.dart` só registro. As emendas em `core/calculo`/`core/festas` são as duas previstas (E-a, E-b) mais a extensão do check aos essenciais, declarada em comentário. |
| Sem abstração para código de uso único | ✅ |
| Segue os padrões existentes (blocs, `*_textos.dart`, guards de arquitetura) | ✅ |
| Testes mapeiam a AC e não são rasos | ⚠️ — sólidos em domínio e widget; a costura `ListaPage → PedidoBloc` é o ponto raso (M18, M19) |
| Spec-anchored outcome check | ⚠️ — 58/61; 2 GAP, 2 cláusulas sem asserção |
| Cobertura por camada | ⚠️ — domínio 1:1; a camada de **página** tem happy path e erro, mas não os dois argumentos que ela calcula |
| Todo teste mapeia a uma AC / edge case / Done-when | ✅ — nenhum teste órfão encontrado |
| Diretrizes documentadas seguidas | ✅ — `CLAUDE.md` (RN-13 uma vez na formatação, RN-14 com os dois divisores coexistindo, copy literal, zero fórmula na UI), `design.md` §13 |

**RN-13 / AD-009**: verificado que a soma é exata e o arredondamento acontece **uma vez**, na formatação — `totais_test.dart:143` ("o total é o arredondamento da soma exata, não a soma dos arredondados") e `lista_sem_formula_test.dart:559` (270,6 → `R$ 271`, `isNot(R$ 270)`). A regra 2 do guard proíbe `.round(`/`.toInt(`/`.toStringAsFixed(` na feature inteira, e M11c prova que ela morde.

**RN-14**: os dois divisores continuam separados. `estimativaPorCabeca` divide por `pessoas` e `porAdulto` por `adultos` (`totais_test.dart:164,171`, com os guards de zero em `:178,185`). A tela Lista mostra **só** o "por adulto" (`ListaTextos.porAdulto`), e `bora_footer_bar_test.dart:202` afirma que o rodapé de `montar` **não** mostra `R$ 271` — as duas moedas seguem sem se cruzar. Criança fora do racha: preservado pela camada.

---

## Fix Plans

### Fix 1 — O modo COMPRAR precisa chegar ao pedido (Blocker/Major)

- **Raiz**: `lib/features/lista/presentation/pages/lista_page.dart:145` — `apenasOQueFalta: estado.modo == ModoDaLista.comprar` não é exercido por nenhum teste. Todo teste de sheet/bloc passa `apenasOQueFalta` à mão.
- **Fix**: teste em `lista_page_test.dart` que abra a tela pela rota, vá a COMPRAR, marque um item de valor conhecido, toque em `RodapeDaLista.ctaKey`, confirme, e afirme que `duplo.enviados.single.subtotal == subtotalDoQueFalta(itensCobraveis(todosOsItens))` **e** que a chave marcada não está em `enviados.single.itens`.
- **Done when**: fixar `apenasOQueFalta: false` em `lista_page.dart` faz a suíte falhar.

### Fix 2 — O endereço do pedido precisa vir da festa (Major)

- **Raiz**: `lista_page.dart:144` — `enderecoDaFesta: festa.festa.local` sem teste.
- **Fix**: no mesmo teste de rota, afirmar `find.text('Laje do Rafa — Vila Madalena')` dentro da sheet aberta pela rota e `duplo.enviados.single.endereco == 'Laje do Rafa — Vila Madalena'`, com a fixture RN-30 sendo a **única** fonte do literal.
- **Done when**: trocar `festa.festa.local` por uma constante faz a suíte falhar.

### Fix 3 — A guarda "essencial não recebe override" precisa de sensor (Minor)

- **Raiz**: `lista_bloc.dart` `_itemAjustavel` percorre `resultado.itens`; nenhum teste manda `QuantidadeAjustada(ChaveItem.carvao, 1)`.
- **Fix**: teste de bloc que emita `QuantidadeAjustada`/`PrecoAjustado` sobre um essencial e afirme `festa.composicao.overrides isEmpty` e `festas.salvas isEmpty`.
- **Done when**: trocar `resultado.itens` por `resultado.todosOsItens` faz a suíte falhar.

### Fix 4 — O teste de eco precisa afirmar o que o nome promete (Minor)

- **Raiz**: `lista_carrinho_test.dart:279` afirma `expect(bloc.state, depois)`, e `ListaState.==` exclui `resultado`, então a asserção passa com a guarda de igualdade removida.
- **Fix**: afirmar a **contagem de emissões** (por exemplo `emitidos.length` num `bloc.stream.listen`, ou `identical(bloc.state.resultado, antes.resultado)`) para que o descarte do eco seja observável; ou, alternativamente, renomear o teste para o que ele de fato prova e documentar que a guarda é economia de recálculo.
- **Done when**: remover `if (evento.festa != null && evento.festa == _ultimaGravada) return;` faz a suíte falhar.

### Fix 5 — Cláusulas sem asserção (Minor)

- P1-5 AC9 "volta no **mesmo modo**": um `expect(_estado(tester).modo, ModoDaLista.comprar)` depois de "VOLTAR À LISTA" no fluxo aberto em COMPRAR.
- P1-3 AC4 2ª cláusula: decidir por escrito a leitura de "ajuste desfeito" (hoje: só o RESTAURAR) e travá-la com um teste que dê `+1` e `−1` e afirme que o ponto vermelho **continua** — a decisão fica explícita em vez de emergente.

---

## Requirement Traceability Update

| Requisito | Status anterior | Novo status |
|---|---|---|
| LIST-01..LIST-20 | Implementing | ✅ Verified |
| **LIST-21** (endereço da sheet) | Implementing | ❌ Needs Fix — origem do endereço sem teste (Fix 2) |
| LIST-22, LIST-23, LIST-24 | Implementing | ✅ Verified |
| **LIST-25** (só o que falta) | Implementing | ❌ Needs Fix — propagação do modo sem teste (Fix 1) |
| LIST-26, LIST-27, LIST-28 | Implementing | ✅ Verified |
| LIST-29..LIST-35 | Implementing | ✅ Verified |

---

## Integridade da árvore

Todas as 21 mutações foram aplicadas e revertidas uma a uma, com `git checkout -- <arquivo>` (ou `rm`, para os três infratores plantados) e conferência de `git status --porcelain` a cada volta.

- **`git status --porcelain` ao final: vazio** (`CLEAN_COUNT=0`).
- **`flutter test` após a restauração: 1926 passaram, 0 falharam** (exit 0).
- Nenhum arquivo do repositório foi modificado por esta verificação, exceto este `validation.md`.

---

## Summary

**Overall**: ⚠️ Issues — a feature está substancialmente correta e o gate está verde, mas quatro mutantes sobreviveram e dois deles descobrem AC de P1 sem defesa.

**Spec-anchored check**: 58/61 AC batem com o desfecho da spec · 2 GAP · 2 cláusulas sem asserção
**Sensor**: 21 mutações, 17 mortas, 4 sobreviventes
**Gate**: 1926 passaram, 0 falharam, `analyze` limpo

**O que funciona, com prova**: os três literais de maior peso do projeto renderizam e estão travados (R$ 271, ≈ R$ 45 por adulto, R$ 60 nos essenciais com Copos & pratos fora do dinheiro); a faixa real (R$ 245–343 na lista, 286/234/356 na tabela) e o marcador em 37,9%; os passos e pisos de RN-12; a ordem dos cinco corredores; os três totais do pedido (283/280/Zé com frete 0); a `Despesa` com o total; a porta de pedido e o caminho de falha; o layout web inteiro; a festa vazia; as quatro abas. O **guard anti-fórmula da T26 fecha de verdade o furo GAP-1 da spec 05**: as duas formas do cifrão na fonte Dart (escapada e raw) e a família de arredondamento são todas mordidas, provado por três mutações independentes.

**O que falta**: a costura entre a `ListaPage` e o `PedidoBloc`. Os dois argumentos que a página **calcula** — de onde vem o endereço e se o pedido encolhe no modo COMPRAR — são exatamente os dois que nenhum teste observa, porque todo teste de sheet os fornece por conta própria.

**Next steps**: aplicar os Fixes 1 e 2 (bloqueantes para o PASS), depois 3, 4 e 5; re-verificar.

---

## Re-verificação — iteração 2

**Date**: 2026-09-01
**Diff dos fixes**: `3fe503c..879be36` (4 commits: `ffe23c0` GAP-1, `ffd7070` GAP-2, `62b81b8` GAP-3, `879be36` GAP-4). Diff completo da feature: `fc744b5..HEAD`.
**Verifier**: sub-agente independente, iteração 2. Escopo **focado**: os 4 mutantes sobreviventes re-plantados por mim, mais a auditoria do diff dos fixes. Os 58/61 AC e os 17/21 mutantes mortos da iteração 1 continuam valendo — nada no diff dos fixes os invalida (`lib/` intocada).

**Veredito**: ❌ **FAIL** — 3 dos 4 gaps fechados com sensor real; **GAP-4 continua aberto**: a alegação de mutante equivalente **não procede**.

### Superfície do diff

`git diff 3fe503c..HEAD -- lib/` → **vazio**. A alegação do fix worker de não ter tocado `lib/` **procede**: os 4 commits mexem em 3 arquivos de teste e só neles (`+145 / −4` linhas), a saber `lista_carrinho_test.dart`, `lista_overrides_test.dart` e `lista_page_test.dart`. Nenhum arquivo de produção mudou entre a iteração 1 e a 2, o que quer dizer que **todo** resultado da iteração 1 sobre o comportamento continua de pé por construção.

### Os 4 mutantes re-plantados — por mim, na minha mão

Cada mutação aplicada no arquivo real, suíte rodada, `git checkout -- <arquivo>` e `git status --porcelain` conferido vazio a cada volta.

| # | Mutação re-plantada | Morta? | Quantos testes morreram | Quem matou |
|---|---|---|---|---|
| M18 (GAP-1) | `lista_page.dart:148` — `apenasOQueFalta: false` fixo | ✅ **Morta** | **1** | `lista_page_test.dart` — LIST-25 "a sheet aberta em COMPRAR pede só o que falta, e o subtotal reflete só ele" |
| M19 (GAP-2) | `lista_page.dart:147` — `enderecoDaFesta: 'Endereco Mutante'` | ✅ **Morta** | **1** | `lista_page_test.dart` — LIST-21 "a linha 📍 e o pedido carregam o local da festa aberta" |
| **M19′ (GAP-2, mutante esperto)** | `lista_page.dart:147` — `enderecoDaFesta: 'Laje do Rafa — Vila Madalena'` (a constante **é** o literal de RN-30) | ✅ **Morta** | **1** | o mesmo teste LIST-21 |
| M16 (GAP-3) | `lista_bloc.dart:376` — `_itemAjustavel` percorre `resultado.todosOsItens` | ✅ **Morta** | **2** | `lista_overrides_test.dart` — RN-10, "ajustar carvao/coposEPratos não grava override nem toca a porta" (laço por chave) |
| M2 (GAP-4) | `lista_bloc.dart:96` — removida a 1ª guarda de `_aoReceberFesta` (`evento.festa == _ultimaGravada`) | ❌ **Sobreviveu** | 0 | ninguém — **suíte inteira: 1930 passaram, 0 falharam** |

**3/4 mortos · 1 sobrevivente.**

### A afirmação do fixer sobre o mutante esperto do GAP-2 — verificada, e **procede**

O fixer alegou que a receita do "Fix 2" da iteração 1 — afirmar `find.text('Laje do Rafa — Vila Madalena')`, o endereço **da fixture** RN-30 — deixaria passar uma constante plantada com esse mesmo literal, e que por isso ele escolheu um endereço distinto (`'Quintal do Tonho — Freguesia do Ó'`, injetado pelo parâmetro novo `local:` de `_festaRn30`/`_abrir`).

Verificado **empiricamente**, não por leitura: com M19′ plantada, troquei no teste `const local = 'Quintal do Tonho — Freguesia do Ó';` por `const local = _endereco;` (ou seja, a receita da iteração 1) e rodei `lista_page_test.dart`:

- receita da iteração 1 + M19′ → **`+11: All tests passed!`** — o mutante **sobrevive**;
- teste como o fixer escreveu + M19′ → **morre**.

A afirmação está correta, e a escolha dele é uma melhoria real sobre a receita que a iteração 1 havia prescrito: com o endereço da fixture, "veio da festa" e "está escrito na página" são indistinguíveis. O teste e o arquivo foram restaurados (`git checkout -- lib/ test/`, status vazio).

### O julgamento do GAP-4 — a alegação de equivalência **não procede**

**O que foi verificado e confere:**

1. **A citação existe.** `pubspec.lock` fixa `bloc` em **9.2.1**, e `~/AppData/Local/Pub/Cache/hosted/pub.dev/bloc-9.2.1/lib/src/bloc_base.dart` tem, **exatamente na linha 102**, `if (state == _state && _emitted) return;`. A citação do fixer é literal e correta.
2. **`ListaState.==` de fato exclui `resultado` e `faixaReal`** (`lista_state.dart`), e inclui `carregando`, `festa`, `modo`, `chaveExpandida`, `falhouAoSalvar`. `_estadoCom` copia `modo`, `chaveExpandida` e `falhouAoSalvar` do estado corrente e fixa `carregando: false` — logo os **únicos** campos do `==` que um eco pode mover são `carregando` e `festa`.
3. **`carregando` é inalcançável**: `_ultimaGravada` só fica não-nulo dentro de `_gravar`, chamado por `_aplicarMudanca`, que emite `_estadoCom` antes — quando a guarda pode disparar, `carregando` já é `false`.
4. **A suíte inteira segue verde com a guarda removida** — 1930 passaram, 0 falharam. Confere com o que o fixer disse.

**O que derruba a alegação:** a equivalência depende de uma premissa **não universal** — `state.festa == _ultimaGravada` no instante em que a guarda dispara. Ela vale no eco puro, e **não** vale quando uma mudança externa entrou entre a nossa gravação e a emissão seguinte. Nesse caso `_estadoCom(evento.festa)` produz um `ListaState` diferente **por `festa`**, que é campo **incluído** no `==` — e a emissão sai.

Provado com uma sonda descartável (`zz_probe_verifier_test.dart`, criada, rodada e apagada; nada commitado):

| Sonda | Sequência | Original | Com a guarda removida |
|---|---|---|---|
| **A — eco puro** | ajuste local (`state.festa == _ultimaGravada == A`) → porta re-emite `A` | zero emissões, `identical(state, depois)` | **idêntico** — `emit` descarta pela igualdade. Inerte ✅ |
| **B — escrita externa que coincide com a nossa** | ajuste local (`A`) → **escrita externa `X`** (`state.festa == X`, `_ultimaGravada` continua `A`) → escrita externa que devolve `A` | zero emissões, tela fica em `X` | **`emitidos` recebe 1 `ListaState`; `state.festa` vira `A`** — **DISCRIMINA** ❌ |

A sonda B **não viola o contrato da porta**: `FestaEmEdicaoRepositoryFake.emitir` grava `_festas[id] = festa` e só então emite, ou seja, cada emissão é o valor **corrente** da porta, entregue em ordem, sem gravação em voo (`_gravacoesEmVoo == 0`). É uma sequência ordinária de duas escritas externas — o caminho real é `galera` mexer na composição (RN-21, com a Lista viva no `indexedStack`) e depois desfazer, deixando a festa num valor que por acaso é igual ao que a Lista gravou por último.

O efeito, quando isso acontece: a guarda **descarta uma mudança externa legítima** e a tela fica exibindo `X` enquanto a porta já guarda `A`. Não é economia de recálculo — é estado de tela obsoleto. Note ainda que o doc da própria guarda declara como consequência aceita só a mudança externa que chega **no meio de uma gravação** — essa é a **2ª** guarda, coberta por M1. A mudança externa **sem gravação em voo** não está declarada em lugar nenhum.

**Conclusão**: a 1ª guarda **não é** mutante equivalente. É comportamento observável, discriminável por um teste que a sonda B mostra ser escrevível em ~15 linhas, e nenhum teste o exerce. GAP-4 **continua aberto** — diferente do precedente `replace` vs `go` da spec 05, em que as duas formas produziam de fato o mesmo desfecho observável.

**Sobre a renomeação do teste (saída (b) escolhida pelo fixer)**: ela **fortaleceu**, como alegado — nada foi afrouxado. O nome saiu de "o eco da própria gravação é descartado" para "o eco da própria gravação não move a tela", e as asserções são um **superconjunto** estrito das antigas: `expect(bloc.state, depois)` e `editado isTrue` continuam, e entram `expect(emitidos, isEmpty, reason: …)` sobre um `bloc.stream.listen` e `expect(identical(bloc.state.resultado, depois.resultado), isTrue, reason: …)`. O nome novo é **honesto** — o antigo prometia discriminar a guarda e não discriminava. Mas honestidade de nome documenta o furo; não o fecha. E como a premissa em que ela se apoia é falsa, o que o comentário de 18 linhas acima do teste afirma ("Não é furo de teste, é mutante equivalente") **está incorreto** e precisa ser corrigido junto com o fix.

### Os fixes afrouxaram alguma coisa? **Não**

| Verificação | Resultado |
|---|---|
| `git diff 3fe503c..HEAD -- lib/` vazio | ✅ nenhum código de produção tocado |
| Teste existente enfraquecido, ou com asserção/`reason` removido | ✅ nenhum. As linhas removidas no diff são a assinatura do `test(` renomeado e as linhas em volta; **nenhuma asserção saiu** |
| Renomeação do GAP-4 fortaleceu | ✅ superconjunto estrito das asserções antigas (ver acima) |
| `skip:` / `solo:` em `test/features/lista/**` | ✅ zero ocorrências |
| Teste apagado | ✅ nenhum — contagem 1926 → **1930** (+4: GAP-1 +1, GAP-2 +1, GAP-3 +2 pelo laço; GAP-4 renomeia, não soma) |
| Pré-condição do teste do GAP-1 é real e correta | ✅ `expect(soOQueFalta, lessThan(subtotalDeItens(cobraveis)))` — o item marcado é o primeiro `CheckboxDaLista` do modo COMPRAR (AÇOUGUE/bovina), cobrável e de valor não-nulo, então a desigualdade é verdadeira **e** necessária: com um item de valor 0 os dois subtotais coincidiriam e o teste não discriminaria modo nenhum. A prova de que ela não é decorativa é M18 morrer |
| Os 2 spec-precision gaps continuam abertos de propósito | ✅ **intocados**. Varredura por `mesmo modo`, `ajuste desfeito`, `desfaz o ajuste` em `test/features/lista/**`: **zero ocorrências**. Nem P1-3 AC4 2ª cláusula nem P1-5 AC9 foram "resolvidos" por leitura inventada — o fixer respeitou que a decisão é do usuário |

### Gate (rodado por mim, com a árvore restaurada)

- `flutter test` → **1930 passaram, 0 falharam, 0 pulados** (exit 0)
- `flutter analyze` → **`No issues found!`** (exit 0)
- `git status --porcelain` → **vazio**

### Integridade da árvore

Cinco mutações de produção (M18, M19, M19′, M16, M2), uma mutação de teste (a receita da iteração 1, para auditar a alegação do GAP-2) e uma sonda descartável (`zz_probe_verifier_test.dart`). Todas aplicadas e revertidas uma a uma com `git checkout -- <arquivo>` / `rm`, com `git status --porcelain` conferido **vazio a cada volta**. Nada foi consertado por esta verificação. Nenhum arquivo do repositório ficou modificado, exceto este `validation.md`.

### Traceability — atualização da iteração 2

| Requisito | Status iteração 1 | Novo status |
|---|---|---|
| **LIST-21** (endereço da sheet) | ❌ Needs Fix | ✅ **Verified** — M19 e M19′ mortos |
| **LIST-25** (só o que falta) | ❌ Needs Fix | ✅ **Verified** — M18 morto |
| RN-10 / override nos essenciais (sensor do Fix 3) | sem sensor | ✅ **Verified** — M16 morto |
| **LIST-34** (supressão de eco) | ⚠️ sem sensor na 1ª guarda | ❌ **Needs Fix** — a guarda não é equivalente (sonda B) |

### Gap remanescente — o único

**GAP-4 (Minor) — a 1ª guarda de `_aoReceberFesta` continua sem sensor, e não é equivalente**

- **Raiz**: `lib/features/lista/presentation/bloc/lista_bloc.dart:96` — `if (evento.festa != null && evento.festa == _ultimaGravada) return;`. Removê-la deixa as 1930 verdes.
- **Por que não é equivalente**: quando `state.festa != _ultimaGravada` — uma escrita externa entrou depois da nossa gravação —, uma emissão seguinte igual a `_ultimaGravada` produz um `ListaState` diferente **por `festa`**, campo incluído no `==`, e a emissão sai. A guarda a suprime, e a tela fica obsoleta.
- **Fix**: promover a sonda B a teste de `lista_carrinho_test.dart` (grupo LIST-34), com o nome dizendo o que ela trava. Duas saídas legítimas, e a escolha é de produto:
  1. **manter a guarda**, e o teste afirma o comportamento atual (a tela fica em `X`, a escrita externa coincidente é descartada) — aí a consequência precisa ser **declarada** no doc de `_aoReceberFesta`, ao lado da que já está escrita para a 2ª guarda;
  2. **trocar a guarda** por `evento.festa == state.festa`, que é o que a economia de recálculo de fato quer dizer — passa a ser inerte de verdade, e o teste trava a não-regressão.
- **Corrigir junto**: o comentário novo em `lista_carrinho_test.dart` afirma "Não é furo de teste, é mutante equivalente". A sonda B mostra que não é; o comentário precisa ser reescrito.
- **Done when**: remover a linha 96 de `lista_bloc.dart` faz a suíte falhar.

### Summary da iteração 2

**Overall**: ⚠️ Issues — 3 dos 4 gaps genuinamente fechados, com mutante morrendo na minha mão em cada um; 1 aberto.

**O que melhorou de verdade**: os dois gaps bloqueantes da iteração 1 (M18/M19, a costura `ListaPage → PedidoBloc`) estão fechados, e o do endereço está fechado **melhor** do que a receita prescrita na iteração 1 — o fixer viu que a fixture RN-30 tornava o sensor cego e injetou um endereço distinto, o que verifiquei ser exatamente a diferença entre matar e não matar M19′. O sensor do GAP-3 mira a **composição gravada**, que é onde o efeito é observável, e não a tela, onde ele é invisível.

**O que falta**: um único gap Minor. O fixer foi honesto ao renomear em vez de fingir cobertura, e as asserções que ele acrescentou são estritamente mais fortes — mas o raciocínio de equivalência parou no eco puro e não considerou a escrita externa coincidente, que discrimina.

**Next steps**: fechar o GAP-4 por uma das duas saídas acima (iteração 3 de 3) e re-verificar só esse mutante.

---

## Re-verificação — iteração 3 (final)

**Date**: 2026-09-02
**Diff dos fixes desta iteração**: `761a82a..HEAD` (3 commits: `ebdb0ca` GAP-4, `3762e7e` P1-3 AC4, `135ad11` handoff). Diff completo da feature: `fc744b5..HEAD`.
**Verifier**: sub-agente independente, iteração 3 — a **última** do laço fix→re-verify. Escopo: os dois commits novos re-mutados do zero, os 3 gaps da iteração 2 re-plantados, uma amostra de regressão de 3 mutações da iteração 1, e a auditoria do diff.

**Veredito**: ✅ **PASS** — os mutantes exigidos morreram, cada um com o conjunto **exato** de testes que a spec prevê; os 3 gaps da iteração 2 seguem fechados; a amostra de regressão continua morrendo; nada foi afrouxado.

### Superfície do diff desde a iteração 2

`git diff --stat 761a82a..HEAD` toca 5 arquivos: `lib/features/lista/presentation/bloc/lista_bloc.dart` (+11/−9), dois arquivos de teste (+105/−14), `.specs/features/lista/spec.md` (+2/−1) e `.specs/STATE.md` (handoff).

- **As 14 linhas removidas em `test/` são todas comentário** — o bloco de 11 linhas que afirmava "mutante equivalente" no grupo LIST-34, mais 3 linhas do parágrafo seguinte, reescritas. **Nenhuma asserção saiu, nenhum `test(` ou `group(` foi apagado ou renomeado**: o diff de nomes tem só `+` (1 `test` novo em LIST-34, 1 `group` + 2 `test` novos em LIST-12).
- Contagem **1930 → 1933 (+3)**, e os 3 são exatamente os 3 testes novos. Varredura por `skip:`/`solo:` em `test/features/lista/**` e `test/core/routing/**`: **zero**.
- **`spec.md` não alterou nenhum AC.** As 2 linhas acrescentadas são um bloco de citação **abaixo** do AC4 (registro datado da decisão), e o texto do AC4 continua byte a byte o mesmo; a única linha modificada é a célula "Notas" da linha LIST-12 da matriz de rastreabilidade. Nenhum SHALL foi reescrito, enfraquecido ou removido.

### Os mutantes dos dois commits novos — re-plantados por mim

Cada mutação aplicada no arquivo real, `flutter test` inteiro rodado, `git checkout -- <arquivo>` e `git status --porcelain` conferido a cada volta.

| # | Mutação re-plantada | Morta? | Quantos | Quais testes morreram |
|---|---|---|---|---|
| **N1 (GAP-4, reversão do fix)** | `lista_bloc.dart` — o arquivo inteiro restaurado de `761a82a`, ou seja, o campo `_ultimaGravada` de volta e a 1ª guarda comparando com ele | ✅ **Morta** | **1** | `lista_carrinho_test.dart` — LIST-34 "escrita externa que devolve o valor que gravamos chega à tela" |
| **N2 (GAP-4, 2ª guarda)** | `lista_bloc.dart:97` — removida `if (_gravacoesEmVoo > 0) return;` | ✅ **Morta** | **1** | `lista_carrinho_test.dart` — LIST-34 "eco atrasado no meio de uma gravação não regride o estado" |
| **N3 (P1-3 AC4, leitura rival)** | `item_de_lista.dart:72` — `editado` passa a ser "override **diferente** do automático": `(quantidadeOverride != null && quantidadeOverride != quantidadeAutomatica) \|\| (precoOverride != null && precoOverride != precoBase)` | ✅ **Morta** | **2** | `lista_overrides_test.dart` — LIST-12 "subir e voltar ao valor automático mantém o override e a marca" **e** "só o RESTAURAR apaga a marca do ajuste desfeito" |

**3/3 mortos.** Os dois números importam:

- **N1 e N2 são discriminados por testes distintos, um cada.** As duas guardas de `_aoReceberFesta` têm sensor **separado** — nenhuma está de carona na outra. É exatamente o que faltava na iteração 1 (M2 sobrevivia) e na iteração 2 (a 1ª guarda continuava sem sensor).
- **N3 mata 2 e só 2**, os dois testes novos do grupo LIST-12, e **nenhum outro** dos 1933. O mutante não é grosseiro: a leitura rival de `editado` é indistinguível para o resto da suíte, o que confirma que o sensor mira precisamente a cláusula ambígua em vez de morder por acidente. E não é falso: se `+1`/`−1` não devolvesse a quantidade ao automático, a pré-condição `expect(item.quantidade, closeTo(automatica, 1e-9))` do primeiro teste falharia; ela passa, então o cenário exercido é o real.

### Sonda extra — a 1ª guarda **na forma nova** é, aí sim, equivalente

Removi a 1ª guarda por inteiro (`if (evento.festa != null && evento.festa == state.festa) return;` apagada): **1933 passaram, 0 falharam**. Isso **não** é um gap, e é a diferença de estrutura que fecha o GAP-4:

- na forma antiga a guarda comparava com `_ultimaGravada` e **descartava escrita externa legítima** — comportamento observável, e portanto exigia sensor. Ele agora existe (N1);
- na forma nova ela compara com `state.festa`, e o desfecho é o mesmo com ou sem ela: `_estadoCom(evento.festa)` reproduz um `ListaState` igual ao corrente e o `emit` do próprio bloc o descarta pela igualdade. É economia de recálculo, **e o doc de `_aoReceberFesta` declara exatamente isso** ("a guarda só poupa o recálculo"). O comentário do grupo LIST-34 também foi reescrito e não afirma mais equivalência onde não havia.

Ou seja: o fix não escondeu o mutante — ele **moveu o comportamento observável para onde há teste** e deixou inerte só a parte que de fato é inerte, com a alegação de inércia agora verdadeira e verificada.

### Os 3 gaps da iteração 2 — re-plantados, seguem fechados

| # | Mutação re-plantada | Morta? | Quantos | Quem matou |
|---|---|---|---|---|
| M18 (GAP-1) | `lista_page.dart:148` — `apenasOQueFalta: false` fixo | ✅ **Morta** | **1** | `lista_page_test.dart` — LIST-25 "a sheet aberta em COMPRAR pede só o que falta, e o subtotal reflete só ele" |
| M19 (GAP-2) | `lista_page.dart:147` — `enderecoDaFesta: 'Endereco Mutante'` | ✅ **Morta** | **1** | `lista_page_test.dart` — LIST-21 "a linha 📍 e o pedido carregam o local da festa aberta" |
| M19′ (GAP-2, mutante esperto) | `lista_page.dart:147` — `enderecoDaFesta: 'Laje do Rafa — Vila Madalena'` (a constante **é** o literal de RN-30) | ✅ **Morta** | **1** | o mesmo teste LIST-21 |
| M16 (GAP-3) | `lista_bloc.dart:378` — `_itemAjustavel` percorre `resultado.todosOsItens` | ✅ **Morta** | **2** | `lista_overrides_test.dart` — RN-10, "ajustar carvao…" e "ajustar coposEPratos não grava override nem toca a porta" |

**4/4 mortos.** Nenhuma regressão: o fix do GAP-4, único a tocar `lib/` desde a iteração 2, não afrouxou nenhum dos anteriores.

### Amostra de regressão da iteração 1 — 3 mutações de alto valor

| # | Mutação | Morta? | Quantos | Quem matou |
|---|---|---|---|---|
| M13 | `regras/totais.dart:17` — `itensCobraveis` devolve **todos** os itens (Copos & pratos entra no dinheiro) | ✅ **Morta** | **21** | `totais_test.dart` (LIST-04, o predicado da AD-010), `faixa_de_preco_test.dart` (as três: Copos fora das pontas, 244,60/342,60, override não move a faixa) e mais 17 |
| M11a | infrator plantado em `lib/features/lista/presentation/widgets/` com o cifrão **escapado** — `Text('R\$ ${total}')`, a forma real no disco | ✅ **Morta** | **1** | `lista_sem_formula_test.dart` — LIST-07 "nenhum arquivo viola nenhuma das cinco regras de §13" |
| M12 | `card_de_comprar.dart:37` — `ordemDosCorredores` com PADARIA e BEBIDAS trocados | ✅ **Morta** | **3** | `card_de_comprar_test.dart` — LIST-16 nos dois viewports **e** "a lista literal é a de RN-27" |

**3/3 mortos.** Os 17/21 da iteração 1 continuam de pé — e o diff novo (um único arquivo de produção, `lista_bloc.dart`) não toca nenhuma das superfícies que eles cobrem.

### O spec-precision gap que devia continuar aberto — continua

**P1-5 AC9 ("volta no mesmo modo")**: **aberto, de propósito, e ninguém inventou leitura.** A única ocorrência de `ModoDaLista.comprar` em `lista_page_test.dart` é a **linha 178**, dentro do teste de travessia de viewport de P2-2 AC6 (`reason: 'W-R3: o modo ativo atravessa a fronteira de AD-007'`) — nada a ver com o retorno do overlay. Nenhum teste de `overlay_de_pedido_test.dart` afirma modo. O gap segue registrado e não fechado, como o usuário decidiu.

O outro gap, **P1-3 AC4 2ª cláusula**, deixou de ser spec-precision gap: a decisão do usuário está datada no corpo do AC em `spec.md`, na matriz de rastreabilidade e em comentário no teste, e a leitura escolhida está **travada por sensor** (N3).

### Nada foi afrouxado

| Verificação | Resultado |
|---|---|
| Linhas removidas em `test/` | ✅ 14, **todas comentário** — o bloco de "mutante equivalente" que a iteração 2 apontou como incorreto |
| Asserção enfraquecida, `reason` removido, `findsAny` introduzido | ✅ nenhum |
| `skip:` / `solo:` | ✅ zero em `test/features/lista/**` e `test/core/routing/**` |
| Teste apagado ou renomeado para prometer menos | ✅ nenhum — o diff de nomes é 100% `+` |
| Contagem | ✅ 1930 → **1933** (+3), e os 3 são os 3 novos |
| `spec.md` alterou algum AC | ✅ **não** — só um bloco de citação abaixo do AC4 e uma célula "Notas" da matriz |
| O comentário incorreto de LIST-34 foi corrigido | ✅ reescrito; não afirma mais equivalência onde a iteração 2 provou que não havia |
| A sequência da porta no teste novo é legítima | ✅ `FestaEmEdicaoRepositoryFake.emitir` (`test/support/festa_em_edicao_repository_fake.dart:80-88`) grava `_festas[id] = festa` **e só então** `_controllerDe(id).add(festa)` — cada emissão é o valor corrente da porta, sem gravação em voo. Não é cenário fabricado |

### Gate (rodado por mim, com a árvore restaurada)

- `flutter test` → **1933 passaram, 0 falharam, 0 pulados** (exit 0)
- `flutter analyze` → **`No issues found!`** (exit 0)
- `git status --porcelain` → só `?? .vscode/`, **diretório não rastreado que já estava lá antes desta verificação começar** e que não pertence à feature. Nenhum arquivo rastreado modificado.

### Integridade da árvore

Onze mutações nesta iteração: N1, N2, N3, a sonda extra da 1ª guarda, M18, M19, M19′, M16, M13, M11a e M12. Todas aplicadas no arquivo real e revertidas uma a uma com `git checkout -- <arquivo>` (ou `rm`, para o infrator plantado do M11a), com `git status --porcelain` conferido a cada volta. **Nada foi consertado por esta verificação.** Nenhum arquivo do repositório ficou modificado, exceto este `validation.md`.

### Traceability — atualização da iteração 3

| Requisito | Status iteração 2 | Novo status |
|---|---|---|
| **LIST-34** (supressão de eco) | ❌ Needs Fix | ✅ **Verified** — as duas guardas com sensor **separado** (N1, N2); a forma nova da 1ª é inerte e declarada como tal |
| **LIST-12** (ponto vermelho) | ⚠️ spec-precision gap | ✅ **Verified** — leitura decidida, registrada e travada (N3) |
| LIST-21, LIST-25, RN-10/override nos essenciais | ✅ Verified | ✅ **Verified** (re-confirmado: M18, M19, M19′, M16) |
| LIST-01..LIST-20, LIST-22..LIST-33, LIST-35 | ✅ Verified | ✅ **Verified** (amostra M13, M11a, M12 re-confirmada) |
| **P1-5 AC9** ("mesmo modo") | ⚠️ aberto por decisão do usuário | ⚠️ **aberto, de propósito** — registrado, não bloqueante |

### Summary da iteração 3

**Overall**: ✅ **PASS**. O laço fecha com 61/61 AC defendidos ou explicitamente decididos, e com todos os mutantes exigidos morrendo na minha mão.

**O que o GAP-4 virou**: o fix não é cosmético. Ele **trocou uma semântica defeituosa** — a guarda que descartava escrita externa legítima e deixava a tela obsoleta — pela que o doc sempre alegou ter, e promoveu a sonda B da iteração 2 a teste permanente. Que a reversão para `_ultimaGravada` mate exatamente esse teste, e que a remoção da 2ª guarda mate exatamente o outro, prova que as duas guardas são discriminadas **independentemente**. Que a remoção da 1ª guarda na forma nova não mate nada é o desfecho **correto e declarado**, não um furo.

**O que o P1-3 AC4 virou**: nenhuma mudança de comportamento, e é o certo — a decisão do usuário foi pela semântica que `core/calculo` já carregava, e mudar `ItemDeLista.editado` para resolver dúvida de uma tela contaminaria uma entidade compartilhada. O que faltava era a **decisão explícita** e o **sensor**, e os dois entraram. O mutante da leitura rival mata 2 testes e só 2 — mira certo, sem morder por acidente.

**Resta aberto, sem bloquear**: `P1-5 AC9` ("volta no mesmo modo"), por decisão do usuário, e os spec-precision gaps já auditados na iteração 1 (`"1 itens"`, os três acentos de D-4, a falta de copy para falha). Todos registrados, nenhum silenciado.

**Recomendação**: a feature `lista` está **pronta para merge**.
