#!/usr/bin/env bash
# ============================================================
# manage-global-skills.sh — Global Skills Symlink Manager
#
# Purpose: Verifies and fixes symlinks/junctions between
#          ~/.claude/skills/ and the hub source of truth at
#          claude-intelligence-hub/.
#
# Operations:
#   verify  — Check all skills: symlink, copy, or missing
#   fix     — Replace copies with junctions, create missing ones
#   list    — List all skills with status
#
# Usage:
#   bash scripts/manage-global-skills.sh [verify|fix|list]
#
# Cross-machine: Resolves hub path from script location.
#                Works on any machine where the hub exists.
#
# Why junctions, not copies:
#   A copy drifts on the next hub update. A junction always
#   reflects the hub source of truth. This matters for
#   bootstrap, machine switching, and multi-agent consistency.
#
# Windows note:
#   On Windows, this script uses PowerShell internally for
#   junction creation (New-Item -ItemType Junction) because
#   bash ln -s creates Unix symlinks that some Windows tools
#   cannot follow. Junctions are universally supported.
# ============================================================

set -euo pipefail

# Resolve hub root from script location
HUB_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$HOME/.claude/skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Operation (default: verify)
OP="${1:-verify}"

# Get list of skill directories from hub (exclude non-skill dirs)
NON_SKILL_DIRS="scripts references .git .github node_modules"

get_hub_skills() {
  for dir in "$HUB_ROOT"/*/; do
    dirname="$(basename "$dir")"
    # Skip non-skill directories
    skip=false
    for ns in $NON_SKILL_DIRS; do
      if [ "$dirname" = "$ns" ]; then
        skip=true
        break
      fi
    done
    if [ "$skip" = false ] && [ -f "$dir/SKILL.md" ]; then
      echo "$dirname"
    fi
  done
}

# Check a single skill
check_skill() {
  local skill="$1"
  local target="$SKILLS_DIR/$skill"
  local hub_source="$HUB_ROOT/$skill"

  if [ ! -e "$target" ]; then
    echo "MISSING"
  elif [ -L "$target" ]; then
    # Unix symlink — check if it points to hub
    local link_target
    link_target="$(readlink "$target" 2>/dev/null || echo "UNKNOWN")"
    if echo "$link_target" | grep -q "claude-intelligence-hub/$skill"; then
      echo "OK_SYMLINK"
    else
      echo "WRONG_SYMLINK:$link_target"
    fi
  elif [ -d "$target" ]; then
    # Directory — could be junction or copy
    # On Windows, check if it's a junction via PowerShell
    local is_junction
    is_junction="$(powershell.exe -NoProfile -Command "
      \$item = Get-Item -Force '$target' -ErrorAction SilentlyContinue
      if (\$item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        Write-Output 'JUNCTION'
      } else {
        Write-Output 'COPY'
      }
    " 2>/dev/null | tr -d '\r')"

    if [ "$is_junction" = "JUNCTION" ]; then
      echo "OK_JUNCTION"
    else
      echo "COPY"
    fi
  else
    echo "UNKNOWN"
  fi
}

# Fix a single skill
fix_skill() {
  local skill="$1"
  local status="$2"
  local target="$SKILLS_DIR/$skill"
  local hub_source="$HUB_ROOT/$skill"
  local win_target
  local win_source

  # Convert to Windows paths for PowerShell
  win_target="$(cygpath -w "$target" 2>/dev/null || echo "$target")"
  win_source="$(cygpath -w "$hub_source" 2>/dev/null || echo "$hub_source")"

  case "$status" in
    MISSING)
      echo -e "  ${YELLOW}Creating junction...${NC}"
      powershell.exe -NoProfile -Command "New-Item -ItemType Junction -Path '$win_target' -Target '$win_source' | Out-Null"
      echo -e "  ${GREEN}Created junction: $skill -> hub${NC}"
      ;;
    COPY)
      echo -e "  ${YELLOW}Replacing copy with junction...${NC}"
      powershell.exe -NoProfile -Command "Remove-Item -Recurse -Force '$win_target'; New-Item -ItemType Junction -Path '$win_target' -Target '$win_source' | Out-Null"
      echo -e "  ${GREEN}Replaced copy with junction: $skill -> hub${NC}"
      ;;
    WRONG_SYMLINK:*)
      echo -e "  ${YELLOW}Fixing symlink target...${NC}"
      rm -f "$target"
      powershell.exe -NoProfile -Command "New-Item -ItemType Junction -Path '$win_target' -Target '$win_source' | Out-Null"
      echo -e "  ${GREEN}Fixed symlink: $skill -> hub${NC}"
      ;;
    *)
      echo -e "  ${GREEN}No fix needed${NC}"
      ;;
  esac
}

# Main
echo "=== Global Skills Symlink Manager ==="
echo "Hub:       $HUB_ROOT"
echo "Skills:    $SKILLS_DIR"
echo "Operation: $OP"
echo "Time:      $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "======================================"
echo ""

# Ensure skills directory exists
mkdir -p "$SKILLS_DIR"

total=0
ok=0
issues=0
fixed=0

while IFS= read -r skill; do
  total=$((total + 1))
  status="$(check_skill "$skill")"

  case "$OP" in
    list)
      printf "%-40s %s\n" "$skill" "$status"
      ;;
    verify)
      case "$status" in
        OK_SYMLINK|OK_JUNCTION)
          echo -e "${GREEN}OK${NC}  $skill"
          ok=$((ok + 1))
          ;;
        *)
          echo -e "${RED}ISSUE${NC}  $skill  ($status)"
          issues=$((issues + 1))
          ;;
      esac
      ;;
    fix)
      case "$status" in
        OK_SYMLINK|OK_JUNCTION)
          echo -e "${GREEN}OK${NC}  $skill"
          ok=$((ok + 1))
          ;;
        *)
          echo -e "${RED}FIX${NC}  $skill  ($status)"
          fix_skill "$skill" "$status"
          fixed=$((fixed + 1))
          ;;
      esac
      ;;
    *)
      echo "Unknown operation: $OP"
      echo "Usage: manage-global-skills.sh [verify|fix|list]"
      exit 1
      ;;
  esac
done < <(get_hub_skills)

echo ""
echo "=== Summary ==="
echo "Total skills: $total"
if [ "$OP" = "verify" ]; then
  echo -e "${GREEN}OK: $ok${NC}"
  if [ "$issues" -gt 0 ]; then
    echo -e "${RED}Issues: $issues${NC}"
    echo "Run with 'fix' to resolve: bash scripts/manage-global-skills.sh fix"
  fi
elif [ "$OP" = "fix" ]; then
  echo -e "${GREEN}OK: $ok${NC}"
  echo -e "${YELLOW}Fixed: $fixed${NC}"
fi
echo "================"
