# Custos & acerto — Specification

**ID prefix:** `CUST` · **Porte:** **Grande** (ver §Porte)
**Design:** `.specs/features/custos/design.md` ✅
**Tasks:** `.specs/features/custos/tasks.md` — pendente
**Context:** `.specs/features/custos/context.md`
**Spec-fonte:** T-09 (`04-telas-ux.md`, as **duas faces**) · W-04 linha "Custos & acerto" + W-R1..W-R5 (`06-telas-web.md`) · UC-19, UC-20, UC-21, UC-22, UC-23 (`05-casos-de-uso.md`) · **RN-19** (origem, estado de UI) · RN-14, RN-15, RN-16, RN-17, RN-18, RN-20 (consumo) · RN-13, RN-22, RN-29 (consumo) · arquivo 01 §6
**Roadmap:** `.specs/ROADMAP.md` — spec 10, marco **M3** · fecha **G6**
**Decisões ativas herdadas:** AD-001..AD-028 · **AD-027 e AD-028 fundam esta spec** (despesa não se cria à mão; cobrança é aviso + estado, sem Pix real) · **AD-009** (dinheiro arredonda uma única vez, na formatação) · **AD-008** (entidades em `core/calculo/dominio/`) · **AD-003** (a aba `custos` já existe em `/roles/:festaId/custos`) · **AD-016** (porta de dados; Firestore no M2) · **AD-022** (contadores são dado da festa) · **AD-024** (a despesa do pedido chega pronta) · **AD-026** (o convidado mantém acesso depois da festa) · **AD-005** (falha vai para o `AppLogger`) · **AD-013** (revestimento do shell)
**Depende de:** spec 02 `calculo` (RN-14..RN-18 e RN-20 já implementados e verdes), spec 09 `convidado` (produz a contribuição de RN-20 e é dona da transação de RSVP), spec 06 `lista` (produz a `Despesa` do pedido, AD-024), spec 07 `galera` (RN-22 como regra de domínio), spec 04 `home` (a porta `FestaRepository` e o atalho "💸 VER O ACERTO DA FESTA →")

## Problem Statement

O BORA promete "a conta do rolê, resolvida" e, até esta spec, resolve tudo menos a conta: o anfitrião monta, chama a galera, o convidado marca o que leva — e ninguém nunca vê quem deve quanto a quem. **T-09 é onde a promessa fecha**, e é o marco M3 inteiro.

O risco desta tela não é layout, é aritmética. Ela mexe em dinheiro em seis lugares — total da festa, cota justa, contribuição por pessoa, saldo, split de despesa e cada linha de transferência — e **todos os seis já existem, implementados e testados, em `core/calculo`** (`cotaPorAdulto`, `contribuicoesPorPessoa`, `calcularSaldos`, `calcularRacha`, `splitIgualitario`, `progressoDeQuitacao`, `MoneyFormatter`). Nenhum deles nasce aqui. O que nasce aqui é **RN-19** (o meio de pagamento, que é estado de UI) e a **persistência da quitação e da cobrança** — o único dado que a camada de cálculo não pode inventar sozinha, porque depende de alguém apertar um botão.

O segundo risco é que T-09 descreve **duas faces** com headers, seções e CTAs diferentes ("Acerto (pós-festa)" e "Custos da festa") e não diz como se navega entre elas, nem quando cada uma aparece — enquanto a AD-003 dá **uma** aba `custos`. A spec resolve isso sem inventar controle nem copy: a face é o momento da festa (A-01, A-02).

## Goals

- [ ] A aba `custos` renderiza as **duas faces** de T-09 com a copy literal, em compacto (T-09) e expandido (W-04), com a face escolhida pelo momento da festa.
- [ ] **Teste A de RN-16 reproduzido na tela**: total R$ 320, cota R$ 80, e as linhas **LÉO→VOCÊ R$ 80 · BIA→VOCÊ R$ 40 · BIA→ANA R$ 40**, nessa ordem.
- [ ] **Teste B de RN-16 reproduzido na tela**: total R$ 380, cota R$ 95, e as linhas **LÉO→RAFA R$ 35 · BIA→RAFA R$ 70 · BIA→ANA R$ 25**, nessa ordem.
- [ ] Soma paga = soma recebida (aceite de UC-20) e **linha paga nunca é cobrada** (aceite de UC-23), afirmados na tela.
- [ ] Marcar pago move a barra verde e o label "N de M quitados · R$ X de R$ Y" (RN-18); todas pagas → 100%.
- [ ] O segmented PIX / CARTÃO / DINHEIRO de RN-19 nasce aqui, com default PIX, e vira a etiqueta das linhas.
- [ ] Quitação e cobrança **sobrevivem ao recálculo**: despesa nova depois do acerto começado não apaga o que já foi quitado nem congela o acerto.
- [ ] **Nenhuma fórmula de RN-13..RN-20 existe em `lib/features/custos/`** — varredura automatizada.

---

## Out of Scope

Explicitamente excluído. Documentado para impedir alargamento.

| Item | Razão |
|---|---|
| **Criar, editar ou apagar despesa à mão ("+ DESPESA")** | **AD-027** (2026-08-27). No MVP a `Despesa` nasce de três fontes que já existem — "EU LEVO" do convidado (RN-20), o pedido por delivery (RN-27 / AD-024) e o que o anfitrião assume na lista. **UC-19 é só leitura**, exatamente como a spec-fonte o escreve, e T-09 não ganha botão de criação. A lacuna (uber, gás, aluguel de churrasqueira) está declarada em A-20, não corrigida aqui. |
| Chave Pix, BR Code, Pix copia-e-cola, deep link de banco, conciliação bancária | **AD-028**. "COBRAR NO PIX 📲" é aviso + mudança de estado; PIX / CARTÃO / DINHEIRO é **etiqueta**, não meio de execução. Quem marca PAGO ✓ **declara**, não comprova. |
| A lista — modos PLANEJAR/COMPRAR, corredores, overrides, sheet de pedido, overlay "PEDIDO A CAMINHO!" | Spec 06 `lista` (T-04 · UC-05, UC-06, UC-14..UC-16 · RN-11, RN-12, RN-27). Esta spec **recebe** a `Despesa` que o pedido produz (LIST-27) e não a cria. |
| O RSVP, o toggle "EU LEVO" ⇄ "VOCÊ LEVA ✓" e a transação que os grava | Spec 09 `convidado` (T-08 · UC-08..UC-10 · RN-24, RN-28). Ela **produz** a contribuição de RN-20; esta spec só a exibe. |
| Pessoas, papéis, preferências, nível do link, a tabela de RN-22 como regra de domínio | Spec 07 `galera` (T-05 · UC-11..UC-13 · RN-21, RN-22, RN-23). Aqui RN-22 é **consumida** como permissão por ação (CUST-25, CUST-26). |
| A mensagem de convite, o grupo do WhatsApp e as enquetes | Spec 08 `convite` (T-06, T-07 · UC-07, UC-17, UC-18 · RN-25, RN-26, RN-26b). "LEMBRAR TODO MUNDO 📲" **não** cria grupo, não posta e não abre o WhatsApp (A-15). |
| O atalho "💸 VER O ACERTO DA FESTA →" | Já entregue pela spec 04 `home` (HOME-10), onde RN-28 o coloca. Esta spec é o **destino** dele, não a origem (D-1). |
| A transição da festa para `passada` como ação do usuário ("ROLÊ SALVO ✊") | UC-24 é da spec 04 `home`. Esta spec **lê** o momento da festa e nunca o altera (A-02). |
| Push notification, e-mail ou WhatsApp para o devedor | Precedente já fixado por `convidado` (A-13): o canal do MVP é a **escrita realtime**. FCM exigiria token, permissão de navegador e uma superfície de aviso que nenhuma tela da spec-fonte desenha (A-14). |
| Recibo, comprovante, anexo de imagem, histórico de cobranças enviadas | Nenhuma tela da spec-fonte desenha qualquer um deles, e AD-028 já declarou que o app **não intermedeia pagamento**. |
| Qualquer alteração em `core/calculo` | RN-14..RN-18 e RN-20 estão implementadas, verdes e verificadas. Esta spec **consome**. A premissa A-16 daquela camada é fechada **sem** mudá-la (A-09). |

---

## Fronteira de arquivos

| Pode tocar | Não pode tocar |
|---|---|
| `lib/features/custos/**` | `lib/core/calculo/**` — a camada está fechada (A-09) |
| `test/features/custos/**` | `lib/core/design_system/**` · `lib/core/routing/**` |
| `lib/core/di/injector.dart` — **só** registro dos próprios | `lib/features/{home,montar,lista,galera,convite,convidado}/**` |
| `firestore.rules` — **só acrescentar** as regras de despesa e linha de acerto | `.specs/{STATE,ROADMAP,LESSONS}.md`, `.specs/lessons.json` |
| `test/fixtures/**` — **só** acrescentar as fixtures dos Testes A e B | qualquer teste existente — a baseline não pode ser enfraquecida nem apagada |

---

## Assumptions & Open Questions

O ROADMAP marcou **Discuss** para esta spec, e a zona cinzenta **G6** foi levada ao usuário e fechada em duas decisões — **AD-027** (G6a: despesa não se cria à mão) e **AD-028** (G6b: cobrança é aviso + estado), ambas de 2026-08-27. Todas as demais ambiguidades foram resolvidas pelo agente e estão registradas abaixo com default escolhido e racional; nenhuma fica silenciosamente em aberto. As mesmas entradas estão em `context.md`.

| # | Ambiguidade | Default escolhido | Racional | Confirmado? |
|---|---|---|---|---|
| A-01 | **As duas faces de T-09.** A fonte descreve "Acerto (pós-festa)" e "Custos da festa" com headers, seções e CTAs diferentes, mas não diz como se navega entre elas nem quando cada uma aparece — e a **AD-003 dá uma única aba `custos`**. *(É a ambiguidade estrutural desta spec.)* | **Uma rota, duas faces mutuamente exclusivas, sem controle novo.** A aba `/roles/:festaId/custos` renderiza **CUSTOS DA FESTA** enquanto a festa não terminou e **ACERTO DO ROLÊ** a partir daí (A-02). Não há segmented de face, não há segunda rota, não há botão de troca | Um segmented de face exigiria dois rótulos que a spec-fonte não escreve, num produto onde a copy é literal — o mesmo erro que `galera` (A-07) e `lista` (A-07) já recusaram. Duas rotas contrariariam a AD-003, que fixou quatro abas permanentes. E o momento **já é a chave que a própria T-09 usa**: ela chama a primeira face de "(pós-festa)". As duas faces leem o mesmo dado (`Despesa` + contribuições) e diferem só em **apresentação** — a face CUSTOS agrupa por despesa ("quem adiantou"), a face ACERTO agrupa por pessoa ("quem levou o quê") | n |
| A-02 | **O que define "pós-festa".** A data passou? O anfitrião marca? Nenhuma tela da spec-fonte tem controle de "encerrar rolê", e `StatusDaFesta` só tem `chegando` e `passada` | **O fim previsto, ou o status, o que vier primeiro:** a face ACERTO vale quando `festa.status == StatusDaFesta.passada` **ou** quando o instante atual é igual ou posterior a `data/hora de início + duração` (a duração de RN-02). O relógio é **injetado**, nunca `DateTime.now()` dentro de widget | O status sozinho não serve: **nenhuma spec anterior produz a transição** (a spec 04 declarou que a fixture já nasce com festas passadas, A-04 de lá), e a face ACERTO — que carrega o Teste A, aceite do M3 — ficaria inalcançável. O relógio sozinho ignoraria o dado que já existe. A união dos dois torna as duas faces alcançáveis hoje e continua correta quando alguma spec ganhar "ROLÊ SALVO ✊". Relógio injetado é o que torna a fronteira testável sem esperar | n |
| A-03 | **Para onde vai o atalho "💸 VER O ACERTO DA FESTA →"** da Home, que por RN-28 aparece **antes** da festa | Para a aba `custos` da festa. A face que ele abre é a **do momento** — CUSTOS DA FESTA antes do fim, ACERTO DO ROLÊ depois | É o único destino que existe (AD-003), e a spec 04 já o entregou apontando para a festa. O rótulo prometer "ACERTO" e abrir "CUSTOS DA FESTA" é **divergência declarada** — ver D-1 —, não bug: as duas faces são o mesmo acerto em momentos diferentes, e a face CUSTOS já mostra "QUEM PAGA QUEM" | n |
| A-04 | **Quem vê a aba.** UC-20 diz "todos os confirmados"; RN-22 dá a SÓ VÊ apenas "vê a festa e confirma presença" | **Leitura liberada a todo participante confirmado, em qualquer papel** — anfitrião, co-anfitrião, convidado e só-vê. A aba inteira é leitura; o que muda por papel é **o que se pode apertar** (A-05, A-12) | UC-20 é explícito no ator ("todos os confirmados") e o valor do produto é justamente todo mundo ver a mesma conta — "é isso que evita a treta". RN-22 restringe **escrita**, não leitura: "vê a festa" inclui a conta da festa. Esconder o acerto de quem deve dinheiro seria o oposto da promessa | n |
| A-05 | **Quem marca PAGO ✓.** UC-22 diz "anfitrião/co-anfitrião (ou o próprio pagador)" — e o credor, que é quem sabe se o dinheiro chegou? | **Anfitrião, co-anfitrião ou o `de` da linha (o devedor).** O credor (`para`) **não** marca | O literal de UC-22 é "o próprio pagador", e AD-028 já fixou que marcar é **declarar, não comprovar** — quem declara é quem diz ter pago. Dar a marcação ao credor inverteria o sentido da declaração e criaria um segundo caminho de escrita que nenhuma copy da tela distingue. Permanece viável trocar depois: é uma linha de permissão | n |
| A-06 | **Desfazer.** UC-22 A1 dá o toggle do **pago**; T-09 escreve "COBRAR NO PIX" ⇄ "COBRADO ✓" com o mesmo símbolo, mas ninguém diz se cobrança desfaz | **PAGO ✓ desfaz** (UC-22 A1, literal, volta a PENDENTE). **COBRADO ✓ não desfaz** — é registro de um aviso já enviado | Desfazer um aviso não desfaz o aviso: a mensagem já chegou no devedor. O precedente do produto é RN-25, onde o chip do grupo criado é declarado "**irreversível na UI**" pelo mesmo motivo. O ⇄ de T-09 marca a transição de estado, não a promessa de reversibilidade — e a única reversão que a spec-fonte escreve em texto é a de UC-22 A1 | n |
| A-07 | **Cobrado e pago são o mesmo estado?** RN-18 dá **um** par por linha ("PENDENTE ⇄ PAGO ✓ (ou COBRADO ✓ no acerto)"), enquanto UC-23 exige que sejam distintos ("linhas pagas nunca são cobradas") e AD-028 diz que cobrar "atualiza o progresso de RN-18" | **Duas flags por linha, persistidas: `paga` e `cobrada`.** Só `paga` alimenta `progressoDeQuitacao` e a barra verde. `cobrada` é registro do aviso e **não** enche a barra. `paga == true` blinda a linha contra cobrança e lembrete | Uma flag só torna UC-23 sem sentido: depois de um toque em "COBRAR PENDENTES", nada estaria pendente e "linhas pagas nunca são cobradas" não teria o que afirmar. E encher a barra verde apertando "cobrar" faria a tela declarar quitação que ninguém pagou — exatamente a mentira que AD-024 já aceitou uma vez e que aqui não precisa acontecer. **Leitura estreita e declarada de AD-028**: "o progresso de RN-18 atualiza" é lido como "a linha muda de estado e a tela reflete", não como "cobrança conta como quitação". **Divergência declarada** — ver D-4 | n |
| A-08 | **Reentrância: despesa nova depois do acerto começado.** Um convidado marca "EU LEVO" quando metade das linhas já está paga; `calcularRacha` regenera as linhas. O que acontece com o que já foi quitado? *(É a ambiguidade de maior risco desta spec.)* | **O acerto é sempre derivado, nunca congelado**, e a marcação é guardada por **par `(de, para)`**, não por posição nem por identidade de linha. Depois de cada recálculo: **(a)** par que continua existindo e cujo valor **não aumentou** mantém `paga` e `cobrada`; **(b)** par cujo valor **aumentou** volta a PENDENTE e perde `cobrada` — o combinado mudou e a diferença precisa ser cobrada de novo; **(c)** par que sumiu do resultado perde o registro; **(d)** par novo nasce PENDENTE. O progresso é **recomputado** das linhas resultantes, nunca acumulado | Congelar o acerto tornaria a contribuição de RN-20 invisível depois do primeiro pagamento — e RN-20 existe justamente para descontar o que a pessoa levou. Guardar por par é o que sobrevive à regeneração: `calcularRacha` produz linhas por `(de, para)` e a ordem de entrada é estável (A-14 de `calculo`). O corte em "valor aumentou" é o único que não engana ninguém: valor menor já foi coberto com folga (o app não movimenta dinheiro, então sobra é entre as pessoas), valor maior deixaria dívida se passando por quitada. Progresso derivado, e não contador, é o que impede a barra de divergir do que está na tela | n |
| A-09 | **Estado vazio e a premissa A-16 de `calculo`.** Sem nenhuma linha, `progressoDeQuitacao` devolve `fracao = 1.0` — **barra cheia** numa festa onde ninguém pagou nada | **A tela nunca renderiza a barra com zero linhas.** Sem despesa e sem contribuição, a face cai num **estado vazio próprio**: card-herói com "TOTAL DA FESTA" R$ 0 e a linha de cota, a dica literal, e **nenhuma** seção, **nenhuma** barra e **nenhum** CTA de cobrança. Logo o `1.0` de A-16 **nunca é exibido**, e a premissa fica fechada **sem alterar `core/calculo`** — a camada continua correta ("nada pendente"), e a decisão de tela é não perguntar | `0.0` seria igualmente defensável na camada e igualmente errado na tela: barra vazia numa festa sem custo também mente, só na direção oposta. A saída que não mente é não pintar barra nenhuma quando não há nada para quitar — e ela custa zero mudança numa camada com 344 testes verdes e Verifier em PASS. **Isto fecha a premissa A-16 de `.specs/features/calculo/spec.md`: nenhuma mudança é exigida naquela camada** | n |
| A-10 | **Há despesas, mas ninguém deve nada** (todo mundo NO ZERO) — `calcularRacha` devolve lista vazia com total > 0 | O card-herói, a dica, "DESPESAS · QUEM ADIANTOU" e "QUEM LEVOU O QUÊ" renderizam normalmente (com as tags **NO ZERO** de RN-15); **"QUEM PAGA QUEM", a barra de progresso e o CTA de cobrança são omitidos** — não há linha, não há o que quitar, não há quem cobrar. Nenhuma copy nova | Omitir é a única saída que não inventa texto: RN-29 não tem toast para o caso e T-09 não desenha estado "acerto fechado". A informação já está na tela — quatro tags NO ZERO dizem exatamente isso, com copy literal de RN-15 | n |
| A-11 | **O meio de pagamento é global ou por linha?** RN-19 diz "o selecionado vira **a etiqueta das linhas**", no plural | **Global por festa**, persistido com a festa, default **PIX**, seleção única (aceite de UC-21). Uma escolha etiqueta **todas** as linhas | T-09 desenha **um** bloco "MEIO DE PAGAMENTO" acima de "QUEM PAGA QUEM", não um segmented por linha; e o plural de RN-19 é literal. Por linha exigiria N segmenteds que a fonte não desenha. Persistir na festa é o que faz W-R1 valer — a escolha é a mesma no web e no mobile, para todo mundo | n |
| A-12 | **Quem troca o meio de pagamento.** UC-21 dá o ator como "quem vai pagar" | **Anfitrião ou co-anfitrião.** Devedor e credor veem a etiqueta, não a trocam | Sendo global (A-11), deixar qualquer devedor trocá-la mudaria a etiqueta das linhas de terceiros. RN-22 dá ao co-anfitrião "edita tudo e cobra a galera", que é exatamente esta superfície. "Quem vai pagar" em UC-21 é a persona da narrativa, não uma linha da tabela de permissões | n |
| A-13 | **Os rótulos "NO PIX" mudam quando o segmented muda?** | **Não.** "COBRAR NO PIX 📲", "COBRAR PENDENTES NO PIX 📲" e o toast "COBRANÇA ENVIADA NO PIX 📲" são **literais e fixos**. O que muda com o segmented é **a etiqueta das linhas** | É o que RN-19 escreve: o selecionado vira a etiqueta **das linhas**, e os três textos acima são literais de RN-29 e T-09. Derivar o rótulo do botão exigiria inventar "COBRAR NO CARTÃO 📲" e "COBRAR NO DINHEIRO 📲", que não existem em lugar nenhum da spec-fonte | n |
| A-14 | **O canal da cobrança e da notificação do devedor** (AD-028 diz "o devedor é notificado") | **A escrita realtime**, como em `convidado` A-13: a linha vira COBRADO ✓ para todo mundo que estiver com a tela aberta (W-R1), e o devedor a encontra ao abrir. **Sem push, sem e-mail, sem WhatsApp no MVP** | Nenhuma tela da spec-fonte desenha superfície de notificação, e o precedente já está fixado uma spec antes. FCM exigiria token, permissão de navegador e ciclo de vida que nenhuma spec cobre | n |
| A-15 | **"LEMBRAR TODO MUNDO 📲" muda estado? E qual toast?** RN-29 não tem toast de lembrete de cobrança; o único de lembrete é "LEMBRETE MANDADO NO GRUPO 📲" | **Só avisa; não muda estado nenhum.** Alcança **apenas** os devedores com linha pendente, e usa o toast canônico **"LEMBRETE MANDADO NO GRUPO 📲"**. Não cria grupo, não posta e não abre o WhatsApp | Se o lembrete marcasse COBRADO ✓, o botão por linha "COBRAR NO PIX" de T-09 seria redundante — a fonte os desenha como duas coisas. O toast é o único canônico aplicável e inventar um novo é proibido pela disciplina do produto. O "grupo" da copy é o grupo do BORA (AD-025), não um objeto do WhatsApp — **divergência declarada**, ver D-2 | n |
| A-16 | **A sublinha "levou R$ X · itens"** de "QUEM LEVOU O QUÊ" — a fonte não diz como as descrições são juntadas | Descrições das contribuições da pessoa, **vírgula entre as primeiras e " e " antes da última**; uma só, sem junção. Ex.: "levou R$ 200 · carnes e carvão" | Reproduz o literal de RN-16 ("VOCÊ 200 (carnes+carvão)") em texto corrido e reusa a regra de junção que `convidado` (A-18) já fixou a partir do literal de T-08. Duas specs com a mesma regra de junção é consistência, não coincidência | n |
| A-17 | **Quem aparece no acerto, e por quanto se divide.** RN-14 divide por "adultos participantes" (steppers H/M de RN-01), mas o acerto lista **pessoas nomeadas** — e `calculo` (A-05) já decidiu que os dois conjuntos não coincidem | **A cota divide por `adultos` (RN-14, literal, criança fora) e as seções listam as pessoas nomeadas.** A diferença — a parte dos "extras sem app" — **não vira linha nem cobrança**: ninguém sem nome é cobrado, e um credor pode ficar com crédito não coberto | Trocar o divisor para "adultos nomeados" contrariaria RN-14 e a decisão já testada de `calculo`. Inventar uma linha "EXTRAS → VOCÊ" seria cobrar um fantasma, com copy que não existe. A consequência é afirmável e continua honrando UC-20 (**entre as linhas geradas**, soma paga = soma recebida). Nos Testes A e B os dois conjuntos coincidem (4 e 4), então o aceite do M3 não depende disto. **Divergência declarada** — ver D-3 | n |
| A-18 | **A ordem das linhas de "QUEM PAGA QUEM"** | **A ordem em que `calcularRacha` devolve** — a ordem de entrada dos participantes. A tela **não reordena**, nem por valor, nem por nome, nem por status | `calculo` A-14 provou que a ordem é comportamento observável: reordenar por valor produziria linhas diferentes no Teste B. Uma tela que reordena para "ficar bonito" quebra o aceite do M3 sem quebrar teste nenhum da camada | **y** (provado pelo Teste B) |
| A-19 | **Onde vivem `cobrada` e a marcação por par** — `LinhaDeAcerto` tem `de`, `para`, `valor` e `paga`, e não tem `cobrada` | **Estado desta feature**, persistido com a festa e chaveado por `(de, para)`. **`core/calculo` não muda** | A camada é Dart puro, fechada e verificada; acrescentar campo nela por causa de um botão de tela inverteria a dependência. A chave por par é o que a reentrância (A-08) exige de qualquer jeito, então guardar `paga` e `cobrada` juntas no mesmo registro é a forma mínima | n |
| A-20 | **Gasto fora da lista** — uber, gás, aluguel de churrasqueira: não têm onde entrar | **Não entram.** **AD-027**: no MVP despesa não se cria à mão, e as três fontes existentes (EU LEVO, pedido, o que o anfitrião assume) são as únicas. É **lacuna declarada**, candidata a spec própria | Decisão do usuário em 2026-08-27, com o trade-off escrito na própria AD: nenhum arquivo da spec-fonte desenha tela de criação de despesa, e inventá-la seria layout e copy nossos. Registrado aqui como assumption, não como requisito | **y** (AD-027) |
| A-21 | **Rate limit da cobrança** | **Nenhum.** O limite é estrutural: linha marcada não recebe cobrança nem lembrete (CUST-18), e o CTA fica inerte sem pendentes (CUST-19) | AD-028 tirou o Pix real do caminho, então cobrar não custa nada nem sai do BORA; um contador de requisições seria infraestrutura sem risco a mitigar. Precedente de `convidado` A-23: o limite estrutural é mais forte que o numérico | n |
| A-22 | **Identidade da pessoa na tela** — `SaldoDePessoa.pessoa` e `Despesa.quemPagou` são **nomes**, não ids (A-24 de `calculo`) | A tela usa o **nome** como identidade, e o avatar/inicial vem do mesmo componente e da mesma cor que a Galera usa. Duas pessoas com o mesmo nome são a mesma linha no acerto | É o contrato que a camada já entrega e que os Testes A e B usam ("VOCÊ", "ANA", "LÉO", "BIA"). Homônimo é consequência aceita de `convidado` A-04, que já declarou que dois dispositivos são duas pessoas com o mesmo nome | n |

**Open questions:** nenhuma — todas resolvidas com o usuário (G6 → AD-027 e AD-028) ou registradas acima.

---

## Varredura de dimensões implícitas (porte Grande — gate completo, todas as nove)

| Dimensão | Cobertura |
|---|---|
| **Input validation & bounds** | **CUST-22** — o segmented de RN-19 aceita **exatamente** três valores (PIX, CARTÃO, DINHEIRO), seleção única, default PIX; valor desconhecido vindo do dado persistido cai em PIX. **CUST-33** — total 0 e `adultos == 0` renderizam R$ 0, nunca `NaN`, `Infinity` nem negativo (a camada já garante, CALC-19). **Campo de texto livre: `N/A because`** AD-027 removeu a criação de despesa, que era a única entrada de valor da tela; o resto da superfície é toggle e segmented. |
| **Failure / partial-failure states** | **CUST-20** — falha ao gravar quitação ou cobrança **não** muda o estado exibido, **não** exibe toast de sucesso, vai para o `AppLogger` (AD-005) e deixa a ação repetível. **CUST-17** — a cobrança em massa é **atômica**: ou todas as linhas pendentes viram COBRADO ✓, ou nenhuma; nunca metade. |
| **Idempotency / retry / duplicate handling** | **CUST-19** — "COBRAR PENDENTES NO PIX 📲" com zero pendentes deixa o CTA **inerte** (não grava, não toasta); tocado duas vezes seguidas, a segunda não encontra pendente e não recobra. **CUST-08** — marcar pago duas vezes é a mesma escrita (a segunda desfaz, por UC-22 A1, e é transição declarada, não duplicata silenciosa). **CUST-27** — recalcular a mesma entrada N vezes devolve o mesmo acerto (CALC-27). |
| **Auth boundaries & rate limits** | **CUST-25** (leitura: todo confirmado, qualquer papel — UC-20 / A-04) e **CUST-26** (escrita por ação: marcar pago = anfitrião, co-anfitrião ou o devedor da linha; cobrar, lembrar e trocar o meio = anfitrião ou co-anfitrião; SÓ VÊ e CONVIDADO não escrevem nada aqui — RN-22 + as rules que `convidado` CVD-31(e) já deixou prontas). A UI **esconde ou desabilita**, e o servidor **recusa** — as duas metades são afirmadas. **Rate limit: nenhum** (A-21) — a cobrança não sai do BORA (AD-028) e o limite é estrutural (linha marcada não é cobrada). |
| **Concurrency / ordering** | **CUST-18/CUST-30** — dois usuários marcando a mesma linha convergem para o mesmo estado (a escrita é por par `(de, para)`, idempotente por valor final); marcar PAGO ✓ numa linha que outro acabou de cobrar **não** apaga o COBRADO ✓, e PAGO ✓ é o estado mais forte na exibição. **CUST-29** — atualização em tempo real (W-R1) enquanto a tela está aberta, sem remontar e sem perder o scroll. **CUST-05/CUST-18** — a ordem das linhas é a de `calcularRacha` e a tela não reordena (A-18). |
| **Data lifecycle / expiry** | **CUST-35** — o acerto **não expira e não congela**: festa `passada` mantém a face ACERTO legível e a quitação mutável (é o que AD-026 promete a quem só tem o link). Nenhuma linha é apagada — linhas são **derivadas** e o registro de quitação/cobrança morre junto com o par que o originou (A-08 c). **TTL: `N/A because`** nada aqui tem prazo — o acerto é o registro final da festa. |
| **Observability** | **CUST-20** — falha de gravação de quitação, falha da cobrança individual e em massa, falha do lembrete e recusa por papel vão para o `AppLogger` (AD-005) com o `festaId` e o par `(de, para)` da linha. |
| **External-dependency failure** | **CUST-20** — Firestore / Function indisponível: nenhum estado muda, nenhum toast de sucesso aparece, a falha é visível e a ação é repetível (precedente `galera` A-07 e `convidado` A-13). O único canal de notificação é a própria escrita (A-14), então **não há segunda dependência externa a cair**. |
| **State-transition integrity** | **CUST-16/CUST-18/CUST-28** — a máquina de estado da linha é fechada e explícita: `PENDENTE → COBRADO ✓` (cobrança, irreversível — A-06), `PENDENTE → PAGO ✓` e `COBRADO ✓ → PAGO ✓` (quitação), `PAGO ✓ → PENDENTE` (desfazer, UC-22 A1, que também limpa `cobrada`), e **`PAGO ✓` nunca recebe cobrança nem lembrete** (aceite de UC-23). O recálculo aplica as quatro regras (a)–(d) de A-08 e nunca deixa uma linha em estado que não seja um destes três. |

Nenhuma dimensão ficou em branco. As duas resolvidas como `N/A because` são a validação de texto livre (AD-027 removeu a superfície) e o TTL (o acerto é registro final).

---

## User Stories

### P1: A face CUSTOS DA FESTA ⭐ MVP

**User Story**: Como anfitrião, quero ver numa tela só quanto a festa custou, quanto cabe a cada adulto, quem adiantou o quê e quem paga quem, para não ter que fazer conta no grupo.

**Why P1**: É UC-19 inteiro e a metade "custos" de T-09. Sem ela não existe M3, e é onde o **Teste B de RN-16** aparece na tela.

**Acceptance Criteria**:

1. WHEN a aba `custos` de uma festa que ainda não terminou é aberta THEN o sistema SHALL renderizar a face **CUSTOS DA FESTA**, com header "CUSTOS DA FESTA" em CAIXA ALTA, e **não** SHALL renderizar a face ACERTO DO ROLÊ. *(CUST-01)*
2. WHEN a face CUSTOS renderiza THEN o card-herói escuro SHALL exibir o label "TOTAL DA FESTA", o total formatado por RN-13 e, abaixo, "cota justa R$ {X} / adulto" com `X` vindo de `cotaPorAdulto` — dividido por **adultos**, criança fora (RN-14). *(CUST-02)*
3. WHEN há ao menos uma linha de acerto THEN a barra de progresso verde `#25D366` SHALL renderizar com a fração de `progressoDeQuitacao`, e o label SHALL ser literalmente "{pagas} de {total} quitados · R$ {pago} de R$ {devido}" (RN-18). *(CUST-03)*
4. WHEN há despesas THEN a seção "DESPESAS · QUEM ADIANTOU" SHALL listar uma linha por `Despesa`, com emoji, descrição, a sublinha "{quemPagou} pagou · split R$ {valorPorAdulto} × {adultos}" vinda de `splitIgualitario` (RN-17) e o valor à direita. *(CUST-04)*
5. WHEN a seção "QUEM PAGA QUEM" renderiza THEN SHALL exibir **exatamente** as linhas de `calcularRacha`, **na ordem em que ela as devolve**, no formato "{de} → {para} · R$ {valor}", cada uma com a etiqueta do meio de pagamento selecionado (RN-19) e o botão "MARCAR PAGO" ⇄ "PAGO ✓". *(CUST-05)*
6. WHEN a festa tem as despesas do **Teste B de RN-16** (Rafa 200, Ana 120, Léo 60, Bia 0, 4 adultos) THEN a tela SHALL exibir total **"R$ 380"**, cota **"R$ 95"** e exatamente três linhas, nesta ordem: **"LÉO → RAFA · R$ 35"**, **"BIA → RAFA · R$ 70"**, **"BIA → ANA · R$ 25"**. *(CUST-06)*
7. WHEN qualquer valor monetário é exibido THEN SHALL vir de `core/calculo` já formatado por RN-13 (`R$` + inteiro, pt-BR, sem centavos), e **nenhum arquivo de `lib/features/custos/` SHALL conter aritmética de RN-13, RN-14, RN-15, RN-16, RN-17, RN-18 ou RN-20**. *(CUST-07)*
8. WHEN a tela precisa de total, cota, contribuição, saldo, split, linhas ou progresso THEN SHALL obtê-los de `package:bora/core/calculo/calculo.dart` (`cotaPorAdulto`, `contribuicoesPorPessoa`, `calcularSaldos`, `calcularRacha`, `splitIgualitario`, `progressoDeQuitacao`, `MoneyFormatter`), sem importar arquivo interno da camada. *(CUST-07)*

**Independent Test**: montar a festa com a fixture do Teste B e afirmar, sobre a árvore renderizada: o header, o label e o valor do herói, a linha da cota, cada sublinha de despesa com o split, e as três linhas de acerto **na ordem**, com os três valores literais. Uma varredura afirma que nenhum arquivo da feature contém as fórmulas.

---

### P1: Marcar pago e ver o progresso andar ⭐ MVP

**User Story**: Como anfitrião ou como quem deve, quero marcar uma linha como paga e ver a barra andar, para saber o que ainda falta sem perguntar a ninguém.

**Why P1**: É UC-22 inteiro e RN-18. É o único dado desta tela que a camada de cálculo não consegue produzir sozinha.

**Acceptance Criteria**:

1. WHEN "MARCAR PAGO" é acionado numa linha pendente THEN o botão SHALL virar "PAGO ✓" verde, a linha SHALL ficar marcada e o estado SHALL persistir com a festa. *(CUST-08)*
2. WHEN "PAGO ✓" é acionado de novo THEN a linha SHALL voltar a PENDENTE (UC-22 A1) e SHALL perder também o registro de cobrança. *(CUST-08)*
3. WHEN uma linha muda de estado THEN a barra e o label "N de M quitados · R$ X de R$ Y" SHALL atualizar na mesma renderização, recomputados por `progressoDeQuitacao` sobre as linhas atuais — nunca por contador acumulado. *(CUST-09)*
4. WHEN todas as linhas estão pagas THEN o progresso SHALL ser 100% e o label SHALL ler "{M} de {M} quitados · R$ {Y} de R$ {Y}" (aceite de UC-22). *(CUST-09)*
5. WHEN quem está olhando é o anfitrião, um co-anfitrião **ou** o `de` da linha THEN o botão de marcar SHALL estar disponível; WHEN é qualquer outra pessoa — inclusive o credor (`para`) THEN o botão SHALL estar indisponível **e** a escrita SHALL ser recusada pelo servidor. *(CUST-10)*

**Independent Test**: com o Teste B na tela, marcar a primeira linha e afirmar "1 de 3 quitados · R$ 35 de R$ 130"; marcar as três e afirmar 100%; desfazer uma e afirmar a volta; e, com um duplo de sessão para cada papel, afirmar disponibilidade do botão nos três casos permitidos e recusa nos demais, na UI **e** na porta de dados.

---

### P1: A face ACERTO DO ROLÊ ⭐ MVP

**User Story**: Como quem foi na festa, quero ver depois do rolê quanto cada um levou, quem recebe, quem paga e quanto, para acertar sem discussão.

**Why P1**: É a outra metade de T-09, é UC-20 e é onde o **Teste A de RN-16** aparece na tela. Sem ela o M3 não fecha.

**Acceptance Criteria**:

1. WHEN a festa já terminou (A-02) THEN a aba SHALL renderizar a face **ACERTO DO ROLÊ**, com header literal "ACERTO DO ROLÊ", e **não** SHALL renderizar a face CUSTOS DA FESTA. *(CUST-11)*
2. WHEN a face ACERTO renderiza THEN o card-herói escuro SHALL exibir "TOTAL DA FESTA", o total, e a linha literal "cota justa R$ {X} — entre {N} adultos, criança de fora" (RN-14). *(CUST-11)*
3. WHEN a face ACERTO renderiza THEN SHALL exibir a dica literal "💡 Quem levou coisa paga menos — é isso que evita a treta." *(CUST-12)*
4. WHEN a seção "QUEM LEVOU O QUÊ" renderiza THEN SHALL listar uma linha por pessoa nomeada, com avatar, nome, a sublinha "levou R$ {X} · {itens}" (A-16) e a tag de RN-15: **"RECEBE R$ {X}"** quando o saldo é positivo, **"PAGA R$ {X}"** quando negativo e **"NO ZERO"** quando zero. *(CUST-13)*
5. WHEN a festa tem as contribuições do **Teste A de RN-16** (VOCÊ 200, ANA 120, LÉO 0, BIA 0, 4 adultos) THEN a tela SHALL exibir total **"R$ 320"**, cota **"R$ 80"**, as tags **"RECEBE R$ 120"** (VOCÊ), **"RECEBE R$ 40"** (ANA), **"PAGA R$ 80"** (LÉO) e **"PAGA R$ 80"** (BIA), e exatamente três linhas em "QUEM PAGA QUEM", nesta ordem: **"LÉO → VOCÊ · R$ 80"**, **"BIA → VOCÊ · R$ 40"**, **"BIA → ANA · R$ 40"**. *(CUST-14)*
6. WHEN as linhas de "QUEM PAGA QUEM" são somadas THEN a soma dos valores que saem SHALL igualar a soma dos valores que entram (aceite de UC-20), e nenhuma linha SHALL ter valor de até 1 centavo. *(CUST-14)*
7. WHEN a cota é exibida em qualquer das duas faces THEN SHALL ser `total ÷ adultos`, **nunca** dividida pelo total de pessoas — a estimativa "≈ R$ X / cabeça" de T-03 **não** aparece nesta tela. *(CUST-15)*

**Independent Test**: montar a festa com a fixture do Teste A, avançar o relógio injetado para depois do fim previsto, e afirmar header, herói, a linha da cota literal, a dica, as quatro tags e as três linhas com os valores e a ordem. Somar as linhas e afirmar a igualdade paga = recebida.

---

### P1: Cobrar quem não pagou ⭐ MVP

**User Story**: Como anfitrião, quero avisar quem ainda deve — uma pessoa ou todas de uma vez — sem abrir o WhatsApp e sem cobrar quem já pagou.

**Why P1**: É UC-23 inteiro, é a segunda metade de AD-028 e é o que faz o acerto sair do papel.

**Acceptance Criteria**:

1. WHEN "COBRAR NO PIX" é acionado numa linha pendente da face ACERTO THEN a linha SHALL virar "COBRADO ✓", o estado SHALL persistir, o devedor SHALL ver a mudança pela escrita realtime (A-14) e **nenhuma chave Pix, BR Code ou app de banco SHALL ser envolvido** (AD-028). *(CUST-16)*
2. WHEN uma linha está COBRADO ✓ THEN o botão **não** SHALL desfazer a cobrança (A-06); a única volta a PENDENTE é a de UC-22 A1, desfazendo o pago. *(CUST-16)*
3. WHEN "COBRAR PENDENTES NO PIX 📲" é acionado na face CUSTOS THEN SHALL marcar como cobradas **todas e apenas** as linhas ainda não pagas, numa **única transação**, e SHALL exibir o toast literal "COBRANÇA ENVIADA NO PIX 📲" (RN-29, 2200 ms, 1 por vez). *(CUST-17)*
4. WHEN uma linha está PAGO ✓ THEN ela **nunca** SHALL ser alcançada por "COBRAR PENDENTES NO PIX 📲", por "COBRAR NO PIX" nem por "LEMBRAR TODO MUNDO 📲" (aceite de UC-23). *(CUST-18)*
5. WHEN uma linha vira COBRADO ✓ THEN a barra de progresso de RN-18 **não** SHALL avançar — só `paga` conta (A-07). *(CUST-18)*
6. WHEN não há nenhuma linha pendente THEN o CTA de cobrança SHALL ficar **inerte**: nada é gravado, nenhum toast aparece e nenhuma copy nova é exibida. *(CUST-19)*
7. WHEN a gravação da cobrança falha THEN nenhum estado SHALL mudar, **nenhum toast de sucesso** SHALL aparecer, a falha SHALL ir para o `AppLogger` (AD-005) e a ação SHALL continuar repetível. *(CUST-20)*
8. WHEN a cobrança em massa falha no meio THEN **nenhuma** linha SHALL ficar cobrada — a transação é atômica, sem cobrança pela metade. *(CUST-20)*
9. WHEN quem está olhando não é anfitrião nem co-anfitrião THEN os controles de cobrança SHALL estar indisponíveis **e** a escrita SHALL ser recusada pelo servidor (RN-22). *(CUST-21)*

**Independent Test**: com o Teste A na tela, cobrar uma linha e afirmar "COBRADO ✓" e a barra parada; marcar outra como paga, acionar a cobrança em massa e afirmar que a linha paga continua sem cobrança; substituir a porta por um duplo que falha e afirmar ausência de toast, ausência de mudança de estado e presença do registro de log; repetir com um duplo que falha na segunda linha e afirmar que nenhuma ficou cobrada.

---

### P1: O meio de pagamento ⭐ MVP

**User Story**: Como anfitrião, quero dizer se o acerto é no Pix, no cartão ou no dinheiro, para a etiqueta das linhas combinar com o que a galera vai fazer.

**Why P1**: É UC-21 e **RN-19 nasce aqui** — é a única regra de negócio cuja implementação é desta spec.

**Acceptance Criteria**:

1. WHEN a face CUSTOS renderiza THEN SHALL exibir a seção "MEIO DE PAGAMENTO" com o segmented **PIX / CARTÃO / DINHEIRO**, seleção única, com **PIX** selecionado por default (aceite de UC-21). *(CUST-22)*
2. WHEN um meio é selecionado THEN **todas** as linhas de "QUEM PAGA QUEM" SHALL passar a exibir a etiqueta correspondente, e o estado SHALL persistir com a festa — igual no web e no mobile (W-R1). *(CUST-23)*
3. WHEN o meio persistido é desconhecido ou ausente THEN a tela SHALL exibir **PIX**, sem erro. *(CUST-22)*
4. WHEN o meio muda THEN os rótulos "COBRAR NO PIX", "COBRAR PENDENTES NO PIX 📲" e o toast "COBRANÇA ENVIADA NO PIX 📲" SHALL permanecer **literais e inalterados** (A-13). *(CUST-23)*
5. WHEN quem está olhando não é anfitrião nem co-anfitrião THEN o segmented SHALL estar indisponível **e** a escrita SHALL ser recusada pelo servidor (A-12). *(CUST-24)*

**Independent Test**: abrir a face CUSTOS e afirmar PIX ativo; tocar CARTÃO e afirmar a etiqueta das três linhas e os rótulos dos botões inalterados; recarregar a tela e afirmar CARTÃO ainda ativo; com sessão de convidado, afirmar o segmented indisponível e a porta recusando.

---

### P1: Quem vê o quê ⭐ MVP

**User Story**: Como convidado, quero ver a mesma conta que o anfitrião vê, sem poder mexer no que não é meu, para confiar no número sem virar administrador da festa.

**Why P1**: UC-20 dá a leitura a "todos os confirmados" e UC-22/UC-23 restringem a escrita. Sem isso a tela ou esconde a conta de quem deve, ou deixa qualquer um zerar o acerto alheio.

**Acceptance Criteria**:

1. WHEN qualquer participante confirmado abre a aba — anfitrião, co-anfitrião, convidado ou só-vê THEN a tela SHALL renderizar **inteira**, com herói, seções e linhas, em modo leitura (UC-20 / A-04). *(CUST-25)*
2. WHEN o papel não autoriza uma ação THEN o controle correspondente SHALL estar **indisponível na UI** e a escrita correspondente SHALL ser **recusada pela camada de dados**, com a recusa registrada no `AppLogger`. *(CUST-26)*
3. WHEN a matriz de permissões é avaliada THEN SHALL valer: **marcar/desmarcar pago** = anfitrião, co-anfitrião ou o `de` da linha; **cobrar linha**, **cobrar pendentes**, **lembrar todo mundo** e **trocar o meio de pagamento** = anfitrião ou co-anfitrião; **nenhuma escrita** para SÓ VÊ e para convidado que não seja o devedor da linha. *(CUST-26)*

**Independent Test**: um teste parametrizado pelos quatro papéis de RN-22, mais o caso "convidado que é o devedor da linha", afirmando para cada um a lista de controles disponíveis na árvore e o resultado de cada escrita contra a porta.

---

### P1: O acerto é sempre derivado ⭐ MVP

**User Story**: Como convidado que marcou "EU LEVO" depois que o acerto já começou, quero que a conta se ajuste sozinha sem apagar o que já foi pago, para ninguém precisar refazer nada na mão.

**Why P1**: É a ambiguidade de maior risco da spec (A-08) e a fronteira com a spec 09. Sem ela, ou a contribuição de RN-20 fica invisível, ou o acerto mente sobre o que já foi quitado.

**Acceptance Criteria**:

1. WHEN uma `Despesa` ou contribuição nova chega — de "EU LEVO" (RN-20), de um pedido (AD-024) ou do que o anfitrião assume THEN total, cota, saldos, splits e linhas SHALL ser **recalculados** por `core/calculo` a partir do estado atual; nada é congelado no primeiro cálculo. *(CUST-27)*
2. WHEN o acerto é recalculado THEN uma linha cujo par `(de, para)` já existia e cujo valor **não aumentou** SHALL manter os estados `paga` e `cobrada`. *(CUST-28)*
3. WHEN o acerto é recalculado THEN uma linha cujo par já existia e cujo valor **aumentou** SHALL voltar a **PENDENTE** e perder o registro de cobrança. *(CUST-28)*
4. WHEN o acerto é recalculado THEN um par que **desaparece** do resultado SHALL perder o registro, e um par **novo** SHALL nascer PENDENTE. *(CUST-28)*
5. WHEN o acerto é recalculado THEN o progresso SHALL ser recomputado das linhas resultantes, e o label "N de M quitados · R$ X de R$ Y" SHALL refletir o novo M. *(CUST-28)*
6. WHEN qualquer dado da festa muda com a tela aberta THEN a tela SHALL atualizar **sem refresh e sem remontar** (W-R1), preservando a posição de rolagem. *(CUST-29)*
7. WHEN duas pessoas agem sobre a mesma linha ao mesmo tempo THEN o estado final SHALL ser determinístico e igual nas duas telas; marcar PAGO ✓ numa linha recém-cobrada **não** SHALL apagar o COBRADO ✓, e PAGO ✓ SHALL prevalecer na exibição. *(CUST-30)*

**Independent Test**: montar o Teste A, marcar "LÉO → VOCÊ · R$ 80" como paga, injetar uma despesa nova de R$ 40 no nome da BIA e afirmar: as linhas recalculadas, a permanência da marcação nos pares cujo valor não subiu, a volta a PENDENTE dos que subiram, e o novo label de progresso. Repetir o recálculo duas vezes e afirmar resultado idêntico.

---

### P2: A face web

**User Story**: Como anfitrião no computador, quero o total e a cobrança sempre à vista enquanto rolo as despesas, para acertar a conta sem perder o número de vista.

**Why P2**: W-04 é adaptação de layout sobre a mesma lógica — não bloqueia o M3, mas é metade do "um codebase, dois quadros".

**Acceptance Criteria**:

1. WHEN a janela é expandida THEN a tela SHALL usar o grid `1fr / 370px` de W-04: despesas e "QUEM PAGA QUEM" à esquerda; rail direito **sticky** com o card-herói do total, a barra de quitação e o CTA de cobrança (W-R2). *(CUST-31)*
2. WHEN a largura cai abaixo de ~900px THEN o layout SHALL colapsar para o compacto de T-09, com o rodapé-CTA de volta (W-R3), sem perder estado. *(CUST-31)*
3. WHEN qualquer conteúdo é largo demais THEN SHALL rolar dentro do próprio contêiner, e a página **nunca** SHALL rolar horizontalmente (W-R4). *(CUST-32)*
4. WHEN a aba do navegador é lida THEN o título SHALL ser "bora — a conta do rolê" (W-R5). *(CUST-32)*
5. WHEN o mesmo acerto está aberto no web e no compacto THEN toda mutação — pago, cobrado, meio de pagamento — SHALL refletir nos dois em tempo real (W-R1). *(CUST-31)*

**Independent Test**: renderizar em 1180×800 e em 390×820 afirmando a estrutura de cada um, o mesmo conteúdo e o mesmo estado; forçar conteúdo largo e afirmar ausência de rolagem horizontal.

---

### P2: Quando não há nada para acertar

**User Story**: Como anfitrião de uma festa em que ninguém gastou nada ainda, quero uma tela honesta em vez de uma barra verde cheia dizendo que está tudo quitado.

**Why P2**: É o estado que todo mundo vê primeiro, antes de qualquer despesa existir — e é onde a premissa **A-16 de `calculo`** se resolve.

**Acceptance Criteria**:

1. WHEN a festa não tem nenhuma despesa e nenhuma contribuição THEN a face SHALL exibir o card-herói com "TOTAL DA FESTA" **"R$ 0"** e a linha de cota, mais a dica literal — e **não** SHALL renderizar "DESPESAS · QUEM ADIANTOU", "QUEM LEVOU O QUÊ", "QUEM PAGA QUEM", **a barra de progresso** nem o CTA de cobrança. *(CUST-33)*
2. WHEN não há nenhuma linha de acerto THEN a barra de progresso **nunca** SHALL ser renderizada — a tela não exibe o `fracao = 1.0` que `progressoDeQuitacao` devolve nesse caso, e `core/calculo` **não muda** (A-09, fecha a premissa A-16). *(CUST-33)*
3. WHEN `adultos == 0` ou o total é 0 THEN a cota exibida SHALL ser **"R$ 0"** — nunca `NaN`, `Infinity` ou valor negativo. *(CUST-33)*
4. WHEN há despesas mas ninguém deve nada (todos NO ZERO, `calcularRacha` vazia) THEN o herói, a dica, as despesas e "QUEM LEVOU O QUÊ" com as tags "NO ZERO" SHALL renderizar, e "QUEM PAGA QUEM", a barra e o CTA de cobrança SHALL ser **omitidos**, sem copy nova. *(CUST-34)*
5. WHEN a festa já é `passada` THEN o acerto SHALL continuar legível **e** a quitação continuar mutável — o acerto não expira e não congela (AD-026). *(CUST-35)*

**Independent Test**: renderizar as duas faces com festa sem despesa e afirmar a ausência da barra e das três seções; renderizar com despesas que zeram os saldos e afirmar as tags NO ZERO e a ausência de "QUEM PAGA QUEM"; abrir uma festa `passada` e afirmar que marcar pago ainda funciona.

---

### P3: Lembrar todo mundo

**User Story**: Como anfitrião no dia seguinte, quero dar um toque geral em quem ainda não acertou, sem cobrar ninguém individualmente.

**Why P3**: É a variante geral de UC-23 na face ACERTO. A cobrança por linha e a cobrança em massa já entregam o caso de uso; o lembrete é o toque a mais.

**Acceptance Criteria**:

1. WHEN "LEMBRAR TODO MUNDO 📲" é acionado THEN SHALL avisar **apenas** os devedores com linha ainda não paga, **sem alterar estado nenhum** (nenhuma linha vira COBRADO ✓, a barra não se move), e SHALL exibir o toast literal "LEMBRETE MANDADO NO GRUPO 📲" (RN-29). *(CUST-36)*
2. WHEN não há devedor pendente THEN o CTA SHALL ficar **inerte** — nada é enviado e nenhum toast aparece. *(CUST-36)*
3. WHEN o envio do lembrete falha THEN nenhum toast de sucesso SHALL aparecer, a falha SHALL ir para o `AppLogger` e a ação SHALL continuar repetível. *(CUST-37)*

**Independent Test**: com o Teste A, marcar uma linha como paga, acionar o lembrete e afirmar o toast, os destinatários (só os pendentes) e que nenhum estado de linha mudou; com o duplo que falha, afirmar ausência de toast e presença do log.

---

## Edge Cases

- WHEN a festa tem despesas mas nenhuma pessoa nomeada THEN as seções por pessoa SHALL ficar vazias e o herói SHALL continuar exibindo total e cota — sem linha, sem barra, sem cobrança (A-17).
- WHEN o número de adultos é maior que o de pessoas nomeadas THEN a cota SHALL continuar dividindo por **adultos** e a diferença **não** SHALL virar linha de acerto nem cobrança (A-17 / D-3).
- WHEN uma pessoa contribui exatamente com a cota THEN a tag SHALL ser "NO ZERO" e ela **não** SHALL aparecer em nenhuma linha de "QUEM PAGA QUEM".
- WHEN um resíduo de arredondamento produziria uma linha de até 1 centavo THEN a linha **não** SHALL existir (tolerância de RN-16, resolvida na camada de cálculo).
- WHEN o total exibido é somado a partir das despesas THEN SHALL ser o `round` da soma exata, **nunca** a soma dos valores já arredondados (AD-009).
- WHEN a mesma pessoa aparece como credora em duas linhas THEN as duas SHALL ter estado independente — quitar uma não quita a outra.
- WHEN a festa cruza o fim previsto com a tela aberta THEN a face SHALL trocar de CUSTOS para ACERTO na próxima renderização, sem perder o estado de quitação.
- WHEN a leitura da festa falha THEN a tela SHALL exibir estado de falha e a ação de repetir, sem exibir herói com R$ 0 como se fosse dado verdadeiro.

---

## Requirement Traceability

| ID | História | Origem na spec-fonte | Fase | Status |
|---|---|---|---|---|
| CUST-01 | P1-1 AC1 | T-09 (as duas faces) · AD-003 · A-01, A-02 | Tasks | Mapeado |
| CUST-02 | P1-1 AC2 | T-09 (face custos) · **RN-14** | Tasks | Mapeado |
| CUST-03 | P1-1 AC3 | T-09 · **RN-18** | Tasks | Mapeado |
| CUST-04 | P1-1 AC4 | T-09 · **RN-17** · **UC-19** | Tasks | Mapeado |
| CUST-05 | P1-1 AC5 | T-09 · **RN-16** · RN-19 (etiqueta) · A-18 | Tasks | Mapeado |
| CUST-06 | P1-1 AC6 | **RN-16 Teste B** · **UC-19 (aceite)** | Tasks | Mapeado |
| CUST-07 | P1-1 AC7, AC8 | **RN-13** · CLAUDE.md ("nunca duplique uma fórmula na UI") · AD-009 | Tasks | Mapeado |
| CUST-08 | P1-2 AC1, AC2 | **RN-18** · **UC-22** + A1 · A-06 | Tasks | Mapeado |
| CUST-09 | P1-2 AC3, AC4 | **RN-18** · **UC-22 (aceite)** | Tasks | Mapeado |
| CUST-10 | P1-2 AC5 | **UC-22 (ator)** · RN-22 · A-05 | Tasks | Mapeado |
| CUST-11 | P1-3 AC1, AC2 | T-09 (face acerto) · **RN-14** (copy literal) · A-02 | Tasks | Mapeado |
| CUST-12 | P1-3 AC3 | T-09 (dica literal) | Tasks | Mapeado |
| CUST-13 | P1-3 AC4 | T-09 · **RN-15** · A-16 | Tasks | Mapeado |
| CUST-14 | P1-3 AC5, AC6 | **RN-16 Teste A** · **UC-20 (aceite)** | Tasks | Mapeado |
| CUST-15 | P1-3 AC7 | **RN-14** · CLAUDE.md (os dois números coexistem) | Tasks | Mapeado |
| CUST-16 | P1-4 AC1, AC2 | T-09 · **UC-23 (variante)** · **AD-028** · A-06 | Tasks | Mapeado |
| CUST-17 | P1-4 AC3 | T-09 · **UC-23** · **RN-29** (toast) · **AD-028** | Tasks | Mapeado |
| CUST-18 | P1-4 AC4, AC5 | **UC-23 (aceite)** · RN-18 · A-07 | Tasks | Mapeado |
| CUST-19 | P1-4 AC6 | **UC-23 (pré)** · dimensão idempotência · precedente `lista` A-07 | Tasks | Mapeado |
| CUST-20 | P1-4 AC7, AC8 | dimensões failure / external-dependency / observability · AD-005 · A-13, A-14 | Tasks | Mapeado |
| CUST-21 | P1-4 AC9 | **UC-23 (ator)** · RN-22 | Tasks | Mapeado |
| CUST-22 | P1-5 AC1, AC3 | **RN-19** · **UC-21 (aceite)** | Tasks | Mapeado |
| CUST-23 | P1-5 AC2, AC4 | **RN-19** · W-R1 · A-11, A-13 | Tasks | Mapeado |
| CUST-24 | P1-5 AC5 | RN-22 · A-12 | Tasks | Mapeado |
| CUST-25 | P1-6 AC1 | **UC-20 (ator)** · A-04 | Tasks | Mapeado |
| CUST-26 | P1-6 AC2, AC3 | **RN-22** · UC-22, UC-23 · `convidado` CVD-31(e) | Tasks | Mapeado |
| CUST-27 | P1-7 AC1 | **RN-20** · AD-024 · AD-027 · UC-19 | Tasks | Mapeado |
| CUST-28 | P1-7 AC2..AC5 | **RN-16** + **RN-18** · A-08 | Tasks | Mapeado |
| CUST-29 | P1-7 AC6 | **W-R1** · RN-28 (consumo) | Tasks | Mapeado |
| CUST-30 | P1-7 AC7 | dimensão concorrência · A-07 | Tasks | Mapeado |
| CUST-31 | P2-1 AC1, AC2, AC5 | **W-04** (linha "Custos & acerto") · W-R1, W-R2, W-R3 | Tasks | Mapeado |
| CUST-32 | P2-1 AC3, AC4 | **W-R4**, **W-R5** | Tasks | Mapeado |
| CUST-33 | P2-2 AC1..AC3 | **A-09** (fecha A-16 de `calculo`) · CALC-19 | Tasks | Mapeado |
| CUST-34 | P2-2 AC4 | **RN-15** ("NO ZERO") · A-10 | Tasks | Mapeado |
| CUST-35 | P2-2 AC5 | **AD-026** · dimensão data lifecycle | Tasks | Mapeado |
| CUST-36 | P3-1 AC1, AC2 | T-09 (CTA) · **UC-23 (variante)** · **RN-29** · A-15 | Tasks | Mapeado |
| CUST-37 | P3-1 AC3 | dimensões failure / observability · AD-005 | Tasks | Mapeado |

**ID format:** `CUST-NN` · **Status:** Pending → In Design → In Tasks → Implementing → Verified

**Cobertura:** 37 requisitos · **P1: 30 · P2: 5 · P3: 2** · 0 órfãos.

### Cobertura da spec-fonte

| Origem | Requisitos |
|---|---|
| **UC-19** (despesas, só leitura) | CUST-02, CUST-04, CUST-06, CUST-27 |
| **UC-20** (quem paga quem) | CUST-05, CUST-13, CUST-14, CUST-25 |
| **UC-21** (meio de pagamento) | CUST-22, CUST-23, CUST-24 |
| **UC-22** (marcar quitado) | CUST-08, CUST-09, CUST-10 |
| **UC-23** (cobrar pendentes) | CUST-16, CUST-17, CUST-18, CUST-19, CUST-21, CUST-36 |
| **RN-14** (cota justa, consumo) | CUST-02, CUST-11, CUST-15, CUST-33 |
| **RN-15** (saldos, consumo) | CUST-13, CUST-34 |
| **RN-16** (quem paga quem, consumo) | CUST-05, CUST-06, CUST-14, CUST-28 |
| **RN-17** (split de despesa, consumo) | CUST-04 |
| **RN-18** (quitação, consumo) | CUST-03, CUST-08, CUST-09, CUST-18, CUST-28 |
| **RN-19** (meio de pagamento, **origem**) | CUST-05, CUST-22, CUST-23, CUST-24 |
| **RN-20** ("eu levo" desconta, consumo) | CUST-13, CUST-27 |
| RN-13 (formatação) · AD-009 | CUST-07 |
| RN-22 (permissões, consumo) | CUST-10, CUST-21, CUST-24, CUST-25, CUST-26 |
| RN-29 (toasts) | CUST-17, CUST-36 |
| **T-09** (as duas faces, copy literal) | CUST-01..CUST-05, CUST-11..CUST-13, CUST-16, CUST-17, CUST-22 |
| **W-04 + W-R1..W-R5** | CUST-23, CUST-29, CUST-31, CUST-32 |

**O que esta spec deixa para as outras:** nada pendente — é a última do roadmap. O que ela **consome e não pode quebrar**: a contribuição de RN-20 da spec 09, a `Despesa` do pedido da spec 06, a tabela de RN-22 da spec 07, a porta de dados da spec 04 e as sete funções de `core/calculo`.

---

## Porte

**Grande**, como o roadmap previa, e o Discuss confirmou — as duas metades de G6 viraram ADs que **mandaram construir dentro do recorte**, não recortar. O corte estimado é de **~14 tasks**:

1. **Duas faces com estruturas diferentes** (agrupada por despesa × agrupada por pessoa), cada uma com header, herói e CTA próprios, e a regra de momento que escolhe entre elas.
2. **RN-19 nasce aqui** — é a única regra de negócio cuja implementação é desta spec, e ela persiste na festa.
3. **A persistência de quitação e cobrança sobrevivendo ao recálculo** (A-08) é lógica de estado com quatro ramos, cada um com aceite próprio — e é o que separa esta tela de um relatório.
4. **Permissões por ação sobre quatro superfícies de escrita**, com a metade servidora nas rules.
5. **Duas plataformas** (T-09 compacto e W-04 expandido com rail sticky).
6. **É o marco M3 inteiro**: os Testes A e B na tela são o critério verificável do marco, não um teste a mais.

**Design e Tasks formais.**

---

## Divergências encontradas na spec-fonte

| # | Divergência | Resolução |
|---|---|---|
| **D-1** | **O atalho promete o que a face não é.** RN-28 e T-02 fazem aparecer "💸 VER O ACERTO DA FESTA →" na Home **assim que um convidado confirma** — bem antes da festa. Mas T-09 chama a face do acerto de "(pós-festa)" | **A-03**: o atalho abre a aba `custos`, e a face é a do momento — CUSTOS DA FESTA antes do fim, ACERTO DO ROLÊ depois. As duas são o mesmo acerto, e a face CUSTOS já mostra "QUEM PAGA QUEM", então o atalho nunca leva a lugar vazio de conteúdo. O rótulo do atalho fica **literal**, sem variação |
| **D-2** | **O toast do lembrete fala em "grupo".** T-09 dá o CTA "LEMBRAR TODO MUNDO 📲", RN-29 não tem toast para ele, e o único de lembrete é "LEMBRETE MANDADO NO GRUPO 📲" — enquanto AD-028 tira o WhatsApp do caminho da cobrança | **A-15**: usa-se o toast canônico, sem inventar. O "grupo" é o do BORA, que **AD-025** já definiu como estado próprio com os confirmados dentro; o lembrete alcança os devedores pendentes por escrita realtime. Inventar um toast novo violaria a copy literal; deixar o CTA sem toast violaria RN-29 |
| **D-3** | **RN-14 supõe que "adultos participantes" e as pessoas do acerto são o mesmo conjunto** — a copy é "entre 4 adultos, criança de fora". Mas RN-01 conta cabeças pelos steppers H/M/C e `calculo` (A-05) já decidiu que pessoa nomeada **não entra com cabeça**. No estado padrão de RN-30 são 6 adultos e 5 nomeados | **A-17**: a cota divide por `adultos` (literal de RN-14) e as seções listam nomeados. A diferença é a parte dos "extras sem app" e **não vira linha nem cobrança** — ninguém sem nome é cobrado, e um credor pode ficar com crédito não coberto. Nos Testes A e B os conjuntos coincidem (4 e 4), então o aceite do M3 não depende da divergência |
| **D-4** | **Cobrado e pago são o mesmo estado ou dois?** RN-18 dá um par só ("PENDENTE ⇄ PAGO ✓ (ou COBRADO ✓ no acerto)") e AD-028 diz que cobrar "atualiza o progresso de RN-18" — mas UC-23 só faz sentido se forem distintos ("linhas pagas nunca são cobradas") | **A-07**: duas flags, e **só `paga` alimenta a barra**. AD-028 é lida estreitamente — "a linha muda de estado e a tela reflete" —, porque a leitura larga faria a barra verde encher com um toque em "cobrar", declarando quitação que ninguém pagou. É a leitura que preserva o aceite escrito de UC-23 |
| **D-5** | **A face CUSTOS não tem header nomeado.** T-09 escreve o header só da face acerto ("ACERTO DO ROLÊ") e chama a outra de "Custos da festa (feature 6d)" — onde "(feature 6d)" é marca de protótipo, não copy | O header da face é **"CUSTOS DA FESTA"**, em CAIXA ALTA, derivado do próprio rótulo da face em T-09 — não inventado. "(feature 6d)" é descartado como artefato de protótipo, pelo mesmo critério com que o arquivo 04 descarta o "Mapa de etapas" e a spec `convidado` (A-06) descarta o banner roxo |
| **D-6** | **Duas formas para a mesma regra.** A face acerto escreve "cota justa R$ 80 — entre 4 adultos, criança de fora" e a face custos "cota justa R$ 95 / adulto" | Cada face mantém **a sua**, literal. São a mesma `cotaPorAdulto` com apresentação diferente; unificar apagaria copy da spec-fonte sem ganho |

---

## Success Criteria

- [ ] **Teste A de RN-16 renderizado na tela**: R$ 320, cota R$ 80, tags RECEBE R$ 120 / RECEBE R$ 40 / PAGA R$ 80 / PAGA R$ 80, e **LÉO→VOCÊ R$ 80 · BIA→VOCÊ R$ 40 · BIA→ANA R$ 40**, nessa ordem.
- [ ] **Teste B de RN-16 renderizado na tela**: R$ 380, cota R$ 95, e **LÉO→RAFA R$ 35 · BIA→RAFA R$ 70 · BIA→ANA R$ 25**, nessa ordem.
- [ ] Soma paga = soma recebida entre as linhas exibidas (UC-20) e **nenhuma linha paga é alcançada por cobrança ou lembrete** (UC-23).
- [ ] Marcar todas as linhas → progresso 100% com o label literal (UC-22); desfazer volta o número.
- [ ] Segmented com default PIX, seleção única, etiquetando todas as linhas e persistindo (UC-21).
- [ ] Despesa nova depois do acerto começado recalcula as linhas **sem** apagar o que já foi quitado nos pares que não subiram de valor.
- [ ] Festa sem despesa nenhuma **não** exibe barra de progresso — a premissa **A-16 de `calculo` fica fechada sem uma linha de mudança naquela camada**.
- [ ] W-04 funcional: grid `1fr / 370px`, rail sticky, colapso abaixo de ~900px, sem scroll horizontal, estado único com o compacto.
- [ ] **Nenhuma fórmula de RN-13..RN-20 em `lib/features/custos/`** — varredura automatizada verde.
- [ ] `flutter analyze` limpo e a baseline de testes preservada — nenhum teste existente enfraquecido.
- [ ] **Marco M3 fechado**: "a conta do rolê, resolvida" é demonstrável ponta a ponta — montar → convidar → convidado confirma e marca o que leva → acerto na tela.
