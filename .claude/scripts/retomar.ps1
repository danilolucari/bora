<#
.SYNOPSIS
O que a tarefa agendada `bora-retomar` executa quando a cota reseta.

.DESCRIPTION
Chama o Claude Code em modo headless (`-p`), com a saída em
`.claude/logs/retomada-<data>.log`, e se desagenda ao terminar. Headless foi a
escolha do usuário: o trabalho continua mesmo com ele dormindo, e o log é o
que ele lê de manhã.

Antes de gastar qualquer coisa, confere se a cota realmente resetou — se o
agendamento disparou cedo (ou se outra sessão queimou a janela nova), ele se
reagenda em vez de bater na mesma parede.
#>
[CmdletBinding()]
param(
    [string]$Prompt = 'Retome o trabalho a partir do handoff em .specs/STATE.md, seção ## Handoff. Siga o workflow tlc-spec-driven e o protocolo de cota do CLAUDE.md.',

    # Retomar a sessão anterior em vez de abrir uma nova.
    [switch]$Continuar,

    [string]$Tarefa = 'bora-retomar'
)

$ErrorActionPreference = 'Continue'
$raiz = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Set-Location $raiz

$pastaLog = Join-Path $raiz '.claude\logs'
if (-not (Test-Path $pastaLog)) { New-Item -ItemType Directory -Path $pastaLog | Out-Null }
$log = Join-Path $pastaLog "retomada-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log([string]$texto) {
    $linha = "[$(Get-Date -Format 'HH:mm:ss')] $texto"
    Write-Host $linha
    Add-Content -Path $log -Value $linha -Encoding utf8
}

Write-Log "Retomada disparada em $raiz"

# --- a cota resetou mesmo? ---------------------------------------------------
$cota = & python (Join-Path $PSScriptRoot 'cota.py') --json | ConvertFrom-Json
Write-Log "Cota: $($cota.veredito) - $($cota.motivo)"

if ($cota.veredito -eq 'PARAR') {
    Write-Log "Ainda em $($cota.gatilho.pct)%. Reagendando em vez de queimar a janela nova."
    & (Join-Path $PSScriptRoot 'agendar-retomada.ps1') @PSBoundParameters
    exit 0
}

if ($cota.veredito -eq 'INCERTO') {
    # O cache fica velho justamente quando ninguem falou com a API por horas —
    # que e exatamente o caso aqui. Seguir e o certo: a primeira chamada
    # atualiza o cache, e o hook PostToolUse pega o numero real em segundos.
    Write-Log "Cache incerto ($($cota.motivo)). Seguindo: o hook confere no primeiro tool call."
}

# --- retomar -----------------------------------------------------------------
$argumentos = @()
if ($Continuar) { $argumentos += '--continue' }
$argumentos += @('-p', $Prompt, '--permission-mode', 'acceptEdits')

Write-Log "claude $($argumentos -join ' ')"
& claude @argumentos 2>&1 | ForEach-Object { Add-Content -Path $log -Value $_ -Encoding utf8 }
$codigo = $LASTEXITCODE
Write-Log "claude terminou com codigo $codigo"

# --- limpar ------------------------------------------------------------------
if (Get-ScheduledTask -TaskName $Tarefa -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $Tarefa -Confirm:$false
    Write-Log "Tarefa '$Tarefa' removida."
}

Write-Log "Log completo: $log"
exit $codigo
