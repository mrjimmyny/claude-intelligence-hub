#!/usr/bin/env bash
# Xavier Memory - Google Drive Sync Script
# Syncs MEMORY.md to Google Drive backup folder
# Created: 2026-02-15

set -euo pipefail

# Configuration
RCLONE_REMOTE="gdrive-jimmy"
GDRIVE_FOLDER="_critical_bkp_xavier_local_persistent_memory"
LOCAL_MEMORY="$HOME/Downloads/claude-intelligence-hub/xavier-memory/MEMORY.md"
BACKUP_DIR="$HOME/Downloads/claude-intelligence-hub/xavier-memory/backups"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "================================================================"
echo "Xavier Memory - Google Drive Sync"
echo "================================================================"
echo ""

# Verify rclone is installed
if ! command -v rclone &> /dev/null; then
    echo -e "${RED}ERROR: rclone is not installed or not in PATH${NC}"
    exit 1
fi

# Verify master MEMORY.md exists
if [[ ! -f "$LOCAL_MEMORY" ]]; then
    echo -e "${RED}ERROR: Master MEMORY.md not found at: $LOCAL_MEMORY${NC}"
    exit 1
fi

# Verify rclone remote is configured
if ! rclone listremotes | grep -q "^${RCLONE_REMOTE}:$"; then
    echo -e "${RED}ERROR: rclone remote '$RCLONE_REMOTE' not configured${NC}"
    echo "Run: rclone config"
    exit 1
fi

echo -e "${GREEN}✓${NC} rclone ready"
echo -e "${GREEN}✓${NC} Master MEMORY.md found"
echo -e "${GREEN}✓${NC} Remote '$RCLONE_REMOTE' configured"
echo ""

# Create local backup before sync
echo "Creating local backup..."
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
mkdir -p "$BACKUP_DIR"
cp "$LOCAL_MEMORY" "$BACKUP_DIR/MEMORY_${TIMESTAMP}.md"
echo -e "${GREEN}✓${NC} Local backup: $BACKUP_DIR/MEMORY_${TIMESTAMP}.md"
echo ""

# Sync to Google Drive
echo "Syncing to Google Drive..."
echo "  Remote: ${RCLONE_REMOTE}:${GDRIVE_FOLDER}/"
echo "  File: MEMORY.md"
echo ""

rclone copy "$LOCAL_MEMORY" "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/" \
    --verbose \
    --stats-one-line \
    --stats 2s

if [[ $? -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}✓${NC} Sync completed successfully"
    echo ""

    # Show Google Drive file info
    echo "Google Drive file info:"
    rclone lsl "${RCLONE_REMOTE}:${GDRIVE_FOLDER}/MEMORY.md" 2>/dev/null || echo "  (file info not available)"

    echo ""
    echo "================================================================"
    echo "Backup Summary"
    echo "================================================================"
    echo "  Local master: $LOCAL_MEMORY"
    echo "  Google Drive: ${RCLONE_REMOTE}:${GDRIVE_FOLDER}/MEMORY.md"
    echo "  Local backup: $BACKUP_DIR/MEMORY_${TIMESTAMP}.md"
    echo "  Status: SUCCESS"
    echo ""
else
    echo ""
    echo -e "${RED}✗${NC} Sync failed"
    echo "Check rclone configuration and network connection"
    exit 1
fi

# Keep only last 10 local backups
echo "Cleaning up old local backups (keeping last 10)..."
cd "$BACKUP_DIR"
ls -1t MEMORY_*.md 2>/dev/null | tail -n +11 | xargs -r rm
echo -e "${GREEN}✓${NC} Cleanup complete"
echo ""

echo "================================================================"
echo "Sync Complete!"
echo "================================================================"
