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
python .claude/scripts/cota.py             # relatório
python .claude/scripts/cota.py --curto     # uma linha
python .claude/scripts/cota.py --json      # para script
python .claude/scripts/cota.py --esperar 3 # espera até 3s por um cache novo
```

### Por que "rodar duas vezes" parecia consertar

O cache **só é regravado quando o Claude Code recebe resposta da API**. Nenhuma
rodada do script atualiza nada — ele lê um arquivo. Quando a leitura saía velha
e a segunda rodada saía certa, quem consertou foi a resposta da API que coube
**entre** as duas, não a repetição.

Onde isso aparecia de verdade: no `SessionStart`. O hook roda antes da primeira
resposta da API da sessão, então o número dali é o da sessão anterior. Em
2026-09-03 ele relatou 54% com o valor real em 68%.

Hoje: o `SessionStart` diz que o número é **herdado** e que se corrige sozinho
na primeira chamada de ferramenta (sem pedir `/usage` à toa), e o `PostToolUse`
**fala uma vez** quando o verde substitui aquele `INCERTO` — a leitura boa chega
sem ninguém rodar nada. Fora dos hooks, use `--esperar SEG`: em vez de devolver
`INCERTO` na hora, o script relê o arquivo a cada 200 ms até o `fetchedAtMs`
mudar ou o orçamento acabar. Ele só espera pelo que uma gravação nova conserta
(cache velho, janela virada); cache ausente ou sem a janela de 5h volta na hora,
porque esperar só atrasaria o mesmo `INCERTO`.

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
| `INCERTO` | — | Cache ausente, malformado, ou velho (>30 min) com a janela ainda aberta. **Siga** sem abrir task longa: a próxima chamada de ferramenta corrige sozinha. Só é defeito se persistir por várias chamadas |

## Qual janela decide

**Só a janela de sessão (5h).** As semanais — `seven_day` e o teto separado de
Opus dos planos Max — continuam sendo lidas e aparecem no relatório marcadas
`(informativa)`, mas **não disparam veredito nenhum**: com a semana em 97% e a
sessão em 5%, o veredito é `SEGUIR`.

Foi decisão do usuário em 2026-08-28, revertendo a regra anterior ("a pior de
todas as janelas"). O motivo: o teto semanal fica alto por dias seguidos, então
por ele o projeto vivia em `ATENCAO` permanente — recusando task longa com a
janela de 5h vazia, que é exatamente o momento em que dá para trabalhar.

O preço, assumido: quando a semana estourar de verdade, a parada vem da API e
não do monitor. O que protege o trabalho aí é o mesmo de sempre — commit
atômico por task mais handoff.

Se o cache não trouxer a janela de 5h, o veredito é `INCERTO`, não `SEGUIR`:
sem a janela que decide, não há decisão.

## Os guardas que mais importam

Dois falsos-verdes já aconteceram neste projeto e o script cobre os dois:

1. **Cache congelado** — `fetchedAtMs` parado. Número velho repetido para
   sempre parece "tudo bem" e não é. Acima de 30 min **com a janela ainda
   aberta** → `INCERTO` (se a janela virou, quem manda é o guarda 2).
2. **Janela já virada** — `resets_at` no passado com a porcentagem antiga
   ainda em cache. Aconteceu em 2026-08-26 03:54 UTC: o cache marcava 55% de
   uma janela encerrada 4 minutos antes. A resposta depende de **quando o cache
   foi buscado**: se ele é *anterior* ao reset, o veredito é `SEGUIR` provisório
   com 0% — a janela nova nasceu depois daquela leitura, e gasto nela teria
   regravado o cache; se é *posterior* e ainda traz a janela morta, é leitura
   inconsistente do servidor → `INCERTO`.
3. **Falha do próprio monitor** — `PARAR` é o exit code 1, que é também o que o
   Python devolve ao morrer de traceback. Um defeito no script ficava
   indistinguível de "pare e escreva o handoff": em 2026-09-01 um
   `KeyError: 'cache_idade_min'` saiu como 1. Hoje o `main` tem uma barreira que
   converte qualquer exceção inesperada em `INCERTO` (código 2). Um monitor
   quebrado não sabe nada sobre a cota, e quem não sabe diz `INCERTO`.

Pela mesma razão, `resets_at` ilegível ou **sem fuso** também é `INCERTO`: sem
ele o guarda 2 não roda, e chutar um fuso erraria por horas justamente no
cálculo que decide se a janela virou.

## `INCERTO` não é motivo para interromper o usuário

`INCERTO` **não é `SEGUIR`** — mas pedir `/usage` quase nunca é a resposta. Quem
regrava o cache é **qualquer** resposta da API, e o próximo turno provoca uma de
graça: `/usage` nunca foi especial, era só a forma manual de fazer o que o
trabalho já faz sozinho. Então **siga**, não abra task longa, e deixe a próxima
chamada de ferramenta trazer o número — o `PostToolUse` fala uma vez quando o
verde substitui o `INCERTO`, justamente para ninguém precisar conferir à mão.

Pedir `/usage` fica para os casos que uma resposta da API **não** conserta,
porque não são falta de atualização e sim cache quebrado: `cachedUsageUtilization`
ausente, `fetchedAtMs` faltando, `resets_at` ilegível, cache sem a janela de 5h,
ou falha do próprio monitor. Aí o `/usage` é diagnóstico — a pergunta é se o
Claude Code está gravando o cache —, não refresh.

## Testes

```bash
python .claude/scripts/cota_test.py   # 23 casos, sem dependência externa
```

Cada caso sai de um critério deste arquivo, não da implementação: a tabela de
gatilho, "só a sessão decide", os três guardas acima e as regressões de
2026-09-01. Os testes rodam o `cota.py` **como subprocesso**, do jeito que o
hook roda, porque o que importa ali é o exit code — asserção sobre função
interna não pegaria o defeito que motivou o arquivo. Bateria de mutação de
2026-09-01: **9 mutantes plantados, 9 mortos**.

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

- **O alvo é o reset da janela do gatilho + 10 min** — que, como só a sessão
  dispara, é sempre o reset de 5h. O script lê `gatilho.reseta_em` do JSON em
  vez de fixar `five_hour`, para não mentir se um dia outra janela voltar a
  decidir; ele diz qual janela usou.
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
