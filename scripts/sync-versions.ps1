
# sync-versions.ps1 - Synchronize version across .metadata, SKILL.md, HUB_MAP.md
# Usage: .\scripts\sync-versions.ps1 <skill-name> [-HubDir <path>]

param(
    [Parameter(Mandatory=$true)][string]$SkillName,
    [string]$HubDir
)

if (-not $HubDir -or $HubDir.Trim() -eq "") {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $HubDir = (Resolve-Path (Join-Path $ScriptDir ".."))
}

$skillDir = Join-Path $HubDir $SkillName
$metaPath = Join-Path $skillDir ".metadata"
$skillMdPath = Join-Path $skillDir "SKILL.md"
$hubMapPath = Join-Path $HubDir "HUB_MAP.md"

if (-not (Test-Path $skillDir -PathType Container)) {
    Write-Error "Skill directory not found: $skillDir"
    exit 1
}
if (-not (Test-Path $metaPath)) {
    Write-Error "Missing .metadata: $metaPath"
    exit 1
}

function Get-FileEncoding([string]$path) {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        return New-Object System.Text.UTF8Encoding($true)
    }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        return New-Object System.Text.UnicodeEncoding($false, $true)
    }
    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        return New-Object System.Text.UnicodeEncoding($true, $true)
    }
    if ($bytes.Length -ge 4 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE -and $bytes[2] -eq 0x00 -and $bytes[3] -eq 0x00) {
        return New-Object System.Text.UTF32Encoding($false, $true)
    }
    if ($bytes.Length -ge 4 -and $bytes[0] -eq 0x00 -and $bytes[1] -eq 0x00 -and $bytes[2] -eq 0xFE -and $bytes[3] -eq 0xFF) {
        return New-Object System.Text.UTF32Encoding($true, $true)
    }
    return New-Object System.Text.UTF8Encoding($false)
}

function Read-File([string]$path) {
    $encoding = Get-FileEncoding $path
    return [System.IO.File]::ReadAllText($path, $encoding)
}

function Write-File([string]$path, [string]$content) {
    $encoding = Get-FileEncoding $path
    [System.IO.File]::WriteAllText($path, $content, $encoding)
}

$metaText = Read-File $metaPath
if ($metaText -notmatch '"version"\s*:\s*"([^"]+)"') {
    Write-Error "No version found in .metadata"
    exit 1
}
$version = $matches[1]

Write-Host ("Version Sync - {0}" -f $SkillName)
Write-Host ("Source version (.metadata): v{0}" -f $version)
Write-Host ""

# Update SKILL.md
if (Test-Path $skillMdPath) {
    $skillText = Read-File $skillMdPath
    if ($skillText -match '^\*\*Version:\*\*' -im) {
        $updatedSkillText = [regex]::Replace(
            $skillText,
            '^\*\*Version:\*\*\s*.*$',
            "**Version:** $version",
            [System.Text.RegularExpressions.RegexOptions]::Multiline
        )
        if ($updatedSkillText -ne $skillText) {
            Write-File $skillMdPath $updatedSkillText
            Write-Host ("Updated SKILL.md to v{0}" -f $version) -ForegroundColor Green
        } else {
            Write-Host "SKILL.md already up to date" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "Warning: Version header not found in SKILL.md" -ForegroundColor Yellow
    }
} else {
    Write-Host "Warning: SKILL.md not found (skipping)" -ForegroundColor Yellow
}

# Update HUB_MAP.md
if (Test-Path $hubMapPath) {
    $hubText = Read-File $hubMapPath
    $pattern = "(?im)^.*" + [regex]::Escape($SkillName) + ".*v[0-9]+\.[0-9]+\.[0-9]+.*$"
    if ($hubText -match $pattern) {
        $updatedHubText = [regex]::Replace(
            $hubText,
            $pattern,
            { param($m) [regex]::Replace($m.Value, 'v[0-9]+\.[0-9]+\.[0-9]+', 'v' + $version, 1) },
            [System.Text.RegularExpressions.RegexOptions]::Multiline
        )
        if ($updatedHubText -ne $hubText) {
            Write-File $hubMapPath $updatedHubText
            Write-Host ("Updated HUB_MAP.md to v{0}" -f $version) -ForegroundColor Green
        } else {
            Write-Host "HUB_MAP.md already up to date" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "Warning: Skill version not found in HUB_MAP.md" -ForegroundColor Yellow
    }
} else {
    Write-Host "Warning: HUB_MAP.md not found (skipping)" -ForegroundColor Yellow
}

# Update last_updated in .metadata (if present)
if ($metaText -match '"last_updated"\s*:\s*"[^"]*"') {
    $today = Get-Date -Format 'yyyy-MM-dd'
    $updatedMeta = [regex]::Replace($metaText, '"last_updated"\s*:\s*"[^"]*"', '"last_updated": "' + $today + '"')
    if ($updatedMeta -ne $metaText) {
        Write-File $metaPath $updatedMeta
        Write-Host ("Updated .metadata last_updated to {0}" -f $today) -ForegroundColor Green
    } else {
        Write-Host ".metadata last_updated already current" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host ("Version synchronization complete for {0} (v{1})" -f $SkillName, $version) -ForegroundColor Green
