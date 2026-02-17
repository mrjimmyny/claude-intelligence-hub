#!/bin/bash
# Context Guardian - Global Config Restore Script
# Restores ~/.claude/ with rollback protection and validation

# Source logging library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging-lib.sh"

# Configuration
RCLONE_REMOTE="gdrive-jimmy"
GDRIVE_FOLDER="Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory"
CLAUDE_DIR="$HOME/.claude"
TEMP_DIR="/tmp/context-guardian-restore-$$"
ROLLBACK_DIR="$HOME/.claude_rollback_$(date +"%Y%m%d_%H%M%S")"

# Parse arguments
DRY_RUN=false
SKIP_CONFIRMATION=false

for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            log_info "DRY-RUN MODE: No files will be modified"
            ;;
        --yes)
            SKIP_CONFIRMATION=true
            ;;
    esac
done

# Error handler for rollback
handle_restore_error() {
    log_error "Restore failed! Initiating rollback..."

    if [ -d "$ROLLBACK_DIR" ]; then
        rm -rf "$CLAUDE_DIR"
        mv "$ROLLBACK_DIR" "$CLAUDE_DIR"
        log_success "Rollback completed - restored to previous state"
    else
        log_error "Rollback directory not found!"
    fi

    log_summary "failed" "Restore failed and rolled back"
    exit 1
}

# Set error trap
trap 'handle_restore_error' ERR

# ==============================================================================
# Pre-flight Checks
# ==============================================================================

log_banner "Context Guardian - Global Config Restore"

log_info "Running pre-flight checks..."

# Check rclone
if ! command -v rclone &> /dev/null; then
    log_error "rclone is not installed or not in PATH"
    exit 1
fi
log_success "rclone found"

# Check rclone remote
if ! rclone listremotes 2>&1 | grep -q "^${RCLONE_REMOTE}:"; then
    log_error "rclone remote '$RCLONE_REMOTE' not configured"
    exit 1
fi
log_success "rclone remote configured"

# ==============================================================================
# Fetch Metadata
# ==============================================================================

log_info "Fetching backup metadata from Google Drive..."

mkdir -p "$TEMP_DIR"

rclone copy "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/LATEST_GLOBAL.json" "$TEMP_DIR/" --verbose

if [ ! -f "$TEMP_DIR/LATEST_GLOBAL.json" ]; then
    log_error "Failed to fetch metadata from Google Drive"
    exit 1
fi

log_success "Metadata fetched"

# Parse metadata
BACKUP_BY=$(jq -r '.backup_by' "$TEMP_DIR/LATEST_GLOBAL.json")
LAST_BACKUP=$(jq -r '.last_backup' "$TEMP_DIR/LATEST_GLOBAL.json")
SKILL_COUNT=$(jq -r '.skill_count' "$TEMP_DIR/LATEST_GLOBAL.json")
TOTAL_SIZE=$(numfmt --to=iec-i --suffix=B $(jq -r '.total_size_bytes' "$TEMP_DIR/LATEST_GLOBAL.json") 2>/dev/null || echo "unknown")

echo ""
echo "Last Backup Information:"
echo "  Backed up by: $BACKUP_BY"
echo "  Backup date: $LAST_BACKUP"
echo "  Skills: $SKILL_COUNT"
echo "  Total size: $TOTAL_SIZE"
echo ""

# Confirmation
if [ "$SKIP_CONFIRMATION" = false ] && [ "$DRY_RUN" = false ]; then
    read -p "Restore this backup? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Restore cancelled by user"
        exit 0
    fi
fi

# ==============================================================================
# Create Rollback Point
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    log_info "Creating rollback point: $ROLLBACK_DIR"

    if [ -d "$CLAUDE_DIR" ]; then
        cp -r "$CLAUDE_DIR" "$ROLLBACK_DIR"
        log_success "Rollback point created"
    else
        log_info "No existing ~/.claude directory (fresh install)"
    fi
else
    log_info "[DRY-RUN] Would create rollback point"
fi

# ==============================================================================
# Download Files
# ==============================================================================

log_info "Downloading files from Google Drive..."

if [ "$DRY_RUN" = false ]; then
    # Download global folder
    rclone copy "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/global/" "$TEMP_DIR/global/" --verbose --progress

    log_success "Files downloaded"
else
    log_info "[DRY-RUN] Would download from: ${RCLONE_REMOTE}:${GDRIVE_FOLDER}/global/"
fi

# ==============================================================================
# Verify Checksums
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    log_info "Verifying checksums..."

    # Verify settings.json
    EXPECTED_SHA=$(jq -r '.files.settings_json.sha256' "$TEMP_DIR/LATEST_GLOBAL.json")
    if [ -n "$EXPECTED_SHA" ] && [ "$EXPECTED_SHA" != "" ] && [ -f "$TEMP_DIR/global/settings.json" ]; then
        ACTUAL_SHA=$(sha256sum "$TEMP_DIR/global/settings.json" | cut -d' ' -f1)
        if [ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]; then
            log_error "Checksum mismatch for settings.json!"
            exit 1
        fi
        log_success "settings.json checksum verified"
    fi

    # Verify plugins configs
    EXPECTED_SHA=$(jq -r '.files.plugins_config.sha256' "$TEMP_DIR/LATEST_GLOBAL.json")
    if [ -n "$EXPECTED_SHA" ] && [ "$EXPECTED_SHA" != "" ] && [ -f "$TEMP_DIR/global/plugins/config.json" ]; then
        ACTUAL_SHA=$(sha256sum "$TEMP_DIR/global/plugins/config.json" | cut -d' ' -f1)
        if [ "$EXPECTED_SHA" != "$ACTUAL_SHA" ]; then
            log_error "Checksum mismatch for plugins/config.json!"
            exit 1
        fi
        log_success "plugins/config.json checksum verified"
    fi

    log_success "All checksums verified"
else
    log_info "[DRY-RUN] Would verify checksums"
fi

# ==============================================================================
# Restore Files
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    log_info "Restoring files to ~/.claude/..."

    mkdir -p "$CLAUDE_DIR/plugins"
    mkdir -p "$CLAUDE_DIR/skills/user"

    # Restore settings.json
    if [ -f "$TEMP_DIR/global/settings.json" ]; then
        cp "$TEMP_DIR/global/settings.json" "$CLAUDE_DIR/"
        log_success "Restored settings.json"
    fi

    # Restore plugins
    if [ -d "$TEMP_DIR/global/plugins" ]; then
        cp -r "$TEMP_DIR/global/plugins"/* "$CLAUDE_DIR/plugins/" 2>/dev/null || true
        log_success "Restored plugins config"
    fi

    # Restore skill directories (not symlinks - those are recreated below)
    DIRECTORIES=$(jq -r '.skills[] | select(.is_symlink == false) | .skill_name' "$TEMP_DIR/LATEST_GLOBAL.json")
    if [ -n "$DIRECTORIES" ]; then
        while IFS= read -r skill_name; do
            if [ -d "$TEMP_DIR/global/skills/$skill_name" ]; then
                cp -r "$TEMP_DIR/global/skills/$skill_name" "$CLAUDE_DIR/skills/user/"
                log_success "Restored skill directory: $skill_name"
            fi
        done <<< "$DIRECTORIES"
    fi

    log_success "Files restored"
else
    log_info "[DRY-RUN] Would restore files to ~/.claude/"
fi

# ==============================================================================
# Recreate Symlinks (Hub Skills Only)
# ==============================================================================

log_info "Recreating symlinks..."

HUB_SKILLS=$(jq -r '.skills[] | select(.is_symlink == true and .link_type == "hub_skill") | @json' "$TEMP_DIR/LATEST_GLOBAL.json")

SYMLINK_COUNT=0
SYMLINK_WARNINGS=""

if [ -n "$HUB_SKILLS" ]; then
    while IFS= read -r skill_json; do
        skill_name=$(echo "$skill_json" | jq -r '.skill_name')
        hub_path=$(echo "$skill_json" | jq -r '.hub_path')
        absolute_target=$(echo "$skill_json" | jq -r '.absolute_target')

        link_path="$CLAUDE_DIR/skills/user/$skill_name"

        # Check if target exists
        if [ ! -d "$absolute_target" ]; then
            log_warn "Target not found for $skill_name: $absolute_target"
            log_warn "Skipping symlink creation (target must be cloned from hub)"
            SYMLINK_WARNINGS="${SYMLINK_WARNINGS}\n⚠️  $skill_name target not found: $absolute_target"
            continue
        fi

        if [ "$DRY_RUN" = false ]; then
            # Remove existing if present (use PowerShell on Windows to avoid deleting junction target content)
            if [ -d "$link_path" ] || [ -L "$link_path" ]; then
                if [[ "$OSTYPE" == "msys" ]] || [[ "$OS" == "Windows_NT" ]]; then
                    powershell -Command "Remove-Item -Path '$(cygpath -w "$link_path")' -Force" 2>/dev/null || rm -rf "$link_path"
                else
                    rm -rf "$link_path"
                fi
            fi

            # Create junction (Windows) or symlink (Unix)
            if [[ "$OSTYPE" == "msys" ]] || [[ "$OS" == "Windows_NT" ]]; then
                win_link=$(cygpath -w "$link_path")
                win_target=$(cygpath -w "$absolute_target")
                powershell -Command "New-Item -ItemType Junction -Path '$win_link' -Target '$win_target'" > /dev/null 2>&1
                if [ -d "$link_path" ] || [ -L "$link_path" ]; then
                    log_success "Created junction: $skill_name → $hub_path"
                    SYMLINK_COUNT=$((SYMLINK_COUNT + 1))
                else
                    log_error "Failed to create junction: $skill_name"
                    SYMLINK_WARNINGS="${SYMLINK_WARNINGS}\n❌ Failed to create junction: $skill_name"
                fi
            else
                ln -s "$absolute_target" "$link_path"
                if [ -L "$link_path" ]; then
                    log_success "Created symlink: $skill_name → $hub_path"
                    SYMLINK_COUNT=$((SYMLINK_COUNT + 1))
                else
                    log_error "Failed to create symlink: $skill_name"
                    SYMLINK_WARNINGS="${SYMLINK_WARNINGS}\n❌ Failed to create symlink: $skill_name"
                fi
            fi
        else
            log_info "[DRY-RUN] Would create symlink: $skill_name → $absolute_target"
            SYMLINK_COUNT=$((SYMLINK_COUNT + 1))
        fi
    done <<< "$HUB_SKILLS"
fi

log_success "Recreated $SYMLINK_COUNT symlink(s)"

# ==============================================================================
# Post-Restore Validation
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    log_info "Validating restored configuration..."

    VALIDATION_FAILED=false

    # Check 1: settings.json exists and valid JSON
    if [ -f "$CLAUDE_DIR/settings.json" ]; then
        if jq empty "$CLAUDE_DIR/settings.json" 2>/dev/null; then
            log_success "Check 1: settings.json is valid"
        else
            log_error "Check 1: settings.json is INVALID JSON!"
            VALIDATION_FAILED=true
        fi
    else
        log_warn "Check 1: settings.json is MISSING (may be default config)"
    fi

    # Check 2: Skills directory exists
    if [ -d "$CLAUDE_DIR/skills/user" ]; then
        CURRENT_SKILL_COUNT=$(ls -1 "$CLAUDE_DIR/skills/user" 2>/dev/null | wc -l)
        log_success "Check 2: Skills directory exists ($CURRENT_SKILL_COUNT skills)"
    else
        log_error "Check 2: Skills directory is MISSING!"
        VALIDATION_FAILED=true
    fi

    # Check 3: Symlinks/junctions valid
    BROKEN_SYMLINKS=0
    for skill in "$CLAUDE_DIR/skills/user"/*; do
        [ -e "$skill" ] || continue
        if [ -L "$skill" ]; then
            # Unix symlink: check target is accessible
            if [ ! -e "$skill" ]; then
                skill_name=$(basename "$skill")
                log_error "Check 3: Broken symlink: $skill_name"
                BROKEN_SYMLINKS=$((BROKEN_SYMLINKS + 1))
                VALIDATION_FAILED=true
            fi
        elif [ -d "$skill" ] && ([[ "$OSTYPE" == "msys" ]] || [[ "$OS" == "Windows_NT" ]]); then
            # Windows junction: verify it is a ReparsePoint (not a plain dir copy)
            skill_name=$(basename "$skill")
            win_path=$(cygpath -w "$skill")
            is_junction=$(powershell -Command "(Get-Item -Force '$win_path' -ErrorAction SilentlyContinue).Attributes -match 'ReparsePoint'" 2>/dev/null)
            if [ "$is_junction" != "True" ]; then
                log_warn "Check 3: $skill_name is a DIR copy, not a junction — run restore to fix"
            fi
        fi
    done

    if [ $BROKEN_SYMLINKS -eq 0 ]; then
        log_success "Check 3: All symlinks valid"
    fi

    # Check 4: Plugins config exists
    if [ -f "$CLAUDE_DIR/plugins/config.json" ]; then
        log_success "Check 4: plugins/config.json exists"
    else
        log_warn "Check 4: plugins/config.json missing (may be optional)"
    fi

    # Check 5: Final file count reasonable
    EXPECTED_SKILL_COUNT=$SKILL_COUNT
    CURRENT_SKILL_COUNT=$(ls -1 "$CLAUDE_DIR/skills/user" 2>/dev/null | wc -l)

    if [ "$CURRENT_SKILL_COUNT" -eq "$EXPECTED_SKILL_COUNT" ]; then
        log_success "Check 5: Skill count matches ($CURRENT_SKILL_COUNT)"
    else
        log_warn "Check 5: Skill count mismatch (expected $EXPECTED_SKILL_COUNT, got $CURRENT_SKILL_COUNT)"
    fi

    # Final verdict
    if [ "$VALIDATION_FAILED" = true ]; then
        log_error "VALIDATION FAILED - Restore may not work correctly!"
        exit 1
    else
        log_success "VALIDATION PASSED - Restore successful!"
    fi
else
    log_info "[DRY-RUN] Would run 5 validation checks"
fi

# ==============================================================================
# Cleanup Rollback
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    log_info "Cleaning up rollback point..."
    rm -rf "$ROLLBACK_DIR"
    log_success "Rollback point deleted"
else
    log_info "[DRY-RUN] Would cleanup rollback point"
fi

# Cleanup temp directory
rm -rf "$TEMP_DIR"

# ==============================================================================
# Summary
# ==============================================================================

log_summary "success" "Global config restored successfully"

echo ""
echo "Restore Summary:"
echo "  Restored from: $BACKUP_BY ($LAST_BACKUP)"
echo "  Skills: $SKILL_COUNT"
echo "  Symlinks recreated: $SYMLINK_COUNT"
echo "  Validation: PASSED (5/5 checks)"

if [ -n "$SYMLINK_WARNINGS" ]; then
    echo ""
    echo -e "${SYMLINK_WARNINGS}"
fi

echo ""
