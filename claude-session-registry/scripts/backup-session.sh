#!/bin/bash
# backup-session.sh
# Orchestrates session backup to claude-session-backups repository
#
# Usage: backup-session.sh <session_id> <session_metadata_json>
#
# This script is automatically triggered after session registration (Step 9)
# Can also be run manually for retroactive backups
#
# Workflow:
#   1. Locate session .jsonl file
#   2. Extract date components (YYYY/MM)
#   3. Create directory structure
#   4. Generate markdown transcript
#   5. Copy .jsonl if #critical tag present
#   6. Update indexes (by-date, by-tag, by-machine)
#   7. Update metadata.json
#   8. Git commit
#   9. Git push (with retry)
#   10. Success summary

set -euo pipefail

# Configuration
BACKUP_REPO="$HOME/claude-session-backups"
REGISTRY_DIR="$HOME/Downloads/claude-intelligence-hub/claude-session-registry"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find jq (check multiple locations)
if command -v jq &> /dev/null; then
    JQ="jq"
elif [ -f "$HOME/bin/jq.exe" ]; then
    JQ="$HOME/bin/jq.exe"
elif [ -f "$HOME/bin/jq" ]; then
    JQ="$HOME/bin/jq"
else
    echo "❌ Error: jq not found. Please install jq."
    echo "💡 Download from: https://jqlang.github.io/jq/download/"
    exit 1
fi

# Arguments
SESSION_ID="${1:-}"
METADATA_JSON="${2:-}"

# Validate arguments
if [ -z "$SESSION_ID" ] || [ -z "$METADATA_JSON" ]; then
    echo "❌ Error: Missing required arguments"
    echo "Usage: $0 <session_id> <metadata_json>"
    exit 1
fi

# Validate backup repo exists
if [ ! -d "$BACKUP_REPO" ]; then
    echo "❌ Error: Backup repository not found: $BACKUP_REPO"
    echo "💡 Initialize: cd ~ && git clone git@github.com:mrjimmyny/claude-session-backups.git"
    exit 1
fi

# Extract metadata fields
SESSION_DATE=$(echo "$METADATA_JSON" | $JQ -r '.date // ""')
SESSION_TIME=$(echo "$METADATA_JSON" | $JQ -r '.time // ""')
SESSION_TAGS=$(echo "$METADATA_JSON" | $JQ -r '.tags // ""')
SESSION_SUMMARY=$(echo "$METADATA_JSON" | $JQ -r '.summary // ""')
SESSION_PROJECT=$(echo "$METADATA_JSON" | $JQ -r '.project // ""')
SESSION_MACHINE=$(echo "$METADATA_JSON" | $JQ -r '.machine // ""')
SESSION_BRANCH=$(echo "$METADATA_JSON" | $JQ -r '.branch // ""')
SESSION_COMMIT=$(echo "$METADATA_JSON" | $JQ -r '.commit // ""')

# Validate required fields
if [ -z "$SESSION_DATE" ]; then
    echo "❌ Error: Session date not found in metadata"
    exit 1
fi

# Check if critical
IS_CRITICAL=false
if [[ "$SESSION_TAGS" == *"#critical"* ]]; then
    IS_CRITICAL=true
fi

echo "🔄 Starting session backup..."
echo "   Session ID: $SESSION_ID"
echo "   Date: $SESSION_DATE"
echo "   Tags: $SESSION_TAGS"
echo "   Critical: $IS_CRITICAL"

# ========== STEP 1: Locate Session File ==========
echo ""
echo "📍 Step 1/10: Locating session file..."

# Convert project path to slug
# Example: /c/Users/jaderson.almeida/Downloads → C--Users-jaderson-almeida-Downloads
# Claude converts: / → -, : → --, . → -, and uppercases drive letter
PROJECT_SLUG=$(echo "$SESSION_PROJECT" | sed 's|^/\([a-z]\)/|\U\1--|; s|/|-|g; s|\.|-|g')
PROJECT_DIR="$HOME/.claude/projects/$PROJECT_SLUG"

JSONL_FILE="$PROJECT_DIR/$SESSION_ID.jsonl"

# Validate file exists
if [ ! -f "$JSONL_FILE" ]; then
    echo "❌ Error: Session file not found: $JSONL_FILE"
    echo "💡 The session may have been deleted or moved"
    echo "💡 Debug: Project=$SESSION_PROJECT, Slug=$PROJECT_SLUG"
    exit 1
fi

echo "   ✅ Found: $JSONL_FILE"

# ========== STEP 2: Extract Date Components ==========
echo ""
echo "📅 Step 2/10: Extracting date components..."

YEAR=$(echo "$SESSION_DATE" | cut -d'-' -f1)
MONTH=$(echo "$SESSION_DATE" | cut -d'-' -f2)

echo "   Year: $YEAR"
echo "   Month: $MONTH"

# ========== STEP 3: Create Directory Structure ==========
echo ""
echo "📁 Step 3/10: Creating directory structure..."

mkdir -p "$BACKUP_REPO/transcripts/$YEAR/$MONTH"
echo "   ✅ Created: transcripts/$YEAR/$MONTH"

if [ "$IS_CRITICAL" = true ]; then
    mkdir -p "$BACKUP_REPO/critical/$YEAR/$MONTH"
    echo "   ✅ Created: critical/$YEAR/$MONTH"
fi

# ========== STEP 4: Generate Markdown Transcript ==========
echo ""
echo "📝 Step 4/10: Generating markdown transcript..."

OUTPUT_MD="$BACKUP_REPO/transcripts/$YEAR/$MONTH/$SESSION_ID.md"

bash "$SCRIPTS_DIR/parse-jsonl-to-markdown.sh" \
    "$SESSION_ID" \
    "$JSONL_FILE" \
    "$OUTPUT_MD" \
    "$METADATA_JSON"

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to generate markdown transcript"
    exit 1
fi

echo "   ✅ Transcript: transcripts/$YEAR/$MONTH/$SESSION_ID.md"

# ========== STEP 5: Copy Critical .jsonl ==========
if [ "$IS_CRITICAL" = true ]; then
    echo ""
    echo "💾 Step 5/10: Copying critical .jsonl backup..."

    cp "$JSONL_FILE" "$BACKUP_REPO/critical/$YEAR/$MONTH/$SESSION_ID.jsonl"

    if [ $? -eq 0 ]; then
        echo "   ✅ Critical backup: critical/$YEAR/$MONTH/$SESSION_ID.jsonl"
    else
        echo "   ⚠️  Warning: Failed to copy .jsonl (continuing with transcript only)"
    fi
else
    echo ""
    echo "⏭️  Step 5/10: Skipping .jsonl copy (not critical)"
fi

# ========== STEP 6: Update Indexes ==========
echo ""
echo "📑 Step 6/10: Updating indexes..."

# by-date index
DATE_INDEX="$BACKUP_REPO/indexes/by-date/$YEAR-$MONTH.md"
mkdir -p "$(dirname "$DATE_INDEX")"

if [ ! -f "$DATE_INDEX" ]; then
    cat > "$DATE_INDEX" <<EOF
# Sessions: $YEAR-$MONTH

Auto-generated index of all sessions backed up in $YEAR-$MONTH.

EOF
fi

# Add entry to date index
SHORT_ID=$(echo "$SESSION_ID" | cut -c1-8)
SHORT_SUMMARY=$(echo "$SESSION_SUMMARY" | head -c 60)
echo "- [$SESSION_DATE] [\`$SHORT_ID\`](../../transcripts/$YEAR/$MONTH/$SESSION_ID.md) $SESSION_TAGS - $SHORT_SUMMARY" >> "$DATE_INDEX"
echo "   ✅ Updated: indexes/by-date/$YEAR-$MONTH.md"

# by-tag indexes
IFS=' ' read -ra TAG_ARRAY <<< "$SESSION_TAGS"
for TAG in "${TAG_ARRAY[@]}"; do
    # Remove # prefix for filename
    TAG_NAME="${TAG#\#}"
    if [ -z "$TAG_NAME" ]; then
        continue
    fi

    TAG_INDEX="$BACKUP_REPO/indexes/by-tag/$TAG_NAME.md"
    mkdir -p "$(dirname "$TAG_INDEX")"

    if [ ! -f "$TAG_INDEX" ]; then
        cat > "$TAG_INDEX" <<EOF
# Sessions: $TAG

Auto-generated index of all sessions tagged with \`$TAG\`.

EOF
    fi

    echo "- [$SESSION_DATE] [\`$SHORT_ID\`](../../transcripts/$YEAR/$MONTH/$SESSION_ID.md) - $SHORT_SUMMARY" >> "$TAG_INDEX"
done
echo "   ✅ Updated tag indexes"

# by-machine index
if [ -n "$SESSION_MACHINE" ]; then
    MACHINE_INDEX="$BACKUP_REPO/indexes/by-machine/$SESSION_MACHINE.md"
    mkdir -p "$(dirname "$MACHINE_INDEX")"

    if [ ! -f "$MACHINE_INDEX" ]; then
        cat > "$MACHINE_INDEX" <<EOF
# Sessions: $SESSION_MACHINE

Auto-generated index of all sessions from machine \`$SESSION_MACHINE\`.

EOF
    fi

    echo "- [$SESSION_DATE] [\`$SHORT_ID\`](../../transcripts/$YEAR/$MONTH/$SESSION_ID.md) $SESSION_TAGS - $SHORT_SUMMARY" >> "$MACHINE_INDEX"
    echo "   ✅ Updated: indexes/by-machine/$SESSION_MACHINE.md"
fi

# ========== STEP 7: Update Metadata.json ==========
echo ""
echo "📊 Step 7/10: Updating metadata.json..."

METADATA_FILE="$BACKUP_REPO/metadata.json"

# Read current values
CURRENT_TOTAL=$($JQ -r '.total_backups // 0' "$METADATA_FILE")
CURRENT_CRITICAL=$($JQ -r '.total_critical // 0' "$METADATA_FILE")

# Increment
NEW_TOTAL=$((CURRENT_TOTAL + 1))
if [ "$IS_CRITICAL" = true ]; then
    NEW_CRITICAL=$((CURRENT_CRITICAL + 1))
else
    NEW_CRITICAL=$CURRENT_CRITICAL
fi

# Update metadata
CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

$JQ \
    --arg total "$NEW_TOTAL" \
    --arg critical "$NEW_CRITICAL" \
    --arg date "$CURRENT_TIMESTAMP" \
    --arg session "$SESSION_ID" \
    '.total_backups = ($total | tonumber) |
     .total_critical = ($critical | tonumber) |
     .last_backup_date = $date |
     .last_backup_session = $session' \
    "$METADATA_FILE" > "$METADATA_FILE.tmp"

mv "$METADATA_FILE.tmp" "$METADATA_FILE"

echo "   ✅ Total backups: $NEW_TOTAL"
echo "   ✅ Critical backups: $NEW_CRITICAL"

# ========== STEP 8: Git Commit ==========
echo ""
echo "📦 Step 8/10: Creating git commit..."

cd "$BACKUP_REPO"

# Stage files
git add "transcripts/$YEAR/$MONTH/$SESSION_ID.md"
git add "indexes/"
git add "metadata.json"

if [ "$IS_CRITICAL" = true ]; then
    git add "critical/$YEAR/$MONTH/$SESSION_ID.jsonl"
fi

# Create commit message
SUMMARY_SHORT=$(echo "$SESSION_SUMMARY" | head -n 1 | head -c 100)

COMMIT_MSG=$(cat <<EOF
backup: add session $SHORT_ID - $SESSION_TAGS

Date: $SESSION_DATE $SESSION_TIME
Machine: $SESSION_MACHINE
Critical: $IS_CRITICAL

Summary: $SUMMARY_SHORT
EOF
)

git commit -m "$COMMIT_MSG"

if [ $? -eq 0 ]; then
    echo "   ✅ Commit created"
else
    echo "   ⚠️  Warning: Git commit failed (files may already be committed)"
fi

# ========== STEP 9: Git Push (with Retry) ==========
echo ""
echo "🚀 Step 9/10: Pushing to GitHub..."

PUSH_SUCCESS=false
for attempt in 1 2 3; do
    echo "   Attempt $attempt/3..."

    if git push origin main 2>&1; then
        PUSH_SUCCESS=true
        echo "   ✅ Push successful!"
        break
    else
        echo "   ⚠️  Push failed"
        if [ $attempt -lt 3 ]; then
            SLEEP_TIME=$((2 ** attempt))
            echo "   ⏳ Retrying in ${SLEEP_TIME}s..."
            sleep $SLEEP_TIME
        fi
    fi
done

if [ "$PUSH_SUCCESS" = false ]; then
    echo ""
    echo "❌ Error: Git push failed after 3 attempts"
    echo ""
    echo "📋 Manual recovery steps:"
    echo "   cd $BACKUP_REPO"
    echo "   git push origin main"
    echo ""
    echo "⚠️  Backup committed locally but not pushed to GitHub"
    exit 1
fi

# ========== STEP 10: Success Summary ==========
echo ""
echo "✅ Step 10/10: Backup complete!"
echo ""
echo "📊 Summary:"
echo "   📄 Transcript: transcripts/$YEAR/$MONTH/$SESSION_ID.md"

if [ "$IS_CRITICAL" = true ]; then
    echo "   💾 Critical backup: critical/$YEAR/$MONTH/$SESSION_ID.jsonl"
fi

echo "   📑 Indexes updated: by-date, by-tag, by-machine"
echo "   📈 Total backups: $NEW_TOTAL"
echo "   🔗 View: https://github.com/mrjimmyny/claude-session-backups"
echo ""

# Update local tracking file
TRACKING_FILE="$REGISTRY_DIR/backup-tracking.json"
if [ -f "$TRACKING_FILE" ]; then
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    $JQ \
        --arg id "$SESSION_ID" \
        --arg date "$TIMESTAMP" \
        --arg status "success" \
        '.backups[$id] = {
            "backup_date": $date,
            "status": $status,
            "is_critical": '"$IS_CRITICAL"'
        } |
        .stats.total_backups += 1 |
        .stats.total_critical += (if '"$IS_CRITICAL"' then 1 else 0 end) |
        .stats.last_backup = $date' \
        "$TRACKING_FILE" > "$TRACKING_FILE.tmp"

    mv "$TRACKING_FILE.tmp" "$TRACKING_FILE"
fi

echo "🎉 Backup process completed successfully!"
