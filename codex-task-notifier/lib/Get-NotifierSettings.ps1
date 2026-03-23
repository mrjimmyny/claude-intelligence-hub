function Get-NotifierSettings {
    [CmdletBinding()]
    param(
        [string]$Path
    )

    function Get-ObjectValue {
        param(
            [object]$Object,
            [string]$Name,
            $Default = $null
        )

        if ($null -eq $Object) { return $Default }

        if ($Object -is [System.Collections.IDictionary]) {
            if ($Object.Contains($Name)) {
                $value = $Object[$Name]
                if ($null -ne $value) { return $value }
            }
            return $Default
        }

        $property = $Object.PSObject.Properties[$Name]
        if ($property -and $null -ne $property.Value) {
            return $property.Value
        }

        return $Default
    }

    function Convert-ToBoolean {
        param($Value, [bool]$Default)

        if ($null -eq $Value) { return $Default }
        if ($Value -is [bool]) { return $Value }

        try {
            return [System.Convert]::ToBoolean($Value)
        } catch {
            return $Default
        }
    }

    function Convert-ToInt {
        param($Value, [int]$Default)

        if ($null -eq $Value) { return $Default }
        try {
            return [int]$Value
        } catch {
            return $Default
        }
    }

    function Normalize-Array {
        param($Value, [object[]]$Default)

        if ($null -eq $Value) { return $Default }
        if ($Value -is [System.Array]) { return @($Value) }
        return @($Value)
    }

    $paths = Get-NotifierPaths
    if (-not $Path) {
        $Path = $paths.SettingsPath
    }

    if (-not (Test-Path $Path)) {
        throw "settings_not_found:$Path"
    }

    $raw = Get-Content -Raw $Path | ConvertFrom-Json
    $providersRaw = Get-ObjectValue -Object $raw -Name "providers"
    $resendRaw = Get-ObjectValue -Object $providersRaw -Name "resend"
    $mailgunRaw = Get-ObjectValue -Object $providersRaw -Name "mailgun"
    $smtpRaw = Get-ObjectValue -Object $providersRaw -Name "smtp"

    $providerOrder = @(Normalize-Array -Value (Get-ObjectValue -Object $raw -Name "provider_order" -Default @("resend", "mailgun")) -Default @("resend", "mailgun") | ForEach-Object {
        if ($null -ne $_) { "$_".Trim().ToLowerInvariant() }
    } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

    return [pscustomobject]@{
        enabled                   = Convert-ToBoolean -Value (Get-ObjectValue -Object $raw -Name "enabled" -Default $true) -Default $true
        channel                   = [string](Get-ObjectValue -Object $raw -Name "channel" -Default "https")
        subject_prefix            = [string](Get-ObjectValue -Object $raw -Name "subject_prefix" -Default "Codex")
        project_label             = [string](Get-ObjectValue -Object $raw -Name "project_label" -Default "codex-task-notifier")
        default_recipient         = [string](Get-ObjectValue -Object $raw -Name "default_recipient" -Default "mrjimmyny@gmail.com")
        default_sender            = [string](Get-ObjectValue -Object $raw -Name "default_sender" -Default "mrjimmyny@gmail.com")
        fallback_sender           = [string](Get-ObjectValue -Object $raw -Name "fallback_sender" -Default "misteranalista@gmail.com")
        include_payload_reference = Convert-ToBoolean -Value (Get-ObjectValue -Object $raw -Name "include_payload_reference" -Default $true) -Default $true
        dedupe_window_minutes     = Convert-ToInt -Value (Get-ObjectValue -Object $raw -Name "dedupe_window_minutes" -Default 1440) -Default 1440
        log_retention_days        = Convert-ToInt -Value (Get-ObjectValue -Object $raw -Name "log_retention_days" -Default 14) -Default 14
        provider_order            = if ($providerOrder.Count -gt 0) { $providerOrder } else { @("resend", "mailgun") }
        http_retry_delays_seconds = @(Normalize-Array -Value (Get-ObjectValue -Object $raw -Name "http_retry_delays_seconds" -Default @(0, 2, 5)) -Default @(0, 2, 5) | ForEach-Object {
            Convert-ToInt -Value $_ -Default 0
        })
        smtp_retry_delays_seconds = @(Normalize-Array -Value (Get-ObjectValue -Object $raw -Name "smtp_retry_delays_seconds" -Default @(0, 2, 5)) -Default @(0, 2, 5) | ForEach-Object {
            Convert-ToInt -Value $_ -Default 0
        })
        providers                 = [pscustomobject]@{
            resend = [pscustomobject]@{
                enabled         = Convert-ToBoolean -Value (Get-ObjectValue -Object $resendRaw -Name "enabled" -Default $true) -Default $true
                base_url        = [string](Get-ObjectValue -Object $resendRaw -Name "base_url" -Default "https://api.resend.com")
                timeout_seconds = Convert-ToInt -Value (Get-ObjectValue -Object $resendRaw -Name "timeout_seconds" -Default 30) -Default 30
            }
            mailgun = [pscustomobject]@{
                enabled         = Convert-ToBoolean -Value (Get-ObjectValue -Object $mailgunRaw -Name "enabled" -Default $true) -Default $true
                base_url        = [string](Get-ObjectValue -Object $mailgunRaw -Name "base_url" -Default "https://api.mailgun.net")
                domain          = Get-ObjectValue -Object $mailgunRaw -Name "domain"
                timeout_seconds = Convert-ToInt -Value (Get-ObjectValue -Object $mailgunRaw -Name "timeout_seconds" -Default 30) -Default 30
            }
            smtp = [pscustomobject]@{
                enabled = Convert-ToBoolean -Value (Get-ObjectValue -Object $smtpRaw -Name "enabled" -Default $true) -Default $true
            }
        }
        completion_rules          = [pscustomobject]@{
            safe_default_no_send = Convert-ToBoolean -Value (Get-ObjectValue -Object (Get-ObjectValue -Object $raw -Name "completion_rules") -Name "safe_default_no_send" -Default $true) -Default $true
        }
    }
}
