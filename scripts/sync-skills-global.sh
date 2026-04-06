#!/bin/bash
# sync-skills-global.sh
# Automatically sync all skills from claude-intelligence-hub to global ~/.claude/skills/
# Usage: ./sync-skills-global.sh

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directories
REPO_ROOT="/c/ai/claude-intelligence-hub"
SKILLS_DIR="/c/Users/{USERNAME}/.claude/skills"

echo -e "${BLUE}🔄 Syncing skills to global directory...${NC}\n"

# Create skills directory if it doesn't exist
mkdir -p "$SKILLS_DIR"

# Counter
new_count=0
existing_count=0
updated_count=0

# Find all SKILL.md files and create symlinks
while IFS= read -r skill_file; do
    # Get the skill directory (parent of SKILL.md)
    skill_dir=$(dirname "$skill_file")
    skill_name=$(basename "$skill_dir")

    # Skip if it's in a subdirectory like playbook
    if [[ "$skill_file" == *"/playbook/"* ]]; then
        continue
    fi

    # Target symlink path
    target="$SKILLS_DIR/$skill_name"

    # Check if symlink already exists
    if [ -L "$target" ]; then
        # Verify it points to the correct location
        current_target=$(readlink "$target")
        if [ "$current_target" = "$skill_dir" ]; then
            echo -e "${GREEN}✓${NC} $skill_name (already linked)"
            ((existing_count++))
        else
            # Update symlink if it points to wrong location
            rm "$target"
            ln -s "$skill_dir" "$target"
            echo -e "${YELLOW}↻${NC} $skill_name (updated link)"
            ((updated_count++))
        fi
    elif [ -e "$target" ]; then
        # Path exists but is not a symlink - warn user
        echo -e "${YELLOW}⚠${NC}  $skill_name (exists but not a symlink - skipping)"
    else
        # Create new symlink
        ln -s "$skill_dir" "$target"
        echo -e "${GREEN}✓${NC} $skill_name (new)"
        ((new_count++))
    fi

done < <(find "$REPO_ROOT" -name "SKILL.md" -type f | grep -v "/playbook/")

# Summary
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Sync complete!${NC}"
echo -e "   New skills:      $new_count"
echo -e "   Existing skills: $existing_count"
echo -e "   Updated links:   $updated_count"
echo -e "   Total skills:    $((new_count + existing_count + updated_count))"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\n${YELLOW}📝 Note:${NC} Restart Claude Code to load new skills"
