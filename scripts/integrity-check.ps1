
# integrity-check.ps1 - Hub integrity checks (PowerShell)
# Usage: .\scripts\integrity-check.ps1 [-HubDir <path>]

param(
    [string]$HubDir
)

if (-not $HubDir -or $HubDir.Trim() -eq "") {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $HubDir = (Resolve-Path (Join-Path $ScriptDir ".."))
}

Set-Location $HubDir

$skipDirs = @(".git", ".claude", "scripts", "docs", "extra-executive-docs")
$hubMapPath = Join-Path $HubDir "HUB_MAP.md"
$execPath = Join-Path $HubDir "EXECUTIVE_SUMMARY.md"

function Should-SkipDir([string]$name) {
    if ($name.StartsWith(".")) { return $true }
    if ($skipDirs -contains $name) { return $true }
    return $false
}

function Write-Header([string]$title) {
    Write-Host ("=" * 72) -ForegroundColor DarkGray
    Write-Host $title -ForegroundColor Cyan
    Write-Host ("=" * 72) -ForegroundColor DarkGray
}

function Write-Section([string]$title) {
    Write-Host ("-" * 72) -ForegroundColor DarkGray
    Write-Host $title -ForegroundColor Yellow
    Write-Host ("-" * 72) -ForegroundColor DarkGray
}

Write-Header "HUB INTEGRITY CHECK"
Write-Host ("Running: {0}" -f (Get-Date -Format "yyyy-MM-dd HH:mm"))
Write-Host ""

$totalChecks = 6
$passed = 0
$failed = 0

# Load HUB_MAP skills
$hubMapSkills = @()
if (Test-Path $hubMapPath) {
    $hubMapSkills = Get-Content $hubMapPath | ForEach-Object {
        if ($_ -match '^###\s+\d+\.\s+(.+)$') { $matches[1].Trim() }
    } | Where-Object { $_ }
}
$hubMapSet = @{}
foreach ($s in $hubMapSkills) { $hubMapSet[$s] = $true }

# CHECK 1: Orphaned Directories
Write-Section "CHECK 1: Orphaned Directories"
$orphans = @()
Get-ChildItem -Directory | ForEach-Object {
    if (Should-SkipDir $_.Name) { return }
    if (-not $hubMapSet.ContainsKey($_.Name)) { $orphans += $_.Name }
}
if ($orphans.Count -eq 0) {
    Write-Host "[PASS] All directories documented in HUB_MAP" -ForegroundColor Green
    $passed++
} else {
    $orphans | ForEach-Object { Write-Host ("[ORPHAN] {0}" -f $_) -ForegroundColor Red }
    Write-Host "[FAIL] Add skill to HUB_MAP or remove directory" -ForegroundColor Red
    $failed++
}
Write-Host ""

# CHECK 2: Ghost Skills
Write-Section "CHECK 2: Ghost Skills"
$ghosts = @()
foreach ($skill in $hubMapSkills) {
    $skillDir = Join-Path $HubDir $skill
    if (-not (Test-Path $skillDir -PathType Container)) { $ghosts += $skill }
}
if ($ghosts.Count -eq 0) {
    Write-Host "[PASS] All HUB_MAP skills have directories" -ForegroundColor Green
    $passed++
} else {
    $ghosts | ForEach-Object { Write-Host ("[GHOST] {0}" -f $_) -ForegroundColor Red }
    Write-Host "[FAIL] Remove from HUB_MAP or create directory" -ForegroundColor Red
    $failed++
}
Write-Host ""

# CHECK 3: Loose Root Files
Write-Section "CHECK 3: Loose Root Files"
$approved = @(
    "CHANGELOG.md",
    "COMMANDS.md",
    "CONTRIBUTING.md",
    "DEVELOPER_CHEATSHEET.md",
    "EXECUTIVE_SUMMARY.md",
    "HUB_MAP.md",
    "QUICKSTART_NEW_SKILL.md",
    "README.md",
    "LICENSE",
    "WINDOWS_JUNCTION_SETUP.md",
    ".gitignore",
    "AUDIT_TRAIL.md",
    "CIH-ROADMAP.md",
    "DEVELOPMENT_IMPACT_ANALYSIS.md"
)
$loose = @()
Get-ChildItem -File | ForEach-Object {
    $name = $_.Name
    $isTarget = $false
    if ($name -eq "LICENSE" -or $name -eq ".gitignore" -or $name.EndsWith(".md") -or $name.EndsWith(".txt")) {
        $isTarget = $true
    }
    if ($isTarget -and ($approved -notcontains $name)) { $loose += $name }
}
if ($loose.Count -eq 0) {
    Write-Host "[PASS] No unauthorized files in root" -ForegroundColor Green
    $passed++
} else {
    $loose | ForEach-Object { Write-Host ("[CLUTTER] {0}" -f $_) -ForegroundColor Yellow }
    Write-Host "[FAIL] Move or delete unauthorized root files" -ForegroundColor Red
    $failed++
}
Write-Host ""

# CHECK 4: Version Consistency (EXECUTIVE_SUMMARY vs .metadata)
Write-Section "CHECK 4: Version Consistency"
$execText = ""
if (Test-Path $execPath) { $execText = Get-Content $execPath -Raw }
$versionDrift = @()
Get-ChildItem -Directory | ForEach-Object {
    if (Should-SkipDir $_.Name) { return }
    $metaPath = Join-Path $_.FullName ".metadata"
    if (-not (Test-Path $metaPath)) { return }
    try {
        $meta = Get-Content $metaPath -Raw | ConvertFrom-Json
        $ver = $meta.version
    } catch { return }
    if (-not $ver) { return }
    if ($execText) {
        $skillName = $_.Name
        $skillNameEsc = [regex]::Escape($skillName)
        $skillNameFormatted = ($skillName -replace "-", " ").ToLower().Split(" ") | ForEach-Object { if ($_.Length -gt 0) { $_.Substring(0,1).ToUpper() + $_.Substring(1) } }
        $skillNameFormatted = ($skillNameFormatted -join " ")
        $skillNameFormattedEsc = [regex]::Escape($skillNameFormatted)
        $pattern = "(?i)${skillNameEsc}.*${ver}|${skillNameFormattedEsc}.*${ver}"
        if ($execText -notmatch $pattern) { $versionDrift += $skillName }
    }
}
if ($versionDrift.Count -eq 0) {
    Write-Host "[PASS] Versions consistent across .metadata and EXECUTIVE_SUMMARY" -ForegroundColor Green
    $passed++
} else {
    $versionDrift | ForEach-Object { Write-Host ("[DRIFT] {0}" -f $_) -ForegroundColor Yellow }
    Write-Host "[FAIL] Update EXECUTIVE_SUMMARY.md with current versions" -ForegroundColor Red
    $failed++
}
Write-Host ""

# CHECK 5: SKILL.md Existence
Write-Section "CHECK 5: SKILL.md Existence"
$missingSkillMd = @()
Get-ChildItem -Directory | ForEach-Object {
    if (Should-SkipDir $_.Name) { return }
    $skillMdPath = Join-Path $_.FullName "SKILL.md"
    if (-not (Test-Path $skillMdPath)) { $missingSkillMd += $_.Name }
}
if ($missingSkillMd.Count -eq 0) {
    Write-Host "[PASS] All skills have SKILL.md" -ForegroundColor Green
    $passed++
} else {
    $missingSkillMd | ForEach-Object { Write-Host ("[MISSING] {0}" -f $_) -ForegroundColor Red }
    Write-Host "[FAIL] Create SKILL.md or remove skill" -ForegroundColor Red
    $failed++
}
Write-Host ""

# CHECK 6: Version Synchronization
Write-Section "CHECK 6: Version Synchronization"
$versionSyncIssues = @()
Get-ChildItem -Directory | ForEach-Object {
    if (Should-SkipDir $_.Name) { return }
    $skillName = $_.Name
    $metaPath = Join-Path $_.FullName ".metadata"
    $skillMdPath = Join-Path $_.FullName "SKILL.md"
    if (-not (Test-Path $metaPath) -or -not (Test-Path $skillMdPath)) { return }

    try {
        $meta = Get-Content $metaPath -Raw | ConvertFrom-Json
        $metaVer = $meta.version
    } catch { return }
    if (-not $metaVer) { return }

    $skillMdVer = $null
    $skillMdLine = Get-Content $skillMdPath | Where-Object { $_ -match '^\*\*Version:\*\*' } | Select-Object -First 1
    if ($skillMdLine -match '^\*\*Version:\*\*\s*([0-9\.]+)') { $skillMdVer = $matches[1] }

    $hubmapVer = $null
    if (Test-Path $hubMapPath) {
        $hubLine = Get-Content $hubMapPath | Where-Object { $_ -match [regex]::Escape($skillName) } | Select-Object -First 1
        if ($hubLine -match 'v([0-9]+\.[0-9]+\.[0-9]+)') { $hubmapVer = $matches[1] }
    }

    $drift = $false
    if ($skillMdVer -and ($metaVer -ne $skillMdVer)) { $drift = $true }
    if ($hubmapVer -and ($metaVer -ne $hubmapVer)) { $drift = $true }

    if ($drift) { $versionSyncIssues += $skillName }
}
if ($versionSyncIssues.Count -eq 0) {
    Write-Host "[PASS] Versions synchronized across .metadata, SKILL.md, HUB_MAP.md" -ForegroundColor Green
    $passed++
} else {
    $versionSyncIssues | ForEach-Object { Write-Host ("[DRIFT] {0}" -f $_) -ForegroundColor Red }
    Write-Host "[FAIL] Run sync-versions.ps1 <skill-name>" -ForegroundColor Red
    $failed++
}
Write-Host ""

# SUMMARY
Write-Section "SUMMARY"
Write-Host ("Total Checks: {0}" -f $totalChecks)
Write-Host ("Passed: {0}" -f $passed) -ForegroundColor Green
if ($failed -gt 0) {
    Write-Host ("Failed: {0}" -f $failed) -ForegroundColor Red
    exit 1
} else {
    Write-Host "Failed: 0"
    Write-Host "Hub integrity verified - all checks passed" -ForegroundColor Green
    exit 0
}
