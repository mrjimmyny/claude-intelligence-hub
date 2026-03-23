function Get-NotificationMessage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Envelope,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$Settings
    )

    function Render-Template {
        param(
            [string]$Template,
            [hashtable]$Tokens
        )

        $result = $Template
        foreach ($key in $Tokens.Keys) {
            $result = $result.Replace(("{{" + $key + "}}"), [string]$Tokens[$key])
        }
        return $result.Trim()
    }

    $paths = Get-NotifierPaths
    $subjectTemplate = [System.IO.File]::ReadAllText($paths.SubjectTemplate, [System.Text.Encoding]::UTF8)
    $bodyTemplate = [System.IO.File]::ReadAllText($paths.BodyTemplate, [System.Text.Encoding]::UTF8)

    $tokens = @{
        subject_prefix    = $Settings.subject_prefix.ToUpperInvariant()
        project           = $Envelope.project
        outcome           = $Envelope.final_outcome.ToUpperInvariant()
        result_label      = if ($Envelope.final_outcome -eq "failure") { "FAIL" } elseif ($Envelope.final_outcome -eq "success") { "SUCCESS" } else { $Envelope.final_outcome.ToUpperInvariant() }
        title             = if ($Envelope.title) { $Envelope.title } else { "Task notification for $($Envelope.project)" }
        short_task_title  = if ($Envelope.title) { $Envelope.title } else { "Task notification for $($Envelope.project)" }
        captured_at_local = $Envelope.captured_at_local
        session_id        = if ($Envelope.session_id) { $Envelope.session_id } else { "-" }
        session_short_id  = if ($Envelope.session_id) { "$($Envelope.session_id)".Substring(0, [Math]::Min(8, "$($Envelope.session_id)".Length)) } else { "-" }
        thread_id         = if ($Envelope.thread_id) { $Envelope.thread_id } else { "-" }
        turn_id           = if ($Envelope.turn_id) { $Envelope.turn_id } else { "-" }
        summary           = if ($Envelope.summary) { $Envelope.summary } else { "No summary provided by payload." }
        owner_name        = if ($Envelope.owner_name) { $Envelope.owner_name } else { "Jimmy" }
        agent_name        = if ($Envelope.agent_name) { $Envelope.agent_name } else { "-" }
        llm_model         = if ($Envelope.llm_model) { $Envelope.llm_model } else { "-" }
        machine_id        = if ($Envelope.machine_id) { $Envelope.machine_id } else { $env:COMPUTERNAME }
        classifier_reason = $Envelope.classifier_reason
        raw_payload_path  = if ($Settings.include_payload_reference) { $Envelope.raw_payload_path } else { "payload_reference_disabled" }
    }

    return [pscustomobject]@{
        subject         = Render-Template -Template $subjectTemplate -Tokens $tokens
        body            = Render-Template -Template $bodyTemplate -Tokens $tokens
        recipient       = Get-EnvironmentValue -Name "CTN_EMAIL_TO" -Default $Settings.default_recipient
        primary_sender  = Get-EnvironmentValue -Name "CTN_EMAIL_FROM" -Default $Settings.default_sender
        fallback_sender = $Settings.fallback_sender
    }
}
