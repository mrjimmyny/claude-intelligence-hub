function Send-SmtpNotification {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Envelope,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$Settings
    )

    $notification = Get-NotificationMessage -Envelope $Envelope -Settings $Settings
    $smtpHost = Get-EnvironmentValue -Name "CTN_SMTP_HOST"
    $smtpPortValue = Get-EnvironmentValue -Name "CTN_SMTP_PORT"
    $smtpPort = if ($smtpPortValue) { [int]$smtpPortValue } else { 587 }
    $smtpUser = Get-EnvironmentValue -Name "CTN_SMTP_USERNAME"
    $smtpPass = Get-EnvironmentValue -Name "CTN_SMTP_PASSWORD"
    if ($smtpPass) { $smtpPass = ($smtpPass -replace '\s', '') }
    $recipient = $notification.recipient
    $primarySender = $notification.primary_sender
    $fallbackSender = $notification.fallback_sender
    $useSslValue = Get-EnvironmentValue -Name "CTN_SMTP_USE_SSL"
    $useSsl = if ($useSslValue) { [System.Convert]::ToBoolean($useSslValue) } else { $true }

    if (-not $Settings.providers.smtp.enabled) {
        return [pscustomobject]@{
            ok        = $false
            provider  = "smtp"
            subject   = $notification.subject
            body      = $notification.body
            recipient = $recipient
            sender    = $primarySender
            attempts  = @([pscustomobject]@{
                provider    = "smtp"
                sender      = $primarySender
                delay_s     = 0
                ok          = $false
                status_code = $null
                error       = "smtp_provider_disabled"
                response_id = $null
            })
            error     = "smtp_provider_disabled"
        }
    }

    if ([string]::IsNullOrWhiteSpace($smtpHost) -or [string]::IsNullOrWhiteSpace($recipient) -or [string]::IsNullOrWhiteSpace($primarySender)) {
        return [pscustomobject]@{
            ok        = $false
            provider  = "smtp"
            subject   = $notification.subject
            body      = $notification.body
            recipient = $recipient
            sender    = $primarySender
            attempts  = @([pscustomobject]@{
                provider    = "smtp"
                sender      = $primarySender
                delay_s     = 0
                ok          = $false
                status_code = $null
                error       = "smtp_configuration_incomplete"
                response_id = $null
            })
            error     = "smtp_configuration_incomplete"
        }
    }

    $senders = @($primarySender)
    if ($fallbackSender -and $fallbackSender -ne $primarySender) {
        $senders += $fallbackSender
    }

    $attempts = New-Object System.Collections.Generic.List[object]
    foreach ($sender in $senders) {
        foreach ($delay in $Settings.smtp_retry_delays_seconds) {
            if ([int]$delay -gt 0) { Start-Sleep -Seconds ([int]$delay) }

            $attempt = [ordered]@{
                provider    = "smtp"
                sender      = $sender
                delay_s     = [int]$delay
                ok          = $false
                status_code = $null
                error       = $null
                response_id = $null
            }

            try {
                $mailMessage = New-Object System.Net.Mail.MailMessage
                $mailMessage.From = $sender
                $mailMessage.To.Add($recipient)
                $mailMessage.Subject = $notification.subject
                $mailMessage.Body = $notification.body
                $mailMessage.IsBodyHtml = $false

                $client = New-Object System.Net.Mail.SmtpClient($smtpHost, $smtpPort)
                $client.EnableSsl = $useSsl
                $client.Timeout = 15000
                $client.UseDefaultCredentials = $false
                if ($smtpUser -and $smtpPass) {
                    $secure = ConvertTo-SecureString $smtpPass -AsPlainText -Force
                    $credential = New-Object System.Management.Automation.PSCredential($smtpUser, $secure)
                    $client.Credentials = $credential.GetNetworkCredential()
                }

                $client.Send($mailMessage)
                $attempt.ok = $true
                $attempts.Add([pscustomobject]$attempt)
                return [pscustomobject]@{
                    ok        = $true
                    provider  = "smtp"
                    subject   = $notification.subject
                    body      = $notification.body
                    recipient = $recipient
                    sender    = $sender
                    attempts  = $attempts.ToArray()
                    error     = $null
                }
            } catch {
                $attempt.error = $_.Exception.Message
                $attempts.Add([pscustomobject]$attempt)
            } finally {
                if ($mailMessage) { $mailMessage.Dispose() }
                if ($client) { $client.Dispose() }
            }
        }
    }

    return [pscustomobject]@{
        ok        = $false
        provider  = "smtp"
        subject   = $notification.subject
        body      = $notification.body
        recipient = $recipient
        sender    = $primarySender
        attempts  = $attempts.ToArray()
        error     = if ($attempts.Count -gt 0) { $attempts[$attempts.Count - 1].error } else { "smtp_delivery_failed" }
    }
}
