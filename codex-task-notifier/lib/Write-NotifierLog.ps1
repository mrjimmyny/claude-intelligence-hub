function Write-NotifierLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("raw", "normalized", "delivery", "validation")]
        [string]$Category,

        [Parameter(Mandatory = $true)]
        [object]$Payload,

        [string]$Extension = "json"
    )

    $paths = Get-NotifierPaths
    $rootMap = @{
        raw        = $paths.RawLogsRoot
        normalized = $paths.NormalizedRoot
        delivery   = $paths.DeliveryRoot
        validation = $paths.ValidationRoot
    }

    $dateFolder = Get-Date -Format "yyyy-MM-dd"
    $targetDir = Join-Path $rootMap[$Category] $dateFolder
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

    $json = if ($Payload -is [string]) { $Payload } else { $Payload | ConvertTo-Json -Depth 100 }
    $hash = [System.BitConverter]::ToString(
        [System.Security.Cryptography.SHA256]::Create().ComputeHash(
            [System.Text.Encoding]::UTF8.GetBytes($json)
        )
    ).Replace("-", "").ToLowerInvariant().Substring(0, 12)

    $path = Join-Path $targetDir ("{0}-{1}.{2}" -f (Get-Date -Format "HHmmss"), $hash, $Extension)
    [System.IO.File]::WriteAllText($path, $json, [System.Text.Encoding]::UTF8)
    return $path
}
