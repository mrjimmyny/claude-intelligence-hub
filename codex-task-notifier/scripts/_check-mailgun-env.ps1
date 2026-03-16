$vars = @('CTN_MAILGUN_API_KEY','CTN_MAILGUN_FROM','CTN_MAILGUN_DOMAIN','CTN_MAILGUN_BASE_URL')
foreach ($v in $vars) {
    $val = [System.Environment]::GetEnvironmentVariable($v, 'User')
    if (-not $val) { $val = [System.Environment]::GetEnvironmentVariable($v, 'Machine') }
    if ($val) {
        if ($v -eq 'CTN_MAILGUN_API_KEY') { Write-Host ($v + ': SET (len=' + $val.Length + ')') }
        else { Write-Host "${v}: $val" }
    } else {
        Write-Host "${v}: NOT SET"
    }
}
