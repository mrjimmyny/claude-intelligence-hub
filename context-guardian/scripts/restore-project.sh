#!/bin/bash
# Context Guardian - Project Context Restore Script
# Restores project-specific context with rollback protection

# Source logging library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging-lib.sh"

# Configuration
RCLONE_REMOTE="gdrive-jimmy"
GDRIVE_FOLDER="Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory"
TEMP_DIR="/tmp/context-guardian-project-restore-$$"
ROLLBACK_DIR=".context-guardian-rollback_$(date +"%Y%m%d_%H%M%S")"

# Parse arguments
DRY_RUN=false
PROJECT_NAME=""
SKIP_CONFIRMATION=false

for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            ;;
        --project-name)
            shift
            PROJECT_NAME="$1"
            ;;
        --yes)
            SKIP_CONFIRMATION=true
            ;;
    esac
    shift 2>/dev/null || true
done

# Error handler
handle_restore_error() {
    log_error "Restore failed! Initiating rollback..."

    if [ -d "$ROLLBACK_DIR" ]; then
        # Restore from rollback
        [ -f "$ROLLBACK_DIR/CLAUDE.md" ] && cp "$ROLLBACK_DIR/CLAUDE.md" . 2>/dev/null
        [ -f "$ROLLBACK_DIR/MEMORY.md" ] && cp "$ROLLBACK_DIR/MEMORY.md" . 2>/dev/null
        [ -d "$ROLLBACK_DIR/.claude" ] && cp -r "$ROLLBACK_DIR/.claude" . 2>/dev/null

        log_success "Rollback completed"
    else
        log_error "Rollback directory not found!"
    fi

    log_summary "failed" "Restore failed and rolled back"
    exit 1
}

trap 'handle_restore_error' ERR

# ==============================================================================
# Pre-flight Checks
# ==============================================================================

log_banner "Context Guardian - Project Context Restore"

log_info "Running pre-flight checks..."

# Check rclone
if ! command -v rclone &> /dev/null; then
    log_error "rclone not installed"
    exit 1
fi
log_success "rclone found"

# ==============================================================================
# Fetch PROJECTS_INDEX.json
# ==============================================================================

log_info "Fetching projects index from Google Drive..."

mkdir -p "$TEMP_DIR"

rclone copy "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/PROJECTS_INDEX.json" "$TEMP_DIR/" --verbose

if [ ! -f "$TEMP_DIR/PROJECTS_INDEX.json" ]; then
    log_error "Failed to fetch projects index"
    exit 1
fi

log_success "Projects index fetched"

# ==============================================================================
# Interactive Project Selection
# ==============================================================================

if [ -z "$PROJECT_NAME" ]; then
    echo ""
    echo "Available projects:"
    echo ""

    PROJECT_COUNT=0
    while read -r project; do
        PROJECT_COUNT=$((PROJECT_COUNT + 1))
        NAME=$(echo "$project" | jq -r '.name')
        LAST_BACKUP=$(echo "$project" | jq -r '.last_backup')
        BACKUP_BY=$(echo "$project" | jq -r '.backup_by')
        SIZE=$(echo "$project" | jq -r '.size_human')

        echo "[$PROJECT_COUNT] $NAME"
        echo "    Last backup: $LAST_BACKUP by $BACKUP_BY"
        echo "    Size: $SIZE"
        echo ""
    done < <(jq -c '.projects[]' "$TEMP_DIR/PROJECTS_INDEX.json")

    if [ $PROJECT_COUNT -eq 0 ]; then
        log_error "No projects found in index"
        exit 1
    fi

    read -p "Select project [1-$PROJECT_COUNT]: " PROJECT_NUM

    if [ -z "$PROJECT_NUM" ] || [ "$PROJECT_NUM" -lt 1 ] || [ "$PROJECT_NUM" -gt $PROJECT_COUNT ]; then
        log_error "Invalid selection"
        exit 1
    fi

    PROJECT_NAME=$(jq -r ".projects[$((PROJECT_NUM - 1))].name" "$TEMP_DIR/PROJECTS_INDEX.json")
    log_info "Selected project: $PROJECT_NAME"
fi

# Get project info
PROJECT_INFO=$(jq -r ".projects[] | select(.name == \"$PROJECT_NAME\")" "$TEMP_DIR/PROJECTS_INDEX.json")

if [ -z "$PROJECT_INFO" ]; then
    log_error "Project '$PROJECT_NAME' not found in index"
    exit 1
fi

BACKUP_BY=$(echo "$PROJECT_INFO" | jq -r '.backup_by')
LAST_BACKUP=$(echo "$PROJECT_INFO" | jq -r '.last_backup')
SIZE_HUMAN=$(echo "$PROJECT_INFO" | jq -r '.size_human')
HAS_CLAUDE_MD=$(echo "$PROJECT_INFO" | jq -r '.has_claude_md')
HAS_MEMORY_MD=$(echo "$PROJECT_INFO" | jq -r '.has_memory_md')
MEMORY_IS_HARD_LINK=$(echo "$PROJECT_INFO" | jq -r '.memory_md_is_hard_link')
HAS_LOCAL_SKILLS=$(echo "$PROJECT_INFO" | jq -r '.has_local_skills')

echo ""
echo "Project Information:"
echo "  Name: $PROJECT_NAME"
echo "  Backed up by: $BACKUP_BY"
echo "  Backup date: $LAST_BACKUP"
echo "  Size: $SIZE_HUMAN"
echo "  Files: $([ "$HAS_CLAUDE_MD" = "true" ] && echo -n "CLAUDE.md "; [ "$HAS_MEMORY_MD" = "true" ] && echo -n "MEMORY.md "; [ "$HAS_LOCAL_SKILLS" = "true" ] && echo -n "local-skills")"
echo ""

# Confirmation
if [ "$SKIP_CONFIRMATION" = false ] && [ "$DRY_RUN" = false ]; then
    read -p "Restore this project? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Restore cancelled"
        exit 0
    fi
fi

# ==============================================================================
# Download Files
# ==============================================================================

log_info "Downloading project from Google Drive..."

if [ "$DRY_RUN" = false ]; then
    rclone copy "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/projects/$PROJECT_NAME/" "$TEMP_DIR/project/" --verbose --progress

    # Download metadata
    rclone copy "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/projects/$PROJECT_NAME/project-metadata.json" "$TEMP_DIR/" --verbose

    log_success "Files downloaded"
else
    log_info "[DRY-RUN] Would download from: ${RCLONE_REMOTE}:${GDRIVE_FOLDER}/projects/$PROJECT_NAME/"
fi

# ==============================================================================
# Create Rollback Point
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    log_info "Creating rollback point: $ROLLBACK_DIR"

    mkdir -p "$ROLLBACK_DIR"

    [ -f "CLAUDE.md" ] && cp "CLAUDE.md" "$ROLLBACK_DIR/"
    [ -f "MEMORY.md" ] && cp "MEMORY.md" "$ROLLBACK_DIR/"
    [ -d ".claude" ] && cp -r ".claude" "$ROLLBACK_DIR/"

    log_success "Rollback point created"
else
    log_info "[DRY-RUN] Would create rollback point"
fi

# ==============================================================================
# Handle MEMORY.md Hard Links
# ==============================================================================

SKIP_MEMORY=false

if [ "$HAS_MEMORY_MD" = "true" ] && [ "$MEMORY_IS_HARD_LINK" = "true" ]; then
    # Check metadata for hard link target
    HARD_LINK_TARGET=$(jq -r '.files.MEMORY_md.hard_link_target' "$TEMP_DIR/project-metadata.json" 2>/dev/null || echo "")

    if [ -n "$HARD_LINK_TARGET" ] && [ -f "$HARD_LINK_TARGET" ]; then
        log_warn "MEMORY.md was a hard link to: $HARD_LINK_TARGET"
        log_warn "Master file exists - SKIPPING restore to avoid breaking hard link"
        log_warn "If you need to restore MEMORY.md, manually copy from backup"

        SKIP_MEMORY=true
    else
        log_warn "MEMORY.md was a hard link to: $HARD_LINK_TARGET"
        log_warn "Master file MISSING - will restore as regular file"
        log_warn "Hard link will be broken (run xavier-memory/setup_memory_junctions.bat to recreate)"

        SKIP_MEMORY=false
    fi
fi

# ==============================================================================
# Restore Files
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    log_info "Restoring files to current directory..."

    # Restore CLAUDE.md
    if [ "$HAS_CLAUDE_MD" = "true" ] && [ -f "$TEMP_DIR/project/CLAUDE.md" ]; then
        cp "$TEMP_DIR/project/CLAUDE.md" .
        log_success "Restored CLAUDE.md"
    fi

    # Restore MEMORY.md (if not skipped)
    if [ "$HAS_MEMORY_MD" = "true" ] && [ "$SKIP_MEMORY" = false ] && [ -f "$TEMP_DIR/project/MEMORY.md" ]; then
        cp "$TEMP_DIR/project/MEMORY.md" .
        log_success "Restored MEMORY.md"
    elif [ "$SKIP_MEMORY" = true ]; then
        log_info "Skipped MEMORY.md (hard link protection)"
    fi

    # Restore local skills
    if [ "$HAS_LOCAL_SKILLS" = "true" ] && [ -d "$TEMP_DIR/project/local-skills" ]; then
        mkdir -p ".claude/skills"
        cp -r "$TEMP_DIR/project/local-skills"/* ".claude/skills/"
        log_success "Restored local skills"
    fi

    log_success "Files restored"
else
    log_info "[DRY-RUN] Would restore files to current directory"
fi

# ==============================================================================
# Post-Restore Validation
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    log_info "Validating restored files..."

    VALIDATION_FAILED=false

    # Check CLAUDE.md
    if [ "$HAS_CLAUDE_MD" = "true" ]; then
        if [ -f "CLAUDE.md" ]; then
            log_success "Check 1: CLAUDE.md exists"
        else
            log_error "Check 1: CLAUDE.md MISSING!"
            VALIDATION_FAILED=true
        fi
    fi

    # Check MEMORY.md
    if [ "$HAS_MEMORY_MD" = "true" ] && [ "$SKIP_MEMORY" = false ]; then
        if [ -f "MEMORY.md" ]; then
            log_success "Check 2: MEMORY.md exists"
        else
            log_error "Check 2: MEMORY.md MISSING!"
            VALIDATION_FAILED=true
        fi
    elif [ "$SKIP_MEMORY" = true ]; then
        log_info "Check 2: MEMORY.md skipped (hard link protection)"
    fi

    # Check local skills
    if [ "$HAS_LOCAL_SKILLS" = "true" ]; then
        if [ -d ".claude/skills" ]; then
            SKILL_COUNT=$(ls -1 ".claude/skills" 2>/dev/null | wc -l)
            log_success "Check 3: Local skills directory exists ($SKILL_COUNT skills)"
        else
            log_error "Check 3: Local skills directory MISSING!"
            VALIDATION_FAILED=true
        fi
    fi

    # Final verdict
    if [ "$VALIDATION_FAILED" = true ]; then
        log_error "VALIDATION FAILED!"
        exit 1
    else
        log_success "VALIDATION PASSED!"
    fi
else
    log_info "[DRY-RUN] Would run validation checks"
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

# Cleanup temp
rm -rf "$TEMP_DIR"

# ==============================================================================
# Summary
# ==============================================================================

log_summary "success" "Project context restored successfully"

echo ""
echo "Restore Summary:"
echo "  Project: $PROJECT_NAME"
echo "  Restored from: $BACKUP_BY ($LAST_BACKUP)"
echo "  Files: $([ "$HAS_CLAUDE_MD" = "true" ] && echo -n "CLAUDE.md "; [ "$HAS_MEMORY_MD" = "true" ] && [ "$SKIP_MEMORY" = false ] && echo -n "MEMORY.md "; [ "$HAS_LOCAL_SKILLS" = "true" ] && echo -n "local-skills")"
echo "  Validation: PASSED"

if [ "$SKIP_MEMORY" = true ]; then
    echo ""
    echo "  ⚠️  MEMORY.md was skipped because it's a hard link to xavier-memory master."
    echo "      If you need to restore it, manually copy from backup."
fi

echo ""
