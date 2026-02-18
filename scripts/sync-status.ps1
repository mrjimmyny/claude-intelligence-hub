# sync-status.ps1 - Check git status of the hub
# Usage: .\scripts\sync-status.ps1

$HubPath = "D:\_git_ws\claude-intelligence-hub"
$GitPath = "C:\Program Files\Git\bin\git.exe"

Write-Host "Claude Intelligence Hub - Git Status" -ForegroundColor Cyan
Write-Host "======================================`n" -ForegroundColor Cyan

if (-not (Test-Path $HubPath)) {
    Write-Host "[ERROR] Hub not found at: $HubPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $GitPath)) {
    Write-Host "[ERROR] Git not found at: $GitPath" -ForegroundColor Red
    exit 1
}

Set-Location $HubPath

# Current branch and remote status
Write-Host "[BRANCH] Current branch:" -ForegroundColor Yellow
& $GitPath status -sb

Write-Host "`n[WORKING TREE] Local changes:" -ForegroundColor Yellow
& $GitPath status --short

# Last commit
Write-Host "`n[LAST COMMIT]" -ForegroundColor Yellow
& $GitPath log -1 --oneline --decorate

# Check if ahead/behind
Write-Host "`n[REMOTE] Comparison with origin/main:" -ForegroundColor Yellow
& $GitPath fetch origin main 2>$null
$local = & $GitPath rev-parse main
$remote = & $GitPath rev-parse origin/main

if ($local -eq $remote) {
    Write-Host "[OK] Up to date with origin/main" -ForegroundColor Green
} else {
    $ahead = & $GitPath rev-list --count origin/main..main
    $behind = & $GitPath rev-list --count main..origin/main

    if ($ahead -gt 0) {
        Write-Host "[AHEAD] You are $ahead commit(s) ahead of origin/main" -ForegroundColor Yellow
    }
    if ($behind -gt 0) {
        Write-Host "[BEHIND] You are $behind commit(s) behind origin/main" -ForegroundColor Yellow
    }
}
