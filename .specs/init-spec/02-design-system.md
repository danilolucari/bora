# 02 — Design system "Convite" (neo-brutalista)

Para o resultado ficar **exatamente igual** ao protótipo: nada de gradientes, nada de cantos arredondados em containers, sombras sempre duras (sem blur), tipografia sempre Archivo.

## 1. Cores (tokens)

| Token | Hex | Uso |
|---|---|---|
| `paper` | `#F4EFE3` | Fundo de todas as telas e barras fixas |
| `paper-2` | `#EFECE5` | Preenchimentos neutros (trilho de barra, chips de fundo) |
| `ink` | `#141414` | Texto principal, bordas, botões primários, cards escuros |
| `cream` | `#F4EFE3` | Texto sobre `ink` (mesmo valor de `paper`) |
| `primary` | `#FF4D2E` | Ação/acento principal: sombras de CTA, tags de data, valores "por cabeça", marcador de média |
| `yellow` | `#FFD23F` | Destaques: labels em card escuro, tag AUTO, papel ANFITRIÃO, atalho do acerto |
| `purple` | `#6C4BF5` | Contexto convidado/link/galera: sombra do card de link, banner "você é a Ana", papel CO-ANFITRIÃO |
| `green` | `#0B6B3A` | Sucesso financeiro: checkbox comprado, botão PAGO ✓ |
| `wa-green` | `#25D366` | Tudo WhatsApp: sombras, botão criar grupo, barra de progresso de quitação, voto |
| `wa-bubble` | `#E7DFCB` | Fundo de conversa WhatsApp (preview) |
| `wa-confirm` | `#DCF8C6` | Chip "grupo criado" |
| `white` | `#FFFFFF` | Cards e listas |
| `text-2` | `#6b6b6b` | Texto secundário, labels de seção |
| `text-3` | `#9b9b9b` | Texto terciário, mín/máx |
| `text-body` | `#3a3a3a` | Parágrafos |
| `divider` | `#141414` @ 9% (`#14141418`) | Separador de linhas em lista (2px) |
| `divider-2` | `#141414` @ 13% (`#14141422`) | Divisor interno de segmented (2px) |

Cores de avatar (fixas por pessoa): Rafa `#FF4D2E`/texto `#fff` · Ana `#FFD23F`/`#141414` · Léo `#6C4BF5`/`#fff` · Bia `#0B6B3A`/`#fff` · Duda `#141414`/`#F4EFE3` · slot "+N" branco com borda tracejada.

**Regra:** máx. 1 cor de acento por contexto de tela (vermelho = dinheiro/CTA geral, roxo = galera/link, verde-WA = WhatsApp, verde = pago/comprado).

## 2. Tipografia

Fontes Google: **Archivo Black** (display) e **Archivo** 400–800 (UI). Nenhuma outra.

| Papel | Especificação |
|---|---|
| Logo/hero login | Archivo Black 64px, line-height .92, letter-spacing −2px, ponto final em `primary` ("BORA<span vermelho>.</span>") |
| Título de tela | Archivo Black 22–24px, ls −0.5px, CAIXA ALTA |
| Título de card | Archivo Black 26–40px, ls −0.5 a −1.5px |
| Valor-herói (R$) | Archivo Black 40–42px, ls −1.5px |
| Valor de rodapé (SAI POR) | Archivo Black 24–26px, ls −1px |
| Label de seção | Archivo 800 11.5px, ls 1.2px, `text-2`, CAIXA ALTA (ex.: "PESSOAS", "QUEM PAGA QUEM") |
| Botão | Archivo 800 12–16px, ls 0.5–1px, CAIXA ALTA |
| Nome/linha de lista | Archivo 800 14px `ink`; sublinha 600 11.5–12px `text-2` |
| Corpo/dica | Archivo 500–600 12–15px, line-height 1.4–1.5 |
| Micro-tag | Archivo 800 8.5–10.5px, ls 0.5–1px |

## 3. Formas e bordas

- `border-radius: 0` em **tudo** (botões, cards, inputs, chips).
  Exceções: avatares e dots (círculo, 50%) e o frame do celular (38px).
- Borda padrão: `2px solid #141414` em cards, botões, inputs, chips, checkboxes.
- Dica/nota: `2px dashed #141414`, fundo branco, texto 600 12px `text-2`, sempre com emoji-âncora (💡 📊 ✅).
- Slot vazio/desabilitado: borda `2px dashed #9b9b9b`, opacity .7.
- Tags rotacionadas: `transform: rotate(-2deg)` (esq.) ou `rotate(3deg)` (dir.), fundo `primary` ou `yellow`, posicionadas vazando o card (`top:-13px`).

## 4. Sombras (sempre duras, sem blur)

| Uso | Sombra |
|---|---|
| Botão CTA | `4px 4px 0 <acento>` |
| CTA grande login | `5px 5px 0 #FF4D2E` |
| Card branco destacado | `6px 6px 0 #141414` ou `8px 8px 0 #141414` |
| Card-herói escuro | `6px 6px 0 #FF4D2E` |
| Flyer do convite | `8px 8px 0 #FF4D2E` |
| Card do link (galera) | `5px 5px 0 #6C4BF5` |
| Card criar grupo | `5px 5px 0 #25D366` |
| Bolha WhatsApp | `4px 4px 0 #141414` |
| Frame do celular | `0 20px 50px -20px rgba(20,10,50,.35)` (única sombra suave permitida — é o "palco", não a UI) |

**Hover/press de CTA (obrigatório):** `transform: translate(2px,2px)` + sombra encolhe de `4px 4px` para `2px 2px` (efeito "afundar"). Secundários: hover ganha `box-shadow 3–4px 4px 0 #141414` ou fundo `paper`.

## 5. Componentes

### Botão primário
Fundo `ink`, texto `cream`, borda 2px `ink`, padding 15–16px, sombra `4px 4px 0` no acento do contexto. Largura total quando é o CTA do rodapé.

### Botão secundário
Fundo transparente ou branco, borda 2px `ink`, texto `ink`. Hover: fundo `paper` ou sombra dura.

### Chip de seleção (itens da festa)
Padding 10px 14px, 800 13px CAIXA ALTA, emoji à esquerda, borda 2px `ink`.
Não selecionado: fundo branco, texto `ink`. Selecionado: fundo `ink`, texto `cream`. Transição `.15s`.

### Segmented control
Container com borda 2px `ink` sobre branco; botões `flex:1` separados por divisor 2px `divider-2`; ativo = fundo `ink` + texto `cream`, inativo = transparente + `text-2`. Variante sobre card escuro: borda e divisores em `cream`/25%; ativo só muda o texto para `cream`.

### Stepper (− n +)
Botões 34×34: "−" branco borda `ink`; "+" fundo `ink` texto `cream` (hover `#FF4D2E`). Valor central 800 17px. *(Implementação real: garantir alvo de toque ≥44px via padding.)*

### Card de lista
Fundo branco, borda 2px `ink`; linhas com padding 12–13px 14–16px separadas por `2px solid divider`; emoji 19–20px à esquerda; valor 800 14px à direita.

### Linha expansível (accordion)
Caret `▾` fechado / `▴` aberto; painel aberto com fundo `paper` e `border-top 2px`. Só 1 aberta por vez (abrir fecha a anterior).

### Avatares empilhados
34–40px, borda 2px `ink`, iniciais 800; sobreposição `margin-left: -8 a -10px`; último slot "+N" branco com borda tracejada.

### Tag de status (pill quadrada)
Borda 2px `ink`, padding 4–6px 7–9px, 800 9–10.5px ls .5px. Cores por significado: RECEBE=fundo `ink`, PAGA=fundo `primary`, NO ZERO=branco, ANFITRIÃO=`yellow`, CO-ANFITRIÃO=`purple`/texto branco, CONVIDADO=branco, SÓ VÊ=`wa-bubble`/texto `text-2`.

### Toast
Fundo `ink`, texto `cream` 800 13px ls .5px, padding 12px 20px, sombra `4px 4px 0` no acento do contexto; posição central, `bottom: 112px`; entrada `toastIn .3s ease` (fade + sobe 14px); **some sozinho após 2200ms**. Texto em CAIXA ALTA com emoji final (ex.: "LINK COPIADO 🔗").

### Rodapé fixo (CTA bar)
Fundo `paper`, `border-top 2px ink`, padding 14–16px 24px 30px. Padrão: bloco "SAI POR"/label à esquerda (label 800 11px ls 1px `text-2` + valor Archivo Black + sublinha vermelha 700 12.5px) e CTA à direita.

### Card-herói escuro (dinheiro)
Fundo `ink`, padding 20–22px, sombra `6px 6px 0 #FF4D2E`. Label `yellow` 800 12px ls 1px; valor `cream` Archivo Black 40–42px; sublinha `primary` 700 13px.

### Bottom sheet
Overlay `rgba(20,10,50,.45)`; painel ancorado embaixo, fundo `paper`, `border-top 2px ink`, padding 22px 24px 30px; título Archivo Black 22px + botão ✕ 32×32 borda 2px.

### Barra de faixa de preço (mín/máx)
Trilho 8px, fundo `paper-2`, borda 2px `ink`; marcador 8×12px fundo `primary` borda 2px `ink`, posicionado em `(média−mín)/(máx−mín)` da largura; extremos rotulados abaixo em 700 10px `text-3`.

### Opção de enquete (estilo WhatsApp)
Borda 2px (`ink`; `#25D366` quando é seu voto); barra de % preenchendo o fundo com `rgba(37,211,102,.18)`; radio circular 15px (verde quando votado); % à direita; contagem "n votos" abaixo.

### Barra de progresso (quitação)
Altura 12px, borda 2px `cream` (sobre card escuro), preenchimento `#25D366`, `transition: width .3s`.

### Inputs
Fundo branco, borda 2px `ink`, radius 0, padding 15px 16px, texto 600 15px; focus: `border-color: #FF4D2E`. Placeholder em minúsculas ("seu e-mail", "senha").

### Frame do celular (apresentação)
390×820, radius 38px, `border 1px rgba(0,0,0,.25)`, overflow hidden, coluna flex; conteúdo rola na área central (`flex:1; overflow-y:auto`), header e rodapé fixos.

## 6. Motion

- `transition: all .15s` em chips, segmented, botões de estado.
- `toastIn`: `from {opacity:0; translateY(14px)} to {opacity:1; translateY(0)}`, .3s ease.
- Progresso: `width .3s`.
- Sem parallax, sem spring, sem skeleton animado — o estilo é seco e imediato.

## 7. Voz e copy

- Português BR informal: "rolê", "galera", "treta", "bora", "zap".
- Títulos, labels, botões e toasts em **CAIXA ALTA**; corpo em sentence case.
- Emojis fazem parte da marca (🔥 ✊ 📲 💸 🍺) — 1 por elemento, geralmente no fim.
- Dinheiro sempre `R$ N` inteiro; aproximações com "≈" ou "~".

## 8. Não fazer

- Cantos arredondados em botões/cards; sombras com blur na UI; gradientes.
- Mais de 2 cores de acento na mesma tela.
- Fontes fora de Archivo/Archivo Black; texto de UI abaixo de 9px.
- Toast persistente ou empilhado (1 por vez, substitui o anterior).
