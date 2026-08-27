# O convidado (link público) — Context

**Gathered:** 2026-08-27
**Spec:** `.specs/features/convidado/spec.md`
**Status:** Ready for design

> **Houve Discuss parcial.** O `ROADMAP.md` marca **Discuss: sim** para a spec 09, e **uma** zona cinzenta — **G5**, o modelo de segurança do link e a identidade do convidado anônimo — foi levada ao usuário e fechada como **AD-026** em 2026-08-27. Ela está registrada abaixo em *Implementation Decisions*, como decisão **do usuário**, não do agente. Todas as demais ambiguidades desta feature foram resolvidas pelo agente a partir da spec-fonte e das ADs ativas, e estão em **"Declined / Undiscussed Gray Areas → Assumptions"**, espelhando uma a uma as vinte e seis entradas da tabela `Assumptions & Open Questions` do `spec.md`.

---

## Feature Boundary

A rota pública `bora.app/c/<codigo>` — T-08 inteiro em compacto e a linha "Convidado (link)" de W-04 em expandido — mais **RN-24** (RSVP sem conta) e **RN-28 do lado que produz**. Entrega os quatro estados de T-08 (Convite · Escolher o que leva · Confirmado · Não vou), a identidade sem conta (auth anônima + nome pedido uma vez), a escrita atômica que cria a `Pessoa` e move os contadores, a contribuição de **RN-20** para o acerto, as **security rules** que traduzem a tabela de RN-22 por nível de RN-23, e a entrada de **Firestore, Hosting e Functions** no projeto atrás das portas que as specs 04–07 já consomem.

**Não** entrega: a tela onde o nível do link é configurado (spec 07 `galera` — esta spec **consome** o nível), a mensagem e o grupo do WhatsApp (spec 08 `convite`), a lista do anfitrião (spec 06 `lista`), o acerto (spec 10 `custos` — esta spec **produz** a contribuição, não a exibe), push/e-mail para o anfitrião, conta para o convidado, nem qualquer controle de revogação ou expiração do link.

---

## Implementation Decisions

### AD-026 — o link é perpétuo, o papel é lido na abertura, a identidade é o aparelho *(decisão do usuário, 2026-08-27 — resolve a zona cinzenta G5)*

- O link `bora.app/c/<codigo>` **não expira e não é revogável**. Não há controle de revogação em nenhuma das duas pontas — nem na Galera (spec 07 já registrou), nem aqui.
- O papel de **RN-23** é lido **no instante da abertura**: quem já entrou mantém o papel com que entrou, mesmo que o anfitrião troque o nível depois. Virou `CVD-29`, com o papel **congelado** na pessoa.
- A identidade do convidado sem conta é o **uid da auth anônima do Firebase, persistido no dispositivo**. O mesmo aparelho volta como a mesma pessoa — é isso que faz "MUDEI DE IDEIA ✊" de UC-10 funcionar (`CVD-09`, `CVD-26`, `CVD-27`). **Outro aparelho é outra pessoa** (`CVD-11`).
- **Modelo de ameaça aceito e declarado**, não falha a corrigir: qualquer portador do código entra com o papel vigente; limpar os dados do navegador faz o convidado voltar como pessoa nova e **duplicar** o RSVP. Virou critério explícito (`CVD-11` AC10 e AC11), não nota de rodapé.
- Consequência para as dimensões implícitas: *data lifecycle* resolve em **N/A** só para expiração/revogação — o resto da dimensão (persistência do par uid+nome, festa concluída) tem requisito.
- Consequência para as rules: elas assumem "**qualquer portador do código, com o papel vigente**" como premissa de projeto (`CVD-30`, `CVD-31`), e o esforço de segurança vai para o que ainda importa — impedir que esse portador escreva contador, papel de terceiro ou nível do link.

### AD-016 — esta spec é a dona da entrada do Firestore, do Hosting e das Functions

- Até aqui o dado de festa é **em memória atrás de porta abstrata**. A troca acontece nesta spec, e a regra é: **as portas não mudam**. `FestaRepository` (spec 04) e `GaleraRepository` (spec 07) mantêm assinatura idêntica; nenhum arquivo de `presentation/` ou `domain/` das specs 04, 05, 06 e 07 é tocado (`CVD-33`).
- O **aceite é a suíte existente continuar verde** — e continuar rodando **sem emulador ligado**, que foi o ganho declarado da AD-016 e não pode ser perdido aqui.
- Firestore, rules e Functions ganham suíte própria contra o **emulador** (AD-004, emulator-first). `firestore.rules` e `functions/` moram na raiz.
- O `codigo` da festa é gerado no servidor (a spec 07, A-03, já declarou que a geração é desta spec) e é perpétuo. A fixture RN-30 mantém `rafa18`.

### AD-022 — os contadores são dado, e a deriva D-5 fecha aqui

- `confirmados` **coincide** com a contagem de pessoas nomeadas confirmadas e **tem de continuar coincidindo**. Virou invariante afirmável, reavaliado **depois de cada uma das seis transições** de RSVP (`CVD-21`).
- `pendentes` conta também quem recebeu o link e não respondeu — por isso decresce no RSVP, com **piso em 0**, e nunca é derivado.
- O aceite de RN-28 é a **transição** `4 confirmados/2 pendentes → 5 confirmados/1 pendente` mais o atalho "💸 VER O ACERTO DA FESTA →" (`CVD-20`), não a string estática.
- **D-5**, a pendência registrada no `validation.md` da spec `home` — a deriva entre o contador da Home e os nomeados da Galera — tem dono aqui e é resolvida por construção: **pessoa e contadores caem na mesma transação** (`CVD-19`), e a adoção de pendente (`CVD-10`) impede que o fluxo canônico de RN-30 produza uma sexta pessoa duplicada.

### AD-017 / AD-003 — a rota pública já existe e passa sempre

- `/c/:codigo` está em `Routes.convidadoPattern` desde a fundação, **fora de qualquer shell**, e a guarda de sessão a deixa passar **com ou sem sessão**. `CVD-01` afirma os dois casos — o segundo é o par que discrimina.
- Erro do convidado **nunca** cai em `/erro`: aquela rota tem chrome de app e W-04 proíbe header nesta tela. Os estados de erro são standalone (`CVD-39`, `CVD-40`, `CVD-43`).

### AD-019 — a auth anônima estende a porta que já existe

- A entrada anônima entra em `lib/core/autenticacao/`, atrás de `AutenticacaoRepository`, ao lado de e-mail/senha e Google. Nenhuma feature importa `firebase_auth`; `FirebaseAutenticacaoRepository` continua sendo o único arquivo que o faz.
- A entrada anônima é **silenciosa**: sem tela, sem botão, sem aviso (`CVD-02`). Qualquer superfície visível de autenticação quebraria o aceite de UC-08.

### O nome do convidado — a ambiguidade central *(decisão do agente)*

Resolvida em `A-01`, e vale a pena o registro completo porque é a decisão que mais amarra o resto da spec:

- O flyer abre **genérico** na primeira vez (RN-24: "abre **direto** no flyer"), com a tag "TE CHAMARAM PRO ROLÊ".
- O nome é pedido **uma vez, no primeiro compromisso** — no primeiro toque em "BORA! ✊" **ou** em "NÃO VOU 😔". Campo único, label "COMO TE CHAMAM?", placeholder "seu nome".
- Da segunda abertura em diante, o flyer é **personalizado** e o campo não reaparece.
- **Por que tem de existir:** AD-022 exige que `confirmados` coincida com pessoas **nomeadas**, e a spec 07 (A-02) declarou que pessoa nomeada nasce de duas fontes só — a fixture e o RSVP pelo link. RSVP anônimo tornaria o invariante impossível de sustentar.
- **Por que não fere UC-08:** um campo de nome não é cadastro — não há e-mail, senha, verificação nem conta. `CVD-05` afirma a ausência de qualquer campo de senha/e-mail, botão de login ou link de loja em todos os quatro estados.
- **Ligação com a Duda:** se o nome digitado bater com uma pessoa `pendente` **sem uid vinculado**, o RSVP **adota** aquela pessoa em vez de criar outra (`CVD-10`). Com a fixture RN-30 o fluxo canônico dá **5 pessoas, 5 confirmadas, 1 pendente** — não 6 pessoas.

### Os artefatos de protótipo saem do produto *(decisão do agente)*

- O banner roxo "← AGORA VOCÊ É A ANA — abriu o link no zap 📲" é narração de demo, marcada "no fluxo integrado" — a mesma marca que o arquivo 04 usa no "Mapa de etapas", que ele próprio declara não fazer parte do produto final. **Sai** (`CVD-06`).
- O botão "💸 VER O ACERTO DA FESTA →" na tela Confirmado também é "no fluxo": por RN-28 ele é o atalho da **Home do anfitrião**, e a spec 04 já o entregou lá (HOME-10). **Sai** da tela do convidado.
- A nota "✅ O {ANFITRIAO} já sabe que você vai." **fica**: é afirmação verdadeira sobre o estado do próprio convidado e é o que torna RN-28 legível para ele.
- Critério aplicado, elemento a elemento: *é alcançável e verdadeiro no produto?* Banner não · botão não · nota sim.

### Exclusividade de item e a corrida *(decisão do agente)*

- Item tem **um dono só** (arquivo 01 §6 e W-03 modelam a atribuição no singular). Compartilhar exigiria dividir valor entre donos — aritmética que RN-20 não define e que `core/calculo` não tem.
- A seleção é **local até "CONFIRMAR →"** (é o que UC-09 desenha), então a corrida é resolvida **dentro da transação do RSVP**, não a cada toque.
- **O RSVP nunca falha por causa de item.** Confirma, atribui só o que ainda está livre, e o bloco "VOCÊ LEVA:" lista exatamente o atribuído; se nada sobrou, lê o literal "nada — só a presença ✊". O item perdido reaparece na **dica** ("🥩 {NOME} já leva…"), que é onde T-08 põe item com dono. **Nenhuma copy nova** (`CVD-42`).

### A notificação ao anfitrião é a própria escrita realtime *(decisão do agente)*

- "Avisamos o Rafa" (UC-10) e "O Rafa já vê você" (T-08) são a **mesma coisa**: a pessoa aparece na Galera e os contadores da Home se movem, sem refresh.
- **Sem push, sem e-mail, sem WhatsApp no MVP** — nenhuma tela da spec-fonte desenha superfície de notificação para o anfitrião, e FCM exigiria token, permissão de navegador e ciclo de vida que nenhuma spec cobre.
- Se a escrita falhar, o convidado **não vê a tela de sucesso** (`CVD-41`): a promessa "avisamos" nunca é exibida sem o aviso ter acontecido.

### Agent's Discretion

O usuário decidiu **G5** e nada mais. Tudo abaixo é discrição do agente, exercida dentro da fronteira do `spec.md` e registrada como assumption:

- A forma exata do pedido de nome (campo único, sheet em compacto / modal em expandido) e o teto de 24 caracteres.
- O formato da junção da dica ("as carnes **e** o pão de alho").
- Os textos dos cinco estados de erro e o título da aba — copy nossa, declarada em §Divergências D-2.
- A escolha da estimativa "por pessoas" (e não da cota por adultos) na faixa amarela do flyer.
- A decisão de resolver o papel **no servidor, no instante da escrita**, em vez de aceitar um papel declarado pelo cliente.

### Declined / Undiscussed Gray Areas → Assumptions

As vinte e seis entradas abaixo espelham a tabela `Assumptions & Open Questions` do `spec.md`. Nenhuma foi levada ao usuário; nenhuma ficou silenciosamente em aberto.

| # | Zona cinzenta | Default do agente |
|---|---|---|
| A-01 | De onde vem o nome do convidado | Pedido uma vez, no primeiro compromisso; flyer genérico antes, personalizado depois |
| A-02 | Concordância de gênero na copy de T-08 | Reescrita sem gênero: "{NOME}, TE CHAMARAM PRO ROLÊ" e "✅ O {ANFITRIAO} já sabe que você vai." (D-1) |
| A-03 | Dois convidados no mesmo dispositivo | A segunda pessoa reabre o RSVP da primeira; sem troca de identidade |
| A-04 | O mesmo convidado em dois dispositivos | São duas pessoas, dois RSVPs, `confirmados` = 2 |
| A-05 | A Duda pendente da fixture | Adoção restrita: `pendente` + sem uid + nome igual após `trim`+`toLowerCase` |
| A-06 | Banner roxo e botão do acerto na tela do convidado | Ambos fora do produto; a nota do anfitrião fica |
| A-07 | Item exclusivo ou compartilhável | Exclusivo, dono único, primeira escrita vence, resolvido na transação |
| A-08 | O que a UI mostra a quem perde a corrida | RSVP confirma; só o livre é atribuído; item perdido migra para a dica; sem copy nova |
| A-09 | Idempotência do RSVP e reabertura do link | Documento chaveado pelo uid; contador se move só na transição; reabrir cai no estado |
| A-10 | O papel "lido na abertura" × cliente forjável | Resolvido no servidor no instante da escrita e congelado; abertura governa o que se vê (D-3) |
| A-11 | Código inválido / festa inexistente | Estado standalone "ESSE LINK NÃO EXISTE"; nunca `/erro` (D-2) |
| A-12 | Festa já concluída | Leitura aberta, escrita negada, "ESSE ROLÊ JÁ ROLOU" (D-2) |
| A-13 | Canal da notificação ao anfitrião | A própria escrita realtime; sem push/e-mail/WhatsApp no MVP |
| A-14 | Offline no meio do RSVP | Sem fila offline; seleção preservada + "TENTAR DE NOVO →" (D-2) |
| A-15 | Qual "por cabeça" vai no flyer | A estimativa por **pessoas** de RN-14, nunca a cota por adultos |
| A-16 | "4 já confirmaram" | Derivado de `confirmados`, com plural correto |
| A-17 | Pão de alho na lista **e** na dica de T-08 | Derivação vence o exemplo: lista = sem dono, dica = com dono (D-5) |
| A-18 | Junção dos itens na dica | Vírgulas e " e " antes do último |
| A-19 | RN-22 dá "ajusta a lista" ao CONVIDADO, T-08 não desenha | Rules permitem, tela desta spec não oferece (D-7) |
| A-20 | Campos da `Pessoa` criada pelo RSVP | `voce: false`, `dieta: null`, `bebe: null` — o caso da Duda (D-4) |
| A-21 | O RSVP muda quantidades e total? | Não — pessoa nomeada não entra com cabeça (decisão já tomada em `core/calculo`) |
| A-22 | Validação do nome | `trim`, recusa vazio, máx. 24 caracteres, sem quebra de linha |
| A-23 | Rate limit no link | Nenhum; a Function idempotente por uid limita o dano a uma pessoa por uid |
| A-24 | Onde moram rules e Functions, e como são testadas | Raiz, com suíte contra o emulador; a suíte de widget continua sem emulador |
| A-25 | Título da aba na página do convidado | "{NOME DA FESTA} — bora" (D-2) |
| A-26 | Como o convidado volta à festa depois | Pelo mesmo link, sempre — ele é perpétuo |

---

## Specific References

- **T-08 é a referência literal** dos quatro estados, e a copy é para ser reproduzida palavra por palavra: "BOA, {NOME}! ✊" · "O que você levar desconta da sua parte no racha." · "EU LEVO" ⇄ "VOCÊ LEVA ✓" · "VOCÊ LEVA R$ {soma}" · "CONFIRMAR →" · "TÁ MARCADO! ✊" · "nada — só a presença ✊" · "📅 SALVAR NA AGENDA" · "mudar o que eu levo" · "😔 QUE PENA" · "Avisamos o {ANFITRIAO} que você não vai desta vez." · "MUDEI DE IDEIA ✊" · "responde direto daqui — sem baixar nada" · "🔗 bora.app/c/<codigo> · abre sem conta". As sete exceções declaradas estão em §Divergências D-1 e D-2.
- **RN-29 é literal e fechada**: o único toast desta feature é "SALVO NA AGENDA 📅", 2200 ms, 1 por vez. Não há toast de erro na lista canônica, e nenhum é inventado.
- **W-04, linha "Convidado (link)"**: página standalone **sem header de app**, flyer centralizado em **máx. 480px**, CTAs abaixo, "RN-24 vale igual". W-R1..W-R5 valem como critério.
- **A spec 07 `galera` é a vizinha direta** e o contrato é consumido como está: o `codigo` e o `nivelDoLink` como dado da festa, a tabela de RN-22 como valor puro em `lib/features/galera/domain/` (explicitamente colocada lá "para que a spec 09 possa traduzi-la em security rules sem arrastar UI"), e a tradução nível → papel de `GAL-20`.
- **A spec 04 `home` é o consumidor que já existe e está mergeado**: `FestaRepository.observarFestas()` devolve `Stream<List<ResumoDeFesta>>`, com `confirmados`/`pendentes` como **campos** de `ResumoDeFesta`. O lado produtor desta spec tem de encaixar nesse contrato sem alterá-lo.
- **`core/calculo` já decidiu** que pessoa nomeada **não entra com cabeça** no cálculo de quantidades (as cabeças vêm dos steppers H/M/C de RN-01, que cobrem os confirmados). Consequência a não "corrigir" adiante: confirmar presença **não** muda o total nem o "~R$ X" do flyer.

---

## Deferred Ideas

Ideias que apareceram no recorte desta feature e que **não** entram aqui. Registradas para não se perderem.

- **Preferências declaradas pelo convidado** (dieta / bebida) — a spec 07 (A-05) delegou "cada um edita as próprias" de UC-11 a esta spec, e T-08 não desenha controle nenhum. Declinado (D-4). Precisa de desenho de tela antes de virar spec; até lá, a `Pessoa` do convidado nasce com os dois campos não declarados, exatamente como a Duda.
- **Notificação real ao anfitrião** (push FCM, e-mail ou mensagem no WhatsApp) — hoje o aviso é a escrita realtime. Exige token, permissão de navegador, ciclo de vida e uma superfície de aviso que nenhuma tela da spec-fonte desenha.
- **Desfazer um RSVP duplicado / remover pessoa da festa** — a spec 07 (A-04) já declarou que remoção não existe, e AD-026 aceitou a duplicação por limpeza de navegador como custo. Uma "fusão de pessoas duplicadas" seria feature própria, com tela própria.
- **Converter convidado em usuário com conta** ("agora crie sua conta para ver seus rolês") — proibido no MVP pelo aceite de UC-08, e sem tela na spec-fonte.
- **Rate limit / abuso do link** — aceito sem limite por AD-026 (A-23). Se o produto for a público, revisar junto com a mesma ressalva de exposição que AD-024 e AD-025 já carregam.
- **Ajuste de item pelo lado do convidado** (quantidade e preço, que RN-22 autoriza ao CONVIDADO) — as rules permitem, a tela desta spec não oferece. Quando a spec 06 ganhar caminho para quem não tem conta, o requisito já está aberto do lado do servidor (D-7).
- **Escolher item já com dono / dividir um item entre duas pessoas** — exigiria aritmética de split por item que RN-20 não define. Fora do MVP.
- **Prévia rica do link no WhatsApp** (Open Graph com o flyer) — pertence ao Hosting e à spec 08, que é quem manda o link; aqui só o título da aba foi decidido (A-25).
