#!/bin/bash
# X-MEM Search Helper Script
# Usage: xmem-search.sh <query> [type=failures|successes|all]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
QUERY="$1"
TYPE="${2:-all}"

if [ -z "$QUERY" ]; then
    echo "Usage: xmem-search.sh <query> [type=failures|successes|all]"
    echo ""
    echo "Examples:"
    echo "  xmem-search.sh rclone"
    echo "  xmem-search.sh 'config error' failures"
    echo "  xmem-search.sh git-commit successes"
    exit 1
fi

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Searching X-MEM for: ${QUERY}${NC}"
echo ""

# Search function
search_file() {
    local file="$1"
    local label="$2"
    local color="$3"

    if [ ! -f "$file" ]; then
        return
    fi

    local matches=$(grep -i "$QUERY" "$file" || true)
    if [ -n "$matches" ]; then
        local count=$(echo "$matches" | wc -l)
        echo -e "${color}${label} (${count} matches):${NC}"
        echo ""

        echo "$matches" | while IFS= read -r line; do
            # Pretty print JSON
            echo "$line" | jq -C '{
                id: .id,
                tool: .tool,
                error: .error // .pattern_name,
                tags: .tags,
                ctx_hash: .ctx_hash
            }' 2>/dev/null || echo "$line"
            echo ""
        done
    fi
}

# Search based on type
case "$TYPE" in
    failures)
        search_file "$DATA_DIR/failures.jsonl" "Failures" "$RED"
        ;;
    successes)
        search_file "$DATA_DIR/successes.jsonl" "Successes" "$GREEN"
        ;;
    all)
        search_file "$DATA_DIR/failures.jsonl" "Failures" "$RED"
        search_file "$DATA_DIR/successes.jsonl" "Successes" "$GREEN"
        ;;
    *)
        echo "Error: Invalid type. Use: failures, successes, or all"
        exit 1
        ;;
esac

echo -e "${BLUE}Search complete.${NC}"
