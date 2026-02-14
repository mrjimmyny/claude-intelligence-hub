#!/bin/bash
# X-MEM Statistics Generator
# Usage: xmem-stats.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}📊 X-MEM Statistics${NC}"
echo ""

# Count entries
failures_count=$([ -f "$DATA_DIR/failures.jsonl" ] && wc -l < "$DATA_DIR/failures.jsonl" || echo 0)
successes_count=$([ -f "$DATA_DIR/successes.jsonl" ] && wc -l < "$DATA_DIR/successes.jsonl" || echo 0)

echo -e "${CYAN}Total Entries:${NC}"
echo "  Failures:  $failures_count"
echo "  Successes: $successes_count"
echo ""

# File sizes
if [ -f "$DATA_DIR/failures.jsonl" ]; then
    failures_size=$(du -h "$DATA_DIR/failures.jsonl" | cut -f1)
else
    failures_size="0"
fi

if [ -f "$DATA_DIR/successes.jsonl" ]; then
    successes_size=$(du -h "$DATA_DIR/successes.jsonl" | cut -f1)
else
    successes_size="0"
fi

echo -e "${CYAN}Storage:${NC}"
echo "  failures.jsonl:  $failures_size"
echo "  successes.jsonl: $successes_size"
echo ""

# Top tools (failures)
if [ -f "$DATA_DIR/failures.jsonl" ] && [ "$failures_count" -gt 0 ]; then
    echo -e "${RED}Top Tools (by failures):${NC}"
    cat "$DATA_DIR/failures.jsonl" | jq -r '.tool' | sort | uniq -c | sort -rn | head -5 | while read count tool; do
        echo "  $count x $tool"
    done
    echo ""
fi

# Top tools (successes)
if [ -f "$DATA_DIR/successes.jsonl" ] && [ "$successes_count" -gt 0 ]; then
    echo -e "${GREEN}Top Tools (by successes):${NC}"
    cat "$DATA_DIR/successes.jsonl" | jq -r '.tool' | sort | uniq -c | sort -rn | head -5 | while read count tool; do
        echo "  $count x $tool"
    done
    echo ""
fi

# Most used tags
if [ -f "$DATA_DIR/failures.jsonl" ] && [ "$failures_count" -gt 0 ]; then
    echo -e "${CYAN}Most Used Tags:${NC}"
    cat "$DATA_DIR/failures.jsonl" "$DATA_DIR/successes.jsonl" 2>/dev/null | \
        jq -r '.tags[]?' | sort | uniq -c | sort -rn | head -10 | while read count tag; do
        echo "  $count x $tag"
    done
    echo ""
fi

# Recent entries
echo -e "${CYAN}Recent Entries (last 5):${NC}"
if [ -f "$DATA_DIR/failures.jsonl" ] || [ -f "$DATA_DIR/successes.jsonl" ]; then
    cat "$DATA_DIR/failures.jsonl" "$DATA_DIR/successes.jsonl" 2>/dev/null | \
        jq -s 'sort_by(.ts) | reverse | .[:5]' | \
        jq -r '.[] | "\(.id) (\(.tool)) - \(.error // .pattern_name)"' 2>/dev/null || echo "  No entries"
else
    echo "  No entries"
fi
echo ""

# Index status
if [ -f "$DATA_DIR/index.json" ]; then
    index_updated=$(jq -r '.last_updated' "$DATA_DIR/index.json")
    echo -e "${CYAN}Index Status:${NC}"
    echo "  Last updated: $index_updated"
else
    echo -e "${YELLOW}⚠️  Index not found${NC}"
fi

echo ""
echo -e "${BLUE}Statistics complete.${NC}"
