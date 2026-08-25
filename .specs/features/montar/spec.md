# Montar — A conta do rolê — Specification

**ID prefix:** `MONT` · **Porte:** **Grande** (confirmado)
**Design:** `.specs/features/montar/design.md` (a produzir)
**Tasks:** `.specs/features/montar/tasks.md` (a produzir)
**Context:** `.specs/features/montar/context.md`
**Spec-fonte:** T-03 (`04-telas-ux.md`) · W-03 + W-R1..W-R5 (`06-telas-web.md`) · UC-03, UC-04 (`05-casos-de-uso.md`) · RN-01..RN-10, RN-13, RN-21 — **consumo**, não implementação (`03-regras-de-negocio.md`)
**Roadmap:** `.specs/ROADMAP.md` — spec 05, marco M1
**Decisões ativas herdadas:** AD-001..AD-017 · **AD-008** (entidades em `core/calculo/dominio/`) · **AD-016** (dado em memória no M1)
**Depende de:** spec 01 `design-system`, spec 02 `calculo`, spec 04 `home` (que é quem navega para cá)

## Problem Statement

Esta é a tela que **é o produto**. As duas outras telas do M1 preparam o terreno: `entrar` dá a sessão, `home` dá o caminho. Montar é onde o anfitrião mexe em sete controles e vê o custo do churrasco mudar embaixo do dedo — a promessa "a conta do rolê, resolvida" acontece aqui ou não acontece.

A aritmética já existe e está testada: `core/calculo/` implementa RN-01..RN-21 com os exemplos do arquivo 03 como testes literais, e o próprio barrel declara o contrato — `totalDosItens` é "o **SAI POR** da tela Montar" e `porCabeca` é "a estimativa ≈ R$ X / cabeça da tela Montar". **Nada nesta spec recalcula nada.** O risco desta tela não é a conta: é a fórmula vazar para o widget na primeira vez que alguém quiser um número que a camada ainda não expõe.

O segundo risco é estrutural. W-03 funde Montar e Lista numa tela só no web — "não existe passo Fechar lista" — enquanto no mobile são duas telas em sequência. A mesma feature tem que servir os dois quadros a partir do mesmo estado (W-R1), e a metade "Lista" do rail nasce aqui pela primeira vez.

## Goals

- [ ] T-03 em compacto e W-03 em expandido, com a copy literal das specs 04 e 06 — inclusive as diferenças de rótulo entre plataformas.
- [ ] Qualquer toque em stepper, chip ou duração recalcula o custo **imediatamente**, sem botão "calcular" (UC-04).
- [ ] O aceite de UC-03 bate exatamente **na tela**: com o estado padrão de RN-30, o rodapé lê "R$ 211" e "≈ R$ 30 / cabeça".
- [ ] Toda aritmética vem de `CalculadoraDaFesta.calcular` e toda formatação de `MoneyFormatter` — zero conta em widget, policiado por teste.
- [ ] O rail web sticky mostra o card-herói escuro e a lista viva recalculando junto com o formulário.
- [ ] "🔥 CHURRASCO" cria um rolê de verdade: `/roles/novo` abre com nome e data default, editáveis no header.
- [ ] Festa sem ninguém dá lista vazia e total R$ 0, e os steppers não descem de 0 (UC-03 E1).

## Out of Scope

| Item | Razão |
|---|---|
| Implementar qualquer RN de cálculo | Spec 02 `calculo`, já entregue e testada. Esta spec **consome**. |
| Seletor "QUEM LEVA?" e atribuição de item a pessoa | **Decidido no Discuss**: fora do M1. Depende da lista de confirmados, que nasce na spec 07 `galera`, e W-03 já pede que ele vire popover/sheet — construir o botão que cicla agora seria construir para jogar fora. |
| A dica tracejada "💡 Toque em **QUEM LEVA?**…" | Sem o botão, a dica seria uma instrução falsa. W-03 já prevê que ela "deixa de ser necessária". |
| Modos PLANEJAR / COMPRAR, checklist, corredores, faixa mín–máx, delivery | Spec 06 `lista` (UC-05, UC-14, UC-15, UC-16 · RN-11, RN-12, RN-27). |
| Overrides de quantidade e preço (ponto vermelho, RESTAURAR) | RN-12 / UC-06 → spec 06 `lista`. A camada de cálculo já os aceita; nenhuma UI daqui os produz. |
| Essenciais automáticos na lista visível | RN-10 é exibido em UC-05, na tela Lista. Ver A-05 — mostrá-los aqui contradiria o "SAI POR" de R$ 211. |
| Preferências por pessoa (dieta, bebe) | Spec 07 `galera` (RN-21, lado produtor). Esta tela **consome** o efeito quando há pessoas nomeadas. |
| Pessoas nomeadas: adicionar, editar, remover | Spec 07 `galera`. Aqui só os steppers de extras sem app. |
| Enviar no WhatsApp | Spec 08 `convite`. O CTA do rail navega para o placeholder. |
| Firestore | **AD-016**: em memória no M1. |

---

## Fronteira de arquivos

| Pode tocar | Não pode tocar |
|---|---|
| `lib/features/montar/**` | `lib/core/calculo/**` — camada fechada; conta que faltar **nasce lá**, como desvio registrado, nunca aqui |
| `lib/core/di/injector.dart` — **só** registro dos próprios | `lib/core/design_system/**` · `lib/core/routing/**` · `lib/app.dart` |
| `lib/features/home/domain/**` — **só** se `FestaRepository` precisar de método novo (coordenar com a spec 04) | `lib/features/{entrar,lista,galera,convite,convidado,custos}/**` |
| `test/features/montar/**` | `.specs/{STATE,ROADMAP,LESSONS}.md`, `.specs/lessons.json` · qualquer teste existente |

---

## Assumptions & Open Questions

| # | Assumption / decisão | Default escolhido | Rationale | Confirmado? |
|---|---|---|---|---|
| A-01 | O arquivo 04 põe "PROS FORTES" como **web-only**, mas o exemplo canônico de R$ 211 e a RN-30 incluem cachaça | **"PROS FORTES" nas duas plataformas.** O mobile ganha a quarta seção de chips | Sem ela o mobile não consegue montar o próprio caso de teste: o total fecharia R$ 196, não R$ 211, e o aceite de UC-03 ficaria impossível na tela que ele descreve | **y** (2026-08-25) |
| A-02 | "QUEM LEVA?" no rail (W-03) | **Fora do M1.** O rail entrega card-herói + lista viva, sem atribuição, e sem a dica 💡 | Depende de confirmados (spec 07); e W-03 já declara o botão que cicla como lacuna a substituir. Construí-lo agora seria construir para jogar fora | **y** (2026-08-25) |
| A-03 | UC-03 pressupõe festa criada, e W-03 mostra "CHURRAS DO RAFA · SÁB 18 JUL" — mas nenhuma tela pede nome e data | `/roles/novo` cria um **rascunho** com nome e data default; ambos **editáveis no header** de Montar | Nenhuma tela nova, nenhum componente fora do arquivo 02, e o rolê existe desde o primeiro toque | **y** (2026-08-25) |
| A-04 | Nome e data default do rascunho não existem em spec nenhuma | Nome **"CHURRAS NOVO"**; data: o **próximo sábado** a partir de hoje | Coerente com a voz do produto e com o formato "SÁB · 18 JUL" de T-02. Declarado como default, **não** como literal de spec *(L-002)* | n |
| A-05 | O rodapé "SAI POR" mostra o total **com** ou **sem** essenciais? | **Sem.** `totalDosItens` e `porCabeca`, exatamente como `ResultadoDoCalculo` documenta: "o SAI POR da tela Montar" e "a estimativa ≈ R$ X / cabeça da tela Montar" | É o que faz o aceite de UC-03 dar R$ 211 / ≈R$ 30. O R$ 271 / ≈R$ 45 com essenciais é da tela Lista (UC-05, RN-14) — os dois números coexistem de propósito e o `CLAUDE.md` proíbe unificá-los | n |
| A-06 | Pela mesma razão, a **lista viva** do rail exibe essenciais? | **Não.** Só os itens escolhidos (mais o kit veggie de RN-21, quando houver) | Exibir essenciais faria a soma da lista divergir do card-herói na mesma tela. RN-10 é exibido em UC-05 | n |
| A-07 | W-03 diz "categorias com subtotal" sem nomear as categorias | As **mesmas três seções do formulário**: NA GRELHA, NA GELADEIRA, PROS FORTES — na ordem de `ordemCanonicaDaLista` | O agrupamento por corredor (RN-27: AÇOUGUE → HORTIFRÚTI → …) é da spec 06 `lista` e o próprio `corredor.dart` declara isso. Espelhar o formulário é o que a tela já mostra | n |
| A-08 | O kit veggie de RN-21 ("Legumes p/ grelha") aparece na lista viva sem ter chip | Entra na categoria **NA GRELHA**, sem chip correspondente no formulário | É item de grelha e entra sozinho por RN-21; dar-lhe chip seria criar controle que a spec não desenha | n |
| A-09 | Rótulos que **diferem** entre plataformas: "CONFIRMADOS + EXTRAS SEM APP" (T-03) × "QUEM CONFIRMOU" (W-03); "QUANTO TEMPO DE FESTA?" (T-03) × "ATÉ QUE HORAS?" (W-03) | **Manter os quatro literais**, um par por plataforma | `CLAUDE.md`: a copy das specs é literal, não paráfrase. Unificar seria escolher qual spec desobedecer |  n |
| A-10 | Steppers do mobile são "CONFIRMADOS + EXTRAS SEM APP" e RN-01 diz que pessoas = nomeados + extras | No M1 **não há pessoas nomeadas** (spec 07): os steppers governam a contagem inteira. A `ComposicaoDaFesta` já aceita `pessoas: []` | Sem `galera`, nomeados não existem. O contrato de `calculo` não muda; só a fonte da contagem | n |
| A-11 | Limite superior dos steppers | Sem teto declarado; piso **0** (UC-03 E1). Interface impede descer abaixo de 0 | UC-03 E1 só declara o piso. Inventar teto seria requisito novo | n |
| A-12 | Persistência da composição | Salva no `FestaRepository` (em memória, AD-016) a cada mudança; sobrevive à navegação dentro da festa | W-R1 exige estado único; e sair de Montar e voltar não pode zerar o rolê | n |
| A-13 | Destino de "FECHAR LISTA →" (mobile) e "MANDAR NO GRUPO 📲" (web) | `/roles/{festaId}/lista` (spec 06) e `/roles/{festaId}/whatsapp` (spec 08) — placeholders no M1 | Rotas já existem desde a fundação; navegar para placeholder é honesto e testável | n |
| A-14 | W-03 pede "salvar sem mandar no grupo" no web, sem dar a copy | Ação secundária no rail com a copy **"SALVAR ROLÊ"**, disparando o toast canônico **"ROLÊ SALVO ✊"** (RN-29) | O toast é literal de RN-29 e já existe em `BoraToastTexts.roleSalvo`; só o rótulo do botão é default | n |
| A-15 | Duração "Dia" no segmented | 10 horas (RN-02) e rótulo **"Dia todo"** no card-herói, via `rotuloDeDuracao` de `core/calculo` | RN-02 e RN-13 fixam ambos; o formatador já existe e não se reescreve aqui | n |
| A-16 | Orçamento de acento do arquivo 02 (**máx. 2 por tela**) | **Vermelho** (CTA, segmented ativo, chip selecionado, sombra do card-herói) e **amarelo** (label do card-herói) | São os únicos dois que T-03 e W-03 nomeiam | n |

**Open questions:** nenhuma — tudo resolvido ou registrado acima.

---

## Varredura de dimensões implícitas (porte Grande — todas cobertas)

| Dimensão | Cobertura |
|---|---|
| Input validation & bounds | MONT-14 (steppers não descem de 0 — UC-03 E1) |
| Failure / partial-failure | MONT-19 (falha ao salvar não perde o estado da tela nem trava a interação) |
| Idempotency / retry / duplicate | MONT-20 (toque repetido no mesmo chip alterna determinística; toque duplo no CTA navega uma vez) |
| Auth boundaries & rate limits | Herdado de ENT-15 (AD-017): `/roles/**` sem sessão redireciona. **Rate limit: N/A** |
| Concurrency / ordering | MONT-21 (toques rápidos em sequência convergem no estado final correto — nenhum recálculo obsoleto sobrescreve um mais novo) |
| Data lifecycle / expiry | MONT-18 (a composição sobrevive à navegação dentro da festa). **Expiração: N/A** — rascunho não expira em nenhuma spec |
| Observability | MONT-19 (falha de persistência vai para o `AppLogger`, AD-005) |
| External-dependency failure | Coberto por MONT-19 — em memória no M1, mas o contrato de falha nasce agora para o M2 não improvisar |
| State-transition integrity | MONT-17 (o rascunho de `/roles/novo` vira festa persistida na primeira mudança, e a URL passa a refletir o `festaId`) |

---

## User Stories

### P1: Montar o churras no celular ⭐ MVP

**User Story**: Como anfitrião, quero dizer quem vai, o que vai ter e quanto tempo dura, para o app montar a lista.

**Why P1**: É o fluxo principal de UC-03 e a razão de existir do produto.

**Acceptance Criteria**:
1. WHEN a tela abre em compacto THEN SHALL renderizar, na ordem de T-03: header com voltar e o título "A CONTA DO ROLÊ"; a seção "CONFIRMADOS + EXTRAS SEM APP" com três steppers ("👨 Homens", "👩 Mulheres", "🧒 Crianças"); "NA GRELHA" com os chips 🥩 BOVINA, 🐷 SUÍNA, 🍗 FRANGO; "NA GELADEIRA" com 🧄 PÃO DE ALHO, 🥤 REFRIGERANTE, 🧃 SUCO, 💧 ÁGUA, 🍺 CERVEJA; "PROS FORTES" com 🍸 VODKA, 🍹 CACHAÇA, 🥃 WHISKY (A-01); e "QUANTO TEMPO DE FESTA?" com o segmented 2h / 4h / 6h / Dia.
2. WHEN um chip é tocado THEN SHALL alternar entre selecionado e não selecionado, com o selecionado no acento vermelho.
3. WHEN uma opção do segmented é tocada THEN SHALL virar a ativa, em vermelho, e as demais SHALL sair do estado ativo.
4. WHEN um stepper é incrementado ou decrementado THEN a contagem SHALL mudar de 1 em 1.
5. WHEN a tela está montada THEN o rodapé fixo SHALL exibir o rótulo "SAI POR", o total, a linha "≈ R$ {x} / cabeça" e o CTA "FECHAR LISTA →".

**Independent Test**: montar a tela em viewport compacta e afirmar cada literal, o número de chips por seção e o estado visual de seleção antes/depois do toque.

---

### P1: O custo muda embaixo do dedo ⭐ MVP

**User Story**: Como anfitrião, quero ver o preço mudar a cada toque, para achar o ponto que cabe no meu bolso sem precisar calcular nada.

**Why P1**: É UC-04 inteiro, e o aceite de UC-03 é um número na tela. Sem isso a tela é um formulário, não o produto.

**Acceptance Criteria**:
1. WHEN qualquer stepper, chip ou opção de duração muda THEN o total e o valor por cabeça SHALL ser recalculados **imediatamente**, sem botão "calcular" (UC-04).
2. WHEN o estado é o padrão de RN-30 (3 homens, 3 mulheres, 1 criança · 4h · bovina + frango + pão de alho + refrigerante + água + cerveja + cachaça) THEN o rodapé SHALL exibir **"R$ 211"** e **"≈ R$ 30 / cabeça"** — o aceite literal de UC-03.
3. WHEN o valor por pessoa é exibido nesta tela THEN SHALL usar o rótulo **"/ cabeça"** e o divisor **pessoas** (criança inclusive) — nunca "por adulto" (UC-04, RN-14).
4. WHEN qualquer valor monetário é exibido THEN SHALL vir de `MoneyFormatter` (RN-13): inteiro, sem centavos, `pt-BR`.
5. WHEN a duração muda para 2h, 6h ou "Dia" THEN as quantidades e o total SHALL refletir o fator de RN-02 vindo de `core/calculo`.
6. WHEN os arquivos de `lib/features/montar/**` são varridos por teste THEN SHALL conter **zero** aritmética de domínio e **zero** formatação de dinheiro própria — só chamadas a `core/calculo`.

**Independent Test**: montar com o estado padrão e afirmar as duas strings do AC2 na árvore renderizada; depois alternar um chip e afirmar que o total mudou. O AC6 é um guard de varredura, no molde dos que a spec 01 instalou.

---

### P1: Montar no web, com o custo sempre à vista ⭐ MVP

**User Story**: Como anfitrião no computador, quero o formulário e a lista lado a lado, para ver o que estou comprando enquanto mexo.

**Why P1**: W-03 é critério declarado do M1 no roadmap ("W-03 funcional"), e a fusão Montar+Lista é a diferença estrutural do web.

**Acceptance Criteria**:
1. WHEN a tela abre em expandido THEN SHALL renderizar a linha de título de W-03: "A CONTA DO ROLÊ" à esquerda e "{NOME DA FESTA} · {DATA}" à direita.
2. WHEN a tela abre em expandido THEN a coluna esquerda SHALL usar os rótulos de W-03 — "QUEM CONFIRMOU" e "ATÉ QUE HORAS?" — no lugar dos rótulos mobile (A-09), mantendo as mesmas três seções de chips.
3. WHEN a tela abre em expandido THEN o rail direito SHALL ser sticky e conter, nesta ordem: o card-herói escuro com a label amarela "SAI POR · {N} PESSOAS · {duração}", o valor total, a linha "dividido dá R$ {x} por cabeça"; a lista viva; e o CTA "MANDAR NO GRUPO 📲".
4. WHEN a lista viva renderiza THEN SHALL agrupar os itens escolhidos pelas três categorias do formulário com subtotal por categoria (A-07), cada linha com emoji, nome, quantidade e valor — **sem** botão "QUEM LEVA?" (A-02) e **sem** a dica 💡.
5. WHEN qualquer controle do formulário muda THEN o card-herói **e** a lista viva SHALL recalcular juntos, na mesma interação.
6. WHEN a lista viva excede a altura disponível THEN SHALL rolar dentro do próprio contêiner, e a página SHALL **nunca** rolar horizontalmente (W-R4).
7. WHEN a tela está em expandido THEN o rodapé fixo mobile SHALL **não** existir — o CTA mora no rail (W-R2).

**Independent Test**: montar em viewport expandida e afirmar os rótulos de W-03, a ordem dos três blocos do rail, a ausência do rodapé fixo e a ausência de "QUEM LEVA?"; mudar um chip e afirmar que card-herói e lista viva mudaram na mesma interação.

---

### P1: Festa sem ninguém ⭐ MVP

**User Story**: Como anfitrião, quero que o app não invente compras quando ainda não tem ninguém confirmado.

**Why P1**: É a exceção E1 de UC-03, escrita explicitamente na spec-fonte, e a camada de cálculo já a implementa com guarda dedicada.

**Acceptance Criteria**:
1. WHEN a contagem chega a 0 pessoas THEN o total SHALL ser "R$ 0", o valor por cabeça SHALL ser "R$ 0" e a lista SHALL ficar vazia.
2. WHEN a contagem é 0 THEN os steppers SHALL **não** descer abaixo de 0 (UC-03 E1) — o controle de decremento fica inerte no piso.
3. WHEN a contagem é 0 e há chips selecionados THEN **nenhum** item SHALL aparecer na lista viva — nenhum piso `max(1, …)` de RN-04..RN-09 pode produzir uma lata de cerveja para uma festa sem plateia.
4. WHEN a contagem volta a subir THEN a lista SHALL voltar a ser calculada normalmente.

**Independent Test**: zerar os três steppers e afirmar "R$ 0", lista vazia e decremento inerte; subir um e afirmar que a lista voltou.

---

### P1: Começar um rolê novo ⭐ MVP

**User Story**: Como anfitrião, quero que tocar "🔥 CHURRASCO" já me deixe montando, e poder dar nome e data ao rolê ali mesmo.

**Why P1**: É a pré-condição de UC-03 ("festa criada ou template CHURRASCO tocado"). Sem ela, `/roles/novo` não tem o que abrir e a Home tem um botão que não leva a lugar nenhum.

**Acceptance Criteria**:
1. WHEN `/roles/novo` abre THEN SHALL exibir um rascunho com o nome default "CHURRAS NOVO" e a data default do próximo sábado (A-04), já montável.
2. WHEN o nome ou a data são acionados no header THEN SHALL ser editáveis na própria tela, sem navegação e sem tela nova (A-03).
3. WHEN o nome é editado THEN o título da festa SHALL refletir a mudança onde ele aparece — no header mobile e na linha de título do web.
4. WHEN a primeira mudança é feita no rascunho THEN a festa SHALL ser persistida e a rota SHALL passar a refletir o `festaId` (`/roles/{festaId}/montar`).
5. WHEN `/roles/{festaId}/montar` abre para uma festa existente THEN SHALL carregar a composição salva, não um rascunho novo.
6. WHEN o nome é apagado por completo THEN SHALL voltar ao default em vez de ficar vazio.

**Independent Test**: abrir `/roles/novo` e afirmar nome e data default; editar o nome e afirmar a mudança no título e a rota com `festaId`; reabrir a rota da festa e afirmar a composição preservada.

---

### P2: Sair da tela pelos dois caminhos

**User Story**: Como anfitrião, quero fechar a lista no celular e, no computador, salvar sem precisar mandar no grupo.

**Why P2**: Os destinos são telas que não existem no M1; o valor da tela está no cálculo ao vivo, que os P1 já entregam.

**Acceptance Criteria**:
1. WHEN "FECHAR LISTA →" é acionado em compacto THEN SHALL navegar para `/roles/{festaId}/lista` (A-13).
2. WHEN "MANDAR NO GRUPO 📲" é acionado em expandido THEN SHALL navegar para `/roles/{festaId}/whatsapp` (A-13).
3. WHEN a tela está em expandido THEN o rail SHALL oferecer uma ação secundária "SALVAR ROLÊ" (A-14) que persiste sem navegar.
4. WHEN "SALVAR ROLÊ" conclui THEN SHALL exibir o toast canônico "ROLÊ SALVO ✊" — literal de RN-29, pelo componente da spec 01, 1 por vez, 2200 ms.
5. WHEN o botão voltar do header é acionado THEN SHALL voltar para a Home com a composição preservada.

**Independent Test**: acionar cada saída e afirmar a rota resultante; afirmar o texto do toast contra `BoraToastTexts.roleSalvo` — **não** contra um literal escrito no teste *(L-008: comparar com o token, não com o literal)*.

---

### P2: As preferências realimentam a lista

**User Story**: Como anfitrião, quero que a lista já venha ajustada às restrições da galera, para não comprar o que ninguém vai comer.

**Why P2**: RN-21 depende de pessoas nomeadas, que só nascem na spec 07 `galera`. No M1 não há produtor — mas o consumo tem que estar certo desde já, senão `galera` reescreve esta tela.

**Acceptance Criteria**:
1. WHEN a composição tem pessoas nomeadas com dieta veggie (≥1) THEN a lista viva SHALL incluir "Legumes p/ grelha" na categoria NA GRELHA (A-08), sem que exista chip para ele.
2. WHEN a composição tem alguém "sem porco" THEN a carne suína SHALL sair da lista mesmo com o chip 🐷 SUÍNA selecionado, e o chip SHALL permanecer no estado em que o usuário o deixou.
3. WHEN há pessoas nomeadas THEN a quantidade de cerveja SHALL dimensionar por **quem bebe**, não por `adultos` (RN-21 sobre RN-05).
4. WHEN **não** há pessoas nomeadas THEN nenhum efeito de RN-21 SHALL se aplicar e a contagem dos steppers SHALL governar sozinha (A-10).

**Independent Test**: alimentar a tela com composições contendo pessoas nomeadas (a camada de cálculo já as aceita) e afirmar os três efeitos na lista viva, mais o caso de controle sem nomeados. *(Todos os efeitos vêm de `CalculadoraDaFesta`; o teste afirma o que a tela **mostra**, não a fórmula.)*

---

## Edge Cases

- WHEN nenhum chip está selecionado e há pessoas THEN a lista SHALL ficar vazia e o total SHALL ser "R$ 0" — sem erro e sem item fantasma.
- WHEN só uma carne está selecionada THEN ela SHALL receber **todas** as gramas de RN-03 (a divisão é entre as carnes selecionadas).
- WHEN todas as carnes são desmarcadas THEN nenhuma linha de carne SHALL aparecer e a divisão de gramas SHALL não ser executada.
- WHEN a duração é "Dia" THEN o card-herói SHALL exibir "Dia todo", não "10 horas" (RN-13 / A-15).
- WHEN a viewport cruza 900px com a tela montada THEN SHALL trocar entre rodapé fixo e rail preservando toda a composição (W-R3, W-R1).
- WHEN o valor total tem centavos na aritmética interna THEN a tela SHALL exibir o inteiro de RN-13 — e o total SHALL ser o arredondamento da soma exata, nunca a soma de parcelas já arredondadas (AD-009).
- WHEN um stepper é mantido pressionado THEN o incremento SHALL permanecer de 1 em 1 por acionamento — nenhuma spec define auto-repeat.

---

## Requirement Traceability

| ID | História | Origem na spec-fonte | Fase | Status |
|---|---|---|---|---|
| MONT-01 | P1-1 AC1 | T-03 | Design | Pending |
| MONT-02 | P1-1 AC2,AC3,AC4 | T-03 | Design | Pending |
| MONT-03 | P1-1 AC5 | T-03 (rodapé) | Design | Pending |
| MONT-04 | P1-2 AC1 | UC-04 | Design | Pending |
| MONT-05 | P1-2 AC2 | **UC-03 (aceite) / RN-30** | Design | Pending |
| MONT-06 | P1-2 AC3 | UC-04 / RN-14 / A-05 | Design | Pending |
| MONT-07 | P1-2 AC4,AC5 | RN-13 / RN-02 | Design | Pending |
| MONT-08 | P1-2 AC6 | `CLAUDE.md` (fórmula não vaza) | Design | Pending |
| MONT-09 | P1-3 AC1,AC2 | W-03 / A-09 | Design | Pending |
| MONT-10 | P1-3 AC3 | W-03 (rail) | Design | Pending |
| MONT-11 | P1-3 AC4 | W-03 / A-02 / A-06 / A-07 | Design | Pending |
| MONT-12 | P1-3 AC5 | W-03 (comportamento) / W-R1 | Design | Pending |
| MONT-13 | P1-3 AC6,AC7 | W-R2 / W-R4 | Design | Pending |
| MONT-14 | P1-4 AC1..AC4 | **UC-03 E1** | Design | Pending |
| MONT-15 | P1-5 AC1,AC2,AC3,AC6 | A-03 / A-04 | Design | Pending |
| MONT-16 | P1-5 AC5 | UC-03 (pré) | Design | Pending |
| MONT-17 | P1-5 AC4 | dimensão: state transition | Design | Pending |
| MONT-18 | P2-1 AC5 / A-12 | W-R1 | Design | Pending |
| MONT-19 | dimensões: failure, observability | AD-004 / AD-005 | Design | Pending |
| MONT-20 | dimensão: idempotência | — | Design | Pending |
| MONT-21 | dimensão: concurrency | UC-04 (latência imperceptível) | Design | Pending |
| MONT-22 | P2-1 AC1,AC2 | T-03 / W-03 / A-13 | Design | Pending |
| MONT-23 | P2-1 AC3,AC4 | W-03 (lacuna) / RN-29 / A-14 | Design | Pending |
| MONT-24 | P2-2 AC1..AC4 | RN-21 (consumo) | Design | Pending |

**Cobertura:** 24 requisitos · 0 mapeados a tasks (Design pendente) · 0 órfãos.

---

## Porte

**Grande**, como o roadmap já previa — e o Discuss não mudou isso. O corte estimado é de **~12 tasks**: duas plataformas com layouts estruturalmente diferentes (rodapé fixo × rail sticky), o rascunho de `/roles/novo` com header editável, a lista viva agrupada, e o guard que impede a fórmula de vazar. **Design e Tasks formais.**

O que o Discuss **reduziu** foi o escopo: sem "QUEM LEVA?", sem dica 💡 e sem overrides, o rail é leitura pura — o que mantém `montar` do lado certo da fronteira com `lista`.

---

## Success Criteria

- [ ] `flutter analyze` = zero issues · suíte inteira verde, baseline preservada.
- [ ] **Aceite de UC-03 na tela**: estado padrão de RN-30 ⇒ "R$ 211" e "≈ R$ 30 / cabeça" renderizados, nas duas plataformas (A-01 é o que torna isso possível no mobile).
- [ ] Aceite de UC-04: nenhum botão "calcular" existe; qualquer toque atualiza total e per capita.
- [ ] Guard de varredura verde: nenhuma aritmética de domínio nem formatação de dinheiro em `lib/features/montar/**`.
- [ ] W-03 funcional: rail sticky, lista viva rolando dentro de si, zero scroll horizontal, sem rodapé fixo.
- [ ] Zerar a festa dá R$ 0 e lista vazia; steppers não descem de 0.
