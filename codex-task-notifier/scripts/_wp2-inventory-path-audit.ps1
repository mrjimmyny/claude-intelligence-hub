# WP2 - Path dependency inventory and audit
# Scans the workspace for hardcoded user/host paths and documents findings
# Produces a persisted JSON report in the validation logs

$root = Split-Path -Parent $PSScriptRoot

. (Join-Path $root "lib\Get-NotifierPaths.ps1")
. (Join-Path $root "lib\Write-NotifierLog.ps1")

$paths = Get-NotifierPaths
New-Item -ItemType Directory -Force -Path $paths.ValidationRoot | Out-Null

Write-Host "=== WP2: Path Dependency Inventory ==="
Write-Host ("RepoRoot   : " + $root)
Write-Host ("RuntimeRoot: " + $paths.RuntimeRoot)
Write-Host ""

# Pattern: user-specific paths that would break on a different machine
$dangerPatterns = @(
    'C:\\Users\\',
    '%USERPROFILE%',
    '\$env:USERPROFILE',
    # 'jaderson',  # Removed — use $env:USERNAME dynamically
    'GLOBALSERVS',
    'globalservs'
)

# Pattern: C:\ai is approved stable base - not a finding
$approvedBasePattern = 'C:\\ai'

$scanRoot = $root
$findings = New-Object System.Collections.Generic.List[object]

$files = Get-ChildItem -Path $scanRoot -Recurse -File -Include '*.ps1','*.py','*.json','*.md','*.txt','*.toml' |
    Where-Object { $_.FullName -notmatch '__pycache__' } |
    Where-Object { $_.Name -notmatch '^_wp2-' }

foreach ($file in $files) {
    $lines = Get-Content -Path $file.FullName -Encoding UTF8 -ErrorAction SilentlyContinue
    if (-not $lines) { continue }

    $lineNum = 0
    foreach ($line in $lines) {
        $lineNum++
        foreach ($pattern in $dangerPatterns) {
            if ($line -imatch [regex]::Escape($pattern)) {
                $findings.Add([pscustomobject]@{
                    file    = $file.FullName.Replace($root + '\', '')
                    line    = $lineNum
                    pattern = $pattern
                    content = $line.Trim()
                    verdict = "HARDCODED_USER_PATH"
                })
            }
        }
    }
}

# Check runtime path resolution
$resolvedPaths = [ordered]@{
    RuntimeRoot     = $paths.RuntimeRoot
    ConfigRoot      = $paths.ConfigRoot
    LogsRoot        = $paths.LogsRoot
    SettingsPath    = $paths.SettingsPath
    DedupeStorePath = $paths.DedupeStorePath
    RepoRoot        = $paths.RepoRoot
}

$pathChecks = New-Object System.Collections.Generic.List[object]
foreach ($name in $resolvedPaths.Keys) {
    $resolved = $resolvedPaths[$name]
    $containsUserProfile = $resolved -imatch 'C:\\Users\\'
    $containsHome = $resolved -imatch [regex]::Escape($HOME)
    $containsAi = $resolved -imatch 'C:\\ai'
    $dynamic = $containsHome -or $containsAi

    $pathChecks.Add([pscustomobject]@{
        name          = $name
        resolved      = $resolved
        dynamic       = $dynamic
        via_home      = $containsHome
        via_stable_ai = $containsAi
        verdict       = if ($dynamic) { "OK" } else { "INVESTIGATE" }
    })
}

$report = [pscustomobject]@{
    captured_at_local     = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    machine               = $env:COMPUTERNAME
    scan_root             = $root
    dangerous_findings    = $findings.ToArray()
    dangerous_count       = $findings.Count
    path_resolution_checks = $pathChecks.ToArray()
    verdict               = if ($findings.Count -eq 0) { "CLEAN" } else { "FINDINGS_REQUIRE_ACTION" }
    note                  = "C:\ai is the approved stable base path. $HOME-based paths are dynamic. Only patterns indicating hardcoded usernames or %USERPROFILE% are flagged."
}

$reportPath = Write-NotifierLog -Category validation -Payload $report

Write-Host "Dangerous path findings: $($findings.Count)"
if ($findings.Count -gt 0) {
    foreach ($f in $findings) {
        Write-Host ("  FINDING: " + $f.file + ":" + $f.line + " [" + $f.pattern + "] -> " + $f.content)
    }
} else {
    Write-Host "  No hardcoded user/host paths found."
}

Write-Host ""
Write-Host "Path resolution checks:"
foreach ($c in $pathChecks) {
    Write-Host ("  " + $c.verdict + " " + $c.name + " -> " + $c.resolved)
}

Write-Host ""
Write-Host ("Verdict: " + $report.verdict)
Write-Host ("Report saved: " + $reportPath)
