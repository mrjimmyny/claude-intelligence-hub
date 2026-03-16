[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

. (Join-Path $root "lib\\Get-NotifierPaths.ps1")
. (Join-Path $root "lib\\Get-NotifierSettings.ps1")
. (Join-Path $root "lib\\Get-EnvironmentValue.ps1")
. (Join-Path $root "lib\\Write-NotifierLog.ps1")
. (Join-Path $root "lib\\Normalize-NotifyPayload.ps1")
. (Join-Path $root "lib\\Test-CompletionEvent.ps1")
. (Join-Path $root "lib\\Get-DedupeKey.ps1")

$paths = Get-NotifierPaths
New-Item -ItemType Directory -Force -Path $paths.ConfigRoot, $paths.ValidationRoot | Out-Null
if (-not (Test-Path $paths.SettingsPath)) {
    Copy-Item (Join-Path $root "config\\settings.example.json") $paths.SettingsPath
}
$settings = Get-NotifierSettings

$cases = [ordered]@{
    T03_intermediate = Join-Path $root "fixtures\\intermediate.json"
    T04_success      = Join-Path $root "fixtures\\success.json"
    T05_failure      = Join-Path $root "fixtures\\failure.json"
}

$results = New-Object System.Collections.Generic.List[object]
foreach ($name in $cases.Keys) {
    $raw = Get-Content -Raw $cases[$name]
    $rawPath = Write-NotifierLog -Category validation -Payload $raw
    $envelope = Normalize-NotifyPayload -RawPayload $raw -RawPayloadPath $rawPath -Settings $settings
    $classified = Test-CompletionEvent -Envelope $envelope
    $results.Add([pscustomobject]@{
        case_name         = $name
        event_type        = $classified.event_type
        project           = $classified.project
        final_outcome     = $classified.final_outcome
        relevant          = $classified.relevant
        dedupe_key        = Get-DedupeKey -Envelope $classified
        classifier_reason = $classified.classifier_reason
        pass              = switch ($name) {
            "T03_intermediate" { -not $classified.relevant }
            "T04_success"      { $classified.relevant -and $classified.final_outcome -eq "success" }
            "T05_failure"      { $classified.relevant -and $classified.final_outcome -eq "failure" }
        }
    })
}

$report = [pscustomobject]@{
    captured_at_local = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    total             = $results.Count
    passed            = @($results | Where-Object { $_.pass }).Count
    failed            = @($results | Where-Object { -not $_.pass }).Count
    transport         = [pscustomobject]@{
        channel        = $settings.channel
        provider_order = $settings.provider_order
        resend_ready   = $settings.providers.resend.enabled -and (-not [string]::IsNullOrWhiteSpace((Get-EnvironmentValue -Name "CTN_RESEND_API_KEY"))) -and (-not [string]::IsNullOrWhiteSpace((Get-EnvironmentValue -Name "CTN_RESEND_FROM" -Default $settings.default_sender)))
        mailgun_ready  = $settings.providers.mailgun.enabled -and (-not [string]::IsNullOrWhiteSpace((Get-EnvironmentValue -Name "CTN_MAILGUN_API_KEY"))) -and (-not [string]::IsNullOrWhiteSpace((Get-EnvironmentValue -Name "CTN_MAILGUN_DOMAIN" -Default $settings.providers.mailgun.domain))) -and (-not [string]::IsNullOrWhiteSpace((Get-EnvironmentValue -Name "CTN_MAILGUN_FROM" -Default $settings.default_sender)))
        smtp_ready     = $settings.providers.smtp.enabled -and (-not [string]::IsNullOrWhiteSpace((Get-EnvironmentValue -Name "CTN_SMTP_HOST"))) -and (-not [string]::IsNullOrWhiteSpace((Get-EnvironmentValue -Name "CTN_SMTP_PASSWORD")))
    }
    results           = $results
    note              = "Classification and dedupe validation executed. HTTPS transport now expects provider credentials for Resend and/or Mailgun; SMTP remains legacy fallback."
}

$reportPath = Write-NotifierLog -Category validation -Payload $report
$report | ConvertTo-Json -Depth 20
Write-Host ""
Write-Host "Validation report: $reportPath"
