function Get-NotifierPaths {
    [CmdletBinding()]
    param()

    $repoRoot = Split-Path -Parent $PSScriptRoot
    $runtimeRoot = Join-Path $HOME ".codex-task-notifier"

    return [pscustomobject]@{
        RepoRoot        = $repoRoot
        RuntimeRoot     = $runtimeRoot
        ConfigRoot      = Join-Path $runtimeRoot "config"
        LogsRoot        = Join-Path $runtimeRoot "logs"
        RawLogsRoot     = Join-Path $runtimeRoot "logs\\raw"
        NormalizedRoot  = Join-Path $runtimeRoot "logs\\normalized"
        DeliveryRoot    = Join-Path $runtimeRoot "logs\\delivery"
        ValidationRoot  = Join-Path $runtimeRoot "logs\\validation"
        StateRoot       = Join-Path $runtimeRoot "state"
        SettingsPath    = Join-Path $runtimeRoot "config\\settings.json"
        DedupeStorePath = Join-Path $runtimeRoot "state\\sent-events.json"
        SubjectTemplate = Join-Path $repoRoot "templates\\subject.txt"
        BodyTemplate    = Join-Path $repoRoot "templates\\body.txt"
    }
}
