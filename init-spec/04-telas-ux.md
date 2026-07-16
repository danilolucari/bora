# 04 — Especificação de telas (UX)

Estrutura comum a toda tela mobile: **header** (padding 28px 24px 10px; botão voltar 40×40 quando aplicável + título Archivo Black 22–24px CAIXA ALTA), **conteúdo rolável** (`flex:1`, padding lateral 24px) e **rodapé fixo** (fundo `paper`, border-top 2px, CTA). Toasts sobem a 112px do fundo (RN-29).

## T-01 · Entrar (login)

- Coluna centralizada vertical, padding lateral 30px.
- Logo "BORA." 64px com ponto vermelho; tag rotacionada −2° vermelha "A CONTA DO ROLÊ, RESOLVIDA"; parágrafo "Monta o churras, chama a galera e racha a conta. Sem planilha, sem treta." (máx 260px).
- Inputs "seu e-mail" e "senha" (focus vermelho).
- CTA "COMEÇAR →" (sombra 5px vermelha) → Home.
- Divisor "OU" (linhas 2px 13%) + botão secundário "CONTINUAR COM GOOGLE" → Home.
- Rodapé de texto: "Novo por aqui? CRIAR CONTA" (link vermelho 800).

## T-02 · Seus rolês (home)

- Título "SEUS ROLÊS" 30px + sub "1 festa chegando · 2 passadas".
- **Card da festa** (branco, sombra 6px preta): tag de data rotacionada +3° "SÁB · 18 JUL" vazando o topo; título "CHURRAS\nDO RAFA 🔥" 26px; avatares R/A/L + "+N" tracejado; linha "4 confirmados · <vermelho>2 pendentes</vermelho>"; botões "+ CONVIDAR" (secundário) e "MONTAR LISTA →" (primário, flex 1.4).
- Quando existe confirmação nova (RN-28): contadores viram "5 confirmados · 1 pendente" e entra botão amarelo full-width "💸 VER O ACERTO DA FESTA →".
- Seção "COMEÇAR OUTRA": grid 2 col — card "🔥 CHURRASCO" (clicável → Montar) e slot "🎈 NIVER · EM BREVE" (tracejado, opacity .7, não clicável).

## T-03 · Montar (a conta do rolê)

- Header com voltar + "A CONTA DO ROLÊ".
- Seção "CONFIRMADOS + EXTRAS SEM APP": card com 3 linhas de stepper (👨 Homens · 👩 Mulheres · 🧒 Crianças).
- "NA GRELHA": chips 🥩 BOVINA · 🐷 SUÍNA · 🍗 FRANGO.
- "NA GELADEIRA": chips 🧄 PÃO DE ALHO · 🥤 REFRIGERANTE · 🧃 SUCO · 💧 ÁGUA · 🍺 CERVEJA.
- (Web também tem "PROS FORTES": 🍸 VODKA · 🍹 CACHAÇA · 🥃 WHISKY.)
- "QUANTO TEMPO DE FESTA?": segmented 2h / 4h / 6h / Dia (ativo vermelho).
- **Tudo recalcula ao vivo** (RN-01..10) no rodapé: "SAI POR" + total + "≈ R$ X / cabeça" · CTA "FECHAR LISTA →".
- Web (1180×800): coluna esquerda = formulário; rail direito sticky = card-herói escuro + dica 💡 + lista viva com "QUEM LEVA?" + CTA "MANDAR NO GRUPO 📲".

## T-04 · Sua lista (lista turbinada)

- Header "SUA LISTA"; abaixo, segmented 🧮 PLANEJAR / 🛒 COMPRAR.

**Modo PLANEJAR** (default):
- Dica tracejada: "📊 Cada preço é a **média real** de mercados perto de você — a barra mostra o mín/máx que a galera achou."
- Card único com itens (RN-11): emoji + nome 800 14px + sub "qtd · média de N mercados"; à direita valor + micro-label vermelha "MÉDIA"; abaixo, barra de faixa com marcador e extremos R$ mín/máx.
- Itens expandem para editar qtd/preço com steppers duplos (RN-12); badge amarela "AUTO ∝ …" nos essenciais; ponto vermelho se editado; botão "RESTAURAR" no rodapé quando houver override.
- Rodapé: "MÉDIA TOTAL" + valor + "faixa real: de R$ X a R$ Y" · CTA "FAZER PEDIDO 🛒".

**Modo COMPRAR**:
- Dica: "✅ Organizado por corredor do mercado — marque o que já tá no carrinho."
- Grupos por corredor (ordem RN-27) com contagem "N itens"; linha = checkbox 26×26 (✓ branco sobre verde `#0B6B3A`) + emoji + nome/qtd + preço; marcada fica a 45% opacidade.
- Rodapé: "N de M no carrinho" + total · CTA "PEDIR O QUE FALTA 🛵".

**Sheet FAZER PEDIDO**: título + ✕; linha 📍 "Laje do Rafa — Vila Madalena" com "TROCAR" vermelho sublinhado; "ENTREGA POR" com 3 cartões-radio (parceiro, "chega em ETA", frete à direita; selecionado = fundo `paper`, borda vermelha, dot vermelho); resumo Subtotal/Frete/Total; CTA "CONFIRMAR PEDIDO →".

**Overlay PEDIDO A CAMINHO**: tela cheia `paper`, 🛵 56px, "PEDIDO A CAMINHO!" 30px, "Chega em **ETA** na Laje do Rafa.", linha vermelha "R$ total · rachado no acerto da festa", CTA "VOLTAR À LISTA".

## T-05 · A galera

- Header "A GALERA" + sub "5 pessoas · 4 confirmadas".
- **Card do link** (escuro, sombra roxa): label amarela "LINK PRA CONVIDAR"; `bora.app/c/rafa18` sublinhado + botão claro "COPIAR 🔗" (hover amarelo); label "QUEM ABRIR O LINK PODE…"; segmented creme SÓ VER / EDITAR LISTA / CO-ANFITRIÃO; nota dinâmica do nível (RN-23).
- Faixa amarela borda 2px: "💡 A lista já se ajusta às preferências: {resumo RN-21}".
- Seção "PESSOAS": cards-linha por pessoa — avatar colorido, nome + badge "VOCÊ" (quando for o usuário), sublinha "dieta · bebe 🍺/não bebe 🚫", tag de papel (cores RN-22/DS §5) e caret.
- Expandido: para o anfitrião, só a nota "👑 Anfitrião manda em tudo — acesso fixo."; para os demais, "NÍVEL DE ACESSO" (3 botões, ativo preto), "RESTRIÇÃO ALIMENTAR" (🍖/🥗/🚫, ativo vermelho) e "BEBIDA" (toggle BEBE 🍺 ✓ / NÃO BEBE 🚫, ativo preto).
- Rodapé: CTA "+ CONVIDAR MAIS GENTE 🔗" (sombra roxa) → copia o link (toast).

## T-06 · Convite / mensagem no grupo

- Header com voltar + "MANDAR NO GRUPO" (+ sub "GRUPO: CHURRAS DO RAFA 🔥" quando já existe grupo).
- "NO PACOTE": 3 toggles FLYER / LISTA / LINK DO CONVITE (ativo preto).
- Área de preview com fundo de conversa `#E7DFCB`: bolha branca (borda 2px, sombra 4px preta, máx 300px, alinhada à direita) montada pelos blocos ativos (RN-26b):
  - FLYER: mini-arte escura "CHURRAS\nDO RAFA 🔥" + linha amarela "SÁB · 18 JUL · 14H · LAJE DO RAFA";
  - LISTA: "🥩 Carnes + pão de alho — **Rafa leva**" / "🍺 Cerveja + 🧊 gelo — **Ana leva**" / vermelho "🥤 Refri · 💧 água — quem leva?" / "💸 sai ~R$ X por cabeça";
  - LINK: "bora.app/c/rafa18" vermelho sublinhado + "confirma e escolhe o que levar 👆";
  - hora "14:02 ✓✓" no rodapé da bolha; legenda central "é assim que chega no grupo — mexa nos blocos acima".
- CTA: "ENVIAR NO WHATSAPP →" (ou, no fluxo integrado, "ENVIAR E VER O LADO DO CONVIDADO →").

## T-07 · WhatsApp (grupo + enquetes)

- Header "WHATSAPP" + sub "grupo do rolê + enquetes num toque".
- **Card criar grupo** (branco, sombra verde-WA): "💬 CRIAR GRUPO DO ROLÊ"; avatares dos 4 confirmados + "4 confirmados entram no grupo"; botão verde "CRIAR GRUPO “CHURRAS DO RAFA 🔥”" → vira chip `#DCF8C6` "✅ “Churras do Rafa 🔥” · 4 membros" (RN-25).
- "ENQUETES PRO GRUPO": 3 toggles HORÁRIO / DATA / O QUE LEVAR.
- Preview em fundo de conversa: bolha com "📊 ENQUETE · você", pergunta, opções votáveis (componente DS §5, RN-26), "14:05 ✓✓"; legenda "toque numa opção pra votar 👆".
- CTA "POSTAR ENQUETE NO GRUPO 📲" (sombra verde-WA) — bloqueado sem grupo (toast RN-26).

## T-08 · Lado do convidado (via link)

No fluxo integrado, banner roxo topo: "← AGORA VOCÊ É A ANA — abriu o link no zap 📲".

**Convite:** linha "🔗 bora.app/c/rafa18 · abre sem conta"; **flyer** escuro (sombra 8px vermelha) com tag amarela rotacionada "ANA, VOCÊ FOI CHAMADA", título 36–40px, linhas 📅 SÁB · 18 JUL · A PARTIR DAS 14H / 📍 LAJE DO RAFA — VILA MADALENA / amarela 💸 "CADA UM LEVA UMA PARTE — SAI ~R$ X"; avatares "4 já confirmaram". CTAs: "BORA! ✊" (primário) e "NÃO VOU 😔" (secundário); nota "responde direto daqui — sem baixar nada".

**Escolher o que leva:** "BOA, ANA! ✊" + "O que você levar desconta da sua parte no racha."; dica "🥩 RAFA já leva as carnes e o pão de alho"; lista de itens disponíveis (🍺 Cerveja 18 latas R$ 72 · 🧊 Gelo R$ 30 · 🥤 Refri R$ 18 · 🧄 Pão de alho R$ 24 · 💧 Água R$ 6 · 🍹 Cachaça R$ 15) com botão "EU LEVO" ⇄ "VOCÊ LEVA ✓" (ativo vermelho); rodapé "VOCÊ LEVA R$ soma" + "CONFIRMAR →".

**Confirmado:** card escuro "TÁ MARCADO! ✊" + data/local amarelo + bloco "VOCÊ LEVA: {itens}" (+ vermelho "R$ X — desconta da sua cota" se levou algo; senão "nada — só a presença ✊"); "📅 SALVAR NA AGENDA"; link vermelho "mudar o que eu levo"; no fluxo, nota "✅ O Rafa já vê você como confirmada..." + botão amarelo "💸 VER O ACERTO DA FESTA →".

**Não vou:** 😔 "QUE PENA" + "Avisamos o Rafa que você não vai desta vez." + CTA "MUDEI DE IDEIA ✊".

## T-09 · Custos & acerto

**Acerto (pós-festa):** header "ACERTO DO ROLÊ"; card-herói escuro "TOTAL DA FESTA" + R$ 320 + "cota justa R$ 80 — entre 4 adultos, criança de fora"; dica "💡 Quem levou coisa paga menos — é isso que evita a treta."; seção "QUEM LEVOU O QUÊ" (avatar, nome, "levou R$ X · itens", tag RECEBE/PAGA/NO ZERO — RN-15); seção "QUEM PAGA QUEM" (linhas `A → B · R$ X` + botão "COBRAR NO PIX" ⇄ "COBRADO ✓"); CTA "LEMBRAR TODO MUNDO 📲".

**Custos da festa (feature 6d):** card-herói com "TOTAL DA FESTA" R$ 380, "cota justa R$ 95 / adulto", barra de progresso verde + "N de M quitados · R$ X de R$ Y" (RN-18); "DESPESAS · QUEM ADIANTOU" (emoji, descrição, "Fulano pagou · split R$ X × 4", valor); "MEIO DE PAGAMENTO" segmented PIX/CARTÃO/DINHEIRO (RN-19); "QUEM PAGA QUEM" com etiqueta do meio + botão "MARCAR PAGO" ⇄ "PAGO ✓" (verde); CTA "COBRAR PENDENTES NO PIX 📲".

## Mapa de etapas (artefato de protótipo)

Barra de chips acima do telefone no fluxo integrado (01 ENTRAR … 07 ACERTO, ativo preto com dot vermelho) — ferramenta de navegação da demo, **não faz parte do produto final**.
