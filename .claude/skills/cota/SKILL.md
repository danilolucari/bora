---
name: cota
description: Lê a cota da sessão do Claude Code (~/.claude.json), decide entre seguir e pausar, e executa o protocolo de handoff + agendamento de retomada quando passa de 85%. Use entre tasks, em fronteira de fase, antes de abrir trabalho longo, ou quando o usuário perguntar quanto resta da sessão.
---

# Monitoria de cota, pausa e retomada

Processo **fixo** deste projeto, combinado com o usuário. Não é opcional e não
precisa ser pedido: rodar a verificação faz parte do ciclo de trabalho.

## A fonte certa

`~/.claude.json` → `cachedUsageUtilization` — o **mesmo dado que o `/usage`
mostra**. O Claude Code reescreve esse cache enquanto a sessão roda.

```bash
python .claude/scripts/cota.py          # relatório
python .claude/scripts/cota.py --curto  # uma linha
python .claude/scripts/cota.py --json   # para script
```

> **Nunca use `ccusage` para esta medida.** Ele soma `cacheReadInputTokens`,
> que cresce a cada turno porque o contexto é relido inteiro, e não enxerga o
> limite da conta. Em 2026-08-25 uma estimativa por `ccusage` gritou **100%**
> quando o `/usage` real marcava **18%**, e o trabalho foi pausado à toa.

## Quando verificar

- **Ao fim de cada task** que envolva implementação.
- **Em toda fronteira de fase** e antes de começar uma feature nova.
- **Antes de abrir trabalho longo** (Execute de uma fase inteira, Verifier).
- Sempre que o usuário perguntar.

Custa uma chamada de shell. Não custa contexto relevante.

## Os limiares

| Veredito | Faixa | O que fazer |
|---|---|---|
| `SEGUIR` | < 70% | Trabalhar normalmente |
| `ATENCAO` | 70–84% | Fechar a task corrente; **não abrir task longa**; preparar o handoff |
| `PARAR` | ≥ 85% | Executar o protocolo de pausa abaixo, imediatamente |
| `INCERTO` | — | Cache ausente, velho (>30 min) ou de janela já encerrada. **Pedir `/usage` ao usuário** e não decidir no escuro |

O gatilho é o **pior** entre sessão (5h) e semana (7d) — estourar a semana
para a sessão inteira, não só a janela.

## O guarda que mais importa

Dois falsos-verdes já aconteceram neste projeto e o script cobre os dois:

1. **Cache congelado** — `fetchedAtMs` parado. Número velho repetido para
   sempre parece "tudo bem" e não é. Acima de 30 min → `INCERTO`.
2. **Janela já virada** — `resets_at` no passado com a porcentagem antiga
   ainda em cache. Aconteceu em 2026-08-26 03:54 UTC: o cache marcava 55% de
   uma janela encerrada 4 minutos antes. → `INCERTO`.

`INCERTO` **não é `SEGUIR`**. Peça ao usuário para rodar `/usage` (ou
`/usage-credits`), que força a atualização do cache, e verifique de novo.

## Protocolo de pausa (≥ 85%)

Executar **nesta ordem**, sem pular etapa:

1. **Fechar o que está aberto.** Terminar a task corrente até o commit, ou
   descartar o trabalho parcial dela. Nunca deixar meia task no disco — foi o
   que manteve a perda em ~zero nos quatro estouros do M0.
2. **Escrever o handoff** no `.specs/STATE.md`, seção `## Handoff`, com:
   feature, fase, tasks concluídas, próximo passo, contagem de testes,
   branch, arquivos não commitados e bloqueios. **Substituir só o corpo
   daquela seção** — nunca sobrescrever o arquivo, que destruiria o log de
   Decisions acima.
3. **Commitar o handoff.**
4. **Agendar a retomada** para `resets_at + 10 min` (§ abaixo).
5. **Avisar o usuário** com: porcentagem que disparou, horário do reset,
   horário agendado da retomada e o que ficou pela metade (idealmente: nada).

## Agendar a retomada

`resets_at + 10 min`, no fuso local. O script já calcula em `retomar_em`.

No Windows, use **PowerShell**, não `schtasks` pelo Git Bash — argumento que
começa com barra vira caminho do Windows lá (lição L-013 do playbook):

```powershell
$quando = Get-Date "AAAA-MM-DDTHH:MM:SS"
$acao = New-ScheduledTaskAction -Execute "claude" `
  -Argument '--continue -p "retome o trabalho a partir do handoff em .specs/STATE.md"' `
  -WorkingDirectory "C:\repos\lucari\bora"
$gatilho = New-ScheduledTaskTrigger -Once -At $quando
Register-ScheduledTask -TaskName "bora-retomar" -Action $acao -Trigger $gatilho -Force
```

Limpar depois de retomar:

```powershell
Unregister-ScheduledTask -TaskName "bora-retomar" -Confirm:$false
```

**Diga ao usuário que a tarefa foi criada e qual o horário.** Tarefa agendada
que ele não conhece é surpresa, não automação.

## O que esta automação não faz

Sendo honesto sobre o limite: **não há vigilância contínua em background.** A
verificação acontece quando este processo roda o script — entre tasks e em
fronteira de fase. Se a sessão morrer entre duas verificações, o que protege o
trabalho é o commit atômico por task e o handoff, não o monitor.
