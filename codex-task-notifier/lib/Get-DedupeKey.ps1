function Get-DedupeKey {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Envelope
    )

    $parts = @(
        $Envelope.event_type,
        $Envelope.project,
        $Envelope.session_id,
        $Envelope.thread_id,
        $Envelope.turn_id,
        $Envelope.final_outcome,
        $Envelope.raw_payload_hash
    ) | ForEach-Object {
        if ([string]::IsNullOrWhiteSpace([string]$_)) { "_" } else { [string]$_ }
    }

    return ($parts -join "|")
}
