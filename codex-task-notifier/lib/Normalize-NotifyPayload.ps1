function Normalize-NotifyPayload {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$RawPayload,

        [Parameter(Mandatory = $true)]
        [string]$RawPayloadPath,

        [Parameter(Mandatory = $true)]
        [pscustomobject]$Settings
    )

    function Get-NormalizedHash {
        param([string]$Text)
        return [System.BitConverter]::ToString(
            [System.Security.Cryptography.SHA256]::Create().ComputeHash(
                [System.Text.Encoding]::UTF8.GetBytes($Text)
            )
        ).Replace("-", "").ToLowerInvariant()
    }

    function Flatten-Node {
        param([object]$Node, [string]$Prefix = "")
        $map = @{}

        if ($null -eq $Node) { return $map }

        if ($Node -is [System.Collections.IDictionary]) {
            foreach ($key in $Node.Keys) {
                $name = if ($Prefix) { "$Prefix.$key" } else { [string]$key }
                $map += Flatten-Node -Node $Node[$key] -Prefix $name
            }
            return $map
        }

        if ($Node -is [psobject] -and $Node.PSObject.Properties.Count -gt 0) {
            foreach ($property in $Node.PSObject.Properties) {
                $name = if ($Prefix) { "$Prefix.$($property.Name)" } else { [string]$property.Name }
                $map += Flatten-Node -Node $property.Value -Prefix $name
            }
            return $map
        }

        if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [string])) {
            $index = 0
            foreach ($item in $Node) {
                $name = if ($Prefix) { "$Prefix[$index]" } else { "[$index]" }
                $map += Flatten-Node -Node $item -Prefix $name
                $index++
            }
            return $map
        }

        $map[$Prefix] = $Node
        return $map
    }

    function Select-Value {
        param([hashtable]$Map, [string[]]$Patterns)
        foreach ($pattern in $Patterns) {
            $match = $Map.GetEnumerator() |
                Where-Object { $_.Key -match $pattern -and $null -ne $_.Value -and "$($_.Value)".Trim() -ne "" } |
                Select-Object -First 1
            if ($match) { return [string]$match.Value }
        }
        return $null
    }

    $parsed = $null
    $parseError = $null
    try {
        $parsed = $RawPayload | ConvertFrom-Json
    } catch {
        $parseError = $_.Exception.Message
    }

    $map = if ($parsed) { Flatten-Node -Node $parsed } else { @{} }

    $eventType = Select-Value -Map $map -Patterns @('(^|\.)(event_type|type|event|kind)$')
    $status = Select-Value -Map $map -Patterns @('(^|\.)(status|state|result|outcome)$')
    $title = Select-Value -Map $map -Patterns @('(^|\.)(title|task_title|subject|task|name)$')
    $summary = Select-Value -Map $map -Patterns @('(^|\.)(summary|message|final_message|text|content)$')
    $sessionId = Select-Value -Map $map -Patterns @('(^|\.)(session_id|sessionId)$')
    $threadId = Select-Value -Map $map -Patterns @('(^|\.)(thread_id|threadId|conversation_id|conversationId)$')
    $turnId = Select-Value -Map $map -Patterns @('(^|\.)(turn_id|turnId|item_id|itemId)$')
    $projectPath = Select-Value -Map $map -Patterns @('(^|\.)(cwd|working_directory|workingDirectory|project_path|projectPath|repo_path|repoPath)$')
    $agentName = Select-Value -Map $map -Patterns @('(^|\.)(agent_name|agentName)$')
    $llmModel = Select-Value -Map $map -Patterns @('(^|\.)(llm_model|llmModel|model_name|modelName)$')
    $machineId = Select-Value -Map $map -Patterns @('(^|\.)(machine_id|machineId|computer_name|computerName)$')
    $ownerName = Select-Value -Map $map -Patterns @('(^|\.)(owner_name|ownerName|recipient_name|recipientName)$')
    $attachmentPath = Select-Value -Map $map -Patterns @('(^|\.)(attachment_path|attachmentPath|attachment)$')

    $projectName = if ($projectPath) { Split-Path -Leaf $projectPath } else { $Settings.project_label }
    if (-not $title) { $title = "Task notification for $projectName" }
    if (-not $summary) { $summary = "No summary provided by payload." }
    if (-not $machineId) { $machineId = $env:COMPUTERNAME }
    if (-not $ownerName) { $ownerName = "Jimmy" }

    return [pscustomobject]@{
        captured_at_local = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        event_type        = if ($eventType) { $eventType } else { "unknown" }
        status            = if ($status) { $status } else { "unknown" }
        session_id        = $sessionId
        thread_id         = $threadId
        turn_id           = $turnId
        completed         = $false
        relevant          = $false
        final_outcome     = "unknown"
        project           = $projectName
        title             = $title
        summary           = $summary
        agent_name        = if ($agentName) { $agentName } else { "-" }
        llm_model         = if ($llmModel) { $llmModel } else { "-" }
        machine_id        = if ($machineId) { $machineId } else { "-" }
        owner_name        = if ($ownerName) { $ownerName } else { "Jimmy" }
        attachment_path   = $attachmentPath
        raw_payload_path  = $RawPayloadPath
        raw_payload_hash  = Get-NormalizedHash -Text $RawPayload
        parse_ok          = [bool]$parsed
        parse_error       = $parseError
        classifier_reason = if ($parseError) { "json_parse_failed" } else { "awaiting_classification" }
    }
}
