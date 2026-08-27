# O convidado (link público) — Specification

**ID prefix:** `CVD` · **Porte:** **Complexo** (ver §Porte)
**Design:** `.specs/features/convidado/design.md` — pendente
**Tasks:** `.specs/features/convidado/tasks.md` — pendente
**Context:** `.specs/features/convidado/context.md`
**Spec-fonte:** T-08 (`04-telas-ux.md`) · W-04 linha "Convidado (link)" + W-R1..W-R5 (`06-telas-web.md`) · UC-08, UC-09, UC-10 (`05-casos-de-uso.md`) · **RN-24**, **RN-28** (origem) · RN-20, RN-22, RN-23 (consumo) · RN-13, RN-29, RN-30 · arquivo 01 §4/§5/§6/§7
**Roadmap:** `.specs/ROADMAP.md` — spec 09, marco M2 · resolve **G5** e fecha **G8**
**Decisões ativas herdadas:** AD-001..AD-028 · **AD-026 funda esta spec** (link perpétuo, papel lido na abertura, identidade = uid anônimo persistido no dispositivo) · **AD-016** (Firestore, Hosting e Functions entram no M2 **com esta spec**) · **AD-017** (`/c/:codigo` passa sempre, com ou sem sessão) · **AD-003** (a rota já existe fora de qualquer shell) · **AD-004** (Firebase emulator-first) · **AD-019** (autenticação em `lib/core/autenticacao/`, atrás de porta) · **AD-022** (contadores são dado da festa) · **AD-005** (observabilidade atrás de `AppLogger`) · **AD-008** (entidades em `core/calculo/dominio/`)
**Depende de:** spec 02 `calculo` (RN-20, RN-13, `Pessoa`, `Festa`), spec 04 `home` (porta `FestaRepository` e o formato do stream de RN-28), spec 06 `lista` (os itens que o convidado assume), spec 07 `galera` (o nível do link, o `codigo` e a tabela de RN-22)

## Problem Statement

`/c/:codigo` é hoje uma rota que existe e não leva a nada. É a rota mais importante do produto: **é a única superfície do BORA que uma pessoa sem conta encontra**, e é ela que sustenta a promessa da capa — "chama a galera por link/WhatsApp — o convidado responde sem baixar nada". Enquanto ela for placeholder, o link que a spec 07 configura e a spec 08 manda no zap termina em nada, e RN-28 — a promessa de tempo real do produto — **não tem produtor**: a Home do anfitrião sabe consumir uma confirmação que ninguém nunca emite.

Esta spec é também onde o projeto **sai da memória**. Até aqui todo dado de festa vive num repositório em memória atrás de porta abstrata (AD-016), porque no M1 não havia nada para transportar entre dois aparelhos. Agora há: o convidado está num navegador, o anfitrião está no app, e a confirmação de um tem de aparecer na tela do outro sem refresh. Firestore, Hosting e Functions entram aqui — e entram **atrás das portas que seis specs já consomem**, sem mudá-las.

E é aqui que nasce o problema que nenhuma spec anterior podia resolver: **como o BORA sabe quem é alguém que não tem conta**. AD-026 respondeu — uid da auth anônima do Firebase, persistido no dispositivo — e essa resposta tem consequências que precisam virar requisito, não nota de rodapé: qualquer portador do código entra, o mesmo aparelho é sempre a mesma pessoa, outro aparelho é outra pessoa, e limpar o navegador duplica o RSVP.

## Goals

- [ ] `bora.app/c/<codigo>` abre o flyer de T-08 **sem conta, sem download e sem cadastro** — o aceite não-negociável de UC-08.
- [ ] Os quatro estados de T-08 (Convite · Escolher o que leva · Confirmado · Não vou) existem em compacto e na adaptação standalone de W-04, com a copy literal da spec-fonte.
- [ ] O convidado ganha identidade sem conta: uid anônimo persistido no dispositivo + um nome pedido **uma vez**, no momento do compromisso.
- [ ] A confirmação produz, **numa escrita só**, a `Pessoa` nomeada e os contadores da festa — e a Home do anfitrião vai de "4 confirmados · 2 pendentes" a "5 confirmados · 1 pendente" sem refresh, expondo o atalho "💸 VER O ACERTO DA FESTA →" (RN-28).
- [ ] O valor dos itens que o convidado assume vira **contribuição dele no acerto** (RN-20), consumindo `core/calculo` — nenhuma fórmula é reescrita aqui.
- [ ] O papel de RN-23 governa o que o convidado vê e o que ele pode escrever, e as **security rules do Firestore** traduzem a tabela de RN-22 para o servidor, capacidade por capacidade.
- [ ] Firestore, Hosting e Functions entram **atrás das portas já consumidas pelas specs 04, 05, 06 e 07**, sem alterar assinatura — o aceite é a suíte existente continuar verde.
- [ ] A deriva **D-5** (contador da Home × nomeados da Galera) fica fechada: quem grava o RSVP grava o contador na mesma escrita, e existe invariante afirmável.
- [ ] O modelo de ameaça de AD-026 está **declarado no produto e coberto por critério**, não escondido.

## Out of Scope

Explicitamente excluído. Documentado para impedir alargamento.

| Item | Razão |
|---|---|
| A tela onde o nível do link é configurado (segmented "QUEM ABRIR O LINK PODE…") | Spec 07 `galera` (T-05 · UC-13 · RN-23). Esta spec **consome** o nível já configurado; não o edita e não o exibe como controle. |
| A tabela de RN-22 como regra de domínio | Spec 07 `galera` (GAL-19). Aqui ela é **traduzida** para security rules; a fonte continua sendo o valor puro que a 07 entrega. |
| A mensagem de convite, o grupo e as enquetes do WhatsApp | Spec 08 `convite` (T-06, T-07 · UC-07, UC-17, UC-18 · RN-25, RN-26, RN-26b). Esta spec entrega o destino do link, não o veículo. |
| A lista do anfitrião — modos PLANEJAR/COMPRAR, corredores, overrides, pedido por delivery | Spec 06 `lista` (T-04 · UC-05, UC-06, UC-14..UC-16 · RN-11, RN-12, RN-27). O convidado **consome** itens que a 06 já modela; não os cria, não os edita em preço nem em quantidade. |
| A tela de acerto — cota, saldos, quem paga quem, cobrança | Spec 10 `custos` (T-09 · UC-19..UC-23 · RN-14..RN-19). Esta spec **produz** a contribuição de RN-20; quem a exibe é a 10. |
| O atalho "💸 VER O ACERTO DA FESTA →" | Já entregue pela spec 04 `home` (HOME-10), onde RN-28 o coloca — na **Home do anfitrião**. Na tela do convidado ele é artefato de protótipo (A-06). |
| Push notification / e-mail / WhatsApp para o anfitrião | A "notificação" de UC-10 é a escrita realtime, que é o que a própria copy de T-08 afirma ("O Rafa já vê você…"). FCM exigiria token, permissão do navegador e uma superfície de aviso que nenhuma tela da spec-fonte desenha (A-13). |
| Preferências do convidado (dieta / bebida) declaradas por ele | **T-08 não desenha nenhum controle de preferência.** A spec 07 (A-05) delegou "cada um edita as próprias" a esta spec, e esta spec **declina** — ver §Divergências D-4. A `Pessoa` do convidado nasce com dieta e bebida **não declaradas**, que é o caso da Duda e que a Galera já sabe renderizar. |
| Editar quantidade ou preço de item pelo lado do convidado | RN-22 dá ao CONVIDADO "marca o que leva e **ajusta a lista**", mas T-08 desenha só o toggle "EU LEVO". O ajuste de lista é a tela da spec 06, alcançada por quem tem conta. As rules **permitem** o que RN-22 manda (CVD-31); a **tela** desta spec não oferece (A-19). |
| Revogar, expirar ou trocar o código do link | **AD-026**: o link é perpétuo. Nenhum controle, em nenhuma das duas pontas. |
| Remover pessoa da festa / desfazer um RSVP duplicado | Spec 07 já declarou (A-04) que não existe remoção. O RSVP duplicado por limpeza de navegador é custo declarado de AD-026, não bug a corrigir aqui. |
| Conta para o convidado ("virar usuário") | RN-24 e o aceite de UC-08 proíbem: nenhuma etapa pede cadastro. Converter convidado em usuário é feature futura, sem tela na spec-fonte. |

---

## Fronteira de arquivos

| Pode tocar | Não pode tocar |
|---|---|
| `lib/features/convidado/**` | `lib/core/calculo/**` · `lib/core/design_system/**` |
| `lib/core/autenticacao/**` — **só** estender a porta com a entrada anônima (AD-019); os métodos existentes ficam intactos | `lib/features/{home,galera,montar,lista}/domain/**` — as portas são consumidas **como estão** (CVD-33) |
| `lib/features/{home,galera}/data/**` — **só acrescentar** implementação Firestore ao lado da em memória | `lib/features/{home,galera,montar,lista,convite,custos}/presentation/**` — nenhum arquivo muda (CVD-33) |
| `lib/core/firebase/**` — wiring do Firestore, emulator-first (AD-004) | `lib/core/routing/routes.dart` — `convidadoPattern` já existe desde a fundação |
| `lib/core/di/injector.dart` — **só** registro dos próprios | `.specs/{STATE,ROADMAP,LESSONS}.md`, `.specs/lessons.json` |
| `test/features/convidado/**` · `test/rules/**` · `integration_test/**` | qualquer teste existente — a baseline não pode ser enfraquecida nem apagada |
| `firestore.rules`, `firestore.indexes.json`, `firebase.json`, `functions/**`, `web/` (rewrite do Hosting) | `lib/app.dart` além do necessário para o bootstrap do Firestore |
| `test/fixtures/**` — **só** estender a fixture RN-30 com o que a serialização exigir | |

---

## Assumptions & Open Questions

O ROADMAP marcou **Discuss** para esta spec, e uma zona cinzenta — **G5** — foi levada ao usuário e fechada como **AD-026** (2026-08-27). Todas as demais ambiguidades foram resolvidas pelo agente e estão registradas aqui com default escolhido e racional; nenhuma fica silenciosamente em aberto. As mesmas entradas estão em `context.md`.

| # | Ambiguidade | Default escolhido | Racional | Confirmado? |
|---|---|---|---|---|
| A-01 | **De onde vem o nome do convidado.** O flyer diz "ANA, VOCÊ FOI CHAMADA" e a tela seguinte "BOA, ANA! ✊", mas o link é o mesmo para todo mundo e o convidado não tem conta — o app não pode saber quem abriu. *(É a ambiguidade central desta spec.)* | **O nome é pedido uma vez, no primeiro compromisso.** O flyer abre **genérico** (RN-24: "abre direto no flyer"); o primeiro toque em "BORA! ✊" **ou** em "NÃO VOU 😔" num dispositivo que ainda não tem nome para esta festa abre um campo único — label "COMO TE CHAMAM?", placeholder "seu nome", CTA repetindo o rótulo da ação. Nome e uid anônimo ficam no dispositivo; **da segunda abertura em diante o flyer é personalizado** e o campo não reaparece | Três forças fixam essa posição. (a) RN-24 diz "abre **direto** no flyer, sem login" — pedir o nome antes do flyer contraria a regra. (b) **AD-022 exige que `confirmados` coincida com a contagem de pessoas nomeadas**, e a spec 07 (A-02) declarou que pessoa nomeada nasce de **duas** fontes só: a fixture e o RSVP pelo link. Logo o RSVP **tem** de produzir um nome — RSVP anônimo tornaria o invariante impossível. (c) Um campo de nome **não é cadastro**: não há e-mail, senha, verificação nem conta, então o aceite de UC-08 continua válido (CVD-05 afirma isso explicitamente). Pedir no compromisso, e não na abertura, é o que mantém o flyer literalmente "direto" | n |
| A-02 | **Concordância de gênero na copy.** "ANA, VOCÊ FOI CHAMADA" e "O Rafa já vê você como confirmada" concordam com o feminino da persona; o produto não sabe o gênero de ninguém — `Pessoa` não tem o campo (arquivo 01 §6) e os steppers H/M/C de RN-01 são extras anônimos, não pessoas | **Copy reescrita sem gênero, preservando voz e estrutura.** Tag do flyer: `{NOME}, TE CHAMARAM PRO ROLÊ` (personalizada) e `TE CHAMARAM PRO ROLÊ` (genérica, primeira abertura). Nota da tela Confirmado: `✅ O {ANFITRIAO} já sabe que você vai.` O resto de T-08 fica **literal**, inclusive "BOA, {NOME}! ✊", que já é livre de gênero | Nenhuma das três saídas alternativas serve: "(A)" viola a voz seca do arquivo 02; assumir masculino erra em metade dos casos; e modelar gênero exigiria um campo que o modelo de dados não tem e que o RSVP teria de perguntar — atrito proibido por UC-08. A própria spec-fonte já prefere construção neutra onde pode ("BOA, ANA! ✊"), o que dá o precedente. **Divergência declarada** — ver §Divergências D-1 | n |
| A-03 | **Dois convidados no mesmo dispositivo** (AD-026) | **A segunda pessoa reabre o RSVP da primeira.** Não há "não sou eu", não há troca de identidade, não há sair. O aparelho é a pessoa | AD-026 fixa a identidade no uid persistido; oferecer troca exigiria uma tela que a spec-fonte não desenha e reabriria G5. O dano é limitado e reversível: a primeira pessoa pode corrigir pelo "mudar o que eu levo". Vira **critério explícito** (CVD-11), não nota | n |
| A-04 | **O mesmo convidado em dois dispositivos** (AD-026) | **São duas pessoas.** Dois RSVPs, dois nomes iguais na Galera, `confirmados` = 2. Sem deduplicação por nome nesse caminho | É a consequência direta de AD-026, e deduplicar por nome no caminho **confirmado** permitiria a um portador do link sequestrar o RSVP de alguém já confirmado. A adoção de A-05 é deliberadamente restrita ao caso em que isso não é possível | n |
| A-05 | **Duda já é uma pessoa pendente nomeada na fixture.** Se ela abrir o link e digitar "Duda", o sistema cria uma segunda Duda? | **Adoção restrita.** O RSVP **adota** uma `Pessoa` existente se, e só se, ela estiver com status `pendente` **e** sem uid vinculado **e** o nome bater exatamente após `trim` + `toLowerCase`. Em qualquer outro caso, cria pessoa nova | Sem adoção, o fluxo canônico de RN-30 produz **6** pessoas nomeadas (a Duda antiga pendente + a nova confirmada) — o invariante de AD-022 continua verdadeiro, mas a Galera cresce um duplicado, que é exatamente a deriva que D-5 alerta, um nível abaixo. A restrição a `pendente` + sem dono é o que impede sequestro: ninguém já confirmado pode ser adotado. Risco residual — um portador do link pode assumir a identidade de um pendente — está **dentro** do modelo de ameaça já aceito por AD-026 | n |
| A-06 | **O banner roxo "← AGORA VOCÊ É A ANA"** e o **botão "💸 VER O ACERTO DA FESTA →"** na tela Confirmado — T-08 marca ambos como "no fluxo (integrado)" | **Fora do produto, os dois.** O banner é narração de demo, igual ao "Mapa de etapas" que o arquivo 04 marca explicitamente como não-produto. O botão é, por RN-28, o atalho **da Home do anfitrião**, e a spec 04 já o entregou lá (HOME-10) — na tela do convidado ele apontaria para uma rota que o convidado não tem. **A nota "✅ O {ANFITRIAO} já sabe que você vai." fica**, porque é afirmação verdadeira sobre o estado do próprio convidado e é o que torna RN-28 legível para ele | O qualificador "no fluxo" marca a narração da demo, não o produto — e o arquivo 04 já usa essa marca uma vez, no Mapa de etapas, dizendo em letras que não faz parte do produto final. Avaliado elemento a elemento pelo critério "é alcançável e verdadeiro no produto?": banner não, botão não, nota sim | n |
| A-07 | **Corrida por item: dois convidados marcam "EU LEVO" no mesmo item.** O item é exclusivo ou compartilhável? | **Exclusivo, dono único, primeira escrita vence.** O arquivo 01 §6 modela "atribuição *quem leva*" no singular e W-03 desenha o botão como "{NOME} LEVA", singular. A seleção é **local até "CONFIRMAR →"**; a exclusividade é resolvida no servidor, dentro da mesma transação do RSVP | Compartilhar um item exigiria dividir o valor entre donos — aritmética nova, que RN-20 não define e que `core/calculo` não tem. Resolver na transação do RSVP, e não a cada toque, é o que UC-09 já desenha ("alterna… CONFIRMAR →") e evita uma chamada de rede por toque | n |
| A-08 | **O que a UI mostra a quem perde a corrida** | **O RSVP nunca falha por causa de item.** A confirmação acontece; só os itens ainda livres são atribuídos; o bloco "VOCÊ LEVA:" lista **exatamente** o que foi atribuído; se nada sobrou, lê o literal "nada — só a presença ✊". Ao reabrir por "mudar o que eu levo", o item perdido aparece na **dica** ("🥩 {NOME} já leva…"), que é onde T-08 põe item com dono. **Nenhuma copy nova** | Falhar o RSVP por causa de um pacote de gelo seria trocar a coisa importante pela sem importância. E a migração do item para a linha de dica não inventa nada: a dica é literalmente o lugar de T-08 onde item com dono aparece, e a lista de escolha é literalmente "itens ainda sem dono" (UC-09 passo 1) | n |
| A-09 | **Idempotência do RSVP.** Reabrir o link já confirmado cai onde? Confirmar duas vezes conta duas vezes? | **O documento da pessoa é chaveado pelo uid anônimo**, então reconfirmar é escrita no mesmo documento. **O contador só se move na transição de status**, nunca na escrita: `sem resposta → confirmado` soma 1; `confirmado → confirmado` não faz nada. Reabrir o link com resposta registrada cai **direto no estado correspondente** — confirmado → "TÁ MARCADO! ✊"; recusou → "QUE PENA" | Chave natural + transição de estado dá idempotência sem chave de deduplicação inventada e sem janela de retry. E é o que faz "MUDEI DE IDEIA ✊" funcionar: sem estado persistido por dispositivo, o convidado voltaria sempre ao flyer genérico e recontaria | n |
| A-10 | **O papel de RN-23 é lido "no instante da abertura" (AD-026) — mas um cliente anônimo pode forjar o que declara** | **O papel é resolvido no servidor, a partir do nível vigente da festa, no instante da escrita do RSVP — e congelado na pessoa.** O cliente nunca envia papel. O nível lido **na abertura** governa o que o convidado **vê** (é ele que decide se a etapa de itens existe — CVD-28); o nível no momento da escrita governa o papel que fica **gravado** | É a única leitura à prova de forja, e preserva exatamente o aceite observável de UC-13 / AD-026: **trocar o nível não retroage sobre quem já está dentro**. Difere de uma leitura literal de "abertura" só na janela entre abrir e confirmar; nessa janela um rebaixamento passa a valer (menor privilégio, mesmo princípio de `galera` A-12) e uma promoção não vale até recarregar. **Divergência declarada** — ver §Divergências D-3 | n |
| A-11 | **Código inválido, festa inexistente e festa já concluída** — `/c/:codigo` sempre passa pela guarda (AD-017), então o erro é da tela | Três estados distintos, todos **standalone** (nunca `/erro`, que tem chrome de app): **(a) código malformado ou inexistente** → "ESSE LINK NÃO EXISTE" + "confere o link com quem te chamou." — sem CTA, sem rota de saída (o convidado não tem para onde ir dentro do BORA). **(b) festa com status `passada`** → CVD-40. **(c) falha de leitura** → CVD-41 | Mandar o convidado para `/erro` o jogaria numa tela com header de app e voltar, que W-04 proíbe explicitamente para esta tela. As três copies são **inventadas** — a spec-fonte não escreve nenhuma — e estão declaradas como tal em D-2 | n |
| A-12 | **Festa já concluída** (`StatusDaFesta.passada`) — AD-026 diz que o convidado mantém acesso ao acerto depois da festa | **O convite abre em leitura.** Quem já respondeu cai no estado dele (Confirmado / Que pena). Quem nunca respondeu vê o flyer **sem os CTAs**, com a linha "ESSE ROLÊ JÁ ROLOU". **RSVP novo é recusado**, no cliente e nas rules | Confirmar presença numa festa que já aconteceu produziria contador falso e contribuição fantasma no acerto da spec 10. Manter a leitura é o que honra AD-026; barrar a escrita é o que protege o acerto. Copy inventada, declarada em D-2 | n |
| A-13 | **"Avisamos o Rafa" (UC-10) — que canal, e o que acontece se falhar** | **O canal é a própria escrita realtime.** A pessoa aparece na Galera do anfitrião e os contadores da Home se movem, sem refresh — que é literalmente o que a copy de T-08 afirma ("O Rafa já vê você como confirmada"). **Sem push, sem e-mail, sem WhatsApp no MVP.** Se a escrita falhar, o convidado **não** vê a tela de sucesso (CVD-41) — a promessa "avisamos" nunca é exibida sem o aviso ter acontecido | Nenhuma tela da spec-fonte desenha superfície de notificação para o anfitrião, e FCM exigiria token, permissão de navegador e ciclo de vida que nenhuma spec cobre. Ligar a promessa ao sucesso da escrita é o que impede a tela de mentir — e é a mesma disciplina de `galera` A-07 (sem sucesso, sem toast de sucesso) | n |
| A-14 | **Offline / perda de conexão no meio do RSVP** — o convidado está num navegador, sem app | **Sem fila offline e sem service worker.** Falha de escrita mantém o convidado na tela de escolha **com a seleção intacta**, exibe estado de falha ("NÃO DEU PRA CONFIRMAR" + "sem internet? tenta de novo." + CTA "TENTAR DE NOVO →") e registra no `AppLogger`. Falha de **leitura** na abertura cai em A-11(c) | Fila offline exigiria resolver conflito de atribuição de item horas depois, contra um estado que mudou — complexidade sem tela que a peça. Preservar a seleção é o que torna o retry barato. Copy inventada, declarada em D-2 | n |
| A-15 | **Qual "por cabeça" vai no flyer** — RN-14 mantém dois números de propósito: a estimativa "≈ R$ X / cabeça" divide por **pessoas**; a cota do racha divide por **adultos** | A faixa amarela do flyer usa a **estimativa por pessoas** — a mesma de T-03 —, vinda de `core/calculo`, formatada por RN-13 | O flyer é convite, não acerto: ele responde "quanto vai me custar mais ou menos", que é a pergunta da montagem. E o texto literal é "CADA UM LEVA UMA PARTE — SAI ~R$ X", com o "~" da estimativa, não o valor exato da cota | n |
| A-16 | **"4 já confirmaram" nos avatares do flyer** — número fixo em T-08 | **Derivado** de `confirmados` (AD-022), com plural correto: `{n} já confirmaram` / `1 já confirmou`. Com a fixture RN-30 dá exatamente o literal | Precedente de `galera` A-10 e `home` A-05: literal fixo mentiria em qualquer outro estado, e o aceite continua sendo a string de T-08, agora como consequência do dado | n |
| A-17 | **Os itens listados em T-08 e a dica do anfitrião se contradizem** — "🧄 Pão de alho R$ 24" aparece na lista de disponíveis **e** na dica "RAFA já leva as carnes e o pão de alho" | **A derivação vence o exemplo**: a lista mostra itens **sem dono**; a dica mostra itens **com dono**, uma linha por dono, no formato "🥩 {NOME} já leva {itens}". Os dois conjuntos são disjuntos por construção | Se a lista e a dica pudessem intersectar, o convidado poderia assumir algo que já tem dono — o que a exclusividade de A-07 proíbe. **Divergência declarada** — ver §Divergências D-5 | n |
| A-18 | **Junção da lista de itens na dica** — o literal é "as carnes **e** o pão de alho" | Vírgula entre os primeiros e " e " antes do último. Um item só: sem junção | É o que o literal mostra, e é a única forma que reproduz a string de T-08 a partir do dado | n |
| A-19 | **RN-22 dá ao CONVIDADO "ajusta a lista", mas T-08 desenha só "EU LEVO"** | As **rules permitem** o que RN-22 manda (CVD-31); a **tela desta spec não oferece** o ajuste. Quem ajusta a lista é a tela da spec 06 | Implementar edição de item em T-08 seria inventar layout e copy numa tela literal. Estreitar as rules seria contradizer RN-22 e travar a spec 06 quando ela ganhar caminho para o convidado. Permitir no servidor e não oferecer no cliente é a única combinação que não mente para nenhum dos dois lados | n |
| A-20 | **A `Pessoa` criada pelo RSVP: quais campos** | `nome` (A-01), `papel` (A-10), `status`, `voce: false`, `dieta: null`, `bebe: null` | `voce` marca "o usuário do app" e o convidado não é usuário do app. Dieta e bebida não declaradas é exatamente o caso da Duda, que a Galera já renderiza (`galera` A-14) — e declarar por ele seria inventar dado. Ver D-4 | n |
| A-21 | **O RSVP muda as quantidades e o total da festa?** | **Não.** `core/calculo` já decidiu (A-22/A-05 da spec 02) que pessoa nomeada **não entra com cabeça** — quantidades vêm dos steppers H/M/C de RN-01, que já cobrem os confirmados. A confirmação move **contador e contribuição**, nunca quantidade | Somar cabeça pela pessoa nomeada exigiria inventar gramas para alguém sem sexo nem idade, que é a razão escrita da decisão da spec 02. Consequência a afirmar: o "~R$ X" do flyer **não muda** quando alguém confirma, e isso é correto, não bug | n |
| A-22 | **Validação do nome** | `trim`; recusa vazio; **máx. 24 caracteres**; sem quebra de linha; o valor gravado é o `trim`ado. Sem recusa por duplicidade (A-04) | 24 cabe no avatar, no "BOA, {NOME}! ✊" e na tag do flyer sem estourar layout, e é folga confortável sobre os nomes do produto. Texto livre é a **única** entrada desta feature, então é onde toda a dimensão de input validation se concentra | n |
| A-23 | **Rate limit no link** | **Nenhum no MVP.** A única superfície de escrita é uma Function que é idempotente por uid, o que limita o dano de um portador a **uma** pessoa por uid anônimo | AD-026 fixou o link como perpétuo e sem quota, e nenhuma tela desenha bloqueio. O limite estrutural (uma pessoa por uid) é mais forte que um contador de requisições e não precisa de infraestrutura. Declarado como aceito, não como esquecido | n |
| A-24 | **Onde as security rules e as Functions moram, e como são testadas** | `firestore.rules` na raiz e `functions/` na raiz, com suíte própria contra o **emulador** (AD-004). Testes de widget continuam rodando **sem emulador**, contra as implementações em memória | AD-004 é emulator-first e a suíte do M1 roda sem emulador por decisão da AD-016 — quebrar isso tornaria toda a baseline dependente de processo externo. Rules sem teste são texto; testadas contra o emulador viram requisito afirmável | n |
| A-25 | **Título da aba na página do convidado** (W-R5 fixa "bora — a conta do rolê" para o app) | **`{NOME DA FESTA} — bora`**, ex.: "CHURRAS DO RAFA 🔥 — bora" | W-R5 fala do app logado, cuja URL base é `bora.app/roles`; a página do convidado é standalone e chega por link compartilhado, onde o título é o que aparece no preview e na aba. Divergência mínima, declarada em D-2 | n |
| A-26 | **Como o convidado alcança a festa depois** — ele não tem Home | **Pelo mesmo link, sempre.** O link é perpétuo (AD-026) e reabri-lo cai no estado da pessoa (A-09). Sem "salvar festa", sem histórico | É o que AD-026 já garante, e qualquer outro caminho exigiria conta | n |

**Open questions:** nenhuma — todas resolvidas com o usuário (G5 → AD-026) ou registradas acima.

---

## Varredura de dimensões implícitas (porte Complexo — gate completo, todas as nove)

| Dimensão | Cobertura |
|---|---|
| **Input validation & bounds** | **CVD-08** — o nome é a única entrada de texto livre da feature: `trim`, recusa de vazio, teto de 24 caracteres, sem quebra de linha (A-22). **CVD-39** — o `codigo` da URL é validado contra o formato e contra a existência da festa antes de qualquer leitura. |
| **Failure / partial-failure states** | **CVD-19** (a escrita é atômica — pessoa, papel, atribuições e contadores caem juntos ou não caem), **CVD-41** (falha de escrita preserva a seleção e não exibe sucesso), **CVD-42** (item perdido não derruba o RSVP), **CVD-43** (falha da auth anônima e falha de leitura). |
| **Idempotency / retry / duplicate handling** | **CVD-22** — o documento é chaveado pelo uid e o contador se move só na **transição** de status; reconfirmar não recontabiliza. **CVD-27** — reabrir o link com resposta registrada cai no estado, não no fluxo. **CVD-10/CVD-11** — a duplicação possível (outro dispositivo, navegador limpo) é declarada e coberta por critério, não silenciada. |
| **Auth boundaries & rate limits** | **CVD-02** (auth anônima, sem conta), **CVD-28..CVD-32** (o papel de RN-23 governa o que se vê e o que se escreve; rules por nível, leitura e escrita, item a item, verificadas contra o emulador nos dois sentidos). **Rate limit: aceito sem limite** (A-23) — AD-026 fixou o link como perpétuo e sem quota, e a Function idempotente por uid limita o dano a uma pessoa por uid. |
| **Concurrency / ordering** | **CVD-42** (dois convidados no mesmo item — dono único, primeira escrita vence, resolvido na transação), **CVD-19** (a transação é a unidade de ordenação), **CVD-29** (troca de nível durante a sessão do convidado). |
| **Data lifecycle / expiry** | **CVD-09** (o par uid+nome vive no dispositivo, sem TTL — é o que faz o retorno de UC-10 funcionar), **CVD-11** (limpar os dados do navegador produz pessoa nova — custo declarado de AD-026), **CVD-40** (festa concluída fecha a escrita e mantém a leitura). **Expiração e revogação do link: N/A because** AD-026 os removeu do produto por decisão do usuário. |
| **Observability** | **CVD-43** — código inválido, falha de auth anônima, falha de leitura, falha de escrita e corrida de item perdida são registradas no `AppLogger` (AD-005), com o `codigo` e **sem** o nome digitado. |
| **External-dependency failure** | **CVD-41** (Firestore / Function indisponível), **CVD-43** (Firebase Auth anônimo indisponível), **CVD-44** (agenda: sem toast de sucesso quando a exportação falha — precedente de `galera` A-07). |
| **State-transition integrity** | **CVD-22** — a máquina de estados do RSVP é fechada e explícita: `sem resposta → confirmado` (+1 confirmados, −1 pendentes), `sem resposta → recusou` (−1 pendentes), `recusou → confirmado` (+1 confirmados), `confirmado → recusou` (−1 confirmados), e todo laço sobre si mesmo é no-op. **CVD-21** (invariante de AD-022 verificado depois de cada transição), **CVD-29** (papel congelado, nunca reescrito). |

Nenhuma dimensão ficou em branco. A única resolvida como `N/A because` é a expiração/revogação do link, por decisão do usuário registrada em AD-026.

---

## User Stories

### P1: O convite abre sem conta ⭐ MVP

**User Story**: Como alguém que recebeu um link no zap, quero ver o convite na hora, sem baixar nada e sem criar conta, para saber se vale a pena ir.

**Why P1**: É UC-08 inteiro e o diferencial declarado do produto. Sem esta história, o link que a spec 07 configura e a spec 08 manda termina em nada.

**Acceptance Criteria**:

1. WHEN `bora.app/c/<codigo>` é aberto **sem sessão** THEN o sistema SHALL renderizar a tela do convidado — **sem** redirecionar para `/entrar`, **sem** `AppShell`, **sem** header de app e **sem** botão voltar (AD-017, AD-003, W-04, arquivo 01 §5).
2. WHEN a mesma URL é aberta **com sessão de anfitrião ativa** THEN o resultado SHALL ser idêntico ao AC1 — a rota passa sempre, e a tela do convidado não muda de forma por causa de sessão.
3. WHEN a tela abre THEN o sistema SHALL executar a **entrada anônima** do Firebase automaticamente, sem exibir tela, botão ou aviso de autenticação.
4. WHEN o flyer renderiza THEN SHALL conter, na ordem de T-08: a linha "🔗 bora.app/c/<codigo> · abre sem conta"; o flyer escuro com sombra 8px vermelha; a tag amarela rotacionada; o título 36–40px com o nome da festa; "📅 SÁB · 18 JUL · A PARTIR DAS 14H"; "📍 LAJE DO RAFA — VILA MADALENA"; a faixa amarela "💸 CADA UM LEVA UMA PARTE — SAI ~R$ X"; os avatares empilhados com "{n} já confirmaram"; os CTAs "BORA! ✊" (primário) e "NÃO VOU 😔" (secundário); e a nota "responde direto daqui — sem baixar nada".
5. WHEN o dispositivo ainda não tem nome para esta festa THEN a tag amarela SHALL ler "TE CHAMARAM PRO ROLÊ"; WHEN já tem THEN SHALL ler "{NOME}, TE CHAMARAM PRO ROLÊ" (A-01, A-02).
6. WHEN a festa é a da fixture RN-30 THEN a linha do link SHALL ler exatamente "🔗 bora.app/c/rafa18 · abre sem conta" e os avatares SHALL ler exatamente "4 já confirmaram".
7. WHEN a festa tem exatamente 1 confirmado THEN a linha dos avatares SHALL ler "1 já confirmou" (A-16).
8. WHEN o "~R$ X" da faixa amarela é calculado THEN SHALL ser a estimativa por **pessoas** de RN-14 (a mesma de T-03), vinda de `core/calculo` e formatada por RN-13 — **nunca** a cota por adultos (A-15).
9. WHEN qualquer estado desta tela é exibido THEN **nenhum** SHALL conter campo de senha, campo de e-mail, botão de login, link para loja de aplicativos ou qualquer texto que peça instalação ou cadastro — o aceite não-negociável de UC-08.
10. WHEN a tela renderiza THEN o banner roxo "← AGORA VOCÊ É A ANA" SHALL estar **ausente** da árvore, em todos os quatro estados (A-06).

**Independent Test**: montar `/c/rafa18` com um repositório-duplo semeado pela fixture e uma porta de auth anônima falsa, duas vezes — com e sem sessão. Afirmar cada literal do flyer, a ausência de `AppShell.chromeKey`, a ausência do banner, e uma varredura na árvore por widgets de entrada de senha/e-mail (`findsNothing`), que é o par que discrimina o aceite de UC-08 de "a tela renderizou".

---

### P1: Quem é você, sem conta ⭐ MVP

**User Story**: Como convidado sem conta, quero dizer meu nome uma vez e ser reconhecido quando voltar, para o anfitrião saber quem confirmou e para eu poder mudar de ideia depois.

**Why P1**: É o que torna AD-022 possível (`confirmados` precisa coincidir com pessoas **nomeadas**) e o que faz "MUDEI DE IDEIA ✊" de UC-10 funcionar. Sem identidade, não há RSVP que o produto saiba representar.

**Acceptance Criteria**:

1. WHEN "BORA! ✊" ou "NÃO VOU 😔" é acionado num dispositivo **sem** nome registrado para esta festa THEN o sistema SHALL apresentar um campo único — label "COMO TE CHAMAM?", placeholder "seu nome", CTA repetindo o rótulo da ação acionada — e SHALL **não** prosseguir antes de um nome válido (A-01).
2. WHEN o nome informado é vazio após `trim` THEN o CTA SHALL permanecer inativo e **nenhuma** escrita SHALL ocorrer.
3. WHEN o nome informado excede 24 caracteres THEN a entrada SHALL ser barrada no limite; WHEN contém quebra de linha THEN SHALL ser recusada (A-22).
4. WHEN um nome válido é aceito THEN o valor gravado SHALL ser o `trim` da entrada — nem mais, nem menos.
5. WHEN o nome é aceito THEN o par `{uid anônimo, nome}` SHALL ser persistido no dispositivo, associado ao `codigo` da festa.
6. WHEN o mesmo dispositivo reabre o mesmo link THEN o campo de nome SHALL **não** reaparecer, e o flyer SHALL exibir a tag personalizada do P1-1 AC5.
7. WHEN o RSVP é gravado e existe na festa uma `Pessoa` com status `pendente`, **sem** uid vinculado, cujo nome coincide com o informado após `trim` + `toLowerCase` THEN o sistema SHALL **adotar** essa pessoa — vinculando o uid a ela — em vez de criar uma nova (A-05).
8. WHEN não existe pessoa nessas três condições simultâneas THEN o sistema SHALL criar uma `Pessoa` nova com `voce: false`, `dieta: null` e `bebe: null` (A-20).
9. WHEN uma `Pessoa` com o mesmo nome existe mas está **confirmada**, ou já tem uid vinculado THEN a adoção SHALL **não** ocorrer — pessoa nova é criada (A-04, A-05).
10. WHEN o link é aberto em **outro** dispositivo pela mesma pessoa THEN SHALL resultar em outra `Pessoa`, outro RSVP e `confirmados` somando os dois — comportamento declarado de AD-026, afirmado como critério, não como defeito.
11. WHEN os dados do navegador são limpos e o link é reaberto THEN o convidado SHALL voltar como pessoa nova, com campo de nome novamente — custo declarado de AD-026 (A-03, A-11 do §Edge Cases).

**Independent Test**: três montagens sobre o mesmo repositório-duplo — dispositivo virgem (pede nome, cria pessoa), dispositivo com par persistido (não pede, personaliza), e dispositivo virgem com "Duda" digitado (adota a pendente da fixture em vez de criar a sexta pessoa). O par que discrimina a adoção é a contagem de pessoas nomeadas: **5**, não 6.

---

### P1: BORA! e o que você leva ⭐ MVP

**User Story**: Como convidado, quero dizer que vou e escolher o que levo, para pagar menos no racha levando alguma coisa.

**Why P1**: É UC-09 inteiro e RN-20 do lado que produz. É a etapa que transforma "eu vou" em dinheiro.

**Acceptance Criteria**:

1. WHEN "BORA! ✊" é concluído e o nível do link permite escolher THEN a tela SHALL exibir o título "BOA, {NOME}! ✊" e, abaixo, "O que você levar desconta da sua parte no racha." — literais de T-08.
2. WHEN existem itens com dono THEN a dica SHALL renderizar uma linha por dono, no formato "🥩 {NOME} já leva {itens}", com os itens unidos por vírgula e " e " antes do último (A-17, A-18).
3. WHEN a lista de escolha renderiza THEN SHALL conter **exatamente** os itens da festa **sem dono**, cada um com emoji, nome, quantidade e valor formatado por RN-13, e o botão "EU LEVO" ⇄ "VOCÊ LEVA ✓" (ativo vermelho).
4. WHEN a festa é a da fixture RN-30 e o anfitrião leva as carnes e o pão de alho THEN a lista de escolha SHALL **não** conter o pão de alho, e a dica SHALL contê-lo (A-17).
5. WHEN itens são alternados THEN o rodapé SHALL ler "VOCÊ LEVA R$ {soma}", com a soma vinda de `core/calculo` e formatada por RN-13, atualizando a cada toque.
6. WHEN nenhum item está marcado THEN o rodapé SHALL ler "VOCÊ LEVA R$ 0" e "CONFIRMAR →" SHALL permanecer **acionável** (UC-09 A1 — confirmar sem levar nada é caminho válido).
7. WHEN itens são alternados THEN **nenhuma** escrita SHALL ocorrer — a seleção é local até "CONFIRMAR →" (A-07).
8. WHEN "CONFIRMAR →" é acionado THEN o sistema SHALL executar **uma** escrita e exibir a tela "TÁ MARCADO! ✊" com data e local em amarelo e o bloco "VOCÊ LEVA: {itens atribuídos}" seguido de "R$ X — desconta da sua cota" em vermelho.
9. WHEN nenhum item foi atribuído THEN o bloco SHALL ler exatamente "nada — só a presença ✊" — literal de T-08.
10. WHEN a tela "TÁ MARCADO! ✊" renderiza THEN SHALL exibir a nota "✅ O {ANFITRIAO} já sabe que você vai." (A-02, A-06) e o link vermelho "mudar o que eu levo"; e SHALL **não** exibir o botão "💸 VER O ACERTO DA FESTA →" (A-06).
11. WHEN "mudar o que eu levo" é acionado THEN a tela de escolha SHALL reabrir com os itens **do próprio convidado** marcados como "VOCÊ LEVA ✓" e os itens de outros na dica; WHEN um item próprio é desmarcado e confirmado THEN SHALL voltar a ficar sem dono (UC-09 A2).
12. WHEN o valor dos itens atribuídos ao convidado é usado THEN SHALL entrar como **contribuição dele** no acerto por RN-20, calculado por `package:bora/core/calculo/calculo.dart` — e **nenhuma fórmula de RN-13, RN-14, RN-15 ou RN-20 SHALL ser escrita em `lib/features/convidado/`**.
13. WHEN um RSVP é gravado THEN as quantidades e o total da festa SHALL permanecer **inalterados** — pessoa nomeada não entra com cabeça (A-21), e o "~R$ X" do flyer não se move.

**Independent Test**: percorrer flyer → nome → escolha → confirmar com dois itens; afirmar o rodapé a cada toque, a ausência de escrita antes do CTA (contador de chamadas do duplo = 0), o bloco literal na tela final, e — com `calcularSaldos` sobre o estado resultante — a contribuição do convidado igual à soma dos itens. Uma varredura afirma que nenhum arquivo de `lib/features/convidado/` contém aritmética de RN-13/RN-14/RN-20.

---

### P1: A confirmação chega no anfitrião ⭐ MVP

**User Story**: Como anfitrião, quero ver o contador subir sozinho quando alguém confirma, para saber que a festa está de pé sem ficar perguntando no grupo.

**Why P1**: É RN-28 do lado que **produz** — o lado que o M1 deixou sem dono — e é onde a pendência **D-5** se fecha.

**Acceptance Criteria**:

1. WHEN um RSVP é gravado THEN a escrita SHALL ser **uma transação única** contendo: o documento da `Pessoa` (nome, papel, status, uid), as atribuições de item conquistadas e os contadores `confirmados`/`pendentes` da festa — todos aplicados juntos ou nenhum aplicado.
2. WHEN a festa é a da fixture RN-30 (4 confirmados · 2 pendentes) e um convidado confirma THEN a Home do anfitrião SHALL passar a ler "5 confirmados · 1 pendente" **sem remontagem da tela e sem ação do usuário**, e o botão amarelo full-width "💸 VER O ACERTO DA FESTA →" SHALL aparecer no card — a transição literal de RN-28 / T-02.
3. WHEN qualquer transição de RSVP é concluída THEN o campo `confirmados` da festa SHALL ser **igual** à contagem de `Pessoa` com status confirmado — o invariante de AD-022, afirmado **depois** da escrita, não antes.
4. WHEN o RSVP é uma recusa ou uma confirmação THEN `pendentes` SHALL decrescer em 1, com **piso em 0** — nunca negativo.
5. WHEN o mesmo dispositivo confirma duas vezes seguidas THEN `confirmados` SHALL somar **1**, não 2 — o contador se move na **transição** de status, nunca na escrita (A-09).
6. WHEN as transições são exercidas THEN SHALL valer exatamente esta tabela e nenhuma outra: `sem resposta → confirmado` = +1 confirmados, −1 pendentes · `sem resposta → recusou` = −1 pendentes · `recusou → confirmado` = +1 confirmados · `confirmado → recusou` = −1 confirmados · `confirmado → confirmado` e `recusou → recusou` = nenhuma mudança.
7. WHEN um RSVP é gravado THEN a Galera do anfitrião (spec 07) SHALL passar a listar a pessoa com o nome informado e o papel congelado, **sem** duplicar quem foi adotado (P1-2 AC7).
8. WHEN o convidado adota uma pessoa pendente THEN `confirmados` SHALL somar 1 e o número de pessoas nomeadas SHALL permanecer o mesmo — com a fixture RN-30: 5 pessoas, 5 confirmadas, 1 pendente.
9. WHEN a transição termina THEN o convidado SHALL ver a tela de sucesso **somente** se a escrita foi confirmada pelo servidor (A-13).

**Independent Test**: emulador do Firestore semeado com a fixture; confirmar pelo caminho do convidado e afirmar, na Home montada em paralelo sobre a mesma fonte, a string "5 confirmados · 1 pendente" e a presença do atalho; depois confirmar de novo e afirmar que a string **não** mudou. A tabela de AC6 vira teste unitário de seis casos sobre a função de transição, e o invariante de AC3 é reafirmado depois de cada um deles — é o par que discrimina "o contador subiu" de "o contador subiu e continua verdadeiro".

---

### P1: Não vou, e mudei de ideia ⭐ MVP

**User Story**: Como convidado, quero poder dizer que não vou sem dar satisfação, e poder voltar atrás depois, porque plano de churrasco muda.

**Why P1**: É UC-10 inteiro, e o aceite dele ("retorno possível a qualquer momento antes da festa") é o que justifica a identidade persistida de AD-026.

**Acceptance Criteria**:

1. WHEN "NÃO VOU 😔" é concluído THEN a tela SHALL exibir "😔 QUE PENA", a linha "Avisamos o {ANFITRIAO} que você não vai desta vez." e o CTA "MUDEI DE IDEIA ✊" — literais de T-08.
2. WHEN a recusa é registrada THEN o sistema SHALL **não** pedir justificativa, motivo ou qualquer campo além do nome (aceite de UC-10).
3. WHEN a recusa é gravada THEN a `Pessoa` SHALL ficar com status `recusou`, `pendentes` SHALL decrescer com piso 0 e `confirmados` SHALL **não** aumentar.
4. WHEN "MUDEI DE IDEIA ✊" é acionado THEN o sistema SHALL reabrir o convite no estado de UC-08 — o flyer, agora com a tag personalizada — sem pedir o nome de novo.
5. WHEN o convidado confirma depois de ter recusado THEN `confirmados` SHALL somar 1 e `pendentes` SHALL permanecer inalterado (já foi decrescido na recusa) — linha `recusou → confirmado` de P1-4 AC6.
6. WHEN o link é reaberto num dispositivo com resposta registrada THEN SHALL cair **direto** no estado correspondente: confirmado → "TÁ MARCADO! ✊"; recusou → "😔 QUE PENA" — nunca no flyer com CTAs (A-09).
7. WHEN a pessoa está confirmada e reabre o link THEN SHALL existir caminho de volta para a recusa **somente** através do fluxo já desenhado ("mudar o que eu levo" não recusa; nenhuma copy nova é inventada para isso) — a transição `confirmado → recusou` existe no domínio (P1-4 AC6) e é alcançada pelo flyer quando exibido.

**Independent Test**: recusar, afirmar as três literais e os contadores; tocar "MUDEI DE IDEIA ✊", afirmar o flyer personalizado sem campo de nome; confirmar e afirmar `confirmados` +1 com `pendentes` estável. Reabrir a montagem do zero com o par persistido e afirmar que a primeira tela é a de estado, não o flyer.

---

### P1: O papel do link manda no que o convidado vê e escreve ⭐ MVP

**User Story**: Como anfitrião, quero que o nível que escolhi no link seja de verdade o limite de quem abrir, para poder chamar gente sem entregar a festa.

**Why P1**: É RN-23 aplicada e RN-22 traduzida para o servidor. Sem enforcement, o segmented da spec 07 é decoração.

**Acceptance Criteria**:

1. WHEN o nível vigente é **SÓ VER** e "BORA! ✊" é concluído THEN o sistema SHALL ir **direto** para "TÁ MARCADO! ✊" com o bloco "nada — só a presença ✊", **sem** exibir a etapa de escolha de itens — RN-23: "convidados só veem a festa e confirmam presença".
2. WHEN o nível vigente é **EDITAR LISTA** ou **CO-ANFITRIÃO** THEN a etapa de escolha SHALL ser exibida (P1-3).
3. WHEN o RSVP é gravado THEN o `papel` SHALL ser resolvido **no servidor**, a partir do nível vigente da festa, pela tradução de RN-23 × RN-22 que a spec 07 entrega (SÓ VER → SÓ VÊ · EDITAR LISTA → CONVIDADO · CO-ANFITRIÃO → CO-ANFITRIÃO); o cliente SHALL **não** enviar papel algum (A-10).
4. WHEN o `papel` já está gravado numa pessoa THEN nenhuma troca posterior do nível do link SHALL alterá-lo — o papel é congelado (AD-026, aceite de UC-13).
5. WHEN o nível armazenado está ausente ou é desconhecido THEN SHALL resolver para **SÓ VER** (menor privilégio — o mesmo default de `galera` A-12).
6. WHEN as security rules são avaliadas para **leitura** THEN um portador autenticado anonimamente SHALL poder ler: o documento da festa (nome, data, local, duração, status, código, nível, contadores), a coleção de itens e a coleção de pessoas — em **todos** os três níveis, porque os três incluem "vê a festa" (RN-22) e o flyer precisa dos três conjuntos.
7. WHEN as security rules são avaliadas para **escrita** THEN SHALL valer, item a item: (a) o documento da festa e seus contadores — **negado a qualquer cliente**, em todos os níveis, gravável só pela Function; (b) o documento de uma pessoa — gravável só pela Function, e só o documento cujo id é o uid de quem chama; (c) a atribuição "quem leva" de um item — negada em SÓ VER, permitida em EDITAR LISTA e CO-ANFITRIÃO, e apenas para atribuir a si mesmo ou liberar o que é seu; (d) demais campos de item (quantidade, preço, override) — negados em SÓ VER, permitidos em EDITAR LISTA e CO-ANFITRIÃO (RN-22 "ajusta a lista" — A-19); (e) despesas e linhas de acerto — negadas em SÓ VER e CONVIDADO, permitidas em CO-ANFITRIÃO ("cobra a galera"); (f) papéis de terceiros e nível do link — **negados em todos os níveis**, inclusive CO-ANFITRIÃO (exclusivos do anfitrião, `galera` A-19).
8. WHEN a festa está com status `passada` THEN toda escrita SHALL ser negada pelas rules, em todos os níveis (A-12).
9. WHEN as rules são testadas THEN cada linha do AC7 SHALL ter **dois** casos — um permitido e um negado — verificados contra o emulador do Firestore (AD-004, A-24).
10. WHEN a tradução de RN-22 é necessária THEN SHALL consumir a tabela de domínio que a spec 07 entregou (GAL-19); **nenhuma capacidade SHALL ser redefinida** em `lib/features/convidado/` nem divergir das rules.

**Independent Test**: suíte de rules contra o emulador percorrendo os três níveis × as seis linhas do AC7, cada uma com o par permitido/negado — nunca só o caminho feliz. Do lado do cliente, montar com nível SÓ VER e afirmar que a tela de escolha **não existe na árvore** (`findsNothing`), montar com EDITAR LISTA e afirmar que existe — o par que discrimina.

---

### P1: Firestore, Hosting e Functions atrás das portas que já existem ⭐ MVP

**User Story**: Como quem mantém o projeto, quero trocar a memória por Firestore sem que nenhuma tela já pronta perceba, para não pagar o M1 duas vezes.

**Why P1**: É AD-016 cobrando o combinado. Seis specs consomem essas portas; se a troca vazar para elas, a decisão que barateou o M1 vira dívida no M2.

**Acceptance Criteria**:

1. WHEN as implementações Firestore entram THEN as assinaturas de `FestaRepository` (spec 04) e `GaleraRepository` (spec 07) SHALL permanecer **idênticas** — nenhum método adicionado, removido ou com tipo alterado.
2. WHEN a troca é concluída THEN **nenhum** arquivo sob `lib/features/{home,galera,montar,lista}/presentation/` e `.../domain/` SHALL ter sido modificado — verificável por diff.
3. WHEN a suíte existente roda THEN SHALL continuar **inteiramente verde**, sem enfraquecer, pular ou reescrever teste algum, e **sem exigir emulador ligado** (AD-004, A-24).
4. WHEN a serialização de `Festa`, `Pessoa` e item é escrita THEN SHALL usar as chaves já declaradas nos enums de domínio (`PapelNaFesta.chave`, `StatusDePresenca.chave`, `StatusDaFesta.chave`), e um valor desconhecido na leitura SHALL resolver por menor privilégio ou por estado seguro, nunca lançar na UI.
5. WHEN o `codigo` de uma festa é gerado THEN SHALL ser único, estável e perpétuo (AD-026), gerado no servidor (`galera` A-03); a festa da fixture RN-30 SHALL manter `rafa18`.
6. WHEN o Hosting serve `bora.app/c/<codigo>` THEN SHALL entregar a aplicação Flutter Web com rewrite de SPA, de forma que uma abertura **direta** da URL (sem navegação interna) renderize a tela do convidado.
7. WHEN a página do convidado carrega THEN o título da aba SHALL ler "{NOME DA FESTA} — bora" (A-25).
8. WHEN o Firestore ou a Function estão indisponíveis THEN o app SHALL degradar conforme AD-004 — a falha vai para o `AppLogger` e a tela exibe estado de erro, nunca tela branca.
9. WHEN as regras e as Functions são versionadas THEN SHALL morar em `firestore.rules` e `functions/` na raiz, com suíte própria contra o emulador (A-24).

**Independent Test**: rodar a suíte inteira sem emulador e afirmar verde; rodar a suíte de repositório contra o emulador e afirmar o mesmo contrato observável do duplo em memória (mesmos `Stream`, mesma ordem, mesmas emissões); e um teste de fronteira que falha se qualquer arquivo de `presentation/` das quatro features listadas aparecer no diff da spec.

---

### P2: O convidado no web

**User Story**: Como convidado que abriu o link no computador, quero a mesma página, legível numa janela grande, para responder dali mesmo.

**Why P2**: W-04 dá a adaptação, mas o link chega pelo WhatsApp e o loop fecha no celular. É paridade, não pré-requisito.

**Acceptance Criteria**:

1. WHEN a página abre em viewport expandida THEN SHALL renderizar **standalone, sem header de app**, com o flyer centralizado em **máx. 480px** e os CTAs abaixo dele (W-04, linha "Convidado (link)").
2. WHEN em expandido THEN SHALL **não** existir barra de app, botão voltar, avatar de usuário nem rodapé-CTA fixo (W-R2, arquivo 01 §5).
3. WHEN a viewport desce abaixo de ~900px THEN o layout SHALL colapsar para o de T-08 preservando o estado — etapa corrente, nome informado e itens marcados continuam como estavam (W-R3).
4. WHEN a página renderiza em qualquer largura THEN SHALL **nunca** produzir scroll horizontal (W-R4).
5. WHEN um item é assumido em uma plataforma THEN o mesmo estado SHALL valer na outra, em tempo real (W-R1).
6. WHEN em expandido THEN todo elemento clicável SHALL ter estado de hover (princípio de adaptação do arquivo 06).
7. WHEN os quatro estados de T-08 são exercidos em expandido THEN todos SHALL respeitar os AC1..AC4 — a adaptação vale para a tela inteira, não só para o flyer.

**Independent Test**: montar os quatro estados nos dois viewports; afirmar a largura máxima do flyer, a ausência de `AppShell.chromeKey` nas duas larguras, a ausência de scroll horizontal, e que trocar de viewport no meio da escolha preserva os itens marcados sem `pumpWidget` novo.

---

### P2: Quando dá ruim

**User Story**: Como convidado, quero entender o que aconteceu quando o link não abre ou a confirmação não vai, para não ficar achando que confirmei sem ter confirmado.

**Why P2**: Não bloqueia o caminho feliz de UC-08/09/10, mas é onde a promessa "avisamos o Rafa" pode virar mentira — e é a metade da superfície que as dimensões implícitas cobram.

**Acceptance Criteria**:

1. WHEN o `codigo` da URL é malformado ou não corresponde a festa alguma THEN a página SHALL exibir, standalone, "ESSE LINK NÃO EXISTE" e "confere o link com quem te chamou." — **sem** CTA e **sem** redirecionar para `/erro` (A-11).
2. WHEN a festa existe com status `passada` e o dispositivo **não** tem resposta registrada THEN o flyer SHALL renderizar em leitura, **sem** os CTAs "BORA! ✊" e "NÃO VOU 😔", com a linha "ESSE ROLÊ JÁ ROLOU" (A-12).
3. WHEN a festa está `passada` e o dispositivo **tem** resposta registrada THEN SHALL cair no estado da pessoa (Confirmado / Que pena), também sem CTAs de mudança.
4. WHEN a escrita do RSVP falha THEN o convidado SHALL permanecer na tela de escolha **com a seleção intacta**, SHALL ver "NÃO DEU PRA CONFIRMAR", "sem internet? tenta de novo." e o CTA "TENTAR DE NOVO →", e SHALL **não** ver nenhuma tela de sucesso (A-13, A-14).
5. WHEN "TENTAR DE NOVO →" é acionado e a escrita passa THEN o resultado SHALL ser idêntico ao de uma primeira confirmação bem-sucedida — sem contador duplicado (P1-4 AC5).
6. WHEN um ou mais itens escolhidos foram assumidos por outra pessoa entre a escolha e o "CONFIRMAR →" THEN o RSVP SHALL ser confirmado mesmo assim, apenas os itens ainda livres SHALL ser atribuídos, e o bloco "VOCÊ LEVA:" SHALL listar **exatamente** o que foi atribuído (A-08).
7. WHEN todos os itens escolhidos foram perdidos na corrida THEN o bloco SHALL ler "nada — só a presença ✊" (A-08).
8. WHEN o convidado reabre a escolha depois de perder um item THEN o item perdido SHALL aparecer na **dica** com o nome do novo dono, e **não** na lista de escolha (A-17).
9. WHEN a entrada anônima do Firebase falha THEN a página SHALL exibir estado de erro visível — nunca tela branca — e SHALL registrar a falha no `AppLogger` (AD-005).
10. WHEN a leitura da festa falha por indisponibilidade THEN SHALL valer o AC9, distinguindo-se de AC1 (código inexistente é resposta, não falha).
11. WHEN qualquer dos casos AC1, AC4, AC6, AC9 e AC10 ocorre THEN SHALL ser registrado no `AppLogger` com o `codigo` e **sem** o nome digitado pelo convidado.

**Independent Test**: cinco montagens com duplos que falham de formas diferentes — código inexistente, festa passada, escrita que lança, item já tomado, auth anônima que lança. Cada uma afirma a copy exibida, a ausência da tela de sucesso e a entrada correspondente no `RecordingAppLogger`. O par que discrimina o AC4 é a seleção preservada: um retry que perde os itens marcados passa num teste que só olha a mensagem.

---

### P3: Salvar na agenda

**User Story**: Como convidado que confirmou, quero jogar a festa na minha agenda, para não esquecer.

**Why P3**: É UC-09 A3 — uma alternativa, não o fluxo. E é a única dependência externa opcional da feature.

**Acceptance Criteria**:

1. WHEN "📅 SALVAR NA AGENDA" é acionado na tela "TÁ MARCADO! ✊" THEN o sistema SHALL oferecer o evento com nome, data, hora e local da festa, atrás de porta própria (testável sem plataforma).
2. WHEN a exportação é bem-sucedida THEN SHALL exibir o toast "SALVO NA AGENDA 📅" — texto, emoji e 2200 ms literais de RN-29, 1 por vez.
3. WHEN a exportação falha THEN o toast de sucesso SHALL **não** ser exibido, a falha SHALL ser registrada no `AppLogger` e a tela SHALL permanecer como estava (precedente de `galera` A-07).

**Independent Test**: porta de agenda falsa que registra a chamada e uma que lança; afirmar o toast literal na primeira e a ausência dele mais o registro no logger na segunda.

---

## Edge Cases

- WHEN o `codigo` da URL contém caractere que exige escape THEN a leitura SHALL usar o valor decodificado e a linha "🔗 bora.app/c/<codigo>" SHALL exibir a mesma string do link recebido.
- WHEN a festa não tem item nenhum sem dono THEN a lista de escolha SHALL renderizar vazia, o rodapé SHALL ler "VOCÊ LEVA R$ 0" e "CONFIRMAR →" SHALL continuar acionável — o convidado confirma só a presença.
- WHEN a festa não tem confirmado nenhum THEN a linha dos avatares SHALL ler "0 já confirmaram" e a pilha de avatares SHALL renderizar vazia, sem copy inventada.
- WHEN dois convidados confirmam ao mesmo tempo THEN os dois SHALL ser contados: as transações são sequenciadas pelo servidor e o invariante de AD-022 SHALL valer depois das duas.
- WHEN o nome informado é igual ao de uma pessoa **confirmada** THEN duas pessoas com o mesmo nome SHALL coexistir na Galera (A-04) — o caso que a spec 07 já previu no seu §Edge Cases.
- WHEN o nome informado contém só espaços THEN SHALL ser tratado como vazio (P1-2 AC2).
- WHEN o convidado assume um item e o anfitrião o remove da lista THEN a contribuição SHALL cair junto — a fonte é a lista, e esta spec não guarda cópia do valor.
- WHEN o dispositivo tem par persistido para a **festa A** e abre o link da **festa B** THEN SHALL pedir o nome de novo — a persistência é por `{codigo, uid}`, não global (P1-2 AC5).
- WHEN o toast de RN-29 já está na tela e outro é disparado THEN o segundo SHALL substituir o primeiro — 1 por vez.
- WHEN o anfitrião troca o nível do link enquanto o convidado está na tela de escolha THEN o convidado SHALL terminar o fluxo que começou, e o papel gravado SHALL ser o do nível vigente **na escrita** (A-10) — inclusive quando isso significa gravar SÓ VÊ para quem escolheu itens, caso em que as atribuições SHALL ser recusadas pelas rules.

---

## Requirement Traceability

| ID | História | Origem na spec-fonte | Fase | Status |
|---|---|---|---|---|
| CVD-01 | P1-1 AC1, AC2 | **AD-017** · **AD-003** · W-04 (standalone) · arquivo 01 §5 | Design | Pending |
| CVD-02 | P1-1 AC3 | **RN-24** ("sem login") · **AD-026** · AD-019 | Design | Pending |
| CVD-03 | P1-1 AC4, AC5, AC6 | **T-08 · Convite** (literal) · A-01, A-02 | Design | Pending |
| CVD-04 | P1-1 AC7, AC8 | **RN-14** (estimativa por pessoas) · **RN-13** · **AD-022** · A-15, A-16 | Design | Pending |
| CVD-05 | P1-1 AC9 | **UC-08 aceite** ("nenhuma etapa pede download ou cadastro") | Design | Pending |
| CVD-06 | P1-1 AC10 · P1-3 AC10 | T-08 ("no fluxo") · arquivo 04 §Mapa de etapas · A-06 | Design | Pending |
| CVD-07 | P1-2 AC1 | **RN-24** · **AD-022** · `galera` A-02 · A-01 | Design | Pending |
| CVD-08 | P1-2 AC2, AC3, AC4 | A-22 (dimensão: input validation & bounds) | Design | Pending |
| CVD-09 | P1-2 AC5, AC6 | **AD-026** (uid persistido no dispositivo) · **UC-10** (retorno) | Design | Pending |
| CVD-10 | P1-2 AC7, AC8, AC9 | **AD-022** · **RN-30** (Duda pendente) · A-05 | Design | Pending |
| CVD-11 | P1-2 AC10, AC11 | **AD-026** (modelo de ameaça aceito) · A-03, A-04 | Design | Pending |
| CVD-12 | P1-3 AC1, AC2 | **T-08 · Escolher o que leva** (literal) · **UC-09** passo 1 · A-17, A-18 | Design | Pending |
| CVD-13 | P1-3 AC3, AC4, AC5, AC6 | **T-08** (lista e rodapé) · **UC-09** passo 2 · **RN-13** | Design | Pending |
| CVD-14 | P1-3 AC7 | **UC-09** passo 3 · A-07 (dimensão: concurrency) | Design | Pending |
| CVD-15 | P1-3 AC8, AC9 | **T-08 · Confirmado** (literal, inclusive "nada — só a presença ✊") | Design | Pending |
| CVD-16 | P1-3 AC11 | **UC-09 A2** ("mudar o que eu levo") | Design | Pending |
| CVD-17 | P1-3 AC12, AC13 | **RN-20** · **UC-09 aceite** · CLAUDE.md ("nunca duplique uma fórmula na UI") · A-21 | Design | Pending |
| CVD-18 | P1-3 AC10 | T-08 (nota do anfitrião) · **RN-28** · A-02, A-06 | Design | Pending |
| CVD-19 | P1-4 AC1 | **RN-28** · **AD-022** · **D-5** (`home/validation.md`) | Design | Pending |
| CVD-20 | P1-4 AC2 | **RN-28** literal (4/2 → 5/1 + atalho) · T-02 · W-02 | Design | Pending |
| CVD-21 | P1-4 AC3, AC4, AC8 | **AD-022** (invariante) · **D-5** | Design | Pending |
| CVD-22 | P1-4 AC5, AC6 | A-09 (dimensões: idempotência, state-transition integrity) | Design | Pending |
| CVD-23 | P1-4 AC7, AC9 | **RN-28** · `galera` GAL-09 · A-05, A-13 | Design | Pending |
| CVD-24 | P1-5 AC1 | **T-08 · Não vou** (literal) · A-02 | Design | Pending |
| CVD-25 | P1-5 AC2, AC3 | **UC-10 aceite** ("recusa não exige justificativa") · **RN-24** | Design | Pending |
| CVD-26 | P1-5 AC4, AC5 | **UC-10** passo 2 ("MUDEI DE IDEIA ✊") · **AD-026** | Design | Pending |
| CVD-27 | P1-5 AC6, AC7 | A-09 (dimensão: idempotência) · **UC-10 aceite** (retorno a qualquer momento) | Design | Pending |
| CVD-28 | P1-6 AC1, AC2 | **RN-23** (copy do nível SÓ VER) · **RN-22** | Design | Pending |
| CVD-29 | P1-6 AC3, AC4, AC5 | **AD-026** · **UC-13 aceite** · `galera` A-12, GAL-20 · A-10 | Design | Pending |
| CVD-30 | P1-6 AC6 | **RN-22** ("vê a festa") · security rules (leitura) | Design | Pending |
| CVD-31 | P1-6 AC7, AC8, AC10 | **RN-22** (tabela) · **RN-23** · `galera` GAL-19 · A-12, A-19 | Design | Pending |
| CVD-32 | P1-6 AC9 | **AD-004** (emulator-first) · A-24 | Design | Pending |
| CVD-33 | P1-7 AC1, AC2, AC3 | **AD-016** (portas intactas, suíte verde) | Design | Pending |
| CVD-34 | P1-7 AC4, AC5 | **AD-016** · `galera` A-03 · **AD-026** (código perpétuo) | Design | Pending |
| CVD-35 | P1-7 AC6, AC7 | **AD-016** (Hosting) · W-04 · W-R5 · A-25 | Design | Pending |
| CVD-36 | P1-7 AC8, AC9 | **AD-004** · **AD-005** · A-24 | Design | Pending |
| CVD-37 | P2-1 AC1, AC2, AC7 | **W-04** linha "Convidado (link)" · W-R2 | Design | Pending |
| CVD-38 | P2-1 AC3, AC4, AC5, AC6 | **W-R1, W-R3, W-R4** · arquivo 06 §Princípios | Design | Pending |
| CVD-39 | P2-2 AC1 | A-11 (dimensão: input validation) · **AD-017** | Design | Pending |
| CVD-40 | P2-2 AC2, AC3 | A-12 (dimensão: data lifecycle) · **AD-026** | Design | Pending |
| CVD-41 | P2-2 AC4, AC5 | A-13, A-14 (dimensões: failure, external-dependency) | Design | Pending |
| CVD-42 | P2-2 AC6, AC7, AC8 | A-07, A-08, A-17 (dimensão: concurrency) | Design | Pending |
| CVD-43 | P2-2 AC9, AC10, AC11 | **AD-005** (dimensões: external-dependency, observability) | Design | Pending |
| CVD-44 | P3-1 AC1, AC2, AC3 | **UC-09 A3** · **RN-29** ("SALVO NA AGENDA 📅") · `galera` A-07 | Design | Pending |

**Formato do ID:** `CVD-[NN]` · **Status:** Pending → In Design → In Tasks → Implementing → Verified

**Cobertura:** 44 requisitos · **P1: 36** (CVD-01..CVD-36) · **P2: 7** (CVD-37..CVD-43) · **P3: 1** (CVD-44) · 0 órfãos · mapeamento a tasks pendente do Design.

**Cobertura da spec-fonte:** UC-08 → CVD-01..CVD-06 + CVD-09 · UC-09 → CVD-12..CVD-18 + CVD-44 · UC-10 → CVD-24..CVD-27 · RN-24 → CVD-02, CVD-05, CVD-07, CVD-25 · RN-28 (origem) → CVD-19..CVD-23 · RN-20 (consumo) → CVD-17 · RN-23 (consumo) → CVD-28..CVD-31 · RN-22 (rules) → CVD-30, CVD-31 · RN-13 → CVD-04, CVD-13 · RN-29 → CVD-44 · T-08 → CVD-03, CVD-12, CVD-15, CVD-24 · W-04 + W-R1..R5 → CVD-35, CVD-37, CVD-38.

---

## Porte

**Complexo** — confirma a classificação do roadmap, por três motivos que não se reduzem um ao outro:

1. **A migração para Firestore, Hosting e Functions.** AD-016 marcou esta spec como a dona da entrada do backend real no projeto. Não é acrescentar uma tela: é escrever serialização para três entidades, uma implementação nova para cada porta já em uso, o wiring emulator-first (AD-004), o rewrite de SPA do Hosting e a primeira Cloud Function do projeto — tudo **sem alterar as portas que as specs 04, 05, 06 e 07 já consomem** (CVD-33), com a suíte existente como aceite.
2. **A superfície de segurança do link.** Esta é a primeira e única superfície do produto exposta a quem não tem conta. As security rules traduzem a tabela de RN-22 para o servidor, capacidade por capacidade e nível por nível (CVD-30, CVD-31), e cada linha precisa do par permitido/negado contra o emulador (CVD-32). Errar aqui não produz tela feia — produz festa reescrita por um portador de link.
3. **A identidade sem conta.** AD-026 fixou a resposta (uid anônimo persistido no dispositivo), e a resposta gera uma máquina de estados própria — adoção de pendente, transições de RSVP, idempotência por chave natural, contadores que precisam continuar coincidindo com AD-022 (CVD-10, CVD-21, CVD-22) — mais um modelo de ameaça que tem de aparecer como critério (CVD-11), não como comentário.

Somados aos quatro estados de T-08 nas duas plataformas, à corrida por item, ao pedido do nome e aos seis estados de falha, o corte estimado passa folgadamente de 20 tasks. **Design e Tasks são formais, e o Design pede pesquisa** (roadmap §2: "sim + pesquisa") em pelo menos três pontos: persistência do uid anônimo em Flutter Web sob limpeza de dados do navegador, transação Firestore atravessando documento de festa + subcoleção, e a forma de rewrite do Hosting que preserva a URL `/c/:codigo` num app Flutter Web.

**O que esta spec deixa para as outras:** a contribuição de RN-20 pronta para a spec 10 exibir no acerto; o produtor de RN-28 que a spec 04 já sabe consumir; as security rules que toda feature futura herda; e as implementações Firestore das portas, que passam a ser o caminho de produção das specs 04 a 07.

---

## Divergências encontradas na spec-fonte

Registradas para que ninguém as "corrija" adiante sem saber que foram vistas.

| # | Divergência | Resolução adotada |
|---|---|---|
| **D-1** | **A copy de T-08 concorda em gênero com a persona Ana** — "ANA, VOCÊ FOI CHAMADA", "O Rafa já vê você como confirmada" — mas o produto não tem campo de gênero em lugar nenhum: `Pessoa` (arquivo 01 §6) não o modela, e os steppers H/M/C de RN-01 são extras anônimos, não pessoas | A-02: as duas frases são reescritas sem gênero — "{NOME}, TE CHAMARAM PRO ROLÊ" e "✅ O {ANFITRIAO} já sabe que você vai." O resto de T-08 fica literal. É **copy nossa numa tela literal**, declarada, não silenciada |
| **D-2** | **T-08 não escreve copy para nenhum estado de erro** — código inválido, festa passada, falha de escrita, falha de auth — e a página do convidado não pode cair em `/erro`, que tem chrome de app (W-04) | A-11, A-12, A-14, A-25: cinco textos inventados, todos declarados aqui — "ESSE LINK NÃO EXISTE" / "confere o link com quem te chamou." · "ESSE ROLÊ JÁ ROLOU" · "NÃO DEU PRA CONFIRMAR" / "sem internet? tenta de novo." / "TENTAR DE NOVO →" · e o título de aba "{FESTA} — bora". Todos seguem a voz do arquivo 02 (título em CAIXA ALTA, corpo em sentence case) |
| **D-3** | **AD-026 diz que o papel é lido "no instante da abertura"**, mas um cliente anônimo pode declarar o que quiser — não existe leitura de abertura confiável no servidor | A-10: o papel é resolvido **no servidor, no instante da escrita**, e congelado. O nível lido na abertura continua governando o que o convidado **vê** (CVD-28). O aceite observável de UC-13 — trocar o nível não retroage sobre quem já está dentro — fica preservado exatamente; a diferença aparece só na janela entre abrir e confirmar, e nela vale o **menor privilégio** |
| **D-4** | **A spec 07 (A-05) delegou a esta spec o "cada um edita as próprias" de UC-11** — as preferências declaradas pelo convidado — mas **T-08 não desenha controle de preferência nenhum**: nem dieta, nem bebida, em nenhum dos quatro estados | A-20: esta spec **declina**. Implementar seria inventar seção, rótulos e layout numa tela literal. A `Pessoa` do convidado nasce com `dieta: null` e `bebe: null`, que é exatamente o caso da Duda e que a Galera já renderiza (`galera` A-14). Fica como **lacuna declarada do MVP**, registrada em `context.md` §Deferred Ideas — e UC-11 continua sem ator convidado até que alguma spec desenhe a tela |
| **D-5** | **T-08 lista "🧄 Pão de alho R$ 24" entre os itens disponíveis e, na mesma tela, diz "🥩 RAFA já leva as carnes e o pão de alho"** — o mesmo item nos dois lugares | A-17: a derivação vence o exemplo. A lista é dos itens **sem dono** e a dica é dos itens **com dono**; os conjuntos são disjuntos por construção, o que é obrigatório para a exclusividade de A-07 fazer sentido. Os valores literais de T-08 (cerveja 72, gelo 30, refri 18, água 6, cachaça 15) continuam batendo com RN-05..RN-10 no estado padrão |
| **D-6** | **T-08 põe "💸 VER O ACERTO DA FESTA →" na tela do convidado**, mas **RN-28** define esse atalho como o da **Home do anfitrião**, e a spec 04 já o entregou lá (HOME-10) | A-06: sai da tela do convidado. O qualificador "no fluxo" de T-08 marca a narração da demo — a mesma marca que o arquivo 04 usa no "Mapa de etapas", declarando-o não-produto. O banner roxo sai pelo mesmo motivo; a nota "✅ O {ANFITRIAO} já sabe que você vai." fica, porque afirma o estado do próprio convidado |
| **D-7** | **RN-22 dá ao CONVIDADO "ajusta a lista"**, mas T-08 só desenha "EU LEVO" ⇄ "VOCÊ LEVA ✓" | A-19: as rules permitem o que RN-22 manda (CVD-31), a tela desta spec não oferece. Estreitar as rules contradiria RN-22 e travaria a spec 06; desenhar o ajuste inventaria tela |

---

## Success Criteria

- [ ] `flutter analyze` = zero issues · suíte inteira verde, **baseline preservada**, e ainda rodando **sem emulador** (CVD-33 AC3).
- [ ] Aceite de **UC-08** verificável: percorrendo os quatro estados de T-08, nenhuma etapa pede download ou cadastro — afirmado por ausência na árvore, não por inspeção visual.
- [ ] Aceite de **UC-09** verificável: o valor escolhido pelo convidado aparece como contribuição dele quando `core/calculo` calcula o acerto da festa.
- [ ] Aceite de **UC-10** verificável: recusar não pede justificativa, e "MUDEI DE IDEIA ✊" devolve ao convite com o RSVP recontado corretamente.
- [ ] Aceite de **UC-13** preservado do lado do servidor: quem entrou com um papel o mantém quando o anfitrião troca o nível.
- [ ] A transição literal de **RN-28** — "4 confirmados · 2 pendentes" → "5 confirmados · 1 pendente" mais o atalho "💸 VER O ACERTO DA FESTA →" — passa ponta a ponta, do toque do convidado à Home do anfitrião, sem refresh.
- [ ] O invariante de **AD-022** (`confirmados` = nº de pessoas nomeadas confirmadas) é afirmado **depois de cada uma das seis transições** de RSVP — a pendência **D-5** fecha aqui.
- [ ] Cada linha da tabela de escrita das rules (CVD-31) tem par permitido/negado verificado contra o emulador.
- [ ] Nenhuma fórmula de RN-13, RN-14, RN-15 ou RN-20 existe em `lib/features/convidado/` — varredura automatizada.
- [ ] Nenhum literal de cor, fonte ou sombra em `lib/features/convidado/**` (guarda de pureza da spec 01).
- [ ] Nenhum arquivo de `presentation/` ou `domain/` das specs 04, 05, 06 e 07 aparece no diff desta spec (CVD-33 AC2).
- [ ] Toda copy da tela é literal de T-08 / RN-24 / RN-29, exceto as sete strings declaradas em **D-1** e **D-2**.
