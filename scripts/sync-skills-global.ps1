# sync-skills-global.ps1
# Sync all skills from claude-intelligence-hub to global ~/.claude/skills/
# Usage: .\sync-skills-global.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = "C:\ai\claude-intelligence-hub"
$SkillsDir = "$env:USERPROFILE\.claude\skills"

Write-Host ""
Write-Host "[INFO] Syncing skills to global directory..." -ForegroundColor Blue
Write-Host ""

if (-not (Test-Path $SkillsDir)) {
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}

$newCount = 0
$existingCount = 0
$updatedCount = 0
$skippedCount = 0

$skillFiles = Get-ChildItem -Path $RepoRoot -Filter "SKILL.md" -Recurse -File |
    Where-Object { $_.FullName -notlike "*\playbook\*" }

foreach ($skillFile in $skillFiles) {
    $skillDir = $skillFile.Directory.FullName
    $skillName = $skillFile.Directory.Name
    $target = Join-Path $SkillsDir $skillName

    if (Test-Path $target) {
        $item = Get-Item $target
        if ($item.LinkType -eq "Junction" -or $item.LinkType -eq "SymbolicLink") {
            $currentTarget = $item.Target[0]
            if ($currentTarget -eq $skillDir) {
                Write-Host "[OK] $skillName (already linked)" -ForegroundColor Green
                $existingCount++
            } else {
                Remove-Item $target -Force
                New-Item -ItemType Junction -Path $target -Target $skillDir | Out-Null
                Write-Host "[UPDATE] $skillName (link updated)" -ForegroundColor Yellow
                $updatedCount++
            }
        } else {
            Write-Host "[SKIP] $skillName (exists but is not a link)" -ForegroundColor Yellow
            $skippedCount++
        }
    } else {
        New-Item -ItemType Junction -Path $target -Target $skillDir | Out-Null
        Write-Host "[NEW] $skillName" -ForegroundColor Green
        $newCount++
    }
}

$total = $newCount + $existingCount + $updatedCount + $skippedCount

Write-Host ""
Write-Host "----------------------------------------" -ForegroundColor Blue
Write-Host "[DONE] Sync complete" -ForegroundColor Green
Write-Host "  New links:      $newCount"
Write-Host "  Existing links: $existingCount"
Write-Host "  Updated links:  $updatedCount"
Write-Host "  Skipped:        $skippedCount"
Write-Host "  Total scanned:  $total"
Write-Host "----------------------------------------" -ForegroundColor Blue
Write-Host ""
Write-Host "[NOTE] Restart Claude Code to load new skills." -ForegroundColor Yellow
