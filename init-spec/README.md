# BORA. — Especificação do produto

> **Fonte da verdade visual:** protótipo `Bora - Revisão e Novas Direções.dc.html`.
> **Escopo desta spec:** a direção vencedora **1b "Convite"** (neo-brutalista), o fluxo integrado ponta-a-ponta (turno 5) e as 4 features novas (turno 6: Galera, Lista turbinada, WhatsApp, Custos). As explorações 1a "Afterdark" e 1c "Cupom" foram descartadas e **não** fazem parte do produto.

## Arquivos

| # | Arquivo | Conteúdo |
|---|---|---|
| 01 | `01-produto-e-fluxos.md` | Conceito, princípios, mapa de telas, navegação e modelo de dados |
| 02 | `02-design-system.md` | Tokens (cores, tipo, formas, sombras), componentes e motion — para reproduzir o visual **exatamente** |
| 03 | `03-regras-de-negocio.md` | Todas as fórmulas e regras (RN-xx): quantidades, preços, essenciais, preço médio, acerto/split, permissões, enquetes |
| 04 | `04-telas-ux.md` | Especificação tela a tela: layout, elementos, estados, interações e copy literal |
| 05 | `05-casos-de-uso.md` | Casos de uso UC-01 a UC-24 com fluxos, exceções e critérios de aceite |
| 06 | `06-telas-web.md` | Especificação das telas web (layout 1180×800, header, rail sticky, adaptações) |

## Como usar

1. Comece por `01` para entender o produto e o fluxo.
2. Implemente o tema a partir de `02` (nenhuma cor/fonte/sombra fora dos tokens).
3. Toda lógica de cálculo vem de `03` — os exemplos numéricos são casos de teste.
4. Monte cada tela seguindo `04` (mobile) e `06` (web) — copy é literal, em CAIXA ALTA onde indicado.
5. Valide o comportamento com os critérios de aceite de `05`.

## Convenções

- Moeda: Real (BRL), formato `R$ 1.234` — **arredondado para inteiro**, locale `pt-BR`.
- Toda referência de regra usa `RN-xx` (arquivo 03) e de caso de uso `UC-xx` (arquivo 05).
- "Adulto" = homem ou mulher; criança nunca entra no racha (RN-14).
