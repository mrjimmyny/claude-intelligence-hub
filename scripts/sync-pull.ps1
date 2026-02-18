# sync-pull.ps1 - Pull latest changes from GitHub
# Usage: .\scripts\sync-pull.ps1

param(
    [switch]$Verbose
)

$HubPath = "D:\_git_ws\claude-intelligence-hub"
$GitPath = "C:\Program Files\Git\bin\git.exe"

Write-Host "[SYNC] Pulling from GitHub..." -ForegroundColor Cyan

if (-not (Test-Path $HubPath)) {
    Write-Host "[ERROR] Hub not found at: $HubPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $GitPath)) {
    Write-Host "[ERROR] Git not found at: $GitPath" -ForegroundColor Red
    exit 1
}

Set-Location $HubPath

Write-Host "[PULL] Downloading changes..." -ForegroundColor Yellow
& $GitPath pull origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCCESS] Hub is up to date!" -ForegroundColor Green

    if ($Verbose) {
        Write-Host "`n[STATUS] Current status:" -ForegroundColor Cyan
        & $GitPath status
    }
} else {
    Write-Host "[ERROR] Sync failed! Check errors above." -ForegroundColor Red
    exit 1
}
