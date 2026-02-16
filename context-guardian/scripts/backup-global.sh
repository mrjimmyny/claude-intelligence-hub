#!/bin/bash
# Context Guardian - Global Config Backup Script
# Backs up ~/.claude/ with symlink detection and metadata storage

# Source logging library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging-lib.sh"

# Configuration
RCLONE_REMOTE="gdrive-jimmy"
GDRIVE_FOLDER="Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude/context-guardian/backups"
TEMP_DIR="/tmp/context-guardian-$$"

# Parse arguments
DRY_RUN=false
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            log_info "DRY-RUN MODE: No files will be modified"
            ;;
    esac
done

# ==============================================================================
# Pre-flight Checks
# ==============================================================================

log_banner "Context Guardian - Global Config Backup"

log_info "Running pre-flight checks..."

# Check 1: rclone installed
if ! command -v rclone &> /dev/null; then
    log_error "rclone is not installed or not in PATH"
    log_error "Install from: https://rclone.org/install/"
    log_summary "failed" "rclone not found"
    exit 1
fi
log_success "rclone found ($(rclone version | head -1))"

# Check 2: rclone remote configured
if ! rclone listremotes 2>&1 | grep -q "^${RCLONE_REMOTE}:"; then
    log_error "rclone remote '$RCLONE_REMOTE' not configured"
    log_error "Run: rclone config"
    log_summary "failed" "rclone remote not configured"
    exit 1
fi
log_success "rclone remote '$RCLONE_REMOTE' configured"

# Check 3: ~/.claude exists
if [ ! -d "$CLAUDE_DIR" ]; then
    log_error "Directory ~/.claude does not exist"
    log_summary "failed" "~/.claude not found"
    exit 1
fi
log_success "~/.claude directory found"

# Check 4: Disk space (warn if <1 GB free)
FREE_SPACE=$(df -BG "$HOME" | tail -1 | awk '{print $4}' | sed 's/G//')
if [ "$FREE_SPACE" -lt 1 ]; then
    log_warn "Low disk space: ${FREE_SPACE}GB free"
    log_warn "Consider freeing up space before backup"
fi

# ==============================================================================
# Calculate Sizes
# ==============================================================================

log_info "Calculating backup sizes..."

SETTINGS_SIZE=$(du -sh "$CLAUDE_DIR/settings.json" 2>/dev/null | cut -f1 || echo "0")
PLUGINS_SIZE=$(du -sh "$CLAUDE_DIR/plugins" 2>/dev/null | cut -f1 || echo "0")
SKILLS_SIZE=$(du -sh "$CLAUDE_DIR/skills/user" 2>/dev/null | cut -f1 || echo "0")
TOTAL_SIZE=$(du -sh "$CLAUDE_DIR" 2>/dev/null | cut -f1 || echo "0")
TOTAL_BYTES=$(du -sb "$CLAUDE_DIR" 2>/dev/null | cut -f1 || echo "0")

log_info "  settings.json: $SETTINGS_SIZE"
log_info "  plugins/: $PLUGINS_SIZE"
log_info "  skills/user/: $SKILLS_SIZE"
log_info "  TOTAL: $TOTAL_SIZE"

# Warn if >100 MB
if [ "$TOTAL_BYTES" -gt 104857600 ]; then
    log_warn "Global config size exceeds 100 MB ($TOTAL_SIZE)"
    log_warn "Consider reviewing for large files"
fi

# ==============================================================================
# Collect Files
# ==============================================================================

log_info "Preparing backup workspace..."

mkdir -p "$TEMP_DIR/global"
mkdir -p "$BACKUP_DIR"

# Collect settings.json
if [ -f "$CLAUDE_DIR/settings.json" ]; then
    log_info "Collecting settings.json..."
    cp "$CLAUDE_DIR/settings.json" "$TEMP_DIR/global/"
    SETTINGS_SHA=$(sha256sum "$CLAUDE_DIR/settings.json" | cut -d' ' -f1)
    SETTINGS_BYTES=$(stat -c%s "$CLAUDE_DIR/settings.json" 2>/dev/null || stat -f%z "$CLAUDE_DIR/settings.json" 2>/dev/null)
else
    log_warn "settings.json not found (may be default config)"
    SETTINGS_SHA=""
    SETTINGS_BYTES=0
fi

# Collect plugins config files
mkdir -p "$TEMP_DIR/global/plugins"

PLUGINS_CONFIG_SHA=""
PLUGINS_CONFIG_BYTES=0
if [ -f "$CLAUDE_DIR/plugins/config.json" ]; then
    log_info "Collecting plugins/config.json..."
    cp "$CLAUDE_DIR/plugins/config.json" "$TEMP_DIR/global/plugins/"
    PLUGINS_CONFIG_SHA=$(sha256sum "$CLAUDE_DIR/plugins/config.json" | cut -d' ' -f1)
    PLUGINS_CONFIG_BYTES=$(stat -c%s "$CLAUDE_DIR/plugins/config.json" 2>/dev/null || stat -f%z "$CLAUDE_DIR/plugins/config.json" 2>/dev/null)
fi

PLUGINS_INSTALLED_SHA=""
PLUGINS_INSTALLED_BYTES=0
if [ -f "$CLAUDE_DIR/plugins/installed_plugins.json" ]; then
    log_info "Collecting plugins/installed_plugins.json..."
    cp "$CLAUDE_DIR/plugins/installed_plugins.json" "$TEMP_DIR/global/plugins/"
    PLUGINS_INSTALLED_SHA=$(sha256sum "$CLAUDE_DIR/plugins/installed_plugins.json" | cut -d' ' -f1)
    PLUGINS_INSTALLED_BYTES=$(stat -c%s "$CLAUDE_DIR/plugins/installed_plugins.json" 2>/dev/null || stat -f%z "$CLAUDE_DIR/plugins/installed_plugins.json" 2>/dev/null)
fi

PLUGINS_MARKETPLACES_SHA=""
PLUGINS_MARKETPLACES_BYTES=0
if [ -f "$CLAUDE_DIR/plugins/known_marketplaces.json" ]; then
    log_info "Collecting plugins/known_marketplaces.json..."
    cp "$CLAUDE_DIR/plugins/known_marketplaces.json" "$TEMP_DIR/global/plugins/"
    PLUGINS_MARKETPLACES_SHA=$(sha256sum "$CLAUDE_DIR/plugins/known_marketplaces.json" | cut -d' ' -f1)
    PLUGINS_MARKETPLACES_BYTES=$(stat -c%s "$CLAUDE_DIR/plugins/known_marketplaces.json" 2>/dev/null || stat -f%z "$CLAUDE_DIR/plugins/known_marketplaces.json" 2>/dev/null)
fi

# Check plugins cache size
PLUGINS_CACHE_INCLUDED=false
PLUGINS_CACHE_REASON="not_exists"
if [ -d "$CLAUDE_DIR/plugins/cache" ]; then
    CACHE_SIZE_BYTES=$(du -sb "$CLAUDE_DIR/plugins/cache" 2>/dev/null | cut -f1)
    if [ "$CACHE_SIZE_BYTES" -lt 52428800 ]; then
        log_info "Collecting plugins/cache/ ($(numfmt --to=iec-i --suffix=B $CACHE_SIZE_BYTES))..."
        cp -r "$CLAUDE_DIR/plugins/cache" "$TEMP_DIR/global/plugins/"
        PLUGINS_CACHE_INCLUDED=true
        PLUGINS_CACHE_REASON="included"
    else
        log_warn "Skipping plugins/cache/ (size: $(numfmt --to=iec-i --suffix=B $CACHE_SIZE_BYTES) exceeds 50 MB)"
        PLUGINS_CACHE_REASON="size_exceeds_50mb"
    fi
fi

# ==============================================================================
# Detect Symlinks
# ==============================================================================

log_info "Detecting skills and symlinks..."

SKILLS_JSON="[]"
HUB_SYMLINKS=0
EXTERNAL_SYMLINKS=0
DIRECTORIES=0

if [ -d "$CLAUDE_DIR/skills/user" ]; then
    for skill in "$CLAUDE_DIR/skills/user"/*; do
        [ -e "$skill" ] || continue  # Skip if no skills

        skill_name=$(basename "$skill")

        if [ -L "$skill" ]; then
            # It's a symlink
            target=$(readlink -f "$skill")

            if [[ "$target" == *"claude-intelligence-hub"* ]]; then
                # Hub skill
                hub_path=$(echo "$target" | sed 's|.*/claude-intelligence-hub/||')

                SKILLS_JSON=$(echo "$SKILLS_JSON" | jq ". += [{
                    \"skill_name\": \"$skill_name\",
                    \"is_symlink\": true,
                    \"link_type\": \"hub_skill\",
                    \"hub_path\": \"$hub_path\",
                    \"absolute_target\": \"$target\"
                }]")

                HUB_SYMLINKS=$((HUB_SYMLINKS + 1))
                log_info "  ✅ $skill_name (symlink → hub: $hub_path)"
            else
                # External symlink
                SKILLS_JSON=$(echo "$SKILLS_JSON" | jq ". += [{
                    \"skill_name\": \"$skill_name\",
                    \"is_symlink\": true,
                    \"link_type\": \"external\",
                    \"absolute_target\": \"$target\"
                }]")

                EXTERNAL_SYMLINKS=$((EXTERNAL_SYMLINKS + 1))
                log_warn "  ⚠️  $skill_name (symlink → external: $target)"
            fi
        else
            # Regular directory - copy it
            log_info "  📁 $skill_name (directory)"
            mkdir -p "$TEMP_DIR/global/skills"
            cp -r "$skill" "$TEMP_DIR/global/skills/"

            SKILLS_JSON=$(echo "$SKILLS_JSON" | jq ". += [{
                \"skill_name\": \"$skill_name\",
                \"is_symlink\": false
            }]")

            DIRECTORIES=$((DIRECTORIES + 1))
        fi
    done
fi

SKILL_COUNT=$(echo "$SKILLS_JSON" | jq 'length')
log_success "Found $SKILL_COUNT skills ($HUB_SYMLINKS hub symlinks, $EXTERNAL_SYMLINKS external, $DIRECTORIES directories)"

# ==============================================================================
# Generate Metadata
# ==============================================================================

log_info "Generating metadata..."

BACKUP_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BACKUP_BY="xavier"

# Create LATEST_GLOBAL.json
cat > "$TEMP_DIR/LATEST_GLOBAL.json" <<EOF
{
  "backup_by": "$BACKUP_BY",
  "last_backup": "$BACKUP_TIMESTAMP",
  "format_version": "1.0",
  "files": {
    "settings_json": {
      "path": "~/.claude/settings.json",
      "sha256": "$SETTINGS_SHA",
      "size_bytes": $SETTINGS_BYTES
    },
    "plugins_config": {
      "path": "~/.claude/plugins/config.json",
      "sha256": "$PLUGINS_CONFIG_SHA",
      "size_bytes": $PLUGINS_CONFIG_BYTES
    },
    "plugins_installed": {
      "path": "~/.claude/plugins/installed_plugins.json",
      "sha256": "$PLUGINS_INSTALLED_SHA",
      "size_bytes": $PLUGINS_INSTALLED_BYTES
    },
    "plugins_marketplaces": {
      "path": "~/.claude/plugins/known_marketplaces.json",
      "sha256": "$PLUGINS_MARKETPLACES_SHA",
      "size_bytes": $PLUGINS_MARKETPLACES_BYTES
    },
    "plugins_cache": {
      "path": "~/.claude/plugins/cache/",
      "included": $PLUGINS_CACHE_INCLUDED,
      "reason": "$PLUGINS_CACHE_REASON"
    }
  },
  "skills": $SKILLS_JSON,
  "total_size_bytes": $TOTAL_BYTES,
  "skill_count": $SKILL_COUNT,
  "skill_breakdown": {
    "hub_symlinks": $HUB_SYMLINKS,
    "external_symlinks": $EXTERNAL_SYMLINKS,
    "directories": $DIRECTORIES
  }
}
EOF

log_success "Metadata generated"

# ==============================================================================
# Create Local Backup
# ==============================================================================

BACKUP_TIMESTAMP_FILE=$(date +"%Y%m%d_%H%M%S")
LOCAL_BACKUP="$BACKUP_DIR/global_${BACKUP_TIMESTAMP_FILE}.tar.gz"

if [ "$DRY_RUN" = false ]; then
    log_info "Creating local backup archive..."
    tar -czf "$LOCAL_BACKUP" -C "$TEMP_DIR" global LATEST_GLOBAL.json
    log_success "Local backup created: $LOCAL_BACKUP"
else
    log_info "[DRY-RUN] Would create: $LOCAL_BACKUP"
fi

# ==============================================================================
# Sync to Google Drive
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    log_info "Syncing to Google Drive..."

    # Upload global folder
    rclone copy "$TEMP_DIR/global" "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/global/" --verbose --progress

    # Upload metadata
    rclone copy "$TEMP_DIR/LATEST_GLOBAL.json" "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/" --verbose

    log_success "Synced to Google Drive"
else
    log_info "[DRY-RUN] Would sync to: ${RCLONE_REMOTE}:${GDRIVE_FOLDER}/"
fi

# ==============================================================================
# Verify Checksums
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    log_info "Verifying checksums..."

    # Download and compare LATEST_GLOBAL.json
    REMOTE_METADATA=$(rclone cat "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/LATEST_GLOBAL.json")
    LOCAL_METADATA=$(cat "$TEMP_DIR/LATEST_GLOBAL.json")

    if [ "$REMOTE_METADATA" = "$LOCAL_METADATA" ]; then
        log_success "Checksums verified - backup integrity confirmed"
    else
        log_error "Checksum mismatch - backup may be corrupted!"
        log_summary "failed" "Checksum verification failed"
        exit 1
    fi
else
    log_info "[DRY-RUN] Would verify checksums"
fi

# ==============================================================================
# Cleanup Old Backups
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    log_info "Cleaning up old backups (keeping last 10)..."

    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/global_*.tar.gz 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 10 ]; then
        ls -1t "$BACKUP_DIR"/global_*.tar.gz | tail -n +11 | xargs rm -f
        DELETED=$((BACKUP_COUNT - 10))
        log_success "Deleted $DELETED old backup(s)"
    else
        log_info "No old backups to delete (have $BACKUP_COUNT)"
    fi
else
    log_info "[DRY-RUN] Would cleanup old backups"
fi

# ==============================================================================
# Cleanup Temp Directory
# ==============================================================================

rm -rf "$TEMP_DIR"

# ==============================================================================
# Summary
# ==============================================================================

DURATION=$SECONDS

log_summary "success" "Global config backed up successfully"

echo ""
echo "Backup Summary:"
echo "  Backed up by: $BACKUP_BY"
echo "  Timestamp: $BACKUP_TIMESTAMP"
echo "  Files: $([ -n "$SETTINGS_SHA" ] && echo "settings.json" || echo "none"), $SKILL_COUNT skills"
echo "  Size: $TOTAL_SIZE"
echo "  Location: ${RCLONE_REMOTE}:${GDRIVE_FOLDER}/global/"
echo "  Duration: ${DURATION}s"
echo ""
