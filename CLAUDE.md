# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Estado do repositório

**O marco M0 está fechado e mergeado em `main`** (2026-08-25): projeto Flutter multi-plataforma, `core/calculo/` (RN-01..RN-21 em Dart puro) e `core/design_system/` (tokens e ~18 componentes do arquivo 02). Baseline: `flutter analyze` limpo e **742 testes verdes**. Comandos reais: `flutter test`, `flutter analyze`, `flutter run`. Sem CI — não crie pipeline sem pedido.

O alvo é **um único codebase Flutter** servindo mobile (frame 390×820) e web (janela 1180×800), com o mesmo estado nas duas plataformas.

`.specs/` tem quatro camadas, e a ordem importa: `init-spec/` é a especificação do produto (fonte da verdade), `ROADMAP.md` decompõe ela em 11 specs de feature e 4 marcos, `STATE.md` guarda as decisões de arquitetura (**AD-001..AD-018**) e o handoff, e `features/<nome>/` tem o `spec.md`/`design.md`/`tasks.md`/`validation.md` de cada uma. **Leia o `STATE.md` antes de decidir qualquer coisa** — uma AD ativa vale mais que este arquivo.

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

**Nunca duplique uma fórmula em componente de UI.** Toda aritmética vive numa camada de cálculo referenciada por `RN-xx`; a tela só consome o resultado. Ao mudar comportamento, cite a regra (`RN-14`) ou o caso de uso (`UC-20`) no corpo do commit — a matriz de rastreabilidade em `05` liga tela ↔ regra ↔ caso de uso, e ela deve continuar verdadeira.

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

## Decisões de engenharia

Decididas antes de o código existir. Valem como default: se uma delas atrapalhar a implementação, levante a questão em vez de divergir em silêncio.

**Stack:** Flutter (mobile + web, um codebase). Estado com **BLoC** — eventos e estados explícitos, nada de lógica de negócio dentro de widget. Backend **Firebase**: Auth (**e-mail/senha + Google** — telefone foi descartado pela **AD-015**, porque T-01/W-01/UC-01 desenham só esses dois; o convidado do link continua **sem conta**, via auth anônima), Firestore (banco principal, realtime — a confirmação do convidado reflete na Home do anfitrião sem refresh), Hosting (deploy do Flutter Web, servindo também o link público `bora.app/c/xxx`) e Functions (lógica servidora: gerar link, notificar, integrações).

**Arquitetura:** Clean Architecture, feature-first, com as camadas dentro de cada feature.

```
lib/
  core/
    design_system/     # tokens e componentes do arquivo 02
    calculo/           # camada de cálculo — TODAS as RN-xx
  features/<feature>/  # montar, galera, lista, convite, custos, convidado
    domain/            # entidades, repositories (abstratos), usecases
    data/              # models, datasources (Firestore), repositories (impl)
    presentation/      # bloc/, pages/, widgets/
```

`core/calculo/` é Dart puro: **sem import de Flutter e sem import de Firebase**. É o que torna as RN-xx testáveis sozinhas e o que impede a fórmula de vazar para a UI. As features consomem o resultado; nenhuma outra camada recalcula.

**Idioma do código:** domínio em **PT-BR**, resto em inglês. Entidades e regras de negócio usam o vocabulário da spec (`Festa`, `Pessoa`, `ItemDeLista`, `Despesa`, `calcularRacha`, `fatorDuracao`) — o mesmo nome que aparece em `01` e `03`, para o código e a spec falarem a mesma língua. Infra, blocs, widgets, datasources e utilitários em inglês (`PartyRepository` não; `FestaRepository` sim — a entidade manda; mas `FirestoreDataSource`, `AppRouter`, `MoneyFormatter` ficam em inglês).

**Testes:** pirâmide completa.
- **Unit** — cobrem toda `RN-xx` em `core/calculo/`. Os exemplos numéricos de `03` entram como casos de teste **literais** (o padrão R$ 211/≈R$ 30, os R$ 271/≈R$ 45 com essenciais, os testes A e B de RN-16). Se um desses falhar, o errado é o código.
- **Widget** — cada critério de aceite de `UC-xx` vira widget test.
- **Integration** (`integration_test/`) — fluxos ponta-a-ponta: montar → convidar → convidado confirma → acerto.

Teste sai do critério de aceite, nunca da implementação. `test/` espelha a estrutura de `lib/`.

**Lint:** `flutter_lints` no `pubspec.yaml`, rodando local. Sem CI por enquanto — não crie pipeline sem pedido.

**Commits:** Conventional Commits em português, assunto simples (`feat(montar): calcula custo ao vivo`). A referência `RN-xx`/`UC-xx` vai no **corpo**, não no assunto. Branches `feature/nome`.


## Cota da sessão: monitorar, pausar, retomar

**Processo fixo, não opcional.** Vale para toda sessão neste repositório.
Detalhe completo na skill `cota` (`.claude/skills/cota/SKILL.md`).

A fonte da cota é `~/.claude.json` → `cachedUsageUtilization` — o mesmo dado do
`/usage`. **Nunca estime com `ccusage`**: ele soma `cacheReadInputTokens`, que
incha a cada turno, e não enxerga o limite da conta; em 2026-08-25 isso produziu
um alarme de 100% com o `/usage` real em 18%, e pausou o trabalho à toa.

```bash
python .claude/scripts/cota.py        # SEGUIR / ATENCAO / PARAR / INCERTO
```

Verificar **ao fim de cada task**, em **toda fronteira de fase** e antes de abrir
trabalho longo. Gatilho pelo pior entre sessão (5h) e semana (7d):

| < 70% | 70–84% | ≥ 85% | cache velho ou janela virada |
|---|---|---|---|
| seguir | fechar a task, não abrir task longa | **protocolo de pausa** | `INCERTO` — pedir `/usage` ao usuário, não decidir no escuro |

**Protocolo de pausa**, nesta ordem: fechar a task corrente até o commit (nunca
deixar meia task no disco) → escrever o handoff na seção `## Handoff` do
`.specs/STATE.md`, **substituindo só o corpo daquela seção** → commitar →
agendar a retomada para `resets_at + 10 min` via `Register-ScheduledTask` do
PowerShell (não `schtasks` pelo Git Bash, onde `/Query` vira caminho) → avisar o
usuário com o horário agendado.

O que de fato protege o trabalho é o **commit atômico por task** somado ao
handoff — não o monitor. Não existe vigilância em background: a verificação só
acontece quando o script roda.

## Workflow

A skill `tlc-spec-driven` (Specify → Design → Tasks → Execute) está instalada localmente em `.claude/skills/` e é o caminho esperado para features: tasks atômicas, commits atômicos, testes derivados dos critérios de aceite (nunca espelhando a implementação), e um verificador independente com regra evidence-or-zero. `.agents/.skill-lock.json` sincroniza a mesma skill para cursor e windsurf — se editar a skill, o lock precisa ser regerado, não editado à mão.
