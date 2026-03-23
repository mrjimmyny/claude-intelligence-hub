function Test-CompletionEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Envelope
    )

    $eventType = "$($Envelope.event_type)".ToLowerInvariant()
    $status = "$($Envelope.status)".ToLowerInvariant()
    $summary = "$($Envelope.summary)".ToLowerInvariant()
    $title = "$($Envelope.title)".ToLowerInvariant()

    $successTokens = @("completed", "complete", "succeeded", "success", "done", "finished")
    $failureTokens = @("failed", "failure", "error", "errored", "cancelled", "canceled", "timeout", "timed_out", "aborted")
    $reasons = New-Object System.Collections.Generic.List[string]

    if (-not $Envelope.parse_ok) {
        $Envelope.classifier_reason = "safe_default_no_send:json_parse_failed"
        return $Envelope
    }

    $isSuccess = $false
    foreach ($token in $successTokens) {
        if ($status -eq $token -or $eventType -match [regex]::Escape($token)) {
            $isSuccess = $true
            $reasons.Add("success_token:$token")
            break
        }
    }

    $isFailure = $false
    foreach ($token in $failureTokens) {
        if ($status -eq $token -or $eventType -match [regex]::Escape($token)) {
            $isFailure = $true
            $reasons.Add("failure_token:$token")
            break
        }
    }

    if (-not $isSuccess -and -not $isFailure) {
        if ($summary -match '\bcompleted\b|\bsucceeded\b' -or $title -match '\bcompleted\b|\bsucceeded\b') {
            $isSuccess = $true
            $reasons.Add("success_text_heuristic")
        } elseif ($summary -match '\bfailed\b|\berror\b|\bcancelled\b|\bcanceled\b' -or $title -match '\bfailed\b|\berror\b|\bcancelled\b|\bcanceled\b') {
            $isFailure = $true
            $reasons.Add("failure_text_heuristic")
        }
    }

    if ($isSuccess -and -not $isFailure) {
        $Envelope.completed = $true
        $Envelope.relevant = $true
        $Envelope.final_outcome = "success"
        $Envelope.classifier_reason = ($reasons -join ",")
        return $Envelope
    }

    if ($isFailure -and -not $isSuccess) {
        $Envelope.completed = $true
        $Envelope.relevant = $true
        $Envelope.final_outcome = "failure"
        $Envelope.classifier_reason = ($reasons -join ",")
        return $Envelope
    }

    $Envelope.classifier_reason = "safe_default_no_send:ambiguous_or_intermediate"
    return $Envelope
}
