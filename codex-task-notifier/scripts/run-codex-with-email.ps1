[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$CodexArguments
)

$ErrorActionPreference = "Stop"

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$entrypoint = Join-Path $scriptRoot "codex-notify-entry.ps1"
$monitorScript = Join-Path $scriptRoot "codex_turn_monitor.py"

function Resolve-CodexPath {
    $preferredCodexPaths = @(
        (Join-Path $env:APPDATA "npm\\codex.cmd"),
        (Join-Path $env:APPDATA "npm\\codex.ps1")
    )

    foreach ($candidate in $preferredCodexPaths) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    $codexCommand = Get-Command codex -CommandType Application,ExternalScript -ErrorAction Stop | Select-Object -First 1
    return $codexCommand.Source
}

function Resolve-PythonCommand {
    foreach ($candidate in @("python", "py")) {
        $command = Get-Command $candidate -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($command) {
            return $command.Source
        }
    }

    throw "Python runtime not found. 'python' or 'py' is required for the monitored Codex launcher."
}

function Invoke-LegacyProcessWrapper {
    param(
        [string]$CodexPath,
        [string[]]$Arguments
    )

    $sessionId = "wrapper-" + ([guid]::NewGuid().ToString("N"))
    $startedAt = Get-Date
    $cwd = (Get-Location).Path

    $title = if ($Arguments -and $Arguments.Count -gt 0) {
        "Codex invocation completed: " + (($Arguments -join " ").Trim())
    } else {
        "Interactive Codex session completed"
    }

    try {
        & $CodexPath @Arguments
        $exitCode = $LASTEXITCODE
    } catch {
        $exitCode = 1
        throw
    } finally {
        $finishedAt = Get-Date
        $duration = [math]::Round(($finishedAt - $startedAt).TotalSeconds, 1)
        $completed = ($exitCode -eq 0)

        $payload = [ordered]@{
            type       = if ($completed) { "task.completed" } else { "task.failed" }
            status     = if ($completed) { "completed" } else { "failed" }
            session_id = $sessionId
            thread_id  = $sessionId
            turn_id    = $sessionId
            cwd        = $cwd
            title      = $title
            summary    = "Codex process exited with code $exitCode after $duration seconds."
        }

        $payloadJson = $payload | ConvertTo-Json -Depth 10
        $payloadJson | & powershell -NoProfile -ExecutionPolicy Bypass -File $entrypoint | Out-Null
    }

    exit $exitCode
}

$codexPath = Resolve-CodexPath
$pythonPath = Resolve-PythonCommand

$approvalPolicy = "on-request"
$sandbox = "workspace-write"
$model = $null
$oncePrompt = $null
$unsupported = New-Object System.Collections.Generic.List[string]

for ($index = 0; $index -lt $CodexArguments.Count; $index++) {
    $argument = $CodexArguments[$index]
    switch ($argument) {
        "--dangerously-bypass-approvals-and-sandbox" {
            $approvalPolicy = "never"
            $sandbox = "danger-full-access"
        }
        "--ask-for-approval" {
            if ($index + 1 -ge $CodexArguments.Count) { throw "--ask-for-approval requires a value." }
            $index++
            $approvalPolicy = $CodexArguments[$index]
        }
        "--sandbox" {
            if ($index + 1 -ge $CodexArguments.Count) { throw "--sandbox requires a value." }
            $index++
            $sandbox = $CodexArguments[$index]
        }
        "--model" {
            if ($index + 1 -ge $CodexArguments.Count) { throw "--model requires a value." }
            $index++
            $model = $CodexArguments[$index]
        }
        "--once" {
            if ($index + 1 -ge $CodexArguments.Count) { throw "--once requires a value." }
            $index++
            $oncePrompt = $CodexArguments[$index]
        }
        default {
            $unsupported.Add($argument)
        }
    }
}

$legacySubcommands = @("exec", "completion", "help", "--help", "-h", "--version", "-V", "app-server")
$requiresLegacyFallback = $false

foreach ($argument in $unsupported) {
    if ($legacySubcommands -contains $argument -or $argument.StartsWith("-")) {
        $requiresLegacyFallback = $true
        break
    }
}

if ($requiresLegacyFallback) {
    Write-Host "codex-task-notifier: using legacy process wrapper for unsupported Codex arguments." -ForegroundColor Yellow
    Invoke-LegacyProcessWrapper -CodexPath $codexPath -Arguments $CodexArguments
    return
}

$launcherArguments = @(
    $monitorScript,
    "--codex-path", $codexPath,
    "--entrypoint", $entrypoint,
    "--cwd", (Get-Location).Path,
    "--approval-policy", $approvalPolicy,
    "--sandbox", $sandbox
)

if ($model) {
    $launcherArguments += @("--model", $model)
}

if ($oncePrompt) {
    $launcherArguments += @("--once", $oncePrompt, "--quiet-banner")
}

& $pythonPath @launcherArguments
exit $LASTEXITCODE
