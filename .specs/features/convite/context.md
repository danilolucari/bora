# O convite (mensagem, grupo e enquetes) — Context

**Gathered:** 2026-08-27
**Spec:** `.specs/features/convite/spec.md`
**Status:** Ready for design

---

## Feature Boundary

Esta feature entrega **as duas telas do WhatsApp** — T-06 (a mensagem de convite montada por blocos, com preview fiel de bolha) e T-07 (o grupo do rolê e as três enquetes) —, mais a linha "WhatsApp" de W-04 no web. Ela implementa **RN-25, RN-26 e RN-26b**, e cobre **UC-07 (P1), UC-17 (P2) e UC-18 (P2)**.

**Não** é dela: o link, o `codigo` e o nível do link (spec 07 `galera` — ela **consome** o link já configurado), a lista e os preços dos itens (spec 06 `lista`), quem confirma e quem assume cada item (spec 09 `convidado`), e o acerto (spec 10 `custos`).

A fatia do roadmap é explícita e vale como prioridade: **a mensagem por blocos (UC-07) é P1** e **grupo + enquetes (UC-17/UC-18) são P2** — a feature pode ser entregue pela metade se preciso.

---

## Implementation Decisions

### AD-025 — grupo e enquete são estado do BORA (decisão do usuário, já fechada)

**Data:** 2026-08-27 · **Decidida pelo usuário** · Registrada em `.specs/STATE.md` · Resolve a zona cinzenta **G4** do roadmap · **Escopo:** esta spec (T-06, T-07, UC-07, UC-17, UC-18).

O ROADMAP marcava "design + pesquisa" para esta spec por causa de G4. **A pesquisa foi substituída pela decisão** — ela não precisa ser refeita, e não foi refeita.

- A **API pública do WhatsApp não cria grupo nem posta enquete**, e a **Cloud API também não** (número comercial, aprovação da Meta, custo por conversa — e nenhuma das duas capacidades).
- Portanto **"grupo" e "enquete" são estado do BORA**, não objetos do WhatsApp.
- **`CRIAR GRUPO`** cria, dentro do BORA, um grupo com o nome da festa contendo **apenas os confirmados** (RN-25); o botão vira o chip verde **irreversível** "✅ '<nome>' · N membros".
- As **três enquetes de RN-26** (HORÁRIO, DATA, O QUE LEVAR) vivem no BORA: **um voto por enquete por pessoa, trocável**, com `% = round(votos/total×100)`.
- **`POSTAR ENQUETE NO GRUPO 📲`** e **`ENVIAR NO WHATSAPP →`** saem por **share sheet / `wa.me`**, levando o **texto montado** — é o único artefato que o WhatsApp de fato aceita de fora.
- A trava **"CRIE O GRUPO PRIMEIRO ☝️"** (E1 de UC-18) continua valendo, agora sobre o grupo do BORA.
- **Toasts e estados seguem RN-29, literais.**
- **Trade-off aceito e registrado:** o chip descreve um grupo que não existe no WhatsApp do usuário. **Sem selo de "simulado", sem alteração de copy** — a copy de T-06/T-07 fica literal. Mesma forma da AD-024 (delivery).

**Objeção do agente:** nenhuma. A decisão é a única que mantém **todo** o comportamento observável de UC-17/UC-18 verdadeiro e testável (ação única e persistente, voto trocável, percentuais somando ~100, trava sem grupo) sem depender de plataforma que não oferece a capacidade. O custo — a copy prometer um efeito externo que não ocorre — está declarado na spec em `A-01` e em `§Divergências D-2`, onde alguém que revisitar o produto vai encontrá-lo.

### Composição da mensagem (T-06)

- Os três blocos são **aditivos** e nascem **os três ativos**; a ordem no texto e no preview é fixa: **FLYER → LISTA → LINK**.
- Com **os três desligados** a bolha **não renderiza** e o CTA fica **desabilitado** — nunca uma mensagem vazia.
- A **hora** do rodapé da bolha vem de um **relógio injetado, congelado na abertura da tela** (`HH:mm`, 24h). Os testes injetam 14:02 (T-06) e 14:05 (T-07) e reproduzem os literais da spec-fonte.
- A bolha **quebra linha e cresce em altura** dentro dos 300px; **nunca** trunca, **nunca** rola horizontalmente.
- O **texto enviado é exatamente o que o preview mostra** — é o aceite de UC-07 e o invariante que o Design tem de proteger (uma única função de montagem, consumida pelo preview e pelo canal).

### O grupo (T-07 / RN-25 / UC-17)

- O grupo guarda **só "foi criado" e o nome congelado**; **os membros são derivados ao vivo** do conjunto de confirmados. Quem confirma depois entra e a contagem sobe; quem passa a recusar sai.
- **Irreversível é o gesto**, não a contagem: o chip nunca volta a ser botão, e uma segunda chamada de criação é **inerte**.
- **Zero confirmados** → botão **desabilitado** e a linha derivada "0 confirmados entram no grupo". Nenhuma copy nova.
- O chip usa o **template de RN-25** com o nome **como gravado** na festa: `✅ "CHURRAS DO RAFA 🔥" · 4 membros`.

### As enquetes (T-07 / RN-26 / UC-18)

- Os três modelos são **exclusivos** (um por vez), com **HORÁRIO** ativo na abertura — ao contrário dos blocos de T-06.
- Os **votos-base de RN-26 são fixture de demo** (5/2/1, 6/2, 3/1), sem votante identificável; o **voto do usuário soma +1**.
- **Trocar de opção move o +1**; tocar a opção já votada é **no-op** — não existe desvoto.
- **As três enquetes coexistem**, cada uma com seu voto: trocar de modelo **preserva** o voto de cada uma (aceite de UC-18).
- Postar leva **só a enquete selecionada**, como texto: pergunta em CAIXA ALTA + uma linha por opção com rótulo literal e `%`. **Sem link, sem assinatura.**

### Persistência, portas e falha

- **`ConviteRepository`** — porta própria em `features/convite/domain/`, reativa (`Stream`), impl **em memória** no escopo da festa (**AD-016**). "Persistente" = sobrevive a rebuild, troca de aba e navegação; **não** sobrevive a reiniciar o processo. Firestore entra no M2 com a spec 09. `FestaRepository` **não muda** (precedente `galera` A-01).
- **`CompartilhadorDeTexto`** — porta única para share sheet (mobile) / `wa.me` (web). **Sem fallback de canal, sem retry, sem fila.**
- **O toast de sucesso só depois de o canal confirmar a abertura.** Cancelar **não é falha** (sem toast, sem log de erro). Falha real: sem toast de sucesso, **sem copy de erro inventada**, registro no `AppLogger` (AD-005) **sem** o texto montado nem o link.
- Falha de leitura do repositório → **estado de erro visível, nunca tela branca**.

### Navegação

- **T-07 é a aba `whatsapp`** que a **AD-003** já criou; **T-06 é rota filha** `/roles/:festaId/whatsapp/convite`, aninhada no mesmo branch do `StatefulShellRoute`, alcançada pelo CTA "MANDAR NO GRUPO 📲" de T-03/W-03 e pelo "+ CONVIDAR" do card da Home. O "voltar" do header de T-06 faz `pop`.
- **É a única alteração no mapa canônico da AD-003 que esta spec autoriza.** O Design confirma a forma exata.
- As duas telas **não revestem** o `FestaTabsShell` (é da spec 06) e têm de renderizar quando abertas direto.

### Consumo, nunca recálculo

- O **"💸 sai ~R$ X por cabeça"** é a **estimativa por pessoas** de RN-14 — a mesma de T-03 —, vinda pronta de `core/calculo` e formatada por **RN-13**. Nenhuma aritmética na camada de apresentação (CLAUDE.md).
- O preço de cada item é **`ItemDeLista.valor`, a moeda da calculadora**, conforme a resolução **D-1 da spec 06 `lista`**. A tabela de mercado de RN-11 **não** entra nesta tela.
- **RN-22** é consumida da spec 07 (GAL-19), não redefinida: **ANFITRIÃO e CO-ANFITRIÃO** enviam o convite, criam o grupo e postam a enquete.

### Agent's Discretion

O usuário não foi consultado sobre nada além de G4 → AD-025. Tudo o mais nesta seção e na seguinte foi decidido pelo agente, e o Design tem liberdade para refinar **a forma** (nomes de classe, granularidade dos blocs, onde exatamente o relógio é injetado, se `ConviteRepository` se divide em dois) **desde que o comportamento observável dos 37 critérios não mude**.

### Declined / Undiscussed Gray Areas → Assumptions

Nenhuma ambiguidade além de G4 foi levada ao usuário — o agente não tinha acesso a ele durante o Specify. **As 28 entradas estão registradas na tabela `Assumptions & Open Questions` do `spec.md`**, cada uma com default escolhido e racional. Resumo, na ordem em que aparecem lá:

| # | Assunto | Default |
|---|---|---|
| A-01 | Consequência declarada da AD-025 (o chip descreve grupo inexistente) | Copy literal, sem selo de "simulado" |
| A-02 | Quem vota nas enquetes / os votos-base de RN-26 | Fixture de demo; o voto do usuário soma +1; sem desvoto |
| A-03 | Persistência do grupo e dos votos sob AD-016 | `ConviteRepository` em memória; "persistente" = sobrevive a navegação, não a restart |
| A-04 | Irreversibilidade × confirmação tardia | Membros **derivados ao vivo**; a contagem sobe, o chip nunca volta a ser botão |
| A-05 | Os três blocos desligados | Bolha não renderiza; CTA desabilitado |
| A-06 | Que hora o preview mostra | Relógio injetado, congelado na abertura; testes injetam 14:02 / 14:05 |
| A-07 | Texto muito longo na bolha | Quebra e cresce; nunca trunca, nunca rola horizontal |
| A-08 | Falha ao abrir o WhatsApp / share cancelado | Toast só após o canal abrir; cancelar não é falha; falha sem copy de erro, com log |
| A-09 | Escopo da memória do voto ao trocar de modelo | Três enquetes independentes no `ConviteRepository`, por festa |
| A-10 | Contrato de leitura do bloco LISTA | Três leituras, zero cálculo; "por cabeça" = por **pessoas**; moeda = D-1 da spec 06 |
| A-11 | Dois separadores no bloco LISTA (" + " × " · ") | Ambos preservados literalmente |
| A-12 | Bloco LISTA sem matéria-prima | Cada linha só se tiver conteúdo; a linha de custo sempre; sem copy nova |
| A-13 | Caixa do nome da festa no chip | Template de RN-25 com o nome como gravado |
| A-14 | Plurais de "confirmados" e "membros" | Derivados, com plural correto |
| A-15 | Estado inicial e exclusividade dos toggles | Blocos aditivos, três ativos; modelos exclusivos, HORÁRIO ativo |
| A-16 | O que "POSTAR" posta | Só a enquete do modelo selecionado |
| A-17 | Conteúdo do texto da enquete | Pergunta em caixa alta + opções com `%`; sem link, sem assinatura |
| A-18 | Onde T-06 e T-07 moram na navegação | T-07 = aba `whatsapp`; T-06 = rota filha `/whatsapp/convite` |
| A-19 | O CTA "ENVIAR E VER O LADO DO CONVIDADO →" | Fora do produto (narração de demo) |
| A-20 | Orçamento de acento do arquivo 02 §8 | T-06: vermelho + `#25D366`; T-07: só `#25D366` (`#DCF8C6` é a variante clara) |
| A-21 | Zero confirmados | Botão desabilitado; linha derivada "0 confirmados entram no grupo" |
| A-22 | Idempotência de criar grupo, postar e togglar | Segunda chamada inerte; toggle já ativo é no-op; 1 toast por vez |
| A-23 | Falha do repositório | Estado de erro visível, nunca tela branca; log no `AppLogger` |
| A-24 | Barra de abas ausente | As telas não revestem o shell e renderizam abertas direto |
| A-25 | Título da aba no web | "bora — a conta do rolê" (W-R5, literal) |
| A-26 | "CONVITE COPIADO 📋" e "LISTA NO GRUPO 📲" de RN-29 | Nenhum botão inventado para eles |
| A-27 | Quem pode enviar, criar grupo e postar | ANFITRIÃO e CO-ANFITRIÃO, pela tabela de RN-22 da spec 07 |
| A-28 | Mudança remota com a tela aberta | Preview recompõe preservando blocos, modelo e voto |

---

## Specific References

- **`.specs/init-spec/04-telas-ux.md` — T-06 e T-07 são a fonte da verdade visual e de copy**, literalmente: "NO PACOTE", "é assim que chega no grupo — mexa nos blocos acima", "💬 CRIAR GRUPO DO ROLÊ", "grupo do rolê + enquetes num toque", "toque numa opção pra votar 👆", "📊 ENQUETE · você".
- **RN-26 é caso de teste, não ilustração** — as três perguntas, as sete opções e os votos-base 5/2/1, 6/2, 3/1 entram literais nos critérios, junto com os percentuais que eles produzem (**63/25/13**, **75/25**, **75/25**) e o que o voto do usuário produz (**67/22/11** em HORÁRIO).
- **RN-29 é copy literal, com emoji**: "ABRINDO O WHATSAPP… 📲", "GRUPO CRIADO NO WHATSAPP ✅", "ENQUETE POSTADA NO GRUPO 📲", "CRIE O GRUPO PRIMEIRO ☝️" — 2200 ms, um por vez.
- **Componentes do arquivo 02 já entregues pela spec 01** que esta feature consome: `BoraPollOption` (opções votáveis com barra e `%`), `BoraSelectionChip`, `BoraToast` / `BoraToastTexts`, `BoraPrimaryButton`, `BoraPressSink`, `BoraAvatar`, `BoraSurface`. **Nada de cor, tipo, forma, sombra ou duração fora dos tokens.**
- **Precedentes de specs vizinhas seguidos de propósito:** `galera` A-01 (porta própria em vez de alargar `FestaRepository`), `galera` A-07 (sem sucesso, sem toast de sucesso), `galera` A-10 / `home` A-05 / `convidado` A-16 (número na copy é derivado, com plural), `galera` A-18 (alcançável sem a barra de abas), `convidado` A-06 ("no fluxo (integrado)" é narração de demo), `convidado` A-15 ("por cabeça" é por pessoas, não a cota).
- **Neo-brutalismo, sem exceção:** `border-radius: 0` (só avatares e o frame fogem), sombras duras sem blur, sem gradiente, máx. 2 acentos por tela, CTA afunda `translate(2px,2px)` com a sombra de 4px para 2px.

---

## Deferred Ideas

Ideias que apareceram durante o Specify e **não** pertencem a esta spec:

- **Publicar o grupo do BORA para os membros.** Hoje o grupo é visível só ao anfitrião, na tela dele. Uma superfície onde o convidado veja "você está no grupo do rolê" seria da spec 09 `convidado`, e nenhuma tela da spec-fonte a desenha.
- **Convidado votando nas enquetes.** RN-26 diz "1 voto por enquete **por pessoa**", o que só faz sentido pleno quando mais de uma pessoa alcança a enquete. T-08 não tem enquete. É evolução natural pós-M2, com tela nova.
- **Enquete personalizada** (pergunta e opções escritas pelo anfitrião). RN-26 fixa **três modelos**; um construtor de enquete seria feature própria, com validação de entrada que esta spec declarou não ter.
- **Cloud API do WhatsApp com template aprovado.** Descartada pela AD-025 por não entregar grupo nem enquete, mas continua sendo o caminho se um dia o produto quiser mandar mensagem **sem** o usuário tocar no share sheet. Exigiria número comercial, aprovação da Meta e custo por conversa.
- **Os toasts órfãos "CONVITE COPIADO 📋" e "LISTA NO GRUPO 📲"** (RN-29) — "LISTA NO GRUPO 📲" tem candidato natural em T-04 (spec 06 `lista`); "CONVITE COPIADO 📋" não tem gesto em nenhuma tela desenhada e provavelmente é resíduo do protótipo.
- **Reenviar / editar uma enquete já postada.** Não há estado de "postada" no BORA — postar é entregar texto ao share sheet e nada mais. Um histórico de postagens seria domínio novo.
- **Renomear ou refazer o grupo.** RN-25 diz irreversível, e A-04 congela o **nome** no instante da criação (só os **membros** são derivados ao vivo) — então renomear a festa depois **não** renomeia o grupo, e o chip continua mostrando o nome com que ele nasceu. Uma UI de renomear, ou uma regra que faça o chip acompanhar o nome da festa, é feature futura.
