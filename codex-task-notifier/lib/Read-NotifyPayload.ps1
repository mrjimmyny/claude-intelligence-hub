function Read-NotifyPayload {
    [CmdletBinding()]
    param(
        [string[]]$RawArguments
    )

    $stdin = [Console]::In.ReadToEnd()
    if (-not [string]::IsNullOrWhiteSpace($stdin)) {
        return [pscustomobject]@{
            Source     = "stdin"
            RawPayload = $stdin.Trim()
        }
    }

    if ($RawArguments -and $RawArguments.Count -gt 0) {
        $joined = ($RawArguments -join " ").Trim()
        if (-not [string]::IsNullOrWhiteSpace($joined)) {
            return [pscustomobject]@{
                Source     = "argv"
                RawPayload = $joined
            }
        }
    }

    return [pscustomobject]@{
        Source     = "none"
        RawPayload = $null
    }
}
