# WP2 - Path resolution validation test
# Verifies that all runtime paths resolve correctly without hardcoded user strings
# Produces a persisted report

$root = Split-Path -Parent $PSScriptRoot

. (Join-Path $root "lib\Get-NotifierPaths.ps1")
. (Join-Path $root "lib\Write-NotifierLog.ps1")
. (Join-Path $root "lib\Get-NotifierSettings.ps1")
. (Join-Path $root "lib\Get-EnvironmentValue.ps1")

$paths = Get-NotifierPaths
New-Item -ItemType Directory -Force -Path $paths.ValidationRoot | Out-Null
$settings = Get-NotifierSettings

Write-Host "=== WP2: Path Resolution Validation ==="
Write-Host ""

$checks = New-Object System.Collections.Generic.List[object]

function Add-Check {
    param([string]$Name, [bool]$Pass, [string]$Resolved, [string]$Reason)
    $script:checks.Add([pscustomobject]@{
        check    = $Name
        pass     = $Pass
        resolved = $Resolved
        reason   = $Reason
    })
    $icon = if ($Pass) { "PASS" } else { "FAIL" }
    Write-Host ("  " + $icon + " " + $Name)
    if ($Resolved) { Write-Host ("       -> " + $Resolved) }
    if (-not $Pass) { Write-Host ("       !! " + $Reason) }
}

# Check 1: RuntimeRoot uses $HOME, not a hardcoded user path
$runtimeContainsHome = $paths.RuntimeRoot.StartsWith($HOME, [System.StringComparison]::OrdinalIgnoreCase)
Add-Check "RuntimeRoot resolves via HOME" $runtimeContainsHome $paths.RuntimeRoot `
    "RuntimeRoot does not start with HOME - may be hardcoded"

# Check 2: RepoRoot is under C:\ai (approved stable base)
$repoUnderAi = $paths.RepoRoot -imatch '^C:\\ai'
Add-Check "RepoRoot is under C:\ai stable base" $repoUnderAi $paths.RepoRoot `
    "RepoRoot is not under C:\ai - unexpected location"

# Check 3: RuntimeRoot does NOT equal RepoRoot (they must be separate)
$rootsSeparated = $paths.RuntimeRoot -ne $paths.RepoRoot
Add-Check "RuntimeRoot and RepoRoot are separate" $rootsSeparated "" `
    "RuntimeRoot and RepoRoot are the same - runtime data would mix with repo"

# Check 4: SettingsPath is under RuntimeRoot
$settingsUnderRuntime = $paths.SettingsPath.StartsWith($paths.RuntimeRoot, [System.StringComparison]::OrdinalIgnoreCase)
Add-Check "SettingsPath is under RuntimeRoot" $settingsUnderRuntime $paths.SettingsPath `
    "SettingsPath is outside RuntimeRoot"

# Check 5: DedupeStorePath is under RuntimeRoot
$dedupeUnderRuntime = $paths.DedupeStorePath.StartsWith($paths.RuntimeRoot, [System.StringComparison]::OrdinalIgnoreCase)
Add-Check "DedupeStorePath is under RuntimeRoot" $dedupeUnderRuntime $paths.DedupeStorePath `
    "DedupeStorePath is outside RuntimeRoot"

# Check 6: RuntimeRoot equals exactly $HOME\.codex-task-notifier (confirming dynamic construction)
$expectedRuntime = Join-Path $HOME ".codex-task-notifier"
$runtimeMatchesExpected = $paths.RuntimeRoot -eq $expectedRuntime
Add-Check "RuntimeRoot matches expected HOME-based path" $runtimeMatchesExpected $paths.RuntimeRoot `
    "RuntimeRoot does not match '$expectedRuntime' - construction may have drifted"

# Check 7: settings.json exists at expected path
$settingsExists = Test-Path $paths.SettingsPath
Add-Check "settings.json exists at SettingsPath" $settingsExists $paths.SettingsPath `
    "settings.json not found - run install-codex-task-notifier.ps1 first"

# Check 8: Mailgun config is fully resolvable at runtime
$mgKey    = Get-EnvironmentValue -Name "CTN_MAILGUN_API_KEY"
$mgDomain = Get-EnvironmentValue -Name "CTN_MAILGUN_DOMAIN" -Default $settings.providers.mailgun.domain
$mgFrom   = Get-EnvironmentValue -Name "CTN_MAILGUN_FROM"   -Default $settings.default_sender
$mailgunReady = (-not [string]::IsNullOrWhiteSpace($mgKey)) -and
               (-not [string]::IsNullOrWhiteSpace($mgDomain)) -and
               (-not [string]::IsNullOrWhiteSpace($mgFrom))
Add-Check "Mailgun runtime config is fully resolvable" $mailgunReady "" `
    "One or more Mailgun env vars are missing"

$passed = @($checks | Where-Object { $_.pass }).Count
$failed = @($checks | Where-Object { -not $_.pass }).Count

$report = [pscustomobject]@{
    captured_at_local = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    machine           = $env:COMPUTERNAME
    total             = $checks.Count
    passed            = $passed
    failed            = $failed
    checks            = $checks.ToArray()
    verdict           = if ($failed -eq 0) { "PASS" } else { "FAIL" }
}

$reportPath = Write-NotifierLog -Category validation -Payload $report

Write-Host ""
Write-Host ("Result: " + $passed + "/" + $checks.Count + " checks passed")
Write-Host ("Verdict: " + $report.verdict)
Write-Host ("Report saved: " + $reportPath)

if ($failed -gt 0) { exit 1 }
