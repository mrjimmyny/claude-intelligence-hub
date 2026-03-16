[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RawArguments
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

. (Join-Path $root "lib\\Get-NotifierPaths.ps1")
. (Join-Path $root "lib\\Get-NotifierSettings.ps1")
. (Join-Path $root "lib\\Get-EnvironmentValue.ps1")
. (Join-Path $root "lib\\Write-NotifierLog.ps1")
. (Join-Path $root "lib\\Read-NotifyPayload.ps1")
. (Join-Path $root "lib\\Normalize-NotifyPayload.ps1")
. (Join-Path $root "lib\\Test-CompletionEvent.ps1")
. (Join-Path $root "lib\\Get-DedupeKey.ps1")
. (Join-Path $root "lib\\Get-NotificationMessage.ps1")
. (Join-Path $root "lib\\Send-SmtpNotification.ps1")
. (Join-Path $root "lib\\Send-ResendNotification.ps1")
. (Join-Path $root "lib\\Send-MailgunNotification.ps1")
. (Join-Path $root "lib\\Send-NotificationWithFailover.ps1")

function Get-DedupeStore {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return @() }
    $content = Get-Content -Raw $Path
    if ([string]::IsNullOrWhiteSpace($content)) { return @() }
    $parsed = $content | ConvertFrom-Json
    if ($parsed -is [System.Array]) { return $parsed }
    return @($parsed)
}

function Save-DedupeStore {
    param([string]$Path, [object[]]$Entries)
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Path) | Out-Null
    $Entries | ConvertTo-Json -Depth 20 | Set-Content -Path $Path -Encoding UTF8
}

try {
    $paths = Get-NotifierPaths
    New-Item -ItemType Directory -Force -Path $paths.ConfigRoot, $paths.RawLogsRoot, $paths.NormalizedRoot, $paths.DeliveryRoot, $paths.ValidationRoot, $paths.StateRoot | Out-Null
    $settings = Get-NotifierSettings
    if (-not $settings.enabled) { exit 0 }

    $payloadInput = Read-NotifyPayload -RawArguments $RawArguments
    if (-not $payloadInput.RawPayload) {
        Write-NotifierLog -Category delivery -Payload ([pscustomobject]@{
            captured_at_local = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            status            = "skipped"
            reason            = "no_payload_received"
        }) | Out-Null
        exit 0
    }

    $rawPath = Write-NotifierLog -Category raw -Payload $payloadInput.RawPayload
    $envelope = Normalize-NotifyPayload -RawPayload $payloadInput.RawPayload -RawPayloadPath $rawPath -Settings $settings
    $envelope = Test-CompletionEvent -Envelope $envelope
    $normalizedPath = Write-NotifierLog -Category normalized -Payload $envelope

    if (-not $envelope.relevant) {
        Write-NotifierLog -Category delivery -Payload ([pscustomobject]@{
            captured_at_local = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            status            = "skipped"
            reason            = $envelope.classifier_reason
            normalized_path   = $normalizedPath
            raw_payload_path  = $rawPath
        }) | Out-Null
        exit 0
    }

    $dedupeKey = Get-DedupeKey -Envelope $envelope
    $store = @(Get-DedupeStore -Path $paths.DedupeStorePath)
    if ($store | Where-Object { $_.dedupe_key -eq $dedupeKey } | Select-Object -First 1) {
        Write-NotifierLog -Category delivery -Payload ([pscustomobject]@{
            captured_at_local = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            status            = "skipped"
            reason            = "duplicate_event"
            dedupe_key        = $dedupeKey
            normalized_path   = $normalizedPath
            raw_payload_path  = $rawPath
        }) | Out-Null
        exit 0
    }

    $sendResult = Send-NotificationWithFailover -Envelope $envelope -Settings $settings
    Write-NotifierLog -Category delivery -Payload ([pscustomobject]@{
        captured_at_local = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        status            = if ($sendResult.ok) { "sent" } else { "failed" }
        channel           = $settings.channel
        provider          = $sendResult.provider
        dedupe_key        = $dedupeKey
        final_outcome     = $envelope.final_outcome
        subject           = $sendResult.subject
        recipient         = $sendResult.recipient
        sender            = $sendResult.sender
        attempts          = $sendResult.attempts
        error             = $sendResult.error
        normalized_path   = $normalizedPath
        raw_payload_path  = $rawPath
    }) | Out-Null

    if ($sendResult.ok) {
        $store += [pscustomobject]@{
            dedupe_key    = $dedupeKey
            first_sent_at = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            email_subject = $sendResult.subject
            delivery      = "sent"
            outcome       = $envelope.final_outcome
            provider      = $sendResult.provider
        }
        Save-DedupeStore -Path $paths.DedupeStorePath -Entries $store
    }

    exit 0
} catch {
    try {
        Write-NotifierLog -Category delivery -Payload ([pscustomobject]@{
            captured_at_local = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            status            = "runtime_error"
            error             = $_.Exception.Message
        }) | Out-Null
    } catch {
    }
    exit 0
}
