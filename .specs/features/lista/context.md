# Sua lista (lista turbinada) — Context

**Gathered:** 2026-08-27
**Spec:** `.specs/features/lista/spec.md`
**Status:** Ready for design

> **O Discuss desta spec já aconteceu — e produziu duas ADs.** O `ROADMAP.md` marcava Discuss para a spec 06 por causa das zonas cinzentas **G2** (origem dos preços de RN-11) e **G3** (integração de delivery de RN-27). O usuário decidiu as duas em **2026-08-27**, e elas estão registradas em `.specs/STATE.md` como **AD-023** e **AD-024**. Este documento registra essas duas decisões como fechadas e, abaixo delas, as **decisões do agente** sobre as ambiguidades que sobraram — que espelham uma a uma as vinte e três assumptions da tabela `Assumptions & Open Questions` do `spec.md`.

---

## Feature Boundary

A tela `/roles/:festaId/lista` — **T-04 nos dois modos** em compacto e a linha "Sua lista (turbinada)" de W-04 em expandido. Entrega: a lista calculada com os quatro essenciais automáticos de **RN-10** e seus badges `AUTO ∝` (UC-05); a leitura de mercado de **RN-11** por item, com "média de N mercados", faixa mín–máx e marcador (UC-14); a régua de override de **RN-12**, com steppers duplos, ponto vermelho e RESTAURAR (UC-06); o checklist agrupado por corredor de **RN-27**, com check verde e contador do carrinho (UC-15); e o pedido por delivery inteiro — sheet, endereço trocável, três parceiros, `subtotal + frete = total`, overlay "PEDIDO A CAMINHO! 🛵" e a despesa de **RN-20** — atrás de porta abstrata (UC-16). O rodapé consome **RN-13** e **RN-14** e mostra "por adulto".

**Não** entrega: a montagem da festa (spec 05 `montar` — steppers, chips, duração, o rail de W-03 e o "SAI POR" de R$ 211 / ≈ R$ 30 por cabeça); pessoas, preferências, papéis e link (spec 07 `galera`); a mensagem e o grupo do WhatsApp (spec 08 `convite`); o RSVP e o "eu levo" (spec 09 `convidado`); a tela de custos e todo o acerto (spec 10 `custos`); e o seletor **"QUEM LEVA?"**, que a **AD-018** já pôs fora do M1.

---

## Implementation Decisions

### AD-023 — os preços de RN-11 são tabela curada em Dart puro *(decisão do usuário, 2026-08-27)*

- A tabela do arquivo 03 — média, mín, máx e nº de fontes por item — é **fixture tipada** em `core/calculo`, sobre a entidade `PrecoDeMercado` que a AD-008 já pôs lá. Ela **já existe implementada e testada** (`tabela_de_precos_de_mercado.dart`, oito linhas literais).
- **Não há geolocalização e não há consulta.** "perto de você" é copy literal da dica de T-04, e o `N` de "média de N mercados" vem da coluna **Fontes** da própria tabela — nunca de uma contagem em runtime.
- Consequência para a tela: `LIST-08` renderiza o sub e a barra **só** para os itens que a tabela cobre. Os que ela não cobre — frango, água, suco, destilados, sal grosso, copos & pratos — aparecem sem faixa e sem "média de N mercados". Fabricar faixa para eles seria inventar dado que a AD-023 não autoriza.
- Consequência para o teste: o total da tabela (**R$ 286**, faixa **R$ 234–356**) é caso literal e continua sendo cobrado onde já é verdadeiro — sobre a fixture, via `totalDeMercado`. `LIST-09` AC5 o mantém como critério desta spec.
- Trade-off aceito na AD: os preços envelhecem e só mudam por deploy. Trocar por fonte viva é substituir a implementação atrás da mesma porta, sem tocar em tela.

### AD-024 — o pedido é implementado inteiro, atrás de porta, com adaptador falso *(decisão do usuário, 2026-08-27)*

- **Tudo o que UC-16 descreve é construído de verdade**: a sheet, o endereço com "TROCAR", os três parceiros com ETA e frete de RN-27, o resumo `Subtotal + Frete = Total`, o overlay de tela cheia e a `Despesa` entrando no acerto por RN-20.
- **Só a chamada ao parceiro é falsa.** O envio passa por uma porta abstrata (`LIST-28`) cuja única implementação do MVP não faz rede. Quando houver contrato, troca-se o adaptador sem tocar em tela nem em teste de aceite.
- **A copy de T-04 fica literal, sem selo de "simulado"** — o selo foi oferecido ao usuário e **recusado**, por alterar copy literal.
- **Consequência declarada, e ela é desconfortável de propósito:** a tela afirma "PEDIDO A CAMINHO! 🛵" sem pedido a caminho, e lança no racha uma despesa de um pedido que não existe. Está registrada como linha da tabela de assumptions do `spec.md` (A-20 e `LIST-28` AC4) e na própria AD-024, que fecha com a ressalva de exposição: **enquanto o adaptador for falso, o produto não vai a público com essa tela ativa** sem revisão da AD.

### AD-010 — "Copos & pratos" aparece e não soma

- `entraNoTotal` é **dado declarado** em `DefinicaoDeItem`, não número embutido. A tela exibe os quatro essenciais e soma três: Carvão 22 + Gelo 30 + Sal 8 = **R$ 60**.
- Consequência que esta spec precisou fechar sozinha: o item fora do total também fica **fora do pedido** e **fora da faixa real** (A-19). Um item que não aparece no total e aparece no pedido cobraria no acerto (RN-20) um valor que a lista nunca mostrou.

### RN-14 — os dois números coexistem e não se unificam

- O rodapé da Lista mostra **"por adulto"** — `totalComEssenciais ÷ adultos`, criança de fora: **R$ 271** e **≈ R$ 45** no estado padrão de RN-30.
- O "≈ R$ X / cabeça" é da tela Montar, divide por **pessoas** e já está entregue pela spec 05, cuja A-05 declara literalmente que o R$ 271 / ≈R$ 45 "é da tela Lista".
- `ResultadoDoCalculo.porAdulto` já se documenta como "o 'por adulto' **da tela Lista**". Nada aqui recalcula: a tela lê os dois campos prontos.
- É esta decisão que resolve a maior divergência da spec-fonte (**D-1**): entre as duas moedas possíveis da tela, a moeda da festa é a da calculadora, e a tabela de RN-11 é leitura de referência ao lado.

### AD-016 — dado de festa em memória atrás de porta

- Nada nesta spec pode exigir Firestore. Overrides e checks vivem na festa, atrás da porta `FestaEmEdicaoRepository` de `core/festas/` — que a spec 05 criou justamente para ter mais de um consumidor — e **morrem com o processo**.
- A spec declara isso em vez de o esconder: A-05 e A-06 dizem que o escopo é "dentro da festa", que é exatamente o que UC-06 e UC-15 cobram, e um `Edge Case` registra que fechar o app perde tudo — comportamento declarado, não defeito.

### Nunca duplique fórmula na UI

- Toda a aritmética desta tela já existe em `core/calculo`: `totalExato`, `estimativaPorAdulto`, `posicaoDoMarcador`, `totalDeMercado`, `comPassoDeQuantidade`, `comPassoDePreco`, `restaurado`, `subtotalDeItens`, `subtotalDoQueFalta`, `totalDoPedido`.
- `LIST-07` instala o mesmo guard de varredura que a spec 05 usou em MONT-08: sem `R$` literal, sem `.round(`/`.toStringAsFixed(`, sem `*` `/` `%`, sem `.fold(`/`.reduce(` em `lib/features/lista/**`.
- É a restrição mais dura do projeto, e esta é a tela com mais superfícies de dinheiro do M1 — cinco: preço de item, override, subtotal de categoria, total com essenciais e subtotal + frete.

---

## Agent's Discretion

Não houve conversa com o usuário além das duas ADs, então não há área em que ele tenha dito "você decide". O que ficou **legitimamente** a critério do Design, e a spec não fixa:

- **Onde mora o conjunto "no carrinho"** — `ComposicaoDaFesta` ou `FestaEmEdicao` (emenda **E-b**). A spec fixa o comportamento (sobrevive à troca de modo e de aba, é reaplicado sobre os itens recalculados) e deixa a entidade em aberto.
- **Como o corredor é atribuído** aos itens que RN-11 não cobre (emenda **E-a**) — campo em `DefinicaoDeItem` ou mapa próprio. A spec fixa a **atribuição** (`LIST-17`), não o formato.
- **A composição visual do checkbox 26×26** a partir dos tokens do arquivo 02 (A-13), já que `core/design_system` está fechado e não tem componente de check.
- **O corte em tasks** e o número de blocs — um por tela ou um por modo.

---

## Declined / Undiscussed Gray Areas → Assumptions

Nenhuma destas foi levada ao usuário; todas estão na tabela `Assumptions & Open Questions` do `spec.md`, com default e racional. Espelho por número:

| # | Zona cinzenta | Default do agente |
|---|---|---|
| A-01 | Qual das duas moedas é a moeda da tela | A da calculadora; RN-11 é leitura de mercado ao lado (**D-1**) |
| A-02 | UC-04 pede "por adulto" e T-04 não desenha a linha | Linha "≈ R$ {x} por adulto" no rodapé, nos dois modos |
| A-03 | Origem do "faixa real" total | Soma sobre os itens da lista: cobertos com (mín, máx) da tabela, não cobertos com o próprio valor nas duas pontas — regra que devolve 234–356 aplicada à tabela |
| A-04 | Override × média | O override manda sempre; a barra de faixa **não** se move com ele |
| A-05 | Escopo de persistência dos overrides | Festa, atrás da porta; morre com o processo (AD-016) |
| A-06 | Escopo de persistência dos checks | Idem, e reaplicados sobre os itens recalculados (**E-b**) |
| A-07 | "PEDIR O QUE FALTA" quando nada falta / quando tudo falta | Nada falta ⇒ CTA inerte, sheet não abre, sem toast; tudo falta ⇒ pede a lista inteira |
| A-08 | Endereço e "TROCAR" | Nasce de `Festa.local`; "TROCAR" vale só para o pedido em curso |
| A-09 | Zé Delivery só-bebidas com açougue na lista | Cartão sempre visível, **inerte** enquanto houver item fora de BEBIDAS; sem copy de erro nova |
| A-10 | "RESTAURAR" tem confirmação? some? | Sem confirmação e sem toast; só existe quando há override e some ao zerar |
| A-11 | Estado vazio da lista (0 pessoas) | Card vazio sem copy inventada, R$ 0, sem faixa, CTA inerte, "0 de 0 no carrinho" |
| A-12 | Categorias do card de PLANEJAR | Ordem canônica + o bloco literal "ESSENCIAIS · ENTRAM SOZINHOS" |
| A-13 | Checkbox 26×26 não existe no design system | Composto na feature com tokens do arquivo 02 |
| A-14 | Parceiro pré-selecionado na sheet | iFood Mercado, o primeiro de RN-27 |
| A-15 | De onde a Lista lê e onde grava | `FestaEmEdicaoRepository` como está, sem alargar e sem porta nova |
| A-16 | W-04 põe a lista "dentro do rail de W-03" | Layout próprio `1fr / 370px`; segmented no topo do rail e modal central ficam literais (**D-3**) |
| A-17 | As abas permanentes da festa | Revestimento em **P3**; a Lista renderiza e é testável sem ele |
| A-18 | Título da sheet | "FAZER PEDIDO", igual nos dois modos de entrada |
| A-19 | Copos & pratos no pedido | Fora do pedido e fora da faixa, como está fora do total |
| A-20 | Quem é "quem pediu" na `Despesa` | O nome do usuário na festa ("VOCÊ" na fixture); descrição "Pedido no {parceiro}"; valor = total com frete |
| A-21 | Confirmar pedido marca os itens? | Não |
| A-22 | Orçamento de 2 acentos por tela, e T-04 usa 3 | Vermelho e amarelo estruturais; verde é estado do check (**D-4**) |
| A-23 | Toasts desta tela | Nenhum — RN-29 não tem texto canônico para nenhuma ação daqui |

---

## Specific References

- **Os números são casos de teste, não ilustração.** Entram literais nos critérios: R$ 271 e ≈ R$ 45 por adulto (RN-10/RN-14), subtotal dos essenciais R$ 60 (AD-010), marcador em 37,9% com extremos R$ 54 e R$ 83 na Picanha bovina (RN-11/UC-14), total da tabela R$ 286 com faixa R$ 234–356 (RN-11), e os três totais de pedido — R$ 283 no iFood, R$ 280 no Rappi, frete R$ 0 no Zé (RN-27/UC-16). Dois números são **derivados da regra**, não literais da spec-fonte, e estão marcados como tais: a faixa real "de R$ 245 a R$ 343" no estado padrão.
- **A tabela de RN-11 nunca é igual à lista da festa.** A 🌭 Linguiça toscana não tem chip em T-03 (e por isso entra com `chave` nula na fixture), e a tabela não cobre frango, água, suco, sal grosso, copos & pratos nem destilados. É o fato que sustenta a resolução D-1: o total R$ 286 não pode ser total de tela.
- **A diferença entre as duas moedas no estado padrão é de exatos R$ 15** — Picanha 54 → 65 e Cerveja 72 → 76. Os outros quatro itens cobertos (pão, refrigerante, carvão, gelo) têm **o mesmo valor nas duas tabelas**.
- **Colisão de numeração a resolver fora desta spec:** o `design.md` da spec 05 `montar` reserva o número **AD-023** para "a escrita da festa mora em `core/festas/`", a registrar no `STATE.md` ao fim do Execute — mas o `STATE.md` já tem um **AD-023** (a tabela de preços curada). Quem fechar o Execute de `montar` precisa renumerar. Esta spec cita a decisão pelo nome (`FestaEmEdicaoRepository` em `core/festas/`), nunca pelo número, para não herdar a ambiguidade.

---

## Deferred Ideas

Ideias e lacunas que apareceram ao escrever a spec e **não** entram aqui:

- **Seletor "QUEM LEVA?" em popover/sheet** — a **AD-018** o adiou para depois do M1 e W-03 já pede o formato. `ItemDeLista.quemLeva` existe no domínio e continua sem UI que o escreva. Vai precisar da lista de confirmados da spec 07 `galera`.
- **Preço de mercado por unidade** — RN-11 dá média para uma quantidade de referência ("1,2 kg", "18 latas"), não preço por unidade. Quando a quantidade da festa diverge da referência, a faixa exibida continua sendo a da tabela, porque reescalá-la exigiria um modelo de preço que a regra não dá. Item para quando houver fonte viva de preços (a evolução que a própria AD-023 prevê).
- **Pedido com ciclo de vida** — rastreio, status, cancelamento. O arquivo 01 §6 modela `status` no `Pedido`, mas nenhuma tela de 04 ou 06 o desenha, e a AD-024 fecha o MVP no overlay. Entra com o adaptador real.
- **Despesa criada à mão** — a **AD-027** já a recusou no MVP e a declarou lacuna conhecida (uber, gás, aluguel de churrasqueira não têm onde entrar). Candidata a spec própria.
- **Golden images da tela** — a Lista é a tela mais densa do M1 (faixa, badges, opacidade a 45%, ponto de 8px) e é a que mais ganharia com teste de aparência. Ficaram fora do escopo por decisão desde o M0; a conferência continua sendo humana, com a skill `run`.
