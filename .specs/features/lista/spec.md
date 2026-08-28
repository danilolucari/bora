# Sua lista (lista turbinada) — Specification

**ID prefix:** `LIST` · **Porte:** **Grande** (ver §Porte)
**Design:** `.specs/features/lista/design.md` — **concluído** (2026-08-27)
**Tasks:** `.specs/features/lista/tasks.md` — pendente
**Context:** `.specs/features/lista/context.md`
**Spec-fonte:** T-04 (`04-telas-ux.md`) · W-03 + W-04 linha "Sua lista (turbinada)" + W-R1..W-R5 (`06-telas-web.md`) · UC-04, UC-05, UC-06, UC-14, UC-15, UC-16 (`05-casos-de-uso.md`) · RN-10, RN-11, RN-12, RN-13, RN-14, RN-20, RN-27, RN-29 (`03-regras-de-negocio.md`) · arquivo 01 §5 (abas permanentes) e §6 (modelo conceitual de Item de lista e Pedido)
**Roadmap:** `.specs/ROADMAP.md` — spec 06, marco M1
**Decisões ativas herdadas:** AD-001..AD-028 · **AD-023** (tabela de preços curada em Dart puro — funda esta spec) · **AD-024** (pedido inteiro atrás de porta, adaptador falso — funda esta spec) · **AD-010** (Copos & pratos aparece e não soma) · **AD-008** (entidades em `core/calculo/dominio/`) · **AD-009** (dinheiro arredonda uma vez, na formatação) · **AD-016** (dado de festa em memória atrás de porta) · **AD-018** ("QUEM LEVA?" fora do M1) · **AD-022** (contadores são dado)
**Depende de:** spec 01 `design_system`, spec 02 `calculo`, spec 05 `montar` (a porta `FestaEmEdicaoRepository` em `core/festas/` e o rail do web nascem lá)

## Problem Statement

`/roles/:festaId/lista` é hoje um `PlaceholderPage` — e é o destino default de `/roles/:festaId`, a primeira aba da festa e o lugar para onde "FECHAR LISTA →" manda o anfitrião. A tela Montar respondeu "quanto sai"; esta responde **"o que eu compro, por quanto, e onde"**. É onde a lista deixa de ser um número e vira uma lista de compras: com os essenciais que ninguém lembra (RN-10), com o preço que o mercado realmente cobra e a faixa que a galera achou (RN-11), com a régua para o anfitrião corrigir o que a calculadora chutou (RN-12), com o checklist agrupado por corredor para quem vai empurrar o carrinho (RN-27) e com o pedido em um toque para quem não vai (UC-16).

Dois riscos governam o desenho. O primeiro é o de sempre, e aqui é maior do que na Montar: **a tela mexe em dinheiro em cinco lugares diferentes** — preço de item, override, subtotal por categoria, total com essenciais, subtotal + frete do pedido — e cada um deles é uma chance de a fórmula vazar para o widget. Toda essa aritmética já existe em `core/calculo` (`totalExato`, `estimativaPorAdulto`, `posicaoDoMarcador`, `totalDeMercado`, `comPassoDeQuantidade`, `comPassoDePreco`, `restaurado`, `subtotalDeItens`, `subtotalDoQueFalta`, `totalDoPedido`); **nada nesta spec recalcula nada.**

O segundo é que a spec-fonte guarda **duas moedas para a mesma tela** — o preço-base da calculadora (que produz o R$ 271 / ≈R$ 45 por adulto de RN-10 e RN-14) e a média real de mercado de RN-11 (que produz o R$ 286 / faixa R$ 234–356). Elas não são o mesmo número e nunca serão: o `tabela_de_precos_de_mercado.dart` já registra que a Picanha bovina vale média R$ 65 lá e R$ 54 aqui, e que **isso não é bug**. Esta spec decide, de uma vez, qual das duas é a moeda da festa e qual é leitura de referência — e é a decisão mais consequente que ela toma (A-01, §Divergências D-1).

## Goals

- [ ] `/roles/:festaId/lista` renderiza T-04 nos dois modos em compacto e a linha "Sua lista (turbinada)" de W-04 em expandido, com a copy **literal** das specs 04, 06 e 03.
- [ ] UC-05 fecha na tela: os quatro essenciais de RN-10 aparecem sem ação nenhuma, com o badge `AUTO ∝ <fonte>`, e o rodapé lê **"R$ 271"** e **"≈ R$ 45 por adulto"** no estado padrão de RN-30.
- [ ] UC-14 fecha na tela: cada item coberto por RN-11 mostra "média de N mercados" e a barra de faixa com o marcador exatamente em `(média−mín)/(máx−mín)` — **37,9% na Picanha bovina**, extremos **R$ 54** e **R$ 83**.
- [ ] UC-06 fecha na tela: passos e mínimos de RN-12, ponto vermelho no item editado, total ao vivo, "RESTAURAR" que zera tudo e some — e o override sobrevive à navegação dentro da festa.
- [ ] UC-15 fecha na tela: corredores na ordem de RN-27, check verde, linha a 45% de opacidade, contador "N de M no carrinho" — e o check sobrevive ao alternar PLANEJAR ⇄ COMPRAR.
- [ ] UC-16 fecha na tela: sheet com endereço trocável, os três parceiros literais de RN-27, `subtotal + frete = total`, overlay "PEDIDO A CAMINHO! 🛵" e a despesa entrando no acerto por RN-20 — tudo atrás da porta da **AD-024**.
- [ ] Zero aritmética de domínio e zero formatação de dinheiro em `lib/features/lista/**`, policiado por varredura (mesmo guard de MONT-08).
- [ ] Festa sem ninguém renderiza lista vazia, R$ 0 e CTA inerte, sem copy inventada.

## Out of Scope

Explicitamente excluído. Documentado para impedir alargamento.

| Item | Razão |
|---|---|
| Montar a festa: steppers de pessoas, chips de item, segmented de duração | Spec 05 `montar` (T-03, W-03 · UC-03, UC-04 · RN-01..RN-10). Esta tela **consome** a composição; ela não a edita, exceto pelos overrides de RN-12. |
| O rodapé "SAI POR" com R$ 211 / ≈ R$ 30 **/ cabeça** | Spec 05 `montar` (A-05 de lá). São dois números diferentes, de propósito, e o `CLAUDE.md` proíbe unificá-los — ver A-02. |
| O rail de W-03 (card-herói escuro + lista viva) e o CTA "MANDAR NO GRUPO 📲" | Já entregues pela spec 05, cujo `design.md` está fechado. Esta spec **não toca** `lib/features/montar/**` (A-16). |
| Implementar qualquer RN de cálculo | Spec 02 `calculo`, já entregue e testada. Esta spec **consome**. |
| Pessoas nomeadas, preferências (dieta/bebida), papéis, link de convite | Spec 07 `galera` (T-05 · UC-11, UC-12, UC-13 · RN-21, RN-22, RN-23). A lista **exibe o efeito** de RN-21; ela não o produz. |
| O seletor "QUEM LEVA?" e a atribuição de item a pessoa | **AD-018**: fora do M1. Depende da lista de confirmados, que nasce na spec 07, e W-03 já pede que ele vire popover/sheet. `ItemDeLista.quemLeva` fica no domínio, sem UI que o escreva. |
| Tela de custos, despesas, cota, saldos, quem-paga-quem, quitação, cobrança | Spec 10 `custos` (T-09 · UC-19..UC-23 · RN-14..RN-19). Esta spec **produz** uma `Despesa` (LIST-27) e para por aí. |
| Criar despesa à mão | **AD-027**: no MVP despesa não se cria à mão. O pedido é uma das três fontes legítimas. |
| Mensagem de convite, grupo e enquetes do WhatsApp | Spec 08 `convite` (T-06, T-07 · RN-25, RN-26, RN-26b). |
| RSVP, "eu levo" do convidado, link público | Spec 09 `convidado` (T-08 · UC-08, UC-09, UC-10 · RN-24). |
| Chamada real a iFood, Rappi ou Zé; rastreio de pedido; cancelamento | **AD-024**: o adaptador do MVP é falso. Nenhum dos três expõe API pública de pedido, e nenhuma tela da spec-fonte desenha rastreio ou cancelamento. |
| Geolocalização, consulta de preço ao vivo, escolha de mercado | **AD-023**: a tabela de RN-11 é fixture curada. "perto de você" é copy. |
| Firestore, models, serialização | **AD-016**: em memória atrás de porta no M1. |
| Componente novo em `core/design_system/` | Fronteira fechada. O checkbox 26×26 de T-04 é composto **dentro da feature** com os tokens do arquivo 02 (A-13). |

---

## Fronteira de arquivos

| Pode tocar | Não pode tocar |
|---|---|
| `lib/features/lista/**` | `lib/core/design_system/**` |
| `lib/core/routing/app_router.dart` — **só** o `builder` de `/roles/:festaId/lista` (precedente **E-4** da spec 05) e o revestimento do `FestaTabsShell` (LIST-35) | `lib/features/{entrar,home,montar,galera,convite,convidado,custos}/**` |
| `lib/core/di/injector.dart` — **só** registro dos próprios | `lib/core/festas/**` — a porta de `montar` é consumida **como está** (A-15) |
| `test/features/lista/**` | `lib/core/calculo/**` — camada fechada; conta que faltar **nasce lá**, como desvio registrado, nunca aqui |
| | `.specs/{STATE,ROADMAP,LESSONS}.md`, `.specs/lessons.json` |
| | qualquer teste existente — a baseline de 1137 testes não pode ser enfraquecida nem apagada |

**Duas emendas são previsíveis e o Design vai declará-las**, no molde das E-1..E-5 da spec 05 — nenhuma é licença para reescrever a camada:

- **E-a · corredor de todo item.** `Corredor` só existe hoje como atributo de `PrecoDeMercado`, e o próprio `corredor.dart` declara que o corredor dos itens que RN-11 não cobre "é decisão de `lista`". Atribuí-lo é **dado de catálogo**, irmão de `nome`/`emoji`/`unidade`, e por isso nasce em `core/calculo/dominio/` — nunca duplicado na feature, que criaria segunda fonte. A **ordem** dos cinco corredores (RN-27) é da feature. Precedente direto: `rotulo_de_quantidade.dart` (§7.2 do `design.md` de `montar`).
- **E-b · onde mora o conjunto "no carrinho".** `ItemDeLista.noCarrinho` existe, mas o item é **recalculado a cada mudança** — guardar o check só nele o perderia no primeiro toque de stepper. O conjunto de marcados é estado da festa e tem de viajar junto da composição, atrás da mesma porta. Qual das duas entidades o recebe (`ComposicaoDaFesta` ou `FestaEmEdicao`) é decisão do Design; as duas ficam fora de `lib/features/lista/**`.

---

## Assumptions & Open Questions

O ROADMAP marcou Discuss para esta spec, e as **duas zonas cinzentas do usuário já foram decididas** — G2 virou **AD-023** e G3 virou **AD-024**, ambas em 2026-08-27. As ambiguidades abaixo são as que sobraram, e nenhuma foi levada ao usuário: cada uma está resolvida aqui com default escolhido e racional. As mesmas entradas estão em `context.md` §"Declined / Undiscussed Gray Areas".

| # | Ambiguidade | Default escolhido | Racional | Confirmado? |
|---|---|---|---|---|
| A-01 | **As duas moedas.** O preço-base da calculadora produz R$ 271; a média de RN-11 produz R$ 286. T-04 rotula o valor da linha como "MÉDIA" e o arquivo 01 §6 modela "preço (média + override)"; RN-10, RN-14 e UC-04 exigem R$ 271 / ≈R$ 45 **por adulto** | **A moeda da festa é a da calculadora.** O valor de cada linha é `ItemDeLista.valor` (preço-base de RN-03..RN-10, coberto pelo override de RN-12); é ele que soma o total, divide o "por adulto", vira subtotal do pedido e vira `Despesa` no racha. **A tabela de RN-11 é leitura de mercado**, exibida ao lado — sub "média de N mercados", barra de faixa e marcador — e **nunca** substitui o preço | É a única leitura em que as linhas somam o rodapé, o rodapé divide o "por adulto" e os três literais de maior peso do projeto (R$ 271, ≈R$ 45, criança fora do racha) continuam verdadeiros **na tela**. O `CLAUDE.md` põe R$ 271/≈R$ 45 entre as "restrições que quebram o produto", e `ResultadoDoCalculo.porAdulto` já se documenta como "o 'por adulto' **da tela Lista**". A leitura oposta (média como preço) sobrevive intacta como alternativa: é trocar uma regra de origem de preço. **Divergência declarada** — ver D-1 | n |
| A-02 | UC-04 manda a Lista dizer "por adulto", mas T-04 não desenha essa linha em rodapé nenhum | O rodapé mostra a linha **"≈ R$ {x} por adulto"** logo abaixo do total, **nos dois modos** | UC-04 está na matriz do arquivo 05 como caso de uso de T-04, e o aceite dele é exatamente o rótulo e o divisor. A spec 05 já declarou (A-05 de lá) que este número é "da tela Lista". Sem a linha, o aceite de UC-04 seria impossível na tela que ele descreve | n |
| A-03 | Origem do **"faixa real: de R$ X a R$ Y"** — soma dos mín/máx, ou a faixa da tabela? | **Soma sobre os itens da lista**: item coberto por RN-11 contribui com `(mínimo, máximo)` da tabela; item não coberto contribui com o próprio `valor` nas duas pontas. `Copos & pratos` fica fora das duas, como fica do total (AD-010) | É a regra que reproduz a própria tabela: aplicada às oito linhas de RN-11 ela devolve **R$ 234 – R$ 356**, o literal da regra, e `totalDeMercado` já a implementa. Inventar faixa para item sem linha na tabela seria fabricar dado; usar a faixa da tabela inteira mentiria sobre uma lista que não é a tabela | n |
| A-04 | **Override × média.** O preço editado manda sobre a leitura de mercado? | **Sim, sempre e nos dois modos.** O valor da linha, o total, o subtotal do pedido e a despesa usam `ItemDeLista.valor`, que já resolve `precoOverride ?? precoBase`. A barra de faixa **continua** sendo a leitura da tabela e **não** se move com o override | Consequência direta de A-01 e do que `overrides.dart` já faz: o ajuste "cobre o valor automático sem apagá-lo". A faixa é dado do mercado, não do usuário — movê-la faria a referência se ajustar ao palpite e deixar de referenciar coisa alguma. Precedente de forma: A-06 da spec `galera` |  n |
| A-05 | **Persistência dos overrides.** UC-06 exige que sobrevivam "à navegação dentro da festa" | Overrides moram em `ComposicaoDaFesta.overrides`, gravados na festa a cada passo pela porta `FestaEmEdicaoRepository`. Sobrevivem à troca de modo, à troca de aba, a sair e voltar da tela e ao recálculo. **Não** sobrevivem a fechar o app: a impl do M1 é em memória (**AD-016**) e o dado da festa inteira morre junto | O escopo literal de UC-06 é "dentro da festa", e é isso que a porta entrega. Prometer sobrevivência ao restart exigiria Firestore, que a AD-016 põe no M2 — e a Lista não pode ser a spec que antecipa a camada de dados | n |
| A-06 | **Persistência dos checks.** UC-15 exige que sobrevivam ao alternar PLANEJAR ⇄ COMPRAR | **Mesmo escopo e mesma porta dos overrides** (E-b): estado da festa, reaplicado sobre os itens a cada recálculo. Sobrevive à troca de modo, de aba e de tela; morre com o processo, como tudo no M1 | Um check guardado no widget morre na primeira troca de modo — que é literalmente o aceite de UC-15. E guardá-lo em lugar diferente do override criaria duas fontes para o estado da mesma lista | n |
| A-07 | **"PEDIR O QUE FALTA 🛵" quando não falta nada, e quando falta tudo** | Nada falta (tudo marcado) ⇒ o CTA fica **inerte** e a sheet **não** abre; nenhum toast, nenhuma copy nova. Tudo falta (nada marcado) ⇒ comporta-se como "FAZER PEDIDO 🛒" sobre a lista inteira | `subtotalDoQueFalta` já devolve 0 com tudo marcado, e confirmar um pedido de R$ 0 criaria despesa vazia no racha. RN-29 não tem toast canônico para o caso, e inventar copy num produto de copy literal é o erro que a spec `galera` já recusou (A-07 de lá) | n |
| A-08 | **Endereço do pedido e o "TROCAR"** | O endereço nasce de `Festa.local` — "Laje do Rafa — Vila Madalena" na fixture RN-30. **"TROCAR" edita o endereço do pedido, não o da festa**: vale para o pedido em curso e some quando a sheet fecha sem confirmar | Nenhuma tela de 04 ou 06 desenha edição do local da festa, e mudar a festa a partir de uma sheet de pedido seria efeito colateral invisível em `home` e `convite`, que exibem o mesmo campo. UC-16 pede só "confere endereço" | n |
| A-09 | **Zé Delivery é "só-bebidas"** (RN-27) e a spec-fonte não diz o que acontece com açougue na lista | O cartão do Zé **sempre aparece**, com o qualificador literal de RN-27, e fica **inerte** (não selecionável) quando o pedido contém qualquer item fora do corredor **BEBIDAS**. Nenhuma copy de erro nova, nenhum filtro silencioso | Esconder o cartão apagaria uma opção que RN-27 declara; deixá-lo selecionável entregaria carne pelo Zé; filtrar a lista sozinho mudaria o subtotal sem o usuário pedir. Inerte com o qualificador visível **é** a explicação, e ela é literal da regra | n |
| A-10 | **"RESTAURAR" tem confirmação?** E some quando não há override? | **Sem confirmação** e **sem toast**: um toque zera todos os overrides. O botão só existe quando há pelo menos um override (`ResultadoDoCalculo.temOverrides`) e desaparece no mesmo frame em que o último é desfeito | T-04 é literal — "botão RESTAURAR no rodapé **quando houver override**" — e UC-06 A1 diz "remove todos os overrides **e o botão some**". Diálogo de confirmação é componente que o arquivo 02 não tem e copy que RN-29 não dá | n |
| A-11 | **Estado vazio da lista** (0 pessoas — exceção E1 de UC-03) | Card de itens **vazio**, sem copy inventada; rodapé lê "R$ 0" e "≈ R$ 0 por adulto"; faixa real não renderiza; CTA de pedido **inerte**; o segmented continua alternando os dois modos, e o modo COMPRAR mostra "0 de 0 no carrinho" | `CalculadoraDaFesta.calcular` já devolve listas vazias e zeros com `pessoas == 0`, antes de qualquer piso `max(1, …)`. Precedente de forma: A-08 da spec `galera` — "sem copy inventada", e o caminho adiante continua visível | n |
| A-12 | **A ordem dos itens no card de PLANEJAR** e o agrupamento em categorias que UC-05 pede | `ordemCanonicaDaLista` de `core/calculo`, com **duas categorias**: os itens escolhidos e, depois, o bloco literal **"ESSENCIAIS · ENTRAM SOZINHOS"** (RN-10). Subtotal por categoria via `totalExato` | RN-10 nomeia a segunda categoria palavra por palavra e a ordem canônica já termina exatamente nela. As três seções do formulário (GRELHA/GELADEIRA/FORTES) são agrupamento de T-03 e ficam com a spec 05 (A-07 de lá); o agrupamento por corredor é do modo COMPRAR | n |
| A-13 | O **checkbox 26×26** de T-04 não existe em `core/design_system` | Composto **dentro da feature**, com os tokens do arquivo 02 (borda 2px `ink`, fundo verde `#0B6B3A`, ✓ branco, `border-radius: 0`) | A fronteira fecha `core/design_system/**`, e o arquivo 02 não lista checkbox entre os ~18 componentes. Compor com token não é criar token | n |
| A-14 | **Parceiro pré-selecionado** na sheet | **iFood Mercado**, o primeiro da ordem de RN-27 | T-04 desenha o estado "selecionado" nos cartões-radio, então algum cartão está selecionado ao abrir. Sem pré-seleção, o resumo teria de exibir um frete que ninguém escolheu — ou "R$ 0", que é mentira testável | n |
| A-15 | **De onde a Lista lê e onde grava** | Consome a porta `FestaEmEdicaoRepository` de `core/festas/` **como está** (`observarFesta` / `salvarFesta`), sem alargá-la; não cria porta de festa própria | A porta nasceu na spec 05 justamente para ter dois consumidores (`home` lê, `montar` escreve) e o escopo dela já declara `lista` entre os herdeiros. Criar uma segunda porta sobre o mesmo store repetiria o erro que a AD-023 de `montar` evitou | n |
| A-16 | **W-04 diz que a lista mora "dentro do rail de W-03"** — o que espremeria o card de T-04, com barras de faixa e steppers duplos, em 370px | **Layout próprio, grid `1fr / 370px`**: o card de itens na coluna principal; o rail sticky com o **segmented no topo** (literal de W-04), o bloco de total, a faixa real, o "por adulto" e o CTA. A sheet vira **modal central** (literal de W-04) | O rail de W-03 já está construído e fechado pela spec 05, e a fronteira proíbe tocá-lo. O grid `1fr / 370px` é o que o próprio W-04 dá para "Custos & acerto", a outra tela de lista longa com total. O que W-04 fixa e é preservado — segmented no rail, modal central — fica literal. **Divergência declarada** — ver D-3 | n |
| A-17 | **As abas permanentes da festa** — o arquivo 01 §5 nomeia "Lista · Galera · WhatsApp · Custos", o `FestaTabsShell` existe cru, e a A-18 de `galera` atribuiu o revestimento a esta spec | Revestimento **em P3**, com os quatro nomes do arquivo 01 §5 e a Lista ativa. **A Lista renderiza e é testável sem ele**: abrir `/roles/:festaId/lista` direto monta a tela | Aceitar a atribuição de `galera` sem prender o valor da tela a ela. Nenhum arquivo de 04 ou 06 desenha a barra, então o visual sai só de tokens do arquivo 02 — o que a torna a peça mais frágil desta spec e a última a entrar | n |
| A-18 | **Título da sheet**, que T-04 chama de "título + ✕" sem dar a copy | **"FAZER PEDIDO"** em caixa alta, igual nos dois modos de entrada | É o nome que a própria T-04 dá à sheet ("Sheet FAZER PEDIDO"). Trocar o título conforme o modo obrigaria a inventar um segundo literal | n |
| A-19 | **Copos & pratos no pedido.** Ele aparece na lista e fica fora do total (AD-010) | Fica **fora do pedido** também: não entra no subtotal nem na faixa real, e não aparece na sheet | Subtotal do pedido que divergisse do total da tela seria a mesma incoerência que a AD-010 resolveu no total. Um item fora do total e dentro do pedido cobraria no acerto (RN-20) um valor que a lista nunca mostrou | n |
| A-20 | **Quem é "quem pediu"** na `Despesa` de RN-20 | O nome do usuário na festa — **"VOCÊ"** na fixture RN-30, onde o Rafa é o "VOCÊ" padrão (arquivo 01 §7). Descrição: **"Pedido no {parceiro}"**; valor: o **total** (subtotal + frete) | `Despesa.quemPagou` é o **nome** da pessoa, não um id (A-24 de `calculo`), e o doc da própria entidade usa "Pedido no Zé" como exemplo de descrição. O frete entra porque quem pediu tirou o frete do bolso | n |
| A-21 | **Confirmar pedido marca os itens como comprados?** | **Não.** Nenhum check muda ao confirmar | UC-16 não diz, e marcar sozinho tornaria "PEDIR O QUE FALTA" permanentemente inerte depois do primeiro pedido (A-07), sem que o usuário tenha tocado em nada | n |
| A-22 | **Orçamento de acento do arquivo 02 §8 — máx. 2 por tela** | **Vermelho** (CTA, segmented ativo, micro-label "MÉDIA", marcador da faixa, ponto de item editado, "TROCAR") e **amarelo** (badge `AUTO ∝`). O **verde `#0B6B3A`** entra só como estado do check no modo COMPRAR, que é significado fixo de §1 ("comprado") | T-04 é literal nos três usos. Estado de controle não é acento de superfície — mesmo raciocínio da A-16 de `galera`, e a leitura estrita de §8 continua contando 3. **Divergência declarada** — ver D-4 | n |
| A-23 | **Toasts desta tela** | **Nenhum.** Nem em RESTAURAR, nem em marcar item, nem em confirmar pedido — a confirmação do pedido é o overlay de tela cheia | RN-29 lista onze textos canônicos e **nenhum** deles é desta tela. Inventar um seria copy nossa num produto de copy literal | n |

**Open questions:** nenhuma — todas resolvidas ou registradas acima. As duas que exigiam o usuário (G2 e G3 do ROADMAP) já voltaram como **AD-023** e **AD-024**.

---

## Varredura de dimensões implícitas (porte Grande — todas resolvidas)

| Dimensão | Cobertura |
|---|---|
| Input validation & bounds | **LIST-11** — os passos e mínimos de RN-12 são a validação inteira: quantidade nunca abaixo de um passo, preço nunca abaixo de R$ 1, e o decremento fica inerte no piso. **Sem entrada de texto livre** exceto o endereço do pedido (LIST-21): campo de uma linha, sem formato a validar, e endereço vazio resolve para o `Festa.local` de origem |
| Failure / partial-failure states | **LIST-32** — falha ao gravar override ou check não perde o estado da tela nem trava a interação; falha da porta de pedido **não** cria despesa, não mostra o overlay e não deixa pedido pela metade |
| Idempotency / retry / duplicate handling | **LIST-33** — "CONFIRMAR PEDIDO →" tocado duas vezes cria **um** pedido e **uma** despesa; marcar/desmarcar o mesmo item alterna deterministicamente; "RESTAURAR" com zero overrides é inalcançável (o botão não existe) |
| Auth boundaries & rate limits | Guarda de sessão herdada de **AD-017**: `/roles/**` sem sessão redireciona. O papel de RN-22 que separa quem edita a lista de quem só a vê nasce na spec 07 `galera` e é aplicado a partir de lá — esta tela não o inventa. **Rate limit: N/A because** o adaptador de pedido do MVP é falso (AD-024) e não há chamada externa a limitar |
| Concurrency / ordering | **LIST-34** — toques rápidos em stepper e em check convergem no estado final correto, sem recálculo obsoleto sobrescrevendo um mais novo; a ordem dos itens é `ordemCanonicaDaLista` e a dos corredores é a de RN-27, ambas estáveis e nunca reordenadas por estado (A-12, LIST-16) |
| Data lifecycle / expiry | **LIST-15** e **LIST-20** — overrides e checks vivem enquanto a festa vive, sem TTL. **Expiração: N/A because** nenhuma spec dá validade a item de lista, e o pedido do MVP não tem ciclo de vida (sem rastreio nem cancelamento, AD-024). Que nada sobreviva ao restart é consequência declarada da AD-016 (A-05) |
| Observability | **LIST-32** — falha de gravação e falha da porta de pedido vão para o `AppLogger` (AD-005) |
| External-dependency failure | **LIST-28 / LIST-32** — a porta de pedido é a **única** dependência externa desta tela, e o contrato de falha nasce agora, com o adaptador falso, para que o adaptador real do futuro não improvise. Firestore só no M2 (AD-016) |
| State-transition integrity | **LIST-14** (RESTAURAR só existe com override e some ao zerar), **LIST-24** (Zé inerte enquanto houver item fora de BEBIDAS), **LIST-25** (CTA inerte quando nada falta) e **LIST-26** (o overlay só existe depois de um pedido confirmado; "VOLTAR À LISTA" o encerra e não o repete) |

---

## User Stories

### P1: A lista da festa, com o que ninguém lembra ⭐ MVP

**User Story**: Como anfitrião, quero abrir a lista fechada e ver tudo o que preciso comprar — inclusive carvão, gelo e sal, que eu ia esquecer — com o total e quanto sai por adulto.

**Why P1**: É UC-05 inteiro e a razão de a tela existir. Sem ela, "FECHAR LISTA →" leva a lugar nenhum e o R$ 271 / ≈R$ 45 da spec-fonte não aparece em tela nenhuma do produto.

**Acceptance Criteria**:

1. WHEN a tela abre em compacto THEN SHALL renderizar o header "SUA LISTA" e, abaixo dele, o segmented com as duas opções literais "🧮 PLANEJAR" e "🛒 COMPRAR", com **PLANEJAR ativo** por default.
2. WHEN o modo PLANEJAR está ativo THEN SHALL exibir a dica tracejada com a copy literal de T-04: "📊 Cada preço é a **média real** de mercados perto de você — a barra mostra o mín/máx que a galera achou."
3. WHEN a lista renderiza THEN SHALL exibir um card único com os itens da lista calculada na ordem de `ordemCanonicaDaLista`, cada linha com emoji, nome e quantidade formatada — **sem** nenhum item que a composição não produza.
4. WHEN a lista renderiza THEN SHALL exibir a categoria literal "ESSENCIAIS · ENTRAM SOZINHOS" contendo **os quatro** itens de RN-10 — 🔥 Carvão, 🧊 Gelo, 🧂 Sal grosso e 🍽️ Copos & pratos — **sem ação nenhuma do usuário**, cada um com a badge amarela "AUTO ∝ {fonte}" nas fontes literais de RN-10: "kg de carne", "volume de bebida gelada", "kg de carne" e "nº de pessoas".
5. WHEN a categoria dos essenciais renderiza THEN "🍽️ Copos & pratos" SHALL aparecer na lista e **não** SHALL somar no total nem no subtotal da categoria (AD-010) — o subtotal dos essenciais lê **"R$ 60"** no estado padrão.
6. WHEN cada categoria renderiza THEN SHALL exibir o **subtotal** da categoria, e o rodapé SHALL exibir o **total geral** (UC-05).
7. WHEN o estado é o padrão de RN-30 (3 homens, 3 mulheres, 1 criança · 4h · bovina + frango + pão de alho + refrigerante + água + cerveja + cachaça) THEN o rodapé de PLANEJAR SHALL exibir o rótulo literal "MÉDIA TOTAL", o valor **"R$ 271"**, a linha **"≈ R$ 45 por adulto"** (A-02) e o CTA "FAZER PEDIDO 🛒".
8. WHEN qualquer valor monetário é exibido THEN SHALL vir de `MoneyFormatter` (RN-13): inteiro, sem centavos, `pt-BR`.
9. WHEN os arquivos de `lib/features/lista/**` são varridos por teste THEN SHALL conter **zero** aritmética de domínio e **zero** formatação de dinheiro própria — só chamadas a `core/calculo`.

**Independent Test**: montar a tela em viewport compacta com a composição padrão de RN-30 e afirmar cada literal, a presença dos quatro essenciais sem interação, o subtotal "R$ 60", e as duas strings "R$ 271" e "≈ R$ 45 por adulto" na árvore renderizada. O AC9 é um guard de varredura, no molde de MONT-08.

---

### P1: O preço médio real, com a faixa que a galera achou ⭐ MVP

**User Story**: Como anfitrião, quero saber quanto cada coisa custa de verdade no mercado, e o quanto o preço varia, para não levar susto no caixa.

**Why P1**: É UC-14 inteiro e o que faz a lista ser "turbinada" em vez de um recibo. É também a razão de a **AD-023** existir.

**Acceptance Criteria**:

1. WHEN um item da lista tem linha correspondente na tabela de RN-11 THEN a linha SHALL exibir o sub "{quantidade} · média de {N} mercados", com o `N` vindo da coluna **Fontes** da própria tabela (AD-023) — "média de 4 mercados" na Picanha bovina, "média de 3 mercados" no Pão de alho, "média de 2 mercados" no Gelo.
2. WHEN um item tem linha em RN-11 THEN SHALL exibir abaixo dela a barra de faixa com os extremos formatados e o marcador na posição `(média−mín)/(máx−mín)`, vinda de `posicaoDoMarcador` — na **Picanha bovina**: extremos **"R$ 54"** e **"R$ 83"**, marcador em **37,9%** da largura.
3. WHEN um item **não** tem linha em RN-11 (frango, água, suco, destilados, sal grosso, copos & pratos) THEN SHALL exibir a quantidade **sem** o texto "média de N mercados" e **sem** barra de faixa — nenhuma faixa é fabricada para item que a tabela não cobre.
4. WHEN o rodapé de PLANEJAR renderiza THEN SHALL exibir a linha literal "faixa real: de R$ {mín} a R$ {máx}", somando `(mínimo, máximo)` da tabela para os itens cobertos e o próprio valor nas duas pontas para os não cobertos (A-03) — no estado padrão de RN-30, **"faixa real: de R$ 245 a R$ 343"** *(números derivados da regra, não literais da spec-fonte)*.
5. WHEN a mesma regra do AC4 é aplicada às **oito linhas** da tabela de RN-11 THEN SHALL devolver média **R$ 286** e faixa **R$ 234 – R$ 356**, os literais da regra.
6. WHEN um item tem override de preço (RN-12) THEN a barra de faixa SHALL continuar exibindo a leitura da tabela, **inalterada** (A-04) — a faixa é dado do mercado, não do usuário.
7. WHEN `máximo == mínimo` numa linha THEN a barra SHALL renderizar sem dividir por zero, com o marcador em 0 — o comportamento que `posicaoDoMarcador` já declara.

**Independent Test**: montar com a composição padrão e afirmar, item a item, o texto "média de N mercados", os dois extremos e a fração passada à barra; afirmar a linha "faixa real: de R$ 245 a R$ 343"; e, em teste separado sobre a fixture, afirmar 286 / 234 / 356 para as oito linhas.

---

### P1: Corrigir o que a calculadora chutou ⭐ MVP

**User Story**: Como anfitrião, quero ajustar a quantidade e o preço de um item quando eu sei melhor que o app, e poder voltar tudo ao automático com um toque.

**Why P1**: É UC-06 inteiro e RN-12 inteiro. É também a única superfície do produto que escreve na composição a partir da Lista.

**Acceptance Criteria**:

1. WHEN um item é tocado THEN a linha SHALL expandir com o caret ▴ e mostrar os dois steppers, "QUANTIDADE" e "PREÇO"; **abrir um item SHALL fechar o anterior** (aceite de UC-06).
2. WHEN o stepper de quantidade é acionado THEN o passo SHALL ser o do catálogo — **0,5 kg** nas carnes, **2 latas** na cerveja e **1** nos demais (RN-12) — e o mínimo SHALL ser **um passo**, com o decremento inerte no piso.
3. WHEN o stepper de preço é acionado THEN o passo SHALL ser **R$ 1** e o mínimo **R$ 1** (RN-12).
4. WHEN um item recebe qualquer ajuste THEN SHALL exibir o **ponto vermelho de 8px** ao lado do nome (RN-12), e SHALL deixar de exibi-lo quando o ajuste é desfeito.
5. WHEN um ajuste é feito THEN o valor da linha, o subtotal da categoria, o total, o "por adulto" e a "faixa real" SHALL recalcular **imediatamente**, sem botão "calcular" (UC-04).
6. WHEN existe pelo menos um override THEN o rodapé SHALL exibir o botão "RESTAURAR"; WHEN não existe nenhum THEN o botão SHALL **não** existir na árvore (A-10).
7. WHEN "RESTAURAR" é acionado THEN **todos** os overrides SHALL ser desfeitos de uma vez, sem diálogo de confirmação e sem toast, os pontos vermelhos SHALL sumir e o botão SHALL desaparecer (UC-06 A1).
8. WHEN o usuário sai da tela e volta, ou troca de modo, ou troca de aba **dentro da festa** THEN os overrides SHALL continuar aplicados (aceite de UC-06 / A-05).

**Independent Test**: expandir um item, afirmar que o anterior fechou; aplicar um passo em cada stepper e afirmar o novo valor, o ponto vermelho e o total recalculado; afirmar que o decremento para no piso; acionar RESTAURAR e afirmar que valor, ponto e botão voltaram ao estado inicial; navegar para outra rota da festa e voltar afirmando o override preservado.

---

### P1: Comprar no mercado, corredor por corredor ⭐ MVP

**User Story**: Como quem foi ao mercado, quero a lista agrupada na ordem em que eu ando pelos corredores e poder ir marcando o que já está no carrinho.

**Why P1**: É UC-15 inteiro, e é a metade da tela que RN-27 nomeia. Sem o modo COMPRAR o segmented do topo tem uma opção que não leva a nada.

**Acceptance Criteria**:

1. WHEN o modo COMPRAR é ativado THEN SHALL exibir a dica com a copy literal de T-04: "✅ Organizado por corredor do mercado — marque o que já tá no carrinho."
2. WHEN o modo COMPRAR renderiza THEN SHALL agrupar os itens por corredor na **ordem fixa de RN-27** — AÇOUGUE → HORTIFRÚTI → PADARIA → BEBIDAS → MERCEARIA — exibindo em cada grupo a contagem "{N} itens"; corredor **sem item SHALL não renderizar**.
3. WHEN um item que a tabela de RN-11 não cobre é agrupado THEN SHALL cair no corredor que a atribuição de catálogo declara (E-a): carnes em **AÇOUGUE**, suco / água / destilados em **BEBIDAS**, sal grosso e copos & pratos em **MERCEARIA**.
4. WHEN uma linha do modo COMPRAR é tocada THEN SHALL alternar o check: marcado exibe o ✓ branco sobre o verde `#0B6B3A` no checkbox 26×26 e a linha inteira SHALL passar a **45% de opacidade**; desmarcado volta ao estado normal.
5. WHEN o rodapé de COMPRAR renderiza THEN SHALL exibir o contador literal "{N} de {M} no carrinho", o total e o CTA "PEDIR O QUE FALTA 🛵".
6. WHEN um item é marcado ou desmarcado THEN o contador SHALL atualizar imediatamente, e o **total SHALL não mudar** — marcar é estado de compra, não de preço.
7. WHEN o usuário alterna PLANEJAR ⇄ COMPRAR, troca de aba ou sai e volta da tela THEN o estado dos checks SHALL ser preservado (aceite de UC-15 / A-06).

**Independent Test**: alternar para COMPRAR e afirmar a dica, a ordem dos cinco corredores, a contagem por grupo e o corredor de cada item; tocar duas linhas e afirmar o contador "2 de M no carrinho", a opacidade e o total inalterado; alternar para PLANEJAR e voltar afirmando os dois checks preservados.

---

### P1: Pedir em um toque ⭐ MVP

**User Story**: Como anfitrião sem tempo de ir ao mercado, quero mandar a lista para um parceiro de entrega, saber quanto sai com frete e que isso já entra no racha da festa.

**Why P1**: É UC-16 inteiro, o critério de M1 no roadmap cita UC-16 explicitamente, e é o que a **AD-024** mandou construir por inteiro.

**Acceptance Criteria**:

1. WHEN "FAZER PEDIDO 🛒" (PLANEJAR) ou "PEDIR O QUE FALTA 🛵" (COMPRAR) é acionado THEN SHALL abrir a sheet com o título "FAZER PEDIDO" (A-18) e o botão ✕.
2. WHEN a sheet abre THEN SHALL exibir a linha 📍 com o endereço da festa — **"Laje do Rafa — Vila Madalena"** na fixture RN-30 — e o "TROCAR" vermelho sublinhado ao lado; WHEN "TROCAR" é acionado e um novo endereço é informado THEN SHALL valer **só para este pedido**, sem alterar a festa (A-08).
3. WHEN a sheet abre THEN SHALL exibir a seção "ENTREGA POR" com os **três** cartões-radio literais de RN-27, nesta ordem: **iFood Mercado** · chega em **40–60 min** · frete **R$ 12**; **Rappi Turbo** · chega em **15–30 min** · frete **R$ 9**; **Zé Delivery** (só bebidas) · chega em **30–45 min** · frete **grátis** — com **iFood Mercado** pré-selecionado (A-14).
4. WHEN um parceiro é selecionado THEN o resumo SHALL exibir Subtotal, Frete e Total, com **Total = Subtotal + Frete** vindo de `totalDoPedido` — no estado padrão de RN-30, com a lista inteira e o iFood: Subtotal **"R$ 271"**, Frete **"R$ 12"**, Total **"R$ 283"**; com o Rappi: Total **"R$ 280"**; e o **Zé SHALL ter frete R$ 0** (aceite de UC-16).
5. WHEN o pedido contém qualquer item fora do corredor BEBIDAS THEN o cartão do Zé Delivery SHALL ficar **inerte** e não SHALL poder ser selecionado (A-09); WHEN o pedido só tem bebidas THEN SHALL ser selecionável normalmente.
6. WHEN a sheet foi aberta pelo modo COMPRAR THEN SHALL levar **apenas os itens não marcados** (UC-16 A2), e o Subtotal SHALL refletir só eles; WHEN **nenhum** item está por marcar THEN o CTA "PEDIR O QUE FALTA 🛵" SHALL ficar inerte e a sheet SHALL **não** abrir (A-07).
7. WHEN ✕ é acionado ou o usuário toca fora da sheet THEN SHALL fechar **sem pedir**, sem criar despesa e sem alterar a lista (UC-16 A1).
8. WHEN "CONFIRMAR PEDIDO →" é acionado THEN SHALL exibir o overlay de tela cheia com 🛵, o título "PEDIDO A CAMINHO!", a linha "Chega em {ETA} na {endereço}.", a linha vermelha "R$ {total} · rachado no acerto da festa" e o CTA "VOLTAR À LISTA".
9. WHEN "VOLTAR À LISTA" é acionado THEN SHALL fechar o overlay e voltar à lista no **mesmo modo** de onde saiu, com checks e overrides intactos.
10. WHEN um pedido é confirmado THEN SHALL nascer uma `Despesa` de quem pediu, com valor igual ao **total (subtotal + frete)** e descrição "Pedido no {parceiro}" (RN-20 / A-20), persistida com a festa para a spec 10 `custos` a ler.
11. WHEN um pedido é confirmado THEN os checks do modo COMPRAR SHALL **não** mudar (A-21).

**Independent Test**: abrir a sheet nos dois modos e afirmar título, endereço, os três cartões com ETA e frete literais, e o resumo somando; selecionar cada parceiro e afirmar os três totais; fechar pelo ✕ e afirmar que nenhuma despesa nasceu; confirmar e afirmar as quatro linhas do overlay e a despesa criada com valor 283.

---

### P2: Toda a tela funciona atrás de uma porta de pedido

**User Story**: Como time, quero que o dia em que houver contrato com um parceiro seja um dia de trocar um adaptador, não de reescrever a tela.

**Why P2**: É a metade estrutural da **AD-024**. Sem ela, o fluxo de P1-5 fica costurado à mão dentro do widget e a troca futura vira reescrita — mas a tela **funciona** sem que a porta seja formalizada, por isso não é P1.

**Acceptance Criteria**:

1. WHEN a feature é montada THEN o envio do pedido SHALL passar por uma **porta abstrata** de pedido, cuja única implementação do MVP é um adaptador falso, sem chamada de rede.
2. WHEN o adaptador falso confirma THEN SHALL devolver o pedido com parceiro, ETA, frete, subtotal e total — os dados que o arquivo 01 §6 modela — e é **ele** que alimenta o overlay, não o widget.
3. WHEN a porta falha THEN SHALL **não** exibir o overlay, **não** criar despesa e **não** deixar pedido pela metade; o estado de erro SHALL ser visível e a falha SHALL ir para o `AppLogger` (AD-005).
4. WHEN a copy da sheet e do overlay é renderizada THEN SHALL ser **literal de T-04**, sem selo de "simulado" e sem qualquer marca de que o pedido não é real — a consequência declarada da AD-024.

**Independent Test**: substituir a porta por um duplo que falha e afirmar ausência de overlay, ausência de despesa e presença do registro de log; afirmar por varredura que nenhum widget da feature monta o pedido por conta própria.

---

### P2: A lista no computador

**User Story**: Como anfitrião no computador, quero a lista larga e o total sempre à vista, sem rodapé fixo e sem rolar de lado.

**Why P2**: W-04 é a adaptação padrão e o critério de M1 cita "W-03 funcional", que a spec 05 já entregou. O valor da tela está nos P1; o web é a segunda plataforma do mesmo estado.

**Acceptance Criteria**:

1. WHEN a tela abre em expandido THEN SHALL renderizar o grid `1fr / 370px` (A-16): o card de itens na coluna principal e o rail à direita.
2. WHEN o rail renderiza THEN SHALL ser **sticky** e conter, nesta ordem: o segmented "🧮 PLANEJAR / 🛒 COMPRAR" **no topo do rail** (literal de W-04), o bloco de total do modo ativo, a "faixa real" (em PLANEJAR) ou o contador do carrinho (em COMPRAR), a linha "≈ R$ {x} por adulto" e o CTA.
3. WHEN a tela está em expandido THEN o rodapé fixo mobile SHALL **não** existir — o CTA mora no rail (W-R2).
4. WHEN o pedido é aberto em expandido THEN SHALL renderizar como **modal central** com o mesmo conteúdo da sheet (W-04), e não como bottom sheet.
5. WHEN o card de itens excede a altura disponível THEN SHALL rolar no documento, e a página SHALL **nunca** rolar horizontalmente (W-R4).
6. WHEN a viewport cruza ~900px com a tela montada THEN SHALL trocar entre rodapé fixo e rail preservando modo ativo, checks, overrides e item expandido (W-R3, W-R1).
7. WHEN a mesma festa é vista nas duas larguras THEN os números SHALL ser os mesmos, vindos do mesmo estado (W-R1).

**Independent Test**: montar em viewport expandida e afirmar a ordem dos blocos do rail, a ausência do rodapé fixo e o modal central; redimensionar através de 900px e afirmar modo, checks e overrides preservados.

---

### P2: Festa sem ninguém

**User Story**: Como anfitrião, quero que a lista não invente compras quando ainda não tem ninguém na festa.

**Why P2**: É a exceção E1 de UC-03 chegando na Lista, e a camada de cálculo já a implementa com guarda dedicada — mas é a tela que decide o que mostrar no lugar.

**Acceptance Criteria**:

1. WHEN a composição tem 0 pessoas THEN o card SHALL renderizar **vazio**, sem item nenhum e **sem copy inventada** (A-11) — nem os essenciais aparecem, porque a guarda de `calcular` vem antes deles.
2. WHEN a composição tem 0 pessoas THEN o rodapé SHALL exibir "R$ 0" e "≈ R$ 0 por adulto", e a linha "faixa real" SHALL **não** renderizar.
3. WHEN a lista está vazia THEN o CTA de pedido SHALL ficar **inerte** e a sheet SHALL não abrir.
4. WHEN a lista está vazia e o modo COMPRAR é ativado THEN SHALL exibir "0 de 0 no carrinho" e nenhum grupo de corredor.
5. WHEN a composição volta a ter pessoas THEN a lista SHALL voltar a ser calculada normalmente, com os essenciais de volta.

**Independent Test**: montar com `ContagemDePessoas()` zerada e afirmar card vazio, "R$ 0", ausência da faixa e CTA inerte nos dois modos; subir a contagem e afirmar que a lista e os essenciais voltaram.

---

### P3: As abas permanentes da festa

**User Story**: Como anfitrião dentro de uma festa, quero trocar entre Lista, Galera, WhatsApp e Custos sem voltar para a Home.

**Why P3**: O arquivo 01 §5 nomeia as quatro abas, o `FestaTabsShell` já existe cru e a A-18 da spec `galera` atribuiu o revestimento aqui — mas nenhum arquivo de 04 ou 06 as desenha, e a Lista é inteiramente utilizável e testável sem elas (A-17).

**Acceptance Criteria**:

1. WHEN qualquer rota sob `/roles/:festaId` que não seja `montar` é aberta THEN SHALL exibir a barra com as quatro abas literais do arquivo 01 §5 — **Lista · Galera · WhatsApp · Custos** — com a aba da rota corrente ativa.
2. WHEN uma aba é acionada THEN SHALL navegar para a rota correspondente **preservando** o estado das outras (é o que o `StatefulShellRoute.indexedStack` já dá).
3. WHEN `/roles/:festaId/lista` é aberta diretamente THEN a tela SHALL renderizar por inteiro, com ou sem a barra revestida (A-17).

---

## Edge Cases

- WHEN um item tem override que o deixa mais caro que o máximo da faixa THEN a barra SHALL continuar mostrando a faixa da tabela e o marcador dentro do trilho (A-04, `posicaoDoMarcador` clampa) — a faixa não persegue o override.
- WHEN a preferência de RN-21 remove a suína ou acrescenta o kit veggie THEN a lista, os corredores, a faixa real e o total SHALL refletir a mudança sem que esta tela recalcule nada (a composição chega pronta de `montar`/`galera`).
- WHEN o kit veggie entra pela RN-21 THEN SHALL cair no corredor **HORTIFRÚTI** e exibir a leitura de mercado de RN-11 ("kit veggie · média de 2 mercados", R$ 22 – R$ 35).
- WHEN um item é marcado no carrinho e depois some da lista (chip desmarcado em `montar`, ou preferência de RN-21) THEN o check SHALL sumir com ele, e o contador SHALL recontar sobre a lista atual — nunca "3 de 2 no carrinho".
- WHEN todos os itens estão marcados THEN o contador SHALL ler "{M} de {M} no carrinho" e o CTA SHALL estar inerte (A-07).
- WHEN a duração é "Dia" THEN as quantidades SHALL refletir o fator 2,5 de RN-02, vindo pronto de `core/calculo`.
- WHEN o total tem centavos na aritmética interna THEN a tela SHALL exibir o inteiro de RN-13 — e o total SHALL ser o arredondamento da soma exata, nunca a soma de parcelas já arredondadas (AD-009).
- WHEN o endereço é trocado e deixado em branco THEN SHALL voltar ao `Festa.local` de origem, nunca ficar vazio (A-08).
- WHEN o app é fechado e reaberto THEN overrides e checks SHALL ter sido perdidos junto com a festa, porque a impl do M1 é em memória (**AD-016** / A-05) — comportamento declarado, não defeito.
- WHEN um item expandido está aberto e a lista recalcula THEN SHALL continuar aberto no mesmo item, sem fechar sozinho.

---

## Requirement Traceability

| ID | História | Origem na spec-fonte | Fase | Status |
|---|---|---|---|---|
| LIST-01 | P1-1 AC1 | T-04 (header + segmented) | Design | Pending |
| LIST-02 | P1-1 AC2 · P1-4 AC1 | T-04 (dicas dos dois modos) | Design | Pending |
| LIST-03 | P1-1 AC3 | T-04 · UC-05 · A-12 | Design | Pending |
| LIST-04 | P1-1 AC4, AC5 | **RN-10 · UC-05 (aceite)** · AD-010 | Design | Pending |
| LIST-05 | P1-1 AC6 | UC-05 | Design | Pending |
| LIST-06 | P1-1 AC7 | **T-04 (rodapé) · RN-10 · RN-14 · UC-04 (aceite)** · A-01, A-02 | Design | Pending |
| LIST-07 | P1-1 AC8, AC9 | RN-13 · `CLAUDE.md` (fórmula não vaza) | Design | Pending |
| LIST-08 | P1-2 AC1, AC2, AC3, AC7 | **RN-11 · UC-14 (aceite)** · AD-023 | Design | Pending |
| LIST-09 | P1-2 AC4, AC5, AC6 | **RN-11 (total R$ 286 · faixa R$ 234–356)** · A-03, A-04 | Design | Pending |
| LIST-10 | P1-3 AC1 | UC-06 (aceite: abrir um fecha o anterior) | Design | Pending |
| LIST-11 | P1-3 AC2, AC3 | **RN-12 (passos e mínimos)** | Design | Pending |
| LIST-12 | P1-3 AC4 | RN-12 (ponto vermelho 8px) | Design | Pending |
| LIST-13 | P1-3 AC5 | UC-04 · UC-06 | Design | Pending |
| LIST-14 | P1-3 AC6, AC7 | RN-12 · UC-06 A1 · A-10 | Design | Pending |
| LIST-15 | P1-3 AC8 | **UC-06 (aceite: sobrevive à navegação)** · A-05 | Design | Pending |
| LIST-16 | P1-4 AC2 | **RN-27 (ordem dos corredores)** · UC-15 | Design | Pending |
| LIST-17 | P1-4 AC3 | RN-27 · E-a (atribuição declarada) | Design | Pending |
| LIST-18 | P1-4 AC4 | T-04 (checkbox 26×26, verde `#0B6B3A`, 45%) · A-13 | Design | Pending |
| LIST-19 | P1-4 AC5, AC6 | T-04 (rodapé COMPRAR) · RN-27 | Design | Pending |
| LIST-20 | P1-4 AC7 | **UC-15 (aceite: check persiste)** · A-06 | Design | Pending |
| LIST-21 | P1-5 AC1, AC2, AC7 | T-04 (sheet) · UC-16 passo 2 e A1 · A-08, A-18 | Design | Pending |
| LIST-22 | P1-5 AC3 | **RN-27 (parceiros, ETA, frete)** · A-14 | Design | Pending |
| LIST-23 | P1-5 AC4 | **UC-16 (aceite: total = subtotal + frete; Zé grátis)** · A-19 | Design | Pending |
| LIST-24 | P1-5 AC5 | RN-27 ("Zé Delivery só-bebidas") · A-09 | Design | Pending |
| LIST-25 | P1-5 AC6 | **UC-16 A2** · A-07 | Design | Pending |
| LIST-26 | P1-5 AC8, AC9 | T-04 (overlay PEDIDO A CAMINHO) | Design | Pending |
| LIST-27 | P1-5 AC10, AC11 | **RN-20** · AD-024 · AD-027 · A-20, A-21 | Design | Pending |
| LIST-28 | P2-1 AC1, AC2, AC4 | **AD-024** (porta + adaptador falso + copy literal) | Design | Pending |
| LIST-29 | P2-2 AC1..AC5 | W-04 ("Sua lista (turbinada)") · W-R2, W-R4 · A-16 | Design | Pending |
| LIST-30 | P2-2 AC6, AC7 | **W-R1, W-R3** | Design | Pending |
| LIST-31 | P2-3 AC1..AC5 | UC-03 E1 (chegando na Lista) · A-11 | Design | Pending |
| LIST-32 | P2-1 AC3 · dimensões: failure, observability, external-dependency | AD-005 · AD-016 | Design | Pending |
| LIST-33 | dimensão: idempotência | UC-16 (um pedido por confirmação) | Design | Pending |
| LIST-34 | dimensão: concurrency / ordering | UC-04 ("latência imperceptível") | Design | Pending |
| LIST-35 | P3-1 AC1..AC3 | **arquivo 01 §5** (abas permanentes) · A-17 · A-18 de `galera` | Design | Pending |

**ID format:** `LIST-[NN]`, sem buraco, de 01 a 35.
**Status values:** Pending → In Design → In Tasks → Implementing → Verified

**Cobertura:** 35 requisitos · 35 rastreados a origem na spec-fonte ou a uma AD ativa · 0 órfãos. O mapa requisito → task sai no `tasks.md`.

**Cobertura dos casos de uso e regras desta spec:**

| Origem | Requisitos |
|---|---|
| UC-04 (lado Lista) | LIST-06, LIST-13, LIST-34 |
| UC-05 | LIST-03, LIST-04, LIST-05, LIST-06 |
| UC-06 | LIST-10, LIST-11, LIST-12, LIST-13, LIST-14, LIST-15 |
| UC-14 | LIST-08, LIST-09 |
| UC-15 | LIST-16, LIST-17, LIST-18, LIST-19, LIST-20 |
| UC-16 | LIST-21, LIST-22, LIST-23, LIST-24, LIST-25, LIST-26, LIST-27, LIST-28, LIST-33 |
| RN-10 | LIST-04, LIST-06 |
| RN-11 | LIST-08, LIST-09 |
| RN-12 | LIST-10, LIST-11, LIST-12, LIST-14 |
| RN-13 | LIST-07 |
| RN-14 | LIST-06 |
| RN-20 | LIST-27 |
| RN-27 | LIST-16, LIST-17, LIST-19, LIST-22, LIST-23, LIST-24, LIST-25 |
| RN-29 | A-23 — **nenhum toast desta tela**; nenhum requisito o inventa |
| T-04 | LIST-01..LIST-27 |
| W-03 / W-04 / W-R1..W-R5 | LIST-29, LIST-30 |
| arquivo 01 §5 | LIST-35 |

---

## Divergências encontradas na spec-fonte

Registradas para que ninguém as "corrija" adiante sem saber que foram vistas.

| # | Divergência | Resolução adotada |
|---|---|---|
| **D-1** | **As duas moedas da mesma tela.** Três fontes apontam para a média de mercado como preço do item — T-04 ("à direita valor + micro-label vermelha 'MÉDIA'"), o total de RN-11 ("R$ 286 · faixa R$ 234–356") e o arquivo 01 §6 ("preço (média + override)"). Três apontam para o preço-base da calculadora — o exemplo de RN-10 ("Com essenciais → R$ 271 · ≈ R$ 45/adulto"), o aceite de UC-04 ("por adulto" na lista) e o `CLAUDE.md`, que põe R$ 271/≈R$ 45 entre as restrições que quebram o produto. Os dois conjuntos **não podem** ser verdadeiros ao mesmo tempo num rodapé só: a diferença no estado padrão é de exatos R$ 15 (Picanha 54→65 e Cerveja 72→76) | **A-01: a moeda é a da calculadora.** O valor da linha é `ItemDeLista.valor`, as linhas somam o rodapé, o rodapé divide o "por adulto", e R$ 271 / ≈ R$ 45 renderizam. A tabela de RN-11 vira **leitura de mercado por item** (sub, faixa, marcador), que é exatamente o que o aceite de UC-14 cobra. O total da tabela (R$ 286 / R$ 234–356) continua **caso de teste literal da camada de cálculo** — `totalDeMercado(tabelaDePrecosDeMercado)`, já verde — e não é número de tela, porque **nenhuma lista que a calculadora produza é igual à tabela**: a 🌭 Linguiça toscana não tem chip em T-03 e a tabela não cobre frango, água, suco, sal, copos nem destilados. A leitura oposta permanece viável: é trocar uma regra de origem de preço, sem tocar em layout |
| **D-2** | **A micro-label "MÉDIA".** T-04 a põe junto do valor à direita, o que sob a A-01 rotularia o preço-base como se fosse a média — e o próprio `tabela_de_precos_de_mercado.dart` registra que o preço-base coincide com o **mín** da faixa na Picanha (54 = 45 × 1,2 kg), não com a média | A micro-label é mantida **literal** e renderiza **apenas** nas linhas que têm leitura de mercado, identificando o bloco de faixa — a média em si é a **posição do marcador**, que é o número que UC-14 cobra. Linha sem cobertura em RN-11 não exibe a micro-label, porque não há média nenhuma para nomear |
| **D-3** | **W-04 diz que a lista turbinada mora "dentro do rail de W-03"**, um rail de 370px que a spec 05 já construiu com card-herói e lista viva — e onde não cabem barra de faixa, steppers duplos e checklist por corredor | **A-16**: layout próprio em grid `1fr / 370px`, o mesmo que W-04 dá a "Custos & acerto". O que W-04 fixa e é preservado literalmente: **segmented no topo do rail** e **sheet vira modal central**. O rail de W-03 permanece intocado, como a fronteira exige |
| **D-4** | **Arquivo 02 §8** limita a **2 acentos por tela**, e T-04 usa vermelho (CTA, "MÉDIA", marcador, ponto de editado, "TROCAR"), amarelo (badge `AUTO ∝`) e verde `#0B6B3A` (check) | **A-22**: vermelho e amarelo são os acentos estruturais; o verde conta como estado de controle com significado fixo de §1 ("comprado"), não como cor de superfície. A leitura estrita de §8 continua violada — declarado, não silenciado. Mesma forma da D-2 da spec `galera` |
| **D-5** | **RN-10 exibe um badge `AUTO ∝ <fonte>` prometendo proporcionalidade, mas não dá fórmula nenhuma** — e as quantidades dos essenciais são fixas (1 saco, 3 sacos, 1 kg, 1 kit) | Já resolvida em `core/calculo` (A-09 de lá): a fonte é **metadado do badge**, e inventar uma escala mudaria o caso literal de R$ 271. LIST-04 renderiza o badge exatamente como a camada o entrega; nenhum requisito desta spec faz o essencial escalar |
| **D-6** | **O overlay de T-04 escreve "Chega em ETA na Laje do Rafa"**, encurtando o local, que em RN-30 e no arquivo 01 §6 é "Laje do Rafa — Vila Madalena" | LIST-26 renderiza o **endereço inteiro**, o mesmo string que a sheet mostrou: não existe regra de encurtamento na spec-fonte, e inventar uma faria a tela dizer um endereço que o usuário não confirmou |
| **D-7** | **`Corredor` não cobre metade do catálogo.** RN-11 declara corredor para 8 itens; a calculadora tem 16, e água, suco, sal grosso, copos & pratos, frango, suína e os três destilados ficam sem | Já antecipada por `corredor.dart` ("é decisão de `lista`"): **E-a** atribui o corredor de todos, como dado de catálogo em `core/calculo/dominio/`, e LIST-17 fixa a atribuição por escrito. A ordem dos corredores é a de RN-27 e mora na feature |

---

## Porte

**Grande**, como o roadmap previa — e o Discuss confirmou, porque as duas zonas cinzentas dele viraram duas ADs que **mandaram construir**, não recortar. O corte estimado é de **~16 tasks**: dois modos com listas estruturalmente diferentes (card com faixa × checklist por corredor), a régua de override com dois steppers e restauração, o fluxo de pedido inteiro (sheet + modal + overlay + despesa) atrás de porta, o layout web, e o guard que impede a fórmula de vazar. **Design e Tasks formais.**

**O que esta spec origina e outras herdam** — é o critério que já subiu `fundacao`, `entrar` e `home` de Médio para Grande:

- **A porta de pedido e o `Pedido` como entidade** (LIST-28). Nasce aqui e é o ponto de troca que a **AD-024** promete; a spec 10 `custos` recebe a `Despesa` que ela produz, e a spec 09 `convidado` herda a mesma forma de "ação que vira despesa" (RN-20).
- **A atribuição de corredor de todo o catálogo** (E-a / LIST-17). Nasce aqui e passa a ser dado de domínio, consumido por qualquer tela que agrupe itens.
- **O conjunto "no carrinho" como estado da festa** (E-b / LIST-20). É a segunda escrita da festa depois da composição, e o formato dela sobrevive à troca para Firestore no M2.
- **A resolução D-1 das duas moedas.** Qualquer tela futura que mostre dinheiro de item — `convidado` ao escolher "eu levo", `custos` ao ratear — herda a resposta de qual preço é o preço.

---

## Success Criteria

- [ ] `flutter analyze` = zero issues · suíte inteira verde, baseline de 1137 testes preservada.
- [ ] **Aceite de UC-05 na tela**: os quatro essenciais de RN-10 presentes sem ação do usuário, com badge `AUTO ∝`, e o rodapé lendo "R$ 271" e "≈ R$ 45 por adulto" no estado padrão.
- [ ] **Aceite de UC-14 na tela**: marcador em `(média−mín)/(máx−mín)` — 37,9% na Picanha bovina, extremos R$ 54 e R$ 83 — e os dados das oito linhas de RN-11 reproduzidos; a regra da faixa aplicada à tabela devolve R$ 286 / R$ 234–356.
- [ ] **Aceite de UC-06 na tela**: passos e mínimos de RN-12, ponto vermelho, total ao vivo, RESTAURAR que zera e some, override sobrevivendo à navegação dentro da festa.
- [ ] **Aceite de UC-15 na tela**: cinco corredores na ordem de RN-27, check verde a 45% de opacidade, contador correto, e o check sobrevivendo ao alternar PLANEJAR ⇄ COMPRAR.
- [ ] **Aceite de UC-16 na tela**: Total = Subtotal + Frete nos três parceiros, Zé com frete grátis, overlay com ETA e "rachado no acerto da festa", e a `Despesa` criada com o total.
- [ ] Guard de varredura verde: nenhuma aritmética de domínio nem formatação de dinheiro em `lib/features/lista/**`.
- [ ] W-04 funcional: grid `1fr / 370px`, rail sticky com segmented no topo, modal central, zero scroll horizontal, sem rodapé fixo.
- [ ] Festa sem ninguém: card vazio, R$ 0, CTA inerte, sem copy inventada.
- [ ] Nenhum toast novo, nenhuma copy fora das specs 03, 04 e 06.
