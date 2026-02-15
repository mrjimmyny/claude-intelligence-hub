# setup_local_env.ps1
# Claude Intelligence Hub - Fresh Machine Setup Script
# Version: 1.0.0
# Platform: Windows (PowerShell 5.1+)
# Purpose: Idempotent setup of 5 mandatory core skills + optional skills

param(
    [Parameter(Mandatory=$false)]
    [string]$HubPath = "$env:USERPROFILE\Downloads\claude-intelligence-hub",

    [Parameter(Mandatory=$false)]
    [string]$SkillsPath = "$env:USERPROFILE\.claude\skills\user",

    [Parameter(Mandatory=$false)]
    [switch]$Force = $false,

    [Parameter(Mandatory=$false)]
    [switch]$SkipOptional = $false,

    [Parameter(Mandatory=$false)]
    [switch]$SkipValidation = $false
)

# ═══════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════

$MANDATORY_SKILLS = @(
    "jimmy-core-preferences",
    "session-memoria",
    "x-mem",
    "gdrive-sync-memoria",
    "claude-session-registry"
)

$OPTIONAL_SKILLS = @(
    "pbi-claude-skills"
)

$SCRIPT_VERSION = "1.0.0"
$LOG_FILE = Join-Path $PSScriptRoot "setup_local_env.log"

# ═══════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $LOG_FILE -Value $logEntry

    switch ($Level) {
        "ERROR"   { Write-Host $Message -ForegroundColor Red }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        "INFO"    { Write-Host $Message -ForegroundColor Cyan }
        default   { Write-Host $Message }
    }
}

function Test-JunctionExists {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return $false
    }

    $item = Get-Item $Path -Force
    return ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
}

function New-JunctionPoint {
    param(
        [string]$Link,
        [string]$Target,
        [string]$SkillName
    )

    try {
        # Check if target exists
        if (-not (Test-Path $Target)) {
            Write-Log "ERROR: Target directory not found: $Target" "ERROR"
            return $false
        }

        # Check if link already exists
        if (Test-Path $Link) {
            if (Test-JunctionExists $Link) {
                if (-not $Force) {
                    Write-Log "  ⏭️  $SkillName: Junction already exists (use -Force to recreate)" "WARNING"
                    return $true
                }
                Write-Log "  🔄 $SkillName: Removing existing junction..." "INFO"
                Remove-Item $Link -Force -Recurse
            } else {
                Write-Log "  ⚠️  $SkillName: Directory exists but is NOT a junction" "WARNING"
                if (-not $Force) {
                    Write-Log "    Use -Force to delete and recreate as junction" "WARNING"
                    return $false
                }
                Write-Log "  🗑️  $SkillName: Removing non-junction directory..." "WARNING"
                Remove-Item $Link -Force -Recurse
            }
        }

        # Create junction
        Write-Log "  🔗 $SkillName: Creating junction point..." "INFO"
        cmd /c mklink /J "$Link" "$Target" | Out-Null

        if ($LASTEXITCODE -ne 0) {
            Write-Log "ERROR: Failed to create junction for $SkillName" "ERROR"
            return $false
        }

        Write-Log "  ✅ $SkillName: Junction created successfully" "SUCCESS"
        return $true

    } catch {
        Write-Log "ERROR: Exception while creating junction for $SkillName : $_" "ERROR"
        return $false
    }
}

function Get-SkillVersion {
    param([string]$SkillPath)

    $metadataFile = Join-Path $SkillPath ".metadata"
    if (Test-Path $metadataFile) {
        $content = Get-Content $metadataFile -Raw
        if ($content -match '"version":\s*"([^"]+)"') {
            return $matches[1]
        }
    }
    return "unknown"
}

# ═══════════════════════════════════════════════════════════════
# SECTION 1: PRE-FLIGHT VALIDATION
# ═══════════════════════════════════════════════════════════════

function Invoke-PreFlightChecks {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  CLAUDE INTELLIGENCE HUB - LOCAL ENVIRONMENT SETUP" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Log "Script Version: $SCRIPT_VERSION" "INFO"
    Write-Log "Hub Path: $HubPath" "INFO"
    Write-Log "Skills Path: $SkillsPath" "INFO"
    Write-Log "Force Mode: $Force" "INFO"
    Write-Host ""

    # Check if hub directory exists
    if (-not (Test-Path $HubPath)) {
        Write-Log "ERROR: Hub directory not found: $HubPath" "ERROR"
        Write-Log "Please clone the repository first:" "ERROR"
        Write-Log "  git clone https://github.com/mrjimmyny/claude-intelligence-hub.git $HubPath" "ERROR"
        return $false
    }

    # Check if HUB_MAP.md exists (validation that it's the right repo)
    $hubMap = Join-Path $HubPath "HUB_MAP.md"
    if (-not (Test-Path $hubMap)) {
        Write-Log "ERROR: HUB_MAP.md not found. Invalid hub directory?" "ERROR"
        return $false
    }

    # Create skills directory if it doesn't exist
    if (-not (Test-Path $SkillsPath)) {
        Write-Log "Creating skills directory: $SkillsPath" "INFO"
        New-Item -ItemType Directory -Path $SkillsPath -Force | Out-Null
    }

    Write-Log "✅ Pre-flight checks passed" "SUCCESS"
    Write-Host ""
    return $true
}

# ═══════════════════════════════════════════════════════════════
# SECTION 2: MANDATORY CORE SKILLS SETUP
# ═══════════════════════════════════════════════════════════════

function Install-MandatorySkills {
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "  STEP 1: MANDATORY CORE SKILLS (Auto-Install)" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""

    $successCount = 0
    $failedSkills = @()

    foreach ($skill in $MANDATORY_SKILLS) {
        $targetPath = Join-Path $HubPath $skill
        $linkPath = Join-Path $SkillsPath $skill

        $result = New-JunctionPoint -Link $linkPath -Target $targetPath -SkillName $skill

        if ($result) {
            $version = Get-SkillVersion $targetPath
            Write-Log "    Version: $version" "INFO"
            $successCount++
        } else {
            $failedSkills += $skill
        }
        Write-Host ""
    }

    Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Log "Mandatory Skills: $successCount/$($MANDATORY_SKILLS.Count) installed" "INFO"

    if ($failedSkills.Count -gt 0) {
        Write-Log "⚠️  Failed skills: $($failedSkills -join ', ')" "WARNING"
        return $false
    }

    Write-Log "✅ All mandatory skills installed successfully" "SUCCESS"
    Write-Host ""
    return $true
}

# ═══════════════════════════════════════════════════════════════
# SECTION 3: OPTIONAL SKILLS PROMPT
# ═══════════════════════════════════════════════════════════════

function Install-OptionalSkills {
    if ($SkipOptional) {
        Write-Log "Skipping optional skills (--SkipOptional flag)" "INFO"
        Write-Host ""
        return $true
    }

    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host "  STEP 2: OPTIONAL SKILLS (User Selection)" -ForegroundColor Magenta
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""

    foreach ($skill in $OPTIONAL_SKILLS) {
        $targetPath = Join-Path $HubPath $skill

        # Check if skill exists in hub
        if (-not (Test-Path $targetPath)) {
            Write-Log "⏭️  $skill: Not available in hub (skipping)" "WARNING"
            continue
        }

        # Get skill description
        $description = switch ($skill) {
            "pbi-claude-skills" { "Power BI optimization and DAX development" }
            default { "Optional skill" }
        }

        Write-Host "┌─────────────────────────────────────────────────────────────┐" -ForegroundColor DarkGray
        Write-Host "│ Skill: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$skill" -ForegroundColor White
        Write-Host "│ Description: " -NoNewline -ForegroundColor DarkGray
        Write-Host "$description" -ForegroundColor White
        Write-Host "└─────────────────────────────────────────────────────────────┘" -ForegroundColor DarkGray

        $response = Read-Host "Install $skill? (Y/N)"

        if ($response -match '^[Yy]') {
            $linkPath = Join-Path $SkillsPath $skill
            $result = New-JunctionPoint -Link $linkPath -Target $targetPath -SkillName $skill

            if ($result) {
                $version = Get-SkillVersion $targetPath
                Write-Log "    Version: $version" "INFO"
            }
        } else {
            Write-Log "  ⏭️  $skill: Skipped by user" "INFO"
        }
        Write-Host ""
    }

    Write-Host ""
    return $true
}

# ═══════════════════════════════════════════════════════════════
# SECTION 4: POST-SETUP VALIDATION
# ═══════════════════════════════════════════════════════════════

function Invoke-PostSetupValidation {
    if ($SkipValidation) {
        Write-Log "Skipping validation (--SkipValidation flag)" "WARNING"
        Write-Host ""
        return $true
    }

    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  STEP 3: POST-SETUP VALIDATION" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""

    # Check junction points
    Write-Log "Validating junction points..." "INFO"
    $junctionsValid = $true

    foreach ($skill in $MANDATORY_SKILLS) {
        $linkPath = Join-Path $SkillsPath $skill

        if (-not (Test-JunctionExists $linkPath)) {
            Write-Log "  ❌ $skill: Junction NOT found or invalid" "ERROR"
            $junctionsValid = $false
        } else {
            Write-Log "  ✅ $skill: Junction valid" "SUCCESS"
        }
    }
    Write-Host ""

    # Run integrity-check.sh if available
    $integrityScript = Join-Path $HubPath "scripts\integrity-check.sh"
    if (Test-Path $integrityScript) {
        Write-Log "Running hub integrity check..." "INFO"
        Write-Host ""

        $originalLocation = Get-Location
        Set-Location $HubPath

        try {
            bash $integrityScript
            if ($LASTEXITCODE -eq 0) {
                Write-Log "✅ Hub integrity check passed" "SUCCESS"
            } else {
                Write-Log "⚠️  Hub integrity check reported issues" "WARNING"
            }
        } catch {
            Write-Log "⚠️  Could not run integrity check (bash not available?)" "WARNING"
        }

        Set-Location $originalLocation
        Write-Host ""
    }

    return $junctionsValid
}

# ═══════════════════════════════════════════════════════════════
# SECTION 5: SUCCESS SUMMARY
# ═══════════════════════════════════════════════════════════════

function Show-Summary {
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "  ✅ SETUP COMPLETE!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""

    Write-Host "📍 Installed Skills:" -ForegroundColor Cyan
    $installedCount = 0

    Get-ChildItem $SkillsPath -Directory | ForEach-Object {
        if (Test-JunctionExists $_.FullName) {
            $version = Get-SkillVersion $_.FullName
            Write-Host "  ✓ " -NoNewline -ForegroundColor Green
            Write-Host "$($_.Name) " -NoNewline -ForegroundColor White
            Write-Host "($version)" -ForegroundColor DarkGray
            $installedCount++
        }
    }

    Write-Host ""
    Write-Host "📊 Summary:" -ForegroundColor Cyan
    Write-Host "  • Total skills installed: $installedCount" -ForegroundColor White
    Write-Host "  • Mandatory core skills: $($MANDATORY_SKILLS.Count)" -ForegroundColor White
    Write-Host "  • Skills directory: $SkillsPath" -ForegroundColor DarkGray
    Write-Host "  • Hub directory: $HubPath" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Start Claude Code in any project directory" -ForegroundColor White
    Write-Host "  2. Skills will auto-load from ~/.claude/skills/user/" -ForegroundColor White
    Write-Host "  3. To update skills: cd $HubPath && git pull" -ForegroundColor White
    Write-Host ""

    Write-Host "📝 Log file: $LOG_FILE" -ForegroundColor DarkGray
    Write-Host ""
}

# ═══════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════

# Initialize log
"" | Out-File $LOG_FILE -Force
Write-Log "═══════════════════════════════════════════════════════════════" "INFO"
Write-Log "Setup Local Environment - START" "INFO"
Write-Log "═══════════════════════════════════════════════════════════════" "INFO"

try {
    # Pre-flight checks
    if (-not (Invoke-PreFlightChecks)) {
        Write-Log "Pre-flight checks failed. Exiting." "ERROR"
        exit 1
    }

    # Install mandatory skills
    if (-not (Install-MandatorySkills)) {
        Write-Log "Mandatory skills installation failed. Review errors above." "ERROR"
        exit 1
    }

    # Install optional skills
    Install-OptionalSkills | Out-Null

    # Post-setup validation
    if (-not (Invoke-PostSetupValidation)) {
        Write-Log "⚠️  Validation detected issues, but setup may still be functional" "WARNING"
    }

    # Show summary
    Show-Summary

    Write-Log "Setup completed successfully" "SUCCESS"
    exit 0

} catch {
    Write-Log "FATAL ERROR: $_" "ERROR"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    exit 1
}
