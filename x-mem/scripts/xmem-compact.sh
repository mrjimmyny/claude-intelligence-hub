#!/bin/bash
# X-MEM Compaction Utility
# Removes duplicate and stale entries from NDJSON files
# Usage: xmem-compact.sh [--dry-run] [--rebuild-index]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
BACKUP_DIR="$DATA_DIR/backup"
DRY_RUN=false
REBUILD_INDEX=false

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --dry-run)
            DRY_RUN=true
            ;;
        --rebuild-index)
            REBUILD_INDEX=true
            ;;
        *)
            echo "Unknown argument: $arg"
            echo "Usage: xmem-compact.sh [--dry-run] [--rebuild-index]"
            exit 1
            ;;
    esac
done

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🗜️  X-MEM Compaction Utility${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN MODE - No changes will be made]${NC}"
    echo ""
fi

# Compact function
compact_file() {
    local file="$1"
    local label="$2"

    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}⚠️  $label not found: $file${NC}"
        return
    fi

    local original_count=$(wc -l < "$file")
    echo -e "${BLUE}Compacting $label...${NC}"
    echo "  Original entries: $original_count"

    # Create temp file with unique ctx_hash entries (keep most recent)
    local temp_file="/tmp/xmem_compact_$$.jsonl"

    # Sort by timestamp (descending), remove duplicates by ctx_hash
    cat "$file" | jq -s 'sort_by(.ts) | reverse | unique_by(.ctx_hash)' | jq -c '.[]' > "$temp_file"

    local compacted_count=$(wc -l < "$temp_file")
    local removed_count=$((original_count - compacted_count))

    echo "  Compacted entries: $compacted_count"
    echo -e "  ${GREEN}Removed duplicates: $removed_count${NC}"

    if [ "$DRY_RUN" = false ]; then
        # Create backup
        mkdir -p "$BACKUP_DIR"
        local timestamp=$(date +%Y%m%d_%H%M%S)
        cp "$file" "$BACKUP_DIR/$(basename "$file").$timestamp"
        echo "  Backup created: $BACKUP_DIR/$(basename "$file").$timestamp"

        # Replace original
        mv "$temp_file" "$file"
        echo -e "  ${GREEN}✅ Compaction complete${NC}"
    else
        rm "$temp_file"
        echo -e "  ${YELLOW}[DRY RUN] Changes not applied${NC}"
    fi

    echo ""
}

# Run compaction
compact_file "$DATA_DIR/failures.jsonl" "Failures"
compact_file "$DATA_DIR/successes.jsonl" "Successes"

# Rebuild index if requested
if [ "$REBUILD_INDEX" = true ] || [ "$DRY_RUN" = false ]; then
    echo -e "${BLUE}Rebuilding index...${NC}"

    # Count entries
    failures_count=$([ -f "$DATA_DIR/failures.jsonl" ] && wc -l < "$DATA_DIR/failures.jsonl" || echo 0)
    successes_count=$([ -f "$DATA_DIR/successes.jsonl" ] && wc -l < "$DATA_DIR/successes.jsonl" || echo 0)

    # Build indices (simplified - full implementation would parse NDJSON)
    # This is a placeholder - actual implementation needs JSON parsing

    if [ "$DRY_RUN" = false ]; then
        # Update index.json with new counts
        cat > "$DATA_DIR/index.json" <<EOF
{
  "version": "1.0.0",
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "total_entries": {
    "failures": $failures_count,
    "successes": $successes_count
  },
  "tool_index": {},
  "tag_index": {},
  "ctx_hash_index": {}
}
EOF
        echo -e "${GREEN}✅ Index rebuilt${NC}"
    else
        echo -e "${YELLOW}[DRY RUN] Index rebuild skipped${NC}"
    fi
fi

echo ""
echo -e "${GREEN}✅ Compaction complete${NC}"

if [ "$DRY_RUN" = true ]; then
    echo ""
    echo -e "${YELLOW}Run without --dry-run to apply changes${NC}"
fi
