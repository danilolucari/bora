# 03 — Regras de negócio

Fórmulas exatas do protótipo. Os exemplos numéricos usam o estado padrão e servem de **casos de teste**.

## Pessoas e tempo

**RN-01 · Contagem de pessoas.** `adultos = homens + mulheres`; `pessoas = adultos + crianças`. As pessoas vêm de: confirmados nomeados (com preferências, RN-20) + steppers "extras sem app" (Homens/Mulheres/Crianças). Estado padrão: 3H + 3M + 1C → 6 adultos, 7 pessoas.

**RN-02 · Fator de duração.** Baseline 4h. `f = max(0.5, horas / 4)`. Opções: 2h→0.5 · 4h→1 · 6h→1.5 · Dia todo (10h)→2.5. Toda quantidade consumível multiplica por `f`.

## Quantidades automáticas (calculadora)

**RN-03 · Carnes.** Gramas totais `= (homens×400 + mulheres×300 + crianças×200) × f`, divididas igualmente entre as carnes selecionadas. Por carne: `kg = max(0,5; arredondar para 0,1 kg)`.
Preços base: Bovina R$ 45/kg · Suína R$ 28/kg · Frango R$ 18/kg.

**RN-04 · Pão de alho.** `un = max(1, ceil(pessoas × 0,5 × f))` · R$ 6/un.

**RN-05 · Cerveja.** Só adultos: `latas = max(1, ceil(adultos × 1000ml × f / 350))` · R$ 4/lata.

**RN-06 · Refrigerante.** `garrafas 2L = max(1, ceil((adultos×400 + crianças×500) × f / 2000))` · R$ 9/gf.

**RN-07 · Suco.** `litros = max(1, ceil((adultos×250 + crianças×400) × f / 1000))` · R$ 8/L.

**RN-08 · Água.** `garrafas 1,5L = max(1, ceil(pessoas × 400 × f / 1500))` · R$ 3/gf.

**RN-09 · Destilados.** Só adultos: `ml por destilado = adultos × 120 × f / nº selecionados`; `garrafas = max(1, ceil(ml/1000))`. Vodka R$ 40 · Cachaça R$ 15 · Whisky R$ 90 (garrafa 1L).

**RN-10 · Essenciais automáticos.** Entram sozinhos na lista, categoria "ESSENCIAIS · ENTRAM SOZINHOS", com badge `AUTO ∝ <fonte>`:

| Item | Default | Preço | Proporcional a |
|---|---|---|---|
| 🔥 Carvão | 1 saco 5 kg | R$ 22 | kg de carne |
| 🧊 Gelo | 3 sacos | R$ 10/saco | volume de bebida gelada |
| 🧂 Sal grosso | 1 kg | R$ 8 | kg de carne |
| 🍽️ Copos & pratos | 1 kit | R$ 15 | nº de pessoas |

**Exemplo de teste (estado padrão, f=1, bovina+frango, pão, refri, água, cerveja, cachaça):**
carne 2.300g ÷ 2 = 1,2 kg cada → Bovina R$ 54, Frango R$ 22 · Pão 4 un R$ 24 · Refri 2 gf R$ 18 · Água 2 gf R$ 6 · Cerveja 18 latas R$ 72 · Cachaça 1 gf R$ 15 → **Total R$ 211 · ≈ R$ 30/cabeça**. Com essenciais (22+30+8+15) → **R$ 271 · ≈ R$ 45/adulto**.

## Preços e edição

**RN-11 · Preço médio real.** Cada item exibe `média` calculada de N mercados próximos (rótulo "média de N mercados") + faixa `mín–máx` em barra com marcador na posição `(média−mín)/(máx−mín)`. Total da lista mostra a média e a faixa: "faixa real: de R$ mín a R$ máx". Dados de referência:

| Item | Corredor | Qtd | Média | Mín | Máx | Fontes |
|---|---|---|---|---|---|---|
| 🥩 Picanha bovina | AÇOUGUE | 1,2 kg | 65 | 54 | 83 | 4 |
| 🌭 Linguiça toscana | AÇOUGUE | 1 kg | 23 | 18 | 29 | 3 |
| 🥗 Legumes p/ grelha | HORTIFRÚTI | kit veggie | 28 | 22 | 35 | 2 |
| 🧄 Pão de alho | PADARIA | 4 un | 24 | 20 | 30 | 3 |
| 🍺 Cerveja | BEBIDAS | 18 latas | 76 | 64 | 92 | 4 |
| 🥤 Refrigerante | BEBIDAS | 2 gf 2 L | 18 | 14 | 23 | 3 |
| 🔥 Carvão 5 kg | MERCEARIA | 1 saco | 22 | 18 | 28 | 3 |
| 🧊 Gelo | MERCEARIA | 3 sacos | 30 | 24 | 36 | 2 |

(Total R$ 286 · faixa R$ 234–356.)

**RN-12 · Edição por item (overrides).** Todo item aceita ajuste de **quantidade** (passo próprio: carnes 0,5 kg; cerveja 2 latas; demais 1) e **preço** (passo R$ 1, mín R$ 1). Item editado ganha ponto vermelho 8px ao lado do nome; existe "RESTAURAR" que zera todos os overrides. Mínimo de quantidade = 1 passo.

**RN-13 · Formatação.** `R$ + Math.round(valor)` em `pt-BR`. Horas: "2/4/6 horas", 10 = "Dia todo".

## Racha e acerto

**RN-14 · Cota justa.** `cota = total da festa / nº de adultos participantes` — **criança fica de fora** (copy: "entre 4 adultos, criança de fora"). A estimativa rápida "≈ R$ X / cabeça" da montagem divide pelo total de pessoas; a divisão financeira real é sempre por adulto.

**RN-15 · Saldo por pessoa.** `saldo = contribuição (o que levou/pagou) − cota`. Tag: saldo > 0 → "RECEBE R$ X" · < 0 → "PAGA R$ X" · = 0 → "NO ZERO".

**RN-16 · Quem paga quem (algoritmo).** Separar credores (saldo>0) e devedores (saldo<0, em módulo). Percorrer devedores em ordem; cada um paga os credores em ordem: `parcela = min(dívida restante, crédito restante)`; gera linha `de → para · R$ parcela`; avança credor quando zera. Tolerância 1 centavo.

**Teste A (acerto "quem levou"):** VOCÊ 200 (carnes+carvão), ANA 120 (cerveja+gelo), LÉO 0, BIA 0 → total 320, cota 80 → linhas: LÉO→VOCÊ 80 · BIA→VOCÊ 40 · BIA→ANA 40.

**Teste B (custos/despesas):** Rafa 200, Ana 120, Léo 60 (pão+descartáveis), Bia 0 → total 380, cota 95 → linhas: LÉO→RAFA 35 · BIA→RAFA 70 · BIA→ANA 25.

**RN-17 · Split de despesa.** Cada despesa exibe "quem adiantou" e o split igualitário: `R$ valor/4 × 4`.

**RN-18 · Quitação.** Cada linha alterna PENDENTE ⇄ PAGO ✓ (ou COBRADO ✓ no acerto). Progresso: `% = pago / devido`; label "N de M quitados · R$ pago de R$ devido". Barra verde `#25D366`.

**RN-19 · Meio de pagamento.** Segmented PIX / CARTÃO / DINHEIRO; o selecionado vira a etiqueta das linhas de acerto. Ações de cobrança: "COBRAR PENDENTES NO PIX 📲" (toast "COBRANÇA ENVIADA NO PIX 📲") e "LEMBRAR TODO MUNDO 📲".

**RN-20 · "Eu levo" desconta.** O valor dos itens que o convidado assume entra como contribuição dele no acerto (copy: "O que você levar desconta da sua parte no racha"). Pedido por delivery (RN-27) entra como despesa de quem pediu: "rachado no acerto da festa".

## Pessoas, preferências e acesso

**RN-21 · Preferências.** Por pessoa: dieta (`🍖 Come de tudo` / `🥗 Veggie` / `🚫 Sem porco`) e bebida (`BEBE 🍺` / `NÃO BEBE 🚫`). Resumo agregado: "A lista já se ajusta às preferências: {n} veggie 🥗 · {n} sem porco 🚫 · {n} bebem 🍺" (omitir termos zerados). Efeitos na lista: veggie ≥1 → item "Legumes p/ grelha (kit veggie)"; sem porco → remove suína; cerveja dimensiona por quem bebe (substitui `adultos` em RN-05 por `nº que bebem`, quando houver pessoas nomeadas).

**RN-22 · Papéis e permissões.**

| Papel | Pode |
|---|---|
| ANFITRIÃO (fixo, 1) | tudo — "Anfitrião manda em tudo — acesso fixo" 👑 |
| CO-ANFITRIÃO | edita tudo e cobra a galera |
| CONVIDADO | marca o que leva e ajusta a lista |
| SÓ VÊ | vê a festa e confirma presença |

O papel do anfitrião não é editável; os demais alternam entre CONVIDADO / CO-ANFITRIÃO / SÓ VÊ.

**RN-23 · Nível do link de convite.** O link único (`bora.app/c/rafa18`) tem 3 níveis — quem abre entra com esse papel: SÓ VER → "convidados só veem a festa e confirmam presença" · EDITAR LISTA → "convidados marcam o que levam e ajustam a lista" · CO-ANFITRIÃO → "acesso total: editam tudo e cobram a galera". Copiar mostra toast "LINK COPIADO 🔗".

**RN-24 · RSVP sem conta.** O link abre direto no flyer (sem login): BORA! ✊ → escolher itens (opcional) → confirmado; NÃO VOU 😔 → avisa o anfitrião, com "MUDEI DE IDEIA ✊" para voltar. Confirmação atualiza contadores do anfitrião em tempo real (RN-28).

## WhatsApp

**RN-25 · Grupo.** "CRIAR GRUPO" gera o grupo com o nome da festa ("Churras do Rafa 🔥") contendo **apenas confirmados** (4). Depois de criado, o botão vira chip verde "✅ '<nome>' · N membros" (irreversível na UI). Toast: "GRUPO CRIADO NO WHATSAPP ✅".

**RN-26 · Enquetes.** 3 modelos: HORÁRIO ("QUE HORAS COMEÇA?" — 14h/15h/16h, votos-base 5/2/1), DATA ("MELHOR DATA?" — Sáb 18/Dom 19, 6/2), O QUE LEVAR ("QUEM LEVA A CAIXA DE SOM?" — "Eu levo 🔊"/"Não tenho 🙃", 3/1). 1 voto por enquete por pessoa, trocável; `% = round(votos/total×100)`. **Postar exige grupo criado** — senão toast "CRIE O GRUPO PRIMEIRO ☝️"; sucesso: "ENQUETE POSTADA NO GRUPO 📲".

**RN-26b · Mensagem de convite por blocos.** Composta por 3 blocos togglable: FLYER (arte da festa), LISTA (resumo "quem leva" + itens órfãos em vermelho "quem leva?" + "💸 sai ~R$ X por cabeça") e LINK DO CONVITE (`bora.app/c/rafa18` + "confirma e escolhe o que levar 👆"). Preview fiel de bolha WhatsApp (fundo `#E7DFCB`, hora + ✓✓).

## Compras e pedido

**RN-27 · Modos da lista.** PLANEJAR 🧮 (itens com média/faixa, RN-11) ⇄ COMPRAR 🛒 (checklist agrupado por corredor na ordem AÇOUGUE → HORTIFRÚTI → PADARIA → BEBIDAS → MERCEARIA; check verde risca a linha a 45% de opacidade; contador "N de M no carrinho"). Pedido em 1 toque via sheet: endereço da festa (trocável), parceiro — iFood Mercado (40–60 min, frete R$ 12) / Rappi Turbo (15–30 min, R$ 9) / Zé Delivery só-bebidas (30–45 min, grátis) — subtotal + frete = total → confirmação em tela cheia "PEDIDO A CAMINHO! 🛵" com ETA. No modo comprar, o CTA vira "PEDIR O QUE FALTA 🛵" (pede só os não-marcados).

**RN-28 · Sincronização de confirmação.** Convidado confirma → Home do anfitrião: confirmados +1, pendentes −1, e aparece o atalho "💸 VER O ACERTO DA FESTA →".

**RN-29 · Toasts.** Duração 2200 ms, 1 por vez. Textos canônicos: "LINK COPIADO 🔗", "ROLÊ SALVO ✊", "CONVITE COPIADO 📋", "LISTA NO GRUPO 📲", "ABRINDO O WHATSAPP… 📲", "SALVO NA AGENDA 📅", "LEMBRETE MANDADO NO GRUPO 📲", "COBRANÇA ENVIADA NO PIX 📲", "GRUPO CRIADO NO WHATSAPP ✅", "ENQUETE POSTADA NO GRUPO 📲", "CRIE O GRUPO PRIMEIRO ☝️".

**RN-30 · Estado inicial.** Festa exemplo: "CHURRAS DO RAFA 🔥", SÁB 18 JUL 14H, Laje do Rafa — Vila Madalena; 5 pessoas nomeadas (4 confirmadas + Duda), 4 confirmados/2 pendentes na Home; itens padrão: bovina+frango, pão de alho, refri, água, cerveja, cachaça; 4h.
