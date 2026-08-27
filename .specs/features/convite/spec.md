# O convite (mensagem, grupo e enquetes) — Specification

**ID prefix:** `CVT` · **Porte:** **Complexo** (ver §Porte)
**Design:** `.specs/features/convite/design.md` — pendente
**Tasks:** `.specs/features/convite/tasks.md` — pendente
**Context:** `.specs/features/convite/context.md`
**Spec-fonte:** T-06, T-07 (`04-telas-ux.md`) · W-04 linha "WhatsApp" + W-R1..W-R5 (`06-telas-web.md`) · UC-07, UC-17, UC-18 (`05-casos-de-uso.md`) · RN-25, RN-26, RN-26b (`03-regras-de-negocio.md`) · RN-13, RN-14, RN-22, RN-29, RN-30 (consumo) · arquivo 01 §4/§5/§6 · arquivo 02 §5/§8
**Roadmap:** `.specs/ROADMAP.md` — spec 08, marco M2. Fatia declarada: **UC-07 é P1**, **UC-17 e UC-18 são P2**
**Decisões ativas herdadas:** AD-001..AD-028 · **AD-025** (grupo e enquete são estado do BORA — funda esta spec) · **AD-003** (a aba `whatsapp` já existe no shell da festa) · **AD-016/AD-021** (dado de festa em memória atrás de porta até o M2) · **AD-022** (contadores são dado, não derivação) · **AD-026** (link perpétuo, papel lido na abertura) · **AD-005** (`AppLogger`) · **AD-008** (entidades em `core/calculo/dominio/`)
**Depende de:** spec 01 `design_system`, spec 02 `calculo`, spec 06 `lista` (atribuições "quem leva" e a resolução D-1 das duas moedas), spec 07 `galera` (o link, o código e a tabela de RN-22)

> **Atenção de contexto:** as AD registradas no `.specs/STATE.md` vão até **AD-028**. A **AD-029 está proposta pela spec 05 `montar` e ainda não registrada** — nenhuma linha desta spec depende dela.

---

## Problem Statement

`/roles/:festaId/whatsapp` é hoje um `PlaceholderPage`. É onde mora a segunda das três promessas do produto — **"chama a galera por link/WhatsApp"** — e é a única superfície do BORA que produz alguma coisa para fora do app: o texto que de fato chega no grupo da galera. Sem T-06, o link que a spec 07 sabe gerar e copiar não tem veículo: ele sai do BORA como uma URL nua, sem flyer, sem o resumo de quem leva o quê, sem o "sai ~R$ X por cabeça" que é o argumento de venda do rolê.

O problema técnico central já foi resolvido antes desta spec começar. A zona cinzenta **G4** do roadmap perguntava o que RN-25 e RN-26 significam num produto real, dado que **a API pública do WhatsApp não cria grupo nem posta enquete, e a Cloud API também não**. A **AD-025** (2026-08-27) fechou: **grupo e enquete são estado do BORA**, e o WhatsApp recebe o único artefato que ele aceita de fora — **texto**, por share sheet / `wa.me`.

Isso muda a natureza desta spec. Ela não integra um sistema externo: ela **define um domínio novo** — composição de mensagem por blocos, grupo do rolê, enquete com voto trocável e percentual — a partir de duas telas que descrevem esse domínio como se ele fosse do WhatsApp. Cada regra de RN-25/RN-26 continua verdadeira e testável; nenhuma delas continua sendo do WhatsApp. É esse deslocamento, e não o volume de tela, que faz o porte.

## Goals

- [ ] `/roles/:festaId/whatsapp/convite` renderiza **T-06** — os três toggles de RN-26b e o preview fiel de bolha — com a copy literal do arquivo 04.
- [ ] Ligar e desligar qualquer bloco recompõe o preview **na hora**, e o texto enviado é exatamente o que o preview mostra (aceite de UC-07).
- [ ] "ENVIAR NO WHATSAPP →" entrega o texto montado ao WhatsApp por share sheet / `wa.me` e mostra o toast literal "ABRINDO O WHATSAPP… 📲" (RN-29) **só quando o canal abriu**.
- [ ] `/roles/:festaId/whatsapp` renderiza **T-07** — card do grupo, três modelos de enquete e preview votável — com a copy literal do arquivo 04.
- [ ] "CRIAR GRUPO" cria, **no BORA**, um grupo com o nome da festa contendo **apenas os confirmados** (RN-25), vira chip verde irreversível e emite "GRUPO CRIADO NO WHATSAPP ✅".
- [ ] As três enquetes de RN-26 existem no BORA com os números literais da regra: HORÁRIO 5/2/1 → **63% / 25% / 13%**, DATA 6/2 → **75% / 25%**, O QUE LEVAR 3/1 → **75% / 25%**.
- [ ] O voto é **um por enquete, trocável**, e **trocar de modelo preserva o voto de cada enquete** (aceite de UC-18).
- [ ] "POSTAR ENQUETE NO GRUPO 📲" **sem grupo criado** não posta nada e mostra "CRIE O GRUPO PRIMEIRO ☝️" (E1 de UC-18).
- [ ] No web, coluna única centralizada de **máx. 560px** com a bolha **nunca acima de 300px** (W-04), respeitando W-R1..W-R5.
- [ ] **Nenhuma aritmética nova.** O "💸 sai ~R$ X por cabeça" e todo dinheiro vêm prontos de `core/calculo`, formatados por RN-13.

## Out of Scope

Explicitamente excluído. Documentado para impedir alargamento.

| Item | Razão |
|---|---|
| O card do link, o `codigo` e o **nível** do link (segmented "QUEM ABRIR O LINK PODE…") | Spec 07 `galera` (T-05 · UC-13 · RN-23 · GAL-01..GAL-04). Esta spec **consome o link já configurado**: ela o cola dentro da mensagem e nunca o edita, nunca o exibe como controle e nunca escolhe o nível. |
| A tabela de RN-22 como regra de domínio | Spec 07 `galera` (GAL-19, GAL-20). Aqui ela é **consultada** para decidir quem pode criar grupo, postar enquete e enviar o convite (CVT-35). |
| Copiar o link para a área de transferência e o toast "LINK COPIADO 🔗" | Spec 07 `galera` (GAL-03, GAL-05, A-07). Esta tela **não tem botão de copiar** — T-06 e T-07 não desenham nenhum. |
| A lista da festa: itens, quantidades, preços, overrides, corredores, modos PLANEJAR/COMPRAR, pedido por delivery | Spec 06 `lista` (T-04 · UC-05, UC-06, UC-14..UC-16 · RN-11, RN-12, RN-27). O bloco LISTA de RN-26b é **leitura** do que a 06 modela (A-10) — nenhum item nasce, muda de preço ou muda de dono aqui. |
| Quem confirma presença, quem escolhe o que leva, e a atribuição "eu levo" | Spec 09 `convidado` (T-08 · UC-08, UC-09, UC-10 · RN-20, RN-24, RN-28). "Apenas confirmados" (RN-25) e "quem leva o quê" (RN-26b) são **insumos** produzidos lá. |
| Pessoas, papéis, preferências, avatares por pessoa | Spec 07 `galera` (T-05 · RN-21, RN-22). Aqui só se lê **quem está confirmado**, para a contagem de membros e os avatares do card. |
| O acerto: cota, saldos, quem paga quem, cobrança | Spec 10 `custos` (T-09 · UC-19..UC-23 · RN-14..RN-19). RN-14 continua valendo — criança nunca entra no racha —, e o "por cabeça" desta tela é a **estimativa** por pessoas, não a cota (A-10). |
| Firestore, models, serialização, Functions, security rules | **AD-016**: até a spec 09, dado de festa é em memória atrás de porta. Esta spec nasce em memória (A-03) e não escreve rules. |
| Criar grupo, adicionar membro ou postar enquete **dentro do WhatsApp** | **AD-025**: a API pública não permite, e a Cloud API tampouco. O WhatsApp recebe **texto**. Trade-off declarado (A-01, D-2). |
| Push, e-mail ou notificação de qualquer espécie para os membros | Nenhuma tela da spec-fonte desenha superfície de aviso. Precedente da spec 09 (A-13): o "aviso" do produto é a escrita realtime. |
| Editar o nome da festa, a data ou o local exibidos no bloco FLYER | O flyer **renderiza** dado da festa; editá-lo é T-03 / spec 05 `montar`. |
| Convidar por outro canal (SMS, e-mail, Telegram, QR) | Nada na spec-fonte desenha. O share sheet do sistema já expõe os canais do aparelho sem UI nossa (A-08). |
| Os toasts "CONVITE COPIADO 📋" e "LISTA NO GRUPO 📲" de RN-29 | Existem no catálogo canônico, mas **nenhum gesto de T-06 ou T-07 os produz** (A-26). Esta spec não inventa botão para eles. |
| Barra de abas da festa (`FestaTabsShell` revestido) | Spec 06 `lista` (precedente `galera` A-18). As duas telas são alcançáveis e testáveis sem ela (A-24). |

---

## Fronteira de arquivos

| Pode tocar | Não pode tocar |
|---|---|
| `lib/features/convite/**` | `lib/core/calculo/**` · `lib/core/design_system/**` |
| `lib/core/di/injector.dart` — **só** registro dos próprios | `lib/features/{home,montar,lista,galera,convidado,custos,entrar}/**` |
| `lib/core/routing/**` — **só** para aninhar a rota filha de T-06 sob o branch `whatsapp` que a AD-003 já criou (A-18); nenhuma outra rota muda | `lib/core/routing/**` para qualquer outra alteração — o mapa canônico da AD-003 vale |
| `test/features/convite/**` | `.specs/{STATE,ROADMAP,LESSONS}.md`, `.specs/lessons.json` |
| `test/fixtures/**` — **só** estender com os três modelos de enquete e os votos-base de RN-26 (A-02) | qualquer teste existente — a baseline não pode ser enfraquecida nem apagada |

---

## Assumptions & Open Questions

O ROADMAP marcou **Discuss** para esta spec, e a zona cinzenta central — **G4** — foi levada ao usuário e fechada como **AD-025** (2026-08-27). Todas as demais ambiguidades foram resolvidas pelo agente e estão registradas aqui com default escolhido e racional; nenhuma fica silenciosamente em aberto. As mesmas entradas estão em `context.md`.

| # | Ambiguidade | Default escolhido | Racional | Confirmado? |
|---|---|---|---|---|
| A-01 | **Consequência declarada da AD-025:** o chip "✅ '<nome>' · N membros" e o toast "GRUPO CRIADO NO WHATSAPP ✅" descrevem um grupo que **não existe** no WhatsApp do usuário | **A copy fica literal.** Nenhum selo de "simulado", nenhuma ressalva na tela, nenhuma alteração de RN-25. O grupo é estado do BORA e a tela não o confessa | É o trade-off que a **AD-025** já aceitou e registrou, na mesma forma da AD-024 (delivery). Acrescentar um selo seria copy inventada num produto de copy literal, e mudar a copy contrariaria a AD. **Consequência declarada, não esquecida** — ver §Divergências D-2 | **y (AD-025)** |
| A-02 | **Quem vota nas enquetes.** Os votos-base de RN-26 somam 8 (5/2/1), 8 (6/2) e 4 (3/1) votantes — mais gente do que os **4 confirmados** de RN-30 e do que os "4 membros" de T-07 | **Os votos-base são fixture de demo**, gravados como campo inicial de cada modelo de enquete, sem votante identificável. **O voto do usuário soma +1** à opção escolhida; trocar move o +1; tocar a opção já votada é **no-op**. Não existe "desvotar" | RN-26 dá os números como parte do modelo, não como resultado de gente que votou — não há em lugar nenhum da spec-fonte uma tela onde essas 8 pessoas votem. Somar em vez de substituir é o que preserva os literais da regra **e** produz percentuais novos e verificáveis (63/25/13 → 67/22/11). "1 voto por enquete por pessoa, trocável" (RN-26) diz trocável, nunca removível — daí o no-op. **Divergência declarada** — ver D-3 | n |
| A-03 | **Persistência do grupo e dos votos** sob AD-016 (dado de festa em memória até a spec 09 trazer o Firestore), contra o "estado persistente" que UC-17 exige | **Porta própria** `ConviteRepository` em `features/convite/domain/`, reativa (`Stream`), impl **em memória** no escopo da festa, registrada como singleton no `injector`. "Persistente" significa: **sobrevive a rebuild, a troca de aba, a sair e voltar da rota e a qualquer navegação dentro do app**; **não** sobrevive a reiniciar o processo. Firestore entra no M2 com a spec 09 | Precedente literal de `galera` A-01: seis specs já consomem `FestaRepository` e alargá-lo por causa de uma tela é mudar contrato herdado. A porta própria segue a forma da AD-016 e some atrás de Firestore no M2 sem tocar na UI. E é o único escopo de "persistente" que o M2-pré-09 pode entregar honestamente — prometer mais seria requisito não testável | n |
| A-04 | **Irreversibilidade do grupo × confirmação tardia.** RN-25 diz "irreversível na UI"; RN-28 diz que confirmação nova reflete sem refresh. O chip atualiza a contagem? | **Sim — a contagem é derivada ao vivo.** O grupo guarda apenas "foi criado" (um booleano e o nome congelado no instante da criação); **os membros são sempre o conjunto de confirmados no instante da leitura**. Quem confirma depois entra e o chip vai de "· 4 membros" para "· 5 membros"; quem passa a recusar sai. **O chip nunca volta a ser botão** | Congelar a lista no instante da criação faria RN-25 ("contendo apenas confirmados") virar "contendo apenas quem estava confirmado", e não existe nenhuma UI na spec-fonte para adicionar membro depois — o grupo nasceria desatualizado e sem conserto. Derivar é também o que faz o realtime de RN-28 valer aqui de graça. A irreversibilidade continua inteira: ela é do **gesto**, não da contagem | n |
| A-05 | **Os três blocos de T-06 todos desligados** — o que a bolha mostra e o que acontece com o CTA | **A bolha não renderiza.** A área de conversa fica com o fundo `#E7DFCB` e **só** a legenda literal "é assim que chega no grupo — mexa nos blocos acima". O CTA "ENVIAR NO WHATSAPP →" fica **desabilitado**: não afunda no press, não abre canal, não emite toast | Uma bolha vazia com hora e ✓✓ seria um preview infiel — ela mostraria uma mensagem que o WhatsApp não aceitaria enviar. Desabilitar o CTA é a única saída que não inventa copy de erro e não manda mensagem vazia. A legenda permanece porque é ela que ensina o caminho de volta ("mexa nos blocos acima") | n |
| A-06 | **Que hora o preview mostra.** T-06 escreve "14:02 ✓✓" e T-07 escreve "14:05 ✓✓" — dois literais fixos | **Relógio injetado, congelado na abertura da tela.** Porta `Clock` (ou equivalente do Design), formato `HH:mm` 24h em `pt-BR`. A hora **não** se atualiza a cada toque em bloco — ela é lida uma vez, quando a tela abre, e vale para toda a sessão da tela. Os testes injetam 14:02 (T-06) e 14:05 (T-07) e reproduzem os literais | Literal fixo mentiria em qualquer horário — e é justamente o tipo de detalhe que faz um "preview fiel" deixar de ser fiel. Relógio real não injetado tornaria o teste indeterminístico, e reler a hora a cada toggle faria a hora dançar enquanto o usuário mexe nos blocos. Congelar na abertura é a leitura que reproduz o literal **e** passa em teste. Precedente de derivação: `galera` A-10, `home` A-05 | n |
| A-07 | **Texto muito longo na bolha** — a bolha tem "máx 300px" de largura e conteúdo variável | **Quebra de linha, altura livre, sem truncamento.** A largura é fixa em `min(300px, disponível)`; o conteúdo quebra e a bolha cresce em altura; a **área de preview rola no documento** (nunca uma caixa de scroll própria, W-R4). **Nunca** reticências, **nunca** scroll horizontal, **nunca** "ver mais" | Truncar o preview quebraria a única coisa que ele promete: ser **fiel**. E W-R4 proíbe scroll horizontal em qualquer largura. A rolagem do documento é a mesma saída que W-R4 já autoriza para conteúdo longo | n |
| A-08 | **Falha ao abrir o WhatsApp** — app não instalado, share sheet cancelado, `wa.me` bloqueado pelo navegador. A spec-fonte só desenha o caminho feliz | **Um canal só, atrás de porta.** `CompartilhadorDeTexto.compartilhar(texto)` — share sheet do sistema no mobile, `wa.me` em nova aba no web. **O toast "ABRINDO O WHATSAPP… 📲" é emitido depois de o canal confirmar a abertura**, nunca antes. **Cancelar não é falha**: sem toast, sem erro, a tela permanece intacta com os blocos como estavam. **Falha real** (canal indisponível, exceção, `false`): também sem toast de sucesso, **sem copy de erro inventada**, com registro no `AppLogger` (AD-005). Sem fallback de canal e sem tentativa automática | Precedente direto de `galera` A-07: RN-29 dá o texto de sucesso e nenhum de falha, então inventar copy de erro violaria "copy literal", e um toast de sucesso após falha seria mentira testável. Emitir o toast **depois** é a mesma disciplina da spec 09 (A-13): a promessa nunca aparece sem o fato. Distinguir cancelamento de falha importa porque cancelar é escolha do usuário e não deve produzir log de erro | n |
| A-09 | **"Trocar de modelo preserva o voto de cada enquete" (aceite de UC-18) — em que escopo** | **As três enquetes coexistem como três objetos independentes**, cada uma com seus votos-base e o voto do usuário. Trocar o toggle **só troca qual delas o preview mostra**. A memória do voto tem o mesmo escopo de A-03: por festa, no `ConviteRepository`, viva enquanto o processo vive | É a leitura que o próprio aceite exige — "preserva o **voto de cada** enquete" pressupõe três votos simultâneos, não um voto que migra. Guardar no `ConviteRepository` (e não no bloc da tela) é o que faz o voto sobreviver a sair e voltar da aba, que é o mesmo "persistente" que UC-17 cobra do grupo | n |
| A-10 | **Contrato de leitura do bloco LISTA (RN-26b)** — de onde vêm "quem leva", os órfãos em vermelho e o "💸 sai ~R$ X por cabeça" | **Três leituras, zero cálculo.** (a) *Quem leva*: atribuições item→dono, modeladas pela spec 06 e escritas pela 09; itens **com** dono viram linhas de dono. (b) *Órfãos*: itens **sem** dono, na linha vermelha. (c) *Por cabeça*: a **estimativa por pessoas** de RN-14 — a mesma de T-03 —, vinda pronta de `core/calculo` e formatada por RN-13. O preço de cada item é `ItemDeLista.valor`, **a moeda da calculadora**, conforme a resolução **D-1 da spec 06** — a tabela de mercado de RN-11 **não** entra aqui | RN-26b escreve "por cabeça", e RN-14 define "cabeça" como **pessoas** (adultos + crianças), reservando "por adulto" para a cota do racha. Os dois números coexistem de propósito (CLAUDE.md) e o convite é convite, não acerto — precedente idêntico em `convidado` A-15. Sobre a moeda: contradizer D-1 da spec 06 faria a mesma festa mostrar dois totais em duas telas. E o CLAUDE.md é explícito: **nunca duplique uma fórmula em componente de UI** | n |
| A-11 | **Dois separadores diferentes no bloco LISTA de T-06** — as linhas com dono usam " + " ("Carnes + pão de alho", "Cerveja + 🧊 gelo") e a linha órfã usa " · " ("Refri · 💧 água") | **Os dois são preservados literalmente.** Linha de dono: `{emoji} {itens juntados por " + "} — **{Nome} leva**`, uma linha por dono. Linha órfã: `{emoji} {itens juntados por " · "} — quem leva?`, **uma só**, em vermelho, com todos os órfãos | É o que a tela literalmente mostra, e a diferença carrega significado: " + " soma o que uma pessoa já assumiu; " · " apenas enumera o que ninguém assumiu. Uniformizar seria "consertar" a spec-fonte por conta própria. **Divergência declarada** — ver D-5 | n |
| A-12 | **Bloco LISTA sem matéria-prima** — nenhum item com dono, nenhum órfão, ou lista inteiramente vazia | Cada linha renderiza **só se tiver conteúdo**: sem dono, nenhuma linha de dono; sem órfão, nenhuma linha vermelha. **A linha "💸 sai ~R$ X por cabeça" renderiza sempre** que o bloco está ativo, inclusive com "R$ 0". O toggle LISTA **nunca** é desabilitado e **nenhuma copy nova** é escrita | Precedente de `galera` A-08 e `home` A-03: omitir o termo vazio, nunca escrever "nenhum". "R$ 0 por cabeça" é um número honesto sobre uma lista vazia; desabilitar o toggle inventaria um estado que T-06 não desenha e esconderia o caminho adiante | n |
| A-13 | **Caixa do nome da festa no chip.** RN-30, o sub de T-06 e o botão de T-07 escrevem "CHURRAS DO RAFA 🔥"; só o chip de T-07 escreve "Churras do Rafa 🔥" | **O template de RN-25 vence:** o chip é `✅ "{nome da festa}" · {N} membro(s)`, com o nome **como gravado na festa**. Com a fixture RN-30 renderiza `✅ "CHURRAS DO RAFA 🔥" · 4 membros`. O botão aplica CAIXA ALTA porque é **botão** (regra de copy do CLAUDE.md); o chip não transforma nada | O nome da festa é **dado interpolado**, não copy — e RN-25 dá o template com `<nome>` explicitamente como placeholder, enquanto T-07 dá uma renderização dele. Entre o template da regra e uma renderização da tela, vale o template. Três das quatro ocorrências na spec-fonte já estão em caixa alta. **Divergência declarada** — ver D-1 | n |
| A-14 | **Plural derivado** — T-07 fixa "4 confirmados entram no grupo" e "· 4 membros" | **Derivados** de `confirmados` (AD-022), com plural correto: `{n} confirmados entram no grupo` / `1 confirmado entra no grupo`; `· {n} membros` / `· 1 membro`. Com a fixture RN-30 dão exatamente os literais de T-07 | Precedente de `galera` A-10, `convidado` A-16 e `home` A-05. Literal fixo mentiria em qualquer outro estado; o aceite continua sendo a string de T-07, agora como consequência do dado | n |
| A-15 | **Estado inicial dos toggles**, e se eles são aditivos ou exclusivos | **T-06 (blocos): aditivos, os três ativos na abertura** — é o preview que T-06 desenha, e é o aceite de UC-07 ("com os 3 blocos ativos…"). **T-07 (modelos de enquete): exclusivos, um por vez, HORÁRIO ativo na abertura** — UC-18 passo 1 diz "escolhe modelo → preview da enquete **muda**", e T-07 desenha **uma** bolha | As duas telas chamam os controles de "toggles", mas o comportamento descrito difere: T-06 monta uma mensagem por acumulação de blocos, T-07 mostra uma enquete por vez. HORÁRIO é o primeiro modelo em RN-26 e em T-07. **Divergência de vocabulário declarada** — ver D-6 | n |
| A-16 | **"POSTAR ENQUETE NO GRUPO 📲" posta o quê** — a enquete visível ou as três? | **Só a enquete do modelo selecionado.** Uma ação, uma enquete | UC-18 passo 1 fixa "escolhe modelo… → preview" e passo 3 age sobre esse preview. Postar as três de uma vez tornaria o preview enganoso e não teria correspondência em nenhuma tela | n |
| A-17 | **O que o texto compartilhado da enquete contém** — RN-26 define pergunta, opções e `%`, e nada mais | Pergunta em CAIXA ALTA numa linha, depois **uma linha por opção** com o rótulo literal e o percentual atual. **Sem link, sem assinatura, sem chamada para ação.** O nome do grupo não entra | Acrescentar link ou copy de convite seria inventar texto num produto de copy literal — e o link tem veículo próprio, que é a mensagem de T-06. O que RN-26 define é exatamente o que vai | n |
| A-18 | **Onde T-06 e T-07 moram na navegação.** A AD-003 dá **uma** aba `whatsapp`, e esta spec tem **duas** telas | **A aba `whatsapp` é T-07**; **T-06 é rota filha** `/roles/:festaId/whatsapp/convite`, aninhada no mesmo branch do `StatefulShellRoute`, alcançada pelo CTA "MANDAR NO GRUPO 📲" de T-03/W-03 e pelo "+ CONVIDAR" do card da Home. O "voltar" do header de T-06 faz `pop` para de onde veio | Aninhar preserva a aba selecionada e o estado do `indexedStack`, que é o que a AD-003 comprou. As duas telas são o mesmo domínio (nota de recorte do roadmap: "é o mesmo domínio WhatsApp"), então uma rota irmã fora do branch as separaria sem motivo. **É a única alteração no mapa canônico da AD-003 que esta spec autoriza** — o Design confirma a forma exata | n |
| A-19 | **O CTA alternativo de T-06** — "ENVIAR E VER O LADO DO CONVIDADO →", marcado "no fluxo integrado" | **Fora do produto.** O CTA é sempre e só "ENVIAR NO WHATSAPP →" | O qualificador "no fluxo (integrado)" marca a **narração da demo**, não o produto — a spec 09 já julgou exatamente esse qualificador (A-06) contra o "Mapa de etapas", que o arquivo 04 declara em letras não fazer parte do produto final. E o destino do link é a tela do convidado, que o anfitrião alcança abrindo o próprio link, não por um botão de anfitrião. **Divergência declarada** — ver D-4 | n |
| A-20 | **Orçamento de acento** (arquivo 02 §8 — máx. 2 por tela) nas duas telas | **T-06: vermelho** (linha órfã "quem leva?", link sublinhado, "💸") **+ `#25D366`** (CTA WhatsApp). **T-07: `#25D366` apenas** — o `#DCF8C6` do chip é a variante clara do **mesmo** acento verde, não um terceiro. O `#E7DFCB` do fundo de conversa é **superfície**, não acento; o amarelo da linha do flyer é **pigmento da mini-arte**, dentro da bolha, não cor de tela | Cada acento carrega o significado fixo que §1 lhe dá: vermelho = dinheiro/pendência, `#25D366` = WhatsApp. As duas telas ficam dentro do orçamento sob essa leitura, e a leitura é a mesma que `galera` A-16 já usou para separar acento estrutural de estado de controle | n |
| A-21 | **Zero confirmados** — UC-17 tem como pré "≥1 confirmado", e a tela não diz o que fazer sem nenhum | O card renderiza sem avatares, a linha lê "0 confirmados entram no grupo" (derivada, A-14) e o **botão CRIAR GRUPO fica desabilitado**: não afunda, não cria, não emite toast. **Nenhuma copy nova** | Criar um grupo vazio produziria um chip "· 0 membros" que contradiz RN-25 ("contendo apenas confirmados") e é irreversível — o pior estado possível para uma ação de gesto único. Desabilitar é o mesmo tratamento de A-05, e a linha derivada evita inventar frase de estado vazio | n |
| A-22 | **Idempotência do CRIAR GRUPO e do POSTAR** — duplo toque, toque durante a operação | Criar grupo é **idempotente**: a segunda chamada não cria nada, não reemite toast e não altera o chip. O toggle já ativo (bloco ou modelo) é **no-op** — nenhuma escrita, nenhum rebuild de estado. Toast: **1 por vez** (RN-29), nunca dois empilhados | Precedente de `galera` A-28 e da disciplina de RN-29. Numa ação declaradamente irreversível, o duplo toque é o caminho de falha mais provável, e ele tem de ser inerte por construção, não por rapidez da UI | n |
| A-23 | **Falha do repositório** ao ler a festa, a lista ou o estado do convite | Estado de erro visível, **nunca tela branca e nunca dado parcial silencioso**; registro no `AppLogger` (AD-005). O caminho adiante permanece visível | Precedente de `galera` A-25 / GAL-25. O contrato de falha nasce agora para a spec 09 não improvisar quando o Firestore entrar | n |
| A-24 | **A barra de abas da festa não existe** — o `FestaTabsShell` é `navigationShell` cru | As duas telas **não revestem** o shell (é da spec 06 `lista`) e têm de ser alcançáveis e testáveis direto: abrir `/roles/:festaId/whatsapp` e `/roles/:festaId/whatsapp/convite` renderiza cada uma | Precedente literal de `galera` A-18. Depender da barra travaria esta spec numa que ainda não foi implementada | n |
| A-25 | **Título da aba no web** | **`bora — a conta do rolê`**, literal de W-R5, sem variação por tela | W-R5 fixa o título para o app logado, e estas duas telas são do app logado. A exceção da spec 09 (A-25) vale só para a página standalone do convidado, que chega por link compartilhado | n |
| A-26 | **"CONVITE COPIADO 📋" e "LISTA NO GRUPO 📲"** existem em RN-29, mas nenhum gesto de T-06 ou T-07 os produz | **Nenhum botão é inventado para eles.** Esta spec usa os quatro toasts que suas telas produzem: "ABRINDO O WHATSAPP… 📲", "GRUPO CRIADO NO WHATSAPP ✅", "ENQUETE POSTADA NO GRUPO 📲", "CRIE O GRUPO PRIMEIRO ☝️" | RN-29 é catálogo de textos canônicos, não lista de obrigações de tela. "LISTA NO GRUPO 📲" tem candidato natural em T-04 (spec 06); "CONVITE COPIADO 📋" não tem gesto em nenhuma tela desenhada. Criar um botão para justificar um toast é inverter a ordem — a tela manda | n |
| A-27 | **Quem pode criar grupo, postar enquete e enviar o convite** (RN-22 não fala de nenhuma das três) | **ANFITRIÃO e CO-ANFITRIÃO** ("edita tudo e cobra a galera"). CONVIDADO e SÓ VÊ não alcançam as duas telas. A tabela consultável é a que a spec 07 entrega (GAL-19); esta spec **consome**, não redefine | As três ações falam pela festa inteira para fora dela — é a mesma natureza de "cobra a galera", que RN-22 já reserva ao co-anfitrião. E consumir a tabela em vez de reinventá-la é exatamente o que a `galera` §Porte declarou que as specs 08/09/10 herdariam | n |
| A-28 | **O que acontece com o preview enquanto o estado remoto muda** (alguém confirma, alguém assume um item) com a tela aberta | O preview **recompõe ao vivo** a partir do stream, preservando quais blocos/modelo estão ativos e o voto do usuário. **Nenhum toque do usuário é descartado** por atualização vinda de fora | É W-R1 ("estado único… em tempo real") aplicado a esta tela, e é o mesmo contrato que `galera` GAL-26 já fixou para o accordion aberto. Sem isso, o "apenas confirmados" de RN-25 e o "quem leva" de RN-26b poderiam ficar velhos na tela sem nada avisar | n |

**Open questions:** nenhuma — todas resolvidas com o usuário (G4 → AD-025) ou registradas acima.

---

## Varredura de dimensões implícitas (porte Complexo — gate completo, todas as nove)

| Dimensão | Cobertura |
|---|---|
| **Input validation & bounds** | **N/A because esta feature não tem entrada de texto livre.** Toda interação é toque em toggle (enum fechado de 3 blocos e 3 modelos), toque em opção de enquete (enum fechado por modelo) ou toque em CTA. O único texto que sai é **montado pelo app** a partir de dado já validado pelas specs 05/06/07. O limite de conteúdo que existe é de **layout**, não de entrada: **CVT-09** (bolha de 300px, quebra sem truncar, sem scroll horizontal). |
| **Failure / partial-failure states** | **CVT-13** (canal de compartilhamento indisponível: sem toast de sucesso, sem copy de erro, blocos intactos, log), **CVT-31** (mesmo contrato para a enquete), **CVT-37** (falha do repositório: estado de erro visível, nunca tela branca). O grupo é **uma escrita só** — não há estado parcial possível entre "criado" e "não criado" (A-04: os membros são derivados, não gravados). |
| **Idempotency / retry / duplicate handling** | **CVT-19** (criar grupo duas vezes: a segunda é inerte — não cria, não reemite toast, não altera o chip), **CVT-14** (duplo toque no CTA: um toast por vez, RN-29), **CVT-26** (tocar a opção já votada é no-op, o voto não é removido nem duplicado), **CVT-07** (tocar o bloco/modelo já no estado desejado não muda nada). Sem retry automático em nenhum canal (A-08). |
| **Auth boundaries & rate limits** | **CVT-35** — as três ações que falam para fora (enviar convite, criar grupo, postar enquete) são de **ANFITRIÃO e CO-ANFITRIÃO**, pela tabela de RN-22 que a spec 07 entrega (A-27); CONVIDADO e SÓ VÊ não alcançam as telas. Guarda de rota herdada da AD-017. **Rate limit: N/A because** não existe chamada de rede nossa — o share sheet é do sistema operacional e o `wa.me` é do WhatsApp, ambos com quota fora do nosso controle; e o link é perpétuo e sem quota por AD-026. |
| **Concurrency / ordering** | **CVT-21** (alguém confirma com o chip já criado: a contagem de membros sobe sem que o chip volte a ser botão), **CVT-28** (mudança remota recompõe o preview preservando blocos ativos, modelo ativo e voto do usuário — nenhum toque descartado), **CVT-34** (W-R1: o mesmo grupo e o mesmo voto nas duas plataformas). Ordenação das linhas do bloco LISTA: **ordem do repositório**, nunca reordenada (precedente `galera` A-15). |
| **Data lifecycle / expiry** | **CVT-20** — o grupo e os votos vivem no `ConviteRepository` em memória, no escopo da festa: sobrevivem a rebuild, troca de aba e navegação; **não** sobrevivem a reiniciar o processo (A-03, AD-016). **Sem TTL, sem arquivamento, sem exclusão:** o grupo é irreversível por RN-25 e o voto é trocável mas nunca removível (A-02). **Expiração do link: N/A because** AD-026 o fixou perpétuo — e o link nem sequer é desta spec (é da 07). |
| **Observability** | **CVT-36** — canal de compartilhamento indisponível, falha de leitura do repositório e tentativa bloqueada de postar sem grupo são registradas no `AppLogger` (AD-005), **sem** o texto montado (ele carrega o link privado da festa e os nomes da galera). Cancelamento pelo usuário **não** gera log de erro (A-08). |
| **External-dependency failure** | **CVT-13** e **CVT-31** — o share sheet / `wa.me` é a **única** dependência externa desta feature, e ela é atravessada por uma porta própria (`CompartilhadorDeTexto`) exatamente para ser testável sem sistema operacional. Sem fallback de canal, sem retry, sem fila. Firestore só entra no M2 (AD-016). **A AD-025 removeu a dependência que seria a mais frágil** — a API do WhatsApp — antes de ela existir. |
| **State-transition integrity** | **CVT-19/CVT-21** — a máquina do grupo é de dois estados e uma aresta: `sem grupo → com grupo`, disparada uma vez, **sem volta** (RN-25 "irreversível na UI"); a contagem de membros varia dentro do estado "com grupo" sem constituir transição. **CVT-26/CVT-27** — a máquina do voto é `sem voto → votou(X) → votou(Y)`, com laço sobre si mesmo inerte e **sem aresta de volta para "sem voto"**; três máquinas independentes, uma por modelo. **CVT-30** — a trava de UC-18 E1 é uma guarda de transição: sem grupo, a ação de postar **não acontece** (não é desfeita depois). |

Nenhuma dimensão ficou em branco. As resolvidas como `N/A because` são **input validation** (não há entrada de texto livre) e **rate limit** (não há chamada de rede nossa).

---

## User Stories

### P1-1 · A mensagem por blocos e o preview fiel ⭐ MVP

**User Story**: Como anfitrião, quero montar a mensagem do convite ligando e desligando FLYER, LISTA e LINK, vendo exatamente como ela vai chegar no grupo, para não mandar um link nu que ninguém entende.

**Why P1**: É UC-07, que o roadmap declara a fatia P1 desta spec. Sem ela o link da spec 07 não tem veículo, e o produto perde a segunda das três promessas.

**Acceptance Criteria**:

1. WHEN `/roles/:festaId/whatsapp/convite` renderiza THEN o header SHALL mostrar o controle de voltar e o título "MANDAR NO GRUPO", e — **somente quando o grupo já existe** — o sub "GRUPO: CHURRAS DO RAFA 🔥". **(CVT-01)**
2. WHEN a tela abre THEN a seção rotulada "NO PACOTE" SHALL mostrar os três toggles "FLYER", "LISTA" e "LINK DO CONVITE", os três **ativos**, com o ativo em preto. **(CVT-02)**
3. WHEN o bloco FLYER está ativo THEN a bolha SHALL conter a mini-arte escura com "CHURRAS" e "DO RAFA 🔥" em duas linhas e, abaixo, a linha amarela "SÁB · 18 JUL · 14H · LAJE DO RAFA", derivada do nome, data, hora e local da festa. **(CVT-03)**
4. WHEN o bloco LISTA está ativo THEN a bolha SHALL conter uma linha por dono no formato "🥩 Carnes + pão de alho — **Rafa leva**", **uma** linha vermelha "🥤 Refri · 💧 água — quem leva?" com todos os itens sem dono, e a linha "💸 sai ~R$ X por cabeça" com o valor formatado por RN-13. **(CVT-04)**
5. WHEN o bloco LINK DO CONVITE está ativo THEN a bolha SHALL conter "bora.app/c/rafa18" em vermelho sublinhado, seguido de "confirma e escolhe o que levar 👆". **(CVT-05)**
6. WHEN a bolha renderiza THEN ela SHALL estar sobre fundo de conversa `#E7DFCB`, em branco, com borda de 2px, sombra dura de 4px preta, **largura máxima de 300px**, alinhada à direita, com a hora + "✓✓" no rodapé e a legenda central "é assim que chega no grupo — mexa nos blocos acima". **(CVT-06)**
7. WHEN o usuário liga ou desliga qualquer bloco THEN o preview SHALL recompor **no mesmo frame de interação**, sem navegação, sem confirmação e sem perder o estado dos outros dois blocos; e tocar um bloco já no estado desejado SHALL ser no-op. **(CVT-07)**
8. WHEN os três blocos estão desligados THEN a bolha SHALL **não renderizar** (fica só o fundo `#E7DFCB` e a legenda) e o CTA "ENVIAR NO WHATSAPP →" SHALL ficar desabilitado — sem afundar no press, sem abrir canal, sem toast. **(CVT-08)**
9. WHEN o conteúdo da bolha excede a altura visível THEN a bolha SHALL quebrar linha e crescer em altura dentro dos 300px de largura, a página SHALL rolar verticalmente, e **nunca** SHALL haver truncamento, reticências ou scroll horizontal. **(CVT-09)**
10. WHEN a tela abre THEN a hora do rodapé da bolha SHALL ser lida **uma vez** do relógio injetado, em `HH:mm` 24h, e **não** SHALL mudar quando o usuário mexe nos blocos — com o relógio em 14:02 renderiza exatamente "14:02 ✓✓". **(CVT-10)**

**Independent Test**: abrir a rota com a fixture RN-30, alternar os três toggles em todas as 8 combinações e conferir a bolha em cada uma, incluindo a combinação vazia e o CTA desabilitado.

---

### P1-2 · Enviar no WhatsApp ⭐ MVP

**User Story**: Como anfitrião, quero mandar a mensagem que acabei de montar direto no grupo, para chamar a galera sem copiar e colar nada.

**Why P1**: É o passo 3 e o aceite de UC-07. Sem ele a tela anterior é um visualizador.

**Acceptance Criteria**:

1. WHEN o usuário toca "ENVIAR NO WHATSAPP →" com ao menos um bloco ativo THEN o sistema SHALL entregar o texto montado ao canal de compartilhamento (share sheet no mobile, `wa.me` no web) e, **somente após o canal confirmar a abertura**, SHALL exibir o toast literal "ABRINDO O WHATSAPP… 📲" por 2200 ms. **(CVT-11)**
2. WHEN o texto é montado THEN ele SHALL conter **exatamente** os blocos ativos, na ordem FLYER → LISTA → LINK, com o mesmo conteúdo que o preview mostra; e com os três ativos SHALL conter a arte, o resumo "quem leva" com os órfãos marcados e o link clicável (aceite de UC-07). **(CVT-12)**
3. WHEN o canal de compartilhamento está indisponível ou falha THEN o sistema SHALL **não** exibir o toast de sucesso, SHALL **não** exibir copy de erro, SHALL manter os blocos e o preview intactos, e SHALL registrar a falha no `AppLogger` **sem** o texto montado. **(CVT-13)**
4. WHEN o usuário cancela o share sheet THEN o sistema SHALL tratar como não-falha: nenhum toast, nenhum log de erro, tela inalterada. **(CVT-13)**
5. WHEN o usuário toca o CTA duas vezes em sequência rápida THEN SHALL haver **um** toast por vez, nunca dois empilhados. **(CVT-14)**
6. WHEN o bloco LISTA compõe "💸 sai ~R$ X por cabeça" THEN o valor SHALL vir pronto de `core/calculo` como a **estimativa por pessoas** de RN-14, formatado por RN-13 (`R$ + Math.round`, `pt-BR`, sem centavos), e **nenhuma aritmética** SHALL existir na camada de apresentação. **(CVT-15)**

**Independent Test**: com a porta `CompartilhadorDeTexto` falsa, disparar o CTA e afirmar (a) a string entregue, (b) o toast só no caminho de sucesso, (c) a ausência de toast no cancelamento e na falha.

---

### P2-1 · Criar o grupo do rolê

**User Story**: Como anfitrião, quero criar o grupo do rolê com um toque, já com todo mundo que confirmou, para não juntar a galera na mão.

**Why P2**: É UC-17, que o roadmap coloca na fatia P2. A mensagem de convite (P1) funciona sem grupo nenhum; o grupo é o degrau seguinte.

**Acceptance Criteria**:

1. WHEN `/roles/:festaId/whatsapp` renderiza THEN o header SHALL mostrar "WHATSAPP" e o sub "grupo do rolê + enquetes num toque". **(CVT-16)**
2. WHEN o grupo ainda não existe THEN o card branco com sombra verde-WhatsApp SHALL mostrar "💬 CRIAR GRUPO DO ROLÊ", os avatares **apenas dos confirmados**, a linha "4 confirmados entram no grupo" (derivada, com plural correto) e o botão verde `CRIAR GRUPO "CHURRAS DO RAFA 🔥"`. **(CVT-16)**
3. WHEN o usuário toca o botão THEN o sistema SHALL criar, **no BORA**, um grupo cujo nome é o nome da festa e cujos membros são **apenas os confirmados** — nenhum pendente, nenhum extra sem app, nenhuma criança sem nome. **(CVT-17)**
4. WHEN o grupo é criado THEN o botão SHALL ser substituído pelo chip de fundo `#DCF8C6` `✅ "CHURRAS DO RAFA 🔥" · 4 membros` e SHALL surgir o toast literal "GRUPO CRIADO NO WHATSAPP ✅" por 2200 ms. **(CVT-18)**
5. WHEN o grupo existe THEN o botão SHALL **nunca** reaparecer — não há desfazer, não há apagar, não há renomear, em nenhum caminho da UI; e uma segunda chamada de criação SHALL ser inerte (sem novo toast, sem alteração do chip). **(CVT-19)**
6. WHEN o usuário sai da aba, navega para outra tela da festa e volta THEN o chip SHALL continuar lá, com a mesma contagem; e o mesmo SHALL valer após rebuild da árvore. **(CVT-20)**
7. WHEN alguém confirma presença **depois** de o grupo ter sido criado THEN a contagem do chip SHALL subir de "· 4 membros" para "· 5 membros" sem refresh e **sem** o chip voltar a ser botão; e quem deixa de estar confirmado SHALL sair da contagem. **(CVT-21)**
8. WHEN a festa não tem nenhum confirmado THEN a linha SHALL ler "0 confirmados entram no grupo", o card SHALL renderizar sem avatares e o botão SHALL ficar **desabilitado** — sem criar, sem toast, sem copy nova. **(CVT-22)**

**Independent Test**: criar o grupo com a fixture RN-30 (4 confirmados), afirmar chip e toast; emitir uma confirmação pelo stream e afirmar "· 5 membros"; tentar criar de novo e afirmar inércia.

---

### P2-2 · As três enquetes e o voto trocável

**User Story**: Como anfitrião, quero abrir uma enquete de horário, data ou do que levar e ver a galera votando, para decidir o rolê sem trinta mensagens no grupo.

**Why P2**: É UC-18 passos 1 e 2, na fatia P2 do roadmap. Independente do grupo — votar funciona antes de postar.

**Acceptance Criteria**:

1. WHEN a seção "ENQUETES PRO GRUPO" renderiza THEN SHALL mostrar os três toggles "HORÁRIO", "DATA" e "O QUE LEVAR", **exclusivos entre si**, com **HORÁRIO** ativo na abertura. **(CVT-23)**
2. WHEN HORÁRIO está ativo THEN o preview SHALL mostrar a pergunta "QUE HORAS COMEÇA?" com as opções "14h", "15h" e "16h" e os votos-base **5 / 2 / 1**, exibindo **63% / 25% / 13%**. **(CVT-24)**
3. WHEN DATA está ativo THEN o preview SHALL mostrar "MELHOR DATA?" com "Sáb 18" e "Dom 19" e os votos-base **6 / 2**, exibindo **75% / 25%**. **(CVT-24)**
4. WHEN O QUE LEVAR está ativo THEN o preview SHALL mostrar "QUEM LEVA A CAIXA DE SOM?" com "Eu levo 🔊" e "Não tenho 🙃" e os votos-base **3 / 1**, exibindo **75% / 25%**. **(CVT-24)**
5. WHEN o usuário toca uma opção THEN o voto dele SHALL somar **+1** àquela opção e os percentuais SHALL recalcular como `round(votos / total × 100)` — votar em "14h" leva HORÁRIO de 5/2/1 para 6/2/1 e de 63/25/13 para **67% / 22% / 11%**; e a soma dos percentuais exibidos SHALL ficar em ~100% (100 ou 101). **(CVT-25)**
6. WHEN o usuário toca **outra** opção da mesma enquete THEN o voto SHALL **mudar de lugar**, nunca somar um segundo — o total volta a subir só 1 sobre a base; e tocar a opção **já votada** SHALL ser no-op, sem remover o voto e sem alterar percentual. **(CVT-26)**
7. WHEN o usuário votou em HORÁRIO, troca para DATA, vota, e volta para HORÁRIO THEN o voto de HORÁRIO SHALL estar **preservado**, e o de DATA também — três enquetes, três votos independentes (aceite de UC-18). **(CVT-27)**
8. WHEN o preview da enquete renderiza THEN SHALL estar sobre o mesmo fundo de conversa, com o cabeçalho "📊 ENQUETE · você", a pergunta, as opções votáveis (componente do arquivo 02 §5), a hora + "✓✓" no rodapé — com o relógio em 14:05, exatamente "14:05 ✓✓" — e a legenda "toque numa opção pra votar 👆". **(CVT-28)**

**Independent Test**: percorrer os três modelos afirmando pergunta, opções e percentuais-base literais; votar, trocar de opção, trocar de modelo e voltar, afirmando os percentuais em cada passo.

---

### P2-3 · Postar a enquete — e a trava sem grupo

**User Story**: Como anfitrião, quero mandar a enquete pro grupo, e quero que o app me impeça de tentar antes de o grupo existir.

**Why P2**: É UC-18 passo 3 e a exceção E1 — a única regra desta spec que existe explicitamente para **não** deixar algo acontecer.

**Acceptance Criteria**:

1. WHEN o grupo existe e o usuário toca "POSTAR ENQUETE NO GRUPO 📲" THEN o sistema SHALL entregar ao canal de compartilhamento **apenas a enquete do modelo selecionado**, como texto — pergunta em CAIXA ALTA e uma linha por opção com rótulo literal e percentual atual, sem link e sem assinatura — e, após o canal confirmar a abertura, SHALL exibir o toast literal "ENQUETE POSTADA NO GRUPO 📲". **(CVT-29)**
2. WHEN o grupo **não** existe e o usuário toca "POSTAR ENQUETE NO GRUPO 📲" THEN o sistema SHALL exibir o toast literal "CRIE O GRUPO PRIMEIRO ☝️", SHALL **não** abrir canal nenhum, SHALL **não** montar texto e SHALL **não** alterar estado algum. **(CVT-30)**
3. WHEN o canal falha ou é cancelado ao postar a enquete THEN SHALL valer o mesmo contrato de CVT-13: sem toast de sucesso, sem copy de erro, estado da enquete e do voto intactos, falha registrada no `AppLogger`. **(CVT-31)**

**Independent Test**: tocar o CTA sem grupo e afirmar o toast da trava + zero chamadas à porta de compartilhamento; criar o grupo, tocar de novo e afirmar a string entregue e o toast de sucesso.

---

### P2-4 · As duas telas no web

**User Story**: Como anfitrião no computador, quero montar a mensagem e mexer no grupo e nas enquetes com o mesmo estado do celular.

**Why P2**: W-04 e W-R1..W-R5 são transversais e o roadmap não os coloca na fatia P1; a fatia P1 é a mensagem funcionando.

**Acceptance Criteria**:

1. WHEN qualquer das duas telas renderiza acima de ~900px THEN o conteúdo SHALL ocupar **coluna única centralizada de no máximo 560px**, e a bolha de preview SHALL permanecer em **no máximo 300px**, sem esticar para acompanhar a coluna. **(CVT-32)**
2. WHEN a tela renderiza no web THEN **não** SHALL existir rodapé-CTA fixo: os CTAs "ENVIAR NO WHATSAPP →" e "POSTAR ENQUETE NO GRUPO 📲" moram no fluxo da coluna (W-R2), e o header do app permanece sticky. **(CVT-33)**
3. WHEN a largura cai abaixo de ~900px THEN o layout SHALL colapsar para o layout mobile, com o rodapé-CTA fixo de volta (W-R3). **(CVT-33)**
4. WHEN a tela renderiza em qualquer largura THEN SHALL **nunca** haver scroll horizontal, e a rolagem SHALL ser só do documento (W-R4); e o título da aba SHALL ser "bora — a conta do rolê" (W-R5). **(CVT-33)**
5. WHEN o grupo é criado ou um voto é dado numa plataforma THEN a outra SHALL refletir o mesmo estado em tempo real (W-R1), sem refresh. **(CVT-34)**

**Independent Test**: rodar a suíte de widget nas duas larguras (390×820 e 1180×800) afirmando as larguras máximas, a ausência de rodapé fixo no expandido e a ausência de overflow horizontal nas duas.

---

### P3-1 · Permissões, falhas e alcance direto

**User Story**: Como produto, quero que só quem manda na festa fale por ela para fora, e que nada disso quebre em tela branca.

**Why P3**: RN-22 não nomeia estas três ações, e a spec-fonte não desenha estado de erro para nenhuma delas. É rede de segurança sobre comportamento já entregue, não capacidade nova.

**Acceptance Criteria**:

1. WHEN o usuário é ANFITRIÃO ou CO-ANFITRIÃO THEN SHALL poder enviar o convite, criar o grupo e postar a enquete; WHEN é CONVIDADO ou SÓ VÊ THEN SHALL **não** alcançar nenhuma das duas telas, e a decisão SHALL ler a tabela de RN-22 que a spec 07 entrega, sem redefini-la. **(CVT-35)**
2. WHEN o canal de compartilhamento falha, a leitura do repositório falha, ou o usuário tenta postar sem grupo THEN o evento SHALL ser registrado no `AppLogger` (AD-005), **sem** o texto montado e **sem** o link da festa; e o cancelamento pelo usuário SHALL **não** gerar log de erro. **(CVT-36)**
3. WHEN a leitura da festa, da lista ou do estado do convite falha THEN a tela SHALL mostrar estado de erro visível, **nunca** tela branca e **nunca** dado parcial silencioso, mantendo o caminho adiante visível. **(CVT-37)**
4. WHEN `/roles/:festaId/whatsapp` ou `/roles/:festaId/whatsapp/convite` é aberta **diretamente**, sem barra de abas revestindo o shell THEN a tela correspondente SHALL renderizar normalmente. **(CVT-37)**

---

## Edge Cases

- WHEN os três blocos estão desligados THEN a bolha não renderiza e o CTA fica desabilitado (CVT-08, A-05).
- WHEN a lista da festa está vazia THEN o bloco LISTA renderiza **só** a linha "💸 sai ~R$ 0 por cabeça", sem linha de dono e sem linha vermelha, e o toggle continua habilitado (A-12).
- WHEN todos os itens têm dono THEN a linha vermelha "quem leva?" **não** renderiza (A-12).
- WHEN nenhum item tem dono THEN não há linha de dono, e todos aparecem na linha vermelha (A-12).
- WHEN a festa não tem nenhum confirmado THEN o botão CRIAR GRUPO fica desabilitado e a linha lê "0 confirmados entram no grupo" (CVT-22, A-21).
- WHEN há exatamente 1 confirmado THEN a linha lê "1 confirmado entra no grupo" e o chip, depois de criado, lê "· 1 membro" (A-14).
- WHEN alguém confirma com o grupo já criado THEN a contagem sobe e o chip permanece chip (CVT-21, A-04).
- WHEN o usuário toca a opção de enquete em que já votou THEN nada muda — sem desvoto, sem duplicação (CVT-26, A-02).
- WHEN o usuário toca duas vezes o botão CRIAR GRUPO THEN a segunda é inerte: nenhum segundo grupo, nenhum segundo toast (CVT-19, A-22).
- WHEN o usuário toca POSTAR sem grupo THEN só o toast da trava acontece; a porta de compartilhamento **não** é chamada nem uma vez (CVT-30).
- WHEN o WhatsApp não está instalado no aparelho THEN não há toast de sucesso e não há copy de erro inventada (CVT-13, A-08).
- WHEN o usuário abre o share sheet e cancela THEN a tela fica exatamente como estava, sem log de erro (CVT-13, A-08).
- WHEN o nome da festa é longo o bastante para estourar o chip THEN o chip quebra ou elide **sem** alterar o nome gravado nem inventar abreviação; a contagem de membros permanece legível (A-13, A-07).
- WHEN o conteúdo da bolha é muito longo THEN quebra e cresce em altura, com rolagem do documento, nunca truncando (CVT-09, A-07).
- WHEN uma atualização remota chega com blocos alternados e voto dado THEN o preview recompõe preservando blocos ativos, modelo ativo e voto (CVT-28, A-28).

---

## Requirement Traceability

| ID | História | Origem na spec-fonte | Fase | Status |
|---|---|---|---|---|
| CVT-01 | P1-1 AC1 | **T-06** (header + sub condicional) · RN-25 (nome do grupo) | Design | Pending |
| CVT-02 | P1-1 AC2 | **T-06** ("NO PACOTE", 3 toggles) · **RN-26b** · A-15 | Design | Pending |
| CVT-03 | P1-1 AC3 | **T-06** (bloco FLYER, literal) · **RN-26b** · RN-30 | Design | Pending |
| CVT-04 | P1-1 AC4 | **T-06** (bloco LISTA, literal) · **RN-26b** · A-10, A-11, A-12 | Design | Pending |
| CVT-05 | P1-1 AC5 | **T-06** (bloco LINK, literal) · **RN-26b** · RN-23 (consumo) | Design | Pending |
| CVT-06 | P1-1 AC6 | **T-06** (bolha `#E7DFCB`, 2px, 4px, 300px) · **RN-26b** · arquivo 02 §5 | Design | Pending |
| CVT-07 | P1-1 AC7 | **UC-07** passos 1–2 ("preview atualiza na hora") · A-22 | Design | Pending |
| CVT-08 | P1-1 AC8 | A-05 (dimensão: state-transition, bounds de layout) | Design | Pending |
| CVT-09 | P1-1 AC9 | **W-R4** · A-07 (dimensão: bounds de conteúdo) | Design | Pending |
| CVT-10 | P1-1 AC10 | **T-06** ("14:02 ✓✓") · A-06 | Design | Pending |
| CVT-11 | P1-2 AC1 | **UC-07** passo 3 · **RN-29** ("ABRINDO O WHATSAPP… 📲") · **AD-025** · A-08 | Design | Pending |
| CVT-12 | P1-2 AC2 | **UC-07 aceite** · **RN-26b** · **AD-025** (texto é o que o WhatsApp aceita) | Design | Pending |
| CVT-13 | P1-2 AC3, AC4 | A-08 (dimensões: failure, external-dependency) · AD-005 | Design | Pending |
| CVT-14 | P1-2 AC5 | **RN-29** (1 toast por vez, 2200 ms) · A-22 (dimensão: idempotência) | Design | Pending |
| CVT-15 | P1-2 AC6 | **RN-14** (estimativa por pessoas) · **RN-13** · CLAUDE.md · spec 06 D-1 · A-10 | Design | Pending |
| CVT-16 | P2-1 AC1, AC2 | **T-07** (header, card, avatares, linha) · **UC-17** passo 1 · A-14, A-27 | Design | Pending |
| CVT-17 | P2-1 AC3 | **RN-25** ("apenas confirmados") · **UC-17** passo 2 · **AD-025** | Design | Pending |
| CVT-18 | P2-1 AC4 | **RN-25** (chip, template `<nome>`) · **RN-29** ("GRUPO CRIADO NO WHATSAPP ✅") · A-13 | Design | Pending |
| CVT-19 | P2-1 AC5 | **RN-25** ("irreversível na UI") · **UC-17 aceite** ("ação única") · A-22 | Design | Pending |
| CVT-20 | P2-1 AC6 | **UC-17 aceite** ("estado persistente") · **AD-016** · A-03 (dimensão: data lifecycle) | Design | Pending |
| CVT-21 | P2-1 AC7 | **RN-28** (consumo) · **RN-25** · A-04 (dimensão: concurrency) | Design | Pending |
| CVT-22 | P2-1 AC8 | **UC-17** pré ("≥1 confirmado") · A-21 | Design | Pending |
| CVT-23 | P2-2 AC1 | **T-07** ("ENQUETES PRO GRUPO") · **UC-18** passo 1 · A-15 | Design | Pending |
| CVT-24 | P2-2 AC2, AC3, AC4 | **RN-26** (3 modelos, opções e votos-base **literais**) · A-02 | Design | Pending |
| CVT-25 | P2-2 AC5 | **RN-26** (`% = round(votos/total×100)`) · **UC-18 aceite** ("~100%") · A-02 | Design | Pending |
| CVT-26 | P2-2 AC6 | **RN-26** ("1 voto por enquete, trocável") · A-02, A-22 | Design | Pending |
| CVT-27 | P2-2 AC7 | **UC-18 aceite** ("trocar de modelo preserva o voto") · A-09 | Design | Pending |
| CVT-28 | P2-2 AC8 | **T-07** (bolha da enquete, "📊 ENQUETE · você", legenda) · arquivo 02 §5 · A-06, A-28 | Design | Pending |
| CVT-29 | P2-3 AC1 | **UC-18** passo 3 · **RN-29** ("ENQUETE POSTADA NO GRUPO 📲") · **AD-025** · A-16, A-17 | Design | Pending |
| CVT-30 | P2-3 AC2 | **UC-18 E1** · **RN-26** ("CRIE O GRUPO PRIMEIRO ☝️") · **AD-025** | Design | Pending |
| CVT-31 | P2-3 AC3 | A-08 (dimensões: failure, external-dependency) | Design | Pending |
| CVT-32 | P2-4 AC1 | **W-04** linha "WhatsApp" (560px / 300px) | Design | Pending |
| CVT-33 | P2-4 AC2, AC3, AC4 | **W-R2, W-R3, W-R4, W-R5** · A-25 | Design | Pending |
| CVT-34 | P2-4 AC5 | **W-R1** (estado único) · A-28 (dimensão: concurrency) | Design | Pending |
| CVT-35 | P3-1 AC1 | **RN-22** (consumido da spec 07, GAL-19) · A-27 (dimensão: auth boundaries) | Design | Pending |
| CVT-36 | P3-1 AC2 | **AD-005** · A-08 (dimensão: observability) | Design | Pending |
| CVT-37 | P3-1 AC3, AC4 | A-23, A-24 (dimensão: failure) · precedente `galera` GAL-25/A-18 | Design | Pending |

**Formato do ID:** `CVT-[NN]` · **Status:** Pending → In Design → In Tasks → Implementing → Verified

**Cobertura:** 37 requisitos · **P1: 15** (CVT-01..CVT-15 — a fatia UC-07 do roadmap) · **P2: 19** (CVT-16..CVT-34 — UC-17, UC-18 e o web) · **P3: 3** (CVT-35..CVT-37) · 0 órfãos · mapeamento a tasks pendente do Design.

**Cobertura da spec-fonte:** T-06 → CVT-01..CVT-12 · T-07 → CVT-16..CVT-18, CVT-23, CVT-28, CVT-29 · W-04 + W-R1..W-R5 → CVT-32..CVT-34 · UC-07 → CVT-02, CVT-07, CVT-11, CVT-12 · UC-17 → CVT-16..CVT-22 · UC-18 → CVT-23..CVT-27, CVT-29, CVT-30 · RN-25 → CVT-17..CVT-19, CVT-21 · RN-26 → CVT-24..CVT-27, CVT-30 · RN-26b → CVT-02..CVT-06, CVT-12 · RN-29 (consumo literal) → CVT-11, CVT-14, CVT-18, CVT-29, CVT-30 · RN-13/RN-14 (consumo) → CVT-15 · RN-22 (consumo) → CVT-35 · RN-28 (consumo) → CVT-21.

---

## Porte

**Complexo** — confirma a classificação do roadmap, e o motivo central é a **AD-025**.

1. **A AD-025 realoca o domínio inteiro.** T-06 e T-07 descrevem grupo, membro, enquete, voto e percentual como se fossem objetos do WhatsApp. A AD-025 determinou que **a API pública do WhatsApp não cria grupo nem posta enquete, e a Cloud API tampouco** — logo os cinco passam a ser **estado do BORA**, e não existe **nenhuma tela na spec-fonte** que os descreva nessa condição. Esta spec tem de definir do zero o ciclo de vida de cada um (quando o grupo nasce, o que ele guarda, se os membros são congelados ou derivados, quando o voto nasce, onde ele mora, o que "persistente" significa sob AD-016) a partir de duas telas escritas para outra premissa. Isso é decisão de domínio, não layout — e é o que separa esta spec de uma spec de tela Grande.
2. **Dois artefatos de saída, com contratos de falha próprios.** O texto do convite (P1) e o texto da enquete (P2-3) atravessam a **única dependência externa** da feature — share sheet / `wa.me` —, cujo caminho de falha a spec-fonte não escreve em lugar nenhum (A-08). Definir esse contrato aqui é o que impede as specs seguintes de improvisarem cada uma o seu.
3. **Duas telas, uma linha de web, três RNs e três UCs numa spec só**, por decisão de recorte do roadmap ("é o mesmo domínio WhatsApp"). São dois blocos de estado independentes (composição da mensagem; grupo + três enquetes) que só compartilham a aba.
4. **Uma alteração no mapa canônico da AD-003** — a rota filha de T-06 sob o branch `whatsapp` (A-18) —, que é a primeira mexida naquele mapa desde a fundação.

Somados à porta `ConviteRepository` (A-03), à porta `CompartilhadorDeTexto` (A-08), à porta de relógio (A-06), ao preview fiel de bolha e às duas plataformas, o corte estimado é de **~17 tasks**, muito acima do limite de 8. **Design e Tasks são formais**, e o Design precisa fixar o formato do texto montado antes de qualquer widget existir.

**O que esta spec deixa para as outras:** o contrato de falha do canal de compartilhamento (a spec 10 vai precisar dele para "COBRAR PENDENTES NO PIX 📲" e "LEMBRAR TODO MUNDO 📲", que são a mesma natureza de aviso — AD-028); o grupo do BORA como conjunto derivado de confirmados, que a spec 09 tem de manter verdadeiro ao gravar cada RSVP; e a leitura de "quem leva o quê" como texto, que a spec 10 reusa ao explicar o racha.

---

## Divergências encontradas na spec-fonte

Registradas para que ninguém as "corrija" adiante sem saber que foram vistas.

| # | Divergência | Resolução adotada |
|---|---|---|
| **D-1** | **Caixa do nome da festa no chip.** RN-30 grava "CHURRAS DO RAFA 🔥"; o sub de T-06 lê "GRUPO: CHURRAS DO RAFA 🔥" e o botão de T-07 lê `CRIAR GRUPO "CHURRAS DO RAFA 🔥"` — mas o chip de T-07 lê `✅ "Churras do Rafa 🔥" · 4 membros`, em title case. As quatro ocorrências não podem estar todas certas com um nome só. | **A-13: vale o template de RN-25** (`✅ '<nome>' · N membros`), com o nome **como gravado**. Com a fixture renderiza `✅ "CHURRAS DO RAFA 🔥" · 4 membros`. O nome da festa é dado interpolado, não copy — e três das quatro ocorrências já estão em caixa alta. A leitura oposta (o chip normaliza para title case) permanece viável e custaria uma função de formatação, sem tocar em layout. |
| **D-2** | **RN-25 promete o que a plataforma não entrega.** O texto da regra é "gera o grupo… **no WhatsApp**" e o toast é "GRUPO CRIADO NO WHATSAPP ✅" — mas nem a API pública nem a Cloud API criam grupo, e nenhuma das duas posta enquete (RN-26). A copy afirma um efeito externo que não acontece. | **Já resolvida pela AD-025** (2026-08-27, decidida pelo usuário): grupo e enquete são **estado do BORA**; o WhatsApp recebe **texto**. A copy fica **literal** e **sem selo de "simulado"** (A-01) — o produto promete mais do que faz, e isso é trade-off registrado, na mesma forma da AD-024 para o delivery. Nesta spec a consequência aparece como linha da tabela de assumptions, não como ressalva na tela. |
| **D-3** | **Os votos-base de RN-26 não fecham com a festa.** HORÁRIO 5/2/1 = **8 votantes**, DATA 6/2 = **8**, O QUE LEVAR 3/1 = **4** — contra os **4 confirmados** de RN-30 e os "**4 membros**" de T-07. Não há em nenhuma tela da spec-fonte onde essas 8 pessoas votariam, e RN-26 diz "1 voto por enquete por pessoa". | **A-02: os votos-base são fixture de demo**, campo inicial de cada modelo, sem votante identificável; o voto do usuário **soma +1**. Preserva os números literais da regra **e** produz percentuais novos verificáveis (63/25/13 → 67/22/11). A leitura oposta — votos-base como votos reais de membros — exigiria oito pessoas na festa e contradiria RN-30 e T-07 ao mesmo tempo. |
| **D-4** | **T-06 tem dois CTAs.** "ENVIAR NO WHATSAPP →" e, "no fluxo integrado", "ENVIAR E VER O LADO DO CONVIDADO →". Só um pode estar na tela. | **A-19: o segundo fica fora do produto**, pelo mesmo critério que a spec 09 já aplicou (A-06) ao banner "← AGORA VOCÊ É A ANA": o qualificador "no fluxo (integrado)" marca a narração da demo, e o arquivo 04 já declara em letras que o "Mapa de etapas" não faz parte do produto final. |
| **D-5** | **Dois separadores no mesmo bloco.** No bloco LISTA de T-06, as linhas com dono usam " + " ("Carnes + pão de alho") e a linha órfã usa " · " ("Refri · 💧 água"). | **A-11: os dois são preservados literalmente** — " + " nas linhas de dono, " · " na linha órfã. A diferença carrega significado (somar o que alguém assumiu × enumerar o que ninguém assumiu), e uniformizar seria consertar a spec-fonte por conta própria. |
| **D-6** | **"Toggle" significa duas coisas.** T-06 chama de toggles três controles **aditivos** (os blocos se acumulam na mesma bolha); T-07 chama de toggles três controles que UC-18 descreve como **exclusivos** ("escolhe modelo → o preview **muda**", e a tela desenha **uma** bolha). | **A-15: o comportamento descrito vence o vocabulário.** Blocos de T-06 são aditivos e nascem os três ativos; modelos de T-07 são exclusivos e nascem com HORÁRIO ativo. |
| **D-7** | **"Percentuais somam ~100%" (UC-18) — e HORÁRIO soma 101.** Com 5/2/1 sobre 8: 62,5→**63**, 25→**25**, 12,5→**13**. | **Não é bug e não se conserta.** RN-26 manda `round(votos/total×100)` por opção, e o aceite de UC-18 escreve "~100%" justamente porque o arredondamento por opção não fecha. **101% é o resultado correto** e entra literalmente no critério CVT-25. Normalizar o último item para fechar 100 contrariaria a fórmula da regra. |

---

## Success Criteria

- [ ] Com a fixture RN-30 e o relógio em 14:02, T-06 com os três blocos ativos renderiza a bolha inteira — flyer, resumo "quem leva" com órfãos em vermelho, "💸 sai ~R$ X por cabeça", link sublinhado, "14:02 ✓✓" e a legenda — em compacto e em expandido.
- [ ] "ENVIAR NO WHATSAPP →" entrega ao canal exatamente o texto do preview, e o toast "ABRINDO O WHATSAPP… 📲" nunca aparece sem o canal ter aberto.
- [ ] "CRIAR GRUPO" com a fixture produz o chip `✅ "CHURRAS DO RAFA 🔥" · 4 membros`, o toast "GRUPO CRIADO NO WHATSAPP ✅", e o botão nunca mais reaparece — inclusive depois de sair da aba e voltar.
- [ ] Uma confirmação nova pelo stream leva o chip a "· 5 membros" sem que ele deixe de ser chip.
- [ ] Os três modelos renderizam os literais de RN-26 (63/25/13 · 75/25 · 75/25), o voto muda os percentuais para 67/22/11 em HORÁRIO, e trocar de modelo três vezes preserva os três votos.
- [ ] "POSTAR ENQUETE NO GRUPO 📲" sem grupo mostra "CRIE O GRUPO PRIMEIRO ☝️" e a porta de compartilhamento não é chamada nenhuma vez.
- [ ] Nenhum widget desta feature contém aritmética de dinheiro: o "por cabeça" e todo valor vêm de `core/calculo` formatados por RN-13.
- [ ] No web, as duas telas em coluna de ≤560px com bolha de ≤300px, sem rodapé fixo, sem scroll horizontal, colapsando abaixo de ~900px.
- [ ] `flutter analyze` limpo e a baseline de testes verde, acrescida da suíte desta feature — nenhum teste existente enfraquecido.
