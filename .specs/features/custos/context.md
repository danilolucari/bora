# Custos & acerto — Context

**Gathered:** 2026-08-27
**Spec:** `.specs/features/custos/spec.md`
**Status:** Ready for design

---

## Feature Boundary

A aba `custos` da festa (`/roles/:festaId/custos`, AD-003) nas suas **duas faces** — **CUSTOS DA FESTA** (despesas, split, progresso de quitação, meio de pagamento) e **ACERTO DO ROLÊ** (quem levou o quê, saldos, quem paga quem, cobrança) —, nas duas plataformas (T-09 compacto, W-04 expandido), cobrindo **UC-19 a UC-23**. **RN-19** nasce aqui como estado de UI; **RN-14, RN-15, RN-16, RN-17, RN-18 e RN-20 são consumo** de `core/calculo` — nenhuma aritmética nasce nesta feature.

**Fora:** a lista e o pedido por delivery (spec 06 — esta spec **recebe** a `Despesa`), o RSVP e o "EU LEVO" (spec 09 — **recebe** a contribuição), pessoas e papéis (spec 07 — **consome** RN-22), a mensagem, o grupo e as enquetes do WhatsApp (spec 08). E, nomeadamente, **a criação manual de despesa** — AD-027.

---

## Implementation Decisions

### AD-027 · Despesa não se cria à mão (G6a) — fechada com o usuário em 2026-08-27

- Toda `Despesa` nasce de **três fontes que já existem**: "EU LEVO" do convidado (RN-20), o pedido por delivery (RN-27 / AD-024, no nome de quem pediu) e o que o anfitrião assume na lista.
- **T-09 não ganha "+ DESPESA"**; **UC-19 continua sendo só leitura**, exatamente como a spec-fonte o escreve.
- A lacuna — gasto fora da lista (uber, gás, aluguel de churrasqueira) não tem onde entrar — é **declarada**, não corrigida: vira a linha de assumption **A-20** e a entrada correspondente em Deferred Ideas, citando a AD-027. Não vira requisito.

### AD-028 · Cobrança é aviso + estado (G6b) — fechada com o usuário em 2026-08-27

- "COBRAR NO PIX 📲", "COBRAR PENDENTES NO PIX 📲" e "LEMBRAR TODO MUNDO 📲" **avisam e mudam estado**. Nada de movimentação financeira.
- **Nenhuma chave Pix, nenhum BR Code, nenhum app de banco.** O segmented PIX / CARTÃO / DINHEIRO de RN-19 é **etiqueta**, não meio de execução.
- Quem marca PAGO ✓ **declara, não comprova** — e isso entra como requisito (CUST-08, CUST-10), não como ressalva de rodapé.
- **Leitura estreita, declarada:** a frase de AD-028 "o progresso de RN-18 atualiza" é lida como "a linha muda de estado e a tela reflete", **não** como "cobrança conta como quitação". A barra verde conta apenas `paga` (A-07 / D-4) — a leitura larga faria a barra encher com um toque em "cobrar", e destruiria o aceite escrito de UC-23 ("linhas pagas nunca são cobradas").

### A premissa A-16 de `calculo` — resolvida por esta spec

`.specs/features/calculo/validation.md` deixou em aberto o que a tela quer de `progressoDeQuitacao` quando não existe **nenhuma** linha de acerto: a camada devolve `fracao = 1.0` (barra cheia), e `0.0` seria igualmente defensável.

**Resolução (A-09 · CUST-33): a tela nunca pergunta.** Sem despesa e sem contribuição, a face cai num **estado vazio próprio** — card-herói com "TOTAL DA FESTA" R$ 0, a linha de cota e a dica literal — e **não renderiza barra de progresso alguma**, nem as seções.

- **Por quê:** `1.0` mente para cima (tudo quitado numa festa em que ninguém pagou nada) e `0.0` mente para baixo (nada quitado quando não há nada a quitar). A saída honesta é não pintar barra quando não há o que quitar.
- **Exige mudança em `core/calculo`? Não.** A camada continua correta no seu próprio vocabulário ("nada pendente"), continua com os 344 testes verdes e o Verifier em PASS, e o `1.0` simplesmente deixa de ser observável. **A premissa A-16 fica fechada sem uma linha de mudança naquela camada.**

### As duas faces de T-09 (A-01, A-02)

- **Uma rota, duas faces mutuamente exclusivas, sem controle novo.** Nem segmented de face (exigiria dois rótulos que a fonte não escreve), nem segunda rota (contrariaria a AD-003, que fixou quatro abas permanentes).
- A face é o **momento da festa**: **CUSTOS DA FESTA** enquanto a festa não terminou; **ACERTO DO ROLÊ** a partir de `festa.status == StatusDaFesta.passada` **ou** do fim previsto (início + duração de RN-02), o que vier primeiro. O relógio é **injetado**, nunca `DateTime.now()` dentro de widget.
- O critério duplo não é indecisão: **nenhuma spec anterior produz a transição de status** (a spec 04 declarou que a fixture já nasce com festas passadas), e sem o relógio a face ACERTO — que carrega o Teste A, aceite do M3 — ficaria inalcançável.
- As duas faces leem **o mesmo dado** e diferem só em apresentação: a face CUSTOS agrupa por despesa ("quem adiantou"), a face ACERTO agrupa por pessoa ("quem levou o quê").

### A máquina de estado da linha (A-06, A-07)

- **Duas flags persistidas por linha:** `paga` (quitação de RN-18, alimenta a barra) e `cobrada` (registro do aviso, não alimenta a barra).
- Transições: `PENDENTE → COBRADO ✓` (irreversível — desfazer um aviso não desfaz o aviso; precedente do chip irreversível de RN-25), `PENDENTE → PAGO ✓`, `COBRADO ✓ → PAGO ✓`, e `PAGO ✓ → PENDENTE` (UC-22 A1, o único desfazer que a fonte escreve, que também limpa `cobrada`).
- `PAGO ✓` **blinda** a linha contra cobrança e lembrete — é o aceite literal de UC-23.
- `cobrada` **não** existe em `LinhaDeAcerto` e **não** exige mudança em `core/calculo`: vive no estado desta feature, chaveada por `(de, para)`, junto com a marcação de quitação.

### Reentrância — despesa nova depois de o acerto começar (A-08)

A decisão de maior risco da spec. **O acerto é sempre derivado, nunca congelado**, e a marcação é guardada por **par `(de, para)`**, não por posição de linha:

- **(a)** par que continua existindo e cujo valor **não aumentou** → mantém `paga` e `cobrada`;
- **(b)** par cujo valor **aumentou** → volta a PENDENTE e perde `cobrada`;
- **(c)** par que sumiu do resultado → perde o registro;
- **(d)** par novo → nasce PENDENTE.

O progresso é **recomputado** das linhas resultantes, nunca acumulado. Congelar tornaria a contribuição de RN-20 invisível depois do primeiro pagamento — e RN-20 existe justamente para descontar o que a pessoa levou.

### Agent's Discretion

O usuário fechou G6 em duas ADs e não opinou sobre layout, densidade, ordem de seções dentro de cada face, escolha de componentes do design system, nem sobre a estrutura de pastas da feature. O Design decide, respeitando: os tokens e componentes do arquivo 02 sem exceção, a copy literal de T-09 e de RN-29, a ordem de linhas de `calcularRacha` (que **não** é discricionária — A-18), e o grid `1fr / 370px` de W-04.

### Declined / Undiscussed Gray Areas → Assumptions

Todas as ambiguidades abaixo foram resolvidas pelo agente e estão na tabela **Assumptions & Open Questions** do `spec.md`, com default e racional completos. Resumo:

| # | Ambiguidade | Default |
|---|---|---|
| A-01 | As duas faces de T-09 | Uma rota, duas faces, sem controle novo |
| A-02 | O que define "pós-festa" | `status == passada` **ou** fim previsto (início + duração), relógio injetado |
| A-03 | Destino do atalho "💸 VER O ACERTO DA FESTA →" | A aba `custos`; a face é a do momento (D-1) |
| A-04 | Quem vê a aba | Todo participante confirmado, qualquer papel (UC-20) |
| A-05 | Quem marca PAGO ✓ | Anfitrião, co-anfitrião ou o **devedor**; o credor não |
| A-06 | Desfazer | PAGO ✓ desfaz (UC-22 A1); COBRADO ✓ não |
| A-07 | Cobrado × pago | Duas flags; só `paga` na barra (D-4) |
| A-08 | Reentrância | Sempre derivado; marcação por par, regras (a)–(d) |
| A-09 | Estado vazio | Sem linha, sem barra — fecha A-16 sem mudar `calculo` |
| A-10 | Ninguém deve nada | Tags NO ZERO; "QUEM PAGA QUEM", barra e CTA omitidos |
| A-11 | Meio de pagamento global ou por linha | **Global por festa**, persistido, default PIX |
| A-12 | Quem troca o meio | Anfitrião ou co-anfitrião |
| A-13 | Os rótulos "NO PIX" variam com o segmented? | Não — literais e fixos; muda a etiqueta das linhas |
| A-14 | Canal da notificação do devedor | A escrita realtime; sem push, e-mail ou WhatsApp |
| A-15 | "LEMBRAR TODO MUNDO 📲" | Só avisa, não muda estado; toast canônico (D-2) |
| A-16 | Junção de "levou R$ X · itens" | Vírgula + " e " antes do último |
| A-17 | Adultos (cota) × nomeados (acerto) | Cota por `adultos`; a diferença não vira linha (D-3) |
| A-18 | Ordem das linhas | A de `calcularRacha`; a tela não reordena |
| A-19 | Onde vive `cobrada` | Estado da feature, por par; `calculo` não muda |
| A-20 | Gasto fora da lista | Não entra — AD-027, lacuna declarada |
| A-21 | Rate limit da cobrança | Nenhum; o limite é estrutural |
| A-22 | Identidade da pessoa | O **nome**, como a camada de cálculo já entrega |

**Nenhuma ficou silenciosamente em aberto.**

---

## Specific References

- **T-09 é literal, nas duas faces.** "TOTAL DA FESTA", "cota justa R$ 80 — entre 4 adultos, criança de fora", "cota justa R$ 95 / adulto", "💡 Quem levou coisa paga menos — é isso que evita a treta.", "QUEM LEVOU O QUÊ", "DESPESAS · QUEM ADIANTOU", "MEIO DE PAGAMENTO", "QUEM PAGA QUEM", "MARCAR PAGO" ⇄ "PAGO ✓", "COBRAR NO PIX" ⇄ "COBRADO ✓", "COBRAR PENDENTES NO PIX 📲", "LEMBRAR TODO MUNDO 📲".
- **RN-15 é literal:** "RECEBE R$ X" / "PAGA R$ X" / "NO ZERO". **RN-18 é literal:** "N de M quitados · R$ X de R$ Y", barra verde `#25D366`.
- **RN-29 é literal:** "COBRANÇA ENVIADA NO PIX 📲" e "LEMBRETE MANDADO NO GRUPO 📲" — 2200 ms, um por vez.
- **Os Testes A e B de RN-16 entram na tela, com a ordem:** A → LÉO→VOCÊ R$ 80 · BIA→VOCÊ R$ 40 · BIA→ANA R$ 40 (total 320, cota 80). B → LÉO→RAFA R$ 35 · BIA→RAFA R$ 70 · BIA→ANA R$ 25 (total 380, cota 95). Não são ilustração: são o critério verificável do marco M3.
- **A camada de cálculo é consumida pelos nomes reais**, sem apelido e sem reimplementação: `cotaPorAdulto`, `contribuicoesPorPessoa`, `calcularSaldos`, `calcularRacha`, `splitIgualitario`, `progressoDeQuitacao`, `MoneyFormatter`, sobre `Despesa`, `SaldoDePessoa`, `SituacaoDeSaldo`, `LinhaDeAcerto` e `ProgressoDeQuitacao` — tudo por `package:bora/core/calculo/calculo.dart`, a porta única.
- **Precedentes de forma seguidos de outras specs:** sem sucesso, sem toast de sucesso (`galera` A-07, `convidado` A-13); CTA sem alvo fica inerte em vez de ganhar copy nova (`lista` A-07); artefato de protótipo é descartado elemento a elemento (`convidado` A-06); junção de lista com vírgula e " e " (`convidado` A-18).

---

## Deferred Ideas

Ideias que apareceram e ficam **fora** desta spec, registradas para não se perderem:

- **Despesa avulsa** — uber, gás, aluguel de churrasqueira, o que se gastou fora da lista. É a lacuna declarada da **AD-027** e o candidato mais forte a spec própria depois do M3: exige tela de criação, copy nova e uma decisão sobre quem pode lançar em nome de quem.
- **Pix de verdade** — chave por pessoa, BR Code / copia-e-cola, deep link de banco, conciliação. Revisitar junto com a AD-009 (que já avisa que `int` em centavos seria a política certa "se o produto passar a cobrar de verdade") e com a ressalva de exposição pública das ADs 024 e 025.
- **Notificação fora do app** — push (FCM), e-mail ou mensagem no WhatsApp para o devedor. Hoje o canal é a escrita realtime (A-14); qualquer um desses exige token, permissão e uma superfície de aviso que nenhuma tela da spec-fonte desenha.
- **Comprovante** — anexar foto/recibo a uma linha, ou histórico de cobranças enviadas. AD-028 já declarou que marcar é declarar; comprovar é outro produto.
- **O acerto para quem não tem conta** — o convidado hoje só alcança a festa por `/c/:codigo` (AD-026), e essa rota é da spec 09. Levar a face ACERTO até lá é feature própria, com decisão de segurança própria.
- **Fechar o rolê pela tela** ("ROLÊ SALVO ✊", UC-24) — hoje nenhuma tela produz a transição para `passada`, e por isso esta spec usa o relógio como segundo critério (A-02). Quando alguma spec ganhar a ação, o critério de momento fica mais simples, não mais complicado.
