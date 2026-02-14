#!/bin/bash
# Incremental skill update procedure
# Usage: update-skill.sh <skill-name> <patch|minor|major> [description]

set -e

SKILL_NAME=$1
UPDATE_TYPE=$2
DESCRIPTION=$3

if [ -z "$SKILL_NAME" ] || [ -z "$UPDATE_TYPE" ]; then
    echo "Usage: update-skill.sh <skill-name> <patch|minor|major> [description]"
    echo ""
    echo "Update types:"
    echo "  patch - Bug fixes, small changes (1.0.0 → 1.0.1)"
    echo "  minor - New features, backward compatible (1.0.0 → 1.1.0)"
    echo "  major - Breaking changes (1.0.0 → 2.0.0)"
    echo ""
    echo "Examples:"
    echo "  update-skill.sh session-memoria patch 'Fix entry ID bug'"
    echo "  update-skill.sh x-mem minor 'Add compact command'"
    echo "  update-skill.sh jimmy-core-preferences major 'Module 3 governance'"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HUB_DIR="$(dirname "$SCRIPT_DIR")"
SKILL_DIR="$HUB_DIR/$SKILL_NAME"
METADATA="$SKILL_DIR/.metadata"
CHANGELOG="$SKILL_DIR/CHANGELOG.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📦 Skill Update - $SKILL_NAME${NC}"
echo ""

# Validate skill directory exists
if [ ! -d "$SKILL_DIR" ]; then
    echo -e "${RED}Error: Skill directory not found: $SKILL_DIR${NC}"
    exit 1
fi

# Validate .metadata exists
if [ ! -f "$METADATA" ]; then
    echo -e "${RED}Error: .metadata not found: $METADATA${NC}"
    exit 1
fi

# Extract current version
CURRENT_VER=$(grep '"version"' "$METADATA" | sed 's/.*"version": *"\([^"]*\)".*/\1/')
echo -e "Current version: ${YELLOW}v$CURRENT_VER${NC}"

# Parse semver
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VER"

# Increment based on update type
case "$UPDATE_TYPE" in
    patch)
        PATCH=$((PATCH + 1))
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    *)
        echo -e "${RED}Error: Invalid update type '$UPDATE_TYPE'${NC}"
        echo "Use: patch, minor, or major"
        exit 1
        ;;
esac

NEW_VER="$MAJOR.$MINOR.$PATCH"
echo -e "New version: ${GREEN}v$NEW_VER${NC}"
echo ""

# Update .metadata version
sed -i "s/\"version\": *\"$CURRENT_VER\"/\"version\": \"$NEW_VER\"/" "$METADATA"
echo -e "${GREEN}✅ Updated .metadata to v$NEW_VER${NC}"

# Run version sync
echo ""
bash "$SCRIPT_DIR/sync-versions.sh" "$SKILL_NAME"

# Update CHANGELOG.md if exists
if [ -f "$CHANGELOG" ]; then
    echo ""
    echo -e "${BLUE}Updating CHANGELOG.md...${NC}"

    TODAY=$(date +%Y-%m-%d)

    # Prepare new entry
    NEW_ENTRY="## [$NEW_VER] - $TODAY\n\n### ${UPDATE_TYPE^}\n- ${DESCRIPTION:-No description provided}\n\n---\n"

    # Insert after "# Changelog" header (usually line 1-3)
    # Find line number of "# Changelog"
    CHANGELOG_LINE=$(grep -n "^# Changelog" "$CHANGELOG" | head -1 | cut -d: -f1)

    if [ -n "$CHANGELOG_LINE" ]; then
        # Insert new entry after changelog header
        sed -i "${CHANGELOG_LINE}a\\
\\
$NEW_ENTRY" "$CHANGELOG"
        echo -e "${GREEN}✅ Updated CHANGELOG.md with [$NEW_VER] entry${NC}"
    else
        echo -e "${YELLOW}⚠️  Warning: '# Changelog' header not found${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Warning: CHANGELOG.md not found${NC}"
fi

echo ""
echo -e "${GREEN}✅ Skill update complete${NC}"
echo -e "   ${BLUE}$SKILL_NAME${NC}: ${YELLOW}v$CURRENT_VER${NC} → ${GREEN}v$NEW_VER${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review changes: git diff"
echo "  2. Commit: git add . && git commit -m 'Update $SKILL_NAME to v$NEW_VER'"
echo "  3. Push: git push origin main"
