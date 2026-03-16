[CmdletBinding()]
param(
    [switch]$ApplyNotifyHook,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $root "lib\\Get-NotifierPaths.ps1")

$paths = Get-NotifierPaths
$settingsSource = Join-Path $root "config\\settings.example.json"

Write-Host "Preparing runtime folders under $($paths.RuntimeRoot)"
Write-Host "Settings target: $($paths.SettingsPath)"
Write-Host "Dedupe store: $($paths.DedupeStorePath)"

if ($DryRun) {
    Write-Host "Dry run complete."
    return
}

New-Item -ItemType Directory -Force -Path $paths.ConfigRoot, $paths.RawLogsRoot, $paths.NormalizedRoot, $paths.DeliveryRoot, $paths.ValidationRoot, $paths.StateRoot | Out-Null
if (-not (Test-Path $paths.SettingsPath)) {
    Copy-Item $settingsSource $paths.SettingsPath
}
if (-not (Test-Path $paths.DedupeStorePath)) {
    "[]" | Set-Content -Path $paths.DedupeStorePath -Encoding UTF8
}

$codexDir = Join-Path $HOME ".codex"
$codexConfig = Join-Path $codexDir "config.toml"
$hook = @"
# codex-task-notifier:start
tui.notifications = ["agent-turn-complete"]
notify = [
  "powershell",
  "-NoProfile",
  "-ExecutionPolicy",
  "Bypass",
  "-File",
  "C:\\ai\\_skills\\codex-task-notifier\\scripts\\codex-notify-entry.ps1"
]
# codex-task-notifier:end
"@

if ($ApplyNotifyHook) {
    New-Item -ItemType Directory -Force -Path $codexDir | Out-Null
    if (-not (Test-Path $codexConfig)) {
        "" | Set-Content -Path $codexConfig -Encoding UTF8
    }

    $content = Get-Content -Raw $codexConfig
    if ($content -match 'codex-task-notifier:start') {
        $updated = [regex]::Replace(
            $content,
            '(?s)# codex-task-notifier:start.*?# codex-task-notifier:end',
            $hook.TrimEnd()
        )
        Set-Content -Path $codexConfig -Value $updated -Encoding UTF8
        Write-Host "Notify hook updated in $codexConfig"
    } else {
        Add-Content -Path $codexConfig -Value "`r`n$hook" -Encoding UTF8
        Write-Host "Notify hook added to $codexConfig"
    }
} else {
    Write-Host "Legacy TUI notify hook not applied. Re-run with -ApplyNotifyHook only if you want the compatibility trail."
}

Write-Host ""
Write-Host "Recommended product path:"
Write-Host "  keep the normal Codex UI"
Write-Host "  use scripts\\send-manual-notification.ps1 only for tasks that explicitly need email"
Write-Host "Optional compatibility path:"
Write-Host "  Codex TUI notify hook + tui.notifications"
Write-Host "Experimental path:"
Write-Host "  scripts\\run-codex-with-email.ps1"

Write-Host ""
Write-Host "Required HTTPS environment variables for the pivot:"
Write-Host "  CTN_RESEND_API_KEY"
Write-Host "  CTN_RESEND_FROM"
Write-Host "  CTN_MAILGUN_API_KEY"
Write-Host "  CTN_MAILGUN_FROM"
Write-Host "  CTN_MAILGUN_DOMAIN"
Write-Host "Optional:"
Write-Host "  CTN_MAILGUN_BASE_URL"
Write-Host "  CTN_RESEND_BASE_URL"
Write-Host "  CTN_EMAIL_TO"
Write-Host "  CTN_EMAIL_FROM"
Write-Host ""
Write-Host "Legacy SMTP variables remain supported only as a fallback trail:"
Write-Host "  CTN_SMTP_HOST"
Write-Host "  CTN_SMTP_PORT"
Write-Host "  CTN_SMTP_USERNAME"
Write-Host "  CTN_SMTP_PASSWORD"
Write-Host "  CTN_SMTP_USE_SSL"
