# 05 — Casos de uso

Formato: **Ator · Pré-condições · Fluxo principal · Alternativas/Exceções · Regras · Aceite**. Papéis conforme RN-22.

---

## UC-01 · Entrar no app
**Ator:** qualquer usuário. **Pré:** app aberto na tela Entrar.
1. Usuário informa e-mail e senha e toca "COMEÇAR →" (ou "CONTINUAR COM GOOGLE").
2. Sistema autentica e abre "Seus rolês".
**Alternativas:** A1 novo usuário toca "CRIAR CONTA". 
**Aceite:** login por e-mail e Google presentes; foco de input com borda vermelha; pós-login sempre cai na Home.

## UC-02 · Ver painel de rolês
**Ator:** anfitrião. **Pré:** logado.
1. Home mostra festa ativa (data, avatares, "4 confirmados · 2 pendentes") e histórico.
2. Ações do card: "+ CONVIDAR" (→ UC-07) e "MONTAR LISTA →" (→ UC-03).
**Alternativas:** A1 há confirmação nova → contadores atualizados + atalho "💸 VER O ACERTO DA FESTA →" (RN-28).
**Aceite:** contadores refletem RSVPs em tempo real; "NIVER · EM BREVE" não é clicável.

## UC-03 · Montar a festa
**Ator:** anfitrião/co-anfitrião. **Pré:** festa criada ou template "CHURRASCO" tocado.
1. Ajusta extras sem app (steppers H/M/C).
2. Seleciona itens por chips (grelha/geladeira/fortes).
3. Define duração (2h/4h/6h/Dia).
4. Rodapé recalcula "SAI POR" a cada toque (RN-01..10).
5. Toca "FECHAR LISTA →".
**Exceções:** E1 0 pessoas → lista vazia e total R$ 0 (nunca negativo, steppers não descem de 0).
**Regras:** RN-01..RN-10, RN-13. **Aceite:** exemplo de teste do arquivo 03 bate exatamente (R$ 211 / R$ 30 por cabeça).

## UC-04 · Acompanhar custo ao vivo
**Ator:** anfitrião. **Pré:** em Montar ou Lista.
1. Qualquer mudança (pessoa, chip, duração, override) atualiza total e per capita imediatamente, sem botão "calcular".
**Aceite:** latência imperceptível; valor por cabeça usa "/ cabeça" na montagem e "por adulto" na lista (RN-14).

## UC-05 · Revisar lista com essenciais automáticos
**Ator:** anfitrião. **Pré:** lista fechada.
1. Sistema exibe categorias, incluindo "ESSENCIAIS · ENTRAM SOZINHOS" com badges "AUTO ∝ carne/bebidas/pessoas" (RN-10).
2. Subtotal por categoria e total geral visíveis.
**Aceite:** carvão, gelo, sal grosso e copos & pratos presentes sem ação do usuário.

## UC-06 · Ajustar quantidade e preço de um item
**Ator:** anfitrião/co-anfitrião (ou convidado com link "EDITAR LISTA"). **Pré:** lista aberta.
1. Toca o item → linha expande (caret ▴) com steppers QUANTIDADE e PREÇO.
2. Ajusta valores (passos e mínimos de RN-12); item ganha ponto vermelho.
3. Total recalcula ao vivo.
**Alternativas:** A1 "RESTAURAR" remove todos os overrides e o botão some.
**Aceite:** abrir um item fecha o anterior; overrides sobrevivem à navegação dentro da festa.

## UC-07 · Montar e enviar o convite no grupo
**Ator:** anfitrião. **Pré:** lista fechada.
1. Abre "MANDAR NO GRUPO"; ativa/desativa blocos FLYER / LISTA / LINK (RN-26b).
2. Preview da bolha atualiza na hora.
3. Toca "ENVIAR NO WHATSAPP →" → abre o compartilhamento (toast "ABRINDO O WHATSAPP… 📲").
**Aceite:** com os 3 blocos ativos a mensagem contém arte, resumo "quem leva" (itens órfãos em vermelho) e link clicável.

## UC-08 · Convidado abre o link e confirma (RSVP)
**Ator:** convidado sem conta. **Pré:** recebeu `bora.app/c/rafa18`.
1. Link abre o flyer personalizado ("ANA, VOCÊ FOI CHAMADA") com data, local e "sai ~R$ X".
2. Toca "BORA! ✊" → vai para "escolher o que leva" (UC-09).
**Alternativas:** A1 "NÃO VOU 😔" → UC-10.
**Regras:** RN-23 (nível do link), RN-24. **Aceite:** nenhuma etapa pede download ou cadastro.

## UC-09 · Convidado escolhe o que leva
**Ator:** convidado confirmado. **Pré:** UC-08 concluído com "BORA!".
1. Vê itens ainda sem dono com valores; itens do anfitrião aparecem como dica ("RAFA já leva…").
2. Alterna "EU LEVO" ⇄ "VOCÊ LEVA ✓"; rodapé soma "VOCÊ LEVA R$ X".
3. "CONFIRMAR →" → tela "TÁ MARCADO! ✊" com resumo do que leva.
**Alternativas:** A1 não escolhe nada → confirma com "nada — só a presença ✊". A2 "mudar o que eu levo" reabre a escolha. A3 "📅 SALVAR NA AGENDA" (toast).
**Regras:** RN-20 (desconta da cota), RN-28. **Aceite:** valor escolhido aparece depois como contribuição no acerto.

## UC-10 · Convidado recusa / muda de ideia
**Ator:** convidado. 
1. "NÃO VOU 😔" → tela "QUE PENA" e anfitrião é avisado.
2. "MUDEI DE IDEIA ✊" reabre o convite (UC-08).
**Aceite:** recusa não exige justificativa; retorno possível a qualquer momento antes da festa.

## UC-11 · Gerenciar preferências de uma pessoa
**Ator:** anfitrião/co-anfitrião (cada um edita as próprias). **Pré:** tela "A GALERA".
1. Toca a pessoa → expande.
2. Define RESTRIÇÃO ALIMENTAR (tudo/veggie/sem porco) e BEBIDA (bebe/não bebe).
3. Sublinha da pessoa e resumo amarelo atualizam ("A lista já se ajusta…" — RN-21).
**Aceite:** lista reflete: kit veggie quando há veggie; sem suína quando há "sem porco"; cerveja dimensionada por quem bebe.

## UC-12 · Alterar nível de acesso de um participante
**Ator:** somente anfitrião. **Pré:** tela "A GALERA", pessoa ≠ anfitrião.
1. Expande a pessoa → "NÍVEL DE ACESSO" → escolhe CONVIDADO / CO-ANFITRIÃO / SÓ VÊ.
2. Tag da pessoa muda de cor conforme papel (RN-22).
**Exceções:** E1 pessoa é o anfitrião → controles ocultos, nota "👑 Anfitrião manda em tudo — acesso fixo."
**Aceite:** permissões efetivas seguem a tabela RN-22.

## UC-13 · Configurar e copiar o link de convite
**Ator:** anfitrião. **Pré:** tela "A GALERA".
1. Escolhe o nível no segmented "QUEM ABRIR O LINK PODE…" (SÓ VER / EDITAR LISTA / CO-ANFITRIÃO).
2. Nota explicativa muda conforme o nível (copy RN-23).
3. "COPIAR 🔗" ou "+ CONVIDAR MAIS GENTE 🔗" → toast "LINK COPIADO 🔗".
**Aceite:** quem abrir o link entra com o papel configurado no momento da abertura.

## UC-14 · Consultar preço médio real (planejar)
**Ator:** qualquer participante com acesso à lista. **Pré:** modo PLANEJAR.
1. Cada item mostra média, "média de N mercados" e barra mín/máx com marcador (RN-11).
2. Rodapé mostra média total + "faixa real: de R$ X a R$ Y".
**Aceite:** posição do marcador = (média−mín)/(máx−mín); dados da tabela RN-11 reproduzidos.

## UC-15 · Comprar no mercado (checklist por corredor)
**Ator:** quem vai ao mercado. **Pré:** modo COMPRAR.
1. Itens agrupados por corredor (ordem fixa RN-27).
2. Toca a linha → check verde, linha esmaece; contador "N de M no carrinho" atualiza.
**Aceite:** estado dos checks persiste ao alternar PLANEJAR ⇄ COMPRAR.

## UC-16 · Fazer pedido por delivery
**Ator:** anfitrião/co-anfitrião. **Pré:** lista com itens.
1. "FAZER PEDIDO 🛒" (ou "PEDIR O QUE FALTA 🛵" no modo comprar) abre a sheet.
2. Confere endereço (📍 local da festa, "TROCAR" disponível).
3. Escolhe parceiro (iFood/Rappi/Zé — ETA e frete de RN-27); resumo Subtotal/Frete/Total.
4. "CONFIRMAR PEDIDO →" → overlay "PEDIDO A CAMINHO! 🛵" com ETA e "R$ total · rachado no acerto da festa".
**Alternativas:** A1 toca fora ou ✕ → fecha sem pedir. A2 modo comprar: só itens não marcados entram.
**Regras:** RN-20 (vira despesa de quem pediu), RN-27. **Aceite:** total = subtotal + frete do parceiro; Zé tem frete grátis.

## UC-17 · Criar grupo no WhatsApp
**Ator:** anfitrião. **Pré:** ≥1 confirmado.
1. Tela WhatsApp mostra avatares e "4 confirmados entram no grupo".
2. "CRIAR GRUPO “CHURRAS DO RAFA 🔥”" → toast "GRUPO CRIADO NO WHATSAPP ✅"; botão vira chip "✅ … · 4 membros".
**Regras:** RN-25 (só confirmados; nome = nome da festa). **Aceite:** ação única, estado persistente.

## UC-18 · Criar enquete e votar
**Ator:** anfitrião cria/posta; membros votam. **Pré:** —.
1. Escolhe modelo (HORÁRIO / DATA / O QUE LEVAR) → preview da enquete muda.
2. Toca uma opção para votar; barras e % recalculam (RN-26); voto é trocável (1 por enquete).
3. "POSTAR ENQUETE NO GRUPO 📲" → toast de sucesso.
**Exceções:** E1 grupo não criado → toast "CRIE O GRUPO PRIMEIRO ☝️" e nada é postado.
**Aceite:** percentuais somam ~100%; trocar de modelo preserva o voto de cada enquete.

## UC-19 · Registrar quem pagou o quê (despesas)
**Ator:** anfitrião/co-anfitrião. **Pré:** tela Custos.
1. Despesas listadas com "Fulano pagou" e "split R$ X × 4" (RN-17).
2. Card-herói mostra total e "cota justa R$ X / adulto" (RN-14).
**Aceite:** teste B de RN-16 reproduzido (total 380 → cota 95).

## UC-20 · Ver quem paga quem (split automático)
**Ator:** todos os confirmados. **Pré:** há despesas/contribuições.
1. Sistema calcula saldos (RN-15) e gera as linhas mínimas de transferência (RN-16).
2. No acerto pós-festa, tags RECEBE/PAGA/NO ZERO por pessoa.
**Aceite:** linhas batem com os testes A e B de RN-16; soma paga = soma recebida.

## UC-21 · Escolher meio de pagamento
**Ator:** quem vai pagar. **Pré:** tela Custos.
1. Segmented PIX / CARTÃO / DINHEIRO → etiqueta das linhas muda (RN-19).
**Aceite:** default PIX; seleção única.

## UC-22 · Marcar pagamento como quitado
**Ator:** anfitrião/co-anfitrião (ou o próprio pagador). **Pré:** linhas de acerto existem.
1. "MARCAR PAGO" → botão vira "PAGO ✓" verde; barra de progresso e label "N de M quitados · R$ X de R$ Y" atualizam (RN-18).
**Alternativas:** A1 toque de novo desfaz (volta a pendente).
**Aceite:** progresso 100% quando todas as linhas pagas.

## UC-23 · Cobrar pendentes
**Ator:** anfitrião/co-anfitrião. **Pré:** ≥1 linha pendente.
1. "COBRAR PENDENTES NO PIX 📲" → toast "COBRANÇA ENVIADA NO PIX 📲" (só pendentes recebem).
**Variante (acerto pós-festa):** "COBRAR NO PIX" por linha (vira "COBRADO ✓") e "LEMBRAR TODO MUNDO 📲" geral.
**Aceite:** linhas pagas nunca são cobradas.

## UC-24 · Salvar/consultar festas passadas
**Ator:** anfitrião. **Pré:** festa concluída/salva.
1. "ROLÊ SALVO ✊" ao salvar; Home lista o arquivo ("Churras da laje · 14 pessoas · R$ 612").
**Aceite:** histórico mostra nome, nº de pessoas e total.

---

## Matriz de rastreabilidade

| Tela (arq. 04) | Casos de uso |
|---|---|
| T-01 Entrar | UC-01 |
| T-02 Home | UC-02, UC-24 |
| T-03 Montar | UC-03, UC-04 |
| T-04 Sua lista | UC-04, UC-05, UC-06, UC-14, UC-15, UC-16 |
| T-05 A galera | UC-11, UC-12, UC-13 |
| T-06 Convite | UC-07 |
| T-07 WhatsApp | UC-17, UC-18 |
| T-08 Convidado | UC-08, UC-09, UC-10 |
| T-09 Custos & acerto | UC-19, UC-20, UC-21, UC-22, UC-23 |
