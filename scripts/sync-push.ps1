# sync-push.ps1 - Push local changes to GitHub
# Usage: .\scripts\sync-push.ps1 [-Message "commit message"]

param(
    [string]$Message = "sync: Update from $(hostname) - $(Get-Date -Format 'yyyy-MM-dd HH:mm')",
    [switch]$Status
)

$HubPath = "D:\_git_ws\claude-intelligence-hub"
$GitPath = "C:\Program Files\Git\bin\git.exe"

Write-Host "[SYNC] Pushing to GitHub..." -ForegroundColor Cyan

if (-not (Test-Path $HubPath)) {
    Write-Host "[ERROR] Hub not found at: $HubPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $GitPath)) {
    Write-Host "[ERROR] Git not found at: $GitPath" -ForegroundColor Red
    exit 1
}

Set-Location $HubPath

# Check if there are changes
Write-Host "[CHECK] Looking for changes..." -ForegroundColor Yellow
& $GitPath status --short

$changes = & $GitPath status --short
if (-not $changes) {
    Write-Host "[INFO] No changes to push. Working tree is clean." -ForegroundColor Green
    exit 0
}

# Add all changes
Write-Host "[ADD] Staging changes..." -ForegroundColor Yellow
& $GitPath add -A

# Commit
Write-Host "[COMMIT] Saving with message: $Message" -ForegroundColor Yellow
& $GitPath commit -m $Message

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Commit failed!" -ForegroundColor Red
    exit 1
}

# Push
Write-Host "[PUSH] Uploading to GitHub..." -ForegroundColor Yellow
& $GitPath push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] Changes pushed to GitHub!" -ForegroundColor Green

    if ($Status) {
        Write-Host "`n[STATUS] Current status:" -ForegroundColor Cyan
        & $GitPath status
    }
} else {
    Write-Host "[ERROR] Push failed! Check errors above." -ForegroundColor Red
    exit 1
}
