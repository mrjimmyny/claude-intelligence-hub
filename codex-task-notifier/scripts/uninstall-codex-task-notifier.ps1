[CmdletBinding()]
param()

$codexConfig = Join-Path (Join-Path $HOME ".codex") "config.toml"
if (-not (Test-Path $codexConfig)) {
    Write-Host "Codex config not found."
    return
}

$content = Get-Content -Raw $codexConfig
$updated = [regex]::Replace($content, '(?ms)\r?\n?# codex-task-notifier:start.*?# codex-task-notifier:end\r?\n?', "`r`n")
if ($updated -ne $content) {
    $updated | Set-Content -Path $codexConfig -Encoding UTF8
    Write-Host "Notify hook removed from $codexConfig"
} else {
    Write-Host "Notify hook markers not found."
}
