# sync-skills-global.ps1
# Automatically sync all skills from claude-intelligence-hub to global ~/.claude/skills/
# Usage: .\sync-skills-global.ps1

$ErrorActionPreference = "Stop"

# Directories
$RepoRoot = "C:\ai\claude-intelligence-hub"
$SkillsDir = "$env:USERPROFILE\.claude\skills"

Write-Host "`n🔄 Syncing skills to global directory...`n" -ForegroundColor Blue

# Create skills directory if it doesn't exist
if (-not (Test-Path $SkillsDir)) {
    New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
}

# Counters
$newCount = 0
$existingCount = 0
$updatedCount = 0

# Find all SKILL.md files
$skillFiles = Get-ChildItem -Path $RepoRoot -Filter "SKILL.md" -Recurse -File |
    Where-Object { $_.FullName -notlike "*\playbook\*" }

foreach ($skillFile in $skillFiles) {
    $skillDir = $skillFile.Directory.FullName
    $skillName = $skillFile.Directory.Name
    $target = Join-Path $SkillsDir $skillName

    # Check if junction/symlink already exists
    if (Test-Path $target) {
        $item = Get-Item $target
        if ($item.LinkType -eq "Junction" -or $item.LinkType -eq "SymbolicLink") {
            $currentTarget = $item.Target[0]
            if ($currentTarget -eq $skillDir) {
                Write-Host "✓ $skillName (already linked)" -ForegroundColor Green
                $existingCount++
            } else {
                # Update link
                Remove-Item $target -Force
                New-Item -ItemType Junction -Path $target -Target $skillDir | Out-Null
                Write-Host "↻ $skillName (updated link)" -ForegroundColor Yellow
                $updatedCount++
            }
        } else {
            Write-Host "⚠  $skillName (exists but not a junction - skipping)" -ForegroundColor Yellow
        }
    } else {
        # Create new junction
        New-Item -ItemType Junction -Path $target -Target $skillDir | Out-Null
        Write-Host "✓ $skillName (new)" -ForegroundColor Green
        $newCount++
    }
}

# Summary
$total = $newCount + $existingCount + $updatedCount
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host "✅ Sync complete!" -ForegroundColor Green
Write-Host "   New skills:      $newCount"
Write-Host "   Existing skills: $existingCount"
Write-Host "   Updated links:   $updatedCount"
Write-Host "   Total skills:    $total"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host "`n📝 Note: Restart Claude Code to load new skills" -ForegroundColor Yellow
