# A galera — Context

**Gathered:** 2026-08-27
**Spec:** `.specs/features/galera/spec.md`
**Status:** Ready for design

> **Não houve Discuss com o usuário.** O `ROADMAP.md` não marcou Discuss para a spec 07 — a coluna está em "—" na tabela mestre. Por isso este documento não registra respostas de conversa: ele registra **decisões tomadas pelo agente** a partir da spec-fonte e das ADs já ativas, e a seção que mais importa aqui é **"Declined / Undiscussed Gray Areas → Assumptions"**, que espelha uma a uma as dezenove assumptions da tabela `Assumptions & Open Questions` do `spec.md`.

---

## Feature Boundary

A tela `/roles/:festaId/galera` — T-05 em compacto e a linha "A galera" de W-04 em expandido — mais **RN-22 como regra de domínio** e o nível do link de **RN-23** como dado da festa. Entrega o card do link (URL, segmented de três níveis, nota dinâmica literal, cópia com o toast de RN-29), a lista de pessoas nomeadas com papel e preferências, o painel de accordion que edita dieta, bebida e nível de acesso, e a faixa amarela do resumo agregado de **RN-21** — cujo efeito sobre a lista vem pronto de `core/calculo` e **não é reimplementado aqui**.

**Não** entrega: a mensagem e o grupo do WhatsApp (spec 08 `convite`), o que o convidado vê ao abrir o link (spec 09 `convidado`), a lista da festa em si (spec 06 `lista`), o acerto (spec 10 `custos`), as security rules que aplicam RN-22 no servidor (spec 09), nem a barra de abas da festa (spec 06).

---

## Implementation Decisions

### AD-026 — o link é perpétuo e o papel é lido na abertura *(decisão do usuário, 2026-08-27)*

- O link `bora.app/c/<codigo>` **não expira e não é revogável**. A tela **não ganha** botão de revogar nem de expirar — inventá-los seria UI fora da spec-fonte num produto de copy literal.
- O papel de RN-23 é lido **no instante da abertura**: trocar o nível no segmented **não altera** o papel de quem já entrou. É o aceite literal de UC-13 e virou critério WHEN/THEN próprio (história P1-2, `GAL-04`), com o par discriminante sendo a igualdade item a item dos papéis antes e depois.
- Consequência assumida: quem repassa o link dá o mesmo papel a um desconhecido. O modelo de ameaça "qualquer portador do código, com o papel vigente na abertura" é **aceito**, não é falha.
- Consequência para esta spec: a dimensão *data lifecycle / expiry* resolve em `N/A because` — não há TTL, arquivamento nem exclusão nesta tela.

### AD-022 — os contadores são dado da festa, não derivação

- `confirmados` e `pendentes` da Home são campos de `ResumoDeFesta`. A Galera **não deriva** nenhum dos dois e **nunca escreve** contador.
- `confirmados` **coincide** com a contagem de pessoas nomeadas confirmadas — T-05 lê "5 pessoas · 4 confirmadas" — e **tem de continuar coincidindo**. Isso virou um critério explícito (`GAL-09` AC8): lendo a mesma festa, o `confirmados` do card da Home é igual à contagem de nomeados confirmados desta tela; 4 com a fixture RN-30.
- `pendentes` **não é derivável**: conta também quem recebeu o link e ainda não respondeu, e essa pessoa não é uma `Pessoa` nomeada. Por isso **T-05 não exibe pendentes** e não representa o excedente — é o "+N" do lado da Galera, e a decisão foi **não renderizar nada** (A-11).
- A divergência declarada (D-5 do `validation.md` da `home`) tem dono na spec 09: quem grava o RSVP atualiza o contador na mesma escrita (RN-28).

### AD-016 / AD-021 — dado de festa em memória atrás de porta

- Nada nesta spec pode exigir Firestore. A implementação do M2-pré-09 é **em memória**, semeada pela fixture RN-30, atrás de porta abstrata.
- A porta é **reativa** (`Stream`), pelo mesmo motivo que a Home: RN-28 exige que a chegada de uma confirmação apareça sem refresh, e ler uma vez e desenhar faria a spec 09 reescrever a tela.
- Firestore, models, serialização e security rules entram no **M2 com a spec 09**.

### RN-21 é consumida, nunca reimplementada

- O efeito já está implementado e testado em `core/calculo`: veggie ≥1 adiciona o kit de legumes, "sem porco" remove a carne suína, e a cerveja dimensiona por **quem bebe** (`adultosQueBebem` substitui `adultos` de RN-05) sempre que houver pessoas nomeadas.
- A faixa amarela renderiza `"💡 "` seguido **exatamente** da string devolvida por `resumoDasPreferencias` — sem recompor copy na feature. Com a fixture: `"💡 A lista já se ajusta às preferências: 1 veggie 🥗 · 1 sem porco 🚫 · 3 bebem 🍺"`.
- Um teste de varredura afirma que nenhum arquivo de `lib/features/galera/` contém as constantes de RN-03, RN-05 ou RN-21.

### RN-22 nasce aqui como domínio, e o enforcement é de outros

- A tabela vira valor **puro** em `lib/features/galera/domain/`, sem import de Flutter, para a spec 09 traduzi-la em security rules sem arrastar UI.
- O aceite é célula a célula: quatro papéis × oito capacidades = **32 asserções explícitas**, nunca um laço que compare o domínio consigo mesmo.
- O papel do anfitrião **não é editável** (E1 de UC-12): o painel dele mostra apenas "👑 Anfitrião manda em tudo — acesso fixo.", com os três controles **ausentes da árvore**, não desabilitados — é o par que discrimina.
- A tradução nível → papel também é domínio: SÓ VER → SÓ VÊ · EDITAR LISTA → CONVIDADO · CO-ANFITRIÃO → CO-ANFITRIÃO.

### Copy literal, sem exceção fora do declarado

- Títulos, labels, botões e toasts em CAIXA ALTA; corpo em sentence case. As três notas de RN-23 e o resumo de RN-21 são literais e não são parafraseados.
- As **únicas** duas frases que não vêm da spec-fonte são defaults declarados: `"nenhuma pessoa ainda"` (A-08) e o plural derivado do sub (A-10).

### Agent's Discretion

- Estrutura do bloc, nomes de eventos e estados, composição interna dos widgets e a decisão entre um accordion por pessoa ou o `BoraExpandableGroup` do design system: livres dentro da Clean Architecture, desde que "1 aberto por vez" (arquivo 02 §5) seja preservado.
- A chave estável de linha que o edge case de nomes repetidos força — `Pessoa` tem o nome como identidade (`calculo` A-24), então o Design decide como chavear a linha.
- Como a porta de área de transferência é modelada (A-07): a exigência é ser testável e não emitir sucesso quando falha.

---

## Declined / Undiscussed Gray Areas → Assumptions

Nenhuma destas foi levada ao usuário — não houve Discuss para esta spec. Cada uma está resolvida com default e racional, e cada linha aqui espelha uma linha da tabela `Assumptions & Open Questions` do `spec.md`. **Nenhuma foi silenciosamente descartada.**

| # | Zona cinzenta | Default | Racional |
|---|---|---|---|
| **A-01** | Como a Galera lê pessoas, código e nível — `FestaRepository` não expõe nenhum dos três | Porta própria `GaleraRepository` em `features/galera/domain/`, reativa, impl em memória sobre **a mesma fonte de dado** da Home. `FestaRepository` não muda | Seis specs já consomem `FestaRepository`; alargá-lo por uma tela é mudar contrato herdado. Fonte única de dado é obrigação — é o que faz `GAL-09` passar |
| **A-02** | **Não existe UC de adicionar pessoa nomeada** — a spec-fonte só tem o link (UC-13) e os steppers de extras (RN-01) | **Sem "+ pessoa" manual.** Nomeada nasce de duas fontes: o RSVP pelo link (spec 09, RN-24) e a fixture RN-30 | O CTA literal do rodapé é "+ CONVIDAR MAIS GENTE 🔗" e ele **copia o link** — a spec-fonte responde "como adiciono gente?" com o link, não com um formulário. Pessoa sem RSVP a AD-022 não sabe contar |
| **A-03** | Origem do `codigo` (`rafa18`) — quem gera, quando, é estável? | Atributo da festa, estável e perpétuo (AD-026). A Galera **lê**, nunca gera; geração e unicidade são da spec 09/Functions. A fixture ganha `codigo: 'rafa18'` | `bora.app/c/rafa18` é literal em RN-23 e RN-26b e a festa de RN-30 é a do Rafa — ligação é leitura, não invenção. Unicidade global só o servidor garante |
| **A-04** | Remover pessoa da festa | **Não oferecido** — nenhum controle, nenhuma rota | Nenhuma tela de 04/06 desenha; RN-22 não tem capacidade correspondente; remover confirmado dessincronizaria o contador da AD-022 sem produtor que conserte |
| **A-05** | **Quem edita as preferências de quem** — UC-11 diz "cada um edita as próprias", mas o ator é "anfitrião/co-anfitrião" e T-05 dá só a nota 👑 ao anfitrião | **T-05 é literal**: anfitrião e co-anfitrião editam dieta e bebida de qualquer pessoa **exceto o próprio anfitrião**. "Cada um edita as próprias" é o lado do convidado, na spec 09 | Entre a tela literal e o parêntese do ator, vale a tela. O parêntese descreve o RSVP (UC-08/09), que não passa por T-05. **Divergência D-1 declarada no `spec.md`** |
| **A-06** | Efeito imediato de RN-21 sobre item que já tinha **override** de RN-12 | O override **sobrevive e continua vencendo**. Se RN-21 remove o item (suína × "sem porco"), o override fica guardado e volta intacto se a preferência for desfeita. Só "RESTAURAR" limpa | É o que `core/calculo` já faz: o ajuste "cobre o valor automático sem apagá-lo", e RN-21 mexe no conjunto de itens, não no mapa de overrides. RN-21 recalcula o automático; não revoga a palavra explícita do usuário |
| **A-07** | Copiar para a área de transferência — comportamento e feedback em mobile e web | `Clipboard.setData` nas duas plataformas, atrás de porta testável. **O feedback é só o toast** "LINK COPIADO 🔗" (RN-29, 2200 ms, 1 por vez). Falha → nenhum toast, registro no `AppLogger`, link continua visível e selecionável | RN-29 dá o texto de sucesso e nenhum de falha; copy de erro seria invenção. No web a cópia depende de gesto e permissão — toast de sucesso após falha é mentira testável |
| **A-08** | **Estado vazio** — festa só com o anfitrião, ou sem pessoa nomeada nenhuma | Só o anfitrião: uma linha em PESSOAS e a faixa com o resumo que sobrar. Zero pessoas: sub lê "nenhuma pessoa ainda", PESSOAS sem linhas e sem copy inventada, faixa ausente, card do link e CTA permanecem | Mesma forma da A-03 da spec `home`: o caminho adiante continua visível. A faixa some porque `resumoDasPreferencias` devolve string vazia sem termos, e "💡" seguido de nada seria pior que silêncio |
| **A-09** | Trocar o nível **com convidados já dentro** — o que a UI comunica, dado que AD-026 diz que o papel deles não muda | **Nenhuma copy nova.** As três notas de RN-23 seguem literais e o label "QUEM ABRIR O LINK PODE…" já está no futuro. A garantia é **comportamental** (`GAL-04`), não textual | Acrescentar aviso seria inventar copy; T-05 e W-04 não desenham nenhum. Um aceite comportamental discrimina melhor: a frase passaria mesmo se o papel retroagisse |
| **A-10** | O sub "5 pessoas · 4 confirmadas" tem números fixos na spec | **Derivado** da lista de nomeados, com plural correto. Com a fixture dá exatamente o literal de T-05 | Precedente A-05 da spec `home`. Literal fixo mentiria em qualquer outro estado; o aceite continua sendo a string de T-05, agora como consequência do dado |
| **A-11** | O pendente **sem nome** — RN-30 tem 2 pendentes na Home e só 1 pendente nomeada (Duda) | T-05 lista **só nomeadas**. A Galera não renderiza o excedente, não deriva `pendentes` e nunca escreve contador | Custo declarado da AD-022: "pendente" conta quem tem o link e não respondeu, e essa pessoa não tem nome, avatar, preferência nem papel para exibir. Reconciliar é obrigação da spec 09 (RN-28) |
| **A-12** | Nível inicial do link, e o que fazer com valor ausente ou desconhecido | Festa nova/fixture nasce em **EDITAR LISTA**. Valor ausente ou desconhecido resolve para **SÓ VER** | Situações diferentes: o default do produto é EDITAR LISTA porque o fluxo canônico (RN-24 → UC-09 → RN-20) exige que o convidado marque itens; dado corrompido resolve por **menor privilégio** — nunca conceder edição por falta de informação |
| **A-13** | Rótulos de "RESTRIÇÃO ALIMENTAR" — T-05 escreve só "🍖/🥗/🚫" | Emoji **+ rótulo literal de RN-21**: "🍖 Come de tudo", "🥗 Veggie", "🚫 Sem porco" | RN-21 dá os três por extenso; "(🍖/🥗/🚫)" é abreviação de enumeração. Botão de emoji sozinho não passa o mínimo de legibilidade do arquivo 02 |
| **A-14** | Sublinha de pessoa com dieta ou bebida **não declarada** (a Duda) | Omite o termo não declarado; com os dois ausentes, a sublinha não renderiza | `dieta`/`bebe` são anuláveis de propósito em `core/calculo` (`null` = não declarado, distinto de `tudo` e de `false`). "Não informado" seria copy inventada, e a omissão é a regra que RN-21 já usa |
| **A-15** | Ordem da lista de pessoas | **Ordem do repositório**, sem reordenar por papel, nome ou status | Ordem de entrada é comportamento observável no racha (`calculo` A-14); reordenar faria a Galera discordar de outra lista da mesma festa sem que nada avisasse |
| **A-16** | Orçamento de acento do arquivo 02 §8 — **máx. 2 por tela** — e T-05 usa roxo, amarelo e vermelho | Roxo (link/CTA) e amarelo (label, faixa, tag ANFITRIÃO) são os acentos **estruturais**; o vermelho entra só como **estado ativo** dos botões de restrição | Os três usos são literais de T-05 e cada um carrega o significado fixo de §1. Estado ativo de controle não é acento de superfície — mas a leitura estrita de §8 conta 3. **Divergência D-2 declarada no `spec.md`** |
| **A-17** | No web, onde mora o CTA "+ CONVIDAR MAIS GENTE 🔗" — W-R2 diz que rodapé fixo não existe no web | Na **coluna esquerda**, sob o card do link, dentro dos 370px | W-04 fixa o card à esquerda e os accordions à direita; o CTA é da mesma família do "COPIAR 🔗" e pertence à mesma coluna. É o análogo de "o CTA mora no rail" de W-R2 |
| **A-18** | A barra de abas da festa não existe — o `FestaTabsShell` é `navigationShell` cru | A Galera **não** reveste o shell (é da spec 06 `lista`) e tem de ser alcançável e testável sem barra de abas | O roadmap dá `galera` como dependente de 01, 02 e 04 — não de 06. Depender da barra inverteria a ordem e travaria esta spec numa ainda não especificada |
| **A-19** | RN-22 não distingue "tudo" (ANFITRIÃO) de "edita tudo e cobra a galera" (CO-ANFITRIÃO) | A diferença são **duas capacidades exclusivas do anfitrião**: gerenciar papéis e configurar o nível do link | UC-12 diz "**Ator:** somente anfitrião" e UC-13 "**Ator:** anfitrião", enquanto UC-11 diz "anfitrião/co-anfitrião". As três linhas juntas dão a fronteira que a tabela deixou implícita. **Divergência D-3 declarada no `spec.md`** |

**Nenhuma pergunta aberta restou.** Se o usuário quiser reabrir alguma, as candidatas de maior impacto são **A-02** (não existe "+ pessoa" manual), **A-05** (o anfitrião não edita as próprias preferências em T-05) e **A-12** (o nível default de festa nova).

---

## Specific References

- **A copy é literal, não paráfrase.** As três notas de RN-23, o resumo agregado de RN-21, os rótulos das opções de dieta, o toast "LINK COPIADO 🔗" e a nota "👑 Anfitrião manda em tudo — acesso fixo." entram na tela exatamente como estão na spec-fonte.
- **Os literais de T-05 saem como consequência do dado**, não como string fixa: "5 pessoas · 4 confirmadas" continua sendo o aceite, agora derivado da lista de nomeados (A-10), no mesmo padrão que a spec `home` adotou.
- **A faixa de RN-21 não é recomposta aqui**: a feature concatena `"💡 "` com o retorno de `resumoDasPreferencias`. Reescrever o template na UI produziria duas fontes da mesma frase.
- **O par discriminante é regra de aceite, não estilo de teste**: painel do anfitrião com a nota **presente** e os três controles **ausentes** (`findsNothing`); papéis idênticos **antes e depois** da troca de nível; faixa **ausente** quando o resumo é vazio.
- **A tabela de RN-22 é afirmada célula a célula** — 32 asserções, uma por par papel × capacidade. Um laço que compare o domínio consigo mesmo passaria com a tabela inteira errada.
- Componentes já prontos do design system que esta tela consome sem recriar: `BoraExpandableRow`/`BoraExpandableGroup` (accordion, 1 aberto por vez), `BoraSegmentedControl` (com a variante `sobreCardEscuro` para o card do link), `BoraStatusTag` (as quatro cores de papel de §5), `BoraAvatar`, `BoraToast` e `BoraDashedNote`.

---

## Deferred Ideas

Apareceram durante a especificação e pertencem a outras specs. Capturados para não se perderem, explicitamente fora do escopo desta.

- **Geração do `codigo` do link** — unicidade global, formato e colisão são da spec 09 `convidado` / Functions. Aqui o código é lido como atributo da festa (A-03).
- **Enforcement de RN-22 nas security rules do Firestore** — a tabela nasce aqui como valor puro; traduzi-la para o servidor é da spec 09. É por isso que `domain/` fica sem import de Flutter.
- **Aplicar o nível na abertura do link** — a leitura do papel no instante da abertura (AD-026) é comportamento da spec 09; esta spec só grava o nível e garante que trocá-lo não retroage.
- **O seletor "QUEM LEVA?" da AD-018** — adiado para `galera`/`lista` no formato popover/sheet que W-03 pede, mas ele mora na **lista**, junto dos itens. Esta spec entrega a matéria-prima dele: a lista de confirmados.
- **Auto-edição de preferências pelo convidado** — o "cada um edita as próprias" de UC-11 vive no fluxo de RSVP da spec 09, não em T-05 (A-05).
- **Adicionar e remover pessoa à mão** — sem UC e sem tela (A-02, A-04). Se o produto quiser, precisa de desenho novo e de resposta para o contador da AD-022.
- **Revogar ou expirar o link** — fechado pela AD-026 como fora do produto, não adiado por falta de tempo.
- **Tratamento visual para quem recusou** — a spec-fonte não dá nenhum; a pessoa aparece como nomeada e não conta em "confirmadas". Se algum dia ganhar destaque próprio, é copy nova e precisa de decisão.
