# WP1 - Update runtime settings.json with Mailgun domain
$settingsPath = Join-Path $HOME ".codex-task-notifier\config\settings.json"

if (-not (Test-Path $settingsPath)) {
    Write-Host "settings.json not found at: $settingsPath"
    exit 1
}

$json = Get-Content $settingsPath -Raw | ConvertFrom-Json
$json.providers.mailgun.domain = 'mg.mrjimmyny.org'
$json | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Encoding UTF8

Write-Host "Updated settings.json:"
Write-Host ("  mailgun.domain   : " + $json.providers.mailgun.domain)
Write-Host ("  mailgun.base_url : " + $json.providers.mailgun.base_url)
Write-Host ("  mailgun.enabled  : " + $json.providers.mailgun.enabled)
