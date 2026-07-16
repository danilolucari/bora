# 01 — Produto e fluxos

## 1. Conceito

**BORA.** — "A conta do rolê, resolvida". App social de organização de festas (v1: churrasco) que:

1. **Calcula** quantidades e custo em tempo real a partir de quem vai, do que vai ter e da duração;
2. **Chama a galera** por link/WhatsApp — o convidado confirma e escolhe o que levar **sem baixar nada**;
3. **Racha a conta** de forma justa: quem levou coisa paga menos; o app diz quem paga quem.

Tagline de valor: *"Monta o churras, chama a galera e racha a conta. Sem planilha, sem treta."*

## 2. Princípios de produto

- **Custo sempre à vista** — a barra "SAI POR" (total + por cabeça) acompanha toda edição, ao vivo.
- **Baixo atrito** — montar uma festa leva < 1 minuto; convidado responde direto do link.
- **Festa é gente, não números** — pessoas nomeadas com preferências alimentam a conta (steppers anônimos só para "extras sem app").
- **O dinheiro reage ao social** — "quem leva" e "quem pagou" mudam o racha; é isso que evita a treta.
- **WhatsApp é a saída natural** — grupo, flyer, lista, link e enquetes nascem prontos para o zap.
- **Confiança nos números** — preços são médias reais de mercados próximos, com faixa mín/máx visível e tudo editável.

## 3. Plataformas

Um codebase (alvo: Flutter) para **mobile** (frame de referência 390×820) e **web** (janela 1180×800). Mesmo estado nas duas plataformas; no web, Montar + Lista viram uma tela só com rail lateral direito fixo (lista viva + CTA).

## 4. Mapa de telas (produto final)

| # | Tela | Papel de quem usa |
|---|---|---|
| 01 | **Entrar** (login) | todos |
| 02 | **Seus rolês** (home) | anfitrião |
| 03 | **Montar** (a conta do rolê) | anfitrião / co-anfitrião |
| 04 | **Sua lista** (lista turbinada: planejar ⇄ comprar + pedido) | anfitrião / co-anfitrião / convidado (conforme link) |
| 05 | **A galera** (pessoas, preferências, acesso, link) | anfitrião / co-anfitrião |
| 06 | **Convite / WhatsApp** (mensagem por blocos, grupo, enquetes) | anfitrião / co-anfitrião |
| 07 | **Lado do convidado** (link → flyer → RSVP → "eu levo") | convidado, sem conta |
| 08 | **Custos & acerto** (despesas, split, quem paga quem, Pix) | todos os confirmados |

## 5. Grafo de navegação

```
Entrar ──► Seus rolês ──► Montar ──► Sua lista ──► Convite ──► (link) Convidado
              │                                        │              │ confirma
              │◄───────────────────────────────────────┘              ▼
              └────────────► Custos & acerto ◄── Home ganha "VER O ACERTO" quando há confirmação
Abas permanentes da festa: Lista · Galera · WhatsApp · Custos
```

- Voltar (`←`) sempre no canto superior esquerdo, exceto Login e telas do convidado.
- Quando um convidado confirma, a Home do anfitrião atualiza (ex.: 4→5 confirmados, 2→1 pendentes) e libera o atalho amarelo "💸 VER O ACERTO DA FESTA →".

## 6. Modelo de dados conceitual

- **Festa**: nome ("CHURRAS DO RAFA 🔥"), data ("SÁB · 18 JUL"), hora ("14H"), local ("Laje do Rafa — Vila Madalena"), duração (2h/4h/6h/dia), status (chegando/passada), link (`bora.app/c/rafa18`), nível do link (RN-22).
- **Pessoa**: nome, inicial, cor de avatar, papel (`host` | `cohost` | `guest` | `viewer`), dieta (`tudo` | `veggie` | `semporco`), bebe álcool (bool), status (confirmado/pendente/recusou), flag `você`.
- **Extras sem app**: contadores anônimos Homens/Mulheres/Crianças que somam ao cálculo (RN-01).
- **Item de lista**: chave, categoria/corredor, emoji, nome, unidade, quantidade (auto + override), preço (média + override), flag essencial-automático, atribuição "quem leva", flag "no carrinho".
- **Preço de mercado**: por item — média, mínimo, máximo, nº de mercados fonte.
- **Despesa**: quem pagou, descrição, valor, regra de split (igualitário entre adultos).
- **Linha de acerto**: de → para, valor, meio (pix/cartão/dinheiro), status (pendente/pago).
- **Enquete**: tipo (horário/data/o que levar), pergunta, opções com votos, voto do usuário (1 por enquete, trocável).
- **Pedido**: parceiro (iFood/Rappi/Zé), frete, ETA, subtotal, total, status.

## 7. Personas de referência (dados do protótipo)

- **Rafa** — anfitrião, avatar `#FF4D2E`, come de tudo, bebe. É o "VOCÊ" padrão.
- **Ana** — co-anfitriã, avatar `#FFD23F`, come de tudo, bebe. É a convidada exemplo do fluxo de link.
- **Léo** — convidado, avatar `#6C4BF5`, veggie, bebe.
- **Bia** — convidada, avatar `#0B6B3A`, não come porco, não bebe.
- **Duda** — só-vê (viewer), avatar `#141414`.
