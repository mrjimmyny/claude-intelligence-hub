# WP1 - Store Mailgun operational env vars
# Run once to configure tier 2 locally
# DO NOT store secrets in this file - API key already in User env storage

[System.Environment]::SetEnvironmentVariable('CTN_MAILGUN_DOMAIN',   '<MAILGUN_DOMAIN>',          'User')
[System.Environment]::SetEnvironmentVariable('CTN_MAILGUN_FROM',      '<MAILGUN_SENDER>',   'User')
[System.Environment]::SetEnvironmentVariable('CTN_MAILGUN_BASE_URL',  'https://api.mailgun.net',   'User')

Write-Host "CTN_MAILGUN_DOMAIN  : $([System.Environment]::GetEnvironmentVariable('CTN_MAILGUN_DOMAIN',  'User'))"
Write-Host "CTN_MAILGUN_FROM    : $([System.Environment]::GetEnvironmentVariable('CTN_MAILGUN_FROM',    'User'))"
Write-Host "CTN_MAILGUN_BASE_URL: $([System.Environment]::GetEnvironmentVariable('CTN_MAILGUN_BASE_URL','User'))"
Write-Host "Done."
