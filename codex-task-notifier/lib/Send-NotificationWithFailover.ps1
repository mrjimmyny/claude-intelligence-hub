function Send-NotificationWithFailover {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Envelope,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$Settings
    )

    $channel = if ($Settings.channel) { $Settings.channel.ToLowerInvariant() } else { "https" }

    if ($channel -eq "smtp") {
        return Send-SmtpNotification -Envelope $Envelope -Settings $Settings
    }

    if ($channel -ne "https") {
        return [pscustomobject]@{
            ok        = $false
            provider  = $null
            subject   = $null
            body      = $null
            recipient = $null
            sender    = $null
            attempts  = @()
            error     = "unsupported_channel:$channel"
        }
    }

    $providerOrder = @($Settings.provider_order)
    if ($providerOrder.Count -eq 0) {
        $providerOrder = @("resend", "mailgun")
    }

    $attempts = New-Object System.Collections.Generic.List[object]
    $lastResult = $null

    foreach ($providerName in $providerOrder) {
        $normalizedProvider = "$providerName".Trim().ToLowerInvariant()

        switch ($normalizedProvider) {
            "resend" {
                $result = Send-ResendNotification -Envelope $Envelope -Settings $Settings
            }
            "mailgun" {
                $result = Send-MailgunNotification -Envelope $Envelope -Settings $Settings
            }
            "smtp" {
                $result = Send-SmtpNotification -Envelope $Envelope -Settings $Settings
            }
            default {
                $result = [pscustomobject]@{
                    ok        = $false
                    provider  = $normalizedProvider
                    subject   = $null
                    body      = $null
                    recipient = $null
                    sender    = $null
                    attempts  = @([pscustomobject]@{
                        provider    = $normalizedProvider
                        sender      = $null
                        delay_s     = 0
                        ok          = $false
                        status_code = $null
                        error       = "unsupported_provider"
                        response_id = $null
                    })
                    error     = "unsupported_provider"
                }
            }
        }

        $lastResult = $result
        foreach ($attempt in $result.attempts) {
            $attempts.Add($attempt)
        }

        if ($result.ok) {
            return [pscustomobject]@{
                ok        = $true
                provider  = $result.provider
                subject   = $result.subject
                body      = $result.body
                recipient = $result.recipient
                sender    = $result.sender
                attempts  = $attempts.ToArray()
                error     = $null
            }
        }
    }

    return [pscustomobject]@{
        ok        = $false
        provider  = if ($lastResult) { $lastResult.provider } else { $null }
        subject   = if ($lastResult) { $lastResult.subject } else { $null }
        body      = if ($lastResult) { $lastResult.body } else { $null }
        recipient = if ($lastResult) { $lastResult.recipient } else { $null }
        sender    = if ($lastResult) { $lastResult.sender } else { $null }
        attempts  = $attempts.ToArray()
        error     = if ($lastResult) { $lastResult.error } else { "notification_delivery_failed" }
    }
}
