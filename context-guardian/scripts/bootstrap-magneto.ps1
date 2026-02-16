#Requires -Version 5.1
# Context Guardian - Bootstrap Script for Magneto
# Self-contained restore script for account switching

param(
    [switch]$FixSymlinks,
    [switch]$DryRun
)

# Start transcript (structured logging)
$LogDir = "$env:USERPROFILE\.claude\context-guardian\logs"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
$LogFile = Join-Path $LogDir "bootstrap_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
Start-Transcript -Path $LogFile

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Context Guardian Bootstrap for Magneto" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Global variables
$global:SYMLINK_WARNINGS = @()
$global:RCLONE_REMOTE = "gdrive-jimmy"
$global:GDRIVE_FOLDER = "Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory"

# ==============================================================================
# Helper Functions
# ==============================================================================

function Test-DeveloperMode {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    try {
        $devMode = Get-ItemProperty -Path $regPath -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction Stop
        return $devMode.AllowDevelopmentWithoutDevLicense -eq 1
    } catch {
        return $false
    }
}

function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function New-SkillSymlink {
    param(
        [string]$SkillName,
        [string]$TargetPath,
        [string]$LinkPath,
        [bool]$IsFallbackMode = $false
    )

    if ($IsFallbackMode) {
        # Strategy 3: Copy fallback
        Write-Host "  📁 Copying skill: $SkillName (fallback mode)" -ForegroundColor Yellow
        if (Test-Path $LinkPath) {
            Remove-Item -Path $LinkPath -Recurse -Force
        }
        Copy-Item -Path $TargetPath -Destination $LinkPath -Recurse -Force
        $global:SYMLINK_WARNINGS += "⚠️  $SkillName was copied instead of symlinked. Updates to hub won't sync automatically."
        return $true
    }

    try {
        # Strategy 1 & 2: Try symlink (works with Developer Mode OR Admin)
        if (Test-Path $LinkPath) {
            Remove-Item -Path $LinkPath -Recurse -Force
        }
        New-Item -ItemType SymbolicLink -Path $LinkPath -Target $TargetPath -Force -ErrorAction Stop | Out-Null
        Write-Host "  ✅ Created symlink: $SkillName" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  ❌ Failed to create symlink: $SkillName" -ForegroundColor Red
        Write-Host "     Error: $_" -ForegroundColor Red
        Write-Host "     Falling back to directory copy..." -ForegroundColor Yellow

        # Fall back to copy
        if (Test-Path $LinkPath) {
            Remove-Item -Path $LinkPath -Recurse -Force
        }
        Copy-Item -Path $TargetPath -Destination $LinkPath -Recurse -Force
        $global:SYMLINK_WARNINGS += "⚠️  $SkillName was copied instead of symlinked."
        return $false
    }
}

# ==============================================================================
# --fix-symlinks Mode
# ==============================================================================

if ($FixSymlinks) {
    Write-Host "🔧 Converting copied skills to symlinks..." -ForegroundColor Cyan
    Write-Host ""

    $metadataPath = Join-Path $env:USERPROFILE ".claude\context-guardian\LATEST_GLOBAL.json"
    if (-not (Test-Path $metadataPath)) {
        # Try downloading from Google Drive
        Write-Host "Downloading metadata from Google Drive..." -ForegroundColor Yellow

        $tempDir = Join-Path $env:TEMP "context-guardian-fix"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

        rclone copy "${global:RCLONE_REMOTE}:${global:GDRIVE_FOLDER}/LATEST_GLOBAL.json" $tempDir --verbose

        $metadataPath = Join-Path $tempDir "LATEST_GLOBAL.json"

        if (-not (Test-Path $metadataPath)) {
            Write-Host "❌ ERROR: Metadata not found" -ForegroundColor Red
            Write-Host "   Run full bootstrap first" -ForegroundColor Red
            Stop-Transcript
            exit 1
        }
    }

    $metadata = Get-Content $metadataPath | ConvertFrom-Json

    $fixedCount = 0
    foreach ($skill in $metadata.skills) {
        if ($skill.is_symlink -and $skill.link_type -eq "hub_skill") {
            $skillPath = Join-Path $env:USERPROFILE ".claude\skills\user\$($skill.skill_name)"

            # Check if it's currently a directory (not symlink)
            if ((Test-Path $skillPath) -and -not ((Get-Item $skillPath).LinkType -eq "SymbolicLink")) {
                Write-Host "Converting: $($skill.skill_name)..." -ForegroundColor Cyan

                # Remove directory
                Remove-Item -Path $skillPath -Recurse -Force

                # Create symlink
                $targetPath = Join-Path $env:USERPROFILE "Downloads\claude-intelligence-hub\$($skill.hub_path)"

                try {
                    New-Item -ItemType SymbolicLink -Path $skillPath -Target $targetPath -Force -ErrorAction Stop | Out-Null
                    Write-Host "✅ Fixed: $($skill.skill_name) now symlinked" -ForegroundColor Green
                    $fixedCount++
                } catch {
                    Write-Host "❌ Failed: $($skill.skill_name) - $_" -ForegroundColor Red
                }
            } else {
                Write-Host "⏭️  Skipped: $($skill.skill_name) (already symlink)" -ForegroundColor Gray
            }
        }
    }

    Write-Host ""
    Write-Host "✅ Symlink fix complete! Fixed $fixedCount skill(s)" -ForegroundColor Green
    Stop-Transcript
    exit 0
}

# ==============================================================================
# Main Bootstrap Flow
# ==============================================================================

# Step 1: Check rclone
Write-Host "Checking dependencies..." -ForegroundColor Cyan
if (-not (Get-Command rclone -ErrorAction SilentlyContinue)) {
    Write-Host "❌ ERROR: rclone is not installed or not in PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install rclone:" -ForegroundColor Yellow
    Write-Host "  1. Download from: https://rclone.org/install/" -ForegroundColor Yellow
    Write-Host "  2. Extract to C:\rclone\" -ForegroundColor Yellow
    Write-Host "  3. Add C:\rclone to PATH" -ForegroundColor Yellow
    Write-Host "  4. Re-run this script" -ForegroundColor Yellow
    Stop-Transcript
    exit 1
}
Write-Host "✅ rclone found" -ForegroundColor Green

# Step 2: Check rclone remote
$remotes = rclone listremotes 2>&1
if ($remotes -notmatch "$($global:RCLONE_REMOTE):") {
    Write-Host "❌ ERROR: rclone remote '$($global:RCLONE_REMOTE)' not configured" -ForegroundColor Red
    Write-Host ""
    Write-Host "Configure rclone:" -ForegroundColor Yellow
    Write-Host "  1. Run: rclone config" -ForegroundColor Yellow
    Write-Host "  2. Select: New remote" -ForegroundColor Yellow
    Write-Host "  3. Name: $($global:RCLONE_REMOTE)" -ForegroundColor Yellow
    Write-Host "  4. Type: Google Drive (drive)" -ForegroundColor Yellow
    Write-Host "  5. Follow authentication prompts" -ForegroundColor Yellow
    Write-Host "  6. Re-run this script" -ForegroundColor Yellow
    Stop-Transcript
    exit 1
}
Write-Host "✅ rclone remote '$($global:RCLONE_REMOTE)' configured" -ForegroundColor Green
Write-Host ""

# Step 3: Check permissions (Developer Mode / Admin)
$developerMode = Test-DeveloperMode
$isAdmin = Test-Administrator

Write-Host "Permission Check:" -ForegroundColor Cyan

if ($developerMode) {
    Write-Host "✅ Developer Mode: ENABLED" -ForegroundColor Green
    Write-Host "   Symlinks will work without admin privileges" -ForegroundColor Gray
    $SYMLINK_STRATEGY = "developer"
} elseif ($isAdmin) {
    Write-Host "⚠️  Developer Mode: DISABLED" -ForegroundColor Yellow
    Write-Host "✅ Running as: Administrator" -ForegroundColor Green
    Write-Host "   Symlinks will work with admin privileges" -ForegroundColor Gray
    $SYMLINK_STRATEGY = "admin"
} else {
    Write-Host "⚠️  Developer Mode: DISABLED" -ForegroundColor Yellow
    Write-Host "⚠️  Running as: Standard User" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  [D] Enable Developer Mode (recommended)" -ForegroundColor Cyan
    Write-Host "  [A] Restart as Administrator" -ForegroundColor Cyan
    Write-Host "  [C] Continue with copy fallback (no symlinks)" -ForegroundColor Cyan
    Write-Host "  [Q] Quit" -ForegroundColor Cyan
    Write-Host ""

    $choice = Read-Host "Choose [D/A/C/Q]"

    switch ($choice.ToUpper()) {
        "D" {
            Write-Host ""
            Write-Host "Opening Settings..." -ForegroundColor Cyan
            Start-Process "ms-settings:developers"
            Write-Host ""
            Write-Host "After enabling Developer Mode:" -ForegroundColor Yellow
            Write-Host "  1. Toggle 'Developer Mode' to ON" -ForegroundColor Yellow
            Write-Host "  2. Close Settings" -ForegroundColor Yellow
            Write-Host "  3. Re-run this script: .\bootstrap-magneto.ps1" -ForegroundColor Yellow
            Stop-Transcript
            exit 0
        }
        "A" {
            Write-Host ""
            Write-Host "Restarting as Administrator..." -ForegroundColor Cyan
            Start-Process powershell -Verb RunAs -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            Stop-Transcript
            exit 0
        }
        "C" {
            Write-Host ""
            Write-Host "⚠️  Using copy fallback mode (no symlinks)" -ForegroundColor Yellow
            $SYMLINK_STRATEGY = "copy"
        }
        default {
            Write-Host "Exiting." -ForegroundColor Red
            Stop-Transcript
            exit 1
        }
    }
}

Write-Host ""

# Step 4: Fetch metadata from Google Drive
Write-Host "Fetching backup metadata from Google Drive..." -ForegroundColor Cyan

$tempDir = Join-Path $env:TEMP "context-guardian-bootstrap"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

$metadataRemote = "$($global:RCLONE_REMOTE):$($global:GDRIVE_FOLDER)/LATEST_GLOBAL.json"
$metadataLocal = Join-Path $tempDir "LATEST_GLOBAL.json"

rclone copy $metadataRemote $tempDir --verbose 2>&1 | Out-Null

if (-not (Test-Path $metadataLocal)) {
    Write-Host "❌ ERROR: Failed to fetch metadata from Google Drive" -ForegroundColor Red
    Write-Host "   Check network connection and rclone configuration" -ForegroundColor Red
    Stop-Transcript
    exit 1
}

$metadata = Get-Content $metadataLocal | ConvertFrom-Json

Write-Host "✅ Metadata fetched" -ForegroundColor Green
Write-Host ""
Write-Host "Last Backup Information:" -ForegroundColor Cyan
Write-Host "  By: $($metadata.backup_by)" -ForegroundColor Gray
Write-Host "  Date: $($metadata.last_backup)" -ForegroundColor Gray
Write-Host "  Skills: $($metadata.skills.Count)" -ForegroundColor Gray
Write-Host ""

# Step 5: Interactive menu
Write-Host "What would you like to restore?" -ForegroundColor Cyan
Write-Host "  [1] Global config only" -ForegroundColor Cyan
Write-Host "  [2] Global config + select projects" -ForegroundColor Cyan
Write-Host "  [3] Specific project only" -ForegroundColor Cyan
Write-Host "  [4] Exit" -ForegroundColor Cyan
Write-Host ""

$choice = Read-Host "Choose [1-4]"

switch ($choice) {
    "1" {
        # Restore global config
        Write-Host ""
        Write-Host "Restoring global config..." -ForegroundColor Cyan

        if ($DryRun) {
            Write-Host "[DRY-RUN] Would restore global config" -ForegroundColor Yellow
        } else {
            # Download global folder
            $globalDest = Join-Path $tempDir "global"
            rclone copy "$($global:RCLONE_REMOTE):$($global:GDRIVE_FOLDER)/global/" $globalDest --verbose --progress

            # Create backup of current config
            $backupDir = "$env:USERPROFILE\.claude_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
            if (Test-Path "$env:USERPROFILE\.claude") {
                Write-Host "Creating backup of current config..." -ForegroundColor Yellow
                Copy-Item -Path "$env:USERPROFILE\.claude" -Destination $backupDir -Recurse -Force
            }

            # Restore files
            Write-Host "Restoring files..." -ForegroundColor Cyan

            # Create directories
            New-Item -ItemType Directory -Path "$env:USERPROFILE\.claude\plugins" -Force | Out-Null
            New-Item -ItemType Directory -Path "$env:USERPROFILE\.claude\skills\user" -Force | Out-Null

            # Copy settings.json
            if (Test-Path "$globalDest\settings.json") {
                Copy-Item -Path "$globalDest\settings.json" -Destination "$env:USERPROFILE\.claude\" -Force
                Write-Host "✅ Restored settings.json" -ForegroundColor Green
            }

            # Copy plugins
            if (Test-Path "$globalDest\plugins") {
                Copy-Item -Path "$globalDest\plugins\*" -Destination "$env:USERPROFILE\.claude\plugins\" -Recurse -Force
                Write-Host "✅ Restored plugins" -ForegroundColor Green
            }

            # Recreate symlinks
            Write-Host "Recreating skills..." -ForegroundColor Cyan

            $isFallback = ($SYMLINK_STRATEGY -eq "copy")

            foreach ($skill in $metadata.skills) {
                if ($skill.is_symlink -and $skill.link_type -eq "hub_skill") {
                    $skillPath = Join-Path $env:USERPROFILE ".claude\skills\user\$($skill.skill_name)"
                    $targetPath = Join-Path $env:USERPROFILE "Downloads\claude-intelligence-hub\$($skill.hub_path)"

                    if (Test-Path $targetPath) {
                        New-SkillSymlink -SkillName $skill.skill_name -TargetPath $targetPath -LinkPath $skillPath -IsFallbackMode $isFallback
                    } else {
                        Write-Host "  ⚠️  Target not found: $($skill.skill_name) → $targetPath" -ForegroundColor Yellow
                        $global:SYMLINK_WARNINGS += "⚠️  $($skill.skill_name) target not found: $targetPath"
                    }
                } elseif (-not $skill.is_symlink) {
                    # Copy directory skill
                    $sourcePath = Join-Path $globalDest "skills\$($skill.skill_name)"
                    $destPath = Join-Path $env:USERPROFILE ".claude\skills\user\$($skill.skill_name)"

                    if (Test-Path $sourcePath) {
                        Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
                        Write-Host "  📁 Restored skill directory: $($skill.skill_name)" -ForegroundColor Green
                    }
                }
            }

            Write-Host ""
            Write-Host "✅ Global config restored successfully!" -ForegroundColor Green
        }
    }

    "2" {
        Write-Host ""
        Write-Host "[Feature not yet implemented - restore global first, then use option 3 for projects]" -ForegroundColor Yellow
    }

    "3" {
        Write-Host ""
        Write-Host "[Feature not yet implemented - use restore-project.sh from bash]" -ForegroundColor Yellow
    }

    "4" {
        Write-Host "Exiting." -ForegroundColor Gray
        Stop-Transcript
        exit 0
    }

    default {
        Write-Host "Invalid choice" -ForegroundColor Red
        Stop-Transcript
        exit 1
    }
}

# Display symlink warnings
if ($global:SYMLINK_WARNINGS.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠️  SYMLINK WARNINGS:" -ForegroundColor Yellow
    foreach ($warning in $global:SYMLINK_WARNINGS) {
        Write-Host $warning -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "To convert copied skills to symlinks later:" -ForegroundColor Cyan
    Write-Host "  1. Enable Developer Mode (Settings > Privacy & Security > For Developers)" -ForegroundColor Cyan
    Write-Host "  2. Run: .\bootstrap-magneto.ps1 -FixSymlinks" -ForegroundColor Cyan
}

# End
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Bootstrap Complete!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Open Claude Code: claude" -ForegroundColor Cyan
Write-Host "  2. Verify skills loaded: /skills" -ForegroundColor Cyan
Write-Host "  3. Continue working!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Full log saved to: $LogFile" -ForegroundColor Gray
Write-Host ""

Stop-Transcript
