---
name: cota
description: Monitoria automática da cota da sessão (hooks + ~/.claude.json), protocolo de pausa com handoff em 85% e agendamento da retomada para o reset + 10 min. Use quando o monitor mandar parar, quando o usuário perguntar quanto resta, ou para entender/consertar a própria monitoria.
---

# Monitoria de cota, pausa e retomada

Processo **fixo** deste projeto, combinado com o usuário. **A monitoria roda
sozinha** — três hooks em `.claude/settings.json` a mantêm ligada em toda
sessão, sem depender de alguém lembrar de rodar um script.

Se você está lendo isto porque o monitor mandou parar, vá direto para
[o protocolo de pausa](#protocolo-de-pausa-85).

## Como a monitoria fica ligada sozinha

| Hook | Quando dispara | O que faz |
|---|---|---|
| `SessionStart` | toda sessão que abre, resume ou dá `/clear` | Lê a cota e injeta o estado atual. É isto que garante que **nenhuma sessão comece sem monitoria**, mesmo que o `CLAUDE.md` não seja lido |
| `PostToolUse` | toda chamada de ferramenta | Relê a cota. Fala a cada 5 min em `ATENCAO`, a cada 15 min em `INCERTO`, **sempre** em `PARAR`, e fica calado em `SEGUIR` |
| `Stop` | fim de cada turno | Em `PARAR`, **bloqueia** o fim do turno e injeta o protocolo. É a única parte com dentes: contexto injetado pode ser ignorado, um `Stop` bloqueado não |

Tudo passa por `.claude/scripts/cota_hook.py`, que chama `cota.py`.

**Por que "a cada chamada de ferramenta" e não um cronômetro de 5 min:** a cota
só anda quando a sessão fala com a API, e toda chamada de ferramenta vem logo
depois de uma. Então o gatilho por ferramenta cobre exatamente os instantes em
que o número pode ter mudado — mais denso que 5 minutos, e sem processo de
fundo para morrer sem ninguém notar. Sessão ociosa não gasta cota e não precisa
de vigia. O intervalo de 5 min governa quando o monitor **fala**, porque
contexto injetado é o único custo real: ler `~/.claude.json` custa ~0,5 ms e o
processo ~30 ms.

**Em verde o monitor fica calado.** Silêncio é o estado normal, não sinal de
que ele morreu. Para conferir que está vivo:

```bash
python .claude/scripts/cota.py     # o mesmo dado que o hook lê
cat .claude/.cota-estado.json      # última leitura por sessão
```

## A fonte certa

`~/.claude.json` → `cachedUsageUtilization` — o **mesmo dado que o `/usage`
mostra**. O Claude Code reescreve esse cache a cada resposta da API, e ele é da
**conta**, não da sessão: outra sessão queimando cota nesta máquina aparece
aqui também.

```bash
python .claude/scripts/cota.py          # relatório
python .claude/scripts/cota.py --curto  # uma linha
python .claude/scripts/cota.py --json   # para script
```

> **Nunca use `ccusage` para esta medida.** Ele soma `cacheReadInputTokens`,
> que cresce a cada turno porque o contexto é relido inteiro, e não enxerga o
> limite da conta. Em 2026-08-25 uma estimativa por `ccusage` gritou **100%**
> quando o `/usage` real marcava **18%**, e o trabalho foi pausado à toa.

## Os limiares

| Veredito | Faixa | O que fazer |
|---|---|---|
| `SEGUIR` | < 70% | Trabalhar normalmente |
| `ATENCAO` | 70–84% | Fechar a task corrente; **não abrir task longa**; preparar o handoff |
| `PARAR` | ≥ 85% | Protocolo de pausa, imediatamente |
| `INCERTO` | — | Cache ausente, velho (>30 min) ou de janela já encerrada. **Pedir `/usage` ao usuário** e não decidir no escuro |

O gatilho é a **pior de todas as janelas** que o cache conhece — não só
`five_hour` e `seven_day`. Planos Max têm teto semanal separado de Opus, que
pode estourar com o semanal geral ainda baixo; ler só os dois nomes óbvios
deixava esse passar em branco.

## Os guardas que mais importam

Dois falsos-verdes já aconteceram neste projeto e o script cobre os dois:

1. **Cache congelado** — `fetchedAtMs` parado. Número velho repetido para
   sempre parece "tudo bem" e não é. Acima de 30 min → `INCERTO`.
2. **Janela já virada** — `resets_at` no passado com a porcentagem antiga
   ainda em cache. Aconteceu em 2026-08-26 03:54 UTC: o cache marcava 55% de
   uma janela encerrada 4 minutos antes. → `INCERTO`.

`INCERTO` **não é `SEGUIR`**. Peça ao usuário para rodar `/usage`, que força a
atualização do cache, e verifique de novo.

## Protocolo de pausa (≥ 85%)

O hook `Stop` injeta estes passos e bloqueia o fim do turno até eles
acontecerem. Executar **nesta ordem**, sem pular etapa:

1. **Fechar o que está aberto.** Terminar a task corrente até o commit, ou
   descartar o trabalho parcial dela. Nunca deixar meia task no disco — foi o
   que manteve a perda em ~zero nos quatro estouros do M0.
2. **Escrever o handoff** no `.specs/STATE.md`, seção `## Handoff`, com:
   feature, fase, tasks concluídas, próximo passo, contagem de testes,
   branch, arquivos não commitados e bloqueios. **Substituir só o corpo
   daquela seção** — nunca sobrescrever o arquivo, que destruiria o log de
   Decisions acima.
3. **Commitar o handoff.**
4. **Agendar a retomada:**
   ```bash
   pwsh -File .claude/scripts/agendar-retomada.ps1
   ```
5. **Avisar o usuário** com: porcentagem que disparou, **qual janela**,
   horário do reset, horário agendado da retomada e o que ficou pela metade
   (idealmente: nada).

## Agendar a retomada

`agendar-retomada.ps1` lê o `cota.py --json`, calcula o alvo e registra a
tarefa `bora-retomar` no Agendador do Windows. Ela dispara `retomar.ps1`, que
chama o Claude Code **headless** (`-p --permission-mode acceptEdits`, escolha
do usuário: o trabalho continua com ele dormindo), loga em
`.claude/logs/retomada-*.log` e se desagenda ao terminar.

```bash
pwsh -File .claude/scripts/agendar-retomada.ps1              # agenda
pwsh -File .claude/scripts/agendar-retomada.ps1 -Cancelar    # desagenda
pwsh -File .claude/scripts/agendar-retomada.ps1 -Continuar   # --continue em vez de sessão nova
```

Três decisões embutidas, todas testadas em 2026-08-27:

- **O alvo é o reset da janela que estourou**, não sempre o de 5h. Se quem
  passou de 85% foi a **semana**, voltar em cinco horas bate na mesma parede —
  o alvo certo pode ser dias à frente. O script diz qual janela usou.
- **Sessão nova, não `--continue`.** O handoff no `STATE.md` existe justamente
  para isso, e recarregar o contexto gigante que acabou de bater no teto queima
  cota logo na volta. Use `-Continuar` quando o contexto anterior for
  insubstituível.
- **`[datetimeoffset]::Parse(...).LocalDateTime`**, nunca
  `[datetime]::Parse(..., RoundtripKind).ToLocalTime()` nem `Get-Date` com uma
  ISO offsetada. O primeiro devolveu `Kind=Utc` e subtraiu o offset de novo,
  agendando a retomada **3 horas adiantada** — em silêncio. O segundo depende
  do locale, e este Windows é pt-BR.

Antes de gastar qualquer coisa, `retomar.ps1` reconfere a cota: se ainda
estiver em `PARAR` (agendamento cedo, ou outra sessão queimou a janela nova),
ele se reagenda em vez de bater na parede.

Nada disso usa `schtasks` pelo Git Bash, onde argumento iniciado por barra vira
caminho do Windows (lição L-013 do playbook). É PowerShell direto.

**Diga ao usuário que a tarefa foi criada e qual o horário.** Tarefa agendada
que ele não conhece é surpresa, não automação.

## O que esta automação ainda não faz

Sendo honesto sobre os limites que sobraram:

- **Não vigia sessão ociosa.** Sem chamada de ferramenta, não há hook. Isso é
  inofensivo — cota parada não anda —, mas significa que o número que você vê
  ao acordar a sessão é do último turno até o primeiro tool call novo.
- **Não sobrevive à sessão morrer.** Se o processo cair entre dois turnos, o
  que protege o trabalho é o **commit atômico por task** somado ao handoff,
  não o monitor. Isso não mudou e é o que de fato segurou as perdas no M0.
- **A retomada headless aprova as próprias edições** (`acceptEdits`, mais o
  allowlist de `git`/`flutter` em `.claude/settings.json`). É o preço do modo
  autônomo que o usuário escolheu; o log em `.claude/logs/` é a auditoria.
- **Hook novo só vale na sessão seguinte** se o `.claude/settings.json` não
  existia quando a sessão atual abriu. Nesse caso o usuário precisa abrir
  `/hooks` uma vez ou reiniciar.
