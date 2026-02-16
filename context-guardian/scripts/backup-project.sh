#!/bin/bash
# Context Guardian - Project Context Backup Script
# Backs up project-specific CLAUDE.md, MEMORY.md, and local skills

# Source logging library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/logging-lib.sh"

# Configuration
RCLONE_REMOTE="gdrive-jimmy"
GDRIVE_FOLDER="Claude/_claude_intelligence_hub/_critical_bkp_xavier_local_persistent_memory"
BACKUP_DIR="$HOME/.claude/context-guardian/backups"
TEMP_DIR="/tmp/context-guardian-project-$$"

# Parse arguments
DRY_RUN=false
PROJECT_DIR="$(pwd)"

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

log_banner "Context Guardian - Project Context Backup"

log_info "Running pre-flight checks..."

# Check rclone
if ! command -v rclone &> /dev/null; then
    log_error "rclone is not installed"
    exit 1
fi
log_success "rclone found"

# Check rclone remote
if ! rclone listremotes 2>&1 | grep -q "^${RCLONE_REMOTE}:"; then
    log_error "rclone remote '$RCLONE_REMOTE' not configured"
    exit 1
fi
log_success "rclone remote configured"

# Auto-detect project directory
PROJECT_NAME=$(basename "$PROJECT_DIR")
log_info "Project directory: $PROJECT_DIR"
log_info "Project name: $PROJECT_NAME"

# ==============================================================================
# Check for .contextignore
# ==============================================================================

RSYNC_EXCLUDE=""
CONTEXTIGNORE_USED=false
EXCLUDE_PATTERNS=()

if [ -f "$PROJECT_DIR/.contextignore" ]; then
    log_success "Using .contextignore exclusion patterns"
    RSYNC_EXCLUDE="--exclude-from=$PROJECT_DIR/.contextignore"
    CONTEXTIGNORE_USED=true

    # Read patterns into array
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        EXCLUDE_PATTERNS+=("$line")
    done < "$PROJECT_DIR/.contextignore"
else
    # Default exclusions
    RSYNC_EXCLUDE="--exclude=node_modules --exclude=.git --exclude=__pycache__ --exclude=dist --exclude=build"
    EXCLUDE_PATTERNS=("node_modules/" ".git/" "__pycache__/" "dist/" "build/")
    log_info "Using default exclusions (node_modules, .git, __pycache__, dist, build)"
fi

# ==============================================================================
# Calculate Size
# ==============================================================================

log_info "Calculating project size (excluding ignored files)..."

# Create temp rsync exclude file for du
EXCLUDE_FILE="$TEMP_DIR/exclude.txt"
mkdir -p "$TEMP_DIR"
printf "%s\n" "${EXCLUDE_PATTERNS[@]}" > "$EXCLUDE_FILE"

# Calculate size (approximate - du doesn't support --exclude-from)
PROJECT_SIZE_BYTES=0
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    RSYNC_EXCLUDE_DU="$RSYNC_EXCLUDE_DU --exclude=$pattern"
done

# Simple approach: calculate total, warn if needed
PROJECT_SIZE_BYTES=$(du -sb "$PROJECT_DIR" 2>/dev/null | cut -f1 || echo "0")
PROJECT_SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B "$PROJECT_SIZE_BYTES" 2>/dev/null || echo "unknown")

log_info "Project size (approximate, may include excluded files): $PROJECT_SIZE_HUMAN"

# Warn if too large
if [ "$PROJECT_SIZE_BYTES" -gt 524288000 ]; then  # 500 MB
    log_warn "Project size exceeds 500 MB!"
    log_warn "Consider adding more exclusions to .contextignore"

    if [ "$DRY_RUN" = false ]; then
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Backup aborted by user (project too large)"
            exit 1
        fi
    fi
fi

# ==============================================================================
# Find Files to Backup
# ==============================================================================

log_info "Scanning project files..."

HAS_CLAUDE_MD=false
HAS_MEMORY_MD=false
HAS_LOCAL_SKILLS=false

# Check CLAUDE.md
if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
    HAS_CLAUDE_MD=true
    CLAUDE_MD_SIZE=$(stat -c%s "$PROJECT_DIR/CLAUDE.md" 2>/dev/null || stat -f%z "$PROJECT_DIR/CLAUDE.md" 2>/dev/null)
    CLAUDE_MD_SHA=$(sha256sum "$PROJECT_DIR/CLAUDE.md" | cut -d' ' -f1)
    log_success "Found CLAUDE.md ($(numfmt --to=iec-i --suffix=B $CLAUDE_MD_SIZE))"
fi

# Check MEMORY.md and detect hard links
MEMORY_IS_HARD_LINK=false
MEMORY_HARD_LINK_TARGET=""
MEMORY_HARD_LINK_COUNT=0

if [ -f "$PROJECT_DIR/MEMORY.md" ]; then
    HAS_MEMORY_MD=true
    MEMORY_MD_SIZE=$(stat -c%s "$PROJECT_DIR/MEMORY.md" 2>/dev/null || stat -f%z "$PROJECT_DIR/MEMORY.md" 2>/dev/null)
    MEMORY_MD_SHA=$(sha256sum "$PROJECT_DIR/MEMORY.md" | cut -d' ' -f1)

    # Detect hard links (Linux/Git Bash)
    if command -v stat &> /dev/null; then
        INODE=$(stat -c %i "$PROJECT_DIR/MEMORY.md" 2>/dev/null || stat -f %i "$PROJECT_DIR/MEMORY.md" 2>/dev/null)
        HARDLINKS=$(find ~/ -inum "$INODE" 2>/dev/null | wc -l)

        if [ "$HARDLINKS" -gt 1 ]; then
            MEMORY_IS_HARD_LINK=true
            MEMORY_HARD_LINK_COUNT=$HARDLINKS
            MEMORY_HARD_LINK_TARGET=$(find ~/ -inum "$INODE" 2>/dev/null | grep -i "xavier-memory" | head -n 1)

            if [ -n "$MEMORY_HARD_LINK_TARGET" ]; then
                log_warn "MEMORY.md is a hard link to xavier-memory master (links: $HARDLINKS)"
                log_warn "Will NOT backup file content (already in xavier-memory)"
            else
                log_warn "MEMORY.md is a hard link (links: $HARDLINKS, master unknown)"
            fi
        else
            log_success "Found MEMORY.md ($(numfmt --to=iec-i --suffix=B $MEMORY_MD_SIZE)) - regular file"
        fi
    else
        log_success "Found MEMORY.md ($(numfmt --to=iec-i --suffix=B $MEMORY_MD_SIZE))"
    fi
fi

# Check local skills
if [ -d "$PROJECT_DIR/.claude/skills" ]; then
    SKILL_COUNT=$(ls -1 "$PROJECT_DIR/.claude/skills" 2>/dev/null | wc -l)
    if [ "$SKILL_COUNT" -gt 0 ]; then
        HAS_LOCAL_SKILLS=true
        log_success "Found local skills directory ($SKILL_COUNT skills)"
    fi
fi

# Check if anything to backup
if [ "$HAS_CLAUDE_MD" = false ] && [ "$HAS_MEMORY_MD" = false ] && [ "$HAS_LOCAL_SKILLS" = false ]; then
    log_warn "No project context files found (CLAUDE.md, MEMORY.md, or .claude/skills/)"
    log_warn "Nothing to backup for this project"
    exit 0
fi

# ==============================================================================
# Collect Files
# ==============================================================================

log_info "Preparing backup workspace..."

mkdir -p "$TEMP_DIR/project"

# Copy CLAUDE.md
if [ "$HAS_CLAUDE_MD" = true ]; then
    cp "$PROJECT_DIR/CLAUDE.md" "$TEMP_DIR/project/"
    log_info "Collected CLAUDE.md"
fi

# Copy MEMORY.md (only if NOT hard link)
if [ "$HAS_MEMORY_MD" = true ] && [ "$MEMORY_IS_HARD_LINK" = false ]; then
    cp "$PROJECT_DIR/MEMORY.md" "$TEMP_DIR/project/"
    log_info "Collected MEMORY.md"
elif [ "$MEMORY_IS_HARD_LINK" = true ]; then
    log_info "Skipped MEMORY.md (hard link - metadata only)"
fi

# Copy local skills
if [ "$HAS_LOCAL_SKILLS" = true ]; then
    mkdir -p "$TEMP_DIR/project/local-skills"
    cp -r "$PROJECT_DIR/.claude/skills"/* "$TEMP_DIR/project/local-skills/" 2>/dev/null || true
    log_info "Collected local skills"
fi

# ==============================================================================
# Generate Metadata
# ==============================================================================

log_info "Generating metadata..."

BACKUP_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BACKUP_BY="xavier"

# Calculate total backup size
BACKUP_SIZE_BYTES=$(du -sb "$TEMP_DIR/project" 2>/dev/null | cut -f1)
BACKUP_SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B "$BACKUP_SIZE_BYTES" 2>/dev/null)

# Build files JSON
FILES_JSON="{"

if [ "$HAS_CLAUDE_MD" = true ]; then
    FILES_JSON="$FILES_JSON
    \"CLAUDE_md\": {
      \"exists\": true,
      \"sha256\": \"$CLAUDE_MD_SHA\",
      \"size_bytes\": $CLAUDE_MD_SIZE
    }"
else
    FILES_JSON="$FILES_JSON
    \"CLAUDE_md\": {
      \"exists\": false
    }"
fi

if [ "$HAS_MEMORY_MD" = true ]; then
    FILES_JSON="$FILES_JSON,
    \"MEMORY_md\": {
      \"exists\": true,
      \"is_hard_link\": $MEMORY_IS_HARD_LINK,
      \"hard_link_target\": \"$MEMORY_HARD_LINK_TARGET\",
      \"hard_link_count\": $MEMORY_HARD_LINK_COUNT,
      \"sha256\": \"$MEMORY_MD_SHA\",
      \"size_bytes\": $MEMORY_MD_SIZE
    }"
else
    FILES_JSON="$FILES_JSON,
    \"MEMORY_md\": {
      \"exists\": false
    }"
fi

FILES_JSON="$FILES_JSON
  }"

# Build exclusions JSON
EXCLUDE_PATTERNS_JSON=$(printf '%s\n' "${EXCLUDE_PATTERNS[@]}" | jq -R . | jq -s .)

# Create project-metadata.json
cat > "$TEMP_DIR/project-metadata.json" <<EOF
{
  "project_name": "$PROJECT_NAME",
  "project_path": "$PROJECT_DIR",
  "backup_timestamp": "$BACKUP_TIMESTAMP",
  "backup_by": "$BACKUP_BY",
  "format_version": "1.0",
  "files": $FILES_JSON,
  "local_skills": {
    "exists": $HAS_LOCAL_SKILLS,
    "count": ${SKILL_COUNT:-0}
  },
  "exclusions": {
    "contextignore_used": $CONTEXTIGNORE_USED,
    "excluded_patterns": $EXCLUDE_PATTERNS_JSON,
    "excluded_bytes": 0
  },
  "total_size_bytes": $BACKUP_SIZE_BYTES,
  "total_size_human": "$BACKUP_SIZE_HUMAN"
}
EOF

log_success "Metadata generated"

# ==============================================================================
# Update PROJECTS_INDEX.json
# ==============================================================================

log_info "Updating PROJECTS_INDEX.json..."

# Download existing index (if exists)
INDEX_FILE="$TEMP_DIR/PROJECTS_INDEX.json"
rclone copy "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/PROJECTS_INDEX.json" "$TEMP_DIR/" 2>/dev/null || true

if [ ! -f "$INDEX_FILE" ]; then
    # Create new index
    cat > "$INDEX_FILE" <<EOF
{
  "format_version": "1.0",
  "last_updated": "$BACKUP_TIMESTAMP",
  "projects": []
}
EOF
fi

# Add or update project entry
PROJECT_ENTRY=$(cat <<EOF
{
  "name": "$PROJECT_NAME",
  "path": "$PROJECT_DIR",
  "last_backup": "$BACKUP_TIMESTAMP",
  "backup_by": "$BACKUP_BY",
  "size_bytes": $BACKUP_SIZE_BYTES,
  "size_human": "$BACKUP_SIZE_HUMAN",
  "has_claude_md": $HAS_CLAUDE_MD,
  "has_memory_md": $HAS_MEMORY_MD,
  "memory_md_is_hard_link": $MEMORY_IS_HARD_LINK,
  "has_local_skills": $HAS_LOCAL_SKILLS,
  "backup_location": "projects/$PROJECT_NAME/"
}
EOF
)

# Remove existing entry (if any) and add new one
UPDATED_INDEX=$(jq --argjson entry "$PROJECT_ENTRY" '
  .last_updated = "'$BACKUP_TIMESTAMP'" |
  .projects = (.projects | map(select(.name != "'$PROJECT_NAME'")) + [$entry])
' "$INDEX_FILE")

echo "$UPDATED_INDEX" > "$INDEX_FILE"

log_success "PROJECTS_INDEX.json updated"

# ==============================================================================
# Sync to Google Drive
# ==============================================================================

if [ "$DRY_RUN" = false ]; then
    log_info "Syncing to Google Drive..."

    # Upload project folder
    rclone copy "$TEMP_DIR/project" "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/projects/$PROJECT_NAME/" --verbose --progress

    # Upload metadata
    rclone copy "$TEMP_DIR/project-metadata.json" "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/projects/$PROJECT_NAME/" --verbose

    # Upload updated index
    rclone copy "$INDEX_FILE" "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/" --verbose

    log_success "Synced to Google Drive"
else
    log_info "[DRY-RUN] Would sync to: ${RCLONE_REMOTE}:${GDRIVE_FOLDER}/projects/$PROJECT_NAME/"
fi

# ==============================================================================
# Git Commit (if in Git repo)
# ==============================================================================

if [ -d "$PROJECT_DIR/.git" ] && [ "$DRY_RUN" = false ]; then
    log_info "Detected Git repository - committing backup metadata..."

    cd "$PROJECT_DIR"
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git add .contextignore 2>/dev/null || true
        git commit -m "chore: context-guardian backup metadata updated

Project: $PROJECT_NAME
Timestamp: $BACKUP_TIMESTAMP
Size: $BACKUP_SIZE_HUMAN

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>" 2>/dev/null || log_info "No changes to commit"

        # Ask about push
        read -p "Push to remote? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push
            log_success "Pushed to remote"
        fi
    fi
fi

# ==============================================================================
# Cleanup
# ==============================================================================

rm -rf "$TEMP_DIR"

# ==============================================================================
# Summary
# ==============================================================================

log_summary "success" "Project context backed up successfully"

echo ""
echo "Backup Summary:"
echo "  Project: $PROJECT_NAME"
echo "  Backed up by: $BACKUP_BY"
echo "  Timestamp: $BACKUP_TIMESTAMP"
echo "  Files: $([ "$HAS_CLAUDE_MD" = true ] && echo -n "CLAUDE.md "; [ "$HAS_MEMORY_MD" = true ] && [ "$MEMORY_IS_HARD_LINK" = false ] && echo -n "MEMORY.md "; [ "$HAS_LOCAL_SKILLS" = true ] && echo -n "$SKILL_COUNT local skills")"
echo "  Size: $BACKUP_SIZE_HUMAN"
echo "  Location: ${RCLONE_REMOTE}:${GDRIVE_FOLDER}/projects/$PROJECT_NAME/"

if [ "$MEMORY_IS_HARD_LINK" = true ]; then
    echo ""
    echo "  ⚠️  MEMORY.md is a hard link - metadata stored, file not backed up"
fi

echo ""
