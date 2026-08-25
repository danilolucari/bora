# Montar — Context

**Gathered:** 2026-08-25
**Spec:** `.specs/features/montar/spec.md`
**Status:** Ready for design

---

## Feature Boundary

T-03 (mobile) e W-03 (web) com steppers, chips, duração e custo recalculando ao vivo a partir de `core/calculo`, mais o rail sticky do web (card-herói + lista viva) e o rascunho de `/roles/novo`. **Não** entrega atribuição "quem leva", overrides, modos PLANEJAR/COMPRAR, essenciais visíveis, pessoas nomeadas nem WhatsApp.

---

## Implementation Decisions

### "PROS FORTES" nas duas plataformas

- O arquivo 04 põe a seção como web-only, mas isso torna o aceite de UC-03 **impossível na tela que ele descreve**: sem o chip 🍹 CACHAÇA, o total mobile fecha R$ 196, não os R$ 211 que UC-03 exige.
- Decisão: o mobile ganha a quarta seção de chips (🍸 VODKA · 🍹 CACHAÇA · 🥃 WHISKY), igual ao web.
- Efeito: o estado padrão de RN-30 é montável no celular e o exemplo canônico é demonstrável nas duas plataformas.

### "QUEM LEVA?" fora do M1

- O rail web entrega **card-herói + lista viva sem atribuição**.
- Razões: depende da lista de confirmados, que nasce na spec 07 `galera`; e o próprio W-03 declara o botão que cicla VOCÊ→ANA→LÉO→BIA como lacuna a ser substituída por popover/sheet. Construí-lo agora seria construir para jogar fora.
- **A dica tracejada "💡 Toque em QUEM LEVA?…" também sai** — sem o botão ela seria uma instrução falsa. W-03 já prevê que ela "deixa de ser necessária".
- A atribuição entra junto com `galera`/`lista`, já no formato popover.

### Onde nasce o rolê

- "🔥 CHURRASCO" (card da Home) e "+ NOVO ROLÊ" (header web) vão para `/roles/novo`, que abre um **rascunho** já montável.
- Nome default **"CHURRAS NOVO"**, data default **próximo sábado** — ambos declarados como assumption, não como literal de spec.
- Nome e data são **editáveis no próprio header** de Montar. Nenhuma tela nova, nenhum componente fora do arquivo 02.
- Na primeira mudança o rascunho é persistido e a rota passa a refletir o `festaId`.
- Rejeitado: sheet/modal de nome e data antes de montar — é componente que nem 04 nem 06 desenham.

### Os dois números que não se unificam

- O rodapé "SAI POR" mostra o total **sem** essenciais e divide por **pessoas** (criança inclusive): R$ 211 / ≈R$ 30. É o que `ResultadoDoCalculo` já documenta como "o SAI POR da tela Montar".
- O R$ 271 / ≈R$ 45 **por adulto** e com essenciais é da tela Lista (UC-05, RN-14). Os dois coexistem de propósito e o `CLAUDE.md` proíbe unificá-los.
- Pela mesma razão, **a lista viva do rail não exibe essenciais** — exibir faria a soma da lista divergir do card-herói na mesma tela.

### Categorias da lista viva

- W-03 diz "categorias com subtotal" sem nomeá-las. Ficam sendo as **três seções do próprio formulário**: NA GRELHA, NA GELADEIRA, PROS FORTES, na ordem de `ordemCanonicaDaLista`.
- O agrupamento por corredor de mercado (RN-27: AÇOUGUE → HORTIFRÚTI → PADARIA → BEBIDAS → MERCEARIA) é da spec 06 `lista` — o `corredor.dart` da camada de cálculo declara isso explicitamente.
- O kit veggie de RN-21 ("Legumes p/ grelha") entra em NA GRELHA, sem chip correspondente.

### Copy literal por plataforma

Quatro rótulos divergem entre 04 e 06, e os quatro ficam:

| Mobile (T-03) | Web (W-03) |
|---|---|
| CONFIRMADOS + EXTRAS SEM APP | QUEM CONFIRMOU |
| QUANTO TEMPO DE FESTA? | ATÉ QUE HORAS? |

Unificar seria escolher qual spec desobedecer.

### Fronteira com `core/calculo` (a regra que mais importa aqui)

- **Zero aritmética de domínio e zero formatação de dinheiro** em `lib/features/montar/**`, policiado por guard de varredura no molde dos que a spec 01 instalou.
- Se a tela precisar de um número que a camada não expõe, **a conta nasce lá**, como desvio registrado — nunca no widget.
- Isso inclui o rótulo "Dia todo" (via `rotuloDeDuracao`) e todo `R$` (via `MoneyFormatter`).

### Agent's Discretion

- Rótulo "SALVAR ROLÊ" para a saída sem WhatsApp (A-14) — W-03 pede a ação sem dar copy; o toast que ela dispara é o canônico "ROLÊ SALVO ✊" de RN-29.
- Ausência de teto nos steppers (A-11), comportamento de nome apagado (P1-5 AC6), e estrutura interna de bloc/widgets: livres.

### Declined / Undiscussed Gray Areas → Assumptions

- **Persistência da composição** (A-12) — não discutida; default: salva no `FestaRepository` em memória a cada mudança, sobrevive à navegação dentro da festa, como W-R1 exige.
- **Destino de "FECHAR LISTA →" e "MANDAR NO GRUPO 📲"** (A-13) — default: navegam para os placeholders de `/roles/{festaId}/lista` e `/roles/{festaId}/whatsapp`.
- **Consumo de RN-21 sem produtor** (A-10, P2-2) — default: o consumo nasce correto agora, exercitado por composições com pessoas nomeadas montadas em teste, para que `galera` não tenha de reescrever esta tela.

---

## Specific References

- O aceite de UC-03 é um **número na tela**, não num teste unitário: R$ 211 e ≈R$ 30 têm de aparecer renderizados. Foi isso que decidiu a questão de "PROS FORTES".
- W-R1 (estado único entre plataformas) e W-R4 (nunca scroll horizontal) valem como critério, não como recomendação.

---

## Deferred Ideas

- **Seletor "QUEM LEVA?" em popover/bottom sheet** com a lista de confirmados e quanto cada um já leva — vai para `galera`/`lista`, no formato que W-03 pede.
- **Modos PLANEJAR/COMPRAR no rail** (segmented no topo) — spec 06 `lista`.
- **Overrides de quantidade e preço** com ponto vermelho e RESTAURAR — RN-12/UC-06, spec 06.
- **Essenciais visíveis com badge "AUTO ∝"** — UC-05, spec 06.
- **Teto e auto-repeat nos steppers** — nenhuma spec pede; só o piso de 0 é regra (UC-03 E1).
