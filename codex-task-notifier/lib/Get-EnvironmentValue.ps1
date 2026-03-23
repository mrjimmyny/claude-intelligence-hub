function Get-EnvironmentValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [string]$Default = $null
    )

    foreach ($scope in @("Process", "User", "Machine")) {
        $value = [Environment]::GetEnvironmentVariable($Name, $scope)
        if (-not [string]::IsNullOrWhiteSpace($value)) {
            return $value
        }
    }

    return $Default
}
