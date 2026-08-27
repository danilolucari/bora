<#
.SYNOPSIS
Agenda a retomada do trabalho para o reset da cota + 10 min.

.DESCRIPTION
Lê `cota.py --json`, pega o `retomar_em` (que já é o reset da janela que
estourou, não sempre o de 5h) e registra a tarefa `bora-retomar` no Agendador
de Tarefas do Windows. A tarefa roda `retomar.ps1`, que chama o Claude Code em
modo headless e se desagenda ao terminar.

Existe como script porque digitar o `Register-ScheduledTask` à mão em cada
pausa erra: a data ISO com fuso não sobrevive ao `Get-Date` num Windows pt-BR,
e `schtasks` pelo Git Bash transforma `/Query` em caminho (lição L-013).

.EXAMPLE
pwsh -File .claude/scripts/agendar-retomada.ps1
pwsh -File .claude/scripts/agendar-retomada.ps1 -Cancelar
pwsh -File .claude/scripts/agendar-retomada.ps1 -Quando "2026-08-27T22:40:00-03:00"
#>
[CmdletBinding()]
param(
    # Remove a tarefa agendada (use depois de retomar à mão).
    [switch]$Cancelar,

    # Retomar com `--continue` em vez de sessão nova. O default é sessão nova:
    # o handoff no STATE.md existe justamente para isso, e recarregar o
    # contexto gigante que acabou de bater no teto queima cota à toa.
    [switch]$Continuar,

    # Horário alvo explícito (ISO 8601). Sem isto, sai do cota.py.
    [string]$Quando,

    [string]$Prompt = 'Retome o trabalho a partir do handoff em .specs/STATE.md, seção ## Handoff. Siga o workflow tlc-spec-driven e o protocolo de cota do CLAUDE.md.',

    [string]$Tarefa = 'bora-retomar'
)

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

if ($Cancelar) {
    if (Get-ScheduledTask -TaskName $Tarefa -ErrorAction SilentlyContinue) {
        Unregister-ScheduledTask -TaskName $Tarefa -Confirm:$false
        Write-Host "Tarefa '$Tarefa' removida."
    } else {
        Write-Host "Nenhuma tarefa '$Tarefa' registrada."
    }
    return
}

# --- descobrir o horário -----------------------------------------------------
if (-not $Quando) {
    $bruto = & python (Join-Path $PSScriptRoot 'cota.py') --json
    $cota = $bruto | ConvertFrom-Json
    $Quando = $cota.retomar_em
    if (-not $Quando) {
        throw "cota.py nao devolveu 'retomar_em' (veredito: $($cota.veredito) - $($cota.motivo)). Rode /usage e tente de novo."
    }
    $janela = $cota.gatilho.janela
    $pct = $cota.gatilho.pct

    if ($cota.veredito -ne 'PARAR') {
        Write-Warning "Cota esta em '$($cota.veredito)' ($($cota.motivo)). O alvo abaixo e o reset da janela mais alta, que so faz sentido depois de um PARAR."
    }
}

# [datetimeoffset] e o unico jeito seguro aqui. Testado em 2026-08-27:
# [datetime]::Parse(..., RoundtripKind).ToLocalTime() numa ISO com offset
# -03:00 devolveu Kind=Utc e o ToLocalTime subtraiu as 3h DE NOVO — a retomada
# ficou agendada 3 horas adiantada, silenciosamente, batendo na mesma parede.
# Get-Date com uma ISO offsetada tem o problema irmao: depende do locale.
$alvo = [datetimeoffset]::Parse(
    $Quando,
    [Globalization.CultureInfo]::InvariantCulture
).LocalDateTime

if ($alvo -le (Get-Date)) {
    $alvo = (Get-Date).AddMinutes(2)
    Write-Warning "Horario calculado ja passou; agendando para daqui a 2 min."
}

# --- registrar ---------------------------------------------------------------
$modo = if ($Continuar) { '-Continuar' } else { '' }
$argumentos = @(
    '-NoProfile'
    '-ExecutionPolicy', 'Bypass'
    '-File', (Join-Path $PSScriptRoot 'retomar.ps1')
    '-Prompt', "`"$Prompt`""
) + @($modo | Where-Object { $_ })

$acao = New-ScheduledTaskAction `
    -Execute (Get-Command pwsh).Source `
    -Argument ($argumentos -join ' ') `
    -WorkingDirectory $raiz

$gatilho = New-ScheduledTaskTrigger -Once -At $alvo

# StartWhenAvailable: se a maquina estava dormindo na hora marcada, a tarefa
# roda assim que ela voltar em vez de simplesmente nao acontecer.
$opcoes = New-ScheduledTaskSettingsSet `
    -StartWhenAvailable `
    -WakeToRun `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Hours 5)

Register-ScheduledTask `
    -TaskName $Tarefa `
    -Action $acao `
    -Trigger $gatilho `
    -Settings $opcoes `
    -Description 'BORA: retoma o trabalho a partir do handoff apos o reset da cota.' `
    -Force | Out-Null

$contexto = if ($janela) { " (reset de $janela, que estava em $pct%)" } else { '' }
Write-Host "Retomada agendada: $($alvo.ToString('yyyy-MM-dd HH:mm:ss'))$contexto"
Write-Host "  tarefa : $Tarefa"
Write-Host "  modo   : $(if ($Continuar) { '--continue (sessao anterior)' } else { 'sessao nova a partir do handoff' })"
Write-Host "  log    : .claude/logs/retomada-*.log"
Write-Host "  cancelar: pwsh -File .claude/scripts/agendar-retomada.ps1 -Cancelar"
