#!/bin/bash
# Google Drive Sync Wrapper Script
# Usage: ./sync-gdrive.sh
# Or: claude code -c "bash gdrive-sync-memoria/sync-gdrive.sh"

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HUB_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SCRIPT_DIR/config/drive_folders.json"
TEMP_DIR="$SCRIPT_DIR/temp"
LOG_FILE="$SCRIPT_DIR/logs/sync_history.log"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Iniciando sincronização Google Drive...${NC}"

# Ensure temp and logs directories exist
mkdir -p "$TEMP_DIR" "$SCRIPT_DIR/logs"

# Read config
REMOTE=$(jq -r '.rclone_remote' "$CONFIG_FILE")
INPUT_FOLDER=$(jq -r '.input_folder' "$CONFIG_FILE")
PROCESSED_FOLDER=$(jq -r '.processed_folder' "$CONFIG_FILE")

# List files in input folder
echo -e "${BLUE}📥 Verificando arquivos pendentes...${NC}"
FILES=$(rclone lsf "$REMOTE:$INPUT_FOLDER/" --files-only --include "*.md")

if [ -z "$FILES" ]; then
    echo -e "${GREEN}✅ Nenhum arquivo pendente no Google Drive.${NC}"
    # Update metadata last_sync
    cd "$HUB_DIR"
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    jq ".gdrive_sync.last_sync = \"$TIMESTAMP\"" session-memoria/knowledge/metadata.json > tmp.$$.json && mv tmp.$$.json session-memoria/knowledge/metadata.json
    echo -e "${GREEN}Tudo atualizado!${NC}"
    exit 0
fi

FILE_COUNT=$(echo "$FILES" | wc -l)
echo -e "${GREEN}📥 Encontrados $FILE_COUNT arquivo(s) para processar${NC}"
echo "$FILES"
echo ""

# Notify user that Xavier will take over
echo -e "${YELLOW}⚡ Delegando processamento para Xavier...${NC}"
echo -e "${YELLOW}Xavier processará: download, parse, session-memoria entry, indexes, git commit/push${NC}"
echo ""

# Log sync start
echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO START: Sync initiated via wrapper script" >> "$LOG_FILE"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO FOUND: $FILE_COUNT files in $INPUT_FOLDER" >> "$LOG_FILE"

# Return file list for Xavier to process
echo -e "${BLUE}📋 Arquivos para processar:${NC}"
echo "$FILES" | while read -r file; do
    echo "  - $file"
done

echo ""
echo -e "${YELLOW}💡 Xavier, por favor processe estes arquivos seguindo o fluxo gdrive-sync-memoria/SKILL.md${NC}"
