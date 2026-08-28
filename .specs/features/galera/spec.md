# A galera — Specification

**ID prefix:** `GAL` · **Porte:** **Grande** (ver §Porte)
**Design:** `.specs/features/galera/design.md` ✅
**Tasks:** `.specs/features/galera/tasks.md` — pendente
**Context:** `.specs/features/galera/context.md`
**Spec-fonte:** T-05 (`04-telas-ux.md`) · W-04 linha "A galera" + W-R1..W-R5 (`06-telas-web.md`) · UC-11, UC-12, UC-13 (`05-casos-de-uso.md`) · RN-21, RN-22, RN-23 (`03-regras-de-negocio.md`) · RN-13, RN-29, RN-30 (consumo) · arquivo 01 §4/§5/§6/§7
**Roadmap:** `.specs/ROADMAP.md` — spec 07, marco M2
**Decisões ativas herdadas:** AD-001..AD-028 · **AD-026** (link perpétuo, papel lido na abertura) · **AD-022** (contadores são dado, não derivação) · **AD-016/AD-021** (dado de festa em memória atrás de porta) · **AD-008** (entidades em `core/calculo/dominio/`) · **AD-018** (o seletor "QUEM LEVA?" depende da lista de confirmados que nasce aqui)
**Depende de:** spec 01 `design_system`, spec 02 `calculo`, spec 04 `home` (porta `FestaRepository` e o formato do stream de RN-28)

## Problem Statement

`/roles/:festaId/galera` é hoje um `PlaceholderPage`. É a tela onde o anfitrião faz as duas coisas que o resto do produto pressupõe e ninguém entrega: **abrir a festa para quem ainda não está nela** (o link único de RN-23, com o papel que quem abrir vai receber) e **declarar quem come e bebe o quê** (RN-21), que é o que faz a lista se ajustar sozinha — kit veggie quando há veggie, sem suína quando há "sem porco", cerveja dimensionada por quem bebe.

O efeito de RN-21 já existe, testado, em `core/calculo`. O que não existe é a superfície que o alimenta: sem T-05 as preferências da fixture RN-30 nunca mudam, e o diferencial "a lista já se ajusta" é uma frase sem gesto que a produza.

Esta spec também é onde **RN-22 nasce como regra de domínio**. Nenhuma feature anterior precisou saber o que um `CONVIDADO` pode fazer que um `SÓ VÊ` não pode; a partir daqui, `convite`, `convidado` e `custos` consultam essa tabela em vez de cada uma reinventar a sua — e as security rules do Firestore (spec 09) traduzem a mesma tabela para o servidor.

## Goals

- [ ] `/roles/:festaId/galera` renderiza T-05 em compacto e a linha "A galera" de W-04 em expandido, com a copy literal das specs 04, 06 e 03.
- [ ] O card do link mostra `bora.app/c/<codigo>`, o segmented dos três níveis de RN-23 e a **nota dinâmica literal** de cada nível.
- [ ] "COPIAR 🔗" e "+ CONVIDAR MAIS GENTE 🔗" copiam o link e mostram o toast literal "LINK COPIADO 🔗" (RN-29).
- [ ] Mudar a dieta ou a bebida de alguém atualiza a sublinha da pessoa, a faixa amarela de RN-21 **e a lista da festa**, consumindo `core/calculo` — nenhuma fórmula é reescrita aqui.
- [ ] O papel de cada pessoa é alterável entre CONVIDADO / CO-ANFITRIÃO / SÓ VÊ; o do anfitrião não, e o painel dele mostra só "👑 Anfitrião manda em tudo — acesso fixo."
- [ ] A tabela de permissões de RN-22 existe como domínio consultável, capacidade por capacidade, e é o que as specs 08/09/10 herdam.
- [ ] Trocar o nível do link **não altera** o papel de quem já entrou (AD-026 / aceite de UC-13).
- [ ] Festa só com o anfitrião, ou sem pessoa nomeada nenhuma, renderiza sem quebrar e sem copy inventada.

## Out of Scope

Explicitamente excluído. Documentado para impedir alargamento.

| Item | Razão |
|---|---|
| A mensagem de convite e o grupo do WhatsApp | Spec 08 `convite` (T-06, T-07 · UC-07, UC-17, UC-18 · RN-25, RN-26, RN-26b). Aqui o link só é **copiado**; para onde ele é colado não é problema desta tela. |
| O que o convidado vê ao abrir o link | Spec 09 `convidado` (T-08 · UC-08, UC-09, UC-10 · RN-24). Esta spec **configura** o papel; quem o aplica na abertura é a 09. |
| Security rules do Firestore que aplicam RN-22 | Spec 09 `convidado`. Aqui RN-22 nasce como **regra de domínio**; o *enforcement* é transversal — cada feature respeita o papel, e o servidor é da 09. |
| Firestore, models, serialização, geração do código do link | **AD-016**: M1/M2-pré-09 é em memória atrás de porta. Gerar `codigo` é da 09/Functions (A-03). |
| A lista da festa (itens, overrides, corredores, pedido) | Spec 06 `lista` (T-04 · UC-05, UC-06, UC-14..UC-16). A Galera **produz o efeito** de RN-21 sobre a lista; ela não desenha item nenhum. |
| O seletor "QUEM LEVA?" | **AD-018** o adiou para `galera`/`lista` no formato popover — mas ele mora na **lista**, que é onde os itens estão. Esta spec entrega a matéria-prima dele: a lista de confirmados. |
| Acerto, cota, saldos, cobrança | Spec 10 `custos` (T-09 · UC-19..UC-23 · RN-14..RN-19). RN-14 continua valendo: criança nunca entra no racha, e esta tela não mexe nisso. |
| Adicionar pessoa nomeada à mão ("+ pessoa") | Nenhum UC existe (A-02). O CTA literal de T-05 é "+ CONVIDAR MAIS GENTE 🔗", e ele **copia o link** — é essa a forma de adicionar gente no produto. |
| Remover pessoa da festa | Nenhuma tela de 04 ou 06 desenha a ação, e RN-22 não tem capacidade correspondente (A-04). |
| Revogar ou expirar o link | **AD-026**: o link é perpétuo. Botão de revogar seria UI fora da spec-fonte. |
| Steppers "extras sem app" (Homens/Mulheres/Crianças) | São de T-03, spec 05 `montar` (RN-01). Extras não são `Pessoa` e não aparecem em T-05. |
| Barra de abas da festa (`FestaTabsShell` revestido) | Spec 06 `lista` (A-18). A Galera é alcançável e testável sem ela. |
| Cor de avatar por pessoa | Token do arquivo 02 §1, já entregue pela spec 01 (`BoraAvatar`). |

---

## Fronteira de arquivos

| Pode tocar | Não pode tocar |
|---|---|
| `lib/features/galera/**` | `lib/core/calculo/**` · `lib/core/design_system/**` |
| `lib/core/di/injector.dart` — **só** registro dos próprios | `lib/features/home/**` (a porta `FestaRepository` é consumida como está — ver A-01) |
| `test/features/galera/**` | `lib/core/routing/**` (a rota `galeraPattern` já existe desde a fundação) |
| `test/fixtures/**` — **só** estender com `codigo` e `nivelDoLink` da festa RN-30 (A-03, A-12) | `lib/features/{montar,lista,convite,convidado,custos}/**` |
| | `.specs/{STATE,ROADMAP,LESSONS}.md`, `.specs/lessons.json` |
| | qualquer teste existente — a baseline não pode ser enfraquecida nem apagada |

---

## Assumptions & Open Questions

O ROADMAP **não marcou Discuss** para esta spec, e nenhuma destas ambiguidades foi levada ao usuário. Cada uma está resolvida aqui com default escolhido e racional — nenhuma fica silenciosamente em aberto. As mesmas entradas estão em `context.md` §"Declined / Undiscussed Gray Areas".

| # | Ambiguidade | Default escolhido | Racional | Confirmado? |
|---|---|---|---|---|
| A-01 | Como a Galera lê pessoas, código e nível do link — `FestaRepository` não expõe nenhum dos três | **Porta própria** `GaleraRepository` em `features/galera/domain/`, reativa (`Stream`), impl em memória sobre **a mesma fonte de dado** da Home. `FestaRepository` não muda | Seis specs já consomem `FestaRepository` (AD-016); alargá-lo por causa de uma tela é mudar contrato herdado. A porta própria segue a forma da AD-016 e some no M2 atrás de Firestore. *Fonte única de dado é obrigação, não detalhe — é o que faz GAL-09 passar.* | n |
| A-02 | **Não existe caso de uso de adicionar pessoa nomeada** — a spec-fonte só tem o link (UC-13) e os steppers de extras (RN-01) | **Sem "+ pessoa" manual.** Pessoa nomeada nasce de duas fontes só: o RSVP pelo link (spec 09, RN-24) e a fixture RN-30 | O CTA literal do rodapé de T-05 é "+ CONVIDAR MAIS GENTE 🔗" e ele **copia o link** — a spec-fonte responde "como adiciono gente?" com o link, não com um formulário. Inventar um formulário criaria uma pessoa sem RSVP, que a AD-022 não sabe contar | n |
| A-03 | Origem do `codigo` (`rafa18`) — quem gera, quando, é estável? | **Atributo da festa**, estável e perpétuo (AD-026). A Galera **lê**, nunca gera. Geração e unicidade são da spec 09/Functions. A fixture RN-30 ganha `codigo: 'rafa18'` | `bora.app/c/rafa18` é literal em RN-23 e RN-26b, e a festa de RN-30 é a do Rafa — a ligação é leitura, não invenção. Gerar código exige unicidade global, que só o servidor da 09 pode garantir | n |
| A-04 | Remover pessoa da festa | **Não oferecido.** Nenhum controle, nenhuma rota | Nenhuma tela de 04/06 desenha; RN-22 não tem capacidade correspondente; e remover confirmado dessincronizaria o contador da AD-022 sem produtor que o conserte | n |
| A-05 | **Quem edita as preferências de quem.** UC-11 diz "cada um edita as próprias", mas o ator é "anfitrião/co-anfitrião" — e T-05 diz que o painel do anfitrião tem **só** a nota 👑 | **T-05 é literal.** Anfitrião e co-anfitrião editam a dieta e a bebida de **qualquer pessoa exceto o próprio anfitrião**, cujo painel expandido mostra apenas "👑 Anfitrião manda em tudo — acesso fixo.". "Cada um edita as próprias" é o lado do convidado, na spec 09 | Entre a tela literal e o parêntese do ator, vale a tela: T-05 desenha os três controles só "para os demais". O parêntese descreve o fluxo do RSVP (UC-08/09), onde o convidado declara as próprias preferências sem passar por T-05. **Divergência declarada** — ver §Divergências | n |
| A-06 | Efeito imediato de RN-21 sobre um item que já tinha **override** de RN-12 | O override **sobrevive e continua vencendo**. Se RN-21 remover o item (suína × "sem porco"), o item sai da lista e o override fica guardado na composição; desfazer a preferência traz o item de volta com o override intacto. Só "RESTAURAR" (RN-12) limpa override | É o comportamento que `core/calculo` já tem: `comPassoDeQuantidade` "cobre o valor automático sem apagá-lo", e a remoção de RN-21 mexe no conjunto de itens, não no mapa de overrides. O override é a palavra explícita do usuário; RN-21 recalcula o automático, não revoga a palavra dele | n |
| A-07 | Copiar para a área de transferência — comportamento e feedback em mobile e web | `Clipboard.setData` nas duas plataformas, atrás de porta própria para ser testável. **O feedback é só o toast** "LINK COPIADO 🔗" (RN-29 literal, 2200 ms, 1 por vez). Falha → **nenhum** toast de sucesso, registro no `AppLogger` (AD-005), e o link continua visível e selecionável | RN-29 dá o texto de sucesso e nenhum de falha; inventar copy de erro violaria "copy literal". No web a cópia depende de gesto do usuário e de permissão do navegador — um toast de sucesso após falha seria mentira testável | n |
| A-08 | **Estado vazio** — festa só com o anfitrião, ou sem pessoa nomeada nenhuma | Só o anfitrião: uma linha na seção PESSOAS e a faixa amarela com o resumo que sobrar. **Zero pessoas**: sub lê "nenhuma pessoa ainda", a seção PESSOAS renderiza sem linhas e **sem copy inventada**, a faixa amarela não renderiza, e o card do link + o CTA permanecem | Mesma forma da A-03 da spec `home` ("nenhuma festa chegando"): o caminho adiante tem de continuar visível. A faixa some porque `resumoDasPreferencias` devolve string vazia quando não há termo, e "💡" seguido de nada seria pior que silêncio (decisão já tomada em `core/calculo`) | n |
| A-09 | Trocar o nível do link **com convidados já dentro** — o que a UI comunica, dado que AD-026 diz que o papel deles não muda | **Nenhuma copy nova.** As três notas de RN-23 continuam literais e o label "QUEM ABRIR O LINK PODE…" já está no futuro — ele fala de quem **vai** abrir. A garantia é **comportamental** e vira critério (GAL-04), não texto | Acrescentar aviso seria inventar copy num produto de copy literal, e T-05/W-04 não desenham nenhum. Um aceite comportamental discrimina melhor que uma frase: a frase passa mesmo se o papel retroagir | n |
| A-10 | O sub "5 pessoas · 4 confirmadas" tem números fixos na spec | **Derivado** da lista de nomeados: `{n} pessoa(s) · {n} confirmada(s)`, com plural correto. Com a fixture RN-30 dá exatamente o literal de T-05 | Precedente A-05 da spec `home`. Literal fixo mentiria em qualquer outro estado; o aceite continua sendo a string de T-05, agora como consequência do dado | n |
| A-11 | O pendente **sem nome** — RN-30 tem 2 pendentes na Home e só 1 pendente nomeada (Duda) | T-05 lista **só pessoas nomeadas**. A Galera **não** renderiza o excedente, **não** deriva `pendentes` e **nunca** escreve contador | É o custo declarado da AD-022 (D-5 do `validation.md` da `home`): "pendente" conta também quem recebeu o link e não respondeu, e essa pessoa não tem nome, avatar, preferência nem papel para exibir. A obrigação de reconciliar é da spec 09, que grava RSVP e contador na mesma escrita (RN-28) | n |
| A-12 | Nível inicial do link, e o que fazer com valor ausente ou desconhecido no dado | Festa nova/fixture nasce em **EDITAR LISTA**. Valor **ausente ou desconhecido** no dado resolve para **SÓ VER** | São situações diferentes. O default do produto é EDITAR LISTA porque o fluxo canônico (RN-24 → UC-09 → RN-20, "o que você levar desconta da sua parte") exige que o convidado marque itens — com SÓ VER a promessa do produto não funciona sem configuração. Já dado corrompido ou de versão futura resolve por **menor privilégio**: nunca conceder edição por falta de informação | n |
| A-13 | Rótulos dos botões de "RESTRIÇÃO ALIMENTAR" — T-05 escreve só "🍖/🥗/🚫" | Emoji **+ rótulo literal de RN-21**: "🍖 Come de tudo", "🥗 Veggie", "🚫 Sem porco" | RN-21 dá os três rótulos por extenso; "(🍖/🥗/🚫)" em T-05 é abreviação de enumeração, não afirmação de que o botão é só emoji. Botão de emoji sozinho não passa o mínimo de legibilidade do arquivo 02 | n |
| A-14 | Sublinha de pessoa com dieta ou bebida **não declarada** (a Duda de RN-30) | Omite o termo não declarado; com os dois ausentes, a sublinha **não renderiza** | `Pessoa.dieta`/`bebe` são anuláveis de propósito em `core/calculo` (`null` = não declarado, distinto de `tudo` e de `false`). Escrever "não informado" seria copy inventada; e a omissão é a mesma regra que RN-21 já usa para termos zerados | n |
| A-15 | Ordem da lista de pessoas | **Ordem do repositório**, sem reordenar por papel, nome ou status | Ordem de entrada é comportamento observável no racha (A-14 de `calculo`); reordenar aqui faria a Galera discordar de qualquer outra lista da mesma festa sem que nada avisasse | n |
| A-16 | Orçamento de acento do arquivo 02 §8 — **máx. 2 por tela** — e T-05 usa roxo, amarelo e vermelho | Os dois acentos **estruturais** de T-05 são **roxo** (galera/link: sombra do card, sombra do CTA) e **amarelo** (label do card escuro, faixa de RN-21, tag ANFITRIÃO). O **vermelho** entra só como **estado ativo** dos botões de RESTRIÇÃO ALIMENTAR, nunca como cor de superfície | T-05 é literal nos três usos e cada um carrega o significado fixo que §1 lhe dá. Estado ativo de controle não é acento de tela — mas a leitura estrita de §8 conta 3. **Divergência declarada** — ver §Divergências | n |
| A-17 | No web, onde mora o CTA "+ CONVIDAR MAIS GENTE 🔗" — W-R2 diz que rodapé fixo não existe no web | Na **coluna esquerda**, logo abaixo do card do link, dentro da coluna de 370px | W-04 fixa o card do link à esquerda e os accordions à direita; o CTA é da mesma família do "COPIAR 🔗" (mesma ação, A-07) e pertence à mesma coluna. É o análogo do "o CTA mora no rail" de W-R2 | n |
| A-18 | A barra de abas da festa não existe — o `FestaTabsShell` é `navigationShell` cru | A Galera **não** reveste o shell (é da spec 06 `lista`) e tem de ser alcançável e testável sem barra de abas: abrir `/roles/:festaId/galera` direto renderiza a tela | O roadmap dá `galera` como dependente de 01, 02 e 04 — não de 06. Depender da barra inverteria a ordem e travaria esta spec numa que ainda não foi especificada | n |
| A-19 | RN-22 não distingue "tudo" (ANFITRIÃO) de "edita tudo e cobra a galera" (CO-ANFITRIÃO) | A diferença são **duas capacidades exclusivas do anfitrião**: gerenciar papéis e configurar o nível do link | UC-12 diz "**Ator:** somente anfitrião" e UC-13 "**Ator:** anfitrião", enquanto UC-11 diz "anfitrião/co-anfitrião". As três linhas juntas definem exatamente a fronteira que a tabela de RN-22 deixou implícita | n |

**Open questions:** nenhuma — todas resolvidas ou registradas acima.

---

## Varredura de dimensões implícitas (porte Grande — todas resolvidas)

| Dimensão | Cobertura |
|---|---|
| Input validation & bounds | GAL-21 — o nível é enum fechado de 3 valores; ausente ou desconhecido resolve para SÓ VER (menor privilégio, A-12). **Sem entrada de texto livre nesta tela**: o resto da dimensão é **N/A because** toda interação é seleção de enum ou toque em botão |
| Failure / partial-failure | GAL-05 (área de transferência falha → sem toast de sucesso, link permanece copiável à mão) e GAL-25 (repositório falha → estado de erro visível, nunca tela branca) |
| Idempotency / retry / duplicate | GAL-28 — tocar a opção já ativa não muda estado nem emite escrita; tocar COPIAR duas vezes produz **um** toast por vez (RN-29), nunca dois empilhados |
| Auth boundaries & rate limits | GAL-19 (a tabela de RN-22, capacidade por capacidade), GAL-20 (gerenciar papéis e nível do link são exclusivos do anfitrião, A-19), GAL-27 (a tela sem essas capacidades). Guarda de rota herdada da AD-017. **Rate limit: N/A because** o link é perpétuo e sem quota (AD-026) e a tela não faz chamada externa |
| Concurrency / ordering | GAL-26 (RSVP chegando pelo stream com um accordion aberto não fecha o accordion nem descarta a edição em curso) e A-15 (ordem do repositório, nunca reordenada) |
| Data lifecycle / expiry | **N/A because** AD-026 fixa o link como perpétuo — sem expiração e sem revogação — e remover pessoa está fora de escopo (A-04). Nada nesta tela tem TTL, arquivamento ou exclusão |
| Observability | GAL-25 — falha do repositório e falha de cópia registradas no `AppLogger` (AD-005) |
| External-dependency failure | GAL-05 — a **área de transferência é a única dependência externa** desta tela; Firestore só entra no M2 (AD-016) e o contrato de falha nasce agora para a 09 não improvisar |
| State-transition integrity | GAL-04 (trocar o nível **não** retroage sobre quem já entrou), GAL-17 (mudar o papel de X não toca no de Y) e GAL-18 (o anfitrião é exatamente 1, nunca atribuível e nunca removível) |

---

## User Stories

### P1: O card do link e o nível de acesso ⭐ MVP

**User Story**: Como anfitrião, quero copiar o link da festa já sabendo o que quem abrir vai poder fazer, para chamar a galera sem abrir mão do controle.

**Why P1**: É UC-13 inteiro e a metade da tela que o produto inteiro pressupõe — sem link copiável não há spec 08 nem spec 09.

**Acceptance Criteria**:

1. WHEN a Galera abre THEN o card do link SHALL renderizar, na ordem de T-05: fundo escuro com **sombra roxa**, label amarela "LINK PRA CONVIDAR", a URL `bora.app/c/<codigo>` sublinhada, o botão claro "COPIAR 🔗", a label "QUEM ABRIR O LINK PODE…" e o segmented creme com exatamente três opções — "SÓ VER", "EDITAR LISTA", "CO-ANFITRIÃO".
2. WHEN a festa é a da fixture RN-30 THEN a URL exibida SHALL ser exatamente `bora.app/c/rafa18` (A-03).
3. WHEN o nível ativo é SÓ VER THEN a nota do card SHALL ler exatamente "convidados só veem a festa e confirmam presença".
4. WHEN o nível ativo é EDITAR LISTA THEN a nota do card SHALL ler exatamente "convidados marcam o que levam e ajustam a lista".
5. WHEN o nível ativo é CO-ANFITRIÃO THEN a nota do card SHALL ler exatamente "acesso total: editam tudo e cobram a galera".
6. WHEN "COPIAR 🔗" é acionado THEN o sistema SHALL escrever a URL completa na área de transferência **e** exibir o toast "LINK COPIADO 🔗" — texto, emoji e duração de 2200 ms literais de RN-29.
7. WHEN "+ CONVIDAR MAIS GENTE 🔗" (rodapé, sombra roxa) é acionado THEN SHALL produzir **exatamente o mesmo efeito** do AC6 — mesma URL, mesmo toast (UC-13 passo 3).
8. WHEN o nível é alterado no segmented THEN o novo nível SHALL persistir no repositório e a nota SHALL trocar para a do AC3/AC4/AC5 correspondente, **sem** toast.

**Independent Test**: montar a tela com um repositório-duplo semeado pela fixture; afirmar cada literal do card, percorrer os três níveis afirmando a nota literal de cada um, e afirmar conteúdo da área de transferência + presença do toast nos dois botões.

---

### P1: O papel de quem já entrou não muda ⭐ MVP

**User Story**: Como anfitrião, quero que apertar o nível do link não mexa em quem já está na festa, para não rebaixar nem promover ninguém sem querer.

**Why P1**: É o aceite literal de UC-13 e a AD-026. Sem ele o segmented vira uma alavanca que reescreve a festa inteira.

**Acceptance Criteria**:

1. WHEN o nível do link é alterado de X para Y THEN o `papel` de **toda** pessoa já existente na festa SHALL permanecer inalterado — nenhuma exceção, nem para quem entrou pelo nível X.
2. WHEN o nível do link é alterado THEN as tags de papel exibidas na seção PESSOAS SHALL continuar idênticas, item a item, às de antes da alteração.
3. WHEN o nível do link é alterado THEN **nenhuma** copy nova SHALL aparecer na tela: as notas de RN-23 continuam sendo as três do P1-1, e nenhum aviso sobre convidados já dentro é renderizado (A-09).
4. WHEN a tela não tem nenhuma pessoa nomeada e o nível é alterado THEN o comportamento SHALL ser o mesmo — só o nível muda.

**Independent Test**: repositório com as cinco pessoas de RN-30; capturar os papéis, percorrer os três níveis, afirmar a lista de papéis **igual** à capturada e a ausência de qualquer texto fora das notas de RN-23. *(O par discriminante é a igualdade item a item: afirmar só "a tela ainda renderiza" passaria com os papéis reescritos.)*

---

### P1: Ver a galera ⭐ MVP

**User Story**: Como anfitrião, quero ver quem está na festa, o que cada um come e bebe e com que acesso, para saber com quem estou contando.

**Why P1**: É a leitura de T-05 e a pré-condição declarada de UC-11, UC-12 e UC-13 ("Pré: tela 'A GALERA'").

**Acceptance Criteria**:

1. WHEN a Galera abre THEN o header SHALL exibir o título "A GALERA" e o sub derivado `{n} pessoas · {n} confirmadas` (A-10).
2. WHEN a festa é a da fixture RN-30 THEN o sub SHALL ler exatamente "5 pessoas · 4 confirmadas" — literal de T-05, como consequência do dado.
3. WHEN a seção "PESSOAS" renderiza THEN SHALL conter um card-linha por pessoa nomeada, na ordem do repositório (A-15), cada um com avatar colorido, nome, tag de papel e caret.
4. WHEN a pessoa é o usuário do app (`voce`) THEN o card SHALL exibir o badge "VOCÊ"; WHEN não é THEN o badge SHALL estar ausente.
5. WHEN a pessoa declarou dieta e bebida THEN a sublinha SHALL ler `{dieta} · bebe 🍺` ou `{dieta} · não bebe 🚫`, com a dieta pelo rótulo literal de RN-21 (A-13).
6. WHEN a pessoa não declarou um dos dois THEN a sublinha SHALL omitir o termo não declarado; WHEN não declarou nenhum dos dois THEN a sublinha SHALL não renderizar (A-14 — o caso da Duda).
7. WHEN a tag de papel renderiza THEN SHALL usar a cor de significado fixo do arquivo 02 §5: ANFITRIÃO amarelo, CO-ANFITRIÃO roxo com texto branco, CONVIDADO branco, SÓ VÊ `wa-bubble` com texto `text-2`.
8. WHEN a mesma festa é lida pela Home e pela Galera THEN o `confirmados` do card da Home SHALL ser **igual** à contagem de pessoas nomeadas com status confirmado nesta tela — 4 com a fixture RN-30 (AD-022).
9. WHEN a Galera renderiza THEN SHALL **não** exibir contagem de pendentes nem qualquer representação do pendente sem nome, e SHALL **não** escrever contador algum (A-11).

**Independent Test**: repositório-duplo com a fixture; afirmar o sub literal, uma linha por pessoa na ordem da fixture, o badge presente só no Rafa, a sublinha de cada um (inclusive a ausência na Duda), a cor de cada tag contra o token, e a igualdade do AC8 contra o `ResumoDeFesta` da mesma festa.

---

### P1: Preferências que realimentam a lista ⭐ MVP

**User Story**: Como anfitrião, quero marcar que fulano é veggie ou não bebe, para a lista se ajustar sozinha sem eu recalcular nada.

**Why P1**: É UC-11 inteiro e o diferencial que RN-21 promete. É também o gesto que faltava: o efeito já existe em `core/calculo` e nunca teve quem o produzisse.

**Acceptance Criteria**:

1. WHEN um card-linha de pessoa é tocado THEN SHALL expandir o painel dela; WHEN outro é tocado THEN o anterior SHALL fechar — **1 aberto por vez** (arquivo 02 §5).
2. WHEN o painel de uma pessoa que não é o anfitrião abre THEN SHALL conter as três seções de T-05, nesta ordem: "NÍVEL DE ACESSO" (ativo preto), "RESTRIÇÃO ALIMENTAR" (ativo vermelho) e "BEBIDA" (toggle "BEBE 🍺" ✓ / "NÃO BEBE 🚫", ativo preto).
3. WHEN uma opção de "RESTRIÇÃO ALIMENTAR" é escolhida THEN a `dieta` daquela pessoa SHALL passar ao valor correspondente (`tudo` / `veggie` / `semPorco`) e a sublinha do card SHALL refletir a mudança imediatamente.
4. WHEN o toggle de "BEBIDA" é acionado THEN o campo `bebe` daquela pessoa SHALL alternar e a sublinha SHALL refletir a mudança imediatamente.
5. WHEN a composição de preferências muda THEN a faixa amarela de borda 2px SHALL exibir "💡 " seguido **exatamente** da string devolvida por `resumoDasPreferencias` de `core/calculo` — com os termos zerados omitidos, como RN-21 manda, e sem recomposição de copy nesta feature.
6. WHEN a festa é a da fixture RN-30 THEN a faixa SHALL ler exatamente "💡 A lista já se ajusta às preferências: 1 veggie 🥗 · 1 sem porco 🚫 · 3 bebem 🍺".
7. WHEN nenhum dos três termos é maior que zero THEN a faixa amarela SHALL **não** renderizar (A-08).
8. WHEN há pelo menos uma pessoa veggie THEN a lista da festa SHALL conter o item "Legumes p/ grelha (kit veggie)"; WHEN não há nenhuma THEN o item SHALL estar ausente (aceite de UC-11, via `core/calculo`).
9. WHEN há pelo menos uma pessoa "sem porco" THEN a carne suína SHALL sair da lista mesmo estando selecionada; WHEN não há nenhuma THEN a suína selecionada SHALL permanecer (aceite de UC-11).
10. WHEN há pessoas nomeadas THEN a quantidade de cerveja SHALL ser dimensionada por `adultosQueBebem` de RN-21, e **não** por `adultos` de RN-05 (aceite de UC-11).
11. WHEN qualquer aritmética de AC8/AC9/AC10 é necessária THEN SHALL vir de `package:bora/core/calculo/calculo.dart` — **nenhuma fórmula de RN-21, RN-03 ou RN-05 SHALL ser escrita em `lib/features/galera/`**.
12. WHEN um item da lista já tinha override de RN-12 e uma preferência muda THEN o override SHALL sobreviver e continuar prevalecendo sobre o valor automático recalculado (A-06).

**Independent Test**: com a fixture, alternar a dieta da Bia de `semPorco` para `tudo` e afirmar (a) a sublinha nova, (b) a faixa amarela nova, (c) a suína de volta na lista; desmarcar a bebida do Léo e afirmar a queda da cerveja. Um teste de varredura afirma que nenhum arquivo de `lib/features/galera/` contém as constantes de RN-03/RN-05/RN-21.

---

### P1: Nível de acesso por pessoa ⭐ MVP

**User Story**: Como anfitrião, quero promover alguém a co-anfitrião ou rebaixar a só-vê, para dividir o trabalho sem perder o comando.

**Why P1**: É UC-12 inteiro, incluindo a exceção E1 — e é o gesto que dá sentido à tabela de RN-22.

**Acceptance Criteria**:

1. WHEN o painel de uma pessoa que **não** é o anfitrião abre THEN "NÍVEL DE ACESSO" SHALL oferecer exatamente três botões — "CONVIDADO", "CO-ANFITRIÃO", "SÓ VÊ" — com o ativo em preto.
2. WHEN um dos três é escolhido THEN o `papel` daquela pessoa SHALL passar ao valor correspondente e a tag do card SHALL trocar para a cor daquele papel (§5).
3. WHEN o papel de uma pessoa muda THEN o papel de **nenhuma outra** pessoa SHALL mudar.
4. WHEN o painel do **anfitrião** abre THEN SHALL exibir **somente** a nota "👑 Anfitrião manda em tudo — acesso fixo." — e "NÍVEL DE ACESSO", "RESTRIÇÃO ALIMENTAR" e "BEBIDA" SHALL estar **ausentes** da árvore, não apenas desabilitados (E1 de UC-12, T-05, A-05).
5. WHEN qualquer caminho da tela é exercido THEN **nenhum** SHALL atribuir o papel ANFITRIÃO a alguém, e a festa SHALL continuar com exatamente 1 anfitrião (RN-22, "fixo, 1").
6. WHEN o papel de uma pessoa muda THEN as capacidades efetivas dela SHALL passar a ser as da linha de RN-22 do novo papel (GAL-19), sem etapa intermediária.

**Independent Test**: expandir a Duda, escolher "CO-ANFITRIÃO", afirmar a tag roxa e que Rafa/Ana/Léo/Bia mantiveram os papéis; expandir o Rafa e afirmar a nota 👑 **presente** e os três controles **ausentes** (`findsNothing`), que é o par que discrimina de "desabilitado".

---

### P1: A tabela de permissões como domínio consultável ⭐ MVP

**User Story**: Como quem for construir convite, convidado e custos, quero perguntar ao domínio "este papel pode isto?", para não reimplementar RN-22 em cada feature.

**Why P1**: RN-22 nasce nesta spec (roadmap §5) e é herdada por três specs. Se não nascer consultável, nasce copiada.

**Acceptance Criteria**:

1. WHEN o papel é ANFITRIÃO THEN SHALL poder: ver a festa, confirmar presença, marcar o que leva, ajustar a lista, editar tudo, cobrar a galera, gerenciar papéis e configurar o nível do link — **todas as oito**.
2. WHEN o papel é CO-ANFITRIÃO THEN SHALL poder ver a festa, confirmar presença, marcar o que leva, ajustar a lista, editar tudo e cobrar a galera; e SHALL **não** poder gerenciar papéis nem configurar o nível do link (A-19).
3. WHEN o papel é CONVIDADO THEN SHALL poder ver a festa, confirmar presença, marcar o que leva e ajustar a lista; e SHALL **não** poder editar tudo, cobrar a galera, gerenciar papéis nem configurar o nível do link.
4. WHEN o papel é SÓ VÊ THEN SHALL poder ver a festa e confirmar presença; e SHALL **não** poder marcar o que leva, ajustar a lista, editar tudo, cobrar a galera, gerenciar papéis nem configurar o nível do link.
5. WHEN um nível de link é aplicado a quem abre THEN o papel resultante SHALL ser: SÓ VER → SÓ VÊ · EDITAR LISTA → CONVIDADO · CO-ANFITRIÃO → CO-ANFITRIÃO (RN-23 lido contra RN-22).
6. WHEN o nível do link armazenado está ausente ou é desconhecido THEN SHALL resolver para **SÓ VER** (menor privilégio, A-12); WHEN uma festa é criada sem nível explícito THEN SHALL nascer em **EDITAR LISTA**.
7. WHEN a tabela é consultada THEN SHALL viver em `lib/features/galera/domain/` como valor puro, sem import de Flutter, para que a spec 09 possa traduzi-la em security rules sem arrastar UI.

**Independent Test**: teste unitário puro que percorre os quatro papéis × as oito capacidades — 32 asserções explícitas, uma por célula, **nunca** um laço que compare o domínio consigo mesmo.

---

### P2: A galera no web

**User Story**: Como anfitrião no computador, quero a mesma tela em duas colunas, para ver o link e a galera ao mesmo tempo.

**Why P2**: W-04 dá a adaptação, mas o loop de M2 fecha no celular; o web é paridade, não pré-requisito.

**Acceptance Criteria**:

1. WHEN a Galera abre em viewport expandida THEN SHALL renderizar duas colunas: o card do link (escuro, sombra roxa) **fixo à esquerda com 370px** e a lista de pessoas com accordions à direita (W-04).
2. WHEN em expandido THEN o CTA "+ CONVIDAR MAIS GENTE 🔗" SHALL morar na coluna esquerda, abaixo do card do link, e **não** SHALL existir rodapé fixo (W-R2, A-17).
3. WHEN a viewport desce abaixo de ~900px THEN o layout SHALL colapsar para o de T-05, com o rodapé fixo de volta (W-R3), preservando o estado — accordion aberto continua aberto, nível selecionado continua selecionado.
4. WHEN a tela renderiza em qualquer largura THEN SHALL **nunca** produzir scroll horizontal (W-R4).
5. WHEN uma preferência ou um papel muda em uma plataforma THEN o mesmo estado SHALL valer na outra (W-R1) — mesma fonte, mesmo bloc, sem cópia local.
6. WHEN em expandido THEN todo elemento clicável SHALL ter estado de hover (princípio de adaptação web do arquivo 06).

**Independent Test**: montar nos dois viewports; afirmar a largura da coluna do card, a posição do CTA, a ausência do rodapé no expandido e a presença no compacto, e que o accordion aberto sobrevive à troca de viewport sem `pumpWidget` novo.

---

### P2: Estado vazio e resiliência

**User Story**: Como anfitrião de uma festa recém-criada, quero a Galera funcionando antes de qualquer pessoa entrar, para conseguir chamar a primeira.

**Why P2**: Não bloqueia UC-11/12/13 (que pressupõem gente), mas é o primeiro estado de toda festa nova vinda de `/roles/novo`.

**Acceptance Criteria**:

1. WHEN a festa tem só o anfitrião THEN SHALL renderizar uma linha na seção PESSOAS, o sub "1 pessoa · 1 confirmada" e a faixa amarela com o resumo que sobrar (termos zerados omitidos, RN-21).
2. WHEN a festa não tem pessoa nomeada nenhuma THEN o sub SHALL ler "nenhuma pessoa ainda", a seção PESSOAS SHALL renderizar sem linhas e **sem copy inventada**, a faixa amarela SHALL estar ausente, e o card do link + o CTA SHALL permanecer presentes e funcionais (A-08).
3. WHEN o repositório emite erro THEN SHALL exibir estado de falha visível — nunca tela branca — e SHALL registrar a falha no `AppLogger` (AD-005).
4. WHEN a área de transferência falha ao gravar THEN o toast "LINK COPIADO 🔗" SHALL **não** ser exibido, a falha SHALL ser registrada e a URL SHALL continuar visível na tela para cópia manual (A-07).
5. WHEN uma confirmação nova chega pelo stream com um accordion aberto THEN o accordion daquela pessoa SHALL continuar aberto, a edição em curso SHALL ser preservada e a lista SHALL incorporar a pessoa nova sem remontar a tela (RN-28, lado consumidor).
6. WHEN a opção já ativa de qualquer um dos três controles é tocada novamente THEN **nada** SHALL mudar: sem escrita no repositório, sem toast, sem reordenação (GAL-28).

**Independent Test**: repositório-duplo vazio, repositório que emite erro e porta de área de transferência que falha — três montagens, cada uma afirmando o estado descrito e a ausência do que não deve aparecer.

---

### P3: A Galera de quem não é o anfitrião

**User Story**: Como co-anfitrião, quero abrir a Galera e cuidar das preferências, sem poder mexer no que só o dono da festa decide.

**Why P3**: O arquivo 01 §4 dá T-05 para "anfitrião / co-anfitrião", mas no M2 o usuário logado é sempre o anfitrião da fixture — não há como alcançar este estado no produto ainda. A regra, porém, precisa existir antes das security rules da spec 09.

**Acceptance Criteria**:

1. WHEN o usuário do app não tem a capacidade de configurar o nível do link THEN o segmented "QUEM ABRIR O LINK PODE…" SHALL estar ausente, e o card do link SHALL continuar exibindo a URL, a nota do nível vigente e o botão "COPIAR 🔗".
2. WHEN o usuário do app não tem a capacidade de gerenciar papéis THEN a seção "NÍVEL DE ACESSO" SHALL estar ausente de **todos** os painéis, e "RESTRIÇÃO ALIMENTAR" e "BEBIDA" SHALL continuar presentes (UC-11 dá o ator como "anfitrião/co-anfitrião").
3. WHEN o usuário do app é o anfitrião THEN os dois controles do AC1 e AC2 SHALL estar presentes — o par que discrimina.

**Independent Test**: montar duas vezes com o mesmo repositório, trocando só quem é o usuário do app (Rafa, depois Ana); afirmar presença num e ausência no outro.

---

## Edge Cases

- WHEN a festa tem mais pessoas do que cabem na tela THEN a seção PESSOAS SHALL rolar no documento, sem scroll horizontal (W-R4) e sem altura fixa.
- WHEN o nome de uma pessoa é longo o bastante para estourar o card THEN SHALL quebrar ou truncar sem overflow de layout.
- WHEN duas pessoas têm o mesmo nome THEN ambas SHALL renderizar como linhas distintas — a identidade de `Pessoa` é o nome (`calculo` A-24), então o Design precisa de uma chave estável de linha, e este é o caso que a força.
- WHEN uma pessoa está com status `recusou` THEN SHALL aparecer na lista como pessoa nomeada e **não** SHALL contar no `{n} confirmadas` do sub — nenhuma spec-fonte lhe dá tratamento visual próprio, e inventar um seria copy nova.
- WHEN o código do link contém caractere que exige escape na URL THEN a URL exibida e a copiada SHALL ser a mesma string.
- WHEN o toast de RN-29 já está na tela e outra cópia é disparada THEN o segundo SHALL substituir o primeiro — 1 por vez (RN-29).
- WHEN a pessoa é o anfitrião e alguém tenta chegar ao controle de papel por outro caminho THEN o domínio SHALL recusar: a capacidade não existe para o alvo anfitrião, independentemente de quem pede.

---

## Requirement Traceability

| ID | História | Origem na spec-fonte | Fase | Status |
|---|---|---|---|---|
| GAL-01 | P1-1 AC1, AC2 | T-05 (card do link) · RN-23 · A-03 | Tasks | Mapeado |
| GAL-02 | P1-1 AC3, AC4, AC5 | **RN-23** (notas literais) · UC-13 passo 2 | Tasks | Mapeado |
| GAL-03 | P1-1 AC6, AC7 | T-05 (rodapé) · UC-13 passo 3 · **RN-29** | Tasks | Mapeado |
| GAL-04 | P1-2 AC1..AC4 | **UC-13 aceite** · **AD-026** · A-09 | Tasks | Mapeado |
| GAL-05 | P2-2 AC4 | A-07 · AD-005 (dimensões: failure, external-dependency) | Tasks | Mapeado |
| GAL-06 | P1-3 AC1, AC2 | T-05 (header) · A-10 | Tasks | Mapeado |
| GAL-07 | P1-3 AC3, AC4, AC5, AC6 | T-05 (seção PESSOAS) · **RN-21** (rótulos) · A-13, A-14, A-15 | Tasks | Mapeado |
| GAL-08 | P1-3 AC7 | arquivo 02 §5 · **RN-22** (cores por papel) | Tasks | Mapeado |
| GAL-09 | P1-3 AC8, AC9 | **AD-022** · T-05 "5 pessoas · 4 confirmadas" · A-11 | Tasks | Mapeado |
| GAL-10 | P1-4 AC1, AC2 | T-05 (expandido) · arquivo 02 §5 (accordion) | Tasks | Mapeado |
| GAL-11 | P1-4 AC3 | **RN-21** (dieta) · UC-11 passo 2 | Tasks | Mapeado |
| GAL-12 | P1-4 AC4 | **RN-21** (bebida) · UC-11 passo 2 | Tasks | Mapeado |
| GAL-13 | P1-4 AC5, AC6, AC7 | T-05 (faixa amarela) · **RN-21** (resumo agregado) · A-08 | Tasks | Mapeado |
| GAL-14 | P1-4 AC8, AC9, AC10 | **UC-11 aceite** · **RN-21** (efeitos) via `core/calculo` | Tasks | Mapeado |
| GAL-15 | P1-4 AC11, AC12 | CLAUDE.md ("nunca duplique uma fórmula na UI") · **RN-12** · A-06 | Tasks | Mapeado |
| GAL-16 | P1-5 AC4 | **UC-12 E1** · T-05 (painel do anfitrião) · A-05 | Tasks | Mapeado |
| GAL-17 | P1-5 AC1, AC2, AC3 | **UC-12** passos 1 e 2 · **RN-22** | Tasks | Mapeado |
| GAL-18 | P1-5 AC5, AC6 | **RN-22** ("ANFITRIÃO fixo, 1") | Tasks | Mapeado |
| GAL-19 | P1-6 AC1..AC4 | **RN-22** (tabela) · A-19 | Tasks | Mapeado |
| GAL-20 | P1-6 AC5, AC6 | **RN-23** × RN-22 · UC-12/UC-13 (ator) · A-12, A-19 | Tasks | Mapeado |
| GAL-21 | P1-6 AC6, AC7 | A-12 (dimensão: input bounds / auth) | Tasks | Mapeado |
| GAL-22 | P2-1 AC1, AC2, AC6 | **W-04** linha "A galera" · W-R2 · A-17 | Tasks | Mapeado |
| GAL-23 | P2-1 AC3, AC4, AC5 | **W-R1, W-R3, W-R4** | Tasks | Mapeado |
| GAL-24 | P2-2 AC1, AC2 | A-08 (estado vazio) | Tasks | Mapeado |
| GAL-25 | P2-2 AC3 | AD-005 (dimensões: failure, observability) | Tasks | Mapeado |
| GAL-26 | P2-2 AC5 | **RN-28** (lado consumidor) · AD-016 (dimensão: concurrency) | Tasks | Mapeado |
| GAL-27 | P3-1 AC1, AC2, AC3 | arquivo 01 §4 · UC-11/UC-12/UC-13 (atores) · A-19 | Tasks | Mapeado |
| GAL-28 | P2-2 AC6 | dimensão: idempotência · RN-29 (1 toast por vez) | Tasks | Mapeado |

**Formato do ID:** `GAL-[NN]` · **Status:** Pending → In Design → In Tasks → Implementing → Verified

**Cobertura:** 28 requisitos · P1: 21 (GAL-01..GAL-04, GAL-06..GAL-21) · P2: 6 (GAL-05, GAL-22..GAL-26, GAL-28 — GAL-05 e GAL-28 nascem de dimensão dentro da história P2-2) · P3: 1 (GAL-27) · 0 órfãos · mapeamento a componente em `design.md` §15; mapeamento a tasks pendente do Tasks.

---

## Porte

**Grande** — confirma a classificação do roadmap, e por dois motivos distintos:

1. **RN-22 é herdada por três specs.** A tabela de permissões e a tradução nível-do-link → papel (GAL-19, GAL-20) são consumidas por `convite` (quem pode postar no grupo e cobrar), `convidado` (as security rules do Firestore são esta tabela traduzida para o servidor) e `custos` (quem pode cobrar pendentes, UC-23). Escolha herdada por três specs é decisão de arquitetura, não detalhe de tela — e errar a forma aqui custa retrabalho nas três.
2. **A configuração do nível do link é o contrato de entrada da spec 09.** O que esta tela grava é o que a 09 lê no instante da abertura (AD-026). O formato desse dado — código, nível, e o fato de o papel **não** retroagir — nasce aqui e não pode mudar depois sem quebrar o link já distribuído, que é perpétuo por decisão.

Somados às duas plataformas, à porta `GaleraRepository` (A-01), ao painel de accordion com três controles, à porta de área de transferência e ao estado vazio, o corte estimado é de **~13 tasks**, acima do limite de 8. **Design e Tasks são formais.**

**O que esta spec deixa para as outras:** a tabela de RN-22 como valor puro consultável; o nível do link como dado da festa; a lista de confirmados que o seletor "QUEM LEVA?" da AD-018 vai precisar; e a garantia comportamental da AD-026, que a spec 09 tem de preservar do lado do servidor.

---

## Divergências encontradas na spec-fonte

Registradas para que ninguém as "corrija" adiante sem saber que foram vistas.

| # | Divergência | Resolução adotada |
|---|---|---|
| D-1 | **UC-11** dá o ator como "anfitrião/co-anfitrião (cada um edita as próprias)", mas **T-05** diz que o painel do anfitrião tem "só a nota 👑" — logo o anfitrião **não** edita as próprias preferências nesta tela | A-05: vale T-05. O anfitrião edita a de todos menos a dele; "cada um edita as próprias" é o lado do convidado, na spec 09 |
| D-2 | **Arquivo 02 §8** limita a **2 acentos por tela**, e T-05 usa roxo (link/CTA), amarelo (label, faixa, tag ANFITRIÃO) e vermelho (estado ativo da restrição alimentar) | A-16: roxo e amarelo são os acentos estruturais; o vermelho conta como estado de controle, não como cor de superfície. A leitura estrita de §8 continua violada — declarado, não silenciado |
| D-3 | **RN-22** descreve ANFITRIÃO como "tudo" e CO-ANFITRIÃO como "edita tudo e cobra a galera", sem dizer o que os separa | A-19: os atores de UC-12 ("somente anfitrião") e UC-13 ("anfitrião") fornecem a diferença — gerenciar papéis e configurar o nível do link |
| D-4 | **T-05** lê "5 pessoas · 4 confirmadas" enquanto a Home de RN-30 lê "4 confirmados · 2 pendentes" — 5 ≠ 4+2 | Já resolvida pela **AD-022**: a divergência mora inteira no `pendentes`, que conta quem tem o link e não respondeu. GAL-09 fixa a metade que **tem** de coincidir e A-11 declara que a Galera não representa a outra |
| D-5 | O template literal de RN-21 produz "1 bebem 🍺" — concordância errada quando o número é 1 | Fora do alcance desta spec: a string é gerada por `resumoDasPreferencias` em `core/calculo`, já implementada e testada contra o literal da regra. GAL-13 renderiza o que a camada devolve, sem corrigir gramática |

---

## Success Criteria

- [ ] `flutter analyze` = zero issues · suíte inteira verde, baseline preservada.
- [ ] Aceite de **UC-11** verificável na tela: kit veggie quando há veggie, sem suína quando há "sem porco", cerveja dimensionada por quem bebe.
- [ ] Aceite de **UC-12** verificável: permissões efetivas seguem a tabela RN-22, célula a célula, e E1 mostra a nota 👑 com os controles ausentes.
- [ ] Aceite de **UC-13** verificável: quem abre o link entra com o papel vigente **no momento da abertura**, e trocar o nível não retroage.
- [ ] Nenhuma fórmula de RN-03, RN-05 ou RN-21 existe em `lib/features/galera/` — varredura automatizada.
- [ ] Nenhum literal de cor, fonte ou sombra em `lib/features/galera/**` (guarda de pureza da spec 01).
- [ ] `lib/features/galera/domain/` é Dart puro no que toca a RN-22 — sem import de Flutter, para a spec 09 traduzir em security rules.
- [ ] Trocar a impl de `GaleraRepository` por Firestore não exige mudar nenhum arquivo de `presentation/`.
- [ ] Toda copy da tela é literal de T-05 / RN-21 / RN-23 / RN-29 — nenhuma frase nova, exceto os dois defaults declarados em A-08 ("nenhuma pessoa ainda") e A-10 (plural do sub).
