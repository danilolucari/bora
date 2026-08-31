# Montar — "A conta do rolê" — Validation

**Data**: 2026-08-31
**Spec**: `.specs/features/montar/spec.md` (MONT-01..MONT-24)
**Diff range**: `fc09a76..9bbd1c0` na branch `feature/montar` (30 commits, 24 tasks)
**Verifier**: sub-agente independente (autor ≠ verificador), evidence-or-zero — cobertura
re-derivada do `spec.md`; nenhuma alegação de `tasks.md`, de mensagem de commit ou de
"self-check de adequação" de worker aceita como prova
**SDK**: Flutter 3.47.1 · Dart 3.13.1 (`C:/SDKs/flutter/bin/flutter`), Windows 11

**Veredito**: ⚠️ **PASS COM RESSALVAS**

O portão está verde — **1519 testes passando**, `flutter analyze` sem nenhum issue — e os
24 requisitos têm evidência ancorada com `file:line` e expressão de asserção. O número
canônico de UC-03 (**R$ 211** / **≈ R$ 30 / cabeça**) é alcançado **pelos eventos da tela**
no bloc e renderizado nas duas plataformas; o `porCabeca` (divisor = pessoas) e o
`porAdulto` continuam separados, com asserção explícita de que divergem; a fronteira com
`core/calculo` é policiada por varredura **e** por teste comportamental.

O sensor de discriminação executou **21 mutações comportamentais** e matou **15**; 2 são
mutantes equivalentes (mudança sem comportamento observável). As **4 sobreviventes** não
são erros de produto — o código está correto — são **furos de sensor**, e ficam exatamente
em cima do que este projeto declarou mais caro: a preservação de `pessoas` (RN-21) no
`copyWith` manual do bloc, o nome da festa na linha de título do web, e a regra 1 do guard
MONT-08, que na prática **não pega a forma como o cifrão de fato se escreve em Dart**.

---

## Gate Check

- **Comando**: `flutter test` · `flutter analyze` (raiz do repo, PATH com `C:/SDKs/flutter/bin`)
- **Resultado**: `All tests passed!` — **1519 passed, 0 failed, 0 skipped** (`exit=0`)
- **`flutter analyze`**: `No issues found! (ran in 1.5s)` (`exit=0`)
- **Baseline antes da feature**: 1137 testes na `main`
- **Delta**: **+382 testes**
- **Integridade**: nenhum teste removido. 4 testes pré-existentes foram *alterados* — auditados
  abaixo, sem enfraquecimento.
- **Árvore ao fim do sensor**: ✅ limpa (`git status` → `nothing to commit, working tree clean`)

---

## Cobertura ancorada na spec (evidence-or-zero)

Um critério sem `file:line` **mais** a expressão da asserção conta como não coberto.
Onde a spec não fixa valor preciso, a linha é marcada ⚠️ **spec-precision gap** em vez de
passar batido.

### P1-1 — Montar o churras no celular (MONT-01, MONT-02, MONT-03)

| Critério | Valor que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — ordem de T-03: header/voltar, "A CONTA DO ROLÊ", 3 steppers, 3 seções de chips, segmented | ordem literal e copy literal | `test/.../widgets/montar_compacto_test.dart:89` — `expect(ordem, orderedEquals(List<double>.from(ordem)..sort()))` sobre `[voltar, 'A CONTA DO ROLÊ', CabecalhoDoRole, FormularioDeMontagem, RodapeDoCusto]` | ✅ PASS |
| AC1 — literais das 5 seções + 11 chips | "CONFIRMADOS + EXTRAS SEM APP", "NA GRELHA", "NA GELADEIRA", "PROS FORTES", "QUANTO TEMPO DE FESTA?" | `montar_compacto_test.dart:112-118` — `expect(find.text('CONFIRMADOS + EXTRAS SEM APP'), findsOneWidget)` … `expect(find.byType(BoraSelectionChip), findsNWidgets(11))` | ✅ PASS |
| AC1 — os 11 chips e sua ordem | 🥩🐷🍗 · 🧄🥤🧃💧🍺 · 🍸🍹🥃 (A-01) | `test/.../domain/secao_da_montagem_test.dart:74,82,94` — `expect(chipsPorSecao[SecaoDaMontagem.naGrelha], [bovina, suina, frango])`, idem geladeira (5) e prosFortes (`[vodka, cachaca, whisky]`) | ✅ PASS |
| AC1 — copy dos 3 steppers | "👨 Homens", "👩 Mulheres", "🧒 Crianças" | `test/.../montar_textos_test.dart:18-20` — `expect(MontarTextos.homens, '👨 Homens')` etc. | ✅ PASS |
| AC1 — segmented 2h/4h/6h/Dia | lista literal | `montar_textos_test.dart:41` — `expect(MontarTextos.opcoesDeDuracao, ['2h','4h','6h','Dia'])` | ✅ PASS |
| AC2 — chip alterna, selecionado em vermelho | par ink/cream de §5 | `test/.../widgets/secao_de_chips_test.dart:134,155` — grupos "tocar um chip emite a chave dele" e "o estado de seleção é o par ink/cream de §5" | ✅ PASS |
| AC3 — segmented: uma ativa, as demais saem | exatamente 1 ativa | `test/.../widgets/secao_de_duracao_test.dart:97` — grupo "exatamente uma ativa, e ela é a duração recebida" | ✅ PASS |
| AC4 — stepper muda de 1 em 1 | ±1 por acionamento | `test/.../widgets/card_de_contagem_test.dart:96` — cada stepper emite `(tipo, ±1)` da sua própria linha | ✅ PASS |
| AC5 — rodapé com "SAI POR", total, "≈ R$ {x} / cabeça", "FECHAR LISTA →" | copy literal | `test/.../widgets/rodape_do_custo_test.dart:69,75` — `expect(find.text('SAI POR'), findsOneWidget)`, `expect(find.text('FECHAR LISTA →'), findsOneWidget)`; `:91` — `expect(find.text('≈ R\$ 30 / cabeça'), findsOneWidget)` | ✅ PASS |
| AC5 — rodapé é **fixo** (não rola) | não se move com a rolagem | `montar_compacto_test.dart:139-141` — `expect(tester.getRect(find.byType(RodapeDoCusto)), rodapeAntes)` depois de `drag(…, Offset(0,-200))` | ✅ PASS |

### P1-2 — O custo muda embaixo do dedo (MONT-04..MONT-08)

| Critério | Valor que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — qualquer toque recalcula imediatamente, sem botão "calcular" | recálculo na mesma interação | `test/.../bloc/montar_bloc_test.dart:128,138,148` — `expect(bloc.state.resultado.totalDosItens, greaterThan(antes))` para stepper, chip e duração; `:95` — todo evento deixa `resultado == CalculadoraDaFesta.calcular(state.composicao)` | ✅ PASS |
| AC1 — nenhum botão "calcular" existe | ausência | — nenhuma asserção de **ausência** de um controle "calcular" | ⚠️ **gap declarado pelo autor — ver GAP-4** |
| AC2 — estado padrão de RN-30 ⇒ "R$ 211" | `totalDosItens ≈ 210,60` → `R$ 211` | `montar_bloc_test.dart:162-166` — `expect(bloc.state.resultado.totalDosItens, closeTo(210.6, 0.001))` **e** `expect(MoneyFormatter.reais(...), 'R\$ 211')`, com o estado alcançado por **7 `ContagemAlterada` reais** (`:71-79`) | ✅ PASS |
| AC2 — ⇒ "≈ R$ 30 / cabeça" | `porCabeca ≈ 30,0857`, 7 pessoas | `montar_bloc_test.dart:171-174` — `expect(contagem.pessoas, 7)`, `closeTo(30.0857, 0.001)`, `'R\$ 30'` | ✅ PASS |
| AC2 — renderizado no compacto | rodapé lê os dois | `montar_compacto_test.dart:169-170` — `expect(find.text('R\$ 211'), findsOneWidget)`, `expect(find.text('≈ R\$ 30 / cabeça'), findsOneWidget)` | ✅ PASS |
| AC2 — renderizado no expandido | card-herói lê os dois | `montar_expandido_test.dart:313` — `expect(find.text(r'R$ 211'), findsOneWidget)`; `rail_do_custo_test.dart:125,142` — `expect(find.text(r'R$ 211'), findsOneWidget)` e `expect(porCabeca, r'R$ 30')` | ✅ PASS |
| AC3 — rótulo "/ cabeça", divisor = **pessoas** (criança inclusive), nunca "por adulto" | `porCabeca` ≠ `porAdulto` | `rodape_do_custo_test.dart:135-146` — `expect(reais(porCabeca), isNot(reais(porAdulto)))` **e** `expect(find.textContaining(reais(porAdulto)), findsNothing)`; `:179` — `expect(find.textContaining('adulto'), findsNothing)` | ✅ PASS |
| AC3 — a criança de fato entra no divisor | tirá-la muda o número | `rodape_do_custo_test.dart:168-172` — com 3H+3M (sem criança) `expect(find.text('≈ R\$ 30 / cabeça'), findsNothing)` | ✅ PASS |
| AC4 — todo dinheiro vem de `MoneyFormatter` (RN-13: inteiro, sem centavos) | `210,60 → R$ 211`, sem vírgula | `rodape_do_custo_test.dart:119-121` — `closeTo(210.60, 0.001)` + `expect(find.textContaining(','), findsNothing)`; `formula_nao_vaza_test.dart:404` — `expect(MoneyFormatter.reais(total), isNot(r'R$ 210'))` | ✅ PASS |
| AC5 — duração 2h/6h/Dia reflete o fator de RN-02 | `f = max(0.5, h/4)` → 0.5 / 1.0 / 1.5 / 2.5 | `montar_bloc_test.dart:294,301,305,309` — `expect(await fatorCom(2), 0.5)`, `(4) → 1.0`, `(6) → 1.5`, `(10) → 2.5` | ✅ PASS |
| AC5 — "Dia" exibe "Dia todo", não "10 horas" | rótulo de `rotuloDeDuracao(10)` | `rail_do_custo_test.dart:159-160` — `expect(label, contains(rotuloDeDuracao(10)))` + `expect(label, isNot(contains('10 horas')))` | ✅ PASS |
| AC6 — varredura: zero aritmética e zero formatação própria em `lib/features/montar/**` | 5 regras de §13, arquivo nomeado | `formula_nao_vaza_test.dart:208` — `expect(violacoesEm(Directory('lib/features/montar')), isEmpty)`; `:216` — a varredura não roda vazia (`arquivosDartEm(...).length > 10`); `:312-325` — a mensagem nomeia arquivo **e** regra | ⚠️ **PASS com furo — regra 1 não pega `R\$`; ver GAP-1** |

### P1-3 — Montar no web (MONT-09..MONT-13)

| Critério | Valor que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — "A CONTA DO ROLÊ" à esquerda, "{NOME} · {DATA}" à direita | posição relativa + template | `montar_expandido_test.dart:139-144` — `expect(_esquerdaDe(titulo), lessThan(_esquerdaDe(identidade)))`; `montar_textos_test.dart:74-79` — `expect(identidadeExpandida(nome:…, data:…), 'CHURRAS DO RAFA 🔥 · SÁB · 18 JUL')` | ⚠️ **PASS com furo — a tela expandida nunca é testada com um nome ≠ default; ver GAP-3** |
| AC2 — rótulos de W-03 ("QUEM CONFIRMOU", "ATÉ QUE HORAS?") no lugar dos de T-03 | os 4 literais, um par por plataforma | `montar_expandido_test.dart:167-170` — `expect(find.text(secaoDePessoasExpandido), findsOneWidget)` **e** `expect(find.text(secaoDePessoasCompacto), findsNothing)` (idem duração); `montar_textos_test.dart:48-57` — os 4 literais | ✅ PASS |
| AC2 — mesmas 3 seções de chips (W-R1) | 11 chips, mesmo `FormularioDeMontagem` | `montar_expandido_test.dart:176-181` — `expect(find.byType(FormularioDeMontagem), findsOneWidget)` + `findsNWidgets(11)`; `formulario_de_montagem_test.dart:116` — o **mesmo** widget com dois conjuntos de rótulos | ✅ PASS |
| AC3 — rail sticky: card-herói escuro, label "SAI POR · {N} PESSOAS · {duração}", valor, "dividido dá R$ {x} por cabeça", lista viva, CTA — **nesta ordem** | ordem + literais | `rail_do_custo_test.dart:75-82` — `expect(ordem, orderedEquals(...))` sobre `[BoraHeroCard, ListaViva, BoraPrimaryButton, BoraSecondaryButton]`; `:106-114` — `expect(_heroi.label, labelDoHeroi(pessoas: 7, duracaoHoras: 4))` com `expect(resultado.contagem.pessoas, 7)`; `:135-141` — `expect(_heroi.sublinha, porCabecaExpandido(porCabeca))` | ✅ PASS |
| AC3 — rail é sticky (não sai do viewport ao rolar) | herói imóvel | `montar_expandido_test.dart:225` — `expect(tester.getTopLeft(find.byType(BoraHeroCard)).dy, heroiAntes)` após `drag` que moveu a seção | ✅ PASS |
| AC4 — lista viva agrupada nas 3 categorias, com subtotal, emoji/nome/qtd/valor | ordem NA GRELHA → NA GELADEIRA → PROS FORTES; subtotal = `totalExato` | `lista_viva_test.dart:84` — `expect(ordem, orderedEquals(...))`; `:132` — `expect(find.text('SUBTOTAL'), findsNWidgets(3))`; `:152-157` — `expect(card.linhas.last.valor, MoneyFormatter.reais(totalExato(itens)))`; `:121-124` — emoji `'🍗'`, sublinha `rotuloDeQuantidade(...)`, valor `reais(item.valor)` | ✅ PASS |
| AC4 — subtotal arredonda a soma exata, não a soma dos arredondados (AD-009) | `10,4 + 10,4 = 20,8 → R$ 21`, nunca `R$ 20` | `lista_viva_test.dart:197-198` — `expect(card.linhas.last.valor, reais(20.8))` + `expect(reais(20.8), isNot(reais(20)))` | ✅ PASS |
| AC4 — **sem** "QUEM LEVA?" e **sem** a dica 💡 (A-02) | ausência | `lista_viva_test.dart:225-227` — `expect(find.textContaining('QUEM LEVA'), findsNothing)`, `find.textContaining('💡') → findsNothing`, `find.byType(BoraDashedNote) → findsNothing` | ✅ PASS |
| AC4 — **sem** essenciais (A-06) | os 4 de RN-10 fora | `lista_viva_test.dart:230` — grupo "os quatro essenciais de RN-10 não aparecem" | ✅ PASS |
| AC5 — card-herói **e** lista viva recalculam na mesma interação | um pump só | `montar_expandido_test.dart:300-307` — após um toque no chip 🍺: `expect(_heroi(tester).valorFormatado, isNot(totalAntes))` **e** `expect(naLista, findsNothing)`; `rail_do_custo_test.dart:91` — `expect(listaViva.resultado, same(resultado))` | ✅ PASS |
| AC6 — lista rola dentro do contêiner; página **nunca** rola horizontalmente (W-R4) | `maxHeight 330`; toda rolagem vertical | `lista_viva_test.dart:325` — grupo "a lista rola dentro do próprio contêiner"; `montar_expandido_test.dart:241-250` — para 1180×800 **e** 900×800, `expect(axisDirectionToAxis(rolagem.axisDirection), Axis.vertical)` em **todos** os `Scrollable` | ✅ PASS |
| AC7 — em expandido o rodapé fixo **não** existe (W-R2) | ausência de `BoraFooterBar` | `montar_expandido_test.dart:203-206` — `expect(find.byType(BoraFooterBar), findsNothing)` + `expect(find.text(fecharLista), findsNothing)` + `expect(find.byType(RailDoCusto), findsOneWidget)` | ✅ PASS |

### P1-4 — Festa sem ninguém (MONT-14)

| Critério | Valor que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — 0 pessoas ⇒ total "R$ 0", por cabeça "R$ 0", lista vazia | zero em ambos | `montar_bloc_test.dart:222-225` — `expect(resultado.itens, isEmpty)`, `totalDosItens == 0`, `porCabeca == 0`; `montar_compacto_test.dart:180-185` — `expect(find.text(MoneyFormatter.reais(0)), findsOneWidget)` e `'≈ R$ 0 / cabeça'` | ✅ PASS |
| AC2 — steppers não descem de 0; o `−` fica inerte | `onDecrementar == null` no piso | `montar_compacto_test.dart:191-194` — `expect(steppers.every((s) => s.onDecrementar == null), isTrue)`; `:203` — tocar o `−` no piso `expect(emitidos.contagem, isEmpty)`; `montar_bloc_test.dart:196-200` — decremento em 0 mantém 0 nos três | ✅ PASS |
| AC3 — 0 pessoas **com chips marcados** ⇒ nenhum item (nenhum `max(1,…)` de RN-04..09) | 7 chips marcados, lista vazia | `montar_bloc_test.dart:221-225` — `expect(itensSelecionados, hasLength(7))` **e** `expect(resultado.itens, isEmpty)` | ✅ PASS |
| AC4 — quando a contagem sobe, a lista volta | não vazia, total > 0 | `montar_bloc_test.dart:233-234` — `expect(resultado.itens, isNotEmpty)`, `greaterThan(0)` | ✅ PASS |

### P1-5 — Começar um rolê novo (MONT-15, MONT-16, MONT-17)

| Critério | Valor que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — `/roles/novo` abre rascunho "CHURRAS NOVO" + próximo sábado | A-04 (default declarado) | `montar_ciclo_de_vida_test.dart:63` — `expect(bloc.state.festa.nome, nomeDefaultDoRole)`; `data_do_role_test.dart:49` — grupo `proximoSabado`; `app_router_montar_test.dart:73` — `expect(find.text(nomeDefaultDoRole), findsOneWidget)` na rota real | ✅ PASS |
| AC2 — nome e data editáveis **na própria tela**, sem navegação | nenhuma rota empilhada | `cabecalho_do_role_test.dart:92-95` — `expect(find.byKey(chaveDoCampoDoNome), findsOneWidget)` **e** `expect(_observador.empilhadas, rotasAntes)` | ✅ PASS |
| AC3 — o nome editado reflete no header mobile | header exibe o valor recebido | `cabecalho_do_role_test.dart:155` (o header não guarda: exibe o que recebe) + `montar_ciclo_de_vida_test.dart:241` — `expect(bloc.state.festa.nome, 'CHURRAS DA VIRADA')`; `montar_page_test.dart:147` — `expect(find.text('CHURRAS DO RAFA'), findsOneWidget)` | ✅ PASS |
| AC3 — …e na linha de título do web | idem no expandido | `montar_textos_test.dart:74` (template) — **nenhum teste renderiza o expandido com nome ≠ default** | ⚠️ **GAP-3** |
| AC4 — a 1ª mudança persiste a festa e a rota passa a `/roles/{festaId}/montar` | `criarFesta` 1×, URL nova | `montar_page_test.dart:352-353` — `expect(palco.festas.criadas, hasLength(1))` + `expect(palco.rotaAtual, Routes.montar(palco.festas.proximoId))`; `montar_ciclo_de_vida_test.dart:82,112` — 1 `criarFesta`, a 2ª mudança **grava** | ✅ PASS |
| AC4 — `replace`, não `push` (o rascunho não fica atrás) | nada empilhado | `montar_page_test.dart:368-373` — `expect(palco.telasEmpilhadas, 1)` + `expect(palco.podeVoltar, isFalse)` | ✅ PASS (garantia, não mecanismo — desvio 8, procede) |
| AC5 — `/roles/{festaId}/montar` carrega a composição salva, não um rascunho | composição = a salva | `montar_ciclo_de_vida_test.dart:149-154` — `expect(state.composicao, _festaSalva().composicao)` **e** `isNot(rascunho().composicao)`; `app_router_montar_test.dart:94-100` — `expect(find.text('CHURRAS DO RAFA'), findsOneWidget)` + `expect(find.text(nomeDefaultDoRole), findsNothing)` | ✅ PASS |
| AC6 — nome apagado por completo volta ao default | "CHURRAS NOVO" | `montar_ciclo_de_vida_test.dart:253-254` — `expect(state.festa.nome, 'CHURRAS NOVO')` e `== nomeDefaultDoRole`; `:263` — só-espaços também | ✅ PASS |

### P2-1 — Sair da tela pelos dois caminhos (MONT-22, MONT-23) · MONT-18..MONT-21

| Critério | Valor que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — "FECHAR LISTA →" ⇒ `/roles/{festaId}/lista` | rota exata | `montar_page_test.dart:201` — `expect(palco.rotaAtual, Routes.lista(_festaExistente))` (**`rotaAtual()`, não widget montado** — AD-014) | ✅ PASS |
| AC2 — "MANDAR NO GRUPO 📲" ⇒ `/roles/{festaId}/whatsapp` | rota exata | `montar_page_test.dart:216` — `expect(palco.rotaAtual, Routes.whatsapp(_festaExistente))` | ✅ PASS |
| AC3 — "SALVAR ROLÊ" persiste **sem navegar** | grava, rota inalterada | `montar_page_test.dart:330-334` — `expect(palco.festas.salvas.map((par) => par.$1), contains(_festaExistente))` **e** `expect(palco.rotaAtual, Routes.montar(_festaExistente))` | ✅ PASS (payload afirmado no valor, não na chamada) |
| AC4 — toast canônico "ROLÊ SALVO ✊", 1 por vez, 2200ms | token de RN-29 | `montar_page_test.dart:288` — `find.text(BoraToastTexts.roleSalvo.toUpperCase())` **comparado com o token** (L-008); `:311,316` — `findsOneWidget` após 2 toques e `findsNothing` após `BoraMotion.toastVida` | ✅ PASS |
| AC5 — o voltar do header volta para a Home… | `/roles` | `montar_page_test.dart:229` — `expect(palco.rotaAtual, Routes.roles)` | ✅ PASS |
| AC5 — …com a composição preservada | composição sobrevive | `app_router_montar_test.dart:172-177` — o chip segue `selecionado: true` após a troca de rota; `montar_ciclo_de_vida_test.dart:196` (MONT-18) — a emissão do repositório com a tela aberta atualiza o estado | ⚠️ **spec-precision gap** — não há round-trip literal montar → Home → montar; a preservação é afirmada no store e na troca de rota, não na volta |
| MONT-18 / A-12 — a composição é salva a cada mudança | `salvarFesta` com o valor novo | `montar_ciclo_de_vida_test.dart:125-128` — `expect(gravada.composicao.contagem.homens, 1)` **e** `mulheres, 1` (valor, não "a chamada ocorreu") | ✅ PASS |
| MONT-19 — falha ao salvar não perde estado nem trava; vai ao `AppLogger` | estado intacto, log emitido | `montar_persistencia_test.dart:142` — grupo dedicado | ✅ PASS |
| MONT-20 — toque repetido no chip alterna determinístico; toque duplo no CTA navega 1× | volta ao estado inicial; 1 tela | `montar_bloc_test.dart:247-251` — `expect(bloc.state, antes)` após 2 toques; `montar_page_test.dart:260-266` — `findsOneWidget` com `skipOffstage: false` + rota única | ✅ PASS |
| MONT-21 — rajada converge no estado final, sem gravação obsoleta | single-flight + coalescência | `montar_persistencia_test.dart:75` — grupo dedicado | ✅ PASS |

### P2-2 — As preferências realimentam a lista (MONT-24)

| Critério | Valor que a spec define | `file:line` + asserção | Result |
|---|---|---|---|
| AC1 — ≥1 veggie ⇒ "Legumes p/ grelha" em NA GRELHA, sem chip | item presente; chave **fora** dos selecionados | `montar_bloc_test.dart:334-340` — `expect(_itemDe(resultado, ChaveItem.legumesParaGrelha), isNotNull)` **e** `expect(itensSelecionados, isNot(contains(legumesParaGrelha)))`; `secao_da_montagem_test.dart:138` — `expect(secaoDe(legumesParaGrelha), SecaoDaMontagem.naGrelha)`; `lista_viva_test.dart:286` — o kit renderiza em NA GRELHA | ✅ PASS |
| AC2 — "sem porco" tira a suína **mesmo com o chip marcado**, e o chip fica como estava | item ausente; chave **ainda** selecionada | `montar_bloc_test.dart:350-356` — `expect(_itemDe(resultado, suina), isNull)` **e** `expect(itensSelecionados, contains(suina))` | ✅ PASS |
| AC3 — cerveja dimensiona por **quem bebe**, não por `adultos` | 18 latas → 12 com 2 abstêmios | `montar_bloc_test.dart:375-376` — `expect(cervejaCheia.quantidade, 18)`, `expect(cervejaReduzida.quantidade, 12)` | ✅ PASS |
| AC4 — sem pessoas nomeadas, nenhum efeito de RN-21 | suína presente, kit ausente | `montar_bloc_test.dart:385-390` — `expect(pessoas, isEmpty)`, `suina isNotNull`, `legumesParaGrelha isNull` | ⚠️ **PASS com furo — ver GAP-2 (M7 sobreviveu)** |

**Cobertura: 24 de 24 requisitos com evidência ancorada. 0 sem evidência.**
21 ✅ · 3 ⚠️ com ressalva de sensor ou de precisão (MONT-08, MONT-15/AC3-web, MONT-24).

---

## Edge Cases da spec

- [x] Nenhum chip + há pessoas ⇒ lista vazia e "R$ 0" — `lista_viva_test.dart:69` (`categorias.isEmpty → SizedBox.shrink`), `montar_bloc_test.dart:222`
- [x] Só uma carne selecionada recebe **todas** as gramas de RN-03 — coberto em `core/calculo` (spec 02), consumido aqui
- [x] Todas as carnes desmarcadas ⇒ nenhuma linha de carne — `montar_expandido_test.dart:305` (a linha some do `ListaViva` no mesmo pump)
- [x] "Dia" ⇒ "Dia todo", não "10 horas" — `rail_do_custo_test.dart:159-160`
- [x] Viewport cruza 900px preservando a composição (W-R3/W-R1) — `montar_page_test.dart:174-185`: troca `MontarCompacto`→`MontarExpandido` e `expect(heroi.valorFormatado, totalNoCompacto)` + chip segue desmarcado
- [x] Total com centavos exibe o inteiro; arredondamento da soma exata, não das parcelas (AD-009) — `lista_viva_test.dart:197-198`, `rodape_do_custo_test.dart:119-121`
- [x] Stepper mantido pressionado continua 1 em 1 — `card_de_contagem_test.dart:96` (uma emissão por acionamento) + `rodape_do_custo_test.dart:188-191` (um toque, uma emissão)

---
## Sensor de discriminação

**Protocolo**: árvore limpa conferida antes de cada mutação (`git status --porcelain`),
edição → `flutter test <alvo>` → `git checkout -- <arquivo>` imediato → `git status`
conferido de novo. Nenhum commit de código, nenhuma mutação deixada para trás. Árvore
conferida também ao fim: limpa.

**Profundidade**: P0-full (dinheiro + regra de negócio na tela) — **21 mutações**.

| # | Arquivo:linha | Mutação | Alvo | Resultado |
|---|---|---|---|---|
| M1 | `widgets/rodape_do_custo.dart:35` | `reais(resultado.totalDosItens)` → `reais(resultado.porCabeca)` | MONT-05 | ✅ **Morta** — 5 falhas (R$ 211 vira R$ 30) |
| M2 | `widgets/rodape_do_custo.dart:35` | replanta `.floor()` no total (o que o worker alegou) | MONT-08 guard | ✅ **Morta nos dois eixos** — a varredura acusa `…/rodape_do_custo.dart: arredonda ou formata número (.floor()` **e** o comportamental acusa `Expected: 'R$ 211' / Actual: 'R$ 210'` |
| M3 | `widgets/lista_viva.dart:129` | replanta `.round()` **em outro arquivo** | MONT-08 guard | ✅ **Morta** — a varredura nomeia `lista_viva.dart` e a regra |
| M4 | `widgets/lista_viva.dart:129` | `.floorToDouble()` no subtotal | MONT-08 guard | ⚠️ **Guard SOBREVIVEU** / comportamento matou — a lista de proibidos tem `.roundToDouble(` mas **não** `.floorToDouble(`, `.ceilToDouble(`, `.truncateToDouble(` → **GAP-1b** |
| M5 | `widgets/rail_do_custo.dart:39` | acrescenta `static const String cifrao` com o cifrão escapado (a forma como ele de fato se escreve em Dart) | MONT-08 regra 1 | ❌ **SOBREVIVEU** — a varredura inteira segue verde → **GAP-1a** |
| M6 | `widgets/rail_do_custo.dart:78` | `reais(total)` → cifrão escrito à mão + `.toInt()` (infração realista completa) | MONT-08 | ✅ **Morta pelo comportamental** — mas a **varredura de §13 passou**: nem o cifrão escapado, nem `.toInt(`, nem `*`/`/`/`%` estão nas 5 regras |
| M7 | `bloc/montar_bloc.dart:381` | `_composicaoCom`: `pessoas: state.composicao.pessoas` → `pessoas: const []` | MONT-24 (RN-21) | ❌ **SOBREVIVEU** — 300/300 em `test/features/montar` verdes → **GAP-2** |
| M8 | `widgets/montar_expandido.dart:152` | linha de título: `nome: festa.nome` → nome fixo igual ao default | MONT-15 AC3 (web) | ❌ **SOBREVIVEU** — 300/300 verdes → **GAP-3** |
| M9 | `bloc/montar_bloc.dart:227` | `_aoMudarDuracao` deixa de propagar para a `ComposicaoDaFesta` | MONT-07 / RN-02 | ✅ **Morta** — 6 falhas (fator 0,5/1,5 e o espelhamento) |
| M10 | `widgets/card_de_contagem.dart:111` | `valor == piso ? null : …` → sempre habilitado | MONT-14 / UC-03 E1 | ✅ **Morta** — 5 falhas |
| M11 | `widgets/rail_do_custo.dart:75` | herói: `contagem.pessoas` → `contagem.adultos` | MONT-10 | ✅ **Morta** — "SAI POR · 7 PESSOAS" vira 6 |
| M12 | `pages/montar_page.dart:82` | `context.replace` → `context.push` | MONT-17 | ✅ **Morta** — 5 falhas (`telasEmpilhadas`, `canPop`, rota) |
| M13 | `pages/montar_page.dart:82` | `context.replace` → `context.go` | MONT-17 | ⬜ **Mutante equivalente** — 416/416 verdes; nenhum comportamento observável separa os dois nesta config de router. **Confirma o desvio 8**: a garantia (`canPop() == false`) é o nível certo |
| M14 | `widgets/rodape_do_custo.dart:37` | sublinha: `porCabeca` → `porAdulto` (a unificação que o `CLAUDE.md` proíbe) | MONT-06 / RN-14 | ✅ **Morta** — 5 falhas |
| M15 | `bloc/montar_bloc.dart:90` | remove o `nome.isEmpty ? nomeDefaultDoRole : nome` | MONT-15 AC6 | ✅ **Morta** — 2 falhas |
| M16 | `widgets/lista_viva.dart:56` | `secaoDe(chave) == secao` → `!=` | MONT-11 | ✅ **Morta** — 7 falhas |
| M17 | `domain/data_do_role.dart:22` | `DateTime.saturday: 7` → `0` | MONT-15 AC1 / A-04 | ✅ **Morta** — 2 falhas |
| M18 | `bloc/montar_bloc.dart:382` | `_composicaoCom`: `overrides: state.composicao.overrides` → `const {}` | (RN-12, fora do escopo) | ❌ **SOBREVIVEU** — mesma causa-raiz de M7 → **GAP-2** |
| M19 | `widgets/lista_viva.dart:57` | injeta `resultado.essenciais` na lista viva | MONT-11 / A-06 | ⬜ **Mutante equivalente** — `secaoDe` devolve `null` para os essenciais, então eles são excluídos **estruturalmente**, não por filtro que se possa perder. A-06 está protegida por construção |
| M20 | `widgets/card_de_contagem.dart` | `aoAlterar(tipo, 1)` → `aoAlterar(tipo, 2)` | MONT-02 AC4 | ✅ **Morta** — 4 falhas |
| M21 | `widgets/formulario_de_montagem.dart` | acrescenta um `BoraPrimaryButton('CALCULAR')` ao formulário | UC-04 ("nenhum botão calcular") | ⚠️ **Morta por acidente** — 1 única falha, e por *finder ambíguo* (`find.byType(BoraPrimaryButton)` no expandido), não por asserção de ausência. No compacto **nada** acusou → **GAP-4** |

**Resultado**: 21 mutações · **15 mortas** · **4 sobreviventes** (M5, M7, M8, M18) ·
**2 mutantes equivalentes** (M13, M19) · 1 morta só por acidente (M21).

**Árvore após o sensor**: `git status --porcelain` → só `?? .specs/features/montar/validation.md`.
Nenhuma mutação deixada para trás; `flutter test` completo re-rodado depois: **1519 passed**.

---

## Os pontos que o projeto pediu para atacar especificamente

| Pergunta | Resposta verificada |
|---|---|
| **R$ 211 / ≈R$ 30 é alcançado pelos eventos da tela?** | **Sim.** `montar_bloc_test.dart:71-79` monta o estado com **7 `ContagemAlterada` reais** sobre o rascunho de `/roles/novo` (que já traz os 7 itens de RN-30 e 4h); só então afirma `closeTo(210.6)` e `'R$ 211'`. Não é `MontarState` montado à mão. As duas telas afirmam o mesmo número renderizado (`montar_compacto_test.dart:169`, `rail_do_custo_test.dart:125`, `montar_expandido_test.dart:313`) — nesses três o `MontarState` é composto no teste, **mas o `resultado` vem de `CalculadoraDaFesta.calcular(...)` real** sobre `itensPadraoDoRole`/`duracaoDefaultDoRole` de produção. **A asserção morre se o número mudar**: M1 e M14 provaram. |
| **O rodapé mostra o total SEM essenciais? Os dois divisores coexistem?** | **Sim, e ninguém unificou.** `rodape_do_custo.dart:35-38` lê `totalDosItens` + `porCabeca`. `rodape_do_custo_test.dart:135-146` afirma **positivamente que `porCabeca ≠ porAdulto` nesta composição** e que o valor de `porAdulto` **não aparece** na tela; `:179` proíbe a palavra "adulto". M14 (trocar por `porAdulto`) matou com 5 falhas. `lista_viva_test.dart:230` mantém os 4 essenciais de RN-10 fora da lista viva, e M19 mostrou que a exclusão é **estrutural**. |
| **O guard MONT-08 morde de verdade?** | **Parcialmente.** Replantei eu mesmo: `.floor()` em `rodape_do_custo.dart` (M2) e `.round()` em `lista_viva.dart` (M3) — **as duas morreram, e a mensagem nomeia o arquivo infrator e a regra**, exatamente como o worker alegou. **Mas** a regra 1 ("escreve R$ na tela") **não pega a forma real** (M5), e a regra 2 tem buraco de família (M4). A infração realista completa (M6) **passou pela varredura inteira** e só morreu no teste comportamental. O guard morde onde foi testado; a lei que ele escreve é mais larga do que o sensor que a policia. |
| **RN-02 e RN-21 chegam à tela?** | **Sim.** RN-02: `montar_bloc_test.dart:294-310` fixa 0,5/1,0/1,5/2,5 e M9 matou. RN-21: os três efeitos afirmados com **valor** (`legumesParaGrelha isNotNull`, `suina isNull` com o chip ainda marcado, cerveja `18 → 12`). **Mas** M7 mostra que o caminho `pessoas` some no primeiro toque na tela sem nenhum teste acusar. |
| **RN-13 em toda superfície?** | **Sim.** Rodapé (`rodape_do_custo_test.dart:119-121`, sem vírgula), card-herói (`rail_do_custo_test.dart:148-149`), linhas e subtotais da lista (`lista_viva_test.dart:124,152-157`), e o subtotal arredondando a soma exata (AD-009, `:197-198`). |
| **A fronteira: `core/calculo` puro, bloc é o único ponto de cálculo?** | **Sim.** `montar_bloc_test.dart:396-406` — a fonte do bloc sem comentários tem **exatamente 1** ocorrência de `CalculadoraDaFesta.calcular(`. `formula_nao_vaza_test.dart:208` — nenhum arquivo de `lib/features/montar/**` viola as 5 regras. `secao_da_montagem_test.dart:180` — `montar/domain` é Dart puro. `lib/core/calculo/**` intacto no diff, salvo a adição legítima de `formatacao/rotulo_de_quantidade.dart` (a conta que faltava **nasceu lá**, como a spec manda). |
| **Rota afirmada por `rotaAtual()` (AD-014)?** | **Sim.** `montar_page_test.dart:201,216,229,239,266,345,353,384` e `app_router_montar_test.dart:71,93,111,124,132,145,171,243` usam `router.routerDelegate.currentConfiguration.uri`. `app_router_montar_test.dart:103-116` torna a razão explícita: as duas rotas montam a **mesma** `MontarPage`, então a chave não discrimina e a URL sim. |
| **Copy literal e toast pelo token de RN-29 (L-008)?** | **Sim.** `montar_textos_test.dart:12-79` afirma os literais **escritos no teste** (não contra as próprias constantes), e `montar_page_test.dart:288` compara o toast com `BoraToastTexts.roleSalvo`, não com uma string redigitada. |
| **W-R1: as duas plataformas compartilham `FormularioDeMontagem` de verdade?** | **Sim, estruturalmente.** `montar_compacto.dart:102` e `montar_expandido.dart` montam o **mesmo** widget, variando só `rotuloDePessoas`/`rotuloDaDuracao`. `formulario_de_montagem_test.dart:116` roda o mesmo widget com os dois conjuntos de rótulos; `montar_expandido_test.dart:176-181` afirma `findsOneWidget` de `FormularioDeMontagem` e os 11 chips. `montar_page_test.dart:174-185` prova que a composição atravessa a fronteira de 900px inteira. Não há cópia. |

---

## Desvios declarados pelos workers — auditoria

| # | Alegação | Veredito |
|---|---|---|
| 1 | `ResumoDeFesta.composicao` é getter sobre campo privado nulo porque default de parâmetro precisa ser `const` e `ContagemDePessoas` não é | ✅ **Procede.** `contagem_de_pessoas.dart:16-24` — construtor **não-`const`** que valida (`_recusaNegativo`). O campo default exigiria `const`; manter `const ResumoDeFesta(...)` era o que preservava a suíte da spec 04 sem editar uma linha. Documentado como `SPEC_DEVIATION` no próprio arquivo, e `==`/`hashCode` usam o **default resolvido** |
| 2 | Primeira supressão de lint do projeto (`prefer_initializing_formals`) | ✅ **Procede e é a única.** `grep -rn "// ignore:" lib/` devolve exatamente 1 ocorrência. É por impossibilidade sintática (parâmetro nomeado não pode começar com `_`), não por conveniência |
| 3 | Rascunho entra por `inicial:` em vez de o bloc chamar `DateTime.now()` | ✅ **Procede e é a decisão certa.** `montar_bloc.dart:28-37`; sem isso a data default só seria afirmável no sábado. O relógio fica na borda, como em `data_do_role.dart` |
| 4 | `MontarState.salvamentos` é contador, não bool | ✅ **Procede.** `montar_page.dart:89` — `atual.salvamentos > anterior.salvamentos`. Com bool, dois "SALVAR ROLÊ" seguidos não disparariam o segundo toast; `montar_page_test.dart:306-311` exercita exatamente esse caso |
| 5 | T16: "confirmar" virou "sair do campo" porque `BoraTextField` não expõe submissão | ✅ **Procede.** `lib/core/design_system/components/bora_text_field.dart:21-46` expõe só `controller`, `placeholder`, `focusNode`, `obscureText` — sem `onSubmitted`/`onEditingComplete`. E `design_system/**` está do lado proibido da fronteira desta spec. **Ressalva de precisão**: a spec diz "acionados"/"editáveis", não "confirmados" — nenhum literal foi desobedecido |
| 6 | A fiação E-4/E-5 entrou no commit da T22, não no da T23 | ✅ **Procede** (`git show --stat 1284022` traz `injector.dart`, `app_router.dart`, `app_de_teste.dart`; `c697ceb` é **só teste**). ⚠️ **Ressalva de processo**: T23 virou um commit sem código de produção — a atomicidade por task ficou borrada, embora nenhum teste tenha sido enfraquecido para isso |
| 7 | 4 testes pré-existentes alterados: `PlaceholderPage.keyFor('montar')` → `MontarPage.pageKey` | ✅ **Procede, sem enfraquecimento.** Auditei o diff dos 4: só a chave muda. `findsOneWidget`, `findsNothing`, `skipOffstage: false` e todos os `reason` seguem idênticos; `app_router_shell_test.dart` troca o ternário por um `switch` exaustivo que **acrescenta** um caso em vez de afrouxar |
| 8 | "`replace`, não `go`" não é observável em go_router 17.5; o teste afirma `canPop() == false` | ✅ **Procede — verificado por mutação.** M13 (`replace` → `go`) deixou 416/416 verdes: **mutante equivalente**. M12 (`replace` → `push`) matou com 5 falhas. A garantia é o nível certo de asserção |
| 9 | O guard de §13 tira comentários antes de varrer | ✅ **Procede.** `formula_nao_vaza_test.dart:106-108` (`semComentarios`) e `:25-97` (`codigoDe`), com o caso de controle em `:342-353` provando que um comentário citando o aceite e uma fórmula **não** é acusado. Legítimo — prosa não escreve nada em tela |
| 10 | `MontarExpandido` não edita nome/data, só reflete | ✅ **Procede** — e é conforme: P1-5 AC2 fala em editar "no header", que é T-03; W-03 só desenha a linha de título. ⚠️ Mas o "reflete" **não é discriminado por teste** — ver GAP-3 |
| 11 | UC-04 tem gap declarado: não há asserção de *ausência* de botão "calcular" | ✅ **Procede, e é gap real** — porém **baixo**. M21 mostrou que um `BoraPrimaryButton('CALCULAR')` plantado no formulário é pego por **um** teste, e por acidente (finder ambíguo no expandido); no compacto nada acusa. Ver GAP-4 |

---

## Code Quality

| Princípio | Status |
|---|---|
| Código mínimo, sem feature além do pedido | ✅ — "QUEM LEVA?", dica 💡, overrides e essenciais ficaram fora, como A-02/A-05/A-06 mandam |
| Sem abstração para uso único | ✅ |
| Fronteira de arquivos da spec respeitada | ✅ — `lib/core/calculo/**` só ganhou `formatacao/rotulo_de_quantidade.dart` (a conta que faltava **nasce lá**, como a spec exige); `design_system/**` e `app.dart` intactos; `core/routing/app_router.dart` e `core/di/injector.dart` tocados só para registrar os próprios (E-4/E-5) |
| Segue os padrões do projeto | ✅ — domínio em PT-BR, infra em inglês; bloc não navega (AD-020); `montar_textos.dart` no molde de `home_textos.dart` |
| Spec-anchored: o valor afirmado é o que a spec define | ✅ — 21 de 24 sem ressalva |
| Todo teste mapeia a um AC/edge case/Done-when | ✅ — os 24 IDs `MONT-xx` aparecem nos nomes dos grupos |
| Diretriz documentada seguida | ✅ — `CLAUDE.md` (RN-13, RN-14, os dois divisores, copy literal), lições L-002 e L-008 aplicadas explicitamente |
| Testes não espelham a implementação | ⚠️ — 3 guards de varredura (`formula_nao_vaza`, o de `rail_do_custo_test.dart:241`, o de `montar_textos_test`) afirmam **forma de código**, não comportamento. É deliberado e a spec pede (AC6), mas é onde os furos apareceram |

---

## Gaps ranqueados

### GAP-1 (**Alta**) — o guard de MONT-08 não pega a forma real da infração

**AC**: P1-2 AC6 · **Evidência**: M5 (sobreviveu), M4 (guard sobreviveu), M6 (varredura passou)
**Arquivo**: `test/features/montar/architecture/formula_nao_vaza_test.dart:140-156`

Dois furos, mesma classe (lista de proibidos incompleta):

- **1a — a regra 1 é praticamente inerte.** `_escreveDinheiro` procura a sequência
  literal do cifrão. Em Dart, `$` seguido de espaço **não compila** dentro de string
  comum: a única forma de escrever o cifrão é escapando-o (na fonte ficam três
  caracteres: `R`, barra invertida, `$`) ou usando raw string. A varredura só pega a
  segunda. Plantei uma constante com o cifrão escapado em `rail_do_custo.dart` e
  **os 15 testes do arquivo passaram**. O mesmo furo está em
  `rodape_do_custo_test.dart:126`.
- **1b — a regra 2 tem família incompleta.** A lista tem `.roundToDouble(` mas não
  `.floorToDouble(`, `.ceilToDouble(`, `.truncateToDouble(`, `.toInt(`,
  `.toStringAsPrecision(`.

Consequência combinada (M6): um widget que escrevesse o cifrão à mão em volta de
`resultado.totalDosItens.toInt()` **passa pelas cinco regras**. Hoje o comportamental
salva; num arquivo novo sem teste de valor, não salvaria.

**Fix task**: (a) em `_escreveDinheiro`, varrer também a forma escapada, sobre
`semComentarios`; (b) completar a família de arredondamento/conversão em `_arredonda`;
(c) acrescentar aos testes de "cada regra pega o caso que devia pegar" um caso com a
**fonte como ela se escreve em Dart**, não com a string já desescapada; (d) mesmo
tratamento em `rodape_do_custo_test.dart:126`.

### GAP-2 (**Média**) — `pessoas` (RN-21) e `overrides` somem no primeiro toque, sem teste acusar

**AC**: P2-2 AC1..AC4 (MONT-24) · **Evidência**: M7 e M18 sobreviveram (300/300 verdes)
**Arquivo**: `lib/features/montar/presentation/bloc/montar_bloc.dart:373-386`

`_composicaoCom` reconstrói a `ComposicaoDaFesta` campo a campo — o próprio comentário
diz que preservar `pessoas` e `overrides` é o que sustenta RN-21 e RN-12. Trocá-los por
`const []` / `const {}` **não quebra nada**: os testes de MONT-24 leem o **estado
inicial** (`blocCom(rascunhoCom(pessoas: …))`) e nunca disparam um evento depois. Ou
seja: hoje o kit veggie, o "sem porco" e a cerveja-por-quem-bebe estão certos na
abertura e **ninguém prova** que sobrevivem ao primeiro toque no stepper — que é
exatamente o que a spec 07 `galera` vai exercitar.

**Fix task**: em `montar_bloc_test.dart`, grupo MONT-24, para cada um dos três efeitos,
disparar um evento (`ContagemAlterada`, `ItemAlternado`, `DuracaoAlterada`) **depois**
de montar com pessoas nomeadas e reafirmar o efeito, mais
`expect(bloc.state.composicao.pessoas, hasLength(n))`.

### GAP-3 (**Média**) — a linha de título do web não discrimina o nome da festa

**AC**: P1-5 AC3 ("o título SHALL refletir a mudança … na linha de título do web")
**Evidência**: M8 sobreviveu · **Arquivo**: `lib/features/montar/presentation/widgets/montar_expandido.dart:150-156`

Trocar `nome: festa.nome` por um literal fixo igual ao default deixa 300/300 verdes:
`montar_expandido_test.dart` só monta com o rascunho default, cujo nome **é** o default.
A metade mobile de AC3 está coberta (`montar_page_test.dart:147` afirma "CHURRAS DO
RAFA" na tela real); a metade web não.

**Fix task**: em `montar_expandido_test.dart`, montar com um `MontarState` cujo
`festa.nome`/`festa.data` **não** sejam os defaults e afirmar
`find.text(identidadeExpandida(nome: 'CHURRAS DO RAFA 🔥', data: 'SÁB · 18 JUL'))`
mais `expect(find.text(nomeDefaultDoRole), findsNothing)`.

### GAP-4 (**Baixa**) — nenhuma asserção de *ausência* do botão "calcular"

**AC**: P1-2 AC1 / Success Criteria ("nenhum botão 'calcular' existe")
**Evidência**: M21 morreu por finder ambíguo, não por asserção; no compacto sobreviveu

**Fix task**: uma linha em `montar_compacto_test.dart` e outra em
`montar_expandido_test.dart`: `expect(find.textContaining(RegExp('CALCULAR', caseSensitive: false)), findsNothing)`.

### GAP-5 (**Informativa**) — spec-precision gaps

Três já marcados `*SPEC_PRECISION_GAP*` no código pelos próprios autores, e nenhum
deles inventa produto:

1. `montar_compacto.dart:42-45` — T-03 diz "header com voltar" sem dar copy; ficou `←`.
2. `montar_textos.dart:94-96` — W-03 escreve "{N} PESSOAS" sem forma singular; o literal
   ficou como a spec o escreve.
3. `montar_bloc.dart:180-183` — nenhuma spec desenha o "salvar" falhando;
   `falhouAoSalvar` existe no estado e nada é desenhado com ele no M1.

Mais dois de cobertura: P2-1 AC5 ("voltar … com a composição preservada") é afirmado
pelo store e pela troca de rota, **não** por um round-trip montar → Home → montar; e o
rótulo "SALVAR ROLÊ" é default declarado (A-14), não literal de spec.

### Observação fora do escopo de `montar` — teste pré-existente instável

`test/architecture/calculo_isolation_test.dart:61` falhou **uma vez** durante o sensor
(numa rodada de suíte completa) e deixou `lib/core/calculo/infrator_de_teste.dart` para
trás na árvore de trabalho. As rodadas seguintes ficaram verdes (1519/1519). O teste
escreve um arquivo real dentro de `lib/` enquanto a suíte roda em paralelo — é frágil por
construção. **Não está no diff de `montar`** (vem da spec `fundacao`); registrado aqui só
para não se perder. O arquivo foi removido; árvore limpa.

---

## Requirement Traceability Update

| ID | Status anterior | Novo status |
|---|---|---|
| MONT-01, MONT-02, MONT-03 | Mapeado | ✅ Verified |
| MONT-04 | Mapeado | ✅ Verified (ressalva menor: GAP-4) |
| MONT-05, MONT-06, MONT-07 | Mapeado | ✅ Verified |
| MONT-08 | Mapeado | ⚠️ Verified com ressalva — **GAP-1** |
| MONT-09..MONT-14 | Mapeado | ✅ Verified |
| MONT-15 | Mapeado | ⚠️ Verified com ressalva — **GAP-3** (metade web de AC3) |
| MONT-16..MONT-23 | Mapeado | ✅ Verified |
| MONT-24 | Mapeado | ⚠️ Verified com ressalva — **GAP-2** |

---

## Summary

| Métrica | Valor |
|---|---|
| Veredito | ⚠️ **PASS COM RESSALVAS** |
| Critérios sem evidência | **0** de 24 |
| Requisitos ✅ Verified | 21 de 24 (3 com ressalva de sensor) |
| Mutações executadas | **21** |
| Mortas | **15** |
| Sobreviventes | **4** (M5, M7, M8, M18) |
| Mutantes equivalentes | 2 (M13, M19) |
| Edge cases da spec cobertos | **7 de 7** |
| `flutter analyze` | ✅ `No issues found!` |
| `flutter test` | ✅ **1519 passed, 0 failed, 0 skipped** (baseline 1137 → **+382**) |
| Testes pré-existentes alterados | 4 — auditados, **nenhuma asserção enfraquecida** |
| Desvios declarados | 11 auditados — **11 procedem** (2 com ressalva de processo/cobertura) |
| Árvore ao fim | ✅ limpa |
| Gaps abertos | 5 (1 alta, 2 médias, 1 baixa, 1 informativa) |

**Por que não é PASS limpo**: a spec põe o guard de MONT-08 como a defesa central
("o risco desta tela não é a conta: é a fórmula vazar para o widget") e o declara nos
Success Criteria. O guard **morde** onde os workers o testaram — replantei `.floor()` e
`.round()` e os dois morreram nomeando o arquivo infrator — mas a regra 1 não pega a
forma como o cifrão de fato se escreve em Dart, e a infração realista completa passou
pela varredura inteira. Some-se a isso que a preservação de `pessoas` (RN-21), que a
spec 07 vai exercitar em cheio, sobrevive por acidente e não por teste.

**Nenhum dos gaps é bug de produto.** O código está correto nos quatro casos: são
**sensores com furo**. Fechados GAP-1, GAP-2 e GAP-3, esta spec vira PASS sem ressalva.
