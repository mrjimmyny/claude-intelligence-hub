function Send-MailgunNotification {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Envelope,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$Settings
    )

    function New-AttemptList {
        return New-Object System.Collections.Generic.List[object]
    }

    function Get-ErrorSummary {
        param([string]$ResponseText, [string]$Fallback)

        if ([string]::IsNullOrWhiteSpace($ResponseText)) {
            return $Fallback
        }

        try {
            $parsed = $ResponseText | ConvertFrom-Json
            foreach ($name in @("message", "error", "detail")) {
                $property = $parsed.PSObject.Properties[$name]
                if ($property -and $property.Value) {
                    return [string]$property.Value
                }
            }
        } catch {
        }

        $compact = $ResponseText.Replace("`r", " ").Replace("`n", " ").Trim()
        if ($compact.Length -gt 240) {
            return $compact.Substring(0, 240)
        }
        return $compact
    }

    Add-Type -AssemblyName System.Net.Http

    $message = Get-NotificationMessage -Envelope $Envelope -Settings $Settings
    $config = $Settings.providers.mailgun
    $apiKey = Get-EnvironmentValue -Name "CTN_MAILGUN_API_KEY"
    $sender = Get-EnvironmentValue -Name "CTN_MAILGUN_FROM" -Default $message.primary_sender
    $domain = Get-EnvironmentValue -Name "CTN_MAILGUN_DOMAIN" -Default $config.domain
    $baseUrl = Get-EnvironmentValue -Name "CTN_MAILGUN_BASE_URL" -Default $config.base_url
    $attempts = New-AttemptList

    if (-not $config.enabled) {
        $attempts.Add([pscustomobject]@{
            provider    = "mailgun"
            sender      = $sender
            delay_s     = 0
            ok          = $false
            status_code = $null
            error       = "mailgun_provider_disabled"
            response_id = $null
        })
        return [pscustomobject]@{
            ok        = $false
            provider  = "mailgun"
            subject   = $message.subject
            body      = $message.body
            recipient = $message.recipient
            sender    = $sender
            attempts  = $attempts.ToArray()
            error     = "mailgun_provider_disabled"
        }
    }

    if ([string]::IsNullOrWhiteSpace($apiKey) -or [string]::IsNullOrWhiteSpace($message.recipient) -or [string]::IsNullOrWhiteSpace($sender) -or [string]::IsNullOrWhiteSpace($domain)) {
        $attempts.Add([pscustomobject]@{
            provider    = "mailgun"
            sender      = $sender
            delay_s     = 0
            ok          = $false
            status_code = $null
            error       = "mailgun_configuration_incomplete"
            response_id = $null
        })
        return [pscustomobject]@{
            ok        = $false
            provider  = "mailgun"
            subject   = $message.subject
            body      = $message.body
            recipient = $message.recipient
            sender    = $sender
            attempts  = $attempts.ToArray()
            error     = "mailgun_configuration_incomplete"
        }
    }

    foreach ($delay in $Settings.http_retry_delays_seconds) {
        $client = $null
        $content = $null
        $response = $null
        $fileStream = $null

        if ([int]$delay -gt 0) {
            Start-Sleep -Seconds ([int]$delay)
        }

        $attempt = [ordered]@{
            provider    = "mailgun"
            sender      = $sender
            delay_s     = [int]$delay
            ok          = $false
            status_code = $null
            error       = $null
            response_id = $null
        }

        try {
            $credentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("api:$apiKey"))
            $endpoint = "{0}/v3/{1}/messages" -f $baseUrl.TrimEnd("/"), $domain

            $client = New-Object System.Net.Http.HttpClient
            $client.Timeout = [TimeSpan]::FromSeconds([int]$config.timeout_seconds)
            $client.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("Basic", $credentials)

            $content = New-Object System.Net.Http.MultipartFormDataContent
            $content.Add((New-Object System.Net.Http.StringContent($sender)), "from")
            $content.Add((New-Object System.Net.Http.StringContent($message.recipient)), "to")
            $content.Add((New-Object System.Net.Http.StringContent($message.subject)), "subject")
            $content.Add((New-Object System.Net.Http.StringContent($message.body)), "text")

            if ($Envelope.attachment_path -and (Test-Path $Envelope.attachment_path)) {
                $fileStream = [System.IO.File]::OpenRead($Envelope.attachment_path)
                $streamContent = New-Object System.Net.Http.StreamContent($fileStream)
                $fileName = [System.IO.Path]::GetFileName($Envelope.attachment_path)
                $content.Add($streamContent, "attachment", $fileName)
            }

            $response = $client.PostAsync($endpoint, $content).GetAwaiter().GetResult()
            $responseText = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
            $attempt.status_code = [int]$response.StatusCode

            if ($response.IsSuccessStatusCode) {
                try {
                    $parsed = $responseText | ConvertFrom-Json
                    if ($parsed.PSObject.Properties["id"] -and $parsed.id) {
                        $attempt.response_id = [string]$parsed.id
                    }
                } catch {
                }

                $attempt.ok = $true
                $attempts.Add([pscustomobject]$attempt)
                return [pscustomobject]@{
                    ok        = $true
                    provider  = "mailgun"
                    subject   = $message.subject
                    body      = $message.body
                    recipient = $message.recipient
                    sender    = $sender
                    attempts  = $attempts.ToArray()
                    error     = $null
                }
            }

            $attempt.error = Get-ErrorSummary -ResponseText $responseText -Fallback ("mailgun_http_" + [int]$response.StatusCode)
        } catch {
            $attempt.error = $_.Exception.Message
        } finally {
            $attempts.Add([pscustomobject]$attempt)
            if ($fileStream) { $fileStream.Dispose() }
            if ($response) { $response.Dispose() }
            if ($content) { $content.Dispose() }
            if ($client) { $client.Dispose() }
        }
    }

    return [pscustomobject]@{
        ok        = $false
        provider  = "mailgun"
        subject   = $message.subject
        body      = $message.body
        recipient = $message.recipient
        sender    = $sender
        attempts  = $attempts.ToArray()
        error     = if ($attempts.Count -gt 0) { $attempts[$attempts.Count - 1].error } else { "mailgun_delivery_failed" }
    }
}
