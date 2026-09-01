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
