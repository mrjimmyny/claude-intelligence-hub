# WP1 Test 1 - Direct Mailgun smoke test
# Calls Send-MailgunNotification directly, bypassing Resend

$root = Split-Path -Parent $PSScriptRoot

. (Join-Path $root "lib\Get-NotifierPaths.ps1")
. (Join-Path $root "lib\Get-NotifierSettings.ps1")
. (Join-Path $root "lib\Get-EnvironmentValue.ps1")
. (Join-Path $root "lib\Write-NotifierLog.ps1")
. (Join-Path $root "lib\Get-NotificationMessage.ps1")
. (Join-Path $root "lib\Send-MailgunNotification.ps1")

$settings = Get-NotifierSettings

$envelope = [pscustomobject]@{
    event_type     = "task.completed"
    session_id     = "wp1-mailgun-test-" + [guid]::NewGuid().ToString("N").Substring(0,8)
    thread_id      = "wp1-thread-01"
    turn_id        = "wp1-turn-01"
    project        = "codex-task-notifier"
    final_outcome  = "success"
    relevant       = $true
    task_title     = "WP1 Mailgun Direct Smoke Test"
    summary        = "Direct test of Mailgun adapter for WP1 validation. Provider order bypassed."
    agent_name     = "Magneto"
    llm_model      = "Claude Sonnet 4.6"
    owner_name     = "Jimmy"
    machine_id     = $env:COMPUTERNAME
    raw_payload    = '{"type":"task.completed"}'
    raw_path       = $null
    captured_at    = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    classifier_reason = "manual_test_wp1"
}

Write-Host "=== WP1 TEST 1: Direct Mailgun Smoke Test ==="
Write-Host ("Sender  : " + [System.Environment]::GetEnvironmentVariable('CTN_MAILGUN_FROM','User'))
Write-Host ("Domain  : " + [System.Environment]::GetEnvironmentVariable('CTN_MAILGUN_DOMAIN','User'))
Write-Host ("BaseURL : " + $settings.providers.mailgun.base_url)
Write-Host ""

$result = Send-MailgunNotification -Envelope $envelope -Settings $settings

Write-Host ("ok          : " + $result.ok)
Write-Host ("provider    : " + $result.provider)
Write-Host ("recipient   : " + $result.recipient)
Write-Host ("sender      : " + $result.sender)
Write-Host ("subject     : " + $result.subject)
Write-Host ("error       : " + $result.error)
Write-Host ""
Write-Host "Attempts:"
foreach ($a in $result.attempts) {
    Write-Host ("  delay_s=" + $a.delay_s + " ok=" + $a.ok + " status_code=" + $a.status_code + " error=" + $a.error + " response_id=" + $a.response_id)
}

Write-Host ""
if ($result.ok) {
    Write-Host "RESULT: PASS - Mailgun delivered successfully"
} else {
    Write-Host "RESULT: FAIL - $($result.error)"
    exit 1
}
