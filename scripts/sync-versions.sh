#!/bin/bash
# Synchronize version across .metadata, SKILL.md, HUB_MAP.md
# Usage: sync-versions.sh <skill-name>

set -e

SKILL_NAME=$1
if [ -z "$SKILL_NAME" ]; then
    echo "Usage: sync-versions.sh <skill-name>"
    echo ""
    echo "Examples:"
    echo "  sync-versions.sh session-memoria"
    echo "  sync-versions.sh x-mem"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HUB_DIR="$(dirname "$SCRIPT_DIR")"
SKILL_DIR="$HUB_DIR/$SKILL_NAME"
METADATA="$SKILL_DIR/.metadata"
SKILLMD="$SKILL_DIR/SKILL.md"
HUBMAP="$HUB_DIR/HUB_MAP.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Version Sync - $SKILL_NAME${NC}"
echo ""

# Validate skill directory exists
if [ ! -d "$SKILL_DIR" ]; then
    echo -e "${RED}Error: Skill directory not found: $SKILL_DIR${NC}"
    exit 1
fi

# Validate files exist
if [ ! -f "$METADATA" ]; then
    echo -e "${RED}Error: $METADATA not found${NC}"
    exit 1
fi

if [ ! -f "$SKILLMD" ]; then
    echo -e "${YELLOW}Warning: $SKILLMD not found (skipping)${NC}"
    SKILLMD=""
fi

if [ ! -f "$HUBMAP" ]; then
    echo -e "${YELLOW}Warning: $HUBMAP not found (skipping)${NC}"
    HUBMAP=""
fi

# Extract version from .metadata (source of truth)
METADATA_VER=$(grep '"version"' "$METADATA" | sed 's/.*"version": *"\([^"]*\)".*/\1/')
echo -e "Source version (from .metadata): ${GREEN}v$METADATA_VER${NC}"
echo ""

# Update SKILL.md header if exists
if [ -n "$SKILLMD" ] && [ -f "$SKILLMD" ]; then
    if grep -q '^\*\*Version:\*\*' "$SKILLMD"; then
        sed -i "s/^\*\*Version:\*\* .*/\*\*Version:\*\* $METADATA_VER/" "$SKILLMD"
        echo -e "${GREEN}✅ Updated SKILL.md version to v$METADATA_VER${NC}"
    else
        echo -e "${YELLOW}⚠️  Warning: Version header not found in SKILL.md${NC}"
    fi
fi

# Update HUB_MAP.md reference if exists
if [ -n "$HUBMAP" ] && [ -f "$HUBMAP" ]; then
    # Find current version in HUB_MAP for this skill
    CURRENT_HUBMAP_VER=$(grep -i "$SKILL_NAME" "$HUBMAP" | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)

    if [ -n "$CURRENT_HUBMAP_VER" ]; then
        # Replace version in HUB_MAP
        sed -i "s/\($SKILL_NAME.*\)$CURRENT_HUBMAP_VER/\1v$METADATA_VER/" "$HUBMAP"
        echo -e "${GREEN}✅ Updated HUB_MAP.md reference to v$METADATA_VER${NC}"
    else
        echo -e "${YELLOW}⚠️  Warning: Skill '$SKILL_NAME' version not found in HUB_MAP.md${NC}"
    fi
fi

# Update last_updated date in .metadata
TODAY=$(date +%Y-%m-%d)
sed -i "s/\"last_updated\": *\"[^\"]*\"/\"last_updated\": \"$TODAY\"/" "$METADATA"
echo -e "${GREEN}✅ Updated last_updated to $TODAY${NC}"

echo ""
echo -e "${GREEN}✅ Version synchronization complete for $SKILL_NAME${NC}"
echo -e "   All files now at ${BLUE}v$METADATA_VER${NC}"
