$runtimeRoot = Join-Path $HOME ".codex-task-notifier"
$settingsPath = Join-Path $runtimeRoot "config\settings.json"
Write-Host ("RuntimeRoot: " + $runtimeRoot)
Write-Host ("SettingsPath: " + $settingsPath)
if (Test-Path $settingsPath) {
    Write-Host "settings.json: EXISTS"
    Get-Content $settingsPath
} else {
    Write-Host "settings.json: NOT FOUND"
}
