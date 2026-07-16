# 06 — Especificação das telas web

Complementa o arquivo 04 (mobile). Mesmo estado, mesmo design system (arquivo 02) — **um codebase, dois quadros**: mexer no web reflete no mobile e vice-versa. Referência de janela: 1180×800 (conteúdo ~716px de altura útil sob o chrome do navegador).

## Princípios de adaptação web

- **Mobile empilha, web justapõe.** O que no mobile são telas em sequência (Montar → Lista), no web vira uma tela só com rail lateral.
- **Custo sempre visível** vira um rail direito **sticky** — o card-herói escuro nunca sai do viewport.
- Larguras de conteúdo: container central `max-width: 1040–1060px`, padding lateral 36px.
- Tipografia sobe um degrau: títulos de página Archivo Black 34–40px (vs. 22–30px mobile); logo do header 20px.
- Hover states são obrigatórios em tudo que é clicável (o mobile depende só de press).
- Nenhum componente novo: os mesmos tokens, bordas 2px, sombras duras e chips do arquivo 02.

## W-01 · Entrar (web)

Layout: duas colunas centralizadas vertical e horizontalmente, `gap: 74px`, padding 50px 40px.

- **Coluna esquerda (marca, máx 410px):** logo "BORA." Archivo Black 92px (ls −3px, ponto vermelho); tag rotacionada −2° "A CONTA DO ROLÊ, RESOLVIDA"; parágrafo 500 16px/1.55 (máx 300px).
- **Coluna direita (form, 340px):** card branco, borda 2px `ink`, **sombra 10px 10px 0 `ink`**, padding 30px. Label "ENTRAR" 800 13px ls 1.2px; inputs e-mail/senha (focus vermelho); CTA "COMEÇAR →" (sombra 5px vermelha, hover afunda); secundário "🌐 ENTRAR COM GOOGLE" (hover fundo `paper`); rodapé "Novo por aqui? CRIAR CONTA".

## Header de app (todas as telas logadas)

Barra sticky (`top:0, z-index:5`): fundo `paper`, `border-bottom 2px ink`, padding 13px 36px.
Conteúdo: [← voltar 36×36 quando aplicável] · logo "BORA." 20px · spacer · [ações contextuais] · avatar do usuário 36px (`#FFD23F`, borda 2px, inicial).
Na Home a ação é o botão "+ NOVO ROLÊ" (primário compacto: padding 9px 14px, 800 12px, sombra 3px vermelha, hover afunda 1px).

## W-02 · Seus rolês (home web)

Container 1040px, padding 34px 36px 48px.

- Linha de título: "SEUS ROLÊS" 40px à esquerda; "1 festa chegando · 2 passadas" 500 14px `text-2` à direita (baseline).
- Grid `1.15fr / 0.85fr`, gap 28px:
  - **Coluna esquerda — card da festa** (branco, sombra 8px preta, padding 28px): tag de data rotacionada +3°; título 38px; avatares 40px empilhados + "+2"; "4 confirmados · 2 pendentes"; botões "+ CONVIDAR" / "MONTAR LISTA →" lado a lado.
  - **Coluna direita:** seção "COMEÇAR OUTRA" (grid 2 col: 🔥 CHURRASCO clicável, 🎈 NIVER tracejado) e seção "ARQUIVO" (card branco com linhas: emoji · nome + "· N pessoas" · valor vermelho à direita).
- Regra RN-28 vale igual: confirmação nova atualiza contadores e expõe o atalho do acerto.

## W-03 · Montar + Lista (tela única com rail)

A fusão é a diferença estrutural do web: **não existe passo "Fechar lista"** — o formulário e a lista viva coexistem.

Container 1060px, padding 30px 36px 48px. Linha de título: "A CONTA DO ROLÊ" 34px + "CHURRAS DO RAFA · SÁB 18 JUL" 800 12px ls 1px `text-2` à direita.

Grid `1fr / 370px`, gap 30px:

### Coluna esquerda — formulário
Mesmas seções do mobile (T-03), com "PROS FORTES" incluída:
1. "QUEM CONFIRMOU" — card de steppers H/M/C;
2. "NA GRELHA" / "NA GELADEIRA" / "PROS FORTES" — chips;
3. "ATÉ QUE HORAS?" — segmented 2h/4h/6h/Dia (máx 360px).

### Coluna direita — rail sticky (`top: 80px`)
1. **Card-herói escuro** (sombra 6px vermelha): label amarela "SAI POR · {N} PESSOAS · {duração}"; valor 38px; "dividido dá R$ X por cabeça".
2. Dica tracejada "💡 Toque em **QUEM LEVA?** para passar o item pra alguém."
3. **Lista viva** (card branco, `max-height: 330px, overflow-y: auto`): categorias com subtotal; linha compacta = emoji 17px · nome 800 12.5px + qtd · valor · botão "QUEM LEVA?" ⇄ "{NOME} LEVA" (ativo vermelho).
4. CTA full-width "MANDAR NO GRUPO 📲".

Comportamento: qualquer toque no formulário recalcula o rail ao vivo (RN-01..10); a lista viva usa as mesmas atribuições "quem leva" do mobile (estado único).

**Evolução pendente do protótipo (P2/lacuna 2):** o botão que cicla VOCÊ→ANA→LÉO→BIA não escala além de 4 pessoas — na implementação, trocar por seletor em popover/bottom sheet com a lista de confirmados + quanto cada um já leva; a dica 💡 deixa de ser necessária. Saída "salvar sem mandar no grupo" também deve existir no web.

## W-04 · Demais telas (adaptação padrão)

Lista turbinada, Galera, WhatsApp, Convidado e Custos ainda não têm quadro web no protótipo; adaptar com estas regras:

| Tela | Adaptação web |
|---|---|
| **Sua lista (turbinada)** | Dentro do rail de W-03 nos modos PLANEJAR/COMPRAR (segmented no topo do rail); sheet de pedido vira **modal central** (mesmo conteúdo, overlay `rgba(20,10,50,.45)`, card `paper` borda 2px, máx 420px) |
| **A galera** | Duas colunas: card do link (escuro, sombra roxa) fixo à esquerda (370px); lista de pessoas com accordions à direita |
| **WhatsApp** | Coluna única centralizada (máx 560px) — o preview de bolha não deve esticar além de 300px |
| **Convidado (link)** | Página standalone sem header de app (convidado não tem conta): flyer centralizado (máx 480px), CTAs abaixo; RN-24 vale igual |
| **Custos & acerto** | Grid `1fr / 370px`: despesas + quem-paga-quem à esquerda; rail sticky com card-herói do total + barra de quitação + CTA de cobrança |

## Regras transversais web

- **W-R1 · Estado único:** toda mutação (steppers, chips, atribuições, checks, pagamentos) sincroniza entre web e mobile em tempo real.
- **W-R2 · Sticky:** header de app e rail direito sempre sticky; rodapé-CTA mobile não existe no web — o CTA mora no rail.
- **W-R3 · Larguras mínimas:** abaixo de ~900px o web colapsa para o layout mobile (rail vira etapa própria, volta o rodapé fixo).
- **W-R4 · Scroll:** rolagem só no documento e na lista viva do rail (330px); nunca scroll horizontal.
- **W-R5 · Título da aba:** "bora — a conta do rolê"; URL base `bora.app/roles`.
