# Home — Context

**Gathered:** 2026-08-25
**Spec:** `.specs/features/home/spec.md`
**Status:** Ready for design

---

## Feature Boundary

A tela `/roles` (T-02 mobile, W-02 web) mais o header de app de `06`, o revestimento do `PlaceholderPage`, e a porta `FestaRepository` com implementação em memória. Entrega o **lado consumidor** de RN-28 — contadores reativos — e as duas saídas do M1: "MONTAR LISTA →" e "🔥 CHURRASCO". **Não** entrega convite, acerto, montagem nem Firestore.

---

## Implementation Decisions

### Origem dos dados (zona cinzenta G8 — resolvida junto com a spec 03)

- `FestaRepository` nasce como **porta abstrata** em `features/home/domain/`.
- A implementação do M1 é **em memória**, semeada pela fixture RN-30 que a fundação já deixou em `test/fixtures/`.
- **Firestore entra no M2**, com a spec 09 `convidado` — que é quem produz a confirmação de RN-28. Trocar a impl não pode tocar em bloc nem em tela.
- Consequência: a suíte de widget do M1 roda sem emulador ligado.

### RN-28 sem produtor

- A Home consome um **`Stream`**, não um `Future`, mesmo sem ninguém produzir confirmação no M1.
- A impl em memória expõe um método de teste que empurra a confirmação; o AC de RN-28 é afirmado por ele: contadores de "4 confirmados · 2 pendentes" para "5 confirmados · 1 pendente", **sem remontar a tela**, e o botão amarelo "💸 VER O ACERTO DA FESTA →" aparecendo.
- O par discriminante importa: sem confirmação nova o botão amarelo **não** existe. Um teste que só afirme presença passaria com o botão sempre visível.

### Festas passadas e Home vazia

- A fixture ganha **duas festas concluídas**. Uma é a "Churras da laje · 14 pessoas · R$ 612" literal de UC-24; a outra é inventada e fica **marcada como assumption**, não como literal de spec.
- Motivo: T-02 diz "2 passadas" e W-02 tem a seção ARQUIVO, mas RN-30 só define uma festa ativa. Sem as passadas, o aceite de UC-24 fica sem prova.
- O subtítulo "1 festa chegando · 2 passadas" passa a ser **derivado** da contagem, com plural correto — com a fixture ele dá exatamente a string literal de T-02.
- **Estado vazio próprio**: sem festa, o card não renderiza, o subtítulo vira "nenhuma festa chegando", "COMEÇAR OUTRA" continua (é o único caminho adiante) e o ARQUIVO renderiza vazio. É o que vê todo usuário que acabou de se cadastrar pela spec 03.

### Header de app

- Sticky, com fundo `paper`, borda inferior 2px `ink`, logo "BORA." 20px e avatar amarelo com a inicial do usuário logado.
- **A ação "+ NOVO ROLÊ" só existe no web** — T-02 não desenha barra de app nenhuma no mobile, então a entrada para criar rolê no celular é o card "🔥 CHURRASCO".
- "+ NOVO ROLÊ" e "🔥 CHURRASCO" vão para o **mesmo destino**: `/roles/novo`.
- O `#FFD23F` do arquivo 06 é o token `BoraColors.yellow` já existente — não vira literal novo.

### Navegação para telas que ainda não existem

- "+ CONVIDAR" → `/roles/{festaId}/whatsapp` (placeholder até a spec 08).
- "💸 VER O ACERTO DA FESTA →" → `/roles/{festaId}/custos` (placeholder até a spec 10).
- Navegar para placeholder é honesto e testável; botão inerte não seria.

### Divisão da herança da AD-013

- `AppShell` e `PlaceholderPage` são desta spec.
- `lib/app.dart` e `RouteErrorPage` ficaram com a spec 03.
- `FestaTabsShell` vai para a spec 06 `lista` — nenhuma tela do M1 monta as abas da festa.

### Agent's Discretion

- Derivação do subtítulo com plural (A-05), tratamento de linha do ARQUIVO como não clicável (A-12), ausência da lista de arquivo no mobile (A-11): a spec-fonte não decide. Defaults registrados como assumptions.
- Estrutura do bloc, nomes de eventos/estados e composição interna dos widgets: livre dentro da Clean Architecture.

### Declined / Undiscussed Gray Areas → Assumptions

- **Ação do avatar do header** — `06` o descreve como elemento sem ação; default: decorativo no M1, sem logout. Nenhuma spec define destino.
- **Detalhe de festa passada** — default: linha do ARQUIVO não navega (A-12), porque inventar rota furaria o mapa canônico da AD-003.
- **Múltiplas festas chegando** — não discutido; default registrado como edge case: um card por festa, na ordem do repositório.

---

## Specific References

- Os literais de T-02 e W-02 devem sair como **consequência do dado da fixture**, não como string fixa: "1 festa chegando · 2 passadas" e "4 confirmados · 2 pendentes" continuam sendo o aceite, mas derivados.
- Orçamento de acento do arquivo 02 respeitado sem escolha: a Home usa vermelho e amarelo, exatamente dois.

---

## Deferred Ideas

- **Logout / troca de conta pelo avatar** — quando alguma spec definir o destino.
- **Abrir uma festa passada** — precisaria de tela de detalhe que nenhum arquivo da spec-fonte desenha.
- **Rolês do tipo NIVER** — "EM BREVE" é literal; o slot existe justamente para ser não clicável.
- **Ordenação e filtro do arquivo** — nenhuma spec pede.
