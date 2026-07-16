# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Estado do repositório

**Não há código ainda.** O repositório contém apenas a especificação do produto em `.specs/init-spec/` e a skill `tlc-spec-driven` em `.claude/skills/`. Não existem `pubspec.yaml`, package manager, build, lint ou suíte de testes — não invente comandos para eles. Quando o código nascer, o alvo declarado é **um único codebase Flutter** servindo mobile (frame 390×820) e web (janela 1180×800), com o mesmo estado nas duas plataformas.

Idioma: toda a spec e a copy do produto são em português BR. Escreva documentação e commits em português.

## O produto

**BORA.** — "A conta do rolê, resolvida". App de organização de churrasco que (1) calcula quantidades e custo ao vivo a partir de quem vai + o que vai ter + duração, (2) chama a galera por link/WhatsApp — o convidado responde sem baixar nada, e (3) racha a conta descontando o que cada um levou.

## A spec é a fonte da verdade

Leia `.specs/init-spec/README.md` primeiro. Os seis arquivos não são redundantes — cada um governa uma camada distinta, e o trabalho quase sempre cruza vários:

| Arquivo | Governa |
|---|---|
| `01-produto-e-fluxos.md` | Conceito, princípios, mapa de telas, grafo de navegação, modelo de dados conceitual, personas |
| `02-design-system.md` | Tokens (cores, tipografia, formas, sombras), componentes, motion, voz/copy |
| `03-regras-de-negocio.md` | **Todas** as fórmulas — RN-01 a RN-30 |
| `04-telas-ux.md` | Telas mobile T-01 a T-09: layout, estados, interações, copy literal |
| `05-casos-de-uso.md` | UC-01 a UC-24: fluxos, exceções, critérios de aceite + matriz de rastreabilidade |
| `06-telas-web.md` | Telas web W-01 a W-04 e as adaptações de layout |

Ordem de trabalho ao implementar uma tela: regra (`03`) → tokens/componentes (`02`) → layout e copy (`04` mobile / `06` web) → validar contra o aceite do UC correspondente (`05`).

**Nunca duplique uma fórmula em componente de UI.** Toda aritmética vive numa camada de cálculo referenciada por `RN-xx`; a tela só consome o resultado. Ao mudar comportamento, cite a regra (`RN-14`) ou o caso de uso (`UC-20`) no commit — a matriz de rastreabilidade em `05` liga tela ↔ regra ↔ caso de uso, e ela deve continuar verdadeira.

O protótipo visual original (`Bora - Revisão e Novas Direções.dc.html`) é citado como fonte da verdade visual mas **não está no repositório**; o arquivo `02` foi escrito para ser suficiente sozinho.

## Restrições que quebram o produto se ignoradas

**Cálculo (arquivo 03):**
- `adultos = homens + mulheres`; `pessoas = adultos + crianças`. **Criança nunca entra no racha** (RN-14) — o split financeiro é sempre por adulto, embora a estimativa rápida "≈ R$ X / cabeça" da tela Montar divida pelo total de pessoas. Os dois números coexistem de propósito; não unifique.
- Todo consumível multiplica pelo fator de duração `f = max(0.5, horas/4)` (RN-02).
- Dinheiro é **sempre `R$ + Math.round(valor)`** inteiro, locale `pt-BR` (RN-13). Não exiba centavos.
- Os exemplos numéricos de `03` são **casos de teste literais**, não ilustrações: o estado padrão (3H+3M+1C, 4h, bovina+frango+pão+refri+água+cerveja+cachaça) tem que dar exatamente R$ 211 / ≈R$ 30 por cabeça, e R$ 271 / ≈R$ 45 por adulto com os essenciais. Os testes A e B de RN-16 fixam a saída do algoritmo "quem paga quem".
- Preferências realimentam a calculadora (RN-21): veggie ≥1 adiciona o kit de legumes, "sem porco" remove a carne suína, e a cerveja dimensiona por quem bebe — não por `adultos` — sempre que houver pessoas nomeadas.

**Design system (arquivo 02) — o visual é neo-brutalista e literal:**
- `border-radius: 0` em tudo. Exceções: avatares/dots (círculo) e o frame do celular (38px).
- Sombras sempre duras, sem blur (`4px 4px 0 <acento>`). A única sombra suave permitida é a do frame do celular — é o palco, não a UI.
- Sem gradientes. Nenhuma cor, fonte ou sombra fora dos tokens. Máx. 2 cores de acento por tela; cada acento tem significado fixo (vermelho = dinheiro/CTA, roxo = galera/link, `#25D366` = WhatsApp, verde = pago/comprado).
- Só Archivo e Archivo Black. Nada de texto de UI abaixo de 9px.
- Todo CTA afunda no press: `translate(2px,2px)` + sombra de `4px` para `2px`.
- Toast: 1 por vez, 2200ms, some sozinho. Os textos canônicos estão em RN-29 — use-os literalmente.

**Copy:** títulos, labels, botões e toasts em CAIXA ALTA; corpo em sentence case; a copy nas specs é literal, não paráfrase.

## Workflow

A skill `tlc-spec-driven` (Specify → Design → Tasks → Execute) está instalada localmente em `.claude/skills/` e é o caminho esperado para features: tasks atômicas, commits atômicos, testes derivados dos critérios de aceite (nunca espelhando a implementação), e um verificador independente com regra evidence-or-zero. `.agents/.skill-lock.json` sincroniza a mesma skill para cursor e windsurf — se editar a skill, o lock precisa ser regerado, não editado à mão.
