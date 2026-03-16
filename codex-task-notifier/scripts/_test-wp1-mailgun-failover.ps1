# WP1 Test 2 - Failover test: Resend disabled, Mailgun as fallback
# Simulates a scenario where Resend is unavailable

$root = Split-Path -Parent $PSScriptRoot

. (Join-Path $root "lib\Get-NotifierPaths.ps1")
. (Join-Path $root "lib\Get-NotifierSettings.ps1")
. (Join-Path $root "lib\Get-EnvironmentValue.ps1")
. (Join-Path $root "lib\Write-NotifierLog.ps1")
. (Join-Path $root "lib\Get-NotificationMessage.ps1")
. (Join-Path $root "lib\Send-ResendNotification.ps1")
. (Join-Path $root "lib\Send-MailgunNotification.ps1")
. (Join-Path $root "lib\Send-SmtpNotification.ps1")
. (Join-Path $root "lib\Send-NotificationWithFailover.ps1")

$settings = Get-NotifierSettings

# Disable Resend to force failover to Mailgun
$settings.providers.resend.enabled = $false
Write-Host "=== WP1 TEST 2: Failover Test (Resend disabled -> Mailgun) ==="
Write-Host ("provider_order : " + ($settings.provider_order -join " -> "))
Write-Host ("resend.enabled : " + $settings.providers.resend.enabled)
Write-Host ("mailgun.enabled: " + $settings.providers.mailgun.enabled)
Write-Host ""

$envelope = [pscustomobject]@{
    event_type     = "task.completed"
    session_id     = "wp1-failover-test-" + [guid]::NewGuid().ToString("N").Substring(0,8)
    thread_id      = "wp1-failover-thread-01"
    turn_id        = "wp1-failover-turn-01"
    project        = "codex-task-notifier"
    final_outcome  = "success"
    relevant       = $true
    task_title     = "WP1 Failover Routing Test"
    summary        = "Failover test: Resend disabled, pipeline must route to Mailgun as tier 2."
    agent_name     = "Magneto"
    llm_model      = "Claude Sonnet 4.6"
    owner_name     = "Jimmy"
    machine_id     = $env:COMPUTERNAME
    raw_payload    = '{"type":"task.completed"}'
    raw_path       = $null
    captured_at    = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    classifier_reason = "manual_failover_test_wp1"
}

$result = Send-NotificationWithFailover -Envelope $envelope -Settings $settings

Write-Host ("ok          : " + $result.ok)
Write-Host ("provider    : " + $result.provider)
Write-Host ("recipient   : " + $result.recipient)
Write-Host ("sender      : " + $result.sender)
Write-Host ("subject     : " + $result.subject)
Write-Host ("error       : " + $result.error)
Write-Host ""
Write-Host "All attempts across providers:"
foreach ($a in $result.attempts) {
    Write-Host ("  provider=" + $a.provider + " delay_s=" + $a.delay_s + " ok=" + $a.ok + " status_code=" + $a.status_code + " error=" + $a.error + " response_id=" + $a.response_id)
}

Write-Host ""
if ($result.ok -and $result.provider -eq "mailgun") {
    Write-Host "RESULT: PASS - Failover correctly routed to Mailgun"
} elseif ($result.ok) {
    Write-Host "RESULT: PARTIAL - Delivered but not via Mailgun (provider=$($result.provider))"
    exit 1
} else {
    Write-Host "RESULT: FAIL - $($result.error)"
    exit 1
}
