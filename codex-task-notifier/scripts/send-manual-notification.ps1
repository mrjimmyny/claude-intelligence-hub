[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TaskTitle,

    [Parameter(Mandatory = $true)]
    [string]$Summary,

    [ValidateSet("completed", "failed")]
    [string]$Status = "completed",

    [string]$SessionId = $null,

    [string]$ThreadId = $null,

    [string]$TurnId = $null,

    [string]$ProjectPath = (Get-Location).Path,

    [string]$AgentName = "Emma",

    [string]$LlmModel = "GPT-5 Codex",

    [string]$OwnerName = "Jimmy",

    [string]$MachineId = $env:COMPUTERNAME
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$entrypoint = Join-Path $scriptRoot "codex-notify-entry.ps1"

if (-not $SessionId) { $SessionId = "manual-" + ([guid]::NewGuid().ToString("N")) }
if (-not $ThreadId) { $ThreadId = $SessionId }
if (-not $TurnId) { $TurnId = "manual-turn-" + ([guid]::NewGuid().ToString("N")) }

$payload = [ordered]@{
    type       = if ($Status -eq "completed") { "task.completed" } else { "task.failed" }
    status     = $Status
    session_id = $SessionId
    thread_id  = $ThreadId
    turn_id    = $TurnId
    cwd        = $ProjectPath
    title      = $TaskTitle
    summary    = $Summary
    agent_name = $AgentName
    llm_model  = $LlmModel
    owner_name = $OwnerName
    machine_id = $MachineId
}

$payloadJson = $payload | ConvertTo-Json -Depth 10
$payloadJson | & powershell -NoProfile -ExecutionPolicy Bypass -File $entrypoint | Out-Null
